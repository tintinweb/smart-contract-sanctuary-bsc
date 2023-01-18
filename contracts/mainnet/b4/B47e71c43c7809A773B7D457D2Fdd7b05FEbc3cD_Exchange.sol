/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

pragma solidity >=0.7.0 <0.9.0;
// SPDX-License-Identifier: MIT

/**
 * Contract Type : Exchange
 * 1st Iten : Native Token
 * 2nd Iten : Coin SOGOToken
 * 2nd Address : 0xf309A32D4f662c53dB2e3fB6c73b9C320c6f39eA
*/

interface ERC20{
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Exchange {

	address owner;
	uint256 public minExchange1To2amt = uint256(100000000000000000);
	uint256 public exchange1To2rate = uint256(2000000000000000);
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
 * Notes for _minExchange1To2amt : 1 Native Token is represented by 10^18.
*/
	function changeValueOf_minExchange1To2amt (uint256 _minExchange1To2amt) external onlyOwner {
		 minExchange1To2amt = _minExchange1To2amt;
	}

	

/**
 * This function allows the owner to change the value of exchange1To2rate.
 * Notes for _exchange1To2rate : Number of Native Token (1 Native Token is represented by 10^18) to 1 Coin SOGOToken (represented by 1).
*/
	function changeValueOf_exchange1To2rate (uint256 _exchange1To2rate) external onlyOwner {
		 exchange1To2rate = _exchange1To2rate;
	}

/**
 * Function exchange1To2
 * Minimum Exchange Amount : Variable minExchange1To2amt
 * Exchange Rate : Variable exchange1To2rate
 * The function takes in 0 variables. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that (amount of native currency sent to contract) is greater than or equals to minExchange1To2amt
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to (((amount of native currency sent to contract) * (exchange1To2rate)) / (1000000000000000000))
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as ((amount of native currency sent to contract) * (exchange1To2rate)) / (1000000000000000000)
 * emits event Exchanged with inputs the address that called this function
*/
	function exchange1To2() public payable {
		require((msg.value >= minExchange1To2amt), "Too little exchanged");
		require((ERC20(0xf309A32D4f662c53dB2e3fB6c73b9C320c6f39eA).balanceOf(address(this)) >= ((msg.value * exchange1To2rate) / uint256(1000000000000000000))), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0xf309A32D4f662c53dB2e3fB6c73b9C320c6f39eA).transfer(msg.sender, ((msg.value * exchange1To2rate) / uint256(1000000000000000000)));
		emit Exchanged(msg.sender);
	}

/**
 * Function withdrawToken1
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (amount of native currency owned by the address of this contract) is greater than or equals to _amt
 * transfers _amt of the native currency to the address that called this function
*/
	function withdrawToken1(uint256 _amt) public onlyOwner {
		require((address(this).balance >= _amt), "Insufficient amount of native currency in this contract to transfer out. Please contact the contract owner to top up the native currency.");
		payable(msg.sender).transfer(_amt);
	}

/**
 * Function withdrawToken2
 * The function takes in 1 variable, (zero or a positive integer) _amt. It can be called by functions both inside and outside of this contract. It does the following :
 * checks that the function is called by the owner of the contract
 * checks that (ERC20's balanceOf function  with variable recipient as the address of this contract) is greater than or equals to _amt
 * calls ERC20's transfer function  with variable recipient as the address that called this function, variable amount as _amt
*/
	function withdrawToken2(uint256 _amt) public onlyOwner {
		require((ERC20(0xf309A32D4f662c53dB2e3fB6c73b9C320c6f39eA).balanceOf(address(this)) >= _amt), "Insufficient amount of the token in this contract to transfer out. Please contact the contract owner to top up the token.");
		ERC20(0xf309A32D4f662c53dB2e3fB6c73b9C320c6f39eA).transfer(msg.sender, _amt);
	}

	function sendMeNativeCurrency() external payable {
	}
}