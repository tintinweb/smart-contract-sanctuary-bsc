/**
 *Submitted for verification at BscScan.com on 2022-12-17
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

contract ROCKET_MINER_V1 {

    address Rocket = 0xb5c9b8f6e1a49F311005cD4A0ecc4631A5A86641; 
    uint256 public FUELS_TO_START_1ROCKET_LAUNCH=8640000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    address public ceoAddress2;
    mapping (address => uint256) public STARTeryROCKET_LAUNCH;
    mapping (address => uint256) public claimedFUELs;
    mapping (address => uint256) public lastSTART;
    mapping (address => address) public referrals;
    uint256 public marketFUELs;
    constructor() public{
        ceoAddress=msg.sender;
        ceoAddress2=address(0xe52AE16982854806Fde17AE7104b6F7Ceaf1e4D7);
    }
    function STARTFUELs(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 FUELsUsed=getMyFUELs();
        uint256 newROCKET_LAUNCH=SafeMath.div(FUELsUsed,FUELS_TO_START_1ROCKET_LAUNCH);
        STARTeryROCKET_LAUNCH[msg.sender]=SafeMath.add(STARTeryROCKET_LAUNCH[msg.sender],newROCKET_LAUNCH);
        claimedFUELs[msg.sender]=0;
        lastSTART[msg.sender]=now;
        
        //send referral FUELs
        claimedFUELs[referrals[msg.sender]]=SafeMath.add(claimedFUELs[referrals[msg.sender]],SafeMath.div(FUELsUsed,7));
        
        //boost market to nerf ROCKET_LAUNCH hoarding
        marketFUELs=SafeMath.add(marketFUELs,SafeMath.div(FUELsUsed,5));
    }
    function sellFUELs() public {
        require(initialized);
        uint256 hasFUELs=getMyFUELs();
        uint256 FUELValue=calculateFUELSell(hasFUELs);
        uint256 fee=devFee(FUELValue);
        uint256 fee2=fee/2;
        claimedFUELs[msg.sender]=0;
        lastSTART[msg.sender]=now;
        marketFUELs=SafeMath.add(marketFUELs,hasFUELs);
        ERC20(Rocket).transfer(ceoAddress, fee2);
        ERC20(Rocket).transfer(ceoAddress2, fee-fee2);
        ERC20(Rocket).transfer(address(msg.sender), SafeMath.sub(FUELValue,fee));
    }
    function buyFUELs(address ref, uint256 amount) public {
        require(initialized);
    
        ERC20(Rocket).transferFrom(address(msg.sender), address(this), amount);
        
        uint256 balance = ERC20(Rocket).balanceOf(address(this));
        uint256 FUELsBought=calculateFUELBuy(amount,SafeMath.sub(balance,amount));
        FUELsBought=SafeMath.sub(FUELsBought,devFee(FUELsBought));
        uint256 fee=devFee(amount);
        uint256 fee2=fee/2;
        ERC20(Rocket).transfer(ceoAddress, fee2);
        ERC20(Rocket).transfer(ceoAddress2, fee-fee2);
        claimedFUELs[msg.sender]=SafeMath.add(claimedFUELs[msg.sender],FUELsBought);
        STARTFUELs(ref);
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateFUELSell(uint256 FUELs) public view returns(uint256) {
        return calculateTrade(FUELs,marketFUELs,ERC20(Rocket).balanceOf(address(this)));
    }
    function calculateFUELBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketFUELs);
    }
    function calculateFUELBuySimple(uint256 eth) public view returns(uint256){
        return calculateFUELBuy(eth,ERC20(Rocket).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,10),100);
    }
    function seedMarket(uint256 amount) public {
        ERC20(Rocket).transferFrom(address(msg.sender), address(this), amount);
        require(marketFUELs==0);
        initialized=true;
        marketFUELs=864000000000;
    }
    function getBalance() public view returns(uint256) {
        return ERC20(Rocket).balanceOf(address(this));
    }
    function getMyROCKET_LAUNCH() public view returns(uint256) {
        return STARTeryROCKET_LAUNCH[msg.sender];
    }
    function getMyFUELs() public view returns(uint256) {
        return SafeMath.add(claimedFUELs[msg.sender],getFUELsSinceLastSTART(msg.sender));
    }
    function getFUELsSinceLastSTART(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(FUELS_TO_START_1ROCKET_LAUNCH,SafeMath.sub(now,lastSTART[adr]));
        return SafeMath.mul(secondsPassed,STARTeryROCKET_LAUNCH[adr]);
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