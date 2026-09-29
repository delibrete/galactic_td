package info;
import cheatFree.SafeInt;

class PlayerInfo 
{
    private var cash_:SafeInt;
    private var lives_:SafeInt;
    private var name_:String;
    private var team_:Int;
    private var score_:SafeInt;
    
    public function new(cash:Int = 0, lives:Int = 0, name:String = "", team:Int = 0) 
    {
        this.score_ = new SafeInt(0);
        this.cash_ = new SafeInt(cash);
        this.lives_ = new SafeInt(lives);
        this.name_ = name;
        this.team_ = team;
    }
    
    public function get_cash():Int { return cash_.get_val(); }
    public function set_cash(val:Int):Void { cash_.set_val(val); }
    public function get_lives():Int { return lives_.get_val(); }
    public function set_lives(val:Int):Void { lives_.set_val(val); }
    public function get_name():String { return name_; }
    public function set_name(val:String):Void { name_ = val; }
    public function get_team():Int { return team_; }
    public function set_team(val:Int):Void { team_ = val; }
    public function get_score():Int { return score_.get_val(); }
    public function set_score(val:Int):Void { score_.set_val(val); }
    
}