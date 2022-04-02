/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.13;

contract VASTTokenManagerDatabase {

    address _owner;

    mapping ( address => bool ) isVTokenManager;

    mapping ( address => bool ) isVerifiedToken;

    modifier onlyOwner() {require(_owner == msg.sender, 'Only Owner Function'); _;}

    constructor() {
        _owner = msg.sender;
    }


    /** Allows Approved Manager To Call TransferFrom */
    function setIsVTokenManager(address manager, bool isManager) external onlyOwner {
        isVTokenManager[manager] = isManager;
        emit SetVTokenManager(manager, isManager);
    }

    function verifyToken(address token, bool isVerified) external onlyOwner {
        isVerifiedToken[token] = isVerified;
    }

    function tokenIsVerified(address token) external view returns (bool) {
        return isVerifiedToken[token];
    }

    /** Returns true if manager is a registered VTokenManager */
    function getIsVTokenManager(address manager) external view returns (bool) {
        return isVTokenManager[manager];
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _owner = newOwner;
    }

    // EVENTS
    event SetVTokenManager(address manager, bool isManager);


}