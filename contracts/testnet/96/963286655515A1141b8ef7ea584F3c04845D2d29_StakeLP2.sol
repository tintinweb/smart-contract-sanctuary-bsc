/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;



// Part: IPancakeSwapPair

interface IPancakeSwapPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

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

// Part: IPinkAntiBot

interface IPinkAntiBot {
    function setTokenOwner(address owner) external;

    function onPreTransferCheck(
        address from,
        address to,
        uint256 amount
    ) external;
}

// Part: IToken

interface IToken {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(uint256 amount) external;

    function balanceOf(address _user) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    /**
     @return taxAmount // total Tax Amount
     @return taxType // How the tax will be distributed
    */
    function calculateTransferTax(
        address from,
        address to,
        uint256 amount
    ) external returns (uint256 taxAmount, uint8 taxType);

    function approve(address spender, uint256 amount) external returns (bool);
}

// Part: ITokenLocker

interface ITokenLocker {
    function updateLock() external;
}

// Part: IVault

interface IVault {
    /**
    * @param amount total amount of tokens to recevie
    * @param _type type of spread to execute.
      Stake Vault - Reservoir Collateral - Treasury
      0: do nothing
      1: Buy Spread 5 - 5 - 3
      2: Sell Spread 5 - 5 - 8
    * @param _customTaxSender the address where the tax is originated from.
      @return bool as successful spread op
    **/
    function spread(
        uint256 amount,
        uint8 _type,
        address _customTaxSender
    ) external returns (bool);

    function withdraw(address _address, uint256 amount) external;

    function withdraw(uint256 amount) external;
}

// Part: OpenZeppelin/[email protected]/Address

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

// Part: OpenZeppelin/[email protected]/Context

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

// Part: OpenZeppelin/[email protected]/IERC20

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

// Part: OpenZeppelin/[email protected]/SafeMath

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// Part: OpenZeppelin/[email protected]/IERC20Metadata

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

// Part: OpenZeppelin/[email protected]/Ownable

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

// Part: OpenZeppelin/[email protected]/SafeERC20

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

// Part: OpenZeppelin/[email protected]/ERC20

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
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
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
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
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
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
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
        return 18;
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

// Part: TokenLocker

contract TokenLocker is Ownable, ITokenLocker {
    uint256 public unlockTime;
    uint256 public prevLockAmount;
    address public immutable token;

    constructor(address _token) {
        require(_token != address(0), "Invalid Token");
        unlockTime = block.timestamp + 12 weeks;
        token = _token;
    }

    function updateLock() external {
        if (prevLockAmount >= IToken(token).balanceOf(address(this))) return;
        prevLockAmount = IToken(token).balanceOf(address(this));
        unlockTime = block.timestamp + 12 weeks;
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        require(unlockTime < block.timestamp, "Funds Locked");
        uint256 availAmount = IToken(token).balanceOf(address(this));
        require(availAmount >= amount, "Insufficient Funds");
        IToken(token).transfer(owner(), amount);
        prevLockAmount -= amount;
    }

    // In case tokens not associated with this locker are sent to the contract
    function withdrawOtherTokens(address _wrongToken) external onlyOwner {
        require(_wrongToken != token, "No sneaky");
        uint256 amount = IToken(_wrongToken).balanceOf(address(this));
        require(amount > 0, "No tokens");
        IToken(token).transfer(owner(), amount);
    }
}

// Part: StakeToken

contract StakeToken is ERC20, Ownable {
    uint256 public transferTax;
    uint256 public sellTax;
    uint256 public buyTax;

    mapping(address => uint256) public customTaxes;
    mapping(address => bool) public hasCustomTaxes; // Custom taxes have an extra 2 zeroes.
    mapping(address => bool) public exclusions; //Send
    mapping(address => bool) public receiveExclusions;
    mapping(address => bool) public liquidityPairs;
    address public vault;
    address public pool;
    bool private vaultIsContract = false;
    uint256 public lastMint;

    uint256 public constant INIT_SUPPLY = 750000 ether;
    uint256 public constant CUSTOM_TAX_BASE = 10000;
    uint256 public constant MAX_SUPPLY = 5000000 ether;

    // ANTI BOT
    IPinkAntiBot public pinkAntiBot;
    bool public antiBotEnabled = true;

    modifier onlyPool() {
        require(pool != address(0) && msg.sender == pool, "Not the pool");
        _;
    }

    constructor(address _vault) ERC20("Stake Token", "STAKE") {
        require(_vault != address(0), "Incorrect address");
        transferTax = 10;
        sellTax = 18;
        buyTax = 11;
        vault = _vault;
        _mint(owner(), INIT_SUPPLY);
        // This conditional is not on mainnet since it's only used for testing
        if (block.chainid == 56) {
            pinkAntiBot = IPinkAntiBot(
                0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002
            );
            pinkAntiBot.setTokenOwner(owner());
        } else {
            antiBotEnabled = false;
        }
        pool = address(0);
        lastMint = block.timestamp;
    }

    function setEnableAntiBot(bool _enable) external onlyOwner {
        antiBotEnabled = _enable;
    }

    function setPool(address _pool) external onlyOwner {
        require(_pool != address(0) && pool == address(0), "zero address");
        pool = _pool;
    }

    function setAllTaxes(
        uint256 _transferTax,
        uint256 _sell,
        uint256 _buy
    ) external onlyOwner {
        require(
            _buy <= 25 && _sell <= 25 && _transferTax <= 20,
            "Invalid Tax Amount"
        );
        transferTax = _transferTax;
        sellTax = _sell;
        buyTax = _buy;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        if (antiBotEnabled) pinkAntiBot.onPreTransferCheck(from, to, amount);

        (uint256 taxAmount, uint8 taxType) = calculateTransferTax(
            from,
            to,
            amount
        );
        uint256 realizedAmount = amount - taxAmount;
        address _taxUser = taxType == 4 ? from : address(0);
        if (taxAmount > 0 && taxType > 0) {
            super._transfer(from, vault, taxAmount);
            if (taxType > 0 && vaultIsContract) {
                try
                    IVault(vault).spread(taxAmount, taxType, _taxUser)
                {} catch {}
            }
        }

        super._transfer(from, to, realizedAmount);
    }

    function calculateTransferTax(
        address from,
        address to,
        uint256 amount
    ) public view returns (uint256, uint8 _type) {
        // BUY 1, SELL 2, Transfer 3, Custom 4
        // Protocol Owned Liquidity and exclusions will handle taxes themselves.
        if (exclusions[from] || receiveExclusions[to]) return (0, 0);
        if (hasCustomTaxes[from])
            return ((customTaxes[from] * amount) / CUSTOM_TAX_BASE, 4);
        if (liquidityPairs[from]) return ((buyTax * amount) / 100, 1);
        if (liquidityPairs[to]) return ((sellTax * amount) / 100, 2);
        return ((transferTax * amount) / 100, 3);
    }

    function setCustomTax(address _contract, uint256 _tax) external onlyOwner {
        require(_tax <= CUSTOM_TAX_BASE / 4, "Tax too large");
        customTaxes[_contract] = _tax;
    }

    function setCustomTaxStatus(address _contract, bool _status)
        external
        onlyOwner
    {
        hasCustomTaxes[_contract] = _status;
    }

    function excludeAddress(
        address _address,
        bool _all,
        bool _isReceive
    ) public onlyOwner {
        if (_all) {
            receiveExclusions[_address] = true;
            exclusions[_address] = true;
            return;
        }
        if (_isReceive) {
            receiveExclusions[_address] = true;
            return;
        }
        exclusions[_address] = true;
    }

    function excludeMultiple(
        address[] calldata _addresses,
        bool _all,
        bool _isReceive
    ) external onlyOwner {
        uint256 totalAddresses = _addresses.length;
        require(totalAddresses > 0, "Empty");
        for (uint256 i = 0; i < totalAddresses; i++) {
            excludeAddress(_addresses[i], _all, _isReceive);
        }
    }

    function removeExclusions(
        address _address,
        bool _all,
        bool _isReceive
    ) public onlyOwner {
        if (_all) {
            receiveExclusions[_address] = false;
            exclusions[_address] = false;
            return;
        }
        if (_isReceive) {
            receiveExclusions[_address] = false;
            return;
        }
        exclusions[_address] = false;
    }

    function removeMultiple(
        address[] calldata _addresses,
        bool _all,
        bool _isReceive
    ) external onlyOwner {
        uint256 totalAddresses = _addresses.length;
        require(totalAddresses > 0, "Empty");
        for (uint256 i = 0; i < totalAddresses; i++) {
            removeExclusions(_addresses[i], _all, _isReceive);
        }
    }

    function updateVault(address _vault, bool _isContract) external onlyOwner {
        require(_vault != address(0) && !vaultIsContract, "Invalid vault");
        vault = _vault;
        vaultIsContract = _isContract;
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    // We don't stop execution if mint is unsuccessful.
    function mint(uint256 amount) public onlyPool returns (bool) {
        if (
            pool != address(0) &&
            amount > 0 &&
            amount <= (totalSupply() / 960) && // max mint of 5% of total Supply daily every 30 min
            amount + totalSupply() <= MAX_SUPPLY &&
            block.timestamp - lastMint > 30 minutes // mint available only every 30 min.
        ) {
            _mint(pool, amount);
            lastMint = block.timestamp;
            return true;
        }
        return false;
    }

    function addLiquidityPair(address _pair) external onlyOwner {
        require(_pair != address(0), "zero address");
        require(
            IPancakeSwapPair(_pair).factory() != address(0),
            "Invalid pair"
        );
        liquidityPairs[_pair] = true;
    }
}

// File: StakeFountainV2.sol

/// 06/13/2022 @DEV PLEASE NOTICE THE FOLLOWING:
/// This is a modified version of the StakeFountain. It uses BUSD instead of BNB, so assume every instance of BNB as BUSD. Functions and vars will have the same names as in V1.

/// This contract will be in charge of swapping BNB for $STAKE, adding Liquidity as $STAKE/BNB and minting LP token to user for the given amount

/// When the user swaps from BNB to STAKE, 3% of it is sent to treasury as BNB.
/// Operators should not be taxed

/// When user swaps from STAKE to BNB, 18% of the STAKE is taxed.
/// 13% of the total value to swap is converted to BNB and sent to treasury.
/// 5% of the STAKE to swap is converted to LP token by converting half of it to BNB and then sent to foundation.

/// Taxes will never be over 25% and can be edited

contract StakeLP2 is ERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    // Vars
    StakeToken public token; // ERC20 token traded on this contract
    TokenLocker public token_lock;
    IToken public busd_token;
    address public treasury;
    address public vault;
    address public foundation;

    // BNB to token fee percentages
    uint256 public bt_treasury_fee;
    uint256 public bt_input_minus_fees;

    // Token to BNB fee percentages
    uint256 public tb_fee_total;
    uint256 public tb_treasury_fee;
    uint256 public tb_vault_fee;
    uint256 public tb_lock_fee;
    uint256 public tb_foundation_fee;
    uint256 public tb_input_with_total_fees;
    uint256 public tb_output_with_total_fees;
    uint256 public tb_input_minus_fees;

    // Contract stats
    uint256 public totalTxs;
    uint256 public lastBalance_;
    uint256 public trackingInterval_ = 1 minutes;
    uint256 public providers;

    // Maps
    mapping(address => bool) public whitelist;
    mapping(address => bool) public _providers;
    mapping(address => uint256) public _txs;

    // Events
    event onTokenPurchase(
        address indexed buyer,
        uint256 indexed bnb_amount,
        uint256 indexed token_amount
    );
    event onBnbPurchase(
        address indexed buyer,
        uint256 indexed token_amount,
        uint256 indexed bnb_amount
    );
    event onAddLiquidity(
        address indexed provider,
        uint256 indexed bnb_amount,
        uint256 indexed token_amount
    );
    event onRemoveLiquidity(
        address indexed provider,
        uint256 indexed bnb_amount,
        uint256 indexed token_amount
    );
    event onLiquidity(address indexed provider, uint256 indexed amount);
    event onContractBalance(uint256 balance);
    event onPrice(uint256 price);
    event onSummary(uint256 liquidity, uint256 price);
    event OperatorAddressAdded(address operator);
    event OperatorAddressRemoved(address operator);
    event TreasuryFee(uint256 amount);
    event VaultFee(uint256 amount);
    event FoundationFee(
        uint256 bnb_amount,
        uint256 stake_amount,
        uint256 liquidity_minted
    );
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);
    event SetLock(address addr);
    event BnbToTokenTax(uint256 treasury);
    event TokenToBnbTaxSpread(
        uint256 treasury,
        uint256 vault,
        uint256 foundation,
        uint256 lock
    );

    constructor(
        address _token,
        address _treasury,
        address _vault,
        address _foundation,
        address _busd_address
    ) ERC20("Stake LP", "STOKE") {
        token = StakeToken(_token);
        busd_token = IToken(_busd_address);
        lastBalance_ = block.timestamp;
        treasury = _treasury;
        vault = _vault;
        foundation = _foundation;
        setFees(3, 20, 0, 5);
    }

    /***********************************|
    |         SETUP FUNCTIONS           |
    |__________________________________*/

    /// @dev Sets lock address. Make sure to set a lock address after deploying.
    /// @param _lock token lock address
    function setLock(address _lock) external onlyOwner {
        token_lock = TokenLocker(_lock);
        emit SetLock(_lock);
    }

    /// @dev Update the treasury wallet to another destination... used when treasury contract is live
    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != owner(), "Treasury not owner");
        treasury = _treasury;
    }

    /// @dev Update the foundation wallet to another destination... used when foundation contract is live
    function setFoundation(address _foundation) external onlyOwner {
        require(_foundation != owner(), "Foundation not owner");
        foundation = _foundation;
    }

    /// @dev Sets fee amount numerators to calculate percentage. It also calculates input and output multipliers.
    /// @param _bt_treasury bnb to token treasury fee
    /// @param _tb_treasury token to bnb treasury fee
    /// @param _tb_vault bnb to token treasury fee
    /// @param _tb_foundation_and_lock bnb to token treasury fee

    function setFees(
        uint256 _bt_treasury,
        uint256 _tb_treasury,
        uint256 _tb_vault,
        uint256 _tb_foundation_and_lock
    ) public onlyOwner {
        tb_fee_total = _tb_treasury + _tb_vault + _tb_foundation_and_lock;
        require(_bt_treasury <= 25 && tb_fee_total <= 25);

        // BNB to token
        bt_treasury_fee = _bt_treasury; // Please divide bt_treasury_fee/100
        bt_input_minus_fees = 100 - bt_treasury_fee; // Please divide bt_input_minus_fees/100

        // Token to BNB
        tb_treasury_fee = _tb_treasury; // Please divide tb_treasury_fee/100
        tb_vault_fee = _tb_vault; //Please divide tb_vault_fee/100
        tb_lock_fee = 9 * _tb_foundation_and_lock; // Please divide tb_lock_fee/1000
        tb_foundation_fee = (10 * _tb_foundation_and_lock) - tb_lock_fee; // Please divide tb_foundation_fee/1000
        tb_input_minus_fees = 100 - tb_fee_total; // Please divide tb_input_with_total_fees/100

        emit BnbToTokenTax(bt_treasury_fee);
        emit TokenToBnbTaxSpread(
            tb_treasury_fee,
            tb_vault_fee,
            tb_foundation_fee,
            tb_lock_fee
        );
    }

    /***********************************|
    |        WHITELIST FUNCTIONS        |
    |__________________________________*/
    // Whitelisted addresses pay no tax when swapping

    /**
     * @dev add an address to the whitelist
     * @param addr address
     */
    function addAddressToWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    /**
     * @dev add addresses to the whitelist
     * @param addrs addresses
     */
    function addAddressesToWhitelist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
    }

    /**
     * @dev remove an address from the whitelist
     * @param addr address
     */
    function removeAddressFromWhitelist(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
        return success;
    }

    /**
     * @dev remove addresses from the whitelist
     * @param addrs addresses
     */
    function removeAddressesFromWhitelist(address[] memory addrs)
        public
        onlyOwner
        returns (bool success)
    {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
    }

    /***********************************|
    |    $STAKE  EXCHANGE FUNCTIONS     |
    |__________________________________*/

    /**
     * @notice Convert BNB to Tokens.
     * @dev User specifies exact input (msg.value).
     */
    function receiveBusd(uint256 _busd_amount) external {
        bnbToTokenInput(_busd_amount, 1, msg.sender, msg.sender);
    }

    /**
     * @dev Pricing function for converting between BNB && Tokens without fee.
     * @param input_amount Amount of BNB or Tokens being sold.
     * @param input_reserve Amount of BNB or Tokens (input type) in exchange reserves.
     * @param output_reserve Amount of BNB or Tokens (output type) in exchange reserves.
     * @return Amount of BNB or Tokens bought.
     */
    function getInputPrice(
        uint256 input_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) public pure returns (uint256) {
        require(input_reserve > 0 && output_reserve > 0, "INVALID_VALUE");
        uint256 numerator = input_amount * output_reserve;
        uint256 denominator = input_reserve + input_amount;
        return numerator / denominator;
    }

    /**
     * @dev Pricing function for converting between BNB && Tokens without fee.
     * @param output_amount Amount of BNB or Tokens being bought.
     * @param input_reserve Amount of BNB or Tokens (input type) in exchange reserves.
     * @param output_reserve Amount of BNB or Tokens (output type) in exchange reserves.
     * @return Amount of BNB or Tokens sold.
     */
    function getOutputPrice(
        uint256 output_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) public pure returns (uint256) {
        require(input_reserve > 0 && output_reserve > 0);
        uint256 numerator = input_reserve * output_amount;
        uint256 denominator = (output_reserve - output_amount);
        return (numerator / denominator) + 1;
    }

    /**
     * @dev Function to convert BNB into STAKE. Set an amount of BNB to obtain an amount of tokens. Fees included.
     * @param _bnb_sold Amount of BNB that user has paid to buy tokens.
     * @param _min_tokens Amount of minimum tokens after slippage.
     * @param _buyer address that paid for the tokens.
     * @param _recipient address that will receive the tokens.
     */
    function bnbToTokenInput(
        uint256 _bnb_sold,
        uint256 _min_tokens,
        address _buyer,
        address _recipient
    ) private returns (uint256) {
        require(_bnb_sold > 0 && _min_tokens > 0, "sold and min 0");
        uint256 bnb_sold;
        uint256 treasury_fee;
        uint256 token_reserve = token.balanceOf(address(this));
        require(
            busd_token.transferFrom(_buyer, address(this), _bnb_sold),
            "BUSD transfer error"
        );
        uint256 bnb_reserve = busd_token.balanceOf(address(this));

        if (whitelist[_buyer] && whitelist[_recipient]) {
            bnb_sold = _bnb_sold;
        } else {
            treasury_fee = (bt_treasury_fee * _bnb_sold) / 100;
            bnb_sold = _bnb_sold - treasury_fee;
        }
        uint256 tokens_bought = getInputPrice(
            bnb_sold,
            bnb_reserve - bnb_sold,
            token_reserve
        );

        require(tokens_bought >= _min_tokens, "tokens_bought >= min_tokens");
        // Transferring tokens to msg.sender and transferring fee
        require(
            token.transfer(_recipient, tokens_bought),
            "Token transfer error"
        );
        if (treasury_fee > 0) transferTreasuryFee(treasury_fee);

        emit TreasuryFee(treasury_fee);
        emit onTokenPurchase(_buyer, _bnb_sold, tokens_bought);
        emit onContractBalance(bnbBalance());

        trackGlobalStats();

        return tokens_bought;
    }

    /**
     * @notice Convert BNB to Tokens.
     * @dev User specifies exact input (msg.value) && minimum output.
     * @param min_tokens Minimum Tokens bought. Considers slippage.
     * @return Amount of Tokens bought.
     */
    function bnbToTokenSwapInput(uint256 min_tokens, uint256 busd_amount)
        public
        returns (uint256)
    {
        return bnbToTokenInput(busd_amount, min_tokens, msg.sender, msg.sender);
    }

    /**
     * @dev Function to convert BNB into STAKE. Set an amount of STAKE get it at a price in BNB .
     * @param _tokens_bought Set amount of tokens
     * @param _max_bnb Maximum amount of BNB that can be charged for the set amount of stake.
     * @param _buyer address that paid for the tokens.
     * @param _recipient address that will receive the tokens.
     */
    function bnbToTokenOutput(
        uint256 _tokens_bought,
        uint256 _max_bnb,
        address _buyer,
        address _recipient
    ) private returns (uint256) {
        require(_tokens_bought > 0 && _max_bnb > 0);
        uint256 total_bnb_sold;
        uint256 treasury_fee;
        uint256 token_reserve = token.balanceOf(address(this));
        require(
            busd_token.transferFrom(_buyer, address(this), _max_bnb),
            "BUSD transfer error"
        );
        uint256 bnb_reserve = busd_token.balanceOf(address(this));
        uint256 bnb_sold = getOutputPrice(
            _tokens_bought,
            bnb_reserve - _max_bnb,
            token_reserve
        );
        if (whitelist[_buyer] && whitelist[_recipient]) {
            total_bnb_sold = bnb_sold;
        } else {
            treasury_fee = (bt_treasury_fee * total_bnb_sold) / 100;
            total_bnb_sold = (bt_input_minus_fees * bnb_sold) / 100;
        }

        require(
            token.transfer(_recipient, _tokens_bought),
            "Token transfer error"
        );
        // Throws if total_bnb_sold > _max_bnb
        uint256 bnb_refund = _max_bnb - total_bnb_sold;
        if (bnb_refund > 0) {
            bool succ = busd_token.transfer(_buyer, bnb_refund);
            require(succ, "Refund failed");
        }
        if (treasury_fee > 0) transferTreasuryFee(treasury_fee);
        emit TreasuryFee(treasury_fee);
        emit onTokenPurchase(_buyer, total_bnb_sold, _tokens_bought);
        emit TreasuryFee(treasury_fee);
        trackGlobalStats();
        return total_bnb_sold;
    }

    /**
     * @notice Convert BNB to Tokens.
     * @dev User specifies maximum input (msg.value) && exact output.
     * @param tokens_bought Amount of tokens bought.
     * @return Amount of BNB sold.
     */
    function bnbToTokenSwapOutput(uint256 tokens_bought, uint256 busd_amount)
        public
        returns (uint256)
    {
        return
            bnbToTokenOutput(
                tokens_bought,
                busd_amount,
                msg.sender,
                msg.sender
            );
    }

    /**
     * @dev Function to convert STAKE into BNB. Taxes before calculating and transferring the tokens.
     * When user swaps from STAKE to BNB, tb_total_input_fee of the STAKE is taxed from total swapped
     * tb_treasury_fee of the total value to swap is converted to BNB and sent to treasury
     * tb_vault_fee of the STAKE to swap is sent to vault in STAKE
     * tb_foundation_and_lock of the STAKE to swap is converted to LP token by converting half of it to BNB and then sent to foundation and lock
     * @param _tokens_sold Amount of STAKE that user has paid to buy BNB
     * @param _min_bnb Amount of minimum BNB after slippage
     * @param _buyer address that transferred the tokens
     * @param _recipient address that will receive the BNB
     */
    function tokenToBnbInput(
        uint256 _tokens_sold,
        uint256 _min_bnb,
        address _buyer,
        address _recipient
    ) private returns (uint256) {
        require(_tokens_sold > 0 && _min_bnb > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_reserve = busd_token.balanceOf(address(this));
        uint256 total_bnb_bought;
        uint256 bnb_bought = getInputPrice(
            _tokens_sold,
            token_reserve,
            bnb_reserve
        );
        require(bnb_bought >= _min_bnb);
        if (whitelist[_buyer] && whitelist[_recipient]) {
            total_bnb_bought = bnb_bought;
        } else {
            total_bnb_bought = (tb_input_minus_fees * bnb_bought) / 100;
            tokenToBnbFees(bnb_bought, _tokens_sold, bnb_reserve);
        }
        require(
            token.transferFrom(_buyer, address(this), _tokens_sold),
            "Token transaction error"
        );
        require(
            busd_token.transfer(_recipient, total_bnb_bought),
            "BUSD transaction error"
        );
        emit onBnbPurchase(_buyer, _tokens_sold, total_bnb_bought);
        trackGlobalStats();
        return total_bnb_bought;
    }

    /**
     * @notice Convert Tokens to BNB.
     * @dev User specifies exact input && minimum output.
     * @param tokens_sold Amount of Tokens sold.
     * @param min_bnb Minimum BNB purchased.
     * @return Amount of BNB bought.
     */
    function tokenToBnbSwapInput(uint256 tokens_sold, uint256 min_bnb)
        public
        returns (uint256)
    {
        return tokenToBnbInput(tokens_sold, min_bnb, msg.sender, msg.sender);
    }

    function tokenToBnbOutput(
        uint256 _bnb_bought,
        uint256 _max_tokens,
        address _buyer,
        address _recipient
    ) private returns (uint256) {
        require(_bnb_bought > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_reserve = busd_token.balanceOf(address(this));
        uint256 tokens_sold = getOutputPrice(
            _bnb_bought,
            token_reserve,
            bnb_reserve
        );
        uint256 total_tokens_sold;
        require(_max_tokens >= tokens_sold, "max tokens exceeded");
        //Added fees into price in tokens
        if (whitelist[_buyer] && whitelist[_recipient]) {
            total_tokens_sold = tokens_sold;
        } else {
            total_tokens_sold = (100 * tokens_sold) / tb_input_minus_fees;
            tokenToBnbFees(_bnb_bought, total_tokens_sold, bnb_reserve);
        }

        // tokens sold is always > 0
        require(
            token.transferFrom(_buyer, address(this), total_tokens_sold),
            "Token transaction error"
        );
        require(
            busd_token.transfer(_recipient, _bnb_bought),
            "BUSD transaction error"
        );
        emit onBnbPurchase(_buyer, total_tokens_sold, _bnb_bought);
        trackGlobalStats();

        return total_tokens_sold;
    }

    /**
     * @notice Convert Tokens to BNB.
     * @dev User specifies maximum input && exact output.
     * @param bnb_bought Amount of BNB purchased.
     * @param max_tokens Maximum Tokens sold.
     * @return Amount of Tokens sold.
     */
    function tokenToBnbSwapOutput(uint256 bnb_bought, uint256 max_tokens)
        public
        returns (uint256)
    {
        return tokenToBnbOutput(bnb_bought, max_tokens, msg.sender, msg.sender);
    }

    function trackGlobalStats() private {
        uint256 price = getBnbToTokenOutputPrice(1e18);
        uint256 balance = busd_token.balanceOf(address(this));

        if (block.timestamp - lastBalance_ > trackingInterval_) {
            emit onSummary(balance * 2, price);
            lastBalance_ = block.timestamp;
        }

        emit onContractBalance(balance);
        emit onPrice(price);

        totalTxs += 1;
        _txs[msg.sender] += 1;
    }

    // Fee functions

    /// Function that charges the respective fee to treasury
    /// @param _treasury_fee is the amount of BNB charged as fee
    function transferTreasuryFee(uint256 _treasury_fee) internal {
        // Calculating fee and BNB sold
        require(_treasury_fee > 0);
        busd_token.transfer(treasury, _treasury_fee);
        emit TreasuryFee(_treasury_fee);
    }

    /// Function that calculates and transfers fees for treasury, vault, foundation and lock
    /// @param _bnb_bought is the amount of BNB that user has bought
    /// @param _tokens_sold is the amount of tokens user sells
    /// @param _bnb_reserve is this contract's bnb balance
    function tokenToBnbFees(
        uint256 _bnb_bought,
        uint256 _tokens_sold,
        uint256 _bnb_reserve
    ) internal {
        // 8% of the total value to swap is converted to BNB and sent to treasury.
        uint256 treasury_fee = (tb_treasury_fee * _bnb_bought) / 100;
        if (treasury_fee > 0) transferTreasuryFee(treasury_fee);

        // 5% of the STAKE to swap is sent to vault in STAKE.
        uint256 vault_fee = (tb_vault_fee * _tokens_sold) / 100;
        if (vault_fee > 0) token.transfer(vault, vault_fee);

        // 5% of the STAKE to swap is converted to LP token by converting half of it to BNB. Then 90% of it is sent to token lock and 10% to foundation.
        uint256 total_liquidity = totalSupply();
        uint256 foundation_fee_bnb = (tb_foundation_fee * _bnb_bought) / 2000;
        uint256 foundation_liquidity_minted = (foundation_fee_bnb *
            total_liquidity) / _bnb_reserve;

        uint256 lock_fee_bnb = (tb_lock_fee * _bnb_bought) / 2000;
        uint256 lock_liquidity_minted = (lock_fee_bnb * total_liquidity) /
            _bnb_reserve;

        if (foundation_liquidity_minted > 0)
            _mint(foundation, foundation_liquidity_minted);
        if (lock_liquidity_minted > 0)
            _mint(address(token_lock), lock_liquidity_minted);
        token_lock.updateLock();

        // Fee events
        emit TreasuryFee(treasury_fee);
        emit VaultFee(vault_fee);

        emit onLiquidity(foundation, balanceOf(foundation));
        emit Transfer(address(0), foundation, foundation_liquidity_minted);

        emit onLiquidity(address(token_lock), balanceOf(address(token_lock)));
        emit Transfer(address(0), address(token_lock), lock_liquidity_minted);
    }

    /// Exchange Getter Functions

    function getBnbToTokenInputPrice(uint256 bnb_sold)
        public
        view
        returns (uint256)
    {
        require(bnb_sold > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        return
            getInputPrice(
                bnb_sold,
                busd_token.balanceOf(address(this)),
                token_reserve
            );
    }

    /**
     * @notice Public price function for BNB to Token trades with an exact output.
     * @param tokens_bought Amount of Tokens bought.
     * @return Amount of BNB needed to buy output Tokens.
     */
    function getBnbToTokenOutputPrice(uint256 tokens_bought)
        public
        view
        returns (uint256)
    {
        require(tokens_bought > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_sold = getOutputPrice(
            tokens_bought,
            busd_token.balanceOf(address(this)),
            token_reserve
        );
        return bnb_sold;
    }

    /**
     * @notice Public price function for Token to BNB trades with an exact input.
     * @param tokens_sold Amount of Tokens sold.
     * @return Amount of BNB that can be bought with input Tokens.
     */
    function getTokenToBnbInputPrice(uint256 tokens_sold)
        public
        view
        returns (uint256)
    {
        require(tokens_sold > 0, "token sold < 0");
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_bought = getInputPrice(
            tokens_sold,
            token_reserve,
            busd_token.balanceOf(address(this))
        );
        return bnb_bought;
    }

    /**
     * @notice Public price function for Token to BNB trades with an exact output.
     * @param bnb_bought Amount of output BNB.
     * @return Amount of Tokens needed to buy output BNB.
     */
    function getTokenToBnbOutputPrice(uint256 bnb_bought)
        public
        view
        returns (uint256)
    {
        require(bnb_bought > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        return
            getOutputPrice(
                bnb_bought,
                token_reserve,
                busd_token.balanceOf(address(this))
            );
    }

    /**
     * @return Address of Token that is sold on this exchange.
     */
    function tokenAddress() public view returns (address) {
        return address(token);
    }

    function bnbBalance() public view returns (uint256) {
        return busd_token.balanceOf(address(this));
    }

    function tokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getBnbToLiquidityInputPrice(uint256 bnb_sold)
        public
        view
        returns (uint256, uint256)
    {
        require(bnb_sold > 0);
        uint256 token_amount = 0;
        uint256 total_liquidity = totalSupply();
        uint256 bnb_reserve = busd_token.balanceOf(address(this));
        uint256 token_reserve = token.balanceOf(address(this));
        token_amount = ((bnb_sold * token_reserve) / bnb_reserve) + 1;
        uint256 liquidity_minted = (bnb_sold * total_liquidity) / bnb_reserve;

        return (liquidity_minted, token_amount);
    }

    function getLiquidityToReserveInputPrice(uint256 amount)
        public
        view
        returns (uint256, uint256)
    {
        uint256 total_liquidity = totalSupply();
        require(total_liquidity > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_amount = (amount * busd_token.balanceOf(address(this))) /
            total_liquidity;
        uint256 token_amount = (amount * token_reserve) / total_liquidity;
        return (bnb_amount, token_amount);
    }

    function txs(address owner) public view returns (uint256) {
        return _txs[owner];
    }

    /// Exchange Liquidity Functions

    /**
     * @notice Deposit BNB && Tokens (STAKE) at current ratio to mint STOKE tokens.
     * @dev min_liquidity does nothing when total SWAP supply is 0.
     * @param min_liquidity Minimum number of STOKE sender will mint if total STAKE supply is greater than 0.
     * @param max_tokens Maximum number of tokens deposited. Deposits max amount if total STOKE supply is 0.
     * @return The amount of SWAP minted.
     */
    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 busd_amount
    ) public returns (uint256) {
        require(
            max_tokens > 0 && busd_amount > 0,
            "Swap#addLiquidity: INVALID_ARGUMENT"
        );
        require(
            busd_token.transferFrom(msg.sender, address(this), busd_amount),
            "busd transfer error"
        );
        uint256 total_liquidity = totalSupply();

        uint256 token_amount = 0;

        if (_providers[msg.sender] == false) {
            _providers[msg.sender] = true;
            providers += 1;
        }

        if (total_liquidity > 0) {
            require(min_liquidity > 0, "Min liq = 0");
            uint256 bnb_reserve = busd_token.balanceOf(address(this)) -
                busd_amount;
            uint256 token_reserve = token.balanceOf(address(this));
            token_amount = ((busd_amount * token_reserve) / bnb_reserve) + 1;
            uint256 liquidity_minted = (busd_amount * total_liquidity) /
                bnb_reserve;

            require(
                max_tokens >= token_amount && liquidity_minted >= min_liquidity,
                "require more tokens"
            );
            _mint(msg.sender, liquidity_minted);
            require(
                token.transferFrom(msg.sender, address(this), token_amount),
                "transfer from unsuccessful"
            );

            emit onAddLiquidity(msg.sender, busd_amount, token_amount);
            emit onLiquidity(msg.sender, balanceOf(msg.sender));
            emit Transfer(address(0), msg.sender, liquidity_minted);
            return liquidity_minted;
        } else {
            require(busd_amount >= 1 ether, "INVALID_VALUE");
            token_amount = max_tokens;
            uint256 initial_liquidity = busd_token.balanceOf(address(this));
            super._mint(msg.sender, initial_liquidity);
            require(
                token.transferFrom(msg.sender, address(this), token_amount),
                "TransferFrom unsuccessful"
            );

            emit onAddLiquidity(msg.sender, busd_amount, token_amount);
            emit onLiquidity(msg.sender, balanceOf(msg.sender));
            emit Transfer(address(0), msg.sender, initial_liquidity);
            return initial_liquidity;
        }
    }

    /**
     * @dev Burn SWAP tokens to withdraw BNB && Tokens at current ratio.
     * @param amount Amount of SWAP burned.
     * @param min_bnb Minimum BNB withdrawn.
     * @param min_tokens Minimum Tokens withdrawn.
     * @return The amount of BNB && Tokens withdrawn.
     */
    function removeLiquidity(
        uint256 amount,
        uint256 min_bnb,
        uint256 min_tokens
    ) public returns (uint256, uint256) {
        require(amount > 0 && min_bnb > 0 && min_tokens > 0);
        uint256 total_liquidity = totalSupply();
        require(total_liquidity > 0);
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 bnb_amount = (amount * busd_token.balanceOf(address(this))) /
            total_liquidity;
        uint256 token_amount = (amount * (token_reserve)) / total_liquidity;
        require(
            bnb_amount >= min_bnb && token_amount >= min_tokens,
            "Not enough received"
        );
        super._burn(msg.sender, amount);
        require(
            busd_token.transfer(msg.sender, bnb_amount),
            "Fail tranfer BUSD"
        );
        require(
            token.transfer(msg.sender, token_amount),
            "Failed STAKE Transfer"
        );
        emit onRemoveLiquidity(msg.sender, bnb_amount, token_amount);
        emit onLiquidity(msg.sender, balanceOf(msg.sender));
        emit Transfer(msg.sender, address(0), amount);
        return (bnb_amount, token_amount);
    }
}