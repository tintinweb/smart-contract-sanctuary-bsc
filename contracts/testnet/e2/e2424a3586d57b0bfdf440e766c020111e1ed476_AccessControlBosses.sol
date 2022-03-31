/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// Sources flattened with hardhat v2.9.1 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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


// File @openzeppelin/contracts/utils/introspection/[email protected]

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


// File @openzeppelin/contracts/token/ERC721/[email protected]

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


// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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


// File @openzeppelin/contracts/utils/structs/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


// File contracts/AccessControlBosses.sol

pragma solidity ^0.8.6;

contract AccessControlBosses {

    /**
     * @notice Shows that the user with specified address received a certain role.
     * @param role is a new role of user.
     * @param user is an address of user.
     */
    event DeputeBoss(Roles role, address user);
    
    /**
     * @notice Shows that the user with specified address lost a certain role.
     * @param role is a lost role of user.
     * @param user is an address of user.
     */
    event RemoveBoss(Roles role, address user);
    
    address public owner;
    address public boss1;
    address public boss2;
    enum Roles{EMPTY, BOSS4, BOSS3, BOSS2, BOSS1, OWNER}
    mapping (address => Roles) roles;

    modifier onlyBoss1_2() {
        require(check_BOSS_1_2(msg.sender), "User doesnt have enough rights");
        _;
    }

    modifier checkAddress(address _user) {
        require(_user != address(0), "Zero address shouldnt have any role");
        require(_user != address(this), "This contract shouldnt have any role");
        require(roles[_user] == Roles.EMPTY, "This address already have some role");
        _;
    }

    constructor(address _boss1, address _boss2) {
        require((_boss1 != _boss2) && (_boss1 != msg.sender) && (_boss2 != msg.sender), "Doesnt enough addresses to appointment primal roles");
        roles[msg.sender] = Roles.OWNER;
        roles[_boss1] = Roles.BOSS1;
        roles[_boss2] = Roles.BOSS2;
        boss1 = _boss1;
        boss2 = _boss2;
        owner = msg.sender;
    }

    /**
     * @notice Shows whether the user matches the role category (Boss1, Boss2).
     * @param _user is the address of specific user.
     */
    function check_BOSS_1_2(address _user) public view returns(bool) {
        require((roles[_user] == Roles.BOSS1) || (roles[_user] == Roles.BOSS2), "User doesnt have enough rights");
        return true;
    }

    /**
     * @notice Shows whether the user matches the role category (Boss1, Boss2, Owner).
     * @param _user is the address of specific user.
     */
    function check_BOSS_1_2_OWNER(address _user) public view returns(bool) {
        require((roles[_user] != Roles.EMPTY) && (roles[_user] != Roles.BOSS4) && (roles[_user] != Roles.BOSS3), "User doesnt have enough rights");
        return true;
    }

    /**
     * @notice Shows whether the user matches the role category (Boss1, Boss2, Boss3, Owner).
     * @param _user is the address of specific user.
     */
    function check_BOSS_1_2_3_OWNER(address _user) external view returns(bool) {
        require((roles[_user] != Roles.EMPTY) && (roles[_user] != Roles.BOSS4), "User doesnt have enough rights");
        return true;
    }

    /**
     * @notice Shows whether the user matches the role category (Boss1, Boss2, Boss3, Boss4, Owner).
     * @param _user is the address of specific user.
     */
    function check_BOSS_1_2_3_4_OWNER(address _user) external view returns(bool) {
        require((roles[_user] != Roles.EMPTY), "User doesnt have enough rights");
        return true;
    }

    /**
     * @notice Shows whether the user matches the role category (Boss1, Boss2, Boss3, Boss4, Owner).
     * @param _user is the address of specific user.
     * @return Role - user's role.
     */
    function getRole(address _user) public view returns(Roles){
        return roles[_user];
    }

    /**
     * @notice Allows certain users to change a new user with the BOSS1 role.
     * @param _user is the address of specific user.
     */
    function deputeBoss1(address _user) external onlyBoss1_2() checkAddress(_user) {
        roles[boss1] = Roles.EMPTY;
        emit RemoveBoss(Roles.BOSS1, boss1);
        boss1 = _user;
        roles[boss1] = Roles.BOSS1;
        emit DeputeBoss(Roles.BOSS1, _user);
    }

    /**
     * @notice Allows certain users to change a new user with the BOSS2 role.
     * @param _user is the address of specific user.
     */
    function deputeBoss2(address _user) external onlyBoss1_2() checkAddress(_user) {
        roles[boss2] = Roles.EMPTY;
        emit RemoveBoss(Roles.BOSS2, boss2);
        boss2 = _user;
        roles[boss2] = Roles.BOSS2;
        emit DeputeBoss(Roles.BOSS2, _user);
    }

    /**
     * @notice Allows certain users to change a new user with the OWNER role.
     * @param _user is the address of specific user.
     */
    function deputeOwner(address _user) external checkAddress(_user) {
        require((roles[msg.sender] == Roles.OWNER), "User doesnt have enough rights");
        roles[owner] = Roles.EMPTY;
        emit RemoveBoss(Roles.OWNER, owner);
        owner = _user;
        roles[owner] = Roles.OWNER;
        emit DeputeBoss(Roles.OWNER, _user);
    }

    /**
     * @notice Allows certain users to depute a new users with the BOSS3 role.
     * @param _users is the array addresses of specific users.
     */
    function deputeBoss3(address[] calldata _users) external onlyBoss1_2() {
        _deputeBossMass(_users, Roles.BOSS3);
    }

    /**
     * @notice Allows certain users to depute a new users with the BOSS4 role.
     * @param _users is the array addresses of specific users.
     */
    function deputeBoss4(address[] calldata _users) external {
        require(check_BOSS_1_2_OWNER(msg.sender), "User doesnt have enough rights");
        _deputeBossMass(_users, Roles.BOSS4);
    }

    function _deputeBossMass(address[] calldata _users, Roles _role) internal {
        for (uint256 i = 0; i < _users.length; i++) 
        {
            require(roles[_users[i]] == Roles.EMPTY, "This address already have some role");
            roles[_users[i]] = _role;
            emit DeputeBoss(_role, _users[i]);
        }
    }

    /**
     * @notice Allows certain users to remove the BOSS3 role from users with a specific address.
     * @param _users is the array addresses of specific users.
     */
    function removeBoss3(address[] calldata _users) external onlyBoss1_2() {
        _removeBossMass(_users, Roles.BOSS3);
    }
   
    /**
     * @notice Allows certain users to remove the BOSS4 role from users with a specific address.
     * @param _users is the array addresses of specific users.
     */
    function removeBoss4(address[] calldata _users) external {
        require(check_BOSS_1_2_OWNER(msg.sender), "User doesnt have enough rights");
        _removeBossMass(_users, Roles.BOSS4);
    }

    function _removeBossMass(address[] calldata _users, Roles _role) internal {
        for (uint256 i = 0; i < _users.length; i++) 
        {
            require(roles[_users[i]] == _role, "This address doesnt have the required role");
            roles[_users[i]] = Roles.EMPTY;
            emit RemoveBoss(_role, _users[i]);
        }
    }

}


// File contracts/ILiquidityProvider.sol

pragma solidity ^0.8.6;





interface ILiquidityProvider{

    /**
     * @notice Shows that contract have a new minimum stake for accrual of referral bonus .
     * @param minimumStake is a new minimum stake.
     */
    event NewMinimumStake(uint256 minimumStake);
    
    /**
     * @notice Shows that the contract have a new minimum liquidity.
     * @param minimumLiquidity is a new minimum liquidity.
     */
    event NewMinimumLiquidity(uint256 minimumLiquidity);
    
    /**
     * @notice Shows that the contract have a new fees for open and close stake.
     * @param openFee is a new fee to open stake.
     * @param closeFee is a new fee to close stake.
     */
    event NewFees(uint256 openFee, uint256 closeFee);
    
    /**
     * @notice Shows that the contract have a new referral bonus percentages.
     * @param refLevel1 is a new referral bonus percentages for first referral link.
     * @param refLevel2 is a new referral bonus percentages for second referral link.
     * @param refLevel3 is a new referral bonus percentages for third referral link.
     */
    event NewReferralRate(uint256 refLevel1, uint256 refLevel2, uint256 refLevel3);
    
    /**
     * @notice Shows that the contract have a new interest rate for next reward day.
     * @param interestRate is a new interest rate.
     */
    event NewInterestRate(uint256 interestRate);
    
    /**
     * @notice Shows that the contract change stake mode.
     * @param liquidity is the stake mode.
     */
    event SwitchLiquidity(bool liquidity);
    
    /**
     * @notice Shows that the some user stake some tokens to a lock period.
     * @param user is an address of user.
     * @param amount is an amount of stake.
     * @param ref1 is an address of user's first referral.
     * @param ref2 is an address of user's second referral.
     * @param ref3 is an address of user's third referral.
     * @param endTime is the end of user's lock period.
     */
    event ProvideLiquidity(address user, uint256 amount, address ref1, address ref2, address ref3, uint256 endTime);
    
    /**
     * @notice Shows that the some user withdrawn some tokens from his balance.
     * @param user is the address of user.
     * @param amount is an amount of withdrawn tokens.
     */
    event WithdrawLiquidity(address user, uint256 amount);
    
    /**
     * @notice Shows that the some user extended some tokens from his balance to 11 month.
     * @param user is the address of user.
     * @param amount is an amount of extended tokens.
     * @param endTime is the end of user's new lock period.
     */
    event ExtendLiquidity(address user, uint256 amount, uint256 endTime);
    
    /**
     * @notice Shows that the some user withdrawn some tokens from his reward balance.
     * @param user is the address of user.
     * @param amount is an amount of withdrawn tokens.
     * @param remainder is the remainder on users reward balance.
     */
    event RewardsWithdraw(address user, uint256 amount, uint256 remainder);
    
    /**
     * @notice Shows that the some user stake some tokens from his reward balance.
     * @param user is the address of user.
     * @param amount is an amount of staked tokens.
     * @param remainder is the remainder on users reward balance.
     */
    event RewardsToLiquidity(address user, uint256 amount, uint256 remainder);
    
    /**
     * @notice Shows that the some user withdrawn some tokens from his referral balance.
     * @param user is the address of user.
     * @param amount is an amount of withdrawn tokens.
     * @param remainder is the remainder on users referral balance.
     */
    event ReferralWithdraw(address user, uint256 amount, uint256 remainder);
    
    /**
     * @notice Shows that the some user stake some tokens from his referral balance.
     * @param user is the address of user.
     * @param amount is an amount of staked tokens.
     * @param remainder is the remainder on users referral balance.
     */
    event ReferralToLiquidity(address user, uint256 amount, uint256 remainder);
    
    /**
     * @notice Shows that the some user withdrawn some tokens from distribution balance.
     * @param user is the address of user.
     * @param amount is an amount of withdrawn tokens.
     */
    event DistributionWithdraw(address user, uint256 amount);
    
    /**
     * @notice Shows that the some user deposited some tokens to distribution balance.
     * @param user is the address of user.
     * @param amount is an amount of deposited tokens.
     */
    event DistributionDeposit(address user, uint256 amount);
    
    /**
     * @notice Shows that a certain number of users have been whitelisted .
     * @param userAddresses is the address array of user.
     */
    event Whitelist(address[] userAddresses);
    
    /**
     * @notice Shows that a certain number of users have been waitlisted .
     * @param userAddresses is the address array of user.
     */
    event WaitList(address[] userAddresses);
    
    /**
     * @notice Shows that a certain number of users have been blacklisted .
     * @param userAddresses is the address array of user.
     */
    event BlackList(address[] userAddresses);
    
    /**
     * @notice Shows that a certain number of users have been removed from blacklist .
     * @param userAddresses is the address array of user.
     */
    event UnblackList(address[] userAddresses);
    
    /**
     * @notice Shows that data from one specific address has been moved to another specific address. 
     * @param oldAddress is the old address of user.
     * @param newAddress is the new address of user.
     */
    event AccountTransfer(address oldAddress, address newAddress);

    /**
     * @notice Shows that the some reward day has been moved to another day.
     * @param oldRewardDay is the old reward day.
     * @param newRewardDay is the new reward day.
     */
    event EditRewardDate(uint256 oldRewardDay, uint256 newRewardDay);
    
    /**
     * @notice Shows that the some user withdrawn some tokens from fee balance.
     * @param user is the address of user.
     * @param amount is an amount of withdrawn tokens.
     */
    event FeeWithdraw(address user, uint256 amount);
    
    /**
     * @notice Shows that the address of contract to access control has been change_d.
     * @param accessControl is the address of contract to access control.
     */
    event ChangeAccessControl(address accessControl);

    struct InterestRate {
        uint256 start;
        uint256 end;
        uint256 value;
    }

    struct Account {
        uint256 balance; 
        uint256 referralBalance; 
        uint256 rewardBalance; 
        uint256 depositeTime; 
        uint256 startTime; 
        uint256 endTime; 
        uint256 lastActive;
        uint256 accumulate;
        uint256 calcReward;
        bool lock; 
    }

    struct User {
        address userAddress;
        uint256 balance;
        uint256 startTime;
        uint256 endTime;
    }

    /**
     * @notice Allows the user to set a new minimum stake for accrual of referral bonus .
     * @dev It is standart set function. 
     * @param _minimumStake is a new minimum stake.
     */
    function setMinimumStake(uint256 _minimumStake) external;

    /**
     * @notice Allows the user to set a new minimum liquidity.
     * @dev It is standart set function. 
     * @param _minimumLiquidity is a new minimum liquidity.
     */
    function setMinimumLiquidity(uint256 _minimumLiquidity) external;

    /**
     * @notice Allows the user to stake some tokens to a lock period.
     * @dev With an already active stake from the called address, is called a utility function for an additional stake. 
     * @param _amount is an amount of stake.
     * @param _ref1 is an address of user's first referral.
     * @param _ref2 is an address of user's second referral.
     * @param _ref3 is an address of user's third referral.
     */
    function provideLiquidity(uint256 _amount, address _ref1, address _ref2, address _ref3) external;

    /**
     * @notice Allows the user to set a new fees for open and close stake.
     * @dev It is standart set function. 
     * @param _openFee is a new fee to open stake.
     * @param _closeFee is a new fee to close stake.
     */
    function setFees(uint256 _openFee, uint256 _closeFee) external;

    /**
     * @notice Allows the user to set a new referral bonus percentages.
     * @dev It is standart set function. 
     * @param _refLevel1 is a new referral bonus percentages for first referral link.
     * @param _refLevel2 is a new referral bonus percentages for second referral link.
     * @param _refLevel3 is a new referral bonus percentages for third referral link.
     */
    function setReferralRate(uint256 _refLevel1, uint256 _refLevel2, uint256 _refLevel3) external;

    /**
     * @notice Allows the user to set a new interest rate for next reward day.
     * @dev It is standart set function. 
     * @param _interestRate is a new interest rate.
     */
    function setInterestRate(uint256 _interestRate) external;

    ///@notice Allows the user to change the stake mode.
    function switchLiquidity() external;

    /**
     * @notice Allows the user to set a new interest rate for next reward day.
     * @dev It is standart set function. Values are written to a new element of the structure with the beginning and end for accruals.
     * @param _userAddresses is a new interest rate.
     * @param _userAddresses is a new interest rate.
     */
    function setLockPeriod(address[] calldata _userAddresses, uint256 _newLockPeriod) external;

    /**
     * @notice Allows the user to withdraw some tokens from his balance.
     * @dev The calculation function is only run when the user's status is normal. 
     * @param _amount is an amount of tokens to withdraw.
     */
    function withdrawLiquidity(uint256 _amount) external;

    /**
     * @notice Allows the user to extend some tokens from his balance to 11 month.
     * @dev Function is only run when the user's status is normal. 
     * @param _amount is an amount of tokens to extend.
     */
    function extendLiquidity(uint256 _amount) external;

    /**
     * @notice Allows the user to withdraw some tokens from his reward balance.
     * @dev The calculation function is only run when the user's status is normal. 
     * @param _amount is an amount of tokens to withdraw.
     */
    function rewardsWithdraw(uint256 _amount) external;

    /**
     * @notice Allows the user to stake some tokens from his reward balance.
     * @dev Function is only run when the user's status is normal. 
     * @param _amount is an amount of tokens to stake.
     */
    function rewardsToLiquidity(uint256 _amount) external;

    /**
     * @notice Allows the user to withdraw some tokens from his referral balance.
     * @param _amount is an amount of tokens to withdraw.
     */
    function referralWithdraw(uint256 _amount) external;

    /**
     * @notice Allows the user to stake some tokens from his referral balance.
     * @dev Function is only run when the user's status is normal. 
     * @param _amount is an amount of tokens to stake.
     */
    function referralToLiquidity(uint256 _amount) external;

    /**
     * @notice Allows the user to withdraw some tokens from distribution balance.
     * @dev The function can only be used with certain roles and with a positive distribution balance 
     * @param _amount is an amount of tokens to withdraw.
     */
    function distributionWithdraw(uint256 _amount) external;

    /**
     * @notice Allows the user to deposite some tokens to distribution balance.
     * @param _amount is an amount of tokens to deposite.
     */
    function distributionDeposit(uint256 _amount) external;

    /**
     * @notice Allows the user to transfer data from one specific address to another specific address. 
     * @dev The function is only for transferring to a previously unused address. Otherwise, use the function setAccount. 
     * @param _from is the old address of user.
     * @param _to is the new address of user.
     */
    function accountTransfer(address _from, address _to) external;

    /**
     * @notice Allows the user to transfer some erc20 tokens to specific address of some specific contrat address. 
     * @dev Function for displaying randomly credited tokens. 
     * @param _token is the contract address of erc20 token.
     * @param _recipient is the address of recipient.
     */
    function erc20Withdraw(address _token, address _recipient) external;

    // /**
    //  * @notice Allows the user to transfer some erc721 tokens to specific address of some specific contrat address. 
    //  * @dev Function for displaying randomly credited tokens. 
    //  * @param _token is the contract address of erc721 token.
    //  * @param _recipient is the address of recipient.
    //  */
    // function erc721Withdraw(address _token, address _recipient) external;

    /**
     * @notice Allows the user to whitelist (close the lock period with the current time) a certain number of users.
     * @param _userAddresses is the address array of user.
     */
    function whitelist(address[] calldata _userAddresses) external;

    /**
     * @notice Allows the user to add data of users to specific addresses.
     * @dev The function is only for transferring to a previously unused address. Otherwise, use the function setAccount. 
     * @param _users is the data array of adeed users.
     */
    function addLiquidity(User[] memory _users) external;

    /**
     * @notice Allows the user to waitlist (suspend award payments) a certain number of users.
     * @param _userAddresses is the address array of user.
     */
    function waitList(address[] calldata _userAddresses) external;

    /**
     * @notice Allows the user to blacklist (suspend award payments and block access to function) a certain number of users.
     * @param _userAddresses is the address array of user.
     */
    function blacklist(address[] calldata _userAddresses) external;

    /**
     * @notice Allows the user to unblacklist (resume award payments and unblock access to function) a certain number of users.
     * @param _userAddresses is the address array of user.
     */
    function unblacklist(address[] calldata _userAddresses) external;

    /**
     * @notice Shows the total stakes of all users.
     * @dev It is standart get function. 
     * @return liquidityBalance - total stakes of all users.
     */
    function allOnLiquidityBalance() view external returns(uint256);

    /**
     * @notice Shows the end of the user's loсk period with a specific address.
     * @dev It is standart get function. 
     * @param _user is the address of specific user .
     * @return endTime - end of the user's loсk period.
     */
    function getLockPeriod(address _user) view external returns(uint256);

    /**
     * @notice Shows the last set interest rate in qwarter.
     * @dev It is standart get function. Get only last interest rate.
     * @return value - last set interest rate in qwarter.
     */
    function getInterestRate() view external returns(uint256);

    /**
     * @notice Shows the last set interest rate in day.
     * @dev It is standart get function. 
     * @return value - last set interest rate in day.
     */
    function getInterestRateInDay() view external returns(uint256);

    /**
     * @notice Shows the data of user with some specific address.
     * @dev It is standart get function. 
     * @param _user is the address of user.
     * @return account - data of user with some specific address.
     */
    function getAccount(address _user) view external returns(Account memory);

    /**
     * @notice Allows the user to add data of user to specific address.
     * @dev It is standart set function. The function for displaying randomly credited tokens is used to edit the data of a specific user. 
     * @param _user is the address of adeed user.
     * @param _account is the data of adeed user.
     */
    function setAccount(address _user, Account calldata _account) external;

    /**
     * @notice Allows the user to add elements into an array of dates according to the number of specified quarters.
     * @param _amount is the address array of user.
     */
    function plusQuarters(uint256 _amount) external;

    /**
     * @notice Shows the reward day from specified pointer.
     * @dev It is standart get function. 
     * @param _pointer is the pointer to array of dates.
     * @return quarterDay - reward day.
     */
    function getRewardDate(uint256 _pointer) external view returns(uint256);

    /**
     * @notice Allows the user to edit the some reward day to another day.
     * @dev It is standart set function. New reward day must be within this month. 
     * @param _pointer is the pointer to array of dates.
     * @param _value is the new reward day.
     */
    function editRewardDate(uint256 _pointer, uint256 _value) external;

    /**
     * @notice Allows the some user to withdraw some tokens from fee balance.
     * @param _amount is an amount of tokens to withdraw.
     */
    function feeWithdraw(uint256 _amount) external;

    /**
     * @notice Allows the user to change the address of contract to access control.
     * @param _accessControl is the new address of contract to access control.
     */
    function changeAccessControl(address _accessControl) external;

    /**
     * @notice Shows the distribution balance of contract.
     * @dev It is standart get function. 
     * @return distributionBalance - distribution balance.
     */
    function getDistribuctionBalance() external view returns(int256);

    /**
     * @notice Allows the every notblacklisted user to check his rewards to current time.
     * @dev Only for notblacklisted users. For users in wait list available to see rewards before waitlisting
     * @return currentReward - rewards to current time.
     * @return potentialReward - rewards with potential rewards.
     */
    function viewRewards() external view returns(uint256 currentReward, uint256 potentialReward);

    /**
     * @notice Allows to check rewards of the every notblacklisted user's to specific time.
     * @dev Only for notblacklisted users. For users in wait list available to see rewards before waitlisting
     * @param _timestamp is the specified timestamp to check rewards.
     * @param _user is the specified address of user.
     * @return currentReward - rewards to specific time.
     */
    function viewRewardsToTimestamp(address _user, uint256 _timestamp) external view returns(uint256 currentReward);
    
    /**
     * @notice Allows to specified user check all users on contract.
     * @return users - array of all users.
     */
    function viewAllUser() external view returns(address[] memory);

    /**
     * @notice Allows to specified user check users on contract with specified indexes.
     * @param _begin is the first user array index.
     * @param _end is the second user array index.
     * @return users - array of users with specified indexes.
     */
    function getUserList(uint256 _begin, uint256 _end) external view returns(address[] memory);

    /**
     * @notice Allows to specified user check the number of users on the contract.
     * @return userListLen - number of users on the contract.
     */
    function getUserListLen() external view returns(uint256);

    /**
     * @notice Allows to specified user check rewards of users with specified indexes.
     * @param _timestamp is the specified timestamp to check rewards.
     * @param _begin is the first user array index.
     * @param _end is the second user array index.
     * @return currentRewards - users rewards with specific time.
     */
    function getRewardsOfUsers(uint256 _timestamp, uint256 _begin, uint256 _end) external view returns(uint256 currentRewards);

}


// File contracts/LiquidityProvider.sol

pragma solidity ^0.8.6;






contract LiquidityProvider is ILiquidityProvider{

    
    
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint64 constant private precision = 1e18;
    uint32 constant secondInDay = 86400;
    uint32 constant secondInMonth = secondInDay * 30;

    uint256 private minimumLiquidity;
    uint256 private minimumStake;
    uint256 private openFee;
    uint256 private closeFee;
    uint256 private feeBalance;
    
    uint256 private counter;

    uint256 private liquidityBalance;
    int256 private distributionBalance;

    address public tokenAddress;
    address private accessControl;
    bool public liquidity = true;
    enum Status {NORMAL, WAITLISTED, BLACKLISTED}

    uint256[] private refLevel = [5 * 1e16, 3 * 1e16, 2 * 1e16];
    uint256[] private firstDaysInMonths = [1640995201, 1643673601, 1646092801, 1648771201, 1651363201, 1654041601, 1656633601, 1659312001, 1661990401, 1664582401, 1667260801, 1669852801, 
    1672531201, 1675209601, 1677628801, 1680307201, 1682899201, 1685577601, 1688169601, 1690848001, 1693526401, 1696118401, 1698796801, 1701388801, 
    1704067201, 1706745601, 1709251201, 1711929601, 1714521601, 1717200001, 1719792001, 1722470401, 1725148801, 1727740801, 1730419201, 1733011201,
    1735689601, 1738368001, 1740787201, 1743465601, 1746057601, 1748736001, 1751328001, 1754006401, 1756684801, 1759276801, 1761955201, 1764547201];
    uint256[] private quarterDays = [1642248000, 1650024000, 1657886400, 1665835200, 1673784000, 1681560000, 1689422400, 1697371200, 1705320000,
    1713182400, 1721044800, 1728993600, 1736942400, 1744718400, 1752580800, 1760529600];
    uint256[] private twentiethDaysInMonths  = [1642680000, 1645358400, 1647777600, 1650456000, 1653048000, 1655726400, 1658318400, 1660996800, 1663675200, 1666267200, 1668945600, 1671537600, 
    1674216000, 1676894400, 1679313600, 1681992000, 1684584000, 1687262400, 1689854400, 1692532800, 1695211200, 1697803200, 1700481600, 1703073600, 
    1705752000, 1708430400, 1710936000, 1713614400, 1716206400, 1718884800, 1721476800, 1724155200, 1726833600, 1729425600, 1732104000, 1734696000,
    1737374400, 1740052800, 1742472000, 1745150400, 1747742400, 1750420800, 1753012800, 1755691200, 1758369600, 1760961600, 1763640000, 1766232000];
    EnumerableSet.AddressSet private userAddresses;
    InterestRate[] private interestRates;

    mapping(address => Status) public statuses;
    mapping(address => Account) public accounts;

    modifier notInBlackList() {
        require(statuses[msg.sender] != Status.BLACKLISTED, "The user is blacklisted");
        _;
    }

    modifier onlyBoss1_2() {
        require(AccessControlBosses(accessControl).check_BOSS_1_2(msg.sender), "Doesnt enough addresses to appointment primal roles");
        _;
    }

    modifier onlyBoss1_2_3_Owner() {
        require(AccessControlBosses(accessControl).check_BOSS_1_2_3_OWNER(msg.sender), "Doesnt enough addresses to appointment primal roles");
        _;
    }

    constructor(address _tokenAddress, address _accessControl, uint256 _minimumLiquidity, uint256 _minimumStake, uint256 _openFee, uint256 _closeFee, uint256 _interestRate) {
        require(_tokenAddress.code.length > 0, "Address should be address of token");
        tokenAddress = _tokenAddress;
        minimumLiquidity = _minimumLiquidity;
        minimumStake = _minimumStake;
        openFee = _openFee;
        closeFee = _closeFee;
        interestRates.push(InterestRate(1, 9999999999, _interestRate));
        accessControl = _accessControl;
    }

    function setMinimumStake(uint256 _minimumStake) external override onlyBoss1_2_3_Owner { // доступ boss1, boss2, boss3, owner
        minimumStake = _minimumStake;
        emit NewMinimumStake(_minimumStake);
    }

    function setMinimumLiquidity(uint256 _minimumLiquidity) external override onlyBoss1_2_3_Owner { // доступ boss1, boss2, boss3, owner
        minimumLiquidity = _minimumLiquidity;
        emit NewMinimumLiquidity(_minimumLiquidity);
    }

    function provideLiquidity(uint256 _amount, address _ref1, address _ref2, address _ref3) external override notInBlackList { // msg.sender
        Account storage account = accounts[msg.sender];
        require(liquidity, "Acceptance of tokens in liquidity is paused");
        require(((_ref1 != _ref2) && (_ref1 != _ref3)) || (_ref1 == address(0)), "Referral address should be different");
        require((_ref2 != _ref3) || (_ref2 == address(0)), "Referral address should be different");
        require(_amount >= minimumLiquidity, "Liquidity amount is less than the minimum");
        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), _amount);
        accounts[_checkStake(_ref1)].referralBalance += _amount * refLevel[0] / precision;
        accounts[_checkStake(_ref2)].referralBalance += _amount * refLevel[1] / precision;
        accounts[_checkStake(_ref3)].referralBalance += _amount * refLevel[2] / precision;
        uint256 fee = _amount * openFee / precision;
        _amount -= fee;
        feeBalance += fee;
        if (account.lock)
        {
            _stake(_amount, account);
        }
        else
        {
            account.balance += _amount;
            account.depositeTime = block.timestamp;
            account.lock = true;
            (account.startTime, account.endTime, account.lastActive) = _getStartEndTime(12);
            userAddresses.add(msg.sender);
        }
        liquidityBalance += _amount;
        emit ProvideLiquidity(msg.sender, _amount, _ref1, _ref2, _ref3, account.endTime);
    }

    function setFees(uint256 _openFee, uint256 _closeFee) external override onlyBoss1_2_3_Owner { // доступ boss1, boss2, boss3, owner
        openFee = _openFee;
        closeFee = _closeFee;
        emit NewFees(_openFee, _closeFee);
    }

    function setReferralRate(uint256 _refLevel1, uint256 _refLevel2, uint256 _refLevel3) external override onlyBoss1_2_3_Owner { // доступ boss1, boss2, boss3, owner
        refLevel[0] = _refLevel1;
        refLevel[1] = _refLevel2;
        refLevel[2] = _refLevel3;
        emit NewReferralRate(_refLevel1, _refLevel2, _refLevel3);
    }

    function setInterestRate(uint256 _interestRate) external override onlyBoss1_2_3_Owner{ // доступ boss1, boss2, boss3, owner
        uint256 timestamp = block.timestamp;
        uint256 pointer;
        for (uint256 i = 0; i < quarterDays.length; i++)
        {
            if (quarterDays[i] > timestamp)
            {
                pointer = i;
                break;
            }
        }
        require(pointer > 0, "Mass of date is over");
        interestRates[interestRates.length - 1].end = pointer;
        interestRates.push(InterestRate(pointer, 9999999999, _interestRate));
        emit NewInterestRate(_interestRate);
    }

    function switchLiquidity() external override onlyBoss1_2_3_Owner { // доступ boss1, boss2, boss3, owner
        liquidity = !liquidity;
        emit SwitchLiquidity(liquidity);
    }

    function setLockPeriod(address[] calldata _userAddresses, uint256 _newLockPeriod) external override onlyBoss1_2_3_Owner { // доступ boss1, boss2, boss3, owner
        require(_newLockPeriod > 0, "new lock period should be more, than current time");
        for (uint256 i = 0; i < _userAddresses.length; i++)
            accounts[_userAddresses[i]].endTime = block.timestamp + _newLockPeriod;
    }

    function withdrawLiquidity(uint256 _amount) external override notInBlackList { // msg.sender
        Account storage account = accounts[msg.sender];
        if (statuses[msg.sender] == Status.NORMAL)
            _calcRewards(account);
        require(account.endTime <= block.timestamp, "Lock period hasnt yet ended");
        require(_amount <= account.balance, "Doesnt enough tokens on the balance");
        liquidityBalance -= _amount;
        account.balance -= _amount;
        //distr
        uint256 fee = _amount * closeFee / precision;
        _amount -= fee;
        feeBalance += fee;
        IERC20(tokenAddress).safeTransfer(msg.sender, _amount);
        emit WithdrawLiquidity(msg.sender, _amount);
    }

    function extendLiquidity(uint256 _amount) external override notInBlackList{ // msg.sender 
        require(_amount >= minimumLiquidity, "Liquidity amount is less than the minimum");
        require(liquidity, "Acceptance of tokens in liquidity is paused");
        Account storage account = accounts[msg.sender];
        require(_amount <= account.balance, "Doesnt enough tokens on the balance");
        require(statuses[msg.sender] == Status.NORMAL, "User doesnt have normal status");
        _calcRewards(account);
        require(account.endTime <= block.timestamp, "Lock period hasnt yet ended");
         (account.startTime, account.endTime, account.lastActive) = _getStartEndTime(11);
        uint256 amount = account.balance - _amount;
        if (amount > 0)
        {
            uint256 fee = amount * closeFee / precision;
            amount -= fee;
            feeBalance += fee;
            IERC20(tokenAddress).safeTransfer(msg.sender, amount);
            account.balance = _amount;
        }
        emit ExtendLiquidity(msg.sender, _amount, account.endTime);
    }

    function rewardsWithdraw(uint256 _amount) external override notInBlackList{ // msg.sender
        Account storage account = accounts[msg.sender];
        if (statuses[msg.sender] == Status.NORMAL)
            _calcRewards(account);
        require(_amount <= account.rewardBalance, "Doesnt enough tokens on the balance");
        IERC20(tokenAddress).safeTransfer(msg.sender, _amount);
        distributionBalance -= int256(_amount);
        account.rewardBalance -= _amount;
        emit RewardsWithdraw(msg.sender, _amount, account.rewardBalance);
    }

    function rewardsToLiquidity(uint256 _amount) external override notInBlackList{ // msg.sender
        require(liquidity, "Acceptance of tokens in liquidity is paused");
        Account storage account = accounts[msg.sender];
        require(statuses[msg.sender] == Status.NORMAL, "User doesnt have normal status");
        _calcRewards(account);
        require(account.endTime >= block.timestamp + secondInMonth, "Calling this function in less than a month is meaningless");
        require(account.balance > 0, "User doesnt open deposite with his own tokens or doesnt have token on balance");
        require(_amount <= account.rewardBalance, "Doesnt enough tokens on the balance");
        distributionBalance -= int256(_amount);
        _stake(_amount, account);
        account.rewardBalance -= _amount;
        emit RewardsToLiquidity(msg.sender, _amount, account.rewardBalance);
    }

    function referralWithdraw(uint256 _amount) external override notInBlackList{ // msg.sender
        Account storage account = accounts[msg.sender];
        require(_amount <= account.referralBalance, "Doesnt enough tokens on the referralBalance");
        IERC20(tokenAddress).safeTransfer(msg.sender, _amount);
        distributionBalance -= int256(_amount);
        account.referralBalance -= _amount;
        emit ReferralWithdraw(msg.sender, _amount, account.referralBalance);
    }

    function referralToLiquidity(uint256 _amount) external override notInBlackList{ // msg.sender
        require(statuses[msg.sender] == Status.NORMAL, "User doesnt have normal status");
        require(liquidity, "Acceptance of tokens in liquidity is paused");
        Account storage account = accounts[msg.sender];
        require(account.endTime >= block.timestamp + secondInMonth, "Calling this function in less than a month is meaningless");
        require(_amount <= account.referralBalance, "Doesnt enough tokens on the referralBalance");
        distributionBalance -= int256(_amount);
        account.referralBalance -= _amount;
        _stake(_amount, account);
        emit ReferralToLiquidity(msg.sender, _amount, account.referralBalance);

    }

    function distributionWithdraw(uint256 _amount) external override onlyBoss1_2 { // доступ boss1, boss2
        require(int256(_amount) <= distributionBalance, "Doesnt enough tokens on the distributionBalance");
        IERC20(tokenAddress).safeTransfer(msg.sender, _amount);
        distributionBalance -= int256(_amount);
        emit DistributionWithdraw(msg.sender, _amount);
    }

    function distributionDeposit(uint256 _amount) external override { //Everyone (its donate)
        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), _amount);
        distributionBalance += int256(_amount);
        emit DistributionDeposit(msg.sender, _amount);
    }

    function accountTransfer(address _from, address _to) external override onlyBoss1_2_3_Owner { //доступ boss1, boss2, boss3, owner
        Account storage accountFrom = accounts[_from];
        Account storage accountTo = accounts[_to];
        require(accountTo.endTime == 0, "Account already have active deposite");
        accounts[_to] = accountFrom;
        delete(accounts[_from]);
        userAddresses.add(_to);
        userAddresses.remove(_from);
        emit AccountTransfer(_from, _to);
    }

    function erc20Withdraw(address _token, address _recipient) external override onlyBoss1_2_3_Owner { //доступ boss1, boss2, boss3, owner
        IERC20(_token).safeTransfer(_recipient, IERC20(_token).balanceOf(address(this)));
    }

    // function erc721Withdraw(address _token, address _recipient) external override onlyBoss1_2_3_Owner { //доступ boss1, boss2, boss3, owner
    //     IERC721(_token).safeTransferFrom(address(this), recipient, IERC721(_token).balanceOf(address(this)));
    // }

    function whitelist(address[] calldata _userAddresses) external override onlyBoss1_2_3_Owner { //доступ boss1, boss2, boss3, owner
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            if (accounts[_userAddresses[i]].endTime > block.timestamp)
                accounts[_userAddresses[i]].endTime = block.timestamp + 1;
        }
        emit Whitelist(_userAddresses); 
    }

    function addLiquidity(User[] memory _users) external override onlyBoss1_2_3_Owner { //доступ boss1, boss2, boss3, owner
        address userAddress;
        for (uint256 i = 0; i < _users.length; i++)
        {
            userAddress = _users[i].userAddress;
            if (!_checkAddress(userAddress))
            {
                userAddresses.add(userAddress);
                require(accounts[userAddress].endTime == 0, "Account already have active deposite");
                Account storage account = accounts[userAddress];
                account.balance = _users[i].balance;
                liquidityBalance += account.balance;
                require(_users[i].startTime > firstDaysInMonths[0], "Start time should be later then first date in massive");
                account.startTime = _users[i].startTime;
                account.depositeTime = account.startTime;
                account.endTime = _users[i].endTime;
                for (uint256 j = 0; j < firstDaysInMonths.length; j++)
                {
                    if (firstDaysInMonths[j] >= account.startTime)
                    {
                        account.lastActive = j + 1;
                        break;
                    }
                }
                if (account.endTime > block.timestamp)
                {
                    account.lock = true;
                }
            }
        }
    }

    function waitList(address[] calldata _userAddresses) external override onlyBoss1_2_3_Owner { //доступ boss1, boss2, boss3, owner
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            if (statuses[_userAddresses[i]] != Status.WAITLISTED)
            {
                _calcRewards(accounts[_userAddresses[i]]);
                statuses[_userAddresses[i]] = Status.WAITLISTED;
            }
            else
                statuses[_userAddresses[i]] = Status.NORMAL;
        }
        emit WaitList(_userAddresses);
    }

    function blacklist(address[] calldata _userAddresses) external override onlyBoss1_2_3_Owner {  //доступ boss1, boss2, boss3, owner
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            if (statuses[_userAddresses[i]] != Status.BLACKLISTED)
                statuses[_userAddresses[i]] = Status.BLACKLISTED;
        }
        emit BlackList(_userAddresses);
    }

    function unblacklist(address[] calldata _userAddresses) external override onlyBoss1_2_3_Owner {  //доступ boss1, boss2, boss3, owner
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            if (statuses[_userAddresses[i]] == Status.BLACKLISTED)
                statuses[_userAddresses[i]] = Status.NORMAL;
        }
        emit UnblackList(_userAddresses);
    }

    function setAccount(address _user, Account calldata _account) external override onlyBoss1_2_3_Owner {
        userAddresses.add(_user);
        liquidityBalance -= accounts[_user].balance;
        accounts[_user] = _account;
        liquidityBalance += accounts[_user].balance;
    }

    function plusQuarters(uint256 _amount) external override onlyBoss1_2_3_Owner{
        require(_amount > 0, "Amount should be more then 0");
        uint256 pointer = firstDaysInMonths.length - 48;
        uint256 distinct = 126230400;
        uint256 distinctQ= distinct + 14 days - 1;
        for(uint256 i = 0; i < _amount * 3; i++)
        {
            firstDaysInMonths.push(firstDaysInMonths[pointer + i] + distinct);
            twentiethDaysInMonths.push(twentiethDaysInMonths[pointer + i] + distinct);
        }
        for(uint256 i = 0; i < _amount * 3; i += 3)
            quarterDays.push(firstDaysInMonths[pointer + i] + distinctQ);
    }

    function editRewardDate(uint256 _pointer, uint256 _value) external override onlyBoss1_2_3_Owner {
        require(counter / 3 <= _pointer, "Forbidden to edit past value");
        if (quarterDays[_pointer] < _value)
            require(_value < firstDaysInMonths[(_pointer * 3) + 1], "The value of reward should be less, than last day of this month");
        else
            require(firstDaysInMonths[(_pointer * 3)] < _value, "The value of reward should be more, than first day of this month");
        emit EditRewardDate(quarterDays[_pointer], _value);
        quarterDays[_pointer] = _value;
    }

    function feeWithdraw(uint256 _amount) external override {
        require(AccessControlBosses(accessControl).getRole(msg.sender) == AccessControlBosses.Roles.BOSS3, "User doesnt have role BOSS3");
        require(_amount <= feeBalance, "Doesnt enough tokens on the feeBalance");
        IERC20(tokenAddress).safeTransfer(msg.sender, _amount);
        feeBalance -= _amount;
        emit FeeWithdraw(msg.sender, _amount);
    }

    function changeAccessControl(address _accessControl) external override onlyBoss1_2{
        accessControl = _accessControl;
        emit ChangeAccessControl(accessControl);
    }

    function allOnLiquidityBalance() external view override returns(uint256){
        return liquidityBalance;
    }

    function getLockPeriod(address _user) external view override returns(uint256){
        return accounts[_user].endTime;
    }

    function getInterestRate() external view override returns(uint256){
        return interestRates[interestRates.length - 1].value;
    }

    function getInterestRateInDay() external view override returns(uint256){
        return interestRates[interestRates.length - 1].value * 4 / 365;
    }

    function getAccount(address _user) external view override returns(Account memory) {
        return accounts[_user];
    }

    function getRewardDate(uint256 _pointer) external view override returns(uint256){
        return quarterDays[_pointer];
    }

    function getDistribuctionBalance() external view override returns(int256){
        return distributionBalance;
    }

    function viewRewards() external view override notInBlackList returns(uint256 currentReward, uint256 potentialReward) {
        (currentReward, potentialReward) = (_calcViewRewards(msg.sender, block.timestamp));
    }

    function viewRewardsToTimestamp(address _user, uint256 _timestamp) external view override notInBlackList returns(uint256 currentReward) {
        (currentReward, ) = (_calcViewRewards(_user, _timestamp));
    }

    function viewAllUser() external view override returns(address[] memory) {
        uint256 length = userAddresses.length();
        address[] memory users = new address[](length);
        for (uint256 i; i < length; i++)
        {
            users[i] = userAddresses.at(i);
        }
        return users;
    }

    function getUserList(uint256 _begin, uint256 _end) external view override returns(address[] memory) {
        require(_begin <= _end, "First index should be more, than second");
        require(_end < userAddresses.length(), "Second index should be less than the length of user array");
        uint256 userListLength = _end - _begin + 1;
        address[] memory users = new address[](userListLength);
        for (uint256 i; i < userListLength; i++)
        {
            users[i] = userAddresses.at(_begin + i);
        }
        return users;
    }

    function getUserListLen() external view override returns(uint256) {
        return userAddresses.length();
    }

    function getRewardsOfUsers(uint256 _timestamp, uint256 _begin, uint256 _end) external view override returns(uint256 currentRewards) {
        require(_begin <= _end, "First index should be more, than second");
        require(_end < userAddresses.length(), "Second index should be less than the length of user array");
        uint256 userCheckLength = _end - _begin + 1;
        uint256 current;
        for (uint256 i; i < userCheckLength; i++)
        {
            (current, ) = (_calcViewRewards(userAddresses.at(_begin + i), _timestamp));
            currentRewards = currentRewards + current;
        }
    }

    function _getStartEndTime(uint32 _numberOfMonth) internal returns(uint256 startTime, uint256 endTime, uint256 activeTime) {
        uint256 timestamp = block.timestamp;
        for (; counter < firstDaysInMonths.length; counter++)
            if(firstDaysInMonths[counter] > timestamp)
                break;
        startTime = firstDaysInMonths[counter];
        require(counter + _numberOfMonth < firstDaysInMonths.length, "Mass of date is over");
        endTime = twentiethDaysInMonths[counter + _numberOfMonth];
        activeTime = counter + 1; 
    }

    function _calcRewards(Account storage account) internal { 
        uint256 timestamp = block.timestamp;
        for (uint256 i = account.lastActive; i < firstDaysInMonths.length; i++) {
            uint256 paymentDay = firstDaysInMonths[i] + 14 days;
            if (i % 3 == 0)
            {
                paymentDay = quarterDays[i / 3];
            }
            if ((paymentDay < account.endTime) && (paymentDay < timestamp))
            {
                if (i % 3 == 0)
                {
                    account.rewardBalance += (account.balance + account.calcReward) * interestRates[_getPointerOfInterestArray(i / 3)].value / (precision * 3);
                    account.calcReward = 0;
                }
                else
                {
                    account.calcReward += account.balance;
                }
                if (account.accumulate > 0)
                {
                    account.balance += account.accumulate;
                    liquidityBalance += account.accumulate;
                    account.accumulate = 0;
                } 
                account.lastActive++;
            }
            else
            {
                break;
            } 
        }
        if (account.endTime <= twentiethDaysInMonths[account.lastActive - 1])
        {
            account.lock = false;
        }
        if ((!account.lock)&&(quarterDays[(account.lastActive - 1) / 3 + 1] <= timestamp))
        {
            account.rewardBalance += account.calcReward * interestRates[_getPointerOfInterestArray((account.lastActive - 1) / 3)].value / (precision * 3);
            account.calcReward = 0;
        }
    }

    function _stake(uint256 _amount, Account storage account) internal { 
        require(liquidity, "Acceptance of tokens in liquidity is paused");
        _calcRewards(account);
        account.accumulate += _amount;
    }

    function _checkStake(address _referral) internal view returns(address decision) {
        if ((accounts[_referral].balance >= minimumStake) && (_referral != address(0)) && (_referral != msg.sender))
            decision = _referral;
        else
            decision = AccessControlBosses(accessControl).boss2();
    }

    function _getPointerOfInterestArray(uint256 pointerOfRewardsArray) internal view returns (uint256) {
        for (uint256 i = 0; i < interestRates.length; i++)
        {
            if (interestRates[i].start > pointerOfRewardsArray)
                return i - 1;
        }
        return interestRates.length - 1;
    }

    function _checkAddress(address _user) internal view returns(bool check) {
        if (accounts[_user].startTime > 0)
            check = true;
    } 

    function _calcViewRewards(address _user, uint256 _timestamp) internal view returns (uint256, uint256) {
        Account memory user = accounts[_user];
        if (statuses[_user] == Status.NORMAL)
        {
            for (uint256 i = user.lastActive; i < firstDaysInMonths.length; i++) {
                uint256 paymentDay = firstDaysInMonths[i] + 14 days;
                if (i % 3 == 0)
                {
                    paymentDay = quarterDays[i / 3];
                }
                if ((paymentDay < user.endTime) && (paymentDay < _timestamp))
                {
                    if (i % 3 == 0)
                    {
                        user.rewardBalance += (user.balance + user.calcReward) * interestRates[_getPointerOfInterestArray(i / 3)].value / (precision * 3);
                        user.calcReward = 0;
                    }
                    else
                    {
                        user.calcReward += user.balance;
                    }
                    if (user.accumulate > 0)
                    {
                        user.balance += user.accumulate;
                        user.accumulate = 0;
                    } 
                    user.lastActive++;
                }
                else
                {
                    break;
                } 
            }
            if (user.endTime <= twentiethDaysInMonths[user.lastActive - 1])
            {
                user.lock = false;
            }
            if ((!user.lock)&&(quarterDays[(user.lastActive - 1) / 3 + 1] <= _timestamp))
            {
                user.rewardBalance += user.calcReward * interestRates[_getPointerOfInterestArray((user.lastActive - 1) / 3)].value / (precision * 3);
                user.calcReward = 0;
            }
            return (user.rewardBalance, user.rewardBalance + user.calcReward * interestRates[_getPointerOfInterestArray((user.lastActive - 1) / 3)].value / (precision * 3));
        }
        else
        {
            return (user.rewardBalance, user.rewardBalance + user.calcReward * interestRates[_getPointerOfInterestArray((user.lastActive - 1) / 3)].value / (precision * 3));
        }
    }

}