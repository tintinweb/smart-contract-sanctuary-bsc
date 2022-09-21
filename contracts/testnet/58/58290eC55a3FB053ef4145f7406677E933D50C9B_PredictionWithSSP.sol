// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../../access/SSPAccessControls.sol";
import "../../utils/Pausable.sol";
import "../../utils/ReentrancyGuard.sol";
import "../../token/ERC20/IERC20.sol";
import "../../utils/libraries/SafeERC20.sol";
import "../../interfaces/IPrediction.sol";

contract PredictionWithSSP is IPrediction, Pausable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  struct Match {
    string matchName;
    uint256 epoch;
    uint256 startTime;
    uint256 endTime;
    uint256 totalAmount;
    uint256 team1Amount;
    uint256 team2Amount;
    uint256 rewardBaseCalAmount;
    uint256 rewardAmount;
    uint256[2] scores;
    bool finalized;
  }

  uint256 public constant MAX_PROTOCOL_FEE = 1000;
  uint256 public constant BUFFER_SECOND = 300;

  IERC20 public immutable ssp;
  SSPAccessControls public sspAccessControls;
  address public treasury;
  uint256 public minPredictAmount;
  uint256 public protocolFee;
  uint256 public protocolAmount;
  uint256 public currentEpoch;

  mapping(uint256 => mapping(address => PredictInfo)) public ledger;
  mapping(uint256 => Match) public matches;
  mapping(address => uint256[]) public userMatches;

  event Predict(address indexed sender, uint256 indexed epoch, uint256 amount, Position position);
  event Claim(address indexed sender, uint256 indexed epoch, uint256 indexed amount);
  event MatchCreated(uint256 indexed epoch, string matchName);
  event MatchFinalized(uint256 indexed epoch, uint256[2] scores);
  event RewardsCalculated(uint256 indexed epoch, uint256 rewardBaseCalAmount, uint256 rewardAmount, uint256 protocolAmount);

  event NewMinPredictAmount(uint256 indexed epoch, uint256 minPredictAmount);
  event NewProtocolFee(uint256 timestamp, uint256 protocolFee);
  event NewTreasury(address treasury);
  event Pause(uint256 indexed epoch);
  event Unpause(uint256 indexed epoch);
  event ProtocolClaim(uint256 amount);
  event WithdrawToken(address indexed token, uint256 amount);

  modifier onlyAdmin() {
    require(sspAccessControls.hasAdminRole(_msgSender()), "PWT: not admin");
    _;
  }

  modifier onlyAdminOrOperator() {
    require(
      sspAccessControls.hasAdminRole(_msgSender()) ||
      sspAccessControls.hasOperatorRole(_msgSender()),
      "PWT: not admin or operator"
    );
    _;
  }

  modifier notContract() {
    require(!_isContract(_msgSender()), "PWT: is contract");
    require(_msgSender() == tx.origin, "PWT: proxy contract");
    _;
  }

  constructor(
    address _ssp,
    address _sspAccessControls,
    address _treasury,
    uint256 _protocolFee
  ) {
    require(_protocolFee <= MAX_PROTOCOL_FEE, "PWT: high protocol fee");
    ssp = IERC20(_ssp);
    sspAccessControls = SSPAccessControls(_sspAccessControls);
    treasury = _treasury;
    minPredictAmount = 1e19;
    protocolFee = _protocolFee;
  }

  function getUserMatches(address user, uint256 cursor, uint256 size) public view override returns (uint256[] memory, PredictInfo[] memory, uint256) {
    uint256 length = size;
    if (length > userMatches[user].length - cursor) {
      length = userMatches[user].length - cursor;
    }

    uint256[] memory values = new uint256[](length);
    PredictInfo[] memory predictInfo = new PredictInfo[](length);

    for (uint256 i = 0; i < length; i++) {
      values[i] = userMatches[user][cursor + i];
      predictInfo[i] = ledger[values[i]][user];
    }

    return (values, predictInfo, cursor + length);
  }

  function getUserMatchesLength(address user) public view override returns (uint256) {
    return userMatches[user].length;
  }

  function claimable(uint256 epoch, address user) public view override returns (bool) {
    PredictInfo memory predictInfo = ledger[epoch][user];
    Match memory _match = matches[epoch];

    return _match.finalized &&
      predictInfo.amount != 0 &&
      !predictInfo.claimed &&
      (_match.scores[0] == _match.scores[1] ||
      (_match.scores[0] > _match.scores[1] && predictInfo.position == Position.Team1) ||
      (_match.scores[0] < _match.scores[1] && predictInfo.position == Position.Team2));
  }

  function refundable(uint256 epoch, address user) public view override returns (bool) {
    PredictInfo memory predictInfo = ledger[epoch][user];
    Match memory _match = matches[epoch];
    return !_match.finalized &&
      !predictInfo.claimed &&
      block.timestamp < _match.endTime + BUFFER_SECOND &&
      predictInfo.amount != 0;
  }

  function pause() external whenNotPaused onlyAdmin {
    _pause();
    emit Pause(currentEpoch);
  }

  function unpause() external whenPaused onlyAdmin {
    _unpause();
    emit Unpause(currentEpoch);
  }

  function setProtocolFee(uint256 fee) public whenPaused onlyAdmin {
    require(fee <= MAX_PROTOCOL_FEE, "PWT: high protocol fee");
    protocolFee = fee;
    emit NewProtocolFee(block.timestamp, fee);
  }

  function setTreasury(address _treasury) external onlyAdmin {
    require(_treasury != address(0), "PWT: zero address");
    treasury = _treasury;
    emit NewTreasury(_treasury);
  }

  function setMinPredictAmount(uint256 _minPredictAmount) external whenPaused onlyAdmin {
    require(_minPredictAmount != 0, "PWT: 0 amount");
    minPredictAmount = _minPredictAmount;
    emit NewMinPredictAmount(currentEpoch, _minPredictAmount);
  }

  function claimProtocol() external onlyAdmin nonReentrant {
    uint256 currentprotocolAmount = protocolAmount;
    ssp.safeTransfer(treasury, currentprotocolAmount);
    protocolAmount = 0;

    emit ProtocolClaim(currentprotocolAmount);
  }

  function withdrawToken(address _token, uint256 _amount) external onlyAdmin {
    require(_token != address(ssp), "PWT: base token");
    IERC20(_token).safeTransfer(address(_msgSender()), _amount);
    emit WithdrawToken(_token, _amount);
  }

  function createMatch(string memory matchName, uint256 startTime) external whenNotPaused onlyAdminOrOperator {
    ++currentEpoch;
    _createMatch(currentEpoch, matchName, startTime);
  }

  function finaliseMatch(uint256 epoch, uint256[2] memory scores) external whenNotPaused onlyAdminOrOperator {
    _finaliseMatch(epoch, scores);
    _calculateRewards(epoch);
  }

  function predict(uint256 epoch, Position position, uint256 amount) external whenNotPaused nonReentrant notContract {
    require(_predictable(epoch), "PWT: match not predictable");
    require(amount >= minPredictAmount, "PWT: < minPredictAmount");
    require(ledger[epoch][_msgSender()].amount == 0, "PWT: only one predict");

    ssp.safeTransferFrom(_msgSender(), address(this), amount);
    Match storage _match = matches[epoch];
    _match.totalAmount += amount;
    if (position == Position.Team1) {
      _match.team1Amount += amount;
    } else {
      _match.team2Amount += amount;
    }

    PredictInfo storage predictInfo = ledger[epoch][_msgSender()];
    predictInfo.position = position;
    predictInfo.amount = amount;
    userMatches[_msgSender()].push(epoch);

    emit Predict(_msgSender(), epoch, amount, position);
  }

  function claim(uint256[] calldata epochs) external nonReentrant notContract {
    uint256 reward;
    for (uint256 i = 0; i < epochs.length; i++) {
      require(matches[epochs[i]].startTime != 0, "PWT: not started");
      require(block.timestamp > matches[epochs[i]].endTime, "PWT: not ended");

      uint256 addedReward = 0;
      if (matches[epochs[i]].finalized) {
        require(claimable(epochs[i], _msgSender()), "PWT: not eligible to claim");
        Match memory _match = matches[epochs[i]];
        addedReward = (ledger[epochs[i]][_msgSender()].amount * _match.rewardAmount) / _match.rewardBaseCalAmount;
      } else {
        require(refundable(epochs[i], _msgSender()), "PWT: not eligible to refund");
        addedReward = ledger[epochs[i]][_msgSender()].amount;
      }

      ledger[epochs[i]][_msgSender()].claimed = true;
      reward += addedReward;
      emit Claim(_msgSender(), epochs[i], addedReward);
    }

    if (reward > 0) {
      ssp.safeTransfer(_msgSender(), reward);
    }
  }

  function _createMatch(
    uint256 _epoch,
    string memory _matchName,
    uint256 _startTime
  ) internal {
    Match storage _match = matches[_epoch];
    _match.matchName = _matchName;
    _match.startTime = _startTime;
    _match.endTime = _startTime + 90 * 1;
    _match.epoch = _epoch;
    _match.totalAmount = 0;

    emit MatchCreated(_epoch, _matchName);
  }

  function _finaliseMatch(uint256 _epoch, uint256[2] memory _scores) internal {
    require(_epoch <= currentEpoch, "PWT: invalid epoch");
    require(block.timestamp >= matches[_epoch].endTime, "PWT: match not ended");

    Match storage _match = matches[_epoch];
    _match.scores = _scores;
    _match.finalized = true;

    emit MatchFinalized(_epoch, _scores);
  }

  function _predictable(uint256 _epoch) internal view returns (bool) {
    return !matches[_epoch].finalized &&
      matches[_epoch].startTime != 0 &&
      block.timestamp < matches[_epoch].startTime;
  }

  function _calculateRewards(uint256 _epoch) internal {
    require(
      matches[_epoch].rewardBaseCalAmount == 0 &&
      matches[_epoch].rewardAmount == 0,
      "PWT: reward calculated"
    );

    Match storage _match = matches[_epoch];
    uint256 rewardBaseCalAmount;
    uint256 protocolAmt = (_match.totalAmount * protocolFee) / 10000;

    if (_match.scores[0] == _match.scores[1]) {
      rewardBaseCalAmount = _match.totalAmount;
    } else if (_match.scores[0] > _match.scores[1]) {
      rewardBaseCalAmount = _match.team1Amount;
    } else {
      rewardBaseCalAmount = _match.team2Amount;
    }

    _match.rewardBaseCalAmount = rewardBaseCalAmount;
    _match.rewardAmount = _match.totalAmount - protocolAmt;
    protocolAmount += protocolAmt;

    emit RewardsCalculated(_epoch, rewardBaseCalAmount, _match.totalAmount, protocolAmt);
  }

  function _isContract(address _account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(_account)
    }
    return size > 0;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SSPAdminAccess.sol";

contract SSPAccessControls is SSPAdminAccess {
  bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");
  bytes32 public constant TOKEN_MINTER_ROLE = keccak256("TOKEN_MINTER_ROLE");
  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

  event TreasuryRoleGranted(address indexed beneficiary, address indexed caller);
  event TreasuryRoleRemoved(address indexed beneficiary, address indexed caller);
  event OperatorRoleGranted(address indexed beneficiary, address indexed caller);
  event OperatorRoleRemoved(address indexed beneficiary, address indexed caller);
  event TokenMinterRoleGranted(address indexed beneficiary, address indexed caller);
  event TokenMinterRoleRemoved(address indexed beneficiary, address indexed caller);

  function hasTreasuryRole(address _address) public view returns (bool) {
    return hasRole(TREASURY_ROLE, _address);
  }

  function hasTokenMinterRole(address _address) public view returns (bool) {
    return hasRole(TOKEN_MINTER_ROLE, _address);
  }

  function hasOperatorRole(address _address) public view returns (bool) {
    return hasRole(OPERATOR_ROLE, _address);
  }

  function addTreasuryRole(address _beneficiary) external {
    grantRole(TREASURY_ROLE, _beneficiary);
    emit TreasuryRoleGranted(_beneficiary, _msgSender());
  }

  function removeMinterRole(address _beneficiary) external {
    revokeRole(TREASURY_ROLE, _beneficiary);
    emit TreasuryRoleRemoved(_beneficiary, _msgSender());
  }

  function addTokenMinterRole(address _beneficiary) external {
    grantRole(TOKEN_MINTER_ROLE, _beneficiary);
    emit TokenMinterRoleGranted(_beneficiary, _msgSender());
  }

  function removeTokenMinterRole(address _beneficiary) external {
    revokeRole(TOKEN_MINTER_ROLE, _beneficiary);
    emit TokenMinterRoleRemoved(_beneficiary, _msgSender());
  }

  function addOperatorRole(address _beneficiary) external {
    grantRole(OPERATOR_ROLE, _beneficiary);
    emit OperatorRoleGranted(_beneficiary, _msgSender());
  }

  function removeOperatorRole(address _beneficiary) external {
    revokeRole(OPERATOR_ROLE, _beneficiary);
    emit OperatorRoleRemoved(_beneficiary, _msgSender());
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";

abstract contract Pausable is Context {
  bool private _paused;

  event Paused(address account);
  event Unpaused(address account);

  modifier whenNotPaused() {
    require(!paused(), "Pausable: paused");
    _;
  }

  modifier whenPaused() {
    require(paused(), "Pausable: not paused");
    _;
  }

  constructor() {
    _paused = false;
  }

  /**
   * @dev Return true if the contract is paused, and false otherwise
   */
  function paused() public virtual view returns (bool) {
    return _paused;
  }

  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  /**
   * @dev Return to normal state
   */
  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 */

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../token/ERC20/IERC20.sol";
import "./Address.sol";

library SafeERC20 {
  using Address for address;

  function safeTransfer(IERC20 token, address to, uint256 value) internal {
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

  function safeApprove(IERC20 token, address spender, uint256 value) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: 0 allowance"
    );
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    unchecked {
      uint256 oldAllowance = token.allowance(address(this), spender);
      require(oldAllowance >= value, "SafeERC20: value excceed");
      uint256 newAllowance = oldAllowance - value;
      _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low level call failed");
    if (returndata.length > 0) {
      require(abi.decode(returndata, (bool)), "SafeERC20: operation did not succeed");
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPrediction {
  enum Position {
    Team1,
    Team2
  }

  struct PredictInfo {
    Position position;
    uint256 amount;
    bool claimed;
  }

  function getUserMatches(address user, uint256 cursor, uint256 size) external view returns (uint256[] memory, PredictInfo[] memory, uint256);
  function getUserMatchesLength(address user) external view returns (uint256);
  function claimable(uint256 epoch, address user) external view returns (bool);
  function refundable(uint256 epoch, address user) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AccessControl.sol";

contract SSPAdminAccess is AccessControl {
  bool private initAccess;

  event AdminRoleGranted(address indexed beneficiary, address indexed caller);
  event AdminRoleRemoved(address indexed beneficiary, address indexed caller);

  function initAccessControls(address _admin) public {
    require(!initAccess, "Admin: Already initialised");
    require(_admin != address(0), "Admin: zero address");
    _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    initAccess = true;
  }

  function hasAdminRole(address _address) public view returns (bool) {
    return hasRole(DEFAULT_ADMIN_ROLE, _address);
  }

  function addAdminRole(address _beneficiary) external {
    grantRole(DEFAULT_ADMIN_ROLE, _beneficiary);
    emit AdminRoleGranted(_beneficiary, _msgSender());
  }

  function removeAdminRole(address _beneficiary) external {
    revokeRole(DEFAULT_ADMIN_ROLE, _beneficiary);
    emit AdminRoleRemoved(_beneficiary, _msgSender());
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
import "../utils/libraries/EnumerableSet.sol";
import "../utils/introspection/ERC165.sol";
import "../interfaces/IAccessControl.sol";

abstract contract AccessControl is Context, IAccessControl, ERC165 {
  using EnumerableSet for EnumerableSet.AddressSet;

  struct RoleData {
    EnumerableSet.AddressSet members;
    bytes32 adminRole;
  }

  mapping(bytes32 => RoleData) private _roles;
  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
  }

  function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
    return _roles[role].members.contains(account);
  }

  function getRoleMemberCount(bytes32 role) public view returns (uint256) {
    return _roles[role].members.length();
  }

  function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
    return _roles[role].members.at(index);
  }

  function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
    return _roles[role].adminRole;
  }

  function grantRole(bytes32 role, address account) public virtual override {
    require(hasRole(_roles[role].adminRole, _msgSender()), "AC: must be an admin");
    _grantRole(role, account);
  }

  function revokeRole(bytes32 role, address account) public virtual override {
    require(hasRole(_roles[role].adminRole, _msgSender()), "AC: must be an admin");
    _revokeRole(role, account);
  }

  function renounceRole(bytes32 role, address account) public virtual override {
    require(account == _msgSender(), "AC: must renounce yourself");
    _revokeRole(role, account);
  }

  function _setupRole(bytes32 role, address account) internal virtual {
    _grantRole(role, account);
  }

  function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
    emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
    _roles[role].adminRole = adminRole;
  }

  function _grantRole(bytes32 role, address account) private {
    if (_roles[role].members.add(account)) {
      emit RoleGranted(role, account, _msgSender());
    }
  }

  function _revokeRole(bytes32 role, address account) private {
    if (_roles[role].members.remove(account)) {
      emit RoleRevoked(role, account, _msgSender());
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library EnumerableSet {
  struct Set {
    bytes32[] _values;
    mapping (bytes32 => uint256) _indexes;
  }

  /**
    * @dev Add a value to a set. O(1).
    *
    * Returns true if the value was added to the set, that is if it was not
    * already present.
    */
  function _add(Set storage set, bytes32 value) private returns (bool) {
    if (!_contains(set, value)) {
      set._values.push(value);
      // The value is stored at length-1, but we add 1 to all indexes
      // and use 0 as a sentinel value
      set._indexes[value] = set._values.length;
      return true;
    } else {
      return false;
    }
  }

  /**
    * @dev Removes a value from a set. O(1).
    *
    * Returns true if the value was removed from the set, that is if it was
    * present.
    */
  function _remove(Set storage set, bytes32 value) private returns (bool) {
    // We read and store the value's index to prevent multiple reads from the same storage slot
    uint256 valueIndex = set._indexes[value];

    if (valueIndex != 0) { // Equivalent to contains(set, value)
      // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
      // the array, and then remove the last element (sometimes called as 'swap and pop').
      // This modifies the order of the array, as noted in {at}.

      uint256 toDeleteIndex = valueIndex - 1;
      uint256 lastIndex = set._values.length - 1;

      // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
      // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

      bytes32 lastvalue = set._values[lastIndex];

      // Move the last value to the index where the value to delete is
      set._values[toDeleteIndex] = lastvalue;
      // Update the index for the moved value
      set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

      // Delete the slot where the moved value was stored
      set._values.pop();

      // Delete the index for the deleted slot
      delete set._indexes[value];

      return true;
    } else {
      return false;
    }
  }

  /**
    * @dev Returns true if the value is in the set. O(1).
    */
  function _contains(Set storage set, bytes32 value) private view returns (bool) {
    return set._indexes[value] != 0;
  }

  /**
    * @dev Returns the number of values on the set. O(1).
    */
  function _length(Set storage set) private view returns (uint256) {
    return set._values.length;
  }

  /**
  * @dev Returns the value stored at position `index` in the set. O(1).
  *
  * Note that there are no guarantees on the ordering of values inside the
  * array, and it may change when more values are added or removed.
  *
  * Requirements:
  *
  * - `index` must be strictly less than {length}.
  */
  function _at(Set storage set, uint256 index) private view returns (bytes32) {
    require(set._values.length > index, "EnumerableSet: index out of bounds");
    return set._values[index];
  }

  // Bytes32Set

  struct Bytes32Set {
    Set _inner;
  }

  /**
    * @dev Add a value to a set. O(1).
    *
    * Returns true if the value was added to the set, that is if it was not
    * already present.
    */
  function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _add(set._inner, value);
  }

  /**
    * @dev Removes a value from a set. O(1).
    *
    * Returns true if the value was removed from the set, that is if it was
    * present.
    */
  function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _remove(set._inner, value);
  }

  /**
    * @dev Returns true if the value is in the set. O(1).
    */
  function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
    return _contains(set._inner, value);
  }

  /**
    * @dev Returns the number of values in the set. O(1).
    */
  function length(Bytes32Set storage set) internal view returns (uint256) {
    return _length(set._inner);
  }

  /**
  * @dev Returns the value stored at position `index` in the set. O(1).
  *
  * Note that there are no guarantees on the ordering of values inside the
  * array, and it may change when more values are added or removed.
  *
  * Requirements:
  *
  * - `index` must be strictly less than {length}.
  */
  function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
    return _at(set._inner, index);
  }

  // AddressSet

  struct AddressSet {
    Set _inner;
  }

  /**
    * @dev Add a value to a set. O(1).
    *
    * Returns true if the value was added to the set, that is if it was not
    * already present.
    */
  function add(AddressSet storage set, address value) internal returns (bool) {
    return _add(set._inner, bytes32(uint256(uint160(value))));
  }

  /**
    * @dev Removes a value from a set. O(1).
    *
    * Returns true if the value was removed from the set, that is if it was
    * present.
    */
  function remove(AddressSet storage set, address value) internal returns (bool) {
    return _remove(set._inner, bytes32(uint256(uint160(value))));
  }

  /**
    * @dev Returns true if the value is in the set. O(1).
    */
  function contains(AddressSet storage set, address value) internal view returns (bool) {
    return _contains(set._inner, bytes32(uint256(uint160(value))));
  }

  /**
    * @dev Returns the number of values in the set. O(1).
    */
  function length(AddressSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }

  /**
  * @dev Returns the value stored at position `index` in the set. O(1).
  *
  * Note that there are no guarantees on the ordering of values inside the
  * array, and it may change when more values are added or removed.
  *
  * Requirements:
  *
  * - `index` must be strictly less than {length}.
  */
  function at(AddressSet storage set, uint256 index) internal view returns (address) {
      return address(uint160(uint256(_at(set._inner, index))));
  }


  // UintSet

  struct UintSet {
    Set _inner;
  }

  /**
    * @dev Add a value to a set. O(1).
    *
    * Returns true if the value was added to the set, that is if it was not
    * already present.
    */
  function add(UintSet storage set, uint256 value) internal returns (bool) {
    return _add(set._inner, bytes32(value));
  }

  /**
    * @dev Removes a value from a set. O(1).
    *
    * Returns true if the value was removed from the set, that is if it was
    * present.
    */
  function remove(UintSet storage set, uint256 value) internal returns (bool) {
    return _remove(set._inner, bytes32(value));
  }

  /**
    * @dev Returns true if the value is in the set. O(1).
    */
  function contains(UintSet storage set, uint256 value) internal view returns (bool) {
    return _contains(set._inner, bytes32(value));
  }

  /**
    * @dev Returns the number of values on the set. O(1).
    */
  function length(UintSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }

  /**
  * @dev Returns the value stored at position `index` in the set. O(1).
  *
  * Note that there are no guarantees on the ordering of values inside the
  * array, and it may change when more values are added or removed.
  *
  * Requirements:
  *
  * - `index` must be strictly less than {length}.
  */
  function at(UintSet storage set, uint256 index) internal view returns (uint256) {
    return uint256(_at(set._inner, index));
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAccessControl {
  /**
    * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
    *
    * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
    * {RoleAdminChanged} not being emitted signaling this.
    */
  event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

  /**
    * @dev Emitted when `account` is granted `role`.
    *
    * `sender` is the account that originated the contract call, an admin role
    * bearer except when using {AccessControl-_setupRole}.
    */
  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

  /**
    * @dev Emitted when `account` is revoked `role`.
    *
    * `sender` is the account that originated the contract call:
    *   - if using `revokeRole`, it is the admin role bearer
    *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
    */
  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  /**
    * @dev Returns `true` if `account` has been granted `role`.
    */
  function hasRole(bytes32 role, address account) external view returns (bool);

  /**
    * @dev Returns the admin role that controls `role`. See {grantRole} and
    * {revokeRole}.
    *
    * To change a role's admin, use {AccessControl-_setRoleAdmin}.
    */
  function getRoleAdmin(bytes32 role) external view returns (bytes32);

  /**
    * @dev Grants `role` to `account`.
    *
    * If `account` had not been already granted `role`, emits a {RoleGranted}
    * event.
    *
    * Requirements:
    *
    * - the caller must have ``role``'s admin role.
    */
  function grantRole(bytes32 role, address account) external;

  /**
    * @dev Revokes `role` from `account`.
    *
    * If `account` had been granted `role`, emits a {RoleRevoked} event.
    *
    * Requirements:
    *
    * - the caller must have ``role``'s admin role.
    */
  function revokeRole(bytes32 role, address account) external;

  /**
    * @dev Revokes `role` from the calling account.
    *
    * Roles are often managed via {grantRole} and {revokeRole}: this function's
    * purpose is to provide a mechanism for accounts to lose their privileges
    * if they are compromised (such as when a trusted device is misplaced).
    *
    * If the calling account had been granted `role`, emits a {RoleRevoked}
    * event.
    *
    * Requirements:
    *
    * - the caller must be `account`.
    */
  function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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