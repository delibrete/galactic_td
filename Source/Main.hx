package;

// import AdSection.Ad;
// import CheatFree.CheatSection;
// import Editor.EditSection;
// import TitleScreen.TitleSection;
// import game.InitialGameData;
import js.Browser;
import network.NetworkToast;
import network.Chat;
import info.InfoBox;
import openfl.text.TextField;
import wait.WaitBar;
import network.Network;
import gamestate.GameState;
import editor.EditSection;
import openfl.text.Font;
import openfl.utils.Assets;
import game.GameGFX;
import wait.WaitSection;
import openfl.display.*;
import openfl.events.*;
import openfl.Lib.getTimer;
import openfl.system.System;
import game.GameData;
import game.GameSection;
import lobby.LobbySection;

class Main extends Sprite {

	// public static var GAME_OPTIONS:Object = {id: "80261d332acbc2ec", res:"700x540", background:0x382780, color:0xFFFFFF, outline:0x0D113F, no_bg:false};
		
	private var lastTime:Int;
	private var timeBank:Int;
	private var fps:FpsCounter;

	private var sectionHolder:Sprite;
	private var section:IGameSection;

	private var didUpdate_:Bool;
		
	// private var memoryReport_:MemoryReport;

	var framesNumber = 0;

	// private function message(m:String) {
	// 	trace(m);
	// }

	private var network:Network;

	private var waitingBar:WaitBar;
    private var waitingText:TextField;

	public function new () {
		super();

		var window = Browser.window;
		window.onfocus = function(){}
		window.onblur = function()
		{
		// 	window.setTimeout(animate, 1000.0 / 60.0); 
		// 	isFocused = false; 
		}           
		// if (requestAnimationFrame == null || !isFocused) window.setTimeout(animate, 1000.0 / 60.0);
		// else requestAnimationFrame(animate);

		Global.network = new Network();

		// This initializes if the preloader is turned off.
		if (stage != null) {
			init(false);
		}
	}

	public function init(did_load:Bool):Void
	{
		this.removeChildren();
		Fonts.registerFonts();

		Global.waitHolder = new Sprite();
		Global.chatHolder = new Chat();
		Global.networkToast = new NetworkToast();
		
		this.sectionHolder = new Sprite();
		this.addChild(this.sectionHolder);
		this.addChild(Global.waitHolder);
		this.addChild(Global.chatHolder);
		this.addChild(Global.networkToast);
		Global.chatHolder.setVisibility(false);
		
		var clip:Shape = new Shape();
		var g:Graphics = clip.graphics;
		g.beginFill(0);
		g.drawRect(0, 0, Global.SCREEN_WIDTH, Global.SCREEN_HEIGHT);
		g.endFill();
		addChild(clip);
		this.mask = clip;

		// this.addChild(new FpsCounter());
		// var fpsBack:Shape = new Shape();
		// var g:Graphics = fpsBack.graphics;
		// g.beginFill(0xFFFFFF);
		// g.drawRect(0, 0, 100,20);
		// g.endFill();
		// addChild(fpsBack);
		// this.addChild(new FPS(2,2,0x000000));
		// memoryReport_ = new MemoryReport(30 * 1000);
		
		this.didUpdate_ = false;
		
		this.timeBank = 0;
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	
	
		// var mute:DisplayObject = addChild(new MuteButton);
		// mute.x = 500 - mute.width;
		// mute.y = 540 - mute.height;




		// Waiting for player stuff
        waitingBar = new WaitBar();
        // holder_.addChild(waitingBar);
        waitingBar.x = -85;
        // waitingBar.y = 200;
        waitingBar.alpha = 0.01;
        
        waitingText = InfoBox.makeTF(16);
        // holder_.addChild(waitingText);
        waitingText.text = "Waiting for player...";
        waitingText.x = 100;
        waitingText.y = 225;

        Global.waitHolder.addChild(waitingText);
        Global.waitHolder.addChild(waitingBar);

		Main.toggleWait(false);
	}

	private function onAddedToStage(e:Event):Void
	{
		Global.stage = this.stage;
			
		this.lastTime = getTimer();
	
		// this.section = new EditSection(null, new GameData());
		//this.section = new SiteLock(loaderInfo.loaderURL);

		// new game?
		if (true) {
			Global.resetGlobal();
		}


		this.section = new LobbySection();
		
		this.sectionHolder.addChild(this.section.getGraphic());
		
		//Global.stage.addEventListener(Event.RENDER, onRender);
		
		stage.stageFocusRect = false;
	}

	private function onEnterFrame(e:Event):Void
	{
		// terrible idea
		if (Global.resetAll == true) {
			init(false);
			Global.resetAll = false;
		}

		if (this.section != null && this.section.networkHandler != null)
			Global.network.listen(this.section.networkHandler);

		if (Global.stage != null)
		{			
			// Horrible keyboard focus stuff
			if (Global.stage.focus != null)
			{
				if (Global.stage != Global.stage.focus)
				{
					if (Global.stage.focus.root == null)
					{
						Global.stage.focus = Global.stage;
					}
				}
			}
			
			// Frame time stuff
			var time:Int = getTimer();
			var timeDiff:Int = time - this.lastTime;
			
			this.lastTime = time;
			
			if (timeDiff > Global.MAX_FRAME_DELTA)
			{
				trace("Warning: Frame has exceeded maximum frame delta");
				timeDiff = Global.MAX_FRAME_DELTA;
			}
			
			this.timeBank += timeDiff;

			if (this.timeBank > 0)
			{					
			
				var numUpdates:Int = 0;
			
				// Update game section
				while (this.timeBank >= Global.UPDATE_LENGTH)
				{					
					this.timeBank -= Global.UPDATE_LENGTH;
					
					var newSection:IGameSection;
					if (numUpdates <= 2) {
						newSection = this.section.update();

						if (Global.waitHolder.alpha > 0) waitUpdate();
						Global.networkToast.update();
					} else {
						newSection = this.section;
					}
					
					// if (Global.cheater && !(this.section is CheatSection))
					// {
					// 	newSection = new CheatSection();
					// }
					
					didUpdate_ = true;
					numUpdates++;
					
					if (newSection != this.section)
					{
						this.sectionHolder.removeChild(this.section.getGraphic());
						this.sectionHolder.addChild(newSection.getGraphic());
						
						this.section = newSection;
					}
				}
			}
			
			onRender(null);
		}
		else
		{
			if (this.stage != null)
			{
				this.onAddedToStage(null);
			}
		}
	}
	
	private function onRender(e:Event):Void
	{
		if (didUpdate_)
		{
			didUpdate_ = false;
			
			this.section.draw();
		}
	}

	private function waitUpdate():Void {
		waitingBar.update();

        var alpha = Math.sin(getTimer() / 1000);
        alpha = alpha < 0 ? alpha * -1 : alpha;

        waitingBar.alpha = waitingText.alpha = alpha;
	}

	public static function toggleWait(enable:Bool = true) {
		if (enable) {
			Global.waitHolder.x = 0;
			Global.waitHolder.alpha = 1;
		} else {
			Global.waitHolder.x = -1000;
			Global.waitHolder.alpha = 0;
		}
	}
}