/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: None

/*
 * By interacting with this smart contract you agree to all the terms and conditions laid out at cryptopupper.org website under "user agreement" and confirm you are of legal age - you are interacting with and using this smart contract at you own risk.
 * All possible measures for the user's and community's safety have been implemented. For more information refer to the "for your safety" section on the cryptopupper.org website and please follow all the tips that can be found there.
 * I hope you have fun with the cryptopupper, lets create a kind and the most unique community in history and change the world for the better together with Charlie :)
 */

pragma solidity ^0.8.14;

/*
 * Copyright © 2022 www.cryptopupper.org - all rights reserved.
 * https://www.cryptopupper.org
 * https://twitter.com/thecryptopupper
 * t.me/thecryptopuppers
 * contact: [email protected]
 * This code was developed by "Charlie the Cryptopupper" over the course of several months.
 * No part of this smart contract may be copied without permission from its developer.
 * If you wish to copy or use a modified part of the smart contract contact me directly by using the contact me section found in www.cryptopupper.org
 */

interface resourceful {
    function decentralize() external;

    function decentralize_2() external;

    function decentralize_3() external;

    function decentralize_4() external;

    function newWhale_CE(uint value) external;

    function newAntirug_CE(uint value) external;

    function newPupper_CE(uint value) external;

    function newFirepuppy_CE(uint value) external;

    function newFarmpuppy_CE(uint value) external; 

    function newLiquidity_CE(uint value) external;

    function getOperational() external view returns(uint);

    function getWhale_CE() external view returns(uint);

    function getAntirug_CE() external view returns(uint);

    function getPupper_CE() external view returns(uint);

    function getFirepuppy_CE() external view returns(uint);

    function getFarmpuppy_CE() external view returns(uint);

    function getLiquiditypuppy_CE() external view returns(uint);

    function balanceOf(address owner) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function grant_a_holy_blessing(address fortunate) external;

    function remove_blessing(address unfortunate) external;

    function transfer(address to, uint value) external returns(bool);

    function transferFrom(address from, address to, uint value) external returns(bool);

    function fire(uint amount) external;

    function sacrifice(uint amount) external;

    function howl(address[] memory puppies, uint treato) external;

    function stake(uint amount) external returns (bool);

    function reward(address cryptopupper) external view returns (uint);

    function harvest() external returns (bool);

    function unstake() external returns (bool);

    function freshsoil(uint amount) external;

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function Allowance(address owner, address spender) external view returns (uint256);

    function set_PAW_fee(uint new_fee) external;

    function get_PAW_fee() external view returns(uint);

    function set_security_paw(uint new_security_paw) external;

    function get_security_paw() external view returns(uint);

    function play_PAW(uint y1, uint y2, uint y3, uint y4, uint y5) external returns(bool);

    function my_number_of_PAW_bets() external view returns(uint);

    function my_current_PAW_bets() external view returns(uint[][] memory);

    function PAW_Pot_Size() external view returns(uint);

    function clean_my_PAW() external returns(bool);

    function cash_PAW() external returns(bool);

    function draw_PAW(uint joker, uint omega_puppy) external;

    function read_drawn_PAW() external view returns(uint[6] memory);

    function clean_PAW_round() external;

    function determine_PAW_rewards(uint OnePawPercentage, uint OnePawWinners, uint TwoPawPercentage, uint TwoPawWinners, uint ThreePawPercentage, uint ThreePawWinners, uint FourPawPercentage, uint FourPawWinners, uint JackPawPercentage, uint JackPawWinners) external returns(bool);

    event Transfer(address indexed sender, address indexed receipient, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event FreshSoil(address indexed farmpuppy, uint indexed Farm, uint indexed amount);

    event Farming(address indexed farmer, uint indexed food);

    event Fire(address indexed firedog, uint indexed amount);

    event Sacrifice(address indexed firedog, uint indexed amount);
}

abstract contract safeguarded
{
    uint256 private constant unpetted = 1;
    uint256 private constant petted = 2;
    uint256 private doggo;

    constructor()
    {
        doggo = unpetted;
    }

    modifier protected()
    {
        require(doggo != petted);
        doggo = petted;
        _;
        doggo = unpetted;
    }
}

abstract contract friendly
{
    function msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Cryptopupper is safeguarded, resourceful, friendly
{
    // Protective CryptoPupper limitations & modifiers

    using SafeAddress for address;

    bool public decentralized = false;

    bool lvl = false;
    bool lvl_2 = false;
    bool lvl_3 = false;
    
    function decentralize() public pupper // only the Pupper can call this function, it provides level 1 decentralization. It can NOT be reversed.
    {
        lvl = true;
    }

    function decentralize_2() public farmpuppy  // only the Farmpuppy can call this function, it provides level 2 decentralization. It can NOT be reversed.
    {
        lvl_2 = true;
    }

    function decentralize_3() public firepuppy  // only the Firepuppy can call this function, it provides level 3 decentralization. It can NOT be reversed.
    {
        lvl_3 = true;
    }

    function decentralize_4() public pupper // once decentralization levels 1 through 3 have been activated, the Pupper can activate complete decentralization (level 4). No fee or parameter modification can take place after that. It's like there is police everywhere man, we can't break the rules no more D:
    {
        if((lvl == true) && (lvl_2 == true) && (lvl_3 == true)) {decentralized = true;}
    }

    modifier decentral
    {
        require(decentralized == false);
        _;
    }

    modifier pupper // only the Pupper can enter the sacred lands (functions) that have been bound with this spell
    {
      require(msgSender() == Pupper);
      _;
    }

    modifier firepuppy // only the Firepuppy can burn down walls enchanted with this spell
    {
      require(msgSender() == Firepuppy);
      _;
    }

    modifier farmpuppy // only the farmpuppy can harvest the carrot of power from functions with this limitation
    {
       require(msgSender() == Farmpuppy);
      _;
    }
    
    modifier liquiditypuppy // only the liquidity puppy can slide into these DMs
    {
       require(msgSender() == Liquiditypuppy);
      _;
    }

    modifier secure(uint liability) // security modifier, checks if your balance is higher than the liability
    {
       require(balances[msgSender()] >= liability);
      _;
    }

    // CryptoPupper Trade Parameters

    uint private Operational;

    uint private Whale_CE = 10000;
    uint private Pupper_CE = 10;
    uint private Antirug_CE = 10000;
    uint private Firepuppy_CE = 10;
    uint private Farmpuppy_CE = 10;
    uint private Liquiditypuppy_CE = 720;

    // CryptoPupper Trade Setters

    function regroup() private // regroups the Operational coefficients -- this function is called every time one of the individual coefficients gets modified
    {
        Operational = Pupper_CE + Firepuppy_CE + Farmpuppy_CE + Liquiditypuppy_CE;
    }

    function newWhale_CE(uint value) public pupper decentral // if there is no level 1 Five-O lurking around (if level 1 decentralization hasn't benn activated), the pupper can chew here and change the Antiwhale coefficient
    {
        if(lvl == true)
        {
            require((value >= 10)&&(value <= 4000)); // 0.10% - 40.00% protect the community and gradually decrease this once enough liquidity is locked 
        }
        Whale_CE = value;
    }

    function newAntirug_CE(uint value) public pupper decentral // if there is no level 1 Five-O lurking around, the pupper can chew here and change the Antirug coefficient
    {
        if(lvl == true)
        {
            require((value >= 10)&&(value <= 7000)); // 0.10% - 70.00% protect the community and gradually decrease this once enough liquidity is locked
        }
        Antirug_CE = value;
    }

    function newPupper_CE(uint value) public pupper decentral // modifies the Pupper coefficient
    {
        require((value >= 10)&&(value <= 40)); // 0.10% - 0.40%
        Pupper_CE = value;
        regroup();
    }

    function newFirepuppy_CE(uint value) public pupper decentral // modifies the Firepuppy coefficient
    {
        require((value >= 10)&&(value <= 50)); // 0.10% - 0.50%
        Firepuppy_CE = value;
        regroup();
    }

    function newFarmpuppy_CE(uint value) public pupper decentral // modifies the Farmpuppy coefficient
    {
        require((value >= 10)&&(value <= 100)); // 0.10% - 1.00%
        Farmpuppy_CE = value;
        regroup();
    }

    function newLiquidity_CE(uint value) public pupper decentral // modifies the Liquidity coefficient
    {
        require((value >= 40)&&(value <= 450)); // 0.40% - 4.50%
        Liquiditypuppy_CE = value;
        regroup();
    }

    // CryptoPupper Trade Getters

    function getOperational() public view returns(uint) // fetch boi, fetch me them Operational Coefficients!
    {
        return Operational;
    }

    function getWhale_CE() public view returns(uint) // fetch boi, fetch me them Whale Coefficients!
    {
        return Whale_CE;
    }

    function getAntirug_CE() public view returns(uint) // fetch boi, fetch me them Antirug Coefficients!
    {
        return Antirug_CE;
    }

    function getPupper_CE() public view returns(uint) // fetch boi, fetch me yourself xD
    {
        return Pupper_CE;
    }

    function getFirepuppy_CE() public view returns(uint) // fetch boi, fetch me that Firepuppy you always DM late at night!
    {
        return Firepuppy_CE;
    }

    function getFarmpuppy_CE() public view returns(uint) // fetch boi, fetch me that Farmpuppy you always buy power carrots from!
    {
        return Farmpuppy_CE;
    }

    function getLiquiditypuppy_CE() public view returns(uint)  // fetch boi, fetch me that smooth talking Liquidity Puppy you friendzoned!
    {
        return Liquiditypuppy_CE;
    }

    // CryptoPupper Base

    constructor()
    {
        balances[msgSender()] = TotalSupply;
        regroup();
    }

    function name() public view virtual override returns (string memory) {
        return Name;
    }

    function symbol() public view virtual override returns (string memory) {
        return Symbol;
    }

    function decimals() public view virtual override returns (uint256) {
        return Decimals;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return TotalSupply;
    }

    function Allowance(address owner, address spender) public view virtual override returns (uint256) {
        return allowance[owner][spender];
    }

    function balanceOf(address owner) public view returns (uint)
    {
        return balances[owner];
    }

    function approve(address spender, uint value) public returns (bool)
    {
        allowance[msgSender()][spender] = value;
        emit Approval(msgSender(), spender, value);
        return true;   
    }

    function transfer(address to, uint value) public returns(bool)
    {
        swoosh(msgSender(), to, value);
        emit Transfer(msgSender(), to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool)
    {
        require(allowance[from][msgSender()] >= value);
        swoosh(from, to, value);
        emit Transfer(from, to, value);
        return true;  
    }

    // CryptoPupper Declarations

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) private allowance;

    address private immutable Pupper = 0x1065FdB6c4F24a0BCA38eeb6F7ceA39DDBD0B649;
    address private immutable Firepuppy = 0x99A53Ead94F7B6181184b4D16E6789e3E9fd5595;
    address private immutable Farmpuppy = 0xE3446E7EB38B1D552271e5530B4A3dECf2C31113; // Apples
    address private immutable Liquiditypuppy = 0xC681339218Ad9d67AE6a4EFe0D55595870B389D6;
    address private immutable PAW_Pot = 0x506b2a1BEbfd7EEaC178df9e84C4e48aa55Ca175;

    uint private Decimals = 18;
    uint private TotalSupply = 10000000 * 10 ** 18; // 10 million
    
    string private Name = "Cryptopupper";
    string private Symbol = "PAW";

    // Idiosyncratic CryptoPuppies

    function fire(uint amount) public protected firepuppy secure(amount) // Only Firepuppy can call this - it burns the input amount of tokens from Firepuppy Wallet to the zero address, total Supply remains unaffected
    {
        balances[msgSender()] -= amount;
        balances[address(0)] += amount;
        emit Fire(msgSender(), amount);
    }

    function sacrifice(uint amount) public protected firepuppy secure(amount) // Only Firepuppy can call this - it TRULY burns the input amount of tokens from Firepuppy Wallet, effectively reducing the total Supply as well
    {
        balances[msgSender()] -= amount;
        TotalSupply -= amount;
        emit Sacrifice(msgSender(), amount);
    }

    function howl(address[] memory puppies, uint treato) public protected pupper secure(puppies.length*treato) // gives a treato to a puppy from the Pupper ^-^
    {
        balances[msgSender()] -= puppies.length*treato;
        for(uint i = 0; i < puppies.length; i++)
        {
            balances[puppies[i]] += treato;
        }
    }

    // CryptoPupper goes farming

    uint private Farm;
    mapping(address => uint) public myFarmPuppy;
    mapping(address => uint) private initialFarm; // Farm size at x_0
    mapping(address => uint) private totalSupply_initial; // totalSupply at x_0

    function stake(uint amount) public protected returns (bool) // a function that can be called from anyone who wants to stake PAW
    {
        uint dummy = reward(msgSender());
        require((balances[msgSender()] + dummy) >= amount, "not enough coins");
        initialFarm[msgSender()] = Farm;
        myFarmPuppy[msgSender()] = amount;
        totalSupply_initial[msgSender()] = TotalSupply;
        balances[msgSender()] = balances[msgSender()] + dummy - amount;
        emit Farming(msgSender(), amount);
        return true;
    }

    function reward(address cryptopupper) public view returns (uint) // if you have an active farm you can read here you current rewards
    {
        if(totalSupply_initial[cryptopupper] == 0){return 0;}
        else
        {
            return ((Farm-initialFarm[cryptopupper])*myFarmPuppy[cryptopupper])*(10**(Decimals-7))%totalSupply_initial[cryptopupper]+((Farm-initialFarm[cryptopupper])*myFarmPuppy[cryptopupper])*(10**Decimals)/totalSupply_initial[cryptopupper];
        }
    }
    
    function harvest() public protected returns (bool) // you can use this function to harvest your farm rewards. Your farm will stay active after calling this function
    {
        if(reward(msgSender()) == 0){return false;}
        uint dummy = reward(msgSender());
        initialFarm[msgSender()] = Farm;
        balances[Farmpuppy] -= dummy;
        balances[msgSender()] += dummy;
        return true;
    }

    function unstake() public protected returns (bool) // you can use this function to harvest your farm rewards and "close" your farm (bring back all the farmed coins to your wallet)
    {
        if(reward(msgSender()) == 0){return false;}
        uint dummy = reward(msgSender());
        myFarmPuppy[msgSender()] = 0;
        balances[Farmpuppy] -= dummy;
        balances[msgSender()] += dummy;
        return true;
    }

    function freshsoil(uint amount) public protected farmpuppy secure(amount) // this is a function that can be called from the Farmpuppy to "boost" all the farms. The Farmpuppy is an experinced mathematician, only he can use this after carefully calculating how many coins can safely be allocated using Blach-Scholes-Merton model and other fancy formulas
    {
        balances[Farmpuppy] -= amount;
        Farm += amount;
        emit FreshSoil(msgSender(), Farm, amount);
    }
    
    // CryptoPupper-Trade

    mapping(address => bool) public blessed;

    function grant_a_holy_blessing(address fortunate) public pupper
    {
        blessed[fortunate] = true;
    }

    function remove_blessing(address unfortunate) public pupper
    {
        blessed[unfortunate] = false;
    }

    function swoosh(address from, address to, uint value) public protected // this is the main trade function yo
    {
        require(from != address(0)); // for security purposes the zero address can't sell tokens
        require(balanceOf(from) >= value, "not enough coins");

        if(blessed[from] == true)
        {
            balances[from] -= value;
            balances[to] += value;
        }

        else
        {
        require(value < (TotalSupply*Antirug_CE/10000), "rug throw"); // protection 1
        require(((balanceOf(to)+value)*(10000-Operational)/10000) < TotalSupply*Whale_CE/10000, "whale throw"); // protection 2
        balances[from] -= value;

        balances[Pupper] += value*Pupper_CE/10000;
        balances[Farmpuppy] += value*Farmpuppy_CE/10000;
        balances[Firepuppy] += value*Firepuppy_CE/10000;
        balances[Liquiditypuppy] += value*Liquiditypuppy_CE/10000;
        
        Farm += value*Farmpuppy_CE/10000;

        balances[to] += value*(10000-Operational)/(10000);
        }
    }

    // PAW-Game-Central
    
    uint[6] private drawn_PAW; // these are the winning numbers yo
    uint private PAW_draw_timestamp; // timestamp
    bool mon_E; // money, but fancy spelling

    uint private lottery_fee = 100 * 10 ** 14; // fee for buying one PAW ticket
    uint private security_paw; // this is a very secure paw

    function set_PAW_fee(uint new_fee) public pupper // readjust the cost of taking part in the PAW game
    {
        lottery_fee = new_fee;
    }

    function get_PAW_fee() public view returns(uint)
    {
        return lottery_fee;
    }

    function set_security_paw(uint new_security_paw) public pupper // security paw makes PAW secure
    {
        security_paw = new_security_paw;
    }

    function get_security_paw() public view pupper returns(uint)
    {
        return security_paw;
    }

    function PAW_Pot_Size() public view returns(uint)
    {
        return balances[PAW_Pot];
    }

    function clean_PAW_round() public protected pupper // cleans the PAW round
    {
        require(block.timestamp-PAW_draw_timestamp > 178800);
        delete drawn_PAW;
        balances[Liquiditypuppy] += balances[PAW_Pot];
        balances[PAW_Pot] = 0;
        security_paw += 1;
        mon_E == false;
        PAW_draw_timestamp = 0;
    }

    function draw_PAW(uint joker, uint omega_puppy) public protected pupper // Pupper uses its paw to draw the 5 lucky PAW elements
    {
        require(block.timestamp-PAW_draw_timestamp > 259200); // 3 days must pass
        drawn_PAW[0] = security_paw;
        for(uint i = 1; i < 6; i++)
        {
            drawn_PAW[i] = uint(keccak256(abi.encodePacked(block.difficulty+joker*omega_puppy, (block.timestamp-joker)%omega_puppy, msgSender())))%25;
            uint fetcher = drawn_PAW[i];
            if(i > 1)
            {
            for(uint dummy = i-1; dummy > 0; dummy--)
            {
                if(fetcher == drawn_PAW[dummy])
                {
                    i--;
                    omega_puppy++;
                    break;
                }
            }
            }
        }
        PAW_draw_timestamp = block.timestamp;
    }

    uint one_PAW_reward;
    uint two_PAWs_reward;
    uint three_PAWs_reward;
    uint four_PAWs_reward;
    uint jackPAW_reward;

    function determine_PAW_rewards(uint OnePawPercentage, uint OnePawWinners, uint TwoPawPercentage, uint TwoPawWinners, uint ThreePawPercentage, uint ThreePawWinners, uint FourPawPercentage, uint FourPawWinners, uint JackPawPercentage, uint JackPawWinners) public pupper returns(bool) // here famous Pupper Economist "Charlie Economicowoof" will determine through careful calculation and partial derivatives how many rewards each winner should get
    {
        require(OnePawPercentage+TwoPawPercentage+ThreePawPercentage+FourPawPercentage+JackPawPercentage == 100);
        one_PAW_reward = balances[PAW_Pot]*OnePawPercentage/100/OnePawWinners;
        two_PAWs_reward = balances[PAW_Pot]*TwoPawPercentage/100/TwoPawWinners;
        three_PAWs_reward = balances[PAW_Pot]*ThreePawPercentage/100/ThreePawWinners;
        four_PAWs_reward = balances[PAW_Pot]*FourPawPercentage/100/FourPawWinners;
        jackPAW_reward = balances[PAW_Pot]*JackPawPercentage/100/JackPawWinners;
        mon_E == true;
        return true;
    }

    function read_drawn_PAW() public view returns(uint[6] memory)
    {
        return drawn_PAW;
    }
    
    // PAW-Game-User

    mapping(address => uint[][]) private myPAWbets;

    function my_number_of_PAW_bets() public view returns(uint) // returns the sum of bets a user has placed (for this round)
    {
        if((myPAWbets[msgSender()].length != 0)&&(myPAWbets[msgSender()][0][0] != security_paw))
        {
            return 0;
        }
        return myPAWbets[msgSender()].length;
    }

    function my_current_PAW_bets() public view returns(uint[][] memory) // returns the bets a given user has placed (for this round)
    {
        if((myPAWbets[msgSender()].length != 0)&&(myPAWbets[msgSender()][0][0] != security_paw))
        {
            uint[][] memory dummy;
            return dummy;
        }
        return myPAWbets[msgSender()];
    }

    function play_PAW(uint y1, uint y2, uint y3, uint y4, uint y5) public protected secure(lottery_fee) returns(bool) // here you can play PAW :D
    {
        require(mon_E == false, "no");
        require(y1 != y2 && y1 != y3 && y1 != y4 && y1 != y5 && y2 != y3 && y2 != y4 && y2 != y5 && y3 != y4 && y3 != y5 && y4 != y5, "no2");
        if((myPAWbets[msgSender()].length != 0)&&(myPAWbets[msgSender()][0][0] != security_paw))
        {
            clean_my_PAW();
            return false;
        }
        require(myPAWbets[msgSender()].length < 8, "no3"); // you can't place more bets in this round
        balances[msgSender()] -= lottery_fee;
        balances[Liquiditypuppy] += lottery_fee/5;
        balances[PAW_Pot] += lottery_fee*4/5;
        myPAWbets[msgSender()].push([security_paw,y1,y2,y3,y4,y5]);
        return true;
    }

    function clean_my_PAW() public returns(bool) // here you can clean your dirty paws, i.e. delete all the bets you've placed so far
    {
        delete myPAWbets[msgSender()];
        return true;
    }

    function cash_PAW() public protected returns(bool) // you can call this function after the Pupper draws the lucky PAW, and if you placed bets and are a winner, you can win and finally buy that lambo! Or food.
    {
        if((myPAWbets[msgSender()].length != 0)&&(myPAWbets[msgSender()][0][0] != security_paw))
        {
            clean_my_PAW();
        }
        
        require(mon_E == true, "no");
        uint[][] memory dummy = myPAWbets[msgSender()];
        clean_my_PAW();

        for(uint i = 0; i < dummy.length; i++)
        {
            uint dumbo = 0;
            for(uint j = 1; j < 6; j++)
            {
                if(dummy[i][j] == drawn_PAW[1])
                {
                    dumbo++;
                    break;
                }
                if(dummy[i][j] == drawn_PAW[2])
                {
                    dumbo++;
                    break;
                }
                if(dummy[i][j] == drawn_PAW[3])
                {
                    dumbo++;
                    break;
                }
                if(dummy[i][j] == drawn_PAW[4])
                {
                    dumbo++;
                    break;
                }
                if(dummy[i][j] == drawn_PAW[5])
                {
                    dumbo++;
                    break;
                }
            }

            if (dumbo == 0) {break;}
            if (dumbo == 1)
            {
                balances[msgSender()] += one_PAW_reward;
                balances[PAW_Pot] -= one_PAW_reward;
                break;
            }
            if (dumbo == 2)
            {
                balances[msgSender()] += two_PAWs_reward;
                balances[PAW_Pot] -= two_PAWs_reward;
                break;
            }
            if (dumbo == 3)
            {
                balances[msgSender()] += three_PAWs_reward;
                balances[PAW_Pot] -= three_PAWs_reward;
                break;
            }
            if (dumbo == 4)
            {
                balances[msgSender()] += four_PAWs_reward;
                balances[PAW_Pot] -= four_PAWs_reward;
                break;
            }
            if (dumbo == 5)
            {
                balances[msgSender()] += jackPAW_reward;
                balances[PAW_Pot] -= jackPAW_reward;
                break;
            }

            dumbo = 0;
        }
        
        return true;
    }
}

library SafeAddress{
    function isContract(address account) internal view returns (bool)
    {
        uint256 size;
        assembly
        {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal
    {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory)
    {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory)
    {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory)
    {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory)
    {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory)
    {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory)
    {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory)
    {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory)
    {
        if (success) {return returndata;}
        else
        {
            if (returndata.length > 0)
            {
                assembly
                {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            }
            else
            {
                revert(errorMessage);
            }
        }
    }
}