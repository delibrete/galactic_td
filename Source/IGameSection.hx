package;

interface IGameSection extends IHasGraphic
{
	function update():IGameSection;
	function draw():Void;
	function networkHandler(data:String):Void;
}