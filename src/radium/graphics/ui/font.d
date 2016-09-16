//module radium.graphics.ui.font;
//
//import derelict.freetype.ft;
//
//__gshared FT_Library ftLib;
//
//private struct Glyph
//{
//    GLuint texId;
//    void[] bitmap;
//    uint width, height;
//    int voffset;
//}
//
//interface FontProvider
//{
//    Glyph loadChar(dchar c);
//}
//
//class Font
//{
//    FontProvider fontProvider;
//    Glyph[dchar] cache;
//
//    this(FontProvider fontProvider)
//    {
//        this.fontProvider = fontProvider;
//        populate();
//    }
//
//    this(void[] fontData, uint size)
//    {
//        this.fontProvider = new FTFontPrevider(fontData, size);
//        populate();
//    }
//
//    void populate()
//    {
//        enum commonChars = "`"
//                ~ `1234567890-=qwertyuiop[]\asdfghjkl;'zxcvbnm,./~!@#$%^&*()_+QWERTYUIOP{}|ASDFGHJKL:"ZXCVBNM<>?`;
//        foreach (c; commonChars)
//            getChar(c);
//    }
//
//    Glyph getChar(dchar c)
//    {
//        auto ptr = c in cache;
//        if (ptr !is null)
//            return *ptr;
//        auto glyph = fontProvider.loadChar(c);
//        glBindTexture(GL_TEXTURE_2D, &glyph.texId);
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, glyph.width, glyph.height, 0,
//                GL_RGBA, GL_FLOAT, glyph.bitmap.ptr);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//        glGenerateMipmap(GL_TEXTURE_2D);
//
//    }
//    
//    void draw(float x, float y,string text)
//    {
//    	
//    }
//}
//
//class FTFontProvider : FontProvider
//{
//    FT_Face face;
//
//    this(void[] buffer, uint charSize)
//    {
//        FT_New_Memory_Face(buffer.ptr, buffer.length, 0, &face);
//        FT_Set_Pixel_Sizes(face, charSize, charSize);
//        foreach (chr; charSet)
//        {
//            getChar(chr);
//        }
//    }
//
//    Glyph getChar(dchar chr)
//    {
//        Glyph glyph;
//        auto ftGlyphIndex = FT_Get_Char_Index(face, chr);
//        FT_Load_Glyph(face, ftGlyphIndex, FT_LOAD_DEFAULT);
//        FT_Render_Glyph(face.glyph, FT_RENDER_MODE_NORMAL);
//        glyph.width = face.slot.bitmap_left;
//        glyph.height = face.slot.bitmap_top;
//        glyph.buffer = face.slot.bitmap[0 .. glyph.width * glyph.height];
//        return glyph;
//    }
//}
