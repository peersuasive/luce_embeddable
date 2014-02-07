
CFLAGS =
EXTRALIB  = 
BIN2C =
TNAME =

ifndef CONFIG
	CONFIG=Release
else
	CFLAGS += -g
endif

ifeq ($(XCROSS),1)
	X = /opt/mingw/usr/bin/i686-pc-mingw32-
	EXT        = .exe
	#CFLAGS += --export-all-symbols
	#LDLAGS += --export-all-symbols
	CFLAGS    += -march=i686
	LDFLAGS   += -march=i686
	EXTRALIBS += -llua5.1 -lstdc++ -lm
	BIN2C      = ./bin2c
	UPX        = echo $(X)upx.exe
else
	CFLAGS    += -fPIC
	EXTRALIBS += libluajit.a -lm -ldl
	LDFLAGS    = -Wl,-E
	#BIN2C      = ./luajit-2.0/src/luajit -b
	BIN2C      = ./bin2c
	#UPX        = upx-nrv
	UPX        = echo ./upx
endif

ifeq ($(STATIC),1)
	TNAME = demo_s
else
	TNAME = demo
endif


TARGET_JIT = libluajit.a_check

CC 	   = $(X)g++
STRIP  = $(X)strip
RM     = rm
SQUISH = ./squish

CFLAGS += -std=c++11
CFLAGS += -march=native

#CFLAGS += -std=c99
CFLAGS += -Os
CFLAGS += -fomit-frame-pointer -fno-stack-protector
CFLAGS += -Iluajit-2.0/src
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
	@$(CC) $(CFLAGS) -c -o $@ $<

oDemo.lua: squishy luce.lua DemoHolder.lua Demo.lua GlyphDemo.lua GraphicsDemoBase.lua LinesDemo.lua
	@$(SQUISH) --no-executable

oDemo.h: oDemo.lua $(TARGET_JIT)
	@$(BIN2C) oDemo.lua oDemo.h

../../Source/lua/luce.lua:
	@cd ../../Source/lua && $(SQUISH) --no-executable

luce.lua: ../../Source/lua/oluce.lua
	@cp -f ../../Source/lua/oluce.lua luce.lua

demo$(EXT): main.o
	@$(CC) $(LDFLAGS) -o $(TARGET) $< $(LIBS)
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK

demo_s: main.o
	@echo "Unifinished config! Can't work without the library anyway!"
	@$(CC) $(LDFLAGS) -o $(TARGET) $< obj/lin/*.o $(LIBS) -L/usr/X11R6/lib/ -lX11 -lXext -lXinerama -ldl -lfreetype -lpthread -lrt -lstdc++
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK

demo_s.exe: main.o
	@echo "Unifinished config! Can't work without the library anyway!"
	@$(CC) $(LDFLAGS) -o $(TARGET) $< obj/win/*.o $(LIBS) -lfreetype -lpthread -lws2_32 -lshlwapi -luuid -lversion -lwinmm -lwininet -lole32 -lgdi32 -lcomdlg32 -limm32 -loleaut32
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK


test: $(TARGET)
	./$(TARGET)

clean:
	@$(RM) -f demo demo.exe main.o oDemo.h oDemo.lua

extraclean: clean
	@$(RM) -f luce.lua

distclean: extraclean
	@cd ./luajit-2.0/src && make clean
	@$(RM) -f libluajit.a libluajit.win.a jit


