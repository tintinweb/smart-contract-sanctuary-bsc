/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// Sources flattened with hardhat v2.10.1 https://hardhat.org

// File contracts/compliance/Blocklist.sol

pragma solidity 0.5.16;

/**
 * @title Blocklist
 * @dev This contract manages a list of addresses and has a simple CRUD
 */
contract Blocklist {
  bytes32 internal constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

  /**
   * @dev The operator
   */
  address public operator;

  /**
   * @dev The index of each user in the list
   */
  mapping(address => uint256) private _userIndex;

  /**
   * @dev The list itself
   */
  address[] private _userList;

  /**
   * @notice Event emitted when a user is added to the blocklist
   */
  event addedToBlocklist(address indexed account, address by);

  /**
   * @notice Event emitted when a user is removed from the blocklist
   */
  event removedFromBlocklist(address indexed account, address by);

  /**
   * @notice Modifier to forbid access from non-operators
   */
  modifier onlyOperator() {
    require(msg.sender == operator, "Only operator");
    _;
  }

  /**
   * @notice Modifier to facilitate checking the blocklist
   */
  modifier onlyInBlocklist(address account) {
    require(isBlocklisted(account), "Not in blocklist");
    _;
  }

  /**
   * @notice Modifier to facilitate checking the blocklist
   */
  modifier onlyNotInBlocklist(address account) {
    require(!isBlocklisted(account), "Already in blocklist");
    _;
  }

  constructor() public {
    operator = msg.sender;
  }

  function changeOperator(address newOperator) public onlyOperator {
    operator = newOperator;
  }

  /**
   * @dev Adds an address to the blocklist
   * @param account The address to add
   * @return true if the operation succeeded
   * @dev Fails if the address was already blocklisted
   */
  function _addToBlocklist(address account) private onlyNotInBlocklist(account) returns (bool) {
    _userIndex[account] = _userList.length;
    _userList.push(account);

    emit addedToBlocklist(account, msg.sender);

    return true;
  }

  /**
   * @notice Adds many addresses to the blocklist at once
   * @param accounts[] The list of addresses to add
   * @dev Fails if at least one of the addresses was already blocklisted
   */
  function batchAddToBlocklist(address[] calldata accounts) external onlyOperator {
    for (uint256 i = 0; i < accounts.length; i++) {
      require(_addToBlocklist(accounts[i]));
    }
  }

  /**
   * @notice Adds an address to the blocklist
   * @param account The address to add
   * @return true if the operation succeeded
   * @dev Fails if the address was already blocklisted
   */
  function addToBlocklist(address account) external onlyOperator returns (bool) {
    return _addToBlocklist(account);
  }

  /**
   * @dev Removes an address from the blocklist
   * @param account The address to remove
   * @return true if the operation succeeds
   * @dev Fails if the address was not blocklisted
   */
  function _removeFromBlocklist(address account) private onlyInBlocklist(account) returns (bool) {
    uint256 rowToDelete = _userIndex[account];
    address keyToMove = _userList[_userList.length - 1];
    _userList[rowToDelete] = keyToMove;
    _userIndex[keyToMove] = rowToDelete;
    _userList.length--;

    emit removedFromBlocklist(account, msg.sender);

    return true;
  }

  /**
   * @notice Removes many addresses from the blocklist at once
   * @param accounts[] The list of addresses to remove
   * @dev Fails if at least one of the addresses was not blocklisted
   */
  function batchRemoveFromBlocklist(address[] calldata accounts) external onlyOperator {
    for (uint256 i = 0; i < accounts.length; i++) {
      require(_removeFromBlocklist(accounts[i]));
    }
  }

  /**
   * @notice Removes an address from the blocklist
   * @param account The address to remove
   * @dev Fails if the address was not blocklisted
   * @return true if the operation succeeded
   */
  function removeFromBlocklist(address account) external onlyOperator returns (bool) {
    return _removeFromBlocklist(account);
  }

  /**
   * @notice Consults whether an address is blocklisted
   * @param account The address to check
   * @return bool True if the address is blocklisted
   */
  function isBlocklisted(address account) public view returns (bool) {
    if (_userList.length == 0) return false;

    // We don't want to throw when querying for an out-of-bounds index.
    // It can happen when the list has been shrunk after a deletion.
    if (_userIndex[account] >= _userList.length) return false;

    return _userList[_userIndex[account]] == account;
  }

  /**
   * @notice Fetches the list of all blocklisted addresses
   * @return array The list of currently blocklisted addresses
   */
  function getFullList() public view returns (address[] memory) {
    return _userList;
  }
}