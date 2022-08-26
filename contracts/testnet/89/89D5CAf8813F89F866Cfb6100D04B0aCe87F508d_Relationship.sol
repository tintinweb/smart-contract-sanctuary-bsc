// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Lockable.sol";
import "./ERC20.sol";
import "./SystemSetting.sol";
import "./RelationshipData.sol";
import "./ModuleBase.sol";
import "./Coupon.sol";

contract Relationship is SafeMath, Lockable, ModuleBase {

    event profitSharedEvent(
        address account,
        address parent,
        uint256 layer,
        uint256 amount
    );

    constructor(address _auth, address _mgr) ModuleBase(_auth, _mgr) {
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
            msg.sender != ssAuth.getOwner(),
            "owner can not develop customer"
        );
        require(customer != ssAuth.getOwner(), "you can not develop an owner");
        require(customer != address(0), "you can not develop a ZERO address");
        (bool hasParent, address parentTemp) = RelationshipData(moduleMgr.getModuleRelationshipData()).getParent(customer);
        require(
            !hasParent && parentTemp != msg.sender,
            "you have developped this customer"
        );
        require(!RelationshipData(moduleMgr.getModuleRelationshipData()).isCustomerDeveloped(customer), "customer had beed developed");
        require(
            !RelationshipData(moduleMgr.getModuleRelationshipData()).isHaveChildren(customer),
            "you can't develop a customer that have children"
        );

        require(
            amount >= SystemSetting(moduleMgr.getModuleSystemSetting()).getMinDevelopCustomerAmount(0),
            "too small amount to develop a customer"
        );
        require(
            ERC20(ssAuth.getFarmToken()).balanceOf(msg.sender) >= amount,
            "Insufficient amount in your balance"
        );
        require(
            ERC20(ssAuth.getFarmToken()).allowance(msg.sender, address(this)) >=
                amount,
            "not allowed to spend amount"
        );

        bool transfered = ERC20(ssAuth.getFarmToken()).transferFrom(
            msg.sender,
            customer,
            amount
        );
        require(transfered, "develop customer error");

        if(!RelationshipData(moduleMgr.getModuleRelationshipData()).isCustomerDeveloped(msg.sender)) {
            _makeRelationship(ssAuth.getOwner(), msg.sender);
        }

        _makeRelationship(msg.sender, customer);
    }

    function makeRelationship(address parent, address child)
        external onlyCaller 
        returns (bool res)
    {
        res = _makeRelationship(parent, child);
    }

    function _makeRelationship(address parent, address child)
        internal
        returns (bool res)
    {
        //`child` must be an orphan, neither has a parent nor has children
        (bool hasParent, address parentTemp) = RelationshipData(moduleMgr.getModuleRelationshipData()).getParent(child);
        if(hasParent && parentTemp == parent || RelationshipData(moduleMgr.getModuleRelationshipData()).isCustomerDeveloped(child) || RelationshipData(moduleMgr.getModuleRelationshipData()).isHaveChildren(child)){
            res = false;
        } else {
            if(RelationshipData(moduleMgr.getModuleRelationshipData()).isHaveChildren(parent)) {
                RelationshipData(moduleMgr.getModuleRelationshipData()).increaseChildrenNumber(parent);
            } else {
                RelationshipData(moduleMgr.getModuleRelationshipData()).newChildNumber(parent);
            }
            uint256 number = RelationshipData(moduleMgr.getModuleRelationshipData()).getChildrenNumber(parent);
            RelationshipData(moduleMgr.getModuleRelationshipData()).addChildToNumberData(parent, child, number);
            RelationshipData(moduleMgr.getModuleRelationshipData()).makeAChild(parent, child);
            RelationshipData(moduleMgr.getModuleRelationshipData()).markCustomerAsDeveloped(child);
            RelationshipData(moduleMgr.getModuleRelationshipData()).markCustomerAsDeveloped(child);
            Coupon(moduleMgr.getModuleCoupon()).addSharedCoupon(parent);
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
        (res, totalAmount, claimedAmount) = RelationshipData(moduleMgr.getModuleRelationshipData()).getSharedProfit(account);
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
        (, uint256[] memory _sharedPercent, uint256 _sharedLayer) = SystemSetting(moduleMgr.getModuleSystemSetting())
            .getSharedSetting(0);

        uint256 sharedLayer = _sharedLayer;
        uint256[] memory sharedPercent = _sharedPercent;

        uint256 tempAmount = 0;
        for (uint256 i = 1; i <= sharedLayer; i++) {
            (bool res, address parent) = RelationshipData(moduleMgr.getModuleRelationshipData()).getUpstreamParent(addr, i);
            if (res) {
                uint256 layerAmount = div(mul(amount, sharedPercent[sub(i, 1)]), 1000);
                if (RelationshipData(moduleMgr.getModuleRelationshipData()).isSharedProfitExists(parent)) {
                    RelationshipData(moduleMgr.getModuleRelationshipData()).increaseSharedProfitAmount(parent, layerAmount);
                } else {
                    RelationshipData(moduleMgr.getModuleRelationshipData()).newSharedProfitAmount(parent, layerAmount);
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
        require(RelationshipData(moduleMgr.getModuleRelationshipData()).isSharedProfitExists(account), "shared profit not exists");
        RelationshipData(moduleMgr.getModuleRelationshipData()).increaseClaimedSharedProfit(account, amount);
    }

    //use share profit as sowing seed
    function useSharedProfit(address account, uint256 amount) external onlyCaller {
        RelationshipData(moduleMgr.getModuleRelationshipData()).useSharedProfit(account, amount);
    }
}