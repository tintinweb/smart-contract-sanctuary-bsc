/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.4.26;
contract PuppyLand{

    //uint256 DOGS_PER_MINERS_PER_SECOND=1;
    uint256 public DOGS_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedPuppies;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    uint256 public marketPuppies;
    
    Jelly jelly;
    constructor(address _jelly) public{
        jelly = Jelly(_jelly); 
        ceoAddress=msg.sender;
        
    }
    function callJelly() public {
       jelly.log(); 

   }
    function breedDog(address ref) public{
        require(initialized);
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 dogsUsed=getMyPuppies();
        uint256 newMiners=SafeMath.div(dogsUsed,DOGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedPuppies[msg.sender]=0;
        lastHatch[msg.sender]=now;

        //send referral eggs
        claimedPuppies[referrals[msg.sender]]=SafeMath.add(claimedPuppies[referrals[msg.sender]],SafeMath.div(SafeMath.mul(dogsUsed,15),100));

        //boost market to nerf miners hoarding
        marketPuppies=SafeMath.add(marketPuppies,SafeMath.div(dogsUsed,5));
    }
    function sellPuppies() public{
        require(initialized);
        uint256 hasDogs=getMyPuppies();
        uint256 dogValue=calculatePuppiesSell(hasDogs);
        uint256 fee=devFee(dogValue);
        claimedPuppies[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketPuppies=SafeMath.add(marketPuppies,hasDogs);
        ceoAddress.transfer(fee);
        msg.sender.transfer(SafeMath.sub(dogValue,fee));
    }
    function buyDogs(address ref) public payable{
        require(initialized);
        uint256 dogsBought=calculateDogBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        dogsBought=SafeMath.sub(dogsBought,devFee(dogsBought));
        uint256 fee=devFee(msg.value);
        ceoAddress.transfer(fee);
        claimedPuppies[msg.sender]=SafeMath.add(claimedPuppies[msg.sender],dogsBought);
        breedDog(ref);
    }

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculatePuppiesSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs,marketPuppies,address(this).balance);
    }
    function calculateDogBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketPuppies);
    }
    function calculateDogBuySimple(uint256 eth) public view returns(uint256){
        return calculateDogBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,2),100);
    }
    function openBreed() public payable{
        require(msg.sender == ceoAddress, 'invalid call');
        require(marketPuppies==0);
        initialized=true;
        marketPuppies=86400000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMyPuppies() public view returns(uint256){
        return SafeMath.add(claimedPuppies[msg.sender],getPuppiesSinceLastHatch(msg.sender));
    }
    function getPuppiesSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=min(DOGS_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}
 contract Jelly {
         event Log(string message);

    function log() public{
    emit Log("Jelly function was called");
   
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