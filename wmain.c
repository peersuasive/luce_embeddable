/*
 * from LuaDist @https://github.com/LuaDist/luajit
 *
 */

#include <windows.h>
#include <stdlib.h>

int PASCAL WinMain(HINSTANCE hinst, HINSTANCE hprev, LPSTR cmdline, int ncmdshow) {
  extern int __argc;
  extern char** __argv;
  return main(__argc, __argv);
}
