/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: None

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256)
    {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

abstract contract ferocious
{
    uint256 private constant hungry = 1;
    uint256 private constant fed = 2;
    uint256 private Bird;

    constructor()
    {
        Bird = hungry;
    }

    modifier safe()
    {
        require(Bird != fed);
        Bird = fed;
        _;
        Bird = hungry;
    }
}

contract Coinbird is ferocious
{
    using SafeMath for uint;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // modifiers

    modifier goose
    {
      require(msg.sender == Goose);
      _;
    }

    modifier lettuce
    {
      require(msg.sender == Lettuce);
      _;
    }

    modifier only_IceGoose
    {
      require(msg.sender == IceGoose);
      _;
    }

    // setters

    function new_Goosehub() private
    {
        Goosehub_Factor = Lettuce_Factor + Game_Factor + Goose_Factor + Farm_Factor + GoldenCarrot_Factor;
    }

    function new_Fat_Goose_Factor(uint value) public only_IceGoose
    {
        require((value >= 10)&&(value <= 400)); // 0.10% to 4.00%
        Fat_Goose_Factor = value;
    }

    function new_Soldier_Goose_Factor(uint value) public only_IceGoose
    {
        require((value >= 10)&&(value <= 400)); // 0.10% to 4.00%
        Soldier_Goose_Factor = value;
    }

    function new_Goose_Factor(uint value) public only_IceGoose
    {
        require((value >= 20)&&(value <= 50));
        Goose_Factor = value;
        new_Goosehub();
    }

    function new_GoldenCarrot_Factor(uint value) public only_IceGoose
    {
        require((value >= 0)&&(value <= 50));
        GoldenCarrot_Factor = value;
        new_Goosehub();
    }

    function new_Lettuce_Factor(uint value) public only_IceGoose
    {
        require((value >= 10)&&(value <= 700));
        Lettuce_Factor = value;
        new_Goosehub();
    }

    function new_Game_Factor(uint value) public only_IceGoose
    {
        require((value >= 0)&&(value <= 50));
        Game_Factor = value;
        new_Goosehub();
    }

    function new_Farm_Factor(uint value) public only_IceGoose
    {
        require((value >= 0)&&(value <= 50));
        Farm_Factor = value;
        new_Goosehub();
    }

    function bless(address fortunate) public only_IceGoose
    {
        blessed[fortunate] = true;
    }

    function farm_protection() public only_IceGoose
    {
        if(secure == true){secure = false;}
        else{secure = true;}
    }

    function set_advantage(uint ka_ching) public only_IceGoose // reminder: modified Black-Scholes-Merton concept for GOOSE implementation
    {
        require(ka_ching <= Goosehub_Factor/2); // 2 decimal places!
        bling = ka_ching;
    }

    function determine_golden_carrot(uint value) public only_IceGoose
    {
        golden_carrot_threshold = value;
    }

    function set_Game_threshold(uint value) public only_IceGoose
    {
        require((protected_flock == true)&&(luckyGeese == 0));
        threshold = value;
    }

    function set_number_of_LuckyGeese(uint Gustav, uint Henrietta, uint max) public only_IceGoose
    {
        require((max <= GameGeese.length)&&(luckyGeese == 0)&&(protected_flock == true));
        luckyGeese = uint(keccak256(abi.encodePacked(block.difficulty+Gustav*Henrietta, (block.timestamp-Gustav)%Henrietta, msg.sender)))%max+1;
        factor = balances[Game]*4/5/luckyGeese;
    }

    // checkers

    function anti_whale(address to, uint value) public view returns (bool) // protection 1
    {
        if((blessed[to] == true)||((blessed[to] == false)&&((balanceOf(to)+myHubGeese(to)+value*(10000-Goosehub_Factor)/10000) <= (TotalSupply*Fat_Goose_Factor/10000))))
        {
            return true;
        }
        return false;
    }

    function anti_rug(address from, uint value) public view returns (bool) // protection 2
    {
        if((blessed[from] == true)||((blessed[from] == false)&&(value <= (TotalSupply*Soldier_Goose_Factor/10000))))
        {
            return true;
        }
        return false;
    }

    function get_FarmGeese_Length() public view returns (uint)
    {
        return FarmGeese.length;        
    }

    function get_Farm_Security() public view returns (bool)
    {
        return secure;
    }

    // Base
    
    mapping(address => bool) public blessed;
    mapping(address => uint) public balances;
    mapping(address => uint) public myGooseFarm;
    mapping(address => bool) public participatedGame;
    mapping(address => bool) private participatedFarm;
    mapping(address => uint) public GoldenCarrotTimeChecker;
    mapping(address => mapping(address => uint)) public _allowances;
    mapping(address => uint) private totalSupply_initial; // totalSupply at x_0
    mapping(address => uint) private initialFarm; // Farm size at x_0
    
    string public Name = "HONK";
    string public Symbol = "HONK";
    
    bool private secure = true;
    bool public boost_deactivated;
    bool public protected_flock = true;
    bool public GoldenCarrotSparkles;
    bool private lvl_2;
    bool private lvl;

    address public constant Game = 0xF7aa6566f731033C1Fc4169014F8E33110A66218;
    address public constant Farm = 0x2f2859732e7d5E1b15A8F725E7F45FDe092E63d6;
    address public constant Securities = 0xF9091c9256adBFD3071463e242a5Dd5Aa4d6E75b;
    address[] public GameGeese;
    address[] public FarmGeese;
    address public constant GoldenCarrot = 0x1764e5702e528Ea7782218B12A5dE11a43ef521f;
    address public constant Goose = 0x6C136CB6e1C41211404905Ec5b2B8d95C4eACB0c;
    address public constant Lettuce = 0xe8Fc36190780451B253021afb98131bcd92e2d8b;
    address public constant IceGoose = 0x934FA83eBE7950085D9375b48620bdA5568C4462;

    uint public Soil;
    uint public bling;
    uint private factor;
    uint public threshold;
    uint public FarmGoose;
    uint public luckyGeese;
    uint public Game_Factor = 20;
    uint public Farm_Factor = 5;
    uint public Goose_Factor = 40;
    uint8 public Decimals = 14;
    uint public Lettuce_Factor = 700;
    uint public Goosehub_Factor;
    uint public Fat_Goose_Factor = 400;
    uint private GoldenCarrotTime ;
    uint public GoldenCarrot_Factor = 5;
    uint public Soldier_Goose_Factor = 400;
    uint public TotalSupply = 1000000000000000000000;
    uint public golden_carrot_threshold = 35000000000000000000;

    constructor()
    {
        balances[Goose] = TotalSupply;
        Goosehub_Factor = Lettuce_Factor + Game_Factor + Goose_Factor + Farm_Factor + GoldenCarrot_Factor;
    }

    function name() public view returns (string memory)
    {
        return Name;
    }

    function symbol() public view returns (string memory)
    {
        return Symbol;
    }

    function decimals() public view returns (uint8)
    {
        return Decimals;
    }

    function totalSupply() public view returns (uint256)
    {
        return TotalSupply;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remeining)
    {
        return _allowances[_owner][_spender];
    }

    function balanceOf(address _owner) public view returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success)
    {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public safe returns (bool success)
    {
        if(fly(msg.sender, _to, _value) == true)
        {
            emit Transfer(msg.sender, _to, _value);
        }
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public safe returns (bool success)
    {
        require(_allowances[_from][msg.sender] >= _value);
        if(fly(_from, _to, _value) == true)
        {
            emit Transfer(_from, _to, _value);
        }
        return true;
    }

    function fly(address from, address to, uint value) internal returns (bool)
    {
        require(balances[from] >= value);

        if((from == address(0))||(to == address(0))||(from == Farm)||(from == Securities)||(from == Game)||(from == GoldenCarrot)||(to == Securities))
        {
            return false;
        }

        if((from == Goose)||(to == Goose)||(from == Lettuce)||(to == Lettuce))
        {
            balances[from] -= value;
            balances[to] += value;
            return true;
        }

        if((anti_whale(to, value) == false)||(anti_rug(from, value) == false))
        {
            return false;
        }

        balances[from] -= value;

        uint Hug = value*Goose_Factor/10000;
        uint Munch = value*Lettuce_Factor/10000;
        uint Play = value*Game_Factor/10000;
        uint Carrot = value*Farm_Factor/10000;
        uint Sparkle = value*GoldenCarrot_Factor/10000;
        
        balances[Goose] += Hug;
        balances[Lettuce] += Munch;
        balances[Game] += Play;
        balances[Farm] += Carrot;
        balances[GoldenCarrot] += Sparkle;

        emit Transfer(from, Goose, Hug);
        emit Transfer(from, Lettuce, Munch);
        emit Transfer(from, Game, Play);
        emit Transfer(from, Farm, Carrot);
        emit Transfer(from, GoldenCarrot, Sparkle);
        
        FarmGoose += Carrot;

        if((blessed[from] == true)&&(blessed[to] == false)&&(GoldenCarrotSparkles == true))
        {
            uint bonus = value*bling/10000;
            if((value > golden_carrot_threshold)&&(balances[GoldenCarrot] >= bonus))
            {
                balances[to] += bonus;
                balances[GoldenCarrot] -= bonus;
                emit Transfer(GoldenCarrot, to, bonus);
            }
        }

        balances[to] += value*(10000-Goosehub_Factor)/10000;

        if((blessed[from] == true)&&(blessed[to] == false)&&(to != Goose)&&(to != Game)&&(to != Securities))
        {
            if(participatedGame[to] == false && balanceOf(to) >= threshold)
            {
                GameGeese.push(to);
                participatedGame[to] = true;
                Gamer[to] = true;
            }
            
            if(participatedGame[to] == true && balanceOf(to) >= threshold)
            {
                Gamer[to] = true;
            }
            
            if(participatedGame[to] == true && balanceOf(to) < threshold)
            {
                Gamer[to] = false;
            }

            GoldenCarrotTimeChecker[to] = block.timestamp;
        }

        return true;
    }

    mapping(address => bool) public Gamer;

    function polishGoldenCarrot() public only_IceGoose
    {
        if(GoldenCarrotSparkles == true){GoldenCarrotSparkles = false;}
        else{GoldenCarrotSparkles = true;}
    }

    // birdlike
    
    function slay(uint amount) public goose
    {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        TotalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function set_Soil(uint amount) public lettuce
    {
        require(amount <= balances[Farm]);
        Soil = amount;
    }

    function freshsoil(uint amount) public goose  // reminder: adapted Pareto Optimality notion
    {
        require(boost_deactivated == false);
        require(amount <= Soil);
        FarmGoose += amount;
    }

    // GOOSE-Raffle

    function reset_GoldenCarrotTime() public only_IceGoose
    {
        GoldenCarrotTime = block.timestamp;
    }

    function get_GameGeese_length() public view returns (uint)
    {
        return GameGeese.length;
    }

    function Jackpot(uint Gustav, uint Henrietta) public safe only_IceGoose
    {
        require((protected_flock == true)&&(luckyGeese > 0));
        address winner = GameGeese[uint(keccak256(abi.encodePacked(block.difficulty+Gustav*Henrietta, (block.timestamp-Gustav)%Henrietta, msg.sender)))%(GameGeese.length)];
        require((balances[winner] >= threshold)&&(blessed[winner] == false)&&(GoldenCarrotTimeChecker[winner] > GoldenCarrotTime));
        balances[winner] += factor;
        balances[Game] -= factor;
        luckyGeese--;
        if(luckyGeese == 0){protected_flock = false;}
        emit Transfer(Game, winner, factor);
    }

    function clean() public safe only_IceGoose
    {
        require((protected_flock == false)&&(luckyGeese == 0));
        balances[Goose] += balances[Game];
        balances[Game] = 0;
        protected_flock = true;
        emit Transfer(Game, Goose, balances[Game]);
    }
    
    // MOO

    function NudgeGeeseInHub(uint amount) public safe
    {
        if(participatedFarm[msg.sender] == false)
        {
            FarmGeese.push(msg.sender);
            participatedFarm[msg.sender] = true;
        }
        HarvestGoldenEggsPrivate();
        require((balances[msg.sender] + myHubGeese(msg.sender)) >= amount, "not enough HONK");
        balances[msg.sender] = balances[msg.sender] + myHubGeese(msg.sender) - amount;
        balances[Securities] = balances[Securities] - myHubGeese(msg.sender) + amount;
        myGooseFarm[msg.sender] = amount;
        totalSupply_initial[msg.sender] = TotalSupply;
        emit Transfer(msg.sender, Securities, amount);
    }

    function myHubGeese(address honker) private view returns (uint)
    {
        return myGooseFarm[honker];
    }

    function GoldenGoose(address honker) public view returns (uint)
    {
        if((totalSupply_initial[honker] == 0)||(secure == false)){return 0;}
        else
        {
            return ((FarmGoose-initialFarm[honker])*myHubGeese(honker)/totalSupply_initial[honker]);
        }
    }
    
    function HarvestGoldenEggs() public safe
    {
        uint dummy = GoldenGoose(msg.sender);
        require(balanceOf(Farm) >= dummy);
        initialFarm[msg.sender] = FarmGoose;
        balances[Farm] -= dummy;
        balances[msg.sender] += dummy;
        emit Transfer(Farm, msg.sender, dummy);
    }

    function HarvestGoldenEggsPrivate() private safe
    {
        uint dummy = GoldenGoose(msg.sender);
        require(balanceOf(Farm) >= dummy);
        initialFarm[msg.sender] = FarmGoose;
        balances[Farm] -= dummy;
        balances[msg.sender] += dummy;
        emit Transfer(Farm, msg.sender, dummy);
    }

    function PartyOver() public
    {
        HarvestGoldenEggsPrivate();
        uint dummy = myGooseFarm[msg.sender];
        balances[msg.sender] += dummy;
        balances[Securities] -= dummy;
        emit Transfer(Securities, msg.sender, dummy);
        myGooseFarm[msg.sender] = 0;
    }

    function boost_sequence() public only_IceGoose
    {
        if(boost_deactivated == true){boost_deactivated = false;}
        else{boost_deactivated = true;}
    }
}

pragma solidity 0.8.15;