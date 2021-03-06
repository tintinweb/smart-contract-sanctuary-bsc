/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

pragma solidity ^0.8.0;


// 
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

// 
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

// 
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

// 
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

// 
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

// 
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

// 
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// 
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

// 
/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// 
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

// 
/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// 
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

// 
/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// 
/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// 
interface IMysteryBoxNFT is IERC1155 {
    function createMysteryBox(
        uint256 _boxType,
        bytes memory _boxName,
        uint256 _amount,
        string memory _tokenURI
    ) external returns (uint256 tokenId);

    function burnMysteryBox(address account, uint256 id, uint256 amount) external;
    function getBoxInfo(uint256 _tokenId) external view returns (uint256, bytes memory, string memory);
    function getBoxType(uint256 _tokenId) external view returns (uint256);
}

// 
contract LuckySpin is Ownable, Initializable, Pausable, ERC1155Holder {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct RoundInfo {
        uint256 roundId;
        uint256 totalSlots;
        uint256 totalJoins;
        uint256 ticketPrice;
        uint256 maxBuy;
        uint256 status; // 1: available | 2 move | 3 spin

        address winner;
        bool claimed;


        address[] rewardUsers; //users has ticket random
        mapping(address => uint256) userStakedTimes; //latest stake
        mapping(address => uint256) userStakedTokens; // total token user stake
        mapping(address => uint256) userSlots; // User Slots To Add address to rewards pool

    }

    struct RoundReturnInfo {
        uint256 roundId;
        uint256 totalSlots;
        uint256 totalJoins;
        uint256 ticketPrice;
        uint256 maxBuy;
        address winner;
        bool claimed;
        uint256 status;

        uint256 staked;
        uint256 slots;
        uint256 burned;
    }

    struct JoinReturnInfo {
        uint256 roundId;
        address winner;
        bool claimed;
        uint256 status;
        uint256 stakedTime;
        uint256 actualRoundId;
        uint256 userStaked;
        uint256 userSlots;
    }

    IMysteryBoxNFT public mysteryBoxNFT;
    uint256 public rewardBoxId;
    IERC20 public erc20Token;


    mapping(uint256 => RoundInfo) public roundInfos;
    uint256 public currentRoundId = 0;
    uint256 public totalZwZBurned = 0;
    address public deadAddress = address(0x0000dead);

    mapping(address => bool) public whiteListUsers;

    mapping(address => uint256) public numOfJoins;


    event StartSpinRound(address indexed creator, uint256 indexed roundId, uint256 totalSlots, uint256 ticketPrice, uint256 maxBuy);
    event SpinReward(uint256 indexed roundId, address indexed winner, uint256 indexed status);
    event Join(address indexed creator, uint256 indexed roundId, uint256 amount);
    event ClaimReward(uint256 indexed roundId, address indexed winner, uint256 boxId);
    event AddReward(address indexed user, uint256 indexed boxId, uint256 indexed quantity);
    event WithdrawReward(address indexed user, uint256 indexed boxId, uint256 indexed quantity);
    event EmergencyWithdraw(address indexed user, uint256 indexed quantity);
    event UpdateTotalSlots(uint256 indexed roundId, uint256 indexed currentTotal, uint256 indexed newTotal);
    event UpdateTicketPrice(uint256 indexed roundId, uint256 indexed currentPrice, uint256 indexed newPrice);


    modifier onlyWhiteListUser() {
        require(whiteListUsers[msg.sender], "Only-white-list-can-execute");
        _;
    }

    constructor() {
        whiteListUsers[msg.sender] = true;
    }

    function adminWhiteListUsers(address _user, bool _whiteList) public onlyOwner {
        whiteListUsers[_user] = _whiteList;
    }

    function initialize(
        address _mysteryBoxNFT,
        uint256 _rewardBoxId,
        address _erc20Token
    ) external initializer {
        require(_mysteryBoxNFT != address(0) && _mysteryBoxNFT != address(this), "Invalid Box Address");
        require(_rewardBoxId > 0, "Invalid Box Id");
        require(_erc20Token != address(0), "Invalid Token Address");


        mysteryBoxNFT = IMysteryBoxNFT(_mysteryBoxNFT);
        rewardBoxId = _rewardBoxId;
        erc20Token = IERC20(_erc20Token);
    }

    function setMysteryBoxNFT(address _mysteryBoxNFT) public onlyOwner {
        require(_mysteryBoxNFT != address(0) && _mysteryBoxNFT != address(this), "invalid address");
        require(_mysteryBoxNFT != address(mysteryBoxNFT), "No Need To Update");
        mysteryBoxNFT = IMysteryBoxNFT(_mysteryBoxNFT);
    }

    function setRewardBoxId(uint256 _rewardBoxId) public onlyOwner {
        require(_rewardBoxId > 0, "Invalid Box Id");
        require(_rewardBoxId != rewardBoxId, "No Need To Update");
        rewardBoxId = _rewardBoxId;
    }

    function setErc20Token(address _erc20Token) public onlyOwner {
        require(_erc20Token != address(0) && _erc20Token != address(this), "invalid address");
        require(_erc20Token != address(erc20Token), "No Need To Update");
        erc20Token = IERC20(_erc20Token);
    }

    function setDeadAddress(address _deadAddress) public onlyOwner {
        require(_deadAddress != _deadAddress, "No Need To Update");
        deadAddress = address(_deadAddress);
    }

    function setTotalZwZBurned(uint256 _totalZwZBurned) public onlyOwner {
        require(_totalZwZBurned >= 0, "Invalid Value");
        require(_totalZwZBurned != totalZwZBurned, "No Need To update");
        totalZwZBurned = _totalZwZBurned;
    }

    function updateTotalSlot(uint256 _roundId, uint256 _totalSlots) public onlyWhiteListUser {
        RoundInfo storage info = roundInfos[_roundId];
        require(info.status == 1, "Invalid round");
        require(_totalSlots > 0, "Invalid Slots");
        require(_totalSlots != info.totalSlots, "No Need To update");
        uint256 cTotal = info.totalSlots;
        info.totalSlots = _totalSlots;
        emit UpdateTotalSlots(_roundId, cTotal, _totalSlots);
    }

    function updateTicketPrice(uint256 _roundId, uint256 _ticketPrice) public onlyWhiteListUser {
        RoundInfo storage info = roundInfos[_roundId];
        require(info.status == 1, "Invalid round");
        require(_ticketPrice > 0, "Invalid Price");
        require(_ticketPrice != info.ticketPrice, "No Need To update");
        uint256 cPrice = info.ticketPrice;
        info.ticketPrice = _ticketPrice;
        emit UpdateTicketPrice(_roundId, cPrice, _ticketPrice);
    }


    function join(uint256 _amount) public whenNotPaused {
        RoundInfo storage info = roundInfos[currentRoundId];


        uint256 totalStaked = info.userStakedTokens[_msgSender()].add(_amount);

        uint256 newSlots = totalStaked.div(info.ticketPrice).sub(info.userSlots[_msgSender()]);

        require(totalStaked <= info.maxBuy, 'Exceed Max Buy!');
        require(info.totalSlots.sub(info.totalJoins) >= newSlots, 'Full Slots');
        require(info.status == 1, 'Round Is Not Available');
        require(erc20Token.balanceOf(_msgSender()) >= _amount, 'Insufficient Balance');
        require(erc20Token.allowance(_msgSender(), address(this)) >= _amount, 'Insufficient Allowance');

        info.userStakedTimes[_msgSender()] = block.timestamp;

        // Count How many time user join
        if (info.userStakedTokens[_msgSender()] == 0) {
            numOfJoins[_msgSender()] = numOfJoins[_msgSender()].add(1);
        }

        info.userStakedTokens[_msgSender()] = info.userStakedTokens[_msgSender()].add(_amount);
        info.userSlots[_msgSender()] = info.userSlots[_msgSender()].add(newSlots);
        info.totalJoins = info.totalJoins.add(newSlots);
        if (newSlots > 0) {
            for (uint256 i = 0; i < newSlots; i++) {
                info.rewardUsers.push(_msgSender());
            }
        }

        erc20Token.safeTransferFrom(_msgSender(), address(this), _amount);
        emit Join(_msgSender(), currentRoundId, _amount);

    }

    function claimReward(uint256 _spinRoundId) public whenNotPaused {
        RoundInfo storage info = roundInfos[_spinRoundId];

        require(info.winner == _msgSender(), 'You Are Not Winner');
        require(info.claimed == false, 'You Have Claimed Reward');
        require(info.status == 3, 'Round Is Not Available!');
        require(mysteryBoxNFT.balanceOf(address(this), rewardBoxId) > 0, 'Can Not Claim Reward Now');

        info.claimed = true;

        mysteryBoxNFT.safeTransferFrom(address(this), _msgSender(), rewardBoxId, 1, abi.encodePacked(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")));
        emit ClaimReward(_spinRoundId, _msgSender(), rewardBoxId);
    }


    function spinReward(
        uint256 _totalSlots,
        uint256 _ticketPrice,
        uint256 _maxBuy) public onlyWhiteListUser {
        require(_totalSlots > 0, 'Invalid  Total Slots');
        require(_ticketPrice > 0, 'Invalid  Ticket Price');
        require(_maxBuy > 0, 'Invalid Max Buy');

        uint256 nextRoundId = _getNextRoundID();
        if (currentRoundId == 0) {
            _incrementRoundID();
            RoundInfo storage initRoundInfo = roundInfos[nextRoundId];

            initRoundInfo.roundId = nextRoundId;
            initRoundInfo.totalSlots = _totalSlots;
            initRoundInfo.ticketPrice = _ticketPrice;
            initRoundInfo.maxBuy = _maxBuy;
            initRoundInfo.status = 1;
            emit StartSpinRound(_msgSender(), nextRoundId, _totalSlots, _ticketPrice, _maxBuy);
            return;
        }

        RoundInfo storage info = roundInfos[currentRoundId];
        require(info.winner == address(0), 'Already Spin');
        require(info.status == 1, 'Round Is Not Available');

        if (info.totalJoins == info.totalSlots) {
            _incrementRoundID();
            RoundInfo storage nextRoundInfo = roundInfos[nextRoundId];
            nextRoundInfo.totalSlots = _totalSlots;
            nextRoundInfo.ticketPrice = _ticketPrice;
            nextRoundInfo.roundId = info.roundId.add(1);
            nextRoundInfo.maxBuy = _maxBuy;
            nextRoundInfo.status = 1;


            uint256 randNum = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _msgSender())));
            uint256 index = randNum.mod(info.rewardUsers.length);
            info.winner = info.rewardUsers[index];
            info.status = 3;

            uint256 balance = erc20Token.balanceOf(address(this));
            if (balance > 0) {
                erc20Token.transfer(deadAddress, balance);
                totalZwZBurned = totalZwZBurned.add(balance);
            }
        } else {
            info.roundId = info.roundId.add(1);
        }

        emit SpinReward(info.roundId, info.winner, info.status);
    }


    function addReward(uint256 _quantity) public onlyWhiteListUser {
        require(mysteryBoxNFT.balanceOf(_msgSender(), rewardBoxId) >= _quantity, 'Not enough Box');
        require(mysteryBoxNFT.isApprovedForAll(_msgSender(), address(this)) == true, 'Not Approved Box');

        mysteryBoxNFT.safeTransferFrom(_msgSender(), address(this), rewardBoxId, _quantity, abi.encodePacked(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")));
        emit AddReward(_msgSender(), rewardBoxId, _quantity);
    }

    function withdrawReward(address _boxAddress, uint256 _rewardBoxId, uint256 _quantity) public onlyWhiteListUser {
        IMysteryBoxNFT mysteryBox = IMysteryBoxNFT(_boxAddress);
        require(mysteryBox.balanceOf(address(this), _rewardBoxId) >= _quantity, 'Not enough Box To BUY');
        mysteryBox.safeTransferFrom(address(this), _msgSender(), _rewardBoxId, _quantity,
            abi.encodePacked(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")));
        emit WithdrawReward(_msgSender(), rewardBoxId, _quantity);
    }


    function emergencyWithdraw() public onlyWhiteListUser {
        uint256 balance = erc20Token.balanceOf(address(this));
        if (balance > 0) {
            erc20Token.safeTransfer(_msgSender(), balance);
        }
        emit EmergencyWithdraw(_msgSender(), balance);
    }


    function getJoins(address _user) public view returns (JoinReturnInfo[] memory) {
        uint256 count = numOfJoins[_user];
        JoinReturnInfo[] memory result = new JoinReturnInfo[](count);

        if (count > 0) {
            uint256 idx = 0;
            for (uint256 i = 1; i <= currentRoundId; i++) {
                RoundInfo storage info = roundInfos[i];
                if (info.userStakedTokens[_user] != 0 && (info.status == 3 || info.status == 1)) {
                    result[idx].roundId = info.roundId;
                    result[idx].stakedTime = info.userStakedTimes[_user];
                    result[idx].winner = info.winner;
                    result[idx].status = info.status;
                    result[idx].claimed = info.claimed;
                    result[idx].actualRoundId = i;
                    result[idx].userStaked = info.userStakedTokens[_user];
                    result[idx].userSlots = info.userSlots[_user];
                    idx++;
                }
            }
        }
        return result;
    }


    function getActiveRounds() public view returns (RoundReturnInfo[] memory) {
        uint256 cRoundId = currentRoundId;
        uint256 size = 0;
        for (uint256 i = 1; i <= cRoundId; i++) {
            if (roundInfos[i].status == 1 || roundInfos[i].status == 3) {
                size++;
            }
        }

        uint256 id = 0;
        RoundReturnInfo[] memory result = new RoundReturnInfo[](size);
        for (uint256 i = 1; i <= cRoundId; i++) {
            if (roundInfos[i].status == 1 || roundInfos[i].status == 3) {
                result[id] = getRoundInfoById(i);
                id++;
            }
        }
        return result;
    }


    function getRoundInfoById(uint256 _roundId) public view returns (RoundReturnInfo memory) {
        RoundInfo  storage round = roundInfos[_roundId];
        RoundReturnInfo memory result;

        result.roundId = round.roundId;
        result.totalSlots = round.totalSlots;
        result.totalJoins = round.totalJoins;
        result.ticketPrice = round.ticketPrice;
        result.maxBuy = round.maxBuy;
        result.claimed = round.claimed;
        result.winner = round.winner;
        result.status = round.status;
        result.burned = totalZwZBurned;
        return result;
    }

    function getCurrentRoundInfo() public view returns (RoundReturnInfo memory) {
        RoundReturnInfo memory result = getRoundInfoById(currentRoundId);
        return result;
    }

    function getTotalStakedUser(uint256 _roundId, address _user) public view returns (uint256, uint256, uint256) {
        RoundInfo  storage round = roundInfos[_roundId];
        return (round.userStakedTokens[_user], round.ticketPrice, round.userSlots[_user]);
    }

    function getCurrentTotalStakedUser(address _user) public view returns (uint256, uint256, uint256) {
        RoundInfo  storage round = roundInfos[currentRoundId];
        return (round.userStakedTokens[_user], round.ticketPrice, round.userSlots[_user]);
    }


    function getRoundInfoUser(uint256 _roundId, address _user) public view returns (RoundReturnInfo memory) {
        RoundInfo  storage round = roundInfos[_roundId];
        RoundReturnInfo memory result;
        result.roundId = round.roundId;
        result.totalSlots = round.totalSlots;
        result.totalJoins = round.totalJoins;
        result.ticketPrice = round.ticketPrice;
        result.maxBuy = round.maxBuy;
        result.claimed = round.claimed;
        result.winner = round.winner;
        result.status = round.status;
        result.staked = round.userStakedTokens[_user];
        result.slots = round.userSlots[_user];
        result.burned = totalZwZBurned;
        return result;
    }

    function getCurrentRoundInfoUser(address _user) public view returns (RoundReturnInfo memory) {
        RoundInfo  storage round = roundInfos[currentRoundId];
        RoundReturnInfo memory result;
        result.roundId = round.roundId;
        result.totalSlots = round.totalSlots;
        result.totalJoins = round.totalJoins;
        result.ticketPrice = round.ticketPrice;
        result.maxBuy = round.maxBuy;
        result.claimed = round.claimed;
        result.winner = round.winner;
        result.status = round.status;
        result.staked = round.userStakedTokens[_user];
        result.burned = totalZwZBurned;
        return result;
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }


    function unpause() public onlyOwner whenPaused {
        _unpause();
    }


    function _getNextRoundID() private view returns (uint256) {
        return currentRoundId.add(1);
    }

    function _incrementRoundID() private {
        currentRoundId++;
    }
}