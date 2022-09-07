/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

// SPDX-License-Identifier: MIT


// Powered by:
// ██████╗░░█████╗░██████╗░░█████╗░░█████╗░██████╗░███╗░░██╗  ░█████╗░██╗░░░░░░█████╗░██╗███╗░░░███╗░██████╗
// ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗████╗░██║  ██╔══██╗██║░░░░░██╔══██╗██║████╗░████║██╔════╝
// ██████╔╝██║░░██║██████╔╝██║░░╚═╝██║░░██║██████╔╝██╔██╗██║  ██║░░╚═╝██║░░░░░███████║██║██╔████╔██║╚█████╗░
// ██╔═══╝░██║░░██║██╔═══╝░██║░░██╗██║░░██║██╔══██╗██║╚████║  ██║░░██╗██║░░░░░██╔══██║██║██║╚██╔╝██║░╚═══██╗
// ██║░░░░░╚█████╔╝██║░░░░░╚█████╔╝╚█████╔╝██║░░██║██║░╚███║  ╚█████╔╝███████╗██║░░██║██║██║░╚═╝░██║██████╔╝
// ╚═╝░░░░░░╚════╝░╚═╝░░░░░░╚════╝░░╚════╝░╚═╝░░╚═╝╚═╝░░╚══╝  ░╚════╝░╚══════╝╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝╚═════╝░
// https://powerminer.cloud


pragma solidity ^0.4.26; 

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract POWERMINER {
    address busd = 0x7d372ff6FCd28dD3b15367F8f449F01B59CcA23a; 
    uint256 public EGGS_TO_HATCH_1MINERS=576000; //for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public popcornDev;
    address public powerAdmin;
    address public popcornAddress;
    address public redbullAddress;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketEggs;
    constructor() public{
        popcornDev=msg.sender;
        powerAdmin=address(0xcFb9d9230c77558e7739703A482dBeeD977B41Df);
        popcornAddress=address(0x2946d0DBC8D7eD53938706549F003Df243235BeA);
        redbullAddress=address(0xa58f93A80a77B27D2c15bd11e9cD37F85B30921d);
    }
    function hatchEggs(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 eggsUsed=getMyEggs();
        uint256 newMiners=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;
        
        //send referral eggs
        claimedEggs[referrals[msg.sender]]=SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(eggsUsed,11));
        
        //boost market to nerf miners hoarding
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
    }
    function sellEggs() public {
        require(initialized);
        uint256 hasEggs=getMyEggs();
        uint256 eggValue=calculateEggSell(hasEggs);
        uint256 fee=devFee(eggValue);
        uint256 fee2=fee/7;   
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketEggs=SafeMath.add(marketEggs,hasEggs);
        ERC20(busd).transfer(popcornDev, fee2*2);
        ERC20(busd).transfer(powerAdmin, fee2*2);
        ERC20(busd).transfer(popcornAddress, fee2*2);
        ERC20(busd).transfer(redbullAddress, fee2);
        ERC20(busd).transfer(address(msg.sender), SafeMath.sub(eggValue,fee));
    }

    function buyEggs(address ref, uint256 amount) public {
        require(initialized);
        require(amount >= 10000000000000000000);   
        require(amount <= 10000000000000000000000);     
        ERC20(busd).transferFrom(address(msg.sender), address(this), amount);
        
        // uint256 balance = ERC20(busd).balanceOf(address(this));
        uint256 balance= 4855660000000000000000;
        uint256 eggsBought=calculateEggBuy(amount, balance);
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
        uint256 fee=devFee(amount);
        uint256 fee2=fee/7;      
        ERC20(busd).transfer(popcornDev, fee2*2);
        ERC20(busd).transfer(powerAdmin, fee2*2);
        ERC20(busd).transfer(popcornAddress, fee2*2);
        ERC20(busd).transfer(redbullAddress, fee2);
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
        hatchEggs(ref);
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateEggSell(uint256 eggs) public view returns(uint256) {
        return calculateTrade(eggs,marketEggs,ERC20(busd).balanceOf(address(this)));
    }
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketEggs);
    }
    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth,ERC20(busd).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,7),100);
    }
    function seedMarket(uint256 amount) public {
        ERC20(busd).transferFrom(address(msg.sender), address(this), amount);
        require(marketEggs==0 && msg.sender == powerAdmin);
        initialized=true;
        // marketEggs=57600000000;
        marketEggs=4266475855428;
    }
    function getBalance() public view returns(uint256) {
        return ERC20(busd).balanceOf(address(this));
    }
    function getMyMiners() public view returns(uint256) {
        return hatcheryMiners[msg.sender];
    }
    function getMyEggs() public view returns(uint256) {
        return SafeMath.add(claimedEggs[msg.sender],getEggsSinceLastHatch(msg.sender));
    }
    function getEggsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}