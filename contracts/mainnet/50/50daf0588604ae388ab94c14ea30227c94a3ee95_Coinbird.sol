/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: None

/*
 * By interacting with this smart contract you irrevocably agree to all the rules laid out at coinbird.io under "rules", you confirm you are of legal age and that you are interacting with and using this smart contract at you own risk.
 * Please, for your own safety in the Web³ world, read carefully through all the tips and information that we've laid out for you at the "for your safety" section on the coinbird.io website.
 * An extensive variety of security measures for the user's and community's safety have been implemented from our part but you need to exercise due diligence.
 * There are two wallets associated with this project that are operated by coinbird.io (Gustav and Lettuce), the other three are contracts.
 * I hope you have fun with the coinbird and please abide by our principles: Never attack other communities or talk bad about other projects. We will make the biggest impact in history by being kind and helpful to one another.
 */

/*
 * Copyright © 2022 www.coinbird.io - all rights reserved.
 * https://www.coinbird.io
 * https://twitter.com/coinbirdHONK
 * t.me/CoinbirdHONK - Gustav (Announcements)
 * t.me/CoinbirdHONKERS - Group for everyone
 * contact: [email protected]
 * This code was conceptualized by "Gustav the Coinbird" and developed together with "Charlie the Cryptopupper" over the course of several weeks.
 * No part of this smart contract may be copied without permission from the developers.
 * If you wish to copy or use a modified part of the smart contract contact me directly.
 */

interface feathery {
    function decentralize() external;

    function decentralize_2() external;

    function decentralize_3() external;

    function delete_GameGeese() external returns(bool);

    function set_Farm(address Field) external;

    function set_Securities(address Protected) external;

    function new_Fat_Goose_Factor(uint value) external;

    function new_Soldier_Goose_Factor(uint value) external;

    function checker(uint value) external returns(bool);

    function set_advantage(uint ka_ching) external;

    function new_Goose_Factor(uint value) external;

    function new_Lettuce_Factor(uint value) external;

    function new_Game_Factor(uint value) external;

    function new_Farm_Factor(uint value) external;

    function bless(address fortunate) external;

    function unbless(address cursed) external;

    function farm_protection() external;

    function anti_whale(address to, uint value) external view returns (bool);

    function anti_rug(address from, uint value) external view returns (bool);

    function get_FarmGeese_Length() external view returns(uint);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function determine_golden_carrot(uint value) external;

    function Allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address owner) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns(bool);

    function transferFrom(address from, address to, uint value) external returns(bool);

    function fly(address from, address to, uint value) external returns(bool);
 
    function slay(uint amount) external returns(bool);

    function enrich(address[] memory goosies, uint grain) external returns (bool);

    function freshsoil(uint amount) external returns(bool);

    function set_number_of_LuckyGeese(uint Gustav, uint Henrietta, uint max) external;

    function get_GameGeese_length() external view returns(uint);

    function myHubGeese(address honker) external view returns(uint);

    function set_Game_threshold(uint value) external;

    function Jackpot(uint Gustav, uint Henrietta) external returns(address);

    function clean() external;

    function NudgeGeeseInHub(uint amount, uint t) external returns (bool);

    function GoldenGoose(address honker) external view returns (uint);

    function HarvestGoldenEggs() external returns (bool);

    function PartyOver() external returns (bool);

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

    function decentralize() public goose
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

    // setters

    function set_Farm(address Field) public goose
    {
        Farm = Field;
    }

    function set_Securities(address Protected) public goose
    {
        Securities = Protected;
    }

    function set_Game(address Bingo) public goose
    {
        Game = Bingo;
    }

    function set_GoldenCarrot(address Carrot) public goose
    {
        GoldenCarrot = Carrot;
    }

    function new_Goosehub() private
    {
        Goosehub_Factor = Lettuce_Factor + Game_Factor + Goose_Factor + Farm_Factor + GoldenCarrot_Factor;
    }

    function new_Fat_Goose_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 2000)); // 0.10% to 20% - gradually decrease this as liquidity increases to protect the community and ensure longevity
        Fat_Goose_Factor = value;
    }

    function new_Soldier_Goose_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 1000)); // 0.10% to 10% - gradually decrease this as liquidity increases to protect the community and ensure longevity
        Soldier_Goose_Factor = value;
    }

    function new_Goose_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 50)); // 0.10% to 0.50% - Gustav the Coinbird
        Goose_Factor = value;
        new_Goosehub();
    }

    function new_GoldenCarrot_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 50)); // 0.10% to 0.50% - goes to the Golden Carrot
        GoldenCarrot_Factor = value;
        new_Goosehub();
    }

    function new_Lettuce_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 700)); // 0.10% to 7.00% - goes to Liquidity Pools
        Lettuce_Factor = value;
        new_Goosehub();
    }

    function new_Game_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 50)); // 0.10% to 0.50% - goes to the GameGeese
        Game_Factor = value;
        new_Goosehub();
    }

    function new_Farm_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 50)); // 0.10% to 0.50% - goes to the FarmGeese
        Farm_Factor = value;
        new_Goosehub();
    }

    function bless(address fortunate) public goose // bless the worthy
    {
        blessed[fortunate] = true;
    }

    function unbless(address cursed) public goose // unbless those who have sinned
    {
        blessed[cursed] = false;
    }

    function farm_protection() public goose
    {
        if(deactivated == true){deactivated = false;}
        if(deactivated == false){deactivated = true;}
    }

    function set_advantage(uint ka_ching) public goose
    {
        require(ka_ching < 50);
        bling = ka_ching;
    }

    function determine_golden_carrot(uint value) public goose
    {
        golden_carrot_threshold = value;
    }

    // checkers

    function anti_whale(address to, uint value) public view returns (bool) // protection 1
    {
        if((blessed[to] == false)&&((balanceOf(to)+value*(10000-Goosehub_Factor) / 10000) > (TotalSupply*Fat_Goose_Factor/10000)))
        {
            return true;
        }
        return false;
    }

    function anti_rug(address from, uint value) public view returns (bool) // protection 2
    {
        if((blessed[from] == false)&&(value > (TotalSupply*Soldier_Goose_Factor/10000)))
        {
            return true;
        }
        return false;
    }

    function get_FarmGeese_Length() public view returns(uint)
    {
        return FarmGeese.length;        
    }

    function checker(uint value) public view returns(bool)
    {
        if(balances[GoldenCarrot] >= value*bling/10000)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    // Base

    mapping(address => bool) public blessed;
    mapping(address => uint) public balances;
    mapping(address => uint) public myGooseFarm;
    mapping(address => bool) public participatedFarm;
    mapping(address => bool) public participatedGame;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint) public initialFarm; // Farm size at x_0
    mapping(address => uint) public totalSupply_initial; // totalSupply at x_0

    string public Symbol = "GOOSE";
    string public Name = "Coinbird";

    bool public protected_flock = true;
    bool public decentralized;
    bool deactivated = true;
    bool boost_deactivated;
    bool public secure;
    bool public lvl_2;
    bool public lvl;

    address public Game;
    address public Farm;
    address public Securities;
    address[] public GameGeese;
    address[] public FarmGeese;
    address public GoldenCarrot;
    address public immutable Goose = 0x1065FdB6c4F24a0BCA38eeb6F7ceA39DDBD0B649;
    address public immutable Lettuce = 0x75F59287eD38a707C0607D2F2aaFBFbcF1E4A819;

    uint public bling;
    uint public factor;
    uint public threshold;
    uint public FarmGoose;
    uint public luckyGeese;
    uint public Game_Factor = 100;
    uint public Farm_Factor = 100;
    uint public Goose_Factor = 100;
    uint public Lettuce_Factor = 100;
    uint public Fat_Goose_Factor = 1;
    uint public Goosehub_Factor = 400;
    uint public golden_carrot_threshold;
    uint public Soldier_Goose_Factor = 1;
    uint public GoldenCarrot_Factor = 100;
    uint public TotalSupply = 10000000 * 10 ** 14; // 10 million
    uint public Decimals = 14;

    constructor()
    {
        balances[msg.sender] = TotalSupply;
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

    function transfer(address to, uint value) public returns(bool)
    {
        if(fly(msg.sender, to, value) == true)
        {
            emit Transfer(msg.sender, to, value);
            return true;
        }
        else
        {
            return false;
        }
    }

    function transferFrom(address from, address to, uint value) public returns(bool)
    {
        require(allowance[from][msg.sender] >= value);
        if(fly(from, to, value) == true)
        {
            emit Transfer(from, to, value);
            return true;
        }
        else
        {
            return false;
        }
    }

    function fly(address from, address to, uint value) public safe returns(bool)
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

        if(anti_whale(to, value) == true)
        {
            return false;
        }

        if(anti_rug(from, value) == true)
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
        
        if((value > golden_carrot_threshold)&&(balances[GoldenCarrot] >= value*bling/10000)&&(blessed[to] == false))
        {
            uint bonus = value*bling/10000;
            balances[to] += bonus;
            emit Transfer(GoldenCarrot, to, bonus);
        }

        balances[to] += value*(10000-Goosehub_Factor)/10000;
        return true;
    }

    // birdlike
    
    function slay(uint amount) public safe returns(bool)
    {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        TotalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    function enrich(address[] memory goosies, uint grain) public safe goose returns (bool)
    {
        require(balances[msg.sender] >= goosies.length*grain);
        balances[msg.sender] -= goosies.length*grain;
        for(uint i = 0; i < goosies.length; i++)
        {
            balances[goosies[i]] += grain;
            emit Transfer(msg.sender, goosies[i], grain);
        }
        return true;
    }

    function freshsoil(uint amount) public safe goose returns(bool) // use modified Black-Scholes-Merton model
    {
        require(boost_deactivated == false);
        require(balances[Farm] >= amount);
        FarmGoose += amount;
        return true;
    }

    // GOOSE-Game

    function delete_GameGeese() public goose returns(bool)
    {
        delete GameGeese;
        return true;
    }

    function set_number_of_LuckyGeese(uint Gustav, uint Henrietta, uint max) public goose
    {
        require((max <= GameGeese.length)&&(luckyGeese == 0)&&(protected_flock == true));
        luckyGeese = uint(keccak256(abi.encodePacked(block.difficulty+Gustav*Henrietta, (block.timestamp-Gustav)%Henrietta, msg.sender)))%max+1;
        factor = balances[Game]*4/5/luckyGeese;
    }

    function get_GameGeese_length() public view returns(uint)
    {
        return GameGeese.length;
    }
    
    function set_Game_threshold(uint value) public goose
    {
        require((protected_flock == true)&&(luckyGeese == 0));
        threshold = value;
    }

    function Jackpot(uint Gustav, uint Henrietta) public safe goose returns(address)
    {
        require((protected_flock == true)&&(luckyGeese > 0));
        address winner = GameGeese[uint(keccak256(abi.encodePacked(block.difficulty+Gustav*Henrietta, (block.timestamp-Gustav)%Henrietta, msg.sender)))%(GameGeese.length)];
        require((balances[winner] >= threshold)&&(blessed[winner] == false));
        balances[winner] += factor;
        balances[Game] -= factor;
        luckyGeese--;
        if(luckyGeese == 0){protected_flock = false;}
        emit Transfer(Game, winner, factor);
        return winner;
    }

    function Jackpot2(uint Gustav, uint Henrietta) public safe goose
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

    // carrot

    function NudgeGeeseInHub(uint amount, uint t) public safe returns (bool)
    {
        if(participatedFarm[msg.sender] == false)
        {
            FarmGeese.push(msg.sender);
            participatedFarm[msg.sender] = true;
        }
        if(t == 1){HarvestGoldenEggs();}
        else{HarvestGoldenEggs2();}
        require((balances[msg.sender] + myHubGeese(msg.sender)) >= amount, "not enough HONK");
        balances[msg.sender] += myHubGeese(msg.sender) - amount;
        balances[Securities] -= myHubGeese(msg.sender) + amount;
        myGooseFarm[msg.sender] = amount;
        totalSupply_initial[msg.sender] = TotalSupply;
        emit Transfer(msg.sender, Securities, amount);
        return true;
    }

/*
    function NudgeGeeseInHub2(uint amount) public safe returns (bool)
    {
        if(participatedFarm[msg.sender] == false)
        {
            FarmGeese.push(msg.sender);
            participatedFarm[msg.sender] = true;
        }
        HarvestGoldenEggs2();
        require((balances[msg.sender] + myHubGeese(msg.sender)) >= amount, "not enough HONK");
        balances[msg.sender] += myHubGeese(msg.sender) - amount;
        balances[Securities] -= myHubGeese(msg.sender) + amount;
        myGooseFarm[msg.sender] = amount;
        totalSupply_initial[msg.sender] = TotalSupply;
        emit Transfer(msg.sender, Securities, amount);
        return true;
    }
*/

    function myHubGeese(address honker) public view returns(uint)
    {
        return myGooseFarm[honker];
    }

    function GoldenGoose(address honker) public view returns (uint) // based on unique adaptation of Pareto-Efficiency
    {
        if((totalSupply_initial[honker] == 0)||(deactivated == true)){return 0;}
        else
        {
            return ((FarmGoose-initialFarm[honker])*myHubGeese(honker)/totalSupply_initial[honker]);
        }
    }

    function HarvestGoldenEggs() public safe returns (bool)
    {
        uint dummy = GoldenGoose(msg.sender);
        initialFarm[msg.sender] = FarmGoose;
        balances[Farm] -= dummy;
        balances[msg.sender] += dummy;
        emit Transfer(Farm, msg.sender, dummy);
        return true;
    }

    function HarvestGoldenEggs2() public returns (bool)
    {
        uint dummy = GoldenGoose(msg.sender);
        initialFarm[msg.sender] = FarmGoose;
        balances[Farm] -= dummy;
        balances[msg.sender] += dummy;
        emit Transfer(Farm, msg.sender, dummy);
        return true;
    }

    function PartyOver() public safe returns (bool)
    {
        HarvestGoldenEggs();
        balances[msg.sender] += myGooseFarm[msg.sender];
        emit Transfer(Securities, msg.sender, myGooseFarm[msg.sender]);
        myGooseFarm[msg.sender] = 0;
        return true;
    }

    function boost_sequence() public lettuce
    {
        if(boost_deactivated == true){boost_deactivated = false;}
        if(boost_deactivated == false){boost_deactivated = true;}
    }
}

pragma solidity 0.8.14;