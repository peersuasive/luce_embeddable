/************************************************************

 demo.c

    @author Christophe Berbizier (cberbizier@peersuasive.com)
    @license GPLv3
    @copyright 


(c) 2014, Peersuasive Technologies

*************************************************************/

#include <lua.hpp>
#include <string>

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>

#include "oResult.h"

#if defined XSTATIC || FULL_XSTATIC
#if LUCE_ANDROID
#include <jni.h>
extern int luaopen_core_and(lua_State*, JNIEnv*, jobject);
#else
extern int luaopen_core(lua_State*);
#endif
#endif

#if LUCE_ANDROID
void Java_org_peersuasive_luce_luce_luceResumeApp( JNIEnv* env, jobject activity ) {
    int argc = 1;
    const char **argv;
#else
int main(int argc, char *argv[]) {
#endif
    int status = 0;
    lua_State *L;
    L = luaL_newstate();
    luaL_openlibs(L);

    #if defined XSTATIC || FULL_XSTATIC
    #if LUCE_ANDROID
    luaopen_core_and(L, env, activity);
    #else
    luaopen_core(L);
    #endif
    lua_pop(L,1);
    #endif

    status = luaL_loadbuffer(L, luaJIT_BC_oResult, luaJIT_BC_oResult_SIZE, NULL);
    if(status) {
        fprintf(stderr, "Error while loading luce class\n");
        lua_error(L);
    }

    #ifndef FULL_XSTATIC
    lua_getglobal( L, "package" );
    lua_getfield( L, -1, "path" );

    std::string cur_path( "./?.lua;classes/?.lua;" );
    cur_path.append( lua_tostring( L, -1 ) );

    lua_pushstring( L, cur_path.c_str() );
    lua_setfield( L, -3, "path" );
    lua_pop( L, 2 ); // field + package

    status = luaL_loadfile(L, "main.lua");
    #endif

    if(!status) {
        for(int i=1;i<argc;++i)
            lua_pushstring(L, argv[i]);
        if ((status = lua_pcall(L, argc-1, 0, 0)) )
            lua_error(L);
    } else {
        fprintf(stderr, "Missing or error with main file: %s\n", "main.lua");
        lua_error(L);
    }
    #if ! LUCE_ANDROID
    lua_close(L);
    return status;
    #endif
}

#ifdef __MINGW32__
#include "wmain.c"
#endif // MINGW32

//#endif // LUCE_ANDROID

#ifdef __cplusplus
}
#endif
