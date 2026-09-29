package editor;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import game.GameGFX;
import grid.GameGrid;

import ToBitmapData.toBitmapData;

class Blocking extends Sprite
{
    private var bmp_:Bitmap;
    private var alpha_:Float;
    
    public function new() 
    {
        super();

        bmp_ = new Bitmap(toBitmapData(GameGFX.blocking));
        bmp_.x = Math.round(0.5 * (GameGrid.DEFAULT_GRID_WIDTH * GameGrid.DEFAULT_SQUARE_SIZE - bmp_.width));
        bmp_.y = Math.round(0.5 * (GameGrid.DEFAULT_GRID_HEIGHT * GameGrid.DEFAULT_SQUARE_SIZE - bmp_.height));
        addChild(bmp_);
        bmp_.alpha = 0;
        alpha_ = 0;
    }
    
    public function show():Void
    {
        alpha_ = 1;
    }
    
    public function update(dt:Float):Void
    {
        alpha_ -= dt;
        if (alpha_ < 0)	alpha_ = 0;
        
        bmp_.alpha = Math.sin(0.5 * Math.PI * Math.max(0, Math.min(1, alpha_)));
    }
    
}