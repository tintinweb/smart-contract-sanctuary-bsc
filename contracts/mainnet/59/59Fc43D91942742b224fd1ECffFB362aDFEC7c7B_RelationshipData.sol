// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./SystemAuth.sol";
import "./SystemSetting.sol";
import "./ModuleBase.sol";

contract RelationshipData is SafeMath, ModuleBase {
    //data struct of children
    struct Children {
        address walletAddr;
        uint256 time;
        bool exists;
    }

    //data struct of Children Number
    struct ChildrenNumber {
        uint256 number;
        bool exists;
    }

    struct SharedProfit {
        uint256 totalAmount;
        uint256 claimedAmount;
        bool exists;
    }

    //container of my single parent
    //key: child => parent
    mapping(address => address) mapParent;
    //container of all relationship that specified an address was developed or not
    mapping(address => bool) mapDeveloped;

    //container of my Children, only contain one layer, key(my address) => (key(index) => children)
    mapping(address => mapping(uint256 => Children)) mapChildren;
    //container of numbers of my children, number = key(index) of children
    mapping(address => ChildrenNumber) mapChildrenNumber;

    mapping(address => SharedProfit) mapSharedProfit;

    constructor(address _auth, address _mgr) ModuleBase(_auth, _mgr) {
    }

    function getParent(address child) external view returns (bool res, address parent) {
        if (mapParent[child] != address(0)) {
            res = true;
            parent = mapParent[child];
        }
    }

    function isCustomerDeveloped(address customer) external view returns (bool res) {
        res = mapDeveloped[customer];
    }

    function isHaveChildren(address addr) external view returns (bool res) {
        res = mapChildrenNumber[addr].exists;
    }

    function getChildrenNumber(address addr) external view returns (uint256 res) {
        res = mapChildrenNumber[addr].number;
    }

    function increaseChildrenNumber(address addr) external onlyCaller {
        ChildrenNumber storage childrenNumber = mapChildrenNumber[
            addr
        ];
        childrenNumber.number ++;
    }

    function newChildNumber(address addr) external onlyCaller {
        mapChildrenNumber[addr] = ChildrenNumber(1, true);
    }

    function addChildToNumberData(address parent, address child, uint256 number) external onlyCaller {
        mapChildren[parent][number] = Children(
            child,
            block.timestamp,
            true
        );
    }

    function makeAChild(address parent, address child) external onlyCaller {
        mapParent[child] = parent;
    }

    function markCustomerAsDeveloped(address customer) external onlyCaller {
        mapDeveloped[customer] = true;
    }

    function getChildByIndex(address parent, uint256 index)
        external
        view
        returns (
            bool res,
            address walletAddr,
            uint256 time
        )
    {
        if (mapChildren[parent][index].exists) {
            walletAddr = mapChildren[parent][index].walletAddr;
            time = mapChildren[parent][index].time;
            res = true;
        }
    }

    function getUpstreamParent(address addr, uint256 layer)
        external
        view
        returns (bool res, address parent)
    {
        (res, parent) = _getUpstreamParent(addr, layer);
    }

    function _getUpstreamParent(address addr, uint256 layer)
        internal
        view
        returns (bool res, address parent)
    {
        (, , uint256 _sharedLayer) = SystemSetting(moduleMgr.getModuleSystemSetting()).getSharedSetting(0);

        uint256 sharedLayer = _sharedLayer;

        if (layer <= sharedLayer && layer > 0) {
            address pTemp = mapParent[addr];
            uint256 i = 1;
            while (pTemp != address(0) && i < layer) {
                pTemp = mapParent[pTemp];
                ++i;
            }

            res = pTemp == address(0) ? false : true;
            parent = pTemp;
        }
    }

    function getSharedProfit(address account)
        external
        view
        returns (
            bool res,
            uint256 totalAmount,
            uint256 claimedAmount
        )
    {
        (res, totalAmount, claimedAmount) = _getSharedProfit(account);
    }

    function _getSharedProfit(address account)
        internal
        view
        returns (
            bool res,
            uint256 totalAmount,
            uint256 claimedAmount
        )
    {
        if (mapSharedProfit[account].exists) {
            res = true;
            totalAmount = mapSharedProfit[account].totalAmount;
            claimedAmount = mapSharedProfit[account].claimedAmount;
        }
    }

    function isSharedProfitExists(address addr) external view returns (bool res) {
        res = mapSharedProfit[addr].exists;
    }

    function increaseSharedProfitAmount(address addr, uint256 amount) external onlyCaller {
        SharedProfit storage sp = mapSharedProfit[addr];
        sp.totalAmount = add(sp.totalAmount, amount);
    }

    function newSharedProfitAmount(address addr, uint256 amount) external onlyCaller {
        mapSharedProfit[addr] = SharedProfit(amount, 0, true );
    }

    function increaseClaimedSharedProfit(address account, uint256 amount) external onlyCaller {
        SharedProfit storage sp = mapSharedProfit[account];
        require(sp.totalAmount >= add(sp.claimedAmount, amount), "claimed overflow totalAmount");
        sp.claimedAmount = add(sp.claimedAmount, amount);
    }

    function useSharedProfit(address account, uint256 amount) external onlyCaller {
        SharedProfit storage sp = mapSharedProfit[account];
        sp.claimedAmount = add(sp.claimedAmount, amount);
    }
}