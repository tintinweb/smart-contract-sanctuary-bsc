/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

//SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.14;

contract AuthManager {

    /**
        Mapping From An Address To An Authorized Contract Manager
     */
    mapping ( address => bool ) private _authorized;

    /**
        Ensures Only Authorized Parties Can Call Certain Functions
     */
    modifier onlyAuthorized() {
        require(
            _authorized[msg.sender],
            'INVISION: RESTRICTED'
        );
        _;
    }

    /**
        Events To Support Data Tracking
     */
    event Authorize(address account);
    event RevokeAuth(address account);
    
    /**
        Initializes Contract State And Authorization
     */
    constructor(
        address initialAuth
    ) {
        _authorized[initialAuth] = true;
        emit Authorize(initialAuth);
    }

    /**
        Authorizes `account` To Call Restricted Functions
        Including Authorizing And Revoking Authority From Other Users
        This Function Should Be Used Extremely Carefully
        Ideally Only A MultiSignature Wallet And Approved Smart Contracts Will Be Authorized
     */
    function authorize(address account) external onlyAuthorized {
        _authorized[account] = true;
        emit Authorize(account);
    }

    /**
        Revokes Authority For `account`
        Can Only Be Called By Authorized Users
     */
    function revokeAuthority(address account) external onlyAuthorized {
        _authorized[account] = false;
        emit RevokeAuth(account);
    }

    /**
        Returns true if `account` is Authorized, False Otherwise
     */
    function isAuthorized(address account) external view returns (bool) {
        return _authorized[account];
    }
}