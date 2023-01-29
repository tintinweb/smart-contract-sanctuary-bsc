/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

/**
 * Contract Type : Exchange
 * 1st Iten : Coin BEP20USDT
 * 1st Address : 0x55d398326f99059fF775485246999027B3197955
 * 2nd Iten : Coin TokenERC20
 * 2nd Address : 0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7
*/

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Exchange {

	address owner;
	struct referralRecord { bool hasDeposited; address referringAddress; uint256 unclaimedRewards1To2; }
	mapping(address => referralRecord) public referralRecordMap;
	uint256 public minExchange1To2amt = uint256(1000000000000000000);
	uint256 public exchange1To2rate = uint256(100000000000000000000);
	uint256 public totalUnclaimedRewards1To2 = uint256(0);
	uint256 public totalClaimedRewards1To2 = uint256(0);
	event Exchanged (address indexed tgt);

	constructor() {
		owner = msg.sender;
	}

	//This function allows the owner to specify an address that will take over ownership rights instead. Please double check the address provided as once the function is executed, only the new owner will be able to change the address back.
	function changeOwner(address _newOwner) public onlyOwner {
		owner = _newOwner;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	

/**
 * This function allows the owner to change the value of minExchange1To2amt.
 * Notes for _minExchange1To2amt : 1 Coin BEP20USDT is represented by 10^18.
*/
	function changeValueOf_minExchange1To2amt (uint256 _minExchange1To2amt) external onlyOwner {
		 minExchange1To2amt = _minExchange1To2amt;
	}

	

/**
 * This function allows the owner to change the value of exchange1To2rate.
 * Notes for _exchange1To2rate : Number of Coin BEP20USDT (1 Coin BEP20USDT is represented by 10^18) to 1 Coin TokenERC20 (represented by 1).
*/
	function changeValueOf_exchange1To2rate (uint256 _exchange1To2rate) external onlyOwner {
		 exchange1To2rate = _exchange1To2rate;
	}

/**
 * Function exchange1To2
 * Minimum Exchange Amount : Variable minExchange1To2amt
 * Exchange Rate : Variable exchange1To2rate
 * ERC20 Transfer : 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684, v0
 * The function takes in 1 variable, (zero or a positive integer) v0. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that v0 is greater than or equals to minExchange1To2amt
 * calls ERC20's transferFrom function  with variable sender as the address that called this function, variable recipient as the address of this contract, variable amount as v0
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to (((v0) * (exchange1To2rate)) / (1000000000000000000))
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as ((v0) * (exchange1To2rate)) / (1000000000000000000)
 * calls addReferral1To2 with variable _amt as v0
 * emits event Exchanged with inputs the address that called this function
*/
	function exchange1To2(uint256 v0) public {
		require((v0 >= minExchange1To2amt), "Too little exchanged");
		ERC20(0x55d398326f99059fF775485246999027B3197955).transferFrom(msg.sender, address(this), v0);
		require((ERC20(0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7).balanceOf(address(this)) >= ((v0 * exchange1To2rate) / uint256(1000000000000000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7).transfer(msg.sender, ((v0 * exchange1To2rate) / uint256(1000000000000000000)));
		addReferral1To2(v0);
		emit Exchanged(msg.sender);
	}

/**
 * Function withdrawReferral1To2
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that (referralRecordMap with element the address that called this function with element unclaimedRewards1To2) is greater than or equals to _amt
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to _amt
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as _amt
 * updates referralRecordMap (Element the address that called this function) (Entity unclaimedRewards1To2) as (referralRecordMap with element the address that called this function with element unclaimedRewards1To2) - (_amt)
 * updates totalUnclaimedRewards1To2 as (totalUnclaimedRewards1To2) - (_amt)
 * updates totalClaimedRewards1To2 as (totalClaimedRewards1To2) + (_amt)
*/
	function withdrawReferral1To2(uint256 _amt) public {
		require((referralRecordMap[msg.sender].unclaimedRewards1To2 >= _amt), "Insufficient referral rewards to withdraw");
		require((ERC20(0x55d398326f99059fF775485246999027B3197955).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x55d398326f99059fF775485246999027B3197955).transfer(msg.sender, _amt);
		referralRecordMap[msg.sender].unclaimedRewards1To2  = (referralRecordMap[msg.sender].unclaimedRewards1To2 - _amt);
		totalUnclaimedRewards1To2  = (totalUnclaimedRewards1To2 - _amt);
		totalClaimedRewards1To2  = (totalClaimedRewards1To2 + _amt);
	}

/**
 * Function addReferral1To2
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can only be called by other functions in this contract. It does the following :
 * creates an internal variable referringAddress with initial value referralRecordMap with element the address that called this function with element referringAddress
 * if not referralRecordMap with element the address that called this function with element hasDeposited then (updates referralRecordMap (Element the address that called this function) (Entity hasDeposited) as true)
 * if referringAddress is equals to Address 0 then ()
 * updates referralRecordMap (Element referringAddress) (Entity unclaimedRewards1To2) as (referralRecordMap with element referringAddress with element unclaimedRewards1To2) + ((_amt) / (10000000000000000000))
 * updates referringAddress as referralRecordMap with element referringAddress with element referringAddress
 * updates totalUnclaimedRewards1To2 as (totalUnclaimedRewards1To2) + ((_amt) / (10000000000000000000))
*/
	function addReferral1To2(uint256 _amt) internal {
		address referringAddress = referralRecordMap[msg.sender].referringAddress;
		if (!(referralRecordMap[msg.sender].hasDeposited)){
			referralRecordMap[msg.sender].hasDeposited  = true;
		}
		if ((referringAddress == address(0))){
			return;
		}
		referralRecordMap[referringAddress].unclaimedRewards1To2  = (referralRecordMap[referringAddress].unclaimedRewards1To2 + (_amt / uint256(10000000000000000000)));
		referringAddress  = referralRecordMap[referringAddress].referringAddress;
		totalUnclaimedRewards1To2  = (totalUnclaimedRewards1To2 + (_amt / uint256(10000000000000000000)));
	}

/**
 * Function withdrawToken1
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to _amt
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as _amt
*/
	function withdrawToken1(uint256 _amt) public onlyOwner {
		require((ERC20(0x55d398326f99059fF775485246999027B3197955).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x55d398326f99059fF775485246999027B3197955).transfer(msg.sender, _amt);
	}

/**
 * Function withdrawToken2
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to _amt
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as _amt
*/
	function withdrawToken2(uint256 _amt) public onlyOwner {
		require((ERC20(0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0x59Cd90dF8AF3c8c6688038a6c028ddb5aA74D1e7).transfer(msg.sender, _amt);
	}

/**
 * Function addReferralAddress
 * The function takes in 1 variable, (an address) _referringAddress. It can only be called by functions outside of this contract. It does the following :
 * checks that referralRecordMap with element _referringAddress with element hasDeposited
 * checks that not _referringAddress is equals to (the address that called this function)
 * checks that (referralRecordMap with element the address that called this function with element referringAddress) is equals to Address 0
 * updates referralRecordMap (Element the address that called this function) (Entity referringAddress) as _referringAddress
*/
	function addReferralAddress(address _referringAddress) external {
		require(referralRecordMap[_referringAddress].hasDeposited, "Referring Address has not made a deposit");
		require(!((_referringAddress == msg.sender)), "Self-referrals are not allowed");
		require((referralRecordMap[msg.sender].referringAddress == address(0)), "User has previously indicated a referral address");
		referralRecordMap[msg.sender].referringAddress  = _referringAddress;
	}
}