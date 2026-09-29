package game.bullets;

import game.creeps.CreepBase;
import openfl.Vector;

interface IBullet extends IHasGraphic
{
    function get_team():Int;
    function update():Bool;

    function apply(creeps:Vector<CreepBase>):Void;
}
