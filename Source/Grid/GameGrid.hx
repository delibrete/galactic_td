package grid;

import openfl.Vector;

class GameGrid 
{
    public static inline var DEFAULT_GRID_WIDTH:Int = 27;
    public static inline var DEFAULT_GRID_HEIGHT:Int = 45;
    public static inline var DEFAULT_SQUARE_SIZE:Float = 12;
    
    private var width_:Int;
    private var height_:Int;
    private var squareSize_:Float;
    
    private var grid_:Vector<Int>;
    
    private var upExit_:GridCoord;
    private var downExit_:GridCoord;
    
    private var pathCacheUp_:Vector<Dynamic>;
    private var pathCacheDown_:Vector<Dynamic>;
    
    public function new(width:Int = DEFAULT_GRID_WIDTH, height:Int = DEFAULT_GRID_HEIGHT, squareSize:Float = DEFAULT_SQUARE_SIZE) 
    {
        width_ = width;
        height_ = height;
        squareSize_ = squareSize;
        pathCacheUp_ = new Vector<Dynamic>();
        pathCacheDown_ = new Vector<Dynamic>();
        
        upExit_ = new GridCoord(13, 0);
        downExit_ = new GridCoord(13, 44);
        
        grid_ = new Vector<Int>(width_ * height_);
        // fillDefault();
    }
    
    private function fillDefault():Void
    {
        for (y in 0...height_)
        {
            for (x in 0...width_)
            {
                setData(x, y, null);
                
                if (y == 0 || y == height_ - 1 || x == 0 || x == width_ - 1)
                {
                    var hw:Int = Math.floor(0.5 * width_);
                    if (x < hw - 3 || x > hw + 2)	setData(x, y, 1);
                }
            }
        }
    }
    
    public function get_isBlocking():Bool
    {
        // trace(findPath(upExit_.x, upExit_.y, downExit_.x, downExit_.y, false).length);
        return null == findPath(upExit_.x, upExit_.y, downExit_.x, downExit_.y, false);
    }
    
    public function setData(x:Int, y:Int, data:Dynamic = 1):Void
    {
        if (!isInGrid(x, y)) {
            return;
        }

        // if (data == null) {
        //     data = 1;
        // }

        grid_[x + y * width_] = data;
        
        pathCacheUp_ = new Vector<Dynamic>();
        pathCacheDown_ = new Vector<Dynamic>();
    }
    
    private function dataAt(x:Int, y:Int):Int
    {
        if (!isInGrid(x, y))
        {
            return null;
        }

        return grid_[x + y * width_];
    }
    
    public function isOccupied(x:Int, y:Int):Bool { 
        // trace(!isInGrid(x, y) || null != dataAt(x, y), !isInGrid(x, y), null != dataAt(x, y), dataAt(x, y));
        // trace(dataAt(x, y));
        // trace(!isInGrid(x, y), dataAt(x, y));
        return !isInGrid(x, y) || 0 != dataAt(x, y);// || null != dataAt(x, y);
        // return !isInGrid(x, y) || null != dataAt(x, y);
    }

    public function isInGrid(x:Int, y:Int):Bool {
        // trace(x, y);
        return x >= 0 && x < width_ && y >= 0 && y < height_; 
    }
    
    public function coordAt(x:Int, y:Int):GridCoord
    {
        x = Math.floor(x / squareSize_);
        y = Math.floor(y / squareSize_);
        
        if (!isInGrid(x, y)) {
            return null;
        }
        return new GridCoord(x, y);
    }
    
    public function pathToExit(upExit:Bool, fromX:Int, fromY:Int):Vector<GridCoord>
    {
        var cache:Vector<Dynamic> = upExit ? pathCacheUp_ : pathCacheDown_;
        
        if (cache[fromX + fromY * width_])
        {
            // trace(cache[fromX + fromY * width_]);
            return cache[fromX + fromY * width_];
        }
        
        var path:Vector<GridCoord> = findPath(fromX, fromY, upExit ? upExit_.x : downExit_.x, upExit ? upExit_.y : downExit_.y, upExit);
        
        cache[fromX + fromY * width_] = path;
        
        return path;
    }
    
    public function findPath(fromX:Int, fromY:Int, toX:Int, toY:Int, upFirst:Bool):Vector<GridCoord>
    {
        // trace("wer");

        if (isOccupied(fromX, fromY) || isOccupied(toX, toY)) {
            trace(isOccupied(fromX, fromY), isOccupied(toX, toY));
            return null;
        }

        // trace("findPath");
        
        var finder:PathFinder = new PathFinder(this, fromX, fromY, toX, toY, upFirst);
        return finder.find();
    }
    
    public function get_width():Int { return width_; }
    public function get_height():Int { return height_; }
    public function get_squareSize():Float { return squareSize_; }
    
    public function clone():GameGrid
    {
        var ng:GameGrid = new GameGrid(width_, height_, squareSize_);
        
        for (y in 0...height_)
        {
            for (x in 0...width_)
            {
                ng.setData(x, y, this.dataAt(x, y));
            }
        }
        
        return ng;
    }
    
}