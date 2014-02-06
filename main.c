/************************************************************

 demo.c

    @author Christophe Berbizier (cberbizier@peersuasive.com)
    @license GPLv3
    @copyright 


(c) 2014, Peersuasive Technologies

*************************************************************/

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "oDemo.h"

#include <stdio.h>

int main(int argc, char *argv[]) {
    int status = 0;
    lua_State *L;
    L = luaL_newstate();
    luaL_openlibs(L);
    status = luaL_loadbuffer(L, luaJIT_BC_oDemo, luaJIT_BC_oDemo_SIZE, NULL);
    if(!status) {
        for(int i=1;i<argc;++i)
            lua_pushstring(L, argv[i]);
        if ((status = lua_pcall(L, argc-1, 0, 0)) )
            lua_error(L);
    } else fprintf(stderr, "Missing main file: %s\n", "Demo.lua");
    return status;
}
