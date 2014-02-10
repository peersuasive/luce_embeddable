
CFLAGS   =
EXTRALIB = 
BIN2C    =
TNAME    =

ifndef CONFIG
	CONFIG=Release
else
	CFLAGS += -g
endif

ifeq ($(STATIC),1)
	TNAME = demo_s
	XSTATIC = -DXSTATIC
else
	TNAME = demo
endif

ifeq ($(LUA52),1)
	TNAME := $(TNAME)52
endif

ifeq ($(XCROSS),1)
	PRE 	= i686-pc-mingw32
	X 		= /opt/mingw/usr/bin/$(PRE)-
	EXT     = .exe
	#CFLAGS += --export-all-symbols
	#LDLAGS += --export-all-symbols
	ifeq ($(LUA52),1)
		CFLAGS    += -I/opt/mingw/usr/$(PRE)/include/lua5.2
		EXTRALIBS += -llua5.2
	else
		CFLAGS    += -I/opt/mingw/usr/$(PRE)/include/lua5.1
		EXTRALIBS += -llua5.1
	endif
	CFLAGS    += -march=i686 $(XSTATIC)
	LDFLAGS   += -march=i686
	EXTRALIBS += -lstdc++ -lm
	BIN2C      = ./bin2c
	UPX        = echo $(X)upx.exe
else
	GLIBCV    := $(shell [ `ldd --version|head -n1|awk '{print $$NF}'|cut -f2 -d.` -gt 13 ] && echo true)
	ifeq ($(GLIBCV), true)
		LDFLAGS += -Wl,--wrap=memcpy
		WRAPCPY  = wrap_memcpy.o
	endif
	CFLAGS    += -fPIC $(XSTATIC)
	CFLAGS    += -Iluajit-2.0/src
	EXTRALIBS += libluajit.a -lm -ldl
	LDFLAGS   += -Wl,-E
	#BIN2C      = ./luajit-2.0/src/luajit -b
	BIN2C      = ./bin2c
	#UPX        = upx-nrv
	UPX        = echo ./upx
	CFLAGS 	   += -march=native
	LDLAGS     += -march=native
endif

TARGET_JIT = libluajit.a_check

CC 	   = $(X)g++
LD     = $(CC)
STRIP  = $(X)strip
RM     = rm
SQUISH = ./squish

CFLAGS += -std=c++11
#CFLAGS += -std=c99

CFLAGS += -Os
CFLAGS += -fomit-frame-pointer -fno-stack-protector
CFLAGS += -MMD
LIBS   += $(EXTRALIBS)
LDFLAGS += -std=c++11
LDFLAGS += -fvisibility=hidden

TARGET = $(TNAME)$(EXT)

all: $(TARGET)

$(TARGET_JIT): luajit-2.0/src/luajit$(EXT)
	@ln -sf luajit-2.0/src/libluajit.a .
	@$(RM) -f jit
	@ln -sf luajit-2.0/src/jit .

bin2c.bin: bin2c.c
	@gcc -std=c99 -o bin2c.bin bin2c.c

luajit-2.0/src/luajit:
	@cd luajit-2.0/src && make clean && make

luajit-2.0/src/luajit.exe:
	@echo "luajit crashes with luce (and probably many other things) under windows -- fallback to lua"
	@#cd luajit-2.0/src && make clean && make HOST_CC="gcc -m32" CROSS=$(X) TARGET_SYS=Windows BUILDMODE=static

main.o: main.c $(TARGET_JIT) oDemo.h
	$(CC) $(CFLAGS) -c -o $@ $<

oDemo.lua: squishy luce.lua DemoHolder.lua Demo.lua GlyphDemo.lua GraphicsDemoBase.lua LinesDemo.lua
	@$(SQUISH) --no-executable

oDemo.h: bin2c.bin oDemo.lua $(TARGET_JIT)
	@$(BIN2C) oDemo.lua oDemo.h

../../Source/lua/oluce.lua:
	@cd ../../Source/lua && make

luce.lua: ../../Source/lua/oluce.lua
	@cp -f ../../Source/lua/oluce.lua luce.lua

$(WRAPCPY): wrap_memcpy.c
	@gcc -c -o $@ $<

demo$(EXT): main.o $(WRAPCPY)
	$(LD) $(LDFLAGS) -o $(TARGET) $(WRAPCPY) $< $(LIBS)
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK
demo52$(EXT): demo$(EXT)

demo_s: main.o $(WRAPCPY)
	@$(LD) $(LDFLAGS) -o $(TARGET) $(WRAPCPY) $< obj/lin/*.o $(LIBS) -L/usr/X11R6/lib/ -lX11 -lXext -lXinerama -ldl -lfreetype -lpthread -lrt -lstdc++
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK

demo_s52: main.o $(WRAPCPY)
	@$(LD) $(LDFLAGS) -o $(TARGET) $(WRAPCPY) $< obj/lin52/*.o $(LIBS) -L/usr/X11R6/lib/ -lX11 -lXext -lXinerama -ldl -lfreetype -lpthread -lrt -lstdc++
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK

demo_s.exe: main.o
	@$(CC) $(LDFLAGS) -o $(TARGET) $< obj/win/*.o $(LIBS) -lfreetype -lpthread -lws2_32 -lshlwapi -luuid -lversion -lwinmm -lwininet -lole32 -lgdi32 -lcomdlg32 -limm32 -loleaut32
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK

demo_s52.exe: main.o
	@$(CC) $(LDFLAGS) -o $(TARGET) $< obj/win52/*.o $(LIBS) -lfreetype -lpthread -lws2_32 -lshlwapi -luuid -lversion -lwinmm -lwininet -lole32 -lgdi32 -lcomdlg32 -limm32 -loleaut32
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK


test: $(TARGET)
	./$(TARGET)

clean:
	@$(RM) -f demo demo52 demo_s demo_s52
	@$(RM) -f demo.exe demo52.exe demo_s.exe demo_s52.exe
	@$(RM) -f main.o oDemo.h oDemo.lua $(WRAPCPY) *.d

extraclean: clean
	@$(RM) -f luce.lua

distclean: extraclean
	@cd ./luajit-2.0/src && make clean
	@$(RM) -f libluajit.a libluajit.win.a jit bin2c.bin

-include $(OBJECTS:%.o=%.d)
