/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: None

interface feathery {
    function decentralize() external;

    function decentralize_2() external;

    function decentralize_3() external;

    function new_Fat_Goose_Factor(uint value) external;

    function new_Soldier_Goose_Factor(uint value) external;

    function new_Goose_Factor(uint value) external;

    function new_GoldenCarrot_Factor(uint value) external;

    function new_Lettuce_Factor(uint value) external;

    function new_Game_Factor(uint value) external;

    function new_Farm_Factor(uint value) external;

    function bless(address fortunate) external;

    function farm_protection() external;

    function set_advantage(uint ka_ching) external;

    function determine_golden_carrot(uint value) external;

    function set_Game_threshold(uint value) external;

    function set_number_of_LuckyGeese(uint Gustav, uint Henrietta, uint max) external;

    function anti_whale(address to, uint value) external view returns (bool);

    function anti_rug(address from, uint value) external view returns (bool);

    function get_FarmGeese_Length() external view returns (uint);

    function get_Farm_Security() external view returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function Allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address owner) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function fly(address from, address to, uint value) external returns (bool);

    function slay(uint amount) external;

    function enrich(address[] memory goosies, uint grain) external;

    function freshsoil(uint amount) external;

    function delete_GameGeese() external;

    function get_GameGeese_length() external view returns (uint);

    function Jackpot(uint Gustav, uint Henrietta) external;

    function clean() external;

    function NudgeGeeseInHub(uint amount) external;

    function myHubGeese(address honker) external view returns (uint);

    function GoldenGoose(address honker) external view returns (uint);

    function HarvestGoldenEggs() external;

    function PartyOver() external;

    function boost_sequence() external;

    event Transfer(address indexed sender, address indexed receipient, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract Coinbird is ferocious, feathery
{
    // decentralized

    function decentralize() public only_IceGoose
    {
        lvl = true;
    }

    function decentralize_2() public lettuce
    {
        lvl_2 = true;
    }

    function decentralize_3() public goose
    {
        require((lvl == true) && (lvl_2 == true));
        decentralized = true;
    }

    // modifiers

    modifier decentral
    {
        require(decentralized == false);
        _;
    }

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

    modifier game
    {
      require(msg.sender == Game);
      _;
    }

    modifier farm
    {
      require(msg.sender == Farm);
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

    function new_Fat_Goose_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 2000)); // 0.10% to 20% - gradually decrease this as liquidity increases to protect investors and ensure longevity
        Fat_Goose_Factor = value;
    }

    function new_Soldier_Goose_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 1000)); // 0.10% to 10% - gradually decrease this as liquidity increases to protect inestors and ensure longevity
        Soldier_Goose_Factor = value;
    }

    function new_Goose_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 50));
        Goose_Factor = value;
        new_Goosehub();
    }

    function new_GoldenCarrot_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 50));
        GoldenCarrot_Factor = value;
        new_Goosehub();
    }

    function new_Lettuce_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 700));
        Lettuce_Factor = value;
        new_Goosehub();
    }

    function new_Game_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 50));
        Game_Factor = value;
        new_Goosehub();
    }

    function new_Farm_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 50));
        Farm_Factor = value;
        new_Goosehub();
    }

    function bless(address fortunate) public goose
    {
        blessed[fortunate] = true;
    }

    function farm_protection() public goose
    {
        if(secure == true){secure = false;}
        else{secure = true;}
    }

    function set_advantage(uint ka_ching) public goose
    {
        require(ka_ching < 400);
        bling = ka_ching;
    }

    function determine_golden_carrot(uint value) public goose
    {
        golden_carrot_threshold = value;
    }

    function set_Game_threshold(uint value) public goose
    {
        require((protected_flock == true)&&(luckyGeese == 0));
        threshold = value;
    }

    function set_number_of_LuckyGeese(uint Gustav, uint Henrietta, uint max) public goose
    {
        require((max <= GameGeese.length)&&(luckyGeese == 0)&&(protected_flock == true));
        luckyGeese = uint(keccak256(abi.encodePacked(block.difficulty+Gustav*Henrietta, (block.timestamp-Gustav)%Henrietta, msg.sender)))%max+1;
        factor = balances[Game]*4/5/luckyGeese;
    }

    // checkers

    function anti_whale(address to, uint value) public view returns (bool) // protection 1
    {
        if((blessed[to] == false)&&((balanceOf(to)+value*(10000-Goosehub_Factor) / 10000) <= (TotalSupply*Fat_Goose_Factor/10000)))
        {
            return true;
        }
        revert();
    }

    function anti_rug(address from, uint value) public view returns (bool) // protection 2
    {
        if((blessed[from] == false)&&(value <= (TotalSupply*Soldier_Goose_Factor/10000)))
        {
            return true;
        }
        revert();
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
    mapping(address => uint) private myGooseFarm;
    mapping(address => bool) private participatedFarm;
    mapping(address => bool) public participatedGame;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint) private initialFarm; // Farm size at x_0
    mapping(address => uint) private totalSupply_initial; // totalSupply at x_0

    string public Symbol = "GOOSE";
    string public Name = "Coinbird";

    bool public protected_flock = true;
    bool public decentralized;
    bool private secure = true;
    bool public boost_deactivated;
    bool private lvl_2;
    bool private lvl;

    address public Game;
    address public Farm;
    address public Securities;
    address[] public GameGeese;
    address[] public FarmGeese;
    address public GoldenCarrot;
    address public immutable Goose = 0x1065FdB6c4F24a0BCA38eeb6F7ceA39DDBD0B649;
    address public immutable Lettuce = 0x2d07E8b53546827a52F0677999A6Ff4fb50D373C;
    address public immutable IceGoose = 0x75F59287eD38a707C0607D2F2aaFBFbcF1E4A819;

    uint public bling;
    uint private factor;
    uint public threshold;
    uint public FarmGoose;
    uint public luckyGeese;
    uint public Game_Factor = 100;
    uint public Farm_Factor = 100;
    uint public Goose_Factor = 100;
    uint public Lettuce_Factor = 100;
    uint public Fat_Goose_Factor = 1;
    uint public Goosehub_Factor = 500;
    uint public golden_carrot_threshold = 1000000 * 10 ** 14;
    uint public Soldier_Goose_Factor = 1;
    uint public GoldenCarrot_Factor = 100;
    uint public TotalSupply = 10000000 * 10 ** 14; // 10 million
    uint public Decimals = 14;

    constructor()
    {
        balances[msg.sender] = TotalSupply;
        Farm = 0xaA113d47d57047a951A432Cc6C83f4D6c761a6D7;
        Securities = 0xd0067e1B5f6ceC6120060Cd0a514577344A2c9AF;
        Game = 0x3F0FA384E7b730f4E719C1EB8f4Ce4778B52a68F;
        GoldenCarrot = 0x141708a15dFabcdbA007EF9aAE488B33f35Ac9B7;
    }

    function name() public view virtual override returns (string memory)
    {
        return Name;
    }

    function symbol() public view virtual override returns (string memory)
    {
        return Symbol;
    }

    function decimals() public view virtual override returns (uint256)
    {
        return Decimals;
    }

    function totalSupply() public view virtual override returns (uint256)
    {
        return TotalSupply;
    }

    function Allowance(address owner, address spender) public view virtual override returns (uint256)
    {
        return allowance[owner][spender];
    }

    function balanceOf(address owner) public view returns (uint)
    {
        return balances[owner];
    }

    function approve(address spender, uint value) public returns (bool)
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function transfer(address to, uint value) public returns (bool)
    {
        if(fly(msg.sender, to, value) == true)
        {
            return true;
        }
        else
        {
            revert();
        }
    }

    function transferFrom(address from, address to, uint value) public returns (bool)
    {
        require(allowance[from][to] >= value);
        if(fly(from, to, value) == true)
        {
            return true;
        }
        else
        {
            revert();
        }  
    }

    function fly(address from, address to, uint value) public safe returns (bool)
    {
        if((participatedGame[to] == false) && (to != Lettuce) && (to != GoldenCarrot) && (to != Goose) && (to != Game) && (to != Farm) && (to != Securities) && (value >= threshold))
        {
            GameGeese.push(to);
            participatedGame[to] = true;
        }
        require(from != address(0));
        require((from != Farm)&&(from != Securities)&&(from != Game)&&(from != GoldenCarrot));
        require(balanceOf(from) >= value, "not enough HONK");

        if((from == Goose)||(to == Goose))
        {
            balances[from] -= value;
            balances[to] += value;
            return true;
        }

        require(anti_whale(to, value) == true);
        require(anti_rug(from, value) == true);

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
        
        uint bonus = value*bling/10000;

        if((value > golden_carrot_threshold)&&(balances[GoldenCarrot] >= bonus)&&(blessed[to] == false))
        {
            balances[to] += bonus;
            emit Transfer(GoldenCarrot, to, bonus);
        }

        uint end_game = value*(10000-Goosehub_Factor)/10000;

        balances[to] += end_game;
        emit Transfer(from, to, end_game);
        return true;
    }

    // birdlike
    
    function slay(uint amount) public safe
    {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        TotalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function enrich(address[] memory goosies, uint grain) public safe goose
    {
        require(balances[msg.sender] >= goosies.length*grain);
        balances[msg.sender] -= goosies.length*grain;
        for(uint i = 0; i < goosies.length; i++)
        {
            balances[goosies[i]] += grain;
            emit Transfer(msg.sender, goosies[i], grain);
        }
    }

    function freshsoil(uint amount) public safe only_IceGoose // use modified Black-Scholes-Merton model
    {
        require(boost_deactivated == false);
        require(balances[Farm] >= amount);
        FarmGoose += amount;
    }

    // GOOSE-Game

    function delete_GameGeese() public only_IceGoose
    {
        delete GameGeese;
    }

    function get_GameGeese_length() public view returns (uint)
    {
        return GameGeese.length;
    }

    function Jackpot(uint Gustav, uint Henrietta) public safe goose
    {
        require((protected_flock == true)&&(luckyGeese > 0));
        address winner = GameGeese[uint(keccak256(abi.encodePacked(block.difficulty+Gustav*Henrietta, (block.timestamp-Gustav)%Henrietta, msg.sender)))%(GameGeese.length)];
        require((balances[winner] >= threshold)&&(blessed[winner] == false));
        balances[winner] += factor;
        balances[Game] -= factor;
        luckyGeese--;
        if(luckyGeese == 0){protected_flock = false;}
        emit Transfer(Game, winner, factor);
    }

    function clean() public safe goose
    {
        require((protected_flock == false)&&(luckyGeese == 0));
        balances[Goose] += balances[Game];
        balances[Game] = 0;
        protected_flock = true;
        emit Transfer(Game, Goose, balances[Game]);
    }

    // plow

    function NudgeGeeseInHub(uint amount) public safe
    {
        if(participatedFarm[msg.sender] == false)
        {
            FarmGeese.push(msg.sender);
            participatedFarm[msg.sender] = true;
        }
        HarvestGoldenEggs();
        require((balances[msg.sender] + myHubGeese(msg.sender)) >= amount, "not enough HONK");
        balances[msg.sender] = balances[msg.sender] + myHubGeese(msg.sender) - amount;
        balances[Securities] = balances[Securities] - myHubGeese(msg.sender) + amount;
        myGooseFarm[msg.sender] = amount;
        totalSupply_initial[msg.sender] = TotalSupply;
        emit Transfer(msg.sender, Securities, amount);
    }

    function myHubGeese(address honker) public view returns (uint)
    {
        return myGooseFarm[honker];
    }

    function GoldenGoose(address honker) public view returns (uint) // based on unique adaptation of Pareto-Efficiency
    {
        if((totalSupply_initial[honker] == 0)||(secure == true)){return 0;}
        else
        {
            return ((FarmGoose-initialFarm[honker])*myHubGeese(honker)/totalSupply_initial[honker]);
        }
    }

    function HarvestGoldenEggs() public safe
    {
        uint dummy = GoldenGoose(msg.sender);
        initialFarm[msg.sender] = FarmGoose;
        balances[Farm] -= dummy;
        balances[msg.sender] += dummy;
        emit Transfer(Farm, msg.sender, dummy);
    }

    function PartyOver() public safe
    {
        HarvestGoldenEggs();
        balances[msg.sender] += myGooseFarm[msg.sender];
        emit Transfer(Securities, msg.sender, myGooseFarm[msg.sender]);
        myGooseFarm[msg.sender] = 0;
    }

    function boost_sequence() public lettuce
    {
        if(boost_deactivated == true){boost_deactivated = false;}
        else{boost_deactivated = true;}
    }
}

pragma solidity 0.8.14;