/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


/** LIBRARY **/

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

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

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

    function _msgValue() internal view virtual returns (uint256) {
        return msg.value;
    }
}

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
abstract contract Auth is Context {
    

    /** DATA **/
    address private _owner;
    
    mapping(address => bool) internal authorizations;

    
    /** CONSTRUCTOR **/

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
        authorizations[_msgSender()] = true;
    }

    /** FUNCTION **/

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
     * @dev Throws if called by any account other authorized accounts.
     */
    modifier authorized() {
        require(isAuthorized(_msgSender()), "Ownable: caller is not an authorized account");
        _;
    }

    /**
     * @dev Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * @dev Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * @dev Check if address is owner
     */
    function isOwner(address adr) public view returns (bool) {
        return adr == owner();
    }

    /**
     * @dev Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
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
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
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


/** UNISWAP V2 INTERFACES **/

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}


/** ERC STANDARD **/

interface IERC20Extended {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

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
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}


/** REWARD POOL DISTRIBUTOR **/

interface IRewardPoolDistributor {

    function deposit() external payable;

    function distributeReward(address _user, uint256 _amount) external;

    function withdrawReward(uint256 _amount) external;

}

contract RewardPoolDistributor is IRewardPoolDistributor, Auth {
    

    /* LIBRARY */
    using SafeMath for uint256;
    using Address for address;


    /* DATA */
    IERC20Extended public rewardToken;
    IUniswapV2Router02 public router;
    
    struct Reward {
        uint256 totalReceived;
        uint256 totalAccumulated;
        uint256 currentLimit;
        uint256 limitReset;
    }

    address public _token;
    address public _owner;

    bool public initialized;
    
    uint256 public totalDistributed;
    uint256 public dailyLimit;
    uint256 public timeLimit;

    address private constant DEAD = address(0xdead);
    address private constant ZERO = address(0);

    mapping(address => Reward) public rewards;


    /* MODIFIER */
    modifier initializer() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(_msgSender() == _token);
        _;
    }
    
    modifier onlyTokenAndOwner() {
        require(_msgSender() == _token || _msgSender() == _owner);
        _;
    }


    /* CONSTRUCTOR */
    constructor(
        address rewardToken_,
        address router_,
        uint256 dailyLimit_
    ) {
        _token = _msgSender();
        _owner = _msgSender();
        rewardToken = IERC20Extended(rewardToken_);
        router = IUniswapV2Router02(router_);
        timeLimit = 1 days;
        dailyLimit = dailyLimit_ * (10**rewardToken.decimals());
    }


    /* FUNCTION */

    function unInitialized(bool initialization) external onlyToken {
        initialized = initialization;
    }

    function setTokenAddress(address token_) external initializer onlyToken {
        _token = token_;
    }

    function setDailyLimit(uint256 dailyLimit_) external authorized {
        dailyLimit = dailyLimit_ * (10**rewardToken.decimals());
    }

    function setTimeLimit(uint256 timeLimit_) external authorized {
        timeLimit = timeLimit_;
    }

    function migratePool(address _newPool) external onlyOwner {
        require(_newPool != ZERO && _newPool != DEAD && _newPool != _owner);
        uint256 rewardBalance = rewardToken.balanceOf(address(this));
        rewardToken.transfer(_newPool, rewardBalance);
    }

    function deposit() external payable override authorized onlyTokenAndOwner {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(rewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens {
            value: _msgValue()
        } (0, path, address(this), block.timestamp);
    }

    /**
     * @dev Distribute reward to the user and update reward information.
     */
    function distributeReward(address _user, uint256 _amount) external authorized {
        require(_user != DEAD && _user != ZERO && _amount > 0);
        if (needResetTimeLimit(_msgSender()) == true) {
            resetTimeLimit(_msgSender());
        }
        rewards[_user].totalAccumulated = rewards[_user].totalAccumulated.add(_amount);
    }

    function withdrawReward(uint256 _amount) external {
        if (needResetTimeLimit(_msgSender()) == true) {
            resetTimeLimit(_msgSender());
        } 
        require(rewards[_msgSender()].currentLimit >= _amount , "Exceed daily limit.");
        
        totalDistributed = totalDistributed.add(_amount);
        rewardToken.transfer(_msgSender(), _amount);
        rewards[_msgSender()].totalReceived = rewards[_msgSender()].totalReceived.add(_amount);
        rewards[_msgSender()].totalAccumulated = rewards[_msgSender()].totalAccumulated.sub(_amount);
        rewards[_msgSender()].currentLimit = rewards[_msgSender()].currentLimit.sub(_amount);
    }

    function resetTimeLimit(address _user) internal {
        uint256 timeDifference = block.timestamp.sub(rewards[_user].limitReset);
        uint256 timeCycle = timeDifference.div(timeLimit);
        if (rewards[_user].limitReset == 0) {
            rewards[_user].currentLimit += dailyLimit;
            rewards[_user].limitReset = block.timestamp;
        } else {
            rewards[_user].currentLimit += dailyLimit.mul(timeCycle);
            rewards[_user].limitReset += timeLimit.mul(timeCycle);
        }
    }

    function needResetTimeLimit(address _user) internal view returns (bool) {
        return block.timestamp >= rewards[_user].limitReset.add(timeLimit);
    }

}


/** APOCALYPSE **/

contract ApocalypseRandomizer {


    /** DATA **/
    
    uint256 internal constant maskLast8Bits = uint256(0xff);
    uint256 internal constant maskFirst248Bits = type(uint256).max;

    /** FUNCTION **/
       
    function sliceNumber(uint256 _n, uint256 _base, uint256 _index, uint256 _offset) public pure returns (uint256) {
        return _sliceNumber(_n, _base, _index, _offset);
    }

    /**
     * @dev Given a number get a slice of any bits, at certain offset.
     * 
     * @param _n a number to be sliced
     * @param _base base number
     * @param _index how many bits long is the new number
     * @param _offset how many bits to skip
     */
    function _sliceNumber(uint256 _n, uint256 _base, uint256 _index, uint256 _offset) internal pure returns (uint256) {
        uint256 mask = uint256((_base**_index) - 1) << _offset;
        return uint256((_n & mask) >> _offset);
    }

    function randomNGenerator(uint256 _param1, uint256 _param2, uint256 _targetBlock) public view returns (uint256) {
        return _randomNGenerator(_param1, _param2, _targetBlock);
    }

    /**
     * @dev Generate random number from the hash of the "target block".
     */
    function _randomNGenerator(uint256 _param1, uint256 _param2, uint256 _targetBlock) internal view returns (uint256) {
        uint256 randomN = uint256(blockhash(_targetBlock));
        
        if (randomN == 0) {
            _targetBlock = (block.number & maskFirst248Bits) + (_targetBlock & maskLast8Bits);
        
            if (_targetBlock >= block.number) {
                _targetBlock -= 256;
            }
            
            randomN = uint256(blockhash(_targetBlock));
        }

        randomN = uint256(keccak256(abi.encodePacked(randomN, _param1, _param2, _targetBlock)));

        return randomN;
    }

}

contract ApocalypseCharacter is ERC721, ERC721Enumerable, Pausable, Auth, ERC721Burnable {
    

    /** LIBRARY **/
    using Counters for Counters.Counter;
    using Strings for string;


    /** DATA **/
    string public URI;
    string private IPFS;
    string private cid;
    
    struct Character {
        uint256[3] charIndex;
        bool charEquip;
        uint256 charStatus;
        uint256 charType;
        uint256 charSkill;
        uint256 charLevel;
        uint256 charHP;
        uint256 charXP;
        uint256 charNextXP;
        uint256 baseAttack;
        uint256 baseDefence;
        uint256 angelModifier;
    }

    uint256 public addDef;
    uint256 public maxAngelModifier;
    uint256 public maxLevel;
    uint256 public baseHP;
    uint256 public upgradeBaseHP;
    uint256 public baseNextXP;
    uint256 public maxUpgradeStatus;

    uint256[2] public upgradePercentage;
    uint256[2] public rarePercentage;
    uint256[2] public commonBaseStat;
    uint256[2] public upgradeBaseStat;
    uint256[2] public rareBaseStat;

    uint256 public commonCurrentSupply;
    uint256 public upgradeCurrentSupply;
    uint256 public rareCurrentSupply;
    uint256 public totalMaxSupply;

    uint256[] public charStatus;
    uint256[] public charType;
    uint256[] public charSkill;

    Character[] public apocChar;

    ApocalypseRandomizer private randomizer;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => uint256) public currentCommonCharSupply;
    mapping(uint256 => mapping(uint256 => uint256)) public currentSpecificCommonCharSupply;
    mapping(uint256 => uint256) public currentUpgradeCharSupply;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) public currentSpecificUpgradeCharSupply;
    mapping(uint256 => uint256) public currentRareCharSupply;
    mapping(uint256 => mapping(uint256 => uint256)) public currentSpecificRareCharSupply;
    mapping(uint256 => uint256) public maxCommonCharSupply;
    mapping(uint256 => mapping(uint256 => uint256)) public maxSpecificCommonCharSupply;
    mapping(uint256 => uint256) public maxRareCharSupply;
    mapping(uint256 => mapping(uint256 => uint256)) public maxSpecificRareCharSupply;
    mapping(uint256 => uint256) public maxCharSupply;

    
    /** CONSTRUCTOR **/
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _URI,
        string memory _IPFS,
        string memory _cid,
        ApocalypseRandomizer _randomizer
    ) ERC721(_name, _symbol) {
        randomizer = _randomizer;
        URI = _URI;
        IPFS = _IPFS;
        cid = _cid;
        
        commonBaseStat = [1, 1];
        upgradeBaseStat = [5, 5];
        rareBaseStat = [10, 10];

        upgradePercentage = [1, 2];
        rarePercentage = [5, 4];

        maxUpgradeStatus = 2;
        setDefaultInfo(50, 1000, 1500, 1000, 3);

        charStatus = [0,1,2];
        charType = [1,2];
        charSkill = [1,2,3,4,5];

        addSpecificMaxCharSupply(0, 1, 1, 2); // 2 dark knight fencing
        addSpecificMaxCharSupply(0, 1, 2, 2); // 2 dark knight axe
        addSpecificMaxCharSupply(0, 1, 3, 2); // 2 dark knight bow
        addSpecificMaxCharSupply(0, 1, 4, 2); // 2 dark knight sword
        addSpecificMaxCharSupply(0, 1, 5, 2); // 2 dark knight hammer
        addSpecificMaxCharSupply(0, 2, 1, 2); // 2 dark wizard energy
        addSpecificMaxCharSupply(0, 2, 2, 2); // 2 dark wizard lightning
        addSpecificMaxCharSupply(0, 2, 3, 2); // 2 dark wizard earth
        addSpecificMaxCharSupply(0, 2, 4, 2); // 2 dark wizard ice
        addSpecificMaxCharSupply(0, 2, 5, 2); // 2 dark wizard fire

        addSpecificMaxCharSupply(1, 1, 1, 1000); // 1000 fencing warriors
        addSpecificMaxCharSupply(1, 1, 2, 1000); // 1000 axe warriors
        addSpecificMaxCharSupply(1, 1, 3, 1000); // 1000 bow warriors
        addSpecificMaxCharSupply(1, 1, 4, 1000); // 1000 sword warriors
        addSpecificMaxCharSupply(1, 1, 5, 1000); // 1000 hammer warriors                        
        addSpecificMaxCharSupply(1, 2, 1, 1000); // 1000 energy mages
        addSpecificMaxCharSupply(1, 2, 2, 1000); // 1000 lightning mages
        addSpecificMaxCharSupply(1, 2, 3, 1000); // 1000 earth mages
        addSpecificMaxCharSupply(1, 2, 4, 1000); // 1000 ice mages
        addSpecificMaxCharSupply(1, 2, 5, 1000); // 1000 fire mages

        _createCharacter(
            [uint256(0),uint256(0),uint256(0)],
            0,
            0,
            0,
            1,
            baseHP,
            baseNextXP,
            commonBaseStat[0],
            commonBaseStat[1]        
        );

        _safeMint(_msgSender());

    }


    /** EVENT **/

    event MintNewCharacter(address _tokenOwner, uint256 _tokenID);
    event AirdropCharacter(address _tokenOwner, uint256 _tokenID);
    event AddCharacterSupply(uint256 _maxCharSupply);
    event SuccessfulCharacterUpgrade(address _owner, uint256 _tokenID1, uint256 _tokenID2, uint256 tokenID);
    event FailedCharacterUpgrade(address _owner, uint256 _tokenID1, uint256 _tokenID2);


    /** FUNCTION **/

    /* General functions */

    function pause() public whenNotPaused authorized {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }
    
    function setCID(string memory _cid) public onlyOwner {
        cid = _cid;
    }

    function setIPFS(string memory _IPFS) public onlyOwner {
        IPFS = _IPFS;
    }

    function setBaseURI(string memory _URI) public onlyOwner {
        URI = _URI;
    }

    function _baseURI() internal view override returns (string memory) {
        return URI;
    }

    /* Randomizer functions */

    function setApocalypseRandomizer(ApocalypseRandomizer _randomizer) public onlyOwner {
        randomizer = _randomizer;
    }

    function ApocRandomizer() public view returns (ApocalypseRandomizer) {
        return randomizer;
    }

    /* Supply functions */

    function addSpecificMaxCharSupply(
        uint256 _charStatus,
        uint256 _charType,
        uint256 _charSkill,
        uint256 _maxCharSupply
    ) public authorized {
        require(_charStatus < 2);
        if (_charStatus == 0) {
            maxRareCharSupply[_charType] += _maxCharSupply;
            maxSpecificRareCharSupply[_charType][_charSkill] += _maxCharSupply;
            _addTotalMaxCharSupply(_charStatus, _maxCharSupply);
        } else {
            maxCommonCharSupply[_charType] += _maxCharSupply;
            maxSpecificCommonCharSupply[_charType][_charSkill] += _maxCharSupply;
            _addTotalMaxCharSupply(_charStatus, _maxCharSupply);
        }
    }

    function _addTotalMaxCharSupply(uint256 _charStatus, uint256 _maxCharSupply) internal {
        maxCharSupply[_charStatus] += _maxCharSupply;
        totalMaxSupply += _maxCharSupply;

        emit AddCharacterSupply(_maxCharSupply);
    }

    /* Default stats functions */

    function setUpgradePercentage(uint256 _upgradeNumerator, uint256 _upgradePower) public authorized {
        require(_upgradeNumerator > 0 && _upgradePower > 0);
        upgradePercentage = [_upgradeNumerator, _upgradePower];
    }

    function setRarePercentage(uint256 _rareNumerator, uint256 _rarePower) public authorized {
        require(_rareNumerator > 0 && _rarePower > 0);
        rarePercentage = [_rareNumerator, _rarePower];
    }

    function setDefaultInfo(uint256 _maxLevel, uint256 _baseHP, uint256 _upgradeBaseHP, uint256 _baseNextXP, uint256 _addDef) public authorized {
        require(_maxLevel > 0 && _baseHP > 0 && _upgradeBaseHP > 0 && _baseNextXP > 0 && _addDef > 0);
        maxLevel = _maxLevel;
        baseHP = _baseHP;
        upgradeBaseHP = _upgradeBaseHP;
        baseNextXP = _baseNextXP;
        addDef = _addDef;
    }

    function setMaxUpgradeStatus(uint256 _maxUpgradeStatus) public authorized {
        require(_maxUpgradeStatus > 0);
        maxUpgradeStatus = _maxUpgradeStatus;
    }

    function setCommonBaseStat(uint256 _baseAttack, uint256 _baseDefence) public authorized {
        require(_baseAttack > 0 && _baseDefence > 0);
        commonBaseStat = [_baseAttack, _baseDefence];
    }

    function setUpgradeBaseStat(uint256 _baseAttack, uint256 _baseDefence) public authorized {
        require(_baseAttack > 0 && _baseDefence > 0);
        upgradeBaseStat = [_baseAttack, _baseDefence];
    }

    function setRareBaseStat(uint256 _baseAttack, uint256 _baseDefence) public authorized {
        require(_baseAttack > 0 && _baseDefence > 0);
        rareBaseStat = [_baseAttack, _baseDefence];
    }

    function addCharStatus(uint256[] memory _statusID) public authorized {
        for(uint256 i = 0; i < _statusID.length; i++){
            charStatus.push(_statusID[i]);
        }
    }

    function addCharType(uint256[] memory _typeID) public authorized {
        for(uint256 i = 0; i < _typeID.length; i++){
            charType.push(_typeID[i]);
        }
    }

    function addCharSkill(uint256[] memory _skillID) public authorized {
        for(uint256 i = 0; i < _skillID.length; i++){
            charSkill.push(_skillID[i]);
        }
    }

    function getBaseHP() public view returns (uint256) {
        return baseHP;
    }
    
    function getUpgradeBaseHP() public view returns (uint256) {
        return upgradeBaseHP;
    }

    /* Character attributes functions */

    // Setter

    function updateCharacterEquip(uint256 _tokenID, bool _equip) external whenNotPaused authorized {
        require(apocChar[_tokenID].charEquip != _equip);
        apocChar[_tokenID].charEquip = _equip;
    }

    function levelUp(uint256 _tokenID) external whenNotPaused authorized {
        if (getCharLevel(_tokenID) < maxLevel) {
            apocChar[_tokenID].charLevel += 1;
        } else if (getCharLevel(_tokenID) == maxLevel) {
            apocChar[_tokenID].charLevel = 1;
            apocChar[_tokenID].charXP = 0;
            apocChar[_tokenID].charNextXP = baseNextXP;
            
            if (getAngelModifier(_tokenID) < maxAngelModifier) {
                apocChar[_tokenID].angelModifier += 1;
            }
        }
    }

    function reduceHP(uint256 _tokenID, uint256 _reduceHP) external whenNotPaused authorized {
        require (getCharHP(_tokenID) > 0);
        if (getCharHP(_tokenID) <= _reduceHP) {
            apocChar[_tokenID].charHP = 0;
        } else {
            apocChar[_tokenID].charHP -= _reduceHP;
        }
    }

    function recoverHP(uint256 _tokenID, uint256 _recoverHP) external whenNotPaused authorized {
        if (getCharStatus(_tokenID) <= 1) {
            require (getCharHP(_tokenID) < baseHP);
        } else if (apocChar[_tokenID].charStatus > 1) {
            require (getCharHP(_tokenID) < upgradeBaseHP);
        }

        if (getCharStatus(_tokenID) <= 1 && getCharHP(_tokenID) + _recoverHP >= baseHP) {
            apocChar[_tokenID].charHP = baseHP;
        } else if (getCharStatus(_tokenID) > 1 && getCharHP(_tokenID) + _recoverHP >= upgradeBaseHP) {
            apocChar[_tokenID].charHP = upgradeBaseHP;
        } else {
            apocChar[_tokenID].charHP += _recoverHP;
        }
    }

    function receiveXP(uint256 _tokenID, uint256 _receiveXP) external whenNotPaused authorized {
        require (getCharXP(_tokenID) < getCharNextXP(_tokenID));
        if (getCharXP(_tokenID) + _receiveXP >= getCharNextXP(_tokenID)) {
            apocChar[_tokenID].charXP = apocChar[_tokenID].charNextXP;
        } else {
            apocChar[_tokenID].charXP += _receiveXP;
        }
    }

    function updateNextXP(uint256 _tokenID) external whenNotPaused authorized {
        require(getCharXP(_tokenID) == getCharNextXP(_tokenID));
        uint256 nextLevel = getCharLevel(_tokenID) + 1;
        apocChar[_tokenID].charNextXP = baseNextXP * nextLevel;
    }

    function increaseAngelModifier(uint256 _tokenID, uint256 _angelModifier) external whenNotPaused authorized {
        require(getAngelModifier(_tokenID) < maxAngelModifier && _angelModifier <= maxAngelModifier );
        if (apocChar[_tokenID].angelModifier + _angelModifier > maxAngelModifier) {
            apocChar[_tokenID].angelModifier = maxAngelModifier;
        } else {
            apocChar[_tokenID].angelModifier += _angelModifier;
        }
    }

    function decreaseAngelModifier(uint256 _tokenID, uint256 _angelModifier) external whenNotPaused authorized {
        require(getAngelModifier(_tokenID) < maxAngelModifier && _angelModifier < maxAngelModifier);
        if (apocChar[_tokenID].angelModifier < _angelModifier) {
            apocChar[_tokenID].angelModifier = 0;
        } else {
            apocChar[_tokenID].angelModifier -= _angelModifier;
        }
    }

    // Getter

    function getCharIndex(uint256 _tokenID) public view returns(uint256[3] memory) {
        return apocChar[_tokenID].charIndex;
    }

    function getCharEquip(uint256 _tokenID) public view returns(bool) {
        return apocChar[_tokenID].charEquip;
    }

    function getCharStatus(uint256 _tokenID) public view returns(uint256) {
        return apocChar[_tokenID].charStatus;
    }

    function getCharType(uint256 _tokenID) public view returns(uint256) {
        return apocChar[_tokenID].charType;
    }

    function getCharSkill(uint256 _tokenID) public view returns(uint256) {
        return apocChar[_tokenID].charSkill;
    }

    function getCharLevel(uint256 _tokenID) public view returns(uint256) {
        return apocChar[_tokenID].charLevel;
    }

    function getCharHP(uint256 _tokenID) public view returns(uint256) {
        return apocChar[_tokenID].charHP;
    }

    function getCharXP(uint256 _tokenID) public view returns(uint256) {
        return apocChar[_tokenID].charXP;
    }

    function getCharNextXP(uint256 _tokenID) public view returns(uint256) {
        return apocChar[_tokenID].charNextXP;
    }

    function getBaseAttack(uint256 _tokenID) public view returns(uint256) {
        return apocChar[_tokenID].baseAttack;
    }

    function getBaseDefence(uint256 _tokenID) public view returns(uint256) {
        return apocChar[_tokenID].baseDefence;
    }

    function getAngelModifier(uint256 _tokenID) public view returns(uint256) {
        return apocChar[_tokenID].angelModifier;
    }

    function getCharImage(uint256 _tokenID) public view returns (string memory) {
        string memory _angelModifier = Strings.toString(getAngelModifier(_tokenID));
        string memory _charStatus = Strings.toString(getCharStatus(_tokenID));
        string memory _charType = Strings.toString(getCharType(_tokenID));
        string memory _charSkill = Strings.toString(getCharSkill(_tokenID));
        string memory imgURI;

        if (_tokenID == 0) {
            imgURI = string(abi.encodePacked(IPFS, "/", cid, "/character/0.png"));
        } else {
            imgURI = string(abi.encodePacked(IPFS, "/", cid, "/character/", _angelModifier, "/", _charStatus, "/", _charType, "/", _charSkill, ".png"));
        }

        return imgURI;
    }

    /* NFT general logic functions */

    function _mixer(address _owner, uint256 _offset) internal view returns (uint256[3] memory){
        uint256 userAddress = uint256(uint160(_owner));
        uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, block.number);

        uint256 _charType = randomizer.sliceNumber(random, charType.length, 1, charType.length);
        uint256 _charSkill = randomizer.sliceNumber(random, charSkill.length, 1, charSkill.length);
        uint256 _addDef = randomizer.sliceNumber(random, addDef, 1, _offset);

        return [_charType, _charSkill, _addDef];
    }

    function _createCharacter(
        uint256[3] memory _currentSupplyInfo,
        uint256 _charStatus,
        uint256 _charType,
        uint256 _charSkill,
        uint256 _charLevel,
        uint256 _baseHP,
        uint256 _baseXP,
        uint256 _baseAttack,
        uint256 _baseDefence        
    ) internal {
        Character memory _apocChar = Character({
            charIndex: _currentSupplyInfo,
            charEquip: false,
            charStatus: _charStatus,
            charType: _charType,
            charSkill: _charSkill,
            charLevel: _charLevel,
            charHP: _baseHP,
            charXP: 0,
            charNextXP: _baseXP,
            baseAttack: _baseAttack,
            baseDefence: _baseDefence,
            angelModifier: 0
        });
        
        apocChar.push(_apocChar);
    }

    function _safeMint(address to) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        emit MintNewCharacter(to, tokenId);
    }

    /* NFT upgrade logic functions */

    function _burnUpgrade(uint256 _tokenID) internal {
        _burn(_tokenID);

        if (getCharStatus(_tokenID) == 0) {
            rareCurrentSupply -= 1;
            currentRareCharSupply[getCharType(_tokenID)] -= 1;
            currentSpecificRareCharSupply[getCharType(_tokenID)][getCharSkill(_tokenID)] -= 1;
        } else if (getCharStatus(_tokenID) == 1) {
            commonCurrentSupply -= 1;
            currentCommonCharSupply[getCharType(_tokenID)] -= 1;
            currentSpecificCommonCharSupply[getCharType(_tokenID)][getCharSkill(_tokenID)] -= 1;
        } else {
            upgradeCurrentSupply -= 1;
            currentUpgradeCharSupply[getCharType(_tokenID)] -= 1;
            currentSpecificUpgradeCharSupply[getCharStatus(_tokenID)][getCharType(_tokenID)][getCharSkill(_tokenID)] -= 1;
        }

    }

    function upgradeCharacter(address _owner, uint256 _tokenID1, uint256 _tokenID2, uint256 _nextStatus) external whenNotPaused authorized returns (bool, uint256) {
        require(
            getCharStatus(_tokenID1) <= maxUpgradeStatus &&
            getCharStatus(_tokenID2) <= maxUpgradeStatus &&
            getCharType(_tokenID1) == getCharType(_tokenID2) &&
            getCharSkill(_tokenID1) == getCharSkill(_tokenID2)
        );

        uint256 _charType = getCharType(_tokenID1);
        uint256 _charSkill = getCharSkill(_tokenID2);

        uint256 userAddress = uint256(uint160(_msgSender()));
        uint256 targetBlock = block.number + (upgradePercentage[1]/upgradePercentage[0]);
        uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);
        uint256 upgradeCheck = randomizer.sliceNumber(random, 10, upgradePercentage[1], upgradePercentage[1]/upgradePercentage[0]);

        if (upgradeCheck <= upgradePercentage[0]) {

            uint256[3] memory _currentSupplyInfo = [upgradeCurrentSupply + 1, currentUpgradeCharSupply[_charType] + 1, currentSpecificUpgradeCharSupply[_nextStatus][_charType][_charSkill] + 1];

            _createCharacter(
                _currentSupplyInfo,
                _nextStatus,
                _charType,
                _charSkill,
                1,
                upgradeBaseHP,
                baseNextXP,
                upgradeBaseStat[0],
                upgradeBaseStat[1]
            );

            upgradeCurrentSupply += 1;
            currentUpgradeCharSupply[_charType] += 1;
            currentSpecificUpgradeCharSupply[_nextStatus][_charType][_charSkill] += 1;

            uint256 tokenID = _tokenIdCounter.current();
            _safeMint(_owner);

            _burnUpgrade(_tokenID1);
            _burnUpgrade(_tokenID2);

            emit SuccessfulCharacterUpgrade(_owner, _tokenID1, _tokenID2, tokenID);

            return (true, tokenID);
        }

        _burnUpgrade(_tokenID1);
        _burnUpgrade(_tokenID2);

        emit FailedCharacterUpgrade(_owner, _tokenID1, _tokenID2);

        return (false, 0);

    }

    /* NFT mint logic functions */

    function mintNewCharacter(address _owner) public whenNotPaused authorized returns (uint256){

        require(totalSupply() < totalMaxSupply);

        if (commonCurrentSupply == maxCharSupply[1] && rareCurrentSupply < maxCharSupply[0]) {
            return _mintRare(_owner);
        } else if (commonCurrentSupply < maxCharSupply[1] && rareCurrentSupply < maxCharSupply[0]) {
            uint256 userAddress = uint256(uint160(_owner));
            uint256 charMixer = charStatus.length + charType.length + charSkill.length;
            uint256 targetBlock = block.number + charMixer;
            uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);

            uint256 rareCheck = randomizer.sliceNumber(random, 10, rarePercentage[1], charMixer);

            if (rareCheck <= rarePercentage[0]) {
                return _mintRare(_owner);
            } else {
                return _mintCommon(_owner);
            }
        } else {
                return _mintCommon(_owner);
        }

    }

    function _mintRare(address _owner) internal returns (uint256) {
        require(rareCurrentSupply < maxCharSupply[0]);

        uint256[3] memory mixer = _mixer(_owner, rareCurrentSupply/addDef);
        
        uint256 typeIterations = 0;
        uint256 skillIterations = 0;

        while(currentRareCharSupply[mixer[0]] == maxRareCharSupply[mixer[0]]) {
            require(typeIterations < charType.length);
            mixer[0] += 1;
            if(mixer[0] > charType.length) {
                mixer[0] -= charType.length;
            }

            typeIterations += 1;
        }
        
        if (typeIterations == charType.length) {
            return (0);
        }

        while(currentSpecificRareCharSupply[mixer[0]][mixer[1]] == maxSpecificRareCharSupply[mixer[0]][mixer[1]]) {
            require(skillIterations < charSkill.length);
            mixer[1] += 1;
            if(mixer[1] > charSkill.length) {
                mixer[1] -= charSkill.length;
            }

            skillIterations += 1;
        }
        
        if(skillIterations == charSkill.length) {
            return (0);
        }

        uint256[3] memory _currentSupplyInfo = [rareCurrentSupply + 1, currentRareCharSupply[mixer[0]] + 1, currentSpecificRareCharSupply[mixer[0]][mixer[1]] + 1];

        _createCharacter(
            _currentSupplyInfo,
            0,
            mixer[0],
            mixer[1],
            1,
            baseHP,
            baseNextXP,
            rareBaseStat[0],
            rareBaseStat[1] + mixer[2]        
        );

        rareCurrentSupply += 1;
        currentRareCharSupply[mixer[0]] += 1;
        currentSpecificRareCharSupply[mixer[0]][mixer[1]] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return (tokenID);
    }

    function _mintCommon(address _owner) internal returns (uint256) {
        require(commonCurrentSupply < maxCharSupply[1]);

        uint256[3] memory mixer = _mixer(_owner, commonCurrentSupply/addDef);
        
        uint256 typeIterations = 0;
        uint256 skillIterations = 0;

        while(currentCommonCharSupply[mixer[0]] == maxCommonCharSupply[mixer[0]]) {
            require(typeIterations < charType.length);
            mixer[0] += 1;
            if(mixer[0] > charType.length) {
                mixer[0] -= charType.length;
            }

            typeIterations += 1;
        }
        
        if (typeIterations == charType.length) {
            return (0);
        }

        while(currentSpecificCommonCharSupply[mixer[0]][mixer[1]] == maxSpecificCommonCharSupply[mixer[0]][mixer[1]]) {
            require(skillIterations < charSkill.length);
            mixer[1] += 1;
            if(mixer[1] > charSkill.length) {
                mixer[1] -= charSkill.length;
            }

            skillIterations += 1;
        }
        
        if (skillIterations == charSkill.length) {
            return (0);
        }

        uint256[3] memory _currentSupplyInfo = [commonCurrentSupply + 1, currentCommonCharSupply[mixer[0]] + 1, currentSpecificCommonCharSupply[mixer[0]][mixer[1]] + 1];

        _createCharacter(
            _currentSupplyInfo,
            1,
            mixer[0],
            mixer[1],
            1,
            baseHP,
            baseNextXP,
            commonBaseStat[0],
            commonBaseStat[1] + mixer[2]        
        );

        commonCurrentSupply += 1;
        currentCommonCharSupply[mixer[0]] += 1;
        currentSpecificCommonCharSupply[mixer[0]][mixer[1]] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return (tokenID);

    }

    /* NFT drop logic functions */

    function dropSpecific(
        address _owner,
        uint256 _charStatus,
        uint256 _charType,
        uint256 _charSkill
    ) external whenNotPaused onlyOwner {

        uint256[3] memory mixer = _mixer(_owner, commonCurrentSupply/addDef);

        uint256 _charStatusIndex;
        uint256 _charTypeIndex;
        uint256 _charSkillIndex;
        uint256 _baseAttack;
        uint256 _baseDefence;

        if (_charStatus <= 1) {
            addSpecificMaxCharSupply(_charStatus, _charType, _charSkill, 1);
        } else {
            _addTotalMaxCharSupply(_charStatus, 1);
        }

        if (_charStatus == 0) {
            _charStatusIndex = rareCurrentSupply + 1;
            _charTypeIndex = currentRareCharSupply[_charType] + 1;
            _charSkillIndex = currentSpecificRareCharSupply[_charType][_charSkill] + 1;
            _baseAttack = rareBaseStat[0];
            _baseDefence = rareBaseStat[1];
        } else if (_charStatus == 1) {
            _charStatusIndex = commonCurrentSupply + 1;
            _charTypeIndex = currentCommonCharSupply[_charType] + 1;
            _charSkillIndex = currentSpecificCommonCharSupply[_charType][_charSkill] + 1;
            _baseAttack = commonBaseStat[0];
            _baseDefence = commonBaseStat[1];
        } else {
            _charStatusIndex = upgradeCurrentSupply + 1;
            _charTypeIndex = currentUpgradeCharSupply[_charType] + 1;
            _charSkillIndex = currentSpecificUpgradeCharSupply[_charStatus][_charType][_charSkill] + 1;
            _baseAttack = upgradeBaseStat[0];
            _baseDefence = upgradeBaseStat[1];
        }

        uint256[3] memory _currentSupplyInfo = [_charStatusIndex, _charTypeIndex, _charSkillIndex];

        _createCharacter(
            _currentSupplyInfo,
            _charStatus,
            _charType,
            _charSkill,
            1,
            baseHP,
            baseNextXP,
            _baseAttack,
            _baseDefence + mixer[2]        
        );

        if (_charStatus == 0) {
            rareCurrentSupply += 1;
            currentRareCharSupply[_charType] += 1;
            currentSpecificRareCharSupply[_charType][_charSkill] += 1;
        } else if (_charStatus == 1) {
            commonCurrentSupply += 1;
            currentCommonCharSupply[_charType] += 1;
            currentSpecificCommonCharSupply[_charType][_charSkill] += 1;
        } else {
            upgradeCurrentSupply += 1;
            currentUpgradeCharSupply[_charType] += 1;
            currentSpecificUpgradeCharSupply[_charStatus][_charType][_charSkill] += 1;
        }

        _safeMint(_owner);
    }

    function dropRandom(
        address[] memory _owner
    ) external whenNotPaused onlyOwner {
        for(uint256 i = 0; i < _owner.length; i++) {
            uint256 userAddress = uint256(uint160(_owner[i]));
            uint256 charMixer = charStatus.length + charType.length + charSkill.length;
            uint256 targetBlock = block.number + charMixer;
            uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);

            uint256 rareCheck = randomizer.sliceNumber(random, 10, rarePercentage[1], charMixer);

            if (rareCheck <= rarePercentage[0]) {
                _mintRareDrop(_owner[i]);
            } else {
                _mintCommonDrop(_owner[i]);
            }
        }

    }

    function _mintRareDrop(address _owner) internal returns (uint256) {
        require(rareCurrentSupply < maxCharSupply[0]);

        uint256[3] memory mixer = _mixer(_owner, rareCurrentSupply/addDef);

        addSpecificMaxCharSupply(0, mixer[0], mixer[1], 1);

        uint256[3] memory _currentSupplyInfo = [rareCurrentSupply + 1, currentRareCharSupply[mixer[0]] + 1, currentSpecificRareCharSupply[mixer[0]][mixer[1]] + 1];

        _createCharacter(
            _currentSupplyInfo,
            0,
            mixer[0],
            mixer[1],
            1,
            baseHP,
            baseNextXP,
            rareBaseStat[0],
            rareBaseStat[1] + mixer[2]        
        );

        rareCurrentSupply += 1;
        currentRareCharSupply[mixer[0]] += 1;
        currentSpecificRareCharSupply[mixer[0]][mixer[1]] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        emit AirdropCharacter(_owner, tokenID);

        return tokenID;

    }

    function _mintCommonDrop(address _owner) internal returns (uint256) {
        require(commonCurrentSupply < maxCharSupply[1]);

        uint256[3] memory mixer = _mixer(_owner, commonCurrentSupply/addDef);

        addSpecificMaxCharSupply(1, mixer[0], mixer[1], 1);

        uint256[3] memory _currentSupplyInfo = [commonCurrentSupply + 1, currentCommonCharSupply[mixer[0]] + 1, currentSpecificCommonCharSupply[mixer[0]][mixer[1]] + 1];

        _createCharacter(
            _currentSupplyInfo,
            1,
            mixer[0],
            mixer[1],
            1,
            baseHP,
            baseNextXP,
            commonBaseStat[0],
            commonBaseStat[1] + mixer[2]        
        );

        commonCurrentSupply += 1;
        currentCommonCharSupply[mixer[0]] += 1;
        currentSpecificCommonCharSupply[mixer[0]][mixer[1]] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);
        
        emit AirdropCharacter(_owner, tokenID);

        return tokenID;
    }

    /* NFT ERC logic functions */

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}

contract ApocalypseWeapon is ERC721, ERC721Enumerable, Pausable, Auth, ERC721Burnable {
    

    /** LIBRARY **/
    using Counters for Counters.Counter;
    using Strings for string;


    /** DATA **/
    string public URI;
    string private IPFS;
    string private cid;
    
    struct Weapon {
        uint256 tokenID;
        uint256[2] weaponIndex;
        bool weaponEquip;
        uint256 weaponStatus;
        uint256 weaponType;
        uint256 weaponLevel;
        uint256 weaponEndurance;
        uint256 baseAttack;
    }

    uint256 public maxLevel;
    uint256 public maxUpgradeStatus;

    uint256[] public weaponStatus;
    uint256[] public weaponType;
    uint256[] public weaponAttack;    
    uint256[] public weaponUpChance;
    uint256[] public weaponDepletion;

    uint256[] public commonWeaponEndurance;
    uint256[] public upgradeWeaponEndurance;
    uint256[] public rareWeaponEndurance;

    uint256[2] public upgradePercentage;
    uint256[2] public rarePercentage;
    uint256[2] public commonBaseStat;
    uint256[2] public upgradeBaseStat;
    uint256[2] public rareBaseStat;

    uint256 public commonCurrentSupply;
    uint256 public upgradeCurrentSupply;
    uint256 public rareCurrentSupply;
    uint256 public totalMaxSupply;

    Weapon[] public apocWeapon;

    ApocalypseRandomizer private randomizer;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => uint256) public maxCommonWeaponSupply;
    mapping(uint256 => uint256) public maxRareWeaponSupply;
    mapping(uint256 => uint256) public maxWeaponSupply;
    mapping(uint256 => uint256) currentCommonWeaponSupply;
    mapping(uint256 => uint256) currentRareWeaponSupply;
    mapping(uint256 => mapping(uint256 => uint256)) public currentSpecificUpgradeWeaponSupply;
    

    /** CONSTRUCTOR **/
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _URI,
        string memory _IPFS,
        string memory _cid,
        ApocalypseRandomizer _randomizer
    ) ERC721(_name, _symbol) {
        randomizer = _randomizer;
        URI = _URI;
        IPFS = _IPFS;
        cid = _cid;

        weaponStatus = [0,1];
        weaponType = [1,2,3,4,5];
        weaponAttack = [3,6,10,15,20,30,50,70,100,120];
        weaponUpChance = [40,38,35,32,28,23,20,15,10,5];
        weaponDepletion = [0,0,0,0,20,30,40,60,100,100];
        commonWeaponEndurance = [1000,1500,2000,2500,3000,3500,4000,4500,5000,10000];

        maxLevel = 10;

        commonBaseStat = [500, 1];
        rareBaseStat = [10000, 100];
        
        rarePercentage = [5, 4];

        addSpecificMaxWeaponSupply(0, 1, 2); // 2 rare fencing
        addSpecificMaxWeaponSupply(0, 2, 2); // 2 rare axe
        addSpecificMaxWeaponSupply(0, 3, 2); // 2 rare bow
        addSpecificMaxWeaponSupply(0, 4, 2); // 2 rare sword
        addSpecificMaxWeaponSupply(0, 5, 2); // 2 rare hammer

        addSpecificMaxWeaponSupply(1, 1, 100000); // 100,000 fencing
        addSpecificMaxWeaponSupply(1, 2, 100000); // 100,000 axe
        addSpecificMaxWeaponSupply(1, 3, 100000); // 100,000 bow
        addSpecificMaxWeaponSupply(1, 4, 100000); // 100,000 sword
        addSpecificMaxWeaponSupply(1, 5, 100000); // 100,000 hammer

        _createWeapon(
            [uint256(0),uint256(0)],
            0,
            0,
            0,
            commonBaseStat[0],
            commonBaseStat[1]
        );

        _safeMint(_msgSender());

    }

    
    /** EVENT **/

    event MintNewWeapon(address _tokenOwner, uint256 _tokenID);
    event AddWeaponSupply(uint256 _maxWeaponSupply);


    /** FUNCTION **/

    /* General functions */

    function pause() public whenNotPaused authorized {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }
    
    function setCID(string memory _cid) public onlyOwner {
        cid = _cid;
    }

    function setIPFS(string memory _IPFS) public onlyOwner {
        IPFS = _IPFS;
    }

    function setBaseURI(string memory _URI) public onlyOwner {
        URI = _URI;
    }

    function _baseURI() internal view override returns (string memory) {
        return URI;
    }

    /* Randomizer functions */

    function setApocalypseRandomizer(ApocalypseRandomizer _randomizer) public onlyOwner {
        randomizer = _randomizer;
    }

    function ApocRandomizer() public view returns (ApocalypseRandomizer) {
        return randomizer;
    }

    /* Supply functions */

    function addSpecificMaxWeaponSupply(
        uint256 _weaponStatus,
        uint256 _weaponType,
        uint256 _maxWeaponSupply
    ) public authorized {
        if (_weaponStatus == 0) {
            maxRareWeaponSupply[_weaponType] += _maxWeaponSupply;
            _addTotalMaxWeaponSupply(_weaponStatus, _maxWeaponSupply);
        } else if (_weaponStatus == 1) {
            maxCommonWeaponSupply[_weaponType] += _maxWeaponSupply;
            _addTotalMaxWeaponSupply(_weaponStatus, _maxWeaponSupply);
        } else {
            _addTotalMaxWeaponSupply(_weaponStatus, _maxWeaponSupply);
        }
    }

    function _addTotalMaxWeaponSupply(uint256 _weaponStatus, uint256 _maxWeaponSupply) internal {
        maxWeaponSupply[_weaponStatus] += _maxWeaponSupply;
        totalMaxSupply += _maxWeaponSupply;

        emit AddWeaponSupply(_maxWeaponSupply);
    }

    /* Default stats functions */

    function setUpgradePercentage(uint256 _upgradeNumerator, uint256 _upgradePower) public authorized {
        require(_upgradeNumerator > 0 && _upgradePower > 0);
        upgradePercentage = [_upgradeNumerator, _upgradePower];
    }

    function setRarePercentage(uint256 _rareNumerator, uint256 _rarePower) public authorized {
        require(_rareNumerator > 0 && _rarePower > 0);
        rarePercentage = [_rareNumerator, _rarePower];
    }

    function setDefaultInfo(uint256 _maxLevel, uint256 _maxUpgradeStatus) public authorized {
        require(_maxLevel > 0);
        maxLevel = _maxLevel;
        maxUpgradeStatus = _maxUpgradeStatus;
    }
    
    function addCommonWeaponEndurance(uint256[] memory _commonWeaponEndurance) public authorized {
        for(uint256 i = 0; i < _commonWeaponEndurance.length; i++){
            commonWeaponEndurance.push(_commonWeaponEndurance[i]);
        }
    }
    
    function addUpgradeWeaponEndurance(uint256[] memory _upgradeWeaponEndurance) public authorized {
        for(uint256 i = 0; i < _upgradeWeaponEndurance.length; i++){
            upgradeWeaponEndurance.push(_upgradeWeaponEndurance[i]);
        }
    }
    
    function addRareWeaponEndurance(uint256[] memory _rareWeaponEndurance) public authorized {
        for(uint256 i = 0; i < _rareWeaponEndurance.length; i++){
            rareWeaponEndurance.push(_rareWeaponEndurance[i]);
        }
    }
    
    function addWeaponAttack(uint256[] memory _weaponAttack) public authorized {
        for(uint256 i = 0; i < _weaponAttack.length; i++){
            weaponAttack.push(_weaponAttack[i]);
        }
    }
    
    function addWeaponUpChance(uint256[] memory _weaponUpChance) public authorized {
        for(uint256 i = 0; i < _weaponUpChance.length; i++){
            weaponUpChance.push(_weaponUpChance[i]);
        }
    }
    
    function addWeaponDepletion(uint256[] memory _weaponDepletion) public authorized {
        for(uint256 i = 0; i < _weaponDepletion.length; i++){
            weaponDepletion.push(_weaponDepletion[i]);
        }
    }
    
    function updateCommonWeaponEndurance(uint256 _weaponLevel, uint256 _commonWeaponEndurance) public authorized {
        require(_weaponLevel != 0 && _weaponLevel < commonWeaponEndurance.length && _commonWeaponEndurance > 0);
        commonWeaponEndurance[_weaponLevel - 1] = _commonWeaponEndurance;
    }

    function getCommonWeaponEndurance(uint256 _weaponLevel) public view returns (uint256) {
        require(_weaponLevel != 0 && _weaponLevel < commonWeaponEndurance.length);
        return commonWeaponEndurance[_weaponLevel - 1];
    }
    
    function updateUpgradeWeaponEndurance(uint256 _weaponLevel, uint256 _upgradeWeaponEndurance) public authorized {
        require(_weaponLevel != 0 && _weaponLevel < upgradeWeaponEndurance.length && _upgradeWeaponEndurance > 0);
        upgradeWeaponEndurance[_weaponLevel - 1] = _upgradeWeaponEndurance;
    }

    function getUpgradeWeaponEndurance(uint256 _weaponLevel) public view returns (uint256) {
        require(_weaponLevel != 0 && _weaponLevel < upgradeWeaponEndurance.length);
        return upgradeWeaponEndurance[_weaponLevel - 1];
    }
    
    function updateRareWeaponEndurance(uint256 _weaponLevel, uint256 _rareWeaponEndurance) public authorized {
        require(_weaponLevel != 0 && _weaponLevel < rareWeaponEndurance.length && _rareWeaponEndurance > 0);
        rareWeaponEndurance[_weaponLevel - 1] = _rareWeaponEndurance;
    }

    function getRareWeaponEndurance(uint256 _weaponLevel) public view returns (uint256) {
        require(_weaponLevel != 0 && _weaponLevel < rareWeaponEndurance.length);
        return rareWeaponEndurance[_weaponLevel - 1];
    }
    
    function updateWeaponAttack(uint256 _weaponLevel, uint256 _weaponAttack) public authorized {
        require(_weaponLevel != 0 && _weaponLevel < weaponAttack.length && _weaponAttack > 0);
        weaponAttack[_weaponLevel - 1] = _weaponAttack;
    }
    
    function updateWeaponUpChance(uint256 _weaponLevel, uint256 _weaponUpChance) public authorized {
        require(_weaponLevel < weaponUpChance.length && _weaponUpChance > 0);
        weaponUpChance[_weaponLevel] = _weaponUpChance;
    }
    
    function updateWeaponDepletion(uint256 _weaponLevel, uint256 _weaponDepletion) public authorized {
        require(_weaponLevel < weaponDepletion.length && _weaponDepletion >= 0);
        weaponDepletion[_weaponLevel] = _weaponDepletion;
    }

    function setCommonBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        commonBaseStat = [_baseEndurance, _baseAttack];
    }

    function getCommonBaseStat() public view returns (uint256[2] memory) {
        return commonBaseStat;
    }

    function setUpgradeBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        upgradeBaseStat = [_baseEndurance, _baseAttack];
    }

    function getUpgradeBaseStat() public view returns (uint256[2] memory) {
        return upgradeBaseStat;
    }

    function setRareBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        rareBaseStat = [_baseEndurance, _baseAttack];
    }

    function getRareBaseStat() public view returns (uint256[2] memory) {
        return rareBaseStat;
    }

    function addWeaponStatus(uint256[] memory _statusID) public authorized {
        for(uint256 i = 0; i < _statusID.length; i++){
            weaponStatus.push(_statusID[i]);
        }
    }

    function addWeaponType(uint256[] memory _typeID) public authorized {
        for(uint256 i = 0; i < _typeID.length; i++){
            weaponType.push(_typeID[i]);
        }
    }

    /* Weapon attributes functions */

    // Setter

    function updateWeaponEquip(uint256 _tokenID, bool _equip) external whenNotPaused authorized {
        require(apocWeapon[_tokenID].weaponEquip != _equip);
        apocWeapon[_tokenID].weaponEquip = _equip;
    }

    function levelUp(uint256 _tokenID) external whenNotPaused authorized {
        require(apocWeapon[_tokenID].weaponLevel < maxLevel);
        apocWeapon[_tokenID].weaponLevel += 1;
    }

    function reduceEndurance(uint256 _tokenID, uint256 _reduceEndurance) external whenNotPaused authorized {
        require (apocWeapon[_tokenID].weaponEndurance > 0);
        if (apocWeapon[_tokenID].weaponEndurance <= _reduceEndurance) {
            apocWeapon[_tokenID].weaponEndurance = 0;
        } else {
            apocWeapon[_tokenID].weaponEndurance -= _reduceEndurance;
        }
    }

    function recoverEndurance(uint256 _tokenID, uint256 _recoverEndurance) external whenNotPaused authorized {
        if (apocWeapon[_tokenID].weaponStatus == 0 && apocWeapon[_tokenID].weaponLevel == 0) {
            require (apocWeapon[_tokenID].weaponEndurance < rareBaseStat[0]);
        } else if (apocWeapon[_tokenID].weaponStatus == 0 && apocWeapon[_tokenID].weaponLevel > 0) {
            require (apocWeapon[_tokenID].weaponEndurance < rareWeaponEndurance[apocWeapon[_tokenID].weaponLevel - 1]);
        } else if (apocWeapon[_tokenID].weaponStatus == 1 && apocWeapon[_tokenID].weaponLevel == 0) {
            require (apocWeapon[_tokenID].weaponEndurance < commonBaseStat[0]);
        } else if (apocWeapon[_tokenID].weaponStatus == 1 && apocWeapon[_tokenID].weaponLevel > 0) {
            require (apocWeapon[_tokenID].weaponEndurance < commonWeaponEndurance[apocWeapon[_tokenID].weaponLevel - 1]);
        } else if (apocWeapon[_tokenID].weaponStatus > 1 && apocWeapon[_tokenID].weaponLevel == 0) {
            require (apocWeapon[_tokenID].weaponEndurance < upgradeBaseStat[0]);
        } else if (apocWeapon[_tokenID].weaponStatus > 1 && apocWeapon[_tokenID].weaponLevel > 0) {
            require (apocWeapon[_tokenID].weaponEndurance < upgradeWeaponEndurance[apocWeapon[_tokenID].weaponLevel - 1]);
        }

        if (apocWeapon[_tokenID].weaponStatus == 0 && apocWeapon[_tokenID].weaponLevel == 0 && apocWeapon[_tokenID].weaponEndurance + _recoverEndurance >= rareBaseStat[0]) {
            apocWeapon[_tokenID].weaponEndurance = rareBaseStat[0];
        } else if (apocWeapon[_tokenID].weaponStatus == 0 && apocWeapon[_tokenID].weaponLevel > 0 && apocWeapon[_tokenID].weaponEndurance + _recoverEndurance >= rareWeaponEndurance[apocWeapon[_tokenID].weaponLevel - 1]) {
            apocWeapon[_tokenID].weaponEndurance = rareWeaponEndurance[apocWeapon[_tokenID].weaponLevel - 1];
        } else if (apocWeapon[_tokenID].weaponStatus == 1 && apocWeapon[_tokenID].weaponLevel == 0 && apocWeapon[_tokenID].weaponEndurance + _recoverEndurance >= commonBaseStat[0]) {
            apocWeapon[_tokenID].weaponEndurance = commonBaseStat[0];
        } else if (apocWeapon[_tokenID].weaponStatus == 1 && apocWeapon[_tokenID].weaponLevel > 0 && apocWeapon[_tokenID].weaponEndurance + _recoverEndurance >= commonWeaponEndurance[apocWeapon[_tokenID].weaponLevel - 1]) {
            apocWeapon[_tokenID].weaponEndurance = commonWeaponEndurance[apocWeapon[_tokenID].weaponLevel - 1];
        } else if (apocWeapon[_tokenID].weaponStatus > 1 && apocWeapon[_tokenID].weaponLevel == 0 && apocWeapon[_tokenID].weaponEndurance + _recoverEndurance >= upgradeBaseStat[0]) {
            apocWeapon[_tokenID].weaponEndurance = upgradeBaseStat[0];
        } else if (apocWeapon[_tokenID].weaponStatus > 1 && apocWeapon[_tokenID].weaponLevel > 0 && apocWeapon[_tokenID].weaponEndurance + _recoverEndurance >= upgradeWeaponEndurance[apocWeapon[_tokenID].weaponLevel - 1]) {
            apocWeapon[_tokenID].weaponEndurance = upgradeWeaponEndurance[apocWeapon[_tokenID].weaponLevel - 1];
        } else {
            apocWeapon[_tokenID].weaponEndurance += _recoverEndurance;
        }
    }

    // Getter

    function getWeaponIndex(uint256 _tokenID) public view returns(uint256[2] memory) {
        return apocWeapon[_tokenID].weaponIndex;
    }

    function getWeaponEquip(uint256 _tokenID) public view returns(bool) {
        return apocWeapon[_tokenID].weaponEquip;
    }

    function getWeaponStatus(uint256 _tokenID) public view returns(uint256) {
        return apocWeapon[_tokenID].weaponStatus;
    }

    function getWeaponType(uint256 _tokenID) public view returns(uint256) {
        return apocWeapon[_tokenID].weaponType;
    }

    function getWeaponLevel(uint256 _tokenID) public view returns(uint256) {
        return apocWeapon[_tokenID].weaponLevel;
    }

    function getWeaponEndurance(uint256 _tokenID) public view returns(uint256) {
        return apocWeapon[_tokenID].weaponEndurance;
    }

    function getBaseAttack(uint256 _tokenID) public view returns(uint256) {
        return apocWeapon[_tokenID].baseAttack;
    }

    function getWeaponImage(uint256 _tokenID) public view returns (string memory) {
        string memory _weaponStatus = Strings.toString(apocWeapon[_tokenID].weaponStatus);
        string memory _weaponType = Strings.toString(apocWeapon[_tokenID].weaponType);
        string memory _weaponLevel = Strings.toString(apocWeapon[_tokenID].weaponLevel);
        string memory imgURI;

        if (_tokenID == 0) {
            imgURI = string(abi.encodePacked(IPFS, "/", cid, "/weapon/0.png"));
        } else {
            imgURI = string(abi.encodePacked(IPFS, "/", cid, "/weapon/", _weaponStatus, "/", _weaponType, "/", _weaponLevel, ".png"));
        }

        return imgURI;
    }

    /* NFT general logic functions */

    function _mixer(address _owner) internal view returns (uint256){
        uint256 userAddress = uint256(uint160(_owner));
        uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, block.number);

        uint256 _weaponType = randomizer.sliceNumber(random, weaponType.length, 1, weaponType.length);

        return _weaponType;
    }

    function _createWeapon(
        uint256[2] memory _currentSupplyInfo,
        uint256 _weaponStatus,
        uint256 _weaponType,
        uint256 _weaponLevel,
        uint256 _weaponEndurance,
        uint256 _baseAttack
    ) internal {
        Weapon memory _apocWeapon = Weapon({
            tokenID: _tokenIdCounter.current(),
            weaponIndex: _currentSupplyInfo,
            weaponEquip: false,
            weaponStatus: _weaponStatus,
            weaponType: _weaponType,
            weaponLevel: _weaponLevel,
            weaponEndurance: _weaponEndurance,
            baseAttack: _baseAttack
        });
        
        apocWeapon.push(_apocWeapon);
    }

    function _safeMint(address to) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        emit MintNewWeapon(to, tokenId);
    }

    /* NFT upgrade logic functions */

    function _burnUpgrade(uint256 _tokenID) internal {
        _burn(_tokenID);

        if (apocWeapon[_tokenID].weaponStatus == 0) {
            rareCurrentSupply -= 1;
            currentRareWeaponSupply[apocWeapon[_tokenID].weaponType] -= 1;
        } else if (apocWeapon[_tokenID].weaponStatus == 1) {
            commonCurrentSupply -= 1;
            currentCommonWeaponSupply[apocWeapon[_tokenID].weaponType] -= 1;
        } else {
            upgradeCurrentSupply -= 1;
            currentSpecificUpgradeWeaponSupply[apocWeapon[_tokenID].weaponStatus][apocWeapon[_tokenID].weaponType] -= 1;
        }

    }

    function upgradeWeapon(address _owner, uint256 _tokenID1, uint256 _tokenID2, uint256 _nextStatus) external whenNotPaused authorized returns (bool, uint256) {
        require(
            apocWeapon[_tokenID1].weaponStatus <= maxUpgradeStatus &&
            apocWeapon[_tokenID2].weaponStatus <= maxUpgradeStatus &&
            apocWeapon[_tokenID1].weaponType == apocWeapon[_tokenID2].weaponType
        );

        uint256 _weaponType = apocWeapon[_tokenID1].weaponType;

        uint256 userAddress = uint256(uint160(_msgSender()));
        uint256 targetBlock = block.number + (upgradePercentage[1]/upgradePercentage[0]);
        uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);
        uint256 upgradeCheck = randomizer.sliceNumber(random, 10, upgradePercentage[1], upgradePercentage[1]/upgradePercentage[0]);

        if (upgradeCheck <= upgradePercentage[0]) {

            uint256[2] memory _currentSupplyInfo = [upgradeCurrentSupply + 1, currentSpecificUpgradeWeaponSupply[_nextStatus][_weaponType] + 1];

            _createWeapon(
                _currentSupplyInfo,
                _nextStatus,
                _weaponType,
                0,
                upgradeBaseStat[0],
                upgradeBaseStat[1]
            );

            upgradeCurrentSupply += 1;
            currentSpecificUpgradeWeaponSupply[_nextStatus][_weaponType] += 1;

            uint256 tokenID = _tokenIdCounter.current();
            _safeMint(_owner);

            _burnUpgrade(_tokenID1);
            _burnUpgrade(_tokenID2);

            return (true, tokenID);
        }

        _burnUpgrade(_tokenID1);
        _burnUpgrade(_tokenID2);

        return (false, 0);

    }

    /* NFT mint logic functions */

    function mintNewWeapon(address _owner) external whenNotPaused authorized returns (uint256){

        require(totalSupply() < totalMaxSupply);

        if (commonCurrentSupply == maxWeaponSupply[1] && rareCurrentSupply < maxWeaponSupply[0]) {
            return _mintRare(_owner);
        } else if (commonCurrentSupply < maxWeaponSupply[1] && rareCurrentSupply < maxWeaponSupply[0]) {
            uint256 userAddress = uint256(uint160(_owner));
            uint256 weaponMixer = weaponStatus.length + weaponType.length;
            uint256 targetBlock = block.number + weaponMixer;
            uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);

            uint256 rareCheck = randomizer.sliceNumber(random, 10, rarePercentage[1], weaponMixer);

            if (rareCheck <= rarePercentage[0]) {
                return _mintRare(_owner);
            } else {
                return _mintCommon(_owner);
            }
        } else {
                return _mintCommon(_owner);
        }

    }

    function _mintRare(address _owner) internal returns (uint256) {
        require(rareCurrentSupply < maxWeaponSupply[0]);

        uint256 mixer = _mixer(_owner);
        
        uint256 typeIterations = 0;

        while(currentRareWeaponSupply[mixer] == maxRareWeaponSupply[mixer]) {
            require(typeIterations < weaponType.length);
            mixer += 1;
            if(mixer > weaponType.length) {
                mixer -= weaponType.length;
            }

            typeIterations += 1;
        }
        
        if (typeIterations >= weaponType.length) {
            return (0);
        }

        uint256[2] memory _currentSupplyInfo = [rareCurrentSupply + 1, currentRareWeaponSupply[mixer] + 1];

        _createWeapon(
            _currentSupplyInfo,
            0,
            mixer,
            0,
            rareBaseStat[0],
            rareBaseStat[1]
        );

        rareCurrentSupply += 1;
        currentRareWeaponSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return (tokenID);
    }

    function _mintCommon(address _owner) internal returns (uint256) {
        require(commonCurrentSupply < maxWeaponSupply[1]);

        uint256 mixer = _mixer(_owner);
        
        uint256 typeIterations = 0;

        while(currentCommonWeaponSupply[mixer] == maxCommonWeaponSupply[mixer]) {
            require(typeIterations < weaponType.length);
            mixer += 1;
            if(mixer > weaponType.length) {
                mixer -= weaponType.length;
            }

            typeIterations += 1;
        }
        
        if (typeIterations >= weaponType.length) {
            return (0);
        }

        uint256[2] memory _currentSupplyInfo = [commonCurrentSupply + 1, currentCommonWeaponSupply[mixer] + 1];

        _createWeapon(
            _currentSupplyInfo,
            1,
            mixer,
            0,
            commonBaseStat[0],
            commonBaseStat[1]
        );

        commonCurrentSupply += 1;
        currentCommonWeaponSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return (tokenID);

    }

    /* NFT drop logic functions */

    function dropSpecific(
        address _owner,
        uint256 _weaponStatus,
        uint256 _weaponType
    ) external whenNotPaused onlyOwner {
        
        uint256 _weaponStatusIndex;
        uint256 _weaponTypeIndex;
        uint256 _baseEndurance;
        uint256 _baseAttack;

        addSpecificMaxWeaponSupply(_weaponStatus, _weaponType, 1);

        if (_weaponStatus == 0) {
            _weaponStatusIndex = rareCurrentSupply + 1;
            _weaponTypeIndex = currentRareWeaponSupply[_weaponType] + 1;
            _baseEndurance = rareBaseStat[0];
            _baseAttack = rareBaseStat[1];
        } else if (_weaponStatus == 1) {
            _weaponStatusIndex = commonCurrentSupply + 1;
            _weaponTypeIndex = currentCommonWeaponSupply[_weaponType] + 1;
            _baseEndurance = commonBaseStat[0];
            _baseAttack = commonBaseStat[1];
        } else {
            _weaponStatusIndex = upgradeCurrentSupply + 1;
            _weaponTypeIndex = currentSpecificUpgradeWeaponSupply[_weaponStatus][_weaponType] + 1;
            _baseEndurance = upgradeBaseStat[0];
            _baseAttack = upgradeBaseStat[1];
        }

        uint256[2] memory _currentSupplyInfo = [_weaponStatusIndex, _weaponTypeIndex];

        _createWeapon(
            _currentSupplyInfo,
            _weaponStatus,
            _weaponType,
            0,
            _baseEndurance,
            _baseAttack
        );

        if (_weaponStatus == 0) {
            rareCurrentSupply += 1;
            currentRareWeaponSupply[_weaponType] += 1;
        } else if (_weaponStatus == 1) {
            commonCurrentSupply += 1;
            currentCommonWeaponSupply[_weaponType] += 1;
        } else {
            upgradeCurrentSupply += 1;
            currentSpecificUpgradeWeaponSupply[_weaponStatus][_weaponType] += 1;
        }

        _safeMint(_owner);
    }

    function dropRandom(
        address[] memory _owner
    ) external whenNotPaused onlyOwner {
        for(uint256 i = 0; i < _owner.length; i++) {
            uint256 userAddress = uint256(uint160(_owner[i]));
            uint256 weaponMixer = weaponStatus.length + weaponType.length;
            uint256 targetBlock = block.number + weaponMixer;
            uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);

            uint256 rareCheck = randomizer.sliceNumber(random, 10, rarePercentage[1], weaponMixer);

            if (rareCheck <= rarePercentage[0]) {
                _mintRareDrop(_owner[i]);
            } else {
                _mintCommonDrop(_owner[i]);
            }
        }

    }

    function mobDropRare(
        address _owner
    ) external whenNotPaused authorized returns (uint256) {
        return _mintRareDrop(_owner);
    }

    function _mintRareDrop(address _owner) internal returns (uint256) {
        require(rareCurrentSupply < maxWeaponSupply[0]);

        uint256 mixer = _mixer(_owner);

        addSpecificMaxWeaponSupply(0, mixer, 1);

        uint256[2] memory _currentSupplyInfo = [rareCurrentSupply + 1, currentRareWeaponSupply[mixer] + 1];

        _createWeapon(
            _currentSupplyInfo,
            0,
            mixer,
            0,
            rareBaseStat[0],
            rareBaseStat[1]
        );

        rareCurrentSupply += 1;
        currentRareWeaponSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return tokenID;
    }

    function _mintCommonDrop(address _owner) internal returns (uint256) {
        require(commonCurrentSupply < maxWeaponSupply[1]);

        uint256 mixer = _mixer(_owner);

        addSpecificMaxWeaponSupply(1, mixer, 1);

        uint256[2] memory _currentSupplyInfo = [commonCurrentSupply + 1, currentCommonWeaponSupply[mixer] + 1];

        _createWeapon(
            _currentSupplyInfo,
            1,
            mixer,
            0,
            commonBaseStat[0],
            commonBaseStat[1]
        );

        commonCurrentSupply += 1;
        currentCommonWeaponSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return tokenID;
    }

    /* NFT ERC logic functions */

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}

contract ApocalypseWand is ERC721, ERC721Enumerable, Pausable, Auth, ERC721Burnable {
    

    /** LIBRARY **/
    using Counters for Counters.Counter;
    using Strings for string;


    /** DATA **/
    string public URI;
    string private IPFS;
    string private cid;
    
    struct Wand {
        uint256 tokenID;
        uint256[2] wandIndex;
        bool wandEquip;
        uint256 wandStatus;
        uint256 wandType;
        uint256 wandLevel;
        uint256 wandEndurance;
        uint256 baseAttack;
    }

    uint256 public maxLevel;
    uint256 public maxUpgradeStatus;

    uint256[] public wandStatus;
    uint256[] public wandType;
    uint256[] public wandAttack;    
    uint256[] public wandUpChance;
    uint256[] public wandDepletion;

    uint256[] public commonWandEndurance;
    uint256[] public upgradeWandEndurance;
    uint256[] public rareWandEndurance;

    uint256[2] public upgradePercentage;
    uint256[2] public rarePercentage;
    uint256[2] public commonBaseStat;
    uint256[2] public upgradeBaseStat;
    uint256[2] public rareBaseStat;

    uint256 public commonCurrentSupply;
    uint256 public upgradeCurrentSupply;
    uint256 public rareCurrentSupply;
    uint256 public totalMaxSupply;

    Wand[] public apocWand;

    ApocalypseRandomizer private randomizer;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => uint256) public maxCommonWandSupply;
    mapping(uint256 => uint256) public maxRareWandSupply;
    mapping(uint256 => uint256) public maxWandSupply;
    mapping(uint256 => uint256) currentCommonWandSupply;
    mapping(uint256 => uint256) currentRareWandSupply;
    mapping(uint256 => mapping(uint256 => uint256)) public currentSpecificUpgradeWandSupply;
    

    /** CONSTRUCTOR **/
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _URI,
        string memory _IPFS,
        string memory _cid,
        ApocalypseRandomizer _randomizer
    ) ERC721(_name, _symbol) {
        randomizer = _randomizer;
        URI = _URI;
        IPFS = _IPFS;
        cid = _cid;

        wandStatus = [0,1];
        wandType = [1,2,3,4,5];
        wandAttack = [3,6,10,15,20,30,50,70,100,120];
        wandUpChance = [40,38,35,32,28,23,20,15,10,5];
        wandDepletion = [0,0,0,0,20,30,40,60,100,100];
        commonWandEndurance = [1000,1500,2000,2500,3000,3500,4000,4500,5000,10000];

        maxLevel = 10;

        commonBaseStat = [500, 1];
        rareBaseStat = [10000, 100];
        
        rarePercentage = [5, 4];

        addSpecificMaxWandSupply(0, 1, 2); // 2 rare energy
        addSpecificMaxWandSupply(0, 2, 2); // 2 rare lightning
        addSpecificMaxWandSupply(0, 3, 2); // 2 rare earth
        addSpecificMaxWandSupply(0, 4, 2); // 2 rare ice
        addSpecificMaxWandSupply(0, 5, 2); // 2 rare fire

        addSpecificMaxWandSupply(1, 1, 100000); // 100,000 energy
        addSpecificMaxWandSupply(1, 2, 100000); // 100,000 lightning
        addSpecificMaxWandSupply(1, 3, 100000); // 100,000 earth
        addSpecificMaxWandSupply(1, 4, 100000); // 100,000 ice
        addSpecificMaxWandSupply(1, 5, 100000); // 100,000 fire

        _createWand(
            [uint256(0),uint256(0)],
            0,
            0,
            0,
            commonBaseStat[0],
            commonBaseStat[1]
        );

        _safeMint(_msgSender());

    }

    
    /** EVENT **/

    event MintNewWand(address _tokenOwner, uint256 _tokenID);
    event AddWandSupply(uint256 _maxWandSupply);


    /** FUNCTION **/

    /* General functions */

    function pause() public whenNotPaused authorized {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }
    
    function setCID(string memory _cid) public onlyOwner {
        cid = _cid;
    }

    function setIPFS(string memory _IPFS) public onlyOwner {
        IPFS = _IPFS;
    }

    function setBaseURI(string memory _URI) public onlyOwner {
        URI = _URI;
    }

    function _baseURI() internal view override returns (string memory) {
        return URI;
    }

    /* Randomizer functions */

    function setApocalypseRandomizer(ApocalypseRandomizer _randomizer) public onlyOwner {
        randomizer = _randomizer;
    }

    function ApocRandomizer() public view returns (ApocalypseRandomizer) {
        return randomizer;
    }

    /* Supply functions */

    function addSpecificMaxWandSupply(
        uint256 _wandStatus,
        uint256 _wandType,
        uint256 _maxWandSupply
    ) public authorized {
        if (_wandStatus == 0) {
            maxRareWandSupply[_wandType] += _maxWandSupply;
            _addTotalMaxWandSupply(_wandStatus, _maxWandSupply);
        } else if (_wandStatus == 1) {
            maxCommonWandSupply[_wandType] += _maxWandSupply;
            _addTotalMaxWandSupply(_wandStatus, _maxWandSupply);
        } else {
            _addTotalMaxWandSupply(_wandStatus, _maxWandSupply);
        }
    }

    function _addTotalMaxWandSupply(uint256 _wandStatus, uint256 _maxWandSupply) internal {
        maxWandSupply[_wandStatus] += _maxWandSupply;
        totalMaxSupply += _maxWandSupply;

        emit AddWandSupply(_maxWandSupply);
    }

    /* Default stats functions */

    function setUpgradePercentage(uint256 _upgradeNumerator, uint256 _upgradePower) public authorized {
        require(_upgradeNumerator > 0 && _upgradePower > 0);
        upgradePercentage = [_upgradeNumerator, _upgradePower];
    }

    function setRarePercentage(uint256 _rareNumerator, uint256 _rarePower) public authorized {
        require(_rareNumerator > 0 && _rarePower > 0);
        rarePercentage = [_rareNumerator, _rarePower];
    }

    function setDefaultInfo(uint256 _maxLevel, uint256 _maxUpgradeStatus) public authorized {
        require(_maxLevel > 0);
        maxLevel = _maxLevel;
        maxUpgradeStatus = _maxUpgradeStatus;
    }
    
    function addCommonWandEndurance(uint256[] memory _commonWandEndurance) public authorized {
        for(uint256 i = 0; i < _commonWandEndurance.length; i++){
            commonWandEndurance.push(_commonWandEndurance[i]);
        }
    }
    
    function addUpgradeWandEndurance(uint256[] memory _upgradeWandEndurance) public authorized {
        for(uint256 i = 0; i < _upgradeWandEndurance.length; i++){
            upgradeWandEndurance.push(_upgradeWandEndurance[i]);
        }
    }
    
    function addRareWandEndurance(uint256[] memory _rareWandEndurance) public authorized {
        for(uint256 i = 0; i < _rareWandEndurance.length; i++){
            rareWandEndurance.push(_rareWandEndurance[i]);
        }
    }
    
    function addWandAttack(uint256[] memory _wandAttack) public authorized {
        for(uint256 i = 0; i < _wandAttack.length; i++){
            wandAttack.push(_wandAttack[i]);
        }
    }
    
    function addWandUpChance(uint256[] memory _wandUpChance) public authorized {
        for(uint256 i = 0; i < _wandUpChance.length; i++){
            wandUpChance.push(_wandUpChance[i]);
        }
    }
    
    function addWandDepletion(uint256[] memory _wandDepletion) public authorized {
        for(uint256 i = 0; i < _wandDepletion.length; i++){
            wandDepletion.push(_wandDepletion[i]);
        }
    }
    
    function updateCommonWandEndurance(uint256 _wandLevel, uint256 _commonWandEndurance) public authorized {
        require(_wandLevel != 0 && _wandLevel < commonWandEndurance.length && _commonWandEndurance > 0);
        commonWandEndurance[_wandLevel - 1] = _commonWandEndurance;
    }
    
    function getCommonWandEndurance(uint256 _wandLevel) public view returns (uint256) {
        require(_wandLevel != 0 && _wandLevel < commonWandEndurance.length);
        return commonWandEndurance[_wandLevel - 1];
    }
    
    function updateUpgradeWandEndurance(uint256 _wandLevel, uint256 _upgradeWandEndurance) public authorized {
        require(_wandLevel != 0 && _wandLevel < upgradeWandEndurance.length && _upgradeWandEndurance > 0);
        upgradeWandEndurance[_wandLevel - 1] = _upgradeWandEndurance;
    }
    
    function getUpgradeWandEndurance(uint256 _wandLevel) public view returns (uint256) {
        require(_wandLevel != 0 && _wandLevel < upgradeWandEndurance.length);
        return upgradeWandEndurance[_wandLevel - 1];
    }
    
    function updateRareWandEndurance(uint256 _wandLevel, uint256 _rareWandEndurance) public authorized {
        require(_wandLevel != 0 && _wandLevel < rareWandEndurance.length && _rareWandEndurance > 0);
        rareWandEndurance[_wandLevel - 1] = _rareWandEndurance;
    }
    
    function getRareWandEndurance(uint256 _wandLevel) public view returns (uint256) {
        require(_wandLevel != 0 && _wandLevel < rareWandEndurance.length);
        return rareWandEndurance[_wandLevel - 1];
    }
    
    function updateWandAttack(uint256 _wandLevel, uint256 _wandAttack) public authorized {
        require(_wandLevel != 0 && _wandLevel < wandAttack.length && _wandAttack > 0);
        wandAttack[_wandLevel - 1] = _wandAttack;
    }
    
    function updateWandUpChance(uint256 _wandLevel, uint256 _wandUpChance) public authorized {
        require(_wandLevel < wandUpChance.length && _wandUpChance > 0);
        wandUpChance[_wandLevel] = _wandUpChance;
    }
    
    function updateWandDepletion(uint256 _wandLevel, uint256 _wandDepletion) public authorized {
        require(_wandLevel < wandDepletion.length && _wandDepletion >= 0);
        wandDepletion[_wandLevel] = _wandDepletion;
    }

    function setCommonBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        commonBaseStat = [_baseEndurance, _baseAttack];
    }

    function getCommonBaseStat() public view returns (uint256[2] memory) {
        return commonBaseStat;
    }

    function setUpgradeBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        upgradeBaseStat = [_baseEndurance, _baseAttack];
    }

    function getUpgradeBaseStat() public view returns (uint256[2] memory) {
        return upgradeBaseStat;
    }

    function setRareBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        rareBaseStat = [_baseEndurance, _baseAttack];
    }

    function getRareBaseStat() public view returns (uint256[2] memory) {
        return rareBaseStat;
    }

    function addWandStatus(uint256[] memory _statusID) public authorized {
        for(uint256 i = 0; i < _statusID.length; i++){
            wandStatus.push(_statusID[i]);
        }
    }

    function addWandType(uint256[] memory _typeID) public authorized {
        for(uint256 i = 0; i < _typeID.length; i++){
            wandType.push(_typeID[i]);
        }
    }

    /* Wand attributes functions */

    // Setter

    function updateWandEquip(uint256 _tokenID, bool _equip) external whenNotPaused authorized {
        require(apocWand[_tokenID].wandEquip != _equip);
        apocWand[_tokenID].wandEquip = _equip;
    }

    function levelUp(uint256 _tokenID) external whenNotPaused authorized {
        require(apocWand[_tokenID].wandLevel < maxLevel);
        apocWand[_tokenID].wandLevel += 1;
    }

    function reduceEndurance(uint256 _tokenID, uint256 _reduceEndurance) external whenNotPaused authorized {
        require (apocWand[_tokenID].wandEndurance > 0);
        if (apocWand[_tokenID].wandEndurance <= _reduceEndurance) {
            apocWand[_tokenID].wandEndurance = 0;
        } else {
            apocWand[_tokenID].wandEndurance -= _reduceEndurance;
        }
    }

    function recoverEndurance(uint256 _tokenID, uint256 _recoverEndurance) external whenNotPaused authorized {
        if (apocWand[_tokenID].wandStatus == 0 && apocWand[_tokenID].wandLevel == 0) {
            require (apocWand[_tokenID].wandEndurance < rareBaseStat[0]);
        } else if (apocWand[_tokenID].wandStatus == 0 && apocWand[_tokenID].wandLevel > 0) {
            require (apocWand[_tokenID].wandEndurance < rareWandEndurance[apocWand[_tokenID].wandLevel - 1]);
        } else if (apocWand[_tokenID].wandStatus == 1 && apocWand[_tokenID].wandLevel == 0) {
            require (apocWand[_tokenID].wandEndurance < commonBaseStat[0]);
        } else if (apocWand[_tokenID].wandStatus == 1 && apocWand[_tokenID].wandLevel > 0) {
            require (apocWand[_tokenID].wandEndurance < commonWandEndurance[apocWand[_tokenID].wandLevel - 1]);
        } else if (apocWand[_tokenID].wandStatus > 1 && apocWand[_tokenID].wandLevel == 0) {
            require (apocWand[_tokenID].wandEndurance < upgradeBaseStat[0]);
        } else if (apocWand[_tokenID].wandStatus > 1 && apocWand[_tokenID].wandLevel > 0) {
            require (apocWand[_tokenID].wandEndurance < upgradeWandEndurance[apocWand[_tokenID].wandLevel - 1]);
        }

        if (apocWand[_tokenID].wandStatus == 0 && apocWand[_tokenID].wandLevel == 0 && apocWand[_tokenID].wandEndurance + _recoverEndurance >= rareBaseStat[0]) {
            apocWand[_tokenID].wandEndurance = rareBaseStat[0];
        } else if (apocWand[_tokenID].wandStatus == 0 && apocWand[_tokenID].wandLevel > 0 && apocWand[_tokenID].wandEndurance + _recoverEndurance >= rareWandEndurance[apocWand[_tokenID].wandLevel - 1]) {
            apocWand[_tokenID].wandEndurance = rareWandEndurance[apocWand[_tokenID].wandLevel - 1];
        } else if (apocWand[_tokenID].wandStatus == 1 && apocWand[_tokenID].wandLevel == 0 && apocWand[_tokenID].wandEndurance + _recoverEndurance >= commonBaseStat[0]) {
            apocWand[_tokenID].wandEndurance = commonBaseStat[0];
        } else if (apocWand[_tokenID].wandStatus == 1 && apocWand[_tokenID].wandLevel > 0 && apocWand[_tokenID].wandEndurance + _recoverEndurance >= commonWandEndurance[apocWand[_tokenID].wandLevel - 1]) {
            apocWand[_tokenID].wandEndurance = commonWandEndurance[apocWand[_tokenID].wandLevel - 1];
        } else if (apocWand[_tokenID].wandStatus > 1 && apocWand[_tokenID].wandLevel == 0 && apocWand[_tokenID].wandEndurance + _recoverEndurance >= upgradeBaseStat[0]) {
            apocWand[_tokenID].wandEndurance = upgradeBaseStat[0];
        } else if (apocWand[_tokenID].wandStatus > 1 && apocWand[_tokenID].wandLevel > 0 && apocWand[_tokenID].wandEndurance + _recoverEndurance >= upgradeWandEndurance[apocWand[_tokenID].wandLevel - 1]) {
            apocWand[_tokenID].wandEndurance = upgradeWandEndurance[apocWand[_tokenID].wandLevel - 1];
        } else {
            apocWand[_tokenID].wandEndurance += _recoverEndurance;
        }
    }

    // Getter

    function getWandIndex(uint256 _tokenID) public view returns(uint256[2] memory) {
        return apocWand[_tokenID].wandIndex;
    }

    function getWandEquip(uint256 _tokenID) public view returns(bool) {
        return apocWand[_tokenID].wandEquip;
    }

    function getWandStatus(uint256 _tokenID) public view returns(uint256) {
        return apocWand[_tokenID].wandStatus;
    }

    function getWandType(uint256 _tokenID) public view returns(uint256) {
        return apocWand[_tokenID].wandType;
    }

    function getWandLevel(uint256 _tokenID) public view returns(uint256) {
        return apocWand[_tokenID].wandLevel;
    }

    function getWandEndurance(uint256 _tokenID) public view returns(uint256) {
        return apocWand[_tokenID].wandEndurance;
    }

    function getBaseAttack(uint256 _tokenID) public view returns(uint256) {
        return apocWand[_tokenID].baseAttack;
    }

    function getWandImage(uint256 _tokenID) public view returns (string memory) {
        string memory _wandStatus = Strings.toString(apocWand[_tokenID].wandStatus);
        string memory _wandType = Strings.toString(apocWand[_tokenID].wandType);
        string memory _wandLevel = Strings.toString(apocWand[_tokenID].wandLevel);
        string memory imgURI;

        if (_tokenID == 0) {
            imgURI = string(abi.encodePacked(IPFS, "/", cid, "/wand/0.png"));
        } else {
            imgURI = string(abi.encodePacked(IPFS, "/", cid, "/wand/", _wandStatus, "/", _wandType, "/", _wandLevel, ".png"));
        }

        return imgURI;
    }

    /* NFT general logic functions */

    function _mixer(address _owner) internal view returns (uint256){
        uint256 userAddress = uint256(uint160(_owner));
        uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, block.number);

        uint256 _wandType = randomizer.sliceNumber(random, wandType.length, 1, wandType.length);

        return _wandType;
    }

    function _createWand(
        uint256[2] memory _currentSupplyInfo,
        uint256 _wandStatus,
        uint256 _wandType,
        uint256 _wandLevel,
        uint256 _wandEndurance,
        uint256 _baseAttack
    ) internal {
        Wand memory _apocWand = Wand({
            tokenID: _tokenIdCounter.current(),
            wandIndex: _currentSupplyInfo,
            wandEquip: false,
            wandStatus: _wandStatus,
            wandType: _wandType,
            wandLevel: _wandLevel,
            wandEndurance: _wandEndurance,
            baseAttack: _baseAttack
        });
        
        apocWand.push(_apocWand);
    }

    function _safeMint(address to) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        emit MintNewWand(to, tokenId);
    }

    /* NFT upgrade logic functions */

    function _burnUpgrade(uint256 _tokenID) internal {
        _burn(_tokenID);

        if (apocWand[_tokenID].wandStatus == 0) {
            rareCurrentSupply -= 1;
            currentRareWandSupply[apocWand[_tokenID].wandType] -= 1;
        } else if (apocWand[_tokenID].wandStatus == 1) {
            commonCurrentSupply -= 1;
            currentCommonWandSupply[apocWand[_tokenID].wandType] -= 1;
        } else {
            upgradeCurrentSupply -= 1;
            currentSpecificUpgradeWandSupply[apocWand[_tokenID].wandStatus][apocWand[_tokenID].wandType] -= 1;
        }

    }

    function upgradeWand(address _owner, uint256 _tokenID1, uint256 _tokenID2, uint256 _nextStatus) external whenNotPaused authorized returns (bool, uint256) {
        require(
            apocWand[_tokenID1].wandStatus <= maxUpgradeStatus &&
            apocWand[_tokenID2].wandStatus <= maxUpgradeStatus &&
            apocWand[_tokenID1].wandType == apocWand[_tokenID2].wandType
        );

        uint256 _wandType = apocWand[_tokenID1].wandType;

        uint256 userAddress = uint256(uint160(_msgSender()));
        uint256 targetBlock = block.number + (upgradePercentage[1]/upgradePercentage[0]);
        uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);
        uint256 upgradeCheck = randomizer.sliceNumber(random, 10, upgradePercentage[1], upgradePercentage[1]/upgradePercentage[0]);

        if (upgradeCheck <= upgradePercentage[0]) {

            uint256[2] memory _currentSupplyInfo = [upgradeCurrentSupply + 1, currentSpecificUpgradeWandSupply[_nextStatus][_wandType] + 1];

            _createWand(
                _currentSupplyInfo,
                _nextStatus,
                _wandType,
                0,
                upgradeBaseStat[0],
                upgradeBaseStat[1]
            );

            upgradeCurrentSupply += 1;
            currentSpecificUpgradeWandSupply[_nextStatus][_wandType] += 1;

            uint256 tokenID = _tokenIdCounter.current();
            _safeMint(_owner);

            _burnUpgrade(_tokenID1);
            _burnUpgrade(_tokenID2);

            return (true, tokenID);
        }

        _burnUpgrade(_tokenID1);
        _burnUpgrade(_tokenID2);

        return (false, 0);

    }

    /* NFT mint logic functions */

    function mintNewWand(address _owner) external whenNotPaused authorized returns (uint256){

        require(totalSupply() < totalMaxSupply);

        if (commonCurrentSupply == maxWandSupply[1] && rareCurrentSupply < maxWandSupply[0]) {
            return _mintRare(_owner);
        } else if (commonCurrentSupply < maxWandSupply[1] && rareCurrentSupply < maxWandSupply[0]) {
            uint256 userAddress = uint256(uint160(_owner));
            uint256 wandMixer = wandStatus.length + wandType.length;
            uint256 targetBlock = block.number + wandMixer;
            uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);

            uint256 rareCheck = randomizer.sliceNumber(random, 10, rarePercentage[1], wandMixer);

            if (rareCheck <= rarePercentage[0]) {
                return _mintRare(_owner);
            } else {
                return _mintCommon(_owner);
            }
        } else {
                return _mintCommon(_owner);
        }

    }

    function _mintRare(address _owner) internal returns (uint256) {
        require(rareCurrentSupply < maxWandSupply[0]);

        uint256 mixer = _mixer(_owner);
        
        uint256 typeIterations = 0;

        while(currentRareWandSupply[mixer] == maxRareWandSupply[mixer]) {
            require(typeIterations < wandType.length);
            mixer += 1;
            if(mixer > wandType.length) {
                mixer -= wandType.length;
            }

            typeIterations += 1;
        }
        
        if (typeIterations >= wandType.length) {
            return (0);
        }

        uint256[2] memory _currentSupplyInfo = [rareCurrentSupply + 1, currentRareWandSupply[mixer] + 1];

        _createWand(
            _currentSupplyInfo,
            0,
            mixer,
            0,
            rareBaseStat[0],
            rareBaseStat[1]
        );

        rareCurrentSupply += 1;
        currentRareWandSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return (tokenID);
    }

    function _mintCommon(address _owner) internal returns (uint256) {
        require(commonCurrentSupply < maxWandSupply[1]);

        uint256 mixer = _mixer(_owner);
        
        uint256 typeIterations = 0;

        while(currentCommonWandSupply[mixer] == maxCommonWandSupply[mixer]) {
            require(typeIterations < wandType.length);
            mixer += 1;
            if(mixer > wandType.length) {
                mixer -= wandType.length;
            }

            typeIterations += 1;
        }
        
        if (typeIterations >= wandType.length) {
            return (0);
        }

        uint256[2] memory _currentSupplyInfo = [commonCurrentSupply + 1, currentCommonWandSupply[mixer] + 1];

        _createWand(
            _currentSupplyInfo,
            1,
            mixer,
            0,
            commonBaseStat[0],
            commonBaseStat[1]
        );

        commonCurrentSupply += 1;
        currentCommonWandSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return (tokenID);

    }

    /* NFT drop logic functions */

    function dropSpecific(
        address _owner,
        uint256 _wandStatus,
        uint256 _wandType
    ) external whenNotPaused onlyOwner {
        
        uint256 _wandStatusIndex;
        uint256 _wandTypeIndex;
        uint256 _baseEndurance;
        uint256 _baseAttack;

        addSpecificMaxWandSupply(_wandStatus, _wandType, 1);

        if (_wandStatus == 0) {
            _wandStatusIndex = rareCurrentSupply + 1;
            _wandTypeIndex = currentRareWandSupply[_wandType] + 1;
            _baseEndurance = rareBaseStat[0];
            _baseAttack = rareBaseStat[1];
        } else if (_wandStatus == 1) {
            _wandStatusIndex = commonCurrentSupply + 1;
            _wandTypeIndex = currentCommonWandSupply[_wandType] + 1;
            _baseEndurance = commonBaseStat[0];
            _baseAttack = commonBaseStat[1];
        } else {
            _wandStatusIndex = upgradeCurrentSupply + 1;
            _wandTypeIndex = currentSpecificUpgradeWandSupply[_wandStatus][_wandType] + 1;
            _baseEndurance = upgradeBaseStat[0];
            _baseAttack = upgradeBaseStat[1];
        }

        uint256[2] memory _currentSupplyInfo = [_wandStatusIndex, _wandTypeIndex];

        _createWand(
            _currentSupplyInfo,
            _wandStatus,
            _wandType,
            0,
            _baseEndurance,
            _baseAttack
        );

        if (_wandStatus == 0) {
            rareCurrentSupply += 1;
            currentRareWandSupply[_wandType] += 1;
        } else if (_wandStatus == 1) {
            commonCurrentSupply += 1;
            currentCommonWandSupply[_wandType] += 1;
        } else {
            upgradeCurrentSupply += 1;
            currentSpecificUpgradeWandSupply[_wandStatus][_wandType] += 1;
        }

        _safeMint(_owner);
    }

    function dropRandom(
        address[] memory _owner
    ) external whenNotPaused onlyOwner {
        for(uint256 i = 0; i < _owner.length; i++) {
            uint256 userAddress = uint256(uint160(_owner[i]));
            uint256 wandMixer = wandStatus.length + wandType.length;
            uint256 targetBlock = block.number + wandMixer;
            uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);

            uint256 rareCheck = randomizer.sliceNumber(random, 10, rarePercentage[1], wandMixer);

            if (rareCheck <= rarePercentage[0]) {
                _mintRareDrop(_owner[i]);
            } else {
                _mintCommonDrop(_owner[i]);
            }
        }

    }

    function mobDropRare(
        address _owner
    ) external whenNotPaused authorized returns (uint256) {
        return _mintRareDrop(_owner);
    }

    function _mintRareDrop(address _owner) internal returns (uint256) {
        require(rareCurrentSupply < maxWandSupply[0]);

        uint256 mixer = _mixer(_owner);

        addSpecificMaxWandSupply(0, mixer, 1);

        uint256[2] memory _currentSupplyInfo = [rareCurrentSupply + 1, currentRareWandSupply[mixer] + 1];

        _createWand(
            _currentSupplyInfo,
            0,
            mixer,
            0,
            rareBaseStat[0],
            rareBaseStat[1]
        );

        rareCurrentSupply += 1;
        currentRareWandSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return tokenID;
    }

    function _mintCommonDrop(address _owner) internal returns (uint256) {
        require(commonCurrentSupply < maxWandSupply[1]);

        uint256 mixer = _mixer(_owner);

        addSpecificMaxWandSupply(1, mixer, 1);

        uint256[2] memory _currentSupplyInfo = [commonCurrentSupply + 1, currentCommonWandSupply[mixer] + 1];

        _createWand(
            _currentSupplyInfo,
            1,
            mixer,
            0,
            commonBaseStat[0],
            commonBaseStat[1]
        );

        commonCurrentSupply += 1;
        currentCommonWandSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return tokenID;
    }

    /* NFT ERC logic functions */

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}

contract ApocalypseShield is ERC721, ERC721Enumerable, Pausable, Auth, ERC721Burnable {
    

    /** LIBRARY **/
    using Counters for Counters.Counter;
    using Strings for string;


    /** DATA **/
    string public URI;
    string private IPFS;
    string private cid;
    
    struct Shield {
        uint256 tokenID;
        uint256[2] shieldIndex;
        bool shieldEquip;
        uint256 shieldStatus;
        uint256 shieldType;
        uint256 shieldLevel;
        uint256 shieldEndurance;
        uint256 baseDefence;
    }

    uint256 public maxLevel;
    uint256 public maxUpgradeStatus;

    uint256[] public shieldStatus;
    uint256[] public shieldType;
    uint256[] public shieldDefence;    
    uint256[] public shieldUpChance;
    uint256[] public shieldDepletion;

    uint256[] public commonShieldEndurance;
    uint256[] public upgradeShieldEndurance;
    uint256[] public rareShieldEndurance;

    uint256[2] public upgradePercentage;
    uint256[2] public rarePercentage;
    uint256[2] public commonBaseStat;
    uint256[2] public upgradeBaseStat;
    uint256[2] public rareBaseStat;

    uint256 public commonCurrentSupply;
    uint256 public upgradeCurrentSupply;
    uint256 public rareCurrentSupply;
    uint256 public totalMaxSupply;

    Shield[] public apocShield;

    ApocalypseRandomizer private randomizer;
    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => uint256) public maxCommonShieldSupply;
    mapping(uint256 => uint256) public maxRareShieldSupply;
    mapping(uint256 => uint256) public maxShieldSupply;
    mapping(uint256 => uint256) currentCommonShieldSupply;
    mapping(uint256 => uint256) currentRareShieldSupply;
    mapping(uint256 => mapping(uint256 => uint256)) public currentSpecificUpgradeShieldSupply;
    

    /** CONSTRUCTOR **/
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _URI,
        string memory _IPFS,
        string memory _cid,
        ApocalypseRandomizer _randomizer
    ) ERC721(_name, _symbol) {
        randomizer = _randomizer;
        URI = _URI;
        IPFS = _IPFS;
        cid = _cid;

        shieldStatus = [0,1];
        shieldType = [1,2];
        shieldDefence = [2,4,8,10,15,20,30,40,50,100];
        shieldUpChance = [40,38,35,32,28,23,20,15,10,5];
        shieldDepletion = [10,10,20,30,40,50,60,80,100,100];
        commonShieldEndurance = [1000,1500,2000,2500,3000,3500,4000,4500,5000,10000];

        maxLevel = 10;

        commonBaseStat = [500, 1];
        rareBaseStat = [10000, 100];
        
        rarePercentage = [5, 4];

        addSpecificMaxShieldSupply(0, 1, 5); // 5 rare medusa
        addSpecificMaxShieldSupply(0, 2, 5); // 5 rare devlin

        addSpecificMaxShieldSupply(1, 1, 100000); // 100,000 universal tower

        _createShield(
            [uint256(0),uint256(0)],
            0,
            0,
            0,
            commonBaseStat[0],
            commonBaseStat[1]
        );

        _safeMint(_msgSender());

    }

    
    /** EVENT **/

    event MintNewShield(address _tokenOwner, uint256 _tokenID);
    event AddShieldSupply(uint256 _maxShieldSupply);


    /** FUNCTION **/

    /* General functions */

    function pause() public whenNotPaused authorized {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }
    
    function setCID(string memory _cid) public onlyOwner {
        cid = _cid;
    }

    function setIPFS(string memory _IPFS) public onlyOwner {
        IPFS = _IPFS;
    }

    function setBaseURI(string memory _URI) public onlyOwner {
        URI = _URI;
    }

    function _baseURI() internal view override returns (string memory) {
        return URI;
    }

    /* Randomizer functions */

    function setApocalypseRandomizer(ApocalypseRandomizer _randomizer) public onlyOwner {
        randomizer = _randomizer;
    }

    function ApocRandomizer() public view returns (ApocalypseRandomizer) {
        return randomizer;
    }

    /* Supply functions */

    function addSpecificMaxShieldSupply(
        uint256 _shieldStatus,
        uint256 _shieldType,
        uint256 _maxShieldSupply
    ) public authorized {
        if (_shieldStatus == 0) {
            maxRareShieldSupply[_shieldType] += _maxShieldSupply;
            _addTotalMaxShieldSupply(_shieldStatus, _maxShieldSupply);
        } else if (_shieldStatus == 1) {
            maxCommonShieldSupply[_shieldType] += _maxShieldSupply;
            _addTotalMaxShieldSupply(_shieldStatus, _maxShieldSupply);
        } else {
            _addTotalMaxShieldSupply(_shieldStatus, _maxShieldSupply);
        }
    }

    function _addTotalMaxShieldSupply(uint256 _shieldStatus, uint256 _maxShieldSupply) internal {
        maxShieldSupply[_shieldStatus] += _maxShieldSupply;
        totalMaxSupply += _maxShieldSupply;

        emit AddShieldSupply(_maxShieldSupply);
    }

    /* Default stats functions */

    function setUpgradePercentage(uint256 _upgradeNumerator, uint256 _upgradePower) public authorized {
        require(_upgradeNumerator > 0 && _upgradePower > 0);
        upgradePercentage = [_upgradeNumerator, _upgradePower];
    }

    function setRarePercentage(uint256 _rareNumerator, uint256 _rarePower) public authorized {
        require(_rareNumerator > 0 && _rarePower > 0);
        rarePercentage = [_rareNumerator, _rarePower];
    }

    function setDefaultInfo(uint256 _maxLevel, uint256 _maxUpgradeStatus) public authorized {
        require(_maxLevel > 0);
        maxLevel = _maxLevel;
        maxUpgradeStatus = _maxUpgradeStatus;
    }
    
    function addCommonShieldEndurance(uint256[] memory _commonShieldEndurance) public authorized {
        for(uint256 i = 0; i < _commonShieldEndurance.length; i++){
            commonShieldEndurance.push(_commonShieldEndurance[i]);
        }
    }
    
    function addUpgradeShieldEndurance(uint256[] memory _upgradeShieldEndurance) public authorized {
        for(uint256 i = 0; i < _upgradeShieldEndurance.length; i++){
            upgradeShieldEndurance.push(_upgradeShieldEndurance[i]);
        }
    }
    
    function addRareShieldEndurance(uint256[] memory _rareShieldEndurance) public authorized {
        for(uint256 i = 0; i < _rareShieldEndurance.length; i++){
            rareShieldEndurance.push(_rareShieldEndurance[i]);
        }
    }
    
    function addShieldDefence(uint256[] memory _shieldDefence) public authorized {
        for(uint256 i = 0; i < _shieldDefence.length; i++){
            shieldDefence.push(_shieldDefence[i]);
        }
    }
    
    function addShieldUpChance(uint256[] memory _shieldUpChance) public authorized {
        for(uint256 i = 0; i < _shieldUpChance.length; i++){
            shieldUpChance.push(_shieldUpChance[i]);
        }
    }
    
    function addShieldDepletion(uint256[] memory _shieldDepletion) public authorized {
        for(uint256 i = 0; i < _shieldDepletion.length; i++){
            shieldDepletion.push(_shieldDepletion[i]);
        }
    }
    
    function updateCommonShieldEndurance(uint256 _shieldLevel, uint256 _commonShieldEndurance) public authorized {
        require(_shieldLevel != 0 && _shieldLevel < commonShieldEndurance.length && _commonShieldEndurance > 0);
        commonShieldEndurance[_shieldLevel - 1] = _commonShieldEndurance;
    }
    
    function getCommonShieldEndurance(uint256 _shieldLevel) public view returns (uint256) {
        require(_shieldLevel != 0 && _shieldLevel < commonShieldEndurance.length);
        return commonShieldEndurance[_shieldLevel - 1];
    }
    
    function updateUpgradeShieldEndurance(uint256 _shieldLevel, uint256 _upgradeShieldEndurance) public authorized {
        require(_shieldLevel != 0 && _shieldLevel < upgradeShieldEndurance.length && _upgradeShieldEndurance > 0);
        upgradeShieldEndurance[_shieldLevel - 1] = _upgradeShieldEndurance;
    }
    
    function getUpgradeShieldEndurance(uint256 _shieldLevel) public view returns (uint256) {
        require(_shieldLevel != 0 && _shieldLevel < upgradeShieldEndurance.length);
        return upgradeShieldEndurance[_shieldLevel - 1];
    }
    
    function updateRareShieldEndurance(uint256 _shieldLevel, uint256 _rareShieldEndurance) public authorized {
        require(_shieldLevel != 0 && _shieldLevel < rareShieldEndurance.length && _rareShieldEndurance > 0);
        rareShieldEndurance[_shieldLevel - 1] = _rareShieldEndurance;
    }
    
    function getRareShieldEndurance(uint256 _shieldLevel) public view returns (uint256) {
        require(_shieldLevel != 0 && _shieldLevel < rareShieldEndurance.length);
        return rareShieldEndurance[_shieldLevel - 1];
    }
    
    function updateShieldDefence(uint256 _shieldLevel, uint256 _shieldDefence) public authorized {
        require(_shieldLevel != 0 && _shieldLevel < shieldDefence.length && _shieldDefence > 0);
        shieldDefence[_shieldLevel - 1] = _shieldDefence;
    }
    
    function updateShieldUpChance(uint256 _shieldLevel, uint256 _shieldUpChance) public authorized {
        require(_shieldLevel < shieldUpChance.length && _shieldUpChance > 0);
        shieldUpChance[_shieldLevel] = _shieldUpChance;
    }
    
    function updateShieldDepletion(uint256 _shieldLevel, uint256 _shieldDepletion) public authorized {
        require(_shieldLevel < shieldDepletion.length && _shieldDepletion >= 0);
        shieldDepletion[_shieldLevel] = _shieldDepletion;
    }

    function setCommonBaseStat(uint256 _baseEndurance, uint256 _baseDefence) public authorized {
        require(_baseEndurance > 0 && _baseDefence > 0);
        commonBaseStat = [_baseEndurance, _baseDefence];
    }

    function getCommonBaseStat() public view returns (uint256[2] memory) {
        return commonBaseStat;
    }

    function setUpgradeBaseStat(uint256 _baseEndurance, uint256 _baseDefence) public authorized {
        require(_baseEndurance > 0 && _baseDefence > 0);
        upgradeBaseStat = [_baseEndurance, _baseDefence];
    }

    function getUpgradeBaseStat() public view returns (uint256[2] memory) {
        return upgradeBaseStat;
    }

    function setRareBaseStat(uint256 _baseEndurance, uint256 _baseDefence) public authorized {
        require(_baseEndurance > 0 && _baseDefence > 0);
        rareBaseStat = [_baseEndurance, _baseDefence];
    }

    function getRareBaseStat() public view returns (uint256[2] memory) {
        return rareBaseStat;
    }

    function addShieldStatus(uint256[] memory _statusID) public authorized {
        for(uint256 i = 0; i < _statusID.length; i++){
            shieldStatus.push(_statusID[i]);
        }
    }

    function addShieldType(uint256[] memory _typeID) public authorized {
        for(uint256 i = 0; i < _typeID.length; i++){
            shieldType.push(_typeID[i]);
        }
    }

    /* Shield attributes functions */

    // Setter

    function updateShieldEquip(uint256 _tokenID, bool _equip) external whenNotPaused authorized {
        require(apocShield[_tokenID].shieldEquip != _equip);
        apocShield[_tokenID].shieldEquip = _equip;
    }

    function levelUp(uint256 _tokenID) external whenNotPaused authorized {
        require(apocShield[_tokenID].shieldLevel < maxLevel);
        apocShield[_tokenID].shieldLevel += 1;
    }

    function reduceEndurance(uint256 _tokenID, uint256 _reduceEndurance) external whenNotPaused authorized {
        require (apocShield[_tokenID].shieldEndurance > 0);
        if (apocShield[_tokenID].shieldEndurance <= _reduceEndurance) {
            apocShield[_tokenID].shieldEndurance = 0;
        } else {
            apocShield[_tokenID].shieldEndurance -= _reduceEndurance;
        }
    }

    function recoverEndurance(uint256 _tokenID, uint256 _recoverEndurance) external whenNotPaused authorized {
        if (apocShield[_tokenID].shieldStatus == 0 && apocShield[_tokenID].shieldLevel == 0) {
            require (apocShield[_tokenID].shieldEndurance < rareBaseStat[0]);
        } else if (apocShield[_tokenID].shieldStatus == 0 && apocShield[_tokenID].shieldLevel > 0) {
            require (apocShield[_tokenID].shieldEndurance < rareShieldEndurance[apocShield[_tokenID].shieldLevel - 1]);
        } else if (apocShield[_tokenID].shieldStatus == 1 && apocShield[_tokenID].shieldLevel == 0) {
            require (apocShield[_tokenID].shieldEndurance < commonBaseStat[0]);
        } else if (apocShield[_tokenID].shieldStatus == 1 && apocShield[_tokenID].shieldLevel > 0) {
            require (apocShield[_tokenID].shieldEndurance < commonShieldEndurance[apocShield[_tokenID].shieldLevel - 1]);
        } else if (apocShield[_tokenID].shieldStatus > 1 && apocShield[_tokenID].shieldLevel == 0) {
            require (apocShield[_tokenID].shieldEndurance < upgradeBaseStat[0]);
        } else if (apocShield[_tokenID].shieldStatus > 1 && apocShield[_tokenID].shieldLevel > 0) {
            require (apocShield[_tokenID].shieldEndurance < upgradeShieldEndurance[apocShield[_tokenID].shieldLevel - 1]);
        }

        if (apocShield[_tokenID].shieldStatus == 0 && apocShield[_tokenID].shieldLevel == 0 && apocShield[_tokenID].shieldEndurance + _recoverEndurance >= rareBaseStat[0]) {
            apocShield[_tokenID].shieldEndurance = rareBaseStat[0];
        } else if (apocShield[_tokenID].shieldStatus == 0 && apocShield[_tokenID].shieldLevel > 0 && apocShield[_tokenID].shieldEndurance + _recoverEndurance >= rareShieldEndurance[apocShield[_tokenID].shieldLevel - 1]) {
            apocShield[_tokenID].shieldEndurance = rareShieldEndurance[apocShield[_tokenID].shieldLevel - 1];
        } else if (apocShield[_tokenID].shieldStatus == 1 && apocShield[_tokenID].shieldLevel == 0 && apocShield[_tokenID].shieldEndurance + _recoverEndurance >= commonBaseStat[0]) {
            apocShield[_tokenID].shieldEndurance = commonBaseStat[0];
        } else if (apocShield[_tokenID].shieldStatus == 1 && apocShield[_tokenID].shieldLevel > 0 && apocShield[_tokenID].shieldEndurance + _recoverEndurance >= commonShieldEndurance[apocShield[_tokenID].shieldLevel - 1]) {
            apocShield[_tokenID].shieldEndurance = commonShieldEndurance[apocShield[_tokenID].shieldLevel - 1];
        } else if (apocShield[_tokenID].shieldStatus > 1 && apocShield[_tokenID].shieldLevel == 0 && apocShield[_tokenID].shieldEndurance + _recoverEndurance >= upgradeBaseStat[0]) {
            apocShield[_tokenID].shieldEndurance = upgradeBaseStat[0];
        } else if (apocShield[_tokenID].shieldStatus > 1 && apocShield[_tokenID].shieldLevel > 0 && apocShield[_tokenID].shieldEndurance + _recoverEndurance >= upgradeShieldEndurance[apocShield[_tokenID].shieldLevel - 1]) {
            apocShield[_tokenID].shieldEndurance = upgradeShieldEndurance[apocShield[_tokenID].shieldLevel - 1];
        } else {
            apocShield[_tokenID].shieldEndurance += _recoverEndurance;
        }
    }

    // Getter

    function getShieldIndex(uint256 _tokenID) public view returns(uint256[2] memory) {
        return apocShield[_tokenID].shieldIndex;
    }

    function getShieldEquip(uint256 _tokenID) public view returns(bool) {
        return apocShield[_tokenID].shieldEquip;
    }

    function getShieldStatus(uint256 _tokenID) public view returns(uint256) {
        return apocShield[_tokenID].shieldStatus;
    }

    function getShieldType(uint256 _tokenID) public view returns(uint256) {
        return apocShield[_tokenID].shieldType;
    }

    function getShieldLevel(uint256 _tokenID) public view returns(uint256) {
        return apocShield[_tokenID].shieldLevel;
    }

    function getShieldEndurance(uint256 _tokenID) public view returns(uint256) {
        return apocShield[_tokenID].shieldEndurance;
    }

    function getBaseDefence(uint256 _tokenID) public view returns(uint256) {
        return apocShield[_tokenID].baseDefence;
    }

    function getShieldImage(uint256 _tokenID) public view returns (string memory) {
        string memory _shieldStatus = Strings.toString(apocShield[_tokenID].shieldStatus);
        string memory _shieldType = Strings.toString(apocShield[_tokenID].shieldType);
        string memory _shieldLevel = Strings.toString(apocShield[_tokenID].shieldLevel);
        string memory imgURI;

        if (_tokenID == 0) {
            imgURI = string(abi.encodePacked(IPFS, "/", cid, "/shield/0.png"));
        } else {
            imgURI = string(abi.encodePacked(IPFS, "/", cid, "/shield/", _shieldStatus, "/", _shieldType, "/", _shieldLevel, ".png"));
        }

        return imgURI;
    }

    /* NFT general logic functions */

    function _mixer(address _owner) internal view returns (uint256){
        uint256 userAddress = uint256(uint160(_owner));
        uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, block.number);

        uint256 _shieldType = randomizer.sliceNumber(random, shieldType.length, 1, shieldType.length);

        return _shieldType;
    }

    function _createShield(
        uint256[2] memory _currentSupplyInfo,
        uint256 _shieldStatus,
        uint256 _shieldType,
        uint256 _shieldLevel,
        uint256 _shieldEndurance,
        uint256 _baseDefence
    ) internal {
        Shield memory _apocShield = Shield({
            tokenID: _tokenIdCounter.current(),
            shieldIndex: _currentSupplyInfo,
            shieldEquip: false,
            shieldStatus: _shieldStatus,
            shieldType: _shieldType,
            shieldLevel: _shieldLevel,
            shieldEndurance: _shieldEndurance,
            baseDefence: _baseDefence
        });
        
        apocShield.push(_apocShield);
    }

    function _safeMint(address to) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        emit MintNewShield(to, tokenId);
    }

    /* NFT upgrade logic functions */

    function _burnUpgrade(uint256 _tokenID) internal {
        _burn(_tokenID);

        if (apocShield[_tokenID].shieldStatus == 0) {
            rareCurrentSupply -= 1;
            currentRareShieldSupply[apocShield[_tokenID].shieldType] -= 1;
        } else if (apocShield[_tokenID].shieldStatus == 1) {
            commonCurrentSupply -= 1;
            currentCommonShieldSupply[apocShield[_tokenID].shieldType] -= 1;
        } else {
            upgradeCurrentSupply -= 1;
            currentSpecificUpgradeShieldSupply[apocShield[_tokenID].shieldStatus][apocShield[_tokenID].shieldType] -= 1;
        }

    }

    function upgradeShield(address _owner, uint256 _tokenID1, uint256 _tokenID2, uint256 _nextStatus) external whenNotPaused authorized returns (bool, uint256) {
        require(
            apocShield[_tokenID1].shieldStatus <= maxUpgradeStatus &&
            apocShield[_tokenID2].shieldStatus <= maxUpgradeStatus &&
            apocShield[_tokenID1].shieldType == apocShield[_tokenID2].shieldType
        );

        uint256 _shieldType = apocShield[_tokenID1].shieldType;

        uint256 userAddress = uint256(uint160(_msgSender()));
        uint256 targetBlock = block.number + (upgradePercentage[1]/upgradePercentage[0]);
        uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);
        uint256 upgradeCheck = randomizer.sliceNumber(random, 10, upgradePercentage[1], upgradePercentage[1]/upgradePercentage[0]);

        if (upgradeCheck <= upgradePercentage[0]) {

            uint256[2] memory _currentSupplyInfo = [upgradeCurrentSupply + 1, currentSpecificUpgradeShieldSupply[_nextStatus][_shieldType] + 1];

            _createShield(
                _currentSupplyInfo,
                _nextStatus,
                _shieldType,
                0,
                upgradeBaseStat[0],
                upgradeBaseStat[1]
            );

            upgradeCurrentSupply += 1;
            currentSpecificUpgradeShieldSupply[_nextStatus][_shieldType] += 1;

            uint256 tokenID = _tokenIdCounter.current();
            _safeMint(_owner);

            _burnUpgrade(_tokenID1);
            _burnUpgrade(_tokenID2);

            return (true, tokenID);
        }

        _burnUpgrade(_tokenID1);
        _burnUpgrade(_tokenID2);

        return (false, 0);

    }

    /* NFT mint logic functions */

    function mintNewShield(address _owner) external whenNotPaused authorized returns (uint256){

        require(totalSupply() < totalMaxSupply);

        if (commonCurrentSupply == maxShieldSupply[1] && rareCurrentSupply < maxShieldSupply[0]) {
            return _mintRare(_owner);
        } else if (commonCurrentSupply < maxShieldSupply[1] && rareCurrentSupply < maxShieldSupply[0]) {
            uint256 userAddress = uint256(uint160(_owner));
            uint256 shieldMixer = shieldStatus.length + shieldType.length;
            uint256 targetBlock = block.number + shieldMixer;
            uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);

            uint256 rareCheck = randomizer.sliceNumber(random, 10, rarePercentage[1], shieldMixer);

            if (rareCheck <= rarePercentage[0]) {
                return _mintRare(_owner);
            } else {
                return _mintCommon(_owner);
            }
        } else {
                return _mintCommon(_owner);
        }

    }

    function _mintRare(address _owner) internal returns (uint256) {
        require(rareCurrentSupply < maxShieldSupply[0]);

        uint256 mixer = _mixer(_owner);
        
        uint256 typeIterations = 0;

        while(currentRareShieldSupply[mixer] == maxRareShieldSupply[mixer]) {
            require(typeIterations < shieldType.length);
            mixer += 1;
            if(mixer > shieldType.length) {
                mixer -= shieldType.length;
            }

            typeIterations += 1;
        }
        
        if (typeIterations >= shieldType.length) {
            return (0);
        }

        uint256[2] memory _currentSupplyInfo = [rareCurrentSupply + 1, currentRareShieldSupply[mixer] + 1];

        _createShield(
            _currentSupplyInfo,
            0,
            mixer,
            0,
            rareBaseStat[0],
            rareBaseStat[1]
        );

        rareCurrentSupply += 1;
        currentRareShieldSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return (tokenID);
    }

    function _mintCommon(address _owner) internal returns (uint256) {
        require(commonCurrentSupply < maxShieldSupply[1]);

        uint256 mixer = _mixer(_owner);
        
        uint256 typeIterations = 0;

        while(currentCommonShieldSupply[mixer] == maxCommonShieldSupply[mixer]) {
            require(typeIterations < shieldType.length);
            mixer += 1;
            if(mixer > shieldType.length) {
                mixer -= shieldType.length;
            }

            typeIterations += 1;
        }
        
        if (typeIterations >= shieldType.length) {
            return (0);
        }

        uint256[2] memory _currentSupplyInfo = [commonCurrentSupply + 1, currentCommonShieldSupply[mixer] + 1];

        _createShield(
            _currentSupplyInfo,
            1,
            mixer,
            0,
            commonBaseStat[0],
            commonBaseStat[1]
        );

        commonCurrentSupply += 1;
        currentCommonShieldSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return (tokenID);

    }

    /* NFT drop logic functions */

    function dropSpecific(
        address _owner,
        uint256 _shieldStatus,
        uint256 _shieldType
    ) external whenNotPaused onlyOwner {
        
        uint256 _shieldStatusIndex;
        uint256 _shieldTypeIndex;
        uint256 _baseEndurance;
        uint256 _baseDefence;

        addSpecificMaxShieldSupply(_shieldStatus, _shieldType, 1);

        if (_shieldStatus == 0) {
            _shieldStatusIndex = rareCurrentSupply + 1;
            _shieldTypeIndex = currentRareShieldSupply[_shieldType] + 1;
            _baseEndurance = rareBaseStat[0];
            _baseDefence = rareBaseStat[1];
        } else if (_shieldStatus == 1) {
            _shieldStatusIndex = commonCurrentSupply + 1;
            _shieldTypeIndex = currentCommonShieldSupply[_shieldType] + 1;
            _baseEndurance = commonBaseStat[0];
            _baseDefence = commonBaseStat[1];
        } else {
            _shieldStatusIndex = upgradeCurrentSupply + 1;
            _shieldTypeIndex = currentSpecificUpgradeShieldSupply[_shieldStatus][_shieldType] + 1;
            _baseEndurance = upgradeBaseStat[0];
            _baseDefence = upgradeBaseStat[1];
        }

        uint256[2] memory _currentSupplyInfo = [_shieldStatusIndex, _shieldTypeIndex];

        _createShield(
            _currentSupplyInfo,
            _shieldStatus,
            _shieldType,
            0,
            _baseEndurance,
            _baseDefence
        );

        if (_shieldStatus == 0) {
            rareCurrentSupply += 1;
            currentRareShieldSupply[_shieldType] += 1;
        } else if (_shieldStatus == 1) {
            commonCurrentSupply += 1;
            currentCommonShieldSupply[_shieldType] += 1;
        } else {
            upgradeCurrentSupply += 1;
            currentSpecificUpgradeShieldSupply[_shieldStatus][_shieldType] += 1;
        }

        _safeMint(_owner);
    }

    function dropRandom(
        address[] memory _owner
    ) external whenNotPaused onlyOwner {
        for(uint256 i = 0; i < _owner.length; i++) {
            uint256 userAddress = uint256(uint160(_owner[i]));
            uint256 shieldMixer = shieldStatus.length + shieldType.length;
            uint256 targetBlock = block.number + shieldMixer;
            uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, targetBlock);

            uint256 rareCheck = randomizer.sliceNumber(random, 10, rarePercentage[1], shieldMixer);

            if (rareCheck <= rarePercentage[0]) {
                _mintRareDrop(_owner[i]);
            } else {
                _mintCommonDrop(_owner[i]);
            }
        }

    }

    function mobDropRare(
        address _owner
    ) external whenNotPaused authorized returns (uint256) {
        return _mintRareDrop(_owner);
    }

    function _mintRareDrop(address _owner) internal returns (uint256) {
        require(rareCurrentSupply < maxShieldSupply[0]);

        uint256 mixer = _mixer(_owner);

        addSpecificMaxShieldSupply(0, mixer, 1);

        uint256[2] memory _currentSupplyInfo = [rareCurrentSupply + 1, currentRareShieldSupply[mixer] + 1];

        _createShield(
            _currentSupplyInfo,
            0,
            mixer,
            0,
            rareBaseStat[0],
            rareBaseStat[1]
        );

        rareCurrentSupply += 1;
        currentRareShieldSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return tokenID;
    }

    function _mintCommonDrop(address _owner) internal returns (uint256) {
        require(commonCurrentSupply < maxShieldSupply[1]);

        uint256 mixer = _mixer(_owner);

        addSpecificMaxShieldSupply(1, mixer, 1);

        uint256[2] memory _currentSupplyInfo = [commonCurrentSupply + 1, currentCommonShieldSupply[mixer] + 1];

        _createShield(
            _currentSupplyInfo,
            1,
            mixer,
            0,
            commonBaseStat[0],
            commonBaseStat[1]
        );

        commonCurrentSupply += 1;
        currentCommonShieldSupply[mixer] += 1;

        uint256 tokenID = _tokenIdCounter.current();
        _safeMint(_owner);

        return tokenID;
    }

    /* NFT ERC logic functions */

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}

contract ApocalypseGame is Pausable, Auth {


    /** LIBRARY **/
    using SafeMath for uint256;
    using Address for address;
    using Strings for string;


    /** DATA **/

    ApocalypseRandomizer public randomizer;
    ApocalypseCharacter public apocCharacter;
    ApocalypseWeapon public apocWeapon;
    ApocalypseWand public apocWand;
    ApocalypseShield public apocShield;
    
    IERC20Extended public rewardToken;
    
    RewardPoolDistributor public distributor;

    struct CharacterSlot {
        uint256 tokenID1;
        uint256 lastHPUpdate1;
        uint256 weaponID1;
        uint256 shieldID1;
        uint256 tokenID2;
        uint256 lastHPUpdate2;
        uint256 weaponID2;
        uint256 shieldID2;
    }

    uint256 public maxLevel;
    uint256 public baseHP;
    uint256 public upgradeBaseHP;
    uint256 public baseNextXP;
    uint256 public addDef;

    uint256 public maxSupplyIncrease;
    uint256 public lastSupplyIncrease;
    uint256 public cooldownSupplyIncrease;

    uint256 public hpRecovery;
    uint256 public durationHPRecover;
    uint256 public enduranceDeduction;
    uint256 public dropPercentage;

    uint256 public xpGainBase;
    uint256 public hpRequireBase;

    uint256[] public baseWinningRate;

    mapping(address => CharacterSlot) public charSlot;


    /** CONSTRUCTOR **/

    constructor(
        IERC20Extended _rewardToken,
        ApocalypseRandomizer _randomizer,
        ApocalypseCharacter _apocCharacter,
        ApocalypseWeapon _apocWeapon,
        ApocalypseWand _apocWand,
        ApocalypseShield _apocShield,
        RewardPoolDistributor _distributor
    ) {
        rewardToken = _rewardToken;
        
        randomizer = _randomizer;

        apocCharacter = _apocCharacter;
        apocWeapon = _apocWeapon;
        apocWand = _apocWand;
        apocShield = _apocShield;
        distributor = _distributor;

        maxLevel = 50;
        baseHP = 1000;
        upgradeBaseHP = 1500;
        baseNextXP =1000;
        addDef = 3;

        hpRequireBase = 100;
        xpGainBase = 10;
        enduranceDeduction = 10;
        hpRecovery = 1;
        durationHPRecover = 30;

        maxSupplyIncrease = 10;
        lastSupplyIncrease = block.timestamp;
        cooldownSupplyIncrease = 1 days;
        dropPercentage = 200;

        baseWinningRate = [90,89,88,87,86,85,84,83,82,81,80,79,78,77,76,75,74,73,72,71,70,69,68,67,66,65,64,63,62,61,60,55,53,50,46,43,40,38,35,30,25,24,22,20,18,16,14,12,10,5];
    }


    /** EVENT **/
    event ChangeRewardToken(address caller, address prevRewardToken, address newRewardToken);
    event ChangeRandomizer(address caller, address prevRandomizer, address newRandomizer);
    event ChangeRewardPool(address caller, address prevRewardPool, address newRewardPool);


    /** FUNCTION **/  

    /* General functions */

    function pause() public whenNotPaused authorized {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }
    /* Respective contract functions */

    function changeRewardToken(IERC20Extended _rewardToken) public authorized {
        address prevRewardToken = address(rewardToken);
        rewardToken = _rewardToken;
        emit ChangeRewardToken(_msgSender(), prevRewardToken, address(rewardToken));
    }

    function changeRandomizer(ApocalypseRandomizer _randomizer) public authorized {
        address prevRandomizer = address(randomizer);
        randomizer = _randomizer;
        emit ChangeRandomizer(_msgSender(), prevRandomizer, address(randomizer));
    }

    function changeRewardPool(RewardPoolDistributor _distributor) public authorized {
        address prevDistributor = address(distributor);
        distributor = _distributor;
        emit ChangeRewardPool(_msgSender(), prevDistributor, address(distributor));
    }

    /* Default stats functions */

    function setDefaultInfo(uint256 _maxLevel, uint256 _baseHP, uint256 _upgradeBaseHP, uint256 _baseNextXP, uint256 _addDef) public onlyOwner {
        require(_maxLevel > 0 && _baseHP > 0 && _upgradeBaseHP > 0 && _baseNextXP > 0 && _addDef > 0);
        maxLevel = _maxLevel;
        baseHP = _baseHP;
        upgradeBaseHP = _upgradeBaseHP;
        baseNextXP =_baseNextXP;
        addDef = _addDef;
        apocCharacter.setDefaultInfo(_maxLevel, _baseHP, _upgradeBaseHP, _baseNextXP, _addDef);
    }
    
    function addBaseWinningRate(uint256[] memory _baseWinningRate) public onlyOwner {
        for(uint256 i = 0; i < _baseWinningRate.length; i++){
            baseWinningRate.push(_baseWinningRate[i]);
        }
    }
    
    function updateBaseWinningRate(uint256 _characterLevel, uint256 _baseWinningRate) public onlyOwner {
        require(_characterLevel > 0 && _characterLevel <= maxLevel && _baseWinningRate > 0);
        baseWinningRate[_characterLevel - 1] = _baseWinningRate;
    }
    
    function updateHPRecovery(uint256 _hpRecovery, uint256 _durationHPRecover) public onlyOwner {
        require(_durationHPRecover > 0 && _hpRecovery > 0);
        durationHPRecover = _durationHPRecover;
        hpRecovery = _hpRecovery;
    }
    
    function updateXPGainBase(uint256 _xpGainBase) public onlyOwner {
        require(_xpGainBase > 0);
        xpGainBase = _xpGainBase;
    }
    
    function updateEnduranceDeduction(uint256 _enduranceDeduction) public onlyOwner {
        require(_enduranceDeduction > 0);
        enduranceDeduction = _enduranceDeduction;
    }
    
    function updateMaxSupplyIncrease(uint256 _maxSupplyIncrease, uint256 _cooldownSupplyIncrease) public onlyOwner {
        require(_maxSupplyIncrease > 0 && _cooldownSupplyIncrease > 0);
        maxSupplyIncrease = _maxSupplyIncrease;
        cooldownSupplyIncrease = _cooldownSupplyIncrease;
    }
    
    function updateDropPercentage(uint256 _dropPercentage) public onlyOwner {
        require(_dropPercentage > 0);
        dropPercentage = _dropPercentage;
    }

    /* Check functions */

    function increaseSupply() internal {
        if (block.timestamp >= lastSupplyIncrease + cooldownSupplyIncrease) {
            dailySupplyIncrease();
            lastSupplyIncrease = block.timestamp;
        }
    }
    
    function dailySupplyIncrease() internal {
        apocCharacter.addSpecificMaxCharSupply(1, 0, 0, maxSupplyIncrease); // fencing warriors
        apocCharacter.addSpecificMaxCharSupply(1, 0, 1, maxSupplyIncrease); // axe warriors
        apocCharacter.addSpecificMaxCharSupply(1, 0, 2, maxSupplyIncrease); // bow warriors
        apocCharacter.addSpecificMaxCharSupply(1, 0, 3, maxSupplyIncrease); // sword warriors
        apocCharacter.addSpecificMaxCharSupply(1, 0, 4, maxSupplyIncrease); // hammer warriors                        
        apocCharacter.addSpecificMaxCharSupply(1, 1, 0, maxSupplyIncrease); // energy mages
        apocCharacter.addSpecificMaxCharSupply(1, 1, 1, maxSupplyIncrease); // lightning mages
        apocCharacter.addSpecificMaxCharSupply(1, 1, 2, maxSupplyIncrease); // earth mages
        apocCharacter.addSpecificMaxCharSupply(1, 1, 3, maxSupplyIncrease); // ice mages
        apocCharacter.addSpecificMaxCharSupply(1, 1, 4, maxSupplyIncrease); // fire mages
    }

    function recoverHP(uint256 _slot) internal {

        if (_slot == 1) {
            uint256 duration = block.timestamp.sub(charSlot[_msgSender()].lastHPUpdate1);
            uint256 recover = duration.div(durationHPRecover).mul(hpRecovery);
            apocCharacter.recoverHP(charSlot[_msgSender()].tokenID1, recover);
        } else if (_slot == 2) {
            uint256 duration = block.timestamp.sub(charSlot[_msgSender()].lastHPUpdate2);
            uint256 recover = duration.div(durationHPRecover).mul(hpRecovery);
            apocCharacter.recoverHP(charSlot[_msgSender()].tokenID2, recover);
        }
    }

    function getSuccessRate(uint256 _tokenID) public view returns(uint256) {
        uint256 success = baseWinningRate[apocCharacter.getCharLevel(_tokenID).sub(1)].mul(100);
        uint256 failure = uint256(100).mul(100).sub(success);
        uint256 totalAttack = apocCharacter.getBaseAttack(_tokenID).add(apocCharacter.getAngelModifier(_tokenID));
        return success.add(totalAttack.mul(failure).div(200));
    }

    function getHPRequired(uint256 _tokenID) internal view returns(uint256) {
        return (apocCharacter.getCharLevel(_tokenID).sub(1)).mul(10).add(hpRequireBase);
    }

    function getXPGain(uint256 _tokenID) internal view returns(uint256) {
        return (apocCharacter.getCharLevel(_tokenID).sub(1)).mul(2).add(xpGainBase);
    }

    function mixer(uint256 _charTokenID) internal view returns (uint256[3] memory) {
        uint256 userAddress = uint256(uint160(_msgSender()));
        uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, block.number);
        uint256 randomN = randomizer.sliceNumber(random, 10, 4, apocCharacter.getCharLevel(_charTokenID));
        
        uint256 dropT = randomizer.sliceNumber(random, 3, 1, dropPercentage);
        uint256 dropN = randomizer.sliceNumber(random, 10, 4, dropPercentage);

        return [randomN, dropN, dropT];
    }

    function checkDrop(uint256 dropN, uint256 dropT) internal returns (uint256){
        if (dropPercentage >= dropN && dropT == 0) {
            return apocShield.mobDropRare(_msgSender());
        } else if (dropPercentage >= dropN && dropT == 1) {
            return apocWeapon.mobDropRare(_msgSender());
        } else if (dropPercentage >= dropN && dropT == 2) {
            return apocWand.mobDropRare(_msgSender());
        }

        return 0;

    }

    function checkFight(uint256 _charTokenID, uint256 _rand) internal view returns (bool) {
        if (
            apocCharacter.getCharType(_charTokenID) == 0 &&
            getSuccessRate(_charTokenID) >= _rand
        ) {
            return true;
        } else if (
            apocCharacter.getCharType(_charTokenID) == 1 &&
            getSuccessRate(_charTokenID) >= _rand
        ) {
            return true;
        } else {
            return false;
        }
    }

    function checkHPRecovery(uint256 _slot) internal {
        if (
            apocCharacter.getCharStatus(charSlot[_msgSender()].tokenID1) <= 1 &&
            apocCharacter.getCharHP(charSlot[_msgSender()].tokenID1) < apocCharacter.getBaseHP() &&
            block.timestamp > durationHPRecover.add(charSlot[_msgSender()].lastHPUpdate1) &&
            _slot == 1
        ) {
            recoverHP(1);
        } else if (
            apocCharacter.getCharStatus(charSlot[_msgSender()].tokenID1) > 1 &&
            apocCharacter.getCharHP(charSlot[_msgSender()].tokenID1) < apocCharacter.getUpgradeBaseHP() &&
            block.timestamp > durationHPRecover.add(charSlot[_msgSender()].lastHPUpdate1) &&
            _slot == 1
        ) {
            recoverHP(1);
        } else if (
            apocCharacter.getCharStatus(charSlot[_msgSender()].tokenID2) <= 1 &&
            apocCharacter.getCharHP(charSlot[_msgSender()].tokenID2) < apocCharacter.getBaseHP() &&
            block.timestamp > durationHPRecover.add(charSlot[_msgSender()].lastHPUpdate2) &&
            _slot == 2
        ) {
            recoverHP(2);
        } else if (
            apocCharacter.getCharStatus(charSlot[_msgSender()].tokenID2) > 1 &&
            apocCharacter.getCharHP(charSlot[_msgSender()].tokenID2) < apocCharacter.getUpgradeBaseHP() &&
            block.timestamp > durationHPRecover.add(charSlot[_msgSender()].lastHPUpdate2) &&
            _slot == 2
        ) {
            recoverHP(2);
        }
    }

    function checkCharacterEquip(uint256 _tokenID) internal {
        if(
            apocCharacter.getCharEquip(_tokenID) == true && 
            charSlot[_msgSender()].tokenID1 != _tokenID &&
            charSlot[_msgSender()].tokenID2 != _tokenID
        ) {
            apocCharacter.updateCharacterEquip(_tokenID, false);
        }

        apocCharacter.updateCharacterEquip(_tokenID, true);
    }
    
    function getCharSlot1(address _address) public view returns (uint256) {
        return charSlot[_address].tokenID1;
    }

    function getCharSlot2(address _address) public view returns (uint256) {
        return charSlot[_address].tokenID2;
    }
        
    /* Equip functions */

    function equipCharSlot1(uint256 _tokenID) external whenNotPaused {
        if(_msgSender() != owner()) {
            require(_tokenID > 0);
        }
        require(apocCharacter.ownerOf(_tokenID) == _msgSender());

        checkCharacterEquip(_tokenID);

        charSlot[_msgSender()].tokenID1 = _tokenID;
        charSlot[_msgSender()].lastHPUpdate1 = block.timestamp;

        increaseSupply();
    }

    function unequipCharSlot1() public whenNotPaused {
        increaseSupply();
        checkHPRecovery(1);
        apocCharacter.updateCharacterEquip(charSlot[_msgSender()].tokenID1, false);
        charSlot[_msgSender()].tokenID1 = 0;
    }


    function equipCharSlot2(uint256 _tokenID) external whenNotPaused {
        if(_msgSender() != owner()) {
            require(_tokenID > 0);
        }
        require(apocCharacter.ownerOf(_tokenID) == _msgSender());

        checkCharacterEquip(_tokenID);

        charSlot[_msgSender()].tokenID2 = _tokenID;
        charSlot[_msgSender()].lastHPUpdate2 = block.timestamp;

        increaseSupply();
    }

    function unequipCharSlot2() public whenNotPaused {
        increaseSupply();
        checkHPRecovery(2);
        apocCharacter.updateCharacterEquip(charSlot[_msgSender()].tokenID2, false);
        charSlot[_msgSender()].tokenID2 = 0;
    }

    /* Fight functions */

    function updateCharacter(bool fightStatus, uint256 tokenId) internal {
        if (fightStatus == true) {
            uint256 totalDefence = apocCharacter.getBaseDefence(tokenId).sub(apocCharacter.getAngelModifier(tokenId));
            uint256 _reduceHP = getHPRequired(tokenId).sub(totalDefence);
            apocCharacter.reduceHP(tokenId, _reduceHP);
            apocCharacter.receiveXP(tokenId, getXPGain(tokenId));
            distributor.distributeReward(_msgSender(), apocCharacter.getCharLevel(tokenId).mul(10**rewardToken.decimals()));
        } else if (fightStatus == false) {
            apocCharacter.reduceHP(tokenId, getHPRequired(tokenId));
        }
    }

    function fightSlot1() public whenNotPaused returns (bool){
        
        checkHPRecovery(1);

        uint256 _charTokenID = charSlot[_msgSender()].tokenID1;

        if (_msgSender() != owner()) {
            require(_charTokenID != 0);
        }

        require(
            apocCharacter.getCharHP(_charTokenID) > getHPRequired(_charTokenID) &&
            apocCharacter.getCharEquip(_charTokenID) == true &&
            apocCharacter.getCharXP(_charTokenID) != apocCharacter.getCharNextXP(_charTokenID)
        );

        uint256[3] memory rand = mixer(_charTokenID);

        bool fightStatus = checkFight(_charTokenID, rand[0]);

        updateCharacter(fightStatus, charSlot[_msgSender()].tokenID1);

        increaseSupply();

        return (fightStatus);

    }

    function fightSlot2() public whenNotPaused returns (bool){

        checkHPRecovery(2);

        uint256 _charTokenID = charSlot[_msgSender()].tokenID2;

        if (_msgSender() != owner()) {
            require(_charTokenID != 0);
        }

        require(
            apocCharacter.getCharHP(_charTokenID) > getHPRequired(_charTokenID) &&
            apocCharacter.getCharEquip(_charTokenID) == true &&
            apocCharacter.getCharXP(_charTokenID) != apocCharacter.getCharNextXP(_charTokenID)
        );
        

        uint256[3] memory rand = mixer(_charTokenID);

        bool fightStatus = checkFight(_charTokenID, rand[0]);

        updateCharacter(fightStatus, charSlot[_msgSender()].tokenID2);

        increaseSupply();

        return (fightStatus);

    }

}

contract ApocalypseMediator is Pausable, Auth {


    /** LIBRARY **/
    using SafeMath for uint256;
    using Address for address;
    using Strings for string;


    /** DATA **/

    IUniswapV2Router02 public router;

    ApocalypseCharacter public apocCharacter;
    ApocalypseWeapon public apocWeapon;
    ApocalypseWand public apocWand;
    ApocalypseShield public apocShield;

    IERC20Extended public mintCharacterToken;
    IERC20Extended public mintWeaponToken;
    IERC20Extended public mintWandToken;
    IERC20Extended public mintShieldToken;
    IERC20Extended public rewardToken;

    IERC20Extended public upgradeCharacterToken;
    IERC20Extended public levelUpCharacterToken;
    IERC20Extended public levelUpWeaponToken;
    IERC20Extended public levelUpWandToken;
    IERC20Extended public levelUpShieldToken;

    IERC20Extended public repairWeaponToken;
    IERC20Extended public repairWandToken;
    IERC20Extended public repairShieldToken;

    uint256 public characterBUSDPrice;
    uint256 public weaponBUSDPrice;
    uint256 public wandBUSDPrice;
    uint256 public shieldBUSDPrice;

    uint256 public characterUpgradeBUSDPrice;

    uint256 public weaponLevelUpBUSDPrice;
    uint256 public wandLevelUpBUSDPrice;
    uint256 public shieldLevelUpBUSDPrice;

    uint256 public weaponRepairBUSDPrice;
    uint256 public wandRepairBUSDPrice;
    uint256 public shieldRepairBUSDPrice;

    uint256 public maxUpgradeStatus;

    uint256 public xpGainBase;


    /** CONSTRUCTOR **/
    constructor(
        IERC20Extended _rvzToken,
        IERC20Extended _apocToken,
        IERC20Extended _rewardToken,
        IUniswapV2Router02 _router,
        ApocalypseCharacter _apocCharacter,
        ApocalypseWeapon _apocWeapon,
        ApocalypseWand _apocWand,
        ApocalypseShield _apocShield
    ) {
        router = _router;

        mintCharacterToken = _rvzToken;
        mintWeaponToken = _apocToken;
        mintWandToken = _apocToken;
        mintShieldToken = _apocToken;
        rewardToken = _rewardToken;
        
        upgradeCharacterToken = _apocToken;
        levelUpCharacterToken = _apocToken;
        levelUpWeaponToken = _apocToken;
        levelUpWandToken = _apocToken;
        levelUpShieldToken = _apocToken;

        repairWeaponToken = _apocToken;
        repairWandToken = _apocToken;
        repairShieldToken = _apocToken;

        apocCharacter = _apocCharacter;
        apocWeapon = _apocWeapon;
        apocWand = _apocWand;
        apocShield = _apocShield;

        maxUpgradeStatus = 2;
        xpGainBase = 10;

        characterUpgradeBUSDPrice = uint256(10).mul(10**rewardToken.decimals());
        weaponLevelUpBUSDPrice = uint256(10).mul(10**rewardToken.decimals());
        wandLevelUpBUSDPrice = uint256(10).mul(10**rewardToken.decimals());
        shieldLevelUpBUSDPrice = uint256(10).mul(10**rewardToken.decimals());
        
        weaponRepairBUSDPrice = uint256(10).mul(10**rewardToken.decimals());
        wandRepairBUSDPrice = uint256(10).mul(10**rewardToken.decimals());
        shieldRepairBUSDPrice = uint256(10).mul(10**rewardToken.decimals());

        characterBUSDPrice = uint256(100).mul(10**rewardToken.decimals());
        weaponBUSDPrice = uint256(50).mul(10**rewardToken.decimals());
        wandBUSDPrice = uint256(50).mul(10**rewardToken.decimals());
        shieldBUSDPrice = uint256(50).mul(10**rewardToken.decimals());
        
    }


    /** EVENT **/
    event ChangeRewardToken(address caller, address prevRewardToken, address newRewardToken);
    event ChangeMintCharacterToken(address caller, address prevMintCharacterToken, address newMintCharacterToken);
    event ChangeMintWeaponToken(address caller, address prevMintWeaponToken, address newMintWeaponToken);
    event ChangeMintWandToken(address caller, address prevMintWandToken, address newMintWandToken);
    event ChangeMintShieldToken(address caller, address prevMintShieldToken, address newMintShieldToken);
    event ChangeRouter(address caller, address prevRouter, address newRouter);
    

    /** FUNCTION **/

    /* General functions */

    function pause() public whenNotPaused authorized {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }

    /* Respective contract functions */

    function changeRewardToken(IERC20Extended _rewardToken) public authorized {
        address prevRewardToken = address(rewardToken);
        rewardToken = _rewardToken;
        emit ChangeRewardToken(_msgSender(), prevRewardToken, address(rewardToken));
    }

    function changeMintCharacterToken(IERC20Extended _mintCharacterToken) public authorized {
        address prevMintCharacterToken = address(mintCharacterToken);
        mintCharacterToken = _mintCharacterToken;
        emit ChangeMintCharacterToken(_msgSender(), prevMintCharacterToken, address(mintCharacterToken));
    }

    function changeMintWeaponToken(IERC20Extended _mintWeaponToken) public authorized {
        address prevMintWeaponToken = address(mintWeaponToken);
        mintWeaponToken = _mintWeaponToken;
        emit ChangeMintWeaponToken(_msgSender(), prevMintWeaponToken, address(mintWeaponToken));
    }

    function changeMintWandToken(IERC20Extended _mintWandToken) public authorized {
        address prevMintWandToken = address(mintWandToken);
        mintWandToken = _mintWandToken;
        emit ChangeMintWandToken(_msgSender(), prevMintWandToken, address(mintWandToken));
    }

    function changeMintShieldToken(IERC20Extended _mintShieldToken) public authorized {
        address prevMintShieldToken = address(mintShieldToken);
        mintShieldToken = _mintShieldToken;
        emit ChangeMintShieldToken(_msgSender(), prevMintShieldToken, address(mintShieldToken));
    }

    function changeRouter(IUniswapV2Router02 _router) public authorized {
        address prevRouter = address(router);
        router = _router;
        emit ChangeRouter(_msgSender(), prevRouter, address(router));
    }

    /* Default stats functions */

    function setMaxUpgradeStatus(uint256 _maxUpgradeStatus) public onlyOwner {
        require(_maxUpgradeStatus > 0);
        maxUpgradeStatus = _maxUpgradeStatus;
        apocCharacter.setMaxUpgradeStatus(_maxUpgradeStatus);
    }
    
    function updateXPGainBase(uint256 _xpGainBase) public onlyOwner {
        require(_xpGainBase > 0);
        xpGainBase = _xpGainBase;
    }

    function updateUpgradeBUSDPrice(uint256 _characterUpgradeBUSDPrice, uint256 _weaponLevelUpBUSDPrice, uint256 _wandLevelUpBUSDPrice, uint256 _shieldLevelUpBUSDPrice) public onlyOwner {
        require(_characterUpgradeBUSDPrice > 0 && _weaponLevelUpBUSDPrice > 0 && _wandLevelUpBUSDPrice > 0 && _shieldLevelUpBUSDPrice > 0);
        characterUpgradeBUSDPrice = uint256(_characterUpgradeBUSDPrice).mul(10**rewardToken.decimals());
        weaponLevelUpBUSDPrice = uint256(_weaponLevelUpBUSDPrice).mul(10**rewardToken.decimals());
        wandLevelUpBUSDPrice = uint256(_wandLevelUpBUSDPrice).mul(10**rewardToken.decimals());
        shieldLevelUpBUSDPrice = uint256(_shieldLevelUpBUSDPrice).mul(10**rewardToken.decimals());
    }

    function updateRepairBUSDPrice(uint256 _weaponRepairBUSDPrice, uint256 _wandRepairBUSDPrice, uint256 _shieldRepairBUSDPrice) public onlyOwner {
        require(_weaponRepairBUSDPrice > 0 && _wandRepairBUSDPrice > 0 && _shieldRepairBUSDPrice > 0);
        weaponRepairBUSDPrice = uint256(_weaponRepairBUSDPrice).mul(10**rewardToken.decimals());
        wandRepairBUSDPrice = uint256(_wandRepairBUSDPrice).mul(10**rewardToken.decimals());
        shieldRepairBUSDPrice = uint256(_shieldRepairBUSDPrice).mul(10**rewardToken.decimals());
    }

    function updateMintBUSDPrice(uint256 _characterBUSDPrice, uint256 _weaponBUSDPrice, uint256 _wandBUSDPrice, uint256 _shieldBUSDPrice) public onlyOwner {
        require(_characterBUSDPrice > 0 && _weaponBUSDPrice > 0 && _wandBUSDPrice > 0 && _shieldBUSDPrice > 0);
        characterBUSDPrice = uint256(_characterBUSDPrice).mul(10**rewardToken.decimals());
        weaponBUSDPrice = uint256(_weaponBUSDPrice).mul(10**rewardToken.decimals());
        wandBUSDPrice = uint256(_wandBUSDPrice).mul(10**rewardToken.decimals());
        shieldBUSDPrice = uint256(_shieldBUSDPrice).mul(10**rewardToken.decimals());
    }

    /* Check functions */

    function checkPrice(uint256 _priceBUSD, IERC20Extended _token) public view returns (uint256){
        address[] memory path = new address[](3);
        path[0] = address(_token);
        path[1] = router.WETH();
        path[2] = address(rewardToken);
        return router.getAmountsIn(_priceBUSD, path)[0];
    }

    function getXPGain(uint256 _tokenID) internal view returns(uint256) {
        return (apocCharacter.getCharLevel(_tokenID).sub(1)).mul(2).add(xpGainBase);
    }

    /* Pay and level up or upgrades functions */

    function upgradeCharacter(uint256 _tokenID1, uint256 _tokenID2) external whenNotPaused returns (bool, uint256) {
        require(_msgSender() == apocCharacter.ownerOf(_tokenID1) && _msgSender() == apocCharacter.ownerOf(_tokenID2));
        require(
            apocCharacter.getCharSkill(_tokenID1) == apocCharacter.getCharSkill(_tokenID2) &&
            apocCharacter.getCharType(_tokenID1) == apocCharacter.getCharType(_tokenID2) &&
            apocCharacter.getCharStatus(_tokenID1) == apocCharacter.getCharStatus(_tokenID2)
        );

        uint256 _nextStatus = apocCharacter.getCharStatus(_tokenID1).add(1);
        require (_nextStatus <= maxUpgradeStatus);

        uint256 amount = checkPrice(characterUpgradeBUSDPrice, upgradeCharacterToken);
        upgradeCharacterToken.transferFrom(_msgSender(), address(upgradeCharacterToken), amount);

        return apocCharacter.upgradeCharacter(_msgSender(), _tokenID1, _tokenID2, _nextStatus);
    }

    function levelUpCharacter(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocCharacter.ownerOf(_tokenID));
        uint256 rounds = uint256(1000).div(getXPGain(_tokenID));
        if (rounds.mul(getXPGain(_tokenID)) < 1000) {
            rounds += 1;
        }
        uint256 gain = rounds.mul(apocCharacter.getCharLevel(_tokenID));
        uint256 fee = gain.div(5);
        
        uint256 amount = checkPrice(fee, upgradeCharacterToken);
        upgradeCharacterToken.transferFrom(_msgSender(), address(upgradeCharacterToken), amount);

        apocCharacter.levelUp(_tokenID);
    }

    function levelUpWeapon(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocWeapon.ownerOf(_tokenID));
        uint256 amount = checkPrice(weaponLevelUpBUSDPrice, levelUpWeaponToken);
        levelUpWeaponToken.transferFrom(_msgSender(), address(levelUpWeaponToken), amount);
        apocWeapon.levelUp(_tokenID);
    }

    function levelUpWand(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocWand.ownerOf(_tokenID));
        uint256 amount = checkPrice(wandLevelUpBUSDPrice, levelUpWandToken);
        levelUpWandToken.transferFrom(_msgSender(), address(levelUpWandToken), amount);
        apocWand.levelUp(_tokenID);
    }

    function levelUpShield(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocShield.ownerOf(_tokenID));
        uint256 amount = checkPrice(shieldLevelUpBUSDPrice, levelUpShieldToken);
        levelUpShieldToken.transferFrom(_msgSender(), address(levelUpShieldToken), amount);
        apocShield.levelUp(_tokenID);
    }

    /* Pay and mint NFT functions */

    function mintCharacter() external whenNotPaused returns (uint256) {
        uint256 amount = checkPrice(characterBUSDPrice, mintCharacterToken);
        mintCharacterToken.transferFrom(_msgSender(), address(mintCharacterToken), amount);
        return apocCharacter.mintNewCharacter(_msgSender());
    }

    function mintWand() external whenNotPaused returns (uint256) {
        uint256 amount = checkPrice(wandBUSDPrice, mintWandToken);
        mintWandToken.transferFrom(_msgSender(), address(mintWandToken), amount);
        return apocWand.mintNewWand(_msgSender());
    }

    function mintWeapon() external whenNotPaused returns (uint256) {
        uint256 amount = checkPrice(weaponBUSDPrice, mintWeaponToken);
        mintWeaponToken.transferFrom(_msgSender(), address(mintWeaponToken), amount);
        return apocWeapon.mintNewWeapon(_msgSender());
    }

    function mintShield() external whenNotPaused returns (uint256)  {
        uint256 amount = checkPrice(shieldBUSDPrice, mintShieldToken);
        mintShieldToken.transferFrom(_msgSender(), address(mintShieldToken), amount);
        return apocShield.mintNewShield(_msgSender());
    }

    /* Pay and mint NFT functions */

    function repairWeapon(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocWeapon.ownerOf(_tokenID));
        uint256 amount = checkPrice(weaponRepairBUSDPrice, repairWeaponToken);
        repairWeaponToken.transferFrom(_msgSender(), address(repairWeaponToken), amount);

        uint256 status = apocWeapon.getWeaponStatus(_tokenID);
        uint256 level = apocWeapon.getWeaponLevel(_tokenID);
        
        uint256 _recoverEndurance;

        if (status == 0 && level > 0) {
            _recoverEndurance = apocWeapon.getRareWeaponEndurance(level);
        } else if (status == 0 && level == 0) {
            _recoverEndurance = apocWeapon.getRareBaseStat()[0];
        } else if (status == 1 && level > 0) {
            _recoverEndurance = apocWeapon.getCommonWeaponEndurance(level);
        } else if (status == 1 && level == 0) {
            _recoverEndurance = apocWeapon.getCommonBaseStat()[0];
        } else if (status > 1 && level > 0) {
            _recoverEndurance = apocWeapon.getUpgradeWeaponEndurance(level);
        } else if (status > 1 && level == 0) {
            _recoverEndurance = apocWeapon.getUpgradeBaseStat()[0];
        }

        apocWeapon.recoverEndurance(_tokenID, _recoverEndurance);
    }

    function repairWand(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocWand.ownerOf(_tokenID));
        uint256 amount = checkPrice(wandRepairBUSDPrice, repairWandToken);
        repairWandToken.transferFrom(_msgSender(), address(repairWandToken), amount);
        
        uint256 status = apocWand.getWandStatus(_tokenID);
        uint256 level = apocWand.getWandLevel(_tokenID);
        
        uint256 _recoverEndurance;

        if (status == 0 && level > 0) {
            _recoverEndurance = apocWand.getRareWandEndurance(level);
        } else if (status == 0 && level == 0) {
            _recoverEndurance = apocWand.getRareBaseStat()[0];
        } else if (status == 1 && level > 0) {
            _recoverEndurance = apocWand.getCommonWandEndurance(level);
        } else if (status == 1 && level == 0) {
            _recoverEndurance = apocWand.getCommonBaseStat()[0];
        } else if (status > 1 && level > 0) {
            _recoverEndurance = apocWand.getUpgradeWandEndurance(level);
        } else if (status > 1 && level == 0) {
            _recoverEndurance = apocWand.getUpgradeBaseStat()[0];
        }

        apocWand.recoverEndurance(_tokenID, _recoverEndurance);
    }

    function repairShield(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocShield.ownerOf(_tokenID));
        uint256 amount = checkPrice(shieldRepairBUSDPrice, repairShieldToken);
        repairShieldToken.transferFrom(_msgSender(), address(repairShieldToken), amount);
        
        uint256 status = apocShield.getShieldStatus(_tokenID);
        uint256 level = apocShield.getShieldLevel(_tokenID);
        
        uint256 _recoverEndurance;

        if (status == 0 && level > 0) {
            _recoverEndurance = apocShield.getRareShieldEndurance(level);
        } else if (status == 0 && level == 0) {
            _recoverEndurance = apocShield.getRareBaseStat()[0];
        } else if (status == 1 && level > 0) {
            _recoverEndurance = apocShield.getCommonShieldEndurance(level);
        } else if (status == 1 && level == 0) {
            _recoverEndurance = apocShield.getCommonBaseStat()[0];
        } else if (status > 1 && level > 0) {
            _recoverEndurance = apocShield.getUpgradeShieldEndurance(level);
        } else if (status > 1 && level == 0) {
            _recoverEndurance = apocShield.getUpgradeBaseStat()[0];
        }

        apocShield.recoverEndurance(_tokenID, _recoverEndurance);
    }

    
    
}