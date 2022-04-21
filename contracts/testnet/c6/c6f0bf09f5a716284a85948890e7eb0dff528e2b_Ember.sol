/**
 *Submitted for verification at BscScan.com on 2022-XX-XX
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SafeMath.sol";
import "./Ownable.sol";

contract Ember is Context, Ownable {
    using SafeMath for uint256;

    uint256 private embersBask = 1080000;
    uint256 private PSN = 10000;
    uint256 private PSNHRS = 5000;
    uint256 private devFeeVal = 2;
    bool private initialized = false;
    address payable private walletOfPrometheus;
    mapping (address => uint256) private campfireSize;
    mapping (address => uint256) private claimedEmbers;
    mapping (address => uint256) private lastStoke;
    mapping (address => address) private referrals;
    uint256 private marketEmbers;
    
    constructor() {
        walletOfPrometheus = payable(msg.sender);
    }
    
    function stokeEmbers(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 embersUsed = getMyEmbers(msg.sender);
        uint256 newMiners = SafeMath.div(embersUsed,embersBask);
        campfireSize[msg.sender] = SafeMath.add(campfireSize[msg.sender],newMiners);
        claimedEmbers[msg.sender] = 0;
        lastStoke[msg.sender] = block.timestamp;
        
        //send referral embers
        claimedEmbers[referrals[msg.sender]] = SafeMath.add(claimedEmbers[referrals[msg.sender]],SafeMath.div(embersUsed,8));
        
        //boost market to nerf miners hoarding
        marketEmbers=SafeMath.add(marketEmbers,SafeMath.div(embersUsed,5));
    }
    
    function sellEmbers() public {
        require(initialized);
        uint256 hasEmbers = getMyEmbers(msg.sender);
        uint256 emberValue = calculateSell(hasEmbers);
        uint256 fee = devFee(emberValue);
        claimedEmbers[msg.sender] = 0;
        lastStoke[msg.sender] = block.timestamp;
        marketEmbers = SafeMath.add(marketEmbers,hasEmbers);
        walletOfPrometheus.transfer(fee);
        payable (msg.sender).transfer(SafeMath.sub(emberValue,fee));
    }
    
    function heatRewards(address adr) public view returns(uint256) {
        uint256 hasEmbers = getMyEmbers(adr);
        uint256 emberValue = calculateSell(hasEmbers);
        return emberValue;
    }
    
    function buyEmbers(address ref) public payable {
        require(initialized);
        uint256 embersBought = calculateEmberBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        embersBought = SafeMath.sub(embersBought,devFee(embersBought));
        uint256 fee = devFee(msg.value);
        walletOfPrometheus.transfer(fee);
        claimedEmbers[msg.sender] = SafeMath.add(claimedEmbers[msg.sender],embersBought);
        stokeEmbers(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNHRS,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNHRS,rt)),rt)));
    }
    
    function calculateSell(uint256 embers) public view returns(uint256) {
        return calculateTrade(embers,marketEmbers,address(this).balance);
    }
    
    function calculateEmberBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketEmbers);
    }
    
    function calculateEmberBuySimple(uint256 eth) public view returns(uint256) {
        return calculateEmberBuy(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }
    
    function seedMarket() public payable onlyOwner {
        require(marketEmbers == 0);
        initialized = true;
        marketEmbers = 108000000000;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getCamfireSize(address adr) public view returns(uint256) {
        return campfireSize[adr];
    }
    
    function getMyEmbers(address adr) public view returns(uint256) {
        return SafeMath.add(claimedEmbers[adr],getEmbersSinceLastStoke(adr));
    }
    
    function getEmbersSinceLastStoke(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(embersBask,SafeMath.sub(block.timestamp,lastStoke[adr]));
        return SafeMath.mul(secondsPassed,campfireSize[adr]);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}