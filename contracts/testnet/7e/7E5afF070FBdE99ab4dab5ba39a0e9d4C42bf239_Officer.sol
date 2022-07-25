// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;

import { AddressArray } from "./Library.sol";

abstract contract OfficerData {
	/**
	 * Status:
	 * 0: Default value. Contract is being checked (not available to use).
	 * 1: Available - Office contract is available.
	 * 2: Paused / Stoped - Contracts are still supported, but users will not be able to use for a short time.
	 * 3: suspended - discontinued. No longer available.
	 * ... : Other extended state.
	 **/

	// STATUS & ROLE: More component states are possible with the SHIFT operator, instead of just one.
	mapping(address => uint8) private status; // Officer status
	mapping(address => mapping(address => uint8)) private acceptedRoles; // Officer destination accepted caller with role.

	address[] private officers; // Lookup

	constructor() {
		// testing.......
		_setOfficerStatus(address(this), 1);
		_setOfficerStatus(msg.sender, 1);
		_setacceptedRole(address(this), msg.sender, 1); // Government
	}

	function _getOfficerStatus(address _officer) public view returns (uint8 officerStatus) {
		return status[_officer]; // Get the first digit of the status variable
	}

	function _isOfficer(address _officer) public view returns (bool) {
		return _getOfficerStatus(_officer) != 0; 
	}	

	function _isAvailableOfficer(address _officer) public view returns (bool) {
		return _getOfficerStatus(_officer) == 1;
	}

	function _getOfficer() public view returns (address[] memory _officers) {
		return officers;
	}

	function _getacceptedRole(address _destination, address _caller) public view returns (uint8 _acceptedRole) {
		return acceptedRoles[_destination][_caller]; // Get the first digit of the acceptedRoles variable
	}

	function _isAccepted(address _destination, address _caller) public view returns (bool) {
		return _getacceptedRole(_destination, _caller) != 0;
	}

	function _setacceptedRole(
		address _destination,
		address _caller,
		uint8 _role
	) public {
		acceptedRoles[_destination][_caller] = _role;
	}

	using AddressArray for address[];

	function _setOfficerStatus(address _officer, uint8 _status) public {
		status[_officer] = _status;
		officers.add(_officer);
	}
}

interface IOfficer {
	function isAvailableOfficer(address officer) external returns (bool);

	function getOfficerStatus() external returns (uint8 status);

	function isAccepted(address caller) external returns (bool);

	function getAcceptedRole(address caller) external returns (uint8 role);

	function isGovernment(address caller) external returns (bool);

	function isMonitoring(address caller) external returns (bool);

	function isBridging(address caller) external returns (bool);

	function setAcceptedRole(
		address destination,
		address caller,
		uint8 role
	) external;

	function setOfficerStatus(address officer, uint8 status) external;

	function getOfficer4Monitoring() external returns (address[] memory officers);

	function getOfficer4Bridging() external returns (address[] memory officers);
}

contract Officer is OfficerData, IOfficer {
	modifier checkAvailable() {
		require(_isAvailableOfficer(msg.sender), "Officer: caller not available");
		require(_isAvailableOfficer(address(this)), "Officer: this contract not available");
		_;
	}
	modifier onlyAccepted() {
		require(_isAccepted(address(this), msg.sender), "Officer: caller not accepted yet");
		_;
	}
	modifier onlyGovernment() {
		require(_getacceptedRole(address(this), msg.sender) == 1, "Officer: caller is not Government");
		_;
	}
	modifier onlyMonitoring() {
		require(_getacceptedRole(address(this), msg.sender) == 2, "Officer: caller is not Monitoring");
		_;
	}
	modifier onlyBridging() {
		require(_getacceptedRole(address(this), msg.sender) == 3, "Officer: caller is not Bridging");
		_;
	}

	/*******************************************************************************************************/

	function isAvailableOfficer(address officer) public view checkAvailable onlyAccepted returns (bool) {
		return _isAvailableOfficer(officer);
	}

	function getOfficerStatus() public view checkAvailable onlyAccepted returns (uint8 status) {
		return _getOfficerStatus(msg.sender); // Can only get your own status
	}

	function isAccepted(address caller) public view checkAvailable onlyAccepted returns (bool) {
		return _isAccepted(msg.sender, caller);
	}

	function getAcceptedRole(address caller) public view checkAvailable onlyAccepted returns (uint8 role) {
		return _getacceptedRole(msg.sender, caller); // Can only get role of caller
	}

	function isGovernment(address caller) public view checkAvailable onlyAccepted returns (bool) {
		return _getacceptedRole(msg.sender, caller) == 1;
	}

	function isMonitoring(address caller) public view checkAvailable onlyAccepted returns (bool) {
		return _getacceptedRole(msg.sender, caller) == 2;
	}

	function isBridging(address caller) public view checkAvailable onlyAccepted returns (bool) {
		return _getacceptedRole(msg.sender, caller) == 3;
	}

	/*******************************************************************************************************/

	function setAcceptedRole(
		address destination,
		address caller,
		uint8 role
	) public checkAvailable onlyGovernment {
		require(destination != address(0) && _isAvailableOfficer(destination), "Officer: destination not available");
		require(caller != address(0) && _isAvailableOfficer(caller), "Officer: caller not available");
		_setacceptedRole(destination, caller, role); // role >= 4
	}

	function setOfficerStatus(address officer, uint8 status) public checkAvailable onlyGovernment {
		require(officer != address(0), "Officer: cannot zero address");
		_setOfficerStatus(officer, status);
	}

	function getOfficer4Monitoring() public view checkAvailable onlyMonitoring returns (address[] memory officers) {
		officers = _getOfficer();
		//...
	}

	function getOfficer4Bridging() public view checkAvailable onlyBridging returns (address[] memory officers) {
		officers = _getOfficer();
		//...
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library AddressArray {
	function remove(address[] storage _array, address _address) internal returns (bool) {
		require(_array.length > 0, "Can't remove from empty array");
		uint256 _oldlength = _array.length;
		// Move the last element into the place to delete
		for (uint256 i = 0; i < _array.length; i++) {
			if (_array[i] == _address) {
				_array[i] = _array[_array.length - 1];
				break;
			}
		}
		// Remove
		_array.pop();
		// Confirm remove
		return (_array.length == _oldlength - 1) ? true : false;
	}

	function add(address[] storage _array, address _address) internal returns (bool) {
		uint256 _oldlength = _array.length;
		// Check exists
		bool _existed = false;
		for (uint256 i = 0; i < _array.length; i++) {
			if (_array[i] == _address) {
				_existed = true;
				break;
			}
		}
		// Add
		if (_existed == false) _array.push(_address);
		// Confirm add
		return ((_array.length == _oldlength + 1) && _array[_array.length - 1] == _address) ? true : false;
	}
}