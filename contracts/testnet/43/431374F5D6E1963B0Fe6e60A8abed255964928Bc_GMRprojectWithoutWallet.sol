// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./verifyVoucher.sol";
import "./Ownable.sol";
contract GMRprojectWithoutWallet is verifyVoucher,Ownable{

	uint256 public CouponRechargeValidaity;

	constructor(uint256 _timestamp){
		RechargeDuration(_timestamp);
	}

	function RechargeDuration(uint256 _timestamp) public onlyOwner{
		CouponRechargeValidaity = _timestamp;
	}

	function validateUser(string memory _identity, string memory _uri, bool _paymentStatus,uint256 _timeOfPayment, bytes memory _signature) public validateCoupon(_timeOfPayment) view returns(string memory){
		bool status = verifyUserVoucher(owner(),_identity,_uri,_paymentStatus,_timeOfPayment,_signature);
		if(status){
			return _uri;
		}
		else{
			return "User Not Exist";
		}
	}	

	modifier validateCoupon(uint _timeOfrecharge){
		require(block.timestamp<_timeOfrecharge+CouponRechargeValidaity,"Kindly recharge coupon");
		_;
	}
}