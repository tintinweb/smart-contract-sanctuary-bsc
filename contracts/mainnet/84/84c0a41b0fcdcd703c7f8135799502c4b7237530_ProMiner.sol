/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

/**
 *Website: https://prometaverseminer.com/
*/

// SPDX-License-Identifier: MIT 

pragma solidity ^0.4.26; // solhint-disable-line

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

contract ProMiner {
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    address usdt = 0x55d398326f99059fF775485246999027B3197955; 
    uint256 public USDT_TO_MINE_1MINERS=2592000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    address public ceoAddress2;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedUSDT;
    mapping (address => uint256) public lastMined;
    mapping (address => address) public referrals;
    mapping (address => uint256) public userInvested;
    mapping (address => uint256) public latestInvestmentTime;
    mapping (address => uint256) public extractedReward;


    uint256 public marketUSDT;
    constructor() public{
        ceoAddress=msg.sender;
        ceoAddress2=address(0xD33804d9E3e16bB2ee837584DdEA70d65a907d47);
    }
    function mineUSDT(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 minersUsed=getMiners();
        uint256 newMiners=SafeMath.div(minersUsed,USDT_TO_MINE_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedUSDT[msg.sender]=0;
        lastMined[msg.sender]=now;
        
        //send referral eggs
        claimedUSDT[referrals[msg.sender]]=SafeMath.add(claimedUSDT[referrals[msg.sender]],SafeMath.div(minersUsed,7));
        
        //boost market to nerf miners hoarding
        marketUSDT=SafeMath.add(marketUSDT,SafeMath.div(minersUsed,5));
    }
    function sellMiners() public {
        require(initialized);
        uint256 hasMiners=getMiners();
        require(hasMiners >0,"You dont have any eggs");
        uint256 minerValue=calculateMinerSell(hasMiners);
        require(minerValue >0, "Egg has no value");
        require((extractedReward[msg.sender] + minerValue) <= (SafeMath.div(userInvested[msg.sender],2) + userInvested[msg.sender]),"You cant extract more then 50% of profit");
        uint256 fee=devFee(minerValue);
        uint256 fee2=fee/2;
        claimedUSDT[msg.sender]=0;
        lastMined[msg.sender]=now;
        extractedReward[msg.sender]  =SafeMath.add(extractedReward[msg.sender],minerValue);
        latestInvestmentTime[msg.sender] = block.timestamp;
        marketUSDT=SafeMath.add(marketUSDT,hasMiners);
        ERC20(usdt).transfer(ceoAddress, fee2);
        ERC20(usdt).transfer(ceoAddress2, fee-fee2);
        ERC20(usdt).transfer(address(msg.sender), SafeMath.sub(minerValue,fee));
    }
    function buyMiners(address ref, uint256 amount) public {
        require(initialized);
        userInvested[msg.sender] = SafeMath.add(userInvested[msg.sender],amount);
        latestInvestmentTime[msg.sender] = block.timestamp;
        ERC20(usdt).transferFrom(address(msg.sender), address(this), amount);
        uint256 balance = ERC20(usdt).balanceOf(address(this));
        uint256 minersBought=calculateMinerBuy(amount,SafeMath.sub(balance,amount));
        minersBought=SafeMath.sub(minersBought,devFee(minersBought));
        uint256 fee=devFee(amount);
        uint256 fee2=fee/2;
        ERC20(usdt).transfer(ceoAddress, fee2);
        ERC20(usdt).transfer(ceoAddress2, fee-fee2);
        claimedUSDT[msg.sender]=SafeMath.add(claimedUSDT[msg.sender],minersBought);
        mineUSDT(ref);
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateMinerSell(uint256 miners) public view returns(uint256) {
        return calculateTrade(miners,marketUSDT,ERC20(usdt).balanceOf(address(this)));
    }
    function calculateMinerBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketUSDT);
    }
    function calculateMinerBuySimple(uint256 eth) public view returns(uint256){
        return calculateMinerBuy(eth,ERC20(usdt).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,6),100);
    }
    function seedMarket(uint256 amount) public {
        ERC20(usdt).transferFrom(address(msg.sender), address(this), amount);
        require(marketUSDT==0);
        initialized=true;
        marketUSDT=259200000000;
    }
    function getBalance() public view returns(uint256) {
        return ERC20(usdt).balanceOf(address(this));
    }
    function getMyMiners() public view returns(uint256) {
        return hatcheryMiners[msg.sender];
    }
    function getMiners() public view returns(uint256) {
        return SafeMath.add(claimedUSDT[msg.sender],getMinersSincelastMined(msg.sender));
    }
    function getMinersSincelastMined(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(USDT_TO_MINE_1MINERS,SafeMath.sub(now,lastMined[adr]));
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