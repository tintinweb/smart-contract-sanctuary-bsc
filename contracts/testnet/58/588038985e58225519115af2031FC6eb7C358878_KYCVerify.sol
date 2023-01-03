/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

//SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.14;

interface IKYCVerification {

    /**
        Returns true if `user` has passed KYC Verification and has been verified by contract owner
        Returns false if `user` has not passed KYC Verification, or has not yet been verified by contract owner
        
        @param user - Address corresponding to a Person who may or may not have passed KYC Verification
        @return bool - Returns true if `user` is KYC verified, false otherwise
     */
    function isVerified(address user) external view returns (bool);

    /**
        Validates that the hashed value for `information` - the KYC Information - of `User`
        Matches what is stored on chain. This function can be used to ensure that off-chain data
        has not been manipulated or altered in any way

        @param user - Address corresponding to a person who may or may not have passed KYC Verification
        @param information - Stringified KYC Information for `user`
        @return bool - Returns true if hashed `information` matches what is stored on-chain for `user`
     */
    function validate(address user, string calldata information) external view returns (bool);

    /**
        Validates that `hashedData` ( the hashed KYC Information of `User` )
        Matches what is stored on chain. This function can be used to ensure that off-chain data
        has not been manipulated or altered in any way

        @param user - Address corresponding to a person who may or may not have passed KYC Verification
        @param hashedData - Hashed version of KYC Information for `user`
        @return bool - Returns true if `hashedData` matches what is stored on-chain for `user`
     */
    function validateHash(address user, bytes32 hashedData) external view returns (bool);

    /**
        Returns the hash of a given input string. Should be used to determine the hash of
        KYC Information from registered users, prior to calling the `verify()` function

        @param information - KYC Information
        @return bytes32 - Hashed bytes of `information`
     */
    function getHash(string calldata information) external view returns (bytes32);

}

interface IDatabase {
    function isAuthorized(address account) external view returns (bool);
}

/**
    @title KYC Verification Contract
    
    Manages Storing and Validating Users Who Have Passed The KYC Audit Process
    Allows External Contracts To Query User's Verification Status
    To Prevent Use From Users Who Have Not Yet Been Verified To Use Them

    This Contract, If Used Appropriately, Will Allow The Owners To Follow
    Proper Legal Guidelines In Accordance With SEC Rules And Regulations

 */
contract KYCVerify is IKYCVerification {

    /**
        Stores the mapping of each registered `user` address
        And the corresponding hash of the KYC data entered off chain

        Use the `getHash()` function to convert a string of KYC data
        Into a bytes32 hash prior to calling `verify()` to ensure the data matches

        `validate()` can be called to ensure that the KYC data stored off chain
        Has not been altered in any way by comparing the hash of the stored data
        To the hash stored on chain

        `isVerified()` can be called by any smart contract to ensure only addresses
        corresponding to users who are KYC Verified are able to interact with the Platform
     */
    mapping ( address => bytes32 ) private hashMap;

    /**
        Master Database Which Interacts With Auth And KYC Databases
     */
    IDatabase public immutable Database;

    /**
        Modifier To Ensure Only Authorized Addresses May Set Verification Status In This Contract
        If `Database.isAuthorized(msg.sender)` returns false, Transaction execution is reverted
     */
    modifier onlyOwner() {
        require(
            Database.isAuthorized(msg.sender),
            'Sender Is Not Authorized'
        );
        _;
    }

    /**
        Initialize Database
     */
    constructor(address DB) {
        Database = IDatabase(DB);
    }

    /**
        Verifies that the address corresponding to `user` has been KYC'd
        Stores the hash of the KYC information on-chain to ensure that the data
        has not been altered off-chain. 
        
        This function will grant access to the address corresponding to `user`
        to interact with restricted contracts that ensure `isVerified()` returns true 
        before allowing for contract interactions to occur.

        To ensure the hash stored on-chain matches the data stored off-chain
        Call `getHash()` on the off-chain data and pass the resulting bytes32 output into `verify()`
        This will ensure small issues like spacing and capitalization are accounted for and will not cause hashes to mismatch

        This function should only be called once the user has passed the KYC Verification Process
        And the operator of this contract is positive the data they provided matches their identity

        This is a dangerous function if misused. Calling verify with a non-zero input for 
        `hashedData` will cause every interacting contract to assume `user` is now KYC Verified. 
        Likewise, calling verify with a zero input for `hashedData` will cause every interacting 
        contract to assume `user` is no longer KYC Verified.

        Ensure the keys which operate this contract are safely kept to prevent manipulation
        Locking contract ownership behind a Multi Signature Wallet owned by Company Executives
        Is the safest way to ensure data is preserved and KYC is enforced.

        @param user - Address corresponding to a Person who has passed KYC Verification
        @param hashedData - Hashed KYC Data Of User, To Ensure Data stored off-chain is accurate
     */
    function verify(address user, bytes32 hashedData) external onlyOwner {
        hashMap[user] = hashedData;
    }

    /**
        Returns true if `user` has passed KYC Verification and has been verified by contract owner
        Returns false if `user` has not passed KYC Verification, or has not yet been verified by contract owner
        
        @param user - Address corresponding to a Person who may or may not have passed KYC Verification
        @return bool - Returns true if `user` is KYC verified, false otherwise
     */
    function isVerified(address user) external view override returns (bool) {
        return hashMap[user] != bytes32(0);
    }

    /**
        Validates that the hashed value for `information` - the KYC Information - of `User`
        Matches what is stored on chain. This function can be used to ensure that off-chain data
        has not been manipulated or altered in any way

        @param user - Address corresponding to a person who may or may not have passed KYC Verification
        @param information - Stringified KYC Information for `user`
        @return bool - Returns true if hashed `information` matches what is stored on-chain for `user`
     */
    function validate(address user, string calldata information) external view override returns (bool) {
        return hashMap[user] == keccak256(bytes(information));
    }

    /**
        Validates that `hashedData` ( the hashed KYC Information of `User` )
        Matches what is stored on chain. This function can be used to ensure that off-chain data
        has not been manipulated or altered in any way

        @param user - Address corresponding to a person who may or may not have passed KYC Verification
        @param hashedData - Hashed version of KYC Information for `user`
        @return bool - Returns true if `hashedData` matches what is stored on-chain for `user`
     */
    function validateHash(address user, bytes32 hashedData) external view override returns (bool) {
        return hashMap[user] == hashedData;
    }

    /**
        Returns the hash of a given input string. Should be used to determine the hash of
        KYC Information from registered users, prior to calling the `verify()` function

        @param information - KYC Information
        @return bytes32 - Hashed bytes of `information`
     */
    function getHash(string calldata information) external pure override returns (bytes32) {
        return keccak256(bytes(information));
    }
}