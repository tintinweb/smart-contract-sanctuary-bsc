/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// File: contracts/libs/Context.sol

pragma solidity ^0.8.0;

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
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/libs/Ownable.sol

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/libs/SafeMath.sol

pragma solidity ^0.8.0;

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/libs/Address.sol

pragma solidity ^0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// File: contracts/libs/IERC20.sol

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// File: contracts/libs/SafeERC20.sol

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: BEP20 operation did not succeed"
            );
        }
    }
}

// File: contracts/libs/ReentrancyGuard.sol

pragma solidity ^0.8.0;

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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

// File: contracts/libs/IERC165.sol

pragma solidity ^0.8.0;

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

// File: contracts/libs/IERC1155.sol

pragma solidity ^0.8.0;

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

// File: contracts/libs/IERC1155Receiver.sol

pragma solidity ^0.8.0;

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

// File: contracts/nx1.75.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;






contract NX175 is Ownable, ReentrancyGuard, IERC1155Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // staked token
    IERC20 public rewardToken;

    // Total staking tokens
    uint256 public totalStakings;

    // Total reward tokens
    uint256 public totalRewards;

    // reward start time (unixtime)
    uint256 public rewardStartTime;

    // reward end time (unixtime)
    uint256 public rewardEndTime;

    // reward period (sec)
    uint256 public rewardPeriod;

    // fixed reward ratio, multiplied by 100. Default value 100%
    // based reward period
    uint256 public rewardPerPeriod = 2000;

    // reward token per staked token rate
    uint256 public exchangeRate = 1;
    uint256 public exchangeRateDenominator = 1;

    // precision factor
    uint256 public PRECISION_FACTOR = 10000000000;

    // initialized flag
    bool public isInitialized = false;

    // force suspend flag
    bool public suspended = false;
    
    address[] public userList;

    // Extra Boost
    mapping(address => mapping(uint256 => BoostInfo)) private extraBoosts;
    address[] public nftContractAddressList;
    mapping(address => uint256[]) public nftTokenIdList;


    // Info of each user that stakes tokens (rewardToken)
    mapping(address => UserInfo) public userInfo;

    uint maxSubNftLimit = 8;
    bool canDepositSameNFT = true;

    struct NftInfo {
        address nftAddress;
        uint256 nftTokenId;
    }

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 lastRewardTime; // Last rewarded time
        bool registered; // it will add user in address list on first deposit
        address addr; //address of user
        uint256 rewardLockedUp; // Reward locked up.
        uint256 lastDepositedTime; // keeps track of deposited time for potential penalty
        // address nftAddress;     // deposited main NFT item contract address
        // uint256 nftTokenId;     // deposited main NFT item token ID
        NftInfo[] nftItems;     // deposited sub NFT item info
    }

    struct BoostInfo {
        uint256 boostPercent; // boost percentage in main item
        address nftContractAddress;
        uint256 nftTokenId;
        string nftName;
        uint setItemCategory;   // 0: none,
        uint setItemCount;
        uint setItemBonus;
        uint256 value;      // NFT value worth NXD
    }
    uint public numSetCategory;    // number of set category
    mapping(uint => uint256) public setItemCategoryBonus;    // bonus of set category

    event Initialized();
    event Withdrawn(address indexed account, uint256 amount);
    event Deposited(address indexed account, uint256 amount);
    event RewardLocked(address indexed account, uint256 amount, uint256 timestamp);
    event AdminTokenRecovery(address token);
    event NftDeposited(address indexed account, address nftAddress, uint256 nftTokenId);
    event NftWithdrawn(address indexed account, address nftAddress, uint256 nftTokenId);

    function initialize(
        address _rewardToken,
        uint256 _rewardStartTime,
        uint256 _rewardEndTime,
        uint256 _exchangeRate,
        uint256 _exchangeRateDenominator,
        uint256 _rewardPerPeriod
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");
        require(block.timestamp < _rewardStartTime, 
                "reward start time should be after now");
        require(_rewardEndTime > _rewardStartTime, 
                "reward end time should be after start time");
        require(_rewardToken != address(0), "invalid address");
        require(_exchangeRate > 0, "invalid exchange rate");
        require(_exchangeRateDenominator > 0, "invalic exchange rate denominator");

        rewardToken = IERC20(_rewardToken); 
        rewardStartTime = _rewardStartTime;
        rewardEndTime = _rewardEndTime;
        rewardPeriod = rewardEndTime.sub(rewardStartTime);

        exchangeRate = _exchangeRate;
        exchangeRateDenominator = _exchangeRateDenominator;

        rewardPerPeriod = _rewardPerPeriod;

        isInitialized = true;

        emit Initialized();
        
    }

    function updateRewardPerPeriod(uint256 _rewardPerPeriod) external onlyOwner {
        rewardPerPeriod = _rewardPerPeriod;
    }

    function updateLimitPerUser(uint _limit) external onlyOwner {
        require(_limit > maxSubNftLimit, "new limit should be greater than old limit");
        maxSubNftLimit = _limit;
    }

    function updateCanDepositSameNFT(bool _canDeposit) external onlyOwner {
        require(canDepositSameNFT != _canDeposit, "not changed");
        canDepositSameNFT = _canDeposit;
    }

    function suspend(bool _suspended) external onlyOwner {
        suspended = _suspended;
    }

    function canDeposit() public view returns (bool available){
        available = !suspended 
                    && block.timestamp < rewardEndTime; 
    }

    /**
     * @notice Deposit nft, then the staked token amount will be boosted
     */
    function depositNft(
        address _nftAddress,
        uint256 _nftTokenId
    ) external nonReentrant {
        require(canDeposit(), "not running now.");

        UserInfo storage user = userInfo[_msgSender()];
        require(
            extraBoosts[_nftAddress][_nftTokenId].value > 0,
            "This NFT is not eligible"
        );

        if (user.registered == false && user.amount == 0) {
            userList.push(_msgSender());
            user.registered = true;
            user.addr = address(_msgSender());
        }

        uint256 currentStakedNftCount = 0;
        uint256 availableIndex = maxSubNftLimit;
        bool _alreadyStakedSameNft = false;
        NftInfo memory _info;
        for (uint i=0; i<user.nftItems.length; i++) {
            _info = user.nftItems[i];
            if (_info.nftAddress != address(0)) {
                currentStakedNftCount++;
                if (_info.nftAddress == _nftAddress && _info.nftTokenId == _nftTokenId) {
                    _alreadyStakedSameNft = true;
                    break;
                }
            } else {
                availableIndex = i;
            }
        }
        require(
            canDepositSameNFT == true 
            || _alreadyStakedSameNft == false, 
            "Already staked the same NFT");

        require(
            currentStakedNftCount < maxSubNftLimit,
            "Item staking limit has been exceeded"
        );

        lockupPendingreward();

        require(
            IERC1155(_nftAddress).isApprovedForAll(
                _msgSender(),
                address(this)
            ),
            "NFT not approved for the staking contract"
        );
        IERC1155(_nftAddress).safeTransferFrom(
            _msgSender(),
            address(this),
            _nftTokenId,
            1,
            ""
        );

        NftInfo memory _nftInfo;
        _nftInfo.nftAddress = _nftAddress;
        _nftInfo.nftTokenId = _nftTokenId;
        if (availableIndex == maxSubNftLimit) {
            user.nftItems.push(_nftInfo);
        } else {
            user.nftItems[availableIndex] = _nftInfo;
        }
        user.amount = user.amount.add(extraBoosts[_nftAddress][_nftTokenId].value);
        
        emit NftDeposited(_msgSender(), _nftAddress, _nftTokenId);
    }

    function withdrawNftAll() public nonReentrant {
        require(_msgSender() == tx.origin, "Invalid Access");

        lockupPendingreward();
        UserInfo memory user = userInfo[_msgSender()];
        for (uint i=0; i<user.nftItems.length; i++) {
            _withdrawNft(i);
        }
    }

    function withdrawSubNft(uint _index) public nonReentrant {
        require(_msgSender() == tx.origin, "Invalid Access");

        lockupPendingreward();
        _withdrawNft(_index);
    }

    function _withdrawNft(uint _index) private {
        UserInfo storage user = userInfo[_msgSender()];
        if (_index < user.nftItems.length) {
            NftInfo memory info = user.nftItems[_index];
            if (info.nftAddress != address(0)) {
                IERC1155(info.nftAddress).safeTransferFrom(
                    address(this),
                    _msgSender(),
                    info.nftTokenId,
                    1,
                    ""
                );
                user.amount = user.amount.sub(extraBoosts[info.nftAddress][info.nftTokenId].value);
                emit NftWithdrawn(
                    _msgSender(),
                    info.nftAddress,
                    info.nftTokenId
                );

                delete user.nftItems[_index];
            }
        }
    }

    function lockupPendingreward() internal {
        UserInfo storage user = userInfo[_msgSender()];
        uint256 pending = pendingReward(_msgSender());
        totalRewards = totalRewards.add(pending).sub(user.rewardLockedUp);
        user.rewardLockedUp = pending;
        user.lastRewardTime = block.timestamp;
        emit RewardLocked(_msgSender(), user.rewardLockedUp, block.timestamp);
    }

    function balanceOf(address account) public view returns (uint256 amount) {
        UserInfo memory user = userInfo[account];
        amount = user.amount;
    }

    function pendingReward(address account) public view returns (uint256 pending) {
        UserInfo memory user = userInfo[account];
        uint256 etmAmount = getUserEtmAmount(account);
        // reward formula
        {
            pending = getUserDuration(account).mul(etmAmount)
                        .mul(rewardPerPeriod)
                        .mul(exchangeRate).mul(PRECISION_FACTOR)
                        .div(exchangeRateDenominator);
        }
        {
            pending = pending.div(rewardPeriod).div(10000)
                        .div(PRECISION_FACTOR)
                        .add(user.rewardLockedUp);
        }
    }

    function getUserDuration(address account) public view returns (uint256 duration) {
        UserInfo memory user = userInfo[account];
        
        uint256 endTime = block.timestamp;
        if (endTime > rewardEndTime) {
            endTime = rewardEndTime;
        }
        uint256 startTime = rewardStartTime;
        if (startTime < user.lastRewardTime) {
            startTime = user.lastRewardTime;
        }
        if (startTime >= endTime) {
            duration = 0;
        } else {
            duration = endTime.sub(startTime);
        }
    }

    function getUserNftItems(address account) public view 
        returns (
            NftInfo[] memory nftItems
        )
    {
        UserInfo memory user = userInfo[account];
        nftItems = user.nftItems;
    }

    function canWithdraw(address account) public view returns (bool _canWithdraw) {
        _canWithdraw = block.timestamp > rewardEndTime && balanceOf(account) > 0 && !suspended;
    }

    function canClaim(address account) public view returns (bool _canClaim) {
        _canClaim = block.timestamp > rewardEndTime && pendingReward(account) > 0 && !suspended;
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress)
        external
        onlyOwner
    {
        require(
            _tokenAddress != address(rewardToken),
            "Cannot withdraw staked token"
        );

        IERC20(_tokenAddress).safeTransfer(address(msg.sender), IERC20(_tokenAddress).balanceOf(address(this)));

        emit AdminTokenRecovery(_tokenAddress);
    }


    function getUsersReward(uint256 _offset, uint256 _limit)
        public
        view
        returns (
            address[] memory addresses,
            uint256[] memory rewards,
            uint256 nextOffset,
            uint256 total
        )
    {
        total = userList.length;
        if (_limit == 0) {
            _limit = 1;
        }

        if (_limit > total.sub(_offset)) {
            _limit = total.sub(_offset);
        }
        nextOffset = _offset.add(_limit);

        addresses = new address[](_limit);
        rewards = new uint256[](_limit);
        UserInfo memory user;
        for (uint256 i = 0; i < _limit; i++) {
            user = userInfo[userList[_offset.add(i)]];
            addresses[i] = user.addr;
            rewards[i] = pendingReward(user.addr);
        }
    }

    /**
     * @notice Update additional boost percentage for the specific nft and id
     * @dev Can only be called by the owner
     */
    function updateExtraBoost(
        address _nftAddress,
        uint256 _nftTokenId,
        uint256 _percent,
        string calldata _nftName,
        uint _setItemCategory,
        uint _setItemCount,
        uint _setItemBonus,
        uint256 _value
    ) external onlyOwner {

        extraBoosts[_nftAddress][_nftTokenId].boostPercent = _percent;
        extraBoosts[_nftAddress][_nftTokenId].nftContractAddress = _nftAddress;
        extraBoosts[_nftAddress][_nftTokenId].nftTokenId = _nftTokenId;
        extraBoosts[_nftAddress][_nftTokenId].nftName = _nftName;
        extraBoosts[_nftAddress][_nftTokenId].setItemCategory = _setItemCategory;
        extraBoosts[_nftAddress][_nftTokenId].setItemCount = _setItemCount;
        extraBoosts[_nftAddress][_nftTokenId].setItemBonus = _setItemBonus;
        extraBoosts[_nftAddress][_nftTokenId].value = _value * (10 ** rewardToken.decimals());
        
        // update set item category count
        if (numSetCategory <= _setItemCategory) {
            numSetCategory = _setItemCategory + 1;
        }

        // add nftContractAddress array
        bool found = false;
        for (uint i=0; i<nftContractAddressList.length; i++) {
            if (_nftAddress == nftContractAddressList[i]) {
                found = true;
                break;
            }
        }
        if (found == false) {
            nftContractAddressList.push(_nftAddress);
        }
        uint256[] storage _nftTokenIdList = nftTokenIdList[_nftAddress];
        found = false;
        for (uint i=0; i<_nftTokenIdList.length; i++) {
            if (_nftTokenId == _nftTokenIdList[i]) {
                found = true;
                break;
            }
        }
        if (found == false) {
            _nftTokenIdList.push(_nftTokenId);
        }
    }

    /*
     * @notice View function to get users.
     * @param _offset: offset for paging
     * @param _limit: limit for paging
     * @return get users, next offset and total users
     */
    function getUsersPaging(uint256 _offset, uint256 _limit)
        public
        view
        returns (
            UserInfo[] memory users,
            uint256 nextOffset,
            uint256 total
        )
    {
        total = userList.length;
        if (_limit == 0) {
            _limit = 1;
        }

        if (_limit > total.sub(_offset)) {
            _limit = total.sub(_offset);
        }
        nextOffset = _offset.add(_limit);

        users = new UserInfo[](_limit);
        for (uint256 i = 0; i < _limit; i++) {
            users[i] = userInfo[userList[_offset.add(i)]];
        }
    }

    function getUserEtmAmount(address account) public view returns (uint256) {
        UserInfo memory user = userInfo[account];
        uint256 boost = getUserTotalBonus(account);
        return user.amount.add(user.amount.mul(boost).div(10000));
    }

    function getUserTotalBonus(address account) public view returns (uint256 boost) {
        boost = 0;
        UserInfo memory user = userInfo[account];

        NftInfo[] memory items = new NftInfo[](user.nftItems.length);

        uint bonusCount = 0;
        uint bonusThreshold = 0;
        for (uint i=0; i<user.nftItems.length; i++) {
            NftInfo memory nft = user.nftItems[i];
            bool found = false;
            if (extraBoosts[nft.nftAddress][nft.nftTokenId].setItemCategory != 0) {
                bonusThreshold = extraBoosts[nft.nftAddress][nft.nftTokenId].setItemCount;

                for (uint j=0; j<items.length; j++) {
                    if (
                        items[j].nftAddress == nft.nftAddress
                        && items[j].nftTokenId == nft.nftTokenId
                    ) {
                        found = true;
                    }
                }
                if (!found) {
                    bonusCount += 1;
                } else {
                    items[i] = nft;
                }
            }
        }
        if (bonusCount >= bonusThreshold) {
            boost = 10000;
        }
    }

    /**
     * @notice Return Extra Boost .
     * @param _nftAddress: NFT Contract Address
     * @param _nftTokenId: NFT Token ID
     */
    function getExtraBoost(address _nftAddress, uint256 _nftTokenId) public view returns (uint256) {
        return extraBoosts[_nftAddress][_nftTokenId].boostPercent;
    }

    function getExtraBoostList() public view 
        returns (
            BoostInfo[] memory _boostInfoList
        )
    {
        uint _length = 0;    
        for (uint i=0; i<nftContractAddressList.length; i++) {
            _length += nftTokenIdList[nftContractAddressList[i]].length;
        }

        _boostInfoList = new BoostInfo[](_length);

        uint _index = 0;
        for (uint i=0; i<nftContractAddressList.length; i++) {
            uint256[] memory _tokenIdList = nftTokenIdList[nftContractAddressList[i]];
            for (uint j=0; j<_tokenIdList.length; j++) {
                _boostInfoList[_index] = extraBoosts[nftContractAddressList[i]][_tokenIdList[j]];
                _index++;
            }
        }
    }

    function claim() external {
        require(canClaim(_msgSender()), "cannot claim now");
        UserInfo storage user = userInfo[_msgSender()];
        
        lockupPendingreward();
        
        rewardToken.safeTransfer(_msgSender(), user.rewardLockedUp);
        user.rewardLockedUp = 0;


    }

    function withdrawReward(uint256 amount) external onlyOwner {
        require(rewardToken.balanceOf(address(this)) >= amount, "insufficient balance");
        rewardToken.safeTransfer(_msgSender(), amount);
    }
    
    function onERC1155Received(
        address, /*operator*/
        address, /*from*/
        uint256, /*id*/
        uint256, /*value*/
        bytes calldata /*data*/
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address, /*from*/
        uint256[] calldata, /*ids*/
        uint256[] calldata, /*values*/
        bytes calldata /*data*/
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 /*interfaceId*/
    ) public view virtual override returns (bool) {
        return false;
    }

}

interface INftBoost {
    function getUserTotalBonus(address account) external view returns (uint256);
}