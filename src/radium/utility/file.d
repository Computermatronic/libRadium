module radium.utility.file;

void autoWrite(string file, void[] data)
{
    import std.path, std.file;

    auto dirs = file[0 .. $ - file.baseName().length];
    mkdirRecurse(dirs);
    std.file.write(file, data);
}
