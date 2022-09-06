/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// IERC20.sol file
pragma solidity ^0.7.0;
interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// IDetailedERC20.sol file
pragma solidity ^0.7.3;
interface IDetailedERC20 is IERC20 {
  function name() external returns (string memory);
  function symbol() external returns (string memory);
  function decimals() external returns (uint8);
}

// Context.sol file
pragma solidity >=0.6.0 <0.8.0;
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }
  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// Ownable.sol file
pragma solidity ^0.7.0;
abstract contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }
  function owner() public view virtual returns (address) {
    return _owner;
  }
  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// ReentrancyGuard.sol file
pragma solidity ^0.7.0;
abstract contract ReentrancyGuard {
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor () {
    _status = _NOT_ENTERED;
  }
  modifier nonReentrant() {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
    _;
    _status = _NOT_ENTERED;
  }
}

// Math.sol file
pragma solidity ^0.7.0;
library Math {
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
  function average(uint256 a, uint256 b) internal pure returns (uint256) {
    // (a + b) / 2 can overflow, so we distribute
    return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
  }
}

// SafeMath.sol file
pragma solidity ^0.7.0;
library SafeMath {
  function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    uint256 c = a + b;
    if (c < a) return (false, 0);
    return (true, c);
  }
  function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b > a) return (false, 0);
    return (true, a - b);
  }
  function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (a == 0) return (true, 0);
    uint256 c = a * b;
    if (c / a != b) return (false, 0);
    return (true, c);
  }
  function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a / b);
  }
  function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    if (b == 0) return (false, 0);
    return (true, a % b);
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: modulo by zero");
    return a % b;
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    return a - b;
  }
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a / b;
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a % b;
  }
}

// Address.sol file
pragma solidity ^0.7.0;
library Address {
  function isContract(address account) internal view returns (bool) {
    // This method relies on extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.

    uint256 size;
    // solhint-disable-next-line no-inline-assembly
    assembly { size := extcodesize(account) }
    return size > 0;
  }
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{ value: amount }("");
    require(success, "Address: unable to send value, recipient may have reverted");
  }
  function functionCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionCall(target, data, "Address: low-level call failed");
  }
  function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    return functionCallWithValue(target, data, 0, errorMessage);
  }
  function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
    return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
  }
  function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
    require(address(this).balance >= value, "Address: insufficient balance for call");
    require(isContract(target), "Address: call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{ value: value }(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }
  function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
    return functionStaticCall(target, data, "Address: low-level static call failed");
  }
  function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
    require(isContract(target), "Address: static call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.staticcall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }
  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    return functionDelegateCall(target, data, "Address: low-level delegate call failed");
  }
  function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
    require(isContract(target), "Address: delegate call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {
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

// SafeERC20.sol file
pragma solidity ^0.7.0;
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
      _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
      _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
      // solhint-disable-next-line max-line-length
      require((value == 0) || (token.allowance(address(this), spender) == 0),
        "SafeERC20: approve from non-zero to non-zero allowance"
      );
      _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
      uint256 newAllowance = token.allowance(address(this), spender).add(value);
      _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
      uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
      _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
      bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
      if (returndata.length > 0) { // Return data is optional
        // solhint-disable-next-line max-line-length
        require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
      }
    }
}

//FixedPointMath.sol file
pragma solidity ^0.7.3;
library FixedPointMath {
  uint256 public constant DECIMALS = 18;
  uint256 public constant SCALAR = 10**DECIMALS;
  struct FixedDecimal {
    uint256 x;
  }
  function fromU256(uint256 value) internal pure returns (FixedDecimal memory) {
    uint256 x;
    require(value == 0 || (x = value * SCALAR) / SCALAR == value);
    return FixedDecimal(x);
  }
  function maximumValue() internal pure returns (FixedDecimal memory) {
    return FixedDecimal(uint256(-1));
  }
  function add(FixedDecimal memory self, FixedDecimal memory value) internal pure returns (FixedDecimal memory) {
    uint256 x;
    require((x = self.x + value.x) >= self.x);
    return FixedDecimal(x);
  }
  function add(FixedDecimal memory self, uint256 value) internal pure returns (FixedDecimal memory) {
    return add(self, fromU256(value));
  }
  function sub(FixedDecimal memory self, FixedDecimal memory value) internal pure returns (FixedDecimal memory) {
    uint256 x;
    require((x = self.x - value.x) <= self.x);
    return FixedDecimal(x);
  }
  function sub(FixedDecimal memory self, uint256 value) internal pure returns (FixedDecimal memory) {
    return sub(self, fromU256(value));
  }
  function mul(FixedDecimal memory self, uint256 value) internal pure returns (FixedDecimal memory) {
    uint256 x;
    require(value == 0 || (x = self.x * value) / value == self.x);
    return FixedDecimal(x);
  }
  function div(FixedDecimal memory self, uint256 value) internal pure returns (FixedDecimal memory) {
    require(value != 0);
    return FixedDecimal(self.x / value);
  }
  function cmp(FixedDecimal memory self, FixedDecimal memory value) internal pure returns (int256) {
    if (self.x < value.x) {
      return -1;
    }
    if (self.x > value.x) {
      return 1;
    }
    return 0;
  }
  function decode(FixedDecimal memory self) internal pure returns (uint256) {
    return self.x / SCALAR;
  }
}

// IERC721.sol file
pragma solidity ^0.7.3;
interface IERC721 {
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  function balanceOf(address owner) external view returns (uint256 balance);
  function ownerOf(uint256 tokenId) external view returns (address owner);
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
  function transferFrom(address from, address to, uint256 tokenId) external;
  function approve(address to, uint256 tokenId) external;
  function getApproved(uint256 tokenId) external view returns (address operator);
  function setApprovalForAll(address operator, bool _approved) external;
  function isApprovedForAll(address owner, address operator) external view returns (bool);
  function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
  function getTokenLevel(uint256 tokenId) external view returns (uint256 level);
}


// Pool.sol file
pragma solidity ^0.7.3;
library Pool {
  using FixedPointMath for FixedPointMath.FixedDecimal;
  using Pool for Pool.Data;
  using Pool for Pool.List;
  using SafeMath for uint256;

  struct Context {
    uint256 rewardRate;
    uint256 totalRewardWeight;
  }

  struct Data {
    IERC721 token;
    uint256 totalDeposited;
    uint256 rewardWeight;
    FixedPointMath.FixedDecimal accumulatedRewardWeight;
    uint256 lastUpdatedBlock;
  }

  struct List {
    Data[] elements;
  }
  function update(Data storage _data, Context storage _ctx) internal {
    _data.accumulatedRewardWeight = _data.getUpdatedAccumulatedRewardWeight(_ctx);
    _data.lastUpdatedBlock = block.number;
  }
  function getRewardRate(Data storage _data, Context storage _ctx) internal view returns (uint256) {
    return _ctx.rewardRate.mul(_data.rewardWeight).div(_ctx.totalRewardWeight);
  }
  function getUpdatedAccumulatedRewardWeight(Data storage _data, Context storage _ctx)
    internal view
    returns (FixedPointMath.FixedDecimal memory)
  {
    if (_data.totalDeposited == 0) {
      return _data.accumulatedRewardWeight;
    }

    uint256 _elapsedTime = block.number.sub(_data.lastUpdatedBlock);
    if (_elapsedTime == 0) {
      return _data.accumulatedRewardWeight;
    }

    uint256 _rewardRate = _data.getRewardRate(_ctx);
    uint256 _distributeAmount = _rewardRate.mul(_elapsedTime);

    if (_distributeAmount == 0) {
      return _data.accumulatedRewardWeight;
    }

    FixedPointMath.FixedDecimal memory _rewardWeight = FixedPointMath.fromU256(_distributeAmount).div(_data.totalDeposited);
    return _data.accumulatedRewardWeight.add(_rewardWeight);
  }
  function push(List storage _self, Data memory _element) internal {
    _self.elements.push(_element);
  }
  function get(List storage _self, uint256 _index) internal view returns (Data storage) {
    return _self.elements[_index];
  }
  function last(List storage _self) internal view returns (Data storage) {
    return _self.elements[_self.lastIndex()];
  }
  function lastIndex(List storage _self) internal view returns (uint256) {
    uint256 _length = _self.length();
    return _length.sub(1, "Pool.List: list is empty");
  }
  function length(List storage _self) internal view returns (uint256) {
    return _self.elements.length;
  }
}

// Stake.sol file
pragma solidity ^0.7.3;
library Stake {
  using FixedPointMath for FixedPointMath.FixedDecimal;
  using Pool for Pool.Data;
  using SafeMath for uint256;
  using Stake for Stake.Data;

  struct Data {
    uint256 totalDeposited;
    uint256 totalUnclaimed;
    FixedPointMath.FixedDecimal lastAccumulatedWeight;
  }

  function update(Data storage _self, Pool.Data storage _pool, Pool.Context storage _ctx) internal {
    _self.totalUnclaimed = _self.getUpdatedTotalUnclaimed(_pool, _ctx);
    _self.lastAccumulatedWeight = _pool.getUpdatedAccumulatedRewardWeight(_ctx);
  }

  function getUpdatedTotalUnclaimed(Data storage _self, Pool.Data storage _pool, Pool.Context storage _ctx)
    internal view
    returns (uint256)
  {
    FixedPointMath.FixedDecimal memory _currentAccumulatedWeight = _pool.getUpdatedAccumulatedRewardWeight(_ctx);
    FixedPointMath.FixedDecimal memory _lastAccumulatedWeight = _self.lastAccumulatedWeight;

    if (_currentAccumulatedWeight.cmp(_lastAccumulatedWeight) == 0) {
      return _self.totalUnclaimed;
    }

    uint256 _distributedAmount = _currentAccumulatedWeight
      .sub(_lastAccumulatedWeight)
      .mul(_self.totalDeposited)
      .decode();

    return _self.totalUnclaimed.add(_distributedAmount);
  }
}

// IERC721Receiver.sol file
pragma solidity ^0.7.0;
interface IERC721Receiver {
  function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

// ERC721Holder.sol file
pragma solidity ^0.7.0;
contract ERC721Holder is IERC721Receiver {
  function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
    return this.onERC721Received.selector;
  }
}

// EnumerableSet.sol file
pragma solidity ^0.7.0;
library EnumerableSet {
  struct Set {
    // Storage of set values
    bytes32[] _values;

    // Position of the value in the `values` array, plus 1 because index 0
    // means a value is not in the set.
    mapping (bytes32 => uint256) _indexes;
  }
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
  function _contains(Set storage set, bytes32 value) private view returns (bool) {
    return set._indexes[value] != 0;
  }
  function _length(Set storage set) private view returns (uint256) {
    return set._values.length;
  }
  function _at(Set storage set, uint256 index) private view returns (bytes32) {
    require(set._values.length > index, "EnumerableSet: index out of bounds");
    return set._values[index];
  }

  // Bytes32Set
  struct Bytes32Set {
    Set _inner;
  }
  function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _add(set._inner, value);
  }
  function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _remove(set._inner, value);
  }
  function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
    return _contains(set._inner, value);
  }
  function length(Bytes32Set storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
    return _at(set._inner, index);
  }

  // AddressSet
  struct AddressSet {
    Set _inner;
  }
  function add(AddressSet storage set, address value) internal returns (bool) {
    return _add(set._inner, bytes32(uint256(uint160(value))));
  }
  function remove(AddressSet storage set, address value) internal returns (bool) {
    return _remove(set._inner, bytes32(uint256(uint160(value))));
  }
  function contains(AddressSet storage set, address value) internal view returns (bool) {
    return _contains(set._inner, bytes32(uint256(uint160(value))));
  }
  function length(AddressSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(AddressSet storage set, uint256 index) internal view returns (address) {
    return address(uint160(uint256(_at(set._inner, index))));
  }

  // UintSet
  struct UintSet {
    Set _inner;
  }
  function add(UintSet storage set, uint256 value) internal returns (bool) {
    return _add(set._inner, bytes32(value));
  }
  function remove(UintSet storage set, uint256 value) internal returns (bool) {
    return _remove(set._inner, bytes32(value));
  }
  function contains(UintSet storage set, uint256 value) internal view returns (bool) {
    return _contains(set._inner, bytes32(value));
  }
  function length(UintSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(UintSet storage set, uint256 index) internal view returns (uint256) {
    return uint256(_at(set._inner, index));
  }
}


contract StakingNFT is ReentrancyGuard ,ERC721Holder, Ownable {
  using FixedPointMath for FixedPointMath.FixedDecimal;
  using EnumerableSet for EnumerableSet.UintSet;
  using Pool for Pool.Data;
  using Pool for Pool.List;
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  using Stake for Stake.Data;
  using Address for address;

  address public constant ZERO_ADDRESS = address(0);

  /// @dev Resolution for all fixed point numeric parameters which represent percents. The resolution allows for a
  /// granularity of 0.01% increments.
  uint256 public constant PERCENT_RESOLUTION = 10000;
 
  // Events
  event PendingGovernanceUpdated(address pendingGovernance);
  event GovernanceUpdated(address governance);
  event RewardRateUpdated(uint256 rewardRate);
  event PoolRewardWeightUpdated(uint256 indexed poolId,uint256 rewardWeight);
  event PoolCreated(uint256 indexed poolId,uint256 indexed weight,IERC721 indexed token);
  event TokensDeposited(address indexed user,uint256 indexed poolId,uint256 amount);
  event TokensWithdrawn(address indexed user,uint256 indexed poolId,uint256 amount);
  event TokensClaimed(address indexed user,uint256 indexed poolId,uint256 amount);
  event TokensMinted(address indexed user,uint256 amountIn,uint256 amountOut);


  /// @dev The token which will be minted as a reward for staking.
  IERC20 public reward;

  /// @dev The address of the account which currently has administrative capabilities over this contract.
  address public governance;

  address public pendingGovernance;

  mapping(IERC721 => uint256) public tokenPoolIds;

  mapping(uint256 => uint256) public tokenWeights;

  /// @dev The context shared between the pools.
  Pool.Context private _ctx;

  /// @dev A list of all of the pools.
  Pool.List private _pools;

  /// @dev A mapping of all of the user stakes mapped first by pool and then by address.
  mapping(address => mapping(uint256 => Stake.Data)) private _stakes;
  mapping(uint256 => mapping(address => EnumerableSet.UintSet)) private _holderTokens;

  constructor(IERC20 _reward,uint256 _rewardRate) {    
    reward = _reward;
    governance = msg.sender;
    setRewardRate(_rewardRate);
  }
  modifier noContractAllowed() {
    require(!address(msg.sender).isContract() && msg.sender == tx.origin, "Sorry we do not accept contract!");
    _;
  }
  modifier onlyGovernance() {
    require(msg.sender == governance, "Staking: only governance");
    _;
  }

  // Admin functions
  function setPendingGovernance(address _pendingGovernance) external onlyGovernance {
    require(_pendingGovernance != address(0), "Staking: pending governance address cannot be 0x0");
    pendingGovernance = _pendingGovernance;

    emit PendingGovernanceUpdated(_pendingGovernance);
  }
  function acceptGovernance() external {
    require(msg.sender == pendingGovernance, "Staking: only pending governance");

    address _pendingGovernance = pendingGovernance;
    governance = _pendingGovernance;

    emit GovernanceUpdated(_pendingGovernance);
  }

  /// @dev Sets the distribution reward rate.
  ///
  /// This will update all of the pools.
  ///
  /// @param _rewardRate The number of tokens to distribute per block.
  function setRewardRate(uint256 _rewardRate) public onlyGovernance {
    _updatePools();

    _ctx.rewardRate = _rewardRate;
    
    emit RewardRateUpdated(_rewardRate);
  }

  function safeWithdraw(address _token, uint256 _amount) public onlyOwner {
    IERC20(_token).safeTransfer( msg.sender, _amount);
  }
   
  // Pool args setting and init functions
  function createPool(IERC721 _token, uint256 _rewardWeight) external onlyGovernance returns (uint256) {
    require(tokenPoolIds[_token] < 4, "Staking: max pool id is 3");
    uint256 _poolId = _pools.length();
    require(_poolId < 4, "Staking: max pools length is 4");
    _pools.push(Pool.Data({
      token: _token,
      totalDeposited: 0,
      rewardWeight: _rewardWeight,
      accumulatedRewardWeight: FixedPointMath.FixedDecimal(0),
      lastUpdatedBlock: block.number
    }));

    tokenPoolIds[_token] = _poolId;

    _updatePools();
    _ctx.totalRewardWeight = _ctx.totalRewardWeight.add(_rewardWeight);

    emit PoolCreated(_poolId,_rewardWeight, _token);

    return _poolId;
  }

  function setPoolRewardWeight(uint256 _poolId, uint256 _rewardWeight) external onlyGovernance {
    _updatePools();

    uint256 _totalRewardWeight = _ctx.totalRewardWeight;
    Pool.Data storage _pool = _pools.get(_poolId);
    uint256 _currentRewardWeight = _pool.rewardWeight;
    if (_currentRewardWeight == _rewardWeight) {
      return;
    }

    _totalRewardWeight = _totalRewardWeight.sub(_currentRewardWeight).add(_rewardWeight);
    _pool.rewardWeight = _rewardWeight;

    emit PoolRewardWeightUpdated(_poolId, _rewardWeight);
    _ctx.totalRewardWeight = _totalRewardWeight;
  }

  function setRewardWeights(uint256[] calldata _rewardWeights) external onlyGovernance {
    require(_rewardWeights.length == _pools.length(), "Staking: weights length mismatch");

    _updatePools();

    uint256 _totalRewardWeight = _ctx.totalRewardWeight;
    for (uint256 _poolId = 0; _poolId < _pools.length(); _poolId++) {
      Pool.Data storage _pool = _pools.get(_poolId);

      uint256 _currentRewardWeight = _pool.rewardWeight;
      if (_currentRewardWeight == _rewardWeights[_poolId]) {
        continue;
      }

      _totalRewardWeight = _totalRewardWeight.sub(_currentRewardWeight).add(_rewardWeights[_poolId]);
      _pool.rewardWeight = _rewardWeights[_poolId];

      emit PoolRewardWeightUpdated(_poolId, _rewardWeights[_poolId]);
    }

    _ctx.totalRewardWeight = _totalRewardWeight;
  }
 
 
 
  // Stake operate functions: Deposit,withdraw,claim
  function deposit(uint256 _poolId, uint256[] calldata tokenIds) external nonReentrant noContractAllowed {
    require(tokenIds.length > 0, "zero id");

    Pool.Data storage _pool = _pools.get(_poolId);
    _pool.update(_ctx);

    Stake.Data storage _stake = _stakes[msg.sender][_poolId];
    _stake.update(_pool, _ctx);

    uint256 currentPoolAcceptLevel = _poolId + 1;
    uint256 _level = 0;
    for (uint i = 0; i < tokenIds.length; i++) {
      require(_pool.token.ownerOf(tokenIds[i]) == msg.sender , "Stake: AINT YO TOKEN");
      require(_pool.token.getTokenLevel(tokenIds[i]) == currentPoolAcceptLevel, "Stake: no match nft and pool id");

      _pool.token.transferFrom(msg.sender, address(this), tokenIds[i]);
      _holderTokens[_poolId][msg.sender].add(tokenIds[i]);
      _level += _pool.token.getTokenLevel(tokenIds[i]); 
    }
 
    _deposit(_poolId, _level * 100);   
  }

  function withdraw(uint256 _poolId, uint256[] calldata tokenIds) public nonReentrant noContractAllowed {
    require(tokenIds.length > 0, "Stake: zero id");
    
    Pool.Data storage _pool = _pools.get(_poolId);
    _pool.update(_ctx);

    Stake.Data storage _stake = _stakes[msg.sender][_poolId];
    _stake.update(_pool, _ctx);
    
    uint256 currentPoolAcceptLevel = _poolId + 1;
    uint256 _level = 0;
    for (uint i = 0; i < tokenIds.length; i++) {
      require(_holderTokens[_poolId][msg.sender].contains(tokenIds[i]) , "Stake: Token id not found");
      require(_pool.token.getTokenLevel(tokenIds[i]) == currentPoolAcceptLevel, "Stake: no match nft and pool id");  //fixme
      _pool.token.transferFrom(address(this), msg.sender, tokenIds[i]);//ERC721 ownership transferred
      _holderTokens[_poolId][msg.sender].remove(tokenIds[i]);
      _level += _pool.token.getTokenLevel(tokenIds[i]); 
    }
    
    _claim(_poolId);
    _withdraw(_poolId, _level * 100);
  }

  function claim(uint256 _poolId) external nonReentrant {
    Pool.Data storage _pool = _pools.get(_poolId);
    _pool.update(_ctx);

    Stake.Data storage _stake = _stakes[msg.sender][_poolId];
    _stake.update(_pool, _ctx);

    _claim(_poolId);
  }

  function _updatePools() internal {
    for (uint256 _poolId = 0; _poolId < _pools.length(); _poolId++) {
      Pool.Data storage _pool = _pools.get(_poolId);
      _pool.update(_ctx);
    }
  }

  function _deposit(uint256 _poolId, uint256 _depositAmount )internal {
    Pool.Data storage _pool = _pools.get(_poolId);
    Stake.Data storage _stake = _stakes[msg.sender][_poolId];
 
    _pool.totalDeposited = _pool.totalDeposited.add(_depositAmount);
    _stake.totalDeposited = _stake.totalDeposited.add(_depositAmount);
 
    emit TokensDeposited(msg.sender, _poolId, _depositAmount);
  }

  function _withdraw(uint256 _poolId, uint256 _withdrawAmount) internal {
    Pool.Data storage _pool = _pools.get(_poolId);
    Stake.Data storage _stake = _stakes[msg.sender][_poolId];
 
    _pool.totalDeposited = _pool.totalDeposited.sub(_withdrawAmount);
    _stake.totalDeposited = _stake.totalDeposited.sub(_withdrawAmount);

    emit TokensWithdrawn(msg.sender, _poolId, _withdrawAmount);
  }

  function _claim(uint256 _poolId) internal {
    Stake.Data storage _stake = _stakes[msg.sender][_poolId];

    uint256 _claimAmount = _stake.totalUnclaimed;
    uint256 _balance = reward.balanceOf(address(this));

    if (_balance >= _claimAmount && _claimAmount > 0) {
      _stake.totalUnclaimed = 0;
      reward.safeTransfer(msg.sender, _claimAmount);

      emit TokensClaimed(msg.sender, _poolId, _claimAmount); 
    }
  }


  // Stake read functions
  function getTokensOnStake(uint256 _poolId,address _address) public view returns (uint256[] memory listOfStake) {
    uint256 _len = _holderTokens[_poolId][_address].length();   
    uint256[] memory _tokens = new uint256[](_len);

    for (uint256 index = 0; index < _len; index++) {
      _tokens[index] = _holderTokens[_poolId][_address].at(index);
    }

    return _tokens;
  }

  function rewardPreDay() public view returns (uint256) {
    return _ctx.rewardRate.mul(28800) ;
  }
  /// @dev Gets the rate at which tokens are minted to stakers for all pools.
  ///
  /// @return the reward rate.
  function rewardRate() external view returns (uint256) {
    return _ctx.rewardRate;
  }

  /// @dev Gets the total reward weight between all the pools.
  ///
  /// @return the total reward weight.
  function totalRewardWeight() external view returns (uint256) {
    return _ctx.totalRewardWeight;
  }

  /// @dev Gets the number of pools that exist.
  ///
  /// @return the pool count.
  function poolCount() external view returns (uint256) {
    return _pools.length();
  }

  /// @dev Gets the token a pool accepts.
  ///
  /// @param _poolId the identifier of the pool.
  ///
  /// @return the token.
  function getPoolToken(uint256 _poolId) external view returns (IERC721) {
    Pool.Data storage _pool = _pools.get(_poolId);
    return _pool.token;
  }

  /// @dev Gets the total amount of funds staked in a pool.
  ///
  /// @param _poolId the identifier of the pool.
  ///
  /// @return the total amount of staked or deposited tokens.
  function getPoolTotalDeposited(uint256 _poolId) public view returns (uint256) {
    Pool.Data storage _pool = _pools.get(_poolId);
    return _pool.totalDeposited;
  }

  /// @dev Gets the reward weight of a pool which determines how much of the total rewards it receives per block.
  ///
  /// @param _poolId the identifier of the pool.
  ///
  /// @return the pool reward weight.
  function getPoolRewardWeight(uint256 _poolId) external view returns (uint256) {
    Pool.Data storage _pool = _pools.get(_poolId);
    return _pool.rewardWeight;
  }

  /// @dev Gets the amount of tokens per block being distributed to stakers for a pool.
  ///
  /// @param _poolId the identifier of the pool.
  ///
  /// @return the pool reward rate.
  function getPoolRewardRate(uint256 _poolId) external view returns (uint256) {
    Pool.Data storage _pool = _pools.get(_poolId);
    return _pool.getRewardRate(_ctx);
  }

  /// @dev Gets the number of tokens a user has staked into a pool.
  ///
  /// @param _account The account to query.
  /// @param _poolId  the identifier of the pool.
  ///
  /// @return the amount of deposited tokens.
  function getStakeTotalDeposited(address _account, uint256 _poolId) external view returns (uint256) {
    Stake.Data storage _stake = _stakes[_account][_poolId];
    return _stake.totalDeposited;
  }

  /// @dev Gets the number of unclaimed reward tokens a user can claim from a pool.
  ///
  /// @param _account The account to get the unclaimed balance of.
  /// @param _poolId  The pool to check for unclaimed rewards.
  ///
  /// @return the amount of unclaimed reward tokens a user has in a pool.
  function getStakeTotalUnclaimed(address _account, uint256 _poolId) external view returns (uint256) {
    Stake.Data storage _stake = _stakes[_account][_poolId];
    return _stake.getUpdatedTotalUnclaimed(_pools.get(_poolId), _ctx);
  }
}