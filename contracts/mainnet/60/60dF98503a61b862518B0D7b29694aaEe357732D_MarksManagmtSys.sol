/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// Solidity program to implement
// the above approach
pragma solidity >= 0.7.0<0.8.0;
// Build the Contract
contract MarksManagmtSys
{ 
	// Create a structure for
	// StnToken details
	struct StnToken
	{ 
		string wallet;
		string sponsor; 
	}

	address owner;
	int public userCount = 0;
	mapping(int => StnToken) public userRecords;

	modifier onlyOwner
	{
		require(owner == msg.sender);
		_;
	}
	constructor()
	{
		owner=msg.sender;
	} 
	// Create a function to add
	// the new records
	function addNewUser( string memory _wallet,
						string memory _sponsor) public onlyOwner
	{
		// Increase the count by 1
		userCount = userCount + 1; 
		// Fetch the StnToken details
		// with the help of userCount
		userRecords[userCount] = StnToken(_wallet,_sponsor);
	} 
}