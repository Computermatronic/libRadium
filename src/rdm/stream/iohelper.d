module rdm.stream.iohelper;

version (Posix)
{
    public import core.sys.posix.stdio;

    alias __fseeki64 = fseeko;
    alias __ftelli64 = ftello;
}
//version (CRuntime_DigitalMars)
//{
//    extern (C)
//    {
//        struct FILE;
//    __gshared:
//        FILE* stdin;
//        FILE* stdout;
//        FILE* stderr;
//    @nogc nothrow:
//        int fclose(FILE* fp);
//        int feof(FILE* fp);
//        int fflush(FILE* fp);
//        FILE* fopen(in char* name, in char* mode);
//        int fseek(FILE* fp, in long offset, in int origin);
//        long ftell(FILE* fp);
//        size_t fwrite(const void* buffer, in size_t sizelem, in size_t n, FILE* fp);
//        size_t fread(const void* buffer, in size_t sizelem, in size_t n, FILE* fp);
//    }
//    alias __fseeki64 = fseek;
//    alias __ftelli64 = ftell;
//}
else version (CRuntime_Microsoft)
{
    public import core.stdc.stdio;

    extern (C) void _fseeki64(FILE*, long, int);
    alias __fseeki64 = _fseeki64;
    alias __ftelli64 = _ftelli64;
}
else
{
    public import core.stdc.stdio;

    void __fseeki64(FILE* fp, long l, int i)
    {
        fseek(fp, cast(int) l, i);
    }

    alias __ftelli64 = ftell;
}
