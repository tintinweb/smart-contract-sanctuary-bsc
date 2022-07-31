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
	mapping(address => uint256) private status; // Officer status
	mapping(address => mapping(address => uint256)) private acceptedRoles; // Officer destination accepted caller with role.

	address[] private officers; // Lookup

	constructor() {
		// testing.......
		_setOfficerStatus(address(this), 1);
		_setOfficerStatus(msg.sender, 1);
		_setAcceptedRole(address(this), msg.sender, 369000001); // Government
	}

	function _getOfficerStatus(address _officer) internal view returns (uint256 officerStatus) {
		require(_officer != address(0), "Officer: cannot zero address");
		return status[_officer]; // Get the first digit of the status variable
	}

	function _isAvailableOfficer(address _officer) internal view returns (bool) {
		return _getOfficerStatus(_officer) == 1;
	}

	function _getOfficer() internal view returns (address[] memory _officers) {
		return officers;
	}

	/** --------------------------------------------------------------------------- */
	function _getacceptedRole(address _destination, address _caller) internal view returns (uint256 _acceptedRole) {
		require(_destination != address(0) && _caller != address(0), "Officer: cannot zero address");
		return acceptedRoles[_destination][_caller]; // Get the first digit of the acceptedRoles variable
	}

	function _isGovernment(address _destination, address _caller) internal view returns (bool) {
		return _getacceptedRole(_destination, _caller) == 369000001; // XXXYYYZZZ
	}

	function _isMonitoring(address _destination, address _caller) internal view returns (bool) {
		return _getacceptedRole(_destination, _caller) == 369000002;
	}

	function _isBridging(address _destination, address _caller) internal view returns (bool) {
		return _getacceptedRole(_destination, _caller) == 369000003;
	}

	/** --------------------------------------------------------------------------- */
	using AddressArray for address[];

	function _setOfficerStatus(address _officer, uint256 _status) internal {
		require(_officer != address(0), "Officer: cannot zero address");
		status[_officer] = _status;
		officers.add(_officer);
	}

	function _setAcceptedRole(
		address _destination,
		address _caller,
		uint256 _role
	) internal {
		require(_isAvailableOfficer(_destination), "Officer: destination not available");
		require(_isAvailableOfficer(_caller), "Officer: caller not available");
		acceptedRoles[_destination][_caller] = _role;
	}
}

interface IOfficer {
	function isAvailableOfficer(address officer) external returns (bool);

	function getOfficerStatus() external returns (uint256 status);

	function isAccepted(address caller) external returns (bool);

	function getAcceptedRole(address caller) external returns (uint256 role);

	function isGovernment(address caller) external returns (bool);

	function isMonitoring(address caller) external returns (bool);

	function isBridging(address caller) external returns (bool);
}

contract Officer is OfficerData, IOfficer {
	modifier onlyAccepted() {
		require(_isAvailableOfficer(msg.sender), "Officer: caller is not available");
		require(_isAvailableOfficer(address(this)), "Officer: this contract not available");
		require(_getacceptedRole(address(this), msg.sender) != 0, "Officer: caller not accepted yet");
		_;
	}
	modifier OnlyAvailableOfficer() {
		require(_isAvailableOfficer(msg.sender), "Officer: caller is not available");
		require(_isAvailableOfficer(address(this)), "Officer: this contract not available");
		_;
	}
	modifier onlyGovernment() {
		require(_isGovernment(address(this), msg.sender), "Officer: caller is not Government");
		_;
	}
	modifier onlyMonitoring() {
		require(_isMonitoring(address(this), msg.sender), "Officer: caller is not Monitoring");
		_;
	}
	modifier onlyBridging() {
		require(_isBridging(address(this), msg.sender), "Officer: caller is not Bridging");
		_;
	}

	/** --------------------------------------------------------------------------- */

	function isAvailableOfficer(address officer) public view onlyAccepted returns (bool) {
		return _isAvailableOfficer(officer);
	}

	function getOfficerStatus() public view virtual onlyAccepted returns (uint256 status) {
		return _getOfficerStatus(msg.sender); // Can only get your own status
	}

	function isAccepted(address caller) public view onlyAccepted returns (bool) {
		return _getacceptedRole(msg.sender, caller) != 0;
	}

	function getAcceptedRole(address caller) public view virtual onlyAccepted returns (uint256 role) {
		return _getacceptedRole(msg.sender, caller); // Can only get role of caller
	}

	function isGovernment(address caller) public view onlyAccepted returns (bool) {
		return _isGovernment(msg.sender, caller);
	}

	function isMonitoring(address caller) public view onlyAccepted returns (bool) {
		return _isMonitoring(msg.sender, caller);
	}

	function isBridging(address caller) public view onlyAccepted returns (bool) {
		return _isBridging(msg.sender, caller);
	}

	/** --------------------------------------------------------------------------- */
	function setOfficerStatus(address officer, uint256 status) public virtual OnlyAvailableOfficer onlyGovernment {
		_setOfficerStatus(officer, status);
	}

	function setOfficerAcceptedRole(
		address destination,
		address caller,
		uint256 role
	) public virtual OnlyAvailableOfficer onlyGovernment {
		_setAcceptedRole(destination, caller, role); // != 0 = Accepted
	}

	function checking(address destination, address caller)
		public
		view
		OnlyAvailableOfficer
		onlyGovernment
		returns (
			uint256 destination_Status,
			uint256 caller_Status,
			uint256 role_
		)
	{
		destination_Status = _getOfficerStatus(destination);
		caller_Status = _getOfficerStatus(caller);
		role_ = _getacceptedRole(destination, caller);
	}

	function Monitoring() public view virtual OnlyAvailableOfficer onlyMonitoring returns (address[] memory officers) {
		officers = _getOfficer();
		//...
	}

	function Bridging() public view virtual OnlyAvailableOfficer onlyBridging returns (address[] memory officers) {
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