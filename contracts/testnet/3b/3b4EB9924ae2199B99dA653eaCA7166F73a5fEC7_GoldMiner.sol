/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract GoldMiner {
    
    uint256 GOLD_TO_MINING_MINER = 864000;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    uint256 public marketGold;
    bool public initialized;
    address public ceoAddress;

    mapping (address => uint256) public miningMiners;
    mapping (address => uint256) public claimedGold;
    mapping (address => uint256) public lastMining;
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
        if(ref == msg.sender || ref == address(0) || miningMiners[ref] == 0) {
            ref = ceoAddress;
        }

        if(referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }

        uint256 goldUsed = getMyGold(msg.sender);
        uint256 newMiners = goldUsed / GOLD_TO_MINING_MINER;
        miningMiners[msg.sender] = miningMiners[msg.sender] + newMiners;
        claimedGold[msg.sender] = 0;
        lastMining[msg.sender] = block.timestamp;

        claimedGold[referrals[msg.sender]] = claimedGold[referrals[msg.sender]] + goldUsed * 13 / 100;
        marketGold = marketGold + goldUsed / 5;
    }

    function sellGold() external onlyOpen {
        uint256 hasGold = getMyGold(msg.sender);
        uint256 goldValue = calculateGoldSell(hasGold);
        uint256 fee = devFee(goldValue);
        claimedGold[msg.sender] = 0;
        lastMining[msg.sender] = block.timestamp;
        marketGold = marketGold + hasGold;
        (bool success, ) = ceoAddress.call{value: fee}("");
        require(success, "ceoAddress pay failed");
        (bool success1, ) = msg.sender.call{value: goldValue - fee}("");
        require(success1, "msg.sender pay failed");
    }

    function buyGold(address ref) external payable onlyOpen {
        uint256 goldBought = calculateGoldBuy(msg.value, address(this).balance - msg.value);
        goldBought = goldBought - devFee(goldBought);
        uint256 fee = devFee(msg.value);
        (bool success, ) = ceoAddress.call{value: fee}("");
        require(success, "ceoAddress pay failed");
        claimedGold[msg.sender] = claimedGold[msg.sender] + goldBought;
        hatchEggs(ref);
    }

    function seedMarket() external onlyOwner {
        require(marketGold == 0);
        initialized = true;
        marketGold = 86400000000;
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {  
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function calculateGoldSell(uint256 gold) public view returns(uint256) {
        return calculateTrade(gold, marketGold, address(this).balance);
    }

    function calculateGoldBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketGold);
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getMyGold(address _address) public view returns(uint256) {
        return claimedGold[_address] + getGoldSinceLastHatch(_address);
    }
    
    function getGoldSinceLastHatch(address _address) public view returns(uint256) {
        uint256 secondsPassed = min(GOLD_TO_MINING_MINER, block.timestamp - lastMining[_address]);
        return secondsPassed * miningMiners[_address];
    }

    function devFee(uint256 amount) private pure returns(uint256) {
        return amount *  3 / 100;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}