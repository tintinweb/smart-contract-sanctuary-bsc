/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT

//    ____                   _               _    _                       _           _   _                  
//   |  _ \                 (_)             | |  | |                     | |         | | | |                 
//   | |_) |_   _ _ __ _ __  _ _ __   __ _  | |__| | ___  _ __ ___  ___  | |     ___ | |_| |_ ___ _ __ _   _ 
//   |  _ <| | | | '__| '_ \| | '_ \ / _` | |  __  |/ _ \| '__/ __|/ _ \ | |    / _ \| __| __/ _ | '__| | | |
//   | |_) | |_| | |  | | | | | | | | (_| | | |  | | (_) | |  \__ |  __/ | |___| (_) | |_| ||  __| |  | |_| |
//   |____/ \__,_|_|  |_| |_|_|_| |_|\__, | |_|  |_|\___/|_|  |___/\___| |______\___/ \__|\__\___|_|   \__, |
//                                    __/ |                                                             __/ |
//                                   |___/                                                             |___/ 

// File: ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
// File: Address.sol


// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


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

// File: IERC20.sol


// OpenZeppelin Contracts v4.3.2 (token/ERC20/IERC20.sol)

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
    
    

    function burn(uint256 amount) external returns(bool);

    function lotteryTransfer(address recipient, uint256 amount) external returns (bool);


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
// File: SafeERC20.sol


// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



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
// File: IRandomGenerator.sol



pragma solidity ^0.8.14;

interface IRandomGenerator {

    function getRandomNumber(uint256 _seed) external returns(uint);

}
// File: IBurningHorse.sol


// BurningHorse                                         //place for social etc

pragma solidity ^0.8.0;

interface IBurningHorse {

    function balanceOf(address account) external view returns (uint256);
    
    function burn(uint256 amount) external returns(bool);

    function mint(address account, uint256 amount) external;

    function lotteryTransfer(address recipient, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function viewBurningPercentage() external returns (uint256);
}
// File: SafeMath.sol



pragma solidity ^0.8.0;

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
// File: Ownable.sol


pragma solidity ^0.8.0;

/**
* @notice Contract is a inheritable smart contract that will add a 
* New modifier called onlyOwner available in the smart contract inherting it
* 
* onlyOwner makes a function only callable from the Token owner
*
*/
contract Ownable {
    // _owner is the owner of the Token
    address private _owner;

    /**
    * Event OwnershipTransferred is used to log that a ownership change of the token has occured
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * Modifier
    * We create our own function modifier called onlyOwner, it will Require the current owner to be 
    * the same as msg.sender
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: only owner can call this function");
        // This _; is not a TYPO, It is important for the compiler;
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    /**
    * @notice owner() returns the currently assigned owner of the Token
    * 
     */
    function owner() public view returns(address) {
        return _owner;

    }
    /**
    * @notice renounceOwnership will set the owner to zero address
    * This will make the contract owner less, It will make ALL functions with
    * onlyOwner no longer callable.
    * There is no way of restoring the owner
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @notice transferOwnership will assign the {newOwner} as owner
    *
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    /**
    * @notice _transferOwnership will assign the {newOwner} as owner
    *
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }



}
// File: Pausable.sol


pragma solidity ^0.8.0;



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
// File: BurningHorseLottery_v1.sol


pragma solidity ^0.8.14;

contract BurningHorseLottery is Ownable, Pausable, ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IBurningHorse;
    using SafeERC20 for IERC20;

    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
    
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    modifier onlyModerator() {
        require(_moderator == msg.sender, "Only moderator can call this function");
        _;
    }

    event DrawLotteryRound (uint round, uint256 winAmount);
    event BuyTickets (address buyer, uint256 ticketsNum);
    event ClaimTicket (uint ticketRound, address winAddr, uint256 winAmount);
    event InjectBRHS (address injector, uint256 injectedValue);
    event ModeratorshipTransferred(address newModerator);
    event NewRandomGenerator(address newRandomGenerator);

    uint private numberOfParticipants;
    uint private maxDiscountPercent;
    uint256 private ticketPrice;
    uint256 private collectedFee;
    uint256 round;
    uint256 public feePercent;
    uint256 maxTicketsForOneBuy;
    uint256 public NFTDiscountPerc; 
    uint256 winnerReward;
    uint256[] winNumber;
    uint[] winNumbers = new uint[](3);
    address payable[] participants;
    address brhsToken = 0x68FD3bDaf70bd14828bab06d5BF854349d1F4aE6;
    address public randGenAddr;
    address discountNFTAddr;
    address private _moderator;    
    address[] winnersArr; 
    address[] winAddresses = new address[](3);

    bool public lotteryStatus;
    
    struct Winner{
        address[] winnersArr;
        uint256[] winNumber;
        uint256 winTime;
        uint256 amount_won;
        uint256 amount_burned;
    }

    struct WinTickets{
        uint256 winTicketNumber;
        address ticketOwner;
        uint256 amountToClaim;
    }

    mapping(uint256 => uint256) collectedBRHSforRound;
    mapping(uint256 => mapping(address => uint256[])) roundTickets;
    mapping(uint256 => mapping(uint256 => WinTickets)) roundWinTickets;
    mapping(uint256 => mapping(address => bool)) isParticipant;
    mapping(uint => uint[]) winNumbersHistory;
    mapping(uint => address[]) winAddressesHistory;
    mapping(address => uint256[]) userWinningRounds;

    function getRoundTickets(uint256 _round, address _user) external view returns (uint256[] memory) {
        return roundTickets[_round][_user];
    }

    function myTickets() public view returns(uint256[] memory){
        return roundTickets[round][msg.sender];
    }

    function myTicketsNumber() public view returns(uint){
        return roundTickets[round][msg.sender].length;
    }

    function getUserWinnedRounds(address _user) external view returns (uint256[] memory) {
        return userWinningRounds[_user];
    }

    function getWinTickets(uint _round, uint _serialNumberOfWinner) external view returns (uint256 winTicketNum, uint256 AmountToClaim) {
        return (roundWinTickets[_round][_serialNumberOfWinner].winTicketNumber, roundWinTickets[_round][_serialNumberOfWinner].amountToClaim);
    }
    
    mapping(uint256 => Winner) public winners;
    
    function addWinner(uint256 _round, uint256 _winTime, uint256 amountWon, uint256 amountBurned) internal{
        winners[_round].winTime = _winTime;
        winners[_round].amount_won = amountWon;
        winners[_round].amount_burned = amountBurned;
    }
    
    
    constructor(){  
        ticketPrice = 200*10**8;
        winnerReward = 5000 * 1e8;
        round = 1;
        feePercent = 5;
        NFTDiscountPerc = 10;
        maxTicketsForOneBuy = 10;
        maxDiscountPercent = 5;
        collectedFee = 0;
        lotteryStatus = true;
        randGenAddr = 0x27C2EE68CA358d8Def2a5EAf8A60395c20BEe517;
        discountNFTAddr = 0x480Eb690b4fe9b8A565e48819682966fAf9011c6;
    }

        
    IBurningHorse token = IBurningHorse(brhsToken);


    function setTicketPrice(uint _valueInEther) external onlyOwner{
        require(_valueInEther != 0, "Ticket Price cannot be zero");
        ticketPrice = (_valueInEther * 10**8);
    }
    
    function setMaxTicketsForOneBuy(uint _maxTicketsForOneBuy) external onlyOwner{
        require(_maxTicketsForOneBuy > 0, "Cannot be zero");
        maxTicketsForOneBuy = _maxTicketsForOneBuy;
    }
    
    function setFeePercent(uint _feePercent) external onlyOwner{
        feePercent = _feePercent;
    }    

    function setMaxDiscountPercent(uint _maxDiscountPercent) external onlyOwner{
        maxDiscountPercent = _maxDiscountPercent;
    } 

    function setNFTDiscountPercent(uint256 _NFTDiscountPercent) external onlyOwner{
        NFTDiscountPerc = _NFTDiscountPercent;
    }

    function setRandomGeneratorAddress(address _newRandomGeneratorAddress) external onlyOwner{
        randGenAddr = _newRandomGeneratorAddress;
        emit NewRandomGenerator(_newRandomGeneratorAddress);
    }

    function setDiscountNFTAddress(address _newdiscountNFTAddress) external onlyOwner{
        discountNFTAddr = _newdiscountNFTAddress;
    }

    function setModerator(address _address) public onlyOwner{
        _moderator = _address;
        emit ModeratorshipTransferred(_address);
    }
    
    function viewTicketPrice() external view returns(uint256){
        return ticketPrice;
    }
    
    function viewMaxTicketsForOneBuy() external view returns(uint256){
        return maxTicketsForOneBuy;
    }
        
    function viewNumberOfParticipants() external view returns(uint){
        return numberOfParticipants;
    }
    
    function viewLottery() external view returns(uint256 TiketPrice, uint256 NumberOfParticipants, uint256 CurrentRound, uint256 MaxTicketsForOneBuy,
                                                 uint discountPerc, uint256 rewardForOne){
        return(ticketPrice, numberOfParticipants, round, maxTicketsForOneBuy, maxDiscountPercent, winnerReward);
    }

    function viewCollectedBRHSforRound(uint _round) external view returns(uint256 BRHSForRound){
        return(collectedBRHSforRound[_round]);
    }

    function viewCollectedFee() public view onlyOwner returns(uint256){
        return collectedFee;
    }

    function viewWinNumbersHistory(uint _round) external view returns(uint256[] memory){
        return(winNumbersHistory[_round]);
    }

    function viewWinAddressesHistory(uint _round) external view returns(address[] memory){
        return(winAddressesHistory[_round]);
    }
    
    function viewIsParticipant(address _participant) public view returns(bool){
        return isParticipant[round][_participant];
    }
    
    function setRoundReward(uint256 _rewardInBRHS) external onlyModerator{
        winnerReward = _rewardInBRHS * 10**8;
    }

    /**
    *  @notice The blacklist is a precautionary measure in case of attacks.
    *  Closes access to lottery.
    *  Do not try to harm and you will not get here :)
    */

    mapping(address => bool) private blacklist;

    function addToBlacklist(address _address) external onlyOwner{
        require(!blacklist[_address], "Already in blacklist");
        blacklist[_address] = true;
    }

    function removeFromBlacklist(address _address) external onlyOwner{
        require(blacklist[_address], "Not in blacklist");
        blacklist[_address] = false;
    }

    function participantTickets(address _participant) public view returns(uint){
        uint i = 0;
        uint ticketsNum = 0;
        uint numOfPart = participants.length;
        for(i; i<numOfPart; ++i){
            if(participants[i] == _participant){
                ticketsNum++;
            }
        }
        return(ticketsNum);
    }
    
    function buyTickets(uint256 numOfTickets) public notContract nonReentrant whenNotPaused{
        require(numOfTickets <= maxTicketsForOneBuy, "Cannot buy more than allowed for one time");
        require(numOfTickets > 0, "Cannot buy zero");
        require(lotteryStatus, "The new round hasn't started yet");
        require(msg.sender != address(0), "Cannot buy from zero address");
        require(!blacklist[msg.sender], "Access denied");
        
        IERC721 discountNFT = IERC721(discountNFTAddr);
        uint i = 0;
        uint tokensForBuy;
        for(i; i < numOfTickets; ++i){
            participants.push(payable(msg.sender));
            roundTickets[round][msg.sender].push(numberOfParticipants + i + 1);
        }
        numberOfParticipants += numOfTickets;

        (numOfTickets == 1) ? tokensForBuy = ticketPrice * numOfTickets : tokensForBuy = (ticketPrice * numOfTickets * (100000 - maxDiscountPercent*1000/maxTicketsForOneBuy * numOfTickets))/100000;
        
        if(discountNFT.balanceOf(msg.sender) > 0) tokensForBuy = (tokensForBuy * (100 - NFTDiscountPerc)) / 100 ;
        
        token.transferFrom(payable(msg.sender), address(this), tokensForBuy);
        collectedBRHSforRound[round] += tokensForBuy;

        isParticipant[round][msg.sender] = true;
        emit BuyTickets(msg.sender, numOfTickets);
    
    }

    function checkIfIAvailableToClaim(uint _round) public view returns(uint256 TicketSlot, uint256 AvailableToClaim){
        uint i = 0;
        for(i; i<3; ++i){
            if(roundWinTickets[_round][i].ticketOwner == msg.sender && roundWinTickets[_round][i].amountToClaim != 0){
                return(i, roundWinTickets[_round][i].amountToClaim);
            }
        }
    }

    function claimTicket(uint _round) external notContract nonReentrant{
        require(_round < round, "This round is not over yet");
        uint256 rewardToSend;
        uint256 ticketSlot;
        (ticketSlot, rewardToSend) = checkIfIAvailableToClaim(_round);
        require(rewardToSend != 0, "Nothing to claim");

        token.lotteryTransfer(msg.sender, rewardToSend);
        roundWinTickets[_round][ticketSlot].amountToClaim = 0;

        emit ClaimTicket(_round, msg.sender, rewardToSend);
    }
   
    function startNewRound(uint256 _oneWinnerRewardForNextRoundInEther) public onlyModerator{
        require(!lotteryStatus, "The previous round has not been drawn yet");
        winnerReward = _oneWinnerRewardForNextRoundInEther * 1e8;
        lotteryStatus = true;
    }
    
    function closeRound() external onlyModerator nonReentrant{
        uint256 fee = collectedBRHSforRound[round] * feePercent / 100;
        require(collectedBRHSforRound[round] >= (winnerReward * 3 + fee), "Not enough tokens");
        uint256 amount_to_burn = collectedBRHSforRound[round] - (winnerReward * 3 + fee);

        IRandomGenerator randGen = IRandomGenerator(randGenAddr);
        uint rand = randGen.getRandomNumber(uint256(keccak256(abi.encodePacked(round, numberOfParticipants, collectedBRHSforRound[round], block.difficulty))));
        uint i = 0;
        uint j = (rand % 25) + 1;

        for(i; i<3; ++i){
            winNumbers[i] = (rand / j % numberOfParticipants) + 1;
            winAddresses[i] = participants[winNumbers[i]];
            roundWinTickets[round][i].winTicketNumber = winNumbers[i];
            roundWinTickets[round][i].ticketOwner = participants[winNumbers[i]];
            roundWinTickets[round][i].amountToClaim = winnerReward;
            userWinningRounds[roundWinTickets[round][i].ticketOwner].push(round);

            j*=3;
        }

        winNumbersHistory[round] = winNumbers;
        winAddressesHistory[round] = winAddresses;
        collectedFee += fee;
        token.burn(amount_to_burn);

        addWinner(round, block.timestamp, winnerReward, amount_to_burn); 
        emit DrawLotteryRound (round, winnerReward*3);

        delete participants;
        numberOfParticipants = 0;
        winnerReward = 0;
        round++;

        lotteryStatus = false;
    }

    function injectBRHSForCurrentRound(uint256 _tokensToInjectInEther, uint256 _shouldRewardIncrease) public {
        require(lotteryStatus, "The new round hasn't started yet");
        uint256 tokensToInjectDecimals = _tokensToInjectInEther * 10**8;
        
        token.transferFrom(payable(msg.sender), address(this), tokensToInjectDecimals);
        collectedBRHSforRound[round] += tokensToInjectDecimals;

        if(_shouldRewardIncrease == 1) winnerReward += tokensToInjectDecimals / 3;
        
        emit InjectBRHS (msg.sender, tokensToInjectDecimals);
    }

    function injectBRHSForCurrentRoundFromLotteryContract(uint256 _tokensToInjectInBRHS, uint256 _shouldRewardIncrease) external onlyOwner{
        require(lotteryStatus, "The new round hasn't started yet");
        require(_tokensToInjectInBRHS != 0, "Cannot inject zero");
        uint256 tokensToInjectDecimals = _tokensToInjectInBRHS * 10**8;
        require(_tokensToInjectInBRHS <= collectedFee, "You can inject only fee tokens");
        collectedBRHSforRound[round] += tokensToInjectDecimals;
        collectedFee -= tokensToInjectDecimals;

        if(_shouldRewardIncrease == 1) winnerReward += tokensToInjectDecimals / 3;
        
        emit InjectBRHS (address(this), tokensToInjectDecimals);
    }
    
    function transferWrongToken(address _token, uint256 _amount) external onlyOwner{
        require(_token != brhsToken, "The returned token cannot be BRHS token");
        require(_token != address(0), "The returned token cannot be zero address");
        IERC20 tokenToReturn = IERC20(address(_token));
        tokenToReturn.transfer(payable(msg.sender), _amount);
    }

    function transferFeeTokens(uint256 _amountWithDecimals) external onlyOwner{
        require(_amountWithDecimals != 0, "Cannot transfer zero");
        require(_amountWithDecimals <= collectedFee, "You can transfer only fee tokens");
        token.transfer(payable(msg.sender), _amountWithDecimals);
        collectedFee -= _amountWithDecimals;
    }
    
    function withdraw(uint256 amount) public onlyOwner{
        payable(owner()).transfer(amount);
    }
    
}