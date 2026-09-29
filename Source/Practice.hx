package;
import openfl.Vector;
import towers.TowerBase;
import gamestate.GameState;
import editor.EditSection;
import info.PlayerInfo;
import openfl.display.*;
import openfl.text.*;
import game.creeps.CreepBase;
import game.creeps.CreepFactory;
import game.GameData;
import game.GameSection;
import grid.GameGrid;
import info.InfoBox;
import info.PlayerInfo;

class Practice extends Sprite
{		
    private var section_:IGameSection;
    private var gameData_:GameData;
    
    private var gameLayer_:Sprite;
    
    private var creepsButton_:PracticeButton;
    private var levelButton_:PracticeButton;
    
    private var banner_:TextField;
    
    private var bannerFadePhase_:Float = 0;
    
    private var urlText_:TextField;
    
    public function new() 
    {	
        super();
        gameData_ = new GameData();
        // gameData_.towers = new Vector<TowerBase>();
        gameData_ = GameState.calculatePhase(gameData_, true);
        gameData_.grid = GameData.masterGrid.clone();
        gameData_.buildTime = 1;
        gameData_.team = 0;
        var pd0:PlayerInfo = gameData_.playerData[0];
        var pd1:PlayerInfo = gameData_.playerData[1];
        pd0.set_cash(Std.int(0.5 * 2147483647)); //int.MAX_VALUE
        pd0.set_lives(10000);
        pd0.set_name("you");
        pd0.set_score(0);
        pd0.set_team(0);
        pd1.set_cash(80);
        pd1.set_lives(10000);
        pd1.set_name("them");
        pd1.set_score(0);
        pd1.set_team(1);
        
        gameLayer_ = new Sprite();
        addChild(gameLayer_);
        
        section_ = new EditSection(null, gameData_);

        gameLayer_.addChild(section_.getGraphic());
        
        creepsButton_ = new PracticeButton(["Normal", "Resistant", "Flying", "Fast"], ["normal", "resistant", "flying", "fast"], 140);
        
        var levelStr:Array<String> = [];
        var levelNum:Array<Int> = [];
        for (i in 0...20)
        {
            levelStr.push("Level " + Std.string(i+1));
            levelNum.push(i);
        }
        
        levelButton_ = new PracticeButton(levelStr, levelNum, 140);
        
        creepsButton_.x = 340;
        creepsButton_.y = 345;
        
        levelButton_.x = creepsButton_.x;
        levelButton_.y = creepsButton_.y + 5 + creepsButton_.height;
        
        addChild(creepsButton_);
        addChild(levelButton_);
        
        banner_ = InfoBox.makeTF(16, true);
        // banner_.text = "Sandbox Mode\nWaiting for player";
        banner_.text = "Sandbox Mode";
        // banner_.x = 329 + 0.5 * (164 - banner_.width);
        banner_.x = 529 + 0.5 * (164 - banner_.width);
        // addChild(banner_);
        
        urlText_ = new TextField();
        addChild(urlText_);
        urlText_.defaultTextFormat = new TextFormat(null, null, 0xFFFFFF, null, null, null, null, null, null, null, null, null, null);
        urlText_.autoSize = TextFieldAutoSize.LEFT;

        Global.practiceSandboxMode = true;
    }
    
    public function update():Void
    {
        bannerFadePhase_ += 3 * Global.UPDATE_SECS;
        
        var newSection:IGameSection = section_.update();
        
        if (newSection != section_)
        {
            if (null == newSection)
            {
                if (section_ is EditSection)
                {
                    prepareCreeps();
                    newSection = new GameSection(null, this.gameData_); // TODO
                }
                else
                if (section_ is GameSection)
                {
                    newSection = new EditSection(null, this.gameData_);
                }
            }
            
            gameLayer_.removeChild(section_.getGraphic());
            
            if (newSection != null)
            {
                gameLayer_.addChild(newSection.getGraphic());
            }
            
            section_ = newSection;
        }
        
        /*if (root)
            urlText_.text = root.stage.loaderInfo.loaderURL;
        else
            urlText_.text = "no loader";*/
    }
    
    private function prepareCreeps():Void
    {
        // gameData_.creepsTeamed = [[], []];
        // gameData_.creepsTeamed;
        gameData_.creepsTeamed = new Vector<Vector<CreepBase>>();
        gameData_.creepsTeamed.push(new Vector<CreepBase>());
        gameData_.creepsTeamed.push(new Vector<CreepBase>());
        
        var level:Int = levelButton_.get_value();
        
        for (i in 0...20)
        {
            var nc:CreepBase = null;
            
            var x:Int = Std.int(162 + Math.random() * 60 - 30);
            var y:Int = Global.SCREEN_HEIGHT + 15 * i;
            
            //["normal", "resistant", "flying", "fast"]
            switch (creepsButton_.get_value())
            {
                default:
                case "normal":
                    nc = CreepFactory.make(level+1, 35, Std.int(20 * Math.pow(2.2, level)), x, y, false, false, 1, false, false, false);
                case "resistant":
                    nc = CreepFactory.make(level+1, 35, Std.int(26 * Math.pow(2.2, level)), x, y, true, false, 1, false, false, false);
                case "flying":
                    nc = CreepFactory.make(level+1, 35, Std.int(40 * Math.pow(2.2, level)), x, y, false, true, 1, false, false, false);
                case "fast":
                    nc = CreepFactory.make(level+1, 50, Std.int(33 * Math.pow(2.2, level)), x, y, false, false, 1, false, true, false);
            }
            
            if (nc != null)
            {					
                // Make
                gameData_.creepsTeamed[1].push(nc);
            }
        }
    }
    
    public function draw():Void
    {
        // trace("practice draw");
        section_.draw(); //TODO: Fix
        
        creepsButton_.visible = levelButton_.visible = section_ is EditSection;
        
        banner_.alpha = 0.5 * (1 + Math.sin(bannerFadePhase_));
    }
    
}