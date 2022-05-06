/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;



interface IInsuranceContract {
	function initiate() external;
	function getBalance() external view returns(uint);
	function getMainContract() external view returns(address);
}

contract INSURANCE {

	//accept funds from MainContract
	receive() external payable {}
	address payable public MAINCONTRACT;

	constructor(address payable _walletProject) {

		MAINCONTRACT = payable(_walletProject);
	}

	function initiate() public {
		require(MAINCONTRACT == MAINCONTRACT, "Forbidden");
		uint balance = address(this).balance;
		if(balance==0) return;
		MAINCONTRACT.transfer(balance);
	}

	function getBalance() public view returns(uint) {
		return address(this).balance;
	}

	function getMainContract() public view returns(address) {
		return MAINCONTRACT;
	}

}