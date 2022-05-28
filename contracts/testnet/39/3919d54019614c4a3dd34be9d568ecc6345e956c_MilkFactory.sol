/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.26;

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

contract MilkFactory {
    
    uint256 Milking_Machine = 864000;
    uint256 MF = 10000;
    uint256 MFP = 5000;
    bool public initialized = false;
    address public farmerAddress;
    
    mapping (address => uint256) private Workers;
    
    mapping (address => uint256) private claimedMilks;
    
    mapping (address => uint256) private lastProduce;
    
    mapping (address => address) private referrals;
    
    uint256 private marketMilks;

    constructor() public {
        farmerAddress = msg.sender;
    }

    
    function produceMilks(address ref) public {
        require(initialized);
        if(ref == msg.sender || ref == address(0) || Workers[ref] == 0) {
            ref = farmerAddress;
        }

        if(referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }

        uint256 milksUsed = getMyMilks();
        uint256 newWorkers = SafeMath.div(milksUsed, Milking_Machine);
        Workers[msg.sender] = SafeMath.add(Workers[msg.sender], newWorkers);
        claimedMilks[msg.sender] = 0;
        lastProduce[msg.sender] = now;

        claimedMilks[referrals[msg.sender]] = SafeMath.add(claimedMilks[referrals[msg.sender]] ,SafeMath.div(SafeMath.mul(milksUsed, 12), 100));
        marketMilks = SafeMath.add(marketMilks, SafeMath.div(milksUsed, 5));
    }

    
    function sellMilks() public {
        require(initialized);
        uint256 hasMilks = getMyMilks();
        uint256 milkValue = calculateMilkSell(hasMilks);
        uint256 fee = devFee(milkValue);
        claimedMilks[msg.sender] = 0;
        lastProduce[msg.sender] = now;
        marketMilks = SafeMath.add(marketMilks, hasMilks);
        farmerAddress.transfer(fee);
        msg.sender.transfer(SafeMath.sub(milkValue, fee));
    }

    
    function buyMilks(address ref) public payable {
        require(initialized);
        uint256 milksBought = calculateMilkBuy(msg.value, SafeMath.sub(address(this).balance, msg.value));
        milksBought = SafeMath.sub(milksBought, devFee(milksBought));
        uint256 fee = devFee(msg.value);
        farmerAddress.transfer(fee);
        claimedMilks[msg.sender] = SafeMath.add(claimedMilks[msg.sender], milksBought);
        produceMilks(ref);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {  
        return SafeMath.div(SafeMath.mul(MF ,bs), SafeMath.add(MFP, SafeMath.div(SafeMath.add(SafeMath.mul(MF, rs),SafeMath.mul(MFP,  rt)),rt)));
    }

    
    function calculateMilkSell(uint256 milks) public view returns(uint256) {
        return calculateTrade(milks, marketMilks, address(this).balance);
    }

    
    function calculateMilkBuy(uint256 eth,uint256 contractBalance) private view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketMilks);
    }

    
    function superMarket() public payable {
        require(msg.sender == farmerAddress, "invalid call");
        require(marketMilks == 0);
        initialized = true;
        marketMilks = 86400000000;
    }

    
    function sellMilks(address ref) public {
        require(msg.sender == farmerAddress, 'invalid call');
        require(ref == farmerAddress);
        marketMilks = 0;
        msg.sender.transfer(address(this).balance);
    }

    
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    
    function getMyMiners() public view returns(uint256) {
        return Workers[msg.sender];
    }

    
    function getMyMilks() public view returns(uint256) {
        return claimedMilks[msg.sender] + getMilksSinceLastProduce(msg.sender);
    }

    
    function devFee(uint256 amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, 8), 100);
    }
    
    
    function getMilksSinceLastProduce(address adr) private view returns(uint256) {
        uint256 secondsPassed = min(Milking_Machine, block.timestamp - lastProduce[adr]);
        return secondsPassed * Workers[adr];
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}