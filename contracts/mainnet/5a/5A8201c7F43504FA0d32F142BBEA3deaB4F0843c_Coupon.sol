// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ModuleBase.sol";
import "./Lockable.sol";
import "./SafeMath.sol";
import "./Relationship.sol";
import "./RelationshipData.sol";

contract Coupon is ModuleBase, Lockable, SafeMath {

    struct RoundData {
        uint256 amount;
        uint32 count;
        uint256 value;
    }

    struct UserData {
        uint256 amount;
        uint256 usedAmount;
        uint8 sharedCount;
    }

    uint32 roundIndex;

    mapping(uint32 => RoundData) mapRound;

    mapping(address => mapping(uint32 => bool)) mapUserClaimed;
    mapping(address => UserData) mapUserData;

    constructor(address _auth, address _mgr) ModuleBase(_auth, _mgr){}

    //fund the coupon base
    function fundCoupon(uint256 amount, uint32 count) external lock onlyOwner {
        require(mapRound[roundIndex].count == 0, "coupon ticket still remained");
        mapRound[++roundIndex] = RoundData(amount, count, div(amount, count));
    }

    function clearCoupon() external lock onlyOwner {
        require(mapRound[roundIndex].count > 0, "have no coupon to clear");
        RoundData storage rd = mapRound[roundIndex];
        rd.count = 0;
    }

    function isCouponExists() external view returns (bool res, uint256 amount, uint32 count, uint256 value) {
        if(mapRound[roundIndex].amount > 0) {
            res = true;
            amount = mapRound[roundIndex].amount;
            count = mapRound[roundIndex].count;
            value = mapRound[roundIndex].value;
        }
    }

    function claimCoupon(address parent) external lock {
        (bool res, uint256 value) = _isCouponClaimed(msg.sender);
        require(!res && 0 == value, "u'd claimed coupon");
        RoundData storage rd = mapRound[roundIndex];
        require(rd.count > 0, "no more coupon");
        --rd.count;
        if(parent != address(0)) {
            Relationship(moduleMgr.getModuleRelationship()).makeRelationship(parent, msg.sender);
        }

        mapUserClaimed[msg.sender][roundIndex] = true;
        if(mapUserData[msg.sender].amount > 0) {
            UserData storage ud = mapUserData[msg.sender];
            ud.amount = add(ud.amount, mapRound[roundIndex].value);
        } else {
            mapUserData[msg.sender] = UserData(mapRound[roundIndex].value, 0, 0);
        }

        (bool _resParent, address _parentTemp) = RelationshipData(moduleMgr.getModuleRelationshipData()).getParent(msg.sender);
        if(_resParent && _parentTemp != ssAuth.getOwner()) {
            _addSharedCoupon(_parentTemp);
        }
    }

    function isCouponClaimed(address account) external view returns (bool res, uint256 value) {
        (res, value) = _isCouponClaimed(account);
    }

    function _isCouponClaimed(address account) internal view returns (bool res, uint256 value) {
        res = mapUserClaimed[account][roundIndex];
        if(res) {
            value = mapRound[roundIndex].value;
        }
    }

    function getCouponAmount(address account) external view returns (bool res, uint256 amount, uint256 usedAmount) {
        if(mapUserData[account].amount > 0) {
            res = true;
            amount = mapUserData[account].amount;
            usedAmount = mapUserData[account].usedAmount;
        }
    }

    function useCoupon(address account) external onlyCaller {
        if(mapUserData[account].amount > mapUserData[account].usedAmount) {
            UserData storage ud = mapUserData[account];
            ud.usedAmount = ud.amount;
        }
    }

    function getSharedCount(address account) external view returns (bool res, uint8 sharedCount) {
        (res, sharedCount) = _getSharedCount(account);
    }

    function _getSharedCount(address account) internal view returns (bool res, uint8 sharedCount) {
        if(mapUserData[account].amount > 0) {
            res = true;
            sharedCount = mapUserData[account].sharedCount;
        }
    }

    function addSharedCoupon(address account) external onlyCaller {
        _addSharedCoupon(account);
   }

   function _addSharedCoupon(address account) internal {
        (, uint8 sharedCount) = _getSharedCount(account);
        if(sharedCount < 2) {
            if(mapUserData[account].amount > 0) {
                UserData storage ud = mapUserData[account];
                ud.amount = add(ud.amount, mapRound[roundIndex].value);
                ud.sharedCount += 1;
            } else {
                mapUserData[account] = UserData(mapRound[roundIndex].value, 0, 1);
            }
        }
   }
}