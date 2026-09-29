import openfl.utils.Assets;
import openfl.text.Font;

//TODO: properly embed fonts: https://pepperpunk.wordpress.com/2014/03/27/font-embedding-in-haxe-openfl/

class Fonts
{
    public static inline var DEFAULT_FONT : String = "_blockbit";
    public static inline var CLEAR_FONT : String = "_verd";
    
    // @:meta(Embed(source="Ernest.ttf",fontName="_blockbit"))
    // private static var defaultFontClass : Class<Dynamic>;
    // @:meta(Embed(source="ariblk.ttf",fontName="_verd"))
    // private static var clearFontClass : Class<Dynamic>;
    
    private static var fontsRegistered : Bool = false;
    
    public static function registerFonts() : Void
    {
        if (!fontsRegistered)
        {
            fontsRegistered = true;
            var defaultFontClass = Assets.getFont("fonts/Ernest.ttf");
            defaultFontClass.fontName = "_blockbit";
            var clearFontClass = Assets.getFont("fonts/ariblk.ttf");
            clearFontClass.fontName = "_verd";

            Font.registerFont(defaultFontClass);
            Font.registerFont(clearFontClass);
        }
    }

    public function new()
    {
    }
}
