/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4; // solhint-disable-line

contract TreasureMiners {
    uint256 public BNB_TO_PLAY_CRYPTO_LOOTERS = 864000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;

    //CREATOR VARIABLES
    address public captainAddress;
    address public subCaptainAddress;

    //MAPPING VARIABLES
    mapping (address => uint256) public cryptoLooters;
    mapping (address => uint256) public claimedRewards;
    mapping (address => uint256) public lastPlay;
    mapping (address => address) public referrals;


    //MARKET VARIABLE
    uint256 public marketBNB;

    uint256 initialMoment;
    
    constructor() {
        captainAddress = msg.sender;
        subCaptainAddress = 0x43ae3E9400f28D8ECF2d0932D86d96456f6D5df2;
        initialMoment = block.timestamp;
    }
    
    function startMining(address ref) public{
        require(initialized);
        if(ref == msg.sender) {
            ref = address(0);
        }

        if(referrals[msg.sender]==address(0) && referrals[msg.sender]!=msg.sender){
            referrals[msg.sender]=ref;
        }

        uint256 BNBUsed=getMyRewards();
        uint256 newCryptoLooter=SafeMath.div(BNBUsed,BNB_TO_PLAY_CRYPTO_LOOTERS);
        cryptoLooters[msg.sender]=SafeMath.add(cryptoLooters[msg.sender],newCryptoLooter);
        claimedRewards[msg.sender]=0;
        lastPlay[msg.sender]=block.timestamp;
        
        //send referral BNB
        claimedRewards[referrals[msg.sender]]=SafeMath.add(claimedRewards[referrals[msg.sender]],SafeMath.div(BNBUsed,10));
        
        //boost market to nerf Crypto Looters hoarding
        marketBNB=SafeMath.add(marketBNB,SafeMath.div(BNBUsed,5));
    }

    function claimTreasures() public{
        require(initialized);
        uint256 hasRewards=getMyRewards();
        uint256 BNBValue=calculateClaimTreasures(hasRewards);
        uint256 fee=devFee(BNBValue);
        uint256 fee2=fee/2;
        claimedRewards[msg.sender] = 0;
        lastPlay[msg.sender] = block.timestamp;
        marketBNB = SafeMath.add(marketBNB,hasRewards);
        payable(captainAddress).transfer(fee2);
        payable(subCaptainAddress).transfer(fee-fee2);
        payable(msg.sender).transfer(SafeMath.sub(BNBValue,fee));
    }

    function buyMiners(address ref) public payable{
        require(initialized);
        uint256 BNBBought=calculateBNBBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        BNBBought=SafeMath.sub(BNBBought,devFee(BNBBought));
        uint256 fee=devFee(msg.value);
        uint256 fee2=fee/2;
        payable(captainAddress).transfer(fee2);
        payable(subCaptainAddress).transfer(fee-fee2);
        claimedRewards[msg.sender]=SafeMath.add(claimedRewards[msg.sender],BNBBought);
        startMining(ref);
    }
    
    
    //BALANCING ALGORITHM
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateClaimTreasures(uint256 BNB) public view returns(uint256){
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
    function getMyCryptoLooters() public view returns(uint256){
        return cryptoLooters[msg.sender];
    }
    function getMyRewards() public view returns(uint256){
        return SafeMath.add(claimedRewards[msg.sender],getRewardsSinceLastPlay(msg.sender));
    }
    function getRewardsSinceLastPlay(address adr) public view returns(uint256){
        uint256 secondsPassed=min(BNB_TO_PLAY_CRYPTO_LOOTERS,SafeMath.sub(block.timestamp,lastPlay[adr]));
        return SafeMath.mul(secondsPassed,cryptoLooters[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
    function getInitialMoment() external view returns(uint256) {
        return initialMoment;
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