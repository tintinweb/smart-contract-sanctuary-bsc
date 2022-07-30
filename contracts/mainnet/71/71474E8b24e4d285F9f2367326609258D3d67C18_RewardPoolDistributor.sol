/**
 *Submitted for verification at BscScan.com on 2022-07-30
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

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
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

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string public _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
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
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Burnable is ERC1155 {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, values);
    }
}

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155Supply is ERC1155 {
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155Supply.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
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
    RewardPoolDistributor public prevDistributor;
    
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
    mapping(address => bool) public migrate;


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
        address payable prevDistributor_,
        uint256 dailyLimit_
    ) {
        _token = _msgSender();
        _owner = _msgSender();
        rewardToken = IERC20Extended(rewardToken_);
        router = IUniswapV2Router02(router_);
        prevDistributor = RewardPoolDistributor(prevDistributor_);
        timeLimit = 1 days;
        dailyLimit = dailyLimit_ * (10**rewardToken.decimals());
        totalDistributed = prevDistributor.totalDistributed();
    }


    /* FUNCTION */

    receive() external payable {}
 
    function withdrawAllTokens(IERC20Extended token_, address beneficiary) public onlyOwner {
        require(IERC20Extended(token_).transfer(beneficiary, IERC20Extended(token_).balanceOf(address(this))));
    }

    function withdrawAllNative(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }

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

    function migrateRewards() external {
        require(migrate[_msgSender()] == false, "You've migrated from previous reward pool distributor.");
        
        (uint256 prevTotalReceived, uint256 prevTotalAccumulated, , ) = prevDistributor.rewards(_msgSender());

        migrate[_msgSender()] = true;
        rewards[_msgSender()].totalReceived = rewards[_msgSender()].totalReceived.add(prevTotalReceived);
        rewards[_msgSender()].totalAccumulated = rewards[_msgSender()].totalAccumulated.add(prevTotalAccumulated);
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
        rewards[_user].currentLimit = dailyLimit;
        rewards[_user].limitReset = block.timestamp;
    }

    function needResetTimeLimit(address _user) internal view returns (bool) {
        return block.timestamp >= rewards[_user].limitReset.add(timeLimit);
    }

}


/** APOCALYPSE **/

contract ApocalypseRandomizer is Auth {


    /** DATA **/
    
    uint256 internal constant maskLast8Bits = uint256(0xff);
    uint256 internal constant maskFirst248Bits = type(uint256).max;
    
    uint256 public baseMultiplier;
    uint256 public addSliceOffset;
    uint256 public addTargetBlock;
    
    
    /** CONSTRUCTOR **/
    
    constructor (uint256 _baseMultipler, uint256 _addSliceOffset, uint256 _addTargetBlock) {
        baseMultiplier = _baseMultipler;
        addSliceOffset = _addSliceOffset;
        addTargetBlock = _addTargetBlock;
    }
    

    /** FUNCTION **/
    
    receive() external payable {}
 
    function withdrawTokens(IERC20Extended _token, address beneficiary) public onlyOwner {
        require(IERC20Extended(_token).transfer(beneficiary, IERC20Extended(_token).balanceOf(address(this))));
    }

    function withdrawNative(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }

    function changeBaseMultiplier(uint256 _baseMultiplier) public authorized {
        baseMultiplier = _baseMultiplier;
    }
    
    function changeAddSliceOffset(uint256 _addSliceOffset) public authorized {
        addSliceOffset = _addSliceOffset;
    }

    function changeAddtargetBlock(uint256 _addTargetBlock) public authorized {
        addTargetBlock = _addTargetBlock;
    }
       
    function sliceNumber(uint256 _n, uint256 _base, uint256 _index, uint256 _offset) public view returns (uint256) {
        return _sliceNumber(_n, _base * baseMultiplier , _index, _offset + addSliceOffset);
    }

    /**
     * @dev Given a number get a slice of any bits, at certain offset.
     * 
     * @param _n a number to be sliced
     * @param _base base number
     * @param _index how many bits long is the new number
     * @param _offset how many bits to skip
     */
    function _sliceNumber(uint256 _n, uint256 _base, uint256 _index, uint256 _offset) internal view returns (uint256) {
        uint256 mask = uint256((_base**_index) - 1) << _offset;
        return uint256((_n & mask) >> _offset) / baseMultiplier;
    }

    function randomNGenerator(uint256 _param1, uint256 _param2, uint256 _targetBlock) public view returns (uint256) {
        return _randomNGenerator(_param1, _param2, _targetBlock + addTargetBlock);
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

    function withdrawNative(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }

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
        weaponAttack = [2,4,8,10,15,20,25,30,40,50];
        weaponUpChance = [40,38,35,32,28,23,20,15,10,5];
        weaponDepletion = [10,20,30,40,50,60,70,80,90,100];

        maxLevel = 10;

        commonBaseStat = [500, 1];
        rareBaseStat = [10000, 100];
        
        rarePercentage = [5, 4];

        addSpecificMaxWeaponSupply(0, 0, 2); // 2 rare fencing
        addSpecificMaxWeaponSupply(0, 1, 2); // 2 rare axe
        addSpecificMaxWeaponSupply(0, 2, 2); // 2 rare bow
        addSpecificMaxWeaponSupply(0, 3, 2); // 2 rare sword
        addSpecificMaxWeaponSupply(0, 4, 2); // 2 rare hammer

        addSpecificMaxWeaponSupply(1, 0, 100000); // 100,000 fencing
        addSpecificMaxWeaponSupply(1, 1, 100000); // 100,000 axe
        addSpecificMaxWeaponSupply(1, 2, 100000); // 100,000 bow
        addSpecificMaxWeaponSupply(1, 3, 100000); // 100,000 sword
        addSpecificMaxWeaponSupply(1, 4, 100000); // 100,000 hammer

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

    receive() external payable {}
 
    function withdrawTokens(IERC20Extended _token, address beneficiary) public onlyOwner {
        require(IERC20Extended(_token).transfer(beneficiary, IERC20Extended(_token).balanceOf(address(this))));
    }

    function withdrawNative(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }

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

    // Setter

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

    function setCommonBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        commonBaseStat = [_baseEndurance, _baseAttack];
    }

    function setUpgradeBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        upgradeBaseStat = [_baseEndurance, _baseAttack];
    }

    function setRareBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        rareBaseStat = [_baseEndurance, _baseAttack];
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
    
    function updateWeaponAttack(uint256 _weaponLevel, uint256 _weaponAttack) public authorized {
        require(_weaponLevel != 0 && _weaponLevel <= weaponAttack.length && _weaponAttack > 0);
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

    // Getter
    
    function getWeaponAttack(uint256 _weaponLevel) public view returns (uint256) {
        require(_weaponLevel != 0 && _weaponLevel <= weaponAttack.length);
        return weaponAttack[_weaponLevel - 1];
    }
    
    function getWeaponUpChance(uint256 _weaponLevel) public view returns (uint256) {
        require(_weaponLevel < weaponUpChance.length);
        return weaponUpChance[_weaponLevel];
    }
    
    function getWeaponDepletion(uint256 _weaponLevel) public view returns (uint256) {
        require(_weaponLevel < weaponDepletion.length);
        return weaponDepletion[_weaponLevel];
    }

    function getCommonBaseStat() public view returns (uint256[2] memory) {
        return commonBaseStat;
    }

    function getUpgradeBaseStat() public view returns (uint256[2] memory) {
        return upgradeBaseStat;
    }

    function getRareBaseStat() public view returns (uint256[2] memory) {
        return rareBaseStat;
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

    function updateAttack(uint256 _tokenID, uint256 _attack) external whenNotPaused authorized {
        require (_attack > 0);
        apocWeapon[_tokenID].baseAttack = _attack;
    }

    function updateEndurance(uint256 _tokenID, uint256 _updateEndurance) external whenNotPaused authorized {
        require (_updateEndurance > 0);
        apocWeapon[_tokenID].weaponEndurance = _updateEndurance;
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
        if (apocWeapon[_tokenID].weaponStatus == 0) {
            require (apocWeapon[_tokenID].weaponEndurance < rareBaseStat[0]);
        } else if (apocWeapon[_tokenID].weaponStatus == 1) {
            require (apocWeapon[_tokenID].weaponEndurance < commonBaseStat[0]);
        } else if (apocWeapon[_tokenID].weaponStatus > 1) {
            require (apocWeapon[_tokenID].weaponEndurance < upgradeBaseStat[0]);
        }

        if (apocWeapon[_tokenID].weaponStatus == 0 && apocWeapon[_tokenID].weaponEndurance + _recoverEndurance >= rareBaseStat[0]) {
            apocWeapon[_tokenID].weaponEndurance = rareBaseStat[0];
        } else if (apocWeapon[_tokenID].weaponStatus == 1 && apocWeapon[_tokenID].weaponEndurance + _recoverEndurance >= commonBaseStat[0]) {
            apocWeapon[_tokenID].weaponEndurance = commonBaseStat[0];
        } else if (apocWeapon[_tokenID].weaponStatus > 1 && apocWeapon[_tokenID].weaponEndurance + _recoverEndurance >= upgradeBaseStat[0]) {
            apocWeapon[_tokenID].weaponEndurance = upgradeBaseStat[0];
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

    function _burnLevelUp(uint256 _tokenID) external whenNotPaused authorized {
        _burnUpgrade(_tokenID);
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

    function upgradeWeapon(address _owner, uint256 _tokenID1, uint256 _tokenID2) external whenNotPaused authorized returns (bool, uint256) {
        require(
            apocWeapon[_tokenID1].weaponStatus <= maxUpgradeStatus &&
            apocWeapon[_tokenID2].weaponStatus <= maxUpgradeStatus &&
            apocWeapon[_tokenID1].weaponType == apocWeapon[_tokenID2].weaponType
        );

        uint256 _weaponType = apocWeapon[_tokenID1].weaponType;
        uint256 _nextStatus = apocWeapon[_tokenID1].weaponStatus + 1;

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
        address[] memory _owner,
        uint256 _weaponStatus,
        uint256 _weaponType
    ) external whenNotPaused onlyOwner {
        for(uint256 i = 0; i < _owner.length; i++) {
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

            _safeMint(_owner[i]);
        }
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
        wandAttack = [2,4,8,10,15,20,25,30,40,50];
        wandUpChance = [40,38,35,32,28,23,20,15,10,5];
        wandDepletion = [10,20,30,40,50,60,70,80,90,100];

        maxLevel = 10;

        commonBaseStat = [500, 1];
        rareBaseStat = [10000, 100];
        
        rarePercentage = [5, 4];

        addSpecificMaxWandSupply(0, 0, 2); // 2 rare energy
        addSpecificMaxWandSupply(0, 1, 2); // 2 rare lightning
        addSpecificMaxWandSupply(0, 2, 2); // 2 rare earth
        addSpecificMaxWandSupply(0, 3, 2); // 2 rare ice
        addSpecificMaxWandSupply(0, 4, 2); // 2 rare fire

        addSpecificMaxWandSupply(1, 0, 100000); // 100,000 energy
        addSpecificMaxWandSupply(1, 1, 100000); // 100,000 lightning
        addSpecificMaxWandSupply(1, 2, 100000); // 100,000 earth
        addSpecificMaxWandSupply(1, 3, 100000); // 100,000 ice
        addSpecificMaxWandSupply(1, 4, 100000); // 100,000 fire

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

    receive() external payable {}
 
    function withdrawTokens(IERC20Extended _token, address beneficiary) public onlyOwner {
        require(IERC20Extended(_token).transfer(beneficiary, IERC20Extended(_token).balanceOf(address(this))));
    }

    function withdrawNative(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }

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

    // Setter

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

    function setCommonBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        commonBaseStat = [_baseEndurance, _baseAttack];
    }

    function setUpgradeBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        upgradeBaseStat = [_baseEndurance, _baseAttack];
    }

    function setRareBaseStat(uint256 _baseEndurance, uint256 _baseAttack) public authorized {
        require(_baseEndurance > 0 && _baseAttack > 0);
        rareBaseStat = [_baseEndurance, _baseAttack];
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

    function updateWandAttack(uint256 _wandLevel, uint256 _wandAttack) public authorized {
        require(_wandLevel != 0 && _wandLevel <= wandAttack.length && _wandAttack > 0);
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
    
    // Getter

    function getWandAttack(uint256 _wandLevel) public view returns (uint256) {
        require(_wandLevel != 0 && _wandLevel <= wandAttack.length);
        return wandAttack[_wandLevel - 1];
    }

    function getWandUpChance(uint256 _wandLevel) public view returns (uint256) {
        require(_wandLevel < wandUpChance.length);
        return wandUpChance[_wandLevel];
    }

    function getWandDepletion(uint256 _wandLevel) public view returns (uint256) {
        require(_wandLevel < wandDepletion.length);
        return wandDepletion[_wandLevel];
    }

    function getCommonBaseStat() public view returns (uint256[2] memory) {
        return commonBaseStat;
    }

    function getUpgradeBaseStat() public view returns (uint256[2] memory) {
        return upgradeBaseStat;
    }

    function getRareBaseStat() public view returns (uint256[2] memory) {
        return rareBaseStat;
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

    function updateAttack(uint256 _tokenID, uint256 _attack) external whenNotPaused authorized {
        require (_attack > 0);
        apocWand[_tokenID].baseAttack = _attack;
    }

    function updateEndurance(uint256 _tokenID, uint256 _updateEndurance) external whenNotPaused authorized {
        require (_updateEndurance > 0);
        apocWand[_tokenID].wandEndurance = _updateEndurance;
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
        if (apocWand[_tokenID].wandStatus == 0) {
            require (apocWand[_tokenID].wandEndurance < rareBaseStat[0]);
        } else if (apocWand[_tokenID].wandStatus == 1) {
            require (apocWand[_tokenID].wandEndurance < commonBaseStat[0]);
        } else if (apocWand[_tokenID].wandStatus > 1) {
            require (apocWand[_tokenID].wandEndurance < upgradeBaseStat[0]);
        }

        if (apocWand[_tokenID].wandStatus == 0 && apocWand[_tokenID].wandEndurance + _recoverEndurance >= rareBaseStat[0]) {
            apocWand[_tokenID].wandEndurance = rareBaseStat[0];
        } else if (apocWand[_tokenID].wandStatus == 1 && apocWand[_tokenID].wandEndurance + _recoverEndurance >= commonBaseStat[0]) {
            apocWand[_tokenID].wandEndurance = commonBaseStat[0];
        } else if (apocWand[_tokenID].wandStatus > 1 && apocWand[_tokenID].wandEndurance + _recoverEndurance >= upgradeBaseStat[0]) {
            apocWand[_tokenID].wandEndurance = upgradeBaseStat[0];
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

    function _burnLevelUp(uint256 _tokenID) external whenNotPaused authorized {
        _burnUpgrade(_tokenID);
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

    function upgradeWand(address _owner, uint256 _tokenID1, uint256 _tokenID2) external whenNotPaused authorized returns (bool, uint256) {
        require(
            apocWand[_tokenID1].wandStatus <= maxUpgradeStatus &&
            apocWand[_tokenID2].wandStatus <= maxUpgradeStatus &&
            apocWand[_tokenID1].wandType == apocWand[_tokenID2].wandType
        );

        uint256 _wandType = apocWand[_tokenID1].wandType;
        uint256 _nextStatus = apocWand[_tokenID1].wandStatus + 1;

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
        address[] memory _owner,
        uint256 _wandStatus,
        uint256 _wandType
    ) external whenNotPaused onlyOwner {
        for(uint256 i = 0; i < _owner.length; i++) {
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

            _safeMint(_owner[i]);
        }
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
        shieldDefence = [2,4,8,10,15,20,25,30,40,50];
        shieldUpChance = [40,38,35,32,28,23,20,15,10,5];
        shieldDepletion = [10,20,30,40,50,60,70,80,90,100];

        maxLevel = 10;

        commonBaseStat = [500, 1];
        rareBaseStat = [10000, 100];
        
        rarePercentage = [5, 4];

        addSpecificMaxShieldSupply(0, 0, 5); // 5 rare medusa
        addSpecificMaxShieldSupply(0, 1, 5); // 5 rare devlin

        addSpecificMaxShieldSupply(1, 0, 100000); // 100,000 universal tower

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

    receive() external payable {}
 
    function withdrawTokens(IERC20Extended _token, address beneficiary) public onlyOwner {
        require(IERC20Extended(_token).transfer(beneficiary, IERC20Extended(_token).balanceOf(address(this))));
    }

    function withdrawNative(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }

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

    // Setter

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

    function setCommonBaseStat(uint256 _baseEndurance, uint256 _baseDefence) public authorized {
        require(_baseEndurance > 0 && _baseDefence > 0);
        commonBaseStat = [_baseEndurance, _baseDefence];
    }

    function setUpgradeBaseStat(uint256 _baseEndurance, uint256 _baseDefence) public authorized {
        require(_baseEndurance > 0 && _baseDefence > 0);
        upgradeBaseStat = [_baseEndurance, _baseDefence];
    }

    function setRareBaseStat(uint256 _baseEndurance, uint256 _baseDefence) public authorized {
        require(_baseEndurance > 0 && _baseDefence > 0);
        rareBaseStat = [_baseEndurance, _baseDefence];
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

    function updateShieldDefence(uint256 _shieldLevel, uint256 _shieldDefence) public authorized {
        require(_shieldLevel != 0 && _shieldLevel <= shieldDefence.length && _shieldDefence > 0);
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

    // Getter

    function getShieldDefence(uint256 _shieldLevel) public view returns (uint256) {
        require(_shieldLevel != 0 && _shieldLevel <= shieldDefence.length);
        return shieldDefence[_shieldLevel - 1];
    }
    
    function getShieldUpChance(uint256 _shieldLevel) public view returns (uint256) {
        require(_shieldLevel < shieldUpChance.length);
        return shieldUpChance[_shieldLevel];
    }

    function getShieldDepletion(uint256 _shieldLevel) public view returns (uint256) {
        require(_shieldLevel < shieldDepletion.length);
        return shieldDepletion[_shieldLevel];
    }

    function getCommonBaseStat() public view returns (uint256[2] memory) {
        return commonBaseStat;
    }

    function getUpgradeBaseStat() public view returns (uint256[2] memory) {
        return upgradeBaseStat;
    }

    function getRareBaseStat() public view returns (uint256[2] memory) {
        return rareBaseStat;
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

    function updateDefence(uint256 _tokenID, uint256 _defence) external whenNotPaused authorized {
        require (_defence > 0);
        apocShield[_tokenID].baseDefence = _defence;
    }

    function updateEndurance(uint256 _tokenID, uint256 _updateEndurance) external whenNotPaused authorized {
        require (_updateEndurance > 0);
        apocShield[_tokenID].shieldEndurance = _updateEndurance;
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
        if (apocShield[_tokenID].shieldStatus == 0) {
            require (apocShield[_tokenID].shieldEndurance < rareBaseStat[0]);
        } else if (apocShield[_tokenID].shieldStatus == 1) {
            require (apocShield[_tokenID].shieldEndurance < commonBaseStat[0]);
        } else if (apocShield[_tokenID].shieldStatus > 1) {
            require (apocShield[_tokenID].shieldEndurance < upgradeBaseStat[0]);
        }

        if (apocShield[_tokenID].shieldStatus == 0 && apocShield[_tokenID].shieldEndurance + _recoverEndurance >= rareBaseStat[0]) {
            apocShield[_tokenID].shieldEndurance = rareBaseStat[0];
        } else if (apocShield[_tokenID].shieldStatus == 1 && apocShield[_tokenID].shieldEndurance + _recoverEndurance >= commonBaseStat[0]) {
            apocShield[_tokenID].shieldEndurance = commonBaseStat[0];
        } else if (apocShield[_tokenID].shieldStatus > 1 && apocShield[_tokenID].shieldEndurance + _recoverEndurance >= upgradeBaseStat[0]) {
            apocShield[_tokenID].shieldEndurance = upgradeBaseStat[0];
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

    function _burnLevelUp(uint256 _tokenID) external whenNotPaused authorized {
        _burnUpgrade(_tokenID);
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

    function upgradeShield(address _owner, uint256 _tokenID1, uint256 _tokenID2) external whenNotPaused authorized returns (bool, uint256) {
        require(
            apocShield[_tokenID1].shieldStatus <= maxUpgradeStatus &&
            apocShield[_tokenID2].shieldStatus <= maxUpgradeStatus &&
            apocShield[_tokenID1].shieldType == apocShield[_tokenID2].shieldType
        );

        uint256 _shieldType = apocShield[_tokenID1].shieldType;
        uint256 _nextStatus = apocShield[_tokenID1].shieldStatus + 1;

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
        address[] memory _owner,
        uint256 _shieldStatus,
        uint256 _shieldType
    ) external whenNotPaused onlyOwner {
        for(uint256 i = 0; i < _owner.length; i++) {
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

            _safeMint(_owner[i]);
        }
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

contract ApocalypseMineral is ERC1155, Auth, Pausable, ERC1155Burnable, ERC1155Supply {


    /** LIBRARY **/

    using Address for address;
    using Strings for string;


    /** DATA **/

    struct Mineral {
        uint256 mineralUpgradeMOQ;
        uint256 mineralUpgradeCost;
        uint256[4] mineralChances;
        string mineralName;
        string mineralDescription;
        string mineralImageLink;
    }

    Mineral[] public apocMineral;

    string public uriExtension;
    string public imageLink;

    /** CONSTRUCTOR **/

    constructor(
        string memory _imageLink
    ) ERC1155("https://api.apocgame.io/minerals/") {
        imageLink = _imageLink;

        createMineral(2, 1, [uint256(5), uint256(50), uint256(50), uint256(50)], "Coal", "", string(abi.encodePacked(imageLink, "0.png")));
        createMineral(2, 1, [uint256(5), uint256(0), uint256(50), uint256(50)], "Super Coal", "", string(abi.encodePacked(imageLink, "1.png")));
        createMineral(2, 1, [uint256(5), uint256(0), uint256(50), uint256(50)], "Ultra Coal", "", string(abi.encodePacked(imageLink, "2.png")));
        createMineral(2, 1, [uint256(5), uint256(0), uint256(50), uint256(50)], "Iron Ore", "", string(abi.encodePacked(imageLink, "3.png")));
        createMineral(2, 1, [uint256(5), uint256(0), uint256(50), uint256(50)], "Iron Ingot", "", string(abi.encodePacked(imageLink, "4.png")));
        createMineral(2, 1, [uint256(5), uint256(0), uint256(50), uint256(50)], "Mithral", "", string(abi.encodePacked(imageLink, "5.png")));
        createMineral(2, 1, [uint256(5), uint256(0), uint256(50), uint256(50)], "Mithral Ingot", "", string(abi.encodePacked(imageLink, "6.png")));
        createMineral(2, 1, [uint256(5), uint256(0), uint256(50), uint256(50)], "Bronze", "", string(abi.encodePacked(imageLink, "7.png")));
        createMineral(2, 1, [uint256(5), uint256(0), uint256(50), uint256(50)], "Bronze Ingot", "", string(abi.encodePacked(imageLink, "8.png")));
        createMineral(2, 1, [uint256(5), uint256(0), uint256(50), uint256(50)], "Silver", "", string(abi.encodePacked(imageLink,"9.png")));
        createMineral(2, 1, [uint256(4), uint256(0), uint256(50), uint256(50)], "Silver Ingot", "", string(abi.encodePacked(imageLink, "10.png")));
        createMineral(2, 1, [uint256(3), uint256(0), uint256(50), uint256(50)], "Gold", "", string(abi.encodePacked(imageLink, "11.png")));
        createMineral(2, 1, [uint256(2), uint256(0), uint256(50), uint256(50)], "Gold Ingot", "", string(abi.encodePacked(imageLink, "12.png")));
        createMineral(2, 1, [uint256(1), uint256(0), uint256(50), uint256(50)], "Crystal", "", string(abi.encodePacked(imageLink, "13.png")));
        createMineral(2, 1, [uint256(1), uint256(0), uint256(50), uint256(50)], "Crystalware", "", string(abi.encodePacked(imageLink, "14.png")));
        createMineral(2, 1, [uint256(1), uint256(0), uint256(50), uint256(50)], "Sapphire", "", string(abi.encodePacked(imageLink, "15.png")));
        createMineral(2, 1, [uint256(1), uint256(0), uint256(50), uint256(50)], "Ruby", "", string(abi.encodePacked(imageLink, "16.png")));
        createMineral(2, 1, [uint256(1), uint256(0), uint256(50), uint256(50)], "Magic Ruby", "", string(abi.encodePacked(imageLink, "17.png")));
        createMineral(2, 1, [uint256(1), uint256(0), uint256(50), uint256(50)], "Emerald", "", string(abi.encodePacked(imageLink, "18.png")));
        createMineral(2, 1, [uint256(1), uint256(0), uint256(50), uint256(50)], "Magic Emerald", "", string(abi.encodePacked(imageLink, "19.png")));
        createMineral(2, 1, [uint256(1), uint256(0), uint256(50), uint256(50)], "Diamond", "", string(abi.encodePacked(imageLink, "20.png")));
        createMineral(2, 1, [uint256(1), uint256(0), uint256(50), uint256(50)], "Magic Diamond", "", string(abi.encodePacked(imageLink, "21.png")));
        createMineral(2, 1, [uint256(1), uint256(0), uint256(50), uint256(50)], "Merien Stone", "", string(abi.encodePacked(imageLink, "22.png")));
        createMineral(2, 1, [uint256(1), uint256(0), uint256(50), uint256(50)], "Xelima Stone", "", string(abi.encodePacked(imageLink, "23.png")));
        createMineral(0, 1, [uint256(1), uint256(0), uint256(0), uint256(0)], "Elemental Stone", "", string(abi.encodePacked(imageLink, "24.png")));
    }


    /** EVENT **/

    event SetImageLink(string prevImageLink, string newImageLink);
    event SetURI(string prevURI, string newURI);
    event SetURIExtension(string prevURIExtension, string newURIExtension);


    /** FUNCTION **/

    // General function
    
    /**
     * @dev Allow smart contract to receive payment.
     */
    receive() external payable {}

    /**
     * @dev Only owner can withdraw ERC20-based token in smart contract.
     */
    function withdrawTokens(IERC20Extended _token, address beneficiary) public onlyOwner {
        require(IERC20Extended(_token).transfer(beneficiary, IERC20Extended(_token).balanceOf(address(this))));
    }

    /**
     * @dev Only owner can withdraw native token in smart contract.
     */
    function withdrawNative(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }

    /**
     * @dev Only owner can set the new image link.
     */
    function setImageLink(string memory newImageLink) public onlyOwner {
        string memory prevImageLink = imageLink;
        imageLink = newImageLink;
        emit SetImageLink(prevImageLink, newImageLink);
    }

    /**
     * @dev Only owner can set the new URI.
     */
    function setURI(string memory newURI) public onlyOwner {
        string memory prevURI = _uri;
        _setURI(newURI);
        emit SetURI(prevURI, newURI);
    }

    /**
     * @dev Only owner can set the new URI extension.
     */
    function setURIExtension(string memory newURIExtension) public onlyOwner {
        string memory prevURIExtension = uriExtension;
        uriExtension = newURIExtension;
        emit SetURIExtension(prevURIExtension, newURIExtension);
    }

    /**
     * @dev Only owner can pause the smart contract.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Only owner can unpause the smart contract.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    // Mineral related function

    /**
     * @dev Push metadata information for the mineral.
     */
    function createMineral(
        uint256 _mineralUpgradeMOQ,
        uint256 _mineralUpgradeCost,
        uint256[4] memory _mineralChances,
        string memory _mineralName,
        string memory _mineralDescription,
        string memory _mineralImageLink
    ) public authorized {
        Mineral memory _apocMineral = Mineral({
            mineralUpgradeMOQ: _mineralUpgradeMOQ,
            mineralUpgradeCost: _mineralUpgradeCost,
            mineralChances: _mineralChances,
            mineralName: _mineralName,
            mineralDescription: _mineralDescription,
            mineralImageLink: _mineralImageLink
        });
        
        apocMineral.push(_apocMineral);
    }

    /**
     * @dev Change information for the mineralUpgradeMOQ.
     */
    function setMineralUpgradeMOQ(uint256 _tokenID, uint256 _mineralUpgradeMOQ) public authorized {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        require(apocMineral[_tokenID].mineralUpgradeMOQ != _mineralUpgradeMOQ, "This is the current value!"); 
        apocMineral[_tokenID].mineralUpgradeMOQ = _mineralUpgradeMOQ;
    }

    /**
     * @dev Change information for the mineralUpgradeCost.
     */
    function setMineralUpgradeCost(uint256 _tokenID, uint256 _mineralUpgradeCost) public authorized {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        require(apocMineral[_tokenID].mineralUpgradeCost != _mineralUpgradeCost, "This is the current value!"); 
        require(_mineralUpgradeCost > 0, "Cannot set as 0!");
        apocMineral[_tokenID].mineralUpgradeCost = _mineralUpgradeCost;
    }

    /**
     * @dev Change information for the mineralPVPDropChances.
     */
    function setMineralPVPDropChance(uint256 _tokenID, uint256 _mineralPVPDropChance) public authorized {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        require(apocMineral[_tokenID].mineralChances[0] != _mineralPVPDropChance, "This is the current value!"); 
        require(_mineralPVPDropChance > 0, "Cannot set as 0!");
        apocMineral[_tokenID].mineralChances[0] = _mineralPVPDropChance;
    }

    /**
     * @dev Change information for the mineralMiningChances.
     */
    function setMineralMiningChance(uint256 _tokenID, uint256 _mineralMiningChance) public authorized {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        require(apocMineral[_tokenID].mineralChances[1] != _mineralMiningChance, "This is the current value!"); 
        require(_mineralMiningChance > 0, "Cannot set as 0!");
        apocMineral[_tokenID].mineralChances[1] = _mineralMiningChance;
    }

    /**
     * @dev Change information for the mineralUpgradeChances.
     */
    function setMineralUpgradeChance(uint256 _tokenID, uint256 _mineralUpgradeChance) public authorized {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        require(apocMineral[_tokenID].mineralChances[2] != _mineralUpgradeChance, "This is the current value!"); 
        require(_mineralUpgradeChance > 0, "Cannot set as 0!");
        apocMineral[_tokenID].mineralChances[2] = _mineralUpgradeChance;
    }

    /**
     * @dev Change information for the mineralDepletionChances.
     */
    function setMineralDepletionChance(uint256 _tokenID, uint256 _mineralDepletionChance) public authorized {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        require(apocMineral[_tokenID].mineralChances[3] != _mineralDepletionChance, "This is the current value!"); 
        require(_mineralDepletionChance > 0, "Cannot set as 0!");
        apocMineral[_tokenID].mineralChances[3] = _mineralDepletionChance;
    }

    /**
     * @dev Change information for the mineralName.
     */
    function setMineralName(uint256 _tokenID, string memory _mineralName) public authorized {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        apocMineral[_tokenID].mineralName = _mineralName;
    }

    /**
     * @dev Change information for the mineralDescription.
     */
    function setMineralDescription(uint256 _tokenID, string memory _mineralDescription) public authorized {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        apocMineral[_tokenID].mineralDescription = _mineralDescription;
    }

    /**
     * @dev Change information for the mineralImageLink.
     */
    function setMineralImageLink(uint256 _tokenID, string memory _mineralImageLink) public authorized {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        apocMineral[_tokenID].mineralImageLink = _mineralImageLink;
    }

    /**
     * @dev Get information for the mineralUpgradeMOQ.
     */
    function getMineralUpgradeMOQ(uint256 _tokenID) public view returns (uint256) {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        return apocMineral[_tokenID].mineralUpgradeMOQ;
    }

    /**
     * @dev Get information for the mineralUpgradeCost.
     */
    function getMineralUpgradeCost(uint256 _tokenID) public view returns (uint256) {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        return apocMineral[_tokenID].mineralUpgradeCost;
    }

    /**
     * @dev Get information for the mineralPVPDropChances.
     */
    function getMineralPVPDropChance(uint256 _tokenID) public view returns (uint256) {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        return apocMineral[_tokenID].mineralChances[0];
    }

    /**
     * @dev Get information for the mineralMiningChances.
     */
    function getMineralMiningChance(uint256 _tokenID) public view returns (uint256) {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        return apocMineral[_tokenID].mineralChances[1];
    }

    /**
     * @dev Get information for the mineralUpgradeChances.
     */
    function getMineralUpgradeChance(uint256 _tokenID) public view returns (uint256) {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        return apocMineral[_tokenID].mineralChances[2];
    }

    /**
     * @dev Get information for the mineralDepletionChances.
     */
    function getMineralDepletionChance(uint256 _tokenID) public view returns (uint256) {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        return apocMineral[_tokenID].mineralChances[3];
    }

    /**
     * @dev Get information for the mineralName.
     */
    function getMineralName(uint256 _tokenID) public view returns (string memory) {
        return apocMineral[_tokenID].mineralName;
    }

    /**
     * @dev Get information for the mineralDescription.
     */
    function getMineralDescription(uint256 _tokenID) public view returns (string memory) {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        return apocMineral[_tokenID].mineralDescription;
    }

    /**
     * @dev Get information for the mineralimageLink.
     */
    function getMineralImageLink(uint256 _tokenID) public view returns (string memory) {
        require(_tokenID < apocMineral.length, "This mineral does not exist!"); 
        return apocMineral[_tokenID].mineralImageLink;
    }

    /**
     * @dev Get total minerals types.
     */
    function getTotalMineralTypes() public view returns (uint256) {
        return apocMineral.length;
    }

    // Mint function

    /**
     * @dev Allow owner to mint more for supply.
     */
    function mint(address account, uint256 id, uint256 amount, bytes memory data) public authorized {
        require(id < apocMineral.length, "This mineral does not exist!");
        _mint(account, id, amount, data);
    }

    /**
     * @dev Allow owner to mint more for supply in batch.
     */
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public authorized {
        _mintBatch(to, ids, amounts, data);
    }

    // Required for ERC standard

    /**
     * @dev Override function for viewing URI.
     */
    function uri(uint256 tokenID) override public view returns (string memory) {
        return string(abi.encodePacked(_uri, Strings.toString(tokenID), uriExtension));
    }

    /**
     * @dev Override internal function for beforeTokenTransfer from ERC1155 and ERC1155Supply.
     */
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
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
    uint256 public hpRequireBase;

    uint256 public hpRecovery;
    uint256 public durationHPRecover;
    uint256 public xpGain;
    uint256 public enduranceDeduction;

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
        baseNextXP = 1000;
        addDef = 3;

        hpRequireBase = 250;
        xpGain = 100;
        enduranceDeduction = 10;
        hpRecovery = 1;
        durationHPRecover = 36;

        baseWinningRate = [90,89,88,87,86,85,84,83,82,81,80,79,78,77,76,75,74,73,72,71,70,69,68,67,66,65,64,63,62,61,60,59,58,57,56,55,54,53,52,51,50,49,48,47,46,45,44,43,42,41];
    }


    /** EVENT **/
    event ChangeRewardToken(address caller, address prevRewardToken, address newRewardToken);
    event ChangeRandomizer(address caller, address prevRandomizer, address newRandomizer);
    event ChangeRewardPool(address caller, address prevRewardPool, address newRewardPool);
    event FightWon(address winner);
    event FightLost(address loser);


    /** FUNCTION **/  

    /* General functions */

    receive() external payable {}
 
    function withdrawAllTokens(IERC20Extended _token, address beneficiary) public onlyOwner {
        require(IERC20Extended(_token).transfer(beneficiary, IERC20Extended(_token).balanceOf(address(this))));
    }

    function withdrawAllNative(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }

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

    function setDefaultInfo(uint256 _maxLevel, uint256 _hpRequireBase, uint256 _baseHP, uint256 _upgradeBaseHP, uint256 _baseNextXP, uint256 _addDef) public onlyOwner {
        require(_maxLevel > 0 && _hpRequireBase > 0 && _baseHP > 0 && _upgradeBaseHP > 0 && _baseNextXP > 0 && _addDef > 0, "None of the value can be set as 0.");
        maxLevel = _maxLevel;
        hpRequireBase = _hpRequireBase;
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
        require(_characterLevel > 0 && _baseWinningRate > 0, "Character level and base winning rate cannot be set as 0.");
        require(_characterLevel <= maxLevel, "Character level should be lesser or equal to max level.");
        baseWinningRate[_characterLevel - 1] = _baseWinningRate;
    }
    
    function updateGameLogic(uint256 _enduranceDeduction, uint256 _xpGain, uint256 _hpRecovery, uint256 _durationHPRecover) public onlyOwner {
        require(_enduranceDeduction > 0 && _xpGain > 0 && _durationHPRecover > 0 && _hpRecovery > 0, "None of the value can be set as 0.");
        enduranceDeduction = _enduranceDeduction;
        xpGain = _xpGain;
        durationHPRecover = _durationHPRecover;
        hpRecovery = _hpRecovery;
    }

    function recoverHP(uint256 _slot) public whenNotPaused {

        if (_slot == 1) {
            uint256 duration = block.timestamp.sub(charSlot[_msgSender()].lastHPUpdate1);
            uint256 recover = duration.mul(hpRecovery).div(durationHPRecover);
            apocCharacter.recoverHP(charSlot[_msgSender()].tokenID1, recover);
            charSlot[_msgSender()].lastHPUpdate1 = block.timestamp;
        } else if (_slot == 2) {
            uint256 duration = block.timestamp.sub(charSlot[_msgSender()].lastHPUpdate2);
            uint256 recover = duration.mul(hpRecovery).div(durationHPRecover);
            apocCharacter.recoverHP(charSlot[_msgSender()].tokenID2, recover);
            charSlot[_msgSender()].lastHPUpdate2 = block.timestamp;
        }
    }

    /* Check functions */

    function getSuccessRate(uint256 _tokenID, uint256 _weaponAttack) public view returns(uint256) {
        uint256 success = baseWinningRate[apocCharacter.getCharLevel(_tokenID).sub(1)].mul(100);
        uint256 failure = uint256(100).mul(100).sub(success);
        uint256 totalAttack = apocCharacter.getBaseAttack(_tokenID).add(apocCharacter.getAngelModifier(_tokenID)).add(_weaponAttack);
        return success.add(totalAttack.mul(failure).div(200));
    }

    function getHPRequired(uint256 _tokenID) public view returns(uint256) {
        return (apocCharacter.getCharLevel(_tokenID).sub(1)).mul(10).add(hpRequireBase);
    }

    function mixer(uint256 _charTokenID) internal view returns (uint256) {
        uint256 userAddress = uint256(uint160(_msgSender()));
        uint256 random = randomizer.randomNGenerator(userAddress, block.timestamp, block.number);
        return randomizer.sliceNumber(random, 10, 4, apocCharacter.getCharLevel(_charTokenID));
    }

    function checkFight(uint256 _charTokenID, uint256 _charWeaponID, uint256 _rand) internal view returns (bool) {
        if (
            apocCharacter.getCharType(_charTokenID) == 0 &&
            getSuccessRate(_charTokenID, apocWeapon.getBaseAttack(_charWeaponID)) >= _rand
        ) {
            return true;
        } else if (
            apocCharacter.getCharType(_charTokenID) == 1 &&
            getSuccessRate(_charTokenID, apocWand.getBaseAttack(_charWeaponID)) >= _rand
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
            _slot == 1
        ) {
            recoverHP(1);
        } else if (
            apocCharacter.getCharStatus(charSlot[_msgSender()].tokenID1) > 1 &&
            apocCharacter.getCharHP(charSlot[_msgSender()].tokenID1) < apocCharacter.getUpgradeBaseHP() &&
            _slot == 1
        ) {
            recoverHP(1);
        } else if (
            apocCharacter.getCharStatus(charSlot[_msgSender()].tokenID2) <= 1 &&
            apocCharacter.getCharHP(charSlot[_msgSender()].tokenID2) < apocCharacter.getBaseHP() &&
            _slot == 2
        ) {
            recoverHP(2);
        } else if (
            apocCharacter.getCharStatus(charSlot[_msgSender()].tokenID2) > 1 &&
            apocCharacter.getCharHP(charSlot[_msgSender()].tokenID2) < apocCharacter.getUpgradeBaseHP() &&
            _slot == 2
        ) {
            recoverHP(2);
        }
    }

    function checkShieldEquip(uint256 _tokenID) internal {
        if(
            apocShield.getShieldEquip(_tokenID) == true && 
            charSlot[_msgSender()].shieldID1 != _tokenID &&
            charSlot[_msgSender()].shieldID2 != _tokenID
        ) {
            apocShield.updateShieldEquip(_tokenID, false);
        }

        apocShield.updateShieldEquip(_tokenID, true);
    }

    function checkWandEquip(uint256 _tokenID) internal {
        if(
            apocWand.getWandEquip(_tokenID) == true && 
            charSlot[_msgSender()].weaponID1 != _tokenID &&
            charSlot[_msgSender()].weaponID2 != _tokenID
        ) {
            apocWand.updateWandEquip(_tokenID, false);
        }

        apocWand.updateWandEquip(_tokenID, true);
    }

    function checkWeaponEquip(uint256 _tokenID) internal {
        if(
            apocWeapon.getWeaponEquip(_tokenID) == true && 
            charSlot[_msgSender()].weaponID1 != _tokenID &&
            charSlot[_msgSender()].weaponID2 != _tokenID
        ) {
            apocWeapon.updateWeaponEquip(_tokenID, false);
        }

        apocWeapon.updateWeaponEquip(_tokenID, true);
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

    function canFight(uint256 _getCharacterID, uint256 _getWeaponID, uint256 _getShieldID) internal view returns (bool) {
        require(
            apocCharacter.ownerOf(_getCharacterID) == _msgSender() &&
            apocCharacter.getCharHP(_getCharacterID) > getHPRequired(_getCharacterID) &&
            apocCharacter.getCharEquip(_getCharacterID) == true &&
            apocCharacter.getCharXP(_getCharacterID) != apocCharacter.getCharNextXP(_getCharacterID) &&
            apocShield.ownerOf(_getShieldID) == _msgSender() &&
            apocShield.getShieldEquip(_getShieldID) == true &&
            apocShield.getShieldEndurance(_getShieldID) > 0
        );
        if (apocCharacter.getCharType(_getCharacterID) == 0) {
            require(
                apocWeapon.ownerOf(_getWeaponID) == _msgSender() &&
                apocWeapon.getWeaponEquip(_getWeaponID) == true &&
                apocWeapon.getWeaponEndurance(_getWeaponID) > 0
            );
        } else if (apocCharacter.getCharType(_getCharacterID) == 1) {
            require(
                apocWand.ownerOf(_getWeaponID) == _msgSender() &&
                apocWand.getWandEquip(_getWeaponID) == true &&
                apocWand.getWandEndurance(_getWeaponID) > 0
            );
        }
        return true;
    }

    /* Equip functions */

    function equipCharSlot1(uint256 _tokenID) external whenNotPaused {
        if(_msgSender() != owner()) {
            require(_tokenID > 0);
        }
        require(apocCharacter.ownerOf(_tokenID) == _msgSender());

        checkCharacterEquip(_tokenID);

        if (charSlot[_msgSender()].lastHPUpdate1 == 0) {
            checkHPRecovery(1);
        }
        charSlot[_msgSender()].tokenID1 = _tokenID;
        charSlot[_msgSender()].lastHPUpdate1 = block.timestamp;
    }

    function equipCharSlot2(uint256 _tokenID) external whenNotPaused {
        if(_msgSender() != owner()) {
            require(_tokenID > 0);
        }
        require(apocCharacter.ownerOf(_tokenID) == _msgSender());

        checkCharacterEquip(_tokenID);

        if (charSlot[_msgSender()].lastHPUpdate2 == 0) {
            checkHPRecovery(2);
        }
        charSlot[_msgSender()].tokenID2 = _tokenID;
        charSlot[_msgSender()].lastHPUpdate2 = block.timestamp;
    }

    function equipWeaponWandSlot1(uint256 _tokenID) external whenNotPaused {
        if(_msgSender() != owner()) {
            require(_tokenID > 0);
        }

        if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID1) == 0) {
            require(
                apocWeapon.ownerOf(_tokenID) == _msgSender() &&
                apocWeapon.getWeaponType(_tokenID) == apocCharacter.getCharSkill(charSlot[_msgSender()].tokenID1) &&
                apocWeapon.getWeaponEndurance(_tokenID) > 0
            );

            checkWeaponEquip(_tokenID);
            
            charSlot[_msgSender()].weaponID1 = _tokenID;
        } else if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID1) == 1) {
            require(
                apocWand.ownerOf(_tokenID) == _msgSender() &&
                apocWand.getWandType(_tokenID) == apocCharacter.getCharSkill(charSlot[_msgSender()].tokenID1) &&
                apocWand.getWandEndurance(_tokenID) > 0
            );

            checkWandEquip(_tokenID);
            
            charSlot[_msgSender()].weaponID1 = _tokenID;
        }
    }

    function equipWeaponWandSlot2(uint256 _tokenID) external whenNotPaused {
        if(_msgSender() != owner()) {
            require(_tokenID > 0);
        }

        if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID2) == 0) {
            require(
                apocWeapon.ownerOf(_tokenID) == _msgSender() &&
                apocWeapon.getWeaponType(_tokenID) == apocCharacter.getCharSkill(charSlot[_msgSender()].tokenID2) &&
                apocWeapon.getWeaponEndurance(_tokenID) > 0
            );

            checkWeaponEquip(_tokenID);
            
            charSlot[_msgSender()].weaponID2 = _tokenID;
        } else if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID2) == 1) {
            require(
                apocWand.ownerOf(_tokenID) == _msgSender() &&
                apocWand.getWandType(_tokenID) == apocCharacter.getCharSkill(charSlot[_msgSender()].tokenID2) &&
                apocWand.getWandEndurance(_tokenID) > 0
            );

            checkWandEquip(_tokenID);
            
            charSlot[_msgSender()].weaponID2 = _tokenID;
        }
    }

    function equipShieldSlot1(uint256 _tokenID) external whenNotPaused {
        if(_msgSender() != owner()) {
            require(_tokenID > 0);
        }
        require(
            apocShield.ownerOf(_tokenID) == _msgSender() &&
            apocShield.getShieldEndurance(_tokenID) > 0
        );
        
        checkShieldEquip(_tokenID);

        charSlot[_msgSender()].shieldID1 = _tokenID;
    }

    function equipShieldSlot2(uint256 _tokenID) external whenNotPaused {
        if(_msgSender() != owner()) {
            require(_tokenID > 0);
        }
        require(
            apocShield.ownerOf(_tokenID) == _msgSender() &&
            apocShield.getShieldEndurance(_tokenID) > 0
        );

        checkShieldEquip(_tokenID);

        charSlot[_msgSender()].shieldID2 = _tokenID;
    }

    /* Unequip functions */

    function unequipCharSlot1() public whenNotPaused {
        checkHPRecovery(1);
        apocCharacter.updateCharacterEquip(charSlot[_msgSender()].tokenID1, false);
        charSlot[_msgSender()].tokenID1 = 0;
    }

    function unequipCharSlot2() public whenNotPaused {
        checkHPRecovery(2);
        apocCharacter.updateCharacterEquip(charSlot[_msgSender()].tokenID2, false);
        charSlot[_msgSender()].tokenID2 = 0;
    }

    function unequipWeaponWandSlot1() public whenNotPaused {
        if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID1) == 0 && apocWeapon.ownerOf(charSlot[_msgSender()].weaponID1) != _msgSender()) {
            apocWand.updateWandEquip(charSlot[_msgSender()].weaponID1, false);
        } else if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID1) == 0) {
            apocWeapon.updateWeaponEquip(charSlot[_msgSender()].weaponID1, false);
        } else if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID1) == 1 && apocWand.ownerOf(charSlot[_msgSender()].weaponID1) != _msgSender()) {
            apocWeapon.updateWeaponEquip(charSlot[_msgSender()].weaponID1, false);
        } else if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID1) == 1) {
            apocWand.updateWandEquip(charSlot[_msgSender()].weaponID1, false);
        }

        charSlot[_msgSender()].weaponID1 = 0;
    }

    function unequipWeaponWandSlot2() public whenNotPaused {
        if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID2) == 0 && apocWeapon.ownerOf(charSlot[_msgSender()].weaponID2) != _msgSender()) {
            apocWand.updateWandEquip(charSlot[_msgSender()].weaponID2, false);
        } else if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID2) == 0) {
            apocWeapon.updateWeaponEquip(charSlot[_msgSender()].weaponID2, false);
        } else if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID2) == 0 && apocWeapon.ownerOf(charSlot[_msgSender()].weaponID2) != _msgSender()) {
            apocWeapon.updateWeaponEquip(charSlot[_msgSender()].weaponID2, false);
        } else if (apocCharacter.getCharType(charSlot[_msgSender()].tokenID2) == 1) {
            apocWand.updateWandEquip(charSlot[_msgSender()].weaponID2, false);
        }
        
        charSlot[_msgSender()].weaponID2 = 0;
    }

    function unequipShieldSlot1() public whenNotPaused {
        apocShield.updateShieldEquip(charSlot[_msgSender()].shieldID1, false);
        charSlot[_msgSender()].shieldID1 = 0;
    }

    function unequipShieldSlot2() public whenNotPaused {
        apocShield.updateShieldEquip(charSlot[_msgSender()].shieldID2, false);
        charSlot[_msgSender()].shieldID2 = 0;
    }

    function forceUnequipSlot1() public whenNotPaused {
        charSlot[_msgSender()].tokenID1 = 0;
        charSlot[_msgSender()].weaponID1 = 0;
        charSlot[_msgSender()].shieldID1 = 0;
    }

    function forceUnequipSlot2() public whenNotPaused {
        charSlot[_msgSender()].tokenID2 = 0;
        charSlot[_msgSender()].weaponID2 = 0;
        charSlot[_msgSender()].shieldID2 = 0;
    }

    /* Fight functions */
    
    function updateCharacter(bool fightStatus, uint256 tokenId, uint256 shieldID, address account) internal {
        if (fightStatus == true) {
            uint256 totalDefence = apocCharacter.getBaseDefence(tokenId).add(apocCharacter.getAngelModifier(tokenId)).add(apocShield.getBaseDefence(shieldID));
            uint256 _reduceHP = getHPRequired(tokenId).sub(totalDefence);
            apocCharacter.reduceHP(tokenId, _reduceHP);
            apocCharacter.receiveXP(tokenId, xpGain);
            distributor.distributeReward(_msgSender(), apocCharacter.getCharLevel(tokenId).mul(10**rewardToken.decimals()));

            emit FightWon(account);
        } else if (fightStatus == false) {
            apocCharacter.reduceHP(tokenId, getHPRequired(tokenId));
            emit FightLost(account);
        }
    }

    function reduceWeaponWandEndurance(uint256 _charTokenID, uint256 _charWeaponID) internal {
        if (apocCharacter.getCharType(_charTokenID) == 0) {
            apocWeapon.reduceEndurance(_charWeaponID, enduranceDeduction);
        } else if (apocCharacter.getCharType(_charTokenID) == 1) {
            apocWand.reduceEndurance(_charWeaponID, enduranceDeduction);
        }
    }

    function fightSlot1() public whenNotPaused returns (bool){
        
        checkHPRecovery(1);

        uint256 _charTokenID = charSlot[_msgSender()].tokenID1;
        uint256 _charWeaponID = charSlot[_msgSender()].weaponID1;
        uint256 _charShieldID = charSlot[_msgSender()].shieldID1;

        if (_msgSender() != owner()) {
            require(_charTokenID != 0 && _charWeaponID != 0 && _charShieldID != 0);
        }

        require(canFight(_charTokenID, _charWeaponID, _charShieldID) == true);
        
        apocShield.reduceEndurance(_charShieldID, enduranceDeduction);

        reduceWeaponWandEndurance(_charTokenID, _charWeaponID);

        uint256 rand = mixer(_charTokenID);

        bool fightStatus = checkFight(_charTokenID, _charWeaponID, rand);

        updateCharacter(fightStatus, charSlot[_msgSender()].tokenID1, _charShieldID, _msgSender());

        return (fightStatus);

    }

    function fightSlot2() public whenNotPaused returns (bool){

        checkHPRecovery(2);

        uint256 _charTokenID = charSlot[_msgSender()].tokenID2;
        uint256 _charWeaponID = charSlot[_msgSender()].weaponID2;
        uint256 _charShieldID = charSlot[_msgSender()].shieldID2;

        if (_msgSender() != owner()) {
            require(_charTokenID != 0 && _charWeaponID != 0 && _charShieldID != 0);
        }

        require(canFight(_charTokenID, _charWeaponID, _charShieldID) == true);
        
        apocShield.reduceEndurance(_charShieldID, enduranceDeduction);

        reduceWeaponWandEndurance(_charTokenID, _charWeaponID);

        uint256 rand = mixer(_charTokenID);

        bool fightStatus = checkFight(_charTokenID, _charWeaponID, rand);

        updateCharacter(fightStatus, charSlot[_msgSender()].tokenID2, _charShieldID, _msgSender());

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

    ApocalypseRandomizer public randomizer;
    ApocalypseCharacter public apocCharacter;
    ApocalypseWeapon public apocWeapon;
    ApocalypseWand public apocWand;
    ApocalypseShield public apocShield;

    IERC20Extended public rewardToken;

    IERC20Extended public recoverToken;
    IERC20Extended[3] public repairToken; // weapon, wand, shield
    IERC20Extended[4] public levelUpToken; // character, weapon, wand, shield
    IERC20Extended[4] public mintToken; // character, weapon, wand, shield
    IERC20Extended[4] public upgradeToken; // character, weapon, wand, shield

    
    uint256[2] public xpGain; // perFight, perLevel
    uint256[2] public charLevelUpTax; // numerator, denominator
    uint256[3] public charRecoverFee; // numerator, denominator, recover
    uint256[3] public repairBUSDPrice; // weapon, wand, shield
    uint256[3] public levelUpBUSDPrice; // weapon, wand, shield
    uint256[4] public mintBUSDPrice; // character, weapon, wand, shield
    uint256[4] public upgradeBUSDPrice; // character, weapon, wand, shield
    uint256[4] public maxUpgradeStatus; // character, weapon, wand, shield


    /** CONSTRUCTOR **/
    constructor(
        IERC20Extended _rewardToken,
        IERC20Extended _rvzToken,
        IERC20Extended _apocToken,
        IERC20Extended _lznToken,
        IUniswapV2Router02 _router,
        ApocalypseRandomizer _randomizer,
        ApocalypseCharacter _apocCharacter,
        ApocalypseWeapon _apocWeapon,
        ApocalypseWand _apocWand,
        ApocalypseShield _apocShield
    ) {
        
        xpGain = [100, 1000];
        charLevelUpTax = [25, 100];
        charRecoverFee = [50, 100, 100];
        maxUpgradeStatus = [2, 0, 0, 0];

        router = _router;

        randomizer = _randomizer;
        apocCharacter = _apocCharacter;
        apocWeapon = _apocWeapon;
        apocWand = _apocWand;
        apocShield = _apocShield;

        rewardToken = _rewardToken;
        recoverToken = _lznToken;
        repairToken = [_apocToken, _apocToken, _apocToken];
        levelUpToken = [_apocToken, _apocToken, _apocToken, _apocToken];
        mintToken = [_rvzToken, _apocToken, _apocToken, _apocToken];
        upgradeToken = [_apocToken, _apocToken, _apocToken, _apocToken];

        repairBUSDPrice = [5000000000000000000, 5000000000000000000, 5000000000000000000];
        
        levelUpBUSDPrice = [10000000000000000000, 10000000000000000000, 10000000000000000000];

        mintBUSDPrice = [100000000000000000000, 30000000000000000000, 30000000000000000000, 50000000000000000000];

        upgradeBUSDPrice = [10000000000000000000, 0, 0, 0];
        
    }


    /** EVENT **/
    event UpdatePrice(address caller, uint256 index, uint256 prevPrice, uint256 newPrice, string category);
    event Repair(address caller, uint256 tokenID, string category);
    event LevelUp(address caller, uint256 tokenID, string category);
    event LevelUpFail(address caller, uint256 tokenID, string category);
    event LevelUpFailAndBurn(address caller, uint256 tokenID, string category);


    /** FUNCTION **/

    /* General functions */

    receive() external payable {}
 
    function withdrawTokens(IERC20Extended _token, address beneficiary) public onlyOwner {
        require(IERC20Extended(_token).transfer(beneficiary, IERC20Extended(_token).balanceOf(address(this))));
    }

    function withdrawNative(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }

    function pause() public whenNotPaused authorized {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }

    /* Respective contract functions */

    function changeRouter(IUniswapV2Router02 _router) public authorized {
        router = _router;
    }

    function changeRandomizer(ApocalypseRandomizer _randomizer) public authorized {
        randomizer = _randomizer;
    }

    function changeRewardToken(IERC20Extended _rewardToken) public authorized {
        rewardToken = _rewardToken;
    }

    function changeRecoverToken(IERC20Extended _recoverToken) public authorized {
        recoverToken = _recoverToken;
    }

    function changeRepairToken(uint256 _index, IERC20Extended _repairToken) public authorized {
        require(_index < repairToken.length, "Index cannot be out of array size.");
        repairToken[_index] = _repairToken;
    }

    function changeLevelUpToken(uint256 _index, IERC20Extended _levelUpToken) public authorized {
        require(_index < levelUpToken.length, "Index cannot be out of array size.");
        levelUpToken[_index] = _levelUpToken;
    }

    function changeMintToken(uint256 _index, IERC20Extended _mintToken) public authorized {
        require(_index < mintToken.length, "Index cannot be out of array size.");
        mintToken[_index] = _mintToken;
    }

    function changeUpgradeToken(uint256 _index, IERC20Extended _upgradeToken) public authorized {
        require(_index < upgradeToken.length, "Index cannot be out of array size.");
        upgradeToken[_index] = _upgradeToken;
    }

    /* Default functions */

    function updateMaxUpgradeStatus(uint256 _index, uint256 _maxUpgradeStatus) public authorized {
        require(_maxUpgradeStatus > 0, "Maximum upgrade status cannot be 0.");
        require(_index < maxUpgradeStatus.length, "Index cannot be out of array size.");
        maxUpgradeStatus[_index] = _maxUpgradeStatus;
    }

    function updateCharRecoverFee(uint256 _numerator, uint256 _denominator, uint256 _recover) public authorized {
        require(_numerator <= _denominator.div(100).mul(50), "Fee cannot exceed 50%.");
        require(_recover > 0, "HP recover cannot be 0.");
        charRecoverFee = [_numerator, _denominator, _recover];
    }

    function updateCharLevelUpTax(uint256 _numerator, uint256 _denominator) public authorized {
        require(_numerator <= _denominator.div(100).mul(25), "Tax cannot exceed 25%.");
        charLevelUpTax = [_numerator, _denominator];
    }

    function updateXPGain(uint256 _perFight, uint256 _perLevel) public authorized {
        require(_perFight > 0, "XP gained per fight need cannot be 0.");
        require(_perLevel >= 1000, "XP gained per level must be at least 1000.");
        xpGain = [_perFight, _perLevel];
    }

    /* Check functions */

    function checkPrice(uint256 _priceBUSD, IERC20Extended _token) public view returns (uint256) {
        address[] memory path = new address[](3);
        path[0] = address(_token);
        path[1] = router.WETH();
        path[2] = address(rewardToken);
        return router.getAmountsIn(_priceBUSD, path)[0];
    }

    function mixer(address _caller, uint256 _upChance, uint256 _depletion) public view returns (uint256, uint256) {
        uint256 ratio1 = _upChance.div(_depletion);
        uint256 ratio2 = _depletion.div(_upChance);
        uint256 targetBlock = block.number + ratio1;
        uint256 random = randomizer.randomNGenerator(uint256(uint160(_caller)), block.timestamp, targetBlock);
        uint256 checkLevelUp = randomizer.sliceNumber(random, 10, 2, ratio1);
        uint256 checkBurn = randomizer.sliceNumber(random, 10, 2, ratio2);
        return (checkLevelUp, checkBurn);
    }

    /* Recover HP functions */

    function recoverHP(uint256 _tokenID) external whenNotPaused {
        uint256 fee = apocCharacter.getCharLevel(_tokenID).mul(charRecoverFee[0]).div(charRecoverFee[1]);
        recoverToken.transferFrom(_msgSender(), address(this), checkPrice(fee.mul(10**18), recoverToken));
        apocCharacter.recoverHP(_tokenID, charRecoverFee[2]);
    }

    /* Repair NFT functions */

    function updateRepairPrice(uint256 _index, uint256 _repairPrice) public authorized {
        require(_index < repairBUSDPrice.length, "Index cannot be out of array size.");
        require(_repairPrice > uint256(0), "Price cannot be 0.");
        uint256 prevRepairPrice = repairBUSDPrice[_index];
        repairBUSDPrice[_index] = _repairPrice;
        emit UpdatePrice(_msgSender(), _index, prevRepairPrice, _repairPrice, "Repair");
    }

    function repairWeapon(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocWeapon.ownerOf(_tokenID), "You are not the owner of this weapon.");

        repairToken[0].transferFrom(_msgSender(), address(this), checkPrice(repairBUSDPrice[0], repairToken[0]));

        uint256 status = apocWeapon.getWeaponStatus(_tokenID);
        
        uint256 _recoverEndurance;

        if (status == 0) {
            _recoverEndurance = apocWeapon.getRareBaseStat()[0];
        } else if (status == 1) {
            _recoverEndurance = apocWeapon.getCommonBaseStat()[0];
        } else if (status > 1) {
            _recoverEndurance = apocWeapon.getUpgradeBaseStat()[0];
        }

        apocWeapon.recoverEndurance(_tokenID, _recoverEndurance);

        emit Repair(_msgSender(), _tokenID, "Weapon");
    }

    function repairWand(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocWand.ownerOf(_tokenID), "You are not the owner of this wand.");
        
        repairToken[1].transferFrom(_msgSender(), address(this), checkPrice(repairBUSDPrice[1], repairToken[1]));
        
        uint256 status = apocWand.getWandStatus(_tokenID);
        
        uint256 _recoverEndurance;

        if (status == 0) {
            _recoverEndurance = apocWand.getRareBaseStat()[0];
        } else if (status == 1) {
            _recoverEndurance = apocWand.getCommonBaseStat()[0];
        } else if (status > 1) {
            _recoverEndurance = apocWand.getUpgradeBaseStat()[0];
        }

        apocWand.recoverEndurance(_tokenID, _recoverEndurance);
        
        emit Repair(_msgSender(), _tokenID, "Wand");
    }

    function repairShield(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocShield.ownerOf(_tokenID), "You are not the owner of this shield.");

        repairToken[2].transferFrom(_msgSender(), address(this), checkPrice(repairBUSDPrice[2], repairToken[2]));
        
        uint256 status = apocShield.getShieldStatus(_tokenID);
       
        uint256 _recoverEndurance;

        if (status == 0) {
            _recoverEndurance = apocShield.getRareBaseStat()[0];
        } else if (status == 1) {
            _recoverEndurance = apocShield.getCommonBaseStat()[0];
        } else if (status > 1) {
            _recoverEndurance = apocShield.getUpgradeBaseStat()[0];
        }

        apocShield.recoverEndurance(_tokenID, _recoverEndurance);

        emit Repair(_msgSender(), _tokenID, "Shield");
    }

    /* Level up NFT functions */

    function updateLevelUpPrice(uint256 _index, uint256 _levelUpPrice) public authorized {
        require(_index < levelUpBUSDPrice.length, "Index cannot be out of array size.");
        require(_levelUpPrice > uint256(0), "Price cannot be 0.");
        uint256 prevLevelUpPrice = levelUpBUSDPrice[_index];
        levelUpBUSDPrice[_index] = _levelUpPrice;
        emit UpdatePrice(_msgSender(), _index, prevLevelUpPrice, _levelUpPrice, "LevelUp");
    }

    function levelUpCharacter(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocCharacter.ownerOf(_tokenID), "You are not the owner of this character.");
        uint256 rounds = xpGain[1].div(xpGain[0]);
        if (rounds.mul(xpGain[0]) < 1000) {
            rounds += 1;
        }
        
        uint256 fee = rounds.mul(apocCharacter.getCharLevel(_tokenID)).mul(charLevelUpTax[0]).div(charLevelUpTax[1]);
                
        levelUpToken[0].transferFrom(_msgSender(), address(this), checkPrice(fee.mul(10**18), levelUpToken[0]));

        apocCharacter.updateNextXP(_tokenID);
        apocCharacter.levelUp(_tokenID);

        emit LevelUp(_msgSender(), _tokenID, "Character");

    }

    function levelUpWeapon(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocWeapon.ownerOf(_tokenID), "You are not the owner of this weapon.");

        uint256 level = apocWeapon.getWeaponLevel(_tokenID);
        uint256 upChance = apocWeapon.getWeaponUpChance(level);
        uint256 depletion = apocWeapon.getWeaponDepletion(level);
        
        (uint256 checkLevelUp, uint256 checkBurn) = mixer(_msgSender(), upChance, depletion);

        levelUpToken[1].transferFrom(_msgSender(), address(this), checkPrice(levelUpBUSDPrice[0], levelUpToken[1]));

        if (checkLevelUp > upChance && checkBurn <= depletion) {
            apocWeapon._burnLevelUp(_tokenID);
            emit LevelUpFailAndBurn(_msgSender(), _tokenID, "Weapon");
            return;
        } else if (checkLevelUp > upChance && checkBurn > depletion) {
            emit LevelUpFail(_msgSender(), _tokenID, "Weapon");
            return;
        } else {
            apocWeapon.levelUp(_tokenID);
            uint256 weaponLevel = apocWeapon.getWeaponLevel(_tokenID);
            apocWeapon.updateAttack(_tokenID, apocWeapon.getWeaponAttack(weaponLevel));
            emit LevelUp(_msgSender(), _tokenID, "Weapon");
        }   

    }

    function levelUpWand(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocWand.ownerOf(_tokenID), "You are not the owner of this wand.");

        uint256 level = apocWand.getWandLevel(_tokenID);
        uint256 upChance = apocWand.getWandUpChance(level);
        uint256 depletion = apocWand.getWandDepletion(level);
        
        (uint256 checkLevelUp, uint256 checkBurn) = mixer(_msgSender(), upChance, depletion);

        levelUpToken[2].transferFrom(_msgSender(), address(this), checkPrice(levelUpBUSDPrice[1], levelUpToken[2]));

        if (checkLevelUp > upChance && checkBurn <= depletion) {
            apocWand._burnLevelUp(_tokenID);
            emit LevelUpFailAndBurn(_msgSender(), _tokenID, "Wand");
            return;
        } else if (checkLevelUp > upChance && checkBurn > depletion) {
            emit LevelUpFail(_msgSender(), _tokenID, "Wand");
            return;
        } else {
            apocWand.levelUp(_tokenID);
            uint256 wandLevel = apocWand.getWandLevel(_tokenID);
            apocWand.updateAttack(_tokenID, apocWand.getWandAttack(wandLevel));
            emit LevelUp(_msgSender(), _tokenID, "Wand");
        }   
    }

    function levelUpShield(uint256 _tokenID) external whenNotPaused {
        require(_msgSender() == apocShield.ownerOf(_tokenID), "You are not the owner of this shield.");
        
        uint256 level = apocShield.getShieldLevel(_tokenID);
        uint256 upChance = apocShield.getShieldUpChance(level);
        uint256 depletion = apocShield.getShieldDepletion(level);

        (uint256 checkLevelUp, uint256 checkBurn) = mixer(_msgSender(), upChance, depletion);

        levelUpToken[3].transferFrom(_msgSender(), address(this), checkPrice(levelUpBUSDPrice[2], levelUpToken[3]));

        if (checkLevelUp > upChance && checkBurn <= depletion) {
            apocShield._burnLevelUp(_tokenID);
            emit LevelUpFailAndBurn(_msgSender(), _tokenID, "Shield");
            return;
        } else if (checkLevelUp > upChance && checkBurn > depletion) {
            emit LevelUpFail(_msgSender(), _tokenID, "Shield");
            return;
        } else {
            apocShield.levelUp(_tokenID);
            uint256 shieldLevel = apocShield.getShieldLevel(_tokenID);
            apocShield.updateDefence(_tokenID, apocShield.getShieldDefence(shieldLevel));
            emit LevelUp(_msgSender(), _tokenID, "Shield");
        }   
    }

    /* Mint NFT functions */

    function updateMintPrice(uint256 _index, uint256 _mintPrice) public authorized {
        require(_index < mintBUSDPrice.length, "Index cannot be out of array size.");
        require(_mintPrice > uint256(0), "Price cannot be 0.");
        uint256 prevMintPrice = mintBUSDPrice[_index];
        mintBUSDPrice[_index] = _mintPrice;
        emit UpdatePrice(_msgSender(), _index, prevMintPrice, _mintPrice, "Mint");
    }

    function mintCharacter() external whenNotPaused returns (uint256) {
        mintToken[0].transferFrom(_msgSender(), address(this), checkPrice(mintBUSDPrice[0], mintToken[0]));
        return apocCharacter.mintNewCharacter(_msgSender());
    }

    function mintWeapon() external whenNotPaused returns (uint256) {
        mintToken[1].transferFrom(_msgSender(), address(this), checkPrice(mintBUSDPrice[1], mintToken[1]));
        return apocWand.mintNewWand(_msgSender());
    }

    function mintWand() external whenNotPaused returns (uint256) {
        mintToken[2].transferFrom(_msgSender(), address(this), checkPrice(mintBUSDPrice[2], mintToken[2]));
        return apocWeapon.mintNewWeapon(_msgSender());
    }

    function mintShield() external whenNotPaused returns (uint256)  {
        mintToken[3].transferFrom(_msgSender(), address(this), checkPrice(mintBUSDPrice[3], mintToken[3]));
        return apocShield.mintNewShield(_msgSender());
    }

    /* Upgrade NFT functions */

    function updateUpgradePrice(uint256 _index, uint256 _upgradePrice) public authorized {
        require(_index < upgradeBUSDPrice.length, "Index cannot be out of array size.");
        require(_upgradePrice > uint256(0), "Price cannot be 0.");
        uint256 prevUpgradePrice = upgradeBUSDPrice[_index];
        upgradeBUSDPrice[_index] = _upgradePrice;
        emit UpdatePrice(_msgSender(), _index, prevUpgradePrice, _upgradePrice, "Upgrade");
    }

    function upgradeCharacter(uint256 _tokenID1, uint256 _tokenID2) external whenNotPaused returns (bool, uint256) {
        require(_msgSender() == apocCharacter.ownerOf(_tokenID1), "You are not the owner of the first character.");
        require(_msgSender() == apocCharacter.ownerOf(_tokenID2), "You are not the owner of the second character.");
        
        ( , uint256 charStatus1, uint256 charType1, uint256 charSkill1, , , , , , , ) = apocCharacter.apocChar(_tokenID1);
        ( , uint256 charStatus2, uint256 charType2, uint256 charSkill2, , , , , , , ) = apocCharacter.apocChar(_tokenID2);
        
        require(
            charStatus1 == charStatus2 && charType1 == charType2 && charSkill1 == charSkill2,
            "You need characters with the exact same skill, type and status."
        );
        require (charStatus1.add(1) < maxUpgradeStatus[0], "You have reach the max upgrade allowed for first character.");
        require (charStatus2.add(1) < maxUpgradeStatus[0], "You have reach the max upgrade allowed for second character.");

        uint256 _nextStatus = charStatus1.add(1);

        upgradeToken[0].transferFrom(_msgSender(), address(this), checkPrice(upgradeBUSDPrice[0], upgradeToken[0]));

        return apocCharacter.upgradeCharacter(_msgSender(), _tokenID1, _tokenID2, _nextStatus);
    }

    function upgradeWeapon(uint256 _tokenID1, uint256 _tokenID2) external whenNotPaused returns (bool, uint256) {
        require(_msgSender() == apocWeapon.ownerOf(_tokenID1), "You are not the owner of the first weapon.");
        require(_msgSender() == apocWeapon.ownerOf(_tokenID2), "You are not the owner of the second weapon.");
        
        ( , , uint256 weaponStatus1, uint256 weaponType1, , , ) = apocWeapon.apocWeapon(_tokenID1);
        ( , , uint256 weaponStatus2, uint256 weaponType2, , , ) = apocWeapon.apocWeapon(_tokenID2);
        
        require(
            weaponStatus1 == weaponStatus2 && weaponType1 == weaponType2,
            "You need weapons with the exact same type and status."
        );
        require (weaponStatus1.add(1) < maxUpgradeStatus[1], "You have reach the max upgrade allowed for first weapon.");
        require (weaponStatus2.add(1) < maxUpgradeStatus[1], "You have reach the max upgrade allowed for second weapon.");

        upgradeToken[1].transferFrom(_msgSender(), address(this), checkPrice(upgradeBUSDPrice[1], upgradeToken[1]));

        return apocWeapon.upgradeWeapon(_msgSender(), _tokenID1, _tokenID2);
    }

    function upgradeWand(uint256 _tokenID1, uint256 _tokenID2) external whenNotPaused returns (bool, uint256) {
        require(_msgSender() == apocWand.ownerOf(_tokenID1), "You are not the owner of the first wand.");
        require(_msgSender() == apocWand.ownerOf(_tokenID2), "You are not the owner of the second wand.");
        
        ( , , uint256 wandStatus1, uint256 wandType1, , , ) = apocWand.apocWand(_tokenID1);
        ( , , uint256 wandStatus2, uint256 wandType2, , , ) = apocWand.apocWand(_tokenID2);
        
        require(
            wandStatus1 == wandStatus2 && wandType1 == wandType2,
            "You need wands with the exact same type and status."
        );
        require (wandStatus1.add(1) < maxUpgradeStatus[2], "You have reach the max upgrade allowed for first wand.");
        require (wandStatus2.add(1) < maxUpgradeStatus[2], "You have reach the max upgrade allowed for second wand.");

        upgradeToken[2].transferFrom(_msgSender(), address(this), checkPrice(upgradeBUSDPrice[2], upgradeToken[2]));

        return apocWand.upgradeWand(_msgSender(), _tokenID1, _tokenID2);
    }

    function upgradeShield(uint256 _tokenID1, uint256 _tokenID2) external whenNotPaused returns (bool, uint256) {
        require(_msgSender() == apocShield.ownerOf(_tokenID1), "You are not the owner of the first shield.");
        require(_msgSender() == apocShield.ownerOf(_tokenID2), "You are not the owner of the second shield.");
        
        ( , , uint256 shieldStatus1, uint256 shieldType1, , , ) = apocShield.apocShield(_tokenID1);
        ( , , uint256 shieldStatus2, uint256 shieldType2, , , ) = apocShield.apocShield(_tokenID2);
        
        require(
            shieldStatus1 == shieldStatus2 && shieldType1 == shieldType2,
            "You need shields with the exact same type and status."
        );
        require (shieldStatus1.add(1) < maxUpgradeStatus[3], "You have reach the max upgrade allowed for first shield.");
        require (shieldStatus2.add(1) < maxUpgradeStatus[3], "You have reach the max upgrade allowed for second shield.");

        upgradeToken[3].transferFrom(_msgSender(), address(this), checkPrice(upgradeBUSDPrice[3], upgradeToken[3]));

        return apocShield.upgradeShield(_msgSender(), _tokenID1, _tokenID2);
    }

}

contract ApocalypsePvP is Pausable, Auth, ReentrancyGuard {

    /** LIBRARY **/
    using SafeMath for uint256;
    using Address for address;
    using Strings for string;
    using Counters for Counters.Counter;


    /** DATA **/

    IUniswapV2Router02 public router;

    RewardPoolDistributor public distributor;
    
    ApocalypseRandomizer public randomizer;
    ApocalypseCharacter public apocCharacter;
    ApocalypseMineral public apocMineral;

    IERC20Extended public rewardToken;
    IERC20Extended public peggedToken;

    Counters.Counter public _pvpID;

    struct pvpInfo {
        uint256 pvpID;
        uint256 amountToStake;
        uint256 charIDP1;
        uint256 charIDP2;
        bool fight;
        address payable player1;
        address payable player2;
    }

    uint256 public minStake;
    uint256 public statusOffset;
    uint256 public dropNumber;
    uint256 public dropOffset;
    uint256 public dropNumerator;
    uint256 public dropDenominatorBase;
    uint256 public rewardTaxNumerator;
    uint256 public rewardTaxDenominator;

    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public ZERO = 0x0000000000000000000000000000000000000000;

    mapping(uint256 => pvpInfo) public idToPvPInfo;
    mapping(address => uint256) public fightLost;
    mapping(address => uint256) public fightWon;


    /** CONSTRUCTOR **/

    constructor(
        IUniswapV2Router02 _router,
        IERC20Extended _rewardToken,
        IERC20Extended _peggedToken,
        ApocalypseRandomizer _randomizer,
        ApocalypseCharacter _apocCharacter,
        ApocalypseMineral _apocMineral,
        RewardPoolDistributor _distributor
    ) {
        router = _router;
        rewardToken = _rewardToken; 
        peggedToken = _peggedToken;
        randomizer = _randomizer;
        apocCharacter = _apocCharacter;
        apocMineral = _apocMineral;
        distributor = _distributor;

        minStake = 1000000000000000000;
        statusOffset = 21;
        dropNumber = 25;
        dropOffset = 3;
        dropNumerator = 30;
        dropDenominatorBase = 2;
        rewardTaxNumerator = 20;
        rewardTaxDenominator = 100;
    }


    /** EVENT **/
    event ChangeRewardToken(address caller, address prevRewardToken, address newRewardToken);
    event ChangePeggedToken(address caller, address prevPeggedToken, address newPeggedToken);
    event ChangeRandomizer(address caller, address prevRandomizer, address newRandomizer);
    event ChangeApocalypseCharacter(address caller, address prevApocalypseCharacter, address newApocalypseCharacter);
    event ChangeApocalypseMineral(address caller, address prevApocalypseMineral, address newApocalypseMineral);
    event ChangeDistributor(address caller, address prevDistributor, address newDistributor);
    event ChangeRouter(address caller, address prevRouter, address newRouter);
    event PvPCompleted(uint256 idPvP, address winner, address loser);
    event CreatePvPRoom(uint256 idPvP, address player1, uint256 stakeAmount);
    event JoinPvPRoom(uint256 idPvP, address player2, uint256 stakeAmount);


    /** FUNCTION **/  

    /* General functions */

    receive() external payable {}
    
    function pause() public whenNotPaused authorized {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }

    function burnAllTokens(IERC20Extended _token) public onlyOwner {
        require(IERC20Extended(_token).transfer(DEAD, IERC20Extended(_token).balanceOf(address(this))));
    }

    function burnPartialTokens(IERC20Extended _token, uint256 _numerator, uint256 _denominator) public onlyOwner {
        uint256 amount = IERC20Extended(_token).balanceOf(address(this)).mul(_numerator).div(_denominator);
        require(IERC20Extended(_token).transfer(DEAD, amount));
    }

    function poolAllTokens(IERC20Extended _token) public onlyOwner {
        
        address[] memory path1 = new address[](2);
        path1[0] = address(_token);
        path1[1] = router.WETH();
        
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            IERC20Extended(_token).balanceOf(address(this)),
            0,
            path1,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        address[] memory path2 = new address[](2);
        path2[0] = router.WETH();
        path2[1] = address(peggedToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens {
            value: amountBNB
        } (0, path2, address(this), block.timestamp);
        
        require(IERC20Extended(peggedToken).transfer(address(distributor), IERC20Extended(peggedToken).balanceOf(address(this))));
    }

    function poolPartialTokens(IERC20Extended _token, uint256 _numerator, uint256 _denominator) public onlyOwner {
         
        uint256 amount = IERC20Extended(_token).balanceOf(address(this)).mul(_numerator).div(_denominator);

        address[] memory path1 = new address[](2);
        path1[0] = address(_token);
        path1[1] = router.WETH();
        
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path1,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        address[] memory path2 = new address[](2);
        path2[0] = router.WETH();
        path2[1] = address(peggedToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens {
            value: amountBNB
        } (0, path2, address(this), block.timestamp);

        require(IERC20Extended(peggedToken).transfer(address(distributor), IERC20Extended(peggedToken).balanceOf(address(this))));
    }

    function withdrawTokens(IERC20Extended _token, address beneficiary) public onlyOwner {
        require(IERC20Extended(_token).transfer(beneficiary, IERC20Extended(_token).balanceOf(address(this))));
    }

    function withdrawNative(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }

    /* Update functions */

    function updateMinStake(uint256 _minStake) public authorized {
        require(minStake >= 1000000000000000000, "Minimum stake cannot be lower than 1 BUSD worth of the token!");
        require(minStake != _minStake, "This is the current value!");
        minStake = _minStake;
    }

    function updateStatusOffset(uint256 _statusOffset) public authorized {
        require(statusOffset != _statusOffset, "This is the current value!");
        statusOffset = _statusOffset;
    }

    function updateDrop(uint256 _dropNumber, uint256 _dropOffset, uint256 _dropNumerator, uint256 _dropDenominatorBase) public authorized {
        require(dropNumber != _dropNumber, "This is the current value for drop number!");
        require(dropOffset != _dropOffset, "This is the current value for drop offset!");
        require(dropNumerator != _dropNumerator, "This is the current value for drop numerator!");
        require(dropDenominatorBase != _dropDenominatorBase, "This is the current value for drop denominator!");
        dropNumber = _dropNumber;
        dropOffset = _dropOffset;
        dropNumerator = _dropNumerator;
        dropDenominatorBase = _dropDenominatorBase;
    }

    function updateRewardTax(uint256 _rewardTaxNumerator, uint256 _rewardTaxDenominator) public authorized {
        require(_rewardTaxNumerator < _rewardTaxDenominator.mul(40).div(100), "Total tax should not be greater than 40%.");
        rewardTaxNumerator = _rewardTaxNumerator;
        rewardTaxDenominator = _rewardTaxDenominator;
    }

    /* Respective contract functions */

    function changeRewardToken(IERC20Extended _rewardToken) public authorized {
        address prevRewardToken = address(rewardToken);
        rewardToken = _rewardToken;
        emit ChangeRewardToken(_msgSender(), prevRewardToken, address(rewardToken));
    }

    function changePeggedToken(IERC20Extended _peggedToken) public authorized {
        address prevPeggedToken = address(peggedToken);
        peggedToken = _peggedToken;
        emit ChangePeggedToken(_msgSender(), prevPeggedToken, address(peggedToken));
    }

    function changeRandomizer(ApocalypseRandomizer _randomizer) public authorized {
        address prevRandomizer = address(randomizer);
        randomizer = _randomizer;
        emit ChangeRandomizer(_msgSender(), prevRandomizer, address(randomizer));
    }

    function changeApocalypseCharacter(ApocalypseCharacter _apocCharacter) public authorized {
        address prevApocalypseCharacter = address(apocCharacter);
        apocCharacter = _apocCharacter;
        emit ChangeApocalypseCharacter(_msgSender(), prevApocalypseCharacter, address(_apocCharacter));
    }

    function changeApocalypseMineral(ApocalypseMineral _apocMineral) public authorized {
        address prevApocalypseMineral = address(apocMineral);
        apocMineral = _apocMineral;
        emit ChangeApocalypseMineral(_msgSender(), prevApocalypseMineral, address(_apocMineral));
    }

    function changeDistributor(RewardPoolDistributor _distributor) public authorized {
        address prevDistributor = address(distributor);
        distributor = _distributor;
        emit ChangeDistributor(_msgSender(), prevDistributor, address(distributor));
    }

    function changeRouter(IUniswapV2Router02 _router) public authorized {
        address prevRouter = address(router);
        router = _router;
        emit ChangeRouter(_msgSender(), prevRouter, address(router));
    }

    /* Check functions */

    function checkPrice(uint256 _priceBUSD, IERC20Extended _token) public view returns (uint256) {
        address[] memory path = new address[](3);
        path[0] = address(_token);
        path[1] = router.WETH();
        path[2] = address(peggedToken);
        return router.getAmountsIn(_priceBUSD, path)[0];
    }

    function mixer(address _player1, address _player2) public view returns (uint256, uint256) {
        uint256 random = randomizer.randomNGenerator(uint256(uint160(_player1)), uint256(uint160(_player2)), block.timestamp);
        uint256 _status = randomizer.sliceNumber(random, 2, 1, statusOffset);
        uint256 _drop = randomizer.sliceNumber(random, dropNumber, 1, dropOffset);
        return (_status, _drop);
    }

    /* Drop functions */

    function dropMineral(address _account) internal {
        uint256 _minerals = apocMineral.getTotalMineralTypes();
        uint256 random = randomizer.randomNGenerator(_minerals, uint256(uint160(_account)), block.timestamp);
        
        uint256 _possibility = randomizer.sliceNumber(random, 10, dropDenominatorBase, _minerals.div(2));
        if (_possibility > dropNumerator) {
            return;
        }
        
        uint256 _confirmation = randomizer.sliceNumber(random, 10, dropDenominatorBase, _minerals);
        uint256 _types = randomizer.sliceNumber(random, _minerals, 1, _minerals.div(2));
        if (_confirmation <= apocMineral.getMineralPVPDropChance(_types)) {
            apocMineral.mint(_account, _types, 1, bytes(""));
        }

    }

    /* PvP logic */

    /**
     * @dev Create a new PvP listing.
     */
    function createPvPRoom(uint256 _charID, uint256 _price) public payable whenNotPaused nonReentrant {

        uint256 _amount = checkPrice(minStake, rewardToken);

        require(_price >= _amount, "Price must be greater than the minimum amount allowed!");
        require(apocCharacter.ownerOf(_charID) == _msgSender(), "You are not the owner of this character!");

        _pvpID.increment();
        uint256 _getPvPID = _pvpID.current();

        idToPvPInfo[_getPvPID] =  pvpInfo(_getPvPID, _price, _charID, 0, false, payable(_msgSender()), payable(ZERO));

        rewardToken.transferFrom(_msgSender(), address(this), _price);

        emit CreatePvPRoom(_getPvPID, _msgSender(), _amount);
    }

    /**
     * @dev Join listed PvP room.
     */
    function joinPvPRoom(uint256 _charID, uint256 _roomID) public payable whenNotPaused nonReentrant {

        require(_roomID > 0 && _roomID <= _pvpID.current(), "This PvP fight does not exist!");
        require(idToPvPInfo[_roomID].fight == false, "This PvP fight already ended!");
        require(apocCharacter.ownerOf(_charID) == _msgSender(), "You are not the owner of this character!");

        uint256 _amount = idToPvPInfo[_roomID].amountToStake;
        
        rewardToken.transferFrom(_msgSender(), address(this), _amount);

        idToPvPInfo[_roomID].player2 = payable(_msgSender());
        idToPvPInfo[_roomID].charIDP2 = _charID;
        
        emit JoinPvPRoom(_roomID, _msgSender(), _amount);
        
        uint256 _tax = (_amount.mul(rewardTaxNumerator)).div(rewardTaxDenominator);
        uint256 _winnerReward = (_amount.sub(_tax)).mul(2);

        address _player1 = idToPvPInfo[_roomID].player1;
        address _player2 = idToPvPInfo[_roomID].player2;
        uint256 _status; 
        uint256 _drop; 
        (_status , _drop) = mixer(_player1, _player2);

        if (_status == 0) {
            IERC20Extended(rewardToken).transfer(_player1, _winnerReward);
            fightWon[_player1] = fightWon[_player1] + 1;
            dropMineral(_player2);
            fightLost[_player2] = fightLost[_player2] + 1;
            emit PvPCompleted(_roomID, _player1, _player2);
        } else if (_status == 1) {
            IERC20Extended(rewardToken).transfer(_player2, _winnerReward);
            fightWon[_player2] = fightWon[_player2] + 1;
            dropMineral(_player1);
            fightLost[_player1] = fightLost[_player1] + 1;
            emit PvPCompleted(_roomID, _player2, _player1);
        }
                
        idToPvPInfo[_roomID].fight = true;

    }
}