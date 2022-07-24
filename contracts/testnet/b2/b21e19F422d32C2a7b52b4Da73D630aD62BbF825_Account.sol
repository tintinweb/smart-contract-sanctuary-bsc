// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;

import { TokenInfo, IToken } from "./Token.sol";
import { IOfficer } from "./Officer.sol";
import { ArrayAddress } from "./Library.sol";

/**
 * ACCOUNT INFO
 */
struct AccountInfo {
	// address contractOfAccount; // One Account can many contract address.
	address[] accountAddr; // User can only login and deposit using address.
	address[] withdrawAddr; // User can only withdraw (or in bulk) with address.
	mapping(address => uint256) balanceOfTokens; // balance per supported token of the account
	uint256 balanceOfETH;
}

abstract contract AccountData {
	using ArrayAddress for address[];
	IToken public token;

	uint256 private numAccount; // Account ID
	mapping(uint256 => AccountInfo) private accounts;
	mapping(address => uint256) private existed;

	function _isAccount(address _address) internal view returns (bool) {
		return existed[_address] != 0;
	}

	event AccountCreated(address _address, uint256 _timestamp);

	function _creatAccount(address _address) internal {
		existed[_address] = ++numAccount;

		AccountInfo storage newAccount = accounts[numAccount];
		newAccount.accountAddr[0] = _address;

		emit AccountCreated(_address, block.timestamp);
	}

	function _getBalanceOfETH(address _accountSigned) internal view returns (uint256 _balanceOfETH) {
		_balanceOfETH = accounts[existed[_accountSigned]].balanceOfETH;
	}

	function _getBalanceOfTokens(address _accountSigned)
		internal
		returns (TokenInfo[] memory _availableToken, uint256[] memory _balanceOfTokens)
	{
		_availableToken = token.getAvailableToken();
		for (uint256 i = 0; i < _availableToken.length; i++)
			_balanceOfTokens[i] = accounts[existed[_accountSigned]].balanceOfTokens[_availableToken[i].token];
	}

	function _getAccountAddr(address _accountSigned) internal view returns (address[] memory _accountAddr) {
		_accountAddr = accounts[existed[_accountSigned]].accountAddr;
	}

	function _getWithdrawAddr(address _accountSigned) internal view returns (address[] memory _withdrawAddr) {
		_withdrawAddr = accounts[existed[_accountSigned]].withdrawAddr;
	}

	function _addAccountAddr(address _accountSigned, address _address) internal returns (bool) {
		existed[_address] = existed[_accountSigned];
		return accounts[existed[_accountSigned]].accountAddr.add(_address);
	}

	function _removeAccountAddr(address _accountSigned, address _address) internal returns (bool) {
		existed[_address] = 0;
		return accounts[existed[_accountSigned]].accountAddr.remove(_address);
	}

	function _addWithdrawAddr(address _accountSigned, address _address) internal returns (bool) {
		return accounts[existed[_accountSigned]].withdrawAddr.add(_address);
	}

	function _removeWithdrawAddr(address _accountSigned, address _address) internal returns (bool) {
		return accounts[existed[_accountSigned]].withdrawAddr.remove(_address);
	}
}

/*******************************************************************************************************/

interface IAccount {
	function isAccount(address _address) external returns (bool);

	function creatAccount(address _address) external;

	function balanceOfETH(address _accountSigned) external returns (uint256 _balanceOfETH);

	function getTokenOfAccount(address _accountSigned)
		external
		returns (TokenInfo[] memory _availableTokens, uint256[] memory _balanceOfTokens);

	function getAccountAddress(address _accountSigned) external returns (address[] memory _accountAddress);

	function getwithdrawAddress(address _accountSigned) external returns (address[] memory _withdrawAddress);

	function addAccountAddress(address _accountSigned, address _address) external;

	function removeAccountAdress(address _accountSigned, address _address) external;

	function addWithdrawAddress(address _accountSigned, address _address) external;

	function removeWithdrawAddress(address _accountSigned, address _address) external;

	function depositETH(address _accountSigned, uint256 _amount) external;

	function withdrawETH(
		address _accountSigned,
		address _to,
		uint256 _amount
	) external;

	function depositToken(
		address _accountSigned,
		address _token,
		uint256 _amount
	) external;

	function withdrawToken(
		address _accountSigned,
		address _token,
		address _to,
		uint256 _amount
	) external;
}

contract Account is AccountData, IAccount {
	IOfficer public officer;

	constructor(IOfficer _officer, IToken _token) {
		officer = _officer;
		token = _token;
	}

	modifier onlyAccepted() {
		require(officer.hasAccept(msg.sender), "Account: caller not accepted");
		_;
	}

	modifier onlyGovernment() {
		require(officer.hasRole(msg.sender) == 1, "Account: caller is not Government");
		_;
	}
	modifier onlyMonitoring() {
		require(officer.hasRole(msg.sender) == 2, "Account: caller is not Monitoring");
		_;
	}

	modifier checkExistedAccount(address _accountSigned) {
		require(_isAccount(_accountSigned), "Account: does not exist");
		_;
	}

	/*******************************************************************************************************/

	function isAccount(address _address) external onlyAccepted returns (bool) {
		return _isAccount(_address);
	}

	function creatAccount(address _address) external onlyAccepted {
		require(_isAccount(_address) == false, "Account: already exists another");
		require(_address.code.length == 0, "Account: address cannot contract");

		_creatAccount(_address);
	}

	/**********************************************************************************************************
	 *	ACCOUNT INFORMATION FOR DASHBOARD
	 */
	function balanceOfETH(address _accountSigned)
		external
		onlyAccepted
		checkExistedAccount(_accountSigned)
		returns (uint256 _balanceOfETH)
	{
		_balanceOfETH = _getBalanceOfETH(_accountSigned);
	}

	function getTokenOfAccount(address _accountSigned)
		external
		onlyAccepted
		checkExistedAccount(_accountSigned)
		returns (TokenInfo[] memory _availableTokens, uint256[] memory _balanceOfTokens)
	{
		(_availableTokens, _balanceOfTokens) = _getBalanceOfTokens(_accountSigned);
	}

	function getAccountAddress(address _accountSigned)
		external
		onlyAccepted
		checkExistedAccount(_accountSigned)
		returns (address[] memory _accountAddress)
	{
		_accountAddress = _getAccountAddr(_accountSigned);
	}

	function getwithdrawAddress(address _accountSigned)
		external
		onlyAccepted
		checkExistedAccount(_accountSigned)
		returns (address[] memory _withdrawAddress)
	{
		_withdrawAddress = _getWithdrawAddr(_accountSigned);
	}

	/*******************************************************************************************************/
	function addAccountAddress(address _accountSigned, address _address)
		external
		onlyAccepted
		checkExistedAccount(_accountSigned)
	{
		require(_address.code.length == 0, "Account: address cannot contract");

		if (_isAccount(_address)) {
			// _address already exists in another account
			// Chưa xủ lý trường hợp này, tạm thời cho hoàn nguyên
			revert("Account: already exists another");
		} else {
			if (_addAccountAddr(_accountSigned, _address) == false) revert("Account: add address failed");
		}
	}

	function removeAccountAdress(address _accountSigned, address _address)
		external
		onlyAccepted
		checkExistedAccount(_accountSigned)
	{
		if (_removeAccountAddr(_accountSigned, _address) == false) revert("Account: remove address failed");
	}

	function addWithdrawAddress(address _accountSigned, address _address)
		external
		onlyAccepted
		checkExistedAccount(_accountSigned)
	{
		if (_addWithdrawAddr(_accountSigned, _address) == false) revert("Account: add address failed");
	}

	function removeWithdrawAddress(address _accountSigned, address _address)
		external
		onlyAccepted
		checkExistedAccount(_accountSigned)
	{
		if (_removeWithdrawAddr(_accountSigned, _address) == false) revert("Account: remove address failed");
	}

	/**********************************************************************************************************
	 *	DEPOSIT & WITHDRAW
	 */
	function depositETH(address _accountSigned, uint256 _amount)
		external
		onlyAccepted
		checkExistedAccount(_accountSigned)
	{}

	function withdrawETH(
		address _accountSigned,
		address _to,
		uint256 _amount
	) external onlyAccepted checkExistedAccount(_accountSigned) {}

	function depositToken(
		address _accountSigned,
		address _token,
		uint256 _amount
	) external onlyAccepted checkExistedAccount(_accountSigned) {}

	function withdrawToken(
		address _accountSigned,
		address _token,
		address _to,
		uint256 _amount
	) external onlyAccepted checkExistedAccount(_accountSigned) {}
}

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IOfficer } from "./Officer.sol";

/**
 * SUPPORTED TOKEN INFO
 */

struct TokenInfo {
	/**
	 * Status: uint status
	 * 0: Default value. Token is being checked (not available to use).
	 * 1: Available (supported) - Token status allows to use (user can Deposit & Withdraw).
	 * 2: Stoped - Withdraw only. Token will be suspend.
	 * 3: paused - Tokens are still supported, but users are temporarily unable to withdraw and deposit for a short time.
	 * 4: suspended - discontinued. No longer available.
	 * ... : Other extended state.
	 */
	address token; // Address of token supported.
	uint256 chainid; // For providing off-chain services and for statistics.
	uint8 status; // More component states are possible with the SHIFT (Bitwise) operator, instead of just one.
	uint256 volumeOfToken; // total volume of tokens in the contract (in project)
}

abstract contract TokenData {
	uint256 private numToken;
	mapping(uint256 => address) private indexs;
	mapping(address => TokenInfo) private tokens;

	function _isToken(address _token) internal view returns (bool) {
		return ((tokens[_token].token == _token) && (tokens[_token].chainid == block.chainid));
	}

	function _isAvailableToken(address _token) internal view returns (bool) {
		return (_isToken(_token) &&
			(tokens[_token].status == 1 || tokens[_token].status == 2 || tokens[_token].status == 3));
	}

	function _getToken(address _token) internal view returns (TokenInfo memory) {
		return tokens[_token];
	}

	function _getToken() internal view returns (TokenInfo[] memory _tokeninfo) {
		_tokeninfo = new TokenInfo[](numToken);
		for (uint256 i = 0; i < numToken; i++) _tokeninfo[i] = tokens[indexs[i]];
	}

	function _getAvailableToken() internal view returns (TokenInfo[] memory _tokeninfo) {
		uint256 k = 0;
		for (uint256 i = 0; i < numToken; i++) if (_isAvailableToken(indexs[i])) _tokeninfo[k++] = tokens[indexs[i]];
	}

	event TokenAddUpdated(address _token, uint256 _timestamp);
	event TokenDeposited(address _token, uint256 _amount, uint256 _timestamp);
	event TokenWithdrawed(address _token, uint256 _amount, uint256 _timestamp);

	// Everyone can not modify balanceOfToken
	function _addUpdateToken(address _token, uint8 _status) internal returns (TokenInfo memory _tokeninfo) {
		if (_isToken(_token)) {
			// Update exits token
			if (tokens[_token].status != _status) tokens[_token].status = _status;
		} else {
			// Add new token
			indexs[++numToken] = _token;
			tokens[_token] = TokenInfo(_token, block.chainid, _status, 0);
		}
		_tokeninfo = tokens[_token];

		emit TokenAddUpdated(_token, block.timestamp);
	}

	function _tokenDeposit(address _token, uint256 _amount) internal {
		uint256 _oldvolume = tokens[_token].volumeOfToken;
		tokens[_token].volumeOfToken += _amount;
		if (tokens[_token].volumeOfToken != _oldvolume + _amount) revert("Token: deposit failed");

		emit TokenDeposited(_token, _amount, block.timestamp);
	}

	function _tokenWithdraw(address _token, uint256 _amount) internal {
		uint256 _oldvolume = tokens[_token].volumeOfToken;
		if (_oldvolume >= _amount) tokens[_token].volumeOfToken -= _amount;
		else revert("Token: insufficient balance");
		if (tokens[_token].volumeOfToken != _oldvolume - _amount) revert("Token: withdraw failed");

		emit TokenWithdrawed(_token, _amount, block.timestamp);
	}
}

interface IToken {
	function getToken(address _token) external returns (TokenInfo memory _tokeninfo);

	function getAvailableToken() external returns (TokenInfo[] memory _tokeninfo);

	function tokenDeposit(address _token, uint256 _amount) external;

	function tokenWithdraw(address _token, uint256 _amount) external;

	function getToken() external returns (TokenInfo[] memory _tokeninfo);

	function addUpdateToken(IERC20 _token, uint8 _status) external returns (TokenInfo memory _tokeninfo);
}

contract Token is IToken, TokenData {
	using SafeERC20 for IERC20;

	IOfficer public officer;

	constructor(IOfficer _officer) {
		officer = _officer;
	}

	modifier onlyAccepted() {
		require(officer.hasAccept(msg.sender), "Token: caller not accepted");
		_;
	}

	modifier onlyGovernment() {
		require(officer.hasRole(msg.sender) == 1, "Token:caller is not Government");
		_;
	}
	modifier onlyMonitoring() {
		require(officer.hasRole(msg.sender) == 2, "Token:caller is not Monitoring");
		_;
	}

	/*******************************************************************************************************/

	function getToken(address _token) external onlyAccepted returns (TokenInfo memory _tokeninfo) {
		require(_isAvailableToken(_token), "Token:not supported or available");
		_tokeninfo = _getToken(_token);
	}

	// Dashboard view
	function getAvailableToken() external onlyAccepted returns (TokenInfo[] memory _tokeninfo) {
		_tokeninfo = _getAvailableToken();
	}

	function tokenDeposit(address _token, uint256 _amount) external onlyAccepted {
		require(_amount > 0, "Token: amount need more than 0");
		require(_isAvailableToken(_token) && _getToken(_token).status == 1, "Token: deposit not allowed");

		_tokenDeposit(_token, _amount);
	}

	function tokenWithdraw(address _token, uint256 _amount) external onlyAccepted {
		require(_amount > 0, "Token: amount need more than 0");
		require(
			_isAvailableToken(_token) && (_getToken(_token).status == 1 || _getToken(_token).status == 2),
			"Token: withdraw not allowed"
		);

		_tokenWithdraw(_token, _amount);
	}

	/*******************************************************************************************************/

	function getToken() public onlyMonitoring returns (TokenInfo[] memory _tokeninfo) {
		_tokeninfo = _getToken();
	}

	function addUpdateToken(IERC20 _token, uint8 _status) public onlyGovernment returns (TokenInfo memory _tokeninfo) {
		require(address(_token) != address(0), "Token: can not zero address");
		require(address(_token).code.length > 0, "Token: must be contract");
		_tokeninfo = _addUpdateToken(address(_token), _status);
	}
}

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library ArrayAddress {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}