// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IPancakePair.sol";
import "./interface/IPancakeRouter.sol";
/*
 * Since solidity doesn't support float type. The x% will be presented as x00. For example, 0.05% will be 5
 */
contract StakingCaash is Ownable {
  using SafeMath for uint256;
  using SafeMath for uint112;
  using Counters for Counters.Counter;
  Counters.Counter internal _tokenIdCounter;

  event Stake(
    address indexed _from,
    uint256 indexed _id,
    uint256 _timestamp,
    uint256 _amount
  );

  event Withdraw(
    address indexed _from,
    uint256 indexed _id,
    uint256 _startTimestamp,
    uint256 _timestamp,
    uint256 _principal,
    uint256 _interest
  );

  event Claim(
    address indexed _from,
    uint256 indexed _id,
    uint256 _timestamp,
    uint256 _interest
  );

  IERC20 public rewardToken;
  IERC20 public stakingToken;
  IPancakeRouter public router;

  mapping(uint256 => uint256) public idToBalance;
  mapping(uint256 => uint256) public idToStartTime;
  mapping(uint256 => address) private _idToAddress;
  mapping(uint256 => uint256) public idToLastClaimAt;
  mapping(address => uint256[]) private _addressToIds;

  address[] internal _addresses;

  bool public enabled = false;
  uint256 constant MIN_AMOUNT = 1e9;
  uint256 constant ONE_DAY_IN_SECONDS = 24 * 60 * 60;

  uint256 public dailyInterestRate = 500;

  constructor(
    address _rewardToken,
    address _router,
    address _stakingToken
  ) {
    rewardToken = IERC20(_rewardToken);
    router = IPancakeRouter(_router);
    stakingToken = IERC20(_stakingToken);
  }

  modifier onlyStakeholder(uint256 _id) {
    require(_idToAddress[_id] == msg.sender, "StakingCaash: Caller is not the stakeholder");
    _;
  }

  function setEnabled(bool _enabled) external onlyOwner {
    enabled = _enabled;
  }

  /*
   * Notice: Since solidity doens't support float type, x% will be presented as x00.
   * For example, let say the interest rate for 1-day term is 0.5%.
   * It will be presented in the code like this:
   * dailyInterestRate = 50
   */
  function setDailyInterestRate(uint256 _dailyInterestRate) external onlyOwner {
    require(!enabled, "StakingCaash: Cannot set daily interest rate while enabled");
    require(_dailyInterestRate <= 10000, "StakingCaash: Daily interest rate must be less than 100%");
    dailyInterestRate = _dailyInterestRate;
  }

  function stake(uint256 _amount) external {
    require(enabled, "StakingCaash: Staking is disabled");
    require(_amount >= 1e18, "StakingCaash: Amount must be >= 1 token");
    if (address(stakingToken) != address(rewardToken)) {
      require(address(router) != address(0), "StakingCaash: Router is not initialized");
    }

    uint256 currentId = _tokenIdCounter.current();
    _idToAddress[currentId] = msg.sender;
    idToStartTime[currentId] = block.timestamp;
    idToBalance[currentId] = _amount;
    if (_addressToIds[msg.sender].length == 0) {
      _addresses.push(msg.sender);
    }
    _addressToIds[msg.sender].push(currentId);
    stakingToken.transferFrom(msg.sender, address(this), _amount);
    _tokenIdCounter.increment();

    emit Stake(msg.sender, currentId, block.timestamp, _amount);
  }

  function getPrincipal(uint256 _id) external view returns (uint256) {
    return idToBalance[_id];
  }

  function getInterest(uint256 _id)
    public
    view
    onlyStakeholder(_id)
    returns (uint256)
  {
    uint256 principal = idToBalance[_id];
    uint256 currentTermStartTime = idToStartTime[_id];
    uint256 lastClaimAt = idToLastClaimAt[_id];
    uint256 duration = block.timestamp.sub(currentTermStartTime);
    if (lastClaimAt > 0) {
      duration = block.timestamp.sub(lastClaimAt);
    }
    uint256 interest = principal
      .mul(dailyInterestRate)
      .mul(duration)
      .div(ONE_DAY_IN_SECONDS)
      .div(10000);
    if (interest >= MIN_AMOUNT) {
      address[] memory path = new address[](2);
      path[0] = address(stakingToken);
      path[1] = address(rewardToken);
      uint256[] memory amounts = router.getAmountsOut(interest, path);
      interest = amounts[1];
    } else {
      interest = 0;
    }

    return interest;
  }

  function claim(uint256 _id) external onlyStakeholder(_id) {
     uint256 interest = getInterest(_id);
     idToLastClaimAt[_id] = block.timestamp;
     rewardToken.transfer(msg.sender, interest);
     emit Claim(msg.sender, _id, block.timestamp, interest);
  }

  function withdraw(uint256 _id) external onlyStakeholder(_id) {
    uint256 interest = getInterest(_id);
    uint256 principal = idToBalance[_id];
    uint256 startTimestamp = idToStartTime[_id];
    delete _idToAddress[_id];
    delete idToStartTime[_id];
    delete idToBalance[_id];
    delete idToLastClaimAt[_id];

    for (uint256 i = 0; i < _addressToIds[msg.sender].length; ++i) {
      if (_addressToIds[msg.sender][i] == _id) {
        _addressToIds[msg.sender][i] = _addressToIds[msg.sender][
          _addressToIds[msg.sender].length - 1
        ];
        _addressToIds[msg.sender].pop();
        break;
      }
    }
    if (_addressToIds[msg.sender].length == 0) {
      for (uint256 i = 0; i < _addresses.length; ++i) {
        if (_addresses[i] == msg.sender) {
          _addresses[i] = _addresses[_addresses.length - 1];
          _addresses.pop();
          break;
        }
      }
    }

    stakingToken.transfer(msg.sender, principal);
    rewardToken.transfer(msg.sender, interest);

    emit Withdraw(
      msg.sender,
      _id,
      startTimestamp,
      block.timestamp,
      principal,
      interest
    );
  }

  function getStakingIds() external view returns (uint256[] memory) {
    return _addressToIds[msg.sender];
  }

  function getStakeHolders()
    external
    view
    onlyOwner
    returns (address[] memory)
  {
    return _addresses;
  }

  function getTotalStaked() public view returns (uint256) {
    uint256 totalStaked;
    for (uint256 i = 0; i < _addresses.length; ++i) {
      uint256[] memory ids = _addressToIds[_addresses[i]];
      for (uint256 j = 0; j < ids.length; ++j) {
        totalStaked = totalStaked.add(idToBalance[ids[j]]);
      }
    }
    return totalStaked;
  }

  function transferStakingToken(address _recipient, uint256 _amount)
    external
    onlyOwner
    returns (bool)
  {
    return stakingToken.transfer(_recipient, _amount);
  }

  function transferRewardToken(address _recipient, uint256 _amount)
    external
    onlyOwner
    returns (bool)
  {
    return rewardToken.transfer(_recipient, _amount);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IPancakePair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(
    address indexed sender,
    uint256 amount0,
    uint256 amount1,
    address indexed to
  );
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IPancakeRouter {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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