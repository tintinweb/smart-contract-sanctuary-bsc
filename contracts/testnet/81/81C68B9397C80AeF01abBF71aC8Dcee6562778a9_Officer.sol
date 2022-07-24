// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;

/**
 * ROLE INFO
 */

struct RoleInfo {
	uint256 roleID; // used as the main role instead of role status.
	bytes32 name;
	// Use as a supporting role, if you wish.
	uint8 status; // More component states are possible with the SHIFT operator, instead of just one.
}

abstract contract RoleData {
	uint256 private numRole;
	mapping(uint256 => RoleInfo) private roles;

	function _isExistsRole(uint256 _roleID) internal view returns (bool) {
		return (_roleID != 0 && roles[_roleID].roleID == _roleID);
	}

	function _getRole(uint256 _roleID) internal view returns (RoleInfo memory) {
		return roles[_roleID];
	}

	function _getRole() internal view returns (RoleInfo[] memory _roles) {
		_roles = new RoleInfo[](numRole);
		for (uint256 i = 0; i < numRole; i++) _roles[i] = roles[i];
	}

	event RoleAddUpdated(uint256 _roleID, uint256 _timestamp);

	function _addUpdateRole(
		uint256 _roleID, /** _roleID = 0 to ADD NEW ROLE */
		bytes32 _name,
		uint8 _status
	) internal returns (RoleInfo memory _role) {
		require(_roleID <= numRole, "Role: outof range! = 0 to addnew");

		if (_isExistsRole(_roleID)) {
			// Update existed role
			if (roles[_roleID].status != _status) roles[_roleID].status = _status;
			if (_name != bytes32(0) && roles[_roleID].name != bytes32(_name)) roles[_roleID].name = bytes32(_name);
		} else if (_roleID == 0) {
			// Add new role
			_roleID = ++numRole;
			_name = (bytes32(_name) == bytes32(0)) ? bytes32("NewRole") : bytes32(_name);
			roles[_roleID] = RoleInfo(_roleID, _name, _status);
		}
		_role = roles[_roleID];

		emit RoleAddUpdated(_roleID, block.timestamp);
	}
}

/**
 * OFFICER INFO
 */

struct OfficerInfo {
	/**
	 * Status: uint256 status
	 * 0: Default value. Contract is being checked (not available to use).
	 * 1: Available - Office contract is available.
	 * 2: Paused / Stoped - Contracts are still supported, but users will not be able to use for a short time.
	 * 3: suspended - discontinued. No longer available.
	 * ... : Other extended state.
	 **/
	address officer; // Address of professional contract.
	uint256 chainid; // For providing off-chain services and statistics.
	uint8 status; // More component states are possible with the SHIFT (Bitwise) operator, instead of just one.
	bytes32 uniKey; // Unique key across networks (any chain). The difference between all contracts on a chain.

	// uint256 roleID; <= Tạo ROLE tự động và bắt buộc các đối tượng officer khác hasRole = roleID để truy cập.
}

abstract contract OfficerData {
	uint256 private numOfficer;
	mapping(uint256 => address) private indexs;
	mapping(address => OfficerInfo) private officers;

	function _isOfficer(address _officer) internal view returns (bool) {
		return (officers[_officer].officer == _officer && officers[_officer].chainid == block.chainid);
	}

	function _isAvailableOfficer(address _officer) internal view returns (bool) {
		return _isOfficer(_officer) && officers[_officer].status == 1;
	}

	function _getOfficer(address _officer) internal view returns (OfficerInfo memory) {
		return officers[_officer];
	}

	function _getOfficer() internal view returns (OfficerInfo[] memory _officers) {
		_officers = new OfficerInfo[](numOfficer);
		for (uint256 i = 0; i < numOfficer; i++) _officers[i] = officers[indexs[i]];
	}

	event OfficerAddUpdated(address _officer, uint256 _timestamp);

	function _addupdateOfficer(
		address _officer,
		uint8 _status,
		bytes32 _unikey
	) internal returns (OfficerInfo memory _officerInfo) {
		if (_isOfficer(_officer)) {
			// Update existed officer
			if (officers[_officer].status != _status) officers[_officer].status = _status;
			if ((_unikey != bytes32(0)) && (officers[_officer].uniKey != _unikey)) officers[_officer].uniKey = _unikey;
		} else {
			// Add new officer
			numOfficer++;
			_unikey = (_unikey != bytes32(0)) ? _unikey : keccak256(abi.encodePacked(_officer, numOfficer));

			indexs[numOfficer] = _officer;
			officers[_officer] = OfficerInfo(_officer, block.chainid, _status, _unikey);
		}
		_officerInfo = officers[_officer];

		emit OfficerAddUpdated(_officer, block.timestamp);
	}
}

/**
 * OFFICER CONTRACT
 */

interface IOfficer {
	function hasAccept(address _callerOfficer) external returns (bool _accepted);

	function hasRole(address _callerOfficer) external returns (uint256 _roleID);

	function getRole(uint256 _roleID) external returns (RoleInfo memory);

	// function isExistsRole(uint256 _roleID) external returns (bool);
	function isAvailableOfficer(address _officer) external returns (bool);

	function getOfficer(address _officer) external returns (OfficerInfo memory);
}

contract Officer is RoleData, OfficerData, IOfficer {
	// Officer can access another Officer with role. (Caller_Destination_RoleID).
	mapping(address => mapping(address => uint256)) private acceptedRole;

	constructor() {
		_addUpdateRole(0, "Government", 1);
		_addUpdateRole(0, "Monitoring", 2); // Statistics, analytics.
		_addUpdateRole(0, "Bridging", 3); // For providing off-chain services.
		_addUpdateRole(0, "CallerAccepted", 4); // Deafault value for all professional contract (officer objects).
		

		_addupdateOfficer(address(this), 1, bytes32(0)); // Activate Officer Service
		_addUpdateRole(0, "Officer", 5); // Other officers has role 5 are allowed access to the contract Officer. 

		_addupdateOfficer(msg.sender, 1, bytes32(0));
		acceptedRole[msg.sender][address(this)] = 1; // Government
	}

	modifier checkAvailable() {
		require(_isAvailableOfficer(msg.sender), "Officer: caller not available");
		require(_isAvailableOfficer(address(this)), "Officer contract not available");
		_;
	}

	modifier onlyAccepted() {
		require(_isExistsRole(acceptedRole[msg.sender][address(this)]), "Officer: caller not accepted yet");
		_;
	}

	modifier onlyGovernment() {
		require(acceptedRole[msg.sender][address(this)] == 1, "Officer:caller is not Government");
		_;
	}
	modifier onlyMonitoring() {
		require(acceptedRole[msg.sender][address(this)] == 2, "Officer:caller is not Monitoring");
		_;
	}

	/*******************************************************************************************************/

	function setAcceptedAndRole(
		address _caller,
		address _destination,
		uint256 _role
	) public checkAvailable onlyGovernment {
		require(_isAvailableOfficer(_destination) && _destination != address(0), "Officer: dest not available");
		require(_isAvailableOfficer(_caller) && _caller != address(0), "Officer: caller not available");
		require(_isExistsRole(_role), "Officer: role does not exist");

		acceptedRole[_caller][_destination] = _role;
	}

	function addUpdateRole(
		uint256 _roleID,
		bytes32 _name,
		uint8 _status
	) public checkAvailable onlyGovernment returns (RoleInfo memory) {
		return _addUpdateRole(_roleID, _name, _status);
	}

	function addupdateOfficer(
		address _officer,
		uint8 _status,
		bytes32 _unikey
	) public checkAvailable onlyGovernment returns (OfficerInfo memory) {
		require(_officer != address(0), "Officer: can not zero address");
		return _addupdateOfficer(_officer, _status, _unikey);
	}

	/*******************************************************************************************************/

	function getAcceptedRole() external view checkAvailable onlyMonitoring returns (bytes[][][] memory _acceptedRole) {
		_acceptedRole = new bytes[][][](10);
	}

	function getRole() external view checkAvailable onlyMonitoring returns (RoleInfo[] memory) {
		return _getRole();
	}

	function getOfficer() external view checkAvailable onlyMonitoring returns (OfficerInfo[] memory) {
		return _getOfficer();
	}

	/*******************************************************************************************************/

	function hasAccept(address _callerOfficer) external view checkAvailable onlyAccepted returns (bool _accepted) {
		require(_isAvailableOfficer(_callerOfficer), "Officer: caller not available");
		_accepted = _isExistsRole(acceptedRole[_callerOfficer][msg.sender]);
	}

	function hasRole(address _callerOfficer) external view checkAvailable onlyAccepted returns (uint256 _roleID) {
		require(this.hasAccept(_callerOfficer), "Officer: caller not accepted");
		_roleID = acceptedRole[_callerOfficer][msg.sender];
	}

	function getRole(uint256 _roleID) external view checkAvailable onlyAccepted returns (RoleInfo memory) {
		require(_isExistsRole(_roleID), "Role: role does not exist");
		return _getRole(_roleID);
	}

	// function isExistsRole(uint256 _roleID) external view checkAvailable onlyAccepted returns (bool) {
	// 	return _isExistsRole(_roleID);
	// }

	function isAvailableOfficer(address _officer) external view checkAvailable onlyAccepted returns (bool) {
		return _isAvailableOfficer(_officer);
	}

	function getOfficer(address _officer) external view checkAvailable onlyAccepted returns (OfficerInfo memory) {
		require(_isOfficer(_officer), "Officer: is not officer");
		return _getOfficer(_officer);
	}
}