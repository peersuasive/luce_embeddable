-include Makefile.config

## TODO: create a version with an optional oResult.h
##       so that we can use this as a simple loader looking at specific folders
##       for specific files (say, luce/main.lua)

VERSION			?= $(shell cd sources/;\
					tag=`git describe 2>/dev/null| sed -e 's|^[v]*\([0-9]\+[^-]\+[-][^-]\+\)[-][^-]\+$$|\1|'`;\
				    echo "$${tag:-0.1}")

STATIC 			?= 1
DEBUG 			?=

CCACHE 			?=

LUCE_HOME   	?= $(HOME)/src-private/luce
LUCE_S_HOME 	?= $(HOME)/src-private/luce_squishable

#OS 				= $(shell uname -a)
CXX 			= g++
LUAC 			= luac
STRIP           = strip
BIN2C      		= ./bin2c
UPX 		    = echo
CFLAGS   		=
EXTRALIBS 		= 
NAME     		?= Luce Embedded Demo
X 				= 
STRIP_OPTIONS 	= --strip-unneeded

SQUISHY 		?= example/squishy

TARGET_JIT 		= libluajit.a_check
ORESULT_MAIN	= luce.lua
LUA_DEPS    	:= $(shell ./get_lua_deps $(SQUISHY))
ifneq ($(filter ERROR%,$(LUA_DEPS)),)
 $(error $(LUA_DEPS))
endif
LUA_MAIN        := $(shell cat $(SQUISHY) |grep '^\ *Main'|awk '{print $$NF}')

EXTRA_SOURCES   = 

ifeq (1,$(DEBUG))
	XDEBUG=-D"DEBUG=1" -D"_DEBUG=1" -g
	CONFIG=Debug
	CFLAGS += -g
else
	XDEBUG=-D"NDEBUG=1" -D"_NDEBUG=1"
	CONFIG=Release
	#CFLAGS += -Os #size
	CFLAGS += -O2 # speed, could try -O3
endif

ifeq ($(FULL_STATIC),1)
	TNAME 		 := $(NAME)_sf
	FULL_XSTATIC  = -DFULL_XSTATIC=1
	XSTATIC 	  = -DXSTATIC=1
	CFLAGS 		 += $(FULL_XSTATIC) $(XSTATIC)
	ORESULT_MAIN  = oResult.lua
else
ifeq ($(STATIC),1)
	TNAME 	:= $(NAME)_s
	XSTATIC  = -DXSTATIC=1
	CFLAGS 	+= $(XSTATIC)
else
	TNAME 	 = $(NAME)
endif
endif

ifeq (,$(LUA_MAIN))
	LUA_MAIN = $(ORESULT_MAIN)
endif

ifeq ($(LUA52),1)
	IS52  	    = 52
	TNAME 	   := $(TNAME)52
	TARGET_JIT  =
endif

WITH_OPENGL=1
ifeq ($(OPENGL),0)
	WITH_OPENGL=
endif

ifeq ($(XCROSS),win)
	PRE 	= i686-pc-mingw32
	X 		= /opt/mingw/usr/bin/$(PRE)-
	CXX	    = $(X)g++
	STRIP   = $(X)strip
	UPX     = echo $(X)upx.exe
	EXT     = .exe
	PREPARE_APP = win_prep_app
	# provided by PREPARE_APP
 	EXTRA_SOURCES = app_res.o 
	BUNDLE_APP  = win_app

	CFLAGS    += -march=i686 
	#CFLAGS += --export-all-symbols
	LDFLAGS   += -march=i686
	#LDLAGS += --export-all-symbols

	ifeq ($(LUA52),1)
		CFLAGS    += -I/opt/mingw/usr/$(PRE)/include/lua5.2
		EXTRALIBS += -llua5.2
	else
		CFLAGS    += -I./luajit-2.0/src -I./luajit/src
		EXTRALIBS += libluajit.a
		EXTRALIBS += -lstdc++ -lm
	endif

	ifneq (,$(XSTATIC))
		STATIC_LIBS = -lfreetype -lpthread -lws2_32 -lshlwapi 
		STATIC_LIBS += -luuid -lversion -lwinmm -lwininet -lole32 -lgdi32 -lcomdlg32 -limm32 -loleaut32
		ifneq (,$(WITH_OPENGL))
			STATIC_LIBS += -lopengl32
		endif
		STATIC_LIBS += -lcomctl32 -Wl,--subsystem,windows
		ifneq (,$(DEV))
	 		STATIC_OBJS = obj/win$(IS52)/*.o
		else
			ifeq (1,$(DEBUG))
	 			STATIC_OBJS = sources/win/libluce$(IS52)_d.a
				STRIP :=
			else
	 			STATIC_OBJS = sources/win/libluce$(IS52).a
			endif
		endif
	endif

else
ifeq ($(XCROSS),osx)
	ifneq (,$(CCACHE))
		export CCACHE_CPP2 = yes
		CFLAGS+= -Qunused-arguments -fcolor-diagnostics
	endif
	#eval `/opt/osxcross/target/bin/osxcross-env`
	export PATH := $(PATH):/opt/osxcross/target/bin
	export LD_LIBRARY_PATH := $(LD_LIBRAY_PATH):/opt/osxcross/target/bin/../lib:/usr/lib/llvm-3.3/lib

	SDK_VER=10.8
	SDK_MIN=10.6
	unexport CODESIGN_ALLOCATE
	X 	= x86_64-apple-darwin12-
	EXT = _osx
	CXX = o64-clang++
	UPX = echo $(X)upx
	BUNDLE_APP = osx_app

	STRIP = echo
	# -S -x ?
	STRIP_OPTIONS =
	CFLAGS += -x objective-c++ 
	#CFLAGS += -MMD -Wno-deprecated-register 
	CFLAGS += -stdlib=libc++ 
	CFLAGS += -mmacosx-version-min=$(SDK_MIN)
	CFLAGS += -fpascal-strings -fmessage-length=0 -fasm-blocks -fstrict-aliasing -fvisibility-inlines-hidden 
	#CFLAGS += -fno-objc-arc

	LDFLAGS += -stdlib=libc++ 
	LDFLAGS += -pagezero_size 10000 -image_base 100000000 
	LDFLAGS += -fnested-functions 
	LDFLAGS += -mmacosx-version-min=$(SDK_MIN)
	LDFLAGS += -demangle
	#LDFLAGS += -fno-objc-arc

	ifeq ($(LUA52),1)
		CFLAGS += -I/opt/zmq-osx/include/lua5.2
		EXTRALIBS += -llua5.2
	else
		CFLAGS 	  += -I./luajit-2.0/src -I./luajit/src
		EXTRALIBS += libluajit.a
	endif

	ifneq (,$(XSTATIC))
		FRAMEWORKS = -framework Carbon -framework Cocoa -framework IOKit 
		FRAMEWORKS += -framework QuartzCore -framework WebKit -framework System
		FRAMEWORKS += -framework AppKit
		ifneq (,$(WITH_OPENGL))
			FRAMEWORKS += -framework OpenGL
		endif
		STATIC_LIBS = $(FRAMEWORKS)
		ifneq (,$(DEV))
	 		STATIC_OBJS = obj/osx$(IS52)/*.o
		else
			ifeq (1,$(DEBUG))
	 			STATIC_OBJS = sources/osx/libluce$(IS52)_d.a
				STRIP :=
			else
	 			STATIC_OBJS = sources/osx/libluce$(IS52).a
			endif
		endif
	endif
 	#EXTRA_SOURCES = osx_main.o

else
ifeq ($(XCROSS),ios)
	#eval `/opt/osxcross/target/bin/osxcross-env`
	export PATH := $(PATH):/opt/osxcross/target/bin
	export LD_LIBRARY_PATH := $(LD_LIBRAY_PATH):/opt/osxcross/target/bin/../lib:/usr/lib/llvm-3.3/lib

	## always static on ios
	FULL_XSTATIC  = -DFULL_XSTATIC=1
	XSTATIC 	  = -DXSTATIC=1
	CFLAGS 		 += $(FULL_XSTATIC) $(XSTATIC)
	ORESULT_MAIN  = oResult.lua

	## TODO: MUST create an .app, anyway !
	unexport CODESIGN_ALLOCATE
	SDK_VER=6.1
	SDK_MIN=5.1
	X 	= /opt/ios-apple-darwin-11/usr/bin/arm-apple-darwin11-
	EXT = _ios
	CXX = /opt/ios-apple-darwin-11/usr/bin/ios-clang++
	UPX = echo $(X)upx
	BUNDLE_APP = ios_app

	## already signed, so better skip stripping,
	## or resign with 
	#export CODESIGN_ALLOCATE=/opt/ios.../usr/bin/arm-apple-darwin11-codesign_allocate; /opt/ios.../usr/bin/ldid -S demo_ios
	STRIP = echo
	CFLAGS += -x objective-c++ 
	#CFLAGS += -MMD -Wno-deprecated-register 
	CFLAGS += -stdlib=libc++ 
	CFLAGS += -miphoneos-version-min=$(SDK_MIN)
	CFLAGS += -fpascal-strings -fmessage-length=0 -fasm-blocks -fstrict-aliasing -fvisibility-inlines-hidden 

	## provides C++
	CFLAGS += -I/opt/osxcross/ios/libcxx-3.4/include

	CFLAGS += -arch armv7 
	LDFGLAGS += -arch armv7
	
	LDFLAGS += -stdlib=libc++ 
	LDFLAGS += -fnested-functions -fmessage-length=0 -fpascal-strings -fstrict-aliasing -fasm-blocks -fobjc-link-runtime 
	LDFLAGS += -miphoneos-version-min=$(SDK_MIN)
	LDFLAGS += -stdlib=libc++ -std=c++0x -std=c++11
	LDFLAGS += -framework CoreGraphics -framework CoreText -framework Foundation 
	LDFLAGS += -framework QuartzCore -framework UIKit 
	ifneq (,$(WITH_OPENGL))
		LDFLAGS += -framework OpenGLES
	endif
	LDFLAGS += -lbundle1.o 
	LDFLAGS += -lstdc++
	## ??
	LDFLAGS += 	-arch armv7 

	ifeq ($(LUA52),1)
		CFLAGS += -I/opt/zmq-ios/include/lua5.2
		EXTRALIBS += -llua5.2
	else
		CFLAGS 	  += -I./luajit-2.0/src -I./luajit/src
		EXTRALIBS += libluajit.a
	endif

	TNAME := $(NAME)
	## always true, but if we were to compile luce as a framework, it might not be anymore -- TODO: check iOS doc
	ifneq (,$(XSTATIC))
	ifneq (,$(DEV))
 		STATIC_OBJS = obj/ios$(IS52)/juce_*.om obj/ios$(IS52)/luce*.om
	else
 		STATIC_OBJS = sources/ios/libluce$(IS52).a
	endif
	endif
else
ifeq ($(XCROSS),android)
	## use this to select gcc instead of clang
	export NDK_TOOLCHAIN_VERSION := 4.8
	## OR use this to select the latest clang version:
	#NDK_TOOLCHAIN_VERSION := clang
	## then enable c++11 extentions in source code
	#APP_CPPFLAGS += -std=c++11
	## or use APP_CPPFLAGS := -std=gnu++11
	#LOCAL_CPPFLAGS += -std=c++11
	NDK 	= /opt/android-ndk
	SDK 	= /opt/android-sdk
	SDK_VER	= 14

	ifeq (emul,$(XARCH))
		CC_ARCH  = x86-4.8
		CC_PRE   = i686-linux-android
		ARCH     = x86
		SDK_ARCH = arch-x86
		EXT 	 = _x86_android
	else
		CC_ARCH  = arm-linux-androideabi-4.8
		CC_PRE   = arm-linux-androideabi
		ARCH     = armeabi-v7a
		SDK_ARCH = arch-arm
		EXT 	 = _android
		LDFLAGS	 += -march=armv7-a -mfloat-abi=softfp -Wl,--fix-cortex-a8
	endif

	NDKVER	= $(NDK)/toolchains/$(CC_ARCH)
	X 		= $(NDKVER)/prebuilt/linux-x86_64/bin/$(CC_PRE)-
	CXX	    = $(X)g++
	STRIP   = $(X)strip
	UPX     = echo $(X)upx.exe
	AND     = .so
	BUNDLE_APP = android_app
	CLASS_NAME = $(subst \ ,,$(NAME))

	CFLAGS += -DLUCE_ANDROID=1
	CFLAGS += -D"CLASS_NAME=$(CLASS_NAME)"

	CFLAGS += --sysroot $(NDK)/platforms/android-$(SDK_VER)/$(SDK_ARCH)
	CFLAGS += -I$(NDK)/sources/cxx-stl/gnu-libstdc++/4.8/include
	CFLAGS += -I$(NDK)/sources/cxx-stl/gnu-libstdc++/4.8/libs/$(ARCH)/include
	
	CFLAGS += -fsigned-char -fexceptions -frtti -Wno-psabi

	LDFLAGS += --sysroot $(NDK)/platforms/android-$(SDK_VER)/$(SDK_ARCH)
	LDFLAGS += -L$(NDK)/sources/cxx-stl/gnu-libstdc++/4.8/libs/$(ARCH)

	LDFLAGS += -shared

	EXTRALIBS += -llog
	EXTRALIBS += -lgnustl_static
	EXTRALIBS += -lstdc++

	ifneq (,$(WITH_OPENGL))
		EXTRALIBS += -lGLESv2
	endif

	#LDFLAGS += -L$(NDK)/platforms/android-14/arch-arm/usr/lib 

	ifeq ($(LUA52),1)
		CFLAGS += -I/opt/zmq-android/include/lua5.2
		EXTRALIBS += -llua5.2
	else
		CFLAGS 	  += -I./luajit-2.0/src -I./luajit/src
		EXTRALIBS += libluajit.a
	endif

	ifneq (,$(XSTATIC))
		#STATIC_OBJS = /home/distances/src-private/luce/Builds/Android/libluce_and.a
		EXTRALIBS += -L./obj/and -Lsources/android -lluajit_$(ARCH) -lluce_jni_$(ARCH)
	endif

else
	UPX        = echo ./upx
	BUNDLE_APP = linux_app
	## force compatibility with glibc >= 2.12
	GLIBCV    := $(shell [ `ldd --version|head -n1|awk '{print $$NF}'|cut -f2 -d.` -gt 13 ] && echo true)
	ifeq ($(GLIBCV), true)
		LDFLAGS += -Wl,--wrap=memcpy
		WRAPCPY  = wrap_memcpy.o
	endif

	CFLAGS += -fPIC 
	CFLAGS += -march=native
	LDLAGS += -march=native
	LDFLAGS   += -Wl,-E

	ifeq ($(LUA52),1)
		CFLAGS    += -I/usr/include/lua5.2
		EXTRALIBS += -llua5.2
	else
		CFLAGS 	  += -I./luajit-2.0/src -I./luajit/src
		EXTRALIBS += libluajit.a -lm -ldl
	endif

	ifneq (,$(XSTATIC))
		STATIC_LIBS = -L/usr/X11R6/lib/ 
		STATIC_LIBS += -lX11 -lXext -lXinerama -ldl -lfreetype -lpthread -lrt -lstdc++
		ifneq (,$(WITH_OPENGL))
			STATIC_LIBS += -lGL
		endif
		ifneq (,$(DEV))
	 		STATIC_OBJS = obj/lin$(IS52)/*.o
		else
			ifeq (1,$(DEBUG))
 				STATIC_OBJS = sources/linux/libluce$(IS52)_d.a
				STRIP :=
			else
 				STATIC_OBJS = sources/linux/libluce$(IS52).a
			endif
		endif
	endif

endif # win
endif # osx
endif # ios
endif # and

-include Makefile.extra

LD     = $(CXX)
RM     = rm
SQUISH = ./squish

CFLAGS += $(XDEBUG)
CFLAGS += -std=c++11
CFLAGS += -fomit-frame-pointer -fno-stack-protector
CFLAGS += -MMD
LIBS   += $(EXTRALIBS)
LDFLAGS += -std=c++11
LDFLAGS += -fvisibility=hidden
LDFLAGS += $(XDEBUG)

TARGET ?= $(TNAME)$(EXT)

space  :=
space  +=
TARGET := $(subst $(space),_,$(TARGET))
XNAME  := $(subst $(space),_,$(NAME))

BLACK  := 0
RED    := 1
GREEN  := 2
YELLOW := 3
BLUE   := 4
MAG    := 5
CYAN   := 6
WHITE  := 7
define echoc
	@tput setaf $1
	@tput bold
	@echo $2
	@tput sgr0
endef

all: $(PREPARE_APP) $(TARGET) $(BUNDLE_APP)

allplats:
	@$(call echoc,$(BLUE),"Compiling for Linux...")
	@$(MAKE) --no-print-directory

	@$(call echoc,$(BLUE),"Compiling for Windows...")
	@$(MAKE) --no-print-directory XCROSS=win

	@$(call echoc,$(BLUE),"Compiling for OS X...")
	@$(MAKE) --no-print-directory XCROSS=osx

	@$(call echoc,$(BLUE),"Compiling for iOS...")
	@$(MAKE) --no-print-directory XCROSS=ios

	@$(call echoc,$(BLUE),"Compiling for Android...")
	@$(MAKE) --no-print-directory XCROSS=android

$(TARGET_JIT): luajit/src/luajit$(EXT)
	@ln -sf luajit/src/libluajit.a .
	@$(RM) -f jit
	@ln -sf luajit/src/jit .

bin2c: bin2c.bin

bin2c.bin: bin2c.c
	@echo "Compiling bin2c..."
	@gcc -std=c99 -o bin2c.bin bin2c.c

luajit/src/luajit:
	@echo "Compiling luajit for linux..."
	@cd luajit/src && make clean && make CCACHE=$(CCACHE)

luajit/src/luajit.exe:
	@echo "Compiling luajit for windows..."
	@cd luajit/src && make clean && \
		make CCACHE=$(CCACHE) CC="gcc -m32" HOST_CC="gcc -m32" CROSS=$(X) TARGET_SYS=Windows

luajit/src/luajit_osx:
	@echo "Compiling luajit for osx..."
	@cd luajit/src && make clean && \
		make CCACHE=$(CCACHE) CROSS=$(X) TARGET_SYS=Darwin

luajit/src/luajit_ios:
	@echo "Compiling luajit for ios..."
	@cd luajit/src && make clean && \
		make CCACHE=$(CCACHE) CROSS=$(X) TARGET_SYS=iOS

luajit/src/luajit_android:
	@echo "Compiling luajit for android..."
	@cd luajit/src && make clean && \
		make CCACHE=$(CCACHE) HOST_CC="gcc -m32" CROSS=$(X) TARGET_SYS=Android

luajit/src/luajit_x86_android:
	@echo "Compiling luajit for android (x86)..."
	@cd luajit/src && make clean && \
		make CCACHE=$(CCACHE) HOST_CC="gcc -m32" CROSS=$(X) TARGET_SYS=Androidx86

main.o: main.cpp $(TARGET_JIT) oResult.h
	@$(LUAC) -p $(LUA_MAIN)
	@echo "Compiling main..."
	@$(CXX) $(CFLAGS) -c -o $@ $<

squishy: $(SQUISHY)
	@ln -sf $(SQUISHY) squishy

oResult.lua: $(LUA_DEPS) squishy luce.lua
	@$(SQUISH) --no-executable

oResult.h: bin2c.bin $(ORESULT_MAIN)
	@$(LUAC) -p $(LUA_MAIN)
	@echo "Embedding luce (with main class $(ORESULT_MAIN))"
	@$(BIN2C) $(ORESULT_MAIN) oResult.h oResult

$(LUCE_S_HOME)/oluce.lua:
	@cd "$(LUCE_S_HOME)" && make

luce.lua: $(LUCE_S_HOME)/oluce.lua
	@echo "Building embedded lua class..."
	@cp -f $(LUCE_S_HOME)/oluce.lua luce.lua

$(WRAPCPY): wrap_memcpy.c
	@echo "Adding memcpy wrapper..."
	@gcc -c -o $@ $<

$(TARGET): main.o $(WRAPCPY) $(EXTRA_SOURCES) 
	@echo "Linking... (static ? $(or $(and $(XSTATIC), yes), no))"
	@echo "   (full static ? $(or $(and $(FULL_STATIC), yes), no))"
	@$(LD) $(LDFLAGS) -o $(TARGET) $< $(WRAPCPY) $(EXTRA_SOURCES) $(STATIC_OBJS) $(LIBS) $(STATIC_LIBS)
	@$(STRIP) $(STRIP_OPTIONS) $(TARGET)
	-@$(UPX) $(TARGET)
	@echo OK

linux_app: $(TARGET) create_bundle
	@echo "Creating bundle..."
	-@$(RM) -rf build/$(CONFIG)/"$(NAME)"
	@./create_bundle lin $(TARGET) "$(NAME)" "$(CONFIG)" "$(VERSION)"

osx_app: $(TARGET) create_bundle
	@echo "Creating bundle..."
	-@$(RM) -rf build/$(CONFIG)/"$(NAME).app"
	@./create_bundle osx $(TARGET) "$(NAME)" "$(CONFIG)" "$(VERSION)"
	
ios_app: $(TARGET) create_bundle
	@echo "Creating bundle..."
	-@$(RM) -rf build/$(CONFIG)/"$(NAME).app"
	@./create_bundle ios $(TARGET) "$(NAME)" "$(CONFIG)" "$(VERSION)"

android_app: $(TARGET) create_bundle
	@echo "Creating bundle..."
	-@$(RM) -rf build/$(CONFIG)/"$(NAME)"
	@./create_bundle android $(TARGET) "$(NAME)" "$(CONFIG)" "$(VERSION)" "$(ARCH)" "$(SDK_VER)" "$(SDK)"

win_prep_app: create_bundle
	@echo "Compiling windows resources..."
	@./create_bundle win prepare $(TARGET) "$(NAME)" "$(CONFIG)" "$(VERSION)"

win_app: $(TARGET) create_bundle
	@echo "Creating windows application..."
	-@$(RM) -rf build/$(CONFIG)/windows/"$(NAME)"
	@./create_bundle win $(TARGET) "$(NAME)" "$(CONFIG)" "$(VERSION)"

test: $(TARGET)
	./$(TARGET)

clean:
	@$(RM) -f main.o oResult.h oResult.lua *.d $(WRAPCPY)
	@$(RM) -f "$(XNAME:$(space)=_)" "$(XNAME)52" "$(XNAME)_s" "$(XNAME)_s52" "$(XNAME)_sf" "$(XNAME)_sf52"
	@$(RM) -f "$(XNAME)"*.exe
	@$(RM) -f "$(XNAME)"*_osx
	@$(RM) -f "$(XNAME)"*_ios
	@$(RM) -f "$(XNAME)"*_android
	@$(RM) -f $(EXTRA_SOURCES) app_res.o

extraclean: clean
	@$(RM) -rf build

distclean: extraclean
	@cd ./luajit/src && make clean
	@$(RM) -f libluajit.a libluajit.win.a jit bin2c.bin

purge: distclean
	@$(RM) -f luce.lua

xtest:
	@echo "v: '$(VERSION)'"

-include $(OBJECTS:%.o=%.d)

.PHONY: clean extraclean distclean libluajit.a_check
