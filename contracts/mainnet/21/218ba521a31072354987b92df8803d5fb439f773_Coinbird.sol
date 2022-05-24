/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: None

/*
 * By interacting with this smart contract you irrevocably agree to all the rules laid out at coinbird.io under "rules", you confirm you are of legal age and that you are interacting with and using this smart contract at you own risk.
 * An extensive variety of security measures for the user's and community's safety have been implemented. For more information read through the smart contract, refer to the "for your safety" section on the coinbird.io website and please follow all the safety tips that can be found there.
 * The three wallets associated with coinbird.io can be found in this smart contract. Their interactions are all logged and they are bound to full transparency and open source fund management - meaning you may request further information on any transaction that was executed by them by contacting me through the "talk to me" section at coinbird.io
 * I hope you have fun with the coinbird, let us create a friendly and kind community that will go down in history as something beautiful. Gustav the coinbird is very excited to revolutionize the world :)
 */

/*
 * Copyright © 2022 www.coinbird.io - all rights reserved.
 * https://www.coinbird.io
 * https://twitter.com/coinbirdHONK
 * t.me/thecoinbirds
 * contact: [email protected]
 * This code was developed by "Charlie the Cryptopupper" and "Gustav the Coinbird" over the course of several months.
 * No part of this smart contract may be copied without permission from the developers.
 * If you wish to copy or use a modified part of the smart contract contact me directly.
 */

interface feathery {
    function decentralize() external;

    function decentralize_2() external;

    function decentralize_3() external;

    function decentralize_4() external;

    function new_Fat_Goose_Factor(uint value) external;

    function new_Soldier_Goose_Factor(uint value) external;

    function new_Goose_Factor(uint value) external;

    function new_Lettuce_Factor(uint value) external;

    function new_Soil_Factor(uint value) external;

    function get_Fat_Goose_Factor() external view returns(uint);

    function get_Soldier_Goose_Factor() external view returns(uint);

    function get_Goose_Factor() external view returns(uint);

    function get_Lettuce_Factor() external view returns(uint);

    function get_Soil_Factor() external view returns(uint);

    function get_slippage() external view returns(uint);

    function name() external returns (string memory);

    function symbol() external returns (string memory);

    function decimals() external returns (uint256);

    function totalSupply() external returns (uint256);

    function Allowance(address owner, address spender) external returns (uint256);

    function balanceOf(address owner) external returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns(bool);

    function transferFrom(address from, address to, uint value) external returns(bool);

    function bless(address fortunate) external;

    function unbless(address cursed) external;

    function fly(address from, address to, uint value) external returns(bool);

    function slay(uint amount) external returns (bool);

    function breadcrumbs(address[] calldata goosies, uint grain) external returns (bool);

    function stake(uint amount) external returns (bool);

    function reward(address gooser) external view returns (uint);

    function harvest() external returns (bool);

    function unstake() external returns (bool);

    function freshsoil(uint amount) external returns (bool);

    event Transfer(address indexed sender, address indexed receipient, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event FreshSoil(address indexed farmgoose, uint indexed Farm, uint indexed amount);

    event Farming(address indexed farmer, uint indexed soil);

    event Slay(address indexed slayer, uint indexed offering);
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

    bool public decentralized;

    bool public lvl;
    bool public lvl_2;
    bool public lvl_3;

    bool deactivated = true;
    
    function decentralize() public goose
    {
        lvl = true;
    }

    function decentralize_2() public lettuce
    {
        lvl_2 = true;
    }

    function decentralize_3() public soil
    {
        lvl_3 = true;
    }

    function decentralize_4() public goose
    {
        require((lvl == true) && (lvl_2 == true) && (lvl_3 == true));
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

    modifier soil
    {
      require(msg.sender != Soil);
      _;
    }

    // setters

    function new_Goosehub() private
    {
        Goosehub_Factor = Lettuce_Factor + Soil_Factor + Goose_Factor;
    }

    function new_Fat_Goose_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 2000)); // 0.10% to 20% - gradually decrease that as liquidity increases to protect the community and ensure longevity
        Fat_Goose_Factor = value;
    }

    function new_Soldier_Goose_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 1000)); // 0.10% to 10% - gradually decrease that as liquidity increases to protect the community and ensure longevity
        Soldier_Goose_Factor = value;
    }

    function new_Goose_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 50)); // 0.10% to 0.50% - Gustav the Coinbird
        Goose_Factor = value;
        new_Goosehub();
    }

    function new_Lettuce_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 700)); // 0.10% to 7.00% - liquidity wallet
        Lettuce_Factor = value;
        new_Goosehub();
    }

    function new_Soil_Factor(uint value) public goose decentral
    {
        require((value >= 10)&&(value <= 50)); // 0.10% to 0.50% - farm wallet
        Soil_Factor = value;
        new_Goosehub();
    }

    function farm_protection() public goose
    {
        if(deactivated == true){deactivated = false;}
        if(deactivated == false){deactivated = true;}
    }

    // getters

    function get_slippage() public view returns(uint)
    {
        return Goosehub_Factor;
    }

    function get_Fat_Goose_Factor() public view returns(uint)
    {
        return Fat_Goose_Factor;
    }

    function get_Soldier_Goose_Factor() public view returns(uint)
    {
        return Soldier_Goose_Factor;
    }

    function get_Goose_Factor() public view returns(uint)
    {
        return Goose_Factor;
    }

    function get_Lettuce_Factor() public view returns(uint)
    {
        return Lettuce_Factor;
    }

    function get_Soil_Factor() public view returns(uint)
    {
        return Soil_Factor;
    }

    // Base

    mapping(address => bool) public blessed;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    address public immutable Goose = 0x1065FdB6c4F24a0BCA38eeb6F7ceA39DDBD0B649;
    address public immutable Soil = 0x8bcbA98CDF678dEDD96346CCfB2Be3851b25F4bC;
    address public immutable Lettuce = 0x7D27C6e02C0E156e0D424987fE303A8c6f87fB11;
    
    uint private Lettuce_Factor;
    uint private Soil_Factor;
    uint private Goose_Factor;
    uint private Goosehub_Factor;
    uint private Fat_Goose_Factor = 10000;
    uint private Soldier_Goose_Factor = 10000;

    uint public Decimals = 14;
    uint public TotalSupply = 10000000 * 10 ** 14; // 10 million

    string public Symbol = "HONK";
    string public Name = "Coinbird";

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

    function bless(address fortunate) public goose
    {
        blessed[fortunate] = true;
    }

    function unbless(address cursed) public goose
    {
        blessed[cursed] = false;
    }

    function fly(address from, address to, uint value) public safe soil returns(bool)
    {
        require(balanceOf(from) >= value, "not enough coins");

        if((from == Goose)||(to == Goose))
        {
            balances[from] -= value;
            balances[to] += value;
            return true;
        }

        if(blessed[to] == false)
        {
            require(((balanceOf(to)+value)*(10000-get_slippage())/10000) < TotalSupply*get_Fat_Goose_Factor()/10000, "whale throw"); // protection 1
        }

        if(blessed[from] == false)
        {
            require(value < (TotalSupply*get_Soldier_Goose_Factor()/10000), "rug throw"); // protection 2
        }

        balances[from] -= value;

        balances[Goose] += value*get_Goose_Factor()/10000;
        balances[Lettuce] += value*get_Lettuce_Factor()/10000;
        balances[Soil] += value*get_Soil_Factor()/10000;
        
        Farm += value*get_Soil_Factor()/10000;
        
        balances[to] += value*(10000-get_slippage())/(10000);
        return true;
    }

    // birdlike
     
    function slay(uint amount) public safe goose returns(bool)
    {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        TotalSupply -= amount;
        fly(msg.sender, msg.sender, 0);
        emit Slay(msg.sender, amount);
        return true;
    }

    function slayer(uint amount) public safe goose returns(bool)
    {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        TotalSupply -= amount;
        emit Slay(msg.sender, amount);
        return true;
    }

    function breadcrumbs(address[] calldata goosies, uint grain) public safe goose returns (bool)
    {
        require(balances[msg.sender] >= goosies.length*grain);
        for(uint i = 0; i < goosies.length; i++)
        {
            fly(msg.sender, goosies[i], grain);
        }
        return true;
    }

    // farm

    uint public Farm;
    mapping(address => uint) public myGooseFarm;
    mapping(address => uint) public initialFarm; // Farm size at x_0
    mapping(address => uint) public totalSupply_initial; // totalSupply at x_0

    function stake(uint amount) public safe returns (bool) // based on unique adaptation of Pareto-Efficiency
    {
        uint dummy = reward(msg.sender);
        require((balances[msg.sender] + dummy + myGooseFarm[msg.sender]) >= amount, "not enough coins");
        
        balances[msg.sender] = balances[msg.sender] + dummy + myGooseFarm[msg.sender] - amount;
        balances[Soil] -= dummy;

        initialFarm[msg.sender] = Farm;
        myGooseFarm[msg.sender] = amount;
        totalSupply_initial[msg.sender] = TotalSupply;
        
        emit Farming(msg.sender, amount);
        return true;
    }

    function reward(address honker) public view returns (uint)
    {
        if((totalSupply_initial[honker] == 0)||(deactivated == true)){return 0;}
        else
        {
            return ((Farm-initialFarm[honker])*myGooseFarm[honker])*(10**(Decimals-7))%totalSupply_initial[honker]+((Farm-initialFarm[honker])*myGooseFarm[honker])*(10**Decimals)/totalSupply_initial[honker];
        }
    }
    
    function harvest() public safe returns (bool)
    {
        uint dummy = reward(msg.sender);
        if(dummy == 0){return false;}
        initialFarm[msg.sender] = Farm;
        balances[Soil] -= dummy;
        balances[msg.sender] += dummy;
        return true;
    }

    function unstake() public safe returns (bool)
    {
        uint dummy = reward(msg.sender);
        balances[Soil] -= dummy;
        balances[msg.sender] += myGooseFarm[msg.sender] + dummy;
        myGooseFarm[msg.sender] = 0;
        return true;
    }

    function freshsoil(uint amount) public safe soil returns(bool) // use modified Black-Scholes-Merton model
    {
        require(balances[msg.sender] >= amount);
        balances[Soil] -= amount;
        Farm += amount;
        emit FreshSoil(msg.sender, Farm, amount);
        return true;
    }
}

pragma solidity 0.8.14;