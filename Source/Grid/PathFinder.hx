package grid;

import openfl.Vector;

class PathFinder 
{
    private var grid_:GameGrid;
    private var workGrid_:Vector<GridCoord>;
    private var checkList_:Vector<Dynamic>;
    private var upFirst_:Bool;
    private var startX_:Int;
    private var startY_:Int;
    private var targetX_:Int;
    private var targetY_:Int;
    
    public function new(grid:GameGrid, startX:Int, startY:Int, targetX:Int, targetY:Int, upFirst:Bool) 
    {
        upFirst_ = upFirst;
        grid_ = grid;
        workGrid_ = new Vector<GridCoord>();
        checkList_ = new Vector<Dynamic>();
        
        startX_ = startX;
        startY_ = startY;
        targetX_ = targetX;
        targetY_ = targetY;
    }
    
    public function find():Vector<GridCoord>
    {
        // var path:Vector<GridCoord> = new Vector<GridCoord>();
        var path:Vector<GridCoord> = null;
        
        // addNode(new GridCoord(startX_, startX_), startX_, startX_);
        addNode(null, startX_, startY_);
        // trace(startX_, startY_);
        while (null == path && 0 != checkList_.length)
        // trace(path.length);
        // while (0 == path.length && 0 != checkList_.length)
        {
            var n:GridCoord = checkList_.shift();
            // trace(n);
            // trace(n.x == targetX_ && n.y == targetY_);
            if (n.x == targetX_ && n.y == targetY_)
            {
                path = makePath(n);
            }
            else
            {
                addValidNeighbours(n);
            }
        }
        
        // trace(path);
        return path;
    }
    
    private function addValidNeighbours(n:GridCoord):Void
    {
        if (upFirst_)
        {
            addIfValid(n, n.x, n.y - 1);
            addIfValid(n, n.x + 1, n.y - 1);
            addIfValid(n, n.x - 1, n.y - 1);
            
            addIfValid(n, n.x + 1, n.y);
            addIfValid(n, n.x - 1, n.y);
            
            addIfValid(n, n.x, n.y + 1);
            addIfValid(n, n.x + 1, n.y + 1);
            addIfValid(n, n.x - 1, n.y + 1);
        }
        else
        {
            // trace(n);
            addIfValid(n, n.x, n.y + 1);
            addIfValid(n, n.x + 1, n.y + 1);
            addIfValid(n, n.x - 1, n.y + 1);			
            
            addIfValid(n, n.x + 1, n.y);
            addIfValid(n, n.x - 1, n.y);

            addIfValid(n, n.x, n.y - 1);
            addIfValid(n, n.x + 1, n.y - 1);
            addIfValid(n, n.x - 1, n.y - 1);
        }
    }
    
    private function addIfValid(parent:GridCoord, x:Int, y:Int):Void
    {
        // trace(x, y);
        if (!(x == startX_ && y == startY_))
        {
            // trace(x, y, !grid_.isOccupied(x, y), workGrid_[x + y * grid_.get_width()], (!grid_.isOccupied(x, y) && workGrid_[x + y * grid_.get_width()] == null));
            if (!grid_.isOccupied(x, y) && workGrid_[x + y * grid_.get_width()] == null)
            {
                // trace("1");
                // Check diagonals
                if (parent != null)
                {
                    // trace("2");
                    if (parent.x != x && parent.y != y)
                    {
                        // trace("3");
                        var difX:Int = x - parent.x;
                        var difY:Int = y - parent.y;
                        
                        if (!grid_.isOccupied(parent.x + difX, parent.y) && !grid_.isOccupied(parent.x, parent.y + difY))
                        {
                            // trace("4");
                            addNode(parent, x, y);
                        }
                    }
                    else
                    {
                        // trace("5");
                        addNode(parent, x, y);
                    }
                }
            }

        }
    }
    
    private function addNode(parent:GridCoord, x:Int, y:Int):Void
    {
        workGrid_[x + y * grid_.get_width()] = parent;
        // trace(workGrid_);
        checkList_.push(new GridCoord(x, y));
    }
    
    private function makePath(n:GridCoord):Vector<GridCoord>
    {			
        var path:Vector<GridCoord> = new Vector<GridCoord>();
        
        while (n == null || n.x != startX_ || n.y != startY_)
        {
            if (n != null)
            {
                path.push(n);
            }
            n = workGrid_[n.x + n.y * grid_.get_width()];
        }
        
        path.reverse();	
        
        return path;
    }
    
}