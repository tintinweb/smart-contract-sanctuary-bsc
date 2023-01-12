// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ModuleBase.sol";
import "./Lockable.sol";
import "./IERC20.sol";

contract MMTLocker is ModuleBase, Lockable {

    uint256 internal constant vest_time_diff = 86400; //one day
    uint256 internal constant lock_time_length = 31536000; //one year
    uint256 internal constant vest_percent_every_time_diff = 5; //0.5%

    uint256 internal totalAmount;
    uint256 internal lockTime;
    uint256 internal vestedAmount;
    bool internal lockInit;

    uint256 internal vestTimeDiff;
    uint256 internal lockTimeLength;
    uint256 internal vestPercentEveryTimeDiff;

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {
        vestTimeDiff = 120; //vest_time_diff;
        lockTimeLength = 300; //lock_time_length;
        vestPercentEveryTimeDiff = 100; //vest_percent_every_time_diff;
    }

    function lockMMT(uint256 amount) external lock onlyOwner {
        require(!lockInit, "initialized");
        require(IERC20(auth.getFarmToken()).balanceOf(msg.sender) >= amount, "insufficient balance");
        require(IERC20(auth.getFarmToken()).allowance(msg.sender, address(this)) >= amount, "amount not approval");
        totalAmount = amount * 99 / 100; //substract burn tax
        lockTime = block.timestamp;
        lockInit = true;
        require(IERC20(auth.getFarmToken()).transferFrom(msg.sender, address(this), amount), "transferFrom err");
    }

    function vestMMT(address to) external lock onlyOwner {
        uint256 vestableAmount = _canVestAmount();
        require(vestableAmount > 0, "no vestable amount");
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= vestableAmount, "insufficient fund");
        vestedAmount += vestableAmount;
        require(IERC20(auth.getFarmToken()).transfer(to, vestableAmount), "transfer err");
    }

    function _canVestAmount() internal view returns (uint256 res) {
        if(block.timestamp > lockTime + lockTimeLength) {
            uint256 passedTimeDiff = ((block.timestamp - lockTime - lockTimeLength) / vestTimeDiff) + 1;
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
        uint256 totalBalance = IERC20(auth.getFarmToken()).balanceOf(address(this));
        uint256 vestBalance = totalAmount - vestedAmount;
        if(totalBalance > vestBalance) {
            require(IERC20(auth.getFarmToken()).transfer(to, totalBalance-vestBalance), "skim err");
        } else {
            revert("no mmt to skim");
        }
    }
}