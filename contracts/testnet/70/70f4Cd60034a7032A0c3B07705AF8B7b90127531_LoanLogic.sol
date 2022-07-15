// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

interface ICore {
    /// @dev Thrown when trying to set fees that don't sum up to one.
    /// @param stabilizationFee The stabilization fee that was tried to set.
    /// @param exchangeFee The stabilization fee that was tried to set.
    /// @param developmentFee The stabilization fee that was tried to set.
    error BaksDAOFeesDontSumUpToOne(uint256 stabilizationFee, uint256 exchangeFee, uint256 developmentFee);

    error BaksDAOZeroAddress();

    event PriceOracleUpdated(address priceOracle, address newPriceOracle);

    event BaksUpdated(address baks, address newBaks);
    event VoiceUpdated(address voice, address newVoice);

    event BankUpdated(address bank, address newBank);
    event DepositaryUpdated(address depositary, address newDepositary);
    event ExchangeFundUpdated(address exchangeFund, address newExchangeFund);
    event DevelopmentFundUpdated(address developmentFund, address newDevelopmentFund);

    event OperatorUpdated(address operator, address newOperator);
    event LiquidatorUpdated(address liquidator, address newLiquidator);

    event InterestUpdated(uint256 interest, uint256 newInterest);
    event DiscountedInterestUpdated(uint256 discountedInterest, uint256 newInterest);
    event MinimumPrincipalAmountUpdated(uint256 minimumPrincipalAmount, uint256 newMinimumPrincipalAmount);
    event StabilityFeeUpdated(uint256 stabilityFee, uint256 newStabilityFee);
    event DiscountedStabilityFeeUpdated(uint256 discountedStabilityFee, uint256 newDiscountedStabilityFee);
    event ReferrerFeeUpdated(uint256 referrerFee, uint256 newReferrerFee);

    event RebalancingThresholdUpdated(uint256 rebalancingThreshold, uint256 newRebalancingThreshold);
    event PlatformFeesUpdated(
        uint256 stabilizationFee,
        uint256 newStabilizationFee,
        uint256 exchangeFee,
        uint256 newExchangeFee,
        uint256 developmentFee,
        uint256 newDevelopmentFee
    );
    event DepositFeesUpdated(
        uint256 stabilizationFee,
        uint256 newStabilizationFee,
        uint256 exchangeFee,
        uint256 newExchangeFee,
        uint256 developmentFee,
        uint256 newDevelopmentFee
    );
    event MarginCallLoanToValueRatioUpdated(uint256 marginCallLoanToValueRatio, uint256 newMarginCallLoanToValueRatio);
    event LiquidationLoanToValueRatioUpdated(
        uint256 liqudationLoanToValueRatio,
        uint256 newLiquidationLoanToValueRatio
    );

    event MinimumMagisterDepositAmountUpdated(
        uint256 minimumMagisterDepositAmount,
        uint256 newMinimumMagisterDepositAmount
    );
    event WorkFeeUpdated(uint256 workFee, uint256 newWorkFee);
    event EarlyWithdrawalPeriodUpdated(uint256 earlyWithdrawalPeriod, uint256 newEarlyWithdrawalPeriod);
    event EarlyWithdrawalFeeUpdated(uint256 earlyWithdrawalFee, uint256 newEarlyWithdrawalFee);

    event ServicingThresholdUpdated(uint256 servicingThreshold, uint256 newServicingThreshold);
    event MinimumLiquidityUpdated(uint256 minimumLiquidity, uint256 newMinimumLiquidity);

    function wrappedNativeCurrency() external view returns (address);

    function uniswapV2Router() external view returns (address);

    function priceOracle() external view returns (address);

    function baks() external view returns (address);

    function voice() external view returns (address);

    function bank() external view returns (address);

    function depositary() external view returns (address);

    function exchangeFund() external view returns (address);

    function developmentFund() external view returns (address);

    function operator() external view returns (address);

    function liquidator() external view returns (address);

    function interest() external view returns (uint256);

    function minimumPrincipalAmount() external view returns (uint256);

    function stabilityFee() external view returns (uint256);

    function stabilizationFee() external view returns (uint256);

    function exchangeFee() external view returns (uint256);

    function developmentFee() external view returns (uint256);

    function marginCallLoanToValueRatio() external view returns (uint256);

    function liquidationLoanToValueRatio() external view returns (uint256);

    function rebalancingThreshold() external view returns (uint256);

    function minimumMagisterDepositAmount() external view returns (uint256);

    function workFee() external view returns (uint256);

    function earlyWithdrawalPeriod() external view returns (uint256);

    function earlyWithdrawalFee() external view returns (uint256);

    function servicingThreshold() external view returns (uint256);

    function minimumLiquidity() external view returns (uint256);

    function voiceMintingSchedule() external view returns (uint256[] memory);

    function voiceTotalShares() external view returns (uint256);

    function voiceMintingBeneficiaries() external view returns (uint256[] memory);

    function isSuperUser(address account) external view returns (bool);

    function depositStabilizationFee() external view returns (uint256);

    function depositExchangeFee() external view returns (uint256);

    function depositDevelopmentFee() external view returns (uint256);

    //возвращает дисконтированную ставку на займ при оплате займа в BDV (3%).
    function discountedInterest() external view returns (uint256);

    function discountedStabilityFee() external view returns (uint256);

    function referrerFee() external view returns (uint256);
}

abstract contract CoreInside {
    ICore public core;

    error BaksDAOOnlyDepositaryAllowed();
    error BaksDAOOnlySuperUserAllowed();

    modifier onlyDepositary() {
        if (msg.sender != address(core.depositary())) {
            revert BaksDAOOnlyDepositaryAllowed();
        }
        _;
    }

    modifier onlySuperUser() {
        if (!core.isSuperUser(msg.sender)) {
            revert BaksDAOOnlySuperUserAllowed();
        }
        _;
    }

    function initializeCoreInside(ICore _core) internal {
        core = _core;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IPriceableERC1155 is IERC1155 {
    function price(uint256 id) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IMintableAndBurnableERC20 is IERC20 {
    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {IERC20} from "./IERC20.sol";
//import "./../libraries/FixedPointMath.sol";

/// @notice Thrown when oracle doesn't provide price for `token` token.
/// @param token The address of the token contract.
error PriceOracleTokenUnknown(IERC20 token);
/// @notice Thrown when oracle provide stale price `price` for `token` token.
/// @param token The address of the token contract.
/// @param price Provided price.
error PriceOracleStalePrice(IERC20 token, uint256 price);
/// @notice Thrown when oracle provide negative, zero or in other ways invalid price `price` for `token` token.
/// @param token The address of the token contract.
/// @param price Provided price.
error PriceOracleInvalidPrice(IERC20 token, int256 price);

interface IPriceOracle {
    /// @notice Gets normalized to 18 decimals price for the `token` token.
    /// @param token The address of the token contract.
    /// @return normalizedPrice Normalized price.
    function getNormalizedPrice(IERC20 token) external view returns (uint256 normalizedPrice);
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import {IERC20} from "./IERC20.sol";

interface IUniswapV2Pair is IERC20 {
    function token0() external view returns (IERC20);

    function token1() external view returns (IERC20);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface IUniswapV2Factory {
    function createPair(IERC20 tokenA, IERC20 tokenB) external returns (IUniswapV2Pair pair);

    function getPair(IERC20 tokenA, IERC20 tokenB) external view returns (IUniswapV2Pair pair);
}

interface IUniswapV2Router {
    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
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

    function removeLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, IERC20[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, IERC20[] calldata path) external view returns (uint256[] memory amounts);

    function factory() external view returns (IUniswapV2Factory);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {IERC20} from "./IERC20.sol";

interface IWrappedNativeCurrency is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

error CallToNonContract(address target);

library Address {
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        if (!isContract(target)) {
            revert CallToNonContract(target);
        }

        (bool success, bytes memory returnData) = target.call(data);
        return verifyCallResult(success, returnData, errorMessage);
    }

    function delegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        if (!isContract(target)) {
            revert CallToNonContract(target);
        }

        (bool success, bytes memory returnData) = target.delegatecall(data);
        return verifyCallResult(success, returnData, errorMessage);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(account)
        }

        return codeSize > 0;
    }

    function verifyCallResult(
        bool success,
        bytes memory returnData,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returnData;
        } else {
            if (returnData.length > 0) {
                assembly {
                    let returnDataSize := mload(returnData)
                    revert(add(returnData, 32), returnDataSize)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {IERC20} from "./../interfaces/IERC20.sol";

library AmountNormalization {
    uint8 internal constant DECIMALS = 18;

    function normalizeAmount(IERC20 self, uint256 denormalizedAmount) internal view returns (uint256 normalizedAmount) {
        uint256 scale = 10**(DECIMALS - self.decimals());
        if (scale != 1) {
            return denormalizedAmount * scale;
        }
        return denormalizedAmount;
    }

    function denormalizeAmount(IERC20 self, uint256 normalizedAmount)
        internal
        view
        returns (uint256 denormalizedAmount)
    {
        uint256 scale = 10**(DECIMALS - self.decimals());
        if (scale != 1) {
            return normalizedAmount / scale;
        }
        return normalizedAmount;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library DataTypes {
    enum Health {
        Ok,
        MarginCall,
        Liquidation
    }

    enum TokenType {
        Native,
        ERC20,
        ERC1155
    }

    struct LoanData {
        uint256 id;
        address borrower;
        bool isActive;
        TokenType tokenType;
        address collateralToken;
        uint40 lastInteractionAt;
        uint40 createdAt;
        uint256 collateralTokenId;
        uint256 interestFee;
        uint256 stabilizationAmount;
        uint256 principalAmount;
        uint256 interestAmount;
        uint256 collateralAmount;
        uint256 initialPrincipalAmount;
    }
    /*
    struct LoanERC1155Data {
        uint256 id;
        address borrower;
        bool isActive;
        address collateralToken;
        uint40 lastInteractionAt;
        uint40 createdAt;
        uint256 collateralTokenId;
        uint256 interestFee;
        uint256 stabilizationAmount;
        uint256 principalAmount;
        uint256 interestAmount;
        uint256 collateralAmount;
        uint256 initialPrincipalAmount;
    } */

    struct CollateralTokenData {
        address collateralToken;
        address priceOracle;
        bool isActive;
        TokenType tokenType;
        uint256 initialLoanToValueRatio;
        uint256 marginCallLoanToValueRatio;
        uint256 liquidationLoanToValueRatio;
    }

    /*     struct ERC1155CollateralTokenData {
        address collateralToken;
        address priceOracle;
        bool isActive;
        uint256 initialLoanToValueRatio;
        uint256[] collateralTokenIds;
        uint256[] collateralAmount;
    } */

    struct FeeData {
        uint256 exchangeFee;
        uint256 developmentFee;
        uint256 stabilityFee;
        uint256 referrerFee;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import {DataTypes} from "./DataTypes.sol";

/**
 * @title Errors library
 * @notice Defines the error messages emitted by the different contracts of the BaksDAO protocol
 */
library Errors {
    /// @dev Thrown when trying to access OnlyDepositary function from non-depositary address.
    error BaksDAOOnlyDepositaryAllowed();

    /// @dev Thrown when trying to access OnlySuperUser function from non-superuser address.
    error BaksDAOOnlySuperUserAllowed();

    /// @dev Thrown when trying to list collateral token that has zero decimals.
    /// @param token The address of the collateral token contract.
    error BaksDAOCollateralTokenZeroDecimals(address token);

    /// @dev Thrown when trying to list collateral token that has too large decimals.
    /// @param token The address of the collateral token contract.
    error BaksDAOCollateralTokenTooLargeDecimals(address token, uint8 decimals);

    /// @dev Thrown when trying to list collateral token that's already listed.
    /// @param token The address of the collateral token contract.
    error BaksDAOCollateralTokenAlreadyListed(address token);

    /// @dev Thrown when trying to unlist collateral token that's not listed.
    /// @param token The address of the collateral token contract.
    error BaksDAOCollateralTokenNotListed(address token);

    /// @dev Thrown when trying to unlist ERC1155 collateral token that's not listed.
    /// @param token The address of the collateral token contract.
    error BaksDAOERC1155CollateralTokenNotListed(address token);

    /// @dev Thrown when interacting with a token that's not allowed as collateral.
    /// @param token The address of the collateral token contract.
    //error BaksDAOTokenNotAllowedAsCollateral(IERC20 token);

    /// @dev Thrown when interacting with a token that's not listed as collateral.
    /// @param token The address of the collateral token contract.
    error BaksDAOTokenNotListedAsCollateral(address token);

    /// @dev Thrown when trying to set initial loan-to-value ratio that higher than margin call or liquidation ones.
    /// @param token The address of the collateral token contract.
    /// @param initialLoanToValueRatio The initial loan-to-value ratio that was tried to set.
    error BaksDAOInitialLoanToValueRatioTooHigh(address token, uint256 initialLoanToValueRatio);

    /// @dev Thrown when trying to interact with inactive loan with `id` id.
    /// @param id The loan id.
    error BaksDAOInactiveLoan(uint256 id);

    /// @dev Thrown when trying to liquidate healthy loan with `id` id.
    /// @param id The loan id.
    error BaksDAOLoanNotSubjectToLiquidation(uint256 id);

    /// @dev Thrown when trying to interact with loan with `id` id that is subject to liquidation.
    /// @param id The loan id.
    error BaksDAOLoanIsSubjectToLiquidation(uint256 id);

    /// @dev Thrown when borrowing a zero amount of stablecoin.
    error BaksDAOBorrowZeroAmount();

    /// @dev Thrown when trying to borrow below minimum principal amount.
    error BaksDAOBorrowBelowMinimumPrincipalAmount();

    /// @dev Thrown when depositing a zero amount of collateral token.
    error BaksDAODepositZeroAmount();

    /// @dev Thrown when repaying a zero amount of stablecoin.
    error BaksDAORepayZeroAmount();

    /// @dev Thrown when there's no need to rebalance the platform.
    error BaksDAONoNeedToRebalance();

    /// @dev Thrown when there's no need to migrate.
    error BaksDAONoNeedToMigrate();

    /// @dev Thrown when trying to rebalance the platform and there is a shortage of funds to burn.
    /// @param shortage Shoratge of funds to burn.
    error BaksDAOStabilizationFundOutOfFunds(uint256 shortage);

    /// @dev Thrown when trying to salvage one of allowed collateral tokens or stablecoin.
    /// @param token The address of the token contract.
    error BaksDAOTokenNotAllowedToBeSalvaged(address token);

    /// @dev Thrown when trying to deposit native currency collateral to the non-wrapped native currency token loan
    /// with `id` id.
    /// @param id The loan id.
    error BaksDAONativeCurrencyCollateralNotAllowed(uint256 id);

    /// @dev Thrown when trying to deposit to non-ERC20 loan
    /// with `id` id.
    /// @param id The loan id.
    error BaksDAODepositCollateralNotAllowed(uint256 id);

    /// @dev Генерируется, если не получилось отправить нативную валюту (ETH, BNB и т. д.).
    error BaksDAONativeCurrencyTransferFailed();

    /// @dev Генерируется, если контракт не принимает переводы нативной валюты.
    error BaksDAOPlainNativeCurrencyTransferNotAllowed();

    /// @dev Генерируется при создании займа, если отправлена недостаточная сумма обеспечения.
    /// @param minimumRequiredSecurityAmount Минимально требуемый размер суммы обеспечения.
    error BaksDAOInsufficientSecurityAmount(uint256 minimumRequiredSecurityAmount);

    /// @dev Генерируется при попытке закрыть чужой займ.
    error BaksDAOOnlyBorrowerAllowed(uint256 id);

    /// @dev Генерируется при попытке указать нулевой адрес в качестве реферрера.
    error BaksDAOReferrerCannotBeZero();

    /// @dev Генерируется при попытке залистить неподдерживаемый тип токена.
    error BaksDAOUnknownTokenType(DataTypes.TokenType);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./Math.sol";

error FixedPointMathMulDivOverflow(uint256 prod1, uint256 denominator);
error FixedPointMathExpArgumentTooBig(uint256 a);
error FixedPointMathExp2ArgumentTooBig(uint256 a);
error FixedPointMathLog2ArgumentTooBig(uint256 a);

/// @title Fixed point math implementation
library FixedPointMath {
    uint256 internal constant SCALE = 1e18;
    uint256 internal constant HALF_SCALE = 5e17;
    /// @dev Largest power of two divisor of scale.
    uint256 internal constant SCALE_LPOTD = 262144;
    /// @dev Scale inverted mod 2**256.
    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661508869554232690281;
    uint256 internal constant LOG2_E = 1_442695040888963407;

    function mul(uint256 a, uint256 b) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= SCALE) {
            revert FixedPointMathMulDivOverflow(prod1, SCALE);
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(a, b, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            assembly {
                result := add(div(prod0, SCALE), roundUpUnit)
            }
            return result;
        }

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 result) {
        result = mulDiv(a, SCALE, b);
    }

    /// @notice Calculates ⌊a × b ÷ denominator⌋ with full precision.
    /// @dev Credit to Remco Bloemen under MIT license https://2π.com/21/muldiv.
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= denominator) {
            revert FixedPointMathMulDivOverflow(prod1, denominator);
        }

        if (prod1 == 0) {
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)

            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        unchecked {
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, lpotdod)
                prod0 := div(prod0, lpotdod)
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }
            prod0 |= prod1 * lpotdod;

            uint256 inverse = (3 * denominator) ^ 2;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;

            result = prod0 * inverse;
        }
    }

    function exp2(uint256 x) internal pure returns (uint256 result) {
        if (x >= 192e18) {
            revert FixedPointMathExp2ArgumentTooBig(x);
        }

        unchecked {
            x = (x << 64) / SCALE;

            result = 0x800000000000000000000000000000000000000000000000;
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }

            result *= SCALE;
            result >>= (191 - (x >> 64));
        }
    }

    function pow(uint256 x, uint256 y) internal pure returns (uint256 result) {
        if (x == 0) {
            result = y == 0 ? SCALE : uint256(0);
        } else {
            result = exp2(mul(log2(x), y));
        }
    }

    function log2(uint256 x) internal pure returns (uint256 result) {
        if (x < SCALE) {
            revert FixedPointMathLog2ArgumentTooBig(x);
        }
        unchecked {
            uint256 n = Math.mostSignificantBit(x / SCALE);

            result = n * SCALE;

            uint256 y = x >> n;

            if (y == SCALE) {
                return result;
            }

            for (uint256 delta = HALF_SCALE; delta > 0; delta >>= 1) {
                y = (y * y) / SCALE;

                if (y >= 2 * SCALE) {
                    result += delta;

                    y >>= 1;
                }
            }
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import {Math, FixedPointMath} from "./FixedPointMath.sol";
import {IERC20, IMintableAndBurnableERC20} from "../interfaces/IERC20.sol";
import {IPriceableERC1155, IERC1155} from "../interfaces/IERC1155.sol";
import {ICore} from "../interfaces/ICore.sol";
import {IWrappedNativeCurrency} from "../interfaces/IWrappedNativeCurrency.sol";
import {IPriceOracle} from "../interfaces/IPriceOracle.sol";
import {IUniswapV2Router} from "../interfaces/IUniswapV2.sol";
import {DataTypes} from "./DataTypes.sol";
import {AmountNormalization} from "./AmountNormalization.sol";
import {SafeERC20} from "./SafeERC20.sol";
import {Errors} from "./Errors.sol";

library LoanLogic {
    using FixedPointMath for uint256;
    using AmountNormalization for IERC20;
    using AmountNormalization for IWrappedNativeCurrency;
    using SafeERC20 for IERC20;
    using SafeERC20 for IMintableAndBurnableERC20;
    using SafeERC20 for IWrappedNativeCurrency;

    uint256 internal constant ONE = 100e16;
    uint256 internal constant SECONDS_PER_YEAR = 31536000;

    /// @dev Генерируется после создания нового займа.
    /// @param id Идентификатор займа.
    /// @param borrower Заёмщик.
    /// @param token Залоговый токен.
    /// @param principalAmount Сумма займа.
    /// @param collateralAmount Сумма залога.
    /// @param initialLoanToValueRatio Начальный LTV.
    event Borrow(
        uint256 indexed id,
        address indexed borrower,
        address indexed token,
        uint256 principalAmount,
        uint256 collateralAmount,
        uint256 initialLoanToValueRatio
    );
    /// @dev Генерируется после добавления залога в займ.
    /// @param id Идентификатор займа.
    /// @param collateralAmount Сумма добавленного залога.
    event Deposit(uint256 indexed id, uint256 collateralAmount);
    /// @dev Генерируется после частичного погашения займа.
    /// @param id Идентификатор займа.
    /// @param principalAmount Сумма погашения.
    event Repay(uint256 indexed id, uint256 principalAmount);
    /// @dev Генерируется после полного погашения займа.
    /// @param id Идентификатор займа.
    event Repaid(uint256 indexed id);

    /// @dev Генерируется после ликвидации займа.
    /// @param id Идентификатор займа.
    event Liquidated(uint256 indexed id);

    /// @dev Генерируется после ребалансировки стабилизационного фонда и эмиссии BDV.
    /// @param delta Количество BAKS, которое было сожжено или эмитированно.
    /// @param voiceMinted Количество вновь эмитированных BDV.
    event Rebalance(int256 delta, uint256 voiceMinted);

    function liquidate(
        DataTypes.LoanData storage loan,
        //mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        mapping(address => mapping(uint256 => uint256)) storage collateralTokensAmount,
        address core
    ) external {
        //collateralTokens[loan.collateralToken].collateralAmount[loan.collateralTokenId] -= loan.collateralAmount;
        collateralTokensAmount[loan.collateralToken][loan.collateralTokenId] -= loan.collateralAmount;
        IERC20(loan.collateralToken).safeTransfer(
            ICore(core).developmentFund(),
            IERC20(loan.collateralToken).denormalizeAmount(loan.collateralAmount)
        );

        IMintableAndBurnableERC20 baks = IMintableAndBurnableERC20(ICore(core).baks());

        uint256 collateralValue = getCollateralValue(
            ICore(core).priceOracle(),
            address(loan.collateralToken),
            loan.collateralAmount
        );
        baks.burn(ICore(core).liquidator(), loan.principalAmount);
        baks.burn(address(this), collateralValue - loan.principalAmount);

        loan.isActive = false;
        emit Liquidated(loan.id);
    }

    function borrow(
        DataTypes.LoanData[] storage loans,
        mapping(address => uint256[]) storage loanIds,
        mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        mapping(address => mapping(uint256 => uint256)) storage collateralTokensAmount,
        address collateralToken,
        uint256 amount,
        address referrer,
        address core
    ) external returns (DataTypes.LoanData memory) {
        bool referral;
        if (referrer != msg.sender) {
            referral = true;
        }
        (DataTypes.LoanData memory loan, DataTypes.FeeData memory fees) = calculateLoanByPrincipalAmount(
            collateralTokens[collateralToken],
            core,
            amount,
            referral
        );

        uint256 operatorStabilityFee = fees.stabilityFee - fees.referrerFee;
        IERC20(collateralToken).safeTransferFrom(
            msg.sender,
            ICore(core).operator(),
            IERC20(collateralToken).denormalizeAmount(operatorStabilityFee)
        );
        if (referral) {
            IERC20(collateralToken).safeTransferFrom(
                msg.sender,
                referrer,
                IERC20(collateralToken).denormalizeAmount(fees.referrerFee)
            );
        }
        IERC20(collateralToken).safeTransferFrom(
            msg.sender,
            address(this),
            IERC20(collateralToken).denormalizeAmount(loan.collateralAmount)
        );

        uint256 initialLoanToValueRatio = collateralTokens[collateralToken].initialLoanToValueRatio;

        return
            _createLoan(
                loans,
                loanIds,
                //collateralTokens,
                collateralTokensAmount,
                loan,
                fees,
                core,
                initialLoanToValueRatio
            );
    }

    function borrowInNativeCurrency(
        DataTypes.LoanData[] storage loans,
        mapping(address => uint256[]) storage loanIds,
        mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        mapping(address => mapping(uint256 => uint256)) storage collateralTokensAmount,
        uint256 amount,
        uint256 initialLoanToValueRatio,
        address referrer,
        address core
    ) external returns (DataTypes.LoanData memory) {
        IWrappedNativeCurrency wrappedNativeCurrency = IWrappedNativeCurrency(ICore(core).wrappedNativeCurrency());
        bool referral;
        if (referrer != msg.sender) {
            referral = true;
        }
        (DataTypes.LoanData memory loan, DataTypes.FeeData memory fees) = calculateLoanByPrincipalAmount(
            collateralTokens[address(wrappedNativeCurrency)],
            core,
            amount,
            referral
        );
        loan.tokenType = DataTypes.TokenType.Native;

        uint256 securityAmount = loan.collateralAmount + fees.stabilityFee;
        if (msg.value < securityAmount) {
            revert Errors.BaksDAOInsufficientSecurityAmount(securityAmount);
        }

        //uint256 operatorStabilityFee = fees.stabilityFee - fees.referrerFee;
        wrappedNativeCurrency.deposit{value: securityAmount}();
        wrappedNativeCurrency.safeTransfer(
            ICore(core).operator(),
            wrappedNativeCurrency.denormalizeAmount(fees.stabilityFee - fees.referrerFee)
        );
        if (referral) {
            wrappedNativeCurrency.safeTransfer(referrer, wrappedNativeCurrency.denormalizeAmount(fees.referrerFee));
        }

        if (msg.value - securityAmount > 0) {
            (bool success, ) = msg.sender.call{value: msg.value - securityAmount}("");
            if (!success) {
                revert Errors.BaksDAONativeCurrencyTransferFailed();
            }
        }

        return
            _createLoan(
                loans,
                loanIds,
                //collateralTokens,
                collateralTokensAmount,
                loan,
                fees,
                core,
                initialLoanToValueRatio
            );
    }

    function borrowInERC1155(
        DataTypes.LoanData[] storage loans,
        mapping(address => uint256[]) storage loanIds,
        mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        mapping(address => mapping(uint256 => uint256)) storage collateralTokensAmount,
        address collateralToken,
        uint256 collateralTokenId,
        uint256 amount,
        address core
    ) external returns (DataTypes.LoanData memory) {
        (DataTypes.LoanData memory loan, DataTypes.FeeData memory fees) = calculateERC1155LoanByCollateralAmount(
            collateralTokens[collateralToken],
            core,
            collateralTokenId,
            amount
        );

        IERC1155(collateralToken).safeTransferFrom(msg.sender, address(this), collateralTokenId, amount, "");
        uint256 initialLoanToValueRatio = collateralTokens[collateralToken].initialLoanToValueRatio;

        return
            _createLoan(
                loans,
                loanIds,
                //collateralTokens,
                collateralTokensAmount,
                loan,
                fees,
                core,
                initialLoanToValueRatio
            );
    }

    function deposit(
        DataTypes.LoanData storage loan,
        //mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        mapping(address => mapping(uint256 => uint256)) storage collateralTokensAmount,
        uint256 amount
    ) external {
        if (amount == 0) {
            revert Errors.BaksDAODepositZeroAmount();
        }

        uint256 normalizedCollateralAmount = IERC20(loan.collateralToken).normalizeAmount(amount);
        loan.collateralAmount += normalizedCollateralAmount;
        //collateralTokens[loan.collateralToken].collateralAmount[loan.collateralTokenId] += normalizedCollateralAmount;
        collateralTokensAmount[loan.collateralToken][loan.collateralTokenId] += loan.collateralAmount;

        emit Deposit(loan.id, normalizedCollateralAmount);
    }

    function repay(
        DataTypes.LoanData storage loan,
        //mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        mapping(address => mapping(uint256 => uint256)) storage collateralTokensAmount,
        uint256 amount,
        address core
    ) external {
        //перерасчитываем сумму процентов в соот-вии с кол-вом блоков прошедших с последнего взаимодействия
        loan.interestAmount = getAccruedInterest(loan);

        amount = Math.min(loan.principalAmount + loan.interestAmount, amount);
        uint256 interestPayment;
        uint256 principalPayment;
        if (loan.interestAmount < amount) {
            principalPayment = amount - loan.interestAmount;
            interestPayment = loan.interestAmount;

            loan.principalAmount -= principalPayment;
            loan.interestAmount = 0;
        } else {
            interestPayment = amount;
            loan.interestAmount -= interestPayment;
        }

        IMintableAndBurnableERC20 baks = IMintableAndBurnableERC20(ICore(core).baks());
        //возвращаем baks от заемщика в счет процентов
        if (interestPayment > 0) {
            baks.safeTransferFrom(msg.sender, ICore(core).developmentFund(), interestPayment);
        }
        //возвращаем baks от заемщика в счет основного долга
        if (principalPayment > 0) {
            baks.safeTransferFrom(msg.sender, address(this), principalPayment);
        }

        _repay(loan, collateralTokensAmount, amount, principalPayment, core);
    }

    function repayWithBDV(
        DataTypes.LoanData storage loan,
        //mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        mapping(address => mapping(uint256 => uint256)) storage collateralTokensAmount,
        address core
    ) external {
        loan.interestAmount = getAccruedDiscountedInterest(loan, ICore(core).discountedInterest());

        uint256 principalPayment = loan.principalAmount;
        uint256 interestPayment = loan.interestAmount;
        uint256 amount = interestPayment + principalPayment;

        uint256 swapDeadline = 20 minutes;

        loan.principalAmount = 0;
        loan.interestAmount = 0;

        IMintableAndBurnableERC20 baks = IMintableAndBurnableERC20(ICore(core).baks());
        IMintableAndBurnableERC20 voice = IMintableAndBurnableERC20(ICore(core).voice());

        IERC20[] memory path = new IERC20[](2);
        path[0] = voice;
        path[1] = baks;

        IUniswapV2Router uniswapV2Router = IUniswapV2Router(ICore(core).uniswapV2Router());
        uint256[] memory amountsIn = uniswapV2Router.getAmountsIn(amount, path);

        voice.transferFrom(msg.sender, address(this), amountsIn[0]);

        uniswapV2Router.swapTokensForExactTokens(
            amount,
            amountsIn[0],
            path,
            address(this),
            block.timestamp + swapDeadline
        );

        if (interestPayment > 0) {
            baks.safeTransfer(ICore(core).developmentFund(), interestPayment);
        }

        _repay(loan, collateralTokensAmount, amount, principalPayment, core);
    }

    function calculateLoanToValueRatio(DataTypes.LoanData storage loan, address oracle)
        external
        view
        returns (uint256 loanToValueRatio)
    {
        if (loan.principalAmount == 0) {
            return 0;
        }
        if (loan.collateralAmount == 0) {
            return type(uint256).max;
        }
        uint256 collateralValue = 0;
        if (loan.tokenType == DataTypes.TokenType.ERC1155) {
            collateralValue =
                IPriceableERC1155(loan.collateralToken).price(loan.collateralTokenId) *
                loan.collateralAmount;
        } else {
            collateralValue = getCollateralValue(oracle, address(loan.collateralToken), loan.collateralAmount);
        }
        loanToValueRatio = (loan.principalAmount + _calculateInterest(loan, loan.interestFee)).div(collateralValue);
    }

    function calculateLoanByCollateralAmount(
        DataTypes.CollateralTokenData storage collateralTokenData,
        address core,
        uint256 collateralAmount,
        bool referral
    ) external view returns (DataTypes.LoanData memory loan, DataTypes.FeeData memory fees) {
        uint256 collateralTokenPrice = IPriceOracle(ICore(core).priceOracle()).getNormalizedPrice(
            IERC20(collateralTokenData.collateralToken)
        );
        uint256 principalAmount = collateralAmount.mul(collateralTokenData.initialLoanToValueRatio).mul(
            collateralTokenPrice
        );

        uint256 restOfIssuance = principalAmount.mul(ONE - collateralTokenData.initialLoanToValueRatio).div(
            collateralTokenData.initialLoanToValueRatio
        );

        uint256 stabilityFee;
        uint256 referrerFee;
        if (referral) {
            stabilityFee = ICore(core).discountedStabilityFee().mul(principalAmount).div(collateralTokenPrice);
            referrerFee = ICore(core).referrerFee().mul(stabilityFee);
        } else {
            stabilityFee = ICore(core).stabilityFee().mul(principalAmount).div(collateralTokenPrice);
        }

        loan = DataTypes.LoanData({
            id: 0,
            borrower: msg.sender,
            isActive: true,
            tokenType: DataTypes.TokenType.ERC20,
            collateralToken: collateralTokenData.collateralToken,
            lastInteractionAt: uint40(block.timestamp),
            createdAt: uint40(block.timestamp),
            collateralTokenId: 0,
            interestFee: 0,
            stabilizationAmount: restOfIssuance.mul(ICore(core).stabilizationFee()),
            principalAmount: principalAmount,
            interestAmount: 0,
            collateralAmount: collateralAmount,
            initialPrincipalAmount: principalAmount
        });

        fees = DataTypes.FeeData({
            exchangeFee: restOfIssuance.mul(ICore(core).exchangeFee()),
            developmentFee: restOfIssuance.mul(ICore(core).developmentFee()),
            stabilityFee: stabilityFee,
            referrerFee: referrerFee
        });
    }

    function calculateLoanBySecurityAmount(
        DataTypes.CollateralTokenData storage collateralTokenData,
        address core,
        uint256 securityAmount,
        bool referral
    ) external view returns (DataTypes.LoanData memory loan, DataTypes.FeeData memory fees) {
        uint256 collateralTokenPrice = IPriceOracle(ICore(core).priceOracle()).getNormalizedPrice(
            IERC20(collateralTokenData.collateralToken)
        );
        uint256 c;
        if (referral) {
            c = ICore(core).discountedStabilityFee().mul(collateralTokenData.initialLoanToValueRatio);
        } else {
            c = ICore(core).stabilityFee().mul(collateralTokenData.initialLoanToValueRatio);
        }
        uint256 principalAmount = securityAmount
            .mul(collateralTokenData.initialLoanToValueRatio)
            .mul(collateralTokenPrice)
            .div(c + ONE);
        return calculateLoanByPrincipalAmount(collateralTokenData, core, principalAmount, referral);
    }

    function calculateLoanByPrincipalAmount(
        DataTypes.CollateralTokenData storage collateralTokenData,
        address core,
        uint256 principalAmount,
        bool referral
    ) public view returns (DataTypes.LoanData memory loan, DataTypes.FeeData memory fees) {
        uint256 collateralTokenPrice = IPriceOracle(ICore(core).priceOracle()).getNormalizedPrice(
            IERC20(collateralTokenData.collateralToken)
        );

        uint256 restOfIssuance = principalAmount.mul(ONE - collateralTokenData.initialLoanToValueRatio).div(
            collateralTokenData.initialLoanToValueRatio
        );

        uint256 stabilityFee;
        uint256 referrerFee;
        if (referral) {
            stabilityFee = ICore(core).discountedStabilityFee().mul(principalAmount).div(collateralTokenPrice);
            referrerFee = ICore(core).referrerFee().mul(stabilityFee);
        } else {
            stabilityFee = ICore(core).stabilityFee().mul(principalAmount).div(collateralTokenPrice);
        }

        loan = DataTypes.LoanData({
            id: 0,
            borrower: msg.sender,
            isActive: true,
            tokenType: DataTypes.TokenType.ERC20,
            collateralToken: collateralTokenData.collateralToken,
            lastInteractionAt: uint40(block.timestamp),
            createdAt: uint40(block.timestamp),
            collateralTokenId: 0,
            interestFee: 0,
            stabilizationAmount: restOfIssuance.mul(ICore(core).stabilizationFee()),
            principalAmount: principalAmount,
            interestAmount: 0,
            collateralAmount: principalAmount.div(
                collateralTokenData.initialLoanToValueRatio.mul(collateralTokenPrice)
            ),
            initialPrincipalAmount: principalAmount
        });

        fees = DataTypes.FeeData({
            exchangeFee: restOfIssuance.mul(ICore(core).exchangeFee()),
            developmentFee: restOfIssuance.mul(ICore(core).developmentFee()),
            stabilityFee: stabilityFee,
            referrerFee: referrerFee
        });
    }

    function calculateERC1155LoanByCollateralAmount(
        DataTypes.CollateralTokenData storage collateralTokenData,
        address core,
        uint256 collateralTokenId,
        uint256 collateralAmount
    ) public view returns (DataTypes.LoanData memory loan, DataTypes.FeeData memory fees) {
        uint256 collateralTokenPrice = IPriceableERC1155(collateralTokenData.collateralToken).price(collateralTokenId);
        uint256 principalAmount = (collateralTokenData.initialLoanToValueRatio).mul(collateralTokenPrice) *
            collateralAmount;

        uint256 restOfIssuance = principalAmount.mul(ONE - collateralTokenData.initialLoanToValueRatio).div(
            collateralTokenData.initialLoanToValueRatio
        );

        loan = DataTypes.LoanData({
            id: 0,
            borrower: msg.sender,
            isActive: true,
            tokenType: DataTypes.TokenType.ERC1155,
            collateralToken: collateralTokenData.collateralToken,
            lastInteractionAt: uint40(block.timestamp),
            createdAt: uint40(block.timestamp),
            collateralTokenId: collateralTokenId,
            interestFee: 0,
            stabilizationAmount: restOfIssuance.mul(ICore(core).stabilizationFee()),
            principalAmount: principalAmount,
            interestAmount: 0,
            collateralAmount: collateralAmount,
            initialPrincipalAmount: principalAmount
        });

        fees = DataTypes.FeeData({
            exchangeFee: restOfIssuance.mul(ICore(core).exchangeFee()),
            developmentFee: restOfIssuance.mul(ICore(core).developmentFee()),
            stabilityFee: 0,
            referrerFee: 0
        });
    }

    function getAccruedInterest(DataTypes.LoanData storage loan) public view returns (uint256 interest) {
        interest = loan.interestAmount + _calculateInterest(loan, loan.interestFee);
    }

    function getAccruedDiscountedInterest(DataTypes.LoanData storage loan, uint256 interestFee)
        public
        view
        returns (uint256 interest)
    {
        interest = _discountedInterest(loan, interestFee) + _calculateInterest(loan, interestFee);
    }

    function getCollateralValue(
        address oracle,
        address token,
        uint256 amount
    ) public view returns (uint256) {
        return amount.mul(IPriceOracle(oracle).getNormalizedPrice(IERC20(token)));
    }

    function _repay(
        DataTypes.LoanData storage loan,
        //mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        mapping(address => mapping(uint256 => uint256)) storage collateralTokensAmount,
        uint256 amount,
        uint256 principalPayment,
        address core
    ) internal {
        loan.lastInteractionAt = uint40(block.timestamp);
        if (loan.principalAmount > 0) {
            emit Repay(loan.id, amount);
        } else {
            uint256 collateralAmount = loan.collateralAmount;
            //collateralTokens[loan.collateralToken].collateralAmount[loan.collateralTokenId] -= collateralAmount;
            collateralTokensAmount[loan.collateralToken][loan.collateralTokenId] -= loan.collateralAmount;
            loan.collateralAmount = 0;

            IMintableAndBurnableERC20(ICore(core).baks()).burn(
                address(this),
                principalPayment + loan.stabilizationAmount
            );

            loan.isActive = false;

            if (loan.tokenType == DataTypes.TokenType.ERC1155) {
                IERC1155(loan.collateralToken).safeTransferFrom(
                    address(this),
                    msg.sender,
                    loan.collateralTokenId,
                    collateralAmount,
                    ""
                );
            } else {
                uint256 denormalizedCollateralAmount = IERC20(loan.collateralToken).denormalizeAmount(collateralAmount);
                IERC20(loan.collateralToken).safeTransfer(loan.borrower, denormalizedCollateralAmount);
            }

            emit Repaid(loan.id);
            /* if (!loan.isNativeCurrency) {
                loan.collateralToken.safeTransfer(loan.borrower, denormalizedCollateralAmount);
            } else {
                IWrappedNativeCurrency(core.wrappedNativeCurrency()).withdraw(denormalizedCollateralAmount);
                (bool success, ) = msg.sender.call{value: denormalizedCollateralAmount}("");
                if (!success) {
                    revert BaksDAONativeCurrencyTransferFailed();
                }
            } */
        }
    }

    function _createLoan(
        DataTypes.LoanData[] storage loans,
        mapping(address => uint256[]) storage loanIds,
        //mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        mapping(address => mapping(uint256 => uint256)) storage collateralTokensAmount,
        DataTypes.LoanData memory loan,
        DataTypes.FeeData memory fees,
        address core,
        uint256 initialLoanToValueRatio
    ) internal returns (DataTypes.LoanData memory) {
        if (loan.principalAmount == 0) {
            revert Errors.BaksDAOBorrowZeroAmount();
        }
        if (loan.principalAmount < ICore(core).minimumPrincipalAmount()) {
            revert Errors.BaksDAOBorrowBelowMinimumPrincipalAmount();
        }

        IMintableAndBurnableERC20 baks = IMintableAndBurnableERC20(ICore(core).baks());
        baks.mint(address(this), loan.stabilizationAmount);
        baks.mint(ICore(core).exchangeFund(), fees.exchangeFee);
        baks.mint(ICore(core).developmentFund(), fees.developmentFee);
        baks.mint(loan.borrower, loan.principalAmount);

        uint256 id = loans.length;
        loan.id = id;
        loan.interestFee = ICore(core).interest();

        loans.push(loan);
        loanIds[loan.borrower].push(id);

        /*         //add tokenId to array of tokenIds if it is not already there
        console.log("Checking if tokenId exists in Array");
        if (
            collateralTokens[loan.collateralToken].collateralTokenIds[loan.collateralTokenId] != loan.collateralTokenId
        ) {
            console.log("Trying to push new TokenID and Amount");
            collateralTokens[loan.collateralToken].collateralTokenIds.push(loan.collateralTokenId);
            //collateralTokens[loan.collateralToken].collateralAmount.push(loan.collateralTokenId);
        } */

        //increase collateralAmount of tokenId
        //collateralTokens[loan.collateralToken].collateralAmount[loan.collateralTokenId] += loan.collateralAmount;
        collateralTokensAmount[loan.collateralToken][loan.collateralTokenId] += loan.collateralAmount;

        emit Borrow(
            id,
            loan.borrower,
            loan.collateralToken,
            loan.principalAmount,
            loan.collateralAmount,
            initialLoanToValueRatio
        );

        return loan;
    }

    function _calculateInterest(DataTypes.LoanData storage loan, uint256 interestFee)
        internal
        view
        returns (uint256 interest)
    {
        interest = loan.principalAmount.mul(interestFee).mul(
            (block.timestamp - loan.lastInteractionAt).mulDiv(ONE, SECONDS_PER_YEAR)
        );
    }

    function _discountedInterest(DataTypes.LoanData storage loan, uint256 newInterest)
        internal
        view
        returns (uint256 interest)
    {
        if (loan.interestFee == 0) {
            interest = 0;
        } else {
            interest = loan.interestAmount.div(loan.interestFee).mul(newInterest);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function abs(int256 a) internal pure returns (uint256) {
        return a >= 0 ? uint256(a) : uint256(-a);
    }

    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }
        uint256 xAux = x;
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        uint256 repeat = 7;
        while (repeat > 0) {
            result = (result + x / result) >> 1;
            repeat--;
        }
        uint256 roundedDownResult = x / result;

        return result >= roundedDownResult ? roundedDownResult : result;
    }

    function fpsqrt(uint256 a) internal pure returns (uint256 result) {
        if (a == 0) result = 0;
        else result = sqrt(a) * 1e9;
    }

    function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {
        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            // No need to shift x any more.
            msb += 1;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {IERC20} from "./../interfaces/IERC20.sol";
import "./Address.sol";

error SafeERC20NoReturnData();

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        callWithOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, amount));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        callWithOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, amount));
    }

    function callWithOptionalReturn(IERC20 token, bytes memory data) internal {
        address tokenAddress = address(token);

        bytes memory returnData = tokenAddress.functionCall(data, "SafeERC20: low-level call failed");
        if (returnData.length > 0) {
            if (!abi.decode(returnData, (bool))) {
                revert SafeERC20NoReturnData();
            }
        }
    }
}