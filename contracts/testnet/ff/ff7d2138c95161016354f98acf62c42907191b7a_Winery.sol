/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

pragma solidity ^0.4.26; // solhint-disable-line

contract Winery{
    //uint256 WINE_PER_MINERS_PER_SECOND=1;
    uint256 public WINE_TO_REAGING_1MINERS=864000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public wineMiners;
    mapping (address => uint256) public claimedWine;
    mapping (address => uint256) public lastDrink;
    mapping (address => address) public referrals;
    uint256 public barWine;
    constructor() public{
        ceoAddress=msg.sender;
    }
    function reAging(address ref) public{
        require(initialized);
        if(ref == msg.sender || ref == address(0) || wineMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 wineUsed=getMyWine();
        uint256 newMiners=SafeMath.div(wineUsed,WINE_TO_REAGING_1MINERS);
        wineMiners[msg.sender]=SafeMath.add(wineMiners[msg.sender],newMiners);
        claimedWine[msg.sender]=0;
        lastDrink[msg.sender]=now;

        //send referral wine
        claimedWine[referrals[msg.sender]]=SafeMath.add(claimedWine[referrals[msg.sender]],SafeMath.div(SafeMath.mul(wineUsed,14),100));

        //boost market to nerf miners hoarding
        barWine=SafeMath.add(barWine,SafeMath.div(wineUsed,5));
    }
    function drinkWine() public{
        require(initialized);
        uint256 hasWine=getMyWine();
        uint256 wineValue=calculateDrinkWine(hasWine);
        uint256 fee=devFee(wineValue);
        claimedWine[msg.sender]=0;
        lastDrink[msg.sender]=now;
        barWine=SafeMath.add(barWine,hasWine);
        ceoAddress.transfer(fee);
        msg.sender.transfer(SafeMath.sub(wineValue,fee));
    }
    function buyWine(address ref) public payable{
        require(initialized);
        uint256 wineBought=calculateBuyWine(msg.value,SafeMath.sub(address(this).balance,msg.value));
        wineBought=SafeMath.sub(wineBought,devFee(wineBought));
        uint256 fee=devFee(msg.value);
        ceoAddress.transfer(fee);
        claimedWine[msg.sender]=SafeMath.add(claimedWine[msg.sender],wineBought);
        reAging(ref);
    }

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateDrinkWine(uint256 wine) public view returns(uint256){
        return calculateTrade(wine,barWine,address(this).balance);
    }
    function calculateBuyWine(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,barWine);
    }
    function calculateBuyWineSimple(uint256 eth) public view returns(uint256){
        return calculateBuyWine(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,2),100);
    }
    function seedMarket() public payable{
        require(msg.sender == ceoAddress, 'invalid call');
        require(barWine==0);
        initialized=true;
        barWine=86400000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return wineMiners[msg.sender];
    }
    function getMyWine() public view returns(uint256){
        return SafeMath.add(claimedWine[msg.sender],getWineSincelastDrink(msg.sender));
    }
    function getWineSincelastDrink(address adr) public view returns(uint256){
        uint256 secondsPassed=min(WINE_TO_REAGING_1MINERS,SafeMath.sub(now,lastDrink[adr]));
        return SafeMath.mul(secondsPassed,wineMiners[adr]);
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