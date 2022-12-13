/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

pragma solidity 0.8.0;

// SPDX-License-Identifier: MIT
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/zeppelin/access/Ownable.sol

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity 0.8.0;

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    // function initialize() internal{
    //     address msgSender = _msgSender();
    //     _owner = msgSender;
    //     emit OwnershipTransferred(address(0), msgSender);
    // }

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// Reference: the source code of Pancakeswap: https://bscscan.com/address/0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F#code
// Reference: the source code of 1Inch: https://etherscan.io/address/0x1111111254fb6c44bac0bed2854e76f90643097d

pragma solidity 0.8.0;

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
}

// File: contracts/zeppelin/math/SafeMathInt.sol

/*
MIT License

Copyright (c) 2018 requestnetwork
Copyright (c) 2018 Fragments, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity 0.8.0;

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

// File: contracts/zeppelin/utils/SafeMathUint.sol

pragma solidity 0.8.0;

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

// File: contracts/zeppelin/utils/Address.sol

pragma solidity 0.8.0;

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
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// File: contracts/zeppelin/token/IERC20.sol

pragma solidity 0.8.0;

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

// File: contracts/zeppelin/token/ERC20.sol

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

pragma solidity 0.8.0;

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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory __name, string memory __symbol) {
        _name = __name;
        _symbol = __symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
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
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

interface IERC20Mintable{
  function mint(address _to, uint256 _amount) external returns (bool);
}

// File: contracts/ERC20Mintable.sol

pragma solidity 0.8.0;

/**
 * @title ERC20Mintable
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract ERC20Mintable is Ownable, ERC20, IERC20Mintable {
    using SafeMath for uint;
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    /**
    * @dev Constructor to initialize the token values when deploying.
    * @param _name The token name.
    * @param _symbol The token symbol
    */
    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {}

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount)
        public
        override
        onlyOwner
        canMint
        returns (bool)
    {
        _mint(_to, _amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() public onlyOwner canMint returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}

// File: contracts/zeppelin/utils/Pausable.sol

// File: @openzeppelin/contracts/utils/Pausable.sol

pragma solidity 0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () {
        _paused = false;
    }

    // function initializePausable() internal{
    //     _paused = false;
    // }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IHarvestPayingToken is IERC20, IERC20Mintable{
  function harvestAvailableOf(address _owner) external view returns(uint256);
  function distribute(uint256 _amount) external;
  function tokensDistributed() view external returns (uint256);
  function distributionsAmount() view external returns (uint256);
  function tokensDistributedNotHarvested() view external returns (uint256);
}

// File: contracts/AirdropToken.sol

pragma solidity 0.8.0;

///  Based on Dividend-Paying Token from Roger Wu (https://github.com/roger-wu)
///  Reference: the source code of PoWH3D: https://etherscan.io/address/0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe#code
///  Reference: the source code of TIKI: https://bscscan.com/address/0x9b76d1b12ff738c113200eb043350022ebf12ff0#code
contract HarvestPayingToken is IHarvestPayingToken, ERC20Mintable {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;
    uint256 public override distributionsAmount;
    uint256 internal magnifiedHarvestPerShare;
    uint256 public override tokensDistributed;
    uint256 public override tokensDistributedNotHarvested;
    uint256 constant internal magnitude = 2**128;
    address public immutable distributionToken;
    mapping(address => int256) internal magnifiedHarvestCorrections;
    mapping(address => uint256) internal harvested;
    // With `magnitude`, we can properly distribute even if the amount of received value is small.
    // For more discussion about choosing the value of `magnitude`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    
    event Distribution(
        address indexed from,
        uint256 weiAmount
    );
    event Harvested(
        address indexed from,
        address indexed to,
        uint256 weiAmount
    );

    constructor(string memory _name, string memory _symbol, address _distributionToken) ERC20Mintable(_name, _symbol) {
      distributionToken = _distributionToken;
    }

    // Distribution
    function distribute(uint256 _amount) external override onlyOwner {  
      require(totalSupply() > 0, "HARVEST_TOKEN: TOTAL_SUPPLY_TOO_LOW");
      require(IERC20(distributionToken).balanceOf(address(this)).sub(tokensDistributedNotHarvested) >= _amount, "HARVEST_TOKEN: INSUFICIENT_DISTRIBUTION_TOKENS");
      if(_amount > 0){
        magnifiedHarvestPerShare = magnifiedHarvestPerShare.add(_amount.mul(magnitude) / totalSupply());
        emit Distribution(msg.sender, _amount);
        ++distributionsAmount;
        tokensDistributedNotHarvested = tokensDistributedNotHarvested.add(_amount);
        tokensDistributed = tokensDistributed.add(_amount);
      }
    }

    function _harvestOfUser(address user, address to) internal returns (uint256) {
        uint256 _harvestAvailable = harvestAvailableOf(user);
        if (_harvestAvailable > 0) {
          harvested[user] = harvested[user].add(_harvestAvailable);
          tokensDistributedNotHarvested = tokensDistributedNotHarvested.sub(_harvestAvailable);
          IERC20(distributionToken).transfer(to, _harvestAvailable);
          emit Harvested(user, to, _harvestAvailable);
          return _harvestAvailable;
        }

        return 0;
    }

    function _harvestOfUserDelegated(address user, address _taxReceiverAddress, uint256 _distributionTokenFee) internal returns (uint256) {
        uint256 _harvestAvailable = harvestAvailableOf(user);
        require(_harvestAvailable >= _distributionTokenFee, "HARVEST_TOKEN: UNABLE_TO_PAY_FOR_HARVEST_FEE");
        if (_harvestAvailable > 0) {
          harvested[user] = harvested[user].add(_harvestAvailable);
          uint256 _finalHarvestAvailable = _harvestAvailable.sub(_distributionTokenFee);
          tokensDistributedNotHarvested = tokensDistributedNotHarvested.sub(_harvestAvailable);
          IERC20(distributionToken).transfer(user, _finalHarvestAvailable);
          IERC20(distributionToken).transfer(_taxReceiverAddress, _distributionTokenFee);
          return _harvestAvailable;
        }

        return 0;
    }

    /// @notice View the amount of harvest in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of harvest in wei that `_owner` can withdraw.
    function harvestAvailableOf(address _owner) public override view returns(uint256) {
        return accumulativeHarvestOf(_owner).sub(harvested[_owner]);
    }

    /// @notice View the amount of harvest in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of harvest in wei that `_owner` has withdrawn.
    function harvestedAmountOf(address _owner) public view returns(uint256) {
        return harvested[_owner];
    }

    function accumulativeHarvestOf(address _owner) public view returns(uint256) {
      return magnifiedHarvestPerShare.mul(balanceOf(_owner)).toInt256Safe()
      .add(magnifiedHarvestCorrections[_owner]).toUint256Safe() / magnitude;
    }

    /// @dev Internal function that transfer tokens from one address to another.
    /// Update magnifiedHarvestCorrections to keep harvest gains unchanged.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param value The amount to be transferred.
    function _transfer(address from, address to, uint256 value) internal virtual override {
        super._transfer(from, to, value);

        int256 _magCorrection = magnifiedHarvestPerShare.mul(value).toInt256Safe();
        magnifiedHarvestCorrections[from] = magnifiedHarvestCorrections[from].add(_magCorrection);
        magnifiedHarvestCorrections[to] = magnifiedHarvestCorrections[to].sub(_magCorrection);
    }

    /// @dev Internal function that mints tokens to an account.
    /// Update magnifiedHarvestCorrections to keep harvest gains unchanged.
    /// @param account The account that will receive the created tokens.
    /// @param value The amount that will be created.
    function _mint(address account, uint256 value) internal override{
        super._mint(account, value);

        magnifiedHarvestCorrections[account] = magnifiedHarvestCorrections[account]
        .sub( (magnifiedHarvestPerShare.mul(value)).toInt256Safe() );
    }

    /// @dev Internal function that burns an amount of the token of a given account.
    /// Update magnifiedHarvestCorrections to keep harvest gains unchanged.
    /// @param account The account whose tokens will be burnt.
    /// @param value The amount that will be burnt.
    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedHarvestCorrections[account] = magnifiedHarvestCorrections[account]
        .add( (magnifiedHarvestPerShare.mul(value)).toInt256Safe() );
    }
}

interface IHarvestTicket is IHarvestPayingToken{
  function harvestForUserTo(address user, address to) external returns (uint256);
  function harvestForUserDelegated(address user, address _taxReceiverAddress, uint256 _distributionTokenFee) external returns (uint256);
  function burnFrom(address account, uint256 amount) external;
}

contract HarvestTicket is HarvestPayingToken, IHarvestTicket{
  constructor(address _distributionToken) HarvestPayingToken("CAU-HarvestTicket", "CAU-HT", _distributionToken) {}

  function harvestForUserTo(address user, address to) external onlyOwner override returns (uint256) {
      return _harvestOfUser(user, to);
  }

  function harvestForUserDelegated(address user, address _taxReceiverAddress, uint256 _distributionTokenFee) external override onlyOwner returns (uint256) {
      return _harvestOfUserDelegated(user, _taxReceiverAddress, _distributionTokenFee);
  }

  function burnFrom(address account, uint256 amount) external override onlyOwner{
    _burn(account, amount);
  }
}

contract HarvestContract is Ownable, Pausable{
  using SafeMath for uint;

  // 8 decimal places
  uint256 public feePercentage;
  address public feeTo;
  mapping(address => bool) public isAdmin;
  address public immutable cauToken;
  address public harvestTicket;

  // Event for fee percentage update
  event UpdatedFeePercentage(uint256 oldFeePercentage, uint256 newFeePercentage);
  // Event for tokens deposit
  event Deposit(address indexed from, uint256 amount);
  // Event for tokens withdraw the amount deposited
  event Withdraw(address indexed from, uint256 amount, uint256 fee);
  // Event for redeposit
  event ReDeposit(address indexed from, uint256 amount);
  // Event for earn redemption
  event Harvest(address indexed from, uint256 amount, uint256 fee);
  // Event for tokens withdraw the amount deposited
  event WithdrawAndHarvest(address indexed from, uint256 withdrawAmount, uint256 harvestAmount, uint256 amount, uint256 fee);

  constructor(address _distributionToken, address _admin, address _feeTo) Ownable() Pausable() {
    HarvestTicket _harvestTicket = new HarvestTicket(_distributionToken);
    harvestTicket = address(_harvestTicket);
    feePercentage = 50000000; // 0.5%
    feeTo = _feeTo;
    cauToken = _distributionToken;
    isAdmin[_admin] = true;
  }

  function _checkOwnerAdmin() internal view virtual{
    require(isAdmin[msg.sender] || msg.sender == owner(), "HARVEST: FORBIDDEN");
  }

  function _checkValidAddress(address _address) internal view virtual{
    require(_address != address(0), "HARVEST: INVALID_ADDRESS");
  }

  modifier checkValidAddress(address _address){
    _checkValidAddress(_address);
    _;
  }

  modifier onlyOwerOrAdmin(){
    _checkOwnerAdmin();
    _;
  }

  // 8 decimal places
  // If zero, turn fee off
  function setFeePercentage(uint256 _feePercentage) external onlyOwerOrAdmin{
    uint256 oldFeePercentage = feePercentage;
    feePercentage = _feePercentage;
    emit UpdatedFeePercentage(oldFeePercentage, feePercentage);
  }

  function addAdmin(address _admin) external onlyOwner checkValidAddress(_admin){
    require(!isAdmin[_admin], "HARVEST: ADMIN_ALREADY_ADDED");
    isAdmin[_admin] = true;
  }

  function removeAdmin(address _admin) external onlyOwner{
    require(isAdmin[_admin], "HARVEST: ADMIN_ALREADY_REMOVED");
    isAdmin[_admin] = false;
  }

  function setFeeTo(address _feeTo) external onlyOwerOrAdmin checkValidAddress(_feeTo){
    feeTo = _feeTo;
  }

  function _applyFee(uint _amount) internal view returns (uint256, uint256) {
    uint256 _feePercentage = feePercentage;
    bool feeIsOn = _feePercentage > 0;
    uint256 _amountWithoutFee = _amount;
    uint256 _feeAmount = 0;
    if(feeIsOn){
      // Calculating fee amount
      _feeAmount = _amount.mul(_feePercentage);
      _feeAmount = _feeAmount.div(10000000000);
      require(_feeAmount > 0, "HARVEST: INSUFICIENT_AMOUNT_FOR_FEE");
      // Discounting fee from amount
      _amountWithoutFee = _amount.sub(_feeAmount);
      require(_amountWithoutFee > 0, "HARVEST: INSUFICIENT_AMOUNT_FOR_FEE");
    }

    return (_amountWithoutFee, _feeAmount);
  }

  function depositedAmountOf(address _account) public view returns (uint256){
    return IERC20(harvestTicket).balanceOf(_account);
  }

  // Increase the tokens to contract
  function deposit(uint256 _amount) external whenNotPaused{
    require(_amount <= IERC20(cauToken).balanceOf(msg.sender), "HARVEST: INSUFICIENT_BALANCE");
    require(IERC20(cauToken).allowance(msg.sender, address(this)) >= _amount, "HARVEST: AMOUNT_EXCEEDS_ALLOWANCE");
    require(_amount > 0, "HARVEST: INVALID_AMOUNT");

    // Depositing the token amount
    TransferHelper.safeTransferFrom(cauToken, msg.sender, address(this), _amount);
    // Incrementing the amount deposited
    IHarvestTicket(harvestTicket).mint(msg.sender, _amount);
    // Emiting event
    emit Deposit(msg.sender, _amount);
  }

  // ReDeposit the tokens earned
  function reDeposit() external whenNotPaused{
    // Obtaining the harvest available
    uint256 _amount = IHarvestTicket(harvestTicket).harvestAvailableOf(msg.sender);
    require(_amount > 0, "HARVEST: INSUFICIENT_TOKENS_TO_REDEPOSIT");
    // Applying fee
    // (uint256 _amountWithoutFee, uint256 _feeAmount) = _applyFee(_amount);
    // Redepositing the gain
    IHarvestTicket(harvestTicket).harvestForUserTo(msg.sender, address(this));
    // Incrementing the amount deposited
    IHarvestTicket(harvestTicket).mint(msg.sender, _amount);
    // Emiting event
    emit ReDeposit(msg.sender, _amount);
  }

  // Removes the tokens deposited
  function withdraw(uint256 _amount) external{
    require(_amount > 0, "HARVEST: INVALID_AMOUNT");
    require(_amount <= IHarvestTicket(harvestTicket).balanceOf(msg.sender), "HARVEST: INSUFICIENT_DEPOSITED_AMOUNT");
    // Applying fee
    (uint256 _amountWithoutFee, uint256 _feeAmount) = _applyFee(_amount);
    // Decrementing the amount deposited
    IHarvestTicket(harvestTicket).burnFrom(msg.sender, _amount);
    // Sending amount to user
    TransferHelper.safeTransfer(cauToken, msg.sender, _amountWithoutFee);
    TransferHelper.safeTransfer(cauToken, feeTo, _feeAmount);
    // Emiting event
    emit Withdraw(msg.sender, _amountWithoutFee, _feeAmount);
  }

  // Harvest the tokens earned
  function harvest() external{
    // Obtaining the harvest available
    uint256 _amount = IHarvestTicket(harvestTicket).harvestAvailableOf(msg.sender);
    require(_amount > 0, "HARVEST: UNAVAILABLE_HARVEST");
    // Applying fee
    (uint256 _amountWithoutFee, uint256 _feeAmount) = _applyFee(_amount);
    // Withdrawing amount paying fee
    IHarvestTicket(harvestTicket).harvestForUserDelegated(msg.sender, feeTo, _feeAmount);
    // Emiting event
    emit Harvest(msg.sender, _amountWithoutFee, _feeAmount);
  }

  // Redeem all the tokens including the earned ones
  function withdrawAndHarvest() external{
    uint256 _deposited = IHarvestTicket(harvestTicket).balanceOf(msg.sender);
    uint256 _harvest = IHarvestTicket(harvestTicket).harvestAvailableOf(msg.sender);
    if(_harvest > 0) IHarvestTicket(harvestTicket).harvestForUserTo(msg.sender, address(this));
    uint256 fullAmountToSend = _deposited.add(_harvest);
    // Applying fee
    (uint256 _amountWithoutFee, uint256 _feeAmount) = _applyFee(fullAmountToSend);
    // Decrementing the amount deposited
    IHarvestTicket(harvestTicket).burnFrom(msg.sender, _deposited);
    // Sending amount to user
    TransferHelper.safeTransfer(cauToken, feeTo, _feeAmount);
    TransferHelper.safeTransfer(cauToken, msg.sender, _amountWithoutFee);
    // Emiting event
    emit WithdrawAndHarvest(msg.sender, _deposited, _harvest, _amountWithoutFee, _feeAmount);
  }

  // Distribute the tokens (_percentage is in 8 decimal places)
  function distribute(uint256 _percentage) external onlyOwerOrAdmin whenNotPaused{
    require(_percentage > 0, "HARVEST: INVALID_PERCENTAGE");
    uint256 _amount = _percentage.mul(tokensDeposited());
    _amount = _amount.div(10000000000);
    require(_amount > 0, "HARVEST: INSUFICIENT_DISTRIBUTION_TOKENS");
    require(distributionTokensAvailable() >= _amount, "HARVEST: INSUFICIENT_DISTRIBUTION_TOKENS");
    TransferHelper.safeTransfer(cauToken, harvestTicket, _amount);
    IHarvestTicket(harvestTicket).distribute(_amount);
  }

  // Simulate distribution (_percentage is in 8 decimal places)
  function simulateDistribution(uint256 _percentage, uint256 _tokensDeposited) external pure returns (uint256) {
    uint256 _amount = _percentage.mul(_tokensDeposited);
    return _amount.div(10000000000);
  }

  // Pause deposits
  function pause() external onlyOwerOrAdmin{
    _pause();
  }

  // Unpause deposits
  function unpause() external onlyOwerOrAdmin{
    _unpause();
  }

  // Tokens available for distribution
  function distributionTokensAvailable() public view returns (uint256){
    return IERC20(cauToken).balanceOf(address(this)).sub(tokensDeposited());
  }

  // Tokens available for redemption of user
  function harvestAvailableOf(address _owner) public view returns(uint256) {
    return IHarvestTicket(harvestTicket).harvestAvailableOf(_owner);
  }

  // Tokens distributed
  function tokensDistributed() public view returns (uint256){
    return IHarvestTicket(harvestTicket).tokensDistributed();
  }

  // Amount of distributions made
  function distributionsAmount() external view returns (uint256){
    return IHarvestTicket(harvestTicket).distributionsAmount();
  }

  function tokensDeposited() public view returns (uint256){
    return IHarvestTicket(harvestTicket).totalSupply();
  }

  // To recover tokens from contract
  function retrieveCauTokens(uint256 _amount, address _to) external onlyOwner checkValidAddress(_to){
    require(_amount > 0, "HARVEST: INVALID_AMOUNT");
    require(_amount <= IERC20(cauToken).balanceOf(address(this)).sub(tokensDeposited()), "HARVEST: INSUFICIENT_BALANCE");
    TransferHelper.safeTransfer(cauToken, _to, _amount);
  }

  function retrieveTokens(address _token, uint256 _amount, address _to) external onlyOwner checkValidAddress(_to){
    require(_amount > 0, "HARVEST: INVALID_AMOUNT");
    require(_token != cauToken, "HARVEST: INVALID_TOKEN_ADDRESS");
    require(_amount <= IERC20(_token).balanceOf(address(this)), "HARVEST: INSUFICIENT_CONTRACT_BALANCE");
    TransferHelper.safeTransfer(_token, _to, _amount);
  }
}