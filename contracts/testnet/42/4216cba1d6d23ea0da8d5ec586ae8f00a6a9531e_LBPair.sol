// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

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
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
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
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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

        /// @solidity memory-safe-assembly
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

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./interfaces/ILBPair.sol";

/** LBRouter errors */

error LBRouter__SenderIsNotWAVAX();
error LBRouter__PairNotCreated(address tokenX, address tokenY, uint256 binStep);
error LBRouter__WrongAmounts(uint256 amount, uint256 reserve);
error LBRouter__SwapOverflows(uint256 id);
error LBRouter__BrokenSwapSafetyCheck();
error LBRouter__NotFactoryOwner();
error LBRouter__TooMuchTokensIn(uint256 excess);
error LBRouter__BinReserveOverflows(uint256 id);
error LBRouter__IdOverflows(int256 id);
error LBRouter__LengthsMismatch();
error LBRouter__WrongTokenOrder();
error LBRouter__IdSlippageCaught(uint256 activeIdDesired, uint256 idSlippage, uint256 activeId);
error LBRouter__AmountSlippageCaught(uint256 amountXMin, uint256 amountX, uint256 amountYMin, uint256 amountY);
error LBRouter__IdDesiredOverflows(uint256 idDesired, uint256 idSlippage);
error LBRouter__FailedToSendAVAX(address recipient, uint256 amount);
error LBRouter__DeadlineExceeded(uint256 deadline, uint256 currentTimestamp);
error LBRouter__AmountSlippageBPTooBig(uint256 amountSlippage);
error LBRouter__InsufficientAmountOut(uint256 amountOutMin, uint256 amountOut);
error LBRouter__MaxAmountInExceeded(uint256 amountInMax, uint256 amountIn);
error LBRouter__InvalidTokenPath(address wrongToken);
error LBRouter__InvalidVersion(uint256 version);
error LBRouter__WrongAvaxLiquidityParameters(
    address tokenX,
    address tokenY,
    uint256 amountX,
    uint256 amountY,
    uint256 msgValue
);

/** LBToken errors */

error LBToken__SpenderNotApproved(address owner, address spender);
error LBToken__TransferFromOrToAddress0();
error LBToken__MintToAddress0();
error LBToken__BurnFromAddress0();
error LBToken__BurnExceedsBalance(address from, uint256 id, uint256 amount);
error LBToken__LengthMismatch(uint256 accountsLength, uint256 idsLength);
error LBToken__SelfApproval(address owner);
error LBToken__TransferExceedsBalance(address from, uint256 id, uint256 amount);
error LBToken__TransferToSelf();

/** LBFactory errors */

error LBFactory__IdenticalAddresses(IERC20 token);
error LBFactory__QuoteAssetNotWhitelisted(IERC20 quoteAsset);
error LBFactory__QuoteAssetAlreadyWhitelisted(IERC20 quoteAsset);
error LBFactory__AddressZero();
error LBFactory__LBPairAlreadyExists(IERC20 tokenX, IERC20 tokenY, uint256 _binStep);
error LBFactory__LBPairNotCreated(IERC20 tokenX, IERC20 tokenY, uint256 binStep);
error LBFactory__DecreasingPeriods(uint16 filterPeriod, uint16 decayPeriod);
error LBFactory__ReductionFactorOverflows(uint16 reductionFactor, uint256 max);
error LBFactory__VariableFeeControlOverflows(uint16 variableFeeControl, uint256 max);
error LBFactory__BaseFeesBelowMin(uint256 baseFees, uint256 minBaseFees);
error LBFactory__FeesAboveMax(uint256 fees, uint256 maxFees);
error LBFactory__FlashLoanFeeAboveMax(uint256 fees, uint256 maxFees);
error LBFactory__BinStepRequirementsBreached(uint256 lowerBound, uint16 binStep, uint256 higherBound);
error LBFactory__ProtocolShareOverflows(uint16 protocolShare, uint256 max);
error LBFactory__FunctionIsLockedForUsers(address user);
error LBFactory__FactoryLockIsAlreadyInTheSameState();
error LBFactory__LBPairIgnoredIsAlreadyInTheSameState();
error LBFactory__BinStepHasNoPreset(uint256 binStep);
error LBFactory__SameFeeRecipient(address feeRecipient);
error LBFactory__SameFlashLoanFee(uint256 flashLoanFee);
error LBFactory__LBPairSafetyCheckFailed(address LBPairImplementation);
error LBFactory__SameImplementation(address LBPairImplementation);
error LBFactory__ImplementationNotSet();

/** LBPair errors */

error LBPair__InsufficientAmounts();
error LBPair__AddressZero();
error LBPair__AddressZeroOrThis();
error LBPair__CompositionFactorFlawed(uint256 id);
error LBPair__InsufficientLiquidityMinted(uint256 id);
error LBPair__InsufficientLiquidityBurned(uint256 id);
error LBPair__WrongLengths();
error LBPair__OnlyStrictlyIncreasingId();
error LBPair__OnlyFactory();
error LBPair__DistributionsOverflow();
error LBPair__OnlyFeeRecipient(address feeRecipient, address sender);
error LBPair__OracleNotEnoughSample();
error LBPair__AlreadyInitialized();
error LBPair__OracleNewSizeTooSmall(uint256 newSize, uint256 oracleSize);
error LBPair__FlashLoanCallbackFailed();
error LBPair__FlashLoanInvalidBalance();
error LBPair__FlashLoanInvalidToken();

/** BinHelper errors */

error BinHelper__BinStepOverflows(uint256 bp);
error BinHelper__IdOverflows();

/** Math128x128 errors */

error Math128x128__PowerUnderflow(uint256 x, int256 y);
error Math128x128__LogUnderflow();

/** Math512Bits errors */

error Math512Bits__MulDivOverflow(uint256 prod1, uint256 denominator);
error Math512Bits__ShiftDivOverflow(uint256 prod1, uint256 denominator);
error Math512Bits__MulShiftOverflow(uint256 prod1, uint256 offset);
error Math512Bits__OffsetOverflows(uint256 offset);

/** Oracle errors */

error Oracle__AlreadyInitialized(uint256 _index);
error Oracle__LookUpTimestampTooOld(uint256 _minTimestamp, uint256 _lookUpTimestamp);
error Oracle__NotInitialized();

/** PendingOwnable errors */

error PendingOwnable__NotOwner();
error PendingOwnable__NotPendingOwner();
error PendingOwnable__PendingOwnerAlreadySet();
error PendingOwnable__NoPendingOwner();
error PendingOwnable__AddressZero();

/** ReentrancyGuardUpgradeable errors */

error ReentrancyGuardUpgradeable__ReentrantCall();
error ReentrancyGuardUpgradeable__AlreadyInitialized();

/** SafeCast errors */

error SafeCast__Exceeds256Bits(uint256 x);
error SafeCast__Exceeds248Bits(uint256 x);
error SafeCast__Exceeds240Bits(uint256 x);
error SafeCast__Exceeds232Bits(uint256 x);
error SafeCast__Exceeds224Bits(uint256 x);
error SafeCast__Exceeds216Bits(uint256 x);
error SafeCast__Exceeds208Bits(uint256 x);
error SafeCast__Exceeds200Bits(uint256 x);
error SafeCast__Exceeds192Bits(uint256 x);
error SafeCast__Exceeds184Bits(uint256 x);
error SafeCast__Exceeds176Bits(uint256 x);
error SafeCast__Exceeds168Bits(uint256 x);
error SafeCast__Exceeds160Bits(uint256 x);
error SafeCast__Exceeds152Bits(uint256 x);
error SafeCast__Exceeds144Bits(uint256 x);
error SafeCast__Exceeds136Bits(uint256 x);
error SafeCast__Exceeds128Bits(uint256 x);
error SafeCast__Exceeds120Bits(uint256 x);
error SafeCast__Exceeds112Bits(uint256 x);
error SafeCast__Exceeds104Bits(uint256 x);
error SafeCast__Exceeds96Bits(uint256 x);
error SafeCast__Exceeds88Bits(uint256 x);
error SafeCast__Exceeds80Bits(uint256 x);
error SafeCast__Exceeds72Bits(uint256 x);
error SafeCast__Exceeds64Bits(uint256 x);
error SafeCast__Exceeds56Bits(uint256 x);
error SafeCast__Exceeds48Bits(uint256 x);
error SafeCast__Exceeds40Bits(uint256 x);
error SafeCast__Exceeds32Bits(uint256 x);
error SafeCast__Exceeds24Bits(uint256 x);
error SafeCast__Exceeds16Bits(uint256 x);
error SafeCast__Exceeds8Bits(uint256 x);

/** TreeMath errors */

error TreeMath__ErrorDepthSearch();

/** JoeLibrary errors */

error JoeLibrary__IdenticalAddresses();
error JoeLibrary__AddressZero();
error JoeLibrary__InsufficientAmount();
error JoeLibrary__InsufficientLiquidity();

/** TokenHelper errors */

error TokenHelper__NonContract();
error TokenHelper__CallFailed();
error TokenHelper__TransferFailed();

/** LBQuoter errors */

error LBQuoter_InvalidLength();

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/** Imports **/

import "./LBErrors.sol";
import "./LBToken.sol";
import "./libraries/BinHelper.sol";
import "./libraries/Constants.sol";
import "./libraries/Decoder.sol";
import "./libraries/FeeDistributionHelper.sol";
import "./libraries/Math512Bits.sol";
import "./libraries/Oracle.sol";
import "./libraries/ReentrancyGuardUpgradeable.sol";
import "./libraries/SafeCast.sol";
import "./libraries/SafeMath.sol";
import "./libraries/SwapHelper.sol";
import "./libraries/TokenHelper.sol";
import "./libraries/TreeMath.sol";
import "./interfaces/ILBPair.sol";

/// @title Liquidity Book Pair
/// @author Trader Joe
/// @notice This contract is the implementation of Liquidity Book Pair that also acts as the receipt token for liquidity positions
contract LBPair is LBToken, ReentrancyGuardUpgradeable, ILBPair {
    /** Libraries **/

    using Math512Bits for uint256;
    using TreeMath for mapping(uint256 => uint256)[3];
    using SafeCast for uint256;
    using SafeMath for uint256;
    using TokenHelper for IERC20;
    using FeeHelper for FeeHelper.FeeParameters;
    using SwapHelper for Bin;
    using Decoder for bytes32;
    using FeeDistributionHelper for FeeHelper.FeesDistribution;
    using Oracle for bytes32[65_535];

    /** Modifiers **/

    /// @notice Checks if the caller is the factory
    modifier onlyFactory() {
        if (msg.sender != address(factory)) revert LBPair__OnlyFactory();
        _;
    }

    /** Public immutable variables **/

    /// @notice The factory contract that created this pair
    ILBFactory public immutable override factory;

    /** Public variables **/

    /// @notice The token that is used as the base currency for the pair
    IERC20 public override tokenX;

    /// @notice The token that is used as the quote currency for the pair
    IERC20 public override tokenY;

    /** Private variables **/

    /// @dev The pair information that is used to track reserves, active ids,
    /// fees and oracle parameters
    PairInformation private _pairInformation;

    /// @dev The fee parameters that are used to calculate fees
    FeeHelper.FeeParameters private _feeParameters;

    /// @dev The reserves of tokens for every bin. This is the amount
    /// of tokenY if `id < _pairInformation.activeId`; of tokenX if `id > _pairInformation.activeId`
    /// and a mix of both if `id == _pairInformation.activeId`
    mapping(uint256 => Bin) private _bins;

    /// @dev Tree to find bins with non zero liquidity

    /// @dev The tree that is used to find the first bin with non zero liquidity
    mapping(uint256 => uint256)[3] private _tree;

    /// @dev The mapping from account to user's unclaimed fees. The first 128 bits are tokenX and the last are for tokenY
    mapping(address => bytes32) private _unclaimedFees;

    /// @dev The mapping from account to id to user's accruedDebt
    mapping(address => mapping(uint256 => Debts)) private _accruedDebts;

    /// @dev The oracle samples that are used to calculate the time weighted average data
    bytes32[65_535] private _oracle;

    /** OffSets */

    uint256 private constant _OFFSET_PAIR_RESERVE_X = 24;
    uint256 private constant _OFFSET_PROTOCOL_FEE = 128;
    uint256 private constant _OFFSET_BIN_RESERVE_Y = 112;
    uint256 private constant _OFFSET_VARIABLE_FEE_PARAMETERS = 144;
    uint256 private constant _OFFSET_ORACLE_SAMPLE_LIFETIME = 136;
    uint256 private constant _OFFSET_ORACLE_SIZE = 152;
    uint256 private constant _OFFSET_ORACLE_ACTIVE_SIZE = 168;
    uint256 private constant _OFFSET_ORACLE_LAST_TIMESTAMP = 184;
    uint256 private constant _OFFSET_ORACLE_ID = 224;

    /** Constructor **/

    /// @notice Set the factory address
    /// @param _factory The address of the factory
    constructor(ILBFactory _factory) LBToken() {
        if (address(_factory) == address(0)) revert LBPair__AddressZero();
        factory = _factory;
    }

    /// @notice Initialize the parameters of the LBPair
    /// @dev The different parameters needs to be validated very cautiously
    /// It is highly recommended to never call this function directly, use the factory
    /// as it validates the different parameters
    /// @param _tokenX The address of the tokenX. Can't be address 0
    /// @param _tokenY The address of the tokenY. Can't be address 0
    /// @param _activeId The active id of the pair
    /// @param _sampleLifetime The lifetime of a sample. It's the min time between 2 oracle's sample
    /// @param _packedFeeParameters The fee parameters packed in a single 256 bits slot
    function initialize(
        IERC20 _tokenX,
        IERC20 _tokenY,
        uint24 _activeId,
        uint16 _sampleLifetime,
        bytes32 _packedFeeParameters
    ) external override onlyFactory {
        if (address(_tokenX) == address(0) || address(_tokenY) == address(0)) revert LBPair__AddressZero();
        if (address(tokenX) != address(0)) revert LBPair__AlreadyInitialized();

        __ReentrancyGuard_init();

        tokenX = _tokenX;
        tokenY = _tokenY;

        _pairInformation.activeId = _activeId;
        _pairInformation.oracleSampleLifetime = _sampleLifetime;

        _setFeesParameters(_packedFeeParameters);
        _increaseOracle(2);
    }

    /** External View Functions **/

    /// @notice View function to get the reserves and active id
    /// @return reserveX The reserve of asset X
    /// @return reserveY The reserve of asset Y
    /// @return activeId The active id of the pair
    function getReservesAndId()
        external
        view
        override
        returns (
            uint256 reserveX,
            uint256 reserveY,
            uint256 activeId
        )
    {
        return _getReservesAndId();
    }

    /// @notice View function to get the total fees and the protocol fees of each tokens
    /// @return feesXTotal The total fees of tokenX
    /// @return feesYTotal The total fees of tokenY
    /// @return feesXProtocol The protocol fees of tokenX
    /// @return feesYProtocol The protocol fees of tokenY
    function getGlobalFees()
        external
        view
        override
        returns (
            uint128 feesXTotal,
            uint128 feesYTotal,
            uint128 feesXProtocol,
            uint128 feesYProtocol
        )
    {
        return _getGlobalFees();
    }

    /// @notice View function to get the oracle parameters
    /// @return oracleSampleLifetime The lifetime of a sample, it accumulates information for up to this timestamp
    /// @return oracleSize The size of the oracle (last ids can be empty)
    /// @return oracleActiveSize The active size of the oracle (no empty data)
    /// @return oracleLastTimestamp The timestamp of the creation of the oracle's latest sample
    /// @return oracleId The index of the oracle's latest sample
    /// @return min The min delta time of two samples
    /// @return max The safe max delta time of two samples
    function getOracleParameters()
        external
        view
        override
        returns (
            uint256 oracleSampleLifetime,
            uint256 oracleSize,
            uint256 oracleActiveSize,
            uint256 oracleLastTimestamp,
            uint256 oracleId,
            uint256 min,
            uint256 max
        )
    {
        (oracleSampleLifetime, oracleSize, oracleActiveSize, oracleLastTimestamp, oracleId) = _getOracleParameters();
        min = oracleActiveSize == 0 ? 0 : oracleSampleLifetime;
        max = oracleSampleLifetime * oracleActiveSize;
    }

    /// @notice View function to get the oracle's sample at `_timeDelta` seconds
    /// @dev Return a linearized sample, the weighted average of 2 neighboring samples
    /// @param _timeDelta The number of seconds before the current timestamp
    /// @return cumulativeId The weighted average cumulative id
    /// @return cumulativeVolatilityAccumulated The weighted average cumulative volatility accumulated
    /// @return cumulativeBinCrossed The weighted average cumulative bin crossed
    function getOracleSampleFrom(uint256 _timeDelta)
        external
        view
        override
        returns (
            uint256 cumulativeId,
            uint256 cumulativeVolatilityAccumulated,
            uint256 cumulativeBinCrossed
        )
    {
        uint256 _lookUpTimestamp = block.timestamp - _timeDelta;

        (, , uint256 _oracleActiveSize, , uint256 _oracleId) = _getOracleParameters();

        uint256 timestamp;
        (timestamp, cumulativeId, cumulativeVolatilityAccumulated, cumulativeBinCrossed) = _oracle.getSampleAt(
            _oracleActiveSize,
            _oracleId,
            _lookUpTimestamp
        );

        if (timestamp < _lookUpTimestamp) {
            FeeHelper.FeeParameters memory _fp = _feeParameters;
            uint256 _activeId = _pairInformation.activeId;
            _fp.updateVariableFeeParameters(_activeId);

            unchecked {
                uint256 _deltaT = _lookUpTimestamp - timestamp;

                cumulativeId += _activeId * _deltaT;
                cumulativeVolatilityAccumulated += uint256(_fp.volatilityAccumulated) * _deltaT;
            }
        }
    }

    /// @notice View function to get the fee parameters
    /// @return The fee parameters
    function feeParameters() external view override returns (FeeHelper.FeeParameters memory) {
        return _feeParameters;
    }

    /// @notice View function to get the first bin that isn't empty, will not be `_id` itself
    /// @param _id The bin id
    /// @param _swapForY Whether you've swapping token X for token Y (true) or token Y for token X (false)
    /// @return The id of the non empty bin
    function findFirstNonEmptyBinId(uint24 _id, bool _swapForY) external view override returns (uint24) {
        return _tree.findFirstBin(_id, _swapForY);
    }

    /// @notice View function to get the bin at `id`
    /// @param _id The bin id
    /// @return reserveX The reserve of tokenX of the bin
    /// @return reserveY The reserve of tokenY of the bin
    function getBin(uint24 _id) external view override returns (uint256 reserveX, uint256 reserveY) {
        return _getBin(_id);
    }

    /// @notice View function to get the pending fees of a user
    /// @dev The array must be strictly increasing to ensure uniqueness
    /// @param _account The address of the user
    /// @param _ids The list of ids
    /// @return amountX The amount of tokenX pending
    /// @return amountY The amount of tokenY pending
    function pendingFees(address _account, uint256[] calldata _ids)
        external
        view
        override
        returns (uint256 amountX, uint256 amountY)
    {
        if (_account == address(this) || _account == address(0)) return (0, 0);

        bytes32 _unclaimedData = _unclaimedFees[_account];

        amountX = _unclaimedData.decode(type(uint128).max, 0);
        amountY = _unclaimedData.decode(type(uint128).max, 128);

        uint256 _lastId;
        // Iterate over the ids to get the pending fees of the user for each bin
        unchecked {
            for (uint256 i; i < _ids.length; ++i) {
                uint256 _id = _ids[i];

                // Ensures uniqueness of ids
                if (_lastId >= _id && i != 0) revert LBPair__OnlyStrictlyIncreasingId();

                uint256 _balance = balanceOf(_account, _id);

                if (_balance != 0) {
                    Bin memory _bin = _bins[_id];

                    (uint128 _amountX, uint128 _amountY) = _getPendingFees(_bin, _account, _id, _balance);

                    amountX += _amountX;
                    amountY += _amountY;
                }

                _lastId = _id;
            }
        }
    }

    /// @notice Returns whether this contract implements the interface defined by
    /// `interfaceId` (true) or not (false)
    /// @param _interfaceId The interface identifier
    /// @return Whether the interface is supported (true) or not (false)
    function supportsInterface(bytes4 _interfaceId) public view override returns (bool) {
        return super.supportsInterface(_interfaceId) || _interfaceId == type(ILBPair).interfaceId;
    }

    /** External Functions **/

    /// @notice Swap tokens iterating over the bins until the entire amount is swapped.
    /// Will swap token X for token Y if `_swapForY` is true, and token Y for token X if `_swapForY` is false.
    /// This function will not transfer the tokens from the caller, it is expected that the tokens have already been
    /// transferred to this contract through another contract.
    /// That is why this function shouldn't be called directly, but through one of the swap functions of the router
    /// that will also perform safety checks.
    ///
    /// The variable fee is updated throughout the swap, it increases with the number of bins crossed.
    /// @param _swapForY Whether you've swapping token X for token Y (true) or token Y for token X (false)
    /// @param _to The address to send the tokens to
    /// @return amountXOut The amount of token X sent to `_to`
    /// @return amountYOut The amount of token Y sent to `_to`
    function swap(bool _swapForY, address _to)
        external
        override
        nonReentrant
        returns (uint256 amountXOut, uint256 amountYOut)
    {
        PairInformation memory _pair = _pairInformation;

        uint256 _amountIn = _swapForY
            ? tokenX.received(_pair.reserveX, _pair.feesX.total)
            : tokenY.received(_pair.reserveY, _pair.feesY.total);

        if (_amountIn == 0) revert LBPair__InsufficientAmounts();

        FeeHelper.FeeParameters memory _fp = _feeParameters;

        uint256 _startId = _pair.activeId;
        _fp.updateVariableFeeParameters(_startId);

        uint256 _amountOut;
        /// Performs the actual swap, iterating over the bins until the entire amount is swapped.
        /// It uses the tree to find the next bin to have a non zero reserve of the token we're swapping for.
        /// It will also update the variable fee parameters.
        while (true) {
            Bin memory _bin = _bins[_pair.activeId];
            if ((!_swapForY && _bin.reserveX != 0) || (_swapForY && _bin.reserveY != 0)) {
                (uint256 _amountInToBin, uint256 _amountOutOfBin, FeeHelper.FeesDistribution memory _fees) = _bin
                    .getAmounts(_fp, _pair.activeId, _swapForY, _amountIn);

                _bin.updateFees(_swapForY ? _pair.feesX : _pair.feesY, _fees, _swapForY, totalSupply(_pair.activeId));

                _bin.updateReserves(_pair, _swapForY, _amountInToBin.safe112(), _amountOutOfBin.safe112());

                _amountIn -= _amountInToBin + _fees.total;
                _amountOut += _amountOutOfBin;

                _bins[_pair.activeId] = _bin;

                // Avoids stack too deep error
                _emitSwap(
                    _to,
                    _pair.activeId,
                    _swapForY,
                    _amountInToBin,
                    _amountOutOfBin,
                    _fp.volatilityAccumulated,
                    _fees.total
                );
            }

            /// If the amount in is not 0, it means that we haven't swapped the entire amount yet.
            /// We need to find the next bin to swap for.
            if (_amountIn != 0) {
                _pair.activeId = _tree.findFirstBin(_pair.activeId, _swapForY);
            } else {
                break;
            }
        }

        // Update the oracle and return the updated oracle id. It uses the oracle size to start filling the new slots.
        uint256 _updatedOracleId = _oracle.update(
            _pair.oracleSize,
            _pair.oracleSampleLifetime,
            _pair.oracleLastTimestamp,
            _pair.oracleId,
            _pair.activeId,
            _fp.volatilityAccumulated,
            _startId.absSub(_pair.activeId)
        );

        // Update the oracleId and lastTimestamp if the sample write on another slot
        if (_updatedOracleId != _pair.oracleId || _pair.oracleLastTimestamp == 0) {
            // Can't overflow as the updatedOracleId < oracleSize
            _pair.oracleId = uint16(_updatedOracleId);
            _pair.oracleLastTimestamp = block.timestamp.safe40();

            // Increase the activeSize if the updated sample is written in a new slot
            // Can't overflow as _updatedOracleId < maxSize = 2**16-1
            unchecked {
                if (_updatedOracleId == _pair.oracleActiveSize) ++_pair.oracleActiveSize;
            }
        }

        /// Update the fee parameters and the pair information
        _feeParameters = _fp;
        _pairInformation = _pair;

        if (_swapForY) {
            amountYOut = _amountOut;
            tokenY.safeTransfer(_to, _amountOut);
        } else {
            amountXOut = _amountOut;
            tokenX.safeTransfer(_to, _amountOut);
        }
    }

    /// @notice Perform a flashloan on one of the tokens of the pair. The flashloan will call the `_receiver` contract
    /// to perform the desired operations. The `_receiver` contract is expected to transfer the `amount + fee` of the
    /// token to this contract.
    /// @param _receiver The contract that will receive the flashloan and execute the callback
    /// @param _token The address of the token to flashloan
    /// @param _amount The amount of token to flashloan
    /// @param _data The call data that will be forwarded to the `_receiver` contract during the callback
    function flashLoan(
        ILBFlashLoanCallback _receiver,
        IERC20 _token,
        uint256 _amount,
        bytes calldata _data
    ) external override nonReentrant {
        IERC20 _tokenX = tokenX;
        if ((_token != _tokenX && _token != tokenY)) revert LBPair__FlashLoanInvalidToken();

        uint256 _totalFee = _getFlashLoanFee(_amount);

        FeeHelper.FeesDistribution memory _fees = FeeHelper.FeesDistribution({
            total: _totalFee.safe128(),
            protocol: uint128((_totalFee * _feeParameters.protocolShare) / Constants.BASIS_POINT_MAX)
        });

        uint256 _balanceBefore = _token.balanceOf(address(this));

        _token.safeTransfer(address(_receiver), _amount);

        if (
            _receiver.LBFlashLoanCallback(msg.sender, _token, _amount, _fees.total, _data) != Constants.CALLBACK_SUCCESS
        ) revert LBPair__FlashLoanCallbackFailed();

        uint256 _balanceAfter = _token.balanceOf(address(this));

        if (_balanceAfter != _balanceBefore + _fees.total) revert LBPair__FlashLoanInvalidBalance();

        uint256 _activeId = _pairInformation.activeId;
        uint256 _totalSupply = totalSupply(_activeId);

        if (_totalFee > 0) {
            if (_token == _tokenX) {
                (uint128 _feesXTotal, , uint128 _feesXProtocol, ) = _getGlobalFees();

                _setFees(_pairInformation.feesX, _feesXTotal + _fees.total, _feesXProtocol + _fees.protocol);
                _bins[_activeId].accTokenXPerShare += _fees.getTokenPerShare(_totalSupply);
            } else {
                (, uint128 _feesYTotal, , uint128 _feesYProtocol) = _getGlobalFees();

                _setFees(_pairInformation.feesY, _feesYTotal + _fees.total, _feesYProtocol + _fees.protocol);
                _bins[_activeId].accTokenYPerShare += _fees.getTokenPerShare(_totalSupply);
            }
        }

        emit FlashLoan(msg.sender, _receiver, _token, _amount, _fees.total);
    }

    /// @notice Mint new LB tokens for each bins where the user adds liquidity.
    /// This function will not transfer the tokens from the caller, it is expected that the tokens have already been
    /// transferred to this contract through another contract.
    /// That is why this function shouldn't be called directly, but through one of the add liquidity functions of the
    /// router that will also perform safety checks.
    /// @dev Any excess amount of token will be sent to the `to` address. The lengths of the arrays must be the same.
    /// @param _ids The ids of the bins where the liquidity will be added. It will mint LB tokens for each of these bins.
    /// @param _distributionX The percentage of token X to add to each bin. The sum of all the values must not exceed 100%,
    /// that is 1e18.
    /// @param _distributionY The percentage of token Y to add to each bin. The sum of all the values must not exceed 100%,
    /// that is 1e18.
    /// @param _to The address that will receive the LB tokens and the excess amount of tokens.
    /// @return The amount of token X added to the pair
    /// @return The amount of token Y added to the pair
    /// @return liquidityMinted The amounts of LB tokens minted for each bin
    function mint(
        uint256[] calldata _ids,
        uint256[] calldata _distributionX,
        uint256[] calldata _distributionY,
        address _to
    )
        external
        override
        nonReentrant
        returns (
            uint256,
            uint256,
            uint256[] memory liquidityMinted
        )
    {
        if (_ids.length == 0 || _ids.length != _distributionX.length || _ids.length != _distributionY.length)
            revert LBPair__WrongLengths();

        PairInformation memory _pair = _pairInformation;

        FeeHelper.FeeParameters memory _fp = _feeParameters;

        MintInfo memory _mintInfo;

        _mintInfo.amountXIn = tokenX.received(_pair.reserveX, _pair.feesX.total).safe112();
        _mintInfo.amountYIn = tokenY.received(_pair.reserveY, _pair.feesY.total).safe112();

        liquidityMinted = new uint256[](_ids.length);

        // Iterate over the ids to calculate the amount of LB tokens to mint for each bin
        for (uint256 i; i < _ids.length; ) {
            _mintInfo.id = _ids[i].safe24();
            Bin memory _bin = _bins[_mintInfo.id];

            if (_bin.reserveX == 0 && _bin.reserveY == 0) _tree.addToTree(_mintInfo.id);

            _mintInfo.totalDistributionX += _distributionX[i];
            _mintInfo.totalDistributionY += _distributionY[i];

            // Can't overflow as amounts are uint112 and total distributions will be checked to be smaller or equal than 1e18
            unchecked {
                _mintInfo.amountX = (_mintInfo.amountXIn * _distributionX[i]) / Constants.PRECISION;
                _mintInfo.amountY = (_mintInfo.amountYIn * _distributionY[i]) / Constants.PRECISION;
            }

            uint256 _price = BinHelper.getPriceFromId(_mintInfo.id, _fp.binStep);
            if (_mintInfo.id >= _pair.activeId) {
                // The active bin is the only bin that can have a non-zero reserve of the two tokens. When adding liquidity
                // with a different ratio than the active bin, the user would actually perform a swap without paying any
                // fees. This is why we calculate the fees for the active bin here.
                if (_mintInfo.id == _pair.activeId) {
                    if (_bin.reserveX != 0 || _bin.reserveY != 0) {
                        uint256 _totalSupply = totalSupply(_mintInfo.id);

                        uint256 _receivedX;
                        uint256 _receivedY;

                        {
                            uint256 _userL = _price.mulShiftRoundDown(_mintInfo.amountX, Constants.SCALE_OFFSET) +
                                _mintInfo.amountY;

                            uint256 _supply = _totalSupply + _userL;

                            // Calculate the amounts received by the user if he were to burn its liquidity directly after adding
                            // it. These amounts will be used to calculate the fees.
                            _receivedX = _userL.mulDivRoundDown(uint256(_bin.reserveX) + _mintInfo.amountX, _supply);
                            _receivedY = _userL.mulDivRoundDown(uint256(_bin.reserveY) + _mintInfo.amountY, _supply);
                        }

                        _fp.updateVariableFeeParameters(_mintInfo.id);

                        FeeHelper.FeesDistribution memory _fees;

                        // Checks if the amount of tokens received after burning its liquidity is greater than the amount of
                        // tokens sent by the user. If it is, we add a composition fee of the difference between the two amounts.
                        if (_mintInfo.amountX > _receivedX) {
                            unchecked {
                                _fees = _fp.getFeeAmountDistribution(
                                    _fp.getFeeAmountForC(_mintInfo.amountX - _receivedX)
                                );
                            }

                            _mintInfo.amountX -= _fees.total;
                            _mintInfo.activeFeeX += _fees.total;

                            _bin.updateFees(_pair.feesX, _fees, true, _totalSupply);
                        }
                        if (_mintInfo.amountY > _receivedY) {
                            unchecked {
                                _fees = _fp.getFeeAmountDistribution(
                                    _fp.getFeeAmountForC(_mintInfo.amountY - _receivedY)
                                );
                            }

                            _mintInfo.amountY -= _fees.total;
                            _mintInfo.activeFeeY += _fees.total;

                            _bin.updateFees(_pair.feesY, _fees, false, _totalSupply);
                        }

                        if (_mintInfo.activeFeeX > 0 || _mintInfo.activeFeeY > 0)
                            emit CompositionFee(
                                msg.sender,
                                _to,
                                _mintInfo.id,
                                _mintInfo.activeFeeX,
                                _mintInfo.activeFeeY
                            );
                    }
                } else if (_mintInfo.amountY != 0) revert LBPair__CompositionFactorFlawed(_mintInfo.id);
            } else if (_mintInfo.amountX != 0) revert LBPair__CompositionFactorFlawed(_mintInfo.id);

            // Calculate the amount of LB tokens to mint for this bin
            uint256 _liquidity = _price.mulShiftRoundDown(_mintInfo.amountX, Constants.SCALE_OFFSET) +
                _mintInfo.amountY;

            if (_liquidity == 0) revert LBPair__InsufficientLiquidityMinted(_mintInfo.id);

            liquidityMinted[i] = _liquidity;

            // Cast can't overflow as amounts are smaller than amountsIn as totalDistribution will be checked to be smaller than 1e18
            _bin.reserveX += uint112(_mintInfo.amountX);
            _bin.reserveY += uint112(_mintInfo.amountY);

            // The addition or the cast can't overflow as it would have reverted during the previous 2 lines if
            // amounts were greater than uint112
            unchecked {
                _pair.reserveX += uint112(_mintInfo.amountX);
                _pair.reserveY += uint112(_mintInfo.amountY);

                _mintInfo.amountXAddedToPair += _mintInfo.amountX;
                _mintInfo.amountYAddedToPair += _mintInfo.amountY;
            }

            _bins[_mintInfo.id] = _bin;

            _mint(_to, _mintInfo.id, _liquidity);

            emit DepositedToBin(msg.sender, _to, _mintInfo.id, _mintInfo.amountX, _mintInfo.amountY);

            unchecked {
                ++i;
            }
        }

        // Assert that the distributions don't exceed 100%
        if (_mintInfo.totalDistributionX > Constants.PRECISION || _mintInfo.totalDistributionY > Constants.PRECISION)
            revert LBPair__DistributionsOverflow();

        _pairInformation = _pair;

        // Send back the excess of tokens to `_to`
        unchecked {
            uint256 _amountXAddedPlusFee = _mintInfo.amountXAddedToPair + _mintInfo.activeFeeX;
            if (_mintInfo.amountXIn > _amountXAddedPlusFee) {
                tokenX.safeTransfer(_to, _mintInfo.amountXIn - _amountXAddedPlusFee);
            }

            uint256 _amountYAddedPlusFee = _mintInfo.amountYAddedToPair + _mintInfo.activeFeeY;
            if (_mintInfo.amountYIn > _amountYAddedPlusFee) {
                tokenY.safeTransfer(_to, _mintInfo.amountYIn - _amountYAddedPlusFee);
            }
        }

        return (_mintInfo.amountXAddedToPair, _mintInfo.amountYAddedToPair, liquidityMinted);
    }

    /// @notice Burns LB tokens and sends the corresponding amounts of tokens to `_to`. The amount of tokens sent is
    /// determined by the ratio of the amount of LB tokens burned to the total supply of LB tokens in the bin.
    /// This function will not transfer the LB Tokens from the caller, it is expected that the tokens have already been
    /// transferred to this contract through another contract.
    /// That is why this function shouldn't be called directly, but through one of the remove liquidity functions of the router
    /// that will also perform safety checks.
    /// @param _ids The ids of the bins from which to remove liquidity
    /// @param _amounts The amounts of LB tokens to burn
    /// @param _to The address that will receive the tokens
    /// @return amountX The amount of token X sent to `_to`
    /// @return amountY The amount of token Y sent to `_to`
    function burn(
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        address _to
    ) external override nonReentrant returns (uint256 amountX, uint256 amountY) {
        if (_ids.length == 0 || _ids.length != _amounts.length) revert LBPair__WrongLengths();

        (uint256 _pairReserveX, uint256 _pairReserveY, uint256 _activeId) = _getReservesAndId();

        // Iterate over the ids to burn the LB tokens
        unchecked {
            for (uint256 i; i < _ids.length; ++i) {
                uint24 _id = _ids[i].safe24();
                uint256 _amountToBurn = _amounts[i];

                if (_amountToBurn == 0) revert LBPair__InsufficientLiquidityBurned(_id);

                (uint256 _reserveX, uint256 _reserveY) = _getBin(_id);

                uint256 _totalSupply = totalSupply(_id);

                uint256 _amountX;
                uint256 _amountY;

                if (_id <= _activeId) {
                    _amountY = _amountToBurn.mulDivRoundDown(_reserveY, _totalSupply);

                    amountY += _amountY;
                    _reserveY -= _amountY;
                    _pairReserveY -= _amountY;
                }
                if (_id >= _activeId) {
                    _amountX = _amountToBurn.mulDivRoundDown(_reserveX, _totalSupply);

                    amountX += _amountX;
                    _reserveX -= _amountX;
                    _pairReserveX -= _amountX;
                }

                if (_reserveX == 0 && _reserveY == 0) _tree.removeFromTree(_id);

                // Optimized `_bins[_id] = _bin` to do only 1 sstore
                assembly {
                    mstore(0, _id)
                    mstore(32, _bins.slot)
                    let slot := keccak256(0, 64)

                    let reserves := add(shl(_OFFSET_BIN_RESERVE_Y, _reserveY), _reserveX)
                    sstore(slot, reserves)
                }

                _burn(address(this), _id, _amountToBurn);

                emit WithdrawnFromBin(msg.sender, _to, _id, _amountX, _amountY);
            }
        }

        // Optimization to do only 2 sstore
        _pairInformation.reserveX = uint136(_pairReserveX);
        _pairInformation.reserveY = uint136(_pairReserveY);

        tokenX.safeTransfer(_to, amountX);
        tokenY.safeTransfer(_to, amountY);
    }

    /// @notice Increases the length of the oracle to the given `_newLength` by adding empty samples to the end of the oracle.
    /// The samples are however initialized to reduce the gas cost of the updates during a swap.
    /// @param _newLength The new length of the oracle
    function increaseOracleLength(uint16 _newLength) external override {
        _increaseOracle(_newLength);
    }

    /// @notice Collect the fees accumulated by a user.
    /// @param _account The address of the user
    /// @param _ids The ids of the bins for which to collect the fees
    /// @return amountX The amount of token X collected and sent to `_account`
    /// @return amountY The amount of token Y collected and sent to `_account`
    function collectFees(address _account, uint256[] calldata _ids)
        external
        override
        nonReentrant
        returns (uint256 amountX, uint256 amountY)
    {
        if (_account == address(0) || _account == address(this)) revert LBPair__AddressZeroOrThis();

        bytes32 _unclaimedData = _unclaimedFees[_account];
        delete _unclaimedFees[_account];

        amountX = _unclaimedData.decode(type(uint128).max, 0);
        amountY = _unclaimedData.decode(type(uint128).max, 128);

        // Iterate over the ids to collect the fees
        for (uint256 i; i < _ids.length; ) {
            uint256 _id = _ids[i];
            uint256 _balance = balanceOf(_account, _id);

            if (_balance != 0) {
                Bin memory _bin = _bins[_id];

                (uint256 _amountX, uint256 _amountY) = _getPendingFees(_bin, _account, _id, _balance);
                _updateUserDebts(_bin, _account, _id, _balance);

                amountX += _amountX;
                amountY += _amountY;
            }

            unchecked {
                ++i;
            }
        }

        if (amountX != 0) {
            _pairInformation.feesX.total -= uint128(amountX);
        }
        if (amountY != 0) {
            _pairInformation.feesY.total -= uint128(amountY);
        }

        tokenX.safeTransfer(_account, amountX);
        tokenY.safeTransfer(_account, amountY);

        emit FeesCollected(msg.sender, _account, amountX, amountY);
    }

    /// @notice Collect the protocol fees and send them to the fee recipient.
    /// @dev The protocol fees are not set to zero to save gas by not resetting the storage slot.
    /// @return amountX The amount of token X collected and sent to the fee recipient
    /// @return amountY The amount of token Y collected and sent to the fee recipient
    function collectProtocolFees() external override nonReentrant returns (uint128 amountX, uint128 amountY) {
        address _feeRecipient = factory.feeRecipient();

        if (msg.sender != _feeRecipient) revert LBPair__OnlyFeeRecipient(_feeRecipient, msg.sender);

        (uint128 _feesXTotal, uint128 _feesYTotal, uint128 _feesXProtocol, uint128 _feesYProtocol) = _getGlobalFees();

        // The protocol fees are not set to 0 to reduce the gas cost during a swap
        if (_feesXProtocol > 1) {
            amountX = _feesXProtocol - 1;
            _feesXTotal -= amountX;

            _setFees(_pairInformation.feesX, _feesXTotal, 1);

            tokenX.safeTransfer(_feeRecipient, amountX);
        }

        if (_feesYProtocol > 1) {
            amountY = _feesYProtocol - 1;
            _feesYTotal -= amountY;

            _setFees(_pairInformation.feesY, _feesYTotal, 1);

            tokenY.safeTransfer(_feeRecipient, amountY);
        }

        emit ProtocolFeesCollected(msg.sender, _feeRecipient, amountX, amountY);
    }

    /// @notice Set the fees parameters
    /// @dev Needs to be called by the factory that will validate the values
    /// The bin step will not change
    /// Only callable by the factory
    /// @param _packedFeeParameters The packed fee parameters
    function setFeesParameters(bytes32 _packedFeeParameters) external override onlyFactory {
        _setFeesParameters(_packedFeeParameters);
    }

    /// @notice Force the decaying of the references for volatility and index
    /// @dev Only callable by the factory
    function forceDecay() external override onlyFactory {
        _feeParameters.volatilityReference = uint24(
            (uint256(_feeParameters.reductionFactor) * _feeParameters.volatilityReference) / Constants.BASIS_POINT_MAX
        );
        _feeParameters.indexRef = _pairInformation.activeId;
    }

    /** Internal Functions **/

    /// @notice Cache the accrued fees for a user before any transfer, mint or burn of LB tokens.
    /// The tokens are not transferred to reduce the gas cost and to avoid reentrancy.
    /// @param _from The address of the sender of the tokens
    /// @param _to The address of the receiver of the tokens
    /// @param _id The id of the bin
    /// @param _amount The amount of LB tokens transferred
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) internal override(LBToken) {
        super._beforeTokenTransfer(_from, _to, _id, _amount);

        if (_from != _to) {
            Bin memory _bin = _bins[_id];
            if (_from != address(0) && _from != address(this)) {
                uint256 _balanceFrom = balanceOf(_from, _id);

                _cacheFees(_bin, _from, _id, _balanceFrom, _balanceFrom - _amount);
            }

            if (_to != address(0) && _to != address(this)) {
                uint256 _balanceTo = balanceOf(_to, _id);

                _cacheFees(_bin, _to, _id, _balanceTo, _balanceTo + _amount);
            }
        }
    }

    /** Private Functions **/

    /// @notice View function to get the pending fees of an account on a given bin
    /// @param _bin The bin data where the user is collecting fees
    /// @param _account The address of the user
    /// @param _id The id where the user is collecting fees
    /// @param _balance The previous balance of the user
    /// @return amountX The amount of token X not collected yet by `_account`
    /// @return amountY The amount of token Y not collected yet by `_account`
    function _getPendingFees(
        Bin memory _bin,
        address _account,
        uint256 _id,
        uint256 _balance
    ) private view returns (uint128 amountX, uint128 amountY) {
        Debts memory _debts = _accruedDebts[_account][_id];

        amountX = (_bin.accTokenXPerShare.mulShiftRoundDown(_balance, Constants.SCALE_OFFSET) - _debts.debtX).safe128();
        amountY = (_bin.accTokenYPerShare.mulShiftRoundDown(_balance, Constants.SCALE_OFFSET) - _debts.debtY).safe128();
    }

    /// @notice Update the user debts of a user on a given bin
    /// @param _bin The bin data where the user has collected fees
    /// @param _account The address of the user
    /// @param _id The id where the user has collected fees
    /// @param _balance The new balance of the user
    function _updateUserDebts(
        Bin memory _bin,
        address _account,
        uint256 _id,
        uint256 _balance
    ) private {
        uint256 _debtX = _bin.accTokenXPerShare.mulShiftRoundDown(_balance, Constants.SCALE_OFFSET);
        uint256 _debtY = _bin.accTokenYPerShare.mulShiftRoundDown(_balance, Constants.SCALE_OFFSET);

        _accruedDebts[_account][_id].debtX = _debtX;
        _accruedDebts[_account][_id].debtY = _debtY;
    }

    /// @notice Cache the accrued fees for a user.
    /// @param _bin The bin data where the user is receiving LB tokens
    /// @param _user The address of the user
    /// @param _id The id where the user is receiving LB tokens
    /// @param _previousBalance The previous balance of the user
    /// @param _newBalance The new balance of the user
    function _cacheFees(
        Bin memory _bin,
        address _user,
        uint256 _id,
        uint256 _previousBalance,
        uint256 _newBalance
    ) private {
        bytes32 _unclaimedData = _unclaimedFees[_user];

        uint128 amountX = uint128(_unclaimedData.decode(type(uint128).max, 0));
        uint128 amountY = uint128(_unclaimedData.decode(type(uint128).max, 128));

        (uint128 _amountX, uint128 _amountY) = _getPendingFees(_bin, _user, _id, _previousBalance);
        _updateUserDebts(_bin, _user, _id, _newBalance);

        amountX += _amountX;
        amountY += _amountY;

        _unclaimedFees[_user] = bytes32(uint256((uint256(amountY) << 128) | amountX));
    }

    /// @notice Set the fee parameters of the pair.
    /// @dev Only the first 112 bits can be set, as the last 144 bits are reserved for the variables parameters
    /// @param _packedFeeParameters The packed fee parameters
    function _setFeesParameters(bytes32 _packedFeeParameters) private {
        bytes32 _feeStorageSlot;
        assembly {
            _feeStorageSlot := sload(_feeParameters.slot)
        }

        uint256 _varParameters = _feeStorageSlot.decode(type(uint112).max, _OFFSET_VARIABLE_FEE_PARAMETERS);
        uint256 _newFeeParameters = _packedFeeParameters.decode(type(uint144).max, 0);

        assembly {
            sstore(_feeParameters.slot, or(_newFeeParameters, shl(_OFFSET_VARIABLE_FEE_PARAMETERS, _varParameters)))
        }
    }

    /// @notice Increases the length of the oracle to the given `_newSize` by adding empty samples to the end of the oracle.
    /// The samples are however initialized to reduce the gas cost of the updates during a swap.
    /// @param _newSize The new size of the oracle. Needs to be bigger than current one
    function _increaseOracle(uint16 _newSize) private {
        uint256 _oracleSize = _pairInformation.oracleSize;

        if (_oracleSize >= _newSize) revert LBPair__OracleNewSizeTooSmall(_newSize, _oracleSize);

        _pairInformation.oracleSize = _newSize;

        // Iterate over the uninitialized oracle samples and initialize them
        for (uint256 _id = _oracleSize; _id < _newSize; ) {
            _oracle.initialize(_id);

            unchecked {
                ++_id;
            }
        }

        emit OracleSizeIncreased(_oracleSize, _newSize);
    }

    /// @notice Return the oracle's parameters
    /// @return oracleSampleLifetime The lifetime of a sample, it accumulates information for up to this timestamp
    /// @return oracleSize The size of the oracle (last ids can be empty)
    /// @return oracleActiveSize The active size of the oracle (no empty data)
    /// @return oracleLastTimestamp The timestamp of the creation of the oracle's latest sample
    /// @return oracleId The index of the oracle's latest sample
    function _getOracleParameters()
        private
        view
        returns (
            uint256 oracleSampleLifetime,
            uint256 oracleSize,
            uint256 oracleActiveSize,
            uint256 oracleLastTimestamp,
            uint256 oracleId
        )
    {
        bytes32 _slot;
        assembly {
            _slot := sload(add(_pairInformation.slot, 1))
        }
        oracleSampleLifetime = _slot.decode(type(uint16).max, _OFFSET_ORACLE_SAMPLE_LIFETIME);
        oracleSize = _slot.decode(type(uint16).max, _OFFSET_ORACLE_SIZE);
        oracleActiveSize = _slot.decode(type(uint16).max, _OFFSET_ORACLE_ACTIVE_SIZE);
        oracleLastTimestamp = _slot.decode(type(uint40).max, _OFFSET_ORACLE_LAST_TIMESTAMP);
        oracleId = _slot.decode(type(uint16).max, _OFFSET_ORACLE_ID);
    }

    /// @notice Return the reserves and the active id of the pair
    /// @return reserveX The reserve of token X
    /// @return reserveY The reserve of token Y
    /// @return activeId The active id of the pair
    function _getReservesAndId()
        private
        view
        returns (
            uint256 reserveX,
            uint256 reserveY,
            uint256 activeId
        )
    {
        uint256 _mask24 = type(uint24).max;
        uint256 _mask136 = type(uint136).max;
        assembly {
            let slot := sload(add(_pairInformation.slot, 1))
            reserveY := and(slot, _mask136)

            slot := sload(_pairInformation.slot)
            activeId := and(slot, _mask24)
            reserveX := and(shr(_OFFSET_PAIR_RESERVE_X, slot), _mask136)
        }
    }

    /// @notice Return the reserves of the bin at index `_id`
    /// @param _id The id of the bin
    /// @return reserveX The reserve of token X in the bin
    /// @return reserveY The reserve of token Y in the bin
    function _getBin(uint24 _id) private view returns (uint256 reserveX, uint256 reserveY) {
        bytes32 _data;
        uint256 _mask112 = type(uint112).max;
        // low level read of mapping to only load 1 storage slot
        assembly {
            mstore(0, _id)
            mstore(32, _bins.slot)
            _data := sload(keccak256(0, 64))

            reserveX := and(_data, _mask112)
            reserveY := shr(_OFFSET_BIN_RESERVE_Y, _data)
        }

        return (reserveX.safe112(), reserveY.safe112());
    }

    /// @notice Return the total fees and the protocol fees of the pair
    /// @dev The fees for users can be computed by subtracting the protocol fees from the total fees
    /// @return feesXTotal The total fees of token X
    /// @return feesYTotal The total fees of token Y
    /// @return feesXProtocol The protocol fees of token X
    /// @return feesYProtocol The protocol fees of token Y
    function _getGlobalFees()
        private
        view
        returns (
            uint128 feesXTotal,
            uint128 feesYTotal,
            uint128 feesXProtocol,
            uint128 feesYProtocol
        )
    {
        bytes32 _slotX;
        bytes32 _slotY;
        assembly {
            _slotX := sload(add(_pairInformation.slot, 2))
            _slotY := sload(add(_pairInformation.slot, 3))
        }

        feesXTotal = uint128(_slotX.decode(type(uint128).max, 0));
        feesYTotal = uint128(_slotY.decode(type(uint128).max, 0));

        feesXProtocol = uint128(_slotX.decode(type(uint128).max, _OFFSET_PROTOCOL_FEE));
        feesYProtocol = uint128(_slotY.decode(type(uint128).max, _OFFSET_PROTOCOL_FEE));
    }

    /// @notice Return the fee added to a flashloan
    /// @dev Rounds up the amount of fees
    /// @param _amount The amount of the flashloan
    /// @return The fee added to the flashloan
    function _getFlashLoanFee(uint256 _amount) private view returns (uint256) {
        uint256 _fee = factory.flashLoanFee();
        return (_amount * _fee + Constants.PRECISION - 1) / Constants.PRECISION;
    }

    /// @notice Set the total and protocol fees
    /// @dev The assembly block does:
    /// _pairFees = FeeHelper.FeesDistribution({total: _totalFees, protocol: _protocolFees});
    /// @param _pairFees The storage slot of the fees
    /// @param _totalFees The new total fees
    /// @param _protocolFees The new protocol fees
    function _setFees(
        FeeHelper.FeesDistribution storage _pairFees,
        uint128 _totalFees,
        uint128 _protocolFees
    ) private {
        assembly {
            sstore(_pairFees.slot, or(shl(_OFFSET_PROTOCOL_FEE, _protocolFees), _totalFees))
        }
    }

    /// @notice Emit the Swap event and avoid stack too deep error
    /// if `swapForY` is:
    /// - true: tokenIn is tokenX, and tokenOut is tokenY
    /// - false: tokenIn is tokenY, and tokenOut is tokenX
    /// @param _to The address of the recipient of the swap
    /// @param _swapForY Whether the `amountInToBin` is tokenX (true) or tokenY (false),
    /// and if `amountOutOfBin` is tokenY (true) or tokenX (false)
    /// @param _amountInToBin The amount of tokenIn sent by the user
    /// @param _amountOutOfBin The amount of tokenOut received by the user
    /// @param _volatilityAccumulated The volatility accumulated number
    /// @param _fees The amount of fees, always denominated in tokenIn
    function _emitSwap(
        address _to,
        uint24 _activeId,
        bool _swapForY,
        uint256 _amountInToBin,
        uint256 _amountOutOfBin,
        uint256 _volatilityAccumulated,
        uint256 _fees
    ) private {
        emit Swap(
            msg.sender,
            _to,
            _activeId,
            _swapForY,
            _amountInToBin,
            _amountOutOfBin,
            _volatilityAccumulated,
            _fees
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "openzeppelin/utils/structs/EnumerableSet.sol";

import "./LBErrors.sol";
import "./interfaces/ILBToken.sol";

/// @title Liquidity Book Token
/// @author Trader Joe
/// @notice The LBToken is an implementation of a multi-token.
/// It allows to create multi-ERC20 represented by their ids
contract LBToken is ILBToken {
    using EnumerableSet for EnumerableSet.UintSet;

    /// @dev Mapping from token id to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    /// @dev Mapping from account to spender approvals
    mapping(address => mapping(address => bool)) private _spenderApprovals;

    /// @dev Mapping from token id to total supplies
    mapping(uint256 => uint256) private _totalSupplies;

    string private constant _NAME = "Liquidity Book Token";
    string private constant _SYMBOL = "LBT";

    modifier checkApproval(address _from, address _spender) {
        if (!_isApprovedForAll(_from, _spender)) revert LBToken__SpenderNotApproved(_from, _spender);
        _;
    }

    modifier checkAddresses(address _from, address _to) {
        if (_from == address(0) || _to == address(0)) revert LBToken__TransferFromOrToAddress0();
        if (_from == _to) revert LBToken__TransferToSelf();
        _;
    }

    modifier checkLength(uint256 _lengthA, uint256 _lengthB) {
        if (_lengthA != _lengthB) revert LBToken__LengthMismatch(_lengthA, _lengthB);
        _;
    }

    /// @notice Returns the name of the token
    /// @return The name of the token
    function name() public pure virtual override returns (string memory) {
        return _NAME;
    }

    /// @notice Returns the symbol of the token, usually a shorter version of the name
    /// @return The symbol of the token
    function symbol() public pure virtual override returns (string memory) {
        return _SYMBOL;
    }

    /// @notice Returns the total supply of token of type `id`
    /// @dev This is the amount of token of type `id` minted minus the amount burned
    /// @param _id The token id
    /// @return The total supply of that token id
    function totalSupply(uint256 _id) public view virtual override returns (uint256) {
        return _totalSupplies[_id];
    }

    /// @notice Returns the amount of tokens of type `id` owned by `_account`
    /// @param _account The address of the owner
    /// @param _id The token id
    /// @return The amount of tokens of type `id` owned by `_account`
    function balanceOf(address _account, uint256 _id) public view virtual override returns (uint256) {
        return _balances[_id][_account];
    }

    /// @notice Return the balance of multiple (account/id) pairs
    /// @param _accounts The addresses of the owners
    /// @param _ids The token ids
    /// @return batchBalances The balance for each (account, id) pair
    function balanceOfBatch(address[] calldata _accounts, uint256[] calldata _ids)
        public
        view
        virtual
        override
        checkLength(_accounts.length, _ids.length)
        returns (uint256[] memory batchBalances)
    {
        batchBalances = new uint256[](_accounts.length);

        unchecked {
            for (uint256 i; i < _accounts.length; ++i) {
                batchBalances[i] = balanceOf(_accounts[i], _ids[i]);
            }
        }
    }

    /// @notice Returns true if `spender` is approved to transfer `_account`'s tokens
    /// @param _owner The address of the owner
    /// @param _spender The address of the spender
    /// @return True if `spender` is approved to transfer `_account`'s tokens
    function isApprovedForAll(address _owner, address _spender) public view virtual override returns (bool) {
        return _isApprovedForAll(_owner, _spender);
    }

    /// @notice Grants or revokes permission to `spender` to transfer the caller's tokens, according to `approved`
    /// @param _spender The address of the spender
    /// @param _approved The boolean value to grant or revoke permission
    function setApprovalForAll(address _spender, bool _approved) public virtual override {
        _setApprovalForAll(msg.sender, _spender, _approved);
    }

    /// @notice Transfers `_amount` token of type `_id` from `_from` to `_to`
    /// @param _from The address of the owner of the token
    /// @param _to The address of the recipient
    /// @param _id The token id
    /// @param _amount The amount to send
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) public virtual override checkAddresses(_from, _to) checkApproval(_from, msg.sender) {
        address _spender = msg.sender;

        _transfer(_from, _to, _id, _amount);

        emit TransferSingle(_spender, _from, _to, _id, _amount);
    }

    /// @notice Batch transfers `_amount` tokens of type `_id` from `_from` to `_to`
    /// @param _from The address of the owner of the tokens
    /// @param _to The address of the recipient
    /// @param _ids The list of token ids
    /// @param _amounts The list of amounts to send
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _amounts
    )
        public
        virtual
        override
        checkLength(_ids.length, _amounts.length)
        checkAddresses(_from, _to)
        checkApproval(_from, msg.sender)
    {
        unchecked {
            for (uint256 i; i < _ids.length; ++i) {
                _transfer(_from, _to, _ids[i], _amounts[i]);
            }
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
    }

    /// @notice Returns whether this contract implements the interface defined by
    /// `interfaceId` (true) or not (false)
    /// @param _interfaceId The interface identifier
    /// @return Whether the interface is supported (true) or not (false)
    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return _interfaceId == type(ILBToken).interfaceId || _interfaceId == type(IERC165).interfaceId;
    }

    /// @notice Internal function to transfer `_amount` tokens of type `_id` from `_from` to `_to`
    /// @param _from The address of the owner of the token
    /// @param _to The address of the recipient
    /// @param _id The token id
    /// @param _amount The amount to send
    function _transfer(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) internal virtual {
        uint256 _fromBalance = _balances[_id][_from];
        if (_fromBalance < _amount) revert LBToken__TransferExceedsBalance(_from, _id, _amount);

        _beforeTokenTransfer(_from, _to, _id, _amount);

        unchecked {
            _balances[_id][_from] = _fromBalance - _amount;
            _balances[_id][_to] += _amount;
        }
    }

    /// @dev Creates `_amount` tokens of type `_id`, and assigns them to `_account`
    /// @param _account The address of the recipient
    /// @param _id The token id
    /// @param _amount The amount to mint
    function _mint(
        address _account,
        uint256 _id,
        uint256 _amount
    ) internal virtual {
        if (_account == address(0)) revert LBToken__MintToAddress0();

        _beforeTokenTransfer(address(0), _account, _id, _amount);

        _totalSupplies[_id] += _amount;

        unchecked {
            _balances[_id][_account] += _amount;
        }

        emit TransferSingle(msg.sender, address(0), _account, _id, _amount);
    }

    /// @dev Destroys `_amount` tokens of type `_id` from `_account`
    /// @param _account The address of the owner
    /// @param _id The token id
    /// @param _amount The amount to destroy
    function _burn(
        address _account,
        uint256 _id,
        uint256 _amount
    ) internal virtual {
        if (_account == address(0)) revert LBToken__BurnFromAddress0();

        uint256 _accountBalance = _balances[_id][_account];
        if (_accountBalance < _amount) revert LBToken__BurnExceedsBalance(_account, _id, _amount);

        _beforeTokenTransfer(_account, address(0), _id, _amount);

        unchecked {
            _balances[_id][_account] = _accountBalance - _amount;
            _totalSupplies[_id] -= _amount;
        }

        emit TransferSingle(msg.sender, _account, address(0), _id, _amount);
    }

    /// @notice Grants or revokes permission to `spender` to transfer the caller's tokens, according to `approved`
    /// @param _owner The address of the owner
    /// @param _spender The address of the spender
    /// @param _approved The boolean value to grant or revoke permission
    function _setApprovalForAll(
        address _owner,
        address _spender,
        bool _approved
    ) internal virtual {
        if (_owner == _spender) revert LBToken__SelfApproval(_owner);

        _spenderApprovals[_owner][_spender] = _approved;
        emit ApprovalForAll(_owner, _spender, _approved);
    }

    /// @notice Returns true if `spender` is approved to transfer `owner`'s tokens
    /// or if `sender` is the `owner`
    /// @param _owner The address of the owner
    /// @param _spender The address of the spender
    /// @return True if `spender` is approved to transfer `owner`'s tokens
    function _isApprovedForAll(address _owner, address _spender) internal view virtual returns (bool) {
        return _owner == _spender || _spenderApprovals[_owner][_spender];
    }

    /// @notice Hook that is called before any token transfer. This includes minting
    /// and burning.
    ///
    /// Calling conditions (for each `id` and `amount` pair):
    ///
    /// - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
    /// of token type `id` will be  transferred to `to`.
    /// - When `from` is zero, `amount` tokens of token type `id` will be minted
    /// for `to`.
    /// - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
    /// will be burned.
    /// - `from` and `to` are never both zero.
    /// @param from The address of the owner of the token
    /// @param to The address of the recipient of the  token
    /// @param id The id of the token
    /// @param amount The amount of token of type `id`
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "openzeppelin/token/ERC20/IERC20.sol";

import "./ILBPair.sol";
import "./IPendingOwnable.sol";

/// @title Liquidity Book Factory Interface
/// @author Trader Joe
/// @notice Required interface of LBFactory contract
interface ILBFactory is IPendingOwnable {
    /// @dev Structure to store the LBPair information, such as:
    /// - binStep: The bin step of the LBPair
    /// - LBPair: The address of the LBPair
    /// - createdByOwner: Whether the pair was created by the owner of the factory
    /// - ignoredForRouting: Whether the pair is ignored for routing or not. An ignored pair will not be explored during routes finding
    struct LBPairInformation {
        uint16 binStep;
        ILBPair LBPair;
        bool createdByOwner;
        bool ignoredForRouting;
    }

    event LBPairCreated(
        IERC20 indexed tokenX,
        IERC20 indexed tokenY,
        uint256 indexed binStep,
        ILBPair LBPair,
        uint256 pid
    );

    event FeeRecipientSet(address oldRecipient, address newRecipient);

    event FlashLoanFeeSet(uint256 oldFlashLoanFee, uint256 newFlashLoanFee);

    event FeeParametersSet(
        address indexed sender,
        ILBPair indexed LBPair,
        uint256 binStep,
        uint256 baseFactor,
        uint256 filterPeriod,
        uint256 decayPeriod,
        uint256 reductionFactor,
        uint256 variableFeeControl,
        uint256 protocolShare,
        uint256 maxVolatilityAccumulated
    );

    event FactoryLockedStatusUpdated(bool unlocked);

    event LBPairImplementationSet(address oldLBPairImplementation, address LBPairImplementation);

    event LBPairIgnoredStateChanged(ILBPair indexed LBPair, bool ignored);

    event PresetSet(
        uint256 indexed binStep,
        uint256 baseFactor,
        uint256 filterPeriod,
        uint256 decayPeriod,
        uint256 reductionFactor,
        uint256 variableFeeControl,
        uint256 protocolShare,
        uint256 maxVolatilityAccumulated,
        uint256 sampleLifetime
    );

    event PresetRemoved(uint256 indexed binStep);

    event QuoteAssetAdded(IERC20 indexed quoteAsset);

    event QuoteAssetRemoved(IERC20 indexed quoteAsset);

    function MAX_FEE() external pure returns (uint256);

    function MIN_BIN_STEP() external pure returns (uint256);

    function MAX_BIN_STEP() external pure returns (uint256);

    function MAX_PROTOCOL_SHARE() external pure returns (uint256);

    function LBPairImplementation() external view returns (address);

    function getNumberOfQuoteAssets() external view returns (uint256);

    function getQuoteAsset(uint256 index) external view returns (IERC20);

    function isQuoteAsset(IERC20 token) external view returns (bool);

    function feeRecipient() external view returns (address);

    function flashLoanFee() external view returns (uint256);

    function creationUnlocked() external view returns (bool);

    function allLBPairs(uint256 id) external returns (ILBPair);

    function getNumberOfLBPairs() external view returns (uint256);

    function getLBPairInformation(
        IERC20 tokenX,
        IERC20 tokenY,
        uint256 binStep
    ) external view returns (LBPairInformation memory);

    function getPreset(uint16 binStep)
        external
        view
        returns (
            uint256 baseFactor,
            uint256 filterPeriod,
            uint256 decayPeriod,
            uint256 reductionFactor,
            uint256 variableFeeControl,
            uint256 protocolShare,
            uint256 maxAccumulator,
            uint256 sampleLifetime
        );

    function getAllBinSteps() external view returns (uint256[] memory presetsBinStep);

    function getAllLBPairs(IERC20 tokenX, IERC20 tokenY)
        external
        view
        returns (LBPairInformation[] memory LBPairsBinStep);

    function setLBPairImplementation(address LBPairImplementation) external;

    function createLBPair(
        IERC20 tokenX,
        IERC20 tokenY,
        uint24 activeId,
        uint16 binStep
    ) external returns (ILBPair pair);

    function setLBPairIgnored(
        IERC20 tokenX,
        IERC20 tokenY,
        uint256 binStep,
        bool ignored
    ) external;

    function setPreset(
        uint16 binStep,
        uint16 baseFactor,
        uint16 filterPeriod,
        uint16 decayPeriod,
        uint16 reductionFactor,
        uint24 variableFeeControl,
        uint16 protocolShare,
        uint24 maxVolatilityAccumulated,
        uint16 sampleLifetime
    ) external;

    function removePreset(uint16 binStep) external;

    function setFeesParametersOnPair(
        IERC20 tokenX,
        IERC20 tokenY,
        uint16 binStep,
        uint16 baseFactor,
        uint16 filterPeriod,
        uint16 decayPeriod,
        uint16 reductionFactor,
        uint24 variableFeeControl,
        uint16 protocolShare,
        uint24 maxVolatilityAccumulated
    ) external;

    function setFeeRecipient(address feeRecipient) external;

    function setFlashLoanFee(uint256 flashLoanFee) external;

    function setFactoryLockedState(bool locked) external;

    function addQuoteAsset(IERC20 quoteAsset) external;

    function removeQuoteAsset(IERC20 quoteAsset) external;

    function forceDecay(ILBPair LBPair) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "openzeppelin/token/ERC20/IERC20.sol";

/// @title Liquidity Book Flashloan Callback Interface
/// @author Trader Joe
/// @notice Required interface to interact with LB flash loans
interface ILBFlashLoanCallback {
    function LBFlashLoanCallback(
        address sender,
        IERC20 token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "openzeppelin/token/ERC20/IERC20.sol";

import "../libraries/FeeHelper.sol";
import "./ILBFactory.sol";
import "./ILBFlashLoanCallback.sol";

/// @title Liquidity Book Pair Interface
/// @author Trader Joe
/// @notice Required interface of LBPair contract
interface ILBPair {
    /// @dev Structure to store the reserves of bins:
    /// - reserveX: The current reserve of tokenX of the bin
    /// - reserveY: The current reserve of tokenY of the bin
    struct Bin {
        uint112 reserveX;
        uint112 reserveY;
        uint256 accTokenXPerShare;
        uint256 accTokenYPerShare;
    }

    /// @dev Structure to store the information of the pair such as:
    /// slot0:
    /// - activeId: The current id used for swaps, this is also linked with the price
    /// - reserveX: The sum of amounts of tokenX across all bins
    /// slot1:
    /// - reserveY: The sum of amounts of tokenY across all bins
    /// - oracleSampleLifetime: The lifetime of an oracle sample
    /// - oracleSize: The current size of the oracle, can be increase by users
    /// - oracleActiveSize: The current active size of the oracle, composed only from non empty data sample
    /// - oracleLastTimestamp: The current last timestamp at which a sample was added to the circular buffer
    /// - oracleId: The current id of the oracle
    /// slot2:
    /// - feesX: The current amount of fees to distribute in tokenX (total, protocol)
    /// slot3:
    /// - feesY: The current amount of fees to distribute in tokenY (total, protocol)
    struct PairInformation {
        uint24 activeId;
        uint136 reserveX;
        uint136 reserveY;
        uint16 oracleSampleLifetime;
        uint16 oracleSize;
        uint16 oracleActiveSize;
        uint40 oracleLastTimestamp;
        uint16 oracleId;
        FeeHelper.FeesDistribution feesX;
        FeeHelper.FeesDistribution feesY;
    }

    /// @dev Structure to store the debts of users
    /// - debtX: The tokenX's debt
    /// - debtY: The tokenY's debt
    struct Debts {
        uint256 debtX;
        uint256 debtY;
    }

    /// @dev Structure to store fees:
    /// - tokenX: The amount of fees of token X
    /// - tokenY: The amount of fees of token Y
    struct Fees {
        uint128 tokenX;
        uint128 tokenY;
    }

    /// @dev Structure to minting informations:
    /// - amountXIn: The amount of token X sent
    /// - amountYIn: The amount of token Y sent
    /// - amountXAddedToPair: The amount of token X that have been actually added to the pair
    /// - amountYAddedToPair: The amount of token Y that have been actually added to the pair
    /// - activeFeeX: Fees X currently generated
    /// - activeFeeY: Fees Y currently generated
    /// - totalDistributionX: Total distribution of token X. Should be 1e18 (100%) or 0 (0%)
    /// - totalDistributionY: Total distribution of token Y. Should be 1e18 (100%) or 0 (0%)
    /// - id: Id of the current working bin when looping on the distribution array
    /// - amountX: The amount of token X deposited in the current bin
    /// - amountY: The amount of token Y deposited in the current bin
    /// - distributionX: Distribution of token X for the current working bin
    /// - distributionY: Distribution of token Y for the current working bin
    struct MintInfo {
        uint256 amountXIn;
        uint256 amountYIn;
        uint256 amountXAddedToPair;
        uint256 amountYAddedToPair;
        uint256 activeFeeX;
        uint256 activeFeeY;
        uint256 totalDistributionX;
        uint256 totalDistributionY;
        uint256 id;
        uint256 amountX;
        uint256 amountY;
        uint256 distributionX;
        uint256 distributionY;
    }

    event Swap(
        address indexed sender,
        address indexed recipient,
        uint256 indexed id,
        bool swapForY,
        uint256 amountIn,
        uint256 amountOut,
        uint256 volatilityAccumulated,
        uint256 fees
    );

    event FlashLoan(
        address indexed sender,
        ILBFlashLoanCallback indexed receiver,
        IERC20 token,
        uint256 amount,
        uint256 fee
    );

    event CompositionFee(
        address indexed sender,
        address indexed recipient,
        uint256 indexed id,
        uint256 feesX,
        uint256 feesY
    );

    event DepositedToBin(
        address indexed sender,
        address indexed recipient,
        uint256 indexed id,
        uint256 amountX,
        uint256 amountY
    );

    event WithdrawnFromBin(
        address indexed sender,
        address indexed recipient,
        uint256 indexed id,
        uint256 amountX,
        uint256 amountY
    );

    event FeesCollected(address indexed sender, address indexed recipient, uint256 amountX, uint256 amountY);

    event ProtocolFeesCollected(address indexed sender, address indexed recipient, uint256 amountX, uint256 amountY);

    event OracleSizeIncreased(uint256 previousSize, uint256 newSize);

    function tokenX() external view returns (IERC20);

    function tokenY() external view returns (IERC20);

    function factory() external view returns (ILBFactory);

    function getReservesAndId()
        external
        view
        returns (
            uint256 reserveX,
            uint256 reserveY,
            uint256 activeId
        );

    function getGlobalFees()
        external
        view
        returns (
            uint128 feesXTotal,
            uint128 feesYTotal,
            uint128 feesXProtocol,
            uint128 feesYProtocol
        );

    function getOracleParameters()
        external
        view
        returns (
            uint256 oracleSampleLifetime,
            uint256 oracleSize,
            uint256 oracleActiveSize,
            uint256 oracleLastTimestamp,
            uint256 oracleId,
            uint256 min,
            uint256 max
        );

    function getOracleSampleFrom(uint256 timeDelta)
        external
        view
        returns (
            uint256 cumulativeId,
            uint256 cumulativeAccumulator,
            uint256 cumulativeBinCrossed
        );

    function feeParameters() external view returns (FeeHelper.FeeParameters memory);

    function findFirstNonEmptyBinId(uint24 id_, bool sentTokenY) external view returns (uint24 id);

    function getBin(uint24 id) external view returns (uint256 reserveX, uint256 reserveY);

    function pendingFees(address account, uint256[] memory ids)
        external
        view
        returns (uint256 amountX, uint256 amountY);

    function swap(bool sentTokenY, address to) external returns (uint256 amountXOut, uint256 amountYOut);

    function flashLoan(
        ILBFlashLoanCallback receiver,
        IERC20 token,
        uint256 amount,
        bytes calldata data
    ) external;

    function mint(
        uint256[] calldata ids,
        uint256[] calldata distributionX,
        uint256[] calldata distributionY,
        address to
    )
        external
        returns (
            uint256 amountXAddedToPair,
            uint256 amountYAddedToPair,
            uint256[] memory liquidityMinted
        );

    function burn(
        uint256[] calldata ids,
        uint256[] calldata amounts,
        address to
    ) external returns (uint256 amountX, uint256 amountY);

    function increaseOracleLength(uint16 newSize) external;

    function collectFees(address account, uint256[] calldata ids) external returns (uint256 amountX, uint256 amountY);

    function collectProtocolFees() external returns (uint128 amountX, uint128 amountY);

    function setFeesParameters(bytes32 packedFeeParameters) external;

    function forceDecay() external;

    function initialize(
        IERC20 tokenX,
        IERC20 tokenY,
        uint24 activeId,
        uint16 sampleLifetime,
        bytes32 packedFeeParameters
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "openzeppelin/utils/introspection/IERC165.sol";

/// @title Liquidity Book Token Interface
/// @author Trader Joe
/// @notice Required interface of LBToken contract
interface ILBToken is IERC165 {
    event TransferSingle(address indexed sender, address indexed from, address indexed to, uint256 id, uint256 amount);

    event TransferBatch(
        address indexed sender,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    event ApprovalForAll(address indexed account, address indexed sender, bool approved);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory batchBalances);

    function totalSupply(uint256 id) external view returns (uint256);

    function isApprovedForAll(address owner, address spender) external view returns (bool);

    function setApprovalForAll(address sender, bool approved) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata id,
        uint256[] calldata amount
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/// @title Liquidity Book Pending Ownable Interface
/// @author Trader Joe
/// @notice Required interface of Pending Ownable contract used for LBFactory
interface IPendingOwnable {
    event PendingOwnerSet(address indexed pendingOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function setPendingOwner(address pendingOwner) external;

    function revokePendingOwner() external;

    function becomeOwner() external;

    function renounceOwnership() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../LBErrors.sol";
import "./Math128x128.sol";

/// @title Liquidity Book Bin Helper Library
/// @author Trader Joe
/// @notice Contract used to convert bin ID to price and back
library BinHelper {
    using Math128x128 for uint256;

    int256 private constant REAL_ID_SHIFT = 1 << 23;

    /// @notice Returns the id corresponding to the given price
    /// @dev The id may be inaccurate due to rounding issues, always trust getPriceFromId rather than
    /// getIdFromPrice
    /// @param _price The price of y per x as a 128.128-binary fixed-point number
    /// @param _binStep The bin step
    /// @return The id corresponding to this price
    function getIdFromPrice(uint256 _price, uint256 _binStep) internal pure returns (uint24) {
        unchecked {
            uint256 _binStepValue = _getBPValue(_binStep);

            // can't overflow as `2**23 + log2(price) < 2**23 + 2**128 < max(uint256)`
            int256 _id = REAL_ID_SHIFT + _price.log2() / _binStepValue.log2();

            if (_id < 0 || uint256(_id) > type(uint24).max) revert BinHelper__IdOverflows();
            return uint24(uint256(_id));
        }
    }

    /// @notice Returns the price corresponding to the given ID, as a 128.128-binary fixed-point number
    /// @dev This is the trusted function to link id to price, the other way may be inaccurate
    /// @param _id The id
    /// @param _binStep The bin step
    /// @return The price corresponding to this id, as a 128.128-binary fixed-point number
    function getPriceFromId(uint256 _id, uint256 _binStep) internal pure returns (uint256) {
        if (_id > uint256(type(uint24).max)) revert BinHelper__IdOverflows();
        unchecked {
            int256 _realId = int256(_id) - REAL_ID_SHIFT;

            return _getBPValue(_binStep).power(_realId);
        }
    }

    /// @notice Returns the (1 + bp) value as a 128.128-decimal fixed-point number
    /// @param _binStep The bp value in [1; 100] (referring to 0.01% to 1%)
    /// @return The (1+bp) value as a 128.128-decimal fixed-point number
    function _getBPValue(uint256 _binStep) internal pure returns (uint256) {
        if (_binStep == 0 || _binStep > Constants.BASIS_POINT_MAX) revert BinHelper__BinStepOverflows(_binStep);

        unchecked {
            // can't overflow as `max(result) = 2**128 + 10_000 << 128 / 10_000 < max(uint256)`
            return Constants.SCALE + (_binStep << Constants.SCALE_OFFSET) / Constants.BASIS_POINT_MAX;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/// @title Liquidity Book Bit Math Library
/// @author Trader Joe
/// @notice Helper contract used for bit calculations
library BitMath {
    /// @notice Returns the closest non-zero bit of `integer` to the right (of left) of the `bit` bits that is not `bit`
    /// @param _integer The integer as a uint256
    /// @param _bit The bit index
    /// @param _rightSide Whether we're searching in the right side of the tree (true) or the left side (false)
    /// @return The index of the closest non-zero bit. If there is no closest bit, it returns max(uint256)
    function closestBit(
        uint256 _integer,
        uint8 _bit,
        bool _rightSide
    ) internal pure returns (uint256) {
        return _rightSide ? closestBitRight(_integer, _bit - 1) : closestBitLeft(_integer, _bit + 1);
    }

    /// @notice Returns the most (or least) significant bit of `_integer`
    /// @param _integer The integer
    /// @param _isMostSignificant Whether we want the most (true) or the least (false) significant bit
    /// @return The index of the most (or least) significant bit
    function significantBit(uint256 _integer, bool _isMostSignificant) internal pure returns (uint8) {
        return _isMostSignificant ? mostSignificantBit(_integer) : leastSignificantBit(_integer);
    }

    /// @notice Returns the index of the closest bit on the right of x that is non null
    /// @param x The value as a uint256
    /// @param bit The index of the bit to start searching at
    /// @return id The index of the closest non null bit on the right of x.
    /// If there is no closest bit, it returns max(uint256)
    function closestBitRight(uint256 x, uint8 bit) internal pure returns (uint256 id) {
        unchecked {
            uint256 _shift = 255 - bit;
            x <<= _shift;

            // can't overflow as it's non-zero and we shifted it by `_shift`
            return (x == 0) ? type(uint256).max : mostSignificantBit(x) - _shift;
        }
    }

    /// @notice Returns the index of the closest bit on the left of x that is non null
    /// @param x The value as a uint256
    /// @param bit The index of the bit to start searching at
    /// @return id The index of the closest non null bit on the left of x.
    /// If there is no closest bit, it returns max(uint256)
    function closestBitLeft(uint256 x, uint8 bit) internal pure returns (uint256 id) {
        unchecked {
            x >>= bit;

            return (x == 0) ? type(uint256).max : leastSignificantBit(x) + bit;
        }
    }

    /// @notice Returns the index of the most significant bit of x
    /// @param x The value as a uint256
    /// @return msb The index of the most significant bit of x
    function mostSignificantBit(uint256 x) internal pure returns (uint8 msb) {
        unchecked {
            if (x >= 1 << 128) {
                x >>= 128;
                msb = 128;
            }
            if (x >= 1 << 64) {
                x >>= 64;
                msb += 64;
            }
            if (x >= 1 << 32) {
                x >>= 32;
                msb += 32;
            }
            if (x >= 1 << 16) {
                x >>= 16;
                msb += 16;
            }
            if (x >= 1 << 8) {
                x >>= 8;
                msb += 8;
            }
            if (x >= 1 << 4) {
                x >>= 4;
                msb += 4;
            }
            if (x >= 1 << 2) {
                x >>= 2;
                msb += 2;
            }
            if (x >= 1 << 1) {
                msb += 1;
            }
        }
    }

    /// @notice Returns the index of the least significant bit of x
    /// @param x The value as a uint256
    /// @return lsb The index of the least significant bit of x
    function leastSignificantBit(uint256 x) internal pure returns (uint8 lsb) {
        unchecked {
            if (x << 128 != 0) {
                x <<= 128;
                lsb = 128;
            }
            if (x << 64 != 0) {
                x <<= 64;
                lsb += 64;
            }
            if (x << 32 != 0) {
                x <<= 32;
                lsb += 32;
            }
            if (x << 16 != 0) {
                x <<= 16;
                lsb += 16;
            }
            if (x << 8 != 0) {
                x <<= 8;
                lsb += 8;
            }
            if (x << 4 != 0) {
                x <<= 4;
                lsb += 4;
            }
            if (x << 2 != 0) {
                x <<= 2;
                lsb += 2;
            }
            if (x << 1 != 0) {
                lsb += 1;
            }

            return 255 - lsb;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/// @title Liquidity Book Buffer Library
/// @author Trader Joe
/// @notice Helper contract used for modulo calculation
library Buffer {
    /// @notice Internal function to do positive (x - 1) % n
    /// @param x The value
    /// @param n The modulo value
    /// @return result The result
    function before(uint256 x, uint256 n) internal pure returns (uint256 result) {
        assembly {
            if gt(n, 0) {
                switch x
                case 0 {
                    result := sub(n, 1)
                }
                default {
                    result := mod(sub(x, 1), n)
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/// @title Liquidity Book Constants Library
/// @author Trader Joe
/// @notice Set of constants for Liquidity Book contracts
library Constants {
    uint256 internal constant SCALE_OFFSET = 128;
    uint256 internal constant SCALE = 1 << SCALE_OFFSET;

    uint256 internal constant PRECISION = 1e18;
    uint256 internal constant BASIS_POINT_MAX = 10_000;

    /// @dev The expected return after a successful flash loan
    bytes32 internal constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/// @title Liquidity Book Decoder Library
/// @author Trader Joe
/// @notice Helper contract used for decoding bytes32 sample
library Decoder {
    /// @notice Internal function to decode a bytes32 sample using a mask and offset
    /// @dev This function can overflow
    /// @param _sample The sample as a bytes32
    /// @param _mask The mask
    /// @param _offset The offset
    /// @return value The decoded value
    function decode(
        bytes32 _sample,
        uint256 _mask,
        uint256 _offset
    ) internal pure returns (uint256 value) {
        assembly {
            value := and(shr(_offset, _sample), _mask)
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/// @title Liquidity Book Encoder Library
/// @author Trader Joe
/// @notice Helper contract used for encoding uint256 value
library Encoder {
    /// @notice Internal function to encode a uint256 value using a mask and offset
    /// @dev This function can underflow
    /// @param _value The value as a uint256
    /// @param _mask The mask
    /// @param _offset The offset
    /// @return sample The encoded bytes32 sample
    function encode(
        uint256 _value,
        uint256 _mask,
        uint256 _offset
    ) internal pure returns (bytes32 sample) {
        assembly {
            sample := shl(_offset, and(_value, _mask))
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../LBErrors.sol";
import "./Constants.sol";
import "./FeeHelper.sol";

/// @title Liquidity Book Fee Distribution Helper Library
/// @author Trader Joe
/// @notice Helper contract used for fees distribution calculations
library FeeDistributionHelper {
    /// @notice Calculate the tokenPerShare when fees are added
    /// @param _fees The fees received by the pair
    /// @param _totalSupply the total supply of a specific bin
    function getTokenPerShare(FeeHelper.FeesDistribution memory _fees, uint256 _totalSupply)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            // This can't overflow as `totalFees >= protocolFees`,
            // shift can't overflow as we shift fees that are a uint128, by 128 bits.
            // The result will always be smaller than max(uint256)
            return ((uint256(_fees.total) - _fees.protocol) << Constants.SCALE_OFFSET) / _totalSupply;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Constants.sol";
import "./SafeCast.sol";
import "./SafeMath.sol";

/// @title Liquidity Book Fee Helper Library
/// @author Trader Joe
/// @notice Helper contract used for fees calculation
library FeeHelper {
    using SafeCast for uint256;
    using SafeMath for uint256;

    /// @dev Structure to store the protocol fees:
    /// - binStep: The bin step
    /// - baseFactor: The base factor
    /// - filterPeriod: The filter period, where the fees stays constant
    /// - decayPeriod: The decay period, where the fees are halved
    /// - reductionFactor: The reduction factor, used to calculate the reduction of the accumulator
    /// - variableFeeControl: The variable fee control, used to control the variable fee, can be 0 to disable them
    /// - protocolShare: The share of fees sent to protocol
    /// - maxVolatilityAccumulated: The max value of volatility accumulated
    /// - volatilityAccumulated: The value of volatility accumulated
    /// - volatilityReference: The value of volatility reference
    /// - indexRef: The index reference
    /// - time: The last time the accumulator was called
    struct FeeParameters {
        // 144 lowest bits in slot
        uint16 binStep;
        uint16 baseFactor;
        uint16 filterPeriod;
        uint16 decayPeriod;
        uint16 reductionFactor;
        uint24 variableFeeControl;
        uint16 protocolShare;
        uint24 maxVolatilityAccumulated;
        // 112 highest bits in slot
        uint24 volatilityAccumulated;
        uint24 volatilityReference;
        uint24 indexRef;
        uint40 time;
    }

    /// @dev Structure used during swaps to distributes the fees:
    /// - total: The total amount of fees
    /// - protocol: The amount of fees reserved for protocol
    struct FeesDistribution {
        uint128 total;
        uint128 protocol;
    }

    /// @notice Update the value of the volatility accumulated
    /// @param _fp The current fee parameters
    /// @param _activeId The current active id
    function updateVariableFeeParameters(FeeParameters memory _fp, uint256 _activeId) internal view {
        uint256 _deltaT = block.timestamp - _fp.time;

        if (_deltaT >= _fp.filterPeriod || _fp.time == 0) {
            _fp.indexRef = uint24(_activeId);
            if (_deltaT < _fp.decayPeriod) {
                unchecked {
                    // This can't overflow as `reductionFactor <= BASIS_POINT_MAX`
                    _fp.volatilityReference = uint24(
                        (uint256(_fp.reductionFactor) * _fp.volatilityAccumulated) / Constants.BASIS_POINT_MAX
                    );
                }
            } else {
                _fp.volatilityReference = 0;
            }
        }

        _fp.time = (block.timestamp).safe40();

        updateVolatilityAccumulated(_fp, _activeId);
    }

    /// @notice Update the volatility accumulated
    /// @param _fp The fee parameter
    /// @param _activeId The current active id
    function updateVolatilityAccumulated(FeeParameters memory _fp, uint256 _activeId) internal pure {
        uint256 volatilityAccumulated = (_activeId.absSub(_fp.indexRef) * Constants.BASIS_POINT_MAX) +
            _fp.volatilityReference;
        _fp.volatilityAccumulated = volatilityAccumulated > _fp.maxVolatilityAccumulated
            ? _fp.maxVolatilityAccumulated
            : uint24(volatilityAccumulated);
    }

    /// @notice Returns the base fee added to a swap, with 18 decimals
    /// @param _fp The current fee parameters
    /// @return The fee with 18 decimals precision
    function getBaseFee(FeeParameters memory _fp) internal pure returns (uint256) {
        unchecked {
            return uint256(_fp.baseFactor) * _fp.binStep * 1e10;
        }
    }

    /// @notice Returns the variable fee added to a swap, with 18 decimals
    /// @param _fp The current fee parameters
    /// @return variableFee The variable fee with 18 decimals precision
    function getVariableFee(FeeParameters memory _fp) internal pure returns (uint256 variableFee) {
        if (_fp.variableFeeControl != 0) {
            // Can't overflow as the max value is `max(uint24) * (max(uint24) * max(uint16)) ** 2 < max(uint104)`
            // It returns 18 decimals as:
            // decimals(variableFeeControl * (volatilityAccumulated * binStep)**2 / 100) = 4 + (4 + 4) * 2 - 2 = 18
            unchecked {
                uint256 _prod = uint256(_fp.volatilityAccumulated) * _fp.binStep;
                variableFee = (_prod * _prod * _fp.variableFeeControl + 99) / 100;
            }
        }
    }

    /// @notice Return the amount of fees from an amount
    /// @dev Rounds amount up, follows `amount = amountWithFees - getFeeAmountFrom(fp, amountWithFees)`
    /// @param _fp The current fee parameter
    /// @param _amountWithFees The amount of token sent
    /// @return The fee amount from the amount sent
    function getFeeAmountFrom(FeeParameters memory _fp, uint256 _amountWithFees) internal pure returns (uint256) {
        return (_amountWithFees * getTotalFee(_fp) + Constants.PRECISION - 1) / (Constants.PRECISION);
    }

    /// @notice Return the fees to add to an amount
    /// @dev Rounds amount up, follows `amountWithFees = amount + getFeeAmount(fp, amount)`
    /// @param _fp The current fee parameter
    /// @param _amount The amount of token sent
    /// @return The fee amount to add to the amount
    function getFeeAmount(FeeParameters memory _fp, uint256 _amount) internal pure returns (uint256) {
        uint256 _fee = getTotalFee(_fp);
        uint256 _denominator = Constants.PRECISION - _fee;
        return (_amount * _fee + _denominator - 1) / _denominator;
    }

    /// @notice Return the fees added when an user adds liquidity and change the ratio in the active bin
    /// @dev Rounds amount up
    /// @param _fp The current fee parameter
    /// @param _amountWithFees The amount of token sent
    /// @return The fee amount
    function getFeeAmountForC(FeeParameters memory _fp, uint256 _amountWithFees) internal pure returns (uint256) {
        uint256 _fee = getTotalFee(_fp);
        uint256 _denominator = Constants.PRECISION * Constants.PRECISION;
        return (_amountWithFees * _fee * (_fee + Constants.PRECISION) + _denominator - 1) / _denominator;
    }

    /// @notice Return the fees distribution added to an amount
    /// @param _fp The current fee parameter
    /// @param _fees The fee amount
    /// @return fees The fee distribution
    function getFeeAmountDistribution(FeeParameters memory _fp, uint256 _fees)
        internal
        pure
        returns (FeesDistribution memory fees)
    {
        fees.total = _fees.safe128();
        // unsafe math is fine because total >= protocol
        unchecked {
            fees.protocol = uint128((_fees * _fp.protocolShare) / Constants.BASIS_POINT_MAX);
        }
    }

    /// @notice Return the total fee, i.e. baseFee + variableFee
    /// @param _fp The current fee parameter
    /// @return The total fee, with 18 decimals
    function getTotalFee(FeeParameters memory _fp) private pure returns (uint256) {
        unchecked {
            return getBaseFee(_fp) + getVariableFee(_fp);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../LBErrors.sol";
import "./BitMath.sol";
import "./Constants.sol";
import "./Math512Bits.sol";

/// @title Liquidity Book Math Helper Library
/// @author Trader Joe
/// @notice Helper contract used for power and log calculations
library Math128x128 {
    using Math512Bits for uint256;
    using BitMath for uint256;

    uint256 constant LOG_SCALE_OFFSET = 127;
    uint256 constant LOG_SCALE = 1 << LOG_SCALE_OFFSET;
    uint256 constant LOG_SCALE_SQUARED = LOG_SCALE * LOG_SCALE;

    /// @notice Calculates the binary logarithm of x.
    ///
    /// @dev Based on the iterative approximation algorithm.
    /// https://en.wikipedia.org/wiki/Binary_logarithm#Iterative_approximation
    ///
    /// Requirements:
    /// - x must be greater than zero.
    ///
    /// Caveats:
    /// - The results are not perfectly accurate to the last decimal, due to the lossy precision of the iterative approximation
    /// Also because x is converted to an unsigned 129.127-binary fixed-point number during the operation to optimize the multiplication
    ///
    /// @param x The unsigned 128.128-binary fixed-point number for which to calculate the binary logarithm.
    /// @return result The binary logarithm as a signed 128.128-binary fixed-point number.
    function log2(uint256 x) internal pure returns (int256 result) {
        // Convert x to a unsigned 129.127-binary fixed-point number to optimize the multiplication.
        // If we use an offset of 128 bits, y would need 129 bits and y**2 would would overflow and we would have to
        // use mulDiv, by reducing x to 129.127-binary fixed-point number we assert that y will use 128 bits, and we
        // can use the regular multiplication

        if (x == 1) return -128;
        if (x == 0) revert Math128x128__LogUnderflow();

        x >>= 1;

        unchecked {
            // This works because log2(x) = -log2(1/x).
            int256 sign;
            if (x >= LOG_SCALE) {
                sign = 1;
            } else {
                sign = -1;
                // Do the fixed-point inversion inline to save gas
                x = LOG_SCALE_SQUARED / x;
            }

            // Calculate the integer part of the logarithm and add it to the result and finally calculate y = x * 2^(-n).
            uint256 n = (x >> LOG_SCALE_OFFSET).mostSignificantBit();

            // The integer part of the logarithm as a signed 129.127-binary fixed-point number. The operation can't overflow
            // because n is maximum 255, LOG_SCALE_OFFSET is 127 bits and sign is either 1 or -1.
            result = int256(n) << LOG_SCALE_OFFSET;

            // This is y = x * 2^(-n).
            uint256 y = x >> n;

            // If y = 1, the fractional part is zero.
            if (y != LOG_SCALE) {
                // Calculate the fractional part via the iterative approximation.
                // The "delta >>= 1" part is equivalent to "delta /= 2", but shifting bits is faster.
                for (int256 delta = int256(1 << (LOG_SCALE_OFFSET - 1)); delta > 0; delta >>= 1) {
                    y = (y * y) >> LOG_SCALE_OFFSET;

                    // Is y^2 > 2 and so in the range [2,4)?
                    if (y >= 1 << (LOG_SCALE_OFFSET + 1)) {
                        // Add the 2^(-m) factor to the logarithm.
                        result += delta;

                        // Corresponds to z/2 on Wikipedia.
                        y >>= 1;
                    }
                }
            }
            // Convert x back to unsigned 128.128-binary fixed-point number
            result = (result * sign) << 1;
        }
    }

    /// @notice Returns the value of x^y. It calculates `1 / x^abs(y)` if x is bigger than 2^128.
    /// At the end of the operations, we invert the result if needed.
    /// @param x The unsigned 128.128-binary fixed-point number for which to calculate the power
    /// @param y A relative number without any decimals, needs to be between ]2^20; 2^20[
    /// @return result The result of `x^y`
    function power(uint256 x, int256 y) internal pure returns (uint256 result) {
        bool invert;
        uint256 absY;

        if (y == 0) return Constants.SCALE;

        assembly {
            absY := y
            if slt(absY, 0) {
                absY := sub(0, absY)
                invert := iszero(invert)
            }
        }

        if (absY < 0x100000) {
            result = Constants.SCALE;
            assembly {
                let pow := x
                if gt(x, 0xffffffffffffffffffffffffffffffff) {
                    pow := div(not(0), pow)
                    invert := iszero(invert)
                }

                if and(absY, 0x1) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x2) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x4) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x8) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x10) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x20) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x40) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x80) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x100) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x200) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x400) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x800) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x1000) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x2000) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x4000) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x8000) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x10000) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x20000) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x40000) {
                    result := shr(128, mul(result, pow))
                }
                pow := shr(128, mul(pow, pow))
                if and(absY, 0x80000) {
                    result := shr(128, mul(result, pow))
                }
            }
        }

        // revert if y is too big or if x^y underflowed
        if (result == 0) revert Math128x128__PowerUnderflow(x, y);

        return invert ? type(uint256).max / result : result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../LBErrors.sol";
import "./BitMath.sol";

/// @title Liquidity Book Math Helper Library
/// @author Trader Joe
/// @notice Helper contract used for full precision calculations
library Math512Bits {
    using BitMath for uint256;

    /// @notice Calculates floor(x*y÷denominator) with full precision
    /// The result will be rounded down
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    ///
    /// Requirements:
    /// - The denominator cannot be zero
    /// - The result must fit within uint256
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers
    ///
    /// @param x The multiplicand as an uint256
    /// @param y The multiplier as an uint256
    /// @param denominator The divisor as an uint256
    /// @return result The result as an uint256
    function mulDivRoundDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        (uint256 prod0, uint256 prod1) = _getMulProds(x, y);

        return _getEndOfDivRoundDown(x, y, denominator, prod0, prod1);
    }

    /// @notice Calculates x * y >> offset with full precision
    /// The result will be rounded down
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    ///
    /// Requirements:
    /// - The offset needs to be strictly lower than 256
    /// - The result must fit within uint256
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers
    ///
    /// @param x The multiplicand as an uint256
    /// @param y The multiplier as an uint256
    /// @param offset The offset as an uint256, can't be greater than 256
    /// @return result The result as an uint256
    function mulShiftRoundDown(
        uint256 x,
        uint256 y,
        uint256 offset
    ) internal pure returns (uint256 result) {
        if (offset > 255) revert Math512Bits__OffsetOverflows(offset);

        (uint256 prod0, uint256 prod1) = _getMulProds(x, y);

        if (prod0 != 0) result = prod0 >> offset;
        if (prod1 != 0) {
            // Make sure the result is less than 2^256.
            if (prod1 >= 1 << offset) revert Math512Bits__MulShiftOverflow(prod1, offset);

            unchecked {
                result += prod1 << (256 - offset);
            }
        }
    }

    /// @notice Calculates x * y >> offset with full precision
    /// The result will be rounded up
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    ///
    /// Requirements:
    /// - The offset needs to be strictly lower than 256
    /// - The result must fit within uint256
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers
    ///
    /// @param x The multiplicand as an uint256
    /// @param y The multiplier as an uint256
    /// @param offset The offset as an uint256, can't be greater than 256
    /// @return result The result as an uint256
    function mulShiftRoundUp(
        uint256 x,
        uint256 y,
        uint256 offset
    ) internal pure returns (uint256 result) {
        unchecked {
            result = mulShiftRoundDown(x, y, offset);
            if (mulmod(x, y, 1 << offset) != 0) result += 1;
        }
    }

    /// @notice Calculates x << offset / y with full precision
    /// The result will be rounded down
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    ///
    /// Requirements:
    /// - The offset needs to be strictly lower than 256
    /// - The result must fit within uint256
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers
    ///
    /// @param x The multiplicand as an uint256
    /// @param offset The number of bit to shift x as an uint256
    /// @param denominator The divisor as an uint256
    /// @return result The result as an uint256
    function shiftDivRoundDown(
        uint256 x,
        uint256 offset,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        if (offset > 255) revert Math512Bits__OffsetOverflows(offset);
        uint256 prod0;
        uint256 prod1;

        prod0 = x << offset; // Least significant 256 bits of the product
        unchecked {
            prod1 = x >> (256 - offset); // Most significant 256 bits of the product
        }

        return _getEndOfDivRoundDown(x, 1 << offset, denominator, prod0, prod1);
    }

    /// @notice Calculates x << offset / y with full precision
    /// The result will be rounded up
    ///
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    ///
    /// Requirements:
    /// - The offset needs to be strictly lower than 256
    /// - The result must fit within uint256
    ///
    /// Caveats:
    /// - This function does not work with fixed-point numbers
    ///
    /// @param x The multiplicand as an uint256
    /// @param offset The number of bit to shift x as an uint256
    /// @param denominator The divisor as an uint256
    /// @return result The result as an uint256
    function shiftDivRoundUp(
        uint256 x,
        uint256 offset,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = shiftDivRoundDown(x, offset, denominator);
        unchecked {
            if (mulmod(x, 1 << offset, denominator) != 0) result += 1;
        }
    }

    /// @notice Helper function to return the result of `x * y` as 2 uint256
    /// @param x The multiplicand as an uint256
    /// @param y The multiplier as an uint256
    /// @return prod0 The least significant 256 bits of the product
    /// @return prod1 The most significant 256 bits of the product
    function _getMulProds(uint256 x, uint256 y) private pure returns (uint256 prod0, uint256 prod1) {
        // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
        // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2^256 + prod0.
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }
    }

    /// @notice Helper function to return the result of `x * y / denominator` with full precision
    /// @param x The multiplicand as an uint256
    /// @param y The multiplier as an uint256
    /// @param denominator The divisor as an uint256
    /// @param prod0 The least significant 256 bits of the product
    /// @param prod1 The most significant 256 bits of the product
    /// @return result The result as an uint256
    function _getEndOfDivRoundDown(
        uint256 x,
        uint256 y,
        uint256 denominator,
        uint256 prod0,
        uint256 prod1
    ) private pure returns (uint256 result) {
        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            unchecked {
                result = prod0 / denominator;
            }
        } else {
            // Make sure the result is less than 2^256. Also prevents denominator == 0
            if (prod1 >= denominator) revert Math512Bits__MulDivOverflow(prod1, denominator);

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1
            // See https://cs.stackexchange.com/q/138556/92363
            unchecked {
                // Does not overflow because the denominator cannot be zero at this stage in the function
                uint256 lpotdod = denominator & (~denominator + 1);
                assembly {
                    // Divide denominator by lpotdod.
                    denominator := div(denominator, lpotdod)

                    // Divide [prod1 prod0] by lpotdod.
                    prod0 := div(prod0, lpotdod)

                    // Flip lpotdod such that it is 2^256 / lpotdod. If lpotdod is zero, then it becomes one
                    lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
                }

                // Shift in bits from prod1 into prod0
                prod0 |= prod1 * lpotdod;

                // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
                // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
                // four bits. That is, denominator * inv = 1 mod 2^4
                uint256 inverse = (3 * denominator) ^ 2;

                // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
                // in modular arithmetic, doubling the correct bits in each step
                inverse *= 2 - denominator * inverse; // inverse mod 2^8
                inverse *= 2 - denominator * inverse; // inverse mod 2^16
                inverse *= 2 - denominator * inverse; // inverse mod 2^32
                inverse *= 2 - denominator * inverse; // inverse mod 2^64
                inverse *= 2 - denominator * inverse; // inverse mod 2^128
                inverse *= 2 - denominator * inverse; // inverse mod 2^256

                // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
                // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
                // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
                // is no longer required.
                result = prod0 * inverse;
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../LBErrors.sol";
import "./Buffer.sol";
import "./Samples.sol";

/// @title Liquidity Book Oracle Library
/// @author Trader Joe
/// @notice Helper contract for oracle
library Oracle {
    using Samples for bytes32;
    using Buffer for uint256;

    struct Sample {
        uint256 timestamp;
        uint256 cumulativeId;
        uint256 cumulativeVolatilityAccumulated;
        uint256 cumulativeBinCrossed;
    }

    /// @notice View function to get the oracle's sample at `_ago` seconds
    /// @dev Return a linearized sample, the weighted average of 2 neighboring samples
    /// @param _oracle The oracle storage pointer
    /// @param _activeSize The size of the oracle (without empty data)
    /// @param _activeId The active index of the oracle
    /// @param _lookUpTimestamp The looked up date
    /// @return timestamp The timestamp of the sample
    /// @return cumulativeId The weighted average cumulative id
    /// @return cumulativeVolatilityAccumulated The weighted average cumulative volatility accumulated
    /// @return cumulativeBinCrossed The weighted average cumulative bin crossed
    function getSampleAt(
        bytes32[65_535] storage _oracle,
        uint256 _activeSize,
        uint256 _activeId,
        uint256 _lookUpTimestamp
    )
        internal
        view
        returns (
            uint256 timestamp,
            uint256 cumulativeId,
            uint256 cumulativeVolatilityAccumulated,
            uint256 cumulativeBinCrossed
        )
    {
        if (_activeSize == 0) revert Oracle__NotInitialized();

        // Oldest sample
        uint256 _nextId;
        assembly {
            _nextId := addmod(_activeId, 1, _activeSize)
        }
        bytes32 _sample = _oracle[_nextId];
        timestamp = _sample.timestamp();
        if (timestamp > _lookUpTimestamp) revert Oracle__LookUpTimestampTooOld(timestamp, _lookUpTimestamp);

        // Most recent sample
        if (_activeSize != 1) {
            _sample = _oracle[_activeId];
            timestamp = _sample.timestamp();

            if (timestamp > _lookUpTimestamp) {
                bytes32 _next;
                (_sample, _next) = binarySearch(_oracle, _activeId, _lookUpTimestamp, _activeSize);

                if (_sample != _next) {
                    uint256 _weightPrev = _next.timestamp() - _lookUpTimestamp; // _next.timestamp() - _sample.timestamp() - (_lookUpTimestamp - _sample.timestamp())
                    uint256 _weightNext = _lookUpTimestamp - _sample.timestamp(); // _next.timestamp() - _sample.timestamp() - (_next.timestamp() - _lookUpTimestamp)
                    uint256 _totalWeight = _weightPrev + _weightNext; // _next.timestamp() - _sample.timestamp()

                    cumulativeId =
                        (_sample.cumulativeId() * _weightPrev + _next.cumulativeId() * _weightNext) /
                        _totalWeight;
                    cumulativeVolatilityAccumulated =
                        (_sample.cumulativeVolatilityAccumulated() *
                            _weightPrev +
                            _next.cumulativeVolatilityAccumulated() *
                            _weightNext) /
                        _totalWeight;
                    cumulativeBinCrossed =
                        (_sample.cumulativeBinCrossed() * _weightPrev + _next.cumulativeBinCrossed() * _weightNext) /
                        _totalWeight;
                    return (_lookUpTimestamp, cumulativeId, cumulativeVolatilityAccumulated, cumulativeBinCrossed);
                }
            }
        }

        timestamp = _sample.timestamp();
        cumulativeId = _sample.cumulativeId();
        cumulativeVolatilityAccumulated = _sample.cumulativeVolatilityAccumulated();
        cumulativeBinCrossed = _sample.cumulativeBinCrossed();
    }

    /// @notice Function to update a sample
    /// @param _oracle The oracle storage pointer
    /// @param _size The size of the oracle (last ids can be empty)
    /// @param _sampleLifetime The lifetime of a sample, it accumulates information for up to this timestamp
    /// @param _lastTimestamp The timestamp of the creation of the oracle's latest sample
    /// @param _lastIndex The index of the oracle's latest sample
    /// @param _activeId The active index of the pair during the latest swap
    /// @param _volatilityAccumulated The volatility accumulated of the pair during the latest swap
    /// @param _binCrossed The bin crossed during the latest swap
    /// @return updatedIndex The oracle updated index, it is either the same as before, or the next one
    function update(
        bytes32[65_535] storage _oracle,
        uint256 _size,
        uint256 _sampleLifetime,
        uint256 _lastTimestamp,
        uint256 _lastIndex,
        uint256 _activeId,
        uint256 _volatilityAccumulated,
        uint256 _binCrossed
    ) internal returns (uint256 updatedIndex) {
        bytes32 _updatedPackedSample = _oracle[_lastIndex].update(_activeId, _volatilityAccumulated, _binCrossed);

        if (block.timestamp - _lastTimestamp >= _sampleLifetime && _lastTimestamp != 0) {
            assembly {
                updatedIndex := addmod(_lastIndex, 1, _size)
            }
        } else updatedIndex = _lastIndex;

        _oracle[updatedIndex] = _updatedPackedSample;
    }

    /// @notice Initialize the sample
    /// @param _oracle The oracle storage pointer
    /// @param _index The index to initialize
    function initialize(bytes32[65_535] storage _oracle, uint256 _index) internal {
        _oracle[_index] |= bytes32(uint256(1));
    }

    /// @notice Binary search on oracle samples and return the 2 samples (as bytes32) that surrounds the `lookUpTimestamp`
    /// @dev The oracle needs to be in increasing order `{_index + 1, _index + 2 ..., _index + _activeSize} % _activeSize`.
    /// The sample that aren't initialized yet will be skipped as _activeSize only contains the samples that are initialized.
    /// This function works only if `timestamp(_oracle[_index + 1 % _activeSize] <= _lookUpTimestamp <= timestamp(_oracle[_index]`.
    /// The edge cases needs to be handled before
    /// @param _oracle The oracle storage pointer
    /// @param _index The current index of the oracle
    /// @param _lookUpTimestamp The looked up timestamp
    /// @param _activeSize The size of the oracle (without empty data)
    /// @return prev The last sample with a timestamp lower than the lookUpTimestamp
    /// @return next The first sample with a timestamp greater than the lookUpTimestamp
    function binarySearch(
        bytes32[65_535] storage _oracle,
        uint256 _index,
        uint256 _lookUpTimestamp,
        uint256 _activeSize
    ) private view returns (bytes32 prev, bytes32 next) {
        // The sample with the lowest timestamp is the one right after _index
        uint256 _low = 1;
        uint256 _high = _activeSize;

        uint256 _middle;
        uint256 _id;

        bytes32 _sample;
        uint256 _sampleTimestamp;
        while (_high >= _low) {
            unchecked {
                _middle = (_low + _high) >> 1;
                assembly {
                    _id := addmod(_middle, _index, _activeSize)
                }
                _sample = _oracle[_id];
                _sampleTimestamp = _sample.timestamp();
                if (_sampleTimestamp < _lookUpTimestamp) {
                    _low = _middle + 1;
                } else if (_sampleTimestamp > _lookUpTimestamp) {
                    _high = _middle - 1;
                } else {
                    return (_sample, _sample);
                }
            }
        }
        if (_sampleTimestamp < _lookUpTimestamp) {
            assembly {
                _id := addmod(_id, 1, _activeSize)
            }
            (prev, next) = (_sample, _oracle[_id]);
        } else (prev, next) = (_oracle[_id.before(_activeSize)], _sample);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../LBErrors.sol";

/// @title Reentrancy Guard
/// @author Trader Joe
/// @notice Contract module that helps prevent reentrant calls to a function
abstract contract ReentrancyGuardUpgradeable {
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

    function __ReentrancyGuard_init() internal {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal {
        if (_status != 0) revert ReentrancyGuardUpgradeable__AlreadyInitialized();

        _status = _NOT_ENTERED;
    }

    /// @notice Prevents a contract from calling itself, directly or indirectly.
    /// Calling a `nonReentrant` function from another `nonReentrant`
    /// function is not supported. It is possible to prevent this from happening
    /// by making the `nonReentrant` function external, and making it call a
    /// `private` function that does the actual work
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        if (_status != _NOT_ENTERED) revert ReentrancyGuardUpgradeable__ReentrantCall();

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../LBErrors.sol";

/// @title Liquidity Book Safe Cast Library
/// @author Trader Joe
/// @notice Helper contract used for converting uint values safely
library SafeCast {
    /// @notice Returns x on uint248 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint248
    function safe248(uint256 x) internal pure returns (uint248 y) {
        if ((y = uint248(x)) != x) revert SafeCast__Exceeds248Bits(x);
    }

    /// @notice Returns x on uint240 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint240
    function safe240(uint256 x) internal pure returns (uint240 y) {
        if ((y = uint240(x)) != x) revert SafeCast__Exceeds240Bits(x);
    }

    /// @notice Returns x on uint232 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint232
    function safe232(uint256 x) internal pure returns (uint232 y) {
        if ((y = uint232(x)) != x) revert SafeCast__Exceeds232Bits(x);
    }

    /// @notice Returns x on uint224 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint224
    function safe224(uint256 x) internal pure returns (uint224 y) {
        if ((y = uint224(x)) != x) revert SafeCast__Exceeds224Bits(x);
    }

    /// @notice Returns x on uint216 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint216
    function safe216(uint256 x) internal pure returns (uint216 y) {
        if ((y = uint216(x)) != x) revert SafeCast__Exceeds216Bits(x);
    }

    /// @notice Returns x on uint208 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint208
    function safe208(uint256 x) internal pure returns (uint208 y) {
        if ((y = uint208(x)) != x) revert SafeCast__Exceeds208Bits(x);
    }

    /// @notice Returns x on uint200 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint200
    function safe200(uint256 x) internal pure returns (uint200 y) {
        if ((y = uint200(x)) != x) revert SafeCast__Exceeds200Bits(x);
    }

    /// @notice Returns x on uint192 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint192
    function safe192(uint256 x) internal pure returns (uint192 y) {
        if ((y = uint192(x)) != x) revert SafeCast__Exceeds192Bits(x);
    }

    /// @notice Returns x on uint184 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint184
    function safe184(uint256 x) internal pure returns (uint184 y) {
        if ((y = uint184(x)) != x) revert SafeCast__Exceeds184Bits(x);
    }

    /// @notice Returns x on uint176 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint176
    function safe176(uint256 x) internal pure returns (uint176 y) {
        if ((y = uint176(x)) != x) revert SafeCast__Exceeds176Bits(x);
    }

    /// @notice Returns x on uint168 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint168
    function safe168(uint256 x) internal pure returns (uint168 y) {
        if ((y = uint168(x)) != x) revert SafeCast__Exceeds168Bits(x);
    }

    /// @notice Returns x on uint160 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint160
    function safe160(uint256 x) internal pure returns (uint160 y) {
        if ((y = uint160(x)) != x) revert SafeCast__Exceeds160Bits(x);
    }

    /// @notice Returns x on uint152 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint152
    function safe152(uint256 x) internal pure returns (uint152 y) {
        if ((y = uint152(x)) != x) revert SafeCast__Exceeds152Bits(x);
    }

    /// @notice Returns x on uint144 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint144
    function safe144(uint256 x) internal pure returns (uint144 y) {
        if ((y = uint144(x)) != x) revert SafeCast__Exceeds144Bits(x);
    }

    /// @notice Returns x on uint136 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint136
    function safe136(uint256 x) internal pure returns (uint136 y) {
        if ((y = uint136(x)) != x) revert SafeCast__Exceeds136Bits(x);
    }

    /// @notice Returns x on uint128 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint128
    function safe128(uint256 x) internal pure returns (uint128 y) {
        if ((y = uint128(x)) != x) revert SafeCast__Exceeds128Bits(x);
    }

    /// @notice Returns x on uint120 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint120
    function safe120(uint256 x) internal pure returns (uint120 y) {
        if ((y = uint120(x)) != x) revert SafeCast__Exceeds120Bits(x);
    }

    /// @notice Returns x on uint112 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint112
    function safe112(uint256 x) internal pure returns (uint112 y) {
        if ((y = uint112(x)) != x) revert SafeCast__Exceeds112Bits(x);
    }

    /// @notice Returns x on uint104 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint104
    function safe104(uint256 x) internal pure returns (uint104 y) {
        if ((y = uint104(x)) != x) revert SafeCast__Exceeds104Bits(x);
    }

    /// @notice Returns x on uint96 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint96
    function safe96(uint256 x) internal pure returns (uint96 y) {
        if ((y = uint96(x)) != x) revert SafeCast__Exceeds96Bits(x);
    }

    /// @notice Returns x on uint88 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint88
    function safe88(uint256 x) internal pure returns (uint88 y) {
        if ((y = uint88(x)) != x) revert SafeCast__Exceeds88Bits(x);
    }

    /// @notice Returns x on uint80 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint80
    function safe80(uint256 x) internal pure returns (uint80 y) {
        if ((y = uint80(x)) != x) revert SafeCast__Exceeds80Bits(x);
    }

    /// @notice Returns x on uint72 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint72
    function safe72(uint256 x) internal pure returns (uint72 y) {
        if ((y = uint72(x)) != x) revert SafeCast__Exceeds72Bits(x);
    }

    /// @notice Returns x on uint64 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint64
    function safe64(uint256 x) internal pure returns (uint64 y) {
        if ((y = uint64(x)) != x) revert SafeCast__Exceeds64Bits(x);
    }

    /// @notice Returns x on uint56 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint56
    function safe56(uint256 x) internal pure returns (uint56 y) {
        if ((y = uint56(x)) != x) revert SafeCast__Exceeds56Bits(x);
    }

    /// @notice Returns x on uint48 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint48
    function safe48(uint256 x) internal pure returns (uint48 y) {
        if ((y = uint48(x)) != x) revert SafeCast__Exceeds48Bits(x);
    }

    /// @notice Returns x on uint40 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint40
    function safe40(uint256 x) internal pure returns (uint40 y) {
        if ((y = uint40(x)) != x) revert SafeCast__Exceeds40Bits(x);
    }

    /// @notice Returns x on uint32 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint32
    function safe32(uint256 x) internal pure returns (uint32 y) {
        if ((y = uint32(x)) != x) revert SafeCast__Exceeds32Bits(x);
    }

    /// @notice Returns x on uint24 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint24
    function safe24(uint256 x) internal pure returns (uint24 y) {
        if ((y = uint24(x)) != x) revert SafeCast__Exceeds24Bits(x);
    }

    /// @notice Returns x on uint16 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint16
    function safe16(uint256 x) internal pure returns (uint16 y) {
        if ((y = uint16(x)) != x) revert SafeCast__Exceeds16Bits(x);
    }

    /// @notice Returns x on uint8 and check that it does not overflow
    /// @param x The value as an uint256
    /// @return y The value as an uint8
    function safe8(uint256 x) internal pure returns (uint8 y) {
        if ((y = uint8(x)) != x) revert SafeCast__Exceeds8Bits(x);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/// @title Liquidity Book Safe Math Helper Library
/// @author Trader Joe
/// @notice Helper contract used for calculating absolute value safely
library SafeMath {
    /// @notice absSub, can't underflow or overflow
    /// @param x The first value
    /// @param y The second value
    /// @return The result of abs(x - y)
    function absSub(uint256 x, uint256 y) internal pure returns (uint256) {
        unchecked {
            return x > y ? x - y : y - x;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Decoder.sol";
import "./Encoder.sol";

/// @title Liquidity Book Sample Helper Library
/// @author Trader Joe
/// @notice Helper contract used for oracle samples operations
library Samples {
    using Encoder for uint256;
    using Decoder for bytes32;

    ///  [ cumulativeBinCrossed | cumulativeVolatilityAccumulated | cumulativeId | timestamp | initialized ]
    ///  [        uint87        |              uint64             |    uint64    |   uint40  |    bool1    ]
    /// MSB                                                                                               LSB

    uint256 private constant _OFFSET_INITIALIZED = 0;
    uint256 private constant _MASK_INITIALIZED = 1;

    uint256 private constant _OFFSET_TIMESTAMP = 1;
    uint256 private constant _MASK_TIMESTAMP = type(uint40).max;

    uint256 private constant _OFFSET_CUMULATIVE_ID = 41;
    uint256 private constant _MASK_CUMULATIVE_ID = type(uint64).max;

    uint256 private constant _OFFSET_CUMULATIVE_VolatilityAccumulated = 105;
    uint256 private constant _MASK_CUMULATIVE_VolatilityAccumulated = type(uint64).max;

    uint256 private constant _OFFSET_CUMULATIVE_BIN_CROSSED = 169;
    uint256 private constant _MASK_CUMULATIVE_BIN_CROSSED = 0x7fffffffffffffffffffff;

    /// @notice Function to update a sample
    /// @param _lastSample The latest sample of the oracle
    /// @param _activeId The active index of the pair during the latest swap
    /// @param _volatilityAccumulated The volatility accumulated of the pair during the latest swap
    /// @param _binCrossed The bin crossed during the latest swap
    /// @return packedSample The packed sample as bytes32
    function update(
        bytes32 _lastSample,
        uint256 _activeId,
        uint256 _volatilityAccumulated,
        uint256 _binCrossed
    ) internal view returns (bytes32 packedSample) {
        uint256 _deltaTime = block.timestamp - timestamp(_lastSample);

        // cumulative can overflow without any issue as what matter is the delta cumulative.
        // It would be an issue if 2 overflows would happen but way too much time should elapsed for it to happen.
        // The delta calculation needs to be unchecked math to allow for it to overflow again.
        unchecked {
            uint256 _cumulativeId = cumulativeId(_lastSample) + _activeId * _deltaTime;
            uint256 _cumulativeVolatilityAccumulated = cumulativeVolatilityAccumulated(_lastSample) +
                _volatilityAccumulated *
                _deltaTime;
            uint256 _cumulativeBinCrossed = cumulativeBinCrossed(_lastSample) + _binCrossed * _deltaTime;

            return pack(_cumulativeBinCrossed, _cumulativeVolatilityAccumulated, _cumulativeId, block.timestamp, 1);
        }
    }

    /// @notice Function to pack cumulative values
    /// @param _cumulativeBinCrossed The cumulative bin crossed
    /// @param _cumulativeVolatilityAccumulated The cumulative volatility accumulated
    /// @param _cumulativeId The cumulative index
    /// @param _timestamp The timestamp
    /// @param _initialized The initialized value
    /// @return packedSample The packed sample as bytes32
    function pack(
        uint256 _cumulativeBinCrossed,
        uint256 _cumulativeVolatilityAccumulated,
        uint256 _cumulativeId,
        uint256 _timestamp,
        uint256 _initialized
    ) internal pure returns (bytes32 packedSample) {
        return
            _cumulativeBinCrossed.encode(_MASK_CUMULATIVE_BIN_CROSSED, _OFFSET_CUMULATIVE_BIN_CROSSED) |
            _cumulativeVolatilityAccumulated.encode(
                _MASK_CUMULATIVE_VolatilityAccumulated,
                _OFFSET_CUMULATIVE_VolatilityAccumulated
            ) |
            _cumulativeId.encode(_MASK_CUMULATIVE_ID, _OFFSET_CUMULATIVE_ID) |
            _timestamp.encode(_MASK_TIMESTAMP, _OFFSET_TIMESTAMP) |
            _initialized.encode(_MASK_INITIALIZED, _OFFSET_INITIALIZED);
    }

    /// @notice View function to return the initialized value
    /// @param _packedSample The packed sample
    /// @return The initialized value
    function initialized(bytes32 _packedSample) internal pure returns (uint256) {
        return _packedSample.decode(_MASK_INITIALIZED, _OFFSET_INITIALIZED);
    }

    /// @notice View function to return the timestamp value
    /// @param _packedSample The packed sample
    /// @return The timestamp value
    function timestamp(bytes32 _packedSample) internal pure returns (uint256) {
        return _packedSample.decode(_MASK_TIMESTAMP, _OFFSET_TIMESTAMP);
    }

    /// @notice View function to return the cumulative id value
    /// @param _packedSample The packed sample
    /// @return The cumulative id value
    function cumulativeId(bytes32 _packedSample) internal pure returns (uint256) {
        return _packedSample.decode(_MASK_CUMULATIVE_ID, _OFFSET_CUMULATIVE_ID);
    }

    /// @notice View function to return the cumulative volatility accumulated value
    /// @param _packedSample The packed sample
    /// @return The cumulative volatility accumulated value
    function cumulativeVolatilityAccumulated(bytes32 _packedSample) internal pure returns (uint256) {
        return _packedSample.decode(_MASK_CUMULATIVE_VolatilityAccumulated, _OFFSET_CUMULATIVE_VolatilityAccumulated);
    }

    /// @notice View function to return the cumulative bin crossed value
    /// @param _packedSample The packed sample
    /// @return The cumulative bin crossed value
    function cumulativeBinCrossed(bytes32 _packedSample) internal pure returns (uint256) {
        return _packedSample.decode(_MASK_CUMULATIVE_BIN_CROSSED, _OFFSET_CUMULATIVE_BIN_CROSSED);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./BinHelper.sol";
import "./Constants.sol";
import "./FeeDistributionHelper.sol";
import "./FeeHelper.sol";
import "./Math512Bits.sol";
import "./SafeMath.sol";
import "../interfaces/ILBPair.sol";

/// @title Liquidity Book Swap Helper Library
/// @author Trader Joe
/// @notice Helper contract used for calculating swaps, fees and reserves changes
library SwapHelper {
    using Math512Bits for uint256;
    using FeeHelper for FeeHelper.FeeParameters;
    using SafeMath for uint256;
    using FeeDistributionHelper for FeeHelper.FeesDistribution;

    /// @notice Returns the swap amounts in the current bin
    /// @param bin The bin information
    /// @param fp The fee parameters
    /// @param activeId The active id of the pair
    /// @param swapForY Whether you've swapping token X for token Y (true) or token Y for token X (false)
    /// @param amountIn The amount sent by the user
    /// @return amountInToBin The amount of token that is added to the bin without the fees
    /// @return amountOutOfBin The amount of token that is removed from the bin
    /// @return fees The swap fees
    function getAmounts(
        ILBPair.Bin memory bin,
        FeeHelper.FeeParameters memory fp,
        uint256 activeId,
        bool swapForY,
        uint256 amountIn
    )
        internal
        pure
        returns (
            uint256 amountInToBin,
            uint256 amountOutOfBin,
            FeeHelper.FeesDistribution memory fees
        )
    {
        uint256 _price = BinHelper.getPriceFromId(activeId, fp.binStep);

        uint256 _reserve;
        uint256 _maxAmountInToBin;
        if (swapForY) {
            _reserve = bin.reserveY;
            _maxAmountInToBin = _reserve.shiftDivRoundUp(Constants.SCALE_OFFSET, _price);
        } else {
            _reserve = bin.reserveX;
            _maxAmountInToBin = _price.mulShiftRoundUp(_reserve, Constants.SCALE_OFFSET);
        }

        fp.updateVolatilityAccumulated(activeId);
        fees = fp.getFeeAmountDistribution(fp.getFeeAmount(_maxAmountInToBin));

        if (_maxAmountInToBin + fees.total <= amountIn) {
            amountInToBin = _maxAmountInToBin;
            amountOutOfBin = _reserve;
        } else {
            fees = fp.getFeeAmountDistribution(fp.getFeeAmountFrom(amountIn));
            amountInToBin = amountIn - fees.total;
            amountOutOfBin = swapForY
                ? _price.mulShiftRoundDown(amountInToBin, Constants.SCALE_OFFSET)
                : amountInToBin.shiftDivRoundDown(Constants.SCALE_OFFSET, _price);
            // Safety check in case rounding returns a higher value than expected
            if (amountOutOfBin > _reserve) amountOutOfBin = _reserve;
        }
    }

    /// @notice Update the fees of the pair and accumulated token per share of the bin
    /// @param bin The bin information
    /// @param pairFees The current fees of the pair information
    /// @param fees The fees amounts added to the pairFees
    /// @param swapForY whether the token sent was Y (true) or X (false)
    /// @param totalSupply The total supply of the token id
    function updateFees(
        ILBPair.Bin memory bin,
        FeeHelper.FeesDistribution memory pairFees,
        FeeHelper.FeesDistribution memory fees,
        bool swapForY,
        uint256 totalSupply
    ) internal pure {
        pairFees.total += fees.total;
        // unsafe math is fine because total >= protocol
        unchecked {
            pairFees.protocol += fees.protocol;
        }

        if (swapForY) {
            bin.accTokenXPerShare += fees.getTokenPerShare(totalSupply);
        } else {
            bin.accTokenYPerShare += fees.getTokenPerShare(totalSupply);
        }
    }

    /// @notice Update reserves
    /// @param bin The bin information
    /// @param pair The pair information
    /// @param swapForY whether the token sent was Y (true) or X (false)
    /// @param amountInToBin The amount of token that is added to the bin without fees
    /// @param amountOutOfBin The amount of token that is removed from the bin
    function updateReserves(
        ILBPair.Bin memory bin,
        ILBPair.PairInformation memory pair,
        bool swapForY,
        uint112 amountInToBin,
        uint112 amountOutOfBin
    ) internal pure {
        if (swapForY) {
            bin.reserveX += amountInToBin;

            unchecked {
                bin.reserveY -= amountOutOfBin;
                pair.reserveX += uint136(amountInToBin);
                pair.reserveY -= uint136(amountOutOfBin);
            }
        } else {
            bin.reserveY += amountInToBin;

            unchecked {
                bin.reserveX -= amountOutOfBin;
                pair.reserveX -= uint136(amountOutOfBin);
                pair.reserveY += uint136(amountInToBin);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "openzeppelin/token/ERC20/IERC20.sol";

import "../LBErrors.sol";

/// @title Safe Transfer
/// @author Trader Joe
/// @notice Wrappers around ERC20 operations that throw on failure (when the token
/// contract returns false). Tokens that return no value (and instead revert or
/// throw on failure) are also supported, non-reverting calls are assumed to be
/// successful.
/// To use this library you can add a `using TokenHelper for IERC20;` statement to your contract,
/// which allows you to call the safe operation as `token.safeTransfer(...)`
library TokenHelper {
    /// @notice Transfers token only if the amount is greater than zero
    /// @param token The address of the token
    /// @param owner The owner of the tokens
    /// @param recipient The address of the recipient
    /// @param amount The amount to send
    function safeTransferFrom(
        IERC20 token,
        address owner,
        address recipient,
        uint256 amount
    ) internal {
        if (amount != 0) {
            bytes memory data = abi.encodeWithSelector(token.transferFrom.selector, owner, recipient, amount);

            bytes memory returnData = _callAndCatchError(address(token), data);

            if (returnData.length > 0 && !abi.decode(returnData, (bool))) revert TokenHelper__TransferFailed();
        }
    }

    /// @notice Transfers token only if the amount is greater than zero
    /// @param token The address of the token
    /// @param recipient The address of the recipient
    /// @param amount The amount to send
    function safeTransfer(
        IERC20 token,
        address recipient,
        uint256 amount
    ) internal {
        if (amount != 0) {
            bytes memory data = abi.encodeWithSelector(token.transfer.selector, recipient, amount);

            bytes memory returnData = _callAndCatchError(address(token), data);

            if (returnData.length > 0 && !abi.decode(returnData, (bool))) revert TokenHelper__TransferFailed();
        }
    }

    /// @notice Returns the amount of token received by the pair
    /// @param token The address of the token
    /// @param reserve The total reserve of token
    /// @param fees The total fees of token
    /// @return The amount received by the pair
    function received(
        IERC20 token,
        uint256 reserve,
        uint256 fees
    ) internal view returns (uint256) {
        uint256 _internalBalance;
        unchecked {
            _internalBalance = reserve + fees;
        }
        return token.balanceOf(address(this)) - _internalBalance;
    }

    /// @notice Private view function to perform a low level call on `target`
    /// @dev Revert if the call doesn't succeed
    /// @param target The address of the account
    /// @param data The data to execute on `target`
    /// @return returnData The data returned by the call
    function _callAndCatchError(address target, bytes memory data) private returns (bytes memory) {
        (bool success, bytes memory returnData) = target.call(data);

        if (success) {
            if (returnData.length == 0 && !_isContract(target)) revert TokenHelper__NonContract();
        } else {
            if (returnData.length == 0) revert TokenHelper__CallFailed();
            else {
                // Look for revert reason and bubble it up if present
                assembly {
                    revert(add(32, returnData), mload(returnData))
                }
            }
        }

        return returnData;
    }

    /// @notice Private view function to return if an address is a contract
    /// @dev It is unsafe to assume that an address for which this function returns
    /// false is an externally-owned account (EOA) and not a contract.
    ///
    /// Among others, `isContract` will return false for the following
    /// types of addresses:
    ///  - an externally-owned account
    ///  - a contract in construction
    ///  - an address where a contract will be created
    ///  - an address where a contract lived, but was destroyed
    /// @param account The address of the account
    /// @return Whether the account is a contract (true) or not (false)
    function _isContract(address account) private view returns (bool) {
        return account.code.length > 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../LBErrors.sol";
import "./BitMath.sol";

/// @title Liquidity Book Tree Math Library
/// @author Trader Joe
/// @notice Helper contract used for finding closest bin with liquidity
library TreeMath {
    using BitMath for uint256;

    /// @notice Returns the first id that is non zero, corresponding to a bin with
    /// liquidity in it
    /// @param _tree The storage slot of the tree
    /// @param _binId the binId to start searching
    /// @param _rightSide Whether we're searching in the right side of the tree (true) or the left side (false)
    /// for the closest non zero bit on the right or the left
    /// @return The closest non zero bit on the right (or left) side of the tree
    function findFirstBin(
        mapping(uint256 => uint256)[3] storage _tree,
        uint24 _binId,
        bool _rightSide
    ) internal view returns (uint24) {
        unchecked {
            uint256 current;
            uint256 bit;

            (_binId, bit) = _getIdsFromAbove(_binId);

            // Search in depth 2
            if ((_rightSide && bit != 0) || (!_rightSide && bit != 255)) {
                current = _tree[2][_binId];
                bit = current.closestBit(uint8(bit), _rightSide);

                if (bit != type(uint256).max) {
                    return _getBottomId(_binId, uint24(bit));
                }
            }

            (_binId, bit) = _getIdsFromAbove(_binId);

            // Search in depth 1
            if ((_rightSide && bit != 0) || (!_rightSide && bit != 255)) {
                current = _tree[1][_binId];
                bit = current.closestBit(uint8(bit), _rightSide);

                if (bit != type(uint256).max) {
                    _binId = _getBottomId(_binId, uint24(bit));
                    current = _tree[2][_binId];

                    return _getBottomId(_binId, current.significantBit(_rightSide));
                }
            }

            // Search in depth 0
            current = _tree[0][0];
            bit = current.closestBit(uint8(_binId), _rightSide);
            if (bit == type(uint256).max) revert TreeMath__ErrorDepthSearch();

            current = _tree[1][bit];
            _binId = _getBottomId(uint24(bit), current.significantBit(_rightSide));

            current = _tree[2][_binId];
            return _getBottomId(_binId, current.significantBit(_rightSide));
        }
    }

    function addToTree(mapping(uint256 => uint256)[3] storage _tree, uint256 _id) internal {
        // add 1 at the right indices
        uint256 _idDepth2 = _id >> 8;
        uint256 _idDepth1 = _id >> 16;

        _tree[2][_idDepth2] |= 1 << (_id & 255);
        _tree[1][_idDepth1] |= 1 << (_idDepth2 & 255);
        _tree[0][0] |= 1 << _idDepth1;
    }

    function removeFromTree(mapping(uint256 => uint256)[3] storage _tree, uint256 _id) internal {
        unchecked {
            // removes 1 at the right indices
            uint256 _idDepth2 = _id >> 8;
            // Optimization of `_tree[2][_idDepth2] & (type(uint256).max - (1 << (_id & 255)))`
            uint256 _newLeafValue = _tree[2][_idDepth2] & (type(uint256).max ^ (1 << (_id & 255)));
            _tree[2][_idDepth2] = _newLeafValue;
            if (_newLeafValue == 0) {
                uint256 _idDepth1 = _id >> 16;
                // Optimization of `_tree[1][_idDepth1] & (type(uint256).max - (1 << (_idDepth2 & 255)))`
                _newLeafValue = _tree[1][_idDepth1] & (type(uint256).max ^ (1 << (_idDepth2 & 255)));
                _tree[1][_idDepth1] = _newLeafValue;
                if (_newLeafValue == 0) {
                    // Optimization of `type(uint256).max - (1 << _idDepth1)`
                    _tree[0][0] &= type(uint256).max ^ (1 << _idDepth1);
                }
            }
        }
    }

    /// @notice Private pure function to return the ids from above
    /// @param _id The current id
    /// @return The branch id from above
    /// @return The leaf id from above
    function _getIdsFromAbove(uint24 _id) private pure returns (uint24, uint24) {
        // Optimization of `(_id / 256, _id % 256)`
        return (_id >> 8, _id & 255);
    }

    /// @notice Private pure function to return the bottom id
    /// @param _branchId The branch id
    /// @param _leafId The leaf id
    /// @return The bottom branchId
    function _getBottomId(uint24 _branchId, uint24 _leafId) private pure returns (uint24) {
        // Optimization of `_branchId * 256 + _leafId`
        // Can't overflow as _leafId would fit in uint8, but kept as uint24 to optimize castings
        unchecked {
            return (_branchId << 8) + _leafId;
        }
    }
}