/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

/**
 *Website: https://WCMiner.finance
*/

pragma solidity ^0.4.26; // solhint-disable-line

/*
*    ___       __   ________                _____ ______   ___  ________   _______   ________     
*   |\  \     |\  \|\   ____\              |\   _ \  _   \|\  \|\   ___  \|\  ___ \ |\   __  \    
*   \ \  \    \ \  \ \  \___|  ____________\ \  \\\__\ \  \ \  \ \  \\ \  \ \   __/|\ \  \|\  \   
*    \ \  \  __\ \  \ \  \    |\____________\ \  \\|__| \  \ \  \ \  \\ \  \ \  \_|/_\ \   _  _\  
*     \ \  \|\__\_\  \ \  \___\|____________|\ \  \    \ \  \ \  \ \  \\ \  \ \  \_|\ \ \  \\  \| 
*      \ \____________\ \_______\             \ \__\    \ \__\ \__\ \__\\ \__\ \_______\ \__\\ _\ 
*       \|____________|\|_______|              \|__|     \|__|\|__|\|__| \|__|\|_______|\|__|\|__|
*                                                                                                 
*/                                                                                              
                                                                                              

contract WCMiner {
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    uint256 public EGGS_TO_HATCH_1MINERS=2592000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    address public ceoAddress2;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => uint256) public lastSell;
    mapping (address => address) public referrals;
    mapping (address => uint256) public compoundTimes;

    uint256 public marketEggs;
    constructor(address _ceo, address _ceo2) public{
        ceoAddress = _ceo;
        ceoAddress2 = _ceo2;
    }
    function hatchEggs(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = 0;
        }
        if (lastHatch[msg.sender] + 1 days <= now) {
            compoundTimes[msg.sender] = compoundTimes[msg.sender] + 1;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender){
            referrals[msg.sender]=ref;
        }
        uint256 eggsUsed = getMyEggs();
        uint256 newMiners = SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
        newMiners = SafeMath.sub(newMiners, devFee(newMiners, 5));
        hatcheryMiners[msg.sender] =SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = now;
        
        //send referral eggs
        claimedEggs[referrals[msg.sender]]=SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(SafeMath.mul(eggsUsed,12), 100));
        
        //boost market to nerf miners hoarding
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
    }
    function sellEggs() public {
        require(initialized);
        require(lastHatch[msg.sender] + 1 days <= now, "You can withdraw after 24hours");
        uint256 hasEggs=getMyEggs();
        if (compoundTimes[msg.sender] >= 28) {
            hasEggs = SafeMath.div(SafeMath.mul(hasEggs, 1090), 1000);
            compoundTimes[msg.sender] = 0;
        } else if (compoundTimes[msg.sender] >= 21) {
            hasEggs = SafeMath.div(SafeMath.mul(hasEggs, 1075), 1000);
            compoundTimes[msg.sender] = 0;
        } else if (compoundTimes[msg.sender] >= 14) {
            hasEggs = SafeMath.div(SafeMath.mul(hasEggs, 1050), 1000);
            compoundTimes[msg.sender] = 0;
        } else if (compoundTimes[msg.sender] >= 7) {
            hasEggs = SafeMath.div(SafeMath.mul(hasEggs, 1030), 1000);
            compoundTimes[msg.sender] = 0;
        }
        
        uint256 eggValue=calculateEggSell(hasEggs);
        uint256 fee=devFee(eggValue, 7);
        uint256 fee2=fee/2;
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;
        lastSell[msg.sender] = now;
        marketEggs=SafeMath.add(marketEggs,hasEggs);
        ceoAddress.transfer(fee2);
        ceoAddress2.transfer(fee-fee2);
        msg.sender.transfer(SafeMath.sub(eggValue,fee));
    }
    function buyEggs(address ref) public payable{
        require(initialized);
        uint256 eggsBought=calculateEggBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought, 2));
        uint256 fee=devFee(msg.value, 2);
        uint256 fee2=fee/2;
        ceoAddress.transfer(fee2);
        ceoAddress2.transfer(fee-fee2);
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
        hatchEggs(ref);
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs,marketEggs,address(this).balance);
    }
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketEggs);
    }
    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount, uint256 _percent) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, _percent), 100);
    }
    function seedMarket() public payable{
        require(marketEggs==0);
        initialized=true;
        marketEggs=259200000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMyEggs() public view returns(uint256){
        return SafeMath.add(claimedEggs[msg.sender],getEggsSinceLastHatch(msg.sender));
    }
    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
    function max(uint256 a, uint256 b) private pure returns (uint256) {
        return a > b ? a : b;
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