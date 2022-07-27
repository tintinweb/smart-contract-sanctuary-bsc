// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SystemAuth.sol";
import "./SystemSetting.sol";

contract Relationship {
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

    struct RelHistoryData {
        address parent;
        address child;
        uint8 rType; //1-develop, 2-share
        uint256 time;
        bool exists;
    }

    SystemSetting ssSetting;
    SystemAuth ssAuth;

    address caller;

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

    uint32 relHistoryCount;
    mapping(uint32 => RelHistoryData) mapRelHistory;

    event profitSharedEvent(
        address account,
        address parent,
        uint256 layer,
        uint256 amount
    );
    event sharedProfitClaimedEvent(address account, uint256 amount);

    constructor(address ssSettingAddress, address ssAuthAddress) {
        ssSetting = SystemSetting(ssSettingAddress);
        ssAuth = SystemAuth(ssAuthAddress);
    }

    function setCaller(address _caller) external {
        require(msg.sender == ssAuth.getOwner(), "Owner only");
        caller = _caller;
    }

    function getCaller() external view returns (address res) {
        res = caller;
    }

    /**
     * develop a new customer, transfer MUT to the customer
     * @param customer: destination customer you wanna develop
     * @param amount: MUT amount sent to customer
     */
    function developCustomer(address customer, uint256 amount) external {
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
        require(
            mapParent[customer] != msg.sender,
            "you have developped this customer"
        );
        require(!mapDeveloped[customer], "customer had beed developed");
        require(
            !mapChildrenNumber[customer].exists,
            "you can't develop a customer that have children"
        );

        require(
            amount >= ssSetting.getMinDevelopCustomerAmount(0),
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

        _makeRelationship(msg.sender, customer, 1);
    }

    function makeRelationship(address parent, address child)
        external
        returns (bool res)
    {
        require(caller != address(0), "caller not set");
        require(msg.sender == caller, "Caller only");
        res = _makeRelationship(parent, child, 2);
    }

    function _makeRelationship(address parent, address child, uint8 rType)
        internal
        returns (bool res)
    {
        //`child` must be an orphan, neither has a parent nor has children
        if (
            mapParent[child] == parent ||
            mapDeveloped[child] ||
            mapChildrenNumber[child].exists
        ) {
            res = false;
        } else {
            uint256 number = 0;
            if (mapChildrenNumber[parent].exists) {
                ChildrenNumber storage childrenNumber = mapChildrenNumber[
                    parent
                ];
                number = childrenNumber.number + 1;
                childrenNumber.number = number;
            } else {
                number = 1;
                mapChildrenNumber[parent] = ChildrenNumber(number, true);
            }

            mapChildren[parent][number] = Children(
                child,
                block.timestamp,
                true
            );

            mapParent[child] = parent;
            mapDeveloped[child] = true;

            relHistoryCount ++;
            mapRelHistory[relHistoryCount] = RelHistoryData(parent, child, rType, block.timestamp, true);
            res = true;
        }
    }

    //get single parent of a child
    function getParent(address child)
        external
        view
        returns (bool res, address parent)
    {
        if (mapParent[child] != address(0)) {
            res = true;
            parent = mapParent[child];
        }
    }

    //get children number of an address
    function getChildrenNumber(address parent)
        external
        view
        returns (uint256 res)
    {
        res = mapChildrenNumber[parent].number;
    }

    //get a child of addr by index
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

    function sharedProfit(address addr, uint256 amount)
        external
        returns (uint256 sharedAmount)
    {
        require(caller != address(0), "caller not set");
        require(msg.sender == caller, "Caller only");
        sharedAmount = _sharedProfit(addr, amount);
    }

    function _sharedProfit(address addr, uint256 amount)
        internal
        returns (uint256 sharedAmount)
    {
        (, uint256[] memory _sharedPercent, uint256 _sharedLayer) = ssSetting
            .getSharedSetting(0);

        uint256 sharedLayer = _sharedLayer;
        uint256[] memory sharedPercent = _sharedPercent;

        uint256 tempAmount = 0;
        for (uint256 i = 1; i <= sharedLayer; i++) {
            (bool res, address parent) = _getUpstreamParent(addr, i);
            if (res) {
                uint256 layerAmount = (amount * sharedPercent[i - 1]) / 1000;
                if (mapSharedProfit[parent].exists) {
                    SharedProfit storage sp = mapSharedProfit[parent];
                    sp.totalAmount += layerAmount;
                } else {
                    mapSharedProfit[parent] = SharedProfit(
                        layerAmount,
                        0,
                        true
                    );
                }

                emit profitSharedEvent(addr, parent, i, layerAmount);

                tempAmount += layerAmount;
            } else {
                break;
            }
        }
        sharedAmount = tempAmount;
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
        (, , uint256 _sharedLayer) = ssSetting.getSharedSetting(0);

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

    function increaseClaimedSharedProfit(address account, uint256 amount) external {
        require(msg.sender == caller, "only caller");
        require(mapSharedProfit[account].exists, "shared profit not exists");
        SharedProfit storage sp = mapSharedProfit[account];
        require(sp.totalAmount >= sp.claimedAmount + amount, "claimed overflow totalAmount");
        sp.claimedAmount += amount;
    }

    //use share profit as sowing seed
    function useSharedProfit(address account, uint256 amount) external {
        require(caller != address(0), "caller not set");
        require(msg.sender == caller, "Caller only");
        SharedProfit storage sp = mapSharedProfit[account];
        sp.claimedAmount += amount;
    }

    function getRelationCount() external view returns (uint32 res) {
        res = relHistoryCount;
    }

    function getRelationHistoryData(uint32 index)
        external
        view
        returns (
            bool res,
            address parent,
            address child,
            uint8 rType,
            uint256 time
        )
    {
        if (mapRelHistory[index].exists) {
            res = true;
            parent = mapRelHistory[index].parent;
            child = mapRelHistory[index].child;
            rType = mapRelHistory[index].rType;
            time = mapRelHistory[index].time;
        }
    }
}