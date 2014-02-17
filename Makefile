
LUCE_HOME = $(HOME)/src-private/luce

CFLAGS   =
EXTRALIBS = 
BIN2C    =
NAME     := demo

ifndef CONFIG
	CONFIG=Release
else
	CFLAGS += -g
endif

ifeq ($(STATIC),1)
	TNAME := $(NAME)_s
	XSTATIC = -DXSTATIC
else
	TNAME = $(NAME)
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
		CFLAGS    += -I./luajit-2.0/src
		EXTRALIBS += libluajit.a
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
	@cd luajit-2.0/src && make clean && make HOST_CC="gcc -m32" CROSS=$(X) TARGET_SYS=Windows BUILDMODE=static

main.o: main.c $(TARGET_JIT) oResult.h
	@$(CC) $(CFLAGS) -c -o $@ $<

oResult.lua: squishy luce.lua
	@$(SQUISH) --no-executable

oResult.h: bin2c.bin oResult.lua $(TARGET_JIT)
	@$(BIN2C) oResult.lua oResult.h

#../../Source/lua/oluce.lua:
#	@cd ../../Source/lua && make

#luce.lua: ../../Source/lua/oluce.lua
#	@cp -f ../../Source/lua/oluce.lua luce.lua

$(LUCE_HOME)/Source/lua/oluce.lua:
	@cd "$(LUCE_HOME)/Source/lua" && make

luce.lua: $(LUCE_HOME)/Source/lua/oluce.lua
	@cp -f $(LUCE_HOME)/Source/lua/oluce.lua luce.lua

$(WRAPCPY): wrap_memcpy.c
	@gcc -c -o $@ $<

$(NAME)_s: main.o $(WRAPCPY)
	echo "STATIC"
	@$(LD) $(LDFLAGS) -o $(TARGET) $(WRAPCPY) $< obj/lin/*.o $(LIBS) -L/usr/X11R6/lib/ -lX11 -lXext -lXinerama -ldl -lfreetype -lpthread -lrt -lstdc++
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK

$(NAME)_s52: main.o $(WRAPCPY)
	@$(LD) $(LDFLAGS) -o $(TARGET) $(WRAPCPY) $< obj/lin52/*.o $(LIBS) -L/usr/X11R6/lib/ -lX11 -lXext -lXinerama -ldl -lfreetype -lpthread -lrt -lstdc++
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK

$(NAME)_s.exe: main.o
	@$(CC) $(LDFLAGS) -o $(TARGET) $< obj/win/*.o $(LIBS) -lfreetype -lpthread -lws2_32 -lshlwapi -luuid -lversion -lwinmm -lwininet -lole32 -lgdi32 -lcomdlg32 -limm32 -loleaut32
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK

$(NAME)_s52.exe: main.o
	@$(CC) $(LDFLAGS) -o $(TARGET) $< obj/win52/*.o $(LIBS) -lfreetype -lpthread -lws2_32 -lshlwapi -luuid -lversion -lwinmm -lwininet -lole32 -lgdi32 -lcomdlg32 -limm32 -loleaut32
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK

$(NAME)$(EXT): main.o $(WRAPCPY)
	$(LD) $(LDFLAGS) -o $(TARGET) $(WRAPCPY) $< $(LIBS)
	@$(STRIP) --strip-unneeded $@
	@$(UPX) $@
	@echo OK
$(NAME)52$(EXT): $(NAME)$(EXT)


test: $(TARGET)
	./$(TARGET)

clean:
	@$(RM) -f main.o oResult.h oResult.lua *.d $(WRAPCPY)
	@$(RM) -f $(NAME) $(NAME)52 $(NAME)_s $(NAME)_s52
	@$(RM) -f $(NAME).exe $(NAME)52.exe $(NAME)_s.exe $(NAME)_s52.exe

extraclean: clean
	@$(RM) -f luce.lua

distclean: extraclean
	@cd ./luajit-2.0/src && make clean
	@$(RM) -f libluajit.a libluajit.win.a jit bin2c.bin

-include $(OBJECTS:%.o=%.d)
