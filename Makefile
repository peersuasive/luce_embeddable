


## TODO: create a version with an optional oResult.h
##       so that we can use this as a simple loader looking at specific folders
##       for specific files (say, luce/main.lua)

STATIC ?= 1

LUCE_HOME = $(HOME)/src-private/luce

#OS 				= $(shell uname -a)
CXX 			= g++
STRIP           = strip
BIN2C      		= ./bin2c
UPX 		    = echo
CFLAGS   		=
EXTRALIBS 		= 
NAME     		:= demo
X 				= 
STRIP_OPTIONS 	= --strip-unneeded

TARGET_JIT 		= libluajit.a_check
ORESULT_MAIN	= luce.lua
LUA_DEPS    	= $(shell ./get_lua_deps)
EXTRA_SOURCES   = 

ifdef $(DEBUG)
	CFLAGS += -g
else
	CFLAGS += -Os
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

ifeq ($(LUA52),1)
	IS52  	    = 52
	TNAME 	   := $(TNAME)52
	TARGET_JIT  =
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
		CFLAGS    += -I./luajit-2.0/src
		EXTRALIBS += libluajit.a
		EXTRALIBS += -lstdc++ -lm
	endif

	ifneq (,$(XSTATIC))
		STATIC_LIBS = -lfreetype -lpthread -lws2_32 -lshlwapi 
		STATIC_LIBS += -luuid -lversion -lwinmm -lwininet -lole32 -lgdi32 -lcomdlg32 -limm32 -loleaut32
		STATIC_LIBS += -lcomctl32 -Wl,--subsystem,windows
 		STATIC_OBJS = obj/win$(IS52)/*.o
	endif

else
ifeq ($(XCROSS),osx)
	#eval `/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin/osxcross-env`
	export PATH := $(PATH):/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin:/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin
	export LD_LIBRARY_PATH := $(LD_LIBRAY_PATH):/usr/local/src/vcs/compiler/osxcross/target/bin/../lib:/usr/lib/llvm-3.3/lib:/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin/../lib:/usr/lib/llvm-3.3/lib:/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin/../lib:/usr/lib/llvm-3.3/lib:/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin/../lib:/usr/lib/llvm-3.3/lib

	SDK_VER=10.8
	SDK_MIN=10.6
	## TODO: SHOULD create an .app, at least for non-static
	unexport CODESIGN_ALLOCATE
	#export CODESIGN_ALLOCATE=/home/distances/src-private/luce/Builds/iOS/tmp/u/usr/bin/arm-apple-darwin11-codesign_allocate
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
	CFLAGS += -Iluajit-2.0/src

	LDFLAGS += -stdlib=libc++ 
	LDFLAGS += -pagezero_size 10000 -image_base 100000000 
	LDFLAGS += -fnested-functions 
	LDFLAGS += -mmacosx-version-min=$(SDK_MIN)
	LDFLAGS += -demangle

	ifeq ($(LUA52),1)
		CFLAGS += -I/opt/zmq-osx/include/lua5.2
		EXTRALIBS += -llua5.2
	else
		CFLAGS    += -I./luajit-2.0/src
		EXTRALIBS += libluajit.a
	endif

	ifneq (,$(XSTATIC))
		FRAMEWORKS = -framework Carbon -framework Cocoa -framework IOKit 
		FRAMEWORKS += -framework QuartzCore -framework WebKit -framework System
		FRAMEWORKS += -framework AppKit
		STATIC_LIBS = $(FRAMEWORKS)
 		STATIC_OBJS = obj/osx$(IS52)/*.o
	endif
 	#EXTRA_SOURCES = osx_main.o

else
ifeq ($(XCROSS),ios)
	#eval `/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin/osxcross-env`
	export PATH := $(PATH):/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin:/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin
	export LD_LIBRARY_PATH := $(LD_LIBRAY_PATH):/usr/local/src/vcs/compiler/osxcross/target/bin/../lib:/usr/lib/llvm-3.3/lib:/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin/../lib:/usr/lib/llvm-3.3/lib:/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin/../lib:/usr/lib/llvm-3.3/lib:/usr/local/src/vcs/compiler/osxcross/target.manatsu/bin/../lib:/usr/lib/llvm-3.3/lib
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
	#export CODESIGN_ALLOCATE=/home/opt/ios.../usr/bin/arm-apple-darwin11-codesign_allocate; /opt/ios.../usr/bin/ldid -S demo_ios
	STRIP = echo
	CFLAGS += -x objective-c++ 
	#CFLAGS += -MMD -Wno-deprecated-register 
	CFLAGS += -stdlib=libc++ 
	CFLAGS += -miphoneos-version-min=$(SDK_MIN)
	CFLAGS += -fpascal-strings -fmessage-length=0 -fasm-blocks -fstrict-aliasing -fvisibility-inlines-hidden 
	CFLAGS += -Iluajit-2.0/src

	## ??
	CFLAGS += -I/usr/local/src/vcs/compiler/osxcross/ios/libcxx-3.4/include
	## ??
	CFLAGS += -arch armv7 
	LDFGLAGS += -arch armv7
	
	## ??
	#main.mm -o main.om

	LDFLAGS += -stdlib=libc++ 
	LDFLAGS += -fnested-functions -fmessage-length=0 -fpascal-strings -fstrict-aliasing -fasm-blocks -fobjc-link-runtime 
	LDFLAGS += -miphoneos-version-min=$(SDK_MIN)
	LDFLAGS += -stdlib=libc++ -std=c++0x -std=c++11
	LDFLAGS += -framework CoreGraphics -framework CoreText -framework Foundation 
	LDFLAGS += -framework QuartzCore -framework UIKit 
	LDFLAGS += -lbundle1.o 
	LDFLAGS += -lstdc++
	## ??
	LDFLAGS += 	-arch armv7 

	ifeq ($(LUA52),1)
		CFLAGS += -I/opt/zmq-ios/include/lua5.2
		EXTRALIBS += -llua5.2
	else
		CFLAGS    += -I./luajit-2.0/src
		EXTRALIBS += libluajit.a
	endif


	TNAME := $(NAME)
	## always true, but if we were to compile luce as a framework, it might not be anymore -- TODO: check iOS doc
	ifneq (,$(XSTATIC))
 		STATIC_OBJS = obj/ios$(IS52)/juce_*.om obj/ios$(IS52)/luce*.om
	endif

else
	UPX        = echo ./upx
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
		CFLAGS    += -I./luajit-2.0/src
		EXTRALIBS += libluajit.a -lm -ldl
	endif

	ifneq (,$(XSTATIC))
		STATIC_LIBS = -L/usr/X11R6/lib/ 
		STATIC_LIBS += -lX11 -lXext -lXinerama -ldl -lfreetype -lpthread -lrt -lstdc++
 		STATIC_OBJS = obj/lin$(IS52)/*.o
	endif

endif
endif
endif

include Makefile.extra

LD     = $(CXX)
RM     = rm
SQUISH = ./squish

CFLAGS += -std=c++11
CFLAGS += -fomit-frame-pointer -fno-stack-protector
CFLAGS += -MMD
LIBS   += $(EXTRALIBS)
LDFLAGS += -std=c++11
LDFLAGS += -fvisibility=hidden

TARGET = $(TNAME)$(EXT)

all: $(PREPARE_APP) $(TARGET) $(BUNDLE_APP)

$(TARGET_JIT): luajit-2.0/src/luajit$(EXT)
	@ln -sf luajit-2.0/src/libluajit.a .
	@$(RM) -f jit
	@ln -sf luajit-2.0/src/jit .

bin2c: bin2c.bin

bin2c.bin: bin2c.c
	@echo "Compiling bin2c..."
	@gcc -std=c99 -o bin2c.bin bin2c.c

luajit-2.0/src/luajit:
	@echo "Compiling lujit for linux..."
	@cd luajit-2.0/src && make clean && make

luajit-2.0/src/luajit.exe:
	@echo "Compiling lujit for windows..."
	@cd luajit-2.0/src && make clean && make CC="gcc -m32" HOST_CC="gcc -m32" CROSS=$(X) TARGET_SYS=Windows BUILDMODE=static

luajit-2.0/src/luajit_osx:
	@echo "Compiling lujit for osx..."
	@cd luajit-2.0/src && make clean && make -f Makefile.cross-macosx clean && make -f Makefile.cross-macosx

luajit-2.0/src/luajit_ios:
	@echo "Compiling lujit for ios..."
	@cd luajit-2.0/src && make clean && make -f Makefile.cross-ios clean && make -f Makefile.cross-ios

main.o: main.cpp $(TARGET_JIT) oResult.h
	@echo "Compiling main..."
	@$(CXX) $(CFLAGS) -c -o $@ $<

oResult.lua: $(LUA_DEPS) squishy luce.lua
	@$(SQUISH) --no-executable

oResult.h: bin2c.bin $(ORESULT_MAIN)
	@echo "Embedding luce (with main class $(ORESULT_MAIN))"
	@$(BIN2C) $(ORESULT_MAIN) oResult.h oResult

$(LUCE_HOME)/Source/lua/oluce.lua:
	@cd "$(LUCE_HOME)/Source/lua" && make

luce.lua: $(LUCE_HOME)/Source/lua/oluce.lua
	@echo "Building embedded lua class..."
	@cp -f $(LUCE_HOME)/Source/lua/oluce.lua luce.lua

$(WRAPCPY): wrap_memcpy.c
	@echo "Adding memcpy wrapper..."
	@gcc -c -o $@ $<

$(TARGET): main.o $(WRAPCPY) $(EXTRA_SOURCES) 
	@echo "Linking... (static ? $(or $(and $(XSTATIC), yes), no))"
	@$(LD) $(LDFLAGS) -o $(TARGET) $< $(WRAPCPY) $(EXTRA_SOURCES) $(STATIC_OBJS) $(LIBS) $(STATIC_LIBS)
	@$(STRIP) $(STRIP_OPTIONS) $(TARGET)
	-@$(UPX) $(TARGET)
	@echo OK

osx_app: $(TARGET) create_bundle
	@echo "Creating bundle..."
	-@$(RM) -rf build/$(CONFIG)/$(NAME).app
	@./create_bundle osx $(TARGET) $(NAME)
	
ios_app: $(TARGET) create_bundle
	@echo "Creating bundle..."
	-@$(RM) -rf build/$(CONFIG)/$(NAME).app
	@./create_bundle ios $(TARGET) $(NAME)

win_prep_app: create_bundle
	@echo "Compiling windows resources..."
	@./create_bundle win prepare $(TARGET) $(NAME)

win_app: $(TARGET) create_bundle
	@echo "Creating windows application..."
	-@$(RM) -rf build/$(CONFIG)/windows/$(NAME)
	@./create_bundle win $(TARGET) $(NAME)

test: $(TARGET)
	./$(TARGET)

clean:
	@$(RM) -f main.o oResult.h oResult.lua *.d $(WRAPCPY)
	@$(RM) -f $(NAME) $(NAME)52 $(NAME)_s $(NAME)_s52 $(NAME)_sf $(NAME)_sf52
	@$(RM) -f $(NAME)*.exe
	@$(RM) -f $(NAME)*_osx
	@$(RM) -f $(NAME)*_ios
	@$(RM) -f $(EXTRA_SOURCES) app_res.o

extraclean: clean
	@$(RM) -f luce.lua
	@$(RM) -rf build

distclean: extraclean
	@cd ./luajit-2.0/src && make clean
	@$(RM) -f libluajit.a libluajit.win.a jit bin2c.bin

-include $(OBJECTS:%.o=%.d)

.PHONY: clean extraclean distclean libluajit.a_check
