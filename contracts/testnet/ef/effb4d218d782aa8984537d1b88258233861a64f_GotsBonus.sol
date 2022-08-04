/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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

contract GotsBonus is Ownable {
    using SafeMath for uint256;

    IBEP20 public gotsToken = IBEP20(0xF2fc86488735d17BC57D1cDC07309EBCD5DcdB20);
    IBEP20 public usdtToken = IBEP20(0xb5Af8648EfF53FdAA680552Ef564c1F79d321a34);
    
    uint256 public baseGotsAmount = 1000000000 * 10**18;
    uint256 public minUsdt = 5;
    uint256 public minGots = 2500 * 10**18;

    uint256 public bonusNum = 1;
    uint256 public bonusStartTime = 0; // 分红开启时间
    uint256 public bonusEndTime = 0; // 分红结束时间

    mapping(address => uint256) public bonusNumMap;//地址->已领分红期数编号
    mapping(address => BonusRecord[]) public bonusRecordMap;
    
    struct BonusRecord {
        uint256 bonusNum;
        uint256 takeTime;
        uint256 takeAmount;
    }

    function takeBonus() public {
        require(bonusNumMap[msg.sender] != bonusNum,"has taked");
        uint256 poolUsdtBalance = usdtToken.balanceOf(address(this));
        uint256 myGotsBalance = gotsToken.balanceOf(msg.sender);
        require(poolUsdtBalance > 0,"Pool is empty");
        require(myGotsBalance >= minGots,"Insufficient GOTS balance");
        uint256 usdtAmount = 0;
        if(myGotsBalance >= baseGotsAmount){
            usdtAmount = poolUsdtBalance;
        }else{
            usdtAmount = poolUsdtBalance * myGotsBalance/baseGotsAmount;
        }
        require(usdtAmount >= minUsdt,"USDT dividend is less than the minimum amount");
        bonusNumMap[msg.sender] = bonusNum;
        usdtToken.transfer(address(msg.sender),usdtAmount);
        BonusRecord memory bonusRecord = BonusRecord({bonusNum:bonusNum,takeTime:block.timestamp,takeAmount:usdtAmount});
        bonusRecordMap[msg.sender].push(bonusRecord);
    }

    function setBonusParam(uint256 _bonusNum,uint256 _bonusStartTime,uint256 _bonusEndTime) public {
        bonusNum = _bonusNum;
        bonusStartTime = _bonusStartTime;
        bonusEndTime = _bonusEndTime;
    }

    function setBaseParam(uint256 _baseGotsAmount,uint256 _minUsdt,uint256 _minGots) public {
        baseGotsAmount = _baseGotsAmount;
        minUsdt = _minUsdt;
        minGots = _minGots;
    }

    function getUserBonusNum(address userAddress) public view returns (uint256){
        return bonusNumMap[userAddress];
    }

    function getBonusParam() public view returns (uint256,uint256,uint256,uint256,uint256,uint256) {
        return (bonusNum,bonusStartTime,bonusEndTime,baseGotsAmount,minUsdt,minGots);
    }

    function getBonusRecord(address userAddress) public view returns (BonusRecord[] memory){
        return bonusRecordMap[userAddress];
    }
}