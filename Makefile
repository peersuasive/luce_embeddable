LUCE_HOME = $(HOME)/src-private/luce

#OS 				= $(shell uname -a)
CXX 			= g++
BIN2C      		= ./bin2c
UPX 		    = echo
CFLAGS   		=
EXTRALIBS 		= 
NAME     		:= demo
X 				= 
STRIP_OPTIONS 	= --strip-unneeded
TARGET_JIT 		= libluajit.a_check

ifdef $(DEBUG)
	CFLAGS += -g
endif

ifeq ($(STATIC),1)
	TNAME := $(NAME)_s
	XSTATIC = -DXSTATIC=1
else
	TNAME = $(NAME)
endif
ifeq ($(LUA52),1)
	IS52  = 52
	TNAME := $(TNAME)52
	TARGET_JIT =
endif

ifeq ($(XCROSS),win)
	PRE 	= i686-pc-mingw32
	X 		= /opt/mingw/usr/bin/$(PRE)-
	CXX	    = $(X)g++
	UPX     = echo $(X)upx.exe
	EXT     = .exe

	CFLAGS    += -march=i686 $(XSTATIC)
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
 		STATIC_OBJS = obj/win$(IS52)/*.o
	endif

else
ifeq ($(XCROSS),osx)
	X 	= x86_64-apple-darwin12-
	OSX = _osx
	CXX = o64-clang++
	UPX = echo $(X)upx

	STRIP_OPTIONS =
	CFLAGS += -x objective-c++ 
	#CFLAGS += -MMD -Wno-deprecated-register 
	CFLAGS += -stdlib=libc++ 
	CFLAGS += -mmacosx-version-min=10.5 
	CFLAGS += -fpascal-strings -fmessage-length=0 -fasm-blocks -fstrict-aliasing -fvisibility-inlines-hidden 
	CFLAGS += -Iluajit-2.0/src

	LDFLAGS += -stdlib=libc++ 
	LDFLAGS += -pagezero_size 10000 -image_base 100000000 
	LDFLAGS += -fnested-functions 
	LDFLAGS += -mmacosx-version-min=10.5

	ifeq ($(LUA52),1)
		CFLAGS += -I/opt/zmq-osx/include/lua5.2
		EXTRALIBS += -llua5.2
	else
		CFLAGS    += -I./luajit-2.0/src
		EXTRALIBS += libluajit.a
	endif

	ifneq (,$(XSTATIC))
		STATIC_LIBS = -framework Carbon -framework Cocoa -framework IOKit 
		STATIC_LIBS += -framework QuartzCore -framework WebKit -framework System
 		STATIC_OBJS = obj/osx$(IS52)/*.o
	endif

else
	UPX        = ./upx
	## force compatibility with glibc >= 2.12
	GLIBCV    := $(shell [ `ldd --version|head -n1|awk '{print $$NF}'|cut -f2 -d.` -gt 13 ] && echo true)
	ifeq ($(GLIBCV), true)
		LDFLAGS += -Wl,--wrap=memcpy
		WRAPCPY  = wrap_memcpy.o
	endif

	CFLAGS += -fPIC $(XSTATIC)
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

LD     = $(CXX)
STRIP  = $(X)strip
RM     = rm
SQUISH = ./squish

CFLAGS += -std=c++11
CFLAGS += -Os
CFLAGS += -fomit-frame-pointer -fno-stack-protector
CFLAGS += -MMD
LIBS   += $(EXTRALIBS)
LDFLAGS += -std=c++11
LDFLAGS += -fvisibility=hidden

TARGET = $(TNAME)$(EXT)$(OSX)

all: $(TARGET)

$(TARGET_JIT): luajit-2.0/src/luajit$(EXT)$(OSX)
	@ln -sf luajit-2.0/src/libluajit.a .
	@$(RM) -f jit
	@ln -sf luajit-2.0/src/jit .

bin2c.bin: bin2c.c
	@gcc -std=c99 -o bin2c.bin bin2c.c

luajit-2.0/src/luajit:
	@cd luajit-2.0/src && make clean && make

luajit-2.0/src/luajit.exe:
	@cd luajit-2.0/src && make clean && make HOST_CC="gcc -m32" CROSS=$(X) TARGET_SYS=Windows BUILDMODE=static

luajit-2.0/src/luajit_osx:
	@cd luajit-2.0/src && make clean && make -f Makefile.cross-macosx clean && make -f Makefile.cross-macosx

main.o: main.c $(TARGET_JIT) oResult.h
	$(CXX) $(CFLAGS) -c -o $@ $<

oResult.lua: squishy luce.lua
	@$(SQUISH) --no-executable

oResult.h: bin2c.bin oResult.lua
	@$(BIN2C) oResult.lua oResult.h

$(LUCE_HOME)/Source/lua/oluce.lua:
	@cd "$(LUCE_HOME)/Source/lua" && make

luce.lua: $(LUCE_HOME)/Source/lua/oluce.lua
	@cp -f $(LUCE_HOME)/Source/lua/oluce.lua luce.lua

$(WRAPCPY): wrap_memcpy.c
	@gcc -c -o $@ $<

$(TARGET): main.o $(WRAPCPY)
	$(LD) $(LDFLAGS) -o $(TARGET) $(WRAPCPY) $< $(STATIC_OBJS) $(LIBS) $(STATIC_LIBS)
	@$(STRIP) $(STRIP_OPTIONS) $(TARGET)
	@$(UPX) $(TARGET)
	@echo OK

test: $(TARGET)
	./$(TARGET)

clean:
	@$(RM) -f main.o oResult.h oResult.lua *.d $(WRAPCPY)
	@$(RM) -f $(NAME) $(NAME)52 $(NAME)_s $(NAME)_s52
	@$(RM) -f $(NAME).exe $(NAME)52.exe $(NAME)_s.exe $(NAME)_s52.exe
	@$(RM) -f $(NAME)_osx $(NAME)_s_osx $(NAME)52_osx $(NAME)_s52_osx

extraclean: clean
	@$(RM) -f luce.lua

distclean: extraclean
	@cd ./luajit-2.0/src && make clean
	@$(RM) -f libluajit.a libluajit.win.a jit bin2c.bin

-include $(OBJECTS:%.o=%.d)

.PHONY: clean extraclean distclean libluajit.a_check
