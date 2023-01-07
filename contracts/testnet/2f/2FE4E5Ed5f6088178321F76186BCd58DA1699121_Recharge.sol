// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Lockable.sol";
import "./ModuleBase.sol";
import "./DepositWallet.sol";

contract Recharge is ModuleBase, Lockable {

    struct RechargeData {
        address account;
        uint256 amount;
        uint256 time;
        bool exists;
    }

    mapping(uint256 => RechargeData) mapRecharge;
    uint256 private totalLength;

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {
    }

    function rechargeMMT(uint256 amount) external lock {
        require(amount > 0, "0 recharge err");
        require(IERC20(auth.getFarmToken()).balanceOf(msg.sender) >= amount, "insufficient balance");
        require(IERC20(auth.getFarmToken()).allowance(msg.sender, address(this)) >= amount, "approval amount err");

        mapRecharge[++totalLength] = RechargeData(msg.sender, amount, block.timestamp, true);
        require(IERC20(auth.getFarmToken()).transferFrom(msg.sender, moduleMgr.getDepositWallet(), amount), "recharge err");
    }

    function getRechargeLength() external view returns (uint256 res) {
        res = totalLength;
    }

    function getRechargeData(uint256 index) external view returns (
        bool res,
        address account,
        uint256 amount,
        uint256 time
    ) {
        if(mapRecharge[index].exists) {
            res = true;
            account = mapRecharge[index].account;
            amount = mapRecharge[index].amount;
            time = mapRecharge[index].time;
        }
    }
}