// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Ownable.sol";
import "./VerifyProfileSignature.sol";

contract profile is Ownable,verifyProfileSignature{
	
    mapping(address => bool) public accessingRights;
	mapping(address => bool) kycProfile;
	mapping(address => bool) lockProfile;
	mapping(bytes => bool) alreadySigned;	
	
	constructor(){
		SetAccessingRightSigner(msg.sender);
	}
	
	// set address which will sign the message off-chain
	//@param _kycSigner the address which can sign the message off-chain

	function SetAccessingRightSigner(address _kycSigner) public onlyOwner{
		accessingRights[_kycSigner] = true;
	}

	// remove the address from signing the message off-chain
	//@param _kycSigner the address which is removed from signing the message

	function ReSetAccessingRightSigner(address _kycSigner) public onlyOwner{
		require(accessingRights[_kycSigner],"KycSigner Not Exist");
		delete accessingRights[_kycSigner];
	}

	/*
		set KYC of a address 
		@param _user is the address for which kyc will be done
		@param _nonce is the timestamp when the message is signed
		@param _signerAddress is the address of the signer
		@param _signature is the message which is signed off-chain by the _signerAddress
	*/

	function KycUserProfile(address _user,uint256 _nonce ,address _signerAddress, bytes calldata _signature) public{
		require(!kycProfile[_user],"Already Kyc verified profile");
		require(!alreadySigned[_signature],"Already Signed using this signature");
		require(accessingRights[_signerAddress],"Not an authorize signer");
		require(verify(_signerAddress,_user,_nonce,_signature),"Signature verification failed");		
        kycProfile[_user] = true;	
		alreadySigned[_signature] = true;	
    }

	/*
		remove the KYC of a address
		@param _user is the address for which KYC is removed
	*/

    function RemoveKycUserProfile(address _user) public{ 
		require(accessingRights[msg.sender] || msg.sender == _user,"Not allowed");
		require(kycProfile[_user],"No Kyc found");       
        delete kycProfile[_user]; 
    }

	/*
		to find the KYC status of an address
		@param _user is the address of which KYC status is to be find
		returns true if the status is found otherwise false
	*/

	function KycStatus(address _user) public view returns(bool){
			return kycProfile[_user];		
	}

	/*
		to lock any profile
		@param _user is the address which will be locked
	*/

	function lockUserProfile(address _user) public{
		require(accessingRights[msg.sender],"Not authorized to lock an Account");
		require(!lockProfile[_user],"Already lock");
        lockProfile[_user] = true;		
    }

	/*
		to unlock any profile
		@param _user is the address which will be unlock
	*/

    function unlockUserProfile(address _user) public{ 
		require(accessingRights[msg.sender],"Not authorized to unlock an Account");
		require(lockProfile[_user],"Profile not lock");       
        delete lockProfile[_user];
    }
	
	/*
		to find lock status of any profile
		@param _user is the address which will be unlock
		returns true if the profile is locked otherwise false
	*/

	function lockStatus(address _user) public view returns(bool){
		return lockProfile[_user];
	}	
}