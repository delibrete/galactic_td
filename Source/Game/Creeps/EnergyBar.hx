package game.creeps;

import openfl.errors.Error;
import openfl.display.Sprite;

class EnergyBar extends Sprite
{
    public static final WIDTH:Int = 20;
    public static final HEIGHT:Int = 3;
    
    private var startEnergy:Int;
    
    public function new(energy:Int) 
    {
        super();
        
        this.startEnergy = energy;
        
        this.x = -0.5 * WIDTH;
        this.y = - 15;
        
        draw(startEnergy);
    }
    
    public function draw(energy:Int):Void
    {
        try
        {
            graphics.clear();
            graphics.beginFill(0xFF0000, 1);
            graphics.drawRect(0, 0, WIDTH, HEIGHT);
            graphics.beginFill(0x00FF00, 1);
            graphics.drawRect(0, 0, WIDTH * energy / startEnergy, HEIGHT);
        }
        catch (e:Error)
        {
        }
    }
    
}