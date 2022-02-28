/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155Receiver.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/utils/ERC1155Receiver.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;



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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/utils/ERC1155Holder.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;


/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
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

// File: contracts/ArkStaking.sol

//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.12;

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
        (bool success, bytes memory returndata) =
            target.call{value: value}(data);
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

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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
        uint256 newAllowance =
            token.allowance(address(this), spender).add(value);
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
        uint256 newAllowance =
            token.allowance(address(this), spender).sub(
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

        bytes memory returndata =
            address(token).functionCall(
                data,
                "SafeERC20: low-level call failed"
            );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

contract Ownable {
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) external onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
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

contract Receiver is Ownable {
    /*
        @notice Send funds owned by this contract to another address
        @param tracker  - ERC20 token tracker ( DAI / MKR / etc. )
        @param amount   - Amount of tokens to send
        @param receiver - Address we're sending these tokens to
        @return true if transfer succeeded, false otherwise 
    */
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function sendFundsTo(address tracker, uint256 amount, address receiver) public onlyOwner returns ( bool ) {
        // callable only by the owner, not using modifiers to improve readability
        // Transfer tokens from this address to the receiver
        return IERC20(tracker).transfer(receiver, amount);
    }
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
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

/**
 * @title ArkRivals Staking Event
 */
contract ArkRivalsStaking is Ownable, ReentrancyGuard, ERC1155Holder, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 private constant BOX_1_STAR = 1;
    uint256 private constant BOX_2_STAR = 2;
    uint256 private constant BOX_3_STAR = 3;
    uint256 private constant BOX_4_STAR = 4;
    uint256 private constant BOX_5_STAR = 5;
    uint256 private constant BOX_6_STAR = 6;

    
    uint256 private constant STATUS_STAKE_NOT_STAKE = 1;
    uint256 private constant STATUS_STAKE_ON_GOING = 2;
    uint256 private constant STATUS_STAKE_CAN_CLAIM = 3;
    uint256 private constant STATUS_STAKE_CLAIMED = 4;
    

    struct EventInfo {
        uint256 eventId;
        uint256 startTime;
        uint256 endTime;
        uint256 period;
        uint256 maxAllEvent; // <= 0 : mean unlimit all event
        bool allowEmergencyWithdraw;
        uint256 numTokenPerStake;
        uint256 rewardBox;
        uint256 rewardNum;
        bool isExist;
    }

    struct StakeInfo{
        uint256 eventId;
        uint256 startTime;
        uint256 endTime; //= startTime + period
        uint256 numToken;
        uint256 rewardBox;
        uint256 rewardNum;
        bool claimed;
        uint256 claimedAt;
        bool isExist;
    }

    struct EventStatus {
        uint256 eventId;
        bool isPaused;
        uint256 eventCounter; //all event Counter for maxEvent check
        uint256 boxClaimed;
        bool isExist;
    }

    //LookUp table
    mapping(uint256 => mapping(address=>StakeInfo)) stakeHolders;
    mapping(uint256 => EventInfo) eventInfoMap;
    mapping(uint256 => EventStatus)  eventStatusMap;
    uint256 public totalStake;
    uint256 public totalBoxClaimed;
    uint256 public totalBoxCancel;
    uint256 public totalEvent;


    function getEventRewardById(uint256 eventId) view public returns(uint256, uint256){
        require(eventInfoMap[eventId].isExist, "Event  Info not Exist");
        return (eventInfoMap[eventId].rewardBox, eventInfoMap[eventId].rewardNum);
    }


    function getEventInfoById(uint256 eventId) view public returns(uint256, uint256,  uint256, uint256, bool, uint256){
        require(eventInfoMap[eventId].isExist, "Event  Info not Exist");
        return (eventInfoMap[eventId].startTime, eventInfoMap[eventId].endTime, eventInfoMap[eventId].period,
			eventInfoMap[eventId].maxAllEvent, eventInfoMap[eventId].allowEmergencyWithdraw, 
			eventInfoMap[eventId].numTokenPerStake);
    }


    function getEventStatusById(uint256 eventId) view public returns(uint256, bool, uint256){
        require(eventStatusMap[eventId].isExist, "Event  Status not Exist");
        return (eventStatusMap[eventId].eventId, eventStatusMap[eventId].isPaused, eventStatusMap[eventId].eventCounter);
    }


    //Only Owner Operate Functions
    function setPauseStatusEvent(uint256 eventId, bool isPause) external onlyOwner{
        require(eventStatusMap[eventId].isExist, "Event Status Not Exist");
        eventStatusMap[eventId].isPaused = isPause;
    }

    function setEmergencyWithdraw(uint256 eventId, bool allowEmergencyWithdraw) external onlyOwner{
        require(eventInfoMap[eventId].isExist, "Event Info Not  Exist");
        eventInfoMap[eventId].allowEmergencyWithdraw = allowEmergencyWithdraw;
    }

    function setTokenPerStake(uint256 eventId, uint256 numToken) external onlyOwner{
        require(eventInfoMap[eventId].isExist, "Event Info Not  Exist");
        eventInfoMap[eventId].numTokenPerStake = numToken;
    }

    function addEvent(uint256 eventId, uint256 startTime, uint256 endTime, uint256 period, uint256 maxAllEvent, bool allowEmergencyWithdraw, uint256 numTokenPerStake, uint256 rewardBox, uint256 rewardNum) external onlyOwner{
        require(!eventInfoMap[eventId].isExist, "Event Id Info Already Exist");
        require(!eventStatusMap[eventId].isExist, "Event Id Status Already Exist");
        
        EventInfo memory info =  EventInfo(eventId, startTime, endTime, period, maxAllEvent, allowEmergencyWithdraw, numTokenPerStake, rewardBox, rewardNum,true);
        EventStatus memory stat =  EventStatus(
                eventId,
                false ,
                0,
                0,
                true
            );
        eventInfoMap[eventId] = info;
        eventStatusMap[eventId] = stat;
        totalEvent++;
    }

    function removeEvent(uint256 eventId) external onlyOwner{
        delete eventInfoMap[eventId];
        delete eventStatusMap[eventId];
        totalEvent--;
    }
	
	
    function resetEvent(uint256 eventId) external onlyOwner{
        eventStatusMap[eventId].eventCounter = 0;
		eventStatusMap[eventId].boxClaimed = 0;
    }

    function removeStakeGM(uint256 eventId, address staker) external onlyOwner{
        require(stakeHolders[eventId][msg.sender].isExist,"User already not stake this event");
        delete stakeHolders[eventId][msg.sender];
        totalBoxCancel++;
        eventStatusMap[eventId].eventCounter--;
    }
    
    function addStakeGM(uint256 eventId, address staker) external onlyOwner returns(uint256){
       require(eventInfoMap[eventId].isExist, "Event  Info Not Exist");
       require(eventStatusMap[eventId].isExist, "Event  Status Not Exist");
       return _stake(eventId, staker);
    }


    //Stake to Event ID and return stakeId
    function stakeByEventId(uint256 eventId) nonReentrant whenNotPaused external returns(uint256){
        require(eventInfoMap[eventId].isExist, "Event Info Not Exist");
        require(eventInfoMap[eventId].startTime < block.timestamp, "Event Not Started Yet");
        require(eventInfoMap[eventId].endTime > block.timestamp, "Event Already Ended");

        require(eventStatusMap[eventId].isExist, "Event Status Not Exist");
        require(!eventStatusMap[eventId].isPaused, "Event Is Paused");
        require(eventStatusMap[eventId].eventCounter < eventInfoMap[eventId].maxAllEvent, "Event Is Fully Stacked");
        require(!stakeHolders[eventId][msg.sender].isExist,"User already stake this event");

        require (TOKENAddress.balanceOf(msg.sender) >= eventInfoMap[eventId].numTokenPerStake , "Not enough tokens to stake");
        require (TOKENAddress.transferFrom(msg.sender, address(this), eventInfoMap[eventId].numTokenPerStake), "Can not send token to smc");

        return _stake(eventId, msg.sender);
    }

    
    function _stake(uint256 eventId, address staker) internal returns(uint256){
        StakeInfo memory info =  StakeInfo(
                eventId,
                block.timestamp,
                block.timestamp +  eventInfoMap[eventId].period,
                eventInfoMap[eventId].numTokenPerStake,
                eventInfoMap[eventId].rewardBox,
                eventInfoMap[eventId].rewardNum,
                false,
                0,
                true
        );

        stakeHolders[eventId][staker] = info;
        eventStatusMap[eventId].eventCounter++;
        totalStake++;
        return eventStatusMap[eventId].eventCounter;
    }

    //Unstake By StakeID
    function unstake(uint256 eventId) nonReentrant whenNotPaused external {
        require(stakeHolders[eventId][msg.sender].isExist, "Stake Info Not Exist");
        require(stakeHolders[eventId][msg.sender].endTime <= block.timestamp, "Stake Not Ended Yet");
        require(!eventStatusMap[eventId].isPaused, "Event Is Paused");
        require(!stakeHolders[eventId][msg.sender].claimed, "Stake Already Claimed");
        _safeARKNTransfer(msg.sender, stakeHolders[eventId][msg.sender].numToken);
        _safeSendNFT(msg.sender, stakeHolders[eventId][msg.sender].rewardBox, stakeHolders[eventId][msg.sender].rewardNum);
        stakeHolders[eventId][msg.sender].claimed = true;
        stakeHolders[eventId][msg.sender].claimedAt = block.timestamp;
        eventStatusMap[eventId].boxClaimed++;
        totalBoxClaimed++;
    }

    //Unstake By StakeID
    function unstakeEmergency(uint256 eventId) nonReentrant whenNotPaused external {
        require(eventInfoMap[eventId].allowEmergencyWithdraw, "This Event is not support emergency withdraw");
        require(stakeHolders[eventId][msg.sender].isExist, "Stake Info Not Exist");
        require(!eventStatusMap[eventId].isPaused, "Event Is Paused");
        require(!stakeHolders[eventId][msg.sender].claimed, "Stake Already Claimed");
        _safeARKNTransfer(msg.sender, stakeHolders[eventId][msg.sender].numToken);

        if (stakeHolders[eventId][msg.sender].endTime <= block.timestamp) {
            _safeSendNFT(msg.sender, stakeHolders[eventId][msg.sender].rewardBox, stakeHolders[eventId][msg.sender].rewardNum);
            stakeHolders[eventId][msg.sender].claimed = true;
            eventStatusMap[eventId].boxClaimed++;
            totalBoxClaimed++;
        } else{
            delete stakeHolders[eventId][msg.sender];
            totalBoxCancel++;
            eventStatusMap[eventId].eventCounter--;
        }
    }

    function _safeSendNFT(address _to, uint256 nftid, uint256 amount) internal{
        //Send eip1155 token to _to
        IERC1155(NFTAddress).safeTransferFrom(address(this), _to, nftid, amount, "0x0");
    }

    function _safeARKNTransfer(address _to, uint256 _amount) internal {
        uint256 ARKNBal = TOKENAddress.balanceOf(address(this));
        if (_amount > ARKNBal) {
           TOKENAddress.transfer(_to, ARKNBal);
        } else {
           TOKENAddress.transfer(_to, _amount);
        }
    }

    function currentTime()  view public returns(uint256) {
        return block.timestamp;
    }
	
	function getUserStakeInfo(uint256 eventId,address _owner)  view public returns(uint256,uint256,uint256,uint256,uint256,uint256,bool, uint256) {

		if (stakeHolders[eventId][_owner].isExist){
            StakeInfo memory info = stakeHolders[eventId][_owner];
			return (info.eventId,
			info.startTime,
			info.endTime,
			info.numToken,
			info.rewardBox,
			info.rewardNum,
			info.claimed,
			info.claimedAt);
				
		}
        return (0,0,0,0,0,0,false,0);
    }

      //Get StakeInfo by StakeId
    function getUserStakeStatus(uint256 eventId)  view public returns(uint256,uint256) {
        return getUserStakeStatusCustom(eventId, msg.sender);
    }

    
      //Get StakeInfo by StakeId
    function getUserStakeStatusCustom(uint256 eventId,address _owner)  view public returns(uint256,uint256) {
        if (stakeHolders[eventId][_owner].isExist){
            if (stakeHolders[eventId][_owner].claimed){
                return (STATUS_STAKE_CLAIMED, stakeHolders[eventId][_owner].claimedAt);
            }
            if (stakeHolders[eventId][_owner].endTime <= block.timestamp){
                return (STATUS_STAKE_CAN_CLAIM, stakeHolders[eventId][_owner].endTime);
            }
            return (STATUS_STAKE_ON_GOING, stakeHolders[eventId][_owner].endTime);
        }
        return (STATUS_STAKE_NOT_STAKE,0);
    }
	
	function setArknAddresses(address nftNewAddress,IERC20 tokenNewAddress) public onlyOwner{
		NFTAddress = nftNewAddress;
		TOKENAddress = tokenNewAddress;
    }

	address NFTAddress = 0x83861d512713E6dF2d850D01Fcc8833901c16947; //testnet
    function getNFTTokenAddress() view public returns(address){
        return NFTAddress;
    }

    function setNFTTokenAddress(address newAddress) public onlyOwner{
        NFTAddress = newAddress;
    }

  
    //MAIN ARKN TOKEN OPERATION
    IERC20 TOKENAddress = IERC20(0xaA20c2e278D99f978989dAa4460F933745F862d5);

    function getMainTokenAddress() view public returns(IERC20){
        return TOKENAddress;
    }

    function setMainTokenAddress(IERC20 newAddress) public onlyOwner{
        TOKENAddress = newAddress;
    }
	
	function getBalanceMainToken() view public returns(uint256) {
        return TOKENAddress.balanceOf(address(this));
    }

    function withdrawMainToken() external onlyOwner {
        TOKENAddress.transfer(owner, getBalanceMainToken());
    }


    //CUSTOM ERC20 TOKEN OPERATION
	function withdrawCustomToken(IERC20 token) external onlyOwner {
      token.transfer(owner, getBalanceCustomToken(token));
    }

    function getBalanceCustomToken(IERC20 token) view public returns(uint256) {
        return token.balanceOf(address(this));
    }
	
    //WITDRAW ETH/BNB BALANCE
	function withdrawBalance() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}