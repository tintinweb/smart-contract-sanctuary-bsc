/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

/*
BlockchainTokenSniper Authentication System (v1)

Website: blockchaintokensniper.com
Telegram: t.me/blockchaintokensniper

SPDX-License-Identifier: UNLICENSED
*/

pragma solidity ^0.8.14;

contract BTSAuthRouter {

    address public ownerWalletAddress;

    uint public defaultRefDiscount;
    uint public defaultRefCommission;

    mapping(address => bool) public isReferrer;
    mapping(address => uint) public refDiscount;
    mapping(address => uint) public refCommission;

    mapping(address => uint) public userTier;
    mapping(uint => uint) public tierDevFees;
    mapping(uint => uint) public tierPrices;

    mapping(string => string) public botLatestVersion;
    mapping(string => bool) public botTradingAllowed;

    bool public trialRegistrationAllowed;

    modifier onlyOwner() {
        require(msg.sender == ownerWalletAddress, "E0: Owner only");
        _;
    }

    constructor() {
        ownerWalletAddress = payable(msg.sender);

        defaultRefDiscount = 10;
        defaultRefCommission = 20;

        tierDevFees[1] = 75; 
        tierDevFees[2] = 10; 
        tierDevFees[3] = 7;
        tierDevFees[4] = 5;
        tierDevFees[5] = 0;

        tierPrices[2] = 0.5 ether;
        tierPrices[3] = 1 ether; 
        tierPrices[4] = 2 ether; 
        tierPrices[5] = 5 ether; 

        trialRegistrationAllowed = true;
    }

    function registerFreeTrial() public {
        require(userTier[msg.sender] == 0, "E1: Tier already exists");
        userTier[msg.sender] = 1;
    }

    function buyTier(uint tierID, address refAddress) public payable {
        uint currentTier = userTier[msg.sender];
        require(currentTier == 0, "E1: Tier already exists");

        uint buyPrice = tierPrices[tierID];

        if (refAddress != address(0)) {
            require(isReferrer[refAddress], "E2: Referrer does not exist");
            uint userBuyPrice = uint((buyPrice * (100 - refDiscount[refAddress])) / 100);
            uint referrerCommission = uint((buyPrice * refCommission[refAddress]) / 100);

            require(msg.value >= userBuyPrice, "E3: Not enough funds");

            payable(refAddress).transfer(referrerCommission);
            payable(ownerWalletAddress).transfer(address(this).balance);
        }

        else {
            require(msg.value >= buyPrice, "E3: Not enough funds");
            payable(ownerWalletAddress).transfer(buyPrice);
        }

        userTier[msg.sender] = tierID;
    }

    function upgradeTier(uint tierID, address refAddress) public payable {
        uint currentTier = userTier[msg.sender];
        uint newTier = tierID;

        require(newTier > currentTier, "E4: Downgrading tier not permitted");
        require(newTier > 0, "E5: Tier does not exist");
        require(newTier <= 4, "E6: Invalid tier choice");

        uint upgradePrice = tierPrices[newTier] - tierPrices[currentTier];

        if (refAddress != address(0)) {
            require(isReferrer[refAddress], "E2: Referrer does not exist");

            uint userUpgradePrice = uint((upgradePrice * (100 - refDiscount[refAddress])) / 100);
            uint referrerCommission = uint((upgradePrice * refCommission[refAddress]) / 100);

            require(msg.value >= userUpgradePrice, "E3: Not enough funds");

            payable(refAddress).transfer(referrerCommission);
            payable(ownerWalletAddress).transfer(address(this).balance);
        }

        else {
            require(msg.value >= upgradePrice, "E3: not enough funds");
            payable(ownerWalletAddress).transfer(upgradePrice);
        }

        userTier[msg.sender] = tierID;
    }

    function registerAsReferrer() public {
        require(isReferrer[msg.sender] != true, "E7: Referrer already registered");
        isReferrer[msg.sender] = true;
        refDiscount[msg.sender] = defaultRefDiscount;
        refCommission[msg.sender] = defaultRefCommission;
    }

    // Functions for developer use only.

    function setUserTier(address userAddr, uint tierType) public onlyOwner {
        require(tierType > userTier[userAddr], "DEV: Downgrading tier not permitted");
        userTier[userAddr] = tierType;
    }

    function changeDevFee(uint tierType, uint newDevFee) public onlyOwner {
        if (tierType >= 2) {
            require(newDevFee <= 25, "DEV: Fees set too high");
        }
        tierDevFees[tierType] = newDevFee;
    }

    function editTierPrice(uint tierType, uint newTierPrice) public onlyOwner {
        tierPrices[tierType] = newTierPrice;
    }

    function changeReferrerCommission(address refAddress, uint commissionAmount) public onlyOwner {
        require(commissionAmount >= 10, "DEV: Commission amount too low");
        refCommission[refAddress] = commissionAmount;
    }

    function changeReferrerDiscount(address refAddress, uint discountAmount) public onlyOwner {
        require(discountAmount >= 10, "DEV: Discount amount too low");
        refDiscount[refAddress] = discountAmount;
    }

    function changeDefaultRefCommission(uint commissionAmount) public onlyOwner {
        require(commissionAmount >= 10, "DEV: Commission amount too low");
        defaultRefCommission = commissionAmount;
    }

    function changeDefaultRefDiscount(uint discountAmount) public onlyOwner {
        require(discountAmount >= 10, "DEV: Discount amount too low");
        defaultRefDiscount = discountAmount;
    }

    function allowTrialRegistrations(bool isAllowed) public onlyOwner {
        trialRegistrationAllowed = isAllowed;
    }

    function changeAdminWallet(address newAdminWallet) public onlyOwner {
        ownerWalletAddress = newAdminWallet;
    }

    function addNewBot(string memory botType, string memory latestVersion) public onlyOwner {
        botTradingAllowed[botType] = true;
        botLatestVersion[botType] = latestVersion;
    }

    function updateBotVersion(string memory botType, string memory latestVersion) public onlyOwner {
        botLatestVersion[botType] = latestVersion;
    }

    function allowBotTrading(string memory botType, bool isAllowed) public onlyOwner {
        botTradingAllowed[botType] = isAllowed;
    }
}