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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import {DataTypes} from "./DataTypes.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {ICore} from "../interfaces/ICore.sol";
import {Errors} from "./Errors.sol";
import {EnumerableAddressSet} from "./EnumerableAddressSet.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

library CollateralLogic {
    using EnumerableAddressSet for EnumerableAddressSet.Set;

    /// @dev Генерируется после добавления нового залогового токена.
    /// @param token Залоговый токен.
    event CollateralTokenListed(address indexed token);
    /// @dev Генерируется после удаления залогового токена.
    /// @param token Залоговый токен.
    event CollateralTokenUnlisted(address indexed token);

    /*     /// @dev Генерируется после добавления нового залогового ERC1155 токена.
    /// @param token Залоговый токен.
    event ERC1155CollateralTokenListed(address indexed token);
    /// @dev Генерируется после удаления залогового ERC1155 токена.
    /// @param token Залоговый токен.
    event ERC1155CollateralTokenUnlisted(address indexed token); */

    /// @dev Генерируется после изменения начального LTV залогового токена.
    /// @param token Залоговый токен.
    /// @param initialLoanToValueRatio Начальный LTV.
    /// @param newInitialLoanToValueRatio Новый начальный LTV.
    event InitialLoanToValueRatioUpdated(
        address indexed token,
        uint256 initialLoanToValueRatio,
        uint256 newInitialLoanToValueRatio
    );

    /*     /// @dev Генерируется после изменения начального LTV залогового ERC1155 токена.
    /// @param token Залоговый токен.
    /// @param initialLoanToValueRatio Начальный LTV.
    /// @param newInitialLoanToValueRatio Новый начальный LTV.
    event ERC1155InitialLoanToValueRatioUpdated(
        address indexed token,
        uint256 initialLoanToValueRatio,
        uint256 newInitialLoanToValueRatio
    ); */

    /// @dev Генерируется после изменения порога MarginCall залогового токена.
    /// @param token Залоговый токен.
    /// @param initialLoanToValueRatio Начальный LTV.
    /// @param newInitialLoanToValueRatio Новый начальный LTV.
    event MarginCallLoanToValueRatioUpdated(
        address indexed token,
        uint256 initialLoanToValueRatio,
        uint256 newInitialLoanToValueRatio
    );

    /// @dev Генерируется после изменения порога ликвидации залогового токена.
    /// @param token Залоговый токен.
    /// @param initialLoanToValueRatio Начальный LTV.
    /// @param newInitialLoanToValueRatio Новый начальный LTV.
    event LiquidationLoanToValueRatioUpdated(
        address indexed token,
        uint256 initialLoanToValueRatio,
        uint256 newInitialLoanToValueRatio
    );

    /// @dev Генерируется после изменения оракула для залогового токена.
    /// @param token Залоговый токен.
    /// @param priceOracle Оракул.
    /// @param newPriceOracle Новый оракул.
    event CollateralTokenPriceOracleUpdated(address indexed token, address priceOracle, address newPriceOracle);

    /*     /// @dev Генерируется после изменения оракула для залогового ERC1155 токена.
    /// @param token Залоговый токен.
    /// @param priceOracle Оракул.
    /// @param newPriceOracle Новый оракул.
    event ERC1155CollateralTokenPriceUpdated(address indexed token, address priceOracle, address newPriceOracle); */

    function listOrUpdateCollateralToken(
        mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        EnumerableAddressSet.Set storage collateralTokensSet,
        address token,
        address priceOracle,
        DataTypes.TokenType tokenType,
        uint256 initialLoanToValueRatio,
        uint256 marginCallLoanToValueRatio,
        uint256 liquidationLoanToValueRatio,
        uint8 cDecimals
    ) external {
        if (initialLoanToValueRatio >= marginCallLoanToValueRatio) {
            revert Errors.BaksDAOInitialLoanToValueRatioTooHigh(token, initialLoanToValueRatio);
        }

        if (tokenType != DataTypes.TokenType.ERC1155) {
            uint8 decimals = IERC20(token).decimals();
            if (decimals == 0) {
                revert Errors.BaksDAOCollateralTokenZeroDecimals(token);
            }
            if (decimals > cDecimals) {
                revert Errors.BaksDAOCollateralTokenTooLargeDecimals(token, decimals);
            }
        }

        uint256 oldInitialLoanToValueRatio = 0;
        uint256 oldMarginCallLoanToValueRatio = 0;
        uint256 oldLiquidationLoanToValueRatio = 0;
        address oldPriceOracle = address(0);

        if (!collateralTokensSet.contains(token)) {
            //uint256[] memory collateralTokenIds;
            //uint256[] memory collateralAmount;
            collateralTokens[token] = DataTypes.CollateralTokenData({
                collateralToken: token,
                priceOracle: priceOracle,
                isActive: true,
                tokenType: tokenType,
                initialLoanToValueRatio: initialLoanToValueRatio,
                marginCallLoanToValueRatio: marginCallLoanToValueRatio,
                liquidationLoanToValueRatio: liquidationLoanToValueRatio
                //collateralTokenIds: collateralTokenIds,
                //collateralAmount: collateralAmount
            });
            collateralTokensSet.add(token);
        } else {
            DataTypes.CollateralTokenData storage collateralToken = collateralTokens[token];

            collateralToken.isActive = true;
            oldPriceOracle = collateralToken.priceOracle;
            collateralToken.priceOracle = priceOracle;
            oldInitialLoanToValueRatio = collateralToken.initialLoanToValueRatio;
            collateralToken.initialLoanToValueRatio = initialLoanToValueRatio;
            oldMarginCallLoanToValueRatio = collateralToken.marginCallLoanToValueRatio;
            collateralToken.marginCallLoanToValueRatio = marginCallLoanToValueRatio;
            oldLiquidationLoanToValueRatio = collateralToken.liquidationLoanToValueRatio;
            collateralToken.liquidationLoanToValueRatio = liquidationLoanToValueRatio;
        }
        collateralTokensSet.activeCount++;
        emit CollateralTokenListed(token);
        emit CollateralTokenPriceOracleUpdated(token, oldPriceOracle, priceOracle);
        emit InitialLoanToValueRatioUpdated(token, oldInitialLoanToValueRatio, initialLoanToValueRatio);
        emit MarginCallLoanToValueRatioUpdated(token, oldMarginCallLoanToValueRatio, marginCallLoanToValueRatio);
        emit LiquidationLoanToValueRatioUpdated(token, oldLiquidationLoanToValueRatio, liquidationLoanToValueRatio);
    }

    /// @dev Удаляет залоговый токен.
    /// @param token Залоговый токен.
    function unlistCollateralToken(
        mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        EnumerableAddressSet.Set storage collateralTokensSet,
        address token
    ) external {
        if (collateralTokens[token].isActive) {
            collateralTokens[token].isActive = false;
            collateralTokensSet.activeCount--;
            emit CollateralTokenUnlisted(token);
        } else {
            revert Errors.BaksDAOCollateralTokenNotListed(token);
        }
    }

    /*     function listOrUpdateERC1155CollateralToken(
        mapping(address => DataTypes.CollateralTokenData) storage collateralTokens,
        EnumerableAddressSet.Set storage collateralTokensSet,
        address token,
        address priceOracle,
        uint256 initialLoanToValueRatio
    ) external {
        if (initialLoanToValueRatio >= 100e16) {
            //initialLTV should not exceed 100%
            revert Errors.BaksDAOInitialLoanToValueRatioTooHigh(token, initialLoanToValueRatio);
        }

        uint256 oldInitialLoanToValueRatio = 0;
        address oldPriceOracle = address(0);

        if (!collateralTokensSet.contains(token)) {
            DataTypes.CollateralTokenData storage collateralToken = collateralTokens[token];
            collateralToken.collateralToken = token;
            collateralToken.priceOracle = priceOracle;
            collateralToken.isActive = true;
            collateralToken.initialLoanToValueRatio = initialLoanToValueRatio;

            collateralTokensSet.add(token);
        } else {
            DataTypes.CollateralTokenData storage collateralToken = collateralTokens[token];

            collateralToken.isActive = true;
            oldPriceOracle = collateralToken.priceOracle;
            collateralToken.priceOracle = priceOracle;
            oldInitialLoanToValueRatio = collateralToken.initialLoanToValueRatio;
            collateralToken.initialLoanToValueRatio = initialLoanToValueRatio;
        }
        collateralTokensSet.activeCount++;
        emit ERC1155CollateralTokenListed(token);
        emit ERC1155CollateralTokenPriceUpdated(token, oldPriceOracle, priceOracle);
        emit ERC1155InitialLoanToValueRatioUpdated(token, oldInitialLoanToValueRatio, initialLoanToValueRatio);
    }

    /// @dev Удаляет залоговый ERC1155 токен.
    /// @param token Залоговый ERC1155 токен.
    function unlistERC1155CollateralToken(
        mapping(address => DataTypes.CollateralTokenData) storage erc1155CollateralTokens,
        EnumerableAddressSet.Set storage erc1155CollateralTokensSet,
        address token
    ) external {
        if (erc1155CollateralTokens[token].isActive) {
            erc1155CollateralTokens[token].isActive = false;
            erc1155CollateralTokensSet.activeCount--;
            emit ERC1155CollateralTokenUnlisted(token);
        } else {
            revert Errors.BaksDAOERC1155CollateralTokenNotListed(token);
        }
    } */
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

library EnumerableAddressSet {
    struct Set {
        address[] elements;
        mapping(address => uint256) indexes;
        uint256 activeCount;
    }

    function add(Set storage self, address element) internal returns (bool) {
        if (contains(self, element)) {
            return false;
        }

        self.elements.push(element);
        self.indexes[element] = self.elements.length;

        return true;
    }

    function remove(Set storage self, address element) internal returns (bool) {
        uint256 elementIndex = indexOf(self, element);
        if (elementIndex == 0) {
            return false;
        }

        uint256 indexToRemove = elementIndex - 1;
        uint256 lastIndex = count(self) - 1;
        if (indexToRemove != lastIndex) {
            address lastElement = self.elements[lastIndex];
            self.elements[indexToRemove] = lastElement;
            self.indexes[lastElement] = elementIndex;
        }
        self.elements.pop();
        delete self.indexes[element];

        return true;
    }

    function indexOf(Set storage self, address element) internal view returns (uint256) {
        return self.indexes[element];
    }

    function contains(Set storage self, address element) internal view returns (bool) {
        return indexOf(self, element) != 0;
    }

    function count(Set storage self) internal view returns (uint256) {
        return self.elements.length;
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