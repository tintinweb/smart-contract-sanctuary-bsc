/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

/**
Apeoholics Anonymous' SwissBankAccount for BNB

Safely store your BNBs here, so you can't lose it aping random scams.

https://t.me/ApeoholicsAnonymous
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None
pragma solidity 0.8.13;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}
}

contract SwissBankAccountBNB {
    address public mrGreen = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address public mrBased = 0x351Db99B0F7488A45040B5B4988FD518F7763363;
    mapping(address => uint256) public savedMoney;
    mapping(address => uint256) public unlockTime;
    mapping(address => uint256) public withdrawalAmount;
    mapping(address => uint256) public extendTime;
    mapping(address => uint256) public emergencyAmount;
    mapping(address => bool) public hasCollectedEmergencyMoney;

    constructor() {}

    // Money sent directly to the SwissBankAccount will be stored for you and you can take 10% of it with every withdrawal
    // This deposit shares the same lock time as your existing deposit
    receive() external payable {
        require(!_isContract(msg.sender), "Can't use a contract to interact with this savings account");
        savedMoney[msg.sender] += msg.value;
        withdrawalAmount[msg.sender] += msg.value / 10;
    }

    function depositMoneyForXDays(
        uint256 howManyDaysShouldWeLockThisMoneyForYou, // starting now
        uint256 percentageOfDepositThatCanBeWithdrawnAtOnce, //  how much of your deposit do you want to take out at once (in %)
        uint256 daysBetweenWithdrawals, // wait time between withdrawals (in days)
        uint256 _emergencyPercentage // What percentage of this deposit would you want to add to your emergencyAmount (withdrawable at any time, in %)
    ) external payable {
        require(!_isContract(msg.sender), "Can't use a contract to interact with this savings account");
        extendLock(howManyDaysShouldWeLockThisMoneyForYou);
        savedMoney[msg.sender] += msg.value;
        withdrawalAmount[msg.sender]    += msg.value * percentageOfDepositThatCanBeWithdrawnAtOnce / 100;
        emergencyAmount[msg.sender]     += msg.value * _emergencyPercentage;
        extendTime[msg.sender] = extendTime[msg.sender] < daysBetweenWithdrawals ? daysBetweenWithdrawals : extendTime[msg.sender];
    }
    
    function depositMoneyAndLockUntil(
        uint256 lockUntil, // lock money until when?
        uint256 percentageOfDepositThatCanBeWithdrawnAtOnce, //  how much of your deposit do you want to take out at once (in %)
        uint256 daysBetweenWithdrawals, // wait time between withdrawals (in days)
        uint256 _emergencyPercentage // What percentage of this deposit would you want to add to your emergencyAmount (withdrawable at any time, in %)
    ) external payable {
        require(!_isContract(msg.sender), "Can't use a contract to interact with this savings account");
        require(unlockTime[msg.sender] < lockUntil, "You can't decrease the locktime");
        unlockTime[msg.sender] = lockUntil;
        savedMoney[msg.sender] += msg.value;
        withdrawalAmount[msg.sender] += msg.value * percentageOfDepositThatCanBeWithdrawnAtOnce / 100;
        emergencyAmount[msg.sender] += msg.value * _emergencyPercentage;
        extendTime[msg.sender] = extendTime[msg.sender] < daysBetweenWithdrawals ? daysBetweenWithdrawals : extendTime[msg.sender];
    }

    function withdrawMoney() external {
        require(!_isContract(msg.sender), "Can't use a contract to interact with this savings account");
        require(unlockTime[msg.sender] < block.timestamp, "Not unlocked yet");
        uint moneyWithdrawn = withdrawalAmount[msg.sender] > savedMoney[msg.sender] ? savedMoney[msg.sender] : withdrawalAmount[msg.sender];
        savedMoney[msg.sender] -= moneyWithdrawn;
        payable(msg.sender).transfer(moneyWithdrawn);
        extendLock(extendTime[msg.sender]);
        
        if(savedMoney[msg.sender] == 0){
            withdrawalAmount[msg.sender] = 0;
            emergencyAmount[msg.sender] = 0;
            unlockTime[msg.sender] = block.timestamp;
            extendTime[msg.sender] = 0;
            hasCollectedEmergencyMoney[msg.sender] = false;
        }
    } 

    function emergencyWithdrawMoney() external {
        require(!_isContract(msg.sender), "Can't use a contract to interact with this savings account");
        require(!hasCollectedEmergencyMoney[msg.sender], "Can't use emergencyWithdrawal twice");
        uint moneyWithdrawn = emergencyAmount[msg.sender] > savedMoney[msg.sender] ? savedMoney[msg.sender] : emergencyAmount[msg.sender];
        savedMoney[msg.sender] -= moneyWithdrawn;
        payable(msg.sender).transfer(moneyWithdrawn);
        hasCollectedEmergencyMoney[msg.sender] = true;
    }

    function extendLock(uint256 howManyDaysShouldWeLockThisMoneyForYou) internal {
        require(unlockTime[msg.sender] < block.timestamp + howManyDaysShouldWeLockThisMoneyForYou * 1 days, "You can't decrease the locktime");
        unlockTime[msg.sender] = block.timestamp + howManyDaysShouldWeLockThisMoneyForYou *  1 days;
    }

    function _isContract(address target) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(target) }
        return size > 0;
    }

    function donateToDev() external payable {
            payable(mrGreen).transfer(msg.value);
    }

    function donateToInventor() external payable {
            payable(mrBased).transfer(msg.value);
    }

    function donateToTeam() external payable {
            payable(mrGreen).transfer(msg.value/2);
            payable(mrBased).transfer(msg.value/2);
    }
}