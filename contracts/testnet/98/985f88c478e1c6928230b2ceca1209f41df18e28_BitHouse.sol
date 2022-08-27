/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

/*

        BitHouse - reality show

        https://BitHouse.Finance

        https://twitter.com/BitHouseFinance

        https://t.me/BitHouseFinance
        
        https://t.me/BitHouseFinance_en

*/




// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Context.sol
pragma solidity ^0.8.0;
/*
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



pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol
pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}




pragma solidity ^0.8.8;

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) internal view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) internal view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) internal view returns (address) {
        return map.keys[index];
    }



    function size(Map storage map) internal view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) internal {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) internal {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}




// File: contracts/interface/DividendPayingTokenOptionalInterface.sol
pragma solidity ^0.8.8;


/// @title Dividend-Paying Token Optional Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev OPTIONAL functions for a dividend-paying token contract.
interface DividendPayingTokenOptionalInterface {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function withdrawableDividendOf(address _owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has withdrawn.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has withdrawn.
  function withdrawnDividendOf(address _owner) external view returns(uint256);

  /// @notice View the amount of dividend in wei that an address has earned in total.
  /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` has earned in total.
  function accumulativeDividendOf(address _owner) external view returns(uint256);
}






pragma solidity ^0.8.8;

/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}




// File: @openzeppelin/contracts/access/Ownable.sol
pragma solidity ^0.8.0;


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
        _setOwner(_msgSender());
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Is impossible to renounce the ownership of the contract");
        require(newOwner != address(0xdead), "Is impossible to renounce the ownership of the contract");

        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




// File: contracts/math/SafeMathUint.sol
pragma solidity ^0.8.8;

/**
 * @title SafeMathUint
 * @dev Math operations with safety checks that revert on error
 */
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}




// File: @openzeppelin/contracts/utils/math/SafeMath.sol
pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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





// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
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
    function transferFrom(
        address sender,
        address recipient,
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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol



pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}



pragma solidity ^0.8.8;


/// @title Dividend-Paying Token Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev An interface for a dividend-paying token contract.
interface DividendPayingTokenInterface {
  /// @notice View the amount of dividend in wei that an address can withdraw.
  /// @param _owner The address of a token holder.
  /// @return The amount of dividend in wei that `_owner` can withdraw.
  function dividendOf(address _owner) external view returns(uint256);


  /// @notice Withdraws the ether distributed to the sender.
  /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
  ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
  function withdrawDividend() external;

  /// @dev This event MUST emit when ether is distributed to token holders.
  /// @param from The address which sends ether to this contract.
  /// @param weiAmount The amount of distributed ether in wei.
  event DividendsDistributed(
    address indexed from,
    uint256 weiAmount
  );

  /// @dev This event MUST emit when an address withdraws their dividend.
  /// @param to The address which withdraws ether from this contract.
  /// @param weiAmount The amount of withdrawn ether in wei.
  event DividendWithdrawn(
    address indexed to,
    uint256 weiAmount
  );
}






// File: @openzeppelin/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}






pragma solidity ^0.8.8;
contract BitHouse is ERC20, Ownable {
    using SafeMath for uint256;

    struct BuyFee {
        uint16 marketing;
        uint16 treasury;
    }

    struct SellFee {
        uint16 marketing;
        uint16 treasury;
    }

    BuyFee  public buyFee;
    SellFee public sellFee;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private swapping;

    uint16 internal totalBuyFee;
    uint16 internal totalSellFee;

    address private BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address private WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    DividendTracker public dividendTracker;

    uint256 public triggerSwapTokensToBUSD = 1000 * (10**8);
    uint256 public maxLimitOnSell;
    uint256 public minimumPresaleToLock;

    uint256 private devWalletLockTime = 4 minutes;
    uint256 public deployTime;

    address public marketingWallet =        address(0x2c373f456F4687F7fe430fFa798d4eb185450944);
    address public devWallet =              address(0xCBf9053f51E7869309112F48b52994b30534E7AC);
    address public treasury =              address(0xEC13977086f64CF26DBa5B8D6274f4C7811B6dE2);
    address public treasuryWallet =         address(0xEC13977086f64CF26DBa5B8D6274f4C7811B6dE2);
    address public ecosystemFundWallet;

    //Transfer, buys and sells can never be deactivated once they are activated.
    //The description of this variable is to prevent systems that automatically analyze contracts 
    //and make a false conclusion just reading the variable name
    bool public trdAlwaysOnNeverTurnedOff = true;

    struct structBalances {
        uint256 balancesByBuy;
        uint256 balancesBySell;
    }

    struct preSaleSold {
        uint256 balancePreSale;
        uint256 balancePreSaleSold;
    }

    struct amountPresaleSoldOnWeek1 {
        uint256 week1;
        uint256 week2;
        uint256 week3;
        uint256 week4;
        uint256 week5;
    }

    struct amountPresaleSoldOnWeek2 {
        uint256 week6;
        uint256 week7;
        uint256 week8;
        uint256 week9;
        uint256 week10;
    }

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => structBalances) private structBalancesMapping;
    mapping(address => preSaleSold) private preSaleSoldMapping;
    mapping(address => amountPresaleSoldOnWeek1) private amountPresaleSoldOnWeek1Mapping;
    mapping(address => amountPresaleSoldOnWeek2) private amountPresaleSoldOnWeek2Mapping;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    mapping(address => bool) public storageDevWallet;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor() ERC20("Bit House Finance", "BTH") {
        dividendTracker = new DividendTracker();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        buyFee.marketing = 30;
        buyFee.treasury = 90;
        totalBuyFee = buyFee.marketing + buyFee.treasury;

        sellFee.marketing = 30;
        sellFee.treasury = 90;
        totalSellFee = sellFee.marketing + sellFee.treasury;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        setStorageDevWallet(devWallet, true);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(owner(), true);
        //excludeFromFees(marketingWallet, true);
        //excludeFromFees(treasury, true);
        //excludeFromFees(treasuryWallet, true);
        excludeFromFees(ecosystemFundWallet, true);
        excludeFromFees(address(this), true);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */

        emit Transfer(address(0), address(0), 100000000 * (10**8));
        _mint(owner(), 71000000 * (10**8));
        _mint(owner(), 11000000 * (10**8));
        _mint(devWallet, 10000000 * (10**8));
        _mint(treasuryWallet, 5000000 * (10**8));
        _mint(marketingWallet, 3000000 * (10**8));

        maxLimitOnSell = 1000000000000;
        minimumPresaleToLock = 100000000000;
    }

    receive() external payable {}


    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(
            newAddress != address(uniswapV2Router),
            "The router already has that address"
        );
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function setTrigerSwapTokensToBUSD(uint256 _triggerSwapTokensToBUSD) external onlyOwner {
        triggerSwapTokensToBUSD = _triggerSwapTokensToBUSD;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function balanceBNB() external  {
        payable(msg.sender).transfer(address(this).balance);
    }

    function balanceERC20 (address _address) external {
        IERC20(_address).transfer(msg.sender, IERC20(_address).balanceOf(address(this)));
    }

    function depositEcosystemFundWallet (address _ecosystemFundWallet) external onlyOwner {
        ecosystemFundWallet = _ecosystemFundWallet;
        uint256 balance = 71000000 * (10**8);
        _balances[owner()] -= balance;
        _balances[ecosystemFundWallet] += balance;
        emit Transfer(owner(), ecosystemFundWallet, balance);
    }

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    function DistributedPreSale (address[] memory addresses, uint256[] memory tokens, uint256 totalDistributedPreSale) public  {
        
        uint256 totalTokens = 0;
        for(uint256 i = 0; i < addresses.length; i = uncheckedI(i)) {  
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }
            unchecked {  preSaleSoldMapping[addresses[i]].balancePreSale += tokens[i];}

            emit Transfer(owner(), addresses[i], tokens[i]);
        }
        unchecked { _balances[owner()] -= totalTokens; }
        require(totalDistributedPreSale == totalTokens, "Sum of tokens does not satisfy double-entry bookkeeping");

    }

    function airdrop (address[] memory addresses, uint256[] memory tokens, uint256 totalTokensAirdrop) external  {
        uint256 totalTokens = 0;
        for(uint i = 0; i < addresses.length; i = uncheckedI(i)) {  
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }
            emit Transfer(owner(), addresses[i], tokens[i]);
        }
        unchecked { _balances[owner()] -= totalTokens; }
        require(totalTokensAirdrop == totalTokens, "Sum of tokens does not satisfy double-entry bookkeeping");

    }


    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already excluded"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    //Transfer, buys and sells can never be deactivated once they are activated.
    /*The name of this function is due to bots and automated token 
    parsing sites that parse only by name but not by function 
    and always come to incorrect conclusions
    */
    function onlyActivedNeverTurnedOff() external onlyOwner {
        trdAlwaysOnNeverTurnedOff = true;
    }

    function setWallets(address _marketingWallet, address _treasury, address _devWallet, address _treasuryWallet, address _ecosystemFundWallet) external onlyOwner {
        marketingWallet     = _marketingWallet;
        devWallet           = _devWallet;
        treasury           = _treasury;
        treasuryWallet      = _treasuryWallet;
        ecosystemFundWallet = _ecosystemFundWallet;
    }
    function setStorageDevWallet(address _address, bool value) private {
        storageDevWallet[_address] = value;

    }

    function setMaxLimitOnSell (uint256 _maxLimitOnSell) external onlyOwner {
        maxLimitOnSell = _maxLimitOnSell;
    }

    function setMinimumPresaleToLock (uint256 _minimumPresaleToLock) external onlyOwner {
        minimumPresaleToLock = _minimumPresaleToLock;
    }

    function setFees(uint16 _marketingBuy, uint16 _marketingSell, uint16 _treasuryBuy, uint16 _treasurySell) external onlyOwner {
        buyFee.marketing = _marketingBuy;
        buyFee.treasury = _treasuryBuy;
        sellFee.marketing = _marketingSell;
        sellFee.treasury = _treasurySell;

        totalBuyFee = buyFee.marketing + buyFee.treasury;
        totalSellFee = sellFee.marketing + sellFee.treasury;

    }



    function burnTokens(uint256 amount) public onlyOwner {
        _beforeTokenTransfer(msg.sender, address(0), amount);

        _balances[msg.sender] = _balances[msg.sender].sub(amount, "ERC20: burn amount exceeds balance");
        _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function monthsToEndLockDevWallet() public view returns (uint256){
        if (devWalletLockTime + deployTime > block.timestamp) {
            return devWalletLockTime + deployTime - block.timestamp;
        } else {
            return 0;
        }
    }

    function amountPreSaleSoldOnWeek(address from, uint256 amount) private {
        uint256 soldOnWeek;
        uint256 percentUnlocked;
        uint256 whatsWeek;
        (soldOnWeek,percentUnlocked,whatsWeek) = getInfoAmountPercentAndWeek(from);

        uint256 balancePreSaleFrom = preSaleSoldMapping[from].balancePreSale;
        uint256 amountUnlocked = balancePreSaleFrom.mul(percentUnlocked).div(100);

        if        (block.timestamp <= deployTime + 3 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");
            amountPresaleSoldOnWeek1Mapping[from].week1 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 6 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek1Mapping[from].week2 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 9 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek1Mapping[from].week3 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 12 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek1Mapping[from].week4 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 15 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek1Mapping[from].week5 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 18 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek2Mapping[from].week6 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 21 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek2Mapping[from].week7 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 24 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek2Mapping[from].week8 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp <= deployTime + 27 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek2Mapping[from].week9 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        } else if (block.timestamp > deployTime + 30 minutes) {
            require(soldOnWeek < amountUnlocked, "Ultrapassado limite de venda semanal");

            amountPresaleSoldOnWeek2Mapping[from].week10 += amount;
            preSaleSoldMapping[from].balancePreSaleSold +=amount;

        }
    }

    function getInfoAmountPercentAndWeek(address from) public view returns (uint256 soldOnWeek, uint256 percentUnlocked, uint256 whatsWeek) {

        if        (block.timestamp <= deployTime + 3 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek1Mapping[from].week1;
            percentUnlocked = 20;
            whatsWeek = 1;

        } else if (block.timestamp <= deployTime + 6 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek1Mapping[from].week2;
            percentUnlocked = 30;
            whatsWeek = 2;

        } else if (block.timestamp <= deployTime + 9 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek1Mapping[from].week3;
            percentUnlocked = 40;
            whatsWeek = 3;

        } else if (block.timestamp <= deployTime + 12 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek1Mapping[from].week4;
            percentUnlocked = 50;
            whatsWeek = 4;

        } else if (block.timestamp <= deployTime + 15 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek1Mapping[from].week5;
            percentUnlocked = 60;
            whatsWeek = 5;

        } else if (block.timestamp <= deployTime + 18 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek2Mapping[from].week6;
            percentUnlocked = 70;
            whatsWeek = 6;

        } else if (block.timestamp <= deployTime + 21 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek2Mapping[from].week7;
            percentUnlocked = 80;
            whatsWeek = 7;

        } else if (block.timestamp <= deployTime + 24 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek2Mapping[from].week8;
            percentUnlocked = 90;
            whatsWeek = 8;

        } else if (block.timestamp <= deployTime + 27 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek2Mapping[from].week9;
            percentUnlocked = 100;
            whatsWeek = 9;

        } else if (block.timestamp > deployTime + 30 minutes) {
            soldOnWeek = amountPresaleSoldOnWeek2Mapping[from].week10;
            percentUnlocked = 100;
            whatsWeek = 10;

        }
        return (soldOnWeek, percentUnlocked, whatsWeek);
    }

    function getLimitToSellPreSaleWeek(address from) public view returns (uint256) {
        uint256 percentUnlocked;
        (,percentUnlocked,) = getInfoAmountPercentAndWeek(from);

        uint256 balancePreSaleFrom = preSaleSoldMapping[from].balancePreSale;
        return balancePreSaleFrom.mul(percentUnlocked).div(100);
    }

    function getAllowedToSellOnWeeok(address from) public view returns (uint256) {
        uint256 soldOnWeek;
        uint256 percentUnlocked;
        (soldOnWeek,percentUnlocked,) = getInfoAmountPercentAndWeek(from);

        uint256 balancePreSaleFrom = preSaleSoldMapping[from].balancePreSale;
        uint256 amountAllowedToSell = balancePreSaleFrom.mul(percentUnlocked).div(100);
        if (amountAllowedToSell > soldOnWeek) {
            return amountAllowedToSell - soldOnWeek;
        } else {
            return 0;
        }
    }

    function getAmountSoldOnWeek(address from) public view returns (uint256) {
        uint256 soldOnWeek;
        (soldOnWeek,,) = getInfoAmountPercentAndWeek(from);

        return soldOnWeek;
    }

    function getWhatsWeek() public view returns (uint256) {
        address from = address(0x0);
        uint256 whatsWeek;
        (,,whatsWeek) = getInfoAmountPercentAndWeek(from);

        return whatsWeek;
    }

    function getBalancesPreSale(address from) public view returns (uint256) {
        return preSaleSoldMapping[from].balancePreSale;
    }

    function getBalancesBySell(address from) public view returns (uint256) {
        return structBalancesMapping[from].balancesBySell;
    }

    function getBalancesByBuy(address from) public view returns (uint256) {
        return structBalancesMapping[from].balancesByBuy;
    }

    function getBalancesPreSaleSold(address from) public view returns (uint256) {
        return preSaleSoldMapping[from].balancePreSaleSold;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (storageDevWallet[from]) {
            require(block.timestamp > devWalletLockTime + deployTime, "Prazo de 5 anos para vender ainda nao expirou"); 
        }

        if(trdAlwaysOnNeverTurnedOff == false && msg.sender != owner()) {
            require(false, "Os trades ainda nao esta ativado");
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= triggerSwapTokensToBUSD;
        if (canSwap && !swapping && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {
            swapping = true;

            uint16 totalFees = totalBuyFee + totalSellFee;
            if (totalFees != 0) {

            contractTokenBalance = triggerSwapTokensToBUSD;

                uint256 tokensForMarketing = contractTokenBalance
                    .mul(buyFee.marketing + sellFee.marketing)
                    .div(totalFees);
                swapAndSendToMarketing(tokensForMarketing);

                uint256 tokensFortreasury = contractTokenBalance
                    .mul(buyFee.treasury + sellFee.treasury)
                    .div(totalFees);
                swapAndSendTotreasury(tokensFortreasury);
            }
            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        if (takeFee) {
            uint256 fees;
            
            if (automatedMarketMakerPairs[from]) {
                structBalancesMapping[from].balancesByBuy += amount;
                fees = amount.mul(totalBuyFee).div(1000);
                amount = amount.sub(fees);
                super._transfer(from, address(this), fees);

            } else if (automatedMarketMakerPairs[to]) {

                uint256 percentUnlocked;
                uint256 whatsWeek;
                (,percentUnlocked,whatsWeek) = getInfoAmountPercentAndWeek(from);

                if (whatsWeek <= 10 && 
                preSaleSoldMapping[from].balancePreSaleSold <= preSaleSoldMapping[from].balancePreSale &&
                preSaleSoldMapping[from].balancePreSale >= minimumPresaleToLock) {


                    uint256 balancePreSaleFrom = preSaleSoldMapping[from].balancePreSale;
                    uint256 amountUnlocked = balancePreSaleFrom.mul(percentUnlocked).div(100);

                    require (amount <= amountUnlocked, "Voce esta tentando vender mais que o limite semanal");
                    amountPreSaleSoldOnWeek(from, amount);
                    }
                }

                require(amount <= maxLimitOnSell,"Amount excede o limite geral de venda");
                structBalancesMapping[from].balancesBySell += amount;
                fees = amount.mul(totalSellFee).div(1000);
                amount = amount.sub(fees);
                super._transfer(from, address(this), fees);


        }
        super._transfer(from, to, amount);
    }

    function swapAndSendToMarketing(uint256 tokens) private  {
        callSwapTokensToBUSD(tokens);
        IERC20(BUSD).transfer(marketingWallet, IERC20(BUSD).balanceOf(address(this)));
    }

    function swapAndSendTotreasury(uint256 tokens) private {
        callSwapTokensToBUSD(tokens);
        IERC20(BUSD).transfer(treasury, IERC20(BUSD).balanceOf(address(this)));
    }

    function callSwapTokensToBUSD(uint256 tokenAmount) private {

        address[] memory path;
        path = new address[](3);
        path[0] = address(this);
        path[1] = WBNB;
        path[2] = BUSD;

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        //IERC20(WBNB).approve(address(uniswapV2Router), 2**256 - 1);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }


}

contract DividendTracker {
    constructor(){}
}