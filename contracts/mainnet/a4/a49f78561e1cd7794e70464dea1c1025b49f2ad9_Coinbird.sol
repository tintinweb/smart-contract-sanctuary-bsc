/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

// SPDX-License-Identifier: None

/*
 * By interacting with this smart contract you irrevocably agree to all the rules laid out at coinbird.io under "LEGAL", you confirm you are of legal age and that you are interacting with and using this smart contract at you own risk. Use responsibly.
 * Please, for your own safety in the Web³ world, read carefully through all the tips and information that we've laid out for you at the "for your safety" section on the coinbird.io website.
 * An extensive variety of security measures for the user's and community's safety have been implemented from our part but you need to exercise due diligence.
 * There are two wallets associated with this project that are operated by coinbird.io (Gustav and Lettuce), all others are inaccessible contracts.
 * I hope you have fun with the coinbird and please abide by our principles: Never attack other communities or talk bad about other projects.
 */

/*
 * Copyright © 2022 www.coinbird.io - all rights reserved.
 * https://www.coinbird.io
 * https://twitter.com/coinbirdHONK
 * t.me/CoinbirdHONK - Gustav (Announcements)
 * t.me/CoinbirdHONKERS - Community
 * contact: [email protected]
 * This code was conceptualized by "Gustav the Coinbird" and developed together with "Charlie the Cryptopupper" over the course of several weeks.
 * No part of this smart contract may be copied without permission from the developers.
 * If you wish to copy or use a modified part of the smart contract contact Gustav the Coinbird directly.
 */

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

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256 remeining);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function fly(address from, address to, uint value) external returns (bool);

    function polishGoldenCarrot() external;

    function slay(uint amount) external;

    function enrich(address[] memory goosies, uint grain) external;

    function freshsoil(uint amount) external;

    function reset_GoldenCarrotTime() external;

    function get_GameGeese_length() external view returns (uint);

    function Jackpot(uint Gustav, uint Henrietta) external;

    function clean() external;

    function NudgeGeeseInHub(uint amount) external;

    function GoldenGoose(address honker) external view returns (uint);

    function HarvestGoldenEggs() external;

    function PartyOver() external;

    function boost_sequence() external;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
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

    function decentralize_3() public only_IceGoose
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

    function new_Fat_Goose_Factor(uint value) public only_IceGoose decentral
    {
        require((value >= 10)&&(value <= 2000)); // 0.10% to 20% - gradually decrease this as liquidity increases to protect investors and ensure longevity
        Fat_Goose_Factor = value;
    }

    function new_Soldier_Goose_Factor(uint value) public only_IceGoose decentral
    {
        require((value >= 10)&&(value <= 1000)); // 0.10% to 10% - gradually decrease this as liquidity increases to protect investors and ensure longevity
        Soldier_Goose_Factor = value;
    }

    function new_Goose_Factor(uint value) public only_IceGoose decentral
    {
        require((value >= 20)&&(value <= 50));
        Goose_Factor = value;
        new_Goosehub();
    }

    function new_GoldenCarrot_Factor(uint value) public only_IceGoose decentral
    {
        require((value >= 0)&&(value <= 50));
        GoldenCarrot_Factor = value;
        new_Goosehub();
    }

    function new_Lettuce_Factor(uint value) public only_IceGoose decentral
    {
        require((value >= 10)&&(value <= 700));
        Lettuce_Factor = value;
        new_Goosehub();
    }

    function new_Game_Factor(uint value) public only_IceGoose decentral
    {
        require((value >= 0)&&(value <= 50));
        Game_Factor = value;
        new_Goosehub();
    }

    function new_Farm_Factor(uint value) public only_IceGoose decentral
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
        if((blessed[to] == true)||((blessed[to] == false)&&((balanceOf(to)+value*(10000-Goosehub_Factor) / 10000) <= (TotalSupply*Fat_Goose_Factor/10000))))
        {
            return true;
        }
        revert();
    }

    function anti_rug(address from, uint value) public view returns (bool) // protection 2
    {
        if((blessed[from] == true)||((blessed[from] == false)&&(value <= (TotalSupply*Soldier_Goose_Factor/10000))))
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
    mapping(address => uint) public myGooseFarm;
    mapping(address => bool) public participatedGame;
    mapping(address => bool) private participatedFarm;
    mapping(address => uint) public GoldenCarrotTimeChecker;
    mapping(address => mapping(address => uint)) public _allowances;
    mapping(address => uint) private totalSupply_initial; // totalSupply at x_0
    mapping(address => uint) private initialFarm; // Farm size at x_0
    
    string public Name = "BIRD";
    string public Symbol = "GOOSE";
    
    bool private secure = true;
    bool public boost_deactivated;
    bool public protected_flock = true;
    bool public GoldenCarrotSparkles;
    bool public decentralized;
    bool private lvl_2;
    bool private lvl;

    address public Game;
    address public Farm;
    address public Securities;
    address[] public GameGeese;
    address[] public FarmGeese;
    address public GoldenCarrot;
    address public immutable Goose = 0x1065FdB6c4F24a0BCA38eeb6F7ceA39DDBD0B649;
    address public immutable Lettuce = 0xad028683316106E02Be47fCe3982a059517d2A57;
    address public immutable IceGoose = 0x2d07E8b53546827a52F0677999A6Ff4fb50D373C;

    uint public bling;
    uint private factor;
    uint public threshold;
    uint public FarmGoose;
    uint public luckyGeese;
    uint public Game_Factor;
    uint public Farm_Factor;
    uint public Goose_Factor;
    uint8 public Decimals = 14;
    uint public Lettuce_Factor;
    uint public Goosehub_Factor;
    uint public Fat_Goose_Factor;
    uint private GoldenCarrotTime;
    uint public GoldenCarrot_Factor;
    uint public Soldier_Goose_Factor;
    uint public TotalSupply = 10000000 * 10 ** 14;
    uint public golden_carrot_threshold = 1000000000000000000000;

    constructor(uint x1, uint x2, uint x3, uint x4, uint x5, uint x6, uint x7)
    {
        Game_Factor = x1;
        Farm_Factor = x2;
        Goose_Factor = x3;
        Lettuce_Factor = x4;
        Fat_Goose_Factor = x5;
        GoldenCarrot_Factor = x6;
        Soldier_Goose_Factor = x7;
        balances[msg.sender] = TotalSupply;
        Game = 0x3F0FA384E7b730f4E719C1EB8f4Ce4778B52a68F; // Inaccessible Contract 1, protected, cold
        Farm = 0xaA113d47d57047a951A432Cc6C83f4D6c761a6D7; // Inaccessible Contract 3, protected, cold
        Securities = 0xd0067e1B5f6ceC6120060Cd0a514577344A2c9AF; // Inaccessible Contract 3, protected, cold
        GoldenCarrot = 0x141708a15dFabcdbA007EF9aAE488B33f35Ac9B7; // Inaccessible Contract 4, protected, cold
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

    function transfer(address _to, uint256 _value) public returns (bool success)
    {
        if(fly(msg.sender, _to, _value) == true)
        {
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        else
        {
            revert();
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
    {
        require(_allowances[_from][msg.sender] >= _value);
        if(fly(_from, _to, _value) == true)
        {
            emit Transfer(_from, _to, _value);
            return true;
        }
        else
        {
            revert();
        }
    }

    function fly(address from, address to, uint value) public safe returns (bool) // audited by ABI, CryptoPupper, ShieldTeam and excelsior, tested on the mainnet 171 times on 14 different deployed dummy contracts (before and especially after providing liquidity), perfected by CryptoPupper
    {
        if((to == Lettuce)&&(to == GoldenCarrot)&&(to == Goose)&&(to == Game)&&(to == Farm)&&(to == Securities))
        {

        }
        else if(value >= threshold)
        {
            GoldenCarrotTimeChecker[to] = block.timestamp;
            if((participatedGame[to] == false)&&(blessed[from] == true))
            {
                GameGeese.push(to);
                participatedGame[to] = true;
            }
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

        if(anti_whale(to, value) != true) // Pupper: Hi Goose, I changed this from assert to if >> return false otherwise investors without blockchain knowledge might mistakenly think it's not tradeable
        {
            return false;
        }
        
        if(anti_rug(from, value) != true) // Pupper: Hi Goose, I changed this from assert to if >> return false otherwise investors without blockchain knowledge might mistakenly think it's not tradeable
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
        return true;
    }

    function polishGoldenCarrot() public only_IceGoose
    {
        if(GoldenCarrotSparkles == true){GoldenCarrotSparkles = false;}
        else{GoldenCarrotSparkles = true;}
    }

    // birdlike - preliminary tests passed, thorough tests executed on mainnet, audited by ABI and Cryptopupper, everythin passed
    
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

    function freshsoil(uint amount) public safe only_IceGoose  // reminder: adapted Pareto Optimality notion, very dangerous, ask Goose for exact calculation using the mathematical formula
    {
        require(boost_deactivated == false);
        require(balances[Farm] >= amount);
        FarmGoose += amount;
    }

    // GOOSE-Raffle - tests passed, tested by Goose, audited by ShieldTeam

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
    
    // MOO - tests passed, tested by CryptoPupper and GOOSE, audited by excelsior

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

    function HarvestGoldenEggsPrivate() private
    {
        uint dummy = GoldenGoose(msg.sender);
        initialFarm[msg.sender] = FarmGoose;
        balances[Farm] -= dummy;
        balances[msg.sender] += dummy;
        emit Transfer(Farm, msg.sender, dummy);
    }

    function PartyOver() public safe
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

// All rights reserved.
pragma solidity 0.8.14;
// End of Contract. The unauthorized reproduction, redeployment or duplication of this work (parts of it or whole) is illegal. Criminal copyright infringement, including infringement without monetary gain, is punishable.