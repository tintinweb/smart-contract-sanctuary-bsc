/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

pragma solidity >= 0.4.16 < 0.7.0;

// Defining a contract
contract Storage
{

	// Declaring state variables
	uint public setData;

	// Defining public function
	// that sets the value of
	// the state variable
	function set(uint x) public
	{
		setData = x;
	}
	
	// Defining function to
	// print the value of
	// state variable
	function get(
	) public view returns (uint) {
		return setData;
	}
}