/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {

    address internal owner;

    modifier onlyOwner () {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address to) external onlyOwner {
        require(to != owner, "owner already");
        owner = to;
    }

    function getOwner() external view returns (address res) {
        res = owner;
    }
}

contract Lockable {
    uint8 internal locked = 0;
    modifier lock {
        require(0 == locked, "locked");
        locked = 1;
        _;
        locked = 0;
    }
}

contract C9Locker is Lockable, Ownable {

    uint256 internal constant vest_time_diff = 86400; //one day
    uint256 internal constant lock_time_length = 31536000; //one year
    uint256 internal constant vest_percent_every_time_diff = 5; //0.5%

    address internal c9Address;
    uint256 internal totalAmount;
    uint256 internal lockTime;
    uint256 internal vestedAmount;
    bool internal lockInit;

    uint256 internal vestTimeDiff;
    uint256 internal lockTimeLength;
    uint256 internal vestPercentEveryTimeDiff;

    mapping(uint256 => bool) mapVested;

    constructor(address _c9Address) {
        c9Address = _c9Address;
        vestTimeDiff = 120; //vest_time_diff;
        lockTimeLength = 300; //lock_time_length;
        vestPercentEveryTimeDiff = 100; //vest_percent_every_time_diff;
    }

    function lockC9(uint256 amount) external lock onlyOwner {
        require(!lockInit, "initialized");
        require(IERC20(c9Address).balanceOf(msg.sender) >= amount, "insufficient balance");
        require(IERC20(c9Address).allowance(msg.sender, address(this)) >= amount, "amount not approval");
        totalAmount = amount;
        lockTime = block.timestamp;
        lockInit = true;
        require(IERC20(c9Address).transferFrom(msg.sender, address(this), amount), "transferFrom err");
    }

    function vestC9(address to) external lock onlyOwner {
        uint256 vestableAmount = _canVestAmount();
        require(vestableAmount > 0, "no vestable amount");
        require(IERC20(c9Address).balanceOf(address(this)) >= vestableAmount, "insufficient fund");
        vestedAmount += vestableAmount;
        uint256 passedTimeDiff = ((block.timestamp - lockTime - lockTimeLength) / vestTimeDiff) + 1;
        for(uint256 i = passedTimeDiff; i > 0; --i) {
            if(mapVested[i]) {
                break;
            }
            mapVested[i] = true;
        }
        require(IERC20(c9Address).transfer(to, vestableAmount), "transfer err");
    }

    function _canVestAmount() internal view returns (uint256 res) {
        if(block.timestamp > lockTime + lockTimeLength) {
            uint256 passedTimeDiff = ((block.timestamp - lockTime - lockTimeLength) / vestTimeDiff) + 1;
            if(passedTimeDiff > 1000 / vestPercentEveryTimeDiff) {
                passedTimeDiff = 1000 / vestPercentEveryTimeDiff;
            }
            uint256 vestTimeAmount = passedTimeDiff * totalAmount * vestPercentEveryTimeDiff / 1000;
            res = vestTimeAmount - vestedAmount;
        }
    }

    function getLockTime() external view returns (uint256 res) {
        res = lockTime;
    }

    function getTatalLockAmount() external view returns (uint256 res) {
        res = totalAmount;
    }

    function getVestedAmount() external view returns (uint256 res) {
        res = vestedAmount;
    }

    function canVestAmount() external view returns (uint256 res) {
        res = _canVestAmount();
    }

    function skim(address to) external lock onlyOwner {
        uint256 totalBalance = IERC20(c9Address).balanceOf(address(this));
        uint256 vestBalance = totalAmount - vestedAmount;
        if(totalBalance > vestBalance) {
            require(IERC20(c9Address).transfer(to, totalBalance-vestBalance), "skim err");
        } else {
            revert("no C9 to skim");
        }
    }

    function vestTimes() external view returns (uint256 res) {
        res = 1000 / vestPercentEveryTimeDiff;
    }

    function vestClipInfo(uint256 index) external view returns (
        bool res,
        uint256 vestTime,
        uint256 amount,
        bool vested
    ) {
        if(index > 0 && index <= 1000/vestPercentEveryTimeDiff) {
            res = true;
            amount = totalAmount * vestPercentEveryTimeDiff / 1000;
            vestTime = lockTime + lockTimeLength + (index-1)*vestTimeDiff;
            vested = mapVested[index];
        }
    }
}