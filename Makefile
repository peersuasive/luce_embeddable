CC = gcc
STRIP = strip
RM = rm

CFLAGS = -std=c99
CFLAGS += -fPIC -O2
#CFLAGS += -g
CFLAGS += -fomit-frame-pointer -fno-stack-protector
CFLAGS += -Iluajit-2.0/src
LIBS = libluajit.a -lm -ldl

all: demo

libluajit.a: luajit-2.0/src/libluajit.a
	@ln -sf luajit-2.0/src/libluajit.a .
	@$(RM) -f jit
	@ln -sf luajit-2.0/src/jit .

luajit-2.0/src/libluajit.a:
	@cd luajit-2.0/src && make

main.o: main.c libluajit.a oDemo.h
	@$(CC) $(CFLAGS) -c -o $@ $<

oDemo.lua: squishy oluce.lua DemoHolder.lua Demo.lua GlyphDemo.lua GraphicsDemoBase.lua LineDemo.lua
	@squish --no-executable

oDemo.h: oDemo.lua libluajit.a
	@./luajit-2.0/src/luajit -b oDemo.lua oDemo.h

../../Source/lua/oluce.lua:
	cd ../../Source/lua && squish --no-executable

oluce.lua: ../../Source/lua/oluce.lua
	ln -s ../../Source/lua/oluce.lua oluce.lua

demo: main.o
	@$(CC) -Wl,-E -o demo $< $(LIBS)
	@$(STRIP) $@
	@echo OK

test: demo
	./demo

clean:
	@$(RM) -f demo main.o oDemo.h oDemo.lua oluce.lua libluajit.a jit

extraclean: clean
	@cd ./luajit-2.0/src && make clean

