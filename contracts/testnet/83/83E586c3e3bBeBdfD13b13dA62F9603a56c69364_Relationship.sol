// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ModuleBase.sol";
import "./Lockable.sol";
import "./ERC20.sol";
import "./SystemAuth.sol";
import "./SystemSetting.sol";
import "./RelationshipData.sol";

contract Relationship is SafeMath, Lockable, ModuleBase {

    event profitSharedEvent(
        address account,
        address parent,
        uint256 layer,
        uint256 amount
    );

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {
    }

    /**
     * develop a new customer, transfer MUT to the customer
     * @param customer: destination customer you wanna develop
     * @param amount: MUT amount sent to customer
     */
    function developCustomer(address customer, uint256 amount) external lock {
        require(
            msg.sender != address(0),
            "ZERO address can not develop customer"
        );
        require(
            msg.sender != SystemAuth(moduleMgr.getAuth()).getOwner(),
            "owner can not develop customer"
        );
        require(customer != SystemAuth(moduleMgr.getAuth()).getOwner(), "you can not develop an owner");
        require(customer != address(0), "you can not develop a ZERO address");
        (bool hasParent, address parentTemp) = RelationshipData(moduleMgr.getRelationshipData()).getParent(customer);
        require(
            !hasParent && parentTemp != msg.sender,
            "you have developped this customer"
        );
        require(!RelationshipData(moduleMgr.getRelationshipData()).isCustomerDeveloped(customer), "customer had beed developed");
        require(
            !RelationshipData(moduleMgr.getRelationshipData()).isHaveChildren(customer),
            "you can't develop a customer that have children"
        );

        require(
            amount >= SystemSetting(moduleMgr.getSystemSetting()).getMinDevelopCustomerAmount(0),
            "too small amount to develop a customer"
        );
        require(
            ERC20(SystemAuth(moduleMgr.getAuth()).getFarmToken()).balanceOf(msg.sender) >= amount,
            "Insufficient amount in your balance"
        );
        require(
            ERC20(SystemAuth(moduleMgr.getAuth()).getFarmToken()).allowance(msg.sender, address(this)) >=
                amount,
            "not allowed to spend amount"
        );

        bool transfered = ERC20(SystemAuth(moduleMgr.getAuth()).getFarmToken()).transferFrom(
            msg.sender,
            customer,
            amount
        );
        require(transfered, "develop customer error");

        if(!RelationshipData(moduleMgr.getRelationshipData()).isCustomerDeveloped(msg.sender)) {
            _makeRelationship(SystemAuth(moduleMgr.getAuth()).getOwner(), msg.sender, 1);
        }

        _makeRelationship(msg.sender, customer, 1);
    }

    function makeRelationship(address parent, address child)
        external onlyCaller
        returns (bool res)
    {
        res = _makeRelationship(parent, child, 2);
    }

    function _makeRelationship(address parent, address child, uint8 rType)
        internal
        returns (bool res)
    {
        //`child` must be an orphan, neither has a parent nor has children
        (bool hasParent, address parentTemp) = RelationshipData(moduleMgr.getRelationshipData()).getParent(child);
        if(hasParent && parentTemp == parent || RelationshipData(moduleMgr.getRelationshipData()).isCustomerDeveloped(child) || RelationshipData(moduleMgr.getRelationshipData()).isHaveChildren(child)){
            res = false;
        } else {
            if(RelationshipData(moduleMgr.getRelationshipData()).isHaveChildren(parent)) {
                RelationshipData(moduleMgr.getRelationshipData()).increaseChildrenNumber(parent);
            } else {
                RelationshipData(moduleMgr.getRelationshipData()).newChildNumber(parent);
            }
            uint256 number = RelationshipData(moduleMgr.getRelationshipData()).getChildrenNumber(parent);
            RelationshipData(moduleMgr.getRelationshipData()).addChildToNumberData(parent, child, number);
            RelationshipData(moduleMgr.getRelationshipData()).makeAChild(parent, child);
            RelationshipData(moduleMgr.getRelationshipData()).markCustomerAsDeveloped(child);
            RelationshipData(moduleMgr.getRelationshipData()).markCustomerAsDeveloped(child);
            RelationshipData(moduleMgr.getRelationshipData()).addHistory(parent, child, rType);
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
        (res, totalAmount, claimedAmount) = RelationshipData(moduleMgr.getRelationshipData()).getSharedProfit(account);
    }

    function sharedProfit(address addr, uint256 amount)
        external onlyCaller
        returns (uint256 sharedAmount)
    {
        sharedAmount = _sharedProfit(addr, amount);
    }

    function _sharedProfit(address addr, uint256 amount)
        internal
        returns (uint256 sharedAmount)
    {
        (, uint256[] memory _sharedPercent, uint256 _sharedLayer) = SystemSetting(moduleMgr.getSystemSetting())
            .getSharedSetting(0);

        uint256 sharedLayer = _sharedLayer;
        uint256[] memory sharedPercent = _sharedPercent;

        uint256 tempAmount = 0;
        for (uint256 i = 1; i <= sharedLayer; i++) {
            (bool res, address parent) = RelationshipData(moduleMgr.getRelationshipData()).getUpstreamParent(addr, i);
            if (res) {
                uint256 layerAmount = div(mul(amount, sharedPercent[sub(i, 1)]), 1000);
                if (RelationshipData(moduleMgr.getRelationshipData()).isSharedProfitExists(parent)) {
                    RelationshipData(moduleMgr.getRelationshipData()).increaseSharedProfitAmount(parent, layerAmount);
                } else {
                    RelationshipData(moduleMgr.getRelationshipData()).newSharedProfitAmount(parent, layerAmount);
                }

                emit profitSharedEvent(addr, parent, i, layerAmount);

                tempAmount = add(tempAmount, layerAmount);
            } else {
                break;
            }
        }
        sharedAmount = tempAmount;
    }

    function increaseClaimedSharedProfit(address account, uint256 amount) external onlyCaller {
        require(RelationshipData(moduleMgr.getRelationshipData()).isSharedProfitExists(account), "shared profit not exists");
        RelationshipData(moduleMgr.getRelationshipData()).increaseClaimedSharedProfit(account, amount);
    }

    //use share profit as sowing seed
    function useSharedProfit(address account, uint256 amount) external onlyCaller {
        RelationshipData(moduleMgr.getRelationshipData()).useSharedProfit(account, amount);
    }
}