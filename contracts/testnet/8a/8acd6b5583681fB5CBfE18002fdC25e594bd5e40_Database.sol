/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

//SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.14;

interface IAuth {
    function isAuthorized(address account) external view returns (bool); 
}

interface IKYC {
    function isVerified(address account) external view returns (bool);
}

contract Database {

    // Authenticator Contract
    IAuth public Auth;

    // KYC Verification Contract
    IKYC public KYC;

    // Database Owner, Controls Everything
    address public owner;

    // Only Authenticated Users Can Change Database Values
    modifier onlyOwner() {
        require(
            owner == msg.sender,
            'Only Database Owner Can Call'
        );
        _;
    }

    // Events
    event OwnerChanged(address oldOwner, address newOwner);
    event AuthChanged(address oldAuth, address newAuth);
    event KYCChanged(address oldKYC, address newKYC);

    // initialize owner
    constructor(address initialOwner){
        owner = initialOwner;
        emit OwnerChanged(address(0), initialOwner);
    }

    /**
        Sets The Database Owner
     */
    function changeOwner(address newOwner) external onlyOwner {
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }

    /**
        Sets KYC Verification Contract
     */
    function setKYC(IKYC KYC_) external onlyOwner {
        require(
            address(KYC_) != address(0),
            'Zero Address'
        );
        emit KYCChanged(address(KYC), address(KYC_));
        KYC = KYC_;
    }

    /**
        Sets Authentication Contract
     */
    function setAuth(IAuth Auth_) external onlyOwner {
        require(
            address(Auth_) != address(0),
            'Zero Address'
        );
        emit AuthChanged(address(Auth), address(Auth_));
        Auth = Auth_;
    }

    /**
        Returns true if `account` is Authorized, False Otherwise
     */
    function isAuthorized(address account) external view returns (bool) {
        return Auth.isAuthorized(account) || account == owner;
    }

    /**
        Returns true if `account` has been KYC Verified, False Otherwise
     */
    function isVerified(address account) external view returns (bool) {
        return KYC.isVerified(account) || account == owner;
    }
}