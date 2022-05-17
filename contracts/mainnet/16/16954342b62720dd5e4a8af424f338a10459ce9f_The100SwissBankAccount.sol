/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

//TEST CONTRACT, do not deposit!
//TEST CONTRACT, do not deposit!
//TEST CONTRACT, do not deposit!
//TEST CONTRACT, do not deposit!
//TEST CONTRACT, do not deposit!
//TEST CONTRACT, do not deposit!
//TEST CONTRACT, do not deposit!

/*
The100 SwissBankAccount 

Safely store your money here for 100 days, so you can't lose it aping random scams.

Every new deposit renews the lock for 100 days.

This contract is 100% safe and secure, nobody except you can take the money you deposited.

There is however an Emergency Withdrawal option, it allows you to access 10% of your savings at any time, just in case.
The emergency function can only be called once. So only use it in actual emergencies.


https://t.me/The100
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None
pragma solidity 0.8.13;

contract The100SwissBankAccount {
    address public mrGreen = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    mapping(address => uint256) public savedMoney;
    mapping(address => uint256) public unlockTime;
    mapping(address => bool) public hasCollectedEmergencyMoney;
    mapping(address => uint256) public accountNumber;
    uint256 public totalAccounts;
    uint256 private zzzLastAccountUnlocks;
    uint256 private zzzBankWillCloseAt;
    bool private zzzBankHasAnnouncedTermination = false;
    uint256 public lockTime = 1 days;


    constructor() {}

    function WhenWillMyMoneyUnlock() public view returns(string memory) {
        string memory timeLeft = "Your Money is unlocked, you can withdraw at any time";
        if(unlockTime[msg.sender] < block.timestamp) return timeLeft;

        uint256 secondsLeft = unlockTime[msg.sender] - block.timestamp;
        uint256 minutesLeft = secondsLeft / 60;
        uint256 hoursLeft = minutesLeft / 60;
        uint256 daysLeft = hoursLeft / 24;
        secondsLeft -= minutesLeft * 60;
        minutesLeft -= hoursLeft * 60;
        hoursLeft -= daysLeft * 24;

        timeLeft = string(abi.encodePacked(uint2str(daysLeft), " days ", uint2str(hoursLeft), " hours ", uint2str(minutesLeft), " minutes and ",uint2str(secondsLeft), " seconds left until your money unlocks."));

        return timeLeft;
    }


    function isBankOpenForBusinessForTheForseeableFuture() public view returns(string memory) {
        string memory answer = "Yes";

        if(zzzBankHasAnnouncedTermination){
            uint256 secondsLeft = zzzBankWillCloseAt - block.timestamp;
            uint256 minutesLeft = secondsLeft / 60;
            uint256 hoursLeft = minutesLeft / 60;
            uint256 daysLeft = hoursLeft / 24;
            secondsLeft -= minutesLeft * 60;
            minutesLeft -= hoursLeft * 60;
            hoursLeft -= daysLeft * 24;

            answer = string(abi.encodePacked(uint2str(daysLeft), " days ", uint2str(hoursLeft), " hours ", uint2str(minutesLeft), " minutes and ",uint2str(secondsLeft), " seconds left until the bank closes."));
        }
         return answer;
    }

    // Money sent directly to the SwissBankAccount will be saved for you, this is the easiest way to add to your savings, as it doesn't require any interaction with the contract. 
    receive() external payable {
        if(accountNumber[msg.sender] == 0){
            totalAccounts++;
            accountNumber[msg.sender] = totalAccounts;
        }

        require(!_isContract(msg.sender), "Can't use a contract to interact with this savings account");
        unlockTime[msg.sender] = block.timestamp + lockTime;
        zzzLastAccountUnlocks = block.timestamp + lockTime;
        savedMoney[msg.sender] += msg.value;
    }

    // calling this function will allow you to deposit money, it will lock for 100 days.
    function lockMyMoneyFor100Days() external payable {
        if(accountNumber[msg.sender] == 0){
            totalAccounts++;
            accountNumber[msg.sender] = totalAccounts;
        }

        require(!_isContract(msg.sender), "Can't use a contract to interact with this savings account");
        unlockTime[msg.sender] = block.timestamp + lockTime;
        zzzLastAccountUnlocks = block.timestamp + lockTime;
        savedMoney[msg.sender] += msg.value;
    }
    
    // This allows you to withdraw your money after the 100 days have expired.
    // It also resets your emergency withdraw flag, so next time you deposit some money, you can use the emergency withdrawal function once again.
    function withdrawMoney() external {
        require(savedMoney[msg.sender] != 0, "No Balance on your account");
        require(!_isContract(msg.sender), "Can't use a contract to interact with this savings account");
        require(unlockTime[msg.sender] < block.timestamp, "Not unlocked yet");
        savedMoney[msg.sender] = 0;
        payable(msg.sender).transfer(savedMoney[msg.sender]);
        unlockTime[msg.sender] = block.timestamp;
        hasCollectedEmergencyMoney[msg.sender] = false;
    } 

    // This allows you to withdraw 10% of your saved money. You can only use this function once, so use it wisely.
    function emergencyWithdrawal() external {
        require(savedMoney[msg.sender] != 0, "No Balance on your account");
        require(!_isContract(msg.sender), "Can't use a contract to interact with this savings account");
        require(!hasCollectedEmergencyMoney[msg.sender], "Can't use emergencyWithdrawal twice");
        uint moneyWithdrawn = savedMoney[msg.sender] / 10;
        savedMoney[msg.sender] -= moneyWithdrawn;
        payable(msg.sender).transfer(moneyWithdrawn);
        hasCollectedEmergencyMoney[msg.sender] = true;
    }

    // This ensures that no contract can send money here, preventing possible loopholes.
    function _isContract(address target) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(target) }
        return size > 0;
    }

    function donateToDev() external payable {
        payable(mrGreen).transfer(msg.value);
    }

    function zzzRescueStuckMoneyAndCloseThisSwissBankAccount() external {
        // In case the last account has been unlocked more than 100 days ago, this function allows the owner to announce the termination of this contract.
        // When this function is called, a 100 day timer will start. If no deposits happen during that time, the owner can close the bank contract and all the money will be sent to mrGreen's wallet.
        // This function exists to make sure no money gets lost/burned in this contract.
        // Anyone can reset the timer by depositing any amount to this contract.
        // That way it is ensured that the bank can only be closed if none of the accounts have any activity and it can be assumed that any money left doesn't have an owner anymore.
        
        if(!zzzBankHasAnnouncedTermination){
            require(zzzLastAccountUnlocks + lockTime < block.timestamp);
            zzzBankWillCloseAt = block.timestamp + lockTime;
        }

        if(!zzzBankHasAnnouncedTermination && zzzBankWillCloseAt < block.timestamp){
            payable(mrGreen).transfer(address(this).balance);
        }



    }

    function uint2str(uint256 _i) internal pure returns (string memory str){
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }












}