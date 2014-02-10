/************************************************************

 demo.c

    @author Christophe Berbizier (cberbizier@peersuasive.com)
    @license GPLv3
    @copyright 


(c) 2014, Peersuasive Technologies

*************************************************************/

#include <lua.hpp>

#ifdef __cplusplus
extern "C" {
#endif

#include "oResult.h"
#include <stdio.h>

#ifdef XSTATIC
extern int luaopen_core(lua_State*);
#endif

int main(int argc, char *argv[]) {
    int status = 0;
    lua_State *L;
    L = luaL_newstate();
    luaL_openlibs(L);

#ifdef XSTATIC
    lua_pushcfunction(L, luaopen_core);
    lua_call(L, 0, 0);
#endif
 
    status = luaL_loadbuffer(L, luaJIT_BC_oResult, luaJIT_BC_oResult_SIZE, NULL);
    if(!status) {
        for(int i=1;i<argc;++i)
            lua_pushstring(L, argv[i]);
        if ((status = lua_pcall(L, argc-1, 0, 0)) )
            lua_error(L);
    } else {
        fprintf(stderr, "Missing main file: %s\n", "Demo.lua");
        lua_error(L);
    }
    lua_close(L);
    return status;
}

#ifdef __cplusplus
}
#endif
