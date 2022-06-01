/**
 *Submitted for verification at BscScan.com on 2022-06-01
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

contract RDC_MINER {
    //uint256 DOTGOLD_PER_MINERS_PER_SECOND=1;
    address rdc = 0x498FcdE159860B550123c58c1f31b590d422C8DA; 
    uint256 public DOTGOLD_TO_HATCH_1MINERS=128571428;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    address public ceoAddress2;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedDotgold;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketDotgold;
    constructor() public{
        ceoAddress=msg.sender;
        ceoAddress2=address (0x6E2CaA15405DdF125e9E7e4c920c9C5f4217a04a);
    }
    function hatchDotgold(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 dotgoldUsed=getMyDotgold();
        uint256 newMiners=SafeMath.div(dotgoldUsed,DOTGOLD_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedDotgold[msg.sender]=0;
        lastHatch[msg.sender]=now;
        
        //send referral dotgold
        claimedDotgold[referrals[msg.sender]]=SafeMath.add(claimedDotgold[referrals[msg.sender]],SafeMath.div(dotgoldUsed,20));
        
        //boost market to nerf miners hoarding
        marketDotgold=SafeMath.add(marketDotgold,SafeMath.div(dotgoldUsed,5));
    }
    function sellDotgold() public {
        require(initialized);
        uint256 hasDotgold=getMyDotgold();
        uint256 dotgoldValue=culateDotgoldSell(hasDotgold);
        uint256 fee=devFee(dotgoldValue);
        uint256 fee2=fee/2;
        claimedDotgold[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketDotgold=SafeMath.add(marketDotgold,hasDotgold);
        ERC20(rdc).transfer(ceoAddress, fee2);
        ERC20(rdc).transfer(ceoAddress2, fee-fee2);
        ERC20(rdc).transfer(address(msg.sender), SafeMath.sub(dotgoldValue,fee));
    }
    function buyDotgold(address ref, uint256 amount) public {
        require(initialized);
    
        ERC20(rdc).transferFrom(address(msg.sender), address(this), amount);
        
        uint256 balance = ERC20(rdc).balanceOf(address(this));
        uint256 dotgoldBought=calculateDotgoldBuy(amount,SafeMath.sub(balance,amount));
        dotgoldBought=SafeMath.sub(dotgoldBought,devFee(dotgoldBought));
        uint256 fee=devFee(amount);
        uint256 fee2=fee/2;
        ERC20(rdc).transfer(ceoAddress, fee2);
        ERC20(rdc).transfer(ceoAddress2, fee-fee2);
        claimedDotgold[msg.sender]=SafeMath.add(claimedDotgold[msg.sender],dotgoldBought);
        hatchDotgold(ref);
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function culateDotgoldSell(uint256 dotgold) public view returns(uint256) {
        return calculateTrade(dotgold,marketDotgold,ERC20(rdc).balanceOf(address(this)));
    }
    function calculateDotgoldBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketDotgold);
    }
    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateDotgoldBuy(eth,ERC20(rdc).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,10),100);
    }
    function seedMarket(uint256 amount) public {
        ERC20(rdc).transferFrom(address(msg.sender), address(this), amount);
        require(marketDotgold==0);
        initialized=true;
        marketDotgold=70000;
    }
    function getBalance() public view returns(uint256) {
        return ERC20(rdc).balanceOf(address(this));
    }
    function getMyMiners() public view returns(uint256) {
        return hatcheryMiners[msg.sender];
    }
    function getMyDotgold() public view returns(uint256) {
        return SafeMath.add(claimedDotgold[msg.sender],getDotgoldSinceLastHatch(msg.sender));
    }
    function getDotgoldSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(DOTGOLD_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
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
  * @dev minusing of two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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