/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract GoldMiner {
    
    uint256 GOLD_TO_MINER = 864000;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    uint256 public marketEggs;
    bool public initialized;
    address public ceoAddress;

    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    
    modifier onlyOwner {
        require(msg.sender == ceoAddress, "not owner");
        _;
    }

    modifier onlyOpen {
        require(initialized, "not open");
        _;
    }

    constructor() {
        ceoAddress = msg.sender;
    }

    function hatchEggs(address ref) public onlyOpen {
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }

        if(referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }

        uint256 eggsUsed = getMyEggs(msg.sender);
        uint256 newMiners = eggsUsed / GOLD_TO_MINER;
        hatcheryMiners[msg.sender] = hatcheryMiners[msg.sender] + newMiners;
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;

        claimedEggs[referrals[msg.sender]] = claimedEggs[referrals[msg.sender]] + eggsUsed * 13 / 100;
        marketEggs = marketEggs + eggsUsed / 5;
    }

    function sellEggs() external onlyOpen {
        uint256 hasEggs = getMyEggs(msg.sender);
        uint256 eggValue = calculateEggSell(hasEggs);
        uint256 fee = devFee(eggValue);
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketEggs = marketEggs + hasEggs;
        (bool success, ) = ceoAddress.call{value: fee}("");
        require(success, "ceoAddress pay failed");
        (bool success1, ) = msg.sender.call{value: eggValue - fee}("");
        require(success1, "msg.sender pay failed");
    }

    function buyEggs(address ref) external payable onlyOpen {
        uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance - msg.value);
        eggsBought = eggsBought - devFee(eggsBought);
        uint256 fee = devFee(msg.value);
        (bool success, ) = ceoAddress.call{value: fee}("");
        require(success, "ceoAddress pay failed");
        claimedEggs[msg.sender] = claimedEggs[msg.sender] + eggsBought;
        hatchEggs(ref);
    }

    function seedMarket() external onlyOwner {
        require(marketEggs == 0);
        initialized = true;
        marketEggs = 86400000000;
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {  
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function calculateEggSell(uint256 eggs) public view returns(uint256) {
        return calculateTrade(eggs, marketEggs, address(this).balance);
    }

    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getMyEggs(address _address) public view returns(uint256) {
        return claimedEggs[_address] + getEggsSinceLastHatch(_address);
    }
    
    function getEggsSinceLastHatch(address _address) public view returns(uint256) {
        uint256 secondsPassed = min(GOLD_TO_MINER, block.timestamp - lastHatch[_address]);
        return secondsPassed * hatcheryMiners[_address];
    }

    function devFee(uint256 amount) private pure returns(uint256) {
        return amount *  3 / 100;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}