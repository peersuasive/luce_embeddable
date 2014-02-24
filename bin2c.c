/*
 * bin2c.c
 * convert files to byte arrays for automatic loading
 * Luiz Henrique de Figueiredo (lhf@tecgraf.puc-rio.br)
 * Fixed to Lua 5.1. Antonio Scuri (scuri@tecgraf.puc-rio.br)
 * Generated files will work also for Lua 5.0
 * 08 Dec 2005
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char * pre = "luaJIT_BC_";
static void dump(FILE* f, const char *name) {
    printf("static const char %s%s[]={\n", pre, name);
    int size = 0;
    for (int n=1;;++n, ++size) {
        int c=getc(f); 
        if (c==EOF) break;
        printf("%3u,",c);
        if (n==20) { putchar('\n'); n=0; }
    }
    printf("\n};\n");
    printf("#define %s%s_SIZE %d\n", pre, name, size);
}

static int fdump(const char* fn, int n, const char* force_name) {
    FILE* f= fopen(fn,"rb");
    if (!f) {
        fprintf(stderr,"bin2c: cannot open ");
        return 1;
    }

    printf("/* %s */\n",fn);
    if(!force_name) {
        int i = strlen(fn)-1;
        for(;fn[i];--i)
            if(fn[i]=='.')
                break;
        char name[i+1];
        strncpy(name, fn, i);
        name[i] = '\0';

        dump(f, name);
    }
    else
        dump(f, force_name);

    fclose(f);
    return 0;
}

int main(int argc, char* argv[]) {
    if (argc<2)
        return 1;
    if(argc>2)
        return fdump(argv[1],1, argv[2]);
    else
        return fdump(argv[1],1, NULL);
}
