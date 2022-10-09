/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// Published on: Dāmodara Māsa - Śrī Gaurābda 536 - Kṛṣṇakal 0.98 - Kārtik Pūrṇimā
/*
888    888 8888888888        d8888 888      
888    888 888              d88888 888      
888    888 888             d88P888 888      
8888888888 8888888        d88P 888 888      
888    888 888           d88P  888 888      
888    888 888          d88P   888 888      
888    888 888         d8888888888 888      
888    888 8888888888 d88P     888 88888888 
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

contract HealEstateV2 {
    
    struct User {
        uint id;
        address referrer;
        uint partnersCount;

        mapping(uint8 => bool) levelsActive;
        mapping(uint8 => Matrix) matrix;
    }
    
    struct Matrix {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        uint reinvestCount;

        address closedPart;

        //New to HEAL.ESTATE - 5 straight bonuses and 6th goes to upline
        address[] bonusesReceieved;
    }

    uint8 public constant TOTAL_LEVELS = 36;

    uint256 public USD_RATE = 300; //BNB price at launch

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;

    //MULTIPLE ADMINISTRATORS
    mapping (address => bool) public admins;
    mapping (address => bool) public mods;
    bool public programLaunched = false;

    //Set Whitelisted Addresses for Leaders
    mapping(address => uint) public whitelistAddresses;

    uint public lastUserId = 2;
    address public owner;
    address public HEALVault;
    
    mapping(uint8 => uint) public levelPrice;
    mapping(uint8 => uint) public refFastStartBonus;
    
    //Store prevValues for restoring price after whitelisting
    mapping(uint8 => uint) private launchLevelPrice;
    mapping(uint8 => uint) private launchRefFastStartBonus;
    
    event RegisterUser(address indexed userAddress, address indexed referrerAddress, uint indexed user_id, uint referrer_id, uint receiver_id);
    event RecordUserPlace(uint indexed user_id, uint indexed referrer_id, uint8 level, uint8 place);    
    event RecordUserBonus(uint indexed user_id, uint indexed receiver_id, uint8 level);    
    event UpgradeLevel(uint indexed user_id, uint indexed referrer_id, uint indexed receiver_id, uint8 level);
    event RecycleUser(uint indexed user_id, uint indexed newReferrer_id, uint indexed caller_id, uint8 level, uint newCycle);
    event updateUSDRate(uint256 rate);
    event genericFundTransfer(uint256 mode);

    constructor(address ownerAddress, address HEALVaultAddress) public {

        admins[ownerAddress] = true;
        mods[ownerAddress] = true;
        admins[msg.sender] = true;
        mods[msg.sender] = true;

        //Level Price
        launchLevelPrice[1]  = 8;
        launchLevelPrice[2]  = 24;
        launchLevelPrice[3]  = 40;
        launchLevelPrice[4]  = 56;
        launchLevelPrice[5]  = 72;
        launchLevelPrice[6]  = 78;
        launchLevelPrice[7]  = 234;
        launchLevelPrice[8]  = 390;
        launchLevelPrice[9]  = 546;
        launchLevelPrice[10] = 702;
        launchLevelPrice[11] = 778;
        launchLevelPrice[12] = 2334;
        launchLevelPrice[13] = 3890;
        launchLevelPrice[14] = 5446;
        launchLevelPrice[15] = 7002;
        launchLevelPrice[16] = 7778;
        launchLevelPrice[17] = 23334;
        launchLevelPrice[18] = 38890;
        launchLevelPrice[19] = 54446;
        launchLevelPrice[20] = 70002;
        launchLevelPrice[21] = 77778;
        launchLevelPrice[22] = 233334;
        launchLevelPrice[23] = 388890;
        launchLevelPrice[24] = 544446;
        launchLevelPrice[25] = 700002;
        launchLevelPrice[26] = 777778;
        launchLevelPrice[27] = 2333334;
        launchLevelPrice[28] = 3888890;
        launchLevelPrice[29] = 5444446;
        launchLevelPrice[30] = 7000002;
        launchLevelPrice[31] = 7777778;
        launchLevelPrice[32] = 23333334;
        launchLevelPrice[33] = 38888890;
        launchLevelPrice[34] = 54444446;
        launchLevelPrice[35] = 70000002;
        launchLevelPrice[36] = 77777778;

        //Referral Bonus
        launchRefFastStartBonus[1] = 3;
        launchRefFastStartBonus[2] = 9;
        launchRefFastStartBonus[3] = 15;
        launchRefFastStartBonus[4] = 21;
        launchRefFastStartBonus[5] = 27;
        launchRefFastStartBonus[6] = 33;
        launchRefFastStartBonus[7] = 99;
        launchRefFastStartBonus[8] = 165;
        launchRefFastStartBonus[9] = 231;
        launchRefFastStartBonus[10] = 297;
        launchRefFastStartBonus[11] = 333;
        launchRefFastStartBonus[12] = 999;
        launchRefFastStartBonus[13] = 1665;
        launchRefFastStartBonus[14] = 2331;
        launchRefFastStartBonus[15] = 2997;
        launchRefFastStartBonus[16] = 3333;
        launchRefFastStartBonus[17] = 9999;
        launchRefFastStartBonus[18] = 16665;
        launchRefFastStartBonus[19] = 23331;
        launchRefFastStartBonus[20] = 29997;
        launchRefFastStartBonus[21] = 33333;
        launchRefFastStartBonus[22] = 99999;
        launchRefFastStartBonus[23] = 166665;
        launchRefFastStartBonus[24] = 233331;
        launchRefFastStartBonus[25] = 299997;
        launchRefFastStartBonus[26] = 333333;
        launchRefFastStartBonus[27] = 999999;
        launchRefFastStartBonus[28] = 1666665;
        launchRefFastStartBonus[29] = 2333331;
        launchRefFastStartBonus[30] = 2999997;
        launchRefFastStartBonus[31] = 3333333;
        launchRefFastStartBonus[32] = 9999999;
        launchRefFastStartBonus[33] = 16666665;
        launchRefFastStartBonus[34] = 23333331;
        launchRefFastStartBonus[35] = 29999997;
        launchRefFastStartBonus[36] = 33333333;

        //Set whitelist costs to 0
        for(uint8 i=1; i<=TOTAL_LEVELS; i++) {
            levelPrice[i] = 0;
            refFastStartBonus[i] = 0;
        }

        owner = ownerAddress;
        HEALVault = HEALVaultAddress;
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0)
        });
        
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
                
        for (uint8 i = 1; i <= TOTAL_LEVELS; i++) {
            users[ownerAddress].levelsActive[i] = true;
        }
        
        userIds[1] = ownerAddress;
    }
    
    fallback() external {
        if(msg.data.length == 0) {
            return activation(msg.sender, owner);
        }
        
        activation(msg.sender, bytesToAddress(msg.data));
    }

    function newActivation(address referrerAddress) external payable {
        activation(msg.sender, referrerAddress);
    }
    
    function purchaseNewLevel(uint8 level) external payable {

        //Pre entry whitelist
        if(!programLaunched) {
            require(whitelistAddresses[msg.sender] >= level, "You are not whitelisted");
        }

        require(isUserExists(msg.sender), "Register first.");
        require(msg.value == getPurchaseCost(level), "Invalid Purchase Cost");
        require(level > 1 && level <= TOTAL_LEVELS, "Invalid Level");
        require(users[msg.sender].levelsActive[level-1], "Purchase prev. level first");
        require(!users[msg.sender].levelsActive[level], "Level already active"); 

        address activeReferrer = findAvailableReferrer(msg.sender, level);
        
        users[msg.sender].levelsActive[level] = true;
        updateMatrixReferrer(msg.sender, activeReferrer, level);
        
        emit UpgradeLevel(users[msg.sender].id, users[users[msg.sender].referrer].id, users[activeReferrer].id, level);

        //Send Referral Fast Start bonus to qualified referrer.
        if(refFastStartBonus[level] > 0) {
            
            address bonusReceiver = decideBonusReceiver(msg.sender, level);

            //After return record the address in bonus received of bonus receiver
            users[bonusReceiver].matrix[level].bonusesReceieved.push(msg.sender);
            
            if (!address(uint160(bonusReceiver)).send(convertDollarToCrypto(refFastStartBonus[level]))) {
                return address(uint160(bonusReceiver)).transfer(convertDollarToCrypto(refFastStartBonus[level]));
            }
            emit RecordUserBonus(users[msg.sender].id, users[bonusReceiver].id, level);
            
        }
    }
    
    function activation(address userAddress, address referrerAddress) private {

        //Pre entry whitelist
        if(!programLaunched) {
            require(whitelistAddresses[msg.sender] > 0, "You are not whitelisted");
        }

        require(msg.value == getPurchaseCost(1), "Invalid registration cost");
        require(!isUserExists(userAddress), "Already registered");
        require(isUserExists(referrerAddress), "Referrer doesnt exist");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        users[userAddress].levelsActive[1] = true;
        
        userIds[lastUserId] = userAddress;
        lastUserId++;
        
        users[referrerAddress].partnersCount++;
        
        address activeReferrer = findAvailableReferrer(userAddress, 1);
        updateMatrixReferrer(userAddress, activeReferrer, 1);
        
        emit RegisterUser(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id, users[activeReferrer].id);

        //Send Referral Fash Start bonus to qualified referrer.
        if(refFastStartBonus[1] > 0) {

            address bonusReceiver = decideBonusReceiver(userAddress, 1);

            //After return record the address in bonus received of bonus receiver
            users[bonusReceiver].matrix[1].bonusesReceieved.push(userAddress);

            if (!address(uint160(bonusReceiver)).send(convertDollarToCrypto(refFastStartBonus[1]))) {
                return address(uint160(bonusReceiver)).transfer(convertDollarToCrypto(refFastStartBonus[1]));
            }
            emit RecordUserBonus(users[msg.sender].id, users[bonusReceiver].id, 1);

        }
        
    }

    function updateMatrixReferrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].levelsActive[level], "500. Referrer level is inactive");
        
        if (users[referrerAddress].matrix[level].firstLevelReferrals.length < 2) {
            users[referrerAddress].matrix[level].firstLevelReferrals.push(userAddress);
            emit RecordUserPlace(users[userAddress].id, users[referrerAddress].id, level, uint8(users[referrerAddress].matrix[level].firstLevelReferrals.length));
            
            //set current level
            users[userAddress].matrix[level].currentReferrer = referrerAddress;

            if (referrerAddress == owner) {
                return sendDividends(referrerAddress, level);
            }
            
            address ref = users[referrerAddress].matrix[level].currentReferrer;            
            users[ref].matrix[level].secondLevelReferrals.push(userAddress); 
            
            uint len = users[ref].matrix[level].firstLevelReferrals.length;
            
            if ((len == 2) && 
                (users[ref].matrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].matrix[level].firstLevelReferrals.length == 1) {
                    emit RecordUserPlace(users[userAddress].id, users[ref].id, level, 5);
                } else {
                    emit RecordUserPlace(users[userAddress].id, users[ref].id, level, 6);
                }
            }  else if ((len == 1 || len == 2) &&
                    users[ref].matrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].matrix[level].firstLevelReferrals.length == 1) {
                    emit RecordUserPlace(users[userAddress].id, users[ref].id, level, 3);
                } else {
                    emit RecordUserPlace(users[userAddress].id, users[ref].id, level, 4);
                }
            } else if (len == 2 && users[ref].matrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].matrix[level].firstLevelReferrals.length == 1) {
                    emit RecordUserPlace(users[userAddress].id, users[ref].id, level, 5);
                } else {
                    emit RecordUserPlace(users[userAddress].id, users[ref].id, level, 6);
                }
            }

            return updateMatrixReferrerSecondLevel(userAddress, ref, level);
        }
        
        users[referrerAddress].matrix[level].secondLevelReferrals.push(userAddress);

        if (users[referrerAddress].matrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].matrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].matrix[level].closedPart)) {

                UpdateMatrix(userAddress, referrerAddress, level, true);
                return updateMatrixReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].matrix[level].firstLevelReferrals[0] == 
                users[referrerAddress].matrix[level].closedPart) {
                UpdateMatrix(userAddress, referrerAddress, level, true);
                return updateMatrixReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                UpdateMatrix(userAddress, referrerAddress, level, false);
                return updateMatrixReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (users[referrerAddress].matrix[level].firstLevelReferrals[1] == userAddress) {
            UpdateMatrix(userAddress, referrerAddress, level, false);
            return updateMatrixReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].matrix[level].firstLevelReferrals[0] == userAddress) {
            UpdateMatrix(userAddress, referrerAddress, level, true);
            return updateMatrixReferrerSecondLevel(userAddress, referrerAddress, level);
        }
        
        if (users[users[referrerAddress].matrix[level].firstLevelReferrals[0]].matrix[level].firstLevelReferrals.length <= 
            users[users[referrerAddress].matrix[level].firstLevelReferrals[1]].matrix[level].firstLevelReferrals.length) {
            UpdateMatrix(userAddress, referrerAddress, level, false);
        } else {
            UpdateMatrix(userAddress, referrerAddress, level, true);
        }
        
        updateMatrixReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function UpdateMatrix(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            users[users[referrerAddress].matrix[level].firstLevelReferrals[0]].matrix[level].firstLevelReferrals.push(userAddress);
            emit RecordUserPlace(users[userAddress].id, users[users[referrerAddress].matrix[level].firstLevelReferrals[0]].id, level, uint8(users[users[referrerAddress].matrix[level].firstLevelReferrals[0]].matrix[level].firstLevelReferrals.length));
            emit RecordUserPlace(users[userAddress].id, users[referrerAddress].id, level, 2 + uint8(users[users[referrerAddress].matrix[level].firstLevelReferrals[0]].matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].matrix[level].currentReferrer = users[referrerAddress].matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].matrix[level].firstLevelReferrals[1]].matrix[level].firstLevelReferrals.push(userAddress);
            emit RecordUserPlace(users[userAddress].id, users[users[referrerAddress].matrix[level].firstLevelReferrals[1]].id, level, uint8(users[users[referrerAddress].matrix[level].firstLevelReferrals[1]].matrix[level].firstLevelReferrals.length));
            emit RecordUserPlace(users[userAddress].id, users[referrerAddress].id, level, 4 + uint8(users[users[referrerAddress].matrix[level].firstLevelReferrals[1]].matrix[level].firstLevelReferrals.length));
            //set current level
            users[userAddress].matrix[level].currentReferrer = users[referrerAddress].matrix[level].firstLevelReferrals[1];
        }
    }
    
    function updateMatrixReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].matrix[level].secondLevelReferrals.length < 4) {
            return sendDividends(referrerAddress, level);
        }
        
        address[] memory referrerFirstLevelRefs = users[users[referrerAddress].matrix[level].currentReferrer].matrix[level].firstLevelReferrals;
        
        if (referrerFirstLevelRefs.length == 2) {
            if (referrerFirstLevelRefs[0] == referrerAddress ||
                referrerFirstLevelRefs[1] == referrerAddress) {
                users[users[referrerAddress].matrix[level].currentReferrer].matrix[level].closedPart = referrerAddress;
            } else if (referrerFirstLevelRefs.length == 1) {
                if (referrerFirstLevelRefs[0] == referrerAddress) {
                    users[users[referrerAddress].matrix[level].currentReferrer].matrix[level].closedPart = referrerAddress;
                }
            }
        }
        
        users[referrerAddress].matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].matrix[level].closedPart = address(0);

        users[referrerAddress].matrix[level].reinvestCount++;
        
        if (referrerAddress != owner) {
            address freeReferrerAddress = findAvailableReferrer(referrerAddress, level);

            emit RecycleUser(users[referrerAddress].id, users[freeReferrerAddress].id, users[userAddress].id, level, users[referrerAddress].matrix[level].reinvestCount);
            updateMatrixReferrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit RecycleUser(users[owner].id, 0, users[userAddress].id, level, users[owner].matrix[level].reinvestCount);
            sendDividends(owner, level);
        }
    }
    
    function findAvailableReferrer(address userAddress, uint8 level) public view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].levelsActive[level]) {
                return users[userAddress].referrer;
            }
            
            userAddress = users[userAddress].referrer;
        }
    }
    
    //New bonus algo
    function decideBonusReceiver(address userAddress, uint8 level) private returns(address) {

        //Get active sponsor
        address activeSponsor = findAvailableReferrer(userAddress, level);
    
        //Check bonusReceived length
        //If less, return activesponsor
        if(users[activeSponsor].matrix[level].bonusesReceieved.length < 5) {
            return activeSponsor;
        } else {
            users[activeSponsor].matrix[level].bonusesReceieved = new address[](0);
            //If more, recurse
            return decideBonusReceiver(activeSponsor, level);
        }

    }

    function userslevelsActive(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].levelsActive[level];
    }
    
    function usersmatrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, address, address[] memory) {
        return (users[userAddress].matrix[level].currentReferrer,
                users[userAddress].matrix[level].firstLevelReferrals,
                users[userAddress].matrix[level].secondLevelReferrals,
                users[userAddress].matrix[level].closedPart,
                users[userAddress].matrix[level].bonusesReceieved);
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function sendDividends(address userAddress, uint8 level) private {

        //10% of payment to HEALVault
        if(convertDollarToCrypto(levelPrice[level])*10/100 > 0) {
            if (!address(uint160(HEALVault)).send(convertDollarToCrypto(levelPrice[level])*10/100)) {
                return address(uint160(HEALVault)).transfer(convertDollarToCrypto(levelPrice[level])*10/100);
            }
        }
        
        //90% of payment to matrix
        if(convertDollarToCrypto(levelPrice[level])*90/100 > 0) {
            if (!address(uint160(userAddress)).send(convertDollarToCrypto(levelPrice[level])*90/100)) {
                return address(uint160(userAddress)).transfer(convertDollarToCrypto(levelPrice[level])*90/100);
            }
        }

    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    //Get Crypto Amount
    function convertDollarToCrypto(uint256 dollarVal) public view returns(uint256) {
       return ((dollarVal*100000/USD_RATE)  * 1 ether)/100000;
    }

    function getPurchaseCost(uint8 level) public view returns(uint) {
        return convertDollarToCrypto(levelPrice[level]+refFastStartBonus[level]);
    }

    //Dynamically adjust USD value
    function adjustUSD(uint256 rate) external {
        require(admins[msg.sender] || mods[msg.sender], "Access Denied");
        USD_RATE = rate;
        emit updateUSDRate(USD_RATE);
    }
    
    //Enable/Disable Admin
    function setAdmin(address adminAddress, bool status) external {
        require(admins[msg.sender], "Access Denied");
        admins[adminAddress] = status;
    }

    //Change vault Address
    function setHEALVault(address _HEALVault) external {
        require(admins[msg.sender], "Access Denied");
        HEALVault = _HEALVault;
    }
    
    //Enable/Disable Admin
    function setMods(address modAddress, bool status) external {
        require(admins[msg.sender], "Access Denied");
        mods[modAddress] = status;
    }

    //Change level price
    function setLevelPrice(uint8 level, uint amount) external {
        require(admins[msg.sender], "Access Denied");
        levelPrice[level] = amount;
    }

    //Change Bonus level price
    function setRefStartBonus(uint8 level, uint amount) external {
        require(admins[msg.sender], "Access Denied");
        refFastStartBonus[level] = amount;
    }
    
    //Withdraw mistakenly sent BNB from contract
    function withdrawContractBalance() external payable {
        require(admins[msg.sender], "Access Denied");
        if(!address(uint160(msg.sender)).send(address(this).balance)) {
            address(uint160(msg.sender)).transfer(address(this).balance);
        }
        return;
    }
    
    //Set whitelistAddresses
    function setWhitelistAddress(address[] calldata addresses, uint[] calldata maxLevel) external {
        require(admins[msg.sender], "Access Denied");
        require(addresses.length == maxLevel.length, "Length Mismatch");
        for(uint256 i = 0; i < addresses.length; i++) {
            whitelistAddresses[addresses[i]] = maxLevel[i];
        }
    }
    
    function launchProgram() external {
        require(admins[msg.sender], "Access Denied");

        //Set launch costs from "launch"
        for(uint8 i=1; i<=TOTAL_LEVELS; i++) {
            levelPrice[i] = launchLevelPrice[i];
            refFastStartBonus[i] = launchRefFastStartBonus[i];
        }

        programLaunched = true;
    }

    //Generic Transfer Funds Module
    function genericTransferFunds(uint256 mode, uint256[] memory payToIds, uint256[] memory amounts) public payable {
        require(payToIds.length == amounts.length, "Length Mismatch");

        for(uint256 i=0; i<payToIds.length; i++) {
            if (!address(uint160(idToAddress[payToIds[i]])).send(convertDollarToCrypto(amounts[i]))) {
                address(uint160(idToAddress[payToIds[i]])).transfer(convertDollarToCrypto(amounts[i]));
            }
        }
        
        emit genericFundTransfer(mode);
    }

}