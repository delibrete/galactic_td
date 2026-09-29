package sounds; 

import openfl.Assets;
import openfl.media.Sound;
// import openfl.media.SoundChannel;
// import openfl.media.SoundMixer;
import openfl.media.SoundTransform;

/**
* ...
* @author Wayne Marsh
*/
class GameSounds 
{
	// [Embed(source="laser.mp3")]
	// private static const LASER_:Class;
	// public static const LASER:Sound = new LASER_;
	public static var LASER = "sfx/laser.mp3";
	
	// [Embed(source="boom.mp3")]
	// private static const BOOM_:Class;
	// public static const BOOM:Sound = new BOOM_;
	public static var BOOM = "sfx/boom.mp3";
	
	// [Embed(source="tick.mp3")]
	// private static const TICK_:Class;
	// public static const TICK:Sound = new TICK_;
	public static var TICK = "sfx/tick.mp3";
	
	// [Embed(source="missile.mp3")]
	// private static const MISSILE_:Class;
	// public static const MISSILE:Sound = new MISSILE_;
	public static var MISSILE = "sfx/missile.mp3";
	
	// [Embed(source="burst.mp3")]
	// private static const BURST_:Class;
	// public static const BURST:Sound = new BURST_;
	public static var BURST = "sfx/burst.mp3";
	
	// [Embed(source="pellet.mp3")]
	// private static const PELLET_:Class;
	// public static const PELLET:Sound = new PELLET_;
	public static var PELLET = "sfx/pellet.mp3";
	
	// [Embed(source="frost.mp3")]
	// private static const FROST_:Class;
	// public static const FROST:Sound = new FROST_;
	public static var FROST = "sfx/frost.mp3";
	
	// [Embed(source="air.mp3")]
	// private static const AIR_:Class;
	// public static const AIR:Sound = new AIR_;
	public static var AIR = "sfx/air.mp3";
	
	// [Embed(source="escape.mp3")]
	// private static const ESCAPE_:Class;
	// public static const ESCAPE:Sound = new ESCAPE_;
	public static var ESCAPE = "sfx/escape.mp3";
	
	// [Embed(source="place.mp3")]
	// private static const PLACE_:Class;
	// public static const PLACE:Sound = new PLACE_;
	public static var PLACE = "sfx/place.mp3";
	
	// [Embed(source="sell.mp3")]
	// private static const SELL_:Class;
	// public static const SELL:Sound = new SELL_;
	public static var SELL = "sfx/sell.mp3";
	
	// [Embed(source="upgrade.mp3")]
	// private static const UPGRADE_:Class;
	// public static const UPGRADE:Sound = new UPGRADE_;
	public static var UPGRADE = "sfx/upgrade.mp3";
	
	// [Embed(source="charge.mp3")]
	// private static const CHARGE_:Class;
	// public static const CHARGE:Sound = new CHARGE_;
	public static var CHARGE = "sfx/charge.mp3";
	
	private static var DEFAULT_TRANSFORM:SoundTransform = new SoundTransform(1, 0);
	
	public static function play(soundStr:String):Void
	{
		var sound:Sound = Assets.getSound(soundStr);
		sound.play(0, 0, DEFAULT_TRANSFORM);
	}
}