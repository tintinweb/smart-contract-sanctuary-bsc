/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
}

contract MUSKDico {
    address _owner;
	/*presale start date*/
    uint private _startdate;
	/*presale end date*/
    uint private _enddate = 45*24*60*60;
	/* Tokens per wei ( 1 BNB = 1 Million MUSKD) */
	uint private _price = 1000000;
	string private _name;
	
	address private _tokenAddress;
	IERC20 public token = IERC20(_tokenAddress);
	
	constructor(){
		_name = "MUSKD ICO";
		_owner = msg.sender;
		_startdate = block.timestamp;
	}
	
	function name() external view returns (string memory){
		return _name;
	}
	
    receive () external payable {
		uint256 now1 = block.timestamp;
        require((now1 > _startdate && now1 < _startdate + _enddate), "Presale ICO Ended!");
		
		uint256 amt = msg.value;
		amt = amt * _price;
		require( token.balanceOf( address(this) ) >= amt, "Dex Doesnot have enough balance");
		
        payable(_owner).transfer(msg.value);
        token.transfer(msg.sender, amt);
    }
	
	function price() external view returns (uint256){
		return _price;
	}
	
	function start() external view returns (uint256){
		return _startdate;
	}
	
	/* Useful in case wrong tokens are recieved */
	function retrieveTokens(address _token, address recipient, uint256 amount) public{
		require(_owner == msg.sender, "Only owner can call this function");
		_retrieveTokens(_token, recipient, amount);
	}
	
	function _retrieveTokens(address _token, address recipient, uint256 amount) internal{
		require(amount > 0, "amount should be greater than zero");
		IERC20 erctoken = IERC20(_token);
		require(erctoken.balanceOf(address(this)) >= amount, "not enough token balance");
		erctoken.transfer(recipient, amount);
	}
	
	function changetokenAddress(address newTA) public{
		require(_owner == msg.sender, "Only owner can call this function");
		_tokenAddress = newTA;
		token = IERC20(_tokenAddress);
	}

	function endSale() public{
		require(_owner == msg.sender, "Only owner can call this function");
		_enddate = block.timestamp;
	}
}