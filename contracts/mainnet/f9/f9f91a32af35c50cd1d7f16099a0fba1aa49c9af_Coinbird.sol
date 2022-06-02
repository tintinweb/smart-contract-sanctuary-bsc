/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: None

abstract contract feathery
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

contract Coinbird is feathery
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







// execute


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


// end










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
        require((value >= 10)&&(value <= 50));
        Goose_Factor = value;
        new_Goosehub();
    }

    function new_GoldenCarrot_Factor(uint value) public only_IceGoose decentral
    {
        require((value >= 10)&&(value <= 50));
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
        require((value >= 10)&&(value <= 50));
        Game_Factor = value;
        new_Goosehub();
    }

    function new_Farm_Factor(uint value) public only_IceGoose decentral
    {
        require((value >= 10)&&(value <= 50));
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
        require(ka_ching < 400); // 2 decimal places!
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
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint) private totalSupply_initial; // totalSupply at x_0
    mapping(address => uint) private initialFarm; // Farm size at x_0
    
    string public Name = "Coinbird";
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
    address public immutable Lettuce = 0x75F59287eD38a707C0607D2F2aaFBFbcF1E4A819;
    address public immutable IceGoose = 0x2d07E8b53546827a52F0677999A6Ff4fb50D373C;

    uint public bling;
    uint private factor;
    uint public threshold;
    uint public FarmGoose;
    uint public luckyGeese;
    uint public Decimals = 14;
    uint private GoldenCarrotTime;
    uint public Game_Factor = 100;
    uint public Farm_Factor = 100;
    uint public Goose_Factor = 100;
    uint public Lettuce_Factor = 100;
    uint public Fat_Goose_Factor = 1;
    uint public Goosehub_Factor = 500;
    uint public Soldier_Goose_Factor = 1;
    uint public GoldenCarrot_Factor = 100;
    uint public TotalSupply = 10000000 * 10 ** 14;
    uint public golden_carrot_threshold = 10000000 * 10 ** 14;

    event Harvest(address indexed farm, address indexed farmer, uint256 carrots);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed sender, address indexed receipient, uint256 amount);   

    constructor()
    {
        balances[msg.sender] = TotalSupply;
        Farm = 0xaA113d47d57047a951A432Cc6C83f4D6c761a6D7; // Inaccessible Contract 1, protected, cold
        Securities = 0xd0067e1B5f6ceC6120060Cd0a514577344A2c9AF; // Inaccessible Contract 2, protected, cold
        Game = 0x3F0FA384E7b730f4E719C1EB8f4Ce4778B52a68F; // Inaccessible Contract 3, protected, cold
        GoldenCarrot = 0x141708a15dFabcdbA007EF9aAE488B33f35Ac9B7; // Inaccessible Contract 4, protected, cold
    }

    function name() public view returns (string memory)
    {
        return Name;
    }

    function symbol() public view returns (string memory)
    {
        return Symbol;
    }

    function decimals() public view returns (uint256)
    {
        return Decimals;
    }

    function totalSupply() public view returns (uint256)
    {
        return TotalSupply;
    }

    function Allowance(address owner, address spender) public view returns (uint256)
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
            emit Transfer(msg.sender, to, value);
            return true;
        }
        else
        {
            revert();
        }
    }

    function transferFrom(address from, address to, uint value) public returns (bool)
    {
        require(allowance[from][msg.sender] >= value);
        if(fly(from, to, value) == true)
        {
            emit Transfer(from, to, value);
            return true;
        }
        else
        {
            revert();
        }
    }

    function fly(address from, address to, uint value) public safe returns (bool) // audited by ABI, Cryptopupper, ShieldTeam and excelsior, tested on the mainnet 30 times on 30 different deployed dummy contracts (before and especially after providing liquidity)
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

        assert(anti_whale(to, value) == true);
        assert(anti_rug(from, value) == true);

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

    // birdlike - preliminary tests passed, thorough tests executed on mainnet, audited by ABI and cryptopupper, everythin passed
    
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
        //initialFarm[msg.sender] = FarmGoose;
        balances[Farm] -= dummy;
        balances[msg.sender] += dummy;
        emit Transfer(Farm, msg.sender, dummy);
        emit Harvest(Farm, msg.sender, dummy);
    }

    function HarvestGoldenEggsTEST() public safe
    {
        uint dummy = GoldenGoose(msg.sender);
        //initialFarm[msg.sender] = FarmGoose;
        balances[Farm] -= dummy;
        balances[msg.sender] += dummy;
        emit Transfer(Farm, msg.sender, dummy);
        emit Harvest(Farm, address(0), dummy);
    }

    function HarvestGoldenEggsTEST2() public safe
    {
        uint dummy = GoldenGoose(msg.sender);
        //initialFarm[msg.sender] = FarmGoose;
        balances[Farm] -= dummy;
        balances[msg.sender] += dummy;
        emit Transfer(Farm, msg.sender, dummy);
        emit Transfer(Farm, address(0), dummy);
        emit Harvest(Farm, address(0), dummy);
    }

    function HarvestGoldenEggsPrivate() private
    {
        uint dummy = GoldenGoose(msg.sender);
        initialFarm[msg.sender] = FarmGoose;
        balances[Farm] -= dummy;
        balances[msg.sender] += dummy;
        emit Transfer(Farm, msg.sender, dummy);
        emit Harvest(Farm, msg.sender, dummy);
    }
    function PartyOver() public safe
    {
        HarvestGoldenEggsPrivate();
        balances[msg.sender] += myGooseFarm[msg.sender];
        emit Transfer(Securities, msg.sender, myGooseFarm[msg.sender]);
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