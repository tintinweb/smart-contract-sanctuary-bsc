/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

contract HmineMain2
{
	struct AccountInfo {
		string nickname; // user nickname
		uint256 amount; // xHMINE staked
		uint256 reward; // BUSD reward accumulated but not claimed
		uint256 accRewardDebt; // BUSD reward debt from PCS distribution algorithm
		uint16 period; // user selected grace period for expirations
		uint64 day; // the day index of the last user interaction
		bool whitelisted; // flag indicating whether or not account pays withdraw penalties
	}

	mapping(address => AccountInfo) public accountInfo;
}

contract HmineMain2Unstuck
{
	address public immutable hmineMain2;

	constructor(address _hmineMain2)
	{
		hmineMain2 = _hmineMain2;
	}

	function accountInfo(address _account) external view returns (string memory nickname, uint256 amount, uint256 reward, uint256 accRewardDebt, uint16 period, uint64 day, bool whitelisted)
	{
		return HmineMain2(hmineMain2).accountInfo(_account);
	}

	function deposit(uint256 /*_amount*/) external pure
	{
		revert("unavailable");
	}

	function withdraw(uint256 /*_amount*/) external pure
	{
		revert("unavailable");
	}

	function claim() external pure returns (uint256 _amount)
	{
		return 0;
	}
}