// SPDX-License-Identifier: MIT
// Creator: OpenZeppelin

pragma solidity ^0.6.5;

import "./Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// Creator: OpenZeppelin

pragma solidity ^0.6.5;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
// Creator: OpenZeppelin

pragma solidity ^0.6.5;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// SPDX-License-Identifier: MIT
// Creator: OpenZeppelin

pragma solidity ^0.6.5;

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
contract Ownable  {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;

import "./ContextUpgradeSafe.sol";
import "./IERC20.sol";
import "./Initializable.sol";
import "./Ownable.sol";
import "./SafeMath.sol";


contract ProsperSocial is Ownable, Initializable, ContextUpgradeSafe {

    using SafeMath for uint;

    struct Pool {
        address creator;
        address token;
        string category;
        string question;
        uint optionsCount;
        uint minBet;
        uint start;
        uint startPeriod;
        uint end;
        uint endPeriod;
    }

    Pool[] public pools;
    mapping (address => bool) public whitelistedAddress;
    mapping (uint => mapping (uint => uint)) public totals;
    mapping (uint => uint) public taken;
    mapping (uint => uint) public results;
    mapping (uint => bool) public resultIsSet;
    mapping (uint => mapping (uint => string)) public options;

    mapping (address => mapping (address => uint)) public fees;
    mapping (uint => mapping (address => mapping(uint => uint))) public funds;

    event NewPool(uint id, address creator, address token, uint minBet, uint start, uint startPeriod, uint end, uint endPeriod, string ppolCategory, string poolQuestion, string[] poolOptions);
    event Bet(uint id, address sender, address asset, uint amount, uint option);
    event Collect(uint id, address sender, uint amount);
    event ResultAnnounced(uint id, uint option);
    event Claim(address claimer, address asset, uint amount);
    event Taken(uint id);

    function __ProsperSocial_init() internal initializer {
        __Context_init_unchained();
        __ProsperSocial_init_unchained();
    }

    function __ProsperSocial_init_unchained() internal initializer {
    }

    function initialize() public initializer {
        __ProsperSocial_init();
    }

    modifier canClaim(address user, address asset) {
        require(fees[user][asset] > 0, "Accumulated fees are not zero");
        _;
    }

    modifier onlyCreator(uint id) {
        require(pools[id].creator == msg.sender);
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelistedAddress[msg.sender], "Your wallet is not in whitelist");
        _;
    }

    function transfer(address from, address payable to, address asset, uint amount) internal {
        if (asset == address(0)) {
            if (address(this) != to) {
                to.call{value: amount};
            }
        } else {
            if (from == address(this)) {
                IERC20(asset).transfer(to, amount);
            } else {
                IERC20(asset).transferFrom(from, to, amount);
            }
        }
    }

    function createPool(address token, uint minBet, uint start, uint startPeriod, uint end, uint endPeriod, string memory poolCategory, string memory poolQuestion, string[] memory poolOptions) onlyWhitelisted public {
        require(block.number < start && end > start + startPeriod, "Invalid period");
        require(poolOptions.length >= 2, "Pool should have at least two options");
        uint id = pools.length;
        Pool memory newPool = Pool(msg.sender, token, poolCategory, poolQuestion, poolOptions.length, minBet, start, startPeriod, end, endPeriod);
        pools.push(newPool);

        for(uint i = 0; i < newPool.optionsCount; i++) {
            options[id][i] = poolOptions[i];
        }

        emit NewPool(id, msg.sender, token, minBet, start, startPeriod, end, endPeriod, poolCategory, poolQuestion, poolOptions);
    }

    function bet(uint id, address asset, uint amount, uint option) public payable {
        require(asset == pools[id].token, "Sent asset is same as asset in which we collect bets");
        if (asset == address(0)) {
            require(amount == msg.value, "Sent value should be equal to the amount");
        }
        require(amount > 0 && amount >= pools[id].minBet, "Amount should be at least the minimal bet");
        require(option <= pools[id].optionsCount, "Option out of bounds");
        uint start = pools[id].start;
        require(block.number >= start && block.number <= start.add(pools[id].startPeriod), "Acceptance period");
        uint fee = amount.div(500);
        uint amt = amount.sub(fee);
        for (uint i = 0; i < pools[id].optionsCount; i++) {
            if (i == option) {
                continue;
            }
            require(funds[id][msg.sender][i] == 0, "Unable to bet on multiple options");
        }
        totals[id][option] = totals[id][option].add(amt);
        funds[id][msg.sender][option] = funds[id][msg.sender][option].add(amt);
        fees[owner()][asset] = fees[owner()][asset].add(fee);
        transfer(msg.sender, payable(address(this)), asset, amount);
        emit Bet(id, msg.sender, asset, amount, option);
    }

    function setResult(uint id, uint option) public onlyCreator(id) {
        uint end = pools[id].end;
        require(block.number >= end && block.number <= end.add(pools[id].endPeriod), "Settlement period");
        require(option <= pools[id].optionsCount, "Option out of bounds");
        results[id] = option;
        resultIsSet[id] = true;
        emit ResultAnnounced(id, option);
    }

    function collect(uint id) public {
        uint timeToCollect = pools[id].end.add(pools[id].endPeriod);
        require(block.number > timeToCollect && block.number < timeToCollect.add(403200), "After price settlement period and not later than 14 days");
        address owner = owner();
        address token = pools[id].token;
        uint option = 0;
        for (uint i = 0; i < pools[id].optionsCount; i++) {
            if (funds[id][msg.sender][i] > 0) {
                option = i;
                break;
            }
        }
        uint amount = funds[id][msg.sender][option];
        require(amount > 0, "Has earnings");
        if (resultIsSet[id]) {
            require(option == results[id], "Losers cannot collect anything");
            uint losersTotal = 0;
            for (uint i = 0; i < pools[id].optionsCount; i++) {
                if (i == option) {
                    continue;
                }
                losersTotal = losersTotal.add(totals[id][i]);
            }
            uint earnings = losersTotal.mul(amount).div(totals[id][option]);
            uint fee = earnings.mul(3).div(100);
            fees[owner][token] = fees[owner][token].add(fee);
            earnings = earnings.sub(fee);
            amount = amount.add(earnings);
            taken[id] = taken[id].add(amount).add(fee);
        } else {
            taken[id] = taken[id].add(amount);
        }

        funds[id][msg.sender][option] = 0;
        transfer(address(this), msg.sender, token, amount);
        emit Collect(id, msg.sender, amount);
    }

    function claimNotTaken(uint id) public onlyOwner {
        uint total = 0;
        for (uint i = 0; i < pools[id].optionsCount; i++) {
            total = total.add(totals[id][i]);
        }
        transfer(address(this), msg.sender, pools[id].token, total.sub(taken[id]));
        taken[id] = total;
        emit Taken(id);
    }

    function claim(address asset) public canClaim(msg.sender, asset) {
        uint amount = fees[msg.sender][asset];
        fees[msg.sender][asset] = 0;
        transfer(address(this), msg.sender, asset, amount);
        emit Claim(msg.sender, asset, amount);
    }

    function addAddressToWhitelist(address _address) onlyOwner public {
        whitelistedAddress[_address] = true;
    }

    function removeAddressFromWhitelist(address _address) onlyOwner public {
        whitelistedAddress[_address] = false;
    }


    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// Creator: OpenZeppelin

pragma solidity ^0.6.5;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}