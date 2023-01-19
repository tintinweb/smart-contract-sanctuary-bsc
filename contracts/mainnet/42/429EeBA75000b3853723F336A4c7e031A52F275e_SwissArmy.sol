/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

pragma solidity ^0.8.17;





abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library Address {
  
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)


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




pragma solidity ^0.8.0;
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

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IBITV {


    function category() external view returns(uint256);

    function _lastIndex() external view returns(uint256);
    
    function _owner() external view returns(address payable);

    function owner() external view returns(address);

    function nftOwner(uint256 _id) external view returns (address);

    function ownerOf(uint256 _id) external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function getCollectionLength() external view returns(uint256);

    function totalSupply() external view returns (uint256);
    
    function referalWallet(address _contractAddress) external view returns(address);

    function getMarketerNft(address _contractAddress) external view returns(address);
    
    function _royaltyFees(address _contractAddress) external view returns(uint256);

    function royaltiesActive(address _contractAddress) external view returns(bool);
    
    function getCollectionCategory(address _contractAddress) external view returns(uint256);

    function getNFTIndexPrice(uint256 _index) external view returns(uint256);

    function mintFor(uint256 quantity, uint256 index, address owner) payable external returns (uint256);
    

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

contract SwissArmy is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    Counters.Counter private _usersCount;
    Counters.Counter private _stakerCount;
    Counters.Counter private _bep20Count;

    struct Reward {
        IBEP20 payoutToken;
        uint256 amount;
    }

    address private devWallet;
    IBEP20 public rewardsToken;
    IBITV public collection;
    IDEXRouter public router;

    uint256 public lastUpdateTime;
    
    mapping(address => bool) private  tokens;
    mapping(uint => uint256) private rewards;
    mapping(address => uint256) public claimedRewards;
    mapping(address => bool) private flags;
    mapping(address => bool) private registry;
    mapping(address => uint256) private staketBalances;
    mapping(uint256 => address) private indexStaker;
    mapping(address => uint256) private stakersIndex;


    mapping(address => bool) private  acceptedBep20List;
    mapping(uint256 => address) private  bep20List;

    uint256 public  totalStakedBalance;
    mapping(address => bool) private whiteList;
    
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public collectionAddress;
    address private WBNB;
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    


    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 tokenId, uint256 idScore);
    event Withdrawn(address indexed user, uint256 tokenId, uint256 idScore);
    event RewardPaid(address indexed user, uint256 reward);

    constructor()  {
        transferOwnership(msg.sender);
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        acceptedBep20List[0xdD8B490001D081eD065239644dae8D1a77b8A91F] = true;
        acceptedBep20List[0xFACE67C5CE2bb48c29779b0Dede5360cC9ef5fd5] = true;
        acceptedBep20List[0x8B6bF63e2b1C221dC0Fb01AE85868b83dDee1B54] = true;
        acceptedBep20List[0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE] = true;

        WBNB = address(router.WETH());
        _usersCount.increment();
        _stakerCount.increment();
        _bep20Count.increment();
    }

    modifier permiterContract() {
            require(whiteList[msg.sender] == true, "Callback: No access!");
            _;
    }


    modifier isNFTOwner(uint _nftId) {
            require(msg.sender == collection.ownerOf(_nftId), "Callback: Not The Owner!");
            _;
    }

    function getStakeByIndex(uint256 index) public view  returns(address) {
        return indexStaker[index];
    }

    function getOwnerIndex(address owner) public  view  returns(uint256) {
        return stakersIndex[owner];
    }

    function getPoolBalance() external  view returns (uint256) {
        return address(this).balance;
    }

    function isStaked(address owner) public view returns(bool) {
        return flags[owner];
    }

    function isRegistered(address owner) public view returns(bool) {
        return registry[owner];
    }

    function getClaimed(address owner) external view returns(uint256){
        return claimedRewards[owner];
    }

    function getPendingRewards(uint index) external view returns(uint256) {
        return rewards[index];
    }

    function getStakedAmount(address owner) external view returns(uint256) {
        return staketBalances[owner];
    }

    function getTotalStakersCount() external  view returns(uint256) {
        return _stakerCount.current();
    }

    function getPendingRewardBep20(uint index, address token) external view returns(uint256) {
            address[] memory path = new address[](2);
            path[0] = router.WETH();
            path[1] =  address(token);
            return router.getAmountsOut(rewards[index], path)[1];
    }

    function getOwnersShares(address owner) public view returns(uint256) {
          return fromX(staketBalances[owner], totalStakedBalance, toWei(100));
    }

    function getSharesFromAmount(uint256 _amount, uint256 index) public view returns(uint256) {
          uint256 sharePercetage =  fromX(staketBalances[indexStaker[index]], totalStakedBalance, toWei(100));
          return  _amount * sharePercetage / toWei(100);
    }

    function getShareAmount(uint256 _amount, uint256 percetage, uint256 scale) public pure returns(uint256) {
        return _amount * percetage / scale;
    }

    function getOwenersPoolPercentage(address owner) public view returns(uint256) {
          return fromX(staketBalances[indexStaker[stakersIndex[owner]]], totalStakedBalance, toWei(100));
    }

    function getTotalStaked() public view returns(uint256) {
        return totalStakedBalance;
    }

    function isAllowedBep20(address contractAddress) public view returns(bool) {
        return acceptedBep20List[contractAddress];
    }

    function getBep20Addresses() external view returns(address[] memory) {
        address[] memory allowedTokens = new address[](_bep20Count.current());
        for(uint i = 0; i < _bep20Count.current(); i++) {
            allowedTokens[i] = bep20List[i + 1];
        }
        return allowedTokens;
    }
    
    function getBalancesIds(uint[] memory _ids) external  view returns(uint256) {
        uint256 amount;
        for(uint i = 0; i < _ids.length; i++) {
            amount = amount + rewards[_ids[i]];
        }
        return amount;
    }

    
    function addAcceptedBep20(address _address, bool _flag) external onlyOwner() {
        acceptedBep20List[_address] = _flag;
    }

    function addwhiteListAccess(address _address, bool _flag) external onlyOwner() {
        whiteList[_address] = _flag;
    }

    function setCollectionAddress(address _collectionAddress) external onlyOwner() {
        collectionAddress = _collectionAddress;
    }

    function setDevWallet(address wallet) external onlyOwner() {
        devWallet = wallet;
    }

    function addStaker(address _address, bool _flag, uint256 _amount) external onlyOwner() {
        flags[_address] = _flag;
        if(_flag) {
            staketBalances[_address] = staketBalances[_address].add(_amount);
            totalStakedBalance = totalStakedBalance.add(_amount);
           
           if(!registry[_address]) {
            indexStaker[_stakerCount.current()] = _address;
            stakersIndex[_address] = _stakerCount.current();
            registry[_address] = true;
             _stakerCount.increment();
           }
        } else {
            staketBalances[_address] = 0;
            totalStakedBalance = totalStakedBalance.sub(_amount);
        }
    }
    

    function batchCalimStaked(address[] memory contracts, uint256[] memory percentage, uint256 _amount) payable external{
        uint256 amount = rewards[stakersIndex[msg.sender]];
        require(amount >= _amount, "Claim larger then reward amount!");

         if(amount > 0) {
            _batchClaimBep20(contracts, percentage, _amount);
            rewards[stakersIndex[msg.sender]] = rewards[stakersIndex[msg.sender]] - _amount;
            claimedRewards[msg.sender] = claimedRewards[msg.sender] + _amount;
        }
    }

   function process(uint256 _amount) internal {

        uint256 army_share = _amount * (100 - 30) / 100;                                                                       
        uint256 owner_share = _amount * 30 / 100;                                                                              

                                                                                                                               
        (bool done,) =  payable(address(devWallet)).call{value: owner_share}("");
        require(done, "Failed to send tx");
     
        for(uint256 index = 0; index < _stakerCount.current(); index++) {

            if(indexStaker[index] == collectionAddress) {
                uint256 sharePercetage =  fromX(staketBalances[indexStaker[index]], totalStakedBalance, toWei(100));
                uint256 computedAmount =  army_share * sharePercetage / toWei(100);
                (bool sent,) =  payable(address(collectionAddress)).call{value: computedAmount}("");
                require(sent, "Failed to send tx");
            }
            
                                                                                                                               
            if(indexStaker[index] != DEAD && indexStaker[index] != collectionAddress) {
                if(staketBalances[indexStaker[index]] > 0) {
                    uint256 sharePercetage =  fromX(staketBalances[indexStaker[index]], totalStakedBalance, toWei(100));
                    uint256 computedAmount =  army_share * sharePercetage / toWei(100);
                    rewards[index] = rewards[index] + computedAmount;
                }
            }
        }
    }

    function ratio(uint256 poolBalance, uint256 stakeringPool, uint256 balance, uint poolPercentage) private pure returns(uint256) {
            uint256 percentageShares = (100 * balance) / stakeringPool;
            uint256 poolshares = poolBalance * percentagecal(poolPercentage, 100, toWei(100));
            return  poolshares * percentagecal(percentageShares, 100, toWei(100));
    }
    
    function fromX(uint256 a, uint256 b, uint256 scale) internal  pure returns(uint256) {
        return (scale * a) / b;
    }

    function toWei(uint value) internal pure returns (uint) {
       return value*(10**18);
    }

    function toW(uint value) public pure returns (uint) {
       return value*(10**18);
    }

    function percentagecal(uint256 a, uint256 b, uint256 scale) private pure returns(uint256) {
        return (scale - a) / b;
    }

    function _batchClaimBep20(address[] memory _contract, uint256[] memory percentages, uint256 _amount) internal {
            require(_contract.length == percentages.length, "Claim: Fallback");
            uint256 totalPercentage = 0;
            address[] memory path = new address[](2);
            uint deadline = block.timestamp;

            for(uint i = 0; i < percentages.length; i++) {
                totalPercentage = totalPercentage + percentages[i];
                if(totalPercentage > 100) revert();
            }

            for(uint i = 0; i < _contract.length; i++) {
                 if(!acceptedBep20List[_contract[i]]) revert();

                   path[0] = router.WETH();
                   path[1] = _contract[i];
                   router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amount * percentages[i] / 100}(
                        0,
                        path,
                        msg.sender,
                        deadline
                    );
            }
    }


    function setLongTerm(address _address, uint256 _amount) external permiterContract {
           require(_amount > 0, "Cannot stake");
           flags[_address] = true;
           totalStakedBalance = totalStakedBalance.sub(staketBalances[_address]);
           staketBalances[_address] = staketBalances[_address].add(_amount);
           totalStakedBalance = totalStakedBalance.add(staketBalances[_address]);
           
           if(!registry[_address]) {
                indexStaker[_stakerCount.current()] = _address;
                stakersIndex[_address] = _stakerCount.current();
                registry[_address] = true;
                _stakerCount.increment();
           }
    }


    function removeLongTerm(address _address) external permiterContract {
           flags[_address] = false;
           require(staketBalances[_address] > 0, "Balance is not greated then 0");
           totalStakedBalance = totalStakedBalance.sub(staketBalances[_address]);
           staketBalances[_address] = 0;
    }


    function putFlag(bool _flag, address _address, uint256 _amount) external permiterContract {
        flags[_address] = _flag;
        if(_flag) {
            staketBalances[_address] = staketBalances[_address].add(_amount);
            totalStakedBalance = totalStakedBalance.add(_amount);
           
           if(!registry[_address]) {
            indexStaker[_stakerCount.current()] = _address;
            stakersIndex[_address] = _stakerCount.current();
            registry[_address] = true;
             _stakerCount.increment();
           }
        } else {
            staketBalances[_address] = 0;
            totalStakedBalance = totalStakedBalance.sub(_amount);
        }
    }
  

    function withdraw() payable external onlyOwner {
        uint256 balance = address(this).balance;
        payable(address(owner())).transfer(balance);
    }
    
    receive() external payable {
        process(msg.value);
    }

}