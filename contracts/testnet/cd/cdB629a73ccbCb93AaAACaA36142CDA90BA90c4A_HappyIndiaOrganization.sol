/*
Copyright 2017, 2018 Conseil départemental des Hauts-de-Seine

This file is part of Donation.

Donation is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Donation is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.24;

import "./SafeMath.sol";		// update privileges


contract HappyIndiaOrganization {
	using SafeMath for uint256;

	// address owning the contract
	address public superAdmin;
	// address of the Privilege Request contract
	address public privilegeRequest;
	// counter of the number of beneficiaries
	uint256 public beneficiaryCount;
	// the fixed value to transfer when doing a distribution
	uint256 public fixedValue = 0.01 ether;
	// last timestamp of execution of the distribute function
	uint256 public lastTimestamp = 1532004027;
	// mapping of beneficiaries with privilege contract
	mapping (address => address) public beneficiaries;
	// storage of beneficiaries with positions
	mapping (uint => address) public beneficiaryPositions;
	// mapping of privileges contracts
	mapping (address => bool) public privileges;
	// storage of privileges balances
	mapping (address => uint256) public privilegesBalances;
	// Events
	event evtSendSuccess(address benef, uint amount);

	// Modifier restricting execution of a function to PrivilegeRequest contract
	modifier onlyPrivilegeRequest {
		require(msg.sender == privilegeRequest);
		_;
	}

	// Modifier restricting execution of a function to superAdmin
	modifier onlyAdmin {
		require(msg.sender == superAdmin);
		_;
	}

	// constructor
	constructor() public {
		superAdmin = msg.sender;
		beneficiaryCount = 0;
	}

	// Allows to give wei to this contract via fallback function
	function () public payable {
	}


	// Adding a new beneficiary
	function registerBeneficiary(address _privilege, address _beneficiary) public onlyPrivilegeRequest {
		if (privileges[_beneficiary] == false) {
			beneficiaries[_beneficiary] = _privilege;
			// save new privilege contract
			privileges[_privilege] = true;
			// privileges count of a beneficiary are initialized to 0
			privilegesBalances[_privilege] = 0;
			beneficiaryPositions[beneficiaryCount] = _beneficiary;
			beneficiaryCount++;
		}
	}

	// Update privileges
	function updatePrivileges(uint256 _value) public {
		// check if the msg.sender is a beneficiary
		require(privileges[msg.sender] == true);
		// add privileges to the beneficiary
		privilegesBalances[msg.sender] = privilegesBalances[msg.sender].add(_value);
	}

	// Get the beneficiaries count
	function getBeneficiaryCount() public view returns (uint) {
		return beneficiaryCount;
	}

	function getPrivilegeAdr(address _beneficiary) public view returns (address){
		return beneficiaries[_beneficiary];
	}

	function getPrivileges(address _privilege) public view returns (uint){
		return privilegesBalances[_privilege];
	}
	// Set up the privilegeRequest address by the admin
	function setPrivilegeRequestAddress(address _privilegeRequest) public onlyAdmin{
		privilegeRequest = _privilegeRequest;
	}

	// Make a distribution of don
	function distribute() public{
		require(now >= lastTimestamp.add(1 hours));
		// check if we already have beneficiaries to make a transfer
		require(beneficiaryCount > 0);
		// check if the balance is suffisant to make a transfer
		require(address(0x42fA6d2EafaDD30DEc88463e408752f89e8eEaae).balance >= fixedValue);

		// balance
		uint balance = address(0x42fA6d2EafaDD30DEc88463e408752f89e8eEaae).balance;
		// determinate the exact number of beneficiaries going to get some ether
		uint nbBenef = balance.div(fixedValue);
		// counter to index the number of paid beneficiaries
		uint counter = 0;

		for(uint i = 0; i < beneficiaryCount; i++){
			// check if the number of beneficiaries to pay is not achieved
			if(counter != nbBenef && counter < nbBenef){
				address benef = beneficiaryPositions[i];
				// check if the beneficiary have enough privilegesBalances to receive a transfer
				if(privilegesBalances[beneficiaries[benef]] < fixedValue){
					// if the beneficiary haven't enough, we will move to the next one
					i++;
				}
				else{
					// if he have enough, transfer the "fixedValue"
					require(benef.send(fixedValue));
					emit evtSendSuccess(benef, fixedValue);
					// update his privileges
					address privilege = beneficiaries[benef];
					uint256 newPrivilege = (privilegesBalances[privilege]).sub(5000000000000000);
					privilegesBalances[privilege] = newPrivilege;
					counter ++;
				}
			}
			else{
				// if the number of beneficiaries to pay is achieved
				i = beneficiaryCount;
			}
		}
		// update the timestamp with the new time of execution
		lastTimestamp = now;
	}

}