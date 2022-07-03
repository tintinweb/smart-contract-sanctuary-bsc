/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.4.26; // solhint-disable-line

contract CryptoVHS{
    //uint256 BNB_PER_VHS_PER_SECOND=1;
    uint256 public BNB_TO_PLAY_1VHS=864000;//for final version should be seconds in a day.
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    address public ceoAddress2;
    mapping (address => uint256) public playedVHS;
    mapping (address => uint256) public claimedBNB;
    mapping (address => uint256) public lastPlay;
    mapping (address => address) public referrals;
    uint256 public marketBNB;
    constructor() public{
        ceoAddress=msg.sender;
        ceoAddress2=address(0xdcc689C710eBC83B9C52d6Cfc3A8e78F1dF74E01);
    }
    function playBNB(address ref) public{
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender){
            referrals[msg.sender]=ref;
        }
        uint256 BNBUsed=getMyBNB();
        uint256 newVHS=SafeMath.div(BNBUsed,BNB_TO_PLAY_1VHS);
        playedVHS[msg.sender]=SafeMath.add(playedVHS[msg.sender],newVHS);
        claimedBNB[msg.sender]=0;
        lastPlay[msg.sender]=now;
        
        //send referral BNB
        claimedBNB[referrals[msg.sender]]=SafeMath.add(claimedBNB[referrals[msg.sender]],SafeMath.div(BNBUsed,10));
        
        //boost market to nerf VHS hoarding
        marketBNB=SafeMath.add(marketBNB,SafeMath.div(BNBUsed,5));
    }
    function sellBNB() public{
        require(initialized);
        uint256 hasBNB=getMyBNB();
        uint256 BNBValue=calculateBNBell(hasBNB);
        uint256 fee=devFee(BNBValue);
        uint256 fee2=fee/2;
        claimedBNB[msg.sender]=0;
        lastPlay[msg.sender]=now;
        marketBNB=SafeMath.add(marketBNB,hasBNB);
        ceoAddress.transfer(fee2);
        ceoAddress2.transfer(fee-fee2);
        msg.sender.transfer(SafeMath.sub(BNBValue,fee));
    }
    function buyBNB(address ref) public payable{
        require(initialized);
        uint256 BNBBought=calculateBNBBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        BNBBought=SafeMath.sub(BNBBought,devFee(BNBBought));
        uint256 fee=devFee(msg.value);
        uint256 fee2=fee/2;
        ceoAddress.transfer(fee2);
        ceoAddress2.transfer(fee-fee2);
        claimedBNB[msg.sender]=SafeMath.add(claimedBNB[msg.sender],BNBBought);
        playBNB(ref);
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateBNBell(uint256 BNB) public view returns(uint256){
        return calculateTrade(BNB,marketBNB,address(this).balance);
    }
    function calculateBNBBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketBNB);
    }
    function calculateBNBBuySimple(uint256 eth) public view returns(uint256){
        return calculateBNBBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,5),100);
    }
    function seedMarket() public payable{
        require(marketBNB==0);
        initialized=true;
        marketBNB=86400000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyVHS() public view returns(uint256){
        return playedVHS[msg.sender];
    }
    function getMyBNB() public view returns(uint256){
        return SafeMath.add(claimedBNB[msg.sender],getBNBSinceLastPlay(msg.sender));
    }
    function getBNBSinceLastPlay(address adr) public view returns(uint256){
        uint256 secondsPassed=min(BNB_TO_PLAY_1VHS,SafeMath.sub(now,lastPlay[adr]));
        return SafeMath.mul(secondsPassed,playedVHS[adr]);
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