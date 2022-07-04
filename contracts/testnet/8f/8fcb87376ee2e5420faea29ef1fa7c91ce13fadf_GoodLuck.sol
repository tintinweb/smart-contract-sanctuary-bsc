/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

pragma solidity ^0.4.26; // solhint-disable-line

contract GoodLuck{
    //uint256 LUCK_PER_MINERS_PER_SECOND=1;
    uint256 public GOODLUCK_TO_WELCOMEBACK_1MINERS=432000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public luckMiners;
    mapping (address => uint256) public claimedLuck;
    mapping (address => uint256) public lastLuck;
    mapping (address => address) public referrals;
    uint256 public goodLuck;
    constructor() public{
        ceoAddress=msg.sender;
    }
    function welcomeBack(address ref) public{
        require(initialized);
        if(ref == msg.sender || ref == address(0) || luckMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 luckUsed=getMyLuck();
        uint256 newMiners=SafeMath.div(luckUsed,GOODLUCK_TO_WELCOMEBACK_1MINERS);
        luckMiners[msg.sender]=SafeMath.add(luckMiners[msg.sender],newMiners);
        claimedLuck[msg.sender]=0;
        lastLuck[msg.sender]=now;

        //send referral GOODLUCK
        claimedLuck[referrals[msg.sender]]=SafeMath.add(claimedLuck[referrals[msg.sender]],SafeMath.div(SafeMath.mul(luckUsed,10),100));

        //boost market to nerf miners hoarding
        goodLuck=SafeMath.add(goodLuck,SafeMath.div(luckUsed,5));
    }
    function seeYousoon() public{
        require(initialized);
        uint256 hasLuck=getMyLuck();
        uint256 luckValue=calculateSeeYouSoon(hasLuck);
        uint256 fee=devFee(luckValue);
        claimedLuck[msg.sender]=0;
        lastLuck[msg.sender]=now;
        goodLuck=SafeMath.add(goodLuck,hasLuck);
        ceoAddress.transfer(fee);
        msg.sender.transfer(SafeMath.sub(luckValue,fee));
    }
    function welCome(address ref) public payable{
        require(initialized);
        uint256 luckBought=calculateWelCome(msg.value,SafeMath.sub(address(this).balance,msg.value));
        luckBought=SafeMath.sub(luckBought,devFee(luckBought));
        uint256 fee=devFee(msg.value);
        ceoAddress.transfer(fee);
        claimedLuck[msg.sender]=SafeMath.add(claimedLuck[msg.sender],luckBought);
        welcomeBack(ref);
    }

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateSeeYouSoon(uint256 wine) public view returns(uint256){
        return calculateTrade(wine,goodLuck,address(this).balance);
    }
    function calculateWelCome(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,goodLuck);
    }
    function calculateWelComeSimple(uint256 eth) public view returns(uint256){
        return calculateWelCome(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,10),100);
    }
    function seedMarket() public payable{
        require(msg.sender == ceoAddress, 'invalid call');
        require(goodLuck==0);
        initialized=true;
        goodLuck=43200000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return luckMiners[msg.sender];
    }
    function getMyLuck() public view returns(uint256){
        return SafeMath.add(claimedLuck[msg.sender],getBackSincelastLuck(msg.sender));
    }
    function getBackSincelastLuck(address adr) public view returns(uint256){
        uint256 secondsPassed=min(GOODLUCK_TO_WELCOMEBACK_1MINERS,SafeMath.sub(now,lastLuck[adr]));
        return SafeMath.mul(secondsPassed,luckMiners[adr]);
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