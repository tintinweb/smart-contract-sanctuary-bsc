pragma solidity ^0.8.0;

import "../interfaces/IWBNB.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2ERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract AggregatorExecutor is Ownable {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using ECDSA for bytes;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct SwapStep {
        address fromToken;
        address toToken;
        address pair;
        uint256 fee;
    }

    uint256 public DENOMINATOR_FEE = 10000;
    IWBNB public WBNB = IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // mainnet

    address public BNB = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    EnumerableSet.AddressSet private signers;

    modifier ensure(uint256 _deadline) {
        require(_deadline >= block.timestamp, 'AggregatorExecutor: EXPIRED');
        _;
    }

    //=========== external functions ============//
    function swap(SwapStep[] memory _steps, uint256 _amountIn, uint256 _amountOutMin, address payable _receiver, uint256 _deadline, bytes calldata _signature)
    external payable
    ensure(_deadline)
    {
        uint256 _length = _steps.length;
        checkSigner(_signature, _steps);
        //check input eth
        if(_steps[0].fromToken == address(BNB) && msg.value > 0) {
            require(_amountIn == msg.value,"AggregatorExecutor: !msgValue");
            _steps[0].fromToken = address(WBNB);
            WBNB.deposit{value: _amountIn}();
        } else {
            IERC20(_steps[0].fromToken).safeTransferFrom(msg.sender, address(this), _amountIn);
        }

        //swap
        bool _needConvert = false;
        if (_steps[_length - 1].toToken == address(BNB)) {
            _steps[_length - 1].toToken = address(WBNB);
            _needConvert = true;
        }
        for (uint256 i = 0; i < _length; i++) {
            _swap(_steps[i], i == _length - 1, address(this));
        }

        uint256 _amountOut = IERC20(_steps[_length - 1].toToken).balanceOf(address(this));
        require(_amountOut >= _amountOutMin, "AggregatorExecutor: price impact too high");

        //send eth to user
        if (_needConvert) {
            WBNB.withdraw(_amountOut);
            (bool _sent,) = _receiver.call{value: _amountOut}("");
            require(_sent, "AggregatorExecutor: Failed to send BNB");
        } else {
            IERC20 _token = IERC20(_steps[_length - 1].toToken);
            _token.safeTransfer(_receiver, _token.balanceOf(address(this)));        }
    }

    function rescueFunds(IERC20 token, uint256 amount) external onlyOwner {
        token.safeTransfer(msg.sender, amount);
    }

    function destroy() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }

    //=========== internal functions ============//
    function checkSigner(bytes memory _signature, SwapStep[] memory _steps) internal{
        bytes32 _hash = keccak256(abi.encode(address(this), _steps)).toEthSignedMessageHash();
        address _signer = _hash.recover(_signature);
        require(signers.contains(_signer), "AggregatorExecutor: !verify signature fail");
    }

    function _getAmountOut
    (
        address _fromToken,
        address _toToken,
        uint256 _amountIn,
        uint256 _reserve0,
        uint256 _reserve1,
        uint256 _fee,
        address _token0)
    internal returns(uint256 _amountOut){
        uint256 _amountInWithFee = _amountIn * (DENOMINATOR_FEE - _fee);
        if (_fromToken == _token0) {
            _amountOut = (_amountInWithFee * _reserve1) / (_reserve0 * DENOMINATOR_FEE + _amountInWithFee);
        } else {
            _amountOut = (_amountInWithFee * _reserve0) / (_reserve1 * DENOMINATOR_FEE + _amountInWithFee);
        }
    }

    function _swap(
        SwapStep memory _step,
        bool _finish,
        address _receiver
    ) internal returns (uint256 _amountOut) {

        //get info
        IUniswapV2Pair _pair = IUniswapV2Pair(_step.pair);
        require(address(_pair) != address(0), "AggregatorExecutor: Pair address is zero");
        address _token0 = _pair.token0();
        uint256 _amountIn = IERC20(_step.fromToken).balanceOf(address(this));

        //get reserve
        (uint256 _reserve0, uint256 _reserve1, ) = _pair.getReserves();
        _amountOut = _getAmountOut(_step.fromToken, _step.toToken, _amountIn, _reserve0, _reserve1, _step.fee, _token0);

        // get amount out
        (uint256 _amount0Out, uint256 _amount1Out) = _step.fromToken == _token0 ? (uint256(0), _amountOut) : (_amountOut, uint256(0));

        //swap
        IERC20(_step.fromToken).safeTransfer(address(_pair), _amountIn);
        _pair.swap(_amount0Out, _amount1Out, _receiver, new bytes(0));

        //event trade mining
        emit TradeMining(tx.origin, address(_pair), _step.fromToken, _step.toToken, _amountIn, _amountOut);
    }

    receive() external payable {}

    //=========== Restrict ============//
    function changeSigner(address _signer, bool _action) external onlyOwner {
        if(_action) {
            require(signers.add(_signer), "AggregatorExecutor: !added");
        } else {
            require(signers.remove(_signer), "AggregatorExecutor: !removed");
        }
        emit SignerUpdated(_signer, _action);
    }

    //=========== View functions ========//
    function getSigner() external view returns (address[] memory) {
        return signers.values();
    }

    function isSigner(address _operator) external view returns (bool) {
        return signers.contains(_operator);
    }

    function verifySignature(bytes memory _signature, SwapStep[] memory _steps) external view returns(bool) {
        bytes32 _hash = keccak256(abi.encode(address(this), _steps)).toEthSignedMessageHash();
        address _signer = _hash.recover(_signature);
        return signers.contains(_signer);
    }

    //=========== Event ============//
    event TradeMining(address _user, address _pool, address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOut);
    event SignerUpdated(address _signer, bool _action);
}

pragma solidity =0.8.4;
interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;

    function balanceOf(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2ERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

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

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../libraries/Math.sol";
import "../interfaces/IUserLevel.sol";
import "../interfaces/IAvatar.sol";
import "../interfaces/IStaking.sol";
import "../interfaces/IFarming.sol";


contract UserLevel is Ownable, IUserLevel {
    using EnumerableSet for EnumerableSet.AddressSet;
    using ECDSA for bytes32;
    using Counters for Counters.Counter;
    using Address for address;

    EnumerableSet.AddressSet private validators;
    EnumerableSet.AddressSet private staking;

    mapping(address => BonusInfo) private boostLevel;
    mapping(address => UserInfo) private user;
    mapping(address => Counters.Counter) private nonce;

    uint constant public ONE_HUNDRED_PERCENT = 10000;
    uint public baseLevel = 5000;

    IAvatar public avatarUserLevel;
    IFarming public farming;

    //===================EVENT=================== //
    event ConfigBaseLevel(uint _old, uint _new);
    event UpdateUserExp(address _user, uint _oldExp, uint _newExp, uint _oldLevel, uint _newLevel, address[] _validators);
    event ConfigBonus(address _contract, uint[] _bonus, uint[] _level);
    event AddValidator(address[] _validators);
    event RemoveValidator(address[] _validators);
    event AvatarAddressChanged(address _avatar);
    event FarmingAddressChanged(address _farming);
    event SetUserExp(address _user, uint _oldExp, uint _newExp, uint _oldLevel, uint _newLevel);

    // ================= PUBLIC FUNCTIONS ================= //
    function getNonce(address _user) public view override returns (uint) {
        return nonce[_user].current();
    }

    function getUserLevel(address _user) public view override returns(uint _level){
        _level= user[_user].level;
    }

    function getUserExp(address _user) public view override returns(uint _exp){
        _exp= user[_user].exp;
    }

    function getUserInfo(address _user) public view override returns(UserInfo memory _userInfo){
        _userInfo = user[_user];
    }

    function getConfigBonus(address _contract) external view returns(uint256[] memory, uint256[] memory) {
        return (boostLevel[_contract].level, boostLevel[_contract].bonus);
    }

    // ================= EXTERNAL FUNCTIONS ================= //
    function getBonus(address _user, address _contract) external view override returns(uint256, uint256) {
        if(boostLevel[_contract].level.length == 0){
            return(0, ONE_HUNDRED_PERCENT);
        }

        uint _levelUser = getUserLevel(_user);
        BonusInfo storage info = boostLevel[_contract];

        for(uint i = 0; i < info.level.length; i++) {
            if(_levelUser <= info.level[i]) {
                return (info.bonus[i], ONE_HUNDRED_PERCENT);
            }
        }

        return (info.bonus[info.bonus.length - 1], ONE_HUNDRED_PERCENT);
    }

    function updateUserExp(uint _exp, uint _expiredTime, address[] memory _lStaking, uint[] memory _pIds, bytes[] memory _signature) external override{
        require(msg.sender != address(0),"UserLevel: Address not zero");
        require(block.timestamp <= _expiredTime, "UserLevel: Expired time");

        bytes32 _hash = _prefixed(keccak256(abi.encodePacked(_exp, _expiredTime, _lStaking, _pIds, msg.sender, address(this), _useNonce(msg.sender))));
        address[] memory _validatorSignature = _getValidatorSignature(_hash, _signature);

        require(_validatorSignature.length > 0, "UserLevel: Signature not empty");
        for(uint i = 0; i < _validatorSignature.length; i++){
            require(validators.contains(_validatorSignature[i]), "UserLevel: Signature invalid");
        }

        UserInfo storage userInfo = user[msg.sender];
        uint _oldExp = userInfo.exp;
        uint _oldLevel = userInfo.level;
        userInfo.exp = _oldExp + _exp;
        userInfo.level = _calculatorLevel(userInfo.exp, userInfo.level, baseLevel);

        if(_oldLevel < userInfo.level){
            if(address(avatarUserLevel) != address(0)){
                for(uint i = 1; i <= (userInfo.level - _oldLevel); i++){
                    avatarUserLevel.createAvatar(_oldLevel + i, msg.sender);
                }
            }
            _updateBonusStaking(_lStaking, msg.sender);
            _updateBonusFarming(_pIds, msg.sender);
        }

        emit UpdateUserExp(msg.sender, _oldExp, userInfo.exp, _oldLevel, userInfo.level, _validatorSignature);
    }

    function listValidator() external view override returns(address[] memory _list) {
        _list = validators.values();
    }

    function estimateExpNeed(uint _level) external view override returns(uint _exp){
        _exp = _calculatorExpNeed(_level, baseLevel);
    }

    function estimateLevel(uint _epx) external view override returns(uint _level){
        _level = _calculatorLevel(_epx, 0, baseLevel);
    }

    // ================= ADMIN FUNCTIONS ================= //
    function setUserExp(address _user, uint _exp, address[] memory _lStaking, uint[] memory _pIds) public onlyOwner{
        UserInfo storage userInfo = user[_user];
        uint _oldExp = userInfo.exp;
        uint _oldLevel = userInfo.level;
        userInfo.exp = _exp;
        userInfo.level = _calculatorLevel(_exp, 0, baseLevel);

        _updateBonusStaking(_lStaking, _user);
        _updateBonusFarming(_pIds, _user);

        emit SetUserExp(_user,  _oldExp, userInfo.exp, _oldLevel, userInfo.level);
    }

    function configBaseLevel(uint _baseLevel) external onlyOwner override{
        uint _old = baseLevel;
        baseLevel = _baseLevel;
        emit ConfigBaseLevel(_old, _baseLevel);
    }

    function configBonus(address _contractAddress, uint[] memory _bonus, uint[] memory _level) external onlyOwner override{
        require(_level.length == _bonus.length, "UserLevel: length not equal");

        BonusInfo storage _info = boostLevel[_contractAddress];

        if(_info.level.length > 0){
            delete _info.level;
            delete _info.bonus;
        }

        for(uint i = 0; i < _level.length; i++) {
            if(i > 0) {
                require(_level[i] > _level[i - 1], "UserLevel: level incorrect");
            }
            _info.level.push(_level[i]);
            _info.bonus.push(_bonus[i]);
        }

        emit ConfigBonus(_contractAddress, _bonus, _level);
    }

    function addValidator(address[] memory _validator) external override onlyOwner {
        for(uint i = 0; i < _validator.length; i++){
            if(!validators.contains(_validator[i])){
                validators.add(_validator[i]);
            }
        }

        emit AddValidator(_validator);
    }

    function removeValidator(address[] memory _validator) external override onlyOwner{
        for(uint i = 0; i < _validator.length; i++){
            if(validators.contains(_validator[i])){
                validators.remove(_validator[i]);
            }
        }

        emit RemoveValidator(_validator);
    }

    function changeAvatarAddress(address _avatar) external override onlyOwner{
        avatarUserLevel = IAvatar(_avatar);
        emit AvatarAddressChanged(_avatar);
    }

    function changeFarmingAddress(address _farming) external override onlyOwner{
        farming = IFarming(_farming);
        emit FarmingAddressChanged(_farming);
    }

    // ================= INTERNAL FUNCTIONS ================= //
    function _getValidatorSignature(bytes32 _hash, bytes[] memory _signature) internal view returns (address[] memory) {
        uint length = _signature.length;
        address[] memory signer = new address[](length);
        for(uint i = 0; i < length; i++){
            signer[i] = ECDSA.recover(_hash, _signature[i]);
        }
        return signer;
    }

    function _prefixed(bytes32 _hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }

    function _calculatorLevel(uint _exp, uint _lastLevel, uint _baseLevel) internal pure returns(uint _level){
        _level = _lastLevel;
        while(_exp >= _calculatorExpNeed(_level + 1, _baseLevel)){
            _level++;
        }
    }

    function _calculatorExpNeed(uint _level, uint _baseLevel) internal pure returns(uint _exp){
        _exp = (25 ** _level) * _baseLevel / (10 ** (_level + 1));
    }

    function _useNonce(address _owner) internal virtual returns (uint256 _current) {
        Counters.Counter storage nonce = nonce[_owner];
        _current = nonce.current();
        nonce.increment();
    }

    function _updateBonusFarming(uint[] memory _pIds, address _user) internal{
        if(address(farming) != address(0)){
            for(uint i = 0; i < _pIds.length; i++){
                farming.update(_pIds[i], _user);
            }
        }
    }

    function _updateBonusStaking(address[] memory _listStaking, address _user) internal{
        for(uint i = 0; i < _listStaking.length; i++){
            if(_listStaking[i].isContract()){
                IStaking(_listStaking[i]).update(_user);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

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

//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.16;

// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

interface IUserLevel {
    struct BonusInfo {
        uint[] level;
        uint[] bonus;
    }

    struct UserInfo {
        uint level;
        uint exp;
    }

    function getUserLevel(address _user) external view returns(uint);
    function getUserExp(address _user) external view returns(uint);
    function getUserInfo(address _user) external view returns(UserInfo memory);
    function getNonce(address _user) external view returns (uint256);
    function getBonus(address _user, address _contract) external view returns(uint, uint);
    function updateUserExp(uint _exp, uint _expiredTime, address[] memory lStaking, uint[] memory pIds, bytes[] memory signature) external;
    function listValidator() external view returns(address[] memory);
    function estimateExpNeed(uint _level) external view returns(uint);
    function estimateLevel(uint _exp) external view returns(uint);
    function configBaseLevel(uint _baseLevel) external;
    function configBonus(address _contractAddress, uint[] memory _bonus, uint[] memory _level) external;
    function addValidator(address[] memory _validator) external;
    function removeValidator(address[] memory _validator) external;
    function changeAvatarAddress(address _nftRouter) external;
    function changeFarmingAddress(address _farming) external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IAvatar {
    function create(address _receiver, uint256 _lv, uint _rand) external returns(uint256 _tokenId);
    function createAvatar(uint256 _lv, address _receiver) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

interface IStaking {
    function update(address owner) external;
    function getTotalPower() external view returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

interface IFarming {
    function update(uint256 pid, address owner) external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "../libraries/NFTLib.sol";
import "../interfaces/IPandoBox.sol";
import "../interfaces/IDroidBot.sol";
import "../interfaces/IPandoPot.sol";
import "../interfaces/IDataStorage.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/ISwapRouter02.sol";
import "../interfaces/IUserLevel.sol";
import "../interfaces/IAvatar.sol";

contract NFTRouterV2 is Ownable, Pausable {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using ECDSA for bytes;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    enum RequestStatus {AVAILABLE, EXECUTED}
    enum RequestType {BUY, CREATE, UPGRADE, AVATAR}
    struct Request {
        uint256 id;
        uint256 createdAt;
        uint256 seed;
        RequestType rType;
        RequestStatus status;
        uint256[] data;
    }

    mapping(uint256 => uint256) private pandoBoxCreated;
    mapping(address => EnumerableSet.UintSet) private userRequests;
    mapping(uint256 => Request) public requests;
    mapping(address => mapping(uint => bool)) public lockNFT;
    EnumerableSet.AddressSet validators;

    uint256 public SAMPLE;
    uint256 constant ONE_HUNDRED_PERCENT = 10000;
    uint256 constant PRECISION = 1e20;
    IDroidBot public droidBot;
    IPandoBox public pandoBox;
    IPandoPot public pandoPot;
    IDataStorage public dataStorage;
    IERC20 public PAN;
    IERC20 public PSR;
    IOracle public PANOracle;
    IOracle public PSROracle;
    ISwapRouter02 public swapRouter;
    IUserLevel public userLevel;
    IAvatar public avatar;

    address[] public PANToPSR;
    uint256 public startTime;
    uint256 public pandoBoxPerDay;
    uint256 public createPandoBoxFee;
    uint256 public upgradeBaseFee;
    uint256 public nRequest = 9000;
    uint256 public PSRRatio = 2000;
    uint256 public PANtoPSRRatio = 2000;
    uint256 public slippage = 8000;
    uint256 public blockConfirmations = 3;

    modifier onlyUserLevel() {
        require(msg.sender == address(userLevel), "NFTRouter: only user level");
        _;
    }

    modifier isLock(address _nftContract, uint256 _nftId) {
        require(!lockNFT[_nftContract][_nftId], "NFTRouter: nft id is locked");
        lockNFT[_nftContract][_nftId] = true;
        _;
    }

    modifier onlyEOA() {
        // Try to make flash-loan exploit harder to do by only allowing externally owned addresses.
        require(msg.sender == tx.origin, "NFTRouter: must use EOA");
        _;
    }
    /*----------------------------INITIALIZE----------------------------*/

    constructor (
        address _pandoBox,
        address _droidBot,
        address _PAN,
        address _PSR,
        address _pandoPot,
        address _dataStorage,
        address _PANOracle,
        address _PSROracle,
        address _swapRouter,
        uint256 _startTime
    ) {
        pandoBox = IPandoBox(_pandoBox);
        droidBot = IDroidBot(_droidBot);
        PAN = IERC20(_PAN);
        PSR = IERC20(_PSR);
        pandoPot = IPandoPot(_pandoPot);
        dataStorage = IDataStorage(_dataStorage);
        startTime = _startTime;
        PANOracle = IOracle(_PANOracle);
        PSROracle = IOracle(_PSROracle);
        swapRouter = ISwapRouter02(_swapRouter);
        SAMPLE = dataStorage.getSampleSpace();
        IERC20(PAN).safeApprove(address(swapRouter), type(uint256).max);
    }

    /*----------------------------INTERNAL FUNCTIONS----------------------------*/

    function _getPandoBoxLv(uint256 _rand) internal view returns (uint256) {
        uint256[] memory _creatingProbability = dataStorage.getPandoBoxCreatingProbability();
        uint256 _cur = 0;
        for (uint256 i = 0; i < _creatingProbability.length; i++) {
            _cur += _creatingProbability[i];
            if (_cur >= _rand) {
                return i;
            }
        }
        return 0;
    }

    function _getNewBotLv(uint256 _boxLv, uint256 _rand, uint256 _salt) internal view returns (uint256, uint256) {
        uint256[] memory _creatingProbability = dataStorage.getDroidBotCreatingProbability(_boxLv);
        uint256 _cur = 0;
        for (uint256 i = 0; i < _creatingProbability.length; i++) {
            _cur += _creatingProbability[i];
            if (_cur >= _rand) {
                uint256 _power = dataStorage.getDroidBotPower(i, _salt);
                return (i, _power);
            }
        }
        return (0, 0);
    }

    function _getUpgradeBotLv(uint256 _mainPower, uint256 _materialPower, uint256 _rand, uint256 _mainLevel) internal view returns (uint256, uint256){
        uint256 _seed = uint256(keccak256(abi.encodePacked(_rand, blockhash(block.number - 1))));
        (uint256 _lv, uint256 _power) = dataStorage.getNewPowerLevel(_seed % SAMPLE, _mainPower, _materialPower, _mainLevel);
        return (_lv, _power);
    }

    function _getBonus(uint256 _value) internal view returns (uint256) {
        if (address(userLevel) != address(0)) {
            (uint256 _n, uint256 _d) = userLevel.getBonus(msg.sender, address(this));
            return _value * _n / _d;
        }
        return 0;
    }

    function _computerSeed(uint _salt) internal view returns (uint256) {
        uint256 _seed =
        uint256(
            keccak256(
                abi.encodePacked(
                    (block.timestamp),
                    block.gaslimit,
                    blockhash(block.number - 1),
                    block.coinbase,
                    tx.origin,
                    _salt
                )
            )
        );
        return _seed;
    }

    function _getNumberOfTicket(RequestType _type, uint256[] memory _data) internal view returns (uint256){
        if (_type == RequestType.CREATE) {
            return dataStorage.getNumberOfTicket(_data[0]);
        } else {
            if (_type == RequestType.UPGRADE) {
                return dataStorage.getNumberOfTicket(_data[4]);
            }
        }
        return 0;
    }

    function _createRequest(RequestType _type, uint256[] memory _data, address _user, uint256 _seed) internal {
        nRequest++;
        uint256 _requestId = nRequest;
        requests[_requestId] = Request({
            id : _requestId,
            createdAt : block.number,
            seed : _seed % PRECISION,
            data : _data,
            rType : _type,
            status : RequestStatus.AVAILABLE
        });
        EnumerableSet.UintSet storage _userRequest = userRequests[_user];
        _userRequest.add(_requestId);
        emit RequestCreated(_user, _type, _requestId, block.number, _data);
    }

    function _executeRequest(uint256 _id, bytes32 _blockHash, address _receiver, uint256 _serial) internal {
        Request storage _request = requests[_id];
        require(_request.status == RequestStatus.AVAILABLE, 'NFTRouter: request unavailable');
        require(block.number > _request.createdAt + blockConfirmations, 'NFTRouter: not enough confirmations');

        _request.status = RequestStatus.EXECUTED;
        uint256 _seed = uint256(keccak256(abi.encodePacked(_blockHash, _serial))) / PRECISION * _request.seed;
        uint256 _rand = _seed % SAMPLE;
        uint256 _salt = _seed / SAMPLE % SAMPLE;

        uint256 _r3 = _seed / SAMPLE / SAMPLE % SAMPLE;
        if (_r3 == 0) {
            _r3 = _rand;
        }
        uint256 _r4 = _seed / SAMPLE / SAMPLE / SAMPLE % SAMPLE;
        if (_r4 == 0) {
            _r4 = _salt;
        }

        if (_request.rType == RequestType.BUY) {
            uint256 _lv = _getPandoBoxLv(_rand);
            emit BoxCreated(_receiver, _lv, _request.data[0], pandoBox.create(_receiver, _lv));
        } else {
            if (_request.rType == RequestType.CREATE) {
                (uint256 _lv, uint256 _power) = _getNewBotLv(_request.data[0], _rand, _salt);
                emit BotCreated(_receiver, _request.data[1], droidBot.create(_receiver, _lv, _power));
            } else {
                if (_request.rType == RequestType.UPGRADE) {
                    (uint256 _lv, uint256 _power) = _getUpgradeBotLv(_request.data[0], _request.data[1], _rand, _request.data[5]);
                    droidBot.upgrade(_request.data[2], _lv, _power);
                    lockNFT[address(droidBot)][_request.data[2]] = false;
                    emit BotUpgraded(_receiver, _request.data[2], _request.data[3]);
                } else {
                    if (_request.rType == RequestType.AVATAR) {
                        if (avatar.create(msg.sender, _request.data[0], _rand) == 0) {
                            revert("NFTRouter: duplicate avatar id");
                        }
                        emit RequestExecuted(_id, _receiver);
                        return;
                    }
                }
            }
        }

        uint256 _nTicket = _getNumberOfTicket(_request.rType, _request.data);
        if (block.number - _request.createdAt - blockConfirmations <= 256) {
            if (_request.rType == RequestType.CREATE && address(pandoPot) != address(0)) {
                pandoPot.enter(_receiver, _r3, _nTicket);
            } else {
                if (_request.rType == RequestType.UPGRADE && address(pandoPot) != address(0)) {
                    pandoPot.enter(_receiver, _r4, _nTicket);
                }
            }
        }
        emit RequestExecuted(_id, _receiver);
    }

    function _processRequest(uint256 _id, uint256 _blockNum, bytes32 _blockHash, bytes memory _signature, uint256 _serial, address _user) internal {
        // latest
        EnumerableSet.UintSet storage _userRequest = userRequests[_user];
        require(_userRequest.length() > 0, 'NFTRouter: empty request');
        bytes32 _hash;
        if (_id == 0) {
            _id = _userRequest.at(_userRequest.length() - 1);
            require(requests[_id].createdAt + 256 + blockConfirmations > block.number, 'NFTRouter: >256 blocks');
            _hash = blockhash(requests[_id].createdAt + blockConfirmations);
        } else {
            require(_userRequest.contains(_id), 'NFTRouter: !exist request');
            if (requests[_id].createdAt + 256 + blockConfirmations <= block.number) {
                _hash = keccak256(abi.encodePacked(address(this), _blockNum, _blockHash)).toEthSignedMessageHash();
                require(validators.contains(_hash.recover(_signature)), 'NFTRouter: !validator');
                require(requests[_id].createdAt + blockConfirmations == _blockNum, 'NFTRouter: invalid blockNum');
            } else {
                _hash = blockhash(requests[_id].createdAt + blockConfirmations);
            }
        }
        _userRequest.remove(_id);
        require(uint256(_hash) != 0, "NFTRouter: hash is zero");
        _executeRequest(_id, _hash, msg.sender, _serial);
    }

    function _createDroidBot(uint256 _pandoBoxId, uint256 _seed)
    internal
    isLock(address(pandoBox), _pandoBoxId)
    {
        require(pandoBox.ownerOf(_pandoBoxId) == msg.sender, 'NFTRouter : not owner of box');
        pandoBox.burn(_pandoBoxId);
        uint256[] memory _data = new uint[](2);
        _data[0] = pandoBox.info(_pandoBoxId).level;
        _data[1] = _pandoBoxId;
        _createRequest(RequestType.CREATE, _data, msg.sender, _seed);
    }

    function _upgradeDroidBot(uint256 _droidBot0Id, uint256 _droidBot1Id, uint256 _seed)
    internal
    isLock(address(droidBot), _droidBot0Id)
    isLock(address(droidBot), _droidBot1Id)
    returns(uint256 _upgradeFee)
    {
        require(droidBot.ownerOf(_droidBot0Id) == msg.sender && droidBot.ownerOf(_droidBot1Id) == msg.sender, 'NFTRouter : not owner of bot');
        uint256[] memory _data = new uint[](6);
        uint256 _id0 = _droidBot0Id;
        uint256 _id1 = _droidBot1Id;
        if (droidBot.power(_droidBot0Id) < droidBot.power(_droidBot1Id)) {
            _id0 = _droidBot1Id;
            _id1 = _droidBot0Id;
        }
        NFTLib.Info memory _info0 = droidBot.info(_id0);
        NFTLib.Info memory _info1 = droidBot.info(_id1);

        //avoid call stack to deep
        _upgradeFee = upgradeBaseFee * (15 ** _info0.level) / (10 ** _info0.level);
        if (_upgradeFee > 0) {
            _upgradeFee -= _getBonus(_upgradeFee);
        }

        droidBot.burn(_id1);
        _data[0] = _info0.power;
        _data[1] = _info1.power;
        _data[2] = _id0;
        _data[3] = _id1;
        _data[4] = _info1.level;
        _data[5] = _info0.level;
        _createRequest(RequestType.UPGRADE, _data, msg.sender, _seed);
    }

    function _generateSeeds(uint256 _quantity) internal view returns (uint256[] memory){
        uint256[] memory _seeds = new uint256[](_quantity);
        for (uint256 i = 0; i < _quantity; i++) {
            _seeds[i] = _computerSeed(i);
        }
        return _seeds;
    }

    function _generateRands(bytes32 _blockHash, uint256 _quantity) internal view returns (uint256[] memory) {
        uint256[] memory _rands = new uint256[](_quantity);
        uint256 _temp = uint(_blockHash);
        for (uint256 i = 0; i < _quantity; i++) {
            _rands[i] = _computerSeed(_temp >> (i * 10) & 0xFF);
        }
        return _rands;
    }

    /*----------------------------EXTERNAL FUNCTIONS----------------------------*/

    function createPandoBoxBundle(uint256 _option, uint256 _quantity) external whenNotPaused {
        require(block.timestamp >= startTime, 'NFTRouter: not started');
        require(_quantity <= 10 && _quantity > 0, "NFTRouter: quantity invalid");
        uint256 _ndays = (block.timestamp - startTime) / 1 days;

        require(pandoBoxCreated[_ndays] + _quantity <= pandoBoxPerDay, 'NFTRouter: !enough box');
        uint256 _createPandoBoxFee = (createPandoBoxFee - _getBonus(createPandoBoxFee)) * _quantity;

        pandoBoxCreated[_ndays] += _quantity;
        if (_createPandoBoxFee > 0) {
            uint _pan = 0;
            uint _psr = 0;
            if (_option == 0) {// only PAN
                PAN.safeTransferFrom(msg.sender, address(this), _createPandoBoxFee);
                uint256 _amountSwap = _createPandoBoxFee *  PANtoPSRRatio / ONE_HUNDRED_PERCENT;
                if(_amountSwap > 0) {
                    uint256[] memory _amounts = swapRouter.getAmountsOut(_amountSwap, PANToPSR);
                    uint256 _minAmount = _amounts[_amounts.length - 1] * slippage / ONE_HUNDRED_PERCENT;
                    swapRouter.swapExactTokensForTokens(_amountSwap, _minAmount, PANToPSR, address(this), block.timestamp + 300);
                    _psr = PSR.balanceOf(address(this));
                    ERC20Burnable(address(PSR)).burn(PSR.balanceOf(address(this)));
                }
                _pan = PAN.balanceOf(address(this));
                ERC20Burnable(address(PAN)).burn(_pan);
            } else {
                require(PSRRatio > 0, 'NFTRouter: PSR_ratio = 0');
                uint256 _price_PAN = PANOracle.consult();
                uint256 _price_PSR = PSROracle.consult();

                uint256 _psr = _createPandoBoxFee * PSRRatio / ONE_HUNDRED_PERCENT * _price_PAN / _price_PSR;
                _pan = _createPandoBoxFee * (ONE_HUNDRED_PERCENT - PSRRatio) / ONE_HUNDRED_PERCENT;
                ERC20Burnable(address(PAN)).burnFrom(msg.sender, _pan);
                ERC20Burnable(address(PSR)).burnFrom(msg.sender, _psr);
            }
            emit CraftBoxFee(_pan, _psr, _option);
        }
        // create request
        uint256[] memory _data = new uint[](1);
        _data[0] = _option;
        uint256[] memory _seeds = _generateSeeds(_quantity);
        for (uint256 i = 0; i < _quantity; i++) {
            _createRequest(RequestType.BUY, _data, msg.sender, _seeds[i]);
        }
    }


    function createDroidBotBundle(uint256[] memory _pandoBoxIds) external whenNotPaused {
        uint256 _length = _pandoBoxIds.length;
        require(_length > 0 && _length <= 10, "NFTRouter: _length > 0");
        uint256[] memory _seeds = _generateSeeds(_length);
        for (uint256 i = 0; i < _length; i++) {
            _createDroidBot(_pandoBoxIds[i], _seeds[i]);
        }
    }

    function upgradeDroidBotBundle(uint256[] memory _droidBot0Ids, uint256[] memory _droidBot1Ids) external whenNotPaused{
        require(_droidBot0Ids.length == _droidBot1Ids.length && _droidBot1Ids.length <= 10 && _droidBot1Ids.length > 0, "NFTRouter: length invalid");
        uint256 _length = _droidBot0Ids.length;
        uint256[] memory _seeds = _generateSeeds(_length);
        uint256 _totalFee = 0;
        for (uint i = 0; i < _length; i++) {
            _totalFee += _upgradeDroidBot(_droidBot0Ids[i], _droidBot1Ids[i], _seeds[i]);
        }
        ERC20Burnable(address(PSR)).burnFrom(msg.sender, _totalFee);
    }

    function createAvatar(uint256 _lv, address _user) external onlyUserLevel onlyEOA  whenNotPaused{
        uint256[] memory _data = new uint[](1);
        _data[0] = _lv;
        _createRequest(RequestType.AVATAR, _data, _user, _computerSeed(_lv));
    }

    function pandoBoxRemain() external view returns (uint256) {
        uint256 _ndays = (block.timestamp - startTime) / 1 days;
        return pandoBoxPerDay - pandoBoxCreated[_ndays];
    }

    function getValidators() external view returns (address[] memory) {
        return validators.values();
    }

    function pendingRequest(address _user) external view returns (uint256[] memory) {
        return userRequests[_user].values();
    }

    function getRequest(uint256 _id) external view returns (Request memory) {
        return requests[_id];
    }


    function processRequestBundle(uint256[] memory _ids, uint256[] memory _blockNums, bytes32[] memory _blockHash, bytes[] memory _signatures) external whenNotPaused {
        require(
            _ids.length == _blockNums.length && _ids.length == _blockHash.length &&
            _ids.length == _signatures.length && _ids.length > 0,
            "NFTRouter: invalid length"
        );
        uint256 _length = _ids.length;
        for (uint256 i = 0; i < _length; i ++) {
            _processRequest(_ids[i], _blockNums[i], _blockHash[i], _signatures[i], i, msg.sender);
        }
    }

    function processRequestForUser(uint256[] memory _ids, uint256[] memory _blockNums, bytes32[] memory _blockHash, bytes[] memory _signatures, address _user) external whenNotPaused {
        require(
            _ids.length == _blockNums.length && _ids.length == _blockHash.length &&
            _ids.length == _signatures.length && _ids.length > 0,
            "NFTRouter: invalid length"
        );
        uint256 _length = _ids.length;
        for (uint256 i = 0; i < _length; i ++) {
            _processRequest(_ids[i], _blockNums[i], _blockHash[i], _signatures[i], i, _user);
        }
    }

    /*----------------------------RESTRICT FUNCTIONS----------------------------*/
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setPandoBoxPerDay(uint256 _value) external onlyOwner {
        uint256 oldPandoBoxPerDay = pandoBoxPerDay;
        pandoBoxPerDay = _value;
        emit PandoBoxPerDayChanged(oldPandoBoxPerDay, _value);
    }

    function setCreatePandoBoxFee(uint256 _newFee) external onlyOwner {
        uint256 oldCreatePandoBoxFee = createPandoBoxFee;
        createPandoBoxFee = _newFee;
        emit CreateFeeChanged(oldCreatePandoBoxFee, _newFee);
    }

    function setUpgradeBaseFee(uint256 _newFee) external onlyOwner {
        uint256 oldUpgradeBaseFee = upgradeBaseFee;
        upgradeBaseFee = _newFee;
        emit UpgradeFeeChanged(oldUpgradeBaseFee, _newFee);
    }

    function setPandoPotAddress(address _addr) external onlyOwner {
        address oldPandoPot = address(pandoPot);
        pandoPot = IPandoPot(_addr);
        emit PandoPotChanged(oldPandoPot, _addr);
    }

    function setDataStorageAddress(address _addr) external onlyOwner {
        address oldDataStorage = address(dataStorage);
        dataStorage = IDataStorage(_addr);
        emit DataStorageChanged(oldDataStorage, _addr);
    }

    function setPANOracle(address _addr) external onlyOwner {
        address oldPANOracle = address(PANOracle);
        PANOracle = IOracle(_addr);
        emit PANOracleChanged(oldPANOracle, _addr);
    }

    function setPSROracle(address _addr) external onlyOwner {
        address oldPSROracle = address(PSROracle);
        PSROracle = IOracle(_addr);
        emit PSROracleChanged(oldPSROracle, _addr);
    }

    function setPath(address[] memory _path) external onlyOwner {
        address[] memory oldPath = PANToPSR;
        PANToPSR = _path;
        emit PANtoPSRChanged(oldPath, _path);
    }

    function setPSRRatio(uint256 _ratio) external onlyOwner {
        uint256 oldPSRRatio = PSRRatio;
        PSRRatio = _ratio;
        emit PSRRatioChanged(oldPSRRatio, _ratio);
    }

    function setPANtoPSRRatio(uint256 _ratio) external onlyOwner {
        uint256 oldPANtoPSRRatio = PANtoPSRRatio;
        PANtoPSRRatio = _ratio;
        emit PANtoPSRRatioChanged(oldPANtoPSRRatio, _ratio);
    }

    function setNftAddress(address _droidBot, address _pandoBox) external onlyOwner {
        address oldDroidBot = address(droidBot);
        address oldPandoBox = address(pandoBox);
        droidBot = IDroidBot(_droidBot);
        pandoBox = IPandoBox(_pandoBox);
        emit DroidBotChanged(oldDroidBot, _droidBot);
        emit PandoBoxChanged(oldPandoBox, _pandoBox);
    }

    function setTokenAddress(address _PSR, address _PAN) external onlyOwner {
        address oldPSR = address(PSR);
        address oldPAN = address(PAN);
        PSR = IERC20(_PSR);
        PAN = IERC20(_PAN);
        emit PSRChanged(oldPSR, _PSR);
        emit PANChanged(oldPAN, _PAN);
    }

    function setSwapRouter(address _swapRouter) external onlyOwner {
        address oldSwapRouter = address(swapRouter);
        swapRouter = ISwapRouter02(_swapRouter);
        emit SwapRouterChanged(oldSwapRouter, _swapRouter);
    }

    function setSlippage(uint256 _value) external onlyOwner {
        require(_value <= ONE_HUNDRED_PERCENT, 'NFT Router: > one_hundred_percent');
        uint256 oldSlippage = slippage;
        slippage = _value;
        emit SlippageChanged(oldSlippage, _value);
    }

    function setUserLevelAddress(address _userLevel) external onlyOwner {
        userLevel = IUserLevel(_userLevel);
        emit UserLevelChanged(_userLevel);
    }

    function addValidator(address _validator) public onlyOwner {
        validators.add(_validator);
        emit ValidatorAdded(_validator);
    }

    function removeValidator(address _validator) public onlyOwner {
        validators.remove(_validator);
        emit ValidatorRemoved(_validator);
    }

    function setAvatarAddress(address _avatar) external onlyOwner {
        avatar = IAvatar(_avatar);
        emit AvatarChanged(_avatar);
    }

    /*----------------------------EVENTS----------------------------*/

    event BoxCreated(address indexed receiver, uint256 level, uint256 option, uint256 indexed newBoxId);
    event BotCreated(address indexed receiver, uint256 indexed boxId, uint256 indexed newBotId);
    event BotUpgraded(address indexed user, uint256 indexed bot0Id, uint256 indexed bot1Id);
    event PandoBoxPerDayChanged(uint256 oldPandoBoxPerDay, uint256 newPandoBoxPerDay);
    event CreateFeeChanged(uint256 oldFee, uint256 newFee);
    event UpgradeFeeChanged(uint256 oldFee, uint256 newFee);
    event PandoPotChanged(address indexed oldPandoPot, address indexed newPandoPot);
    event DataStorageChanged(address indexed oldDataStorate, address indexed newDataStorate);
    event PANOracleChanged(address indexed oldPANOracle, address indexed newPANOracle);
    event PSROracleChanged(address indexed oldPSROracle, address indexed newPSROracle);
    event PANtoPSRChanged(address[] oldPath, address[] newPath);
    event PSRRatioChanged(uint256 oldRatio, uint256 newRatio);
    event PandoBoxChanged(address indexed oldPandoBox, address indexed newPandoBox);
    event DroidBotChanged(address indexed oldDroidBot, address indexed newDroidBot);
    event PSRChanged(address indexed oldPSR, address indexed newPSR);
    event PANChanged(address indexed oldPAN, address indexed newPAN);
    event SwapRouterChanged(address indexed oldSwapRouter, address indexed newSwapRouter);
    event SlippageChanged(uint256 oldSlippage, uint256 newSlippage);
    event UserLevelChanged(address indexed userLevel);
    event RequestCreated(address owner, RequestType requestType, uint256 id, uint256 createdAt, uint256[] data);
    event RequestExecuted(uint256 id, address owner);
    event ValidatorAdded(address validator);
    event ValidatorRemoved(address validator);
    event AvatarChanged(address _avatar);
    event PANtoPSRRatioChanged(uint256 oldRatio, uint256 newRatio);
    event CraftBoxFee(uint _pan, uint _psr, uint _option);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;
import "../interfaces/IDroidBot.sol";

library NFTLib {
    struct Info {
        uint256 level;
        uint256 power;
    }

    function max(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a < b) {
            return b;
        }
        return a;
    }

    function min(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a < b) {
            return a;
        }
        return b;
    }

    function optimizeEachLevel(NFTLib.Info[] memory info, uint256 level, uint256 m,  uint256 n) internal pure returns (uint256){
        // calculate m maximum values after remove n values
        uint256 l = 0;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].level == level) {
                l++;
            }
        }
        uint256[] memory tmp = new uint256[](l);
        require(l >= n + m, 'Lib: not enough droidBot');
        uint256 j = 0;
        for (uint256 i = 0; i < info.length; i++) {
            if (info[i].level == level) {
                tmp[j] = info[i].power;
                j++;
            }
        }
        for (uint256 i = 0; i < l; i++) {
            for (j = i + 1; j < l; j++) {
                if (tmp[i] < tmp[j]) {
                    uint256 a = tmp[i];
                    tmp[i] = tmp[j];
                    tmp[j] = a;
                }
            }
        }

        uint256 res = 0;
        for (uint256 i = n; i < n + m; i++) {
            res += tmp[i];
        }
        return res;
    }

    function getPower(uint256[] memory tokenIds, IDroidBot droidBot) external view returns (uint256) {
        NFTLib.Info[] memory info = new NFTLib.Info[](tokenIds.length);
        uint256[9] memory count;
        uint256[9] memory old_count;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            info[i] = droidBot.info(tokenIds[i]);
            count[info[i].level]++;
        }
        uint256 res = 0;
        uint256 c9 = count[0];
        for (uint256 i = 1; i < 9; i++) {
            c9 = min(c9, count[i]);
        }
        if (c9 > 0) {
            uint256 tmp = 0;
            for (uint256 i = 0; i < 9; i++) {
                tmp += optimizeEachLevel(info, i, c9, 0);
            }
            if (c9 >= 3) {
                res += tmp * 5; // 5x
            } else {
                res += tmp * 2; // 2x
            }
        }

        for (uint256 i = 0; i < 9; i++) {
            old_count[i] = count[i];
            count[i] -= c9;
        }

        for (uint256 i = 8; i >= 5; i--) {
            uint256 fi = count[i];
            for (uint256 j = i; j >= i - 5; j--) {
                fi = min(fi, count[j]);
                if (j == 0) {
                    break;
                }
            }
            if (fi > 0) {
                uint tmp = 0;
                for (uint256 j = i; j >= i - 5; j--) {
                    tmp += optimizeEachLevel(info, j, fi, old_count[j] - count[j]);
                    count[j] -= fi;
                    if (j == 0) {
                        break;
                    }
                }
                res += tmp * 14 / 10; // 1.4x
            }
        }

        for (uint256 i = 8; i >= 2; i--) {
            uint256 fi = count[i];
            for (uint256 j = i; j >= i - 2; j--) {
                fi = min(fi, count[j]);
                if (j == 0) {
                    break;
                }
            }
            if (fi > 0) {
                uint tmp = 0;
                for (uint256 j = i; j >= i - 2; j--) {
                    tmp += optimizeEachLevel(info, j, fi, old_count[j] - count[j]);
                    count[j] -= fi;
                    if (j == 0) {
                        break;
                    }
                }
                res += tmp * 115 / 100; //1.15 x
            }
        }

        for (uint256 i = 0; i < 9; i++) {
            if (count[i] > 0) {
                res += optimizeEachLevel(info, i, count[i], old_count[i] - count[i]); // normal
            }
        }
        return res;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "../libraries/NFTLib.sol";

interface IPandoBox is IERC721 {
    function create(address receiver, uint256 level) external returns(uint256);
    function burn(uint256 tokenId) external;
    function info(uint256 id) external view returns(NFTLib.Info memory);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "../libraries/NFTLib.sol";

interface IDroidBot is IERC721{
    function create(address, uint256, uint256) external returns(uint256);
    function upgrade(uint256, uint256, uint256) external;
    function burn(uint256) external;
    function info(uint256) external view returns(NFTLib.Info memory);
    function power(uint256) external view returns(uint256);
    function level(uint256) external view returns(uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IPandoPot {
    enum PRIZE_TYPE {LEADERBOARD, MEGA, MINOR, MINI}
    struct TypePrize {
        PRIZE_TYPE types;
        uint256 sampleSpace;
        uint256 winners;
        uint256 percentage;
        string name;
    }
    function enter(address, uint256, uint256) external;
    function enterWithoutRand(address _receiver, uint256[] memory _tickets) external;
    function updateLuckyNumber(uint256, uint256, uint256) external;
    function finishRound() external;
    function getRoundDuration() external view returns (uint256);
    function currentRoundId() external view returns (uint256);
    function updatePandoPot() external;
    function getAmountPan(uint256 _quantityTicket) external view returns(uint256);
    function typePrize(uint8 _type) external view returns (TypePrize memory);
    function isReceivedFreeTicket(address _receiver) external view returns (bool);
    function panBurnPercent() external view returns (uint256);
    function ticketPrice() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IDataStorage {
    function getSampleSpace() external pure returns(uint256);
    function getPandoBoxCreatingProbability() external view returns (uint256[] memory);
    function getDroidBotCreatingProbability(uint256) external view returns (uint256[] memory);
    function getDroidBotUpgradingProbability(uint256, uint256) external view returns(uint256[] memory);
    function getDroidBotPower(uint256, uint256) external pure returns(uint256);
    function getNumberOfTicket(uint256) view external returns(uint256);
    function getNewPowerLevel(uint256 _rand, uint256 _mainPower, uint256 _materialPower, uint256 _mainLevel) external view returns (uint256 , uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
pragma experimental ABIEncoderV2;

interface IOracle {
    function consult() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity = 0.8.4;
pragma experimental ABIEncoderV2;

import './ISwapRouter01.sol';

interface ISwapRouter02 is ISwapRouter01 {
    function tradingPool() external pure returns (address);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface ISwapRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function pairFor(address, address) external view returns(address);
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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IUserLevel.sol";

contract ConfigUserLevel is Ownable {
    IUserLevel public userLevel;

    function setUserLevelAddress(address _userLevel) external onlyOwner {
        userLevel = IUserLevel(_userLevel);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "../interfaces/IMinter.sol";
import "../interfaces/IPAN.sol";

contract TradeMining is Ownable, Pausable, Initializable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using ECDSA for bytes;


    IMinter public minter;
    IERC20  public PAN;
    uint public lastUpdateBlock;
    uint public PanPerBlock;

    EnumerableSet.AddressSet private operators;
    mapping(address => Counters.Counter) private nonces;

    //=========== Event ============//
    event Harvest(address _user, uint _amount, uint _nonce, address _to);
    event OperatorChange(address _operator, bool _action);
    event MinterChanged(address indexed oldMinter, address indexed newMinter);
    event PANPerBlockChanged(uint256 oldPANPerBlock, uint256 newPANPerBlock);
    //=========== Modifier ============//
    //constructor
    constructor(address _minter, address _pan, uint256 _PANPerBlock) {
        PAN = IERC20(_pan);
        minter = IMinter(_minter);
        PanPerBlock = _PANPerBlock;
        lastUpdateBlock = block.number;
    }

    //=========== Internal functions ============//
    function _useNonce(address _user) internal returns (uint256 current) {
        Counters.Counter storage nonce = nonces[_user];
        current = nonce.current();
        nonce.increment();
    }

    function _validateSignature(bytes memory _signature, address _user, uint _amount, uint _expire) internal returns (uint _nonce) {
        _nonce = _useNonce(_user);
        bytes32 _hash = keccak256(abi.encodePacked(_user, _amount, _nonce, _expire, address(this))).toEthSignedMessageHash();
        address _signer = _hash.recover(_signature);
        require(operators.contains(_signer), "TradeMining: !operator");
    }

    function _transferReward(address _receiver, uint256 _amount) internal {
        if (PAN.balanceOf(address(this)) <= _amount) {
            mintReward();
        }
        PAN.safeTransfer(_receiver, _amount);
    }

    //=========== External functions ============//
    function harvest(bytes memory _signature, address _user, uint _amount, uint _expire, address _to) external whenNotPaused {
        require(block.timestamp <= _expire, "TradeMining: !expire");
        require(_to != address(0), "TradeMining: !zero address");

        uint _nonce = _validateSignature(_signature, _user, _amount, _expire);
        address _receiver;
        {
            _receiver = msg.sender == _user ? _to : _user;
            _transferReward(_receiver, _amount);
        }
        emit Harvest(_user, _amount, _nonce, _receiver);
    }

    function mintReward() public {
        uint256 _amount = (block.number - lastUpdateBlock) * PanPerBlock;
        minter.transfer(address(this), _amount);
        lastUpdateBlock = block.number;
    }

    //=========== View functions ============//
    function currentNonce(address _user) public view returns (uint256) {
        return nonces[_user].current();
    }

    function getOperators() external view returns (address[] memory) {
        return operators.values();
    }

    function isOperator(address _operator) external view returns (bool) {
        return operators.contains(_operator);
    }

    //=========== Restrict functions ============//
    function init(uint256 _amount) external onlyOwner initializer {
        minter.transfer(address(this), _amount);
    }

    function recuseFund(address _token, address _receiver) external onlyOwner whenPaused {
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        if (_amount > 0) {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    function changeOperator(address _operator, bool _action) external onlyOwner {
        if(_action) {
            require(operators.add(_operator), "TradeMining: !added");
        } else {
            require(operators.remove(_operator), "TradeMining: !removed");
        }
        emit OperatorChange(_operator, _action);
    }

    function changeMinter(address _newMinter) external onlyOwner {
        address oldMinter = address(minter);
        minter = IMinter(_newMinter);
        emit MinterChanged(oldMinter, _newMinter);
    }

    function setPanPerBlock(uint256 _v) external onlyOwner {
        uint256 oldPANPerBlock = PanPerBlock;
        PanPerBlock = _v;
        emit PANPerBlockChanged(oldPANPerBlock, _v);
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

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
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
pragma experimental ABIEncoderV2;

interface IMinter {
    function transfer(address, uint256) external;
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPAN is IERC20{
    function mint(address, uint256) external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../interfaces/IPAN.sol";
import "../interfaces/IMinter.sol";


contract Referral is Ownable {
    address public operator;
    uint256 public lastUpdateBlock;
    uint256 public PANPerBlock;
    IPAN public PAN;
    IMinter public minter;

    modifier onlyOperator() {
        require(msg.sender == operator, 'Referral: caller is not operator');
        _;
    }

    constructor(address _PAN, uint256 _PANPerBlock, IMinter _minter) {
        PAN = IPAN(_PAN);
        PANPerBlock = _PANPerBlock;
        operator = msg.sender;
        lastUpdateBlock = block.number;
        minter = _minter;
    }

    function mintReward() public {
        uint256 _amount = (block.number - lastUpdateBlock) * PANPerBlock;
        minter.transfer(address(this), _amount);
        lastUpdateBlock = block.number;
    }

    function distribute(address[] memory _accounts, uint256[] memory _amounts) public onlyOperator {
        mintReward();
        uint256 length = _accounts.length;
        require(length == _amounts.length, "Distribution: array length is invalid");
        for (uint256 i = 0; i < length; i++) {
            address account = _accounts[i];
            uint256 amount = _amounts[i];
            require(account != address(0), "Distribution: address is invalid");
            require(amount > 0, "Distribution: amount is invalid");
            PAN.transfer(account, amount);
            emit Distributed(account, amount);
        }
    }

    function setPanPerBlock(uint256 _v) external onlyOwner {
        uint256 oldPANPerBlock = PANPerBlock;
        PANPerBlock = _v;
        emit PANPerBlockChanged(oldPANPerBlock, _v);
    }

    function setOperator(address _newOperator) external onlyOwner {
        address oldOperator = operator;
        operator = _newOperator;
        emit OperatorChanged(oldOperator, _newOperator);
    }

    event Distributed(address account, uint256 amount);
    event Claimed(address account, uint256 amount);
    event PANPerBlockChanged(uint256 oldPANPerBlock, uint256 newPANPerBlock);
    event OperatorChanged(address indexed oldOperator, address indexed newOperator);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IMinter.sol";
import "../interfaces/IUserLevel.sol";

contract StakingV1 is Ownable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 bonus;
        int256 rewardDebt;
    }

    IERC20 public PAN;
    IERC20 public PSR;
    IMinter public minter;
    IUserLevel public userLevel;

    // governance
    address public reserveFund;

    uint256 public accRewardPerShare;
    uint256 public lastRewardBlock;
    uint256 public startRewardBlock;
    uint256 public totalBonus;

    uint256 public rewardPerBlock;
    uint256 private constant ACC_REWARD_PRECISION = 1e12;

    mapping (address => UserInfo) public userInfo;

    /* ========== Modifiers =============== */


    constructor(IERC20 _PSR, IERC20 _PAN, IMinter _minter, uint256 _startReward, uint256 _rewardPerBlock) {
        PAN = _PAN;
        PSR = _PSR;
        lastRewardBlock = _startReward;
        startRewardBlock = _startReward;
        rewardPerBlock = _rewardPerBlock;
        minter = IMinter(_minter);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function getBonus(uint256 _value, address account) internal view returns(uint256) {
        if (address(userLevel) != address(0)) {
            (uint256 _n, uint256 _d) = userLevel.getBonus(account, address(this));
            return _value * _n / _d;
        }
        return 0;
    }

    function _update(address account) internal {
        UserInfo storage user = userInfo[account];
        uint256 _oldBonus = user.bonus;
        uint256 _newBonus = getBonus(user.amount, account);
        if (_newBonus > _oldBonus) {
            user.rewardDebt += int256((_newBonus - _oldBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            totalBonus += _newBonus - _oldBonus;
        } else {
            user.rewardDebt -= int256((_oldBonus - _newBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            totalBonus -= _oldBonus - _newBonus;
        }
        user.bonus = _newBonus;
    }

    function totalLp() internal view  returns(uint256) {
        return PSR.balanceOf(address(this)) + totalBonus;
    }
    /* ========== PUBLIC FUNCTIONS ========== */

    /// @notice View function to see pending reward on frontend.
    /// @param _user Address of user.
    /// @return pending reward for a given user.
    function pendingReward(address _user) external view returns (uint256 pending) {
        UserInfo storage user = userInfo[_user];
        uint256 supply = totalLp();
        uint256 _accRewardPerShare = accRewardPerShare;
        if (block.number > lastRewardBlock && supply != 0) {
            uint256 rewardAmount = (block.number - lastRewardBlock) * rewardPerBlock;
            _accRewardPerShare += (rewardAmount * ACC_REWARD_PRECISION) / supply;
        }
        pending = uint256(int256((user.amount + user.bonus) * _accRewardPerShare / ACC_REWARD_PRECISION) - user.rewardDebt);
    }

    /// @notice Update reward variables of the given pool.
    function updatePool() public {
        if (block.number > lastRewardBlock) {
            uint256 supply = totalLp();
            if (supply > 0 && block.number > lastRewardBlock) {
                uint256 rewardAmount = (block.number - lastRewardBlock) * rewardPerBlock;
                accRewardPerShare += rewardAmount * ACC_REWARD_PRECISION / supply;
            }
            lastRewardBlock = block.number;
            emit LogUpdatePool(lastRewardBlock, supply, accRewardPerShare);
        }
    }

    /// @notice Deposit LP tokens to MCV2 for reward allocation.
    /// @param amount LP token amount to deposit.
    /// @param to The receiver of `amount` deposit benefit.
    function deposit(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[to];

        // Effects
        user.amount += amount;
        user.rewardDebt += int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);

        PSR.safeTransferFrom(msg.sender, address(this), amount);
        _update(msg.sender);
        emit Deposit(msg.sender, amount, to);
    }

    /// @notice Withdraw LP tokens from MCV2.
    /// @param amount LP token amount to withdraw.
    /// @param to Receiver of the LP tokens.
    function withdraw(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];

        // Effects
        user.rewardDebt -= int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);
        user.amount -= amount;

        _update(msg.sender);
        PSR.safeTransfer(to, amount);

        emit Withdraw(msg.sender, amount, to);
    }

    /// @notice Harvest proceeds for transaction sender to `to`.
    /// @param to Receiver of rewards.
    function harvest(address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedReward = int256((user.amount + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedReward;

        // Interactions
        if (_pendingReward > 0) {
            minter.transfer(to, _pendingReward);
        }
        emit Harvest(msg.sender, _pendingReward);
    }

    /// @notice Withdraw LP tokens from MCV2 and harvest proceeds for transaction sender to `to`.
    /// @param amount LP token amount to withdraw.
    /// @param to Receiver of the LP tokens and rewards.
    function withdrawAndHarvest(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedReward = int256((user.amount + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedReward - int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);
        user.amount -= amount;

        // Interactions
        if (_pendingReward > 0) {
            minter.transfer(to, _pendingReward);
        }

        _update(msg.sender);
        PSR.safeTransfer(to, amount);

        emit Withdraw(msg.sender, amount, to);
        emit Harvest(msg.sender, _pendingReward);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    /// @param to Receiver of the LP tokens.
    function emergencyWithdraw(address to) public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        // Note: transfer can fail or succeed if `amount` is zero.
        PSR.safeTransfer(to, amount);
        emit EmergencyWithdraw(msg.sender, amount, to);
    }

    function update(address owner) public {
        updatePool();
        _update(owner);
    }

    function getUserInfo(address user) external view returns(UserInfo memory info) {
        info = userInfo[user];
    }
    /* ========== RESTRICTED FUNCTIONS ========== */

    /// @notice Sets the reward per second to be distributed. Can only be called by the owner.
    /// @param _rewardPerBlock The amount of reward to be distributed per second.
    function setRewardPerBlock(uint256 _rewardPerBlock) public onlyOwner {
        updatePool();
        uint256 oldRewardPerBlock = rewardPerBlock;
        rewardPerBlock = _rewardPerBlock;
        emit RewardPerBlockChanged(oldRewardPerBlock, _rewardPerBlock);
    }

    function changeMinter(address _newMinter) external onlyOwner {
        address oldMinter = address(minter);
        minter = IMinter(_newMinter);
        emit MinterChanged(oldMinter, _newMinter);
    }

    function setUserLevelAddress(address _userLevel) external onlyOwner {
        userLevel = IUserLevel(_userLevel);
        emit UserLevelChanged(_userLevel);
    }

    /* =============== EVENTS ==================== */

    event Deposit(address indexed user, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 amount);
    event LogUpdatePool(uint256 lastRewardBlock, uint256 lpSupply, uint256 accRewardPerShare);
    event RewardPerBlockChanged(uint256 oldRewardPerBlock, uint256 newRewardPerBlock);
    event FundRescued(address indexed receiver, uint256 amount);
    event MinterChanged(address indexed oldMinter, address indexed newMinter);
    event UserLevelChanged(address indexed userLevel);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../../interfaces/ISwapRouter02.sol";
import "../../../interfaces/IUniswapV2Pair.sol";
import "../../../interfaces/IMasterchefV2.sol";
import "../common/StratManager.sol";
import "../common/FeeManager.sol";


contract StrategyPandoraLP is StratManager, FeeManager {
    using SafeERC20 for IERC20;

    // Tokens used
    address constant public native = address(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
    address public output;
    address public want;
    address public lpToken0;
    address public lpToken1;

    // Third party contracts
    address public masterchefV2;
    uint256 public pid;

    // Routes
    address[] public outputToNativeRoute;
    address[] public outputToLp0Route;
    address[] public outputToLp1Route;
    bool public harvestOnDeposit;

    constructor(
        address _output,
        address _want,
        address _masterchefV2,
        uint256 _pid,
        address _vault,
        address _swapRouter,
        address _keeper,
        address _strategist,
        address _pandoraFeeRecipient
    ) StratManager(_keeper, _strategist, _swapRouter, _vault, _pandoraFeeRecipient) {
        output = _output;
        want = _want;
        lpToken0 = IUniswapV2Pair(want).token0();
        lpToken1 = IUniswapV2Pair(want).token1();
        masterchefV2 = _masterchefV2;
        pid = _pid;

        outputToNativeRoute = [output, native];
        if (lpToken0 == native) {
            outputToLp0Route = [output, native];
        } else if (lpToken0 != output) {
            outputToLp0Route = [output, lpToken0];
        }

        if (lpToken1 == native) {
            outputToLp1Route = [output, native];
        } else if (lpToken1 != output) {
            outputToLp1Route = [output, lpToken1];
        }

        harvestOnDeposit = true;
        _giveAllowances();
    }

    modifier onlyVault() {
        require(msg.sender == vault, "Strategy: !Vault");
        _;
    }

    function setHarvestOnDeposit(bool _harvestOnDeposit) external onlyManager {
        harvestOnDeposit = _harvestOnDeposit;
        if (harvestOnDeposit) {
            setWithdrawalFee(0);
        } else {
            setWithdrawalFee(10);
        }
    }

    // puts the funds to work
    function deposit() public whenNotPaused {
        uint256 wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal > 0) {
            IMasterchefV2(masterchefV2).deposit(pid, wantBal, address(this));
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 _amount) external onlyVault{
        uint256 wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal < _amount) {
            IMasterchefV2(masterchefV2).withdraw(pid, _amount - wantBal, address(this));
            wantBal = IERC20(want).balanceOf(address(this));
        }

        if (wantBal > _amount) {
            wantBal = _amount;
        }

        if (tx.origin == owner() || paused()) {
            IERC20(want).safeTransfer(msg.sender, wantBal);
        } else {
            uint256 withdrawalFeeAmount = wantBal * withdrawalFee / WITHDRAWAL_MAX;
            IERC20(want).safeTransfer(msg.sender, wantBal - withdrawalFeeAmount);
        }
        emit Withdraw(balanceOf());
    }

    function beforeDeposit() external override onlyVault {
        if (harvestOnDeposit) {
            harvest();
        }
    }

    // compounds earnings and charges performance fee
    function harvest() public whenNotPaused {
        IMasterchefV2(masterchefV2).harvest(pid, address(this));
        chargeFees();
        addLiquidity();
        deposit();

        emit StratHarvest(msg.sender);
    }

    // performance fees
    function chargeFees() internal {
        uint256 toNative = IERC20(output).balanceOf(address(this)) * 45 / 1000;
        ISwapRouter02(swapRouter).swapExactTokensForTokens(toNative, 0, outputToNativeRoute, address(this), block.timestamp);

        uint256 nativeBal = IERC20(native).balanceOf(address(this));

        uint256 callFeeAmount = nativeBal * callFee / MAX_FEE;
        IERC20(native).safeTransfer(tx.origin, callFeeAmount);

        uint256 pandoraFeeAmount = nativeBal * pandoraFee / MAX_FEE;
        IERC20(native).safeTransfer(pandoraFeeRecipient, pandoraFeeAmount);

        uint256 strategistFee = nativeBal * STRATEGIST_FEE / MAX_FEE;
        IERC20(native).safeTransfer(strategist, strategistFee);
        emit ChargedFees(callFee, pandoraFee, strategistFee);
    }

    // Adds liquidity to AMM and gets more LP tokens.
    function addLiquidity() internal {
        uint256 outputHalf = IERC20(output).balanceOf(address(this)) / 2;

        if (lpToken0 != output) {
            ISwapRouter02(swapRouter).swapExactTokensForTokens(outputHalf, 0, outputToLp0Route, address(this), block.timestamp);
        }

        if (lpToken1 != output) {
            ISwapRouter02(swapRouter).swapExactTokensForTokens(outputHalf, 0, outputToLp1Route, address(this), block.timestamp);
        }

        uint256 lp0Bal = IERC20(lpToken0).balanceOf(address(this));
        uint256 lp1Bal = IERC20(lpToken1).balanceOf(address(this));
        ISwapRouter02(swapRouter).addLiquidity(lpToken0, lpToken1, lp0Bal, lp1Bal, 1, 1, address(this), block.timestamp);
    }

    // calculate the total underlaying 'want' held by the strat.
    function balanceOf() public view returns (uint256) {
        return balanceOfWant() + balanceOfPool();
    }

    // it calculates how much 'want' this contract holds.
    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    // it calculates how much 'want' the strategy has working in the farm.
    function balanceOfPool() public view returns (uint256) {
        (uint256 _amount,) = IMasterchefV2(masterchefV2).userInfo(pid, address(this));
        return _amount;
    }


    // called as part of strat migration. Sends all the available funds back to the vault.
    function retireStrat() external {
        require(msg.sender == vault, "!vault");

        IMasterchefV2(masterchefV2).withdraw(pid, balanceOfPool(), address(this));

        uint256 wantBal = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(vault, wantBal);
    }

    function rewardsAvailable() public view returns(uint256) {
        return IMasterchefV2(masterchefV2).pendingReward(pid, address(this));
    }

    function callReward() external view returns(uint256) {
        uint256 outputBal = rewardsAvailable();
        if (outputBal > 0) {
            ISwapRouter02(swapRouter).getAmountsOut(outputBal, outputToNativeRoute);
            return outputBal * 45 / 1000 * callFee / MAX_FEE;
        }
        return 0;
    }

    // pauses deposits and withdraws all funds from third party systems.
    function panic() public onlyManager {
        pause();
        IMasterchefV2(masterchefV2).withdraw(pid, balanceOfPool(), address(this));
    }

    function pause() public onlyManager {
        _pause();

        _removeAllowances();
    }

    function unpause() external onlyManager {
        _unpause();

        _giveAllowances();

        deposit();
    }

    function _giveAllowances() internal {
        IERC20(want).safeApprove(masterchefV2, type(uint256).max);
        IERC20(output).safeApprove(swapRouter, type(uint256).max);

        IERC20(lpToken0).safeApprove(swapRouter, 0);
        IERC20(lpToken0).safeApprove(swapRouter, type(uint256).max);

        IERC20(lpToken1).safeApprove(swapRouter, 0);
        IERC20(lpToken1).safeApprove(swapRouter, type(uint256).max);
    }

    function _removeAllowances() internal {
        IERC20(want).safeApprove(masterchefV2, 0);
        IERC20(output).safeApprove(swapRouter, 0);
        IERC20(lpToken0).safeApprove(swapRouter, 0);
        IERC20(lpToken1).safeApprove(swapRouter, 0);
    }

    event StratHarvest(address indexed harvester);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);
    event ChargedFees(uint256 callFees, uint256 pandoraFees, uint256 strategistFees);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.8.4;
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IMasterchefV2 {
    function deposit(uint256 _pid, uint256 _amount, address _for) external;
    function withdraw(uint256 _pid, uint256 _amount, address _for) external;
    function harvest(uint256 _pid, address _for) external;
    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);
    function pendingReward(uint256 _pid, address _user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract StratManager is Ownable, Pausable {
    /**
     * @dev Pandora Contracts:
     * {keeper} - Address to manage a few lower risk features of the strat
     * {strategist} - Address of the strategy author/deployer where strategist fee will go.
     * {vault} - Address of the vault that controls the strategy's funds.
     * {swapRouter} - Address of exchange to execute swaps.
     */
    address public keeper;
    address public strategist;
    address public swapRouter;
    address public vault;
    address public pandoraFeeRecipient;

    /**
     * @dev Initializes the base strategy.
     * @param _keeper address to use as alternative owner.
     * @param _strategist address where strategist fees go.
     * @param _swapRouter router to use for swaps
     * @param _vault address of parent vault.
     * @param _pandoraFeeRecipient address where to send pandora's fees.
     */
    constructor(
        address _keeper,
        address _strategist,
        address _swapRouter,
        address _vault,
        address _pandoraFeeRecipient
    ) public {
        keeper = _keeper;
        strategist = _strategist;
        swapRouter = _swapRouter;
        vault = _vault;
        pandoraFeeRecipient = _pandoraFeeRecipient;
    }

    // checks that caller is either owner or keeper.
    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == keeper, "!manager");
        _;
    }

    /**
     * @dev Updates address of the strat keeper.
     * @param _keeper new keeper address.
     */
    function setKeeper(address _keeper) external onlyManager {
        keeper = _keeper;
    }

    /**
     * @dev Updates address where strategist fee earnings will go.
     * @param _strategist new strategist address.
     */
    function setStrategist(address _strategist) external {
        require(msg.sender == strategist, "!strategist");
        strategist = _strategist;
    }

    /**
     * @dev Updates router that will be used for swaps.
     * @param _swapRouter new swapRouter address.
     */
    function setSwapRouter(address _swapRouter) external onlyOwner {
        swapRouter = _swapRouter;
    }

    /**
     * @dev Updates parent vault.
     * @param _vault new vault address.
     */
    function setVault(address _vault) external onlyOwner {
        vault = _vault;
    }

    /**
     * @dev Updates pandora fee recipient.
     * @param _pandoraFeeRecipient new pandora fee recipient address.
     */
    function setPandoraFeeRecipient(address _pandoraFeeRecipient) external onlyOwner {
        pandoraFeeRecipient = _pandoraFeeRecipient;
    }

    /**
     * @dev Function to synchronize balances before new user deposit.
     * Can be overridden in the strategy.
     */
    function beforeDeposit() external virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./StratManager.sol";

abstract contract FeeManager is StratManager {
    uint constant public STRATEGIST_FEE = 112;
    uint constant public MAX_FEE = 1000;
    uint constant public MAX_CALL_FEE = 111;

    uint constant public WITHDRAWAL_FEE_CAP = 50;
    uint constant public WITHDRAWAL_MAX = 10000;

    uint public withdrawalFee = 10;

    uint public callFee = 111;
    uint public pandoraFee = MAX_FEE - STRATEGIST_FEE - callFee;

    function setCallFee(uint256 _fee) public onlyManager {
        require(_fee <= MAX_CALL_FEE, "!cap");
        
        callFee = _fee;
        pandoraFee = MAX_FEE - STRATEGIST_FEE - callFee;
    }

    function setWithdrawalFee(uint256 _fee) public onlyManager {
        require(_fee <= WITHDRAWAL_FEE_CAP, "!cap");

        withdrawalFee = _fee;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../interfaces/IPandoAssembly.sol";


contract Rewarder is Ownable, Pausable, Initializable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;
    }

    /* ==========  Constants  ========== */

    uint256 private constant ACC_REWARD_PRECISION = 1e12;
    IERC20 public rewardToken;
    IPandoAssembly public pandoAssembly;


    uint256 public accRewardPerShare;
    uint256 public lastRewardTime;
    uint256 public endRewardTime;
    uint256 public startRewardTime;
    uint256 public rewardPerSecond;


    address public reserveFund;
    /* ==========  Storage  ========== */
    mapping(address => UserInfo) internal _userInfo;

    /* ==========  Modifiers  ========== */


    modifier onlyPandoAssembly() {
        require(msg.sender == address(pandoAssembly), "Rewarder: Only PandoAssembly");
        _;
    }

    modifier onlyReserveFund() {
        require(reserveFund == msg.sender, "Rewarder: caller is not the reserveFund");
        _;
    }


    /* ========== ===================*/
    event LogOnReward(address indexed user, uint256 amount, address indexed to);
    event LogUpdatePool(uint256 lastRewardTime, uint256 lpSupply, uint256 accRewardPerShare);
    event LogInit();
    event ReserveFundChanged(address indexed oldReserveFund, address indexed newReserveFund);
    event FundRescued(address indexed receiver, uint256 amount);
    event RewardPerSecondChanged(uint256 oldRewardPerSecond, uint256 newRewardPerSecond);
    event Deposit(address _user, uint256 _change, address _to);
    event Withdraw(address _user, uint256 _change);
    event Update(address _user, uint256 _amount);
    event SetStartRewardTime(uint256 _time);

    /* ==========  Initializer  ========== */

    function initialize(
        address _pandoAssembly,
        address _reward
    ) external initializer {
        pandoAssembly = IPandoAssembly(_pandoAssembly);
        rewardToken = IERC20(_reward);
        emit LogInit();
    }


    /* ==========  Queries  ========== */
    function userInfo(address _account) external view returns (UserInfo memory) {
        return _userInfo[_account];
    }

    function getUserInfo(address _account) external view returns(uint ,int256) {
        return (_userInfo[_account].amount, _userInfo[_account].rewardDebt);
    }

    function getRewardForDuration(uint256 _from, uint256 _to) public view returns (uint256) {
        uint256 _rewardPerSecond = rewardPerSecond;
        if (_from >= _to || _from >= endRewardTime) return 0;
        if (_to <= startRewardTime) return 0;
        if (_from <= startRewardTime) {
            if (_to <= endRewardTime) return (_to - startRewardTime) * _rewardPerSecond;
            else return (endRewardTime - startRewardTime) * _rewardPerSecond;
        }
        if (_to <= endRewardTime) return (_to - _from) * _rewardPerSecond;
        else return (endRewardTime - _from) * _rewardPerSecond;
    }

    function getRewardPerSecond() public view returns (uint256) {
        return getRewardForDuration(block.timestamp, block.timestamp + 1);
    }

    function pendingReward(address _account) external view returns (uint256 _pending) {
        UserInfo storage _user = _userInfo[_account];
        uint256 _accRewardPerShare = accRewardPerShare;
        uint256 _totalPower = pandoAssembly.getTotalPower();
        if (block.timestamp > lastRewardTime && _totalPower != 0) {
            uint256 _rewardAmount = getRewardForDuration(lastRewardTime, block.timestamp);
            _accRewardPerShare += (_rewardAmount * ACC_REWARD_PRECISION) / _totalPower;
        }
        _pending = uint256(int256(_user.amount * _accRewardPerShare / ACC_REWARD_PRECISION) - _user.rewardDebt);
    }

    /* ==========  Actions  ========== */

    function _updatePool() internal {
        if (block.timestamp > lastRewardTime) {
            uint256 _totalPower = pandoAssembly.getTotalPower();
            if (_totalPower > 0) {
                uint256 rewardAmount = getRewardForDuration(lastRewardTime, block.timestamp);
                accRewardPerShare += rewardAmount * ACC_REWARD_PRECISION / _totalPower;
            }
            lastRewardTime = block.timestamp;
            emit LogUpdatePool(lastRewardTime, _totalPower, accRewardPerShare);
        }
    }

    function updatePool() public onlyPandoAssembly {
        _updatePool();
    }

    function onReward(
        address _account,
        address _to,
        uint256,
        uint256 _amount
    )
    external
    onlyPandoAssembly
    whenNotPaused
    {
        UserInfo storage _user = _userInfo[_account];
        uint256 _accumulatedRewards = _user.amount * accRewardPerShare / ACC_REWARD_PRECISION;
        uint256 _pending = uint256(int256(_accumulatedRewards) - _user.rewardDebt);
        if (_pending > 0) {
            rewardToken.safeTransfer(_to, _pending);
        }
        _user.rewardDebt = int256(_amount * accRewardPerShare / ACC_REWARD_PRECISION);

        _user.amount = _amount;
        emit LogOnReward(_account, _pending, _to);

    }

    function onDeposit(address _account, address _to, uint256 _amount) external onlyPandoAssembly whenNotPaused {
        UserInfo storage _user = _userInfo[_account];
        uint256 _change = _amount - _user.amount;
//        user.rewardDebt += int256(_change * accRewardPerShare / ACC_REWARD_PRECISION);
        _user.rewardDebt += (int256(_amount * accRewardPerShare / ACC_REWARD_PRECISION) - int256(_user.amount * accRewardPerShare / ACC_REWARD_PRECISION));
        _user.amount = _amount;
        emit Deposit(_account, _change, _to);
    }

    function onWithdraw(address _account, uint256 _amount) external onlyPandoAssembly whenNotPaused {
        UserInfo storage _user = _userInfo[_account];
        if(_user.amount < _amount) {
            return;
        }
        uint256 _change = _user.amount - _amount;
//        _user.rewardDebt -= int256(_change * accRewardPerShare / ACC_REWARD_PRECISION);
        _user.rewardDebt -= (int256(_user.amount * accRewardPerShare / ACC_REWARD_PRECISION) - int256(_amount * accRewardPerShare / ACC_REWARD_PRECISION));
        _user.amount = _amount;
        if (0 <= _user.rewardDebt && _user.rewardDebt <= int256(ACC_REWARD_PRECISION) && _user.amount == 0) {
            _user.rewardDebt = 0; // prevent Dept = 1
        }
        emit Withdraw(_account, _change);
    }

    function onUpdate(address _account, uint256 _amount) external onlyPandoAssembly whenNotPaused {
        updatePool();
        UserInfo storage _user = _userInfo[_account];
        if (_user.amount < _amount) {
            _user.rewardDebt += int256((_amount - _user.amount) * accRewardPerShare / ACC_REWARD_PRECISION);
        } else {
            _user.rewardDebt -= int256((_user.amount - _amount) * accRewardPerShare / ACC_REWARD_PRECISION);
        }
        _user.amount = _amount;
        if (0 <= _user.rewardDebt && _user.rewardDebt <= int256(ACC_REWARD_PRECISION) && _user.amount == 0) {
            _user.rewardDebt = 0; // prevent Dept = 1
        }
        emit Update(_account, _amount);
    }


    //Administration

    function allocateMoreRewards(uint256 _addedReward, uint256 _days) external onlyReserveFund {
        require(startRewardTime != 0, "Set startRewardTime first");
        _updatePool();
        uint256 _pendingSeconds = (endRewardTime > block.timestamp) ? (endRewardTime - block.timestamp) : 0;
        uint256 _newPendingReward = (rewardPerSecond * _pendingSeconds) + _addedReward;
        uint256 _newPendingSeconds = _pendingSeconds + (_days * (1 days));
        uint256 _newRewardPerSecond = _newPendingReward / _newPendingSeconds;
        setRewardPerSecond(_newRewardPerSecond);
        if (_days > 0) {
            if (endRewardTime < block.timestamp) {
                endRewardTime = block.timestamp + (_days * (1 days));
            } else {
                endRewardTime = endRewardTime + (_days * (1 days));
            }
        }
        rewardToken.safeTransferFrom(msg.sender, address(this), _addedReward);
    }

    function setReserveFund(address _reserveFund) external onlyOwner {
        address oldReserveFund = reserveFund;
        reserveFund = _reserveFund;
        emit ReserveFundChanged(oldReserveFund, _reserveFund);
    }

    function rescueFund(uint256 _amount) external onlyOwner {
        require(_amount > 0 && _amount <= rewardToken.balanceOf(address(this)), "invalid amount");
        rewardToken.safeTransfer(owner(), _amount);
        emit FundRescued(owner(), _amount);
    }

    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }


    function setStartReward(uint256 _time) external onlyOwner {
        require(startRewardTime == 0, "startRewardTime has already set");
        startRewardTime = _time;
        lastRewardTime = _time;
        emit SetStartRewardTime(_time);
    }
    // internal
    function setRewardPerSecond(uint256 _rewardPerSecond) internal {
        uint256 oldRewardPerSecond = rewardPerSecond;
        rewardPerSecond = _rewardPerSecond;
        emit RewardPerSecondChanged(oldRewardPerSecond, _rewardPerSecond);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IPandoAssembly {
    function allocateMoreRewards(uint256, uint256) external;
    function currentPower(address _user) external view returns(uint256);
    function getTotalPower() external view returns(uint256);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../interfaces/IPandoAssembly.sol";

contract PandoPool is Ownable, Pausable {
    using SafeERC20 for IERC20;

    address public pandoAssembly;
    mapping(address => bool) public operators;
    uint256 public allocationDailyPercent;
    uint256 public constant ONE_HUNDRED_PERCENT = 10000;
    uint256 public minAllocateInterval = 23 * 1 hours;
    uint256 public lastAllocatedTime;
    address public busd;
    uint256 public allocateDay;

    constructor (address _busd, address _pandoAssembly, uint256 _allocationDailyPercent) {
        busd = _busd;
        pandoAssembly = _pandoAssembly;
        allocationDailyPercent = _allocationDailyPercent;
        lastAllocatedTime = 0;
        allocateDay = 1;
    }

    modifier onlyOperator() {
        // Try to make flash-loan exploit harder to do by only allowing externally owned addresses.
        require(operators[msg.sender] == true, "PandoPool: must be operator");
        _;
    }

    function allocateReward() external onlyOperator whenNotPaused{
        require(allocateDay > 0 && block.timestamp - lastAllocatedTime > minAllocateInterval, 'PandoPot: !invalid');
        lastAllocatedTime = block.timestamp;
        uint256 _balance = IERC20(busd).balanceOf(address(this));
        uint256 _allocationAmount = _balance * allocationDailyPercent / ONE_HUNDRED_PERCENT;

        IERC20(busd).safeApprove(pandoAssembly, _allocationAmount);
        IPandoAssembly(pandoAssembly).allocateMoreRewards(_allocationAmount, allocateDay);
        emit RewardAllocated(allocateDay);
    }

    function emergencyWithdraw(address _token) external onlyOwner whenPaused {
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(_token, _amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setOperator(address _operator, bool _status) external onlyOwner {
        operators[_operator] = _status;
        emit OperatorChanged(_operator, _status);
    }

    function setPandoAssembly(address _pandoAssembly) external onlyOwner {
        address oldPandoAssembly = pandoAssembly;
        pandoAssembly = _pandoAssembly;
        emit PandoAssemblyChanged(oldPandoAssembly, _pandoAssembly);
    }

    function setAllocationPercent(uint256 _allocationDailyPercent) external onlyOwner {
        uint256 oldAllocationDailyPercent = allocationDailyPercent;
        allocationDailyPercent = _allocationDailyPercent;
        emit AllocationPercentChanged(oldAllocationDailyPercent, _allocationDailyPercent);
    }

    function setMinAllocateInterval(uint256 _newValue) external onlyOwner {
        uint256 oldMinAllocateInterval = minAllocateInterval;
        minAllocateInterval = _newValue;
        emit MinAllocateIntervalChanged(minAllocateInterval, oldMinAllocateInterval);
    }

    function setAllocateDay(uint256 _newValue) external onlyOwner {
        uint256 oldtAllocateDay = allocateDay;
        allocateDay = _newValue;
        emit AllocateDayChanged(allocateDay, oldtAllocateDay);
    }

    event RewardAllocated(uint256 _days);
    event MinAllocateIntervalChanged(uint256 newMinAllocateIntervalChanged, uint256 oldMinAllocateIntervalChanged);
    event AllocateDayChanged(uint256 newAllocateDayChanged, uint256 oldAllocateDayChanged);
    event EmergencyWithdraw(address token, uint256 amount);
    event OperatorChanged(address indexed operator, bool status);
    event PandoAssemblyChanged(address indexed oldPandoAssembly, address indexed newPandoAssembly);
    event AllocationPercentChanged(uint256 oldAllocationDailyPercent, uint256 newAllocationDailyPercent);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IPandoAssembly.sol";

contract PandoChestV2 is Ownable, Pausable {
    using SafeERC20 for IERC20;
    struct PoolInfo {
        address pool;
        uint256 rate;
    }
    mapping(address=> PoolInfo[]) public poolInfo;
    mapping(address => bool) public operators;
    address public pandoPool;
    uint256 public dailyDistributeAmount = 2000 ether; // 2000 USD/days
    uint256 public lastAllocatedTime;
    uint256 public minAllocateInterval = 23 * 1 hours;
    uint256 public constant ONE_HUNDRED_PERCENT = 10000;

    constructor (address _pandoPool) {
        pandoPool = _pandoPool;
        operators[_pandoPool] = true;
        lastAllocatedTime = 0;
    }

    modifier onlyOperator() {
        // Try to make flash-loan exploit harder to do by only allowing externally owned addresses.
        require(operators[msg.sender] == true, "PandoChest: must be operator");
        _;
    }

    function allocateMoreRewards(address[] memory _tokens, uint256[] memory _allocationAmounts, uint256 _allocateDay) external onlyOperator whenNotPaused{
        require(_allocateDay > 0 && block.timestamp - lastAllocatedTime > minAllocateInterval, 'PandoChest: !invalid minAllocateInterval');
        require(_tokens.length == _allocationAmounts.length, 'PandoChest: !invalid length');
        lastAllocatedTime = block.timestamp;
        for(uint256 i = 0; i < _tokens.length; i++){
            address _token = _tokens[i];
            PoolInfo[] memory pools = poolInfo[_token];
            if(pools.length > 0){
                uint256 _allocationAmount = _allocationAmounts[i];
                IERC20(_token).safeTransferFrom(pandoPool, address(this), _allocationAmount);
                PoolInfo[] memory pools = poolInfo[_token];
                for(uint256 i = 0; i < pools.length; i++){
                    uint256 _amount = _allocationAmount * pools[i].rate / ONE_HUNDRED_PERCENT;
                    IPandoAssembly(pools[i].pool).allocateMoreRewards(_amount, _allocateDay);
                    emit RewardAllocated(pools[i].pool, _token, _amount, _allocateDay);
                }
            }

            if (IERC20(_token).balanceOf(address(this)) >= dailyDistributeAmount) {
                IERC20(_token).safeTransfer(pandoPool, dailyDistributeAmount);
            }
        }
    }

    function manualAllocate(address _token, uint256 _allocationAmount, uint256 _allocateDay) external onlyOwner{
        PoolInfo[] memory pools = poolInfo[_token];
        if(pools.length > 0){
            IERC20(_token).safeTransferFrom(msg.sender,address(this), _allocationAmount);
            for(uint256 i = 0; i < pools.length; i++){
                uint256 _amount = _allocationAmount * pools[i].rate / ONE_HUNDRED_PERCENT;
                IPandoAssembly(pools[i].pool).allocateMoreRewards(_amount, _allocateDay);
                emit RewardAllocated(pools[i].pool, _token, _amount, _allocateDay);
            }
        }
    }

    function directAllocate(address _pool, address _token, uint256 _allocationAmount, uint256 _allocateDay) external onlyOwner{
        IERC20(_token).safeTransferFrom(msg.sender,address(this), _allocationAmount);
        IPandoAssembly(_pool).allocateMoreRewards(_allocationAmount , _allocateDay);
        emit RewardAllocated(_pool, _token, _allocationAmount, _allocateDay);
    }

    function emergencyWithdraw(address _token) external onlyOwner whenPaused {
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(_token, _amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setOperator(address _operator, bool _status) external onlyOwner {
        operators[_operator] = _status;
        emit OperatorChanged(_operator, _status);
    }

    function setMinAllocateInterval(uint256 _newValue) external onlyOwner {
        uint256 oldMinAllocateInterval = minAllocateInterval;
        minAllocateInterval = _newValue;
        emit MinAllocateIntervalChanged(minAllocateInterval, oldMinAllocateInterval);
    }

    function setDailyDistributeAmount(uint256 _amount) external onlyOwner {
        dailyDistributeAmount = _amount;
    }

    function setPandoPool(address _pandoPool) external onlyOwner {
        address old = pandoPool;
        pandoPool = _pandoPool;
        emit PandoPoolChanged(_pandoPool, old);
    }

    function setPools(address _token, address[] memory _pools, uint256[] memory _rates) external onlyOwner {
        require(_pools.length == _rates.length,"PandoChest: !length");

        PoolInfo[] storage _poolInfo = poolInfo[_token];
        while (0 < _poolInfo.length) {
            _poolInfo.pop();
        }

        uint256 _totalRate = 0;
        for(uint256 i = 0; i < _pools.length; i++){
            PoolInfo memory _pool = PoolInfo({
                pool: _pools[i],
                rate: _rates[i]
            });
            _poolInfo.push(_pool);

            if(IERC20(_token).allowance(address(this), _pools[i]) == 0){
                IERC20(_token).safeApprove(_pools[i], type(uint256).max);
            }
            _totalRate += _rates[i];
        }
        poolInfo[_token] = _poolInfo;

        require((_pools.length == 0 && _totalRate == 0) || _totalRate == ONE_HUNDRED_PERCENT,"PandoChest: !ONE_HUNDRED_PERCENT");
        emit PoolChanged(_token,_pools,_rates);
    }

    function getPoolInfo(address _token) public view returns(PoolInfo[] memory _poolInfo){
        _poolInfo = poolInfo[_token];
    }

    event RewardAllocated(address _pool, address _token,uint256 _amount, uint256 _days);
    event MinAllocateIntervalChanged(uint256 newMinAllocateIntervalChanged, uint256 oldMinAllocateIntervalChanged);
    event EmergencyWithdraw(address token, uint256 amount);
    event OperatorChanged(address indexed operator, bool status);
    event PoolChanged(address token, address[] pools, uint256[] rates);
    event PandoPoolChanged(address newPool, address oldPool);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Pandorium is ERC20Burnable, Ownable {
    uint256 public totalBurned;
    address public minter;

    constructor() ERC20('Pandorium', 'PAN'){
        minter = msg.sender;
    }

    /*----------------------------EXTERNAL FUNCTIONS----------------------------*/

    function burn(uint256 _amount) public override {
        totalBurned += _amount;
        ERC20Burnable.burn(_amount);
    }

    function burnFrom(address _account, uint256 _amount)  public override {
        totalBurned += _amount;
        ERC20Burnable.burnFrom(_account, _amount);
    }

    function mint(address _account, uint256 _amount) public onlyMinter {
        _mint(_account, _amount);
    }

    /*----------------------------RESTRICT FUNCTIONS----------------------------*/

    function changeMinter(address _newMinter) public onlyOwner {
        address _oldMinter = minter;
        minter = _newMinter;
        emit MinterChanged(_oldMinter, _newMinter);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Pandorium : caller is not the minter");
        _;
    }

    /*----------------------------EVENTS----------------------------*/

    event MinterChanged(address indexed oldMinter, address indexed newMinter);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract PandoraSpirit is ERC20Burnable {
    uint256 public totalBurned;

    constructor(uint256 _initialSupply, address _owner) ERC20('Pandora Spirit', 'PSR'){
        _mint(_owner, _initialSupply);
    }

    /*----------------------------EXTERNAL FUNCTIONS----------------------------*/
    function burn(uint256 _amount) public override {
        totalBurned += _amount;
        ERC20Burnable.burn(_amount);
    }

    function burnFrom(address _account, uint256 _amount)  public override {
        totalBurned += _amount;
        ERC20Burnable.burnFrom(_account, _amount);
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../interfaces/IDroidBot.sol";
import "../libraries/NFTLib.sol";
import "../interfaces/IUserLevel.sol";
import "../interfaces/IRewarder.sol";
import "hardhat/console.sol";

contract PandoAssemblyV3 is Ownable, IERC721Receiver, Pausable {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 power;
        uint256 bonus;
        int256 rewardDebt;
        EnumerableSet.UintSet nftIds;
    }

    IERC20 public busd;
    IDroidBot public droidBot;
    IUserLevel public userLevel;

    // governance
    uint256 private constant ACC_REWARD_PRECISION = 1e12;
    uint256 private constant SLOT_PRICE_PRECISION = 100;
    address public reserveFund;
    address public PSR;
    address public receivingFund;

    uint256 public accRewardPerShare;
    uint256 public lastRewardTime;
    uint256 public endRewardTime;
    uint256 public startRewardTime;

    uint256 public rewardPerSecond;
    uint256 public totalPower;
    uint256 public totalBonus;
    uint256 public slotBasePrice;
    uint256 public slotCoefficient;
    uint256 public minUserLevelStaking;
    uint256 public minDroidBotLevelStaking;

    mapping (address => UserInfo) private userInfo;
    mapping (address => uint256) public slotPurchased;

    IRewarder public rewarder;

    /* ========== Modifiers =============== */

    modifier onlyReserveFund() {
        require(reserveFund == msg.sender, "NFTStakingPool: caller is not the reserveFund");
        _;
    }

    modifier onlyMinUserLevel() {
        require( minUserLevelStaking <= userLevel.getUserLevel(msg.sender), "NFTStakingPool: !userLevel requirements");
        _;
    }

    constructor(address _busd, address _droidBot, address _PSR, address _userLevel) {
        busd = IERC20(_busd);
        droidBot = IDroidBot(_droidBot);
        userLevel = IUserLevel(_userLevel);
        PSR = _PSR;

        lastRewardTime = block.timestamp;
        startRewardTime = block.timestamp;
        slotBasePrice = 75 * 1e18;
        slotCoefficient = 120;
        minUserLevelStaking = 2;
        minDroidBotLevelStaking = 0;
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    function info(address _user) external view returns(uint256[] memory _nftIds){
        UserInfo storage user = userInfo[_user];
        _nftIds = EnumerableSet.values(user.nftIds);
    }

    function getTotalPower() external returns(uint256) {
        return _getTotalPower();
    }

    function originalPower(address _user) public view returns (uint256 res) {
        UserInfo storage user = userInfo[_user];
        uint256[] memory tokenIds = EnumerableSet.values(user.nftIds);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            res += droidBot.info(tokenIds[i]).power;
        }
    }

    function currentPower(address _user) public view returns(uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 power = NFTLib.getPower(EnumerableSet.values(user.nftIds), droidBot);
        return power + getBonus(power, _user);
    }

    function getRewardForDuration(uint256 _from, uint256 _to) public view returns (uint256) {
        uint256 _rewardPerSecond = rewardPerSecond;
        if (_from >= _to || _from >= endRewardTime) return 0;
        if (_to <= startRewardTime) return 0;
        if (_from <= startRewardTime) {
            if (_to <= endRewardTime) return (_to - startRewardTime) * _rewardPerSecond;
            else return (endRewardTime - startRewardTime) * _rewardPerSecond;
        }
        if (_to <= endRewardTime) return (_to - _from) * _rewardPerSecond;
        else return (endRewardTime - _from) * _rewardPerSecond;
    }

    function getRewardPerSecond() public view returns (uint256) {
        return getRewardForDuration(block.timestamp, block.timestamp + 1);
    }

    function pendingReward(address _user) external view returns (uint256 pending) {
        UserInfo storage user = userInfo[_user];
        uint256 _accRewardPerShare = accRewardPerShare;
        uint256 _totalPower = _getTotalPower();
        if (block.timestamp > lastRewardTime && _totalPower != 0) {
            uint256 rewardAmount = getRewardForDuration(lastRewardTime, block.timestamp);
            _accRewardPerShare += (rewardAmount * ACC_REWARD_PRECISION) / _totalPower;
        }
        pending = uint256(int256(user.power * _accRewardPerShare / ACC_REWARD_PRECISION) + int256(user.bonus * _accRewardPerShare / ACC_REWARD_PRECISION) - user.rewardDebt);
    }

    function getUserInfo(address _user) external view returns(uint, uint ,int256) {
        return (userInfo[_user].power, userInfo[_user].bonus, userInfo[_user].rewardDebt);
    }

    /// @notice Update reward variables of the given pool.
    function updatePool() public {
        if (block.timestamp > lastRewardTime) {
            uint256 _totalPower = _getTotalPower();
            if (_totalPower > 0) {
                uint256 rewardAmount = getRewardForDuration(lastRewardTime, block.timestamp);
                accRewardPerShare += rewardAmount * ACC_REWARD_PRECISION / _totalPower;
            }
            lastRewardTime = block.timestamp;
            emit LogUpdatePool(lastRewardTime, _totalPower, accRewardPerShare);
        }
        if(address(rewarder) != address(0)) {
            rewarder.updatePool();
        }
    }

    function buySlot(address to) external whenNotPaused {
        uint256 n = slotPurchased[to];
        uint256 p = slotBasePrice * (slotCoefficient**n) / (SLOT_PRICE_PRECISION**n);
        p -= getBonus(p, to);
        slotPurchased[to]++;
        if (receivingFund == address (0)) {
            ERC20Burnable(PSR).burnFrom(msg.sender, p);
        } else {
            IERC20(PSR).safeTransferFrom(msg.sender, receivingFund, p);
        }
        emit SlotBought(msg.sender, n);
    }

    function deposit(uint256[] memory tokenIds, address to) external whenNotPaused onlyMinUserLevel{
        updatePool();
        UserInfo storage user = userInfo[to];
        require(EnumerableSet.length(user.nftIds) + tokenIds.length <= 1 + slotPurchased[to], 'NFTStaking: stake more than slot purchased');

        // Effects
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require( minDroidBotLevelStaking <= _getDroidBotLevel(tokenId), "NFTStaking: < min level required");
            EnumerableSet.add(user.nftIds, tokenId);
            droidBot.safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }

        uint256 power = NFTLib.getPower(EnumerableSet.values(user.nftIds), droidBot);
        uint256 incPower = 0;

        require(power >= user.power, 'NFTStaking: Invalid deposit');

        incPower = power - user.power;
        totalPower += incPower;
//                user.rewardDebt += int256(incPower * accRewardPerShare / ACC_REWARD_PRECISION);
        user.rewardDebt += (int256(power * accRewardPerShare / ACC_REWARD_PRECISION) - int256(user.power * accRewardPerShare / ACC_REWARD_PRECISION));
        user.power = power;

        _update(to);

        if(address(rewarder) != address(0)) {
            rewarder.onDeposit(to, to, currentPower(to));
        }
        emit Deposit(msg.sender, tokenIds, incPower, to);
    }

    function withdraw(uint256[] memory tokenIds, address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if (EnumerableSet.contains(user.nftIds, tokenId)) {
                EnumerableSet.remove(user.nftIds, tokenId);
                droidBot.transferFrom(address(this), to, tokenId);
            }
        }
        uint256 power = NFTLib.getPower(EnumerableSet.values(user.nftIds), droidBot);
        uint256 withdrawPower = 0;
        require (user.power >= power, 'NFTStaking: Invalid withdraw');

        withdrawPower = user.power - power;
//                user.rewardDebt -= int256(withdrawPower * accRewardPerShare / ACC_REWARD_PRECISION);
        user.rewardDebt -= (int256(user.power * accRewardPerShare / ACC_REWARD_PRECISION) - int256(power * accRewardPerShare / ACC_REWARD_PRECISION));
        totalPower -= withdrawPower;
        user.power = power;

        _update(msg.sender);

        if(address(rewarder) != address(0)) {
            rewarder.onWithdraw(msg.sender, currentPower(msg.sender));
        }

        emit Withdraw(msg.sender, tokenIds, withdrawPower, to);
    }

    function update(address _account) external {
        updatePool();
        _update(_account);
        if(address(rewarder) != address(0)) {
            rewarder.onUpdate(_account, currentPower(_account));
        }
    }

    /// @notice Harvest proceeds for transaction sender to `to`.
    /// @param to Receiver of rewards.
    function harvest(address to) public whenNotPaused{
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
//        int256 accumulatedReward = int256((user.power + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        int256 accumulatedReward = int256(user.power * accRewardPerShare / ACC_REWARD_PRECISION) + int256( user.bonus * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedReward;

        // Interactions
        if (_pendingReward > 0) {
            busd.safeTransfer(to, _pendingReward);
        }

        if(address(rewarder) != address(0)) {
            rewarder.onReward(msg.sender, to, _pendingReward, currentPower(msg.sender));
        }
        emit Harvest(msg.sender, _pendingReward);
    }


    function withdrawAndHarvest(uint256[] memory tokenIds, address to) public whenNotPaused {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];

        int256 accumulatedReward = int256((user.power + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if (EnumerableSet.contains(user.nftIds, tokenId)) {
                EnumerableSet.remove(user.nftIds, tokenId);
                droidBot.transferFrom(address(this), to, tokenId);
            }
        }
        uint256 power = NFTLib.getPower(EnumerableSet.values(user.nftIds), droidBot);
        require (user.power >= power, 'NFTStaking: Invalid withdraw');

        uint256 withdrawPower = user.power - power;

        int256 newRewardDebt = (int256(user.power * accRewardPerShare / ACC_REWARD_PRECISION) - int256(power * accRewardPerShare / ACC_REWARD_PRECISION));
        user.rewardDebt = accumulatedReward - newRewardDebt;
        //        user.rewardDebt = accumulatedReward - int256(withdrawPower * accRewardPerShare / ACC_REWARD_PRECISION);
        user.power -= withdrawPower;
        totalPower -= withdrawPower;

        // Interactions
        if (_pendingReward > 0) {
            busd.safeTransfer(to, _pendingReward);
        }
        _update(msg.sender);

        if(address(rewarder) != address(0)) {
            rewarder.onReward(msg.sender, to, _pendingReward, currentPower(msg.sender));
        }

        emit Withdraw(msg.sender, tokenIds, withdrawPower, to);
        emit Harvest(msg.sender, _pendingReward);
    }

    function withdrawAll(address to) public {
        UserInfo storage user = userInfo[msg.sender];

        uint256[] memory tokenIds = EnumerableSet.values(user.nftIds);
        withdraw(tokenIds, to);
    }

    function withdrawAndHarvestAll(address to) public whenNotPaused{
        UserInfo storage user = userInfo[msg.sender];

        uint256[] memory tokenIds = EnumerableSet.values(user.nftIds);
        withdrawAndHarvest(tokenIds, to);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    /// @param to Receiver of the LP tokens.
    function emergencyWithdraw(address to) public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 power = user.power;
        user.power = 0;
        user.rewardDebt = 0;
        totalPower -= power;

        // Note: transfer can fail or succeed if `amount` is zero.
        uint256[] memory tokenIds = EnumerableSet.values(user.nftIds);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if (EnumerableSet.contains(user.nftIds, tokenId)) {
                EnumerableSet.remove(user.nftIds, tokenId);
                droidBot.transferFrom(address(this), to, tokenId);
            }
        }

        emit EmergencyWithdraw(msg.sender, tokenIds, power, to);
    }

    function onERC721Received(
        address operator,
        address, //from
        uint256, //tokenId
        bytes calldata //data
    ) public view override returns (bytes4) {
        require(
            operator == address(this),
            "received Nft from unauthenticated contract"
        );

        return
        bytes4(
            keccak256("onERC721Received(address,address,uint256,bytes)")
        );
    }

    /* ========== INTERNAL FUNCTIONS ========== */
    function _update(address account) internal {
        UserInfo storage user = userInfo[account];
        uint256 _oldBonus = user.bonus;
        uint256 _newBonus = getBonus(user.power, account);
        if (_newBonus > _oldBonus) {
            //            user.rewardDebt += int256((_newBonus - _oldBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            user.rewardDebt += (int256(_newBonus * accRewardPerShare / ACC_REWARD_PRECISION) - int256(_oldBonus * accRewardPerShare / ACC_REWARD_PRECISION));
            totalBonus += _newBonus - _oldBonus;
        } else {
            //            user.rewardDebt -= int256((_oldBonus - _newBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            user.rewardDebt -= (int256(_oldBonus * accRewardPerShare / ACC_REWARD_PRECISION) - int256(_newBonus * accRewardPerShare / ACC_REWARD_PRECISION));
            totalBonus -= _oldBonus - _newBonus;
        }

        if (0 <= user.rewardDebt && user.rewardDebt <= int256(ACC_REWARD_PRECISION) && user.power == 0) {
            user.rewardDebt = 0; // prevent Dept = 1
        }
        user.bonus = _newBonus;
    }

    function getBonus(uint256 _value, address _user) internal view returns(uint256) {
        if (address(userLevel) != address(0)) {
            (uint256 _n, uint256 _d) = userLevel.getBonus(_user, address(this));
            return _value * _n / _d;
        }
        return 0;
    }

    /// @notice Sets the reward per second to be distributed. Can only be called by the owner.
    /// @param _rewardPerSecond The amount of reward to be distributed per second.
    function setRewardPerSecond(uint256 _rewardPerSecond) internal {
        uint256 oldRewardPerSecond = rewardPerSecond;
        rewardPerSecond = _rewardPerSecond;
        emit RewardPerSecondChanged(oldRewardPerSecond, _rewardPerSecond);
    }

    function _getTotalPower() internal view returns(uint256) {
        return totalPower + totalBonus;
    }

    function _getDroidBotLevel(uint256 _tokenId) internal view returns (uint256 _lv) {
        if (address(droidBot) != address(0)) {
            _lv = droidBot.level(_tokenId);
        } else {
            _lv = 0;
        }
    }
    /* ========== RESTRICTED FUNCTIONS ========== */

    function allocateMoreRewards(uint256 _addedReward, uint256 _days) external onlyReserveFund {
        updatePool();
        uint256 _pendingSeconds = (endRewardTime >  block.timestamp) ? (endRewardTime - block.timestamp) : 0;
        uint256 _newPendingReward = (rewardPerSecond * _pendingSeconds) + _addedReward;
        uint256 _newPendingSeconds = _pendingSeconds + (_days * (1 days));
        uint256 _newRewardPerSecond = _newPendingReward / _newPendingSeconds;
        setRewardPerSecond(_newRewardPerSecond);
        if (_days > 0) {
            if (endRewardTime <  block.timestamp) {
                endRewardTime =  block.timestamp + (_days * (1 days));
            } else {
                endRewardTime = endRewardTime +  (_days * (1 days));
            }
        }
        busd.safeTransferFrom(msg.sender, address(this), _addedReward);
    }

    function setReserveFund(address _reserveFund) external onlyOwner {
        address oldReserveFund = reserveFund;
        reserveFund = _reserveFund;
        emit ReserveFundChanged(oldReserveFund ,_reserveFund);
    }

    function rescueFund(uint256 _amount) external onlyOwner {
        require(_amount > 0 && _amount <= busd.balanceOf(address(this)), "invalid amount");
        busd.safeTransfer(owner(), _amount);
        emit FundRescued(owner(), _amount);
    }

    function setPayment(address _PSR, uint256 _price, uint256 _coef) external onlyOwner {
        address oldPaymentToken = PSR;
        uint256 oldSlotBasePrice = slotBasePrice;
        uint256 oldSlotCoefficient = slotCoefficient;
        PSR = _PSR;
        slotBasePrice = _price;
        slotCoefficient = _coef;
        emit PaymentTokenChanged(oldPaymentToken, _PSR);
        emit SlotBasePriceChanged(oldSlotBasePrice, _price);
        emit SlotCoefficientChanged(oldSlotCoefficient, _coef);
    }

    function changeDroidBotAddress(address _newAddr) external onlyOwner {
        address oldDroidBot = address(droidBot);
        droidBot = IDroidBot(_newAddr);
        emit DroidBotChanged(oldDroidBot, _newAddr);
    }

    function setReceivingFund(address _addr) external onlyOwner {
        address oldReceivingFund = receivingFund;
        receivingFund = _addr;
        emit ReceivingFundChanged(oldReceivingFund, _addr);
    }

    function setRewarder(address _rewarder) external onlyOwner {
        address oldRewarder = address(rewarder);
        rewarder = IRewarder(_rewarder);
        emit RewarderChanged(oldRewarder, _rewarder);
    }

    function setUserLevelAddress(address _userLevel) external onlyOwner {
        userLevel = IUserLevel(_userLevel);
        emit UserLevelChanged(_userLevel);
    }

    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }
    /* =============== EVENTS ==================== */

    event Deposit(address indexed user, uint256[] nftId, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256[] nftId, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user,  uint256[] nftId, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 amount);
    event LogUpdatePool(uint256 lastRewardTime, uint256 lpSupply, uint256 accRewardPerShare);
    event RewardPerSecondChanged(uint256 oldRewardPerSecond, uint256 newRewardPerSecond);
    event FundRescued(address indexed receiver, uint256 amount);
    event DroidBotChanged(address indexed oldDroiBot, address indexed newDroiBot);
    event PaymentTokenChanged(address indexed oldToken, address indexed newToken);
    event SlotBasePriceChanged(uint256 oldPrice, uint256 newPrice);
    event SlotCoefficientChanged(uint256 oldCoef, uint256 newCoef);
    event ReceivingFundChanged(address indexed oldReceivingFund, address indexed newReceivingFund);
    event ReserveFundChanged(address indexed oldReserveFund, address indexed newReserveFund);
    event RewarderChanged(address indexed oldRewarder, address indexed newRewarder);
    event UserLevelChanged(address indexed userLevel);
    event SlotBought(address indexed buyer, uint256 slotNum);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewarder {
    function onReward(address, address, uint256, uint256) external;
    function pendingTokens(uint256, address, uint256) external view returns (IERC20[] memory, uint256[] memory);
    function onDeposit(address _user, address _to, uint256 _amount) external;
    function onWithdraw(address _user, uint256 _amount) external;
    function onUpdate(address _user, uint256 _amount) external;
    function updatePool() external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../interfaces/IDroidBot.sol";
import "../libraries/NFTLib.sol";
import "../interfaces/IUserLevel.sol";

contract PandoAssembly is Ownable, IERC721Receiver, Pausable {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 power;
        uint256 bonus;
        int256 rewardDebt;
        EnumerableSet.UintSet nftIds;
    }

    IERC20 public busd;
    IDroidBot public droidBot;
    IUserLevel public userLevel;

    // governance
    uint256 private constant ACC_REWARD_PRECISION = 1e12;
    uint256 private constant SLOT_PRICE_PRECISION = 100;
    address public reserveFund;
    address public PSR;
    address public receivingFund;

    uint256 public accRewardPerShare;
    uint256 public lastRewardTime;
    uint256 public endRewardTime;
    uint256 public startRewardTime;

    uint256 public rewardPerSecond;
    uint256 public totalPower;
    uint256 public totalBonus;
    uint256 public slotBasePrice;
    uint256 public slotCoefficient;

    //migrate
    address immutable public oldNftStaking;
    address public migrationAddress;
    bool public isMigrated;

    mapping (address => UserInfo) private userInfo;
    mapping (address => uint256) public slotPurchased;

    /* ========== Modifiers =============== */

    modifier onlyReserveFund() {
        require(reserveFund == msg.sender, "NFTStakingPool: caller is not the reserveFund");
        _;
    }

    modifier onlyMigrate() {
        require(migrationAddress == msg.sender, "NFTStakingPool: caller is not the migrationAddress");
        _;
    }

    constructor(address _busd, address _droidBot, address _PSR) {
        busd = IERC20(_busd);
        droidBot = IDroidBot(_droidBot);
        lastRewardTime = block.timestamp;
        startRewardTime = block.timestamp;
        PSR = _PSR;
        slotBasePrice = 100 * 1e18;
        slotCoefficient = 120;
        migrationAddress = msg.sender;
        //set old staking here
        oldNftStaking = 0xaBd9127dD374f9f72468A9efA86e12F84cE19f30;
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    function info(address _user) external view returns(uint256[] memory _nftIds){
        UserInfo storage user = userInfo[_user];
        _nftIds = EnumerableSet.values(user.nftIds);
    }

    function originalPower(address _user) public view returns (uint256 res) {
        UserInfo storage user = userInfo[_user];
        uint256[] memory tokenIds = EnumerableSet.values(user.nftIds);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            res += droidBot.info(tokenIds[i]).power;
        }
    }

    function currentPower(address _user) public view returns(uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 power = NFTLib.getPower(EnumerableSet.values(user.nftIds), droidBot);
        return power + getBonus(power, _user);
    }

    function getRewardForDuration(uint256 _from, uint256 _to) public view returns (uint256) {
        uint256 _rewardPerSecond = rewardPerSecond;
        if (_from >= _to || _from >= endRewardTime) return 0;
        if (_to <= startRewardTime) return 0;
        if (_from <= startRewardTime) {
            if (_to <= endRewardTime) return (_to - startRewardTime) * _rewardPerSecond;
            else return (endRewardTime - startRewardTime) * _rewardPerSecond;
        }
        if (_to <= endRewardTime) return (_to - _from) * _rewardPerSecond;
        else return (endRewardTime - _from) * _rewardPerSecond;
    }

    function getRewardPerSecond() public view returns (uint256) {
        return getRewardForDuration(block.timestamp, block.timestamp + 1);
    }

    function pendingReward(address _user) external view returns (uint256 pending) {
        UserInfo storage user = userInfo[_user];
        uint256 _accRewardPerShare = accRewardPerShare;
        uint256 _totalPower = getTotalPower();
        if (block.timestamp > lastRewardTime && _totalPower != 0) {
            uint256 rewardAmount = getRewardForDuration(lastRewardTime, block.timestamp);
            _accRewardPerShare += (rewardAmount * ACC_REWARD_PRECISION) / _totalPower;
        }
        pending = uint256(int256((user.power + user.bonus) * _accRewardPerShare / ACC_REWARD_PRECISION) - user.rewardDebt);
    }

    function getUserInfo(address _user) external view returns(uint, uint ,int256) {
        return (userInfo[_user].power, userInfo[_user].bonus, userInfo[_user].rewardDebt);
    }

    /// @notice Update reward variables of the given pool.
    function updatePool() public {
        uint256 _totalPower = getTotalPower();
        if (block.timestamp > lastRewardTime) {
            if (_totalPower > 0) {
                uint256 rewardAmount = getRewardForDuration(lastRewardTime, block.timestamp);
                accRewardPerShare += rewardAmount * ACC_REWARD_PRECISION / _totalPower;
            }
            lastRewardTime = block.timestamp;
            emit LogUpdatePool(lastRewardTime, _totalPower, accRewardPerShare);
        }
    }

    function buySlot(address to) external whenNotPaused {
        uint256 n = slotPurchased[to];
        uint256 p = slotBasePrice * (slotCoefficient**n) / (SLOT_PRICE_PRECISION**n);
        p -= getBonus(p, to);
        slotPurchased[to]++;
        if (receivingFund == address (0)) {
            ERC20Burnable(PSR).burnFrom(msg.sender, p);
        } else {
            IERC20(PSR).safeTransferFrom(msg.sender, receivingFund, p);
        }
        emit SlotBought(msg.sender, n);
    }

    function deposit(uint256[] memory tokenIds, address to) external {
        updatePool();
        UserInfo storage user = userInfo[to];
        require(EnumerableSet.length(user.nftIds) + tokenIds.length <= 4 + slotPurchased[to], 'Staking : stake more than slot purchased');

        // Effects
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            EnumerableSet.add(user.nftIds, tokenId);
            droidBot.safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }

        uint256 power = NFTLib.getPower(EnumerableSet.values(user.nftIds), droidBot);
        uint256 incPower = 0;

        require(power >= user.power, 'NFTStaking: Invalid deposit');

        incPower = power - user.power;
        totalPower += incPower;
        user.rewardDebt += int256(incPower * accRewardPerShare / ACC_REWARD_PRECISION);
        user.power = power;
        _update(msg.sender);
        emit Deposit(msg.sender, tokenIds, incPower, to);
    }

    function withdraw(uint256[] memory tokenIds, address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if (EnumerableSet.contains(user.nftIds, tokenId)) {
                EnumerableSet.remove(user.nftIds, tokenId);
                droidBot.transferFrom(address(this), to, tokenId);
            }
        }
        uint256 power = NFTLib.getPower(EnumerableSet.values(user.nftIds), droidBot);
        uint256 withdrawPower = 0;
        require (user.power >= power, 'NFTStaking: Invalid withdraw');

        withdrawPower = user.power - power;
        user.rewardDebt -= int256(withdrawPower * accRewardPerShare / ACC_REWARD_PRECISION);
        totalPower -= withdrawPower;

        user.power = power;
        _update(msg.sender);
        emit Withdraw(msg.sender, tokenIds, withdrawPower, to);
    }

    function update(address _account) external {
        updatePool();
        _update(_account);
    }

    /// @notice Harvest proceeds for transaction sender to `to`.
    /// @param to Receiver of rewards.
    function harvest(address to) public whenNotPaused{
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedReward = int256((user.power + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedReward;

        // Interactions
        if (_pendingReward > 0) {
            busd.safeTransfer(to, _pendingReward);
        }
        emit Harvest(msg.sender, _pendingReward);
    }


    function withdrawAndHarvest(uint256[] memory tokenIds, address to) public whenNotPaused {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];

        int256 accumulatedReward = int256((user.power + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if (EnumerableSet.contains(user.nftIds, tokenId)) {
                EnumerableSet.remove(user.nftIds, tokenId);
                droidBot.transferFrom(address(this), to, tokenId);
            }
        }
        uint256 power = NFTLib.getPower(EnumerableSet.values(user.nftIds), droidBot);
        require (user.power >= power, 'NFTStaking: Invalid withdraw');

        uint256 withdrawPower = user.power - power;

        user.rewardDebt = accumulatedReward - int256(withdrawPower * accRewardPerShare / ACC_REWARD_PRECISION);
        user.power -= withdrawPower;
        totalPower -= withdrawPower;

        // Interactions
        if (_pendingReward > 0) {
            busd.safeTransfer(to, _pendingReward);
        }
        _update(msg.sender);
        emit Withdraw(msg.sender, tokenIds, withdrawPower, to);
        emit Harvest(msg.sender, _pendingReward);
    }

    function withdrawAll(address to) public {
        UserInfo storage user = userInfo[msg.sender];

        uint256[] memory tokenIds = EnumerableSet.values(user.nftIds);
        withdraw(tokenIds, to);
    }

    function withdrawAndHarvestAll(address to) public whenNotPaused{
        UserInfo storage user = userInfo[msg.sender];

        uint256[] memory tokenIds = EnumerableSet.values(user.nftIds);
        withdrawAndHarvest(tokenIds, to);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    /// @param to Receiver of the LP tokens.
    function emergencyWithdraw(address to) public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 power = user.power;
        user.power = 0;
        user.rewardDebt = 0;
        totalPower -= power;

        // Note: transfer can fail or succeed if `amount` is zero.
        uint256[] memory tokenIds = EnumerableSet.values(user.nftIds);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if (EnumerableSet.contains(user.nftIds, tokenId)) {
                EnumerableSet.remove(user.nftIds, tokenId);
                droidBot.transferFrom(address(this), to, tokenId);
            }
        }

        emit EmergencyWithdraw(msg.sender, tokenIds, power, to);
    }

    function onERC721Received(
        address operator,
        address, //from
        uint256, //tokenId
        bytes calldata //data
    ) public view override returns (bytes4) {
        require(
            operator == address(this),
            "received Nft from unauthenticated contract"
        );

        return
        bytes4(
            keccak256("onERC721Received(address,address,uint256,bytes)")
        );
    }

    /* ========== MIGRATE FUNCTIONS ========== */
    function migrate(address[] memory _users, uint256[] memory _slots, bool _finish) external onlyOwner whenPaused{
        require(!isMigrated, "Staking: project has been migrated");
        uint256 _length = _users.length;
        require(_length == _slots.length, "Staking: !equal length");
        for(uint i = 0; i < _length; i ++) {
            slotPurchased[_users[i]] = _slots[i];
            emit MigrateSlot(_users[i], _slots[i]);
        }
        isMigrated = _finish;
        emit MigrateFinish(_finish);
    }


    /* ========== INTERNAL FUNCTIONS ========== */
    function _update(address account) internal {
        UserInfo storage user = userInfo[account];
        uint256 _oldBonus = user.bonus;
        uint256 _newBonus = getBonus(user.power, account);
        if (_newBonus > _oldBonus) {
            user.rewardDebt += int256((_newBonus - _oldBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            totalBonus += _newBonus - _oldBonus;
        } else {
            user.rewardDebt -= int256((_oldBonus - _newBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            totalBonus -= _oldBonus - _newBonus;
        }
        user.bonus = _newBonus;
    }

    function getBonus(uint256 _value, address _user) internal view returns(uint256) {
        if (address(userLevel) != address(0)) {
            (uint256 _n, uint256 _d) = userLevel.getBonus(_user, address(this));
            return _value * _n / _d;
        }
        return 0;
    }

    /// @notice Sets the reward per second to be distributed. Can only be called by the owner.
    /// @param _rewardPerSecond The amount of reward to be distributed per second.
    function setRewardPerSecond(uint256 _rewardPerSecond) internal {
        uint256 oldRewardPerSecond = rewardPerSecond;
        rewardPerSecond = _rewardPerSecond;
        emit RewardPerSecondChanged(oldRewardPerSecond, _rewardPerSecond);
    }

    function getTotalPower() internal view returns(uint256) {
        return totalPower + totalBonus;
    }
    /* ========== RESTRICTED FUNCTIONS ========== */

    function allocateMoreRewards(uint256 _addedReward, uint256 _days) external onlyReserveFund {
        updatePool();
        uint256 _pendingSeconds = (endRewardTime >  block.timestamp) ? (endRewardTime - block.timestamp) : 0;
        uint256 _newPendingReward = (rewardPerSecond * _pendingSeconds) + _addedReward;
        uint256 _newPendingSeconds = _pendingSeconds + (_days * (1 days));
        uint256 _newRewardPerSecond = _newPendingReward / _newPendingSeconds;
        setRewardPerSecond(_newRewardPerSecond);
        if (_days > 0) {
            if (endRewardTime <  block.timestamp) {
                endRewardTime =  block.timestamp + (_days * (1 days));
            } else {
                endRewardTime = endRewardTime +  (_days * (1 days));
            }
        }
        busd.safeTransferFrom(msg.sender, address(this), _addedReward);
    }

    function setReserveFund(address _reserveFund) external onlyOwner {
        address oldReserveFund = reserveFund;
        reserveFund = _reserveFund;
        emit ReserveFundChanged(oldReserveFund ,_reserveFund);
    }

    function rescueFund(uint256 _amount) external onlyOwner {
        require(_amount > 0 && _amount <= busd.balanceOf(address(this)), "invalid amount");
        busd.safeTransfer(owner(), _amount);
        emit FundRescued(owner(), _amount);
    }

    function setPayment(address _PSR, uint256 _price, uint256 _coef) external onlyOwner {
        address oldPaymentToken = PSR;
        uint256 oldSlotBasePrice = slotBasePrice;
        uint256 oldSlotCoefficient = slotCoefficient;
        PSR = _PSR;
        slotBasePrice = _price;
        slotCoefficient = _coef;
        emit PaymentTokenChanged(oldPaymentToken, _PSR);
        emit SlotBasePriceChanged(oldSlotBasePrice, _price);
        emit SlotCoefficientChanged(oldSlotCoefficient, _coef);
    }

    function changeDroidBotAddress(address _newAddr) external onlyOwner {
        address oldDroidBot = address(droidBot);
        droidBot = IDroidBot(_newAddr);
        emit DroidBotChanged(oldDroidBot, _newAddr);
    }

    function setReceivingFund(address _addr) external onlyOwner {
        address oldReceivingFund = receivingFund;
        receivingFund = _addr;
        emit ReceivingFundChanged(oldReceivingFund, _addr);
    }

    function setUserLevelAddress(address _userLevel) external onlyOwner {
        userLevel = IUserLevel(_userLevel);
        emit UserLevelChanged(_userLevel);
    }

    function setMigrateAddress(address _migrateAddress) external onlyOwner {
        address old = migrationAddress;
        migrationAddress = _migrateAddress;
        emit MigrateAddressChanged(old ,_migrateAddress);
    }

    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }
    /* =============== EVENTS ==================== */

    event Deposit(address indexed user, uint256[] nftId, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256[] nftId, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user,  uint256[] nftId, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 amount);
    event LogUpdatePool(uint256 lastRewardTime, uint256 lpSupply, uint256 accRewardPerShare);
    event RewardPerSecondChanged(uint256 oldRewardPerSecond, uint256 newRewardPerSecond);
    event FundRescued(address indexed receiver, uint256 amount);
    event DroidBotChanged(address indexed oldDroiBot, address indexed newDroiBot);
    event PaymentTokenChanged(address indexed oldToken, address indexed newToken);
    event SlotBasePriceChanged(uint256 oldPrice, uint256 newPrice);
    event SlotCoefficientChanged(uint256 oldCoef, uint256 newCoef);
    event ReceivingFundChanged(address indexed oldReceivingFund, address indexed newReceivingFund);
    event ReserveFundChanged(address indexed oldReserveFund, address indexed newReserveFund);
    event UserLevelChanged(address indexed userLevel);
    event SlotBought(address indexed buyer, uint256 slotNum);
    event MigrateSlot(address user, uint256 slotNum);
    event MigrateFinish(bool _isDone);
    event MigrateAddressChanged(address _old ,address _new);

}

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PrivateSale is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public PSR;

    struct LockedData {
        uint256 total;
        uint256 pending;
        uint256 estUnlock;
        uint256 unlockedAmounts;
    }

    mapping(address => LockedData) public data;
    uint256 public startLock;
    uint256 public unlockDuration = 30 days;
    uint256 public lockedTime = 6 * 30 days;

    constructor (address _psr) {
        PSR = IERC20(_psr);
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    function lock(address _account, uint256 _amount, uint256 _unlockAmount) external {
        if (startLock == 0) {
            startLock = block.timestamp;
        }
        require(data[_account].total == 0, 'Locked: locked before');
        if (_amount > 0) {
            PSR.safeTransferFrom(msg.sender, address(this), _amount);
            data[_account] = LockedData ({
            total : _amount,
            unlockedAmounts : 0,
            estUnlock : (_amount - _unlockAmount) / (lockedTime / unlockDuration),
            pending : _unlockAmount
            });
        }
        emit Locked(_account, _amount, _unlockAmount);
    }

    function pending(address _account) public view returns(uint256 _pending) {
        if (block.timestamp < startLock) {
            return 0;
        }
        LockedData memory _data = data[_account];
        uint256 _totalLockRemain =  _data.total - _data.unlockedAmounts - _data.pending;
        if (_totalLockRemain > 0) {
            if (block.timestamp >= startLock + lockedTime) {
                _pending = _totalLockRemain;
            } else {
                uint256 _nUnlock = (lockedTime - (block.timestamp - startLock) - 1) / unlockDuration + 1;
                _pending = _totalLockRemain - _data.estUnlock * _nUnlock;
            }
        }
        if (_data.pending > 0) {
            _pending += _data.pending;
        }
    }

    function unlock(address _to) external whenNotPaused nonReentrant {
        LockedData storage _lockedData = data[msg.sender];
        require(_lockedData.total > _lockedData.unlockedAmounts, 'Locked: cannot unlock');

        uint256 _unlockAmount = pending(msg.sender);
        require(_unlockAmount > 0, 'Locked:  invalid unlock amount');

        _lockedData.unlockedAmounts += _unlockAmount;
        if (_lockedData.pending > 0) {
            _lockedData.pending = 0;
        }
        PSR.safeTransfer(_to, _unlockAmount);
        emit Unlocked(_to, _unlockAmount);
    }

    function emergencyWithdraw(address _to) external whenPaused {
        LockedData storage _lockedData = data[msg.sender];
        uint256 _unlockAmount = _lockedData.total - _lockedData.unlockedAmounts;
        _lockedData.unlockedAmounts += _unlockAmount;
        PSR.safeTransfer(_to, _unlockAmount);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setStartLock(uint256 _value) external onlyOwner {
        uint256 oldStartLock = startLock;
        startLock = _value;
        emit StartLockChanged(oldStartLock, _value);
    }
    function setUnlockDuration(uint256 _newValue) external onlyOwner {
        uint256 oldUnlockDuration = unlockDuration;
        unlockDuration = _newValue;
        emit UnlockDurationChanged(oldUnlockDuration, _newValue);
    }

    function setLockedTime(uint256 _newValue) external onlyOwner {
        uint256 oldLockedTime = lockedTime;
        lockedTime = _newValue;
        emit LockedTimeChanged(oldLockedTime, _newValue);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /* ========== EVENTS ========== */

    event Locked(address account, uint256 amount, uint256 unlockAmount);
    event Unlocked(address to, uint256 amount);
    event StartLockChanged(uint256 oldStartLock, uint256 newStartLock);
    event UnlockDurationChanged(uint256 oldUnlockDuration, uint256 newUnlockDuration);
    event LockedTimeChanged(uint256 oldLockedTime, uint256 newLockedTime);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../interfaces/IPAN.sol";

contract Minter is Ownable, ReentrancyGuard {
    using SafeERC20 for IPAN;

    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;
    }

    mapping (address => bool) public operators;
    uint256 public PANPerBlock;
    uint256 public lastMinted;
    IPAN public PAN;
    address public devFund;
    uint256 public devFundPercent = 1000;
    uint256 public constant ONE_HUNDRED_PERCENT = 10000;

    modifier onlyOperators() {
        require(operators[msg.sender] == true, "Minter: caller is not the operators");
        _;
    }

    constructor (address _devFund, IPAN _PAN, uint256 _PANPerBlock, uint256 _startMint) {
        devFund = _devFund;
        PANPerBlock = _PANPerBlock;
        PAN = _PAN;
        lastMinted = _startMint;
    }

    function update() public {
        if (block.number > lastMinted) {
            uint256 _amount = (block.number - lastMinted) * PANPerBlock;
            uint256 _toDev = _amount * devFundPercent / ONE_HUNDRED_PERCENT;
            PAN.mint(address(this), _amount);
            PAN.safeTransfer(devFund, _toDev);
            lastMinted = block.number;
        }
    }

    function transfer(address _to, uint256 _amount) external onlyOperators nonReentrant {
        if (_amount >= PAN.balanceOf(address(this))) {
            update();
        }
        require(_amount <= PAN.balanceOf(address(this)), 'Minter: not enough PAN');
        PAN.safeTransfer(_to, _amount);
    }

    function setOperator(address _operator, bool _status) external onlyOwner {
        operators[_operator] = _status;
        emit OperatorChanged(_operator, _status);
    }

    function setPANPerBlock(uint256 _PANPerBlock) external onlyOwner {
        update();
        uint256 oldPANPerBlock = PANPerBlock;
        PANPerBlock = _PANPerBlock;
        emit PANPerBlockChanged(oldPANPerBlock, _PANPerBlock);
    }

    function changeDevFundPercent(uint256 _newPercent) external onlyOwner {
        uint256 oldDevFundPercent = devFundPercent;
        devFundPercent = _newPercent;
        emit DevFundPercentChanged(oldDevFundPercent, _newPercent);
    }

    function changeDevFund(address _newAddr) external onlyOwner {
        address oldDevFund = devFund;
        devFund = _newAddr;
        emit DevFundChanged(oldDevFund, _newAddr);
    }

    event OperatorChanged(address indexed operator, bool status);
    event PANPerBlockChanged(uint256 oldPANPerBlock, uint256 newPANPerBlock);
    event DevFundPercentChanged(uint256 oldPercent, uint256 newPercent);
    event DevFundChanged(address indexed oldDevFund, address indexed newDevFund);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ClaimReward is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using Counters for Counters.Counter;

    uint256 public constant ONE_HUNDRED_PERCENT = 10000;
    address public tokenReward;
    address public validator;
    
    mapping(address => bool) public isClaimed;

    constructor (address _tokenReward, address _validator) {
        tokenReward = _tokenReward;
        validator = _validator;
    }

    modifier onlyEOA() {
        // Try to make flash-loan exploit harder to do by only allowing externally owned addresses.
        require(msg.sender == tx.origin, "ClaimReward: must use EOA");
        _;
    }

    // ================= INTERNAL FUNCTIONS ================= //
    function _getValidatorSignature(bytes32 hash, bytes memory signature) internal view returns (address) {
        return ECDSA.recover(hash, signature);
    }

    function _prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    // ================= PUBLIC FUNCTIONS ================= //
    function claimReward(uint _amount, uint _expiredTime, bytes memory signature) external onlyEOA whenNotPaused nonReentrant {
        require(msg.sender != address(0), "ClaimReward: Address not zero");
        require(block.timestamp <= _expiredTime, "ClaimReward: Expired time");
        require(!isClaimed[msg.sender], "ClaimReward: You are claimed");
        isClaimed[msg.sender] = true;

        bytes32 _hash = _prefixed(keccak256(abi.encodePacked(_amount, _expiredTime, msg.sender, address(this))));
        require(validator == _getValidatorSignature(_hash, signature), "ClaimReward: Signature invalid");

        IERC20(tokenReward).safeTransfer(msg.sender, _amount);
        
        emit ClaimRewarded(msg.sender, tokenReward, _amount);
    }

    function checkBalance()public view returns(uint256) {
        return IERC20(tokenReward).balanceOf(address(this));
    }

    // ================= ADMIN FUNCTIONS ================= //
    function emergencyWithdraw(address _token) external onlyOwner whenPaused {
        uint256 _amount = IERC20(tokenReward).balanceOf(address(this));
        IERC20(tokenReward).safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(tokenReward, _amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function changeValidator(address _validator) external onlyOwner {
        address oldValidator = validator;
        validator = _validator;
        emit ValidatorChanged(oldValidator, validator);
    }

    event ClaimRewarded(address user, address token, uint256 amount);
    event EmergencyWithdraw(address token, uint256 amount);
    event AddBalance(address token, uint256 amount);
    event ValidatorChanged(address indexed oldValidator, address indexed newValidator);
}

pragma solidity 0.8.4;
pragma abicoder v2;


import "../libraries/EthReceiver.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../libraries/Permitable.sol";
import "../interfaces/IWETH.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract LimitOrderProtocolRFQ is EthReceiver, EIP712("1inch RFQ", "2"), Permitable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event OrderFilledRFQ(
        bytes32 orderHash,
        uint256 makingAmount
    );

    struct OrderRFQ {
        // lowest 64 bits is the order id, next 64 bits is the expiration timestamp
        // highest bit is unwrap WETH flag which is set on taker's side
        // [unwrap eth(1 bit) | unused (127 bits) | expiration timestamp(64 bits) | orderId (64 bits)]
        uint256 info;
        IERC20 makerAsset;
        IERC20 takerAsset;
        address maker;
        address allowedSender;  // equals to Zero address on public orders
        uint256 makingAmount;
        uint256 takingAmount;
    }

    bytes32 constant public LIMIT_ORDER_RFQ_TYPEHASH = keccak256(
        "OrderRFQ(uint256 info,address makerAsset,address takerAsset,address maker,address allowedSender,uint256 makingAmount,uint256 takingAmount)"
    );
    uint256 private constant _UNWRAP_WETH_MASK = 1 << 255;

    IWETH private immutable _WETH;  // solhint-disable-line var-name-mixedcase
    mapping(address => mapping(uint256 => uint256)) private _invalidator;

    constructor(address weth) {
        _WETH = IWETH(weth);
    }

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns(bytes32) {
        return _domainSeparatorV4();
    }

    /// @notice Returns bitmask for double-spend invalidators based on lowest byte of order.info and filled quotes
    /// @return Result Each bit represents whenever corresponding quote was filled
    function invalidatorForOrderRFQ(address maker, uint256 slot) external view returns(uint256) {
        return _invalidator[maker][slot];
    }

    /// @notice Cancels order's quote
    function cancelOrderRFQ(uint256 orderInfo) external {
        _invalidateOrder(msg.sender, orderInfo);
    }

    /// @notice Fills order's quote, fully or partially (whichever is possible)
    /// @param order Order quote to fill
    /// @param signature Signature to confirm quote ownership
    /// @param makingAmount Making amount
    /// @param takingAmount Taking amount
    function fillOrderRFQ(
        OrderRFQ memory order,
        bytes calldata signature,
        uint256 makingAmount,
        uint256 takingAmount
    ) external payable returns(uint256 /* actualMakingAmount */, uint256 /* actualTakingAmount */) {
        return fillOrderRFQTo(order, signature, makingAmount, takingAmount, payable(msg.sender));
    }

    /// @notice Fills Same as `fillOrderRFQ` but calls permit first,
    /// allowing to approve token spending and make a swap in one transaction.
    /// Also allows to specify funds destination instead of `msg.sender`
    /// @param order Order quote to fill
    /// @param signature Signature to confirm quote ownership
    /// @param makingAmount Making amount
    /// @param takingAmount Taking amount
    /// @param target Address that will receive swap funds
    /// @param permit Should consist of abiencoded token address and encoded `IERC20Permit.permit` call.
    /// See tests for examples
    function fillOrderRFQToWithPermit(
        OrderRFQ memory order,
        bytes calldata signature,
        uint256 makingAmount,
        uint256 takingAmount,
        address payable target,
        bytes calldata permit
    ) external returns(uint256 /* actualMakingAmount */, uint256 /* actualTakingAmount */) {
        _permit(address(order.takerAsset), permit);
        return fillOrderRFQTo(order, signature, makingAmount, takingAmount, target);
    }

    /// @notice Same as `fillOrderRFQ` but allows to specify funds destination instead of `msg.sender`
    /// @param order Order quote to fill
    /// @param signature Signature to confirm quote ownership
    /// @param makingAmount Making amount
    /// @param takingAmount Taking amount
    /// @param target Address that will receive swap funds
    function fillOrderRFQTo(
        OrderRFQ memory order,
        bytes calldata signature,
        uint256 makingAmount,
        uint256 takingAmount,
        address payable target
    ) public payable returns(uint256 /* actualMakingAmount */, uint256 /* actualTakingAmount */) {
        address maker = order.maker;
        bool unwrapWETH = (order.info & _UNWRAP_WETH_MASK) > 0;
        order.info = order.info & (_UNWRAP_WETH_MASK - 1);  // zero-out unwrap weth flag as it is taker-only
        {  // Stack too deep
            uint256 info = order.info;
            // Check time expiration
            uint256 expiration = uint128(info) >> 64;
            require(expiration == 0 || block.timestamp <= expiration, "LOP: order expired");  // solhint-disable-line not-rely-on-time
            _invalidateOrder(maker, info);
        }

        {  // stack too deep
            uint256 orderMakingAmount = order.makingAmount;
            uint256 orderTakingAmount = order.takingAmount;
            // Compute partial fill if needed
            if (takingAmount == 0 && makingAmount == 0) {
                // Two zeros means whole order
                makingAmount = orderMakingAmount;
                takingAmount = orderTakingAmount;
            }
            else if (takingAmount == 0) {
                require(makingAmount <= orderMakingAmount, "LOP: making amount exceeded");
                takingAmount = orderTakingAmount.mul(makingAmount).add(orderMakingAmount - 1).div(orderMakingAmount);
            }
            else if (makingAmount == 0) {
                require(takingAmount <= orderTakingAmount, "LOP: taking amount exceeded");
                makingAmount = orderMakingAmount.mul(takingAmount).div(orderTakingAmount);
            }
            else {
                revert("LOP: one of amounts should be 0");
            }
        }

        require(makingAmount > 0 && takingAmount > 0, "LOP: can't swap 0 amount");

        // Validate order
        require(order.allowedSender == address(0) || order.allowedSender == msg.sender, "LOP: private order");
        bytes32 orderHash = _hashTypedDataV4(keccak256(abi.encode(LIMIT_ORDER_RFQ_TYPEHASH, order)));
        _validate(maker, orderHash, signature);

        // Maker => Taker
        if (order.makerAsset == _WETH && unwrapWETH) {
            order.makerAsset.safeTransferFrom(maker, address(this), makingAmount);
            _WETH.withdraw(makingAmount);
            target.transfer(makingAmount);
        } else {
            order.makerAsset.safeTransferFrom(maker, target, makingAmount);
        }
        // Taker => Maker
        if (order.takerAsset == _WETH && msg.value > 0) {
            require(msg.value == takingAmount, "LOP: wrong msg.value");
            _WETH.deposit{ value: takingAmount }();
            _WETH.transfer(maker, takingAmount);
        } else {
            require(msg.value == 0, "LOP: wrong msg.value");
            order.takerAsset.safeTransferFrom(msg.sender, maker, takingAmount);
        }

        emit OrderFilledRFQ(orderHash, makingAmount);
        return (makingAmount, takingAmount);
    }

    function _validate(address signer, bytes32 orderHash, bytes calldata signature) private view {
        // if (ECDSA.tryRecover(orderHash, signature)[0] != signer) {
        //     (bool success, bytes memory result) = signer.staticcall(
        //         abi.encodeWithSelector(IERC1271.isValidSignature.selector, orderHash, signature)
        //     );
        //     require(success && result.length == 32 && abi.decode(result, (bytes4)) == IERC1271.isValidSignature.selector, "LOP: bad signature");
        // }
    }

    function _invalidateOrder(address maker, uint256 orderInfo) private {
        uint256 invalidatorSlot = uint64(orderInfo) >> 8;
        uint256 invalidatorBit = 1 << uint8(orderInfo);
        mapping(uint256 => uint256) storage invalidatorStorage = _invalidator[maker];
        uint256 invalidator = invalidatorStorage[invalidatorSlot];
        require(invalidator & invalidatorBit == 0, "LOP: invalidated order");
        invalidatorStorage[invalidatorSlot] = invalidator | invalidatorBit;
    }
}

pragma solidity 0.8.4;

/// @title Base contract with common payable logics
abstract contract EthReceiver {
    receive() external payable {
        // solhint-disable-next-line avoid-tx-origin
        require(msg.sender != tx.origin, "ETH deposit rejected");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "../libraries/RevertReasonParser.sol";

/// @title Base contract with common permit handling logics
contract Permitable {
    function _permit(address token, bytes calldata permit) internal {
        if (permit.length > 0) {
            bool success;
            bytes memory result;
            if (permit.length == 32 * 7) {
                // solhint-disable-next-line avoid-low-level-calls
                (success, result) = token.call(abi.encodePacked(IERC20Permit.permit.selector, permit));
            } else {
                revert("Wrong permit length");
            }
            if (!success) {
                revert(RevertReasonParser.parse(result, "Permit failed: "));
            }
        }
    }
}

pragma solidity 0.8.4;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
/// @title Interface for WETH tokens
interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.0;

import "./draft-IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/draft-EIP712.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

pragma solidity 0.8.4;

/// @title Library that allows to parse unsuccessful arbitrary calls revert reasons.
/// See https://solidity.readthedocs.io/en/latest/control-structures.html#revert for details.
/// Note that we assume revert reason being abi-encoded as Error(string) so it may fail to parse reason
/// if structured reverts appear in the future.
///
/// All unsuccessful parsings get encoded as Unknown(data) string
library RevertReasonParser {
    bytes4 constant private _PANIC_SELECTOR = bytes4(keccak256("Panic(uint256)"));
    bytes4 constant private _ERROR_SELECTOR = bytes4(keccak256("Error(string)"));

    function parse(bytes memory data, string memory prefix) internal pure returns (string memory) {
        if (data.length >= 4) {
            bytes4 selector;
            assembly {  // solhint-disable-line no-inline-assembly
                selector := mload(add(data, 0x20))
            }

            // 68 = 4-byte selector + 32 bytes offset + 32 bytes length
            if (selector == _ERROR_SELECTOR && data.length >= 68) {
                uint256 offset;
                bytes memory reason;
                // solhint-disable no-inline-assembly
                assembly {
                    // 36 = 32 bytes data length + 4-byte selector
                    offset := mload(add(data, 36))
                    reason := add(data, add(36, offset))
                }
                /*
                    revert reason is padded up to 32 bytes with ABI encoder: Error(string)
                    also sometimes there is extra 32 bytes of zeros padded in the end:
                    https://github.com/ethereum/solidity/issues/10170
                    because of that we can't check for equality and instead check
                    that offset + string length + extra 36 bytes is less than overall data length
                */
                require(data.length >= 36 + offset + reason.length, "Invalid revert reason");
                return string(abi.encodePacked(prefix, "Error(", reason, ")"));
            }
            // 36 = 4-byte selector + 32 bytes integer
            else if (selector == _PANIC_SELECTOR && data.length == 36) {
                uint256 code;
                // solhint-disable no-inline-assembly
                assembly {
                    // 36 = 32 bytes data length + 4-byte selector
                    code := mload(add(data, 36))
                }
                return string(abi.encodePacked(prefix, "Panic(", _toHex(code), ")"));
            }
        }

        return string(abi.encodePacked(prefix, "Unknown(", _toHex(data), ")"));
    }

    function _toHex(uint256 value) private pure returns(string memory) {
        return _toHex(abi.encodePacked(value));
    }

    function _toHex(bytes memory data) private pure returns(string memory) {
        bytes16 alphabet = 0x30313233343536373839616263646566;
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 * i + 2] = alphabet[uint8(data[i] >> 4)];
            str[2 * i + 3] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../libraries/Random.sol";
import "../libraries/NFTLib.sol";
import "../interfaces/IDataStorage.sol";

contract PandoBox is ERC721Burnable, Ownable {
    address public minter;
    uint256 public totalSupply;
    mapping (uint256 => NFTLib.Info) public nftInfo;
    string baseURI;

    /*----------------------------CONSTRUCTOR----------------------------*/

    constructor(string memory _URI) ERC721("PandoBox NFT Token", "PBOX")
    {
        baseURI = _URI;
    }

    function _baseURI() internal view override returns(string memory) {
        return baseURI;
    }

    /*----------------------------EXTERNAL FUNCTIONS----------------------------*/

    function create(address _receiver, uint256 _lv) external onlyMinter returns(uint256 _tokenId){
        require(_receiver != address(0), 'PandoBoxNFT: _receiver is the zero address');

        totalSupply++;
        _tokenId = totalSupply;
        _mint(_receiver, _tokenId);
        nftInfo[_tokenId] = NFTLib.Info({
            level : _lv,
            power : 0
        });
        emit PandoBoxCreated(_receiver, _tokenId, _lv);
    }

    function info(uint256 _id) external view returns (NFTLib.Info memory) {
        return nftInfo[_id];
    }

    /*----------------------------RESTRICT FUNCTIONS----------------------------*/

    function changeMinter(address _newMinter) external onlyOwner {
        address _oldMinter = minter;
        minter = _newMinter;
        emit MinterChanged(_oldMinter, _newMinter);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "PandoBox: caller is not the minter");
        _;
    }

    /*----------------------------EVENTS----------------------------*/

    event PandoBoxCreated(address indexed receiver,uint256 indexed id, uint256 level);
    event MinterChanged(address indexed oldMinter, address indexed newMinter);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library Random {
    address constant BNB = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE; // mainnet 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
    address constant BTC = 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf; // mainnet 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf
    address constant ETH = 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e; // mainnet 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e

    uint256 constant PRECISION = 1e20;

    function getLatestPrice(address _addr) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_addr);
        (, int256 _price, , , ) = priceFeed.latestRoundData();
        return uint256(_price);
    }

    function computerSeed(uint256 salt) internal view returns (uint256) {
        uint256 seed =
        uint256(
            keccak256(
                abi.encodePacked(
                    (block.timestamp)
                    + block.gaslimit
                    + uint256(keccak256(abi.encodePacked(blockhash(block.number)))) / (block.timestamp)
                    + uint256(keccak256(abi.encodePacked(block.coinbase))) / (block.timestamp)
                    + (uint256(keccak256(abi.encodePacked(tx.origin)))) / (block.timestamp)
                    + block.number * block.timestamp
                )
            )
        );
        seed = (seed % PRECISION) * getLatestPrice(BNB);
        seed = (seed % PRECISION) * getLatestPrice(ETH);
        seed = (seed % PRECISION) * getLatestPrice(BTC);
        if (salt > 0) {
            seed = seed % PRECISION * salt;
        }
        return seed;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../libraries/Random.sol";
import "../libraries/NFTLib.sol";
import "../interfaces/IDataStorage.sol";

contract DroidBot is ERC721Burnable, Ownable {
    address public minter;
    uint256 public totalSupply;
    mapping (uint256 => NFTLib.Info) public nftInfo;
    string baseURI;

    /*----------------------------CONSTRUCTOR----------------------------*/

    constructor(string memory _URI) ERC721("DroidBot NFT Token", "DBOT") {
        baseURI = _URI;
    }

    function _baseURI() internal view override returns(string memory) {
        return baseURI;
    }

    /*----------------------------EXTERNAL FUNCTIONS----------------------------*/

    function create(address _receiver, uint256 _lv, uint256 _power) external onlyMinter returns(uint256 _tokenId) {
        require(_receiver != address(0), 'DroidBotNFT: _receiver is the zero address');
        totalSupply++;
        _tokenId = totalSupply;
        _mint(_receiver, _tokenId);
        nftInfo[_tokenId] = NFTLib.Info({
            level : _lv,
            power : _power
        });
        emit DroidBotCreated(_receiver, _tokenId, _lv, _power);
    }

    function upgrade(uint256 _id, uint256 _lv, uint256 _power) external onlyMinter {
        NFTLib.Info storage _token = nftInfo[_id];
        _token.level = _lv;
        _token.power = _power;
        emit DroidBotUpgraded(_id, _lv, _power);
    }

    function info(uint256 _id) external view returns (NFTLib.Info memory) {
        return nftInfo[_id];
    }

    function power(uint256 _id) external view returns(uint256) {
        return nftInfo[_id].power;
    }

    function level(uint256 _id) external view returns(uint256) {
        return nftInfo[_id].level;
    }

    /*----------------------------RESTRICT FUNCTIONS----------------------------*/

    function changeMinter(address _newMinter) external onlyOwner {
        address _oldMinter = minter;
        minter = _newMinter;
        emit MinterChanged(_oldMinter, _newMinter);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "DroidBot: caller is not the minter");
        _;
    }

    /*----------------------------EVENTS----------------------------*/

    event DroidBotCreated(address indexed receiver, uint256 indexed id, uint256 level, uint256 power);
    event DroidBotEvolved(address indexed receiver, uint256 newDroidBotLevel, uint256 droid0Level, uint256 droid1Level, uint256 indexed newDroidBotId, uint256 newDroidBotPower);
    event DroidBotUpgraded(uint256 indexed tokenId, uint256 newLv, uint256 newPower);
    event MinterChanged(address indexed oldMinter, address indexed newMinter);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../libraries/TransferHelper.sol";
import "../interfaces/ISwapRouter02.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IWBNB.sol";

contract PandoArbitrage is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    ISwapRouter02 public swapRouter;
    uint256 constant PRECISION = 1000;
    mapping (address => bool) public operators;

    event Arbitrage(uint256 amountIn, uint256 amountOut, address[] path);
    event Withdraw(address indexed token, uint256 amount, address to);
    event OperatorChanged(address indexed operator, bool status);
    event swapRouterChanged(address indexed oldRouter, address indexed newRouter);
    constructor(address _swapRouter) public {
        swapRouter = ISwapRouter02(_swapRouter);
    }

    modifier onlyOperators() {
        require(operators[msg.sender] == true, "Arbitrage: caller is not the operators");
        _;
    }

    function arbitrage(uint256 usdtAmountIn, address[] memory path, uint256 slippage, uint256  gasInUsd, uint256 expectedRevenuePercent) public onlyOperators  {
        _approveTokenIfNeeded(path[0]);
        uint256[] memory usdtAmountOut = swapRouter.swapExactTokensForTokens(usdtAmountIn, usdtAmountIn*(PRECISION - slippage)/PRECISION, path, address(this), block.timestamp);
        uint256 invest = usdtAmountIn + gasInUsd;
        require(usdtAmountOut[usdtAmountOut.length - 1] > invest, "Arbitrage: Amount out is lesser than invest!");
            uint256 revenuePercent = ((usdtAmountOut[usdtAmountOut.length - 1] - invest) * PRECISION )/ invest;
            require(revenuePercent >= expectedRevenuePercent, "Arbitrage: Captial loss!");
            emit Arbitrage(usdtAmountIn, usdtAmountOut[usdtAmountOut.length - 1], path);
    }

    function withdraw(address token, address _to) external onlyOwner {
        if (token == address(0)) {
            TransferHelper.safeTransferETH(_to, address(this).balance);
            emit Withdraw(token, address(this).balance, _to);
            return;
        }

        uint256 _balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(_to, _balance);
        emit Withdraw(token, _balance, _to);
    }

    function setSwapRouter(ISwapRouter02 _swapRouter) external onlyOwner {
        address oldRouter = address(swapRouter);
        swapRouter = _swapRouter;
        emit swapRouterChanged(oldRouter, address(_swapRouter));
    }

    function setOperator(address _operator, bool _status) external onlyOwner {
        operators[_operator] = _status;
        emit OperatorChanged(_operator, _status);
    }

    function _approveTokenIfNeeded(address token) private {
        if (IERC20(token).allowance(address(this), address(swapRouter)) == 0) {
            IERC20(token).safeApprove(address(swapRouter), type(uint256).max);
        }
    }

}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {

    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function universalTransfer(
        address token,
        address payable to,
        uint256 amount
    ) internal {
        if (amount > 0) {
            if (isETH(token)) {
                to.transfer(amount);
            } else {
                safeTransfer(token, to, amount);
            }
        }
    }

    function universalApproveMax(
        address token,
        address to,
        uint256 amount
    ) internal {
        uint256 allowance = IERC20(token).allowance(address(this), to);
        if (allowance < amount) {
            if (allowance > 0) {
                safeApprove(token, to, 0);
            }
            safeApprove(token, to, type(uint256).max);
        }
    }

    function universalBalanceOf(address token, address who) internal view returns (uint256) {
        if (isETH(token)) {
            return who.balance;
        } else {
            return IERC20(token).balanceOf(who);
        }
    }

    function tokenBalanceOf(address token, address who) internal view returns (uint256) {
        return IERC20(token).balanceOf(who);
    }

    function isETH(address token) internal pure returns (bool) {
        return token == ETH_ADDRESS;
    }

    function getETH() internal pure returns (address) {
        return ETH_ADDRESS;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2Factory.sol";

contract MarketFeeCollector is Ownable {
    address public operator;
    using SafeERC20 for IERC20;

    mapping (address => address) public bridges;

    IUniswapV2Factory public factory;
    IERC20 public busd;

    address public pandoPool;
    address public pandoPot;
    address public operatingFund;

    uint256 public rPool = 5000;
    uint256 public rPot = 2000;
    uint256 public rFund = 3000;
    uint256 public constant ONE_HUNDRED_PERCENT = 10000;

    constructor (address _factory, address _busd, address _pandoPool, address _pandoPot, address _operatingFund) {
        factory = IUniswapV2Factory(_factory);
        busd = IERC20(_busd);
        pandoPool = _pandoPool;
        pandoPot = _pandoPot;
        operatingFund = _operatingFund;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, 'Referral: caller is not operator');
        _;
    }

    function convert(address _token) public {
        address bridge = bridges[_token];
        uint256 amount = IERC20(_token).balanceOf(address(this));
        if (bridge != address(0)) {
            uint256 _amount = _swap(_token, bridge, amount);
            _swap(bridge, address(busd), _amount);
        } else {
            _swap(_token, address(busd), amount);
        }
    }

    function convertMultiple(
        address[] calldata token
    ) external {
        uint256 len = token.length;
        for (uint256 i = 0; i < len; i++) {
            convert(token[i]);
        }
    }

    function distribute() external onlyOperator {
        uint256 amount = busd.balanceOf(address(this));
        if (amount > 0) {
            busd.safeTransfer(pandoPool, amount * rPool / ONE_HUNDRED_PERCENT);
            busd.safeTransfer(pandoPot, amount * rPot / ONE_HUNDRED_PERCENT);
            busd.safeTransfer(operatingFund, amount * rFund / ONE_HUNDRED_PERCENT);
        }
    }

    function _swap(
        address fromToken,
        address toToken,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {
        // Checks
        // X1 - X5: OK
        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(fromToken, toToken));
        require(address(pair) != address(0), "Treasury: Cannot convert");

        // Interactions
        // X1 - X5: OK
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        uint256 amountInWithFee = amountIn * 997;
        if (fromToken == pair.token0()) {
            amountOut = (amountInWithFee * reserve1) /
            (reserve0 * 1000 + amountInWithFee);
            IERC20(fromToken).safeTransfer(address(pair), amountIn);
            pair.swap(0, amountOut, address(this), new bytes(0));
            // TODO: Add maximum slippage?
        } else {
            amountOut = (amountInWithFee * reserve0) /
            (reserve1 * 1000 + amountInWithFee);
            IERC20(fromToken).safeTransfer(address(pair), amountIn);
            pair.swap(amountOut, 0, address(this), new bytes(0));
            // TODO: Add maximum slippage?
        }
    }

    function setOperator(address _newOperator) external onlyOwner {
        address oldOperator = operator;
        operator = _newOperator;
        emit OperatorChanged(oldOperator, _newOperator);
    }

    function setBridge(address token, address bridge) external onlyOwner {
        // Checks
        require(
            token != address(busd) && token != bridge && bridge != address(busd),
            "MarketFeeCollector: Invalid bridge"
        );

        // Effects
        bridges[token] = bridge;
        emit BridgeChanged(token, bridge);
    }

    function changeTarget(address _pandoPool, address _pandoPot, address _operatingFund, uint256 _rPool, uint256 _rPot, uint256 _rFund) external onlyOwner {
        address oldPandoPool = pandoPool;
        address oldPandoPot = pandoPot;
        address oldOperatingFund = operatingFund;
        uint256 oldRPool = rPool;
        uint256 oldRPot = rPot;
        uint256 oldRFund = rFund;
        pandoPool = _pandoPool;
        pandoPot = _pandoPot;
        operatingFund = _operatingFund;
        rPool = _rPool;
        rPot = _rPot;
        rFund = _rFund;
        emit PandoPoolChanged(oldPandoPool, _pandoPool);
        emit PandoPotChanged(oldPandoPot, _pandoPot);
        emit OperatingFundChanged(oldOperatingFund, _operatingFund);
        emit RPoolChanged(oldRPool, _rPool);
        emit RPotChanged(oldRPot, _rPot);
        emit RFundChanged(oldRFund, _rFund);
    }

    event OperatorChanged(address indexed oldOperator, address indexed newOperator);
    event BridgeChanged(address indexed token, address indexed bridge);
    event PandoPoolChanged(address indexed oldPandoPool, address indexed newPandoPool);
    event PandoPotChanged(address indexed oldPandoPot, address indexed newPandoPot);
    event OperatingFundChanged(address indexed oldOperatingFund, address indexed newOperatingFund);
    event RPoolChanged(uint256 oldRPool, uint256 newRPool);
    event RPotChanged(uint256 oldRPot, uint256 newRPot);
    event RFundChanged(uint256 oldRFund, uint256 newRFund);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.8.4;
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function migrator() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setMigrator(address) external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


contract TimeLockV2 is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant WALLET_ROLE = keccak256("WALLET_ROLE");
    uint256 internal constant _DONE_TIMESTAMP = uint256(1);

    mapping(bytes32 => uint256) private confirmations;
    mapping(bytes32 => uint256) private _timestamps;
    mapping(bytes32 => mapping(address => bool)) private isConfirmed;
    mapping(bytes32 => bool) private isCanceled;
    mapping(bytes32 => address) private proposers;

    uint256 public required;
    uint256 public minDelay;
    uint256 public nAdmins;

    constructor(address _admin, uint256 _minDelay) {
        _setupRole(PROPOSER_ROLE, _admin);
        _setupRole(EXECUTOR_ROLE, _admin);
        _setupRole(ADMIN_ROLE, _admin);
        _setupRole(WALLET_ROLE, address(this));
        required = 1;
        nAdmins = 1;
        minDelay = _minDelay;
    }

    /* ========== MODIFIERS ========== */
    modifier onlyRoleOrOpenRole(bytes32 role) {
        if (!hasRole(role, address(0))) {
            _checkRole(role, _msgSender());
        }
        _;
    }

    /* ========== PUBLIC FUNCTIONS ========== */
    /**
       * @dev Returns whether an id correspond to a registered operation. This
     * includes both Pending, Ready and Done operations.
     */
    function isOperation(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > 0;
    }

    /**
     * @dev Returns whether an operation is pending or not.
     */
    function isOperationPending(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > _DONE_TIMESTAMP;
    }

    /**
     * @dev Returns whether an operation is ready or not.
     */
    function isOperationReady(bytes32 id) public view virtual returns (bool ready) {
        uint256 timestamp = getTimestamp(id);
        return timestamp > _DONE_TIMESTAMP && timestamp <= block.timestamp;
    }

    /**
     * @dev Returns whether an operation is done or not.
     */
    function isOperationDone(bytes32 id) public view virtual returns (bool done) {
        return getTimestamp(id) == _DONE_TIMESTAMP;
    }

    function getConfirmation(bytes32 _id) public view returns(uint256 _confirmation) {
        return confirmations[_id];
    }

    function isConfirm(bytes32 _id, address _acc) public view returns(bool) {
        return isConfirmed[_id][_acc];
    }

    function getMinDelay() public view virtual returns (uint256 duration) {
        return minDelay;
    }

    function getTimestamp(bytes32 id) public view virtual returns (uint256 timestamp) {
        return _timestamps[id];
    }

    function getProposer(bytes32 id) public view returns(address proposer) {
        return proposers[id];
    }

    function getStatus(bytes32 id) public view returns(bool status) {
        return isCanceled[id];
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function _schedule(bytes32 _id, uint256 _delay) internal {
        require(!isOperation(_id), "Timelock: operation already scheduled");
        require(_delay >= getMinDelay(), "TimelockController: insufficient delay");
        _timestamps[_id] = block.timestamp + _delay;
    }

    function _call(
        bytes32 _id,
        uint256 _index,
        address _target,
        uint256 _value,
        bytes calldata _data
    ) private {
        (bool _success, ) = _target.call{value: _value}(_data);
        require(_success, "Timelock: underlying transaction reverted");
        emit CallExecuted(_id, _index, _target, _value, _data);
    }

    function _hashOperation(
        address _target,
        uint256 _value,
        bytes calldata _data,
        bytes32 _predecessor,
        bytes32 _salt
    ) public pure virtual returns (bytes32 _hash) {
        return keccak256(abi.encode(_target, _value, _data, _predecessor, _salt));
    }

    function _beforeCall(bytes32 _id, bytes32 _predecessor) private view {
        require(isOperationReady(_id), "Timelock: operation is not ready");
        require(_predecessor == bytes32(0) || isOperationDone(_predecessor), "TimelockController: missing dependency");
    }


    function _afterCall(bytes32 _id) private {
        require(isOperationReady(_id), "Timelock: operation is not ready");
        _timestamps[_id] = _DONE_TIMESTAMP;
    }

    function _vote(
        bytes32 _id
    ) internal {
        confirmations[_id]++;
        isConfirmed[_id][msg.sender] = true;
    }

    function _execute(
        bytes32 _id,
        address _target,
        uint256 _value,
        bytes calldata _data,
        bytes32 _predecessor
    ) internal {
        _beforeCall(_id, _predecessor);
        _call(_id, 0, _target, _value, _data);
        _afterCall(_id);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function schedule(
        address _target,
        uint256 _value,
        bytes calldata _data,
        bytes32 _predecessor,
        bytes32 _salt,
        uint256 _delay
    ) external onlyRole(PROPOSER_ROLE) {
        bytes32 _id = _hashOperation(_target, _value, _data, _predecessor, _salt);
        require(confirmations[_id] == 0, "Timelock: operation already scheduled");
        _vote(_id);
        _schedule(_id, _delay);
        proposers[_id] = msg.sender;
        isCanceled[_id] = false;
        emit Scheduled(_id, _target, _value, _data, _predecessor, _salt, _delay);
    }

    function vote(
        address _target,
        uint256 _value,
        bytes calldata _data,
        bytes32 _predecessor,
        bytes32 _salt)
    external onlyRole(ADMIN_ROLE){
        bytes32 _id = _hashOperation(_target, _value, _data, _predecessor, _salt);
        require(!isConfirm(_id, msg.sender), "Timelock: admin already voted");
        require(!isCanceled[_id], "Timelock: proposer already canceled");
        _vote(_id);
        emit Voted(_id, _target, _value, _data);
    }

    function execute(
        address _target,
        uint256 _value,
        bytes calldata _data,
        bytes32 _predecessor,
        bytes32 _salt
    ) external payable onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        bytes32 _id = _hashOperation(_target, _value, _data, _predecessor, _salt);
        require(!isCanceled[_id], "Timelock: proposer already canceled");
        if (confirmations[_id] >= required) {
            _beforeCall(_id, _predecessor);
            _call(_id, 0, _target, _value, _data);
            _afterCall(_id);
        }
    }

    function revoke(
        address _target,
        uint256 _value,
        bytes calldata _data,
        bytes32 _predecessor,
        bytes32 _salt
    ) external onlyRole(ADMIN_ROLE) {
        bytes32 _id = _hashOperation(_target, _value, _data, _predecessor, _salt);
        require(isConfirm(_id, msg.sender), "Timelock: admin haven't voted yet");
        require(!isCanceled[_id], "Timelock: proposer already canceled");
        isConfirmed[_id][msg.sender] = false;
        confirmations[_id]--;
        emit Revoked(_id, _target, _value, _data);
    }

    function cancel(
        address _target,
        uint256 _value,
        bytes calldata _data,
        bytes32 _predecessor,
        bytes32 _salt
    ) external onlyRole(PROPOSER_ROLE) {
        bytes32 _id = _hashOperation(_target, _value, _data, _predecessor, _salt);
        require(msg.sender == proposers[_id], "Timelock: !proposer");
        require(!isCanceled[_id], "Timelock: proposer already canceled");
        isCanceled[_id] = true;
        emit Cancel(_id, true);
    }

    function changeRequired(uint256 _newValue) external onlyRole(WALLET_ROLE) {
        require(_newValue > 0, "Timelock: required = 0");
        require(_newValue <= nAdmins, "Timelock: > nAdmins");
        uint256 oldValue = required;
        required = _newValue;
        emit RequiredChanged(oldValue, _newValue);
    }

    function changeMinDelay(uint256 _newDelay) external onlyRole(WALLET_ROLE){
        require(_newDelay > 0, "Timelock: minDelay = 0");
        uint256 oldValue = minDelay;
        minDelay = _newDelay;
        emit MinDelayChanged(oldValue, _newDelay);
    }

    function grantRole(bytes32 _role, address _account) public override onlyRole(WALLET_ROLE) {
        require(_role != WALLET_ROLE, "Cant add Wallet role");
        if (_role == ADMIN_ROLE && !hasRole(_role, _account)) {
            nAdmins++;
        }
        _grantRole(_role, _account);
    }

    function revokeRole(bytes32 _role, address _account) public override onlyRole(WALLET_ROLE) {
        require(_role != WALLET_ROLE, "Cant revoke wallet role");
        if (_role == ADMIN_ROLE && hasRole(_role, _account)) {
            nAdmins--;
        }
        _revokeRole(_role, _account);
    }
    /* ========== EVENTS ========== */
    event Voted(bytes32 indexed id, address target, uint256 value, bytes data);
    event Scheduled(bytes32 indexed id, address target, uint256 value, bytes data, bytes32 predecessor, bytes32 salt, uint256 delay);
    event Revoked(bytes32 indexed id, address target, uint256 value, bytes data);
    event RequiredChanged(uint256 oldRequired, uint256 newRequired);
    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);
    event MinDelayChanged(uint256 oldMinDelay, uint256 newMinDelay);
    event Cancel(bytes32 indexed id, bool status);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (governance/TimelockController.sol)

pragma solidity ^0.8.0;

import "../access/AccessControl.sol";

/**
 * @dev Contract module which acts as a timelocked controller. When set as the
 * owner of an `Ownable` smart contract, it enforces a timelock on all
 * `onlyOwner` maintenance operations. This gives time for users of the
 * controlled contract to exit before a potentially dangerous maintenance
 * operation is applied.
 *
 * By default, this contract is self administered, meaning administration tasks
 * have to go through the timelock process. The proposer (resp executor) role
 * is in charge of proposing (resp executing) operations. A common use case is
 * to position this {TimelockController} as the owner of a smart contract, with
 * a multisig or a DAO as the sole proposer.
 *
 * _Available since v3.3._
 */
contract TimelockController is AccessControl {
    bytes32 public constant TIMELOCK_ADMIN_ROLE = keccak256("TIMELOCK_ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    uint256 internal constant _DONE_TIMESTAMP = uint256(1);

    mapping(bytes32 => uint256) private _timestamps;
    uint256 private _minDelay;

    /**
     * @dev Emitted when a call is scheduled as part of operation `id`.
     */
    event CallScheduled(
        bytes32 indexed id,
        uint256 indexed index,
        address target,
        uint256 value,
        bytes data,
        bytes32 predecessor,
        uint256 delay
    );

    /**
     * @dev Emitted when a call is performed as part of operation `id`.
     */
    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);

    /**
     * @dev Emitted when operation `id` is cancelled.
     */
    event Cancelled(bytes32 indexed id);

    /**
     * @dev Emitted when the minimum delay for future operations is modified.
     */
    event MinDelayChange(uint256 oldDuration, uint256 newDuration);

    /**
     * @dev Initializes the contract with a given `minDelay`.
     */
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors
    ) {
        _setRoleAdmin(TIMELOCK_ADMIN_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(EXECUTOR_ROLE, TIMELOCK_ADMIN_ROLE);

        // deployer + self administration
        _setupRole(TIMELOCK_ADMIN_ROLE, _msgSender());
        _setupRole(TIMELOCK_ADMIN_ROLE, address(this));

        // register proposers
        for (uint256 i = 0; i < proposers.length; ++i) {
            _setupRole(PROPOSER_ROLE, proposers[i]);
        }

        // register executors
        for (uint256 i = 0; i < executors.length; ++i) {
            _setupRole(EXECUTOR_ROLE, executors[i]);
        }

        _minDelay = minDelay;
        emit MinDelayChange(0, minDelay);
    }

    /**
     * @dev Modifier to make a function callable only by a certain role. In
     * addition to checking the sender's role, `address(0)` 's role is also
     * considered. Granting a role to `address(0)` is equivalent to enabling
     * this role for everyone.
     */
    modifier onlyRoleOrOpenRole(bytes32 role) {
        if (!hasRole(role, address(0))) {
            _checkRole(role, _msgSender());
        }
        _;
    }

    /**
     * @dev Contract might receive/hold ETH as part of the maintenance process.
     */
    receive() external payable {}

    /**
     * @dev Returns whether an id correspond to a registered operation. This
     * includes both Pending, Ready and Done operations.
     */
    function isOperation(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > 0;
    }

    /**
     * @dev Returns whether an operation is pending or not.
     */
    function isOperationPending(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > _DONE_TIMESTAMP;
    }

    /**
     * @dev Returns whether an operation is ready or not.
     */
    function isOperationReady(bytes32 id) public view virtual returns (bool ready) {
        uint256 timestamp = getTimestamp(id);
        return timestamp > _DONE_TIMESTAMP && timestamp <= block.timestamp;
    }

    /**
     * @dev Returns whether an operation is done or not.
     */
    function isOperationDone(bytes32 id) public view virtual returns (bool done) {
        return getTimestamp(id) == _DONE_TIMESTAMP;
    }

    /**
     * @dev Returns the timestamp at with an operation becomes ready (0 for
     * unset operations, 1 for done operations).
     */
    function getTimestamp(bytes32 id) public view virtual returns (uint256 timestamp) {
        return _timestamps[id];
    }

    /**
     * @dev Returns the minimum delay for an operation to become valid.
     *
     * This value can be changed by executing an operation that calls `updateDelay`.
     */
    function getMinDelay() public view virtual returns (uint256 duration) {
        return _minDelay;
    }

    /**
     * @dev Returns the identifier of an operation containing a single
     * transaction.
     */
    function hashOperation(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    /**
     * @dev Returns the identifier of an operation containing a batch of
     * transactions.
     */
    function hashOperationBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(targets, values, datas, predecessor, salt));
    }

    /**
     * @dev Schedule an operation containing a single transaction.
     *
     * Emits a {CallScheduled} event.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function schedule(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _schedule(id, delay);
        emit CallScheduled(id, 0, target, value, data, predecessor, delay);
    }

    /**
     * @dev Schedule an operation containing a batch of transactions.
     *
     * Emits one {CallScheduled} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function scheduleBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _schedule(id, delay);
        for (uint256 i = 0; i < targets.length; ++i) {
            emit CallScheduled(id, i, targets[i], values[i], datas[i], predecessor, delay);
        }
    }

    /**
     * @dev Schedule an operation that is to becomes valid after a given delay.
     */
    function _schedule(bytes32 id, uint256 delay) private {
        require(!isOperation(id), "TimelockController: operation already scheduled");
        require(delay >= getMinDelay(), "TimelockController: insufficient delay");
        _timestamps[id] = block.timestamp + delay;
    }

    /**
     * @dev Cancel an operation.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function cancel(bytes32 id) public virtual onlyRole(PROPOSER_ROLE) {
        require(isOperationPending(id), "TimelockController: operation cannot be cancelled");
        delete _timestamps[id];

        emit Cancelled(id);
    }

    /**
     * @dev Execute an (ready) operation containing a single transaction.
     *
     * Emits a {CallExecuted} event.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _beforeCall(id, predecessor);
        _call(id, 0, target, value, data);
        _afterCall(id);
    }

    /**
     * @dev Execute an (ready) operation containing a batch of transactions.
     *
     * Emits one {CallExecuted} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _beforeCall(id, predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            _call(id, i, targets[i], values[i], datas[i]);
        }
        _afterCall(id);
    }

    /**
     * @dev Checks before execution of an operation's calls.
     */
    function _beforeCall(bytes32 id, bytes32 predecessor) private view {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        require(predecessor == bytes32(0) || isOperationDone(predecessor), "TimelockController: missing dependency");
    }

    /**
     * @dev Checks after execution of an operation's calls.
     */
    function _afterCall(bytes32 id) private {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        _timestamps[id] = _DONE_TIMESTAMP;
    }

    /**
     * @dev Execute an operation's call.
     *
     * Emits a {CallExecuted} event.
     */
    function _call(
        bytes32 id,
        uint256 index,
        address target,
        uint256 value,
        bytes calldata data
    ) private {
        (bool success, ) = target.call{value: value}(data);
        require(success, "TimelockController: underlying transaction reverted");

        emit CallExecuted(id, index, target, value, data);
    }

    /**
     * @dev Changes the minimum timelock duration for future operations.
     *
     * Emits a {MinDelayChange} event.
     *
     * Requirements:
     *
     * - the caller must be the timelock itself. This can only be achieved by scheduling and later executing
     * an operation where the timelock is the target and the data is the ABI-encoded call to this function.
     */
    function updateDelay(uint256 newDelay) external virtual {
        require(msg.sender == address(this), "TimelockController: caller must be timelock");
        emit MinDelayChange(_minDelay, newDelay);
        _minDelay = newDelay;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
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
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
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

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "../interfaces/IUserLevel.sol";
import "../interfaces/ILaunchpadFactory.sol";



contract INOProject is Initializable, ERC721Holder {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using ECDSA for bytes;

    // type => nft contract
    mapping(uint256 => address) public typeAddress;

    // type => nft id
    mapping(uint256 => EnumerableSet.UintSet) typeNFTId;

    // type => supply
    mapping(uint256 => uint256) public totalSupply;

    // type => price
    mapping(uint256 => uint256) public prices;

    // type => total sold
    mapping(uint256 => uint256) public totalSold;

    // user => type => count
    mapping(address => mapping(uint256 => uint256)) public balances;

    // allocations for type
    mapping(uint256 => uint256) public allocations;

    // address user => type => nft ids
    mapping(address => mapping(uint => EnumerableSet.UintSet)) nftTypes;

    // total type
    uint256 public totalTypes;

    // operator
    address public operator;

    // router
    uint public projectId;

    //user level
    address public userLevel;

    //currency
    IERC20 public currency;

    //time
    uint256 public startTime;
    uint256 public endTime;
    uint256 public registerTime;

    //total token
    uint256 public totalReceive;
    bool public settingProject = false;

    //admin
    address public admin;
    address public operatorFund;
    address public launchpadFactory;

    EnumerableSet.AddressSet register;

    //level milestone
    uint[] public milestones;

    mapping(uint => uint) public bonusMilestones;

    //=================== MODIFIERS ===================//

    modifier onlyOperator() {
        require(msg.sender == operator,"InitialNFTOffering: Only operator");
        _;
    }

    modifier onlyOperatorFund() {
        require(msg.sender == operatorFund, "!Operator");
        _;
    }

    modifier checkTypeId(uint id) {
        require(id > 0 && id <= totalTypes, "InitialNFTOffering: not support type");
        _;
    }

    modifier onSale() {
        require(startTime < block.timestamp && block.timestamp < endTime, "InitialNFTOffering: not on sale");
        _;
    }

    modifier afterSale() {
        require(block.timestamp > endTime, "InitialNFTOffering: not on after sale");
        _;
    }

    modifier checkSigner(bytes memory _signature, uint _userLevel) {
        bytes32 _hash = keccak256(abi.encodePacked(projectId, msg.sender, address(this), _userLevel)).toEthSignedMessageHash();
        require(_hash.recover(_signature) == admin, "InitialNFTOffering: !verify");
        _;
    }

    modifier allowBuy() {
        require(register.contains(msg.sender), "InitialNFTOffering: user not register");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "InitialNFTOffering: not in time");
        _;
    }

    //=================== EVENTS ===================//
    event ProjectCreated(uint indexed projectId, address indexed contractAddress);
    event BuySuccess(address indexed user, uint256 indexed typeId, uint256 indexed amount);
    event Setting(
        uint indexed projectId,
        bool indexed update,
        uint registerTime,
        uint startTime,
        uint endTime,
        address admin,
        address currency,
        uint totalTypes,
        uint256[] milestones,
        uint256[] bonus
    );
    event RegisterINO(address indexed user, uint indexed projectId, uint indexed userLevel);
    event ChangeOperatorFund(address _new, address _old);

    //=================== EXTERNAL FUNCTIONS ===================//
    function registerINO(bytes memory _signature, uint _userLevel) external checkSigner(_signature, _userLevel) {
        require(block.timestamp >= registerTime && block.timestamp <= startTime, "InitialNFTOffering: can not register now");
        register.add(msg.sender);
        emit RegisterINO(msg.sender, projectId, _userLevel);
    }


    function depositNFT(uint _typeId, uint[] memory _ids) external checkTypeId(_typeId){
        require(settingProject, "InitialNFTOffering: project not setting");
        IERC721 tokenAddress = IERC721(typeAddress[_typeId]);
        for(uint i = 0; i < _ids.length; i++) {
            tokenAddress.safeTransferFrom(msg.sender, address(this), _ids[i]);
            typeNFTId[_typeId].add(_ids[i]);
        }
    }

    function buy(uint _typeId, uint _amount) public checkTypeId(_typeId) allowBuy {
        require( typeNFTId[_typeId].length() >= _amount, "InitialNFTOffering: not enough");
        require( balances[msg.sender][_typeId] + _amount <= getAllocations(_typeId, msg.sender), "InitialNFTOffering: user reach limited");
        require( totalSold[_typeId] + _amount <= totalSupply[_typeId], "InitialNFTOffering: supply reach limited");
        require(_amount > 0, "InitialNFTOffering: _amount zero");
        //receive token
        uint _totalReceive = _amount * prices[_typeId];
        currency.safeTransferFrom(msg.sender, address(this), _totalReceive);

        // update state
        totalReceive += _totalReceive;
        totalSold[_typeId] += _amount;
        balances[msg.sender][_typeId] += _amount;

        // transfer nft
        for(uint i = 0; i < _amount; i++) {
            _safeBuy(_typeId);
        }

        emit BuySuccess(msg.sender, _typeId, _amount);
    }

    //=================== INTERNAL FUNCTIONS ===================//
    function _safeBuy(uint _typeId) internal {
        //get address of nft
        IERC721 _nft = IERC721(typeAddress[_typeId]);

        //get id of nft
        uint length = typeNFTId[_typeId].length();
        uint id = typeNFTId[_typeId].at(length - 1);

        //remove id
        typeNFTId[_typeId].remove(id);

        // store id for user
        nftTypes[msg.sender][_typeId].add(id);

        //transfer
        _nft.safeTransferFrom(address(this), msg.sender, id);
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function getAllocations(uint _typeId, address _user) internal view returns(uint) {
        uint currentAllocation = allocations[_typeId];
        if(userLevel != address(0)) {
            uint level = IUserLevel(userLevel).getUserLevel(_user);
            currentAllocation += getBonusLevel(level);
        }
        return currentAllocation;
    }

    function getBonusLevel(uint level) internal view returns(uint) {
        for(uint i = 0; i < milestones.length; i++) {
            if(level <= milestones[i]) {
                return bonusMilestones[milestones[i]];
            }
        }
        return 0;
    }

    // ====================== RESTRICTED FUNCTIONS ======================== //
    function initialize(uint _projectId, address _operator, address _userLevel, address _launchpad) public initializer returns (bool) {
        require(_operator != address(0), "!zero");
        projectId = _projectId;
        operator = _operator;
        userLevel = _userLevel;
        launchpadFactory = _launchpad;
        emit ProjectCreated(projectId, address(this));
        return true;
    }

    function setUserLevel(address _userLevel) external onlyOperator {
        require(_userLevel != address(0), "InitialNFTOffering: !zero");
        userLevel = _userLevel;
    }

    //setting project
    function setting(
        uint _types,
        uint[] memory _supplies,
        uint[] memory _allocations,
        address[] memory _tokens,
        uint[] memory _prices,
        IERC20 _currency,
        uint256[] memory _times,
        uint256[] memory _milestones,
        uint256[] memory _bonus,
        address _admin,
        bool _update
    ) external onlyOperator returns(bool){
        require(!settingProject || _update, "Project setting first time");
        require(address(_currency) != address (0),"InitialNFTOffering: !zero");
        require(_admin != address (0),"InitialNFTOffering: !zero");
        require(_supplies.length == _types, "InitialNFTOffering: length not equal supply");
        require(_allocations.length == _types, "InitialNFTOffering: length not equal _allocations");
        require(_tokens.length == _types, "InitialNFTOffering: length not equal _tokens");
        require(_times.length == 3 && _times[1] > block.timestamp && _times[1] < _times[2], "InitialNFTOffering: time buying incorrect");
        require( _times[1] > _times[0] && _times[0] >= block.timestamp, "InitialNFTOffering: time register incorrect");
        require(_milestones.length + 1 == _bonus.length, "InitialNFTOffering: length not equal");
        if(_update) {
            require(block.timestamp < startTime, "InitialNFTOffering: Can not setting after starting");
            delete milestones;
        }

        for(uint i = 1; i <= _types; i++) {
            typeAddress[i] = _tokens[i-1];
            totalSupply[i] = _supplies[i-1];
            allocations[i] = _allocations[i-1];
            prices[i] = _prices[i-1];
        }
        currency = _currency;
        totalTypes = _types;
        admin = _admin;

        // store bonus level
        for(uint i = 0; i < _milestones.length; i++) {
            if(i > 0) {
                require(_milestones[i] > _milestones[i-1], "InitialNFTOffering: milestone level incorrect");
            }
            milestones.push(_milestones[i]);
            bonusMilestones[_milestones[i]] = _bonus[i];
        }
        milestones.push(~uint(0));
        bonusMilestones[~uint(0)] = _bonus[_bonus.length - 1];

        if(!_update) {
            registerTime = _times[0];
            startTime = _times[1];
            endTime = _times[2];
            settingProject = true;
        }

        emit Setting(projectId, _update, registerTime, startTime, endTime, admin, address(currency), totalTypes, _milestones, _bonus);
        return true;
    }

    //withdraw admin
    function withdrawAdmin() external onlyOperator afterSale {
        require(operatorFund != address(0), "operator fund is zero");
        currency.safeTransfer(operatorFund, currency.balanceOf(address(this)));
    }

    function setOperatorFund(address _new) external {
        require(msg.sender == ILaunchpadFactory(launchpadFactory).owner(), "Only master owner set it");
        require(_new != address(0), "!zero");
        address _old = operatorFund;
        operatorFund = _new;
        emit ChangeOperatorFund(_new, _old);
    }

    function withdrawNFT(uint _typeId) external onlyOperator afterSale checkTypeId(_typeId) {
        uint length = typeNFTId[_typeId].length();
        require(operatorFund != address(0), "operator fund is zero");
        IERC721 nft = IERC721(typeAddress[_typeId]);
        for(uint i = length; i > 0;) {
            --i;
            uint _id = typeNFTId[_typeId].at(i);
            nft.safeTransferFrom(address(this), operatorFund, _id);
            typeNFTId[_typeId].remove(_id);
        }
    }

    function changeTime(uint _registerTime, uint _startTime, uint _endTime) external onlyOperator {
        registerTime = _registerTime;
        startTime = _startTime;
        endTime = _endTime;
    }

    function emergencyWithdraw(address token) external onlyOperator {
        require(operatorFund != address(0), "operator fund is zero");
        IERC20(token).safeTransfer(operatorFund, IERC20(token).balanceOf(address(this)));
    }

    // ====================== VIEW FUNCTIONS ======================== //

    function getAllocationForUser(uint _typeId, address _user) external view returns(uint _maxAllocation, uint _quantity, uint _availableNFT) {
        _maxAllocation = getAllocations(_typeId, _user);
        _quantity = _min(typeNFTId[_typeId].length(), _min(_maxAllocation - balances[_user][_typeId], totalSupply[_typeId] - totalSold[_typeId]));
        _availableNFT = typeNFTId[_typeId].length();
    }

    function verifySignature(bytes memory _signature, address _sampleAddress, uint _userLevel) external view returns (bool) {
        bytes32 _hash = keccak256(abi.encodePacked(projectId, _sampleAddress, address(this), _userLevel)).toEthSignedMessageHash();
        return _hash.recover(_signature) == admin;
    }

    function getRegister(uint256 _page, uint256 _limit) external view returns (address[] memory, uint _length) {
        uint _from = _page * _limit;
        _length = register.length();
        uint _to = _min((_page + 1) * _limit, register.length());
        address[] memory _result = new address[](_to - _from);
        for (uint i = 0; _from < _to; i++) {
            _result[i] = register.at(_from);
            ++_from;
        }
        return (_result, _length);
    }

    function isRegister(address _user) external view returns(bool) {
        return register.contains(_user);
    }

    function getMilestones() external view returns (uint[] memory) {
        return milestones;
    }

    function getNFTDeposit(uint _id) external view returns (uint[] memory) {
        return typeNFTId[_id].values();
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILaunchpadFactory {
    function owner() external view returns(address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/utils/Create2.sol";
import  "./INOProject.sol";

contract INOProjectFactory {
    function createINO(
        uint _projectId,
        address _operator,
        address _userLevel,
        address _launchpad
    ) external returns(address) {
        address _projectAddress = _calculateAddress(_projectId, _operator);
        _initialize(_projectId, _operator, _userLevel, _projectAddress, _launchpad);
        return _projectAddress;

    }

    function _calculateAddress(uint _projectId, address _operator) internal returns(address) {
        bytes memory bytecode = type(INOProject).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_projectId, _operator, block.timestamp));
        address _projectAddress = Create2.deploy(0, salt, bytecode);
        return _projectAddress;
    }

    function _initialize(
        uint _projectId,
        address _operator,
        address _userLevel,
        address _projectAddress,
        address _launchpad
    ) internal {
        bool check = INOProject(_projectAddress).initialize(_projectId, _operator, _userLevel, _launchpad);
        require(check, "deploy failed");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IDOProjectFactory.sol";
import "./INOProjectFactory.sol";

contract LaunchpadFactory is Ownable {

    mapping(uint => address) public projects;
    mapping(uint => address) public nftProjects;
    mapping(address => bool) public operators;
    IDOProjectFactory public idoFactory;
    INOProjectFactory public inoFactory;

    modifier onlyOperator() {
        require(operators[msg.sender], "LaunchpadFactory: only operator");
        _;
    }
    event IDOProjectCreated(uint indexed projectId, address indexed contractAddress);
    event INOProjectCreated(uint indexed projectId, address indexed contractAddress);
    event ChangeOperator(address indexed _newOperator, bool indexed _status);

    constructor() {
        operators[msg.sender] = true;
    }

    function setFactory(IDOProjectFactory _idoFactory, INOProjectFactory _inoFactory) external onlyOwner {
        require(address(_idoFactory) != address(0), "LaunchpadFactory: input zero _idoFactory");
        require(address(_inoFactory) != address(0), "LaunchpadFactory: input zero _inoFactory");
        idoFactory = _idoFactory;
        inoFactory = _inoFactory;
    }

    function setOperator(address _newOperator, bool _status) external onlyOwner {
        require(_newOperator != address(0), "LaunchpadFactory: input zero");
        operators[_newOperator] = _status;
        emit ChangeOperator(_newOperator, _status);
    }

    function createIDO(uint _projectId, address _operator, address _userLevel) external onlyOperator {
        require(_operator != address(0), "LaunchpadFactory: !zero");
        require(projects[_projectId] == address(0), "LaunchpadFactory: Duplicate project id");
        address _projectAddress = idoFactory.createProject(_projectId, _operator, _userLevel, address(this));
        projects[_projectId] = _projectAddress;
        emit IDOProjectCreated(_projectId, _projectAddress);
    }

    function createINO(
        uint _projectId,
        address _userLevel,
        address _operator
    ) external onlyOperator {
        require(_operator != address(0), "LaunchpadFactory: !zero");
        require(nftProjects[_projectId] == address(0), "LaunchpadFactory: Already deployed nftproject with id");
        address inoAddress = inoFactory.createINO(_projectId, _operator, _userLevel, address(this));
        nftProjects[_projectId] = inoAddress;
        emit INOProjectCreated(_projectId, inoAddress);
    }

    receive() external payable {
        revert("Nothing send to here");
    }
}

// SPDX-License-Identifier: pro

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";
import  "./IDOProject.sol";

contract IDOProjectFactory {

    function createProject(uint _projectId, address _operator, address _userLevel, address _launchpad) external returns(address) {
        bytes memory bytecode = type(IDOProject).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_projectId, _operator));
        address _projectAddress = Create2.deploy(0, salt, bytecode);
        bool check = IDOProject(_projectAddress).initialize(_projectId, _operator, _userLevel, _launchpad);
        require(check, "deploy failed");
        return _projectAddress;
    }
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../interfaces/IUserLevel.sol";
import "../interfaces/ILaunchpadFactory.sol";

interface Decimal {
    function decimals() external view returns(uint8);
}


contract IDOProject is ReentrancyGuard, Initializable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using ECDSA for bytes;


    struct Cliff {
        uint timeStamp;
        uint percentage;
    }

    struct ClaimInfo {
        uint8 lastClaim;
        uint totalToken;
        uint totalTokenClaimed;
        bool finish;
    }

    //constant
    uint public constant ONE_HUNDRED_PERCENT = 10000;

    // address verify
    address public admin;

    //setting
    uint public projectId;
    uint public registerStartTime;
    uint public calculationTime;
    uint public fcfsStartTime;
    uint public rate; // multiple with decimals token
    uint public totalSlot;
    uint public totalWhiteList;

    //vesting
    Cliff[] public vestingInfo;

    //info
    IERC20 public currency;
    IERC20 public tokenSale;
    uint public tokenSaleDecimal;

    // storage
    mapping(address => ClaimInfo) public claimInfo; // user address => ClaimInfo data
    mapping(address => uint) public commit;  // user address => committed amount

    //list user
    EnumerableSet.AddressSet users;
    EnumerableSet.AddressSet winners;
    EnumerableSet.AddressSet whiteList;
    EnumerableSet.AddressSet whiteListSubmitted;
    EnumerableSet.AddressSet fcfsSubmitted;
    // allocation
    uint public maxAllocation;
    uint public fcfsAllocation;

    // total tokens for fcfs
    uint public fcfsSupply;
    // totol tokens fcfs bought
    uint public fcfsBought;
    mapping(address => uint) public userAllocation;

    //control
    bool public poolEnd = false;
    bool public settingProject = false;

    //operator
    address public operator;
    address public operatorFund;
    address public launchpadFactory;

    //user level
    address public userLevel;

    //total token currency receiver
    uint public totalReceive;
    uint totalWithdraw;



    //=================== MODIFIERS ===================//
    modifier onlyOperator() {
        require(msg.sender == operator, "!Operator");
        _;
    }

    modifier onlyOperatorFund() {
        require(msg.sender == operatorFund, "!Operator");
        _;
    }

    modifier onPoolSale() {
        require(block.timestamp >= registerStartTime && block.timestamp <= calculationTime, "Not time on pool sale");
        _;
    }

    modifier afterSale() {
        require(block.timestamp > calculationTime, "before sale end");
        require(!poolEnd, "pool not end");
        _;
    }

    modifier checkSigner(bytes memory _signature, uint256 _slot, uint _userLevel) {
        require(_slot > 0, "_slot minimum is 1");
        bytes32 _hash = keccak256(abi.encodePacked(projectId, msg.sender, address(this), _slot, _userLevel)).toEthSignedMessageHash();
        require(_hash.recover(_signature) == admin, "Verify signature failed");
        _;
    }

    modifier isWithdrawable() {
        bool check = block.timestamp > calculationTime && poolEnd && !winners.contains(msg.sender);
        require(check, "Not time for withdraw");
        _;
    }

    modifier isClaimable() {
        bool check = block.timestamp > calculationTime && poolEnd && (winners.contains(msg.sender) || whiteListSubmitted.contains(msg.sender) || fcfsSubmitted.contains(msg.sender));
        require(check, "Not time for claim");
        _;
    }

    modifier isWithdrawableAdmin() {
        bool check = block.timestamp > calculationTime;
        require(check, "Not time for admin withdraw");
        _;
    }

    modifier isFCFS() {
        require(poolEnd, "All pool did not finish yet");
        require(block.timestamp < vestingInfo[0].timeStamp, "FCFS has finished");
        require(block.timestamp >= fcfsStartTime, "FCFS did not start");
        _;
    }

    //=================== EVENTS ===================
    event Setting(
        uint indexed projectId,
        bool indexed update,
        uint _registerStartTime,
        uint _calculationTime,
        uint _rate,
        address _currency,
        address _tokenSale,
        address _admin,
        uint _allocation,
        uint[]  timestamps,
        uint[]  percentages,
        uint _totalSlot,
        uint _whiteList,
        uint _fcfsStartTime
    );
    event ProjectCreated(uint indexed projectId, address indexed contractAddress);
    event Register(address indexed user, uint indexed projectId, uint indexed allocation, uint slot, uint userLevel, uint pool);
    event Withdraw(address indexed user, uint indexed amount, uint indexed projectId);
    event Claim(address indexed user,uint indexed projectId, uint indexed amount);
    event WinnerMember(address indexed user, uint indexed projectId, uint indexed pool, uint amount);
    event PoolEnd(bool indexed _slot, uint indexed projectId);
    event CreateRandom(uint indexed number, uint indexed projectId);
    event SettingFCFS(uint indexed startTime, uint indexed allocation, uint indexed projectId);
    event BuyFCFS(address indexed user, uint indexed amount, uint indexed projectId);
    event AddWhiteList(address[] indexed addresses, uint indexed projectId);
    event RemoveWhiteList(address indexed user, uint indexed projectId);
    event ChangeCalculationTime(uint indexed projectId, uint indexed newTime);
    event ChangeRegisterTime(uint indexed projectId, uint indexed newTime);
    event ChangeDistribution(uint indexed projectId, uint[]  timestamps, uint[] percentages);
    event ChangeOperatorFund(address _new, address _old);


    // initialize
    function initialize(uint _projectId, address _operator, address _userLevel, address _launchpadFactory) public initializer returns (bool) {
        require(_operator != address(0), "!zero");
        projectId = _projectId;
        operator = _operator;
        userLevel = _userLevel;
        launchpadFactory = _launchpadFactory;
        emit ProjectCreated(projectId, address(this));
        return true;
    }

    //=================== EXTERNAL FUNCTIONS ===================== //
    function registerProject(bytes memory _signature, uint256 _slot, uint _userLevel, uint _pool) external onPoolSale checkSigner(_signature, _slot, _userLevel) {
        require(_pool == 1 || _pool == 2, "_pool not support");
        // white list
        if(_pool == 1) {
            require(whiteList.contains(msg.sender), "User not in white list");
            currency.safeTransferFrom(msg.sender, address(this), maxAllocation);
            _execute(msg.sender, maxAllocation, _pool);
        }
        // other
        if( _pool == 2) {
            require(!users.contains(msg.sender), "User already register");
            currency.safeTransferFrom(msg.sender, address(this), maxAllocation * _slot);
            commit[msg.sender] = maxAllocation * _slot;
            users.add(msg.sender);
        }
        emit Register(msg.sender, projectId, maxAllocation * _slot, _slot, _userLevel, _pool);
    }

    function withdraw() external isWithdrawable nonReentrant {
        uint _amount = 0;
        _amount = commit[msg.sender];
        commit[msg.sender] = 0;
        currency.safeTransfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount, projectId);
    }

    function claim() external isClaimable nonReentrant {
        uint _amount = 0;
        ClaimInfo storage _user = claimInfo[msg.sender];
        (,bool _finish,bool _claimable,uint _totalClaim,uint8 _lastClaim) = getClaimInfo(_user.totalToken, _user.lastClaim);
        require(_claimable, "!Claimable");
        _amount = _totalClaim;
        if (_finish) {
            _user.finish = _finish;
            _amount = _user.totalToken - _user.totalTokenClaimed;
        }
        _user.lastClaim = _lastClaim;
        _user.totalTokenClaimed += _amount;
        require(_user.totalTokenClaimed <= _user.totalToken, "Overflow claimable");
        tokenSale.safeTransfer(msg.sender, _amount);
        emit Claim(msg.sender, projectId, _amount);
    }

    function buyFCFS(uint _amount) external isFCFS {
        uint _allocation = fcfsAllocation > 0 ? fcfsAllocation : maxAllocation;
        userAllocation[msg.sender] += _amount;
        require(userAllocation[msg.sender] <= _allocation, "amount > allocation");
        currency.safeTransferFrom(msg.sender, address(this), _amount);

        // token bought
        fcfsBought += _amount;
        require(fcfsBought <= fcfsSupply, "Not enough token for sale");
        _execute(msg.sender, _amount, 3);
        emit BuyFCFS(msg.sender, _amount, projectId);
    }

    //=================== INTERNAL FUNCTIONS ======================//
    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function _execute(address _user, uint _allocation, uint _pool) internal {
        // set claim info
        ClaimInfo storage _data = claimInfo[_user];
        _data.totalToken += _allocation * 10 ** tokenSaleDecimal / rate;

        // change state
        totalReceive += _allocation;

        bool check;
        // add to winner
        if(_pool == 1) {
            check = whiteListSubmitted.add(_user);
        } else if(_pool == 2){
            check = winners.add(_user);
            commit[_user] = 0;
        } else if(_pool == 3) {
            fcfsSubmitted.add(_user);
            check = true;
        }
        require(check, "User already added");
        emit WinnerMember(_user, projectId, _pool, _allocation);
    }

    function _setCliffInfo(uint[] memory _timestamps, uint[] memory _percentages, bool _deleted) internal {
        require(_timestamps.length == _percentages.length, "length must be equal");
        uint256 sum;
        if(_deleted) {
            delete vestingInfo;
        }
        for (uint256 i = 0; i < _timestamps.length; i ++) {
            require(_percentages[i] <= ONE_HUNDRED_PERCENT, "percentage over 100 %");
            if(i < _timestamps.length - 1) {
                require(_timestamps[i] < _timestamps[i+1], "time distribute is out of order");
            }
            Cliff memory _cliffInfo;
            _cliffInfo.percentage = _percentages[i];
            _cliffInfo.timeStamp = _timestamps[i];
            vestingInfo.push(_cliffInfo);
            sum += _percentages[i];
        }
        require(sum == ONE_HUNDRED_PERCENT, "total percentage is not 100%");
    }

    //=============== VIEWS FUNCTIONS ==================//
    function getClaimInfo(uint256 _totalToken, uint8 _claimTimes) public view returns (uint amountClaim, bool finish, bool claimable, uint totalClaim, uint8 lastCliff) {
        lastCliff = _claimTimes;
        uint totalPercentage = 0;
        finish = false;
        amountClaim = 0;
        totalClaim = 0;
        for (uint i = _claimTimes; i < vestingInfo.length; i++) {
            if (vestingInfo[i].timeStamp <= block.timestamp) {
                totalPercentage += vestingInfo[i].percentage;
                lastCliff += 1;
            }
        }
        amountClaim = vestingInfo[_claimTimes].percentage * _totalToken / ONE_HUNDRED_PERCENT;
        totalClaim = _totalToken * totalPercentage / ONE_HUNDRED_PERCENT;
        claimable = totalPercentage > 0;
        if (lastCliff == vestingInfo.length) {
            finish = true;
        }
    }

    function getCliffInfo(uint256 _index) public view returns (uint256 _percentage, uint256 _timestamp) {
        if (_index < vestingInfo.length) {
            Cliff memory _cliffInfo = vestingInfo[_index];
            _percentage = _cliffInfo.percentage;
            _timestamp = _cliffInfo.timeStamp;
        }
    }


    function getUsers(uint256 _page, uint256 _limit) external view returns (address[] memory, uint _length) {
        uint _from = _page * _limit;
        _length = users.length();
        uint _to = _min((_page + 1) * _limit, users.length());
        address[] memory _result = new address[](_to - _from);
        for (uint i = 0; _from < _to; i++) {
            _result[i] = users.at(_from);
            ++_from;
        }
        return (_result, _length);
    }


    function getWinners(uint256 _page, uint256 _limit) external view returns (address[] memory, uint _length) {
        uint _from = _page * _limit;
        _length = winners.length();
        uint _to = _min((_page + 1) * _limit, winners.length());
        address[] memory _result = new address[](_to - _from);
        for (uint i = 0; _from < _to; i++) {
            _result[i] = winners.at(_from);
            ++_from;
        }
        return (_result, _length);
    }

    function getWinnersWhitelist(uint256 _page, uint256 _limit) external view returns (address[] memory, uint _length) {
        uint _from = _page * _limit;
        _length = whiteListSubmitted.length();
        uint _to = _min((_page + 1) * _limit, whiteListSubmitted.length());
        address[] memory _result = new address[](_to - _from);
        for (uint i = 0; _from < _to; i++) {
            _result[i] = whiteListSubmitted.at(_from);
            ++_from;
        }
        return (_result, _length);
    }

    function getFCFSUser(uint256 _page, uint256 _limit) external view returns (address[] memory, uint _length) {
        uint _from = _page * _limit;
        _length = fcfsSubmitted.length();
        uint _to = _min((_page + 1) * _limit, fcfsSubmitted.length());
        address[] memory _result = new address[](_to - _from);
        for (uint i = 0; _from < _to; i++) {
            _result[i] = fcfsSubmitted.at(_from);
            ++_from;
        }
        return (_result, _length);
    }

    function checkUserInPool(address _user) external view returns (bool isRegistered, bool isWinner, bool isWhiteList, bool isWhiteListSubmitted) {
        return (users.contains(_user), winners.contains(_user), whiteList.contains(_user), whiteListSubmitted.contains(_user));
    }

    function fcfsStatus(address _user) external view returns(uint _availableAllocation, bool _status, uint _availableFCFS){
        uint _allocation = fcfsAllocation > 0 ? fcfsAllocation : maxAllocation;
        _availableAllocation = _allocation - userAllocation[_user];
        _status = fcfsSubmitted.contains(_user);
        _availableFCFS = fcfsSupply - fcfsBought;
    }

    function getProgress() external view returns (uint _numerator, uint _denominator) {
        _numerator = 0;
        _denominator = 1;
        if (rate > 0) {
            _numerator = ((winners.length() + whiteListSubmitted.length())* maxAllocation + fcfsBought);
            _denominator = (totalSlot + totalWhiteList)* maxAllocation; //total token receive
        }
    }

    function verifySignature(bytes memory _signature, address _sampleAddress, uint _slot, uint _userLevel) external view returns (bool) {
        bytes32 _hash = keccak256(abi.encodePacked(projectId, _sampleAddress, address(this), _slot, _userLevel)).toEthSignedMessageHash();
        return _hash.recover(_signature) == admin;
    }

    function estimateTransfer() external view returns(uint) {
        return totalReceive * 10 ** Decimal(address(tokenSale)).decimals() / rate;
    }

    function totalCliff() external view returns(uint) {
        return vestingInfo.length;
    }

    function isWhiteList(address _user) external view returns(bool) {
        return whiteList.contains(_user);
    }

    function getWhiteList() external view returns(address[] memory) {
        return whiteList.values();
    }

    // ====================== RESTRICTED FUNCTIONS ======================== //
    function changeTime(uint _registerTime, uint _calculationTime) external onlyOperator {
        require( registerStartTime > block.timestamp &&  _calculationTime > _registerTime, "Time setting not in correct");
        registerStartTime = _registerTime;
        calculationTime = _calculationTime;
        emit ChangeCalculationTime(projectId, calculationTime);
        emit ChangeRegisterTime(projectId, registerStartTime);
    }

    function changeCalculationTime(uint _calculationTime) external onlyOperator {
        require(_calculationTime > registerStartTime, "Time setting not in correct");
        require(_calculationTime < fcfsStartTime, "Time setting not in correct");
        calculationTime = _calculationTime;
        emit ChangeCalculationTime(projectId, calculationTime);
    }

    function updateVestingInfo(uint[] memory timestamps, uint[] memory percentages) external onlyOperator {
        require(block.timestamp < vestingInfo[0].timeStamp, "Invalid time");
        require(timestamps[0] > fcfsStartTime, "Distribute time incorrect");
        _setCliffInfo(timestamps, percentages, true);
        emit ChangeDistribution(projectId, timestamps, percentages);
    }

    function changeRegisterTime(uint _registerTime) external onlyOperator {
        require(registerStartTime > block.timestamp, "registerStartTime in past");
        require(_registerTime > block.timestamp, "_registerTime in past");
        require(_registerTime < calculationTime, "_registerTime over calculation time");
        registerStartTime = _registerTime;
        emit ChangeRegisterTime(projectId, registerStartTime);
    }

    function settingFCFS(uint _value, uint _start) external onlyOperator {
        require(_value > 0, "!zero");
        require(_start > calculationTime, "fcfs start time must be greater than calculation time");
        require(_start < vestingInfo[0].timeStamp, "fcfs over start time");
        fcfsAllocation = _value;
        fcfsStartTime = _start;
        emit SettingFCFS(fcfsStartTime, fcfsAllocation, projectId);
    }

    function emergencyWithdraw(address token) external onlyOperator {
        require(operatorFund != address(0), "operator fund is zero");
        require(block.timestamp > vestingInfo[0].timeStamp , "Can not withdraw after user vesting");
        IERC20(token).safeTransfer(operatorFund, IERC20(token).balanceOf(address(this)));
    }

    function withdrawAdmin() external onlyOperator isWithdrawableAdmin() nonReentrant {
        uint currentWithdraw = totalReceive - totalWithdraw;
        require(currentWithdraw > 0, "No token to withdraw");
        require(operatorFund != address(0), "operator fund is zero");
        currency.safeTransfer(operatorFund, currentWithdraw);
        totalWithdraw += currentWithdraw;
        emit Withdraw(msg.sender, currentWithdraw, projectId);
    }

    function setting(
        uint[] memory _dataUint,
        IERC20[] memory _dataErc20,
        uint[] memory _timestamps,
        uint[] memory _percentages,
        address _admin,
        bool _update
    ) external onlyOperator {
        require(!settingProject || _update, "Project first time setting");
        require(_dataUint.length == 7, "Not enough");
        require(_dataUint[0] > block.timestamp, "_registerStartTime in pass");
        require(_dataUint[0] < _dataUint[1], "_registerStartTime < _calculationTime");
        require(_dataUint[1] < _dataUint[6], "_calculationTime > _fcfsTime");
        require(_dataUint[2] > 0, "Rate can not zero");
        require(_dataUint[3] > 0, "allocation can not zero");

        if(_update) {
            require(block.timestamp < registerStartTime, "Can not update after start");
        }

        require(address(_dataErc20[0]) != address(0), "!zero address");
        require(address(_dataErc20[1]) != address(0), "!zero address");
        require(address(_admin) != address(0), "!zero address");

        rate = _dataUint[2];
        maxAllocation = _dataUint[3];

        if(!_update) {
            registerStartTime = _dataUint[0];
            calculationTime = _dataUint[1];
            fcfsStartTime = _dataUint[6];
        }

        currency = _dataErc20[0];
        tokenSale = _dataErc20[1];
        tokenSaleDecimal = Decimal(address(tokenSale)).decimals();
        admin = _admin;
        totalSlot = _dataUint[4]; // total slot
        totalWhiteList = _dataUint[5]; // total allow list
        _setCliffInfo(_timestamps, _percentages, _update);
        settingProject = true;
        emit Setting(projectId, _update, registerStartTime, calculationTime, rate, address(currency), address(tokenSale), admin, maxAllocation, _timestamps, _percentages, totalSlot, totalWhiteList, fcfsStartTime);
    }

    function setPoolEnd() external onlyOperator {
        require(block.timestamp > calculationTime && !poolEnd, "Before calculation time");
        poolEnd = true;
        fcfsSupply = (totalSlot - winners.length() + totalWhiteList - whiteListSubmitted.length()) * maxAllocation;
        emit PoolEnd(poolEnd, projectId);
    }

    function addWhiteList(address[] memory _users) external onlyOperator {
        require(_users.length > 0, "_users empty");
        require(_users.length + whiteList.length() <= totalWhiteList, "white list full");
        require( block.timestamp < registerStartTime, "Must be added white list before start");
        for(uint i = 0; i < _users.length; i++) {
            whiteList.add(_users[i]);
        }
        emit AddWhiteList(_users, projectId);
    }

    function submitWinners(address[] memory _users) external onlyOperator {
        require(block.timestamp > calculationTime, "Before calculation time");
        require(!poolEnd, "!poolEnd");
        require(winners.length() + _users.length  <= totalSlot, "Slot over flow");
        for(uint i = 0; i < _users.length; i++ ){
            address _user = _users[i];
            require(users.contains(_user), "User not register");
            uint _allocation = commit[_user];
            _execute(_user, _allocation, 2);
        }
        if(winners.length() == totalSlot) {
            poolEnd = true;
            fcfsSupply = (totalSlot - winners.length() + totalWhiteList - whiteListSubmitted.length()) * maxAllocation;
            emit PoolEnd(poolEnd, projectId);
        }
    }

    function setOperator(address _newOperator) external onlyOperator {
        require(_newOperator != address(0), "!zero");
        operator = _newOperator;
    }

    function removeWhiteList(address _user) external onlyOperator {
        require(block.timestamp < registerStartTime, "Must be added white list before start");
        whiteList.remove(_user);
        emit RemoveWhiteList(_user, projectId);
    }

    //fund
    function setOperatorFund(address _new) external {
        require(msg.sender == ILaunchpadFactory(launchpadFactory).owner(), "Only master owner set it");
        require(_new != address(0), "!zero");
        address _old = operatorFund;
        operatorFund = _new;
        emit ChangeOperatorFund(_new, _old);
    }

}

pragma solidity 0.8.4;
import "../libraries/Permitable.sol";
import "../libraries/EthReceiver.sol";
import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IWETH.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

contract UnoswapV3Router is EthReceiver, Permitable, IUniswapV3SwapCallback {
    using Address for address payable;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 private constant _ONE_FOR_ZERO_MASK = 1 << 255;
    uint256 private constant _WETH_WRAP_MASK = 1 << 254;
    uint256 private constant _WETH_UNWRAP_MASK = 1 << 253;
    bytes32 private constant _POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;
    bytes32 private constant _FF_FACTORY = 0xff1F98431c8aD98523631AE4a59f267346ea31F9840000000000000000000000;
    bytes32 private constant _SELECTORS = 0x0dfe1681d21220a7ddca3f430000000000000000000000000000000000000000;
    uint256 private constant _ADDRESS_MASK =   0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    uint160 private constant _MIN_SQRT_RATIO = 4295128739 + 1;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    uint160 private constant _MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342 - 1;
    IWETH private immutable _WETH;  // solhint-disable-line var-name-mixedcase

    constructor(address weth) {
        _WETH = IWETH(weth);
    }

    /// @notice Same as `uniswapV3SwapTo` but calls permit first,
    /// allowing to approve token spending and make a swap in one transaction.
    /// @param recipient Address that will receive swap funds
    /// @param srcToken Source token
    /// @param amount Amount of source tokens to swap
    /// @param minReturn Minimal allowed returnAmount to make transaction commit
    /// @param pools Pools chain used for swaps. Pools src and dst tokens should match to make swap happen
    /// @param permit Should contain valid permit that can be used in `IERC20Permit.permit` calls.
    /// See tests for examples
    function uniswapV3SwapToWithPermit(
        address payable recipient,
        IERC20 srcToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools,
        bytes calldata permit
    ) external returns(uint256 returnAmount) {
        _permit(address(srcToken), permit);
        return uniswapV3SwapTo(recipient, amount, minReturn, pools);
    }

    /// @notice Same as `uniswapV3SwapTo` but uses `msg.sender` as recipient
    /// @param amount Amount of source tokens to swap
    /// @param minReturn Minimal allowed returnAmount to make transaction commit
    /// @param pools Pools chain used for swaps. Pools src and dst tokens should match to make swap happen
    function uniswapV3Swap(
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external payable returns(uint256 returnAmount) {
        return uniswapV3SwapTo(msg.sender, amount, minReturn, pools);
    }

    /// @notice Performs swap using Uniswap V3 exchange. Wraps and unwraps ETH if required.
    /// Sending non-zero `msg.value` for anything but ETH swaps is prohibited
    /// @param recipient Address that will receive swap funds
    /// @param amount Amount of source tokens to swap
    /// @param minReturn Minimal allowed returnAmount to make transaction commit
    /// @param pools Pools chain used for swaps. Pools src and dst tokens should match to make swap happen
    function uniswapV3SwapTo(
        address recipient,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) public payable returns(uint256 returnAmount) {
        uint256 len = pools.length;
        require(len > 0, "UNIV3R: empty pools");
        uint256 lastIndex = len - 1;
        returnAmount = amount;
        bool wrapWeth = pools[0] & _WETH_WRAP_MASK > 0;
        bool unwrapWeth = pools[lastIndex] & _WETH_UNWRAP_MASK > 0;
        if (wrapWeth) {
            require(msg.value == amount, "UNIV3R: wrong msg.value");
            _WETH.deposit{value: amount}();
        } else {
            require(msg.value == 0, "UNIV3R: msg.value should be 0");
        }
        if (len > 1) {
            returnAmount = _makeSwap(address(this), wrapWeth ? address(this) : msg.sender, pools[0], returnAmount);

            for (uint256 i = 1; i < lastIndex; i++) {
                returnAmount = _makeSwap(address(this), address(this), pools[i], returnAmount);
            }
            returnAmount = _makeSwap(unwrapWeth ? address(this) : recipient, address(this), pools[lastIndex], returnAmount);
        } else {
            returnAmount = _makeSwap(unwrapWeth ? address(this) : recipient, wrapWeth ? address(this) : msg.sender, pools[0], returnAmount);
        }

        require(returnAmount >= minReturn, "UNIV3R: min return");

        // if (unwrapWeth) {
        //     _WETH.withdraw(returnAmount);
        //     recipient.sendValue(returnAmount);
        // }
    }

    /// @inheritdoc IUniswapV3SwapCallback
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata /* data */
    ) external override {
        IERC20 token0;
        IERC20 token1;
        bytes32 ffFactoryAddress = _FF_FACTORY;
        bytes32 poolInitCodeHash = _POOL_INIT_CODE_HASH;
        address payer;

        assembly {  // solhint-disable-line no-inline-assembly
            function reRevert() {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }

            function revertWithReason(m, len) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x20, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(0x40, m)
                revert(0, len)
            }

            let emptyPtr := mload(0x40)
            let resultPtr := add(emptyPtr, 0x20)
            mstore(emptyPtr, _SELECTORS)

            if iszero(staticcall(gas(), caller(), emptyPtr, 0x4, resultPtr, 0x20)) {
                reRevert()
            }
            token0 := mload(resultPtr)
            if iszero(staticcall(gas(), caller(), add(emptyPtr, 0x4), 0x4, resultPtr, 0x20)) {
                reRevert()
            }
            token1 := mload(resultPtr)
            if iszero(staticcall(gas(), caller(), add(emptyPtr, 0x8), 0x4, resultPtr, 0x20)) {
                reRevert()
            }
            let fee := mload(resultPtr)

            let p := emptyPtr
            mstore(p, ffFactoryAddress)
            p := add(p, 21)
            // Compute the inner hash in-place
            mstore(p, token0)
            mstore(add(p, 32), token1)
            mstore(add(p, 64), fee)
            mstore(p, keccak256(p, 96))
            p := add(p, 32)
            mstore(p, poolInitCodeHash)
            let pool := and(keccak256(emptyPtr, 85), _ADDRESS_MASK)

            if iszero(eq(pool, caller())) {
                revertWithReason(0x00000010554e495633523a2062616420706f6f6c000000000000000000000000, 0x54)  // UNIV3R: bad pool
            }

            calldatacopy(emptyPtr, 0x84, 0x20)
            payer := mload(emptyPtr)
        }

        if (amount0Delta > 0) {
            if (payer == address(this)) {
                token0.safeTransfer(msg.sender, uint256(amount0Delta));
            } else {
                token0.safeTransferFrom(payer, msg.sender, uint256(amount0Delta));
            }
        }
        if (amount1Delta > 0) {
            if (payer == address(this)) {
                token1.safeTransfer(msg.sender, uint256(amount1Delta));
            } else {
                token1.safeTransferFrom(payer, msg.sender, uint256(amount1Delta));
            }
        }
    }

    function _makeSwap(address recipient, address payer, uint256 pool, uint256 amount) private returns (uint256) {
        bool zeroForOne = pool & _ONE_FOR_ZERO_MASK == 0;
        // if (zeroForOne) {
        //     (, int256 amount1) = IUniswapV3Pool(pool).swap(
        //         recipient,
        //         zeroForOne,
        //         SafeCast.toInt256(amount),
        //         _MIN_SQRT_RATIO,
        //         abi.encode(payer)
        //     );
        //     return SafeCast.toUint256(-amount1);
        // } else {
        //     (int256 amount0,) = IUniswapV3Pool(pool).swap(
        //         recipient,
        //         zeroForOne,
        //         SafeCast.toInt256(amount),
        //         _MAX_SQRT_RATIO,
        //         abi.encode(payer)
        //     );
        //     return SafeCast.toUint256(-amount0);
        // }
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import './pool/IUniswapV3PoolImmutables.sol';
import './pool/IUniswapV3PoolState.sol';
import './pool/IUniswapV3PoolDerivedState.sol';
import './pool/IUniswapV3PoolActions.sol';
import './pool/IUniswapV3PoolOwnerActions.sol';
import './pool/IUniswapV3PoolEvents.sol';

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values
interface IUniswapV3PoolImmutables {
    /// @notice The contract that deployed the pool, which must adhere to the IUniswapV3Factory interface
    /// @return The contract address
    function factory() external view returns (address);

    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

    /// @notice The pool tick spacing
    /// @dev Ticks can only be used at multiples of this value, minimum of 1 and always positive
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    /// @return The tick spacing
    function tickSpacing() external view returns (int24);

    /// @notice The maximum amount of position liquidity that can use any tick in the range
    /// @dev This parameter is enforced per tick to prevent liquidity from overflowing a uint128 at any point, and
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    /// @return The max amount of liquidity per tick
    function maxLiquidityPerTick() external view returns (uint128);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IUniswapV3PoolState {
    /// @notice The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
    /// when accessed externally.
    /// @return sqrtPriceX96 The current price of the pool as a sqrt(token1/token0) Q64.96 value
    /// tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// observationIndex The index of the last oracle observation that was written,
    /// observationCardinality The current maximum number of observations stored in the pool,
    /// observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice The fee growth as a Q128.128 fees of token0 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice The fee growth as a Q128.128 fees of token1 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice The amounts of token0 and token1 that are owed to the protocol
    /// @dev Protocol fees will never exceed uint128 max in either token
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    /// @notice The currently in range liquidity available to the pool
    /// @dev This value has no relationship to the total liquidity across all ticks
    function liquidity() external view returns (uint128);

    /// @notice Look up information about a specific tick in the pool
    /// @param tick The tick to look up
    /// @return liquidityGross the total amount of position liquidity that uses the pool either as tick lower or
    /// tick upper,
    /// liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Returns 256 packed tick initialized boolean values. See TickBitmap for more information
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the information about a position by the position's key
    /// @param key The position's key is a hash of a preimage composed by the owner, tickLower and tickUpper
    /// @return _liquidity The amount of liquidity in the position,
    /// Returns feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// Returns feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// Returns tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// Returns tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Returns data about a specific observation index
    /// @param index The element of the observations array to fetch
    /// @dev You most likely want to use #observe() instead of this method to get an observation as of some amount of time
    /// ago, rather than at a specific index in the array.
    /// @return blockTimestamp The timestamp of the observation,
    /// Returns tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// Returns secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// Returns initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    /// @notice Returns the cumulative tick and liquidity as of each timestamp `secondsAgo` from the current block timestamp
    /// @dev To get a time weighted average tick or liquidity-in-range, you must call this with two values, one representing
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    /// @dev The time weighted average tick represents the geometric time weighted average price of the pool, in
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    /// @param secondsAgos From how long ago each cumulative tick and liquidity value should be returned
    /// @return tickCumulatives Cumulative tick values as of each `secondsAgos` from the current block timestamp
    /// @return secondsPerLiquidityCumulativeX128s Cumulative seconds per liquidity-in-range value as of each `secondsAgos` from the current block
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    /// @notice Returns a snapshot of the tick cumulative, seconds per liquidity and seconds inside a tick range
    /// @dev Snapshots must only be compared to other snapshots, taken over a period for which a position existed.
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    /// @param tickLower The lower tick of the range
    /// @param tickUpper The upper tick of the range
    /// @return tickCumulativeInside The snapshot of the tick accumulator for the range
    /// @return secondsPerLiquidityInsideX128 The snapshot of seconds per liquidity for the range
    /// @return secondsInside The snapshot of seconds per liquidity for the range
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone
interface IUniswapV3PoolActions {
    /// @notice Sets the initial price for the pool
    /// @dev Price is represented as a sqrt(amountToken1/amountToken0) Q64.96 value
    /// @param sqrtPriceX96 the initial sqrt price of the pool as a Q64.96
    function initialize(uint160 sqrtPriceX96) external;

    /// @notice Adds liquidity for the given recipient/tickLower/tickUpper position
    /// @dev The caller of this method receives a callback in the form of IUniswapV3MintCallback#uniswapV3MintCallback
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    /// @param recipient The address for which the liquidity will be created
    /// @param tickLower The lower tick of the position in which to add liquidity
    /// @param tickUpper The upper tick of the position in which to add liquidity
    /// @param amount The amount of liquidity to mint
    /// @param data Any data that should be passed through to the callback
    /// @return amount0 The amount of token0 that was paid to mint the given amount of liquidity. Matches the value in the callback
    /// @return amount1 The amount of token1 that was paid to mint the given amount of liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Collects tokens owed to a position
    /// @dev Does not recompute fees earned, which must be done either via mint or burn of any amount of liquidity.
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    /// @param recipient The address which should receive the fees collected
    /// @param tickLower The lower tick of the position for which to collect fees
    /// @param tickUpper The upper tick of the position for which to collect fees
    /// @param amount0Requested How much token0 should be withdrawn from the fees owed
    /// @param amount1Requested How much token1 should be withdrawn from the fees owed
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice Burn liquidity from the sender and account tokens owed for the liquidity to the position
    /// @dev Can be used to trigger a recalculation of fees owed to a position by calling with an amount of 0
    /// @dev Fees must be collected separately via a call to #collect
    /// @param tickLower The lower tick of the position for which to burn liquidity
    /// @param tickUpper The upper tick of the position for which to burn liquidity
    /// @param amount How much liquidity to burn
    /// @return amount0 The amount of token0 sent to the recipient
    /// @return amount1 The amount of token1 sent to the recipient
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Swap token0 for token1, or token1 for token0
    /// @dev The caller of this method receives a callback in the form of IUniswapV3SwapCallback#uniswapV3SwapCallback
    /// @param recipient The address to receive the output of the swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountSpecified The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param data Any data to be passed through to the callback
    /// @return amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @return amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice Receive token0 and/or token1 and pay it back, plus a fee, in the callback
    /// @dev The caller of this method receives a callback in the form of IUniswapV3FlashCallback#uniswapV3FlashCallback
    /// @dev Can be used to donate underlying tokens pro-rata to currently in-range liquidity providers by calling
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    /// @param recipient The address which will receive the token0 and token1 amounts
    /// @param amount0 The amount of token0 to send
    /// @param amount1 The amount of token1 to send
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    /// @notice Increase the maximum number of price and liquidity observations that this pool will store
    /// @dev This method is no-op if the pool already has an observationCardinalityNext greater than or equal to
    /// the input observationCardinalityNext.
    /// @param observationCardinalityNext The desired minimum number of observations for the pool to store
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IUniswapV3PoolOwnerActions {
    /// @notice Set the denominator of the protocol's % share of the fees
    /// @param feeProtocol0 new protocol fee for token0 of the pool
    /// @param feeProtocol1 new protocol fee for token1 of the pool
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    /// @notice Collect the protocol fee accrued to the pool
    /// @param recipient The address to which collected protocol fees should be sent
    /// @param amount0Requested The maximum amount of token0 to send, can be 0 to collect fees in only token1
    /// @param amount1Requested The maximum amount of token1 to send, can be 0 to collect fees in only token0
    /// @return amount0 The protocol fee collected in token0
    /// @return amount1 The protocol fee collected in token1
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolEvents {
    /// @notice Emitted exactly once by a pool when #initialize is first called on the pool
    /// @dev Mint/Burn/Swap cannot be emitted by the pool before Initialize
    /// @param sqrtPriceX96 The initial sqrt price of the pool, as a Q64.96
    /// @param tick The initial tick of the pool, i.e. log base 1.0001 of the starting price of the pool
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    /// @notice Emitted when liquidity is minted for a given position
    /// @param sender The address that minted the liquidity
    /// @param owner The owner of the position and recipient of any minted liquidity
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity minted to the position range
    /// @param amount0 How much token0 was required for the minted liquidity
    /// @param amount1 How much token1 was required for the minted liquidity
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when fees are collected by the owner of a position
    /// @dev Collect events may be emitted with zero amount0 and amount1 when the caller chooses not to collect fees
    /// @param owner The owner of the position for which fees are collected
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount0 The amount of token0 fees collected
    /// @param amount1 The amount of token1 fees collected
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice Emitted when a position's liquidity is removed
    /// @dev Does not withdraw any fees earned by the liquidity position, which must be withdrawn via #collect
    /// @param owner The owner of the position for which liquidity is removed
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity to remove
    /// @param amount0 The amount of token0 withdrawn
    /// @param amount1 The amount of token1 withdrawn
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted by the pool for any swaps between token0 and token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the output of the swap
    /// @param amount0 The delta of the token0 balance of the pool
    /// @param amount1 The delta of the token1 balance of the pool
    /// @param sqrtPriceX96 The sqrt(price) of the pool after the swap, as a Q64.96
    /// @param liquidity The liquidity of the pool after the swap
    /// @param tick The log base 1.0001 of price of the pool after the swap
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    /// @notice Emitted by the pool for any flashes of token0/token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the tokens from flash
    /// @param amount0 The amount of token0 that was flashed
    /// @param amount1 The amount of token1 that was flashed
    /// @param paid0 The amount of token0 paid for the flash, which can exceed the amount0 plus the fee
    /// @param paid1 The amount of token1 paid for the flash, which can exceed the amount1 plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice Emitted by the pool for increases to the number of observations that can be stored
    /// @dev observationCardinalityNext is not the observation cardinality until an observation is written at the index
    /// just before a mint/swap/burn.
    /// @param observationCardinalityNextOld The previous value of the next observation cardinality
    /// @param observationCardinalityNextNew The updated value of the next observation cardinality
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice Emitted when the protocol fee is changed by the pool
    /// @param feeProtocol0Old The previous value of the token0 protocol fee
    /// @param feeProtocol1Old The previous value of the token1 protocol fee
    /// @param feeProtocol0New The updated value of the token0 protocol fee
    /// @param feeProtocol1New The updated value of the token1 protocol fee
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    /// @notice Emitted when the collected protocol fees are withdrawn by the factory owner
    /// @param sender The address that collects the protocol fees
    /// @param recipient The address that receives the collected protocol fees
    /// @param amount0 The amount of token0 protocol fees that is withdrawn
    /// @param amount0 The amount of token1 protocol fees that is withdrawn
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}

pragma solidity 0.8.4;

import "../libraries/EthReceiver.sol";
import "../libraries/Permitable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWETH.sol";
import "../interfaces/IClipperExchangeInterface.sol";



/// @title Clipper router that allows to use `ClipperExchangeInterface` for swaps
contract ClipperRouter is EthReceiver, Permitable {
    using SafeERC20 for IERC20;

    IWETH private immutable _WETH;  // solhint-disable-line var-name-mixedcase
    IERC20 private constant _ETH = IERC20(address(0));
    bytes private constant _INCH_TAG = "1INCH";
    IClipperExchangeInterface private immutable _clipperExchange;
    address payable private immutable _clipperPool;

    constructor(
        address weth,
        IClipperExchangeInterface clipperExchange
    ) {
        _clipperExchange = clipperExchange;
        _clipperPool = clipperExchange.theExchange();
        _WETH = IWETH(weth);
    }

    /// @notice Same as `clipperSwapTo` but calls permit first,
    /// allowing to approve token spending and make a swap in one transaction.
    /// @param recipient Address that will receive swap funds
    /// @param srcToken Source token
    /// @param dstToken Destination token
    /// @param amount Amount of source tokens to swap
    /// @param minReturn Minimal allowed returnAmount to make transaction commit
    /// @param permit Should contain valid permit that can be used in `IERC20Permit.permit` calls.
    /// See tests for examples
    function clipperSwapToWithPermit(
        address payable recipient,
        IERC20 srcToken,
        IERC20 dstToken,
        uint256 amount,
        uint256 minReturn,
        bytes calldata permit
    ) external returns(uint256 returnAmount) {
        _permit(address(srcToken), permit);
        return clipperSwapTo(recipient, srcToken, dstToken, amount, minReturn);
    }

    /// @notice Same as `clipperSwapTo` but uses `msg.sender` as recipient
    /// @param srcToken Source token
    /// @param dstToken Destination token
    /// @param amount Amount of source tokens to swap
    /// @param minReturn Minimal allowed returnAmount to make transaction commit
    function clipperSwap(
        IERC20 srcToken,
        IERC20 dstToken,
        uint256 amount,
        uint256 minReturn
    ) external payable returns(uint256 returnAmount) {
        // return clipperSwapTo(msg.sender, srcToken, dstToken, amount, minReturn);
    }

    /// @notice Performs swap using Clipper exchange. Wraps and unwraps ETH if required.
    /// Sending non-zero `msg.value` for anything but ETH swaps is prohibited
    /// @param recipient Address that will receive swap funds
    /// @param srcToken Source token
    /// @param dstToken Destination token
    /// @param amount Amount of source tokens to swap
    /// @param minReturn Minimal allowed returnAmount to make transaction commit
    function clipperSwapTo(
        address payable recipient,
        IERC20 srcToken,
        IERC20 dstToken,
        uint256 amount,
        uint256 minReturn
    ) public payable returns(uint256 returnAmount) {
        bool srcETH;
        if (srcToken == _WETH) {
            require(msg.value == 0, "CL1IN: msg.value should be 0");
            _WETH.transferFrom(msg.sender, address(this), amount);
            _WETH.withdraw(amount);
            srcETH = true;
        }
        else if (srcToken == _ETH) {
            require(msg.value == amount, "CL1IN: wrong msg.value");
            srcETH = true;
        }
        else {
            require(msg.value == 0, "CL1IN: msg.value should be 0");
            srcToken.safeTransferFrom(msg.sender, _clipperPool, amount);
        }

        // if (srcETH) {
        //     _clipperPool.transfer(amount);
        //     returnAmount = _clipperExchange.sellEthForToken(dstToken, recipient, minReturn, _INCH_TAG);
        // } else if (dstToken == _WETH) {
        //     returnAmount = _clipperExchange.sellTokenForEth(srcToken, address(this), minReturn, _INCH_TAG);
        //     _WETH.deposit{ value: returnAmount }();
        //     _WETH.transfer(recipient, returnAmount);
        // } else if (dstToken == _ETH) {
        //     returnAmount = _clipperExchange.sellTokenForEth(srcToken, recipient, minReturn, _INCH_TAG);
        // } else {
        //     returnAmount = _clipperExchange.sellTokenForToken(srcToken, dstToken, recipient, minReturn, _INCH_TAG);
        // }
    }
}

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Clipper interface subset used in swaps
interface IClipperExchangeInterface {
    function sellTokenForToken(IERC20 inputToken, IERC20 outputToken, address recipient, uint256 minBuyAmount, bytes calldata auxiliaryData) external returns (uint256 boughtAmount);
    function sellEthForToken(IERC20 outputToken, address recipient, uint256 minBuyAmount, bytes calldata auxiliaryData) external payable returns (uint256 boughtAmount);
    function sellTokenForEth(IERC20 inputToken, address payable recipient, uint256 minBuyAmount, bytes calldata auxiliaryData) external returns (uint256 boughtAmount);
    function theExchange() external returns (address payable);
}

pragma solidity 0.8.4;
import "../libraries/Permitable.sol";
import "../libraries/EthReceiver.sol";


contract UnoswapRouter is EthReceiver, Permitable {
    uint256 private constant _TRANSFER_FROM_CALL_SELECTOR_32 = 0x23b872dd00000000000000000000000000000000000000000000000000000000;
    uint256 private constant _WETH_DEPOSIT_CALL_SELECTOR_32 = 0xd0e30db000000000000000000000000000000000000000000000000000000000;
    uint256 private constant _WETH_WITHDRAW_CALL_SELECTOR_32 = 0x2e1a7d4d00000000000000000000000000000000000000000000000000000000;
    uint256 private constant _ERC20_TRANSFER_CALL_SELECTOR_32 = 0xa9059cbb00000000000000000000000000000000000000000000000000000000;
    uint256 private constant _ADDRESS_MASK =   0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    uint256 private constant _REVERSE_MASK =   0x8000000000000000000000000000000000000000000000000000000000000000;
    uint256 private constant _WETH_MASK =      0x4000000000000000000000000000000000000000000000000000000000000000;
    uint256 private constant _NUMERATOR_MASK = 0x0000000000000000ffffffff0000000000000000000000000000000000000000;
    /// @dev WETH address is network-specific and needs to be changed before deployment.
    /// It can not be moved to immutable as immutables are not supported in assembly
    uint256 private constant _WETH = 0x000000000000000000000000C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 private constant _UNISWAP_PAIR_RESERVES_CALL_SELECTOR_32 = 0x0902f1ac00000000000000000000000000000000000000000000000000000000;
    uint256 private constant _UNISWAP_PAIR_SWAP_CALL_SELECTOR_32 = 0x022c0d9f00000000000000000000000000000000000000000000000000000000;
    uint256 private constant _DENOMINATOR = 1000000000;
    uint256 private constant _NUMERATOR_OFFSET = 160;

    /// @notice Same as `unoswap` but calls permit first,
    /// allowing to approve token spending and make a swap in one transaction.
    /// @param srcToken Source token
    /// @param amount Amount of source tokens to swap
    /// @param minReturn Minimal allowed returnAmount to make transaction commit
    /// @param pools Pools chain used for swaps. Pools src and dst tokens should match to make swap happen
    /// @param permit Should contain valid permit that can be used in `IERC20Permit.permit` calls.
    /// See tests for examples
    function unoswapWithPermit(
        IERC20 srcToken,
        uint256 amount,
        uint256 minReturn,
        bytes32[] calldata pools,
        bytes calldata permit
    ) external returns(uint256 returnAmount) {
        _permit(address(srcToken), permit);
        return unoswap(srcToken, amount, minReturn, pools);
    }

    /// @notice Performs swap using Uniswap exchange. Wraps and unwraps ETH if required.
    /// Sending non-zero `msg.value` for anything but ETH swaps is prohibited
    /// @param srcToken Source token
    /// @param amount Amount of source tokens to swap
    /// @param minReturn Minimal allowed returnAmount to make transaction commit
    /// @param pools Pools chain used for swaps. Pools src and dst tokens should match to make swap happen
    function unoswap(
        IERC20 srcToken,
        uint256 amount,
        uint256 minReturn,
        // solhint-disable-next-line no-unused-vars
        bytes32[] calldata pools
    ) public payable returns(uint256 returnAmount) {
        assembly {  // solhint-disable-line no-inline-assembly
            function reRevert() {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }

            function revertWithReason(m, len) {
                mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x20, 0x0000002000000000000000000000000000000000000000000000000000000000)
                mstore(0x40, m)
                revert(0, len)
            }

            function swap(emptyPtr, swapAmount, pair, reversed, numerator, dst) -> ret {
                mstore(emptyPtr, _UNISWAP_PAIR_RESERVES_CALL_SELECTOR_32)
                if iszero(staticcall(gas(), pair, emptyPtr, 0x4, emptyPtr, 0x40)) {
                    reRevert()
                }
                if iszero(eq(returndatasize(), 0x60)) {
                    revertWithReason(0x0000001472657365727665732063616c6c206661696c65640000000000000000, 0x59)  // "reserves call failed"
                }

                let reserve0 := mload(emptyPtr)
                let reserve1 := mload(add(emptyPtr, 0x20))
                if reversed {
                    let tmp := reserve0
                    reserve0 := reserve1
                    reserve1 := tmp
                }
                ret := mul(swapAmount, numerator)
                ret := div(mul(ret, reserve1), add(ret, mul(reserve0, _DENOMINATOR)))

                mstore(emptyPtr, _UNISWAP_PAIR_SWAP_CALL_SELECTOR_32)
                switch reversed
                case 0 {
                    mstore(add(emptyPtr, 0x04), 0)
                    mstore(add(emptyPtr, 0x24), ret)
                }
                default {
                    mstore(add(emptyPtr, 0x04), ret)
                    mstore(add(emptyPtr, 0x24), 0)
                }
                mstore(add(emptyPtr, 0x44), dst)
                mstore(add(emptyPtr, 0x64), 0x80)
                mstore(add(emptyPtr, 0x84), 0)
                if iszero(call(gas(), pair, 0, emptyPtr, 0xa4, 0, 0)) {
                    reRevert()
                }
            }

            let emptyPtr := mload(0x40)
            mstore(0x40, add(emptyPtr, 0xc0))

            let poolsOffset := add(calldataload(0x64), 0x4)
            let poolsEndOffset := calldataload(poolsOffset)
            poolsOffset := add(poolsOffset, 0x20)
            poolsEndOffset := add(poolsOffset, mul(0x20, poolsEndOffset))
            let rawPair := calldataload(poolsOffset)
            switch srcToken
            case 0 {
                if iszero(eq(amount, callvalue())) {
                    revertWithReason(0x00000011696e76616c6964206d73672e76616c75650000000000000000000000, 0x55)  // "invalid msg.value"
                }

                mstore(emptyPtr, _WETH_DEPOSIT_CALL_SELECTOR_32)
                if iszero(call(gas(), _WETH, amount, emptyPtr, 0x4, 0, 0)) {
                    reRevert()
                }

                mstore(emptyPtr, _ERC20_TRANSFER_CALL_SELECTOR_32)
                mstore(add(emptyPtr, 0x4), and(rawPair, _ADDRESS_MASK))
                mstore(add(emptyPtr, 0x24), amount)
                if iszero(call(gas(), _WETH, 0, emptyPtr, 0x44, 0, 0)) {
                    reRevert()
                }
            }
            default {
                if callvalue() {
                    revertWithReason(0x00000011696e76616c6964206d73672e76616c75650000000000000000000000, 0x55)  // "invalid msg.value"
                }

                mstore(emptyPtr, _TRANSFER_FROM_CALL_SELECTOR_32)
                mstore(add(emptyPtr, 0x4), caller())
                mstore(add(emptyPtr, 0x24), and(rawPair, _ADDRESS_MASK))
                mstore(add(emptyPtr, 0x44), amount)
                if iszero(call(gas(), srcToken, 0, emptyPtr, 0x64, 0, 0)) {
                    reRevert()
                }
            }

            returnAmount := amount

            for {let i := add(poolsOffset, 0x20)} lt(i, poolsEndOffset) {i := add(i, 0x20)} {
                let nextRawPair := calldataload(i)

                returnAmount := swap(
                    emptyPtr,
                    returnAmount,
                    and(rawPair, _ADDRESS_MASK),
                    and(rawPair, _REVERSE_MASK),
                    shr(_NUMERATOR_OFFSET, and(rawPair, _NUMERATOR_MASK)),
                    and(nextRawPair, _ADDRESS_MASK)
                )

                rawPair := nextRawPair
            }

            switch and(rawPair, _WETH_MASK)
            case 0 {
                returnAmount := swap(
                    emptyPtr,
                    returnAmount,
                    and(rawPair, _ADDRESS_MASK),
                    and(rawPair, _REVERSE_MASK),
                    shr(_NUMERATOR_OFFSET, and(rawPair, _NUMERATOR_MASK)),
                    caller()
                )
            }
            default {
                returnAmount := swap(
                    emptyPtr,
                    returnAmount,
                    and(rawPair, _ADDRESS_MASK),
                    and(rawPair, _REVERSE_MASK),
                    shr(_NUMERATOR_OFFSET, and(rawPair, _NUMERATOR_MASK)),
                    address()
                )

                mstore(emptyPtr, _WETH_WITHDRAW_CALL_SELECTOR_32)
                mstore(add(emptyPtr, 0x04), returnAmount)
                if iszero(call(gas(), _WETH, 0, emptyPtr, 0x24, 0, 0)) {
                    reRevert()
                }

                if iszero(call(gas(), caller(), returnAmount, 0, 0, 0, 0)) {
                    reRevert()
                }
            }

            if lt(returnAmount, minReturn) {
                revertWithReason(0x000000164d696e2072657475726e206e6f742072656163686564000000000000, 0x5a)  // "Min return not reached"
            }
        }
    }
}

pragma solidity 0.8.4;


import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../libraries/RevertReasonParser.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


library UniERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private constant _ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IERC20 private constant _ZERO_ADDRESS = IERC20(address(0));

    function isETH(IERC20 token) internal pure returns (bool) {
        return (token == _ZERO_ADDRESS || token == _ETH_ADDRESS);
    }

    function uniBalanceOf(IERC20 token, address account) internal view returns (uint256) {
        if (isETH(token)) {
            return account.balance;
        } else {
            return token.balanceOf(account);
        }
    }

    function uniTransfer(IERC20 token, address payable to, uint256 amount) internal {
        if (amount > 0) {
            if (isETH(token)) {
                to.transfer(amount);
            } else {
                token.safeTransfer(to, amount);
            }
        }
    }

    function uniApprove(IERC20 token, address to, uint256 amount) internal {
        require(!isETH(token), "Approve called on ETH");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(abi.encodeWithSelector(token.approve.selector, to, amount));

        if (!success || (returndata.length > 0 && !abi.decode(returndata, (bool)))) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, to, 0));
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, to, amount));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory result) = address(token).call(data);
        if (!success) {
            revert(RevertReasonParser.parse(result, "Low-level call failed: "));
        }

        if (result.length > 0) { // Return data is optional
            require(abi.decode(result, (bool)), "ERC20 operation did not succeed");
        }
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IUserLevel.sol";

contract StakingV2 is Ownable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 bonus;
        int256 rewardDebt;
    }

    IERC20 public reward;
    IERC20 public lpToken;
    IUserLevel public userLevel;

    // governance
    address public reserveFund;

    uint256 public accRewardPerShare;
    uint256 public lastRewardTime;
    uint256 public endRewardTime;
    uint256 public startRewardTime;

    uint256 public rewardPerSecond;
    uint256 public totalBonus;
    uint256 private constant ACC_REWARD_PRECISION = 1e12;

    mapping (address => UserInfo) public userInfo;

    /* ========== Modifiers =============== */

    modifier onlyReserveFund() {
        require(reserveFund == msg.sender || owner() == msg.sender, "Staking: caller is not the reserveFund");
        _;
    }

    constructor(IERC20 _reward, IERC20 _lpToken, uint256 _startReward) {
        reward = _reward;
        lpToken = _lpToken;
        lastRewardTime = _startReward;
        startRewardTime = _startReward;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function getBonus(uint256 _value, address account) internal view returns(uint256) {
        if (address(userLevel) != address(0)) {
            (uint256 _n, uint256 _d) = userLevel.getBonus(account, address(this));
            return _value * _n / _d;
        }
        return 0;
    }

    function _update(address account) internal {
        UserInfo storage user = userInfo[account];
        uint256 _oldBonus = user.bonus;
        uint256 _newBonus = getBonus(user.amount, account);
        if (_newBonus > _oldBonus) {
            user.rewardDebt += int256((_newBonus - _oldBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            totalBonus += _newBonus - _oldBonus;
        } else {
            user.rewardDebt -= int256((_oldBonus - _newBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            totalBonus -= _oldBonus - _newBonus;
        }
        user.bonus = _newBonus;
    }

    function totalLp() internal view returns(uint256) {
        return lpToken.balanceOf(address(this)) + totalBonus;
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    function getRewardForDuration(uint256 _from, uint256 _to) public view returns (uint256) {
        uint256 _rewardPerSecond = rewardPerSecond;
        if (_from >= _to || _from >= endRewardTime) {
            return 0;
        }
        if (_to <= startRewardTime) {
            return 0;
        }
        if (_from <= startRewardTime) {
            if (_to <= endRewardTime) {
                return (_to - startRewardTime) * _rewardPerSecond;
            }
            else {
                return (endRewardTime - startRewardTime) * _rewardPerSecond;
            }
        }
        if (_to <= endRewardTime) {
            return (_to - _from) * _rewardPerSecond;
        }
        else {
            return (endRewardTime - _from) * _rewardPerSecond;
        }
    }

    function getRewardPerSecond() public view returns (uint256) {
        return getRewardForDuration(block.timestamp, block.timestamp + 1);
    }


    /// @notice View function to see pending reward on frontend.
    /// @param _user Address of user.
    /// @return pending reward for a given user.
    function pendingReward(address _user) external view returns (uint256 pending) {
        UserInfo storage user = userInfo[_user];
        uint256 supply = totalLp();
        uint256 _accRewardPerShare = accRewardPerShare;
        if (block.timestamp > lastRewardTime && supply != 0) {
            uint256 rewardAmount = getRewardForDuration(lastRewardTime, block.timestamp);
            _accRewardPerShare += (rewardAmount * ACC_REWARD_PRECISION) / supply;
        }
        pending = uint256(int256((user.amount + user.bonus) * _accRewardPerShare / ACC_REWARD_PRECISION) - user.rewardDebt);
    }

    /// @notice Update reward variables of the given pool.
    function updatePool() public {
        if (block.timestamp > lastRewardTime) {
            uint256 supply = totalLp();
            if (supply > 0) {
                uint256 rewardAmount = getRewardForDuration(lastRewardTime, block.timestamp);
                accRewardPerShare += rewardAmount * ACC_REWARD_PRECISION / supply;
            }
            lastRewardTime = block.timestamp;
            emit LogUpdatePool(lastRewardTime, supply, accRewardPerShare);
        }
    }

    /// @notice Deposit LP tokens to MCV2 for reward allocation.
    /// @param amount LP token amount to deposit.
    /// @param to The receiver of `amount` deposit benefit.
    function deposit(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[to];

        // Effects
        user.amount += amount;
        user.rewardDebt += int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);

        lpToken.safeTransferFrom(msg.sender, address(this), amount);
        _update(msg.sender);
        emit Deposit(msg.sender, amount, to);
    }

    /// @notice Withdraw LP tokens from MCV2.
    /// @param amount LP token amount to withdraw.
    /// @param to Receiver of the LP tokens.
    function withdraw(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];

        // Effects
        user.rewardDebt -= int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);
        user.amount -= amount;

        lpToken.safeTransfer(to, amount);
        _update(msg.sender);
        emit Withdraw(msg.sender, amount, to);
    }

    /// @notice Harvest proceeds for transaction sender to `to`.
    /// @param to Receiver of rewards.
    function harvest(address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedReward = int256((user.amount + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedReward;

        // Interactions
        if (_pendingReward > 0) {
            reward.safeTransfer(to, _pendingReward);
        }
        emit Harvest(msg.sender, _pendingReward);
    }

    /// @notice Withdraw LP tokens from MCV2 and harvest proceeds for transaction sender to `to`.
    /// @param amount LP token amount to withdraw.
    /// @param to Receiver of the LP tokens and rewards.
    function withdrawAndHarvest(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedReward = int256((user.amount + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedReward - int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);
        user.amount -= amount;

        // Interactions
        if (_pendingReward > 0) {
            reward.safeTransfer(to, _pendingReward);
        }

        lpToken.safeTransfer(to, amount);
        _update(msg.sender);
        emit Withdraw(msg.sender, amount, to);
        emit Harvest(msg.sender, _pendingReward);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    /// @param to Receiver of the LP tokens.
    function emergencyWithdraw(address to) public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        // Note: transfer can fail or succeed if `amount` is zero.
        lpToken.safeTransfer(to, amount);
        emit EmergencyWithdraw(msg.sender, amount, to);
    }

    function update(address owner) public {
        updatePool();
        _update(owner);
    }

    function getUserInfo(address user) external view returns(UserInfo memory info) {
        info = userInfo[user];
    }
    /* ========== RESTRICTED FUNCTIONS ========== */

    /// @notice Sets the reward per second to be distributed. Can only be called by the owner.
    /// @param _rewardPerSecond The amount of reward to be distributed per second.
    function setRewardPerSecond(uint256 _rewardPerSecond) internal {
        updatePool();
        uint256 oldRewardPerSecond = rewardPerSecond; 
        rewardPerSecond = _rewardPerSecond;
        emit RewardPerSecondChanged(oldRewardPerSecond, _rewardPerSecond);
    }

    function allocateMoreRewards(uint256 _addedReward, uint256 _days) external onlyReserveFund {
        updatePool();
        uint256 _pendingSeconds = (endRewardTime >  block.timestamp) ? (endRewardTime - block.timestamp) : 0;
        uint256 _newPendingReward = (rewardPerSecond * _pendingSeconds) + _addedReward;
        uint256 _newPendingSeconds = _pendingSeconds + (_days * (1 days));
        uint256 _newRewardPerSecond = _newPendingReward / _newPendingSeconds;
        setRewardPerSecond(_newRewardPerSecond);
        if (_days > 0) {
            if (endRewardTime <  block.timestamp) {
                endRewardTime =  block.timestamp + (_days * (1 days));
            } else {
                endRewardTime = endRewardTime + (_days * (1 days));
            }
        }
        reward.safeTransferFrom(msg.sender, address(this), _addedReward);
    }

    function setReserveFund(address _reserveFund) external onlyReserveFund {
        reserveFund = _reserveFund;
    }

    function rescueFund(uint256 _amount) external onlyOwner {
        require(_amount > 0 && _amount <= reward.balanceOf(address(this)), "invalid amount");
        reward.safeTransfer(owner(), _amount);
        emit FundRescued(owner(), _amount);
    }

    function setUserLevelAddress(address _userLevel) external onlyOwner {
        userLevel = IUserLevel(_userLevel);
        emit UserLevelChanged(_userLevel);
    }

    /* =============== EVENTS ==================== */

    event Deposit(address indexed user, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 amount);
    event LogUpdatePool(uint256 lastRewardTime, uint256 lpSupply, uint256 accRewardPerShare);
    event RewardPerSecondChanged(uint256 oldRewardPerSecond, uint256 newRewardPerSecond);
    event FundRescued(address indexed receiver, uint256 amount);
    event UserLevelChanged(address indexed userLevel);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IUserLevel.sol";

contract PSR_TAUM is Ownable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 bonus;
        int256 rewardDebt;
    }

    IERC20 public reward;
    IERC20 public PSR;
    IUserLevel public userLevel;

    // governance
    address public reserveFund;

    uint256 public accRewardPerShare;
    uint256 public lastRewardTime;
    uint256 public endRewardTime;
    uint256 public startRewardTime;

    uint256 public rewardPerSecond;
    uint256 public totalBonus;
    uint256 private constant ACC_REWARD_PRECISION = 1e12;

    mapping (address => UserInfo) public userInfo;

    /* ========== Modifiers =============== */

    modifier onlyReserveFund() {
        require(reserveFund == msg.sender || owner() == msg.sender, "Staking: caller is not the reserveFund");
        _;
    }

    constructor(IERC20 _PSR, IERC20 _reward, uint256 _startReward) {
        reward = _reward;
        PSR = _PSR;
        lastRewardTime = _startReward;
        startRewardTime = _startReward;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function getBonus(uint256 _value, address account) internal view returns(uint256) {
        if (address(userLevel) != address(0)) {
            (uint256 _n, uint256 _d) = userLevel.getBonus(account, address(this));
            return _value * _n / _d;
        }
        return 0;
    }

    function _update(address account) internal {
        UserInfo storage user = userInfo[account];
        uint256 _oldBonus = user.bonus;
        uint256 _newBonus = getBonus(user.amount, account);
        if (_newBonus > _oldBonus) {
            user.rewardDebt += int256((_newBonus - _oldBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            totalBonus += _newBonus - _oldBonus;
        } else {
            user.rewardDebt -= int256((_oldBonus - _newBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            totalBonus -= _oldBonus - _newBonus;
        }
        user.bonus = _newBonus;
    }

    function totalLp() internal view returns(uint256) {
        return PSR.balanceOf(address(this)) + totalBonus;
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    function getRewardForDuration(uint256 _from, uint256 _to) public view returns (uint256) {
        uint256 _rewardPerSecond = rewardPerSecond;
        if (_from >= _to || _from >= endRewardTime) {
            return 0;
        }
        if (_to <= startRewardTime) {
            return 0;
        }
        if (_from <= startRewardTime) {
            if (_to <= endRewardTime) {
                return (_to - startRewardTime) * _rewardPerSecond;
            }
            else {
                return (endRewardTime - startRewardTime) * _rewardPerSecond;
            }
        }
        if (_to <= endRewardTime) {
            return (_to - _from) * _rewardPerSecond;
        }
        else {
            return (endRewardTime - _from) * _rewardPerSecond;
        }
    }

    function getRewardPerSecond() public view returns (uint256) {
        return getRewardForDuration(block.timestamp, block.timestamp + 1);
    }


    /// @notice View function to see pending reward on frontend.
    /// @param _user Address of user.
    /// @return pending reward for a given user.
    function pendingReward(address _user) external view returns (uint256 pending) {
        UserInfo storage user = userInfo[_user];
        uint256 supply = totalLp();
        uint256 _accRewardPerShare = accRewardPerShare;
        if (block.timestamp > lastRewardTime && supply != 0) {
            uint256 rewardAmount = getRewardForDuration(lastRewardTime, block.timestamp);
            _accRewardPerShare += (rewardAmount * ACC_REWARD_PRECISION) / supply;
        }
        pending = uint256(int256((user.amount + user.bonus) * _accRewardPerShare / ACC_REWARD_PRECISION) - user.rewardDebt);
    }

    /// @notice Update reward variables of the given pool.
    function updatePool() public {
        if (block.timestamp > lastRewardTime) {
            uint256 supply = totalLp();
            if (supply > 0) {
                uint256 rewardAmount = getRewardForDuration(lastRewardTime, block.timestamp);
                accRewardPerShare += rewardAmount * ACC_REWARD_PRECISION / supply;
            }
            lastRewardTime = block.timestamp;
            emit LogUpdatePool(lastRewardTime, supply, accRewardPerShare);
        }
    }

    /// @notice Deposit LP tokens to MCV2 for reward allocation.
    /// @param amount LP token amount to deposit.
    /// @param to The receiver of `amount` deposit benefit.
    function deposit(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[to];

        // Effects
        user.amount += amount;
        user.rewardDebt += int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);

        PSR.safeTransferFrom(msg.sender, address(this), amount);
        _update(msg.sender);
        emit Deposit(msg.sender, amount, to);
    }

    /// @notice Withdraw LP tokens from MCV2.
    /// @param amount LP token amount to withdraw.
    /// @param to Receiver of the LP tokens.
    function withdraw(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];

        // Effects
        user.rewardDebt -= int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);
        user.amount -= amount;

        PSR.safeTransfer(to, amount);
        _update(msg.sender);
        emit Withdraw(msg.sender, amount, to);
    }

    /// @notice Harvest proceeds for transaction sender to `to`.
    /// @param to Receiver of rewards.
    function harvest(address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedReward = int256((user.amount + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedReward;

        // Interactions
        if (_pendingReward > 0) {
            reward.safeTransfer(to, _pendingReward);
        }
        emit Harvest(msg.sender, _pendingReward);
    }

    /// @notice Withdraw LP tokens from MCV2 and harvest proceeds for transaction sender to `to`.
    /// @param amount LP token amount to withdraw.
    /// @param to Receiver of the LP tokens and rewards.
    function withdrawAndHarvest(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedReward = int256((user.amount + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedReward - int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);
        user.amount -= amount;

        // Interactions
        if (_pendingReward > 0) {
            reward.safeTransfer(to, _pendingReward);
        }

        PSR.safeTransfer(to, amount);
        _update(msg.sender);
        emit Withdraw(msg.sender, amount, to);
        emit Harvest(msg.sender, _pendingReward);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    /// @param to Receiver of the LP tokens.
    function emergencyWithdraw(address to) public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        // Note: transfer can fail or succeed if `amount` is zero.
        PSR.safeTransfer(to, amount);
        emit EmergencyWithdraw(msg.sender, amount, to);
    }

    function update(address owner) public {
        updatePool();
        _update(owner);
    }

    function getUserInfo(address user) external view returns(UserInfo memory info) {
        info = userInfo[user];
    }
    /* ========== RESTRICTED FUNCTIONS ========== */

    /// @notice Sets the reward per second to be distributed. Can only be called by the owner.
    /// @param _rewardPerSecond The amount of reward to be distributed per second.
    function setRewardPerSecond(uint256 _rewardPerSecond) internal {
        updatePool();
        uint256 oldRewardPerSecond = rewardPerSecond; 
        rewardPerSecond = _rewardPerSecond;
        emit RewardPerSecondChanged(oldRewardPerSecond, _rewardPerSecond);
    }

    function allocateMoreRewards(uint256 _addedReward, uint256 _days) external onlyReserveFund {
        updatePool();
        uint256 _pendingSeconds = (endRewardTime >  block.timestamp) ? (endRewardTime - block.timestamp) : 0;
        uint256 _newPendingReward = (rewardPerSecond * _pendingSeconds) + _addedReward;
        uint256 _newPendingSeconds = _pendingSeconds + (_days * (1 days));
        uint256 _newRewardPerSecond = _newPendingReward / _newPendingSeconds;
        setRewardPerSecond(_newRewardPerSecond);
        if (_days > 0) {
            if (endRewardTime <  block.timestamp) {
                endRewardTime =  block.timestamp + (_days * (1 days));
            } else {
                endRewardTime = endRewardTime + (_days * (1 days));
            }
        }
        reward.safeTransferFrom(msg.sender, address(this), _addedReward);
    }

    function setReserveFund(address _reserveFund) external onlyReserveFund {
        reserveFund = _reserveFund;
    }

    function rescueFund(uint256 _amount) external onlyOwner {
        require(_amount > 0 && _amount <= reward.balanceOf(address(this)), "invalid amount");
        reward.safeTransfer(owner(), _amount);
        emit FundRescued(owner(), _amount);
    }

    function setUserLevelAddress(address _userLevel) external onlyOwner {
        userLevel = IUserLevel(_userLevel);
        emit UserLevelChanged(_userLevel);
    }

    /* =============== EVENTS ==================== */

    event Deposit(address indexed user, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 amount);
    event LogUpdatePool(uint256 lastRewardTime, uint256 lpSupply, uint256 accRewardPerShare);
    event RewardPerSecondChanged(uint256 oldRewardPerSecond, uint256 newRewardPerSecond);
    event FundRescued(address indexed receiver, uint256 amount);
    event UserLevelChanged(address indexed userLevel);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


import "../interfaces/IRandomNumberGenerator.sol";
import "../interfaces/IMultiOracle.sol";


contract PandoPotV3 is Ownable, ReentrancyGuard, Pausable {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    enum PRIZE_STATUS {AVAILABLE, CLAIMED, LIQUIDATED}
    enum PRIZE_TYPE {LEADERBOARD, MEGA, MINOR, MINI}

    uint256 public maxTypes = 4;
    uint256 public totalPrizePercentage = 0;
    mapping(PRIZE_TYPE => TypePrize) public typePrize;

    struct TypePrize {
        PRIZE_TYPE types;
        uint256 sampleSpace;
        uint256 winners;
        uint256 percentage;
        string name;
    }

    // 0 : mega, 1 : minor, 2 : leaderboard
    struct PrizeInfo {
        uint256 USD;
        uint256 PSR;
        uint256 PAN;
        uint256 expire;
        uint256 nClaimed;
        uint256 totalWinner;
    }

    struct LeaderboardPrizeInfo {
        uint256 USD;
        uint256 PSR;
        uint256 PAN;
        uint256 expire;
        PRIZE_STATUS status;
    }

    struct RoundInfo {
        //type => numbers
        mapping(PRIZE_TYPE => EnumerableSet.UintSet) numbers;
        uint256 finishedAt;
        uint256 status; //0 : need Update prizeInfo
    }

    address public USD;
    address public PSR;
    address public PAN;
    address public randomNumberGenerator;
    address public multiOracle;

    uint256 public constant unlockPeriod = 2 * 365 * 1 days;
    uint256 public constant ONE_HUNDRED_PERCENT = 1000000;
    uint256 public timeBomb = 2 * 30 * 1 days;
    uint256 public prizeExpireTime = 14 * 1 days;
    uint256 public timeBombPrizePercentage = 250000;
    uint256 public roundDuration = 1 hours;

    uint256 public lastJackpot;
    uint256 public totalPSRAllocated;
    uint256 public lastUpdatePot;

    uint256 public USDForCurrentPot;
    uint256 public PSRForCurrentPot;
    uint256 public PANForCurrentPot;

    uint256 public USDForTimeBomb;
    uint256 public PSRForTimeBomb;
    uint256 public PANForTimeBomb;

    uint256 public currentRoundId;
    uint256 public currentDistributeId;

    uint256 public panBurnPercent = 0;
    uint256 public ticketPrice = 1e18;

    // round => type => number => address => quantity // ticket mapping with users
    mapping(uint256 => mapping (PRIZE_TYPE => mapping(uint256 => mapping(address => uint)))) public tickets;
    mapping(uint256 => mapping (PRIZE_TYPE => mapping(uint256 => mapping(address => bool)))) public isClaimed;

    //user
    mapping(address => bool) public isReceivedFreeTicket;
    uint256 public numFreeTicket = 1;

    // round => type => number => quantity
    mapping(uint256 => mapping(PRIZE_TYPE => mapping (uint256 => uint))) public nTickets; // number of tickets mapping with round

    // round => type => prize
    mapping(uint256 => mapping(PRIZE_TYPE => PrizeInfo)) public prizes;

    //round => address => prize
    mapping (uint256 => mapping(address => LeaderboardPrizeInfo)) public leaderboardPrize;
    mapping (uint256 => RoundInfo) roundInfo;

    mapping (address => bool) public whitelist;

    uint256 public pendingUSD;
    uint256 public pendingPAN;

    uint256[21] public discountPercentages;
//    uint256 public discountPerAmount = 1e16;

    /*----------------------------CONSTRUCTOR----------------------------*/
    constructor (address _USD, address _PSR, address _PAN, address _randomNumberGenerator, address _router, address _multiOracle, uint256 _lastUpdated) {
        USD = _USD;
        PSR = _PSR;
        PAN = _PAN;
        multiOracle = _multiOracle;
        randomNumberGenerator = _randomNumberGenerator;
        lastJackpot = _lastUpdated;
        lastUpdatePot = _lastUpdated;
        currentRoundId = 1;
        roundInfo[0].finishedAt = block.timestamp;
        roundInfo[0].status = 1;
        whitelist[_router] = true;
        _initPrize();

        for(uint i = 0; i < 21; i++) {
            if(i < 5){
                discountPercentages[i] = 0;
            }else if(i < 10){
                discountPercentages[i] = 30000;
            }else if(i <15){
                discountPercentages[i] = 70000;
            }else if(i < 20){
                discountPercentages[i] = 110000;
            }else{
                discountPercentages[i] = 150000;
            }
        }
    }

    /*----------------------------INTERNAL FUNCTIONS----------------------------*/

    function _transferToken(address _token, address _receiver, uint256 _amount) internal {
        if (_amount > 0) {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    function _generateTicket(uint256 _rand, uint256 _sample, uint256 _salt) internal view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(_rand, _salt)))% _sample;
    }

    function _updateRound(uint256 _id) internal {
        RoundInfo storage _roundInfo = roundInfo[_id];
        uint256 _expire = _roundInfo.finishedAt + prizeExpireTime;
        if (_roundInfo.status == 0) {
            _roundInfo.status = 1;
            _updateLuckyNumber(_id, _roundInfo);
            (uint256 _usd, uint256 _psr, uint256 _pan) = _updatePrize(_id, _roundInfo, _expire);
            if (_psr + _usd + _pan > 0) {
                pendingUSD += _usd;
                pendingPAN += _pan;
                PSRForCurrentPot -= _psr;
            }
            emit RoundCompleted(_id, _expire,_roundInfo.numbers[PRIZE_TYPE.MEGA].values(), _roundInfo.numbers[PRIZE_TYPE.MINOR].values(), _roundInfo.numbers[PRIZE_TYPE.MINI].values());
        }
    }

    function _updateLuckyNumber(uint256 _id, RoundInfo storage _roundInfo) internal  {
        uint256[] memory _numbers = IRandomNumberGenerator(randomNumberGenerator).getNumber(_id);
        for(uint256 i = 1; i < maxTypes; i++) {
            {
                uint256 _winners = typePrize[PRIZE_TYPE(i)].winners;
                _calculateNumbers(_numbers[0], _numbers[1], _numbers[2], PRIZE_TYPE(i), _winners, _roundInfo.numbers[PRIZE_TYPE(i)]);
            }
        }
    }

    function _updatePrize(uint256 _id, RoundInfo storage _roundInfo, uint256 _expire) internal returns(uint, uint, uint) {
        uint256 _totalUSD = 0;
        uint256 _totalPSR = 0;
        uint256 _totalPAN = 0;

        uint256 _usd;
        uint256 _psr;
        uint256 _pan;
        for(uint256 i = 1; i < maxTypes; i++) {
            {
                (_usd, _psr, _pan)= _calcPrize(_id, _roundInfo.numbers[PRIZE_TYPE(i)].values(), _expire, PRIZE_TYPE(i));
                _totalUSD += _usd;
                _totalPSR += _psr;
                _totalPAN += _pan;
            }
        }
        return (_totalUSD, _totalPSR, _totalPAN);
    }

    function _calculateNumbers(uint256 _number1, uint256 _number2, uint256 _number3, PRIZE_TYPE _type, uint256 _quantity, EnumerableSet.UintSet storage _set) internal {
        uint256 _seed = (block.timestamp + block.number + uint256(_type) + _quantity ) % 256;
        uint256 _rand = uint256(keccak256(abi.encodePacked(_number1 >> _seed, _number2, _number3 >> (256 - _seed ), _type, _quantity)));

        uint256 _value;
        for(uint256 i = 0; i < _quantity; i++) {
            _value = uint256(keccak256(abi.encodePacked(_rand, i))) % typePrize[_type].sampleSpace;
            while(!_set.add(_value)){
                _value += 1;
            }
        }
    }

    function _countWinners(uint256 _roundId, uint256[] memory _numbers, PRIZE_TYPE _type) internal view returns (uint) {
        uint256 _count = 0;
        for(uint256 i = 0; i < _numbers.length; i++) {
            _count += nTickets[_roundId][_type][_numbers[i]];
        }
        return _count;
    }

    function _calcPrize(uint256 _roundId, uint256[] memory _numbers, uint256 _expire, PRIZE_TYPE _type) internal returns(uint256, uint256, uint256) {
        PrizeInfo memory _prize = PrizeInfo({
            USD : 0,
            PSR : 0,
            PAN : 0,
            expire : _expire,
            nClaimed : 0,
            totalWinner : 0
        });
        uint256 _percentage = typePrize[_type].percentage;

        uint256 _USDForWinner = USDForCurrentPot * _percentage / ONE_HUNDRED_PERCENT;
        uint256 _PSRForWinner = PSRForCurrentPot * _percentage / ONE_HUNDRED_PERCENT;
        uint256 _PANForWinner = PANForCurrentPot * _percentage / ONE_HUNDRED_PERCENT;

        _prize.totalWinner = _countWinners(_roundId, _numbers, _type);
        if (_prize.totalWinner > 0) {
            _prize.USD = _USDForWinner;
            _prize.PSR = _PSRForWinner;
            _prize.PAN = _PANForWinner;
            if(_type == PRIZE_TYPE.MEGA) {
                lastJackpot = _expire - prizeExpireTime;
            }
        }
        prizes[_roundId][_type] = _prize;

        emit PriceForWinner(_roundId, _type, _USDForWinner, _PSRForWinner, _PANForWinner);
        return (_prize.USD, _prize.PSR, _prize.PAN);
    }


    // 0: leaderboard // 1 : mega // 2: minor // 3: mini
    function _liquidate(PRIZE_TYPE _type, uint256 _roundId, address _owner) internal {
        uint256 _totalUSD = 0;
        uint256 _totalPSR = 0;
        uint256 _totalPAN = 0;

        if (_type != PRIZE_TYPE.LEADERBOARD) {
            PrizeInfo storage _prize = prizes[_roundId][_type];
            require(_prize.expire < block.timestamp , 'PandoPot: !expire');
            if(_prize.totalWinner > _prize.nClaimed) {
                _totalUSD = _prize.USD * (_prize.totalWinner - _prize.nClaimed) / _prize.totalWinner;
                _totalPSR = _prize.PSR * (_prize.totalWinner - _prize.nClaimed) / _prize.totalWinner;
                _totalPAN = _prize.PAN * (_prize.totalWinner - _prize.nClaimed) / _prize.totalWinner;
                _prize.nClaimed = _prize.totalWinner;
            }
        } else {
            LeaderboardPrizeInfo storage _prize = leaderboardPrize[_roundId][_owner];
            require(_prize.expire < block.timestamp, 'PandoPot: !expire');
            require(_prize.status == PRIZE_STATUS.AVAILABLE, 'PandoPot: !AVAILABLE');
            _prize.status = PRIZE_STATUS.LIQUIDATED;
            _totalUSD = _prize.USD;
            _totalPSR = _prize.PSR;
            _totalPAN = _prize.PAN;
        }
        pendingUSD -= _totalUSD;
        pendingPAN -= _totalPAN;
        PSRForCurrentPot += _totalPSR;
        emit Liquidated(_type, _roundId, _owner, _totalUSD, _totalPSR, _totalPAN);
    }

    function _addTicket(address _receiver, uint256 _mega, uint256 _minor, uint256 _mini, uint256 _roundId) internal{
        tickets[_roundId][PRIZE_TYPE.MEGA][_mega][_receiver]++;
        tickets[_roundId][PRIZE_TYPE.MINOR][_minor][_receiver]++;
        tickets[_roundId][PRIZE_TYPE.MINI][_mini][_receiver]++;

        nTickets[_roundId][PRIZE_TYPE.MEGA][_mega]++;
        nTickets[_roundId][PRIZE_TYPE.MINOR][_minor]++;
        nTickets[_roundId][PRIZE_TYPE.MINI][_mini]++;

    }

    function _randomTicket(address _receiver, uint256 _rand, uint256 _quantity) internal {
        uint256[] memory _tickets = new uint[](_quantity);
        uint256 _ticketNumber;
        uint256 _megaSpace = typePrize[PRIZE_TYPE.MEGA].sampleSpace; // mega sampleSpace
        uint256 _minorSpace = typePrize[PRIZE_TYPE.MINOR].sampleSpace;
        uint256 _miniSpace =  typePrize[PRIZE_TYPE.MINI].sampleSpace;
        uint256 _seed = uint256(keccak256(abi.encodePacked(_rand, block.timestamp)));
        for (uint256 i = 0; i < _quantity; i++) {
            if (_seed > _megaSpace) {
                _ticketNumber = _seed % _megaSpace;
                _seed = _seed / _megaSpace;
            } else {
                _seed = uint256(keccak256(abi.encodePacked(_rand, i, _seed)));
            }
            uint256 _minor = _ticketNumber % _minorSpace;
            uint256 _mini = _ticketNumber % _miniSpace;

           _addTicket(_receiver, _ticketNumber, _minor, _mini, currentRoundId);

            _tickets[i] = _ticketNumber;
        }
        emit NewTicket(currentRoundId, _receiver, _tickets, 1);
    }

    function _getPriceOfTickets(uint256 _quantity) internal view returns (uint256) {
        return ticketPrice * _quantity * (ONE_HUNDRED_PERCENT - discountPercentages[_quantity]) / ONE_HUNDRED_PERCENT;
    }

    function _checkAndTransferPan(uint256 _quantity) internal{
        require(_quantity > 0,"PandoPot: Quantity ticket buy must more than zero");
        uint256 _amount_PAN = getAmountPan(_quantity);
        if(_amount_PAN > 0){
            IERC20(PAN).safeTransferFrom(msg.sender, address(this), _amount_PAN);
            if(panBurnPercent > 0){
                ERC20Burnable(PAN).burn(_amount_PAN * panBurnPercent / ONE_HUNDRED_PERCENT);
            }
        }
    }

    function _addNewPrize(uint256 _sampleSpace, uint256 _numberOfWinner, uint256 _percentage, string memory _name, PRIZE_TYPE _types) internal {
        require(_percentage + totalPrizePercentage <= ONE_HUNDRED_PERCENT, "PandoPot: percentage over");
        require(_numberOfWinner > 0 , "PandoPot: _numberOfWinner zero");
        require(_sampleSpace > 0 , "PandoPot: _sampleSpace zero");
        TypePrize storage _typePrize = typePrize[_types];
        _typePrize.sampleSpace = _sampleSpace;
        _typePrize.winners = _numberOfWinner;
        _typePrize.percentage = _percentage;
        _typePrize.name = _name;
        _typePrize.types = _types;
        totalPrizePercentage += _percentage;
        emit NewPrize(_types, _sampleSpace, _numberOfWinner, _percentage, _name);
    }

    function _checkTicketInRound(PRIZE_TYPE _type, uint256 _roundId, uint256 _ticketNumber) internal view returns (bool) {
        return roundInfo[_roundId].numbers[_type].contains(_ticketNumber);

    }

    function _claim(PRIZE_TYPE _type, uint256 _roundId, uint256 _ticketNumber, address _receiver) internal {
        require(uint256(_type) <  maxTypes, 'PandoPot: Invalid type');

        uint256 _USDAmount = 0;
        uint256 _PANAmount = 0;
        uint256 _PSRAmount = 0;

        if (_type != PRIZE_TYPE.LEADERBOARD) {
            uint256 _roundInfoStatus = roundInfo[_roundId].status;
            require(_roundInfoStatus == 1, 'PandoPot: Round hasnt been finished yet');

            uint256 _number = _ticketNumber % typePrize[_type].sampleSpace;
            require(tickets[_roundId][_type][_number][msg.sender] > 0 && _checkTicketInRound(_type, _roundId, _number), 'PandoPot: no prize');

            require(!isClaimed[_roundId][_type][_ticketNumber][msg.sender], 'Pandot:  claimed');
            isClaimed[_roundId][_type][_ticketNumber][msg.sender] = true;

            PrizeInfo storage _prizeInfo = prizes[_roundId][_type];
            if (_prizeInfo.expire >= block.timestamp) {

                uint256 _nWiningTicket = tickets[_roundId][PRIZE_TYPE.MEGA][_ticketNumber][msg.sender];
                uint256 _totalWinner = _prizeInfo.totalWinner;

                _USDAmount = _prizeInfo.USD * _nWiningTicket / _totalWinner;
                _PSRAmount = _prizeInfo.PSR * _nWiningTicket / _totalWinner;
                _PANAmount = _prizeInfo.PAN * _nWiningTicket / _totalWinner;

                _prizeInfo.nClaimed +=_nWiningTicket;
            } else {
                _liquidate(_type, _roundId, msg.sender);
            }
        } else {
            LeaderboardPrizeInfo storage _prize = leaderboardPrize[_roundId][msg.sender];
            require(_prize.USD + _prize.PSR > 0, 'PandoPot: no prize');
            if (_prize.expire >= block.timestamp) {
                require(_prize.status == PRIZE_STATUS.AVAILABLE, 'PandoPot: prize not available');
                _prize.status = PRIZE_STATUS.CLAIMED;
                _USDAmount = _prize.USD;
                _PSRAmount = _prize.PSR;
                _PANAmount = _prize.PAN;
            } else {
                _liquidate(_type, _roundId, msg.sender);
            }
        }
        pendingUSD -= _USDAmount;
        pendingPAN -= _PANAmount;

        _transferToken(USD, _receiver, _USDAmount);
        _transferToken(PSR, _receiver, _PSRAmount);
        _transferToken(PAN, _receiver, _PANAmount);
        emit Claimed(_type, _roundId, _ticketNumber, _USDAmount, _PSRAmount, _PANAmount, _receiver);
    }


    function _initPrize() internal {
        _addNewPrize(1e6, 2, 250000, "Mega", PRIZE_TYPE.MEGA); // 6 digits
        _addNewPrize(1e4, 2, 5000, "Minor", PRIZE_TYPE.MINOR); // 4 digits
        _addNewPrize(1e3, 4, 750, "Mini", PRIZE_TYPE.MINI); // 3 digits
    }

    function _computerSeed() internal view returns (uint256) {
        uint256 seed =
        uint256(
            keccak256(
                abi.encodePacked(
                    (block.timestamp),
                    block.gaslimit,
                    blockhash(block.number - 1),
                    block.coinbase,
                    tx.origin
                )
            )
        );
        return seed;
    }
    /*----------------------------EXTERNAL FUNCTIONS----------------------------*/

    function getRoundDuration() external view returns(uint256) {
        return roundDuration;
    }

    function getAmountPan(uint256 _quantityTicket) public view returns(uint256) {
        uint256 _priceTicket = _getPriceOfTickets(_quantityTicket);
        if(_priceTicket > 0){
            uint256 _price_PAN = IMultiOracle(multiOracle).consult(address(PAN));
            uint256 _price_USD = IMultiOracle(multiOracle).consult(address(USD));
            if (_price_PAN > 0 && _price_USD > 0) {
                return _priceTicket * _price_USD / _price_PAN;
            }
        }
        return 0;
    }

    function buyTickets(address _receiver, uint256[] memory _tickets) external availableBuyTicket(_receiver) onlyEOA whenNotPaused nonReentrant{
        require(0 < _tickets.length && _tickets.length < 21,"PandoPot: Quantity ticket buy must more than zero or maximum 20 tickets");
        uint256 _roundId = currentRoundId;
        _checkAndTransferPan(_tickets.length);

        uint256 _megaSampleSpace = typePrize[PRIZE_TYPE.MEGA].sampleSpace;
        uint256 _minorSampleSpace = typePrize[PRIZE_TYPE.MINOR].sampleSpace;
        uint256 _miniSampleSpace = typePrize[PRIZE_TYPE.MINI].sampleSpace;

        uint256 _megaNumber;
        uint256 _minorNumber;
        uint256 _miniNumber;
        for (uint256 i = 0; i < _tickets.length; i++) {
            _megaNumber = _tickets[i] % _megaSampleSpace;
            _minorNumber = _tickets[i] % _minorSampleSpace;
            _miniNumber = _tickets[i] % _miniSampleSpace;

            _addTicket(_receiver, _megaNumber, _minorNumber, _miniNumber, _roundId);
        }

        if(!isReceivedFreeTicket[_receiver]){
            isReceivedFreeTicket[_receiver] = true;
            _randomTicket(_receiver, _computerSeed(), numFreeTicket);
        }

        emit NewTicket(_roundId, _receiver, _tickets, 0);
    }

    function enter(address _receiver, uint256 _rand, uint256 _quantity) external whenNotPaused nonReentrant onlyWhitelist() {
        _randomTicket(_receiver, _rand, _quantity); // mega
    }

    function enterWithoutRand(address _receiver, uint256[] memory _tickets) external whenNotPaused nonReentrant onlyWhitelist() {
        uint256 _len = _tickets.length;
        uint256 _roundId = currentRoundId;
        uint256 _megaSampleSpace = typePrize[PRIZE_TYPE.MEGA].sampleSpace;
        uint256 _minorSampleSpace = typePrize[PRIZE_TYPE.MINOR].sampleSpace;
        uint256 _miniSampleSpace = typePrize[PRIZE_TYPE.MINI].sampleSpace;

        for (uint256 i = 0; i < _len; i++) {
            uint256 _ticketNumber = _tickets[i];
            _addTicket(_receiver, _ticketNumber % _megaSampleSpace, _ticketNumber % _minorSampleSpace, _ticketNumber % _miniSampleSpace, _roundId);
        }
        emit NewTicket(_roundId, _receiver, _tickets, 0);
    }

    function claim(PRIZE_TYPE _type, uint256 _roundId, uint256 _ticketNumber, address _receiver) external whenNotPaused nonReentrant {
        _claim(_type, _roundId, _ticketNumber, _receiver);
    }

    function distribute(address[] memory _leaderboards, uint256[] memory ratios, uint256 _lastJackpot) external onlyOwner whenNotPaused {
        require(_leaderboards.length == ratios.length, 'PandoPot: leaderboards != ratios');
        require(block.timestamp - lastJackpot >= timeBomb, 'PandoPot: not enough timebomb');
        uint256 _cur = 0;
        for (uint256 i = 0; i < ratios.length; i++) {
            _cur += ratios[i];
        }
        require(_cur == ONE_HUNDRED_PERCENT, 'PandoPot: ratios incorrect');
        currentDistributeId++;
        updatePandoPot();
        require(USDForTimeBomb + PSRForTimeBomb + PANForTimeBomb > 0, 'PandoPot: no prize');
        uint256 _nRatios = ratios.length;
        uint256[] memory _usdAmounts = new uint256[](_nRatios);
        uint256[] memory _psrAmounts = new uint256[](_nRatios);
        uint256[] memory _panAmounts = new uint256[](_nRatios);

        for (uint256 i = 0; i < _leaderboards.length; i++) {
            uint256 _USDAmount = USDForTimeBomb * ratios[i] / ONE_HUNDRED_PERCENT;
            uint256 _PSRAmount = PSRForTimeBomb * ratios[i] / ONE_HUNDRED_PERCENT;
            uint256 _PANAmount = PANForTimeBomb * ratios[i] / ONE_HUNDRED_PERCENT;
            LeaderboardPrizeInfo memory _prize = LeaderboardPrizeInfo({
                USD : _USDAmount,
                PSR : _PSRAmount,
                PAN : _PANAmount,
                expire : block.timestamp + prizeExpireTime,
                status : PRIZE_STATUS.AVAILABLE
            });
            leaderboardPrize[currentDistributeId][_leaderboards[i]] = _prize;
            _usdAmounts[i] = _USDAmount;
            _psrAmounts[i] = _PSRAmount;
            _panAmounts[i] = _PANAmount;
        }
        pendingUSD += USDForTimeBomb;
        pendingPAN += PANForTimeBomb;
        USDForTimeBomb = 0;
        PSRForTimeBomb = 0;
        PANForTimeBomb = 0;
        if (_lastJackpot == 0) {
            lastJackpot = block.timestamp;
        } else {
            lastJackpot = _lastJackpot;
        }
        emit Distributed(currentDistributeId, block.timestamp + prizeExpireTime, _leaderboards, _usdAmounts, _psrAmounts, _panAmounts);
    }

    function updatePandoPot() public {
        _updateRound(currentRoundId - 1);

        PSRForCurrentPot += totalPSRAllocated * (block.timestamp - lastUpdatePot) / unlockPeriod;
        USDForCurrentPot = IERC20(USD).balanceOf(address(this)) - USDForTimeBomb - pendingUSD;
        PANForCurrentPot = IERC20(PAN).balanceOf(address(this)) - PANForTimeBomb - pendingPAN;

        if (block.timestamp - lastJackpot >= timeBomb) {
            if (PSRForTimeBomb == 0 && USDForTimeBomb == 0 && PANForTimeBomb == 0) {
                USDForTimeBomb = USDForCurrentPot * timeBombPrizePercentage / ONE_HUNDRED_PERCENT;
                PSRForTimeBomb = PSRForCurrentPot * timeBombPrizePercentage / ONE_HUNDRED_PERCENT;
                PANForTimeBomb = PANForCurrentPot * timeBombPrizePercentage / ONE_HUNDRED_PERCENT;
                PSRForCurrentPot -= PSRForTimeBomb;
            }
        }
        lastUpdatePot = block.timestamp;
    }

    function liquidate(PRIZE_TYPE _type, uint256 _roundId, address[] memory _owners) external whenNotPaused {
        require(uint256(_type) <  maxTypes, 'PandoPot: Invalid type');
        for(uint256 i = 0; i < _owners.length; i++){
            _liquidate(_type, _roundId, _owners[i]);
        }
        updatePandoPot();
    }

    function currentPot() external view returns(uint256, uint256, uint256) {
        uint256 _USD = IERC20(USD).balanceOf(address(this)) - USDForTimeBomb - pendingUSD;
        uint256 _PAN = IERC20(PAN).balanceOf(address(this)) - PANForTimeBomb - pendingPAN;
        uint256 _PSR = totalPSRAllocated * (block.timestamp - lastUpdatePot) / unlockPeriod + PSRForCurrentPot;

        if (currentRoundId > 1) {
            uint256 _preRound = currentRoundId - 1;
            if (roundInfo[_preRound].status == 0) {
                for(uint256 i = 1; i < maxTypes; i++) {
                    if(_countWinners(_preRound, roundInfo[_preRound].numbers[PRIZE_TYPE(i)].values(), PRIZE_TYPE(i)) > 0) {
                        _USD -= USDForCurrentPot * typePrize[PRIZE_TYPE(i)].percentage / ONE_HUNDRED_PERCENT;
                        _PSR -= PSRForCurrentPot * typePrize[PRIZE_TYPE(i)].percentage / ONE_HUNDRED_PERCENT;
                        _PAN -= PANForCurrentPot * typePrize[PRIZE_TYPE(i)].percentage / ONE_HUNDRED_PERCENT;
                    }
                }
            }
        }
        return (_USD, _PSR, _PAN);
    }

    function finishRound() external onlyRNG {
        require(block.timestamp > roundDuration + roundInfo[currentRoundId - 1].finishedAt, 'PandoPot: < roundDuration');
        roundInfo[currentRoundId].finishedAt = block.timestamp;
        emit RoundFinished(currentRoundId);
        currentRoundId++;
    }

    // 0: wrong
    // 1: valid
    // 2: expired
    // 3: claimed
    // 4: you is not winner
    //_type: 0: distribute 1: mega 2: minor 3: mini
    function checkTicketStatus(uint256 _roundId, PRIZE_TYPE _type, address _owner, uint256 _ticketNumber) external view returns (uint256) {
        if (roundInfo[_roundId].numbers[_type].contains(_ticketNumber)) {
            if (roundInfo[_roundId].finishedAt + prizeExpireTime < block.timestamp) {
                return 2;
            }
            if(tickets[_roundId][_type][_ticketNumber][_owner] == 0){
                return 4;
            }
            if (!isClaimed[_roundId][_type][_ticketNumber][_owner]) {
                return 1;
            }
            return 3;
        }
        return 0;
    }

    function getDiscountPercentage(uint256 _quantity) external view returns (uint256) {
        require(_quantity <= 20);
        return discountPercentages[_quantity];
    }

    function getWinningNumbers(uint _roundId) public view returns (uint256[] memory, uint256[] memory, uint256[] memory) {
        return (roundInfo[_roundId].numbers[PRIZE_TYPE.MEGA].values(), roundInfo[_roundId].numbers[PRIZE_TYPE.MINOR].values(), roundInfo[_roundId].numbers[PRIZE_TYPE.MINI].values());
    }

    function getRoundInfo(uint256 _roundId) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256 finishedAt, uint256 status) {
        return (roundInfo[_roundId].numbers[PRIZE_TYPE.MEGA].values(), roundInfo[_roundId].numbers[PRIZE_TYPE.MINOR].values(), roundInfo[_roundId].numbers[PRIZE_TYPE.MINI].values(), roundInfo[_roundId].finishedAt, roundInfo[_roundId].status);
    }

    /*----------------------------RESTRICTED FUNCTIONS----------------------------*/
    modifier availableBuyTicket(address _receive) {
        require( _receive != address(0), "PandoPot: Receiver must different address zero");
        _;
    }

    modifier onlyEOA() {
        // Try to make flash-loan exploit harder to do by only allowing externally owned addresses.
        require(msg.sender == tx.origin, "PandoPot: must use EOA");
        _;
    }

    modifier onlyWhitelist() {
        require(whitelist[msg.sender], 'PandoPot: caller is not in the whitelist');
        _;
    }

    modifier onlyRNG() {
        require(msg.sender == randomNumberGenerator, 'PandoPot: !RNG');
        _;
    }

    function toggleWhitelist(address _addr) external onlyOwner {
        whitelist[_addr] = !whitelist[_addr];
        emit WhitelistChanged(_addr, whitelist[_addr]);
    }

    function allocatePSR(uint256 _amount) external onlyOwner {
        totalPSRAllocated += _amount;
        IERC20(PSR).safeTransferFrom(msg.sender, address(this), _amount);
        emit PSRAllocated(_amount);
    }

    function changeTimeBomb(uint256 _second) external onlyOwner {
        uint256 oldSecond = timeBomb;
        timeBomb = _second;
        emit TimeBombChanged(oldSecond, _second);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function emergencyWithdraw() external onlyOwner whenPaused {
        IERC20 _USD = IERC20(USD);
        IERC20 _PSR = IERC20(PSR);
        IERC20 _PAN = IERC20(PAN);
        uint256 _USDAmount = _USD.balanceOf(address(this));
        uint256 _PSRAmount = _PSR.balanceOf(address(this));
        uint256 _PANAmount = _PAN.balanceOf(address(this));
        _USD.safeTransfer(owner(), _USDAmount);
        _PSR.safeTransfer(owner(), _PSRAmount);
        _PAN.safeTransfer(owner(), _PANAmount);
        emit EmergencyWithdraw(owner(), _USDAmount, _PSRAmount, _PANAmount);
    }

    function changeRewardExpireTime(uint256 _newExpireTime) external onlyOwner whenPaused {
        uint256 _oldExpireTIme = prizeExpireTime;
        prizeExpireTime = _newExpireTime;
        emit RewardExpireTimeChanged(_oldExpireTIme, _newExpireTime);
    }

    function changeRandomNumberGenerator(address _rng) external onlyOwner whenPaused {
        address _oldRNG = randomNumberGenerator;
        randomNumberGenerator = _rng;
        emit RandomNumberGeneratorChanged(_oldRNG, _rng);
    }

    function changeRoundDuration(uint256 _newDuration) external onlyOwner whenPaused {
        uint256 _oldDuration = roundDuration;
        roundDuration = _newDuration;
        emit RoundDurationChanged(_oldDuration, _newDuration);
    }

    function changeMultiOracle(address _newOracle) external onlyOwner {
        address  _oldOracle = multiOracle;
        multiOracle = _newOracle;
        emit MultiOracleChanged(_oldOracle, _newOracle);
    }


    function changePanBurnPercent(uint256 _newPercent) external onlyOwner {
        uint256 _oldPercent = panBurnPercent;
        panBurnPercent = _newPercent;
        emit PanBurnPercentChanged(_oldPercent, _newPercent);
    }

//    function changeDiscount(uint256 _percentage, uint256 _usd) external onlyOwner {
//        require(_percentage <= ONE_HUNDRED_PERCENT, "PandoPot: over 100 percentage");
//        require(_usd <=  ticketPrice, "PandoPot: over price");
//        discountPercentage = _percentage;
//        discountPerAmount = _usd;
//        emit DiscountChange(discountPercentage, discountPerAmount);
//    }

    function changePriceTicket(uint256 _value) external onlyOwner {
        uint256 _old = ticketPrice;
        ticketPrice = _value;
        emit PriceTicketChanged(_old, ticketPrice);
    }

    function changeNumberFreeTicket(uint256 _value) external onlyOwner {
        uint256 _old = numFreeTicket;
        numFreeTicket = _value;
        emit NumberFreeTicketChanged(_old, numFreeTicket);
    }

    function updatePrizeInfo(uint256 _sampleSpace, uint256 _numberOfWinner, uint256 _percentage, string memory _name, PRIZE_TYPE _types) external onlyOwner whenPaused {
        require(_percentage + totalPrizePercentage <= ONE_HUNDRED_PERCENT, "PandoPot: percentage over");
        require(_numberOfWinner > 0 , "PandoPot: _numberOfWinner zero");
        require(_sampleSpace > 0 , "PandoPot: _sampleSpace zero");
        TypePrize storage _typePrize = typePrize[_types];
        totalPrizePercentage += _percentage - _typePrize.percentage;
        _typePrize.sampleSpace = _sampleSpace;
        _typePrize.winners = _numberOfWinner;
        _typePrize.percentage = _percentage;
        _typePrize.name = _name;
        _typePrize.types = _types;
        emit PrizeUpdated(_types, _sampleSpace, _numberOfWinner, _percentage, _name);
    }

    function changeDiscountPercentage(uint256[] memory _percentages) external onlyOwner {
        require(_percentages.length == 21, "PandoPot: Overflow");
        for(uint i = 0; i < _percentages.length; i++) {
            require(_percentages[i] < ONE_HUNDRED_PERCENT, "PandoPot: over 100 percent");
            discountPercentages[i] = _percentages[i];
        }
        emit DiscountChange(_percentages);
    }
    /*----------------------------EVENTS----------------------------*/

    event PriceForWinner(uint256 _roundId, PRIZE_TYPE _type, uint256 USDForWinner, uint256 PSRForWinner, uint256 PANForWinner);
    event NewTicket(uint256 indexed roundId, address indexed user, uint256[] numbers, uint256 indexed _type);//_type: 0-BuyTicket, 1-EnterTicket
    event Claimed(PRIZE_TYPE _type, uint256 roundId, uint256 ticketNumber, uint256 USD, uint256 PSR,uint256 PAN, address receiver);
    event Liquidated(PRIZE_TYPE _type, uint256 id, address owner, uint256 USD, uint256 PSR, uint256 PAN);
    event WhitelistChanged(address indexed whitelist, bool status);
    event PSRAllocated(uint256 amount);
    event TimeBombChanged(uint256 oldValueSecond, uint256 newValueSecond);
    event EmergencyWithdraw(address owner, uint256 USD, uint256 PSR, uint256 PAN);
    event RewardExpireTimeChanged(uint256 oldExpireTime, uint256 newExpireTime);
    event RandomNumberGeneratorChanged(address indexed _oldRNG, address indexed _RNG);
    event RoundCompleted(uint256 roundId, uint256 expireTime, uint256[] mega, uint256[] minor, uint256[] mini);
    event RoundFinished(uint256 newRoundId);
    event Distributed(uint256 distributeId, uint256 expire, address[] leaderboards, uint256[] usdAmounts, uint[] psrAmounts, uint[] panAmounts);
    event RoundDurationChanged(uint256 oldDuration, uint256 newDuration);
    event MultiOracleChanged(address oldOracle, address newOracle);
    event PriceTicketChanged(uint256 oldPrice, uint256 newPrice);
    event NumberFreeTicketChanged(uint256 oldTicket, uint256 newTicket);
    event PanBurnPercentChanged(uint256 oldPercent, uint256 newPercent);
    event NewPrize(PRIZE_TYPE _type, uint256 _sampleSpace, uint256 _numberOfWinner, uint256 _percentage, string  _name);
    event DiscountChange(uint256[] percentages);
    event PrizeUpdated(PRIZE_TYPE _type, uint256 _sampleSpace, uint256 _numberOfWinner, uint256 _percentage, string  _name);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IRandomNumberGenerator {
    function computerSeed(uint256) external view returns(uint256);
    function getNumber(uint256) external view returns(uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;
pragma experimental ABIEncoderV2;

interface IMultiOracle {
    function consult(address _token) external view returns (uint256);
    function tradingPair(address _token) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
import '../jackpot/PandoPotV3.sol';

contract MockNFTRouter{
    PandoPotV3 public pandoPot;
    constructor(address _pandoPot){
        pandoPot = PandoPotV3(_pandoPot);
    }
    function upgradeDroidBot(uint256 _number) public{
        pandoPot.enter(msg.sender, (uint256(keccak256(abi.encodePacked(blockhash(block.number-1)))) + 1), _number);
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;

import "../interfaces/IRandomNumberGenerator.sol";

contract DataStorage {
    uint256 constant N_PETS = 9;
    uint256 constant N_EGGS = 6;
    uint256 constant BASE_POWER = 10000;
    uint256 constant SAMPLE_SPACE = 1e10;
    uint256 constant STEP = 1e9;

    uint256 constant BASE_POWER_LEVEL_FLOOR = 9000;
    uint256 constant BASE_POWER_LEVEL_CEILING = 18000;
    uint256 constant MAX_LEVEL = 8;

    uint256 constant MAX_CEILING = BASE_POWER_LEVEL_CEILING * 2 ** MAX_LEVEL;

    uint256[N_EGGS] private pandoBoxCreating;
    mapping (uint256 => mapping(uint256 => uint256)) private droidBotCreating;
    mapping (uint256 => mapping(uint256 => mapping(uint256 => uint256))) private droidBotUpgrading;
//    mapping (uint256 => uint256) ;
    uint256[N_PETS - 1] public nTickets;
    uint256[39] private droidBotUpgradingPower;

    /*----------------------------CONSTRUCTOR----------------------------*/

    constructor() {
        pandoBoxCreating = [9000000000 , 700000000, 200000000, 75000000, 20000000, 5000000];
        nTickets = [1, 2, 3, 4, 5, 8, 11, 17];
        droidBotCreating[0][0] = 9000000000;
        droidBotCreating[0][1] = 650000000;
        droidBotCreating[0][2] = 210400000;
        droidBotCreating[0][3] = 84160000;
        droidBotCreating[0][4] = 33664000;
        droidBotCreating[0][5] = 13465600;
        droidBotCreating[0][6] = 5386240;
        droidBotCreating[0][7] = 2154496;
        droidBotCreating[0][8] = 769664;


        droidBotCreating[1][0] = 0;
        droidBotCreating[1][1] = 9000000000;
        droidBotCreating[1][2] = 650000000;
        droidBotCreating[1][3] = 211000000;
        droidBotCreating[1][4] = 84400000;
        droidBotCreating[1][5] = 33760000;
        droidBotCreating[1][6] = 13504000;
        droidBotCreating[1][7] = 5401600;
        droidBotCreating[1][8] = 1934400;

        droidBotCreating[2][0] = 0;
        droidBotCreating[2][1] = 0;
        droidBotCreating[2][2] = 9000000000;
        droidBotCreating[2][3] = 650000000;
        droidBotCreating[2][4] = 212500000;
        droidBotCreating[2][5] = 85000000;
        droidBotCreating[2][6] = 34000000;
        droidBotCreating[2][7] = 13600000;
        droidBotCreating[2][8] = 4900000;

        droidBotCreating[3][0] = 0;
        droidBotCreating[3][1] = 0;
        droidBotCreating[3][2] = 0;
        droidBotCreating[3][3] = 9000000000;
        droidBotCreating[3][4] = 650000000;
        droidBotCreating[3][5] = 216500000;
        droidBotCreating[3][6] = 86600000;
        droidBotCreating[3][7] = 34640000;
        droidBotCreating[3][8] = 12260000;

        droidBotCreating[4][0] = 0;
        droidBotCreating[4][1] = 0;
        droidBotCreating[4][2] = 0;
        droidBotCreating[4][3] = 0;
        droidBotCreating[4][4] = 9000000000;
        droidBotCreating[4][5] = 650000000;
        droidBotCreating[4][6] = 227000000;
        droidBotCreating[4][7] = 90800000;
        droidBotCreating[4][8] = 32200000;

        droidBotCreating[5][0] = 0;
        droidBotCreating[5][1] = 0;
        droidBotCreating[5][2] = 0;
        droidBotCreating[5][3] = 0;
        droidBotCreating[5][4] = 0;
        droidBotCreating[5][5] = 9000000000;
        droidBotCreating[5][6] = 650000000;
        droidBotCreating[5][7] = 258000000;
        droidBotCreating[5][8] = 92000000;

        droidBotUpgradingPower = [21677600, 467803500, 920432600, 1324070400, 1286351300, 1117699200, 891514600, 685013400, 592623300, 466242700, 379523500, 305455300, 249691700, 201555400, 170942700, 135546800, 112981700, 102953600, 85578100, 71187600, 61826800, 52114800, 45516500, 38450100, 32944400, 28449300, 24660500, 21609100, 18850400, 16368800, 14152500, 12158600, 10363600, 8748200, 7292800, 5981700, 4803300, 3742000, 3121600];
    }

    /*----------------------------INTERNAL FUNCTIONS----------------------------*/

    function _powerToLevel(uint256 _oldLevel, uint256 _power) internal pure returns(uint256) {
        uint256 _baseCeiling = BASE_POWER_LEVEL_CEILING;
        uint256 _maxLevel = MAX_LEVEL;
        for(uint256 i = _oldLevel; i <= _maxLevel; i++) {
            if(_power < _baseCeiling * 2 ** i) {
                return i;
            }
        }
        return MAX_LEVEL;
    }

    function _getPowerUpgradeProbability(uint256 _rand) internal view returns(uint256) {
        uint256 _length = droidBotUpgradingPower.length;
        uint256 _cur = 0;
        for(uint i = 0; i < _length; i++ ) {
            _cur += droidBotUpgradingPower[i];
            if(_rand <= _cur) {
                return i + 2; //start from 20%
            }
        }
        return 0;
    }

    /*----------------------------EXTERNAL FUNCTIONS----------------------------*/

    function getPandoBoxPower() external pure returns(uint256) {
        return 0;
    }

    function getSampleSpace() external pure returns(uint256) {
        return SAMPLE_SPACE;
    }

    function getNewPowerLevel(uint256 _rand, uint256 _mainPower, uint256 _materialPower, uint256 _mainLevel) external view returns (uint256 , uint256) {
        uint256 _probability = _getPowerUpgradeProbability(_rand);
        uint256 _newPower = _mainPower + _materialPower * _probability * STEP / SAMPLE_SPACE;
        uint256 _ceiling = MAX_CEILING;
        if(_newPower >= _ceiling) {
            _newPower = _ceiling - 1;
        }
        uint256 _level = _powerToLevel(_mainLevel, _newPower);
        return (_level, _newPower);
    }

    // power
    // power based = (level - 10%)
    // power + rand ( < 20 %) => 90% < power < 110%
    function getDroidBotPower(uint256 _droidBotLevel, uint256 _rand) external pure returns (uint256) {
        uint256 _seed = _rand % 1000;
        uint256 _power = BASE_POWER * (2**(_droidBotLevel)) * 9 / 10;
        uint256 _r1 = _rand % 10;
        //30% greater than base
        if(_r1 >= 7) {
            _seed += 1000; // 10%
        }
        return _power + _power * _seed / BASE_POWER;
    }

    function getPandoBoxCreatingProbability() external view returns(uint256[] memory _pandoBoxCreating) {
        _pandoBoxCreating = new uint256[](N_EGGS);
        for (uint256 i = 0; i < N_EGGS; i++) {
            _pandoBoxCreating[i] = pandoBoxCreating[i];
        }
    }

    function getDroidBotCreatingProbability(uint256 _pandoBoxLevel) external view returns(uint256[] memory _droidBotCreating) {
        _droidBotCreating = new uint256[](N_PETS);
        for (uint256 i = 0; i < N_PETS; i++) {
            _droidBotCreating[i] = droidBotCreating[_pandoBoxLevel][i];
        }
    }

    function getDroidBotUpgradingProbability(uint256 _droidBot0Level, uint256 _droidBot1Level) external view returns(uint256[] memory _droidBotUpgrading) {
        _droidBotUpgrading = new uint256[](N_PETS);
        for (uint256 i = 0; i < N_PETS; i++) {
            _droidBotUpgrading[i] = droidBotUpgrading[_droidBot0Level][_droidBot1Level][i];
        }
    }

    function getNumberOfTicket(uint256 _lv) external view returns (uint256) {
        return nTickets[_lv];
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "../interfaces/IRandomNumberGenerator.sol";

contract PandoPot is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    enum REWARD_STATUS {AVAILABLE, CLAIMED, EXPIRED}
    // 0 : mega, 1 : minor, 2 : leaderboard
    struct Reward {
        address owner;
        uint256[3] usdt;
        uint256[3] psr;
        uint256 expire;
        REWARD_STATUS status;
    }

    address public USDT;
    address public PSR;

    uint256 public constant PRECISION = 10000000000;
    uint256 public constant unlockPeriod = 2 * 365 * 1 days;
    uint256 public timeBomb = 2 * 30 * 1 days;
    uint256 public rewardExpireTime = 14 * 1 days;
    uint256 public constant megaPrizePercentage = 25;
    uint256 public constant minorPrizePercentage = 1;
    uint256 public lastDistribute;
    uint256 public usdtForCurrentPot;
    uint256 public PSRForCurrentPot;
    uint256 public totalPSRAllocated;
    uint256 public lastUpdatePot;

    uint256 public usdtForPreviousPot;
    uint256 public PSRForPreviousPot;

    uint256 public nTickets;
    uint256 public pendingUSDT;
    mapping (address => bool) public whitelist;
    mapping (uint256 => Reward) private rewards;

    /*----------------------------CONSTRUCTOR----------------------------*/
    constructor (address _USDT, address _PSR) {
        USDT = _USDT;
        PSR = _PSR;
        lastDistribute = block.timestamp;
        lastUpdatePot = block.timestamp;
    }

    /*----------------------------INTERNAL FUNCTIONS----------------------------*/

    function transferToken(address _token, address _receiver, uint256 _amount) internal {
        if (_amount > 0) {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    /*----------------------------EXTERNAL FUNCTIONS----------------------------*/

    function reward(uint256 _ticketNumber) external view returns(Reward memory) {
        return rewards[_ticketNumber];
    }

    function enter(address _receiver, uint256 _mega, uint256 _minor, uint256 _rand, uint256 _salt) external whenNotPaused nonReentrant  onlyWhitelist() {
        updateJackpot();
        Reward memory _reward = Reward({
            owner: _receiver,
            usdt: [uint256(0), uint256(0), uint256(0)],
            psr: [uint256(0), uint256(0), uint256(0)],
            expire: block.timestamp + rewardExpireTime,
            status: REWARD_STATUS.AVAILABLE
        });
        //mega
        if (_rand <= _mega) {
            lastDistribute = block.timestamp;
            _reward.usdt[0] = usdtForCurrentPot * megaPrizePercentage / 100;
            _reward.psr[0] = PSRForCurrentPot * megaPrizePercentage / 100;
        }
        updateJackpot();

        //minor
        _rand = _rand * _salt % PRECISION + 1;
        if (_rand <= _minor) {
            _reward.usdt[1] = usdtForCurrentPot * minorPrizePercentage / 100;
            _reward.psr[1] = PSRForCurrentPot * minorPrizePercentage / 100;
        }
        pendingUSDT += _reward.usdt[0] + _reward.usdt[1];
        PSRForCurrentPot -= _reward.psr[0] + _reward.psr[1];

        uint256 _ticketId = nTickets;
        rewards[_ticketId] = _reward;
        nTickets++;
        emit NewTicket(_ticketId, _reward.owner, _reward.usdt, _reward.psr, _reward.expire);
    }


    function claim(uint256 _ticketId) external whenNotPaused nonReentrant {
        Reward storage _reward = rewards[_ticketId];
        require(_reward.status == REWARD_STATUS.AVAILABLE && _reward.expire >= block.timestamp, 'Jackpot: reward unavailable');
        _reward.status = REWARD_STATUS.CLAIMED;
        for (uint8 i = 0; i < 3; i++) {
            transferToken(USDT, _reward.owner, _reward.usdt[i]);
            transferToken(PSR, _reward.owner, _reward.psr[i]);
            pendingUSDT -= _reward.usdt[i];
        }
        emit Claimed(_ticketId, _reward.owner, _reward.usdt, _reward.psr);

    }

    function distribute(address[] memory _leaderboards, uint256[] memory ratios) external onlyWhitelist whenNotPaused {
        require(_leaderboards.length == ratios.length, 'Jackpot: leaderboards != ratios');
        uint256 _cur = 0;
        for (uint256 i = 0; i < ratios.length; i++) {
            _cur += ratios[i];
        }
        require(_cur == PRECISION, 'Jackpot: ratios incorrect');
        updateJackpot();
        for (uint256 i = 0; i < _leaderboards.length; i++) {
            uint256 ticketId = nTickets;
            rewards[ticketId].usdt[2] = usdtForPreviousPot * ratios[i] / PRECISION;
            rewards[ticketId].psr[2] = PSRForPreviousPot * ratios[i] / PRECISION;
            rewards[ticketId].expire = block.timestamp + rewardExpireTime;
            rewards[ticketId].status = REWARD_STATUS.AVAILABLE;
            rewards[ticketId].owner = _leaderboards[i];
            nTickets++;
            emit NewTicket(ticketId, _leaderboards[i], rewards[ticketId].usdt, rewards[ticketId].psr, rewards[ticketId].expire);
        }
        pendingUSDT += usdtForPreviousPot;
        usdtForPreviousPot = 0;
        PSRForPreviousPot = 0;
        lastDistribute = block.timestamp;
    }

    function updateJackpot() public {
        usdtForCurrentPot = IERC20(USDT).balanceOf(address(this)) - usdtForPreviousPot - pendingUSDT;
        PSRForCurrentPot += totalPSRAllocated * (block.timestamp - lastUpdatePot) / unlockPeriod;

        if (block.timestamp - lastDistribute >= timeBomb) {
            if (PSRForPreviousPot == 0 && usdtForPreviousPot == 0) {
                usdtForPreviousPot = usdtForCurrentPot * megaPrizePercentage / 100;
                PSRForPreviousPot = PSRForCurrentPot * megaPrizePercentage / 100;
                PSRForCurrentPot -= PSRForPreviousPot;
            }
        }
        lastUpdatePot = block.timestamp;
    }

    function liquidation(uint256 _ticketId) external whenNotPaused {
        Reward storage _reward = rewards[_ticketId];
        require(_reward.status == REWARD_STATUS.AVAILABLE, 'Jackpot: reward unavailable');
        if (_reward.expire < block.timestamp) {
            _reward.status = REWARD_STATUS.EXPIRED;
            for (uint8 i = 0; i < 3; i++) {
                if (_reward.psr[i] > 0 || _reward.usdt[i] > 0) {
                    pendingUSDT -= _reward.usdt[i];
                    PSRForCurrentPot += _reward.psr[i];
                }
            }
        }
        emit Liquidated(_ticketId);
    }

    function currentPot() external view returns(uint256, uint256) {
        uint256 _usdt = IERC20(USDT).balanceOf(address(this)) - usdtForPreviousPot - pendingUSDT;
        uint256 _psr = totalPSRAllocated * (block.timestamp - lastUpdatePot) / unlockPeriod + PSRForCurrentPot;
        return (_usdt, _psr);
    }

    /*----------------------------RESTRICTED FUNCTIONS----------------------------*/

    modifier onlyWhitelist() {
        require(whitelist[msg.sender] == true, 'Jackpot: caller is not in the whitelist');
        _;
    }

    function toggleWhitelist(address _addr) external onlyOwner {
        whitelist[_addr] = !whitelist[_addr];
        emit WhitelistChanged(_addr, whitelist[_addr]);
    }

    function allocatePSR(uint256 _amount) external onlyOwner {
        totalPSRAllocated += _amount;
        IERC20(PSR).safeTransferFrom(msg.sender, address(this), _amount);
        emit PSRAllocated(_amount);
    }

    function changeTimeBomb(uint256 _second) external onlyOwner {
        uint256 oldSecond = timeBomb;
        timeBomb = _second;
        emit TimeBombChanged(oldSecond, _second);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function emergencyWithdraw() external onlyOwner whenPaused {
        IERC20 _usdt = IERC20(USDT);
        IERC20 _psr = IERC20(PSR);
        uint256 _usdtAmount = _usdt.balanceOf(address(this));
        uint256 _psrAmount = _psr.balanceOf(address(this));
        _usdt.safeTransfer(owner(), _usdtAmount);
        _psr.safeTransfer(owner(), _psrAmount);
        emit EmergencyWithdraw(owner(), _usdtAmount, _psrAmount);
    }

    function changeRewardExpireTime(uint256 _newExpireTime) external onlyOwner whenPaused {
        uint256 _oldExpireTIme = rewardExpireTime;
        rewardExpireTime = _newExpireTime;
        emit RewardExpireTimeChanged(_oldExpireTIme, _newExpireTime);
    }


    /*----------------------------EVENTS----------------------------*/

    event NewTicket(uint256 ticketId, address user, uint256[3] usdt, uint256[3] PSR, uint256 expire);
    event Claimed(uint256 ticketId, address user, uint256[3] usdt, uint256[3] PSR);
    event Liquidated(uint256 ticketId);
    event WhitelistChanged(address indexed whitelist, bool status);
    event PSRAllocated(uint256 amount);
    event TimeBombChanged(uint256 oldValueSecond, uint256 newValueSecond);
    event EmergencyWithdraw(address owner, uint256 usdt, uint256 psr);
    event RewardExpireTimeChanged(uint256 oldExpireTime, uint256 newExpireTime);
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import '../interfaces/IVerifier.sol';

contract Presale is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;


    struct UserInfo {
        uint8 status; // 0 - 1 - 2 - 3 - 4 : times claim token
        bool finish; // claim done
        uint256 totalToken; // total token receive
        uint256 totalTokenClaim; // total token user has received
        uint256 amountUsdt; // amount of usdt user buy
        uint256 amountBusd; // amount of usdt user buy
    }

    struct WaitingInfo {
        uint256 amountUsdt; // amount of usdt user commit to buy
        uint256 amountBusd; // amount of usdt user commit to buy
        bool isRefunded;
    }

    // register
    EnumerableSet.AddressSet private registerList;

    // white list
    EnumerableSet.AddressSet private whiteList;

    // waiting list
    address[] private waitingList;
    mapping(address => uint256) private index;
    mapping(uint256 => bool) private userReservation;

    mapping(address => UserInfo) public userInfo;
    mapping(address => WaitingInfo) public waiting;

    EnumerableSet.AddressSet private contributors;

    // token erc20 info
    IERC20 public PandoraSpirit;
    IERC20 public USDT;
    IERC20 public BUSD;

    //Verifier claim
    IVerifier public verifier;

    //amount usd bought
    uint256 public totalAmountUSDT = 0;
    uint256 public totalAmountBUSD = 0;

    // sale setting
    uint256 public MAX_BUY_USDT = 1000 ether;
    uint256 public MIN_BUY_USDT = 0;
    uint256 public MAX_BUY_PSR = 1000 ether;
    uint256 public totalTokensSale;
    uint256 public remain;
    uint256 public whiteListSlots; // number of white list slot
    uint256 public waitingListSlots; // number of waiting list slot
    uint256 public startSale;
    uint256 public duration;
    uint256 public endingRegister;
    // price
    // token buy = usdt * denominator / numerator;
    // rate usdt / psr = numerator / denominator;
    uint256 public numerator = 1;
    uint256 public denominator = 1;

    address public operator;

    //control variable
    bool public isSetting = false;
    bool public isApprove = false;
    bool private isAdminWithdraw = false;

    //call when approve
    uint256 private currentApproval = 0;
    uint256 private base = 0;

    modifier allowBuy(address _currency, uint256 _amount) {
        require(block.timestamp >= startSale && block.timestamp <= startSale + duration, "Token not in sale");
        require(_currency == address(USDT) || _currency == address(BUSD), "Currency not allowed");
        require(_amount >= MIN_BUY_USDT, "purchase amount needs to be greater than MIM_BUY_USDT");
        _;
    }

    modifier inWhiteList() {
        require(whiteList.contains(msg.sender), "User not in white list");
        _;
    }

    modifier inWaitingList() {
        require(index[msg.sender] > base, "User not in waiting list");
        _;
    }

    modifier isWithdraw() {
        require(block.timestamp >= startSale + duration, "Not in time withdraw");
        require(isApprove, "Waiting list on buy time");
        _;
    }

    modifier isSettingTime() {
        require(!isSetting, "Contract has called setting");
        _;
        isSetting = true;
    }

    modifier isCallApprove() {
        require(!isApprove, "Contract has called approve");
        require(block.timestamp > startSale + duration, "Can not approve this time");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Only operator role can call function");
        _;
    }

    modifier allowRegister() {
        require(block.timestamp <= endingRegister || endingRegister == 0, "Can not register now");
        _;
    }


    // event
    event BuySuccess(address indexed user, uint256 indexed amount, uint256 indexed timestamp);
    event CommitSuccess(address indexed user, uint256 indexed amount, uint256 indexed timestamp);
    event ApproveWaitingBuy(address indexed user, uint256 indexed amount, uint256 indexed timestamp);
    event Claim(address indexed _to, uint256 indexed amount, uint256 indexed timestamp);
    event Withdraw(address indexed _to, uint256 indexed timestamp);
    event WhiteListChanged(address indexed user, bool status);
    event WaitingListChanged(address indexed user, bool status);
    event Registered(address indexed user);
    event OperatorChanged(address indexed oldOperator, address indexed newOperator);

    constructor(IERC20 _psr,IERC20 _usdt, IERC20 _busd, IVerifier _verifier) {
        PandoraSpirit = _psr;
        USDT = _usdt;
        BUSD = _busd;
        verifier = _verifier;
    }

    // ================= INTERNAL FUNCTIONS ================= //
    function _getAmountToken(uint256 _amountIn) internal view returns (uint256) {
        return _amountIn * denominator / numerator;
    }

    function _addWhiteList(address _user) internal {
        require(registerList.contains(_user), "User not in register list");
        require(!(index[_user] > base), "User already in waiting list");
        whiteList.add(_user);
        emit WhiteListChanged(_user, true);
    }

    function _addWaitingList(address _user) internal {
        require(registerList.contains(_user), "User not in register list");
        require(!whiteList.contains(_user), "User already in white list");
        if(index[_user] > base) return;
        waitingList.push(_user);
        index[_user] = waitingList.length;
        emit WaitingListChanged(_user, true);
    }

    function _approveWaitingList(uint256 _index) internal returns (bool isBreak) {
        WaitingInfo storage _info = waiting[waitingList[_index]];
        UserInfo storage _userInfo = userInfo[waitingList[_index]];

        isBreak = true;
        if(_getAmountToken(_info.amountBusd) >= remain ) {
            uint256 exceed = _info.amountBusd - remain * numerator / denominator;
            _userInfo.amountBusd += _info.amountBusd - exceed;
            _userInfo.amountUsdt = 0;
            _info.amountBusd = exceed;
        } else if(_getAmountToken(_info.amountUsdt) >= remain ) {
            uint256 exceed = _info.amountUsdt - remain * numerator / denominator;
            _userInfo.amountUsdt += _info.amountUsdt - exceed;
            _userInfo.amountBusd = 0;
            _info.amountUsdt = exceed;
        } else if(_getAmountToken(_info.amountBusd + _info.amountUsdt) >= remain ) {
            uint256 exceed = _info.amountBusd + _info.amountUsdt - remain * numerator / denominator;
            if(_info.amountBusd >= exceed) {
                _userInfo.amountBusd += _info.amountBusd - exceed;
                _userInfo.amountUsdt = _info.amountUsdt;
                _info.amountBusd = exceed;
                _info.amountUsdt = 0;
            } else {
                _userInfo.amountUsdt += _info.amountUsdt - exceed;
                _userInfo.amountBusd = _info.amountBusd;
                _info.amountUsdt = exceed;
                _info.amountBusd = 0;
            }
        } else {
            _userInfo.amountBusd += _info.amountBusd;
            _userInfo.amountUsdt += _info.amountUsdt;
            _info.amountUsdt = 0;
            _info.amountBusd = 0;
            isBreak = false;
        }

        _userInfo.totalToken = _getAmountToken(_userInfo.amountBusd + _userInfo.amountUsdt);
        totalAmountBUSD += _userInfo.amountBusd;
        totalAmountUSDT += _userInfo.amountUsdt;
        contributors.add(waitingList[_index]);
        remain -= _userInfo.totalToken;

        emit ApproveWaitingBuy(waitingList[_index], _userInfo.totalToken, block.timestamp);
    }

    function _buy(address _currency, uint256 _amount) internal {
        UserInfo storage _info = userInfo[msg.sender];
        require(_amount + _info.amountBusd + _info.amountUsdt <= MAX_BUY_USDT, "User buy overflow allowance");

        // transfer usd to contract
        IERC20(_currency).safeTransferFrom(msg.sender, address(this), _amount);

        // store info
        uint256 _amountPSR = _getAmountToken(_amount);
        // store number of usdt buy
        if(_currency == address(USDT)) {
            _info.amountUsdt += _amount;
            totalAmountUSDT += _amount;
        } else {
            _info.amountBusd += _amount;
            totalAmountBUSD += _amount;
        }
        //        _info.nextCliff = startSale + duration;
        _info.totalToken += _amountPSR;

        //update global
        remain -= _amountPSR;

        //add to contributors
        contributors.add(msg.sender);

        //event
        emit BuySuccess(msg.sender, _info.totalToken, block.timestamp);
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    // ================= EXTERNAL FUNCTIONS ================= //
    function settingPresale(
        uint256 _whitelistSlots,
        uint256 _waitingListSlots,
        uint256 _startSale,
        uint256 _duration,
        uint256 _numerator,
        uint256 _denominator,
        uint256 _maxBuy,
        uint256 _endingRegister
    )
    external
    onlyOperator
    isSettingTime
    {
        require(_startSale > block.timestamp, "_start sale in past");
        require(_startSale > _endingRegister, "_start sale can not before endingRegister");
        require(_endingRegister > block.timestamp, "__endingRegister in past");
        require(_numerator > 0 && _denominator > 0, "Price can not be zero");
        whiteListSlots = _whitelistSlots;
        waitingListSlots = _waitingListSlots;
        startSale = _startSale;
        duration = _duration;
        numerator = _numerator;
        denominator = _denominator;
        MAX_BUY_USDT = _maxBuy * 1 ether;
        MAX_BUY_PSR = _getAmountToken(MAX_BUY_USDT);
        totalTokensSale = _getAmountToken(MAX_BUY_USDT * whiteListSlots);
        remain = totalTokensSale;
        endingRegister = _endingRegister;
    }

    function setEndingRegister(uint256 _endingRegister) external onlyOperator {
        require(_endingRegister > block.timestamp && (_endingRegister < startSale || startSale == 0), "_endingRegister can not be after startSale");
        endingRegister = _endingRegister;
    }

    function addWhiteList(address[] memory _whiteList) external onlyOperator {
        require(_whiteList.length + whiteList.length() <= whiteListSlots, "white list overflow");
        require(block.timestamp < startSale, "Can not add white list after starting sale");
        for(uint i = 0; i < _whiteList.length; i++) {
            _addWhiteList(_whiteList[i]);
        }
    }

    function addWaitingList(address[] memory _waitingList) external onlyOperator{
        require(_waitingList.length + waitingList.length  <= waitingListSlots + base, "waiting list overflow");
        require(whiteList.length() == whiteListSlots, "Add white list first");
        require(block.timestamp < startSale, "Can not add waiting list after starting sale" );
        for(uint i = 0; i < _waitingList.length; i++) {
            _addWaitingList(_waitingList[i]);
        }
    }

    function buy(address _currency, uint256 _amount) public allowBuy(_currency, _amount) inWhiteList whenNotPaused nonReentrant {
        _buy(_currency, _amount);
    }

    // user in waiting list reserve slot to buy
    function reserveSlot(address _currency, uint256 _amount) public allowBuy(_currency, _amount) inWaitingList whenNotPaused nonReentrant {
        WaitingInfo storage _info = waiting[msg.sender];
        require(_amount + _info.amountBusd + _info.amountUsdt <= MAX_BUY_USDT, "User buy overflow allowance");

        // transfer usd to contract
        IERC20(_currency).safeTransferFrom(msg.sender, address(this), _amount);

        // update _info
        if(_currency == address(USDT)) {
            _info.amountUsdt += _amount;
        } else {
            _info.amountBusd += _amount;
        }

        //store user in list
        userReservation[index[msg.sender] - 1] = true;

        //emit event
        emit CommitSuccess(msg.sender, _amount, block.timestamp);
    }

    function approveWaitingList(uint256 _count) public isCallApprove {
        if(remain == 0) {
            isApprove = true;
            return;
        }
        if (currentApproval < base) {
            currentApproval = base;
        }
        uint256 _length = waitingList.length;
        uint256 _end = _min(currentApproval + _count, _length);
        for(uint256 i = currentApproval; i < _end; i++) {
            if(!userReservation[i]) continue;
            if(_approveWaitingList(i)) {
                isApprove = true;
                return;
            }
        }
        //update progress
        if( currentApproval + _count >= _length) {
            isApprove = true;
        } else {
            currentApproval = currentApproval + _count;
        }
    }

    function claim(address _to) public nonReentrant {
        require(_to != address(0), "address must be different 0");
        UserInfo storage _userInfo = userInfo[msg.sender];
        require(_userInfo.totalToken > 0 && !_userInfo.finish, "User not in list claim");
        (, bool finish, bool claimable, uint256 totalClaim, uint8 lastCliff) = verifier.verify(msg.sender, _userInfo.totalToken, _userInfo.status);
        require(claimable, "User can not claim now");
        if(finish) {
            _userInfo.finish = finish;
            totalClaim = _userInfo.totalToken - _userInfo.totalTokenClaim;
        }
        _userInfo.totalTokenClaim += totalClaim;
        _userInfo.status = lastCliff;
        require(_userInfo.totalTokenClaim <= _userInfo.totalToken, "Token claimed can not greater than total token");
        PandoraSpirit.safeTransfer(_to, totalClaim);
        emit Claim(_to, totalClaim, block.timestamp);
    }

    function withdraw() public isWithdraw nonReentrant {
        WaitingInfo storage _waitingInfo = waiting[msg.sender];
        require(_waitingInfo.amountUsdt > 0 || _waitingInfo.amountBusd > 0, "Don't have any fund");
        require(!_waitingInfo.isRefunded, "User have been refunded");

        if(_waitingInfo.amountUsdt > 0) {
            uint256 amountUsdt = _waitingInfo.amountUsdt;
            _waitingInfo.amountUsdt = 0;
            USDT.safeTransfer(msg.sender, amountUsdt);
        }

        if(_waitingInfo.amountBusd > 0) {
            uint256 amountBusd = _waitingInfo.amountBusd;
            _waitingInfo.amountBusd = 0;
            BUSD.safeTransfer(msg.sender, amountBusd);
        }
        _waitingInfo.isRefunded = true;
        emit Withdraw(msg.sender, block.timestamp);
    }

    function register() external allowRegister {
        bool added = registerList.add(msg.sender);
        require(added, "User has registered");
        emit Registered(msg.sender);
    }

    function removeUserInWhiteList(address[] memory _users) external onlyOperator {
        require(block.timestamp < startSale, "Can not remove white list after starting sale");
        uint256 _gap = 0;
        for(uint i = 0; i < _users.length; i++) {
            bool check = whiteList.remove(_users[i]);
            if ( i + base < waitingList.length && check) {
                //add waitingList to whiteList
                whiteList.add(waitingList[ i + base]);
                //remove user to waitingList
                index[waitingList[i]] = 0;
                _gap++;
                emit WaitingListChanged(waitingList[i], false);
            }
            emit WhiteListChanged(_users[i], false);
        }
        base = base + _gap;
    }

    //NOTE: function can consume more gas to update.
    function removeUserInWaitingList(uint256 _index) external onlyOperator {
        require(block.timestamp < startSale, "Can not remove waiting list after starting sale");
        require((base <= _index) && (_index < waitingList.length), "Out of range waiting list");

        //remove index
        address user = waitingList[_index];
        index[waitingList[_index]] = 0;

        //remove gap and delete
        for (uint i = _index; i < waitingList.length - 1; i++){
            waitingList[i] = waitingList[i+1];
            //update index
            index[waitingList[i]] = i + 1;
        }
        waitingList.pop();
        emit WaitingListChanged(user, false);
    }

    //NOTE: function can consume more gas to update.
    function updateWaitingListQueue(address _user, uint256 _newIndex) external onlyOperator {
        require(index[_user] > base, "User must be in waiting list");
        require((base <= _newIndex) && (_newIndex < waitingList.length), "User must be in waiting list");
        uint256 _index = index[_user] - 1;
        //update address affected
        if(_newIndex > _index) {
            for(uint i = _index; i < _newIndex; i++) {
                waitingList[i] = waitingList[i + 1];
                index[waitingList[i]] = i + 1;
            }
        } else {
            for(uint i = _index; i > _newIndex; i--) {
                waitingList[i] = waitingList[i - 1];
                index[waitingList[i]] = i + 1;
            }
        }
        waitingList[_newIndex] = _user;
        index[_user] = _newIndex + 1;
    }


    // ================= VIEWS FUNCTIONS ================= //
    function isRegistered(address _user) external view returns(bool) {
        return registerList.contains(_user);
    }

    function listRegister(uint256 _page, uint256 _limit) external view returns(address[] memory) {
        uint _from = _page * _limit;
        uint _to = _min((_page + 1) * _limit, registerList.length());
        address[] memory _result = new address[](_to - _from);
        for(uint i = 0; _from < _to; i++){
            _result[i] = registerList.at(_from);
            ++_from;
        }
        return _result;
    }

    function totalRegister() external view returns(uint256) {
        return registerList.length();
    }

    function isWhiteList(address _user) external view returns(bool) {
        return whiteList.contains(_user);
    }

    function whiteListUser(uint256 _page, uint256 _limit) external view returns(address[] memory) {
        uint _from = _page * _limit;
        uint _to = _min((_page + 1) * _limit, whiteList.length());
        address[] memory _result = new address[](_to - _from);
        for(uint i = 0; _from < _to; i++){
            _result[i] = whiteList.at(_from);
            ++_from;
        }
        return _result;
    }

    function totalWhiteList() external view returns(uint256) {
        return whiteList.length();
    }

    function isWaitingList(address _user) external view returns(bool) {
        return index[_user] > base;
    }

    function waitingListUser(uint256 _page, uint256 _limit) external view returns(address[] memory) {
        uint _from = _page * _limit + base;
        uint _to = _min((_page + 1) * _limit + base, waitingList.length);
        address[] memory _result = new address[](_to - _from);
        for(uint i = 0; _from < _to; i++){
            _result[i] = waitingList[_from];
            ++_from;
        }
        return _result;
    }

    function totalWaitingList() external view returns(uint256) {
        return waitingList.length - base;
    }

    function getAmountOfAllowBuying(address _user) external view returns(uint256) {
        return MAX_BUY_USDT - (userInfo[_user].amountUsdt + userInfo[_user].amountBusd);
    }

    function getAmountOfAllowWaiting(address _user) external view returns(uint256) {
        return MAX_BUY_USDT - (waiting[_user].amountUsdt + waiting[_user].amountBusd);
    }

    function waitingQueueNumber(address _user) external view returns (uint256) {
        return index[_user] - base;
    }

    function totalContributors() external view returns (uint256) {
        return contributors.length();
    }

    function getContributors(uint256 _page, uint256 _limit) external view returns (address[] memory) {
        uint _from = _page * _limit;
        uint _to = _min((_page + 1) * _limit, contributors.length());
        address[] memory _result = new address[](_to - _from);
        for(uint i = 0; _from < _to; i++){
            _result[i] = contributors.at(_from);
            ++_from;
        }
        return _result;
    }

    function getIndexWaitingList(address _user) external view returns(uint256) {
        return index[_user] - 1;
    }

    function getNumberOfTokenRequire(uint256 _index) external view returns(uint256 _amount) {
        if(remain > 0) {
            _amount = totalTokensSale - remain;
        } else {
            _amount = totalTokensSale;
        }
        (uint256 _percentage, , ) = verifier.getCliffInfo(_index);
        _amount = _amount * _percentage / verifier.ONE_HUNDRED_PERCENT();
    }

    function getTimeTGE() external view returns(uint256 _timestamp) {
        (,_timestamp,) = verifier.getCliffInfo(0);
    }


    // ================= ADMIN FUNCTIONS ================= //
    function emergencyWithdraw(address _to) external onlyOwner whenPaused {
        PandoraSpirit.safeTransfer(_to, PandoraSpirit.balanceOf(address(this)));
        USDT.safeTransfer(_to, USDT.balanceOf(address(this)));
        BUSD.safeTransfer(_to, BUSD.balanceOf(address(this)));
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    function withdrawAdmin(address _to) public onlyOwner {
        require(block.timestamp >= startSale + duration && isApprove && !isAdminWithdraw, "Can not withdraw before end");
        USDT.safeTransfer(_to, totalAmountUSDT);
        BUSD.safeTransfer(_to, totalAmountBUSD);
        isAdminWithdraw = true;
    }

    function setMinBuy(uint256 _value) public onlyOwner {
        require(_value <= MAX_BUY_USDT, "_value can not be greater than MAX_BUY_USDT");
        MIN_BUY_USDT = _value;
    }

    function setOperator(address _newOperator) public onlyOwner {
        require(_newOperator != address(0), "Operator must be different address 0");
        address oldOperator = operator;
        operator = _newOperator;
        emit OperatorChanged(oldOperator, _newOperator);
    }

    // ================= Testing ================= //
    function setWhiteListSlot(uint256 _newValue, bool _delete) public onlyOperator {
        whiteListSlots = _newValue;
        totalTokensSale = _getAmountToken(MAX_BUY_USDT * whiteListSlots);
        if(_delete) {
            uint _length = whiteList.length();
            uint i = _length;
            while(i > 0) {
                --i;
                whiteList.remove(whiteList.at(i));
            }
        }
    }

    function setWaitingListSlot(uint256 _newValue, bool _delete) public onlyOperator {
        waitingListSlots = _newValue;
        if(_delete) {
            delete waitingList;
        }
    }

    function setStartSale(uint256 _startSale) public onlyOperator {
        startSale = _startSale;
    }

    function setDuration(uint256 _duration) public onlyOperator {
        duration = _duration;
    }

    function setPrice(uint256 _numerator, uint256 _denominator) public onlyOperator {
        numerator = _numerator;
        denominator = _denominator;
        totalTokensSale = _getAmountToken(MAX_BUY_USDT * whiteListSlots);
        remain = totalTokensSale;
    }

    function setMaxBuy(uint256 _newValue) public onlyOperator {
        MAX_BUY_USDT = _newValue;
        totalTokensSale = _getAmountToken(MAX_BUY_USDT * whiteListSlots);
        remain = totalTokensSale;
    }

    function resetControl() public onlyOperator {
        isSetting = false;
        isApprove = false;
        isAdminWithdraw = false;
        totalAmountBUSD = 0;
        totalAmountUSDT = 0;
    }

    function setVerifier(IVerifier _newValue) public onlyOperator {
        verifier = _newValue;
    }

    function resetData(address _user) public onlyOperator {
        delete userInfo[_user];
        delete waiting[_user];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IVerifier {
    function verify(address _user, uint256 _totalToken, uint8 _claimTimes) external view returns(uint,bool,bool,uint,uint8);
    function totalCliff() external view returns (uint256);
    function getCliffInfo(uint256 _index) external view returns (uint256 _percentage, uint256 _timestamp, uint256 _proof);
    function ONE_HUNDRED_PERCENT() external view returns (uint256);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract MockERC20 is ERC20Burnable {
    constructor(
        string memory name,
        string memory symbol,
        address to,
        uint256 supply
    ) public ERC20(name, symbol) {
        _mint(to, supply);
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../interfaces/IPandoAssembly.sol";

contract PandoChest is Ownable, Pausable {
    using SafeERC20 for IERC20;

    mapping(address => bool) public operators;
    address public pandoAssembly;
    address public busd;
    address public pandoPool;
    uint256 public dailyDistributeAmount = 2000 ether; // 2000 USD/days
    uint256 public lastAllocatedTime;
    uint256 public minAllocateInterval = 23 * 1 hours;

    constructor (address _busd, address _pandoAssembly, address _pandoPool) {
        busd = _busd;
        pandoAssembly = _pandoAssembly;
        pandoPool = _pandoPool;
        operators[_pandoPool] = true;
        lastAllocatedTime = 0;
        init();
    }

    function init() public {
        IERC20(busd).safeApprove(pandoAssembly, type(uint256).max);
    }

    modifier onlyOperator() {
        // Try to make flash-loan exploit harder to do by only allowing externally owned addresses.
        require(operators[msg.sender] == true, "PandoChest: must be operator");
        _;
    }

    function allocateMoreRewards(uint256 _allocationAmount, uint256 _allocateDay) external onlyOperator whenNotPaused{
        require(_allocateDay > 0 && block.timestamp - lastAllocatedTime > minAllocateInterval, 'PandoChest: !invalid');
        lastAllocatedTime = block.timestamp;
        IERC20(busd).safeTransferFrom(pandoPool, address(this), _allocationAmount);
        IPandoAssembly(pandoAssembly).allocateMoreRewards(_allocationAmount, _allocateDay);

        if (IERC20(busd).balanceOf(address(this)) >= dailyDistributeAmount) {
            IERC20(busd).safeTransfer(pandoPool, dailyDistributeAmount);
        }
        emit RewardAllocated(_allocationAmount, _allocateDay);
    }

    function manualAllocate(uint256 _allocationAmount, uint256 _allocateDay) external onlyOwner{
        IPandoAssembly(pandoAssembly).allocateMoreRewards(_allocationAmount, _allocateDay);
        emit RewardAllocated(_allocationAmount, _allocateDay);
    }

    function emergencyWithdraw(address _token) external onlyOwner whenPaused {
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(_token, _amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setOperator(address _operator, bool _status) external onlyOwner {
        operators[_operator] = _status;
        emit OperatorChanged(_operator, _status);
    }

    function setPandoAssembly(address _pandoAssembly) external onlyOwner {
        address oldPandoAssembly = pandoAssembly;
        pandoAssembly = _pandoAssembly;
        emit PandoAssemblyChanged(oldPandoAssembly, _pandoAssembly);
    }


    function setMinAllocateInterval(uint256 _newValue) external onlyOwner {
        uint256 oldMinAllocateInterval = minAllocateInterval;
        minAllocateInterval = _newValue;
        emit MinAllocateIntervalChanged(minAllocateInterval, oldMinAllocateInterval);
    }

    function setDailyDistributeAmount(uint256 _amount) external onlyOwner {
        dailyDistributeAmount = _amount;
    }

    event RewardAllocated(uint256 _amount, uint256 _days);
    event MinAllocateIntervalChanged(uint256 newMinAllocateIntervalChanged, uint256 oldMinAllocateIntervalChanged);
    event EmergencyWithdraw(address token, uint256 amount);
    event OperatorChanged(address indexed operator, bool status);
    event PandoAssemblyChanged(address indexed oldPandoAssembly, address indexed newPandoAssembly);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../interfaces/IPandoChest.sol";

contract PandoPoolV2 is Ownable, Pausable {
    using SafeERC20 for IERC20;

    address public pandoChest;
    mapping(address => bool) public operators;
    mapping(address => uint256) public allocationDailyPercent;
    uint256 public constant ONE_HUNDRED_PERCENT = 10000;
    uint256 public minAllocateInterval = 23 * 1 hours;
    uint256 public lastAllocatedTime;
    uint256 public allocateDay;

    constructor (address[] memory _tokens, uint256[] memory _allocationDailyPercent) {
        lastAllocatedTime = 0;
        allocateDay = 1;

        require(_tokens.length == _allocationDailyPercent.length);
        for(uint256 i; i < _tokens.length;i++){
            allocationDailyPercent[_tokens[i]] = _allocationDailyPercent[i];
        }
    }

    modifier onlyOperator() {
        // Try to make flash-loan exploit harder to do by only allowing externally owned addresses.
        require(operators[msg.sender] == true, "PandoPool: must be operator");
        _;
    }

    function allocateReward(address[] memory _tokens) external onlyOperator whenNotPaused{
        require(allocateDay > 0 && block.timestamp - lastAllocatedTime > minAllocateInterval, 'PandoPot: !invalid');
        lastAllocatedTime = block.timestamp;
        uint256[] memory _allocationAmounts = new uint256[](_tokens.length);
        for(uint256 i; i < _tokens.length;i++){
            address _token = _tokens[i];
            uint256 _balance = IERC20(_token).balanceOf(address(this));
            uint256 _allocationAmount = _balance * allocationDailyPercent[_token] / ONE_HUNDRED_PERCENT;
            _allocationAmounts[i] = _allocationAmount;
            IERC20(_token).approve(pandoChest, _allocationAmount);
        }
        IPandoChest(pandoChest).allocateMoreRewards(_tokens,_allocationAmounts, allocateDay);
        emit RewardAllocated(_tokens,_allocationAmounts, allocateDay);
    }

    function emergencyWithdraw(address _token) external onlyOwner whenPaused {
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(_token, _amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setOperator(address _operator, bool _status) external onlyOwner {
        operators[_operator] = _status;
        emit OperatorChanged(_operator, _status);
    }

    function setPandoChest(address _pandoChest) external onlyOwner {
        address oldPandoChest = pandoChest;
        pandoChest = _pandoChest;
        emit PandoChestChanged(oldPandoChest, _pandoChest);
    }

    function setAllocationPercent(address _token, uint256 _allocationDailyPercent) external onlyOwner {
        uint256 oldAllocationDailyPercent = allocationDailyPercent[_token];
        allocationDailyPercent[_token] = _allocationDailyPercent;
        emit AllocationPercentChanged(_token, oldAllocationDailyPercent, _allocationDailyPercent);
    }

    function setMinAllocateInterval(uint256 _newValue) external onlyOwner {
        uint256 oldMinAllocateInterval = minAllocateInterval;
        minAllocateInterval = _newValue;
        emit MinAllocateIntervalChanged(minAllocateInterval, oldMinAllocateInterval);
    }

    function setAllocateDay(uint256 _newValue) external onlyOwner {
        uint256 oldtAllocateDay = allocateDay;
        allocateDay = _newValue;
        emit AllocateDayChanged(allocateDay, oldtAllocateDay);
    }

    event RewardAllocated(address[] indexed _tokens, uint256[] _amounts,uint256 _days);
    event MinAllocateIntervalChanged(uint256 newMinAllocateIntervalChanged, uint256 oldMinAllocateIntervalChanged);
    event AllocateDayChanged(uint256 newAllocateDayChanged, uint256 oldAllocateDayChanged);
    event EmergencyWithdraw(address token, uint256 amount);
    event OperatorChanged(address indexed operator, bool status);
    event PandoChestChanged(address indexed oldPandoAssembly, address indexed newPandoAssembly);
    event AllocationPercentChanged(address indexed token,uint256 oldAllocationDailyPercent, uint256 newAllocationDailyPercent);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IPandoChest {
    function allocateMoreRewards(address[] memory,uint256[] memory,uint256) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IMinter.sol";
import "../interfaces/IUserLevel.sol";

contract Staking_PAN is Ownable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 bonus;
        int256 rewardDebt;
    }

    IERC20 public PAN;
    IMinter public minter;
    IUserLevel public userLevel;

    // governance
    address public reserveFund;

    uint256 public accRewardPerShare;
    uint256 public lastRewardBlock;
    uint256 public startRewardBlock;
    uint256 public totalBonus;

    uint256 public rewardPerBlock;
    uint256 private constant ACC_REWARD_PRECISION = 1e12;

    mapping (address => UserInfo) public userInfo;

    /* ========== Modifiers =============== */


    constructor(IERC20 _PAN, IMinter _minter, uint256 _startReward, uint256 _rewardPerBlock) {
        PAN = _PAN;
        lastRewardBlock = _startReward;
        startRewardBlock = _startReward;
        rewardPerBlock = _rewardPerBlock;
        minter = IMinter(_minter);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function getBonus(uint256 _value, address account) internal view returns(uint256) {
        if (address(userLevel) != address(0)) {
            (uint256 _n, uint256 _d) = userLevel.getBonus(account, address(this));
            return _value * _n / _d;
        }
        return 0;
    }

    function _update(address account) internal {
        UserInfo storage user = userInfo[account];
        uint256 _oldBonus = user.bonus;
        uint256 _newBonus = getBonus(user.amount, account);
        if (_newBonus > _oldBonus) {
            user.rewardDebt += int256((_newBonus - _oldBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            totalBonus += _newBonus - _oldBonus;
        } else {
            user.rewardDebt -= int256((_oldBonus - _newBonus) * accRewardPerShare / ACC_REWARD_PRECISION);
            totalBonus -= _oldBonus - _newBonus;
        }
        user.bonus = _newBonus;
    }

    function totalLp() internal view  returns(uint256) {
        return PAN.balanceOf(address(this)) + totalBonus;
    }
    /* ========== PUBLIC FUNCTIONS ========== */

    /// @notice View function to see pending reward on frontend.
    /// @param _user Address of user.
    /// @return pending reward for a given user.
    function pendingReward(address _user) external view returns (uint256 pending) {
        UserInfo storage user = userInfo[_user];
        uint256 supply = totalLp();
        uint256 _accRewardPerShare = accRewardPerShare;
        if (block.number > lastRewardBlock && supply != 0) {
            uint256 rewardAmount = (block.number - lastRewardBlock) * rewardPerBlock;
            _accRewardPerShare += (rewardAmount * ACC_REWARD_PRECISION) / supply;
        }
        pending = uint256(int256((user.amount + user.bonus) * _accRewardPerShare / ACC_REWARD_PRECISION) - user.rewardDebt);
    }

    /// @notice Update reward variables of the given pool.
    function updatePool() public {
        if (block.number > lastRewardBlock) {
            uint256 supply = totalLp();
            if (supply > 0 && block.number > lastRewardBlock) {
                uint256 rewardAmount = (block.number - lastRewardBlock) * rewardPerBlock;
                accRewardPerShare += rewardAmount * ACC_REWARD_PRECISION / supply;
            }
            lastRewardBlock = block.number;
            emit LogUpdatePool(lastRewardBlock, supply, accRewardPerShare);
        }
    }

    /// @notice Deposit LP tokens to MCV2 for reward allocation.
    /// @param amount LP token amount to deposit.
    /// @param to The receiver of `amount` deposit benefit.
    function deposit(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[to];

        // Effects
        user.amount += amount;
        user.rewardDebt += int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);

        PAN.safeTransferFrom(msg.sender, address(this), amount);
        _update(msg.sender);
        emit Deposit(msg.sender, amount, to);
    }

    /// @notice Withdraw LP tokens from MCV2.
    /// @param amount LP token amount to withdraw.
    /// @param to Receiver of the LP tokens.
    function withdraw(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];

        // Effects
        user.rewardDebt -= int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);
        user.amount -= amount;

        _update(msg.sender);
        PAN.safeTransfer(to, amount);

        emit Withdraw(msg.sender, amount, to);
    }

    /// @notice Harvest proceeds for transaction sender to `to`.
    /// @param to Receiver of rewards.
    function harvest(address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedReward = int256((user.amount + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedReward;

        // Interactions
        if (_pendingReward > 0) {
            minter.transfer(to, _pendingReward);
        }
        emit Harvest(msg.sender, _pendingReward);
    }

    /// @notice Withdraw LP tokens from MCV2 and harvest proceeds for transaction sender to `to`.
    /// @param amount LP token amount to withdraw.
    /// @param to Receiver of the LP tokens and rewards.
    function withdrawAndHarvest(uint256 amount, address to) public {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        int256 accumulatedReward = int256((user.amount + user.bonus) * accRewardPerShare / ACC_REWARD_PRECISION);
        uint256 _pendingReward = uint256(accumulatedReward - user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedReward - int256(amount * accRewardPerShare / ACC_REWARD_PRECISION);
        user.amount -= amount;

        // Interactions
        if (_pendingReward > 0) {
            minter.transfer(to, _pendingReward);
        }

        _update(msg.sender);
        PAN.safeTransfer(to, amount);

        emit Withdraw(msg.sender, amount, to);
        emit Harvest(msg.sender, _pendingReward);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    /// @param to Receiver of the LP tokens.
    function emergencyWithdraw(address to) public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        // Note: transfer can fail or succeed if `amount` is zero.
        PAN.safeTransfer(to, amount);
        emit EmergencyWithdraw(msg.sender, amount, to);
    }

    function update(address owner) public {
        updatePool();
        _update(owner);
    }

    function getUserInfo(address user) external view returns(UserInfo memory info) {
        info = userInfo[user];
    }
    /* ========== RESTRICTED FUNCTIONS ========== */

    /// @notice Sets the reward per second to be distributed. Can only be called by the owner.
    /// @param _rewardPerBlock The amount of reward to be distributed per second.
    function setRewardPerBlock(uint256 _rewardPerBlock) public onlyOwner {
        updatePool();
        uint256 oldRewardPerBlock = rewardPerBlock;
        rewardPerBlock = _rewardPerBlock;
        emit RewardPerBlockChanged(oldRewardPerBlock, _rewardPerBlock);
    }

    function changeMinter(address _newMinter) external onlyOwner {
        address oldMinter = address(minter);
        minter = IMinter(_newMinter);
        emit MinterChanged(oldMinter, _newMinter);
    }

    function setUserLevelAddress(address _userLevel) external onlyOwner {
        userLevel = IUserLevel(_userLevel);
        emit UserLevelChanged(_userLevel);
    }

    /* =============== EVENTS ==================== */

    event Deposit(address indexed user, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 amount);
    event LogUpdatePool(uint256 lastRewardBlock, uint256 lpSupply, uint256 accRewardPerShare);
    event RewardPerBlockChanged(uint256 oldRewardPerBlock, uint256 newRewardPerBlock);
    event FundRescued(address indexed receiver, uint256 amount);
    event MinterChanged(address indexed oldMinter, address indexed newMinter);
    event UserLevelChanged(address indexed userLevel);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IPandoPot.sol";

contract RandomNumberGenerator is VRFConsumerBaseV2, Ownable {
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINK_TOKEN;

    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    address link_token_contract = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;
    bytes32 keyHash = 0x17cd473250a9a479dc7f234c64332ed4bc8af9e8ded7556aa6e66d83da49f470;

    // A reasonable default is 100000, but this value could be different on other networks.
    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;
    uint32 public numWords = 3;

    uint256 constant PRECISION = 1e20;

    // Storage parameters

    uint256 public s_requestId;
    uint64 private s_subscriptionId;
    IPandoPot public pandoPot;
    address public operator;
    uint256 public lastUpdateResult;

    mapping(uint256 => uint256[]) public numbers;
    uint256[] public curNumbers;

    bool public lockFullFill = true;
    uint256 public currentRoundId;

    constructor(address _pandoPot) VRFConsumerBaseV2(vrfCoordinator) {
        pandoPot = IPandoPot(_pandoPot);
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINK_TOKEN = LinkTokenInterface(link_token_contract);
        //Create a new subscription when you deploy the contract.
        createNewSubscription();
        curNumbers = [0, 0, 0];
        operator = msg.sender;
        lockFullFill = false;
    }

    modifier onlyOperator {
        require(msg.sender == operator, 'RandomNumberGenerator: !operator');
        _;
    }

    /* ========== EXTERNAL FUNCTIONS ========== */
    function getNumber(uint256 _roundId) external view returns(uint256[] memory) {
        if (_roundId == currentRoundId) {
            return curNumbers;
        }
        return (numbers[_roundId]);
    }

    /* ========== INTERNAL FUNCTIONS ========== */
    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        curNumbers = randomWords;
        lastUpdateResult = block.timestamp;
        lockFullFill = false;
    }

    function setLockFullFill(bool status) external onlyOperator{
        lockFullFill = status;
    }

    // Create a new subscription when the contract is initially deployed.
    function createNewSubscription() internal {
        // Create a subscription with a new subscription ID.
        address[] memory consumers = new address[](1);
        consumers[0] = address(this);
        s_subscriptionId = COORDINATOR.createSubscription();
        // Add this contract as a consumer of its own subscription.
        COORDINATOR.addConsumer(s_subscriptionId, consumers[0]);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */
    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external onlyOperator {
        // Will revert if subscription is not set and funded.
        require(!lockFullFill, "RNG: Waiting for full fill!");
        require(block.timestamp >= lastUpdateResult + pandoPot.getRoundDuration(), 'RNG: < roundDuration');
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        numbers[currentRoundId] = curNumbers;
        pandoPot.updatePandoPot();
        pandoPot.finishRound();
        currentRoundId++;
        lockFullFill = true;
    }

    // Assumes this contract owns link.
    // 1000000000000000000 = 1 LINK
    function topUpSubscription(uint256 amount) external onlyOwner {
        LINK_TOKEN.transferAndCall(address(COORDINATOR), amount, abi.encode(s_subscriptionId));
    }

    function cancelSubscription(address receivingWallet) external onlyOwner {
        // Cancel the subscription and send the remaining LINK to a wallet address.
        COORDINATOR.cancelSubscription(s_subscriptionId, receivingWallet);
        s_subscriptionId = 0;
    }

    // Transfer this contract's funds to an address.
    // 1000000000000000000 = 1 LINK
    function withdraw(uint256 amount, address to) external onlyOwner {
        LINK_TOKEN.transfer(to, amount);
    }

    function changePandoPot(address _pandoPot) external onlyOwner {
        address _oldPandoPot = address(pandoPot);
        pandoPot = IPandoPot(_pandoPot);
        emit PandoPotChanged(_oldPandoPot, _pandoPot);
    }

    function changeRoundId(uint256 _roundId) external onlyOwner {
        require(currentRoundId > _roundId, 'RNG: cur < roundID');
        currentRoundId = _roundId;
    }

    function setOperator(address _newOperator) external onlyOwner {
        address _oldOperator = operator;
        operator = _newOperator;
        emit OperatorChanged(_oldOperator, _newOperator);
    }

    event OperatorChanged(address oldOperator, address newOperator);
    event PandoPotChanged(address oldPandoPot, address newPandoPot);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

pragma solidity ^0.8.0;
import "../interfaces/IPandoPot.sol";
contract MockRNG {
    IPandoPot public pandoPot;
    uint256[] public s_randomWords = [
    85043179478089809626806064256264325091479652846362056406846085550471972349265,
    78978907195286932707553577998998163929008979459432747155555797801905064452157,
    70753885951753179799505076745705261078202852830773515697963132860201859012276,
    100862563449325298120828748489117532195944519144389870225893980063467188442053,
    111825487233298883927608518429776713106378090045673489558542111826549636839851,
    25055244386446540787368706638829020317480017361398358047295598806307558451841
    ];
    uint256 public lastUpdateResult;
    uint256 numWords = 10;

    constructor(address _pandoPot){
        pandoPot = IPandoPot(_pandoPot);
        lastUpdateResult = block.timestamp;
        for(uint256 i = 0; i < numWords; i++){
            s_randomWords.push(_random(block.timestamp * i + block.timestamp));
        }
    }

    function _random(uint number) internal returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty, block.number, blockhash(block.number-1), tx.origin))) % number;
    }

    function getNumber() external view returns(uint256, uint256, uint256) {
        return (s_randomWords[0], s_randomWords[1], s_randomWords[2]);
    }

    function getNumber(uint256 _roundId) external view returns(uint256[] memory) {
        return s_randomWords;
    }

    function setResultNumber(uint[] memory data) external {
        delete s_randomWords;
        for(uint i = 0; i < data.length; i++) {
            s_randomWords.push(data[i]);
        }

        for(uint i = 0; i < numWords - data.length; i++) {
            s_randomWords.push(_random(block.timestamp * i + block.timestamp));
        }
    }

    function clearNumber() external {
        delete s_randomWords;
    }

    function requestRandomWords() public{
        require(block.timestamp >= lastUpdateResult + pandoPot.getRoundDuration(), 'RNG: < roundDuration');
        pandoPot.updatePandoPot();
        if(s_randomWords.length < numWords){
            for(uint i = 0; i < numWords - s_randomWords.length; i++) {
                s_randomWords.push(_random(block.timestamp * i + block.timestamp));
            }
        }
        fulfillRandomWords();
    }

    function fulfillRandomWords() internal {
        pandoPot.finishRound();
        lastUpdateResult = block.timestamp;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "../interfaces/IOracle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MultiOracle is Ownable {
    mapping (address => address) public oracles;
    mapping (address => bool) public tradingPair;

    function setOracle(address _token, address _oracle) external onlyOwner{
        address oldOracle = oracles[_token];
        oracles[_token] = _oracle;
        emit OracleChanged(_token, oldOracle, _oracle);
    }

    function setTradingPair(address _pair, bool status) external onlyOwner{
        tradingPair[_pair] = status;
        emit TradingPairChanged(_pair, status);
    }

    function consult(address _token) external view returns(uint256) {
        address oracle = oracles[_token];
        if (oracle != address (0)) {
            return IOracle(oracle).consult();
        }
        return 0;
    }

    event OracleChanged(address indexed _token, address indexed oldOracle, address indexed newOracle);
    event TradingPairChanged(address pair, bool status);
}