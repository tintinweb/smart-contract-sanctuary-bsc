/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
   
    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0),"Ownable: new owner is thezeroAddress address");
        _owner = newOwner;
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not beingzeroAddress, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MinerToken is Ownable {
    using SafeMath for uint256;

    uint256 private _daySecond = 86400;
    uint256 private date = 1080;
    uint256 public totalDepositeUSDT;
    uint256 public totalComputPower;
    uint256 public totalMinerAmount;
    uint256 public totalBurnDCTAmount;
    uint256 public totalDepositDCTAmount;
    uint256 public minRewardPower; // 获取收益的最低算力

    address public dct;
    address public usdt;
    address public collectAddress = 0x2618E49B8c049053120659690A33895feA44c49f; // 收U地址

    mapping (address => uint256) private _balance; // 记录用户的算力
    mapping (address => uint256) private _user; // 记录用户的时间

    event Deposit(address indexed sender, uint256 amount);
    event WithdrawLinearRelease(address indexed sender, uint256 amount);
    
    constructor(address _dct, address _usdt) {
        _owner = msg.sender;
        dct = _dct;
        usdt = _usdt;
        totalMinerAmount = 30000000e18;
        minRewardPower = 1;
    }

    // 获取总算力和总质押USDT、总销毁DCT
    function getTotalPowerAndUSDT() external view returns(uint256, uint256, uint256){
        return (totalComputPower, totalDepositeUSDT, totalBurnDCTAmount);
    }

    // 查询每个用户的算力
    function getUserPower(address account) external view returns(uint256){
        return _balance[account];
    }

    // 质押
    function deposit(uint256 dctAmount, uint256 usdtAmount) external {
        address sender = msg.sender;
        require((dctAmount == usdtAmount) && dctAmount > 0);
        uint256 approveAmountUSDT = IERC20(usdt).allowance(sender, address(this));
        uint256 approveAmountDCT = IERC20(dct).allowance(sender, address(this));
        require(approveAmountDCT >= dctAmount && approveAmountUSDT >= usdtAmount, "Insufficient authorized amount");
        IERC20(usdt).transferFrom(sender, collectAddress, usdtAmount);
        IERC20(dct).transferFrom(sender, address(this), dctAmount);

        if (_user[sender] > 0 && block.timestamp > _user[sender]){ // 如果之前质押过，先将之前奖励领取，后面再增加
            withdrawLinearRelease();
        }
        uint256 interval1 = dctAmount.div(1e18) / 100;
        uint256 interval2 = dctAmount.div(1e18) / 1000;
        uint256 computPower = interval1 + interval2*2;
        totalDepositeUSDT += usdtAmount;
        totalBurnDCTAmount += dctAmount;
        totalComputPower += computPower;
        totalDepositDCTAmount = totalDepositDCTAmount.add(approveAmountDCT);
        _user[sender] = block.timestamp;
        _balance[sender] = _balance[sender].add(computPower);
        emit Deposit(sender, computPower);
    }
    
    // 释放
    function withdrawLinearRelease() public {
        address sender = msg.sender;
        uint256 dctBalance = IERC20(dct).balanceOf(address(this));
        require(dctBalance > totalBurnDCTAmount, "balance is not enough");
        dctBalance = dctBalance.sub(totalBurnDCTAmount);
        require(totalComputPower >= minRewardPower, "The minimum computing power is not reached"); // 最小算力限制
        require(block.timestamp > _user[sender], "Collection time is not up");
        uint256 interval = block.timestamp - _user[sender]; // 间隔多少时间（秒）
        uint256 rewardAmount = totalMinerAmount.mul(interval).mul(_balance[sender]).div(totalComputPower).div(date*24).div(_daySecond);
        require(rewardAmount > 0, "No tokens available");
        if (dctBalance < rewardAmount) {
            rewardAmount = dctBalance;
        }
        IERC20(dct).transfer(sender, rewardAmount);
        _user[sender] = block.timestamp;
        emit WithdrawLinearRelease(sender, rewardAmount);
    }

    // 设置释放周期
    function setDate(uint256 date_) external onlyOwner {
        date = date_;
    }

     // 设置能获取收益的最低算力
    function setMinRewardPower(uint256 limit_) external onlyOwner {
        minRewardPower = limit_;
    }

    // 提取dct
    function withdrawDCT() external onlyOwner {
        uint256 balance = IERC20(dct).balanceOf(address(this));
        require(balance > totalBurnDCTAmount, "balance is not enough");
        IERC20(dct).transfer(msg.sender, balance - totalBurnDCTAmount);
    }

    // 查询可领取奖励
    function getRewardAmount(address account) view external  returns(uint256){
        uint256 dctBalance = IERC20(dct).balanceOf(address(this));
        if (dctBalance <= 0 || dctBalance <= totalBurnDCTAmount || totalComputPower < minRewardPower) {
            return 0;
        }
        dctBalance = dctBalance.sub(totalBurnDCTAmount);
        uint256 interval = block.timestamp - _user[account]; // 间隔多少时间（秒）
        uint256 rewardAmount = totalMinerAmount.mul(interval).mul(_balance[account]).div(totalComputPower).div(date*24).div(_daySecond);
        if (dctBalance < rewardAmount) {
            rewardAmount = dctBalance;
        }
        return rewardAmount;
    }
}