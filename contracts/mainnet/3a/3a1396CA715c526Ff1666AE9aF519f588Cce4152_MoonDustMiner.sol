// SPDX-License-Identifier: MIT

/*
 ██████   ██████                              ██████████                       █████   
░░██████ ██████                              ░░███░░░░███                     ░░███    
 ░███░█████░███   ██████   ██████  ████████   ░███   ░░███ █████ ████  █████  ███████  
 ░███░░███ ░███  ███░░███ ███░░███░░███░░███  ░███    ░███░░███ ░███  ███░░  ░░░███░   
 ░███ ░░░  ░███ ░███ ░███░███ ░███ ░███ ░███  ░███    ░███ ░███ ░███ ░░█████   ░███    
 ░███      ░███ ░███ ░███░███ ░███ ░███ ░███  ░███    ███  ░███ ░███  ░░░░███  ░███ ███
 █████     █████░░██████ ░░██████  ████ █████ ██████████   ░░████████ ██████   ░░█████ 
░░░░░     ░░░░░  ░░░░░░   ░░░░░░  ░░░░ ░░░░░ ░░░░░░░░░░     ░░░░░░░░ ░░░░░░     ░░░░░  
                                                                                       
                                                                                       
                                                                                       
The DeFi Platform 
For growing your bag
and generating passive income  

4% Daily Interest on ur Initial       
5% Ref 
6% Treasury and Development Fee

A shameless copy 

*/

pragma solidity ^0.4.26; // solhint-disable-line

contract MoonDustMiner {
    uint256 public Moondust_TO_Crumble_1MINERS=2160000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public moonshotFund;

    mapping (address => uint256) public miners;
    mapping (address => uint256) public claimedMoondust;
    mapping (address => uint256) public lastCrumble;
    mapping (address => address) public referrals;
    uint256 public marketMoondust;

    event sellUnobtainium();
    event buyMoonDustRover(address ref);
    event seedMarket();
    event crumbleMoonDust(address ref);

    constructor() public{
        moonshotFund=address(0x9d8a5d6B405c2Eb7cee724F4B2F67a902F0f0864);
    }
    function CrumbleMoondust(address ref) public{
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender){
            referrals[msg.sender]=ref;
        }
        uint256 MoondustUsed=getMyMoondust();
        uint256 newMiners=SafeMath.div(MoondustUsed,Moondust_TO_Crumble_1MINERS);
        miners[msg.sender]=SafeMath.add(miners[msg.sender],newMiners);
        claimedMoondust[msg.sender]=0;
        lastCrumble[msg.sender]=now;
        
        //send referral Moondust
        claimedMoondust[referrals[msg.sender]]=SafeMath.add(claimedMoondust[referrals[msg.sender]],SafeMath.div(MoondustUsed,5));
        
        //boost market to nerf miners hoarding
        marketMoondust=SafeMath.add(marketMoondust,SafeMath.div(MoondustUsed,5));

        emit crumbleMoonDust(ref);
    }
    function SellUnobtainium() public{
        require(initialized);
        uint256 hasMoondust=getMyMoondust();
        uint256 MoondustValue=calculateMoondustSell(hasMoondust);
        uint256 fee=devFee(MoondustValue);
        claimedMoondust[msg.sender]=0;
        lastCrumble[msg.sender]=now;
        marketMoondust=SafeMath.add(marketMoondust,hasMoondust);
        moonshotFund.transfer(fee);
        msg.sender.transfer(SafeMath.sub(MoondustValue,fee));

        emit sellUnobtainium();
    }
    function BuyMoonDustRover(address ref) public payable{
        require(initialized);
        uint256 MoondustBought=calculateMoondustBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        MoondustBought=SafeMath.sub(MoondustBought,devFee(MoondustBought));
        uint256 fee=devFee(msg.value);
        moonshotFund.transfer(fee);
        claimedMoondust[msg.sender]=SafeMath.add(claimedMoondust[msg.sender],MoondustBought);

        emit buyMoonDustRover(ref);

        CrumbleMoondust(ref);
    }
    function SeedMarket() public payable{
        require(marketMoondust==0);
        initialized=true;
        marketMoondust=120000000000;

        emit seedMarket();
    }

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateMoondustSell(uint256 Moondust) public view returns(uint256){
        return calculateTrade(Moondust,marketMoondust,address(this).balance);
    }
    function calculateMoondustBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketMoondust);
    }
    function calculateMoondustBuySimple(uint256 eth) public view returns(uint256){
        return calculateMoondustBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,6),100);
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return miners[msg.sender];
    }
    function getMyMoondust() public view returns(uint256){
        return SafeMath.add(claimedMoondust[msg.sender],getMoondustSinceLastCrumble(msg.sender));
    }
    function getMoondustSinceLastCrumble(address adr) public view returns(uint256){
        uint256 secondsPassed=min(Moondust_TO_Crumble_1MINERS,SafeMath.sub(now,lastCrumble[adr]));
        return SafeMath.mul(secondsPassed,miners[adr]);
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