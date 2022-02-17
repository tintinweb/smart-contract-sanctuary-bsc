// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);


    /**
     * @dev Returns the amount of tokens in existence.
     */
    function decimals() external view returns (uint8);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
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
     * _Available since v3.3._
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

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
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
    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
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
    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
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
    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return _at(set._inner, index);
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
    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(value)));
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
    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint256(_at(set._inner, index)));
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
    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
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
    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";
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

    constructor() internal {
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

interface IXRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IXRouter02 is IXRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// For interacting with our own strategy
interface IStrategy {
    // Total want tokens managed by strategy
    function wantLockedTotal() external view returns (uint256);

    // Sum of all shares of users to wantLockedTotal
    function sharesTotal() external view returns (uint256);

    // Sum of TVL
    function getTotalValueLocked() external view returns (uint256);

    // Main want token compounding function
    function earn() external;

    // Transfer want tokens autoFarm -> strategy
    function deposit(uint256 _wantAmt)
        external
        returns (uint256);

    // Transfer want tokens strategy -> autoFarm
    function withdraw(uint256 _wantAmt)
        external
        returns (uint256);
    
    // Get tokens in case they get stucked
    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) external;

    function WETH() external pure returns (address);
}

interface IEllipsis {
    function get_dy(int128 i, int128 j, uint256 dx) external returns (uint256);
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
}

contract MainStakingContractBSC is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 shares; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    // Info of each pool.
    struct PoolInfo {
        uint256 lastRewardBlock;  // Last block number that native distribution occurs.
        uint256 accNativePerShare; // Accumulated native per share, times PRECISION_FACTOR. See below.
        uint256 rewardPerBlock;
    }
    
    // Strategy struct
    struct Strategy {
        uint256 allocPoint;
        bool noWithdraw;
        address strat;
    }

    // Info of each pool.
    PoolInfo public poolInfo;

    // Token address
    address public NATIVE;
    uint256 public startBlock; // https://bscscan.com/block/countdown/8049678

    uint256 public launchTimestamp;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; 
    
    // Info of each strat.  
    Strategy[] public strategies; 
    // Total strategy alloc points. Must be the sum of all allocation points in all pools
    uint256 public totalStrategyAllocPoint = 0;
    // Shares total
    uint256 public sharesTotal = 0;
    
    // BUSD contract address
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public WBNB;
    
    // Stable tokens
    address[] public token;
    address[] public uniRouterAddress;
    address[][] public pathTokenToBUSD;

    address public constant ELLIPSIS_3EP_POOL = 0x160CAed03795365F3A589f10C379FfA7d75d4E76;
    
    // Router
    uint256 public routerDeadlineDuration = 300;

    // The precision factor
    uint256 public PRECISION_FACTOR;

    // Gov
    address public gov;
    
    // Events
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event WithdrawStrategy(uint256 index, uint256 stratAmt);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    modifier onlyGov() {
        require(gov == _msgSender(), "Gov: caller is not the gov");
        _;
    }
    
    // Contract constructor
    constructor(address _native, uint256 _launchTimestamp, uint256 _startBlock, uint256 _rewardPerBlock) public {
        // Set variables
        NATIVE = _native;
        startBlock = _startBlock;
        // Get WBNB from router
        WBNB = IXRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E).WETH();
        // Set stable tokens
        token.push(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // BUSD (0)
        token.push(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d); // USDC (1)
        token.push(0x55d398326f99059fF775485246999027B3197955); // USDT (2)
        token.push(0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3); // DAI
        token.push(0x23396cF899Ca06c4472205fC903bDB4de249D6fC); // UST
        // Set uniRouterAddress
        uniRouterAddress.push(ELLIPSIS_3EP_POOL); // PCS V2
        uniRouterAddress.push(ELLIPSIS_3EP_POOL); // PCS V2
        uniRouterAddress.push(ELLIPSIS_3EP_POOL); // PCS V2
        uniRouterAddress.push(0x10ED43C718714eb63d5aA57B78B54704E256024E); // PCS V2
        uniRouterAddress.push(0x10ED43C718714eb63d5aA57B78B54704E256024E); // PCS V2
        // Path tokens to BUSD
        pathTokenToBUSD.push([token[0], BUSD]);
        pathTokenToBUSD.push([token[1], BUSD]);
        pathTokenToBUSD.push([token[2], BUSD]);
        pathTokenToBUSD.push([token[3], BUSD]);
        pathTokenToBUSD.push([token[4], BUSD]);
        // Pool
        poolInfo = PoolInfo({
            lastRewardBlock: startBlock,
            accNativePerShare: 0,
            rewardPerBlock: _rewardPerBlock
        });
        // Precision factor
        uint256 decimalsRewardToken = uint256(IERC20(NATIVE).decimals());
        PRECISION_FACTOR = uint256(10**(uint256(30).sub(decimalsRewardToken)));
        // Launch
        launchTimestamp = _launchTimestamp;
        // Set gov
        gov = address(msg.sender);
    }




    /** VIEWS */

    // Get token path to BUSD
    function getTokenToBUSDPath(uint256 _index) public view returns (address[] memory) {
        return pathTokenToBUSD[_index];
    }

    // Get token path to BUSD
    function getBUSDToTokenPath(uint256 _index) public view returns (address[] memory) {
        return reverseArray(pathTokenToBUSD[_index]);
    }
    
    // Get token id
    function getTokenId(address _token) public view returns (uint256) {
        uint256 tokenId = 999;
        for (uint256 i = 0; i < token.length; i++) {
            if (address(token[i]) == address(_token)) {
                tokenId = i;
            }
        }
        require(tokenId < token.length, "token not found");
        return tokenId;
    }
    
    // Get total value locked
    function getTotalValueLocked() public view returns (uint256) {
        uint256 tvl = 0;
        for (uint256 i = 0; i < strategies.length; i++) {
            tvl = tvl.add(IStrategy(strategies[i].strat).getTotalValueLocked());
        }
        return tvl;
    }

    // Get total value locked withdraw
    function getTotalValueLockedWithdraw() public view returns (uint256) {
        uint256 tvl = 0;
        for (uint256 i = 0; i < strategies.length; i++) {
            if (strategies[i].noWithdraw == false) {
                tvl = tvl.add(IStrategy(strategies[i].strat).getTotalValueLocked());
            }
        }
        return tvl;
    }
    
    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from);
    }

    // Get total user balance for front purposes
    function getUserBalance(address _user) public view returns (uint256) {
        if (sharesTotal == 0) {
            return 0;
        }
        return getTotalValueLocked().mul(userInfo[0][_user].shares).div(sharesTotal);
    }

    // View function to see pending Reward on frontend.
    function pendingNative(address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[0][_user];
        uint256 accNativePerShare = pool.accNativePerShare;
        if (block.number < startBlock) {
            return 0;
        }
        if (block.number > pool.lastRewardBlock && sharesTotal != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 nativeReward = multiplier.mul(pool.rewardPerBlock);
            accNativePerShare = accNativePerShare.add(nativeReward.mul(PRECISION_FACTOR).div(sharesTotal));
        }
        return user.shares.mul(accNativePerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
    }




    /** FUNCTIONS */

    // Want tokens moved from user to strategies
    function deposit(uint256 _wantAmt0, uint256 _wantAmt1, uint256 _wantAmt2, uint256 _wantAmt3, uint256 _wantAmt4) public nonReentrant {
        // start block
        require(launchTimestamp <= block.timestamp, "not launched yet");
        // init amount array
        uint256[5] memory amounts = [_wantAmt0, _wantAmt1, _wantAmt2, _wantAmt3, _wantAmt4];
        // Get pool and user info
        UserInfo storage user = userInfo[0][msg.sender];
        PoolInfo storage pool = poolInfo;
        // Update pool and transfer pending natives
        updatePool();
        if (user.shares > 0) {
            uint256 pending = user.shares.mul(pool.accNativePerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
            if (pending > 0) {
                IERC20(NATIVE).transfer(msg.sender, pending);
            }
            user.rewardDebt = user.shares.mul(pool.accNativePerShare).div(PRECISION_FACTOR);
        }
        // Get actual total value locked
        uint256 oldTvl = getTotalValueLocked();
        // Get everything, convert everything to BUSD and get final deposited amount
        uint256 totalWantAmount = getAndUnifyStables(amounts);
        // If user deposited something
        if (totalWantAmount > 0) {
            // Send BUSD to strategies
            for (uint256 i = 0; i < strategies.length; i++) {
                // only if allocPoint higher than 0
                if (strategies[i].allocPoint > 0) {
                    // init strat want amount
                    uint256 _stratWantAmt = totalWantAmount.mul(strategies[i].allocPoint).div(totalStrategyAllocPoint);
                    // deposit in strategy
                    IERC20(BUSD).safeIncreaseAllowance(strategies[i].strat, _stratWantAmt);
                    // sum shares returned by strategy
                    IStrategy(strategies[i].strat).deposit(_stratWantAmt);
                }
            }
            // Add shares to user
            uint256 newTvl = getTotalValueLocked();
            uint256 busdAdded = newTvl.sub(oldTvl);
            uint256 sharesAdded = busdAdded;
            if (oldTvl > 0) {
                sharesAdded = busdAdded.mul(sharesTotal).div(oldTvl);
            }
            user.shares = user.shares.add(sharesAdded);
            sharesTotal = sharesTotal.add(sharesAdded);
        }
        // Update reward debt
        user.rewardDebt = user.shares.mul(pool.accNativePerShare).div(PRECISION_FACTOR);
        // Emit event
        emit Deposit(msg.sender, 0, totalWantAmount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _wantAmt0, uint256 _wantAmt1, uint256 _wantAmt2, uint256 _wantAmt3, uint256 _wantAmt4) public nonReentrant {
        // Get user and pool info
        UserInfo storage user = userInfo[0][msg.sender];
        PoolInfo storage pool = poolInfo;
        // Total value locked (BUSD)
        uint256 oldTvl = getTotalValueLocked();
        // fail if user has no deposited value or share totals are 0
        require(user.shares > 0, "user.shares is 0");
        require(sharesTotal > 0, "sharesTotal is 0");
        // Update pool and transfer pending natives
        updatePool();
        if (user.shares > 0) {
            uint256 pending = user.shares.mul(pool.accNativePerShare).div(PRECISION_FACTOR).sub(user.rewardDebt);
            if (pending > 0) {
                IERC20(NATIVE).transfer(msg.sender, pending);
            }
            user.rewardDebt = user.shares.mul(pool.accNativePerShare).div(PRECISION_FACTOR);
        }
        // init amount array
        uint256[5] memory amounts = [_wantAmt0, _wantAmt1, _wantAmt2, _wantAmt3, _wantAmt4];
        uint256 wantAmtTotal = 0;
        wantAmtTotal = wantAmtTotal.add(_wantAmt0);
        wantAmtTotal = wantAmtTotal.add(_wantAmt1);
        wantAmtTotal = wantAmtTotal.add(_wantAmt2);
        wantAmtTotal = wantAmtTotal.add(_wantAmt3);
        wantAmtTotal = wantAmtTotal.add(_wantAmt4);
        uint256 userTotalAmt = getUserBalance(msg.sender);
        // fix to fit user total staked. if amount is higher than 99% of user balance, withdraw all
        if (wantAmtTotal > userTotalAmt.mul(9999).div(10000)) {
            wantAmtTotal = userTotalAmt;
        }
    
        // if user is withdrawing
        uint256 totalValueLockedWithdraw = getTotalValueLockedWithdraw();
        if (wantAmtTotal > 0) {
            // Get actual BUSD balance
            uint256 pre = IERC20(BUSD).balanceOf(address(this));
            // Withdraw want tokens from strategy
            for (uint256 i = 0; i < strategies.length; i++) {
                // If is withdrawal
                if (strategies[i].noWithdraw == false) {
                    // Get amount to withdraw from strategy
                    uint256 _stratAmt = wantAmtTotal
                        .mul(IStrategy(strategies[i].strat).getTotalValueLocked())
                        .div(totalValueLockedWithdraw);
                    // Event
                    emit WithdrawStrategy(i, _stratAmt);
                    // Remove shares
                    if (_stratAmt > 0) {
                        IStrategy(strategies[i].strat).withdraw(_stratAmt);
                    }
                }
            }
            // Actual BUSD removed
            uint256 busdRemoved = IERC20(BUSD).balanceOf(address(this)).sub(pre);
            // init total shares removed
            uint256 newTvl = getTotalValueLocked();
            uint256 tvlRemoved = oldTvl.sub(newTvl);
            uint256 sharesRemoved = tvlRemoved.mul(sharesTotal).div(oldTvl);
            // fix shares removal
            if (sharesRemoved > user.shares) {
                user.shares = 0;
            } else {
                user.shares = user.shares.sub(sharesRemoved);
            }
            if (sharesRemoved > sharesTotal) {
                sharesRemoved = sharesTotal;
            }
            sharesTotal = sharesTotal.sub(sharesRemoved);
            // send to user
            sendStablesToUser(busdRemoved, amounts, wantAmtTotal);
        }

        // Update reward debt
        user.rewardDebt = user.shares.mul(pool.accNativePerShare).div(PRECISION_FACTOR);

        // Emit event
        emit Withdraw(msg.sender, 0, wantAmtTotal);
    }




    /** GOV */

    // Set new governorn
    function setGov(address _address) public onlyGov {
        gov = _address;
    }
    
    // Set uniRouterAddress
    function setUniRouterAddress(uint256 _stableID, address _uniRouterAddress) public onlyGov {
        uniRouterAddress[_stableID] = _uniRouterAddress;
    }
    
    // Set uniRouterAddress
    function setPathTokenToBUSD(uint256 _stableID, address[] memory _pathTokenToBUSD) public onlyGov {
        require(address(_pathTokenToBUSD[_pathTokenToBUSD.length-1]) == address(BUSD), "wrong path");
        pathTokenToBUSD[_stableID] = _pathTokenToBUSD;
    }

    // Set startBlock
    function setStartBlock(uint256 _startBlock) public onlyGov {
        startBlock = _startBlock;
        updatePool();
    }

    // Set launchTimestamp
    function setLaunchTimestamp(uint256 _launchTimestamp) public onlyGov {
        launchTimestamp = _launchTimestamp;
    }

    // Set rewardPerBlock
    function setRewardPerBlock(uint256 _rewardPerBlock) public onlyGov {
        poolInfo.rewardPerBlock = _rewardPerBlock;
    }
    
    // Withdraw stucked tokens in the contract
    function inCaseTokensGetStuck(address _token, uint256 _amount) public onlyGov {
        require(address(_token) == address(NATIVE), "token not native");
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    // Add strategy
    function addStrategy(address _strat, uint256 _allocPoint, bool _noWithdraw) public onlyGov {
        // strat check no duplicates
        bool stratDuplicated = false;
        for (uint256 i = 0; i < strategies.length; i++) {
            if (address(strategies[i].strat) == address(_strat)) {
                stratDuplicated = true;
            } 
        }
        require(stratDuplicated == false, "strategy already exists");
        // update total alloc points
        totalStrategyAllocPoint = totalStrategyAllocPoint.add(_allocPoint);
        // add strategy
        strategies.push(
            Strategy({
                allocPoint: _allocPoint,
                strat: _strat,
                noWithdraw: _noWithdraw
            })
        );
    }

    // Set strategy allocs
    function setStrategyNoWithdraw(uint256 _stratId, bool _noWithdraw) public onlyGov {
        require(
            IStrategy(strategies[_stratId].strat).getTotalValueLocked() < 10e18 || 
            strategies[_stratId].noWithdraw == true, 
            "wrong noWithdraw"
        );
        strategies[_stratId].noWithdraw = _noWithdraw;
    }




    /** OWNER */

    // Alloc and reinvest
    function setStrategyAllocsAndReinvest(
        uint256 _stratId, 
        uint256 _allocPoint, 
        uint256 _stratIdFrom, 
        uint256 _stratIdTo, 
        uint256 _amountInBUSD
    ) public onlyOwner {
        setStrategyAllocs(_stratId, _allocPoint);
        strategyReinvestToAnotherStrategy(_stratIdFrom, _stratIdTo, _amountInBUSD);
    }

    // Alloc and reinvest
    function setStrategyAllocsAndReinvestAll(
        uint256 _stratId, 
        uint256 _allocPoint, 
        uint256 _stratIdFrom, 
        uint256 _stratIdTo 
    ) public onlyOwner {
        setStrategyAllocs(_stratId, _allocPoint);
        strategyReinvestAllToAnotherStrategy(_stratIdFrom, _stratIdTo);
    }
    
    // Set strategy allocs
    function setStrategyAllocs(uint256 _stratId, uint256 _allocPoint) public onlyOwner {
        totalStrategyAllocPoint = totalStrategyAllocPoint.sub(strategies[_stratId].allocPoint).add(_allocPoint);
        strategies[_stratId].allocPoint = _allocPoint;
    }

    // Reinvest Only if strat allocs = 0;
    function strategyReinvestToAnotherStrategy(uint256 _stratIdFrom, uint256 _stratIdTo, uint256 _amountInBUSD) public onlyOwner {
        // Require strat tvl >= amount
        require(IStrategy(strategies[_stratIdFrom].strat).getTotalValueLocked() >= _amountInBUSD, "not enough busd amount in strat");
        // Get actual BUSD balance
        uint256 pre = IERC20(BUSD).balanceOf(address(this));
        // Withdraw from strategy
        IStrategy(strategies[_stratIdFrom].strat).withdraw(_amountInBUSD);
        // Get actual BUSD balance minous pre
        uint256 totalBUSDRemoved = IERC20(BUSD).balanceOf(address(this)).sub(pre);
        // Deposit into strategy
        if (totalBUSDRemoved > 0) {
            IERC20(BUSD).safeIncreaseAllowance(strategies[_stratIdTo].strat, totalBUSDRemoved);
            IStrategy(strategies[_stratIdTo].strat).deposit(totalBUSDRemoved);
        }
    }

    // Reinvest all
    function strategyReinvestAllToAnotherStrategy(uint256 _stratIdFrom, uint256 _stratIdTo) public onlyOwner {
        // Get actual BUSD balance
        uint256 pre = IERC20(BUSD).balanceOf(address(this));
        // Withdraw from strategy
        uint256 _amountInBUSD = IStrategy(strategies[_stratIdFrom].strat).getTotalValueLocked();
        IStrategy(strategies[_stratIdFrom].strat).withdraw(_amountInBUSD);
        // Get actual BUSD balance minous pre
        uint256 totalBUSDRemoved = IERC20(BUSD).balanceOf(address(this)).sub(pre);
        // Deposit into strategy
        if (totalBUSDRemoved > 0) {
            IERC20(BUSD).safeIncreaseAllowance(strategies[_stratIdTo].strat, totalBUSDRemoved);
            IStrategy(strategies[_stratIdTo].strat).deposit(totalBUSDRemoved);
        }
    }





    /** UTILS */

    // reverse array
    function reverseArray(address[] memory _array) public pure returns(address[] memory) {
        address[] memory reversedArray = new address[](_array.length);
        uint256 counter = 0;
        for (uint i = _array.length; i > 0; i--) {
            reversedArray[counter] = _array[i-1];
            counter++;
        }
        return reversedArray;
    }

    
    // Get and convert all stables into BUSD
    function getAndUnifyStables(uint256[5] memory amounts) internal returns (uint256) {
        // Init total deposited
        uint256 totalWantAmount = 0;
        // Iterate stables
        for (uint256 i = 0; i < amounts.length; i++) {
            if (amounts[i] > 0) {
                IERC20(token[i]).safeTransferFrom(address(msg.sender), address(this), amounts[i]);
                totalWantAmount = totalWantAmount.add(swapToBUSD(i, amounts[i]));
            }
        }
        return totalWantAmount;
    }
    
    // onvert BUSD to stables and send to user
    function sendStablesToUser(uint256 busdAmount, uint256[5] memory amounts, uint256 wantAmtTotal) internal {
        // iterate amounts
        for (uint256 i = 0; i < amounts.length; i++) {
            // calculate amount of token i
            uint256 amount = busdAmount.mul(amounts[i]).div(wantAmtTotal);
            // if there is an amount
            if (amount > 0) {
                // swap to token
                uint256 swappedAmt = swapFromBUSD(i, amount);
                // transfer
                IERC20(token[i]).safeTransfer(address(msg.sender), swappedAmt);
            }
        }
    }
    
    // Swap BUSD to token i
    function swapFromBUSD(uint256 _stableID, uint256 _wantAmt) internal returns (uint256) {
        // if token is BUSD, return exactly the same
        if (token[_stableID] == BUSD) { 
            return _wantAmt; 
        }
        // increase allowance
        IERC20(BUSD).safeIncreaseAllowance(uniRouterAddress[_stableID], _wantAmt);
        // get actual token quantity
        uint256 pre = IERC20(token[_stableID]).balanceOf(address(this));
        // Swap BUSD to token i tokens
        if (address(uniRouterAddress[_stableID]) == ELLIPSIS_3EP_POOL) {
            uint256 dy = IEllipsis(uniRouterAddress[_stableID]).get_dy(0, int128(_stableID), _wantAmt);
            IEllipsis(uniRouterAddress[_stableID]).exchange(0, int128(_stableID), _wantAmt, dy);
        } else {
            IXRouter02(uniRouterAddress[_stableID])
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _wantAmt,
                0,
                reverseArray(pathTokenToBUSD[_stableID]),
                address(this),
                now + routerDeadlineDuration
            );
        }
        // return swap token quantity
        return IERC20(token[_stableID]).balanceOf(address(this)).sub(pre);
    }
    
    // Swap stables to BUSD
    function swapToBUSD(uint256 _stableID, uint256 _wantAmt) internal returns (uint256) {
        // if token is BUSD, return exactly the same
        if (token[_stableID] == BUSD) { 
            return _wantAmt; 
        }
        // increase allowance
        IERC20(token[_stableID]).safeIncreaseAllowance(uniRouterAddress[_stableID], _wantAmt);
        // get actual BUSD quantity
        uint256 pre = IERC20(BUSD).balanceOf(address(this));
        // Swap all dust tokens to earned tokens
        if (address(uniRouterAddress[_stableID]) == ELLIPSIS_3EP_POOL) {
            uint256 dy = IEllipsis(uniRouterAddress[_stableID]).get_dy(int128(_stableID), 0, _wantAmt);
            IEllipsis(uniRouterAddress[_stableID]).exchange(int128(_stableID), 0, _wantAmt, dy);
        } else {
            IXRouter02(uniRouterAddress[_stableID])
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _wantAmt,
                0,
                pathTokenToBUSD[_stableID],
                address(this),
                now + routerDeadlineDuration
            );
        }
        // return swap token quantity
        return IERC20(BUSD).balanceOf(address(this)).sub(pre);
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool() public {
        // Get pool info
        PoolInfo storage pool = poolInfo;
        if (block.number <= startBlock) {
            pool.lastRewardBlock = startBlock;
        }
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        // Get shares total
        if (sharesTotal == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        // Get multiplier from last reward to this block
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        if (multiplier <= 0) {
            return;
        }
        // Calculate native rewards
        uint256 nativeReward = multiplier.mul(pool.rewardPerBlock);
        // Update pool variables
        pool.accNativePerShare = pool.accNativePerShare.add(nativeReward.mul(PRECISION_FACTOR).div(sharesTotal));
        pool.lastRewardBlock = block.number;
    }
}