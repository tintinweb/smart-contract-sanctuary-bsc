/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/* 
SPDX-License-Identifier: UNLICENSED
*/

pragma solidity ^0.8.14;

contract BTSAuthRouter {
    address public ownerWalletAddress;
    address public devFeeAddress;
    uint public defaultRefDiscount;
    uint public defaultRefCommission;

    mapping(address => bool) public isReferrer;
    mapping(address => uint) public refDiscount;
    mapping(address => uint) public refCommission;
    mapping(address => uint) public numReferrals;
    mapping(address => uint) public userTier;
    mapping(uint => uint) public tierDevFees;
    mapping(uint => uint) public tierPrices;
    mapping(string => string) public botLatestVersion;

    bool public trialRegistrationAllowed;
    uint public numUsers;
    uint public numReferrers;
    uint public maxNumTiers;

    modifier onlyOwner() {
        require(msg.sender == ownerWalletAddress, "Owner only");
        _;
    }

    constructor() {
        ownerWalletAddress = payable(msg.sender);
        devFeeAddress = payable(msg.sender);
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

        maxNumTiers = 5;
        trialRegistrationAllowed = true;
        numUsers = 0;
        numReferrers = 0;
    }

    function registerFreeTrial() public {
        require(userTier[msg.sender] == 0, "Wallet already registered");
        userTier[msg.sender] = 1;
        numUsers++;
    }

    function buyTier(uint tierID, address refAddress) public payable {
        uint currentTier = userTier[msg.sender];
        uint buyPrice = tierPrices[tierID];
        require(currentTier == 0, "Wallet already registered");
        require(tierID >= 2 && tierID <= maxNumTiers, "Invalid tier choice");

        if (refAddress != address(0)) {
            require(isReferrer[refAddress], "Referrer does not exist");
            uint userBuyPrice = uint((buyPrice * (100 - refDiscount[refAddress])) / 100);
            uint referrerCommission = uint((buyPrice * refCommission[refAddress]) / 100);
            require(msg.value >= userBuyPrice, "Not enough funds");
            payable(refAddress).transfer(referrerCommission);
            payable(ownerWalletAddress).transfer(address(this).balance);
            numReferrals[refAddress]++;
        } else {
            require(msg.value >= buyPrice, "Not enough funds");
            payable(ownerWalletAddress).transfer(address(this).balance);
        }

        userTier[msg.sender] = tierID;
        numUsers++;
    }

    function upgradeTier(uint tierID, address refAddress) public payable {
        uint currentTier = userTier[msg.sender];
        require(tierID > currentTier, "Downgrading tier not permitted");
        require(tierID > 0 && tierID <= maxNumTiers, "Invalid tier choice");
        uint upgradePrice = tierPrices[tierID] - tierPrices[currentTier];

        if (refAddress != address(0)) {
            require(isReferrer[refAddress], "Referrer does not exist");
            uint userUpgradePrice = uint((upgradePrice * (100 - refDiscount[refAddress])) / 100);
            uint referrerCommission = uint((upgradePrice * refCommission[refAddress]) / 100);
            require(msg.value >= userUpgradePrice, "Not enough funds");
            payable(refAddress).transfer(referrerCommission);
            payable(ownerWalletAddress).transfer(address(this).balance);
            numReferrals[refAddress]++;
        } else {
            require(msg.value >= upgradePrice, "Not enough funds");
            payable(ownerWalletAddress).transfer(address(this).balance);
        }

        userTier[msg.sender] = tierID;
    }

    function registerAsReferrer() public {
        require(isReferrer[msg.sender] == false, "Referrer already registered");
        isReferrer[msg.sender] = true;
        refDiscount[msg.sender] = defaultRefDiscount;
        refCommission[msg.sender] = defaultRefCommission;
        numReferrers++;
    }

    function changeRegisteredWallet(address newWallet) public {
        require(userTier[msg.sender] > 0, "Existing wallet not registered");
        require(userTier[newWallet] == 0, "New wallet already registered");
        userTier[newWallet] = userTier[msg.sender];
        userTier[msg.sender] = 0;
    }

    function setUserTier(address userAddr, uint tierType) public onlyOwner {
        require(tierType > userTier[userAddr], "DEV: Downgrading tier not permitted");

        if(userTier[userAddr] == 0) { 
            numUsers++;
        }

        userTier[userAddr] = tierType;
    }

    function addReferrer(address refAddr) public onlyOwner {
        require(isReferrer[refAddr] != true, "DEV: Referrer already registered");
        isReferrer[refAddr] = true;
        refDiscount[refAddr] = defaultRefDiscount;
        refCommission[refAddr] = defaultRefCommission;
        numReferrers++;
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

    function addNewTierType(uint newTierPrice) public onlyOwner {
        tierPrices[maxNumTiers] = newTierPrice;
        maxNumTiers++;
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

    function changeDevFeeWallet(address newDevFeeWallet) public onlyOwner {
        devFeeAddress = newDevFeeWallet;
    }

    function updateBotVersion(string memory botType, string memory latestVersion) public onlyOwner {
        botLatestVersion[botType] = latestVersion;
    }
}