/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// File: Address.sol

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

// File: Context.sol

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

// File: EnumerableSet.sol

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

// File: IAccessControl.sol

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File: IERC165.sol

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

// File: IERC20.sol

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

// File: IERC721Receiver.sol

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: Interfaces.sol

interface IPancakePair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface ILiquidityPool {
    struct LockedLiquidity {
        uint256 amount;
        uint256 premium;
        bool locked;
    }

    event Profit(uint256 indexed id, uint256 amount);
    event Loss(uint256 indexed id, uint256 amount);
    event Provide(address indexed account, uint256 amount, uint256 writeAmount);
    event Withdraw(
        address indexed account,
        uint256 amount,
        uint256 writeAmount
    );

    function unlock(uint256 id) external;

    // function unlockPremium(uint256 amount) external;
    event UpdateRevertTransfersInLockUpPeriod(
        address indexed account,
        bool value
    );
    event InitiateWithdraw(uint256 tokenXAmount, address account);
    event ProcessWithdrawRequest(uint256 tokenXAmount, address account);
    event UpdatePoolState(bool hasPoolEnded);
    event PoolRollOver(uint256 round);
    event UpdateMaxLiquidity(uint256 indexed maxLiquidity);
    event UpdateExpiry(uint256 expiry);
    event UpdateProjectOwner(address account);
    event Initialize(uint256 _initialExpiry);

    function totalTokenXBalance() external view returns (uint256 amount);

    function unlockWithoutProfit(uint256 id) external;

    function send(
        uint256 id,
        address account,
        uint256 amount
    ) external;

    function lock(
        uint256 id,
        uint256 tokenXAmount,
        uint256 premium
    ) external;

    function changeLock(
        uint256 id,
        uint256 tokenXAmount,
        uint256 premium
    ) external;
}

interface IBufferOptions {
    event Create(
        uint256 indexed id,
        address indexed account,
        uint256 settlementFee,
        uint256 totalFee,
        string metadata
    );

    event Exercise(uint256 indexed id, uint256 profit);
    event Expire(uint256 indexed id, uint256 premium);
    event PayReferralFee(address indexed referrer, uint256 amount);
    event PayAdminFee(address indexed owner, uint256 amount);
    event AutoExerciseStatusChange(address indexed account, bool status);

    enum State {
        Inactive,
        Active,
        Exercised,
        Expired
    }
    enum OptionType {
        Invalid,
        Put,
        Call
    }
    enum PaymentMethod {
        Usdc,
        TokenX
    }

    event UpdateOptionCreationWindow(
        uint256 startHour,
        uint256 startMinute,
        uint256 endHour,
        uint256 endMinute
    );
    event TransferUnits(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        uint256 targetTokenId,
        uint256 transferUnits
    );

    event Split(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 newTokenId,
        uint256 splitUnits
    );

    event Merge(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 indexed targetTokenId,
        uint256 mergeUnits
    );

    event ApprovalUnits(
        address indexed approval,
        uint256 indexed tokenId,
        uint256 allowance
    );
    struct OptionDetails {
        uint256 period;
        uint256 amount;
        uint256 strike;
        bool isYes;
        bool isAbove;
    }

    struct Option {
        State state;
        uint256 strike;
        uint256 amount;
        uint256 lockedAmount;
        uint256 premium;
        uint256 expiration;
        OptionType optionType;
    }

    struct BinaryOptionType {
        bool isYes;
        bool isAbove;
    }

    struct SlotDetail {
        uint256 strike;
        uint256 expiration;
        OptionType optionType;
        bool isValid;
    }

    struct ApproveUnits {
        address[] approvals;
        mapping(address => uint256) allowances;
    }
}

interface INFTReceiver {
    function onNFTReceived(
        address operator,
        address from,
        uint256 tokenId,
        uint256 units,
        bytes calldata data
    ) external returns (bytes4);
}

interface IOptionsConfig {
    enum PermittedTradingType {
        All,
        OnlyPut,
        OnlyCall,
        None
    }
    event UpdateImpliedVolatility(uint256 value);
    event UpdateSettlementFeePercentage(uint256 value);
    event UpdateSettlementFeeRecipient(address account);
    event UpdateStakingFeePercentage(uint256 value);
    event UpdateReferralRewardPercentage(uint256 value);
    event UpdateOptionCollaterizationRatio(uint256 value);
    event UpdateNFTSaleRoyaltyPercentage(uint256 value);
    event UpdateTradingPermission(PermittedTradingType permissionType);
    event UpdateStrike(uint256 value);
    event UpdateUnits(uint256 value);
    event Initialize(uint256 initialStrike, uint256 iv);
}

interface IOptionWindowCreator {
    struct OptionCreationWindow {
        uint256 startHour;
        uint256 startMinute;
        uint256 endHour;
        uint256 endMinute;
    }
    event UpdateOptionCreationWindow(
        uint256 startHour,
        uint256 startMinute,
        uint256 endHour,
        uint256 endMinute
    );
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function getTimestamp(uint256 _roundId)
        external
        view
        returns (uint256 timestamp);

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

interface IPriceProvider {
    function getUsdPrice() external view returns (uint256 _price);

    function getRoundData(uint256 _roundId)
        external
        view
        returns (
            uint80 roundId,
            uint256 price,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function decimals() external view returns (uint8);
}

interface INFTCore {
    function burnOption(uint256 optionId_) external;

    function unitsInToken(uint256 optionId_) external view returns (uint256);

    function slotOf(uint256 optionId_) external view returns (uint256);

    function transferUnitsFrom(
        address from_,
        address to_,
        uint256 optionId_,
        uint256 targetOptionId_,
        uint256 transferUnits_,
        address sender
    ) external;

    function checkOnNFTReceived(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 units_,
        bytes memory _data,
        address sender
    ) external returns (bool);

    function isApprovedOrOwner(address account, uint256 optionId_)
        external
        returns (bool);
}

interface ISlidingWindowOracleV1 {
    function consult(
        address tokenIn,
        uint256 amountIn,
        address tokenOut
    ) external view returns (uint256 amountOut);

    function observationIndexOf(uint256 timestamp)
        external
        view
        returns (uint256 index);
}

interface ISlidingWindowOracle {
    function consult(address tvlOracle)
        external
        view
        returns (uint256 amountOut);

    function getTimeWeightedAverageTVL(address tvlOracle, uint256 roundId)
        external
        view
        returns (uint256 roundTimestamp, uint256 KPI);
}

// File: OptionMath.sol

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
library ABDKMath64x64 {
    /*
     * Minimum value signed 64.64-bit fixed point number may have.
     */
    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

    /*
     * Maximum value signed 64.64-bit fixed point number may have.
     */
    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * Convert signed 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromInt(int256 x) public pure returns (int128) {
        unchecked {
            require(x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
            return int128(x << 64);
        }
    }

    /**
     * Convert signed 64.64 fixed point number into signed 64-bit integer number
     * rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64-bit integer number
     */
    function toInt(int128 x) public pure returns (int64) {
        unchecked {
            return int64(x >> 64);
        }
    }

    /**
     * Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
     * number.  Revert on overflow.
     *
     * @param x unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function fromUInt(uint256 x) internal pure returns (int128) {
        unchecked {
            require(x <= 0x7FFFFFFFFFFFFFFF);
            return int128(int256(x << 64));
        }
    }

    /**
     * Convert signed 64.64 fixed point number into unsigned 64-bit integer
     * number rounding down.  Revert on underflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return unsigned 64-bit integer number
     */
    function toUInt(int128 x) public pure returns (uint64) {
        unchecked {
            require(x >= 0);
            return uint64(uint128(x >> 64));
        }
    }

    /**
     * Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
     * number rounding down.  Revert on overflow.
     *
     * @param x signed 128.128-bin fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function from128x128(int256 x) internal pure returns (int128) {
        unchecked {
            int256 result = x >> 64;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Convert signed 64.64 fixed point number into signed 128.128 fixed point
     * number.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 128.128 fixed point number
     */
    function to128x128(int128 x) internal pure returns (int256) {
        unchecked {
            return int256(x) << 64;
        }
    }

    /**
     * Calculate x + y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function add(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) + y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x - y.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sub(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) - y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x * y rounding down.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function mul(int128 x, int128 y) public pure returns (int128) {
        unchecked {
            int256 result = (int256(x) * y) >> 64;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
     * number and y is signed 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y signed 256-bit integer number
     * @return signed 256-bit integer number
     */
    function muli(int128 x, int256 y) internal pure returns (int256) {
        unchecked {
            if (x == MIN_64x64) {
                require(
                    y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
                        y <= 0x1000000000000000000000000000000000000000000000000
                );
                return -y << 63;
            } else {
                bool negativeResult = false;
                if (x < 0) {
                    x = -x;
                    negativeResult = true;
                }
                if (y < 0) {
                    y = -y; // We rely on overflow behavior here
                    negativeResult = !negativeResult;
                }
                uint256 absoluteResult = mulu(x, uint256(y));
                if (negativeResult) {
                    require(
                        absoluteResult <=
                            0x8000000000000000000000000000000000000000000000000000000000000000
                    );
                    return -int256(absoluteResult); // We rely on overflow behavior here
                } else {
                    require(
                        absoluteResult <=
                            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                    );
                    return int256(absoluteResult);
                }
            }
        }
    }

    /**
     * Calculate x * y rounding down, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64 fixed point number
     * @param y unsigned 256-bit integer number
     * @return unsigned 256-bit integer number
     */
    function mulu(int128 x, uint256 y) internal pure returns (uint256) {
        unchecked {
            if (y == 0) return 0;

            require(x >= 0);

            uint256 lo = (uint256(int256(x)) *
                (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
            uint256 hi = uint256(int256(x)) * (y >> 128);

            require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            hi <<= 64;

            require(
                hi <=
                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF -
                        lo
            );
            return hi + lo;
        }
    }

    /**
     * Calculate x / y rounding towards zero.  Revert on overflow or when y is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function div(int128 x, int128 y) public pure returns (int128) {
        unchecked {
            require(y != 0);
            int256 result = (int256(x) << 64) / y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are signed 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x signed 256-bit integer number
     * @param y signed 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divi(int256 x, int256 y) internal pure returns (int128) {
        unchecked {
            require(y != 0);

            bool negativeResult = false;
            if (x < 0) {
                x = -x; // We rely on overflow behavior here
                negativeResult = true;
            }
            if (y < 0) {
                y = -y; // We rely on overflow behavior here
                negativeResult = !negativeResult;
            }
            uint128 absoluteResult = divuu(uint256(x), uint256(y));
            if (negativeResult) {
                require(absoluteResult <= 0x80000000000000000000000000000000);
                return -int128(absoluteResult); // We rely on overflow behavior here
            } else {
                require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int128(absoluteResult); // We rely on overflow behavior here
            }
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return signed 64.64-bit fixed point number
     */
    function divu(uint256 x, uint256 y) public pure returns (int128) {
        unchecked {
            require(y != 0);
            uint128 result = divuu(x, y);
            require(result <= uint128(MAX_64x64));
            return int128(result);
        }
    }

    /**
     * Calculate -x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function neg(int128 x) internal pure returns (int128) {
        unchecked {
            require(x != MIN_64x64);
            return -x;
        }
    }

    /**
     * Calculate |x|.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function abs(int128 x) internal pure returns (int128) {
        unchecked {
            require(x != MIN_64x64);
            return x < 0 ? -x : x;
        }
    }

    /**
     * Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
     * zero.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function inv(int128 x) internal pure returns (int128) {
        unchecked {
            require(x != 0);
            int256 result = int256(0x100000000000000000000000000000000) / x;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function avg(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            return int128((int256(x) + int256(y)) >> 1);
        }
    }

    /**
     * Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
     * Revert on overflow or in case x * y is negative.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function gavg(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 m = int256(x) * int256(y);
            require(m >= 0);
            require(
                m <
                    0x4000000000000000000000000000000000000000000000000000000000000000
            );
            return int128(sqrtu(uint256(m)));
        }
    }

    /**
     * Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
     * and y is unsigned 256-bit integer number.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @param y uint256 value
     * @return signed 64.64-bit fixed point number
     */
    function pow(int128 x, uint256 y) internal pure returns (int128) {
        unchecked {
            bool negative = x < 0 && y & 1 == 1;

            uint256 absX = uint128(x < 0 ? -x : x);
            uint256 absResult;
            absResult = 0x100000000000000000000000000000000;

            if (absX <= 0x10000000000000000) {
                absX <<= 63;
                while (y != 0) {
                    if (y & 0x1 != 0) {
                        absResult = (absResult * absX) >> 127;
                    }
                    absX = (absX * absX) >> 127;

                    if (y & 0x2 != 0) {
                        absResult = (absResult * absX) >> 127;
                    }
                    absX = (absX * absX) >> 127;

                    if (y & 0x4 != 0) {
                        absResult = (absResult * absX) >> 127;
                    }
                    absX = (absX * absX) >> 127;

                    if (y & 0x8 != 0) {
                        absResult = (absResult * absX) >> 127;
                    }
                    absX = (absX * absX) >> 127;

                    y >>= 4;
                }

                absResult >>= 64;
            } else {
                uint256 absXShift = 63;
                if (absX < 0x1000000000000000000000000) {
                    absX <<= 32;
                    absXShift -= 32;
                }
                if (absX < 0x10000000000000000000000000000) {
                    absX <<= 16;
                    absXShift -= 16;
                }
                if (absX < 0x1000000000000000000000000000000) {
                    absX <<= 8;
                    absXShift -= 8;
                }
                if (absX < 0x10000000000000000000000000000000) {
                    absX <<= 4;
                    absXShift -= 4;
                }
                if (absX < 0x40000000000000000000000000000000) {
                    absX <<= 2;
                    absXShift -= 2;
                }
                if (absX < 0x80000000000000000000000000000000) {
                    absX <<= 1;
                    absXShift -= 1;
                }

                uint256 resultShift = 0;
                while (y != 0) {
                    require(absXShift < 64);

                    if (y & 0x1 != 0) {
                        absResult = (absResult * absX) >> 127;
                        resultShift += absXShift;
                        if (absResult > 0x100000000000000000000000000000000) {
                            absResult >>= 1;
                            resultShift += 1;
                        }
                    }
                    absX = (absX * absX) >> 127;
                    absXShift <<= 1;
                    if (absX >= 0x100000000000000000000000000000000) {
                        absX >>= 1;
                        absXShift += 1;
                    }

                    y >>= 1;
                }

                require(resultShift < 64);
                absResult >>= 64 - resultShift;
            }
            int256 result = negative ? -int256(absResult) : int256(absResult);
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    /**
     * Calculate sqrt (x) rounding down.  Revert if x < 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function sqrt(int128 x) public pure returns (int128) {
        unchecked {
            require(x >= 0);
            return int128(sqrtu(uint256(int256(x)) << 64));
        }
    }

    /**
     * Calculate binary logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function log_2(int128 x) internal pure returns (int128) {
        unchecked {
            require(x > 0);

            int256 msb = 0;
            int256 xc = x;
            if (xc >= 0x10000000000000000) {
                xc >>= 64;
                msb += 64;
            }
            if (xc >= 0x100000000) {
                xc >>= 32;
                msb += 32;
            }
            if (xc >= 0x10000) {
                xc >>= 16;
                msb += 16;
            }
            if (xc >= 0x100) {
                xc >>= 8;
                msb += 8;
            }
            if (xc >= 0x10) {
                xc >>= 4;
                msb += 4;
            }
            if (xc >= 0x4) {
                xc >>= 2;
                msb += 2;
            }
            if (xc >= 0x2) msb += 1; // No need to shift xc anymore

            int256 result = (msb - 64) << 64;
            uint256 ux = uint256(int256(x)) << uint256(127 - msb);
            for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
                ux *= ux;
                uint256 b = ux >> 255;
                ux >>= 127 + b;
                result += bit * int256(b);
            }

            return int128(result);
        }
    }

    /**
     * Calculate natural logarithm of x.  Revert if x <= 0.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function ln(int128 x) internal pure returns (int128) {
        unchecked {
            require(x > 0);

            return
                int128(
                    int256(
                        (uint256(int256(log_2(x))) *
                            0xB17217F7D1CF79ABC9E3B39803F2F6AF) >> 128
                    )
                );
        }
    }

    /**
     * Calculate binary exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp_2(int128 x) internal pure returns (int128) {
        unchecked {
            require(x < 0x400000000000000000); // Overflow

            if (x < -0x400000000000000000) return 0; // Underflow

            uint256 result = 0x80000000000000000000000000000000;

            if (x & 0x8000000000000000 > 0)
                result = (result * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
            if (x & 0x4000000000000000 > 0)
                result = (result * 0x1306FE0A31B7152DE8D5A46305C85EDEC) >> 128;
            if (x & 0x2000000000000000 > 0)
                result = (result * 0x1172B83C7D517ADCDF7C8C50EB14A791F) >> 128;
            if (x & 0x1000000000000000 > 0)
                result = (result * 0x10B5586CF9890F6298B92B71842A98363) >> 128;
            if (x & 0x800000000000000 > 0)
                result = (result * 0x1059B0D31585743AE7C548EB68CA417FD) >> 128;
            if (x & 0x400000000000000 > 0)
                result = (result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8) >> 128;
            if (x & 0x200000000000000 > 0)
                result = (result * 0x10163DA9FB33356D84A66AE336DCDFA3F) >> 128;
            if (x & 0x100000000000000 > 0)
                result = (result * 0x100B1AFA5ABCBED6129AB13EC11DC9543) >> 128;
            if (x & 0x80000000000000 > 0)
                result = (result * 0x10058C86DA1C09EA1FF19D294CF2F679B) >> 128;
            if (x & 0x40000000000000 > 0)
                result = (result * 0x1002C605E2E8CEC506D21BFC89A23A00F) >> 128;
            if (x & 0x20000000000000 > 0)
                result = (result * 0x100162F3904051FA128BCA9C55C31E5DF) >> 128;
            if (x & 0x10000000000000 > 0)
                result = (result * 0x1000B175EFFDC76BA38E31671CA939725) >> 128;
            if (x & 0x8000000000000 > 0)
                result = (result * 0x100058BA01FB9F96D6CACD4B180917C3D) >> 128;
            if (x & 0x4000000000000 > 0)
                result = (result * 0x10002C5CC37DA9491D0985C348C68E7B3) >> 128;
            if (x & 0x2000000000000 > 0)
                result = (result * 0x1000162E525EE054754457D5995292026) >> 128;
            if (x & 0x1000000000000 > 0)
                result = (result * 0x10000B17255775C040618BF4A4ADE83FC) >> 128;
            if (x & 0x800000000000 > 0)
                result = (result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB) >> 128;
            if (x & 0x400000000000 > 0)
                result = (result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9) >> 128;
            if (x & 0x200000000000 > 0)
                result = (result * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
            if (x & 0x100000000000 > 0)
                result = (result * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
            if (x & 0x80000000000 > 0)
                result = (result * 0x10000058B90CF1E6D97F9CA14DBCC1628) >> 128;
            if (x & 0x40000000000 > 0)
                result = (result * 0x1000002C5C863B73F016468F6BAC5CA2B) >> 128;
            if (x & 0x20000000000 > 0)
                result = (result * 0x100000162E430E5A18F6119E3C02282A5) >> 128;
            if (x & 0x10000000000 > 0)
                result = (result * 0x1000000B1721835514B86E6D96EFD1BFE) >> 128;
            if (x & 0x8000000000 > 0)
                result = (result * 0x100000058B90C0B48C6BE5DF846C5B2EF) >> 128;
            if (x & 0x4000000000 > 0)
                result = (result * 0x10000002C5C8601CC6B9E94213C72737A) >> 128;
            if (x & 0x2000000000 > 0)
                result = (result * 0x1000000162E42FFF037DF38AA2B219F06) >> 128;
            if (x & 0x1000000000 > 0)
                result = (result * 0x10000000B17217FBA9C739AA5819F44F9) >> 128;
            if (x & 0x800000000 > 0)
                result = (result * 0x1000000058B90BFCDEE5ACD3C1CEDC823) >> 128;
            if (x & 0x400000000 > 0)
                result = (result * 0x100000002C5C85FE31F35A6A30DA1BE50) >> 128;
            if (x & 0x200000000 > 0)
                result = (result * 0x10000000162E42FF0999CE3541B9FFFCF) >> 128;
            if (x & 0x100000000 > 0)
                result = (result * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
            if (x & 0x80000000 > 0)
                result = (result * 0x10000000058B90BFBF8479BD5A81B51AD) >> 128;
            if (x & 0x40000000 > 0)
                result = (result * 0x1000000002C5C85FDF84BD62AE30A74CC) >> 128;
            if (x & 0x20000000 > 0)
                result = (result * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
            if (x & 0x10000000 > 0)
                result = (result * 0x1000000000B17217F7D5A7716BBA4A9AE) >> 128;
            if (x & 0x8000000 > 0)
                result = (result * 0x100000000058B90BFBE9DDBAC5E109CCE) >> 128;
            if (x & 0x4000000 > 0)
                result = (result * 0x10000000002C5C85FDF4B15DE6F17EB0D) >> 128;
            if (x & 0x2000000 > 0)
                result = (result * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
            if (x & 0x1000000 > 0)
                result = (result * 0x10000000000B17217F7D20CF927C8E94C) >> 128;
            if (x & 0x800000 > 0)
                result = (result * 0x1000000000058B90BFBE8F71CB4E4B33D) >> 128;
            if (x & 0x400000 > 0)
                result = (result * 0x100000000002C5C85FDF477B662B26945) >> 128;
            if (x & 0x200000 > 0)
                result = (result * 0x10000000000162E42FEFA3AE53369388C) >> 128;
            if (x & 0x100000 > 0)
                result = (result * 0x100000000000B17217F7D1D351A389D40) >> 128;
            if (x & 0x80000 > 0)
                result = (result * 0x10000000000058B90BFBE8E8B2D3D4EDE) >> 128;
            if (x & 0x40000 > 0)
                result = (result * 0x1000000000002C5C85FDF4741BEA6E77E) >> 128;
            if (x & 0x20000 > 0)
                result = (result * 0x100000000000162E42FEFA39FE95583C2) >> 128;
            if (x & 0x10000 > 0)
                result = (result * 0x1000000000000B17217F7D1CFB72B45E1) >> 128;
            if (x & 0x8000 > 0)
                result = (result * 0x100000000000058B90BFBE8E7CC35C3F0) >> 128;
            if (x & 0x4000 > 0)
                result = (result * 0x10000000000002C5C85FDF473E242EA38) >> 128;
            if (x & 0x2000 > 0)
                result = (result * 0x1000000000000162E42FEFA39F02B772C) >> 128;
            if (x & 0x1000 > 0)
                result = (result * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
            if (x & 0x800 > 0)
                result = (result * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
            if (x & 0x400 > 0)
                result = (result * 0x100000000000002C5C85FDF473DEA871F) >> 128;
            if (x & 0x200 > 0)
                result = (result * 0x10000000000000162E42FEFA39EF44D91) >> 128;
            if (x & 0x100 > 0)
                result = (result * 0x100000000000000B17217F7D1CF79E949) >> 128;
            if (x & 0x80 > 0)
                result = (result * 0x10000000000000058B90BFBE8E7BCE544) >> 128;
            if (x & 0x40 > 0)
                result = (result * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
            if (x & 0x20 > 0)
                result = (result * 0x100000000000000162E42FEFA39EF366F) >> 128;
            if (x & 0x10 > 0)
                result = (result * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
            if (x & 0x8 > 0)
                result = (result * 0x100000000000000058B90BFBE8E7BCD6D) >> 128;
            if (x & 0x4 > 0)
                result = (result * 0x10000000000000002C5C85FDF473DE6B2) >> 128;
            if (x & 0x2 > 0)
                result = (result * 0x1000000000000000162E42FEFA39EF358) >> 128;
            if (x & 0x1 > 0)
                result = (result * 0x10000000000000000B17217F7D1CF79AB) >> 128;

            result >>= uint256(int256(63 - (x >> 64)));
            require(result <= uint256(int256(MAX_64x64)));

            return int128(int256(result));
        }
    }

    /**
     * Calculate natural exponent of x.  Revert on overflow.
     *
     * @param x signed 64.64-bit fixed point number
     * @return signed 64.64-bit fixed point number
     */
    function exp(int128 x) internal pure returns (int128) {
        unchecked {
            require(x < 0x400000000000000000); // Overflow

            if (x < -0x400000000000000000) return 0; // Underflow

            return
                exp_2(
                    int128(
                        (int256(x) * 0x171547652B82FE1777D0FFDA0D23A7D12) >> 128
                    )
                );
        }
    }

    /**
     * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
     * integer numbers.  Revert on overflow or when y is zero.
     *
     * @param x unsigned 256-bit integer number
     * @param y unsigned 256-bit integer number
     * @return unsigned 64.64-bit fixed point number
     */
    function divuu(uint256 x, uint256 y) private pure returns (uint128) {
        unchecked {
            require(y != 0);

            uint256 result;

            if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
                result = (x << 64) / y;
            else {
                uint256 msb = 192;
                uint256 xc = x >> 192;
                if (xc >= 0x100000000) {
                    xc >>= 32;
                    msb += 32;
                }
                if (xc >= 0x10000) {
                    xc >>= 16;
                    msb += 16;
                }
                if (xc >= 0x100) {
                    xc >>= 8;
                    msb += 8;
                }
                if (xc >= 0x10) {
                    xc >>= 4;
                    msb += 4;
                }
                if (xc >= 0x4) {
                    xc >>= 2;
                    msb += 2;
                }
                if (xc >= 0x2) msb += 1; // No need to shift xc anymore

                result = (x << (255 - msb)) / (((y - 1) >> (msb - 191)) + 1);
                require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

                uint256 hi = result * (y >> 128);
                uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

                uint256 xh = x >> 192;
                uint256 xl = x << 64;

                if (xl < lo) xh -= 1;
                xl -= lo; // We rely on overflow behavior here
                lo = hi << 128;
                if (xl < lo) xh -= 1;
                xl -= lo; // We rely on overflow behavior here

                assert(xh == hi >> 128);

                result += xl / y;
            }

            require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return uint128(result);
        }
    }

    /**
     * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
     * number.
     *
     * @param x unsigned 256-bit integer number
     * @return unsigned 128-bit integer number
     */
    function sqrtu(uint256 x) private pure returns (uint128) {
        unchecked {
            if (x == 0) return 0;
            else {
                uint256 xx = x;
                uint256 r = 1;
                if (xx >= 0x100000000000000000000000000000000) {
                    xx >>= 128;
                    r <<= 64;
                }
                if (xx >= 0x10000000000000000) {
                    xx >>= 64;
                    r <<= 32;
                }
                if (xx >= 0x100000000) {
                    xx >>= 32;
                    r <<= 16;
                }
                if (xx >= 0x10000) {
                    xx >>= 16;
                    r <<= 8;
                }
                if (xx >= 0x100) {
                    xx >>= 8;
                    r <<= 4;
                }
                if (xx >= 0x10) {
                    xx >>= 4;
                    r <<= 2;
                }
                if (xx >= 0x8) {
                    r <<= 1;
                }
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1; // Seven iterations should be enough
                uint256 r1 = x / r;
                return uint128(r < r1 ? r : r1);
            }
        }
    }
}

library OptionMath {
    using ABDKMath64x64 for int128;

    // 64x64 fixed point integer constants
    int128 internal constant ONE_64x64 = 0x10000000000000000;
    int128 internal constant THREE_64x64 = 0x30000000000000000;

    // 64x64 fixed point constants used in Choudhury’s approximation of the Black-Scholes CDF
    int128 private constant CDF_CONST_0 = 0x09109f285df452394; // 2260 / 3989
    int128 private constant CDF_CONST_1 = 0x19abac0ea1da65036; // 6400 / 3989
    int128 private constant CDF_CONST_2 = 0x0d3c84b78b749bd6b; // 3300 / 3989

    /**
     * @notice calculate the exponential decay coefficient for a given interval
     * @param oldTimestamp timestamp of previous update
     * @param newTimestamp current timestamp
     * @return 64x64 fixed point representation of exponential decay coefficient
     */
    function _decay(uint256 oldTimestamp, uint256 newTimestamp)
        internal
        pure
        returns (int128)
    {
        return
            ONE_64x64.sub(
                (-ABDKMath64x64.divu(newTimestamp - oldTimestamp, 7 days)).exp()
            );
    }

    /**
     * @notice calculate Choudhury’s approximation of the Black-Scholes CDF
     * @param input64x64 64x64 fixed point representation of random variable
     * @return 64x64 fixed point representation of the approximated CDF of x
     */
    function _N(int128 input64x64) internal pure returns (int128) {
        // squaring via mul is cheaper than via pow
        int128 inputSquared64x64 = input64x64.mul(input64x64);

        int128 value64x64 = (-inputSquared64x64 >> 1).exp().div(
            CDF_CONST_0.add(CDF_CONST_1.mul(input64x64.abs())).add(
                CDF_CONST_2.mul(inputSquared64x64.add(THREE_64x64).sqrt())
            )
        );

        return input64x64 > 0 ? ONE_64x64.sub(value64x64) : value64x64;
    }

    /**
     * @notice calculate the price of an option using the Black-Scholes model
     * @param impliedVol uint256 representation of annualized impliedVol with a factor of 1e4
     * @param strike uint256 representation of strike price with a factor of 1e8
     * @param spot uint256 representation of spot price with a factor of 1e8
     * @param period uint256 representation of duration of option contract (in seconds)
     * @param isCall whether to price "call" or "put" option
     * @return uint256 representation of Black-Scholes option price with a factor of 1e8
     */
    function blackScholesPrice(
        uint256 impliedVol,
        uint256 strike,
        uint256 spot,
        uint256 period,
        bool isCall
    ) public pure returns (uint256) {
        int128 D8 = ABDKMath64x64.fromUInt(10**8);
        int128 D4 = ABDKMath64x64.fromUInt(10**4);
        int128 impliedVol64x64 = ABDKMath64x64.fromUInt(impliedVol).div(D4);
        int128 variance64x64 = impliedVol64x64.mul(impliedVol64x64);
        int128 strike64x64 = ABDKMath64x64.fromUInt(strike).div(D8);
        int128 spot64x64 = ABDKMath64x64.fromUInt(spot).div(D8);
        int128 maturity64x64 = ABDKMath64x64.fromUInt(period).div(
            ABDKMath64x64.fromUInt(365 days)
        );

        int128 premium64x64 = _blackScholesPrice(
            variance64x64,
            strike64x64,
            spot64x64,
            maturity64x64,
            isCall
        );
        return ABDKMath64x64.toUInt(premium64x64.mul(D8));
    }

    /**
     * @notice calculate the price of an option using the Black-Scholes model
     * @param varianceAnnualized64x64 64x64 fixed point representation of annualized variance
     * @param strike64x64 64x64 fixed point representation of strike price
     * @param spot64x64 64x64 fixed point representation of spot price
     * @param timeToMaturity64x64 64x64 fixed point representation of duration of option contract (in years)
     * @param isCall whether to price "call" or "put" option
     * @return 64x64 fixed point representation of Black-Scholes option price
     */
    function _blackScholesPrice(
        int128 varianceAnnualized64x64,
        int128 strike64x64,
        int128 spot64x64,
        int128 timeToMaturity64x64,
        bool isCall
    ) public pure returns (int128) {
        int128 cumulativeVariance64x64 = timeToMaturity64x64.mul(
            varianceAnnualized64x64
        );
        int128 cumulativeVarianceSqrt64x64 = cumulativeVariance64x64.sqrt();

        int128 d1_64x64 = spot64x64
            .div(strike64x64)
            .ln()
            .add(cumulativeVariance64x64 >> 1)
            .div(cumulativeVarianceSqrt64x64);
        int128 d2_64x64 = d1_64x64.sub(cumulativeVarianceSqrt64x64);

        if (isCall) {
            return
                spot64x64.mul(_N(d1_64x64)).sub(strike64x64.mul(_N(d2_64x64)));
        } else {
            return
                -spot64x64.mul(_N(-d1_64x64)).sub(
                    strike64x64.mul(_N(-d2_64x64))
                );
        }
    }

    /**
     * @notice calculate the price of an option using the Black-Scholes model
     * @param impliedVol uint256 representation of annualized impliedVol with a factor of 1e4
     * @param strike uint256 representation of strike price with a factor of 1e8
     * @param spot uint256 representation of spot price with a factor of 1e8
     * @param period uint256 representation of duration of option contract (in seconds)
     * @param isYes whether to price "call" or "put" option
     * @param isAbove whether to the user bets the price will stay above this strike or not
     * @return uint256 representation of Black-Scholes option price with a factor of 1e8
     */
    function blackScholesPriceBinary(
        uint256 impliedVol,
        uint256 strike,
        uint256 spot,
        uint256 period,
        bool isYes,
        bool isAbove
    ) public pure returns (uint256) {
        int128 D8 = ABDKMath64x64.fromUInt(10**8);
        int128 D4 = ABDKMath64x64.fromUInt(10**4);
        int128 impliedVol64x64 = ABDKMath64x64.fromUInt(impliedVol).div(D4);
        int128 variance64x64 = impliedVol64x64.mul(impliedVol64x64);
        int128 strike64x64 = ABDKMath64x64.fromUInt(strike).div(D8);
        int128 spot64x64 = ABDKMath64x64.fromUInt(spot).div(D8);
        int128 maturity64x64 = ABDKMath64x64.fromUInt(period).div(
            ABDKMath64x64.fromUInt(365 days)
        );

        int128 premium64x64 = _blackScholesPriceBinary(
            variance64x64,
            strike64x64,
            spot64x64,
            maturity64x64,
            isYes,
            isAbove
        );
        return ABDKMath64x64.toUInt(premium64x64.mul(D8));
    }

    /**
     * @notice calculate the price of an option using the Black-Scholes model
     * @param varianceAnnualized64x64 64x64 fixed point representation of annualized variance
     * @param strike64x64 64x64 fixed point representation of strike price
     * @param spot64x64 64x64 fixed point representation of spot price
     * @param timeToMaturity64x64 64x64 fixed point representation of duration of option contract (in years)
     * @param isYes whether to price "call" or "put" option
     * @param isAbove whether to the user bets the price will stay above this strike or not
     * @return 64x64 fixed point representation of Black-Scholes option price
     */
    function _blackScholesPriceBinary(
        int128 varianceAnnualized64x64,
        int128 strike64x64,
        int128 spot64x64,
        int128 timeToMaturity64x64,
        bool isYes,
        bool isAbove
    ) public pure returns (int128) {
        int128 cumulativeVariance64x64 = timeToMaturity64x64.mul(
            varianceAnnualized64x64
        );
        int128 cumulativeVarianceSqrt64x64 = cumulativeVariance64x64.sqrt();

        int128 d1_64x64 = spot64x64
            .div(strike64x64)
            .ln()
            .add(cumulativeVariance64x64 >> 1)
            .div(cumulativeVarianceSqrt64x64);
        int128 d2_64x64 = d1_64x64.sub(cumulativeVarianceSqrt64x64);

        if (isYes) {
            if (isAbove) {
                return _N(d2_64x64);
            } else {
                return ABDKMath64x64.fromUInt(1).sub(_N(d2_64x64));
            }
        } else {
            if (isAbove) {
                return ABDKMath64x64.fromUInt(1).sub(_N(-d2_64x64));
            } else {
                return _N(-d2_64x64);
            }
        }
    }

}

// File: ReentrancyGuard.sol

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

// File: Strings.sol

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

// File: ERC165.sol

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

// File: IERC20Metadata.sol

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

// File: IERC721.sol

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

// File: Ownable.sol

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

// File: AccessControl.sol

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: ERC20.sol

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
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

// File: IERC721Metadata.sol

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

// File: BufferEpocPoolV2Unintialized.sol

/**
 * @author Heisenberg
 * @title Buffer TokenX Liquidity Pool
 * @notice Accumulates liquidity in TokenX from LPs and distributes P&L in TokenX
 */
contract BufferEpocPoolV2Unintialized is
    ERC20("Buffer LP Token", "rBFR"),
    AccessControl,
    ILiquidityPool
{
    string private _name;
    string private _symbol;
    uint256 public constant ACCURACY = 1e3;
    uint256 public constant INITIAL_RATE = 1e3;
    uint256 public lockedAmount;
    uint256 public lockedPremium;
    uint256 public maxLiquidity;
    uint256 public fixedExpiry;
    uint256 public startDate;
    uint256 public currentRound = 1;
    bool public hasPoolEnded = false;
    bool public isInitialized = false;
    bool public isAcceptingWithdrawRequests = true;
    address public projectOwner;
    address public owner;
    mapping(address => LockedLiquidity[]) public lockedLiquidity;

    bytes32 public constant OPTION_ISSUER_ROLE =
        keccak256("OPTION_ISSUER_ROLE");

    bytes32 public constant PROJECT_OWNER_ROLE =
        keccak256("PROJECT_OWNER_ROLE");

    ERC20 public tokenX;

    struct WithdrawRequest {
        uint256 withdrawAmount;
        uint256 round;
        address account;
    }
    struct User {
        uint256 requestIndex; // Pointer to the withdraw request
        bool exists;
    }

    mapping(uint256 => WithdrawRequest) public WithdrawRequestQueue;
    mapping(address => User) public AddressToWithdrawRequest;
    uint256 public queueStart = 0;
    uint256 public queueEnd = 0;

    constructor(ERC20 _tokenX) {
        _name = string(
            bytes.concat(
                "Buffer Generic ",
                bytes(_tokenX.symbol()),
                " LP Token"
            )
        );
        _symbol = string(bytes.concat("r", bytes(_tokenX.symbol())));
        tokenX = _tokenX;
        owner = msg.sender;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Initializes the pool
     * @param _maxLiquidity Pool token cap
     * @param _initialExpiry Initial expiry
     */
    function initialize(
        uint256 _maxLiquidity,
        uint256 _initialExpiry,
        uint256 _startDate
    ) external onlyRole(PROJECT_OWNER_ROLE) {
        require(!isInitialized, "Pool: Already initialized");
        setMaxLiquidity(_maxLiquidity);
        setExpiry(_initialExpiry);
        isInitialized = true;
        startDate = _startDate;
        emit Initialize(_initialExpiry);
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
     * @dev Returns the decimals of the token.
     */
    function decimals() public view virtual override returns (uint8) {
        return tokenX.decimals();
    }

    /**
     * @notice Used for changing expiry
     * @param value New fixedExpiry value
     */
    function setExpiry(uint256 value) internal {
        fixedExpiry = value;
        emit UpdateExpiry(value);
    }

    /**
     * @notice Used for setting owner
     * @param account owner account
     */
    function setProjectOwner(address account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        grantRole(PROJECT_OWNER_ROLE, account);
        projectOwner = account;
        emit UpdateProjectOwner(account);
    }

    /**
     * @notice Used for adjusting the max limit of the pool
     * @param _maxLiquidity New limit
     */
    function setMaxLiquidity(uint256 _maxLiquidity) internal {
        maxLiquidity = _maxLiquidity;
        emit UpdateMaxLiquidity(_maxLiquidity);
    }

    /**
     * @notice Used for setting the liquidity pool's state
     * @param _hasPoolEnded New state
     */
    function setPoolState(bool _hasPoolEnded)
        external
        onlyRole(PROJECT_OWNER_ROLE)
    {
        hasPoolEnded = _hasPoolEnded;
        emit UpdatePoolState(hasPoolEnded);
    }

    /**
     * @notice Used to start a new round
     * @param expiry New expiry
     */
    function rollOver(uint256 expiry, uint256 _maxLiquidity)
        external
        onlyRole(PROJECT_OWNER_ROLE)
    {
        require(
            block.timestamp > fixedExpiry,
            "Pool: Can't roll over before the expiry ends"
        );
        require(
            lockedAmount == 0 && lockedPremium == 0,
            "Pool: Current round hasn't ended completely"
        );
        setExpiry(expiry);
        setMaxLiquidity(_maxLiquidity);
        currentRound++;
        isAcceptingWithdrawRequests = false;
        emit PoolRollOver(currentRound);
    }

    /**
     * @notice A provider supplies tokenX to the pool and receives rBFR-X tokens
     * @param minMint Minimum amount of tokens that should be received by a provider.
                      Calling the provide function will require the minimum amount of tokens to be minted.
                      The actual amount that will be minted could vary but can only be higher (not lower) than the minimum value.
     * @return mint Amount of tokens to be received
     */
    function provide(uint256 tokenXAmount, uint256 minMint)
        external
        returns (uint256 mint)
    {
        require(block.timestamp > startDate, "Pool: Not started yet");
        require(!hasPoolEnded, "Pool: Already ended");
        require(msg.sender == projectOwner, "Pool: You don't have the access");

        uint256 supply = totalSupply();
        uint256 balance = tokenX.balanceOf(address(this));

        require(
            balance + tokenXAmount <= maxLiquidity,
            "Pool: Pool has already reached it's max limit"
        );

        if (supply > 0 && balance > 0)
            mint = (tokenXAmount * supply) / (balance);
        else mint = tokenXAmount * INITIAL_RATE;

        require(mint >= minMint, "Pool: Mint limit is too large");
        require(mint > 0, "Pool: Amount is too small");

        bool success = tokenX.transferFrom(
            msg.sender,
            address(this),
            tokenXAmount
        );
        require(success, "Pool: The Provide transfer didn't go through");

        _mint(msg.sender, mint);

        emit Provide(msg.sender, tokenXAmount, mint);
    }

    /**
     * @notice Provider burns rBFR-X and receives X from the pool
     * @param tokenXAmount Amount of X to receive
     * @param account User address for which the withdrawal has to be initiated
     * @return burn Amount of tokens to be burnt
     */
    function _withdraw(uint256 tokenXAmount, address account)
        internal
        returns (uint256 burn)
    {
        require(
            availableBalance() > 0,
            "Pool: Not enough funds on the pool contract"
        );
        uint256 totalSupply = totalSupply();
        uint256 balance = totalTokenXBalance();

        uint256 maxUserTokenXWithdrawal = (balanceOf(account) * balance) /
            totalSupply;

        uint256 tokenXAmountToWithdraw = maxUserTokenXWithdrawal < tokenXAmount
            ? maxUserTokenXWithdrawal
            : tokenXAmount;

        burn = divCeil((tokenXAmountToWithdraw * totalSupply), balance);

        require(burn <= balanceOf(account), "Pool: Amount is too large");
        require(burn > 0, "Pool: Amount is too small");

        _burn(account, burn);

        bool success = tokenX.transfer(account, tokenXAmountToWithdraw);
        require(success, "Pool: The Withdrawal didn't go through");
        emit Withdraw(account, tokenXAmountToWithdraw, burn);
    }

    /**
     * @notice Initiates withdraw requests for users
     * @param tokenXAmount Amount of X to receive
     * @param account User address for which the withdrawal has to be initiated
     */
    function _initiateWithdraw(uint256 tokenXAmount, address account) internal {
        require(balanceOf(account) > 0, "Pool: Nothing to withdraw");

        User storage addressToWithdrawRequest = AddressToWithdrawRequest[
            account
        ];
        if (addressToWithdrawRequest.exists) {
            WithdrawRequest storage withdrawRequest = WithdrawRequestQueue[
                addressToWithdrawRequest.requestIndex
            ];
            require(
                (withdrawRequest.round == currentRound ||
                    withdrawRequest.round == 0),
                "Pool: State locked up"
            );
            withdrawRequest.withdrawAmount =
                withdrawRequest.withdrawAmount +
                tokenXAmount;
        } else {
            WithdrawRequestQueue[queueEnd] = WithdrawRequest(
                tokenXAmount,
                currentRound,
                account
            );
            addressToWithdrawRequest.requestIndex = queueEnd;
            addressToWithdrawRequest.exists = true;
            queueEnd++;
        }

        emit InitiateWithdraw(tokenXAmount, account);
    }

    /**
     * @notice withdraw burns rBFR-X and receives X from the pool
     * @param tokenXAmount Amount Amount of X to receive
     */
    function withdraw(uint256 tokenXAmount) external {
        require(msg.sender == projectOwner, "Pool: You don't have the access");
        if (hasPoolEnded) {
            _withdraw(tokenXAmount, msg.sender);
        } else {
            require(
                isAcceptingWithdrawRequests && isInitialized,
                "Pool: Not accepting withdraw requests currently"
            );
            _initiateWithdraw(tokenXAmount, msg.sender);
        }
    }

    /**
     * @notice Processes all the withdraw requests once the round ends
     * @param requestsToProcess Number of requests to process
     */
    function processWithdrawRequests(uint256 requestsToProcess) external {
        uint256 endIndex = queueStart + requestsToProcess > queueEnd
            ? queueEnd
            : queueStart + requestsToProcess;
        for (uint256 i = queueStart; i < endIndex; i++) {
            WithdrawRequest storage withdrawRequest = WithdrawRequestQueue[i];
            User storage addressToWithdrawRequest = AddressToWithdrawRequest[
                withdrawRequest.account
            ];

            require(
                withdrawRequest.round != currentRound,
                "Pool: Can't process the requests when the round is active"
            );

            _withdraw(withdrawRequest.withdrawAmount, withdrawRequest.account);
            emit ProcessWithdrawRequest(
                withdrawRequest.withdrawAmount,
                withdrawRequest.account
            );

            delete WithdrawRequestQueue[i];
            addressToWithdrawRequest.requestIndex = 0;
            addressToWithdrawRequest.exists = false;
            queueStart++;
        }

        // When all requests have been processed reset the queue
        if (queueStart == queueEnd) {
            queueEnd = queueStart = 0;
            isAcceptingWithdrawRequests = true;
        }
    }

    /**
     * @notice Called by BufferCallOptions to lock the funds
     * @param tokenXAmount Amount of funds that should be locked in an option
     */
    function lock(
        uint256 id,
        uint256 tokenXAmount,
        uint256 premium
    ) external override onlyRole(OPTION_ISSUER_ROLE) {
        require(id == lockedLiquidity[msg.sender].length, "Pool: Wrong id");

        require(
            (lockedAmount + tokenXAmount) <= totalTokenXBalance(),
            "Pool: Amount is too large."
        );

        lockedLiquidity[msg.sender].push(
            LockedLiquidity(tokenXAmount, premium, true)
        );
        lockedPremium = lockedPremium + premium;
        lockedAmount = lockedAmount + tokenXAmount;
    }

    /**
     * @notice Called by BufferCallOptions to change the locked funds
     * @param tokenXAmount Amount of funds that should be locked in an option
     */
    function changeLock(
        uint256 id,
        uint256 tokenXAmount,
        uint256 premium
    ) public override onlyRole(OPTION_ISSUER_ROLE) {
        LockedLiquidity storage ll = lockedLiquidity[msg.sender][id];
        require(ll.locked, "Pool: lockedAmount is already unlocked");

        lockedPremium = lockedPremium - ll.premium + premium;
        lockedAmount = lockedAmount - ll.amount + tokenXAmount;
        ll.premium = premium;
        ll.amount = tokenXAmount;
    }

    /**
     * @notice Called by BufferOptions to unlock the funds
     * @param id Id of LockedLiquidity that should be unlocked
     */
    function _unlock(uint256 id)
        internal
        onlyRole(OPTION_ISSUER_ROLE)
        returns (uint256 premium)
    {
        LockedLiquidity storage ll = lockedLiquidity[msg.sender][id];
        require(ll.locked, "Pool: lockedAmount is already unlocked");
        ll.locked = false;

        lockedPremium = lockedPremium - ll.premium;
        lockedAmount = lockedAmount - ll.amount;
        premium = ll.premium;
    }

    /**
     * @notice Called by BufferOptions to unlock the funds
     * @param id Id of LockedLiquidity that should be unlocked
     */
    function unlock(uint256 id) external override {
        uint256 premium = _unlock(id);

        emit Profit(id, premium);
    }

    /**
     * @notice Called by BufferOptions to unlock the funds
     * @param id Id of LockedLiquidity that should be unlocked
     */
    function unlockWithoutProfit(uint256 id) external override {
        _unlock(id);
    }

    /**
     * @notice Called by BufferCallOptions to send funds to liquidity providers after an option's expiration
     * @param to Provider
     * @param tokenXAmount Funds that should be sent
     */
    function send(
        uint256 id,
        address to,
        uint256 tokenXAmount
    ) external override onlyRole(OPTION_ISSUER_ROLE) {
        LockedLiquidity storage ll = lockedLiquidity[msg.sender][id];
        require(ll.locked, "Pool: lockedAmount is already unlocked");
        require(to != address(0));

        ll.locked = false;
        lockedPremium = lockedPremium - ll.premium;
        lockedAmount = lockedAmount - ll.amount;

        uint256 transferTokenXAmount = tokenXAmount > ll.amount
            ? ll.amount
            : tokenXAmount;

        bool success = tokenX.transfer(to, transferTokenXAmount);
        require(success, "Pool: The Payout transfer didn't go through");

        if (transferTokenXAmount <= ll.premium)
            emit Profit(id, ll.premium - transferTokenXAmount);
        else emit Loss(id, transferTokenXAmount - ll.premium);
    }

    /**
     * @notice Returns provider's share in X
     * @param account Provider's address
     * @return share Provider's share in X
     */
    function shareOf(address account) external view returns (uint256 share) {
        if (totalSupply() > 0)
            share = (totalTokenXBalance() * balanceOf(account)) / totalSupply();
        else share = 0;
    }

    /**
     * @notice Returns the amount of X available for withdrawals
     * @return balance Unlocked amount
     */
    function availableBalance() public view returns (uint256 balance) {
        return totalTokenXBalance() - lockedAmount;
    }

    /**
     * @notice Returns the total balance of X provided to the pool
     * @return balance Pool balance
     */
    function totalTokenXBalance()
        public
        view
        override
        returns (uint256 balance)
    {
        return tokenX.balanceOf(address(this)) - lockedPremium;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        if (a % b != 0) c = c + 1;
        return c;
    }
}

// File: ERC721.sol

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
     * by default, can be overriden in child contracts.
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
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
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
}

// File: ERC721URIStorage.sol

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
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
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// File: OptionConfigUnintialized.sol

/**
 * @author Heisenberg
 * @title Buffer BNB Bidirectional (Call and Put) Options
 * @notice Buffer BNB Options Contract
 */
contract OptionConfigUnintialized is Ownable, IBufferOptions, IOptionsConfig {
    uint256 public impliedVolRate;
    uint256 public optionCollateralizationRatio = 100;
    uint256 public settlementFeePercentage = 1;
    uint256 public nftSaleRoyaltyPercentage = 5;
    uint256 internal constant PRICE_DECIMALS = 1e8;
    uint256 public utilizationRate = 60e8;
    uint256 public fixedStrike;
    BufferEpocPoolV2Unintialized public pool;
    PermittedTradingType public permittedTradingType;
    bool public isInitialized = false;

    constructor(BufferEpocPoolV2Unintialized _pool) {
        pool = _pool;
    }

    function initialize(uint256 initialImpliedVolRate, uint256 initialStrike)
        external
        onlyProjectOwner
    {
        require(!isInitialized, "Already initialized");
        fixedStrike = initialStrike;
        impliedVolRate = initialImpliedVolRate;
        isInitialized = true;
        emit Initialize(initialStrike, initialImpliedVolRate);
    }

    /**
     * @notice Check the validity of the input params
     * @param optionType Call or Put option type
     * @param period Option period in seconds (1 days <= period <= 90 days)
     * @param amount Option amount
     * @param strikeFee strike fee for the option
     * @param totalFee total fee for the option
     * @param msgValue the msg.value given to the Create function
     */
    function checkParams(
        IBufferOptions.OptionType optionType,
        uint256 period,
        uint256 amount,
        uint256 strikeFee,
        uint256 totalFee,
        uint256 msgValue
    ) external pure {
        require(
            optionType == IBufferOptions.OptionType.Call ||
                optionType == IBufferOptions.OptionType.Put,
            "Wrong option type"
        );
        require(period >= 1 days, "Period is too short");
        require(period <= 90 days, "Period is too long");
        require(amount > strikeFee, "Price difference is too large");
        require(msgValue >= totalFee, "Wrong value");
    }

    /**
     * @notice Used for adjusting the options prices while balancing asset's implied volatility rate
     * @param value New IVRate value
     */
    function setImpliedVolRate(uint256 value) external onlyProjectOwner {
        require(value >= 100, "ImpliedVolRate limit is too small");
        impliedVolRate = value;
        emit UpdateImpliedVolatility(value);
    }

    function setTradingPermission(PermittedTradingType permissionType)
        external
        onlyOwner
    {
        permittedTradingType = permissionType;
        emit UpdateTradingPermission(permissionType);
    }

    /**
     * @notice Used for changing strike
     * @param value New fixedStrike value
     */
    function setStrike(uint256 value) external onlyProjectOwner {
        require(
            block.timestamp > pool.fixedExpiry(),
            "Can't change strike before the expiry ends"
        );
        fixedStrike = value;
        emit UpdateStrike(value);
    }

    /**
     * @notice Used for adjusting the settlement fee percentage
     * @param value New Settlement Fee Percentage
     */
    function setSettlementFeePercentage(uint256 value) external onlyOwner {
        require(value < 20, "SettlementFeePercentage is too high");
        settlementFeePercentage = value;
        emit UpdateSettlementFeePercentage(value);
    }

    /**
     * @notice Used for changing option collateralization ratio
     * @param value New optionCollateralizationRatio value
     */
    function setOptionCollaterizationRatio(uint256 value)
        external
        onlyProjectOwner
    {
        require(50 <= value && value <= 100, "wrong value");
        optionCollateralizationRatio = value;
        emit UpdateOptionCollaterizationRatio(value);
    }

    /**
     * @notice Used for changing nftSaleRoyaltyPercentage
     * @param value New nftSaleRoyaltyPercentage value
     */
    function setNFTSaleRoyaltyPercentage(uint256 value) external onlyOwner {
        require(value <= 10, "wrong value");
        nftSaleRoyaltyPercentage = value;
        emit UpdateNFTSaleRoyaltyPercentage(value);
    }

    /**
     * @notice Used for updating utilizationRate value
     * @param value New utilizationRate value
     **/
    function setUtilizationRate(uint256 value) external onlyProjectOwner {
        utilizationRate = value;
    }

    modifier onlyProjectOwner() {
        require(msg.sender == pool.projectOwner(), "You don't have the access");
        _;
    }
}

// File: BufferNFTCore.sol

abstract contract BufferNFTCore is
    ERC721,
    IBufferOptions,
    AccessControl,
    ERC721URIStorage
{
    using EnumerableSet for EnumerableSet.UintSet;
    using Address for address;

    /// @dev optionId => units
    mapping(uint256 => uint256) public optionSlotMapping;

    /// @dev optionId => operator => units
    mapping(uint256 => ApproveUnits) private _tokenApprovalUnits;

    /// @dev slot => optionIds
    mapping(uint256 => EnumerableSet.UintSet) private _slotTokens;

    uint256 public maxUnits = 1e6;
    uint8 internal _unitDecimals = 18;
    mapping(uint256 => uint256) public _units;

    constructor() ERC721("Buffer Pro", "BFR") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _mintUnits(
        address minter_,
        uint256 optionId_,
        uint256 slot_,
        uint256 units_
    ) internal {
        if (!_exists(optionId_)) {
            _mint(minter_, optionId_);
            _slotTokens[slot_].add(optionId_);
        }

        _units[optionId_] = _units[optionId_] + units_;
        emit TransferUnits(address(0), minter_, 0, optionId_, units_);
    }

    function _mint(
        uint256 optionID,
        address minter_,
        uint256 slot_
    ) internal {
        optionSlotMapping[optionID] = slot_;
        _mintUnits(minter_, optionID, slot_, maxUnits);
    }

    function _split(
        uint256 optionId_,
        uint256 newOptionId_,
        uint256 splitUnits_
    ) internal {
        require(_isApprovedOrOwner(_msgSender(), optionId_), "N2");
        require(!_exists(newOptionId_), "N3");
        setSlotOf(newOptionId_, slotOf(optionId_));
        _units[optionId_] = _units[optionId_] - splitUnits_;

        address owner = ownerOf(optionId_);
        _mintUnits(owner, newOptionId_, slotOf(optionId_), splitUnits_);

        emit Split(owner, optionId_, newOptionId_, splitUnits_);
    }

    function _merge(uint256 optionId_, uint256 targetOptionId_) internal {
        require(_isApprovedOrOwner(_msgSender(), optionId_), "N5");
        require(optionId_ != targetOptionId_, "N6");
        require(slotOf(optionId_) == slotOf(targetOptionId_), "N7");

        address owner = ownerOf(optionId_);
        require(owner == ownerOf(targetOptionId_), "N8");

        uint256 mergeUnits = _units[optionId_];
        _units[targetOptionId_] = mergeUnits + _units[targetOptionId_];
        burnToken(optionId_);

        emit Merge(owner, optionId_, targetOptionId_, mergeUnits);
    }

    function _transferUnitsFrom(
        address from_,
        address to_,
        uint256 optionId_,
        uint256 targetOptionId_,
        uint256 transferUnits_
    ) internal {
        require(from_ == ownerOf(optionId_), "N9");
        require(to_ != address(0), "N10");
        _beforeTransferUnits(
            from_,
            to_,
            optionId_,
            targetOptionId_,
            transferUnits_
        );

        if (_msgSender() != from_ && !isApprovedForAll(from_, _msgSender())) {
            _tokenApprovalUnits[optionId_].allowances[_msgSender()] =
                _tokenApprovalUnits[optionId_].allowances[_msgSender()] -
                transferUnits_;
        }

        _units[optionId_] = _units[optionId_] - transferUnits_;

        if (!_exists(targetOptionId_)) {
            _mintUnits(to_, targetOptionId_, slotOf(optionId_), transferUnits_);
        } else {
            require(ownerOf(targetOptionId_) == to_, "N11");
            require(slotOf(optionId_) == slotOf(targetOptionId_), "N7");
            _units[targetOptionId_] = _units[targetOptionId_] + transferUnits_;
        }
        optionSlotMapping[targetOptionId_] = optionSlotMapping[optionId_];

        emit TransferUnits(
            from_,
            to_,
            optionId_,
            targetOptionId_,
            transferUnits_
        );
    }

    /**
     * @dev See EIP-165: ERC-165 Standard Interface Detection
     * https://eips.ethereum.org/EIPS/eip-165
     **/

    function burnToken(uint256 optionID) internal {
        delete optionSlotMapping[optionID];
        _burn(optionID);
    }

    function _burnUnits(uint256 optionId_, uint256 burnUnits_)
        internal
        returns (uint256 balance)
    {
        address owner = ownerOf(optionId_);
        _units[optionId_] = _units[optionId_] - burnUnits_;

        emit TransferUnits(owner, address(0), optionId_, 0, burnUnits_);
        return _units[optionId_];
    }

    function _burn(uint256 optionId_)
        internal
        override(ERC721, ERC721URIStorage)
    {
        address owner = ownerOf(optionId_);
        uint256 slot = slotOf(optionId_);
        uint256 burnUnits = _units[optionId_];

        _slotTokens[slot].remove(optionId_);
        delete _units[optionId_];

        ERC721._burn(optionId_);
        emit TransferUnits(owner, address(0), optionId_, 0, burnUnits);
    }

    function approve(
        address to_,
        uint256 optionId_,
        uint256 allowance_
    ) public {
        require(_msgSender() == ownerOf(optionId_), "O9");
        _approveUnits(to_, optionId_, allowance_);
    }

    function allowance(uint256 optionId_, address spender_)
        public
        view
        returns (uint256)
    {
        return _tokenApprovalUnits[optionId_].allowances[spender_];
    }

    /**
     * @dev Approve `to_` to operate on `optionId_` within range of `allowance_`
     */
    function _approveUnits(
        address to_,
        uint256 optionId_,
        uint256 allowance_
    ) internal {
        if (_tokenApprovalUnits[optionId_].allowances[to_] == 0) {
            _tokenApprovalUnits[optionId_].approvals.push(to_);
        }
        _tokenApprovalUnits[optionId_].allowances[to_] = allowance_;
        emit ApprovalUnits(to_, optionId_, allowance_);
    }

    /**
     * @dev Clear existing approveUnits for `optionId_`, including approved addresses and their approved units.
     */
    function _clearApproveUnits(uint256 optionId_) internal {
        ApproveUnits storage approveUnits = _tokenApprovalUnits[optionId_];
        for (uint256 i = 0; i < approveUnits.approvals.length; i++) {
            delete approveUnits.allowances[approveUnits.approvals[i]];
            delete approveUnits.approvals[i];
        }
    }

    function unitDecimals() public view returns (uint8) {
        return _unitDecimals;
    }

    function unitsInSlot(uint256 slot_) public view returns (uint256 units_) {
        for (uint256 i = 0; i < tokensInSlot(slot_); i++) {
            units_ = units_ + unitsInToken(tokenOfSlotByIndex(slot_, i));
        }
    }

    function unitsInToken(uint256 optionId_) public view returns (uint256) {
        return _units[optionId_];
    }

    function tokensInSlot(uint256 slot_) public view returns (uint256) {
        return _slotTokens[slot_].length();
    }

    function tokenOfSlotByIndex(uint256 slot_, uint256 index_)
        public
        view
        returns (uint256)
    {
        return _slotTokens[slot_].at(index_);
    }

    function slotOf(uint256 optionId_) public view returns (uint256) {
        return optionSlotMapping[optionId_];
    }

    function exists(uint256 optionID) public view returns (bool) {
        return _exists(optionID);
    }

    function setSlotOf(uint256 optionID, uint256 _slot) internal {
        optionSlotMapping[optionID] = _slot;
    }

    /**
     * @dev Before transferring or burning a token, the existing approveUnits should be cleared.
     */
    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 optionId_
    ) internal virtual override {
        if (from_ != address(0)) {
            _clearApproveUnits(optionId_);
        }
    }

    function _beforeTransferUnits(
        address from_,
        address to_,
        uint256 optionId_,
        uint256 targetOptionId_,
        uint256 transferUnits_
    ) internal {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Template code provided by OpenZepplin Code Wizard
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        override
    {
        return super._setTokenURI(tokenId, _tokenURI);
    }

    /**
     * @dev Template code provided by OpenZepplin Code Wizard
     */
    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/";
    }

    /**
     * @dev Template code provided by OpenZepplin Code Wizard
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}

// File: OptionFeeCalculator.sol

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */

library FeeCalculator {
    /**
     * @notice Calculate the current Utilisation
     * @param amount Option amount
     * @param pool The pool selling the option
     * @return utilization Current utilization
     */
    function getNewUtilisation(
        uint256 amount,
        BufferEpocPoolV2Unintialized pool
    ) public view returns (uint256 utilization) {
        uint256 poolBalance = pool.totalTokenXBalance();
        require(poolBalance > 0, "O8");

        utilization = ((pool.lockedAmount() + amount) * 100e8) / poolBalance;
    }

    /**
     * @notice Calculate the Utilisation adjusted ImpliedVol for the pool according to https://www.desmos.com/calculator/xdmhn97opd
     * @param amount Option amount
     * @param pool The pool selling the option
     * @param config The option configuration
     * @return iv The adjusted ImpliedVol
     */
    function currentImpliedVolatility(
        uint256 amount,
        BufferEpocPoolV2Unintialized pool,
        OptionConfigUnintialized config
    ) public view returns (uint256 iv) {
        iv = config.impliedVolRate();
        uint256 utilization = getNewUtilisation(amount, pool);
        if (utilization > 40e8) {
            iv += (iv * (utilization - 40e8)) / config.utilizationRate();
        }
    }

    /**
     * @notice Used for getting the price for Options in tokenX
     * @param period Option period in seconds (1 days <= period <= 4 weeks)
     * @param amount Option amount
     * @param strike Strike price of the option
     * @param optionType Type of the Option
     * @param currentPrice Current price of the underlying asset
     * @param config The option configuration
     * @param pool The pool selling the option
     * @return total Total price to be paid
     * @return settlementFee Amount to be distributed to the Buffer token holders
     * @return premium Amount that covers the price difference in the ITM options
     */
    function fees(
        uint256 period,
        uint256 amount,
        uint256 strike,
        IBufferOptions.OptionType optionType,
        uint256 currentPrice,
        OptionConfigUnintialized config,
        BufferEpocPoolV2Unintialized pool
    )
        public
        view
        returns (
            uint256 total,
            uint256 settlementFee,
            uint256 premium
        )
    {
        // usdPremium per amount is USD Price of the option in 1e8
        uint256 usdPremium = OptionMath.blackScholesPrice(
            currentImpliedVolatility(amount, pool, config),
            strike,
            currentPrice,
            period,
            optionType == IBufferOptions.OptionType.Call
        );
        premium = (usdPremium * amount) / currentPrice;
        settlementFee = getSettlementFee(amount, config);
        total = settlementFee + premium;
    }

    /**
     * @notice Used for getting the price for Options in USD
     * @param period Option period in seconds (1 days <= period <= 4 weeks)
     * @param amount Option amount
     * @param strike Strike price of the option
     * @param optionType Type of the Option
     * @param currentPrice Current price of the underlying asset
     * @param config The option configuration
     * @param pool The pool selling the option
     * @return total Total price to be paid in USD
     * @return settlementFee Amount to be distributed to the Buffer token holders in USD
     * @return premium Amount that covers the price difference in the ITM options in USD
     */
    function feesUsd(
        uint256 period,
        uint256 amount,
        uint256 strike,
        IBufferOptions.OptionType optionType,
        uint256 currentPrice,
        OptionConfigUnintialized config,
        BufferEpocPoolV2Unintialized pool
    )
        public
        view
        returns (
            uint256 total,
            uint256 settlementFee,
            uint256 premium
        )
    {
        // usdPremium per asset amount is USD Price of the option in 1e8
        uint256 usdPremium = OptionMath.blackScholesPrice(
            currentImpliedVolatility(amount, pool, config),
            strike,
            currentPrice,
            period,
            optionType == IBufferOptions.OptionType.Call
        );
        settlementFee = getSettlementFee(amount, config);
        premium = (usdPremium * amount) / currentPrice;
        total = settlementFee + premium;
    }

    /**
     * @notice Used for getting the price for Binary Options
     * @param period Option period in seconds (1 days <= period <= 4 weeks)
     * @param amount Option amount
     * @param strike Strike price of the option
     * @param isYes whether the option isAbove or not
     * @param isAbove whether the price will stay above this strike or not
     * @param currentPrice Current price of the underlying asset
     * @param config The option configuration
     * @param pool The pool selling the option
     * @return total Total price to be paid
     * @return settlementFee Amount to be distributed to the Buffer token holders
     * @return premium Amount that covers the price difference in the ITM options
     */
    function feesBinary(
        uint256 period,
        uint256 amount,
        uint256 strike,
        bool isYes,
        bool isAbove,
        uint256 currentPrice,
        OptionConfigUnintialized config,
        BufferEpocPoolV2Unintialized pool
    )
        external
        view
        returns (
            uint256 total,
            uint256 settlementFee,
            uint256 premium
        )
    {
        premium = getPremium(
            amount,
            pool,
            config,
            strike,
            period,
            currentPrice,
            isYes,
            isAbove
        );
        settlementFee = getSettlementFee(amount, config);
        total = settlementFee + premium;
    }

    /**
     * @notice Used for getting the price for Binary KPI Options
     * @param optionDetails Details of the option to be priced
     * @param currentPrice Current price of the tokenX
     * @param KPI KPI value for option
     * @param config Option config
     * @param pool pool contract
     * @return total Total price to be paid
     * @return settlementFee Amount to be distributed to the Buffer token holders
     * @return premium Amount that covers the price difference in the ITM options
     */
    function feesKPIBinary(
        IBufferOptions.OptionDetails memory optionDetails,
        uint256 currentPrice,
        uint256 KPI,
        OptionConfigUnintialized config,
        BufferEpocPoolV2Unintialized pool
    )
        external
        view
        returns (
            uint256 total,
            uint256 settlementFee,
            uint256 premium
        )
    {
        premium = getPremiumBinary(
            optionDetails,
            pool,
            config,
            currentPrice,
            KPI
        );
        settlementFee = getSettlementFee(optionDetails.amount, config);
        total = settlementFee + premium;
    }

    /**
     * @notice Calculates settlementFee
     * @param amount Option amount
     * @return fee Settlement fee amount
     */
    function getSettlementFee(uint256 amount, OptionConfigUnintialized config)
        internal
        view
        returns (uint256 fee)
    {
        return (amount * config.settlementFeePercentage()) / 100;
    }

    function getPremium(
        uint256 amount,
        BufferEpocPoolV2Unintialized pool,
        OptionConfigUnintialized config,
        uint256 strike,
        uint256 period,
        uint256 currentPrice,
        bool isYes,
        bool isAbove
    ) internal view returns (uint256 premium) {
        // usdPremium per amount is USD Price of the option in 1e8
        uint256 usdPremium = OptionMath.blackScholesPriceBinary(
            currentImpliedVolatility(amount, pool, config),
            strike,
            currentPrice,
            period,
            isYes,
            isAbove
        );
        premium = (usdPremium * amount) / currentPrice;
    }

    function getPremiumBinary(
        IBufferOptions.OptionDetails memory optionDetails,
        BufferEpocPoolV2Unintialized pool,
        OptionConfigUnintialized config,
        uint256 currentPrice,
        uint256 KPI
    ) internal view returns (uint256 premium) {
        // TODO : check unit
        // usdPremium per amount is USD Price of the option in 1e8
        uint256 usdPremium = OptionMath.blackScholesPriceBinary(
            currentImpliedVolatility(optionDetails.amount, pool, config),
            optionDetails.strike,
            KPI,
            optionDetails.period,
            optionDetails.isYes,
            optionDetails.isAbove
        );
        premium = (usdPremium * optionDetails.amount) / currentPrice;
    }
}

// File: BufferBinaryEuropeanKPIOptions.sol

/**
 * @author Heisenberg
 * @title Buffer TokenX Bidirectional (Call and Put) Options
 * @notice Buffer TokenX Options Contract
 */
contract BufferBinaryEuropeanKPIOptions is
    IBufferOptions,
    Ownable,
    ReentrancyGuard,
    BufferNFTCore
{
    ERC20 public stableCoin;
    ISlidingWindowOracle public KPIOracle;
    address public tvlOracle;
    mapping(uint256 => string) private _tokenURIs;
    IPriceProvider public priceProvider;
    uint256 public nextTokenId = 0;
    mapping(uint256 => Option) public options;
    mapping(uint256 => BinaryOptionType) public binaryOptionType;
    mapping(uint256 => uint256) public expiryToRoundID;
    BufferEpocPoolV2Unintialized public pool;
    OptionConfigUnintialized public config;
    mapping(uint256 => SlotDetail) public slotDetails;
    uint256 internal contractCreationTimestamp;

    bytes32 public constant AUTO_CLOSER_ROLE = keccak256("AUTO_CLOSER_ROLE");

    uint256 public constant minimumYield = 5;

    constructor(
        ERC20 _stableCoin,
        address _tvlOracle,
        ISlidingWindowOracle _KPIOracle,
        IPriceProvider pp,
        BufferEpocPoolV2Unintialized _pool,
        OptionConfigUnintialized _config
    ) {
        stableCoin = _stableCoin;
        KPIOracle = _KPIOracle;
        tvlOracle = _tvlOracle;
        pool = _pool;
        contractCreationTimestamp = block.timestamp;
        config = _config;
        priceProvider = pp;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /************************************************
     *  OPTIONS CORE
     ***********************************************/
    /**
     * @notice Creates a new option
     * @param amount Option amount in tokenX
     * @param isYes Whether the option isAbove or not
     * @param isAbove Whether the price will stay above this strike or not
     * @param metadata Option metadata
     * @return optionID Created option's ID
     */
    function create(
        uint256 amount,
        bool isYes,
        bool isAbove,
        string memory metadata
    ) external nonReentrant returns (uint256 optionID) {
        require(
            pool.isInitialized() && config.isInitialized(),
            "Initialization pending"
        );
        uint256 poolExpiration = pool.fixedExpiry();
        require(poolExpiration > block.timestamp, "O1");
        uint256 period = poolExpiration - block.timestamp;

        require(period >= 12 hours, "O1");

        (uint256 totalFee, uint256 settlementFee, uint256 premium) = fees(
            period,
            amount,
            config.fixedStrike(),
            isYes,
            isAbove
        );

        require(
            totalFee * 365 days * 100 > amount * period * minimumYield,
            "O2"
        );
        uint256 currentPrice = priceProvider.getUsdPrice();
        uint256 tokenXDecimals = 10**(ERC20(pool.tokenX()).decimals());
        if (msg.sender != pool.projectOwner()) {
            // User has to approve first inorder to execute this function
            bool success = stableCoin.transferFrom(
                msg.sender,
                address(this),
                (totalFee * currentPrice * (10**stableCoin.decimals())) /
                    (tokenXDecimals * 1e8)
            );
            require(success, "O3");
        }
        OptionType optionType = OptionType.Put;

        if (
            (isYes == true && isAbove == true) ||
            (isYes == false && isAbove == false)
        ) {
            optionType = OptionType.Call;
        }
        Option memory option = Option(
            State.Active,
            config.fixedStrike(),
            amount,
            amount,
            premium,
            block.timestamp + period,
            optionType
        );
        optionID = _generateTokenId();
        binaryOptionType[optionID] = BinaryOptionType(isYes, isAbove);
        _setOption(optionID, option);
        _mint(
            optionID,
            msg.sender,
            createSlot(optionID, option.strike, option.expiration, optionType)
        );
        _setTokenURI(optionID, metadata);

        _lock(optionID, option.lockedAmount, option.premium);

        if (msg.sender != pool.projectOwner()) {
            stableCoin.transfer(
                pool.projectOwner(),
                (premium * currentPrice * (10**stableCoin.decimals())) /
                    (tokenXDecimals * 1e8)
            );
            stableCoin.transfer(
                owner(),
                (settlementFee * currentPrice * (10**stableCoin.decimals())) /
                    (tokenXDecimals * 1e8)
            );
            emit PayAdminFee(owner(), settlementFee);
        }

        emit Create(optionID, msg.sender, settlementFee, totalFee, metadata);
    }

    function _modifyOption(
        uint256 optionID,
        Option memory option,
        uint256 lockedAmount,
        uint256 amount,
        uint256 premium
    ) internal returns (Option memory modifiedOption) {
        option.lockedAmount = lockedAmount;
        option.amount = amount;
        option.premium = premium;
        modifiedOption = option;
        _setOption(optionID, option);
    }

    function _lock(
        uint256 id,
        uint256 lockedAmount,
        uint256 premium
    ) internal {
        pool.lock(id, lockedAmount, premium);
    }

    /**
     * @notice Sets the expiry price in the oracle
     * @dev a roundId must be provided to confirm price validity,
     * which is the first Chainlink price provided after the expiryTimestamp
     * @param roundId the first roundId after expiryTimestamp
     * @return isCorrectRoundId Has the roundID been set
     */
    function setRoundIDForExpiry(uint256 roundId)
        external
        returns (bool isCorrectRoundId)
    {
        (uint256 roundTimestamp, uint256 KPI) = KPIOracle
            .getTimeWeightedAverageTVL(tvlOracle, roundId);
        uint256 expiryTimestamp = pool.fixedExpiry();
        require(expiryTimestamp < roundTimestamp, "C1");
        require(KPI >= 0, "C2");
        uint256 previousRoundId = roundId - 1;
        while (!isCorrectRoundId) {
            (uint256 previousRoundTimestamp, ) = KPIOracle
                .getTimeWeightedAverageTVL(tvlOracle, previousRoundId);

            if (previousRoundTimestamp == 0) {
                require(previousRoundId > 0, "C3");
                previousRoundId = previousRoundId - 1;
            } else if (previousRoundTimestamp > expiryTimestamp) {
                revert("C4");
            } else {
                isCorrectRoundId = true;
                expiryToRoundID[expiryTimestamp] = previousRoundId;
            }
        }
    }

    /**
     * @notice Unlocks the locked funds if the option was
     * OTM at the time of expiry otherwise exercises it
     * @param optionID ID of the option
     */
    function unlock(uint256 optionID) public {
        Option storage option = options[optionID];
        require(option.expiration <= block.timestamp, "O4");
        require(option.state == State.Active, "O5");
        uint256 roundID = expiryToRoundID[option.expiration];
        require(roundID > 0, "O20");

        (, uint256 KPIAtExpiration) = KPIOracle.getTimeWeightedAverageTVL(
            tvlOracle,
            roundID
        );
        if (
            (option.optionType == OptionType.Call &&
                KPIAtExpiration >= option.strike) ||
            (option.optionType == OptionType.Put &&
                KPIAtExpiration <= option.strike)
        ) {
            exercise(optionID);
        } else {
            option.state = State.Expired;
            pool.unlock(optionID);
            burnToken(optionID);
            emit Expire(optionID, option.premium);
        }
    }

    /**
     * @notice Unlocks an array of options
     * @param optionIDs array of options
     */
    function unlockAll(uint256[] calldata optionIDs) external {
        uint256 arrayLength = optionIDs.length;
        for (uint256 i = 0; i < arrayLength; i++) {
            unlock(optionIDs[i]);
        }
    }

    /**
     * @notice Exercises an option if it was
     * ITM at the time of expiry
     * @param optionID ID of your option
     * @return profit Profit sent to the user
     */
    function exercise(uint256 optionID) public returns (uint256 profit) {
        require(exists(optionID), "O10");

        Option storage option = options[optionID];

        require(option.expiration <= block.timestamp, "O4");
        require(option.state == State.Active, "O14");
        uint256 roundID = expiryToRoundID[option.expiration];
        require(roundID > 0, "O20");

        (, uint256 KPIAtExpiration) = KPIOracle.getTimeWeightedAverageTVL(
            tvlOracle,
            roundID
        );

        if (option.optionType == OptionType.Call) {
            require(option.strike <= KPIAtExpiration, "O17");
        } else {
            require(option.strike >= KPIAtExpiration, "O18");
        }
        profit = option.lockedAmount;
        pool.send(optionID, ownerOf(optionID), profit);
        // Burn the option
        burnToken(optionID);
        option.state = State.Exercised;
        emit Exercise(optionID, profit);
    }

    /**
     * @notice Used for getting the option's price using blackscholes
     * @param period Option period in seconds
     * @param amount Option amount
     * @param strike Strike price of the option
     * @param isYes whether the option isAbove or not
     * @param isAbove whether the price will stay above this strike or not
     * @return total Total price to be paid
     * @return settlementFee Amount to be distributed to the Buffer token holders
     * @return premium Amount that covers the price difference in the ITM options
     */
    function fees(
        uint256 period,
        uint256 amount,
        uint256 strike,
        bool isYes,
        bool isAbove
    )
        public
        view
        returns (
            uint256 total,
            uint256 settlementFee,
            uint256 premium
        )
    {
        uint256 currentPrice = priceProvider.getUsdPrice();
        uint256 KPI = KPIOracle.consult(tvlOracle);
        OptionDetails memory _optionDetails = OptionDetails(
            period,
            amount,
            strike,
            isYes,
            isAbove
        );
        (total, settlementFee, premium) = FeeCalculator.feesKPIBinary(
            _optionDetails,
            currentPrice,
            KPI,
            config,
            pool
        );
    }

    function _generateTokenId() internal returns (uint256) {
        return nextTokenId++;
    }

    function _getOption(uint256 optionID)
        internal
        view
        returns (Option memory)
    {
        return options[optionID];
    }

    function _setOption(uint256 optionID, Option memory option) internal {
        options[optionID] = option;
    }

    function burn(uint256 tokenId_) external {
        require(msg.sender == ownerOf(tokenId_), "O9");
        burnToken(tokenId_);
    }

    /************************************************
     *  ERC3525 Functions
     ***********************************************/

    /**
     * @notice Splits the option
     * @param optionID OptionId to be splitted
     * @param splitUnits_ Units to be splitted into
     * @return newOptionIDs An array of the splitted options
     */
    function split(uint256 optionID, uint256[] calldata splitUnits_)
        external
        returns (uint256[] memory newOptionIDs)
    {
        require(splitUnits_.length > 0, "N1");
        newOptionIDs = new uint256[](splitUnits_.length);
        Option memory option = _getOption(optionID);
        uint256 totalUnits = unitsInToken(optionID);
        uint256 totalChildAmount;
        uint256 totalChildLockedAmount;
        uint256 totalChildPremium;
        // Create child options
        for (uint256 i = 0; i < splitUnits_.length; i++) {
            uint256 newOptionID = _generateTokenId();
            newOptionIDs[i] = newOptionID;

            _split(optionID, newOptionID, splitUnits_[i]);

            uint256 childAmount = (option.amount * splitUnits_[i]) / totalUnits;
            totalChildAmount += childAmount;

            uint256 childLockedAmount = (option.lockedAmount * splitUnits_[i]) /
                totalUnits;
            totalChildLockedAmount += childLockedAmount;

            uint256 childPremium = (option.premium * splitUnits_[i]) /
                totalUnits;
            totalChildPremium += childPremium;

            Option memory newOption = Option(
                option.state,
                option.strike,
                childAmount,
                childLockedAmount,
                childPremium,
                option.expiration,
                option.optionType
            );
            _setOption(newOptionID, newOption);
        }
        // Modify the parent option once all child options are created
        option = _modifyOption(
            optionID,
            option,
            option.lockedAmount - totalChildLockedAmount,
            option.amount - totalChildAmount,
            option.premium - totalChildPremium
        );
        pool.changeLock(optionID, option.lockedAmount, option.premium);

        // Lock the amount in the pool for the child options
        for (uint256 i = 0; i < splitUnits_.length; i++) {
            Option memory newOption = _getOption(newOptionIDs[i]);
            _lock(newOptionIDs[i], newOption.lockedAmount, newOption.premium);
        }
    }

    /**
     * @notice Merges the options
     * @param optionIDs An array of the optionsIds to be merged
     * @param targetOptionID OptionId to be merged into
     */
    function merge(uint256[] calldata optionIDs, uint256 targetOptionID)
        external
    {
        require(optionIDs.length > 0, "N4");
        Option memory targetOption = _getOption(targetOptionID);

        uint256 totalLockedAmount = targetOption.lockedAmount;
        uint256 totalAmount = targetOption.amount;
        uint256 totalPremium = targetOption.premium;

        for (uint256 i = 0; i < optionIDs.length; i++) {
            Option memory option = _getOption(optionIDs[i]);
            totalLockedAmount = totalLockedAmount + option.lockedAmount;
            totalAmount = totalAmount + option.amount;
            totalPremium = totalPremium + option.premium;
            pool.unlockWithoutProfit(optionIDs[i]);
            _merge(optionIDs[i], targetOptionID);
        }
        _modifyOption(
            targetOptionID,
            targetOption,
            totalLockedAmount,
            totalAmount,
            totalPremium
        );
        pool.changeLock(targetOptionID, totalLockedAmount, totalPremium);
    }

    /**
     * @notice Transfer part of units of a option to another option.
     * @param optionID Id of the option to transfer
     * @param transferUnits_ Amount of units to transfer
     */
    function _beforeTransferFrom(uint256 optionID, uint256 transferUnits_)
        internal
        returns (
            uint256 newAmount,
            uint256 newPremium,
            uint256 newLockedAmount,
            Option memory option
        )
    {
        option = _getOption(optionID);
        uint256 totalUnits = unitsInToken(optionID);
        newAmount = (option.amount * transferUnits_) / totalUnits;
        newPremium = (option.premium * transferUnits_) / totalUnits;
        newLockedAmount = (option.lockedAmount * transferUnits_) / totalUnits;

        option = _modifyOption(
            optionID,
            option,
            option.lockedAmount - newLockedAmount,
            option.amount - newAmount,
            option.premium - newPremium
        );
        pool.changeLock(optionID, option.lockedAmount, option.premium);
    }

    /**
     * @notice Transfer part of units of a option to target address.
     * @param from_ Address of the option sender
     * @param to_ Address of the option recipient
     * @param optionID Id of the option to transfer
     * @param transferUnits_ Amount of units to transfer
     */
    function transferFrom(
        address from_,
        address to_,
        uint256 optionID,
        uint256 transferUnits_
    ) external returns (uint256 newOptionID) {
        newOptionID = _generateTokenId();
        (
            uint256 newAmount,
            uint256 newPremium,
            uint256 newLockedAmount,
            Option memory option
        ) = _beforeTransferFrom(optionID, transferUnits_);
        Option memory newOption = Option(
            option.state,
            option.strike,
            newAmount,
            newLockedAmount,
            newPremium,
            option.expiration,
            option.optionType
        );
        _setOption(newOptionID, newOption);

        _lock(newOptionID, newLockedAmount, newPremium);
        _transferUnitsFrom(from_, to_, optionID, newOptionID, transferUnits_);
    }

    /**
     * @notice Transfer part of units of a option to another option.
     * @param from_ Address of the option sender
     * @param to_ Address of the option recipient
     * @param optionID Id of the option to transfer
     * @param targetOptionID Id of the option to receive
     * @param transferUnits_ Amount of units to transfer
     */
    function transferFrom(
        address from_,
        address to_,
        uint256 optionID,
        uint256 targetOptionID,
        uint256 transferUnits_
    ) external virtual {
        require(exists(targetOptionID), "N12");
        (
            uint256 newAmount,
            uint256 newPremium,
            uint256 newLockedAmount,

        ) = _beforeTransferFrom(optionID, transferUnits_);
        Option memory targetOption = _getOption(targetOptionID);
        targetOption = _modifyOption(
            targetOptionID,
            targetOption,
            targetOption.lockedAmount + newLockedAmount,
            targetOption.amount + newAmount,
            targetOption.premium + newPremium
        );

        pool.changeLock(
            targetOptionID,
            targetOption.lockedAmount,
            targetOption.premium
        );
        _transferUnitsFrom(
            from_,
            to_,
            optionID,
            targetOptionID,
            transferUnits_
        );
    }

    function createSlot(
        uint256 optionID,
        uint256 strike,
        uint256 expiration,
        OptionType optionType
    ) internal returns (uint256 slot) {
        slot = uint256(
            keccak256(abi.encode(strike, expiration, optionType, optionID))
        );
        require(!slotDetails[slot].isValid, "N14");
        slotDetails[slot] = SlotDetail(strike, expiration, optionType, true);
    }
}