/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
}

contract GotsKeep is Ownable {
    using SafeMath for uint256;

    IBEP20 public gotsToken = IBEP20(0x750fc4A5A16678B3303a51fC1A511C8D5f89Fc86);
    uint256 public keepTotal = 0;
    uint256 public keepUser = 0;
    mapping(address => KeepData) public keepMap;
    mapping(address => KeepRecord[]) public keepRecordMap;
    uint256 timeLimit = 3600;
    uint256 keepRate = 95;
    uint256 keepRateJS = 100000;
   
    struct KeepData {
        bool isConf;
        uint256 myAmount;
        uint256 myWaitProfit;
        uint256 myTakeTotal;
        uint256 myTakeTime;
    }

    struct KeepRecord {
        uint256 takeAmount;
        uint256 takeTime;
    }

    function joinKeep(uint256 keepAmount) public {
        require(keepAmount > 0,"params error");
        keepTotal = keepTotal + keepAmount;
        gotsToken.transferFrom(address(msg.sender),address(this),keepAmount);
        if(keepMap[msg.sender].isConf){
            uint256 newProfitAmount = getKeepNewProfit(msg.sender);
            keepMap[msg.sender].myWaitProfit = keepMap[msg.sender].myWaitProfit + newProfitAmount;
            keepMap[msg.sender].myTakeTime = block.timestamp;
            keepMap[msg.sender].myAmount = keepMap[msg.sender].myAmount + keepAmount;
        }else{
            keepUser = keepUser + 1;
            KeepData memory keepData = KeepData({
                isConf:true,
                myAmount:keepAmount,
                myWaitProfit:0,
                myTakeTotal:0,
                myTakeTime:block.timestamp
            });
            keepMap[msg.sender] = keepData;
        }
    }

    function releaseKeep() public {
        require(keepMap[msg.sender].isConf && keepMap[msg.sender].myAmount > 0,"has not join");
        uint256 newProfitAmount = getKeepNewProfit(msg.sender);

        keepMap[msg.sender].myWaitProfit = keepMap[msg.sender].myWaitProfit + newProfitAmount;
        keepMap[msg.sender].myTakeTime = block.timestamp;
        gotsToken.transfer(address(msg.sender),keepMap[msg.sender].myAmount);
        keepTotal = keepTotal - keepMap[msg.sender].myAmount;
        keepMap[msg.sender].myAmount = 0;
    }

    function takeKeepProfit() public {
        require(keepMap[msg.sender].isConf,"has not join");
        uint256 newProfitAmount = getKeepNewProfit(msg.sender);
        keepMap[msg.sender].myTakeTime = block.timestamp;
        uint256 nowTakeAmount = keepMap[msg.sender].myWaitProfit + newProfitAmount;
        if(nowTakeAmount > 0){
            keepMap[msg.sender].myTakeTotal = keepMap[msg.sender].myTakeTotal + nowTakeAmount;
            gotsToken.transfer(address(msg.sender),nowTakeAmount);
            KeepRecord memory keepRecord = KeepRecord({takeAmount:nowTakeAmount,takeTime:block.timestamp});
            keepRecordMap[msg.sender].push(keepRecord);
        }
    }

    function getKeepNewProfit(address userAddress) public view returns (uint256) {
        KeepData memory keepData = keepMap[userAddress];
        if(!keepData.isConf || keepData.myAmount <= 0){
            return 0;
        }else{
            uint256 rateTimes = (block.timestamp - keepData.myTakeTime) / timeLimit;
            if(rateTimes>=1){
                uint256 newRate = keepData.myAmount * rateTimes * keepRate / keepRateJS;
                return newRate;
            }else{
                return 0;
            }
        }
    }

    function getUserKeepInfo(address userAddress) public view returns (KeepData memory){
        return keepMap[userAddress];
    }

    function getKeepInfo() public view returns(uint256,uint256){
        return (keepTotal,keepUser);
    }

    function getKeepRecord(address userAddress) public view returns (KeepRecord[] memory){
        return keepRecordMap[userAddress];
    }
}