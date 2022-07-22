// solhint-disable private-vars-leading-underscore
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "../renting/Rentings.sol";
import "../universe/IUniverseRegistry.sol";
import "../listing/Listings.sol";
import "./IPaymentManager.sol";

library Accounts {
    using Accounts for Account;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.AddressToUintMap;

    /**
     * @dev Thrown when the estimated rental fee calculated upon renting
     * is higher than maximal payment amount the renter is willing to pay.
     */
    error RentalFeeSlippage();

    /**
     * @dev Thrown when the amount requested to be paid out is not valid.
     */
    error InvalidWithdrawalAmount(uint256 amount);

    /**
     * @dev Thrown when the amount requested to be paid out is larger than available balance.
     */
    error InsufficientBalance(uint256 balance);

    /**
     * @dev A structure that describes account balance in ERC20 tokens.
     */
    struct Balance {
        address token;
        uint256 amount;
    }

    /**
     * @dev Describes an account state.
     * @param tokenBalances Mapping from an ERC20 token address to the amount.
     */
    struct Account {
        EnumerableMapUpgradeable.AddressToUintMap tokenBalances;
    }

    /**
     * @dev Transfers funds from the account balance to the specific address after validating balance sufficiency.
     */
    function withdraw(
        Account storage self,
        address token,
        uint256 amount,
        address to
    ) external {
        if (amount == 0) revert InvalidWithdrawalAmount(amount);
        uint256 currentBalance = self.balance(token);
        if (amount > currentBalance) revert InsufficientBalance(currentBalance);
        unchecked {
            self.tokenBalances.set(token, currentBalance - amount);
        }
        IERC20Upgradeable(token).safeTransfer(to, amount);
    }

    struct UserEarning {
        IPaymentManager.EarningType earningType;
        address account;
        uint256 value;
        address token;
    }

    struct RentalEarnings {
        UserEarning[] userEarnings;
        // Universe
        uint256 universeId;
        uint256 universeEarningValue;
        address universeEarningToken;
        // Protocol
        uint256 protocolEarningValue;
        address protocolEarningToken;
    }

    function handleRentalPayment(
        Accounts.Registry storage self,
        Rentings.Params calldata rentingParams,
        Rentings.RentalFees calldata fees,
        address payer,
        uint256 maxPaymentAmount,
        IWarperManager warperManager,
        Listings.Registry storage listingRegistry
    ) external returns (RentalEarnings memory earnings) {
        // Ensure no rental fee payment slippage.
        if (fees.total > maxPaymentAmount) revert RentalFeeSlippage();

        // The amount of payment tokens to be accumulated on the Metahub for future payouts.
        // This will include all fees which are not being paid out immediately.
        uint256 accumulatedTokens = 0;

        // Initialize user earnings array. Currently we only support earnings for single user, who is the lister.
        earnings.userEarnings = new UserEarning[](1);

        // Handle lister fee component.
        Listings.Listing storage listing = listingRegistry.listings[rentingParams.listingId];
        UserEarning memory listerEarning = UserEarning({
            earningType: IPaymentManager.EarningType.LISTER_FEE,
            account: listing.lister,
            value: fees.listerBaseFee + fees.listerPremium,
            token: rentingParams.paymentToken
        });
        earnings.userEarnings[0] = listerEarning;

        // If the lister has not requested immediate payout, the earned amount is added to the lister balance.
        // The direct payout case is handled along with other transfers later.
        if (!listing.immediatePayout) {
            self.users[listerEarning.account].increaseBalance(listerEarning.token, listerEarning.value);
            accumulatedTokens += listerEarning.value;
        }

        // Handle universe fee component.
        earnings.universeId = warperManager.warperInfo(rentingParams.warper).universeId;
        earnings.universeEarningValue = fees.universeBaseFee + fees.universePremium;
        earnings.universeEarningToken = rentingParams.paymentToken;
        // Increase universe balance.
        self.universes[earnings.universeId].increaseBalance(
            earnings.universeEarningToken,
            earnings.universeEarningValue
        );
        accumulatedTokens += earnings.universeEarningValue;

        // Handle protocol fee component.
        earnings.protocolEarningValue = fees.protocolFee;
        earnings.protocolEarningToken = rentingParams.paymentToken;
        self.protocol.increaseBalance(earnings.protocolEarningToken, earnings.protocolEarningValue);
        accumulatedTokens += earnings.protocolEarningValue;

        // Proceed with transfers.
        // If immediate payout requested, transfer the lister earnings directly to the lister account.
        if (listing.immediatePayout && listerEarning.value > 0) {
            IERC20Upgradeable(listerEarning.token).safeTransferFrom(payer, listerEarning.account, listerEarning.value);
        }

        // Transfer the accumulated token amount from payer to the metahub.
        if (accumulatedTokens > 0) {
            IERC20Upgradeable(rentingParams.paymentToken).safeTransferFrom(payer, address(this), accumulatedTokens);
        }
    }

    /**
     * @dev Increments value of the particular account balance.
     */
    function increaseBalance(
        Account storage self,
        address token,
        uint256 amount
    ) internal {
        uint256 currentBalance = self.balance(token);
        self.tokenBalances.set(token, currentBalance + amount);
    }

    /**
     * @dev Returns account current balance.
     * Does not revert if `token` is not in the map.
     */
    function balance(Account storage self, address token) internal view returns (uint256) {
        (, uint256 value) = self.tokenBalances.tryGet(token);
        return value;
    }

    /**
     * @dev Returns the list of account balances in various tokens.
     */
    function balances(Account storage self) internal view returns (Balance[] memory) {
        uint256 length = self.tokenBalances.length();
        Balance[] memory allBalances = new Balance[](length);
        for (uint256 i = 0; i < length; i++) {
            (address token, uint256 amount) = self.tokenBalances.at(i);
            allBalances[i] = Balance({token: token, amount: amount});
        }
        return allBalances;
    }

    /**
     * @dev Account registry.
     * @param protocol The protocol account state.
     * @param universes Mapping from a universe ID to the universe account state.
     * @param users Mapping from a user address to the account state.
     */
    struct Registry {
        Account protocol;
        mapping(uint256 => Account) universes;
        mapping(address => Account) users;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableMap.sol)

pragma solidity ^0.8.0;

import "./EnumerableSetUpgradeable.sol";

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * The following map types are supported:
 *
 * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
 * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
 * - `bytes32 -> bytes32` (`Bytes32ToBytes32`) since v4.6.0
 */
library EnumerableMapUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Bytes32ToBytes32Map {
        // Storage of keys
        EnumerableSetUpgradeable.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        Bytes32ToBytes32Map storage map,
        bytes32 key,
        bytes32 value
    ) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToBytes32Map storage map, bytes32 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Bytes32ToBytes32Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function get(
        Bytes32ToBytes32Map storage map,
        bytes32 key,
        string memory errorMessage
    ) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), errorMessage);
        return value;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key), errorMessage))));
    }

    // AddressToUintMap

    struct AddressToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        AddressToUintMap storage map,
        address key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
    }

    /**
     * @dev Returns the element stored at position `index` in the set. O(1).
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressToUintMap storage map, uint256 index) internal view returns (address, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (address(uint160(uint256(key))), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        AddressToUintMap storage map,
        address key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key))), errorMessage));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "../asset/Assets.sol";
import "../metahub/Protocol.sol";
import "../listing/Listings.sol";
import "../warper/Warpers.sol";
import "../universe/IUniverseRegistry.sol";

library Rentings {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using Rentings for RenterInfo;
    using Rentings for Agreement;
    using Rentings for Registry;
    using Assets for Assets.AssetId;
    using Protocol for Protocol.Config;
    using Listings for Listings.Registry;
    using Listings for Listings.Listing;
    using Warpers for Warpers.Registry;
    using Warpers for Warpers.Warper;

    /**
     * A constant that represents one hundred percent for calculation.
     * This defines a calculation precision for percentage values as two decimals.
     * For example: 1 is 0.01%, 100 is 1%, 10_000 is 100%.
     */
    uint16 public constant HUNDRED_PERCENT = 10_000;

    /**
     * @dev Thrown when a rental agreement is being registered for a specific warper ID,
     * while the previous rental agreement for this warper is still effective.
     */
    error RentalAgreementConflict(uint256 conflictingRentalId);

    /**
     * @dev Thrown when attempting to delete effective rental agreement data (before expiration).
     */
    error CannotDeleteEffectiveRentalAgreement(uint256 rentalId);

    /**
     * @dev Warper rental status.
     * NONE - means the warper had never been minted.
     * AVAILABLE - can be rented.
     * RENTED - currently rented.
     */
    enum RentalStatus {
        NONE,
        AVAILABLE,
        RENTED
    }

    /**
     * @dev Defines the maximal allowed number of cycles when looking for expired rental agreements.
     */
    uint256 private constant _GC_CYCLES = 20;

    /**
     * @dev Rental fee breakdown.
     */
    struct RentalFees {
        uint256 total;
        uint256 protocolFee;
        uint256 listerBaseFee;
        uint256 listerPremium;
        uint256 universeBaseFee;
        uint256 universePremium;
    }

    /**
     * @dev Renting parameters structure.
     * It is used to encode all the necessary information to estimate and/or fulfill a particular renting request.
     * @param listingId Listing ID. Also allows to identify the asset being rented.
     * @param warper Warper address.
     * @param renter Renter address.
     * @param rentalPeriod Desired period of asset renting.
     * @param paymentToken The token address which renter offers as a mean of payment.
     */
    struct Params {
        uint256 listingId;
        address warper;
        address renter;
        uint32 rentalPeriod;
        address paymentToken;
    }

    /**
     * @dev Rental agreement information.
     * @param warpedAsset Rented asset.
     * @param collectionId Warped collection ID.
     * @param listingId The corresponding ID of the original asset listing.
     * @param renter The renter account address.
     * @param startTime The rental agreement staring time. This is the timestamp after which the `renter`
     * considered to be an warped asset owner.
     * @param endTime The rental agreement ending time. After this timestamp, the rental agreement is terminated
     * and the `renter` is no longer the owner of the warped asset.
     * @param listingParams Selected listing parameters.
     */
    struct Agreement {
        // slots 0-2
        Assets.Asset warpedAsset;
        // slot 3
        bytes32 collectionId;
        // slot 4
        uint256 listingId;
        // slot 5 (4 bytes left)
        address renter;
        uint32 startTime;
        uint32 endTime;
        // slots 6-7
        Listings.Params listingParams;
    }

    function isEffective(Agreement storage self) internal view returns (bool) {
        return self.endTime > uint32(block.timestamp);
    }

    function duration(Agreement memory self) internal pure returns (uint32) {
        return self.endTime - self.startTime;
    }

    /**
     * @dev Describes user specific renting information.
     * @param rentalIndex Renter's set of rental agreement IDs.
     * @param collectionRentalIndex Mapping from collection ID to the set of rental IDs.
     */
    struct RenterInfo {
        EnumerableSetUpgradeable.UintSet rentalIndex;
        mapping(bytes32 => EnumerableSetUpgradeable.UintSet) collectionRentalIndex;
    }

    /**
     * @dev Describes asset specific renting information.
     * @param latestRentalId Holds the most recent rental agreement ID.
     */
    struct AssetInfo {
        uint256 latestRentalId; // NOTE: This must never be deleted during cleanup.
    }

    /**
     * @dev Renting registry.
     * @param idTracker Rental agreement ID tracker (incremental counter).
     * @param agreements Mapping from rental ID to the rental agreement details.
     * @param renters Mapping from renter address to the user specific renting info.
     * @param assets Mapping from asset ID (byte32) to the asset specific renting info.
     */
    struct Registry {
        CountersUpgradeable.Counter idTracker;
        mapping(uint256 => Agreement) agreements;
        mapping(address => RenterInfo) renters;
        mapping(bytes32 => AssetInfo) assets;
    }

    /**
     * @dev Returns the number of currently registered rental agreements for particular renter account.
     */
    function userRentalCount(Registry storage self, address renter) internal view returns (uint256) {
        return self.renters[renter].rentalIndex.length();
    }

    /**
     * @dev Returns the paginated list of currently registered rental agreements for particular renter account.
     */
    function userRentalAgreements(
        Registry storage self,
        address renter,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Rentings.Agreement[] memory) {
        EnumerableSetUpgradeable.UintSet storage userRentalIndex = self.renters[renter].rentalIndex;
        uint256 indexSize = userRentalIndex.length();
        if (offset >= indexSize) return (new uint256[](0), new Rentings.Agreement[](0));

        if (limit > indexSize - offset) {
            limit = indexSize - offset;
        }

        Rentings.Agreement[] memory agreements = new Rentings.Agreement[](limit);
        uint256[] memory rentalIds = new uint256[](limit);
        for (uint256 i = 0; i < limit; i++) {
            rentalIds[i] = userRentalIndex.at(offset + i);
            agreements[i] = self.agreements[rentalIds[i]];
        }

        return (rentalIds, agreements);
    }

    /**
     * @dev Finds expired user rental agreements associated with `collectionId` and deletes them.
     * Deletes only first N entries defined by `toBeRemoved` param.
     * The total number of cycles is capped by GC_CYCLES constant.
     */
    function deleteExpiredUserRentalAgreements(
        Registry storage self,
        address renter,
        bytes32 collectionId,
        uint256 toBeRemoved
    ) external {
        EnumerableSetUpgradeable.UintSet storage rentalIndex = self.renters[renter].collectionRentalIndex[collectionId];
        uint256 rentalCount = rentalIndex.length();
        if (rentalCount == 0 || toBeRemoved == 0) return;

        uint256 maxCycles = rentalCount < _GC_CYCLES ? rentalCount : _GC_CYCLES;
        uint256 removed = 0;

        for (uint256 i = 0; i < maxCycles; i++) {
            uint256 rentalId = rentalIndex.at(i);

            if (!self.agreements[rentalId].isEffective()) {
                // Warning: we are iterating an array that we are also modifying!
                _removeRentalAgreement(self, rentalId);
                removed += 1;
                maxCycles -= 1; // This is so we account for reduced `rentalCount`.

                // Stop iterating if we have cleaned up enough desired items.
                if (removed == toBeRemoved) break;
            }
        }
    }

    /**
     * @dev Performs new rental agreement registration.
     */
    function register(Registry storage self, Agreement memory agreement) external returns (uint256 rentalId) {
        // Make sure the there is no active rentals for the warper ID.
        bytes32 assetId = agreement.warpedAsset.id.hash();
        uint256 latestRentalId = self.assets[assetId].latestRentalId;
        if (latestRentalId != 0 && self.agreements[latestRentalId].isEffective()) {
            revert RentalAgreementConflict(latestRentalId);
        }

        // Generate new rental ID.
        self.idTracker.increment();
        rentalId = self.idTracker.current();

        // Save new rental agreement.
        self.agreements[rentalId] = agreement;

        // Update warper latest rental ID.
        self.assets[assetId].latestRentalId = rentalId;

        // Update user rental data.
        self.renters[agreement.renter].rentalIndex.add(rentalId);
        self.renters[agreement.renter].collectionRentalIndex[agreement.collectionId].add(rentalId);
    }

    /**
     * @dev Safely removes expired rental data from the registry.
     */
    function removeExpiredRentalAgreement(Registry storage self, uint256 rentalId) external {
        if (self.agreements[rentalId].isEffective()) revert CannotDeleteEffectiveRentalAgreement(rentalId);
        _removeRentalAgreement(self, rentalId);
    }

    /**
     * @dev Removes rental data from the registry.
     */
    function _removeRentalAgreement(Registry storage self, uint256 rentalId) private {
        address renter = self.agreements[rentalId].renter;
        bytes32 collectionId = self.agreements[rentalId].collectionId;

        // Remove user rental data.
        self.renters[renter].rentalIndex.remove(rentalId);
        self.renters[renter].collectionRentalIndex[collectionId].remove(rentalId);

        // Delete rental agreement.
        delete self.agreements[rentalId];
    }

    /**
     * @dev Finds all effective rental agreements from specific collection.
     * Returns the total value rented by `renter`.
     */
    function collectionRentedValue(
        Registry storage self,
        address renter,
        bytes32 collectionId
    ) external view returns (uint256 value) {
        EnumerableSetUpgradeable.UintSet storage rentalIndex = self.renters[renter].collectionRentalIndex[collectionId];
        uint256 length = rentalIndex.length();
        for (uint256 i = 0; i < length; i++) {
            Agreement storage agreement = self.agreements[rentalIndex.at(i)];
            if (agreement.isEffective()) {
                value += agreement.warpedAsset.value;
            }
        }
    }

    /**
     * @dev Returns asset rental status based on latest rental agreement.
     */
    function assetRentalStatus(Registry storage self, Assets.AssetId memory assetId)
        external
        view
        returns (RentalStatus)
    {
        uint256 latestRentalId = self.assets[assetId.hash()].latestRentalId;
        if (latestRentalId == 0) return RentalStatus.NONE;

        return self.agreements[latestRentalId].isEffective() ? RentalStatus.RENTED : RentalStatus.AVAILABLE;
    }

    /**
     * @dev Main renting request validation function.
     */
    function validateRentingParams(
        Params calldata params,
        Protocol.Config storage protocolConfig,
        Listings.Registry storage listingRegistry,
        IWarperManager warperManager
    ) external view {
        // Validate from the protocol perspective.
        protocolConfig.checkBaseToken(params.paymentToken);

        // Validate from the listing perspective.
        listingRegistry.checkListed(params.listingId);
        Listings.Listing storage listing = listingRegistry.listings[params.listingId];
        listing.checkNotPaused();
        listing.checkValidLockPeriod(params.rentalPeriod);

        // Validate from the warper perspective.
        warperManager.checkRegisteredWarper(params.warper);
        Warpers.Warper memory warper = warperManager.warperInfo(params.warper);
        warper.checkCompatibleAsset(listing.asset);
        warper.checkNotPaused();
        warper.controller.validateRentingParams(listing.asset, params);
    }

    /**
     * @dev Performs rental fee calculation and returns the fee breakdown.
     */
    function calculateRentalFees(
        Params calldata rentingParams,
        Protocol.Config storage protocolConfig,
        Listings.Registry storage listingRegistry,
        IWarperManager warperManager,
        IUniverseRegistry universeRegistry
    ) external view returns (RentalFees memory fees) {
        // Calculate lister base fee.
        Listings.Listing storage listing = listingRegistry.listings[rentingParams.listingId];
        Listings.Params memory listingParams = listing.params;
        // Resolve listing controller to calculate lister fee based on selected listing strategy.
        IListingController listingController = listingRegistry.listingController(listingParams.strategy);
        fees.listerBaseFee = listingController.calculateRentalFee(listingParams, rentingParams);

        // Calculate universe base fee.
        Warpers.Warper memory warper = warperManager.warperInfo(rentingParams.warper);
        uint16 universeRentalFeePercent = universeRegistry.universeRentalFeePercent(warper.universeId);
        fees.universeBaseFee = (fees.listerBaseFee * universeRentalFeePercent) / HUNDRED_PERCENT;

        // Calculate protocol fee.
        fees.protocolFee = (fees.listerBaseFee * protocolConfig.rentalFeePercent) / HUNDRED_PERCENT;

        // Calculate warper premiums.
        (uint256 universePremium, uint256 listerPremium) = warper.controller.calculatePremiums(
            listing.asset,
            rentingParams,
            fees.universeBaseFee,
            fees.listerBaseFee
        );
        fees.listerPremium = listerPremium;
        fees.universePremium = universePremium;

        // Calculate TOTAL rental fee.
        fees.total += fees.listerBaseFee + listerPremium;
        fees.total += fees.universeBaseFee + universePremium;
        fees.total += fees.protocolFee;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IUniverseRegistry {
    /**
     * @dev Thrown when a check is made where the given account must also be the universe owner.
     */
    error AccountIsNotUniverseOwner(address account);

    /**
     * @dev Thrown when a the supplied universe name is empty.
     */
    error EmptyUniverseName();

    /**
     * @dev Thrown when trying to read universe data for a universe is not registered.
     */
    error QueryForNonexistentUniverse(uint256 universeId);

    /**
     * @dev Emitted when a universe is created.
     * @param universeId Universe ID.
     * @param name Universe name.
     */
    event UniverseCreated(uint256 indexed universeId, string name);

    /**
     * @dev Emitted when a universe name is changed.
     * @param universeId Universe ID.
     * @param name The newly set name.
     */
    event UniverseNameChanged(uint256 indexed universeId, string name);

    /**
     * @dev Emitted when universe rental fee is changed.
     * @param universeId Universe ID.
     * @param rentalFeePercent The newly rental fee.
     */
    event UniverseRentalFeeChanged(uint256 indexed universeId, uint16 rentalFeePercent);

    /**
     * @dev Updates the universe token base URI.
     * @param baseURI New base URI. Must include a trailing slash ("/").
     */
    function setUniverseTokenBaseURI(string calldata baseURI) external;

    /**
     * @dev The universe properties & initial configuration params.
     * @param name The universe name.
     * @param rentalFeePercent The base percentage of the rental fee which the universe charges for using its warpers.
     */
    struct UniverseParams {
        string name;
        uint16 rentalFeePercent;
    }

    /**
     * @dev Creates new Universe. This includes minting new universe NFT,
     * where the caller of this method becomes the universe owner.
     * @param params The universe properties & initial configuration params.
     * @return Universe ID (universe token ID).
     */
    function createUniverse(UniverseParams calldata params) external returns (uint256);

    /**
     * @dev Update the universe name.
     * @param universeId The unique identifier for the universe.
     * @param universeName The universe name to set.
     */
    function setUniverseName(uint256 universeId, string memory universeName) external;

    /**
     * @dev Update the universe rental fee percent.
     * @param universeId The unique identifier for the universe.
     * @param rentalFeePercent The universe rental fee percent.
     */
    function setUniverseRentalFeePercent(uint256 universeId, uint16 rentalFeePercent) external;

    /**
     * @dev Returns Universe owner address.
     * @param universeId Universe ID.
     * @return Universe owner.
     */
    function universeOwner(uint256 universeId) external view returns (address);

    /**
     * @dev Returns Universe rental fee percent.
     * @param universeId Universe ID.
     * @return universe fee percent.
     */
    function universeRentalFeePercent(uint256 universeId) external view returns (uint16);

    /**
     * @dev Returns name.
     * @param universeId Universe ID.
     * @return universe name.
     */
    function universeName(uint256 universeId) external view returns (string memory);

    /**
     * @dev Returns the Universe token address.
     */
    function universeToken() external view returns (address);

    /**
     * @dev Returns the Universe token base URI.
     */
    function universeTokenBaseURI() external view returns (string memory);

    /**
     * @dev Aggregate and return Universe data.
     * @param universeId Universe-specific ID.
     * @return name The name of the universe.
     * @return rentalFeePercent The base percentage of the rental fee which the universe charges for using its warpers.
     */
    function universe(uint256 universeId) external view returns (string memory name, uint16 rentalFeePercent);

    /**
     * @dev Reverts if the universe owner is not the provided account address.
     * @param universeId Universe ID.
     * @param account The address of the expected owner.
     */
    function checkUniverseOwner(uint256 universeId, address account) external view;

    /**
     * @dev Returns `true` if the universe owner is the supplied account address.
     * @param universeId Universe ID.
     * @param account The address of the expected owner.
     */
    function isUniverseOwner(uint256 universeId, address account) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "../asset/Assets.sol";
import "./IListingController.sol";
import "./IListingStrategyRegistry.sol";

library Listings {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using Listings for Registry;
    using Listings for Listing;
    using Assets for Assets.Asset;

    /**
     * @dev Thrown when the `listingId` is invalid or the asset has been delisted.
     */
    error NotListed(uint256 listingId);

    /**
     * @dev Thrown when the `listingId` has never been registered.
     */
    error ListingIsNotRegistered(uint256 listingId);

    /**
     * @dev Thrown when the operation is not allowed due to the listing being paused.
     */
    error ListingIsPaused();

    /**
     * @dev Thrown when the operation is not allowed due to the listing not being paused.
     */
    error ListingIsNotPaused();

    /**
     * @dev Thrown when attempting to lock the listed asset for the period longer than the lister allowed.
     */
    error InvalidLockPeriod(uint32 period);

    /**
     * @dev Thrown when the listing strategy is not registered or deprecated.
     * @param strategyId Unsupported listing strategy ID.
     */
    error UnsupportedListingStrategy(bytes4 strategyId);

    /**
     * @dev Thrown when the operation is not allowed due to the listing group being nonempty.
     * @param listingGroupId Listing group ID.
     */
    error ListingGroupIsNotEmpty(uint256 listingGroupId);

    /**
     * @dev Thrown when the provided `account` doesn't match the listing group owner address.
     * @param listingGroupId Listing group ID.
     * @param account Invalid owner account.
     */
    error InvalidListingGroupOwner(uint256 listingGroupId, address account);

    /*
     * @dev Listing strategy identifiers to be used across the system:
     */
    bytes4 public constant FIXED_PRICE = bytes4(keccak256("FIXED_PRICE"));
    bytes4 public constant FIXED_PRICE_WITH_REWARD = bytes4(keccak256("FIXED_PRICE_WITH_REWARD"));

    /**
     * @dev Listing params.
     * The layout of `data` might vary for different listing strategies.
     * For example, in case of FIXED_PRICE strategy, the `data` might contain only base rate,
     * and for more advanced auction strategies it might include period, min bid step etc.
     * @param strategy Listing strategy ID
     * @param data Listing strategy data.
     */
    struct Params {
        bytes4 strategy;
        bytes data;
    }

    /**
     * @dev Listing structure.
     * @param asset Listed asset structure.
     * @param params Listing strategy parameters.
     * @param lister Lister account address.
     * @param maxLockPeriod The maximum amount of time the asset owner can wait before getting the asset back.
     * @param lockedTill The earliest possible time when the asset can be returned to the owner.
     * @param immediatePayout Indicates whether the rental fee must be transferred to the lister on every renting.
     * If FALSE, the rental fees get accumulated until withdrawn manually.
     * @param delisted Indicates whether the asset is delisted.
     * @param paused Indicates whether the listing is paused.
     * @param groupId Listing group ID.
     */
    struct Listing {
        // slots 0-2
        Assets.Asset asset;
        // slot 3-4
        Params params;
        // slot 5 (1 byte)
        address lister;
        uint32 maxLockPeriod;
        uint32 lockedTill;
        bool immediatePayout;
        bool delisted;
        bool paused;
        // slot 6
        uint256 groupId;
    }

    /**
     * @dev Listing related data associated with the specific account.
     * @param listingIndex The set of listing IDs.
     * @param listingGroupIndex The set of listing group IDs.
     */
    struct ListerInfo {
        EnumerableSetUpgradeable.UintSet listingIndex;
        EnumerableSetUpgradeable.UintSet listingGroupIndex;
    }

    /**
     * @dev Listing related data associated with the specific account.
     * @param listingIndex The set of listing IDs.
     */
    struct AssetInfo {
        EnumerableSetUpgradeable.UintSet listingIndex;
    }

    /**
     * @dev Listing group information.
     * @param name The listing group name.
     * @param owner The listing group owner address.
     * @param listingIndex The set of listing IDs which belong to the group.
     */
    struct ListingGroupInfo {
        string name;
        address owner;
        EnumerableSetUpgradeable.UintSet listingIndex;
    }

    /**
     * @dev Listing registry.
     * @param idTracker Listing ID tracker (incremental counter).
     * @param strategyRegistry Listing strategy registry contract.
     * @param listingIndex The global set of registered listing IDs.
     * @param listings Mapping from listing ID to the listing info.
     * @param listers Mapping from lister address to the lister info.
     * @param assets Mapping from an asset address to the asset info.
     * @param listingGroups Mapping from listing group ID to the listing group info.
     */
    struct Registry {
        CountersUpgradeable.Counter listingIdTracker;
        IListingStrategyRegistry strategyRegistry;
        EnumerableSetUpgradeable.UintSet listingIndex;
        mapping(uint256 => Listing) listings;
        mapping(address => ListerInfo) listers;
        mapping(address => AssetInfo) assets;
        CountersUpgradeable.Counter listingGroupIdTracker;
        mapping(uint256 => ListingGroupInfo) listingGroups;
    }

    /**
     * @dev Puts the listing on pause.
     */
    function pause(Listing storage self) internal {
        if (self.paused) revert ListingIsPaused();

        self.paused = true;
    }

    /**
     * @dev Lifts the listing pause.
     */
    function unpause(Listing storage self) internal {
        if (!self.paused) revert ListingIsNotPaused();

        self.paused = false;
    }

    /**
     * Determines whether the listing is active.
     */
    function listed(Listing storage self) internal view returns (bool) {
        return self.lister != address(0) && !self.delisted;
    }

    /**
     * @dev Reverts if the listing is paused.
     */
    function checkNotPaused(Listing storage self) internal view {
        if (self.paused) revert ListingIsPaused();
    }

    /*
     * @dev Validates lock period.
     */
    function isValidLockPeriod(Listing storage self, uint32 lockPeriod) internal view returns (bool) {
        return (lockPeriod > 0 && lockPeriod <= self.maxLockPeriod);
    }

    /**
     * @dev Reverts if the lock period is not valid.
     */
    function checkValidLockPeriod(Listing storage self, uint32 lockPeriod) internal view {
        if (!self.isValidLockPeriod(lockPeriod)) revert InvalidLockPeriod(lockPeriod);
    }

    /**
     * @dev Extends listing lock time.
     * Does not modify the state if current lock time is larger.
     */
    function addLock(Listing storage self, uint32 unlockTimestamp) internal {
        // Listing is already locked till later time, no need to extend locking period.
        if (self.lockedTill >= unlockTimestamp) return;
        // Extend listing lock.
        self.lockedTill = unlockTimestamp;
    }

    /**
     * @dev Registers new listing group.
     * @param name The listing group name.
     * @param owner The listing group owner address.
     * @return listingGroupId New listing group ID.
     */
    function registerListingGroup(
        Registry storage self,
        string memory name,
        address owner
    ) external returns (uint256 listingGroupId) {
        listingGroupId = _registerListingGroup(self, name, owner);
    }

    /**
     * @dev Removes listing group data.
     * @param listingGroupId The ID of the listing group to be deleted.
     */
    function removeListingGroup(Registry storage self, uint256 listingGroupId) external {
        ListingGroupInfo storage listingGroup = self.listingGroups[listingGroupId];

        // Deleting nonempty listing groups is forbidden.
        if (listingGroup.listingIndex.length() > 0) revert ListingGroupIsNotEmpty(listingGroupId);

        // Remove the listing group ID from the user account data.
        self.listers[listingGroup.owner].listingGroupIndex.remove(listingGroupId);

        // Delete listing group.
        delete self.listingGroups[listingGroupId];
    }

    /**
     * @dev Registers new listing.
     * @return listingId New listing ID.
     * @return listingGroupId Effective listing group ID.
     */
    function register(Registry storage self, Listing memory listing)
        external
        returns (uint256 listingId, uint256 listingGroupId)
    {
        // Generate new listing ID.
        self.listingIdTracker.increment();
        listingId = self.listingIdTracker.current();

        // Listing is being added to an existing group.
        if (listing.groupId != 0) {
            listingGroupId = listing.groupId;
            self.checkListingGroupOwner(listingGroupId, listing.lister);
        } else {
            // Otherwise the new listing group is created and the listing is added to this group by default.
            listingGroupId = _registerListingGroup(self, "", listing.lister);
            listing.groupId = listingGroupId;
        }

        // Add new listing ID to the global index.
        self.listingIndex.add(listingId);
        // Add new listing ID to the listing group index.
        self.listingGroups[listingGroupId].listingIndex.add(listingId);
        // Add user listing data.
        self.listers[listing.lister].listingIndex.add(listingId);
        // Add asset listing data.
        self.assets[listing.asset.token()].listingIndex.add(listingId);
        // Store new listing record.
        self.listings[listingId] = listing;
    }

    /**
     * @dev Removes listing data.
     * @param listingId The ID of the listing to be deleted.
     */
    function remove(Registry storage self, uint256 listingId) external {
        address lister = self.listings[listingId].lister;
        address original = self.listings[listingId].asset.token();
        uint256 listingGroupId = self.listings[listingId].groupId;

        // Remove the listing ID from the global index.
        self.listingIndex.remove(listingId);
        // Remove the listing ID from the group index.
        self.listingGroups[listingGroupId].listingIndex.remove(listingId);
        // Remove user listing data.
        self.listers[lister].listingIndex.remove(listingId);
        // Remove asset listing data.
        self.assets[original].listingIndex.remove(listingId);
        // Delete listing.
        delete self.listings[listingId];
    }

    /**
     * @dev Returns the paginated list of currently registered listings.
     */
    function allListings(
        Registry storage self,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listing[] memory) {
        return self.paginateIndexedListings(self.listingIndex, offset, limit);
    }

    /**
     * @dev Returns the paginated list of currently registered listings for the particular lister account.
     */
    function userListings(
        Registry storage self,
        address lister,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listing[] memory) {
        return self.paginateIndexedListings(self.listers[lister].listingIndex, offset, limit);
    }

    /**
     * @dev Returns the paginated list of currently registered listings for the original asset.
     */
    function assetListings(
        Registry storage self,
        address original,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listing[] memory) {
        return self.paginateIndexedListings(self.assets[original].listingIndex, offset, limit);
    }

    /**
     * @dev Reverts if listing has not been registered.
     * @param listingId Listing ID.
     */
    function checkRegisteredListing(Registry storage self, uint256 listingId) external view {
        if (!self.isRegisteredListing(listingId)) revert ListingIsNotRegistered(listingId);
    }

    /**
     * @dev Reverts if the provided `account` doesn't match the listing group owner address.
     * @param listingGroupId Listing group ID.
     * @param account The account to check ownership for.
     */
    function checkListingGroupOwner(
        Registry storage self,
        uint256 listingGroupId,
        address account
    ) internal view {
        if (self.listingGroups[listingGroupId].owner != account)
            revert InvalidListingGroupOwner(listingGroupId, account);
    }

    /**
     * @dev Checks listing registration by ID.
     * @param listingId Listing ID.
     */
    function isRegisteredListing(Registry storage self, uint256 listingId) internal view returns (bool) {
        return self.listings[listingId].lister != address(0);
    }

    /**
     * @dev Reverts if listing strategy is not supported.
     * @param strategyId Listing strategy ID.
     */
    function checkSupportedListingStrategy(Registry storage self, bytes4 strategyId) internal view {
        if (!self.strategyRegistry.isRegisteredListingStrategy(strategyId))
            revert UnsupportedListingStrategy(strategyId);
    }

    /**
     * @dev Returns listing controller for strategy.
     * @param strategyId Listing strategy ID.
     */
    function listingController(Registry storage self, bytes4 strategyId) internal view returns (IListingController) {
        return IListingController(self.strategyRegistry.listingController(strategyId));
    }

    /**
     * @dev Reverts if listing is not registered or has been already delisted.
     * @param listingId Listing ID.
     */
    function checkListed(Registry storage self, uint256 listingId) internal view {
        if (!self.listings[listingId].listed()) revert NotListed(listingId);
    }

    /**
     * @dev Returns the number of currently registered listings.
     */
    function listingCount(Registry storage self) internal view returns (uint256) {
        return self.listingIndex.length();
    }

    /**
     * @dev Returns the number of currently registered listings for a particular lister account.
     */
    function userListingCount(Registry storage self, address lister) internal view returns (uint256) {
        return self.listers[lister].listingIndex.length();
    }

    /**
     * @dev Returns the number of currently registered listings for a particular original asset.
     */
    function assetListingCount(Registry storage self, address original) internal view returns (uint256) {
        return self.assets[original].listingIndex.length();
    }

    /**
     * @dev Returns the paginated list of currently registered listing using provided index reference.
     */
    function paginateIndexedListings(
        Registry storage self,
        EnumerableSetUpgradeable.UintSet storage listingIndex,
        uint256 offset,
        uint256 limit
    ) internal view returns (uint256[] memory, Listing[] memory) {
        uint256 indexSize = listingIndex.length();
        if (offset >= indexSize) return (new uint256[](0), new Listing[](0));

        if (limit > indexSize - offset) {
            limit = indexSize - offset;
        }

        Listing[] memory listings = new Listing[](limit);
        uint256[] memory listingIds = new uint256[](limit);
        for (uint256 i = 0; i < limit; i++) {
            listingIds[i] = listingIndex.at(offset + i);
            listings[i] = self.listings[listingIds[i]];
        }

        return (listingIds, listings);
    }

    /**
     * @dev Registers new listing group.
     * @param name The listing group name.
     * @param owner The listing group owner address.
     * @return listingGroupId New listing group ID.
     */
    function _registerListingGroup(
        Registry storage self,
        string memory name,
        address owner
    ) private returns (uint256 listingGroupId) {
        // Generate new listing group ID.
        self.listingGroupIdTracker.increment();
        listingGroupId = self.listingGroupIdTracker.current();

        // Store new listing group record.
        self.listingGroups[listingGroupId].name = name;
        self.listingGroups[listingGroupId].owner = owner;

        // Associate the new listing group with the user account.
        self.listers[owner].listingGroupIndex.add(listingGroupId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Accounts.sol";

interface IPaymentManager {
    /**
     * @notice Describes the earning type.
     */
    enum EarningType {
        LISTER_FEE
    }

    /**
     * @dev Emitted when a user has earned some amount tokens.
     * @param user Address of the user that earned some amount.
     * @param earningType Describes the type of the user.
     * @param paymentToken The currency that the user has earned.
     * @param amount The amount of tokens that the user has earned.
     */
    event UserEarned(
        address indexed user,
        EarningType indexed earningType,
        address indexed paymentToken,
        uint256 amount
    );

    /**
     * @dev Emitted when the universe has earned some amount of tokens.
     * @param universeId ID of the universe that earned the tokens.
     * @param paymentToken The currency that the user has earned.
     * @param amount The amount of tokens that the user has earned.
     */
    event UniverseEarned(uint256 indexed universeId, address indexed paymentToken, uint256 amount);

    /**
     * @dev Emitted when the protocol has earned some amount of tokens.
     * @param paymentToken The currency that the user has earned.
     * @param amount The amount of tokens that the user has earned.
     */
    event ProtocolEarned(address indexed paymentToken, uint256 amount);

    /**
     * @dev Transfers the specific `amount` of `token` from a protocol balance to an arbitrary address.
     * @param token The token address.
     * @param amount The amount to be withdrawn.
     * @param to The payee address.
     */
    function withdrawProtocolFunds(
        address token,
        uint256 amount,
        address to
    ) external;

    /**
     * @dev Transfers the specific `amount` of `token` from a universe balance to an arbitrary address.
     * @param universeId The universe ID.
     * @param token The token address.
     * @param amount The amount to be withdrawn.
     * @param to The payee address.
     */
    function withdrawUniverseFunds(
        uint256 universeId,
        address token,
        uint256 amount,
        address to
    ) external;

    /**
     * @dev Transfers the specific `amount` of `token` from a user balance to an arbitrary address.
     * @param token The token address.
     * @param amount The amount to be withdrawn.
     * @param to The payee address.
     */
    function withdrawFunds(
        address token,
        uint256 amount,
        address to
    ) external;

    /**
     * @dev Returns the amount of `token`, currently accumulated by the protocol.
     * @param token The token address.
     * @return Balance of `token`.
     */
    function protocolBalance(address token) external view returns (uint256);

    /**
     * @dev Returns the list of protocol balances in various tokens.
     * @return List of balances.
     */
    function protocolBalances() external view returns (Accounts.Balance[] memory);

    /**
     * @dev Returns the amount of `token`, currently accumulated by the universe.
     * @param universeId The universe ID.
     * @param token The token address.
     * @return Balance of `token`.
     */
    function universeBalance(uint256 universeId, address token) external view returns (uint256);

    /**
     * @dev Returns the list of universe balances in various tokens.
     * @param universeId The universe ID.
     * @return List of balances.
     */
    function universeBalances(uint256 universeId) external view returns (Accounts.Balance[] memory);

    /**
     * @dev Returns the amount of `token`, currently accumulated by the user.
     * @param account The account to query the balance for.
     * @param token The token address.
     * @return Balance of `token`.
     */
    function balance(address account, address token) external view returns (uint256);

    /**
     * @dev Returns the list of user balances in various tokens.
     * @param account The account to query the balance for.
     * @return List of balances.
     */
    function balances(address account) external view returns (Accounts.Balance[] memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
 */
library EnumerableSetUpgradeable {
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
library CountersUpgradeable {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./IAssetController.sol";
import "./IAssetVault.sol";
import "./IAssetClassRegistry.sol";

library Assets {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using Address for address;
    using Assets for Registry;
    using Assets for Asset;

    /*
     * @dev This is the list of asset class identifiers to be used across the system.
     */
    bytes4 public constant ERC721 = bytes4(keccak256("ERC721"));
    bytes4 public constant ERC1155 = bytes4(keccak256("ERC1155"));

    bytes32 public constant ASSET_ID_TYPEHASH = keccak256("AssetId(bytes4 class,bytes data)");

    bytes32 public constant ASSET_TYPEHASH =
        keccak256("Asset(AssetId id,uint256 value)AssetId(bytes4 class,bytes data)");

    /**
     * @dev Thrown upon attempting to register an asset twice.
     * @param asset Duplicate asset address.
     */
    error AssetIsAlreadyRegistered(address asset);

    /**
     * @dev Communicates asset identification information.
     * The structure designed to be token-standard agnostic,
     * so the layout of `data` might vary for different token standards.
     * For example, in case of ERC721 token, the `data` will contain contract address and tokenId.
     * @param class Asset class ID
     * @param data Asset identification data.
     */
    struct AssetId {
        bytes4 class;
        bytes data;
    }

    /**
     * @dev Calculates Asset ID hash
     */
    function hash(AssetId memory assetId) internal pure returns (bytes32) {
        return keccak256(abi.encode(ASSET_ID_TYPEHASH, assetId.class, keccak256(assetId.data)));
    }

    /**
     * @dev Extracts token contract address from the Asset ID structure.
     * The address is the common attribute for all assets regardless of their asset class.
     */
    function token(AssetId memory self) internal pure returns (address) {
        return abi.decode(self.data, (address));
    }

    /**
     * @dev Uniformed structure to describe arbitrary asset (token) and its value.
     * @param id Asset ID structure.
     * @param value Asset value (amount).
     */
    struct Asset {
        AssetId id;
        uint256 value;
    }

    /**
     * @dev Calculates Asset hash
     */
    function hash(Asset memory asset) internal pure returns (bytes32) {
        return keccak256(abi.encode(ASSET_TYPEHASH, hash(asset.id), asset.value));
    }

    /**
     * @dev Extracts token contract address from the Asset structure.
     * The address is the common attribute for all assets regardless of their asset class.
     */
    function token(Asset memory self) internal pure returns (address) {
        return abi.decode(self.id.data, (address));
    }

    /**
     * @dev Original asset data.
     * @param controller Asset controller.
     * @param assetClass The asset class identifier.
     * @param vault Asset vault.
     */
    struct AssetConfig {
        IAssetController controller;
        bytes4 assetClass;
        IAssetVault vault;
    }

    /**
     * @dev Asset registry.
     * @param classRegistry Asset class registry contract.
     * @param assetIndex Set of registered asset addresses.
     * @param assets Mapping from asset address to the asset configuration.
     */
    struct Registry {
        IAssetClassRegistry classRegistry;
        EnumerableSetUpgradeable.AddressSet assetIndex;
        mapping(address => AssetConfig) assets;
    }

    /**
     * @dev Registers new asset.
     */
    function registerAsset(
        Registry storage self,
        bytes4 assetClass,
        address asset
    ) external {
        if (!self.assetIndex.add(asset)) revert AssetIsAlreadyRegistered(asset);

        IAssetClassRegistry.ClassConfig memory assetClassConfig = self.classRegistry.assetClassConfig(assetClass);
        self.assets[asset] = AssetConfig({
            controller: IAssetController(assetClassConfig.controller),
            assetClass: assetClass,
            vault: IAssetVault(assetClassConfig.vault)
        });
    }

    /**
     * @dev Returns the paginated list of currently registered listings and their corresponding asset configs.
     */
    function supportedAssets(
        Registry storage self,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory, AssetConfig[] memory) {
        uint256 indexSize = self.assetIndex.length();
        if (offset >= indexSize) return (new address[](0), new AssetConfig[](0));

        if (limit > indexSize - offset) {
            limit = indexSize - offset;
        }

        AssetConfig[] memory assetConfigs = new AssetConfig[](limit);
        address[] memory assetAddresses = new address[](limit);
        for (uint256 i = 0; i < limit; i++) {
            assetAddresses[i] = self.assetIndex.at(offset + i);
            assetConfigs[i] = self.assets[assetAddresses[i]];
        }
        return (assetAddresses, assetConfigs);
    }

    /**
     * @dev Transfers an asset to the vault using associated controller.
     */
    function transferAssetToVault(
        Registry storage self,
        Assets.Asset memory asset,
        address from
    ) external {
        // Extract token address from asset struct and check whether the asset is supported.
        address assetToken = asset.token();

        // Transfer asset to the class asset specific vault.
        address assetController = address(self.assets[assetToken].controller);
        address assetVault = address(self.assets[assetToken].vault);
        assetController.functionDelegateCall(
            abi.encodeWithSelector(IAssetController.transferAssetToVault.selector, asset, from, assetVault)
        );
    }

    /**
     * @dev Transfers an asset from the vault using associated controller.
     */
    function returnAssetFromVault(Registry storage self, Assets.Asset memory asset) external {
        address assetToken = asset.token();
        address assetController = address(self.assets[assetToken].controller);
        address assetVault = address(self.assets[assetToken].vault);

        assetController.functionDelegateCall(
            abi.encodeWithSelector(IAssetController.returnAssetFromVault.selector, asset, assetVault)
        );
    }

    function assetCount(Registry storage self) internal view returns (uint256) {
        return self.assetIndex.length();
    }

    /**
     * @dev Checks asset registration by address.
     */
    function isRegisteredAsset(Registry storage self, address asset) internal view returns (bool) {
        return self.assetIndex.contains(asset);
    }

    /**
     * @dev Returns controller for asset class.
     * @param assetClass Asset class ID.
     */
    function assetClassController(Registry storage self, bytes4 assetClass) internal view returns (address) {
        return self.classRegistry.assetClassConfig(assetClass).controller;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

library Protocol {
    /**
     * @dev Thrown when the provided token does not match with the configured base token.
     */
    error BaseTokenMismatch();

    /**
     * @dev Protocol configuration.
     * @param baseToken ERC20 contract. Used as the price denominator.
     * @param rentalFeePercent The fixed part of the total rental fee paid to protocol.
     */
    struct Config {
        IERC20Upgradeable baseToken;
        uint16 rentalFeePercent;
    }

    /**
     * @dev Reverts if the `token` does not match the base one.
     */
    function checkBaseToken(Config storage self, address token) internal view {
        if (token != address(self.baseToken)) revert BaseTokenMismatch();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";

import "./IWarperController.sol";
import "./IWarperPresetFactory.sol";
import "../asset/Assets.sol";
import "./IWarperManager.sol";

library Warpers {
    using AddressUpgradeable for address;
    using ERC165CheckerUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using Warpers for Registry;
    using Assets for Assets.Asset;
    using Assets for Assets.Registry;

    /**
     * @dev Thrown if provided warper address does not implement warper interface.
     */
    error InvalidWarperInterface();

    /**
     * @dev Thrown when the warper returned metahub address differs from the one it is being registered in.
     * @param provided Metahub address returned by warper.
     * @param required Required metahub address.
     */
    error WarperHasIncorrectMetahubReference(address provided, address required);

    /**
     * @dev Thrown when performing action or accessing data of an unknown warper.
     * @param warper Warper address.
     */
    error WarperIsNotRegistered(address warper);

    /**
     * @dev Thrown upon attempting to register a warper twice.
     * @param warper Duplicate warper address.
     */
    error WarperIsAlreadyRegistered(address warper);

    /**
     * @dev Thrown when the operation is not allowed due to the warper being paused.
     */
    error WarperIsPaused();

    /**
     * @dev Thrown when the operation is not allowed due to the warper not being paused.
     */
    error WarperIsNotPaused();

    /**
     * @dev Thrown when there are no registered warpers for a particular asset.
     * @param asset Asset address.
     */
    error UnsupportedAsset(address asset);

    /**
     * @dev Thrown upon attempting to use the warper which is not registered for the provided asset.
     */
    error IncompatibleAsset(address asset);

    /**
     * @dev Registered warper data.
     * @param assetClass The identifying asset class.
     * @param original Original asset contract address.
     * @param paused Indicates whether the warper is paused.
     * @param controller Warper controller.
     * @param name Warper name.
     * @param universeId Warper universe ID.
     */
    struct Warper {
        bytes4 assetClass;
        address original;
        bool paused;
        IWarperController controller;
        string name;
        uint256 universeId;
    }

    /**
     * @dev Reverts if the warper original does not match the `asset`;
     */
    function checkCompatibleAsset(Warper memory self, Assets.Asset memory asset) internal pure {
        address original = asset.token();
        if (self.original != original) revert IncompatibleAsset(original);
    }

    /**
     * @dev Puts the warper on pause.
     */
    function pause(Warper storage self) internal {
        if (self.paused) revert WarperIsPaused();

        self.paused = true;
    }

    /**
     * @dev Lifts the warper pause.
     */
    function unpause(Warper storage self) internal {
        if (!self.paused) revert WarperIsNotPaused();

        self.paused = false;
    }

    /**
     * @dev Reverts if the warper is paused.
     */
    function checkNotPaused(Warper memory self) internal pure {
        if (self.paused) revert WarperIsPaused();
    }

    /**
     * @dev Warper registry.
     * @param presetFactory Warper preset factory contract.
     * @param warperIndex Set of registered warper addresses.
     * @param universeWarperIndex Mapping from a universe ID to the set of warper addresses registered by the universe.
     * @param assetWarperIndex Mapping from an original asset address to the set of warper addresses,
     * registered for the asset.
     * @param warpers Mapping from a warper address to the warper details.
     */
    struct Registry {
        IWarperPresetFactory presetFactory;
        EnumerableSetUpgradeable.AddressSet warperIndex;
        mapping(uint256 => EnumerableSetUpgradeable.AddressSet) universeWarperIndex;
        mapping(address => EnumerableSetUpgradeable.AddressSet) assetWarperIndex;
        mapping(address => Warpers.Warper) warpers;
    }

    /**
     * @dev Performs warper registration.
     * @param warper Warper address.
     * @param params Warper registration params.
     */
    function registerWarper(
        Registry storage self,
        address warper,
        IWarperManager.WarperRegistrationParams calldata params,
        IAssetClassRegistry assetClassRegistry
    ) internal returns (bytes4 assetClass, address original) {
        // Check that provided warper address is a valid contract.
        if (!warper.isContract() || !warper.supportsInterface(type(IWarper).interfaceId)) {
            revert InvalidWarperInterface();
        }

        // Check that warper has correct metahub reference.
        address metahub = IWarper(warper).__metahub();
        if (metahub != IWarperManager(address(this)).metahub())
            revert WarperHasIncorrectMetahubReference(metahub, address(this));

        // Check that warper asset class is supported.
        assetClass = IWarper(warper).__assetClass();

        // Retrieve warper controller based on assetClass.
        // Controller resolution for unsupported asset class will revert.
        IWarperController controller = IWarperController(assetClassRegistry.assetClassConfig(assetClass).controller);

        // Ensure warper compatibility with the current generation of asset controller.
        controller.checkCompatibleWarper(warper);

        // Retrieve original asset address.
        original = IWarper(warper).__original();

        // Save warper record.
        _register(
            self,
            warper,
            Warpers.Warper({
                original: original,
                controller: controller,
                name: params.name,
                universeId: params.universeId,
                paused: params.paused,
                assetClass: assetClass
            })
        );
    }

    /**
     * @dev Performs warper registration.
     */
    function _register(
        Registry storage self,
        address warperAddress,
        Warper memory warper
    ) private {
        if (!self.warperIndex.add(warperAddress)) revert WarperIsAlreadyRegistered(warperAddress);

        // Create warper main registration record.
        self.warpers[warperAddress] = warper;
        // Associate the warper with the universe.
        self.universeWarperIndex[warper.universeId].add(warperAddress);
        // Associate the warper with the original asset.
        self.assetWarperIndex[warper.original].add(warperAddress);
    }

    /**
     * @dev Removes warper data from the registry.
     */
    function remove(Registry storage self, address warperAddress) internal {
        Warper storage warper = self.warpers[warperAddress];
        // Clean up universe index.
        self.universeWarperIndex[warper.universeId].remove(warperAddress);
        // Clean up asset index.
        self.assetWarperIndex[warper.original].remove(warperAddress);
        // Clean up main index.
        self.warperIndex.remove(warperAddress);
        // Delete warper data.
        delete self.warpers[warperAddress];
    }

    /**
     * @dev Returns the paginated list of warpers belonging to the particular universe.
     */
    function universeWarpers(
        Registry storage self,
        uint256 universeId,
        uint256 offset,
        uint256 limit
    ) internal view returns (address[] memory, Warpers.Warper[] memory) {
        return self.paginateIndexedWarpers(self.universeWarperIndex[universeId], offset, limit);
    }

    /**
     * @dev Returns the paginated list of warpers associated with the particular original asset.
     */
    function assetWarpers(
        Registry storage self,
        address original,
        uint256 offset,
        uint256 limit
    ) internal view returns (address[] memory, Warpers.Warper[] memory) {
        return self.paginateIndexedWarpers(self.assetWarperIndex[original], offset, limit);
    }

    /**
     * @dev Checks warper registration by address.
     */
    function isRegisteredWarper(Registry storage self, address warper) internal view returns (bool) {
        return self.warperIndex.contains(warper);
    }

    /**
     * @dev Reverts if warper is not registered.
     */
    function checkRegisteredWarper(Registry storage self, address warper) internal view {
        if (!self.isRegisteredWarper(warper)) revert WarperIsNotRegistered(warper);
    }

    /**
     * @dev Reverts if asset is not supported.
     * @param asset Asset address.
     */
    function checkSupportedAsset(Registry storage self, address asset) internal view {
        if (!self.isSupportedAsset(asset)) revert UnsupportedAsset(asset);
    }

    /**
     * @dev Checks asset support by address.
     * The supported asset should have at least one warper.
     * @param asset Asset address.
     */
    function isSupportedAsset(Registry storage self, address asset) internal view returns (bool) {
        return self.assetWarperIndex[asset].length() > 0;
    }

    /**
     * @dev Returns the number of warpers belonging to the particular universe.
     */
    function universeWarperCount(Registry storage self, uint256 universeId) internal view returns (uint256) {
        return self.universeWarperIndex[universeId].length();
    }

    /**
     * @dev Returns the number of warpers associated with the particular original asset.
     */
    function assetWarperCount(Registry storage self, address original) internal view returns (uint256) {
        return self.assetWarperIndex[original].length();
    }

    /**
     * @dev Returns the paginated list of registered warpers using provided index reference.
     */
    function paginateIndexedWarpers(
        Registry storage self,
        EnumerableSetUpgradeable.AddressSet storage warperIndex,
        uint256 offset,
        uint256 limit
    ) internal view returns (address[] memory, Warper[] memory) {
        uint256 indexSize = warperIndex.length();
        if (offset >= indexSize) return (new address[](0), new Warper[](0));

        if (limit > indexSize - offset) {
            limit = indexSize - offset;
        }

        Warper[] memory warpers = new Warper[](limit);
        address[] memory warperAddresses = new address[](limit);
        for (uint256 i = 0; i < limit; i++) {
            warperAddresses[i] = warperIndex.at(offset + i);
            warpers[i] = self.warpers[warperAddresses[i]];
        }

        return (warperAddresses, warpers);
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "./Assets.sol";

interface IAssetController is IERC165 {
    /**
     * @dev Thrown when the asset has invalid class for specific operation.
     * @param provided Provided class ID.
     * @param required Required class ID.
     */
    error AssetClassMismatch(bytes4 provided, bytes4 required);

    /**
     * @dev Emitted when asset is transferred.
     * @param asset Asset being transferred.
     * @param from Asset sender.
     * @param to Asset recipient.
     * @param data Auxiliary data.
     */
    event AssetTransfer(Assets.Asset asset, address indexed from, address indexed to, bytes data);

    /**
     * @dev Returns controller asset class.
     * @return Asset class ID.
     */
    function assetClass() external pure returns (bytes4);

    /**
     * @dev Transfers asset.
     * Emits a {AssetTransfer} event.
     * @param asset Asset being transferred.
     * @param from Asset sender.
     * @param to Asset recipient.
     * @param data Auxiliary data.
     */
    function transfer(
        Assets.Asset memory asset,
        address from,
        address to,
        bytes memory data
    ) external;

    /**
     * @dev Transfers asset from owner to the vault contract.
     * @param asset Asset being transferred.
     * @param assetOwner Original asset owner address.
     * @param vault Asset vault contract address.
     */
    function transferAssetToVault(
        Assets.Asset memory asset,
        address assetOwner,
        address vault
    ) external;

    /**
     * @dev Transfers asset from the vault contract to the original owner.
     * @param asset Asset being transferred.
     * @param vault Asset vault contract address.
     */
    function returnAssetFromVault(Assets.Asset memory asset, address vault) external;

    /**
     * @dev Decodes asset ID structure and returns collection identifier.
     * The collection ID is byte32 value which is calculated based on the asset class.
     * For example, ERC721 collection can be identified by address only,
     * but for ERC1155 it should be calculated based on address and token ID.
     * @return Collection ID.
     */
    function collectionId(Assets.AssetId memory assetId) external pure returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAssetVault is IERC165 {
    /**
     * @dev Thrown when the asset is not is found among vault inventory.
     */
    error AssetNotFound();

    /**
     * @dev Thrown when the function is called on the vault in recovery mode.
     */
    error VaultIsInRecoveryMode();

    /**
     * @dev Thrown when the asset return is not allowed, due to the vault state or the caller permissions.
     */
    error AssetReturnIsNotAllowed();

    /**
     * @dev Thrown when the asset deposit is not allowed, due to the vault state or the caller permissions.
     */
    error AssetDepositIsNotAllowed();

    /**
     * @dev Emitted when the vault is switched to recovery mode by `account`.
     */
    event RecoveryModeActivated(address account);

    /**
     * @dev Activates asset recovery mode.
     * Emits a {RecoveryModeActivated} event.
     */
    function switchToRecoveryMode() external;

    /**
     * @notice Send ERC20 tokens to an address.
     */
    function withdrawERC20Tokens(
        IERC20 token,
        address to,
        uint256 amount
    ) external;

    /**
     * @dev Pauses the vault.
     */
    function pause() external;

    /**
     * @dev Unpauses the vault.
     */
    function unpause() external;

    /**
     * @dev Returns vault asset class.
     * @return Asset class ID.
     */
    function assetClass() external pure returns (bytes4);

    /**
     * @dev Returns the Metahub address.
     */
    function metahub() external view returns (address);

    /**
     * @dev Returns vault recovery mode flag state.
     * @return True when the vault is in recovery mode.
     */
    function isRecovery() external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IAssetController.sol";
import "./IAssetVault.sol";

interface IAssetClassRegistry {
    /**
     * @dev Thrown when the asset class supported by contract does not match the required one.
     * @param provided Provided class ID.
     * @param required Required class ID.
     */
    error AssetClassMismatch(bytes4 provided, bytes4 required);

    /**
     * @dev Thrown upon attempting to register an asset class twice.
     * @param assetClass Duplicate asset class ID.
     */
    error AssetClassIsAlreadyRegistered(bytes4 assetClass);

    /**
     * @dev Thrown upon attempting to work with unregistered asset class.
     * @param assetClass Asset class ID.
     */
    error UnregisteredAssetClass(bytes4 assetClass);

    /**
     * @dev Thrown when the asset controller contract does not implement the required interface.
     */
    error InvalidAssetControllerInterface();

    /**
     * @dev Thrown when the vault contract does not implement the required interface.
     */
    error InvalidAssetVaultInterface();

    /**
     * @dev Emitted when the new asset class is registered.
     * @param assetClass Asset class ID.
     * @param controller Controller address.
     * @param vault Vault address.
     */
    event AssetClassRegistered(bytes4 indexed assetClass, address indexed controller, address indexed vault);

    /**
     * @dev Emitted when the asset class controller is changed.
     * @param assetClass Asset class ID.
     * @param newController New controller address.
     */
    event AssetClassControllerChanged(bytes4 indexed assetClass, address indexed newController);

    /**
     * @dev Emitted when the asset class vault is changed.
     * @param assetClass Asset class ID.
     * @param newVault New vault address.
     */
    event AssetClassVaultChanged(bytes4 indexed assetClass, address indexed newVault);

    /**
     * @dev Asset class configuration.
     * @param vault Asset class vault.
     * @param controller Asset class controller.
     */
    struct ClassConfig {
        address vault;
        address controller;
    }

    /**
     * @dev Registers new asset class.
     * @param assetClass Asset class ID.
     * @param config Asset class initial configuration.
     */
    function registerAssetClass(bytes4 assetClass, ClassConfig calldata config) external;

    /**
     * @dev Sets asset class vault.
     * @param assetClass Asset class ID.
     * @param vault Asset class vault address.
     */
    function setAssetClassVault(bytes4 assetClass, address vault) external;

    /**
     * @dev Sets asset class controller.
     * @param assetClass Asset class ID.
     * @param controller Asset class controller address.
     */
    function setAssetClassController(bytes4 assetClass, address controller) external;

    /**
     * @dev Returns asset class configuration.
     * @param assetClass Asset class ID.
     * @return Asset class configuration.
     */
    function assetClassConfig(bytes4 assetClass) external view returns (ClassConfig memory);

    /**
     * @dev Checks asset class registration.
     * @param assetClass Asset class ID.
     */
    function isRegisteredAssetClass(bytes4 assetClass) external view returns (bool);

    /**
     * @dev Reverts if asset class is not registered.
     * @param assetClass Asset class ID.
     */
    function checkRegisteredAssetClass(bytes4 assetClass) external view;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC165.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "./Listings.sol";
import "../renting/Rentings.sol";

interface IListingController is IERC165 {
    /**
     * @dev Thrown when the listing strategy ID does not match the required one.
     * @param provided Provided listing strategy ID.
     * @param required Required listing strategy ID.
     */
    error ListingStrategyMismatch(bytes4 provided, bytes4 required);

    /**
     * @dev Returns implemented strategy ID.
     * @return Listing strategy ID.
     */
    function strategyId() external pure returns (bytes4);

    /**
     * @dev Calculates rental fee based on renting params and implemented listing strategy.
     * @param listingParams Listing strategy params.
     * @param rentingParams Renting params.
     * @return Asset rental fee (base tokens per second).
     */
    function calculateRentalFee(Listings.Params calldata listingParams, Rentings.Params calldata rentingParams)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Listings.sol";
import "./IListingController.sol";

interface IListingStrategyRegistry {
    /**
     * @dev Thrown when listing controller does not implement the required interface.
     */
    error InvalidListingControllerInterface();

    /**
     * @dev Thrown when the listing cannot be processed by the specific controller due to the listing strategy ID
     * mismatch.
     * @param provided Provided listing strategy ID.
     * @param required Required listing strategy ID.
     */
    error ListingStrategyMismatch(bytes4 provided, bytes4 required);

    /**
     * @dev Thrown upon attempting to register a listing strategy twice.
     * @param strategyId Duplicate listing strategy ID.
     */
    error ListingStrategyIsAlreadyRegistered(bytes4 strategyId);

    /**
     * @dev Thrown upon attempting to work with unregistered listing strategy.
     * @param strategyId Listing strategy ID.
     */
    error UnregisteredListingStrategy(bytes4 strategyId);

    /**
     * @dev Emitted when the new listing strategy is registered.
     * @param strategyId Listing strategy ID.
     * @param controller Controller address.
     */
    event ListingStrategyRegistered(bytes4 indexed strategyId, address indexed controller);

    /**
     * @dev Emitted when the listing strategy controller is changed.
     * @param strategyId Listing strategy ID.
     * @param newController Controller address.
     */
    event ListingStrategyControllerChanged(bytes4 indexed strategyId, address indexed newController);

    /**
     * @dev Listing strategy information.
     * @param controller Listing controller address.
     */
    struct StrategyConfig {
        address controller;
    }

    /**
     * @dev Registers new listing strategy.
     * @param strategyId Listing strategy ID.
     * @param config Listing strategy configuration.
     */
    function registerListingStrategy(bytes4 strategyId, StrategyConfig calldata config) external;

    /**
     * @dev Sets listing strategy controller.
     * @param strategyId Listing strategy ID.
     * @param controller Listing controller address.
     */
    function setListingController(bytes4 strategyId, address controller) external;

    /**
     * @dev Returns listing strategy configuration.
     * @param strategyId Listing strategy ID.
     * @return Listing strategy information.
     */
    function listingStrategy(bytes4 strategyId) external view returns (StrategyConfig memory);

    /**
     * @dev Returns listing strategy controller.
     * @param strategyId Listing strategy ID.
     * @return Listing controller address.
     */
    function listingController(bytes4 strategyId) external view returns (address);

    /**
     * @dev Checks listing strategy registration.
     * @param strategyId Listing strategy ID.
     */
    function isRegisteredListingStrategy(bytes4 strategyId) external view returns (bool);

    /**
     * @dev Reverts if listing strategy is not registered.
     * @param strategyId Listing strategy ID.
     */
    function checkRegisteredListingStrategy(bytes4 strategyId) external view;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165CheckerUpgradeable {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165Upgradeable).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165Upgradeable.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../accounting/Accounts.sol";
import "../asset/Assets.sol";
import "../renting/Rentings.sol";
import "../asset/IAssetController.sol";
import "./IWarper.sol";

interface IWarperController is IAssetController {
    /**
     * @dev Thrown if warper interface is not compatible with the controller.
     */
    error IncompatibleWarperInterface();

    /**
     * @dev Thrown upon attempting to use the warper with an asset different from the one expected by the warper.
     */
    error InvalidAssetForWarper(address warper, address asset);

    /**
     * @dev Thrown upon attempting to rent a warped asset which is already rented.
     */
    error AlreadyRented();

    /**
     * @dev Takes an existing asset and then mints a warper token representing it.
     *      Used in Metahub->Warper communication.
     * @param asset The asset that must be warped.
     * @param warper Warper contract to used for warping.
     * @param to The account which will receive the warped asset.
     * @return warpedCollectionId Warped collection ID.
     * @return warpedAsset Warper asset structure.
     */
    function warp(
        Assets.Asset calldata asset,
        address warper,
        address to
    ) external returns (bytes32 warpedCollectionId, Assets.Asset memory warpedAsset);

    /**
     * @dev Executes warper rental hook.
     * @param rentalId Rental agreement ID.
     * @param rentalAgreement Newly registered rental agreement details.
     * @param rentalEarnings The rental earnings breakdown.
     */
    function executeRentingHooks(
        uint256 rentalId,
        Rentings.Agreement calldata rentalAgreement,
        Accounts.RentalEarnings calldata rentalEarnings
    ) external;

    /**
     * @dev Validates that the warper interface is supported by the current WarperController.
     * @param warper Warper whose interface we must validate.
     * @return bool - `true` if warper is supported.
     */
    function isCompatibleWarper(address warper) external view returns (bool);

    /**
     * @dev Reverts if provided warper is not compatible with the controller.
     */
    function checkCompatibleWarper(address warper) external view;

    /**
     * @dev Validates renting params taking into account various warper mechanics.
     * Throws an error if the specified asset cannot be rented with particular renting parameters.
     * @param asset Asset being rented.
     * @param rentingParams Renting parameters.
     */
    function validateRentingParams(Assets.Asset calldata asset, Rentings.Params calldata rentingParams) external view;

    /**
     * @dev Calculates the universe and/or lister premiums.
     * Those are extra amounts that should be added the the resulting rental fee paid by renter.
     * @param asset Asset being rented.
     * @param rentingParams Renting parameters.
     * @param universeFee The current value of the universe fee component.
     * @param listerFee The current value of the lister fee component.
     * @return universePremium The universe premium amount.
     * @return listerPremium The lister premium amount.
     */
    function calculatePremiums(
        Assets.Asset calldata asset,
        Rentings.Params calldata rentingParams,
        uint256 universeFee,
        uint256 listerFee
    ) external view returns (uint256 universePremium, uint256 listerPremium);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IWarperPresetFactory {
    /**
     * @dev Thrown when the implementation does not support the IWarperPreset interface
     */
    error InvalidWarperPresetInterface();

    /**
     * @dev Thrown when the warper preset id is already present in the storage.
     */
    error DuplicateWarperPresetId(bytes32 presetId);

    /**
     * @dev Thrown when the warper preset has been disabled, when it was expected for it to be enabled.
     */
    error DisabledWarperPreset(bytes32 presetId);

    /**
     * @dev Thrown when the warper preset has been enabled, when it was expected for it to be disabled.
     */
    error EnabledWarperPreset(bytes32 presetId);

    /**
     * @dev Thrown when it was expected for the warper preset to be registeredr.
     */
    error WarperPresetNotRegistered(bytes32 presetId);

    /**
     * @dev Thrown when the provided preset initialization data is empty.
     */
    error EmptyPresetData();

    struct WarperPreset {
        bytes32 id;
        address implementation;
        bool enabled;
    }

    /**
     * @dev Emitted when new warper preset is added.
     */
    event WarperPresetAdded(bytes32 indexed presetId, address indexed implementation);

    /**
     * @dev Emitted when a warper preset is disabled.
     */
    event WarperPresetDisabled(bytes32 indexed presetId);

    /**
     * @dev Emitted when a warper preset is enabled.
     */
    event WarperPresetEnabled(bytes32 indexed presetId);

    /**
     * @dev Emitted when a warper preset is enabled.
     */
    event WarperPresetRemoved(bytes32 indexed presetId);

    /**
     * @dev Emitted when a warper preset is deployed.
     */
    event WarperPresetDeployed(bytes32 indexed presetId, address indexed warper);

    /**
     * @dev Stores the association between `presetId` and `implementation` address.
     * NOTE: Warper `implementation` must be deployed beforehand.
     * @param presetId Warper preset id.
     * @param implementation Warper implementation address.
     */
    function addPreset(bytes32 presetId, address implementation) external;

    /**
     * @dev Removes the association between `presetId` and its implementation.
     * @param presetId Warper preset id.
     */
    function removePreset(bytes32 presetId) external;

    /**
     * @dev Enables warper preset, which makes it deployable.
     * @param presetId Warper preset id.
     */
    function enablePreset(bytes32 presetId) external;

    /**
     * @dev Disable warper preset, which makes non-deployable.
     * @param presetId Warper preset id.
     */
    function disablePreset(bytes32 presetId) external;

    /**
     * @dev Deploys a new warper from the preset identified by `presetId`.
     * @param presetId Warper preset id.
     * @param initData Warper initialization payload.
     * @return Deployed warper address.
     */
    function deployPreset(bytes32 presetId, bytes calldata initData) external returns (address);

    /**
     * @dev Checks whether warper preset is enabled and available for deployment.
     * @param presetId Warper preset id.
     */
    function presetEnabled(bytes32 presetId) external view returns (bool);

    /**
     * @dev Returns the list of all registered warper presets.
     */
    function presets() external view returns (WarperPreset[] memory);

    /**
     * @dev Returns the warper preset details.
     * @param presetId Warper preset id.
     */
    function preset(bytes32 presetId) external view returns (WarperPreset memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../asset/IAssetController.sol";
import "./Warpers.sol";

interface IWarperManager {
    /**
     * @dev Warper registration params.
     * @param name The warper name.
     * @param universeId The universe ID.
     * @param paused Indicates whether the warper should stay paused after registration.
     */
    struct WarperRegistrationParams {
        string name;
        uint256 universeId;
        bool paused;
    }

    /**
     * @dev Emitted when a new warper is registered.
     * @param universeId Universe ID.
     * @param warper Warper address.
     * @param original Original asset address.
     * @param assetClass Asset class ID (identical for the `original` and `warper`).
     */
    event WarperRegistered(
        uint256 indexed universeId,
        address indexed warper,
        address indexed original,
        bytes4 assetClass
    );

    /**
     * @dev Emitted when the warper is no longer registered.
     * @param warper Warper address.
     */
    event WarperDeregistered(address indexed warper);

    /**
     * @dev Emitted when the warper is paused.
     * @param warper Address.
     */
    event WarperPaused(address indexed warper);

    /**
     * @dev Emitted when the warper pause is lifted.
     * @param warper Address.
     */
    event WarperUnpaused(address indexed warper);

    /**
     * @dev Registers a new warper.
     * The warper must be deployed and configured prior to registration,
     * since it becomes available for renting immediately.
     * @param warper Warper address.
     * @param params Warper registration params.
     */
    function registerWarper(address warper, WarperRegistrationParams calldata params) external;

    /**
     * @dev Deletes warper registration information.
     * All current rental agreements with the warper will stay intact, but the new rentals won't be possible.
     * @param warper Warper address.
     */
    function deregisterWarper(address warper) external;

    /**
     * @dev Puts the warper on pause.
     * Emits a {WarperPaused} event.
     * @param warper Address.
     */
    function pauseWarper(address warper) external;

    /**
     * @dev Lifts the warper pause.
     * Emits a {WarperUnpaused} event.
     * @param warper Address.
     */
    function unpauseWarper(address warper) external;

    /**
     * @dev Sets the new controller address for one or multiple registered warpers.
     * @param warpers A list of registered warper addresses which controller will be changed.
     * @param controller Warper controller address.
     */
    function setWarperController(address[] calldata warpers, address controller) external;

    /**
     * @dev Reverts if asset is not supported.
     * @param asset Asset address.
     */
    function checkSupportedAsset(address asset) external view;

    /**
     * @dev Reverts if warper is not registered.
     */
    function checkRegisteredWarper(address warper) external view;

    /**
     * @dev Returns the number of warpers belonging to the particular universe.
     * @param universeId The universe ID.
     * @return Warper count.
     */
    function universeWarperCount(uint256 universeId) external view returns (uint256);

    /**
     * @dev Returns the list of warpers belonging to the particular universe.
     * @param universeId The universe ID.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return List of warper addresses.
     * @return List of warpers.
     */
    function universeWarpers(
        uint256 universeId,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory, Warpers.Warper[] memory);

    /**
     * @dev Returns the number of warpers associated with the particular original asset.
     * @param original Original asset address.
     * @return Warper count.
     */
    function assetWarperCount(address original) external view returns (uint256);

    /**
     * @dev Returns the list of warpers associated with the particular original asset.
     * @param original Original asset address.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return List of warper addresses.
     * @return List of warpers.
     */
    function assetWarpers(
        address original,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory, Warpers.Warper[] memory);

    /**
     * @dev Returns warper preset factory address.
     */
    function warperPresetFactory() external view returns (address);

    /**
     * @dev Returns the Metahub address.
     */
    function metahub() external view returns (address);

    /**
     * @dev Checks whether `account` is the `warper` admin.
     * @param warper Warper address.
     * @param account Account address.
     * @return True if the `account` is the admin of the `warper` and false otherwise.
     */
    function isWarperAdmin(address warper, address account) external view returns (bool);

    /**
     * @dev Returns registered warper details.
     * @param warper Warper address.
     * @return Warper details.
     */
    function warperInfo(address warper) external view returns (Warpers.Warper memory);

    /**
     * @dev Returns warper controller address.
     * @param warper Warper address.
     * @return Current controller.
     */
    function warperController(address warper) external view returns (address);
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
interface IERC165Upgradeable {
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
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

interface IWarper is IERC165 {
    /**
     * @dev Returns the original asset address.
     */
    function __original() external view returns (address);

    /**
     * @dev Returns the Metahub address.
     */
    function __metahub() external view returns (address);

    /**
     * @dev Returns the warper asset class ID.
     */
    function __assetClass() external view returns (bytes4);

    /**
     * @dev Validates if a warper supports multiple interfaces at once.
     * @return an array of `bool` flags in order as the `interfaceIds` were passed.
     */
    function __supportedInterfaces(bytes4[] memory interfaceIds) external view returns (bool[] memory);
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

import "../../../renting/Rentings.sol";
import "../../../accounting/Accounts.sol";

interface IRentingHookMechanics {
    /**
     * @dev Thrown when the renting hook execution failed due to the `reason`.
     */
    error RentingHookError(string reason);

    /**
     * @dev Executes arbitrary logic after successful renting.
     * NOTE: This function should not revert directly and must set correct `success` value instead.
     *
     * @param rentalId Rental agreement ID.
     * @param tokenId The token ID.
     * @param amount The token amount.
     * @param rentalAgreement Newly registered rental agreement details.
     * @param rentalEarnings The rental earnings breakdown.
     * @return success True if hook was executed successfully.
     * @return errorMessage The reason of the hook execution failure.
     */
    function __onRent(
        uint256 rentalId,
        uint256 tokenId,
        uint256 amount,
        Rentings.Agreement calldata rentalAgreement,
        Accounts.RentalEarnings calldata rentalEarnings
    ) external returns (bool success, string memory errorMessage);
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

import "../warper/ERC721/ERC721Warper.sol";
import "../warper/mechanics/renting-hook/IRentingHookMechanics.sol";

contract WarperWithRenting is IRentingHookMechanics, ERC721Warper {
    uint256 public rentalId;
    uint256 public tokenId;
    uint256 public amount;
    Rentings.Agreement public rentalAgreement;
    Accounts.RentalEarnings public rentalEarnings;

    bool public successState = true;

    function __initialize(address original, address metahub) external virtual warperInitializer {
        _Warper_init(original, metahub);
    }

    function setSuccessState(bool successState_) external {
        successState = successState_;
    }

    function __onRent(
        uint256 rentalId_,
        uint256 tokenId_,
        uint256 amount_,
        Rentings.Agreement calldata rentalAgreement_,
        Accounts.RentalEarnings calldata rentalEarnings_
    ) external override returns (bool success, string memory errorMessage) {
        rentalId = rentalId_;
        tokenId = tokenId_;
        amount = amount_;
        rentalAgreement = rentalAgreement_;
        rentalEarnings = rentalEarnings_;

        success = successState;
        errorMessage = "There was an error!";
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IRentingHookMechanics).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// solhint-disable ordering
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";
import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "../../metahub/IMetahub.sol";
import "../../renting/Rentings.sol";
import "../Warper.sol";
import "./IERC721Warper.sol";
import "./IERC721WarperController.sol";

/**
 * @title Warper for the ERC721 token contract
 */
abstract contract ERC721Warper is IERC721Warper, Warper {
    using ERC165Checker for address;
    using Address for address;

    /**
     * @dev Mapping from token ID to owner address
     */
    mapping(uint256 => address) private _owners;

    /**
     * @inheritdoc IWarper
     */
    // solhint-disable-next-line private-vars-leading-underscore
    function __assetClass() external pure returns (bytes4) {
        return Assets.ERC721;
    }

    /**
     * @inheritdoc IERC721
     * @dev Method is disabled, kept only for interface compatibility purposes.
     */
    function setApprovalForAll(address, bool) external virtual {
        revert MethodNotAllowed();
    }

    /**
     * @inheritdoc IERC721
     * @dev Method is disabled, kept only for interface compatibility purposes.
     */
    function approve(address, uint256) external virtual {
        revert MethodNotAllowed();
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - needs to pass validation of `_beforeTokenTransfer()`.
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function mint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) external {
        if (to == address(0)) revert MintToTheZeroAddress();
        if (_exists(tokenId)) revert TokenIsAlreadyMinted(tokenId);

        _beforeTokenTransfer(address(0), to, tokenId);

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        if (!_checkOnERC721Received(address(0), to, tokenId, data)) {
            revert TransferToNonERC721ReceiverImplementer(to);
        }
    }

    /**
     * @inheritdoc IERC721
     *
     * @dev Need to fulfill all the requirements of `_transfer()`
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {
        _transfer(from, to, tokenId);
    }

    /**
     * @inheritdoc IERC721
     *
     * @dev Need to fulfill all the requirements of `_transfer()`
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @inheritdoc IERC721
     *
     * @dev Need to fulfill all the requirements of `_transfer()`
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public {
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(Warper, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721Warper).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IERC721
     * @dev The rental count calculations get offloaded to the Metahub
     */
    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        IERC721WarperController warperController = _warperController();
        return warperController.rentalBalance(_metahub(), address(this), owner);
    }

    /**
     * @inheritdoc IERC721
     * @dev The ownership is dependant on the rental status - metahub is
     *      responsible for tracking the state:
     *          - NONE: revert with an error
     *          - AVAILABLE: means, that the token is not currently rented. Metahub is the owner.
     *          - RENTED: Use the Warpers internal ownership constructs
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        // Special rent-sate handling
        {
            Rentings.RentalStatus rentalStatus = _getWarperRentalStatus(tokenId);

            if (rentalStatus == Rentings.RentalStatus.NONE) revert OwnerQueryForNonexistentToken(tokenId);
            if (rentalStatus == Rentings.RentalStatus.AVAILABLE) return _metahub();
        }

        // `rentalStatus` is now RENTED
        // Fallback to using the internal owner tracker
        address owner = _owners[tokenId];
        if (owner == address(0)) revert OwnerQueryForNonexistentToken(tokenId);

        return owner;
    }

    /**
     * @inheritdoc IERC721
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        Rentings.RentalStatus rentalStatus = _getWarperRentalStatus(tokenId);
        if (rentalStatus == Rentings.RentalStatus.NONE) revert OwnerQueryForNonexistentToken(tokenId);

        return _metahub();
    }

    /**
     * @inheritdoc IERC721
     */
    function isApprovedForAll(address, address operator) public view returns (bool) {
        return operator == _metahub();
    }

    /**
     * @dev Validates the original NFT.
     */
    function _validateOriginal(address original) internal virtual override {
        if (!original.supportsInterface(type(IERC721Metadata).interfaceId)) {
            revert InvalidOriginalTokenInterface(original, type(IERC721Metadata).interfaceId);
        }
        super._validateOriginal(original);
    }

    /**
     * @dev ONLY THE METAHUB CAN CALL THIS METHOD.
     *      This validates every single transfer that the warper can perform.
     *      Metahub can be the only source of transfers, so it can properly synchronise
     *      the rental agreement ownership.
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
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal onlyMetahub {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - Needs to fulfill all the requirements of `_transfer()`
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        _transfer(from, to, tokenId);
        if (!_checkOnERC721Received(from, to, tokenId, data)) {
            revert TransferToNonERC721ReceiverImplementer(to);
        }
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - needs to pass validation of `_beforeTokenTransfer()`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        if (!_exists(tokenId)) revert OperatorQueryForNonexistentToken(tokenId);
        if (to == address(0)) revert TransferToTheZeroAddress();

        _beforeTokenTransfer(from, to, tokenId);

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Get the associated warper controller.
     */
    function _warperController() internal view returns (IERC721WarperController) {
        return IERC721WarperController(IMetahub(_metahub()).warperController(address(this)));
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (!to.isContract()) return true;

        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 result) {
            return result == IERC721Receiver.onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer(to);
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    /**
     * @dev Get the rental status of a token.
     */
    function _getWarperRentalStatus(uint256 tokenId) private view returns (Rentings.RentalStatus) {
        IERC721WarperController warperController = _warperController();
        return warperController.rentalStatus(_metahub(), address(this), tokenId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/extensions/IERC721Metadata.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Receiver.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721Receiver.sol";

// SPDX-License-Identifier: MIT
// solhint-disable no-empty-blocks
pragma solidity ^0.8.13;

import "../accounting/IPaymentManager.sol";
import "../listing/IListingManager.sol";
import "../renting/IRentingManager.sol";
import "../asset/IAssetManager.sol";
import "./IProtocolConfigManager.sol";

interface IMetahub is IProtocolConfigManager, IPaymentManager, IListingManager, IRentingManager, IAssetManager {}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore, func-name-mixedcase
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "./IWarper.sol";
import "./utils/CallForwarder.sol";
import "./utils/WarperContext.sol";

abstract contract Warper is IWarper, WarperContext, CallForwarder, Multicall {
    using ERC165Checker for address;

    /**
     * @dev Thrown when the original asset contract does not implement the interface, expected by Warper.
     */
    error InvalidOriginalTokenInterface(address original, bytes4 requiredInterfaceId);

    /**
     * @dev Forwards the current call to the original asset contract. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Forwards the current call to the original asset contract`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Warper initializer.
     *
     */
    function _Warper_init(address original, address metahub) internal onlyInitializingWarper {
        _validateOriginal(original);
        _setOriginal(original);
        _setMetahub(metahub);
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return
            interfaceId == type(IWarper).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            _original().supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IWarper
     */
    function __supportedInterfaces(bytes4[] memory interfaceIds) external view returns (bool[] memory) {
        return address(this).getSupportedInterfaces(interfaceIds);
    }

    /**
     * @dev Returns the original NFT address.
     */
    function __original() external view returns (address) {
        return _original();
    }

    /**
     * @inheritdoc IWarper
     */
    function __metahub() external view returns (address) {
        return _metahub();
    }

    /**
     * @dev Forwards the current call to the original asset contract`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _forward(_original());
    }

    /**
     * @dev Hook that is called before falling back to the original. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Validates the original NFT.
     *
     * If overridden should call `super._validateOriginal()`.
     */
    function _validateOriginal(address original) internal virtual {
        // solhint-disable-previous-line no-empty-blocks
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "../IWarper.sol";

interface IERC721Warper is IWarper, IERC721 {
    /**
     * @dev Thrown when querying token balance for address(0)
     */
    error BalanceQueryForZeroAddress();

    /**
     * @dev Thrown when querying for the owner of a token that has not been minted yet.
     */
    error OwnerQueryForNonexistentToken(uint256 tokenId);

    /**
     * @dev Thrown when querying for the operator of a token that has not been minted yet.
     */
    error OperatorQueryForNonexistentToken(uint256 tokenId);

    /**
     * @dev Thrown when attempting to safeTransfer to a contract that cannot handle ERC721 tokens.
     */
    error TransferToNonERC721ReceiverImplementer(address to);

    /**
     * @dev Thrown when minting to the address(0).
     */
    error MintToTheZeroAddress();

    /**
     * @dev Thrown when minting a token that already exists.
     */
    error TokenIsAlreadyMinted(uint256 tokenId);

    /**
     * @dev Thrown transferring a token to the address(0).
     */
    error TransferToTheZeroAddress();

    /**
     * @dev Thrown when calling a method that has been purposely disabled.
     */
    error MethodNotAllowed();

    /**
     * @dev Mint new tokens.
     * @param to The address to mint the token to.
     * @param tokenId The ID of the token to mint.
     * @param data The data to send over to the receiver if it supports `onERC721Received` hook.
     */
    function mint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../IWarperController.sol";
import "../../asset/Assets.sol";

interface IERC721WarperController is IWarperController {
    /**
     * @dev Get the active rental balance for a given warper and a renter.
     *      Used in Warper->Metahub communication.
     * @param metahub Address of the metahub.
     * @param warper Address of the warper.
     * @param renter Address of the renter whose active rental counts we need to fetch.
     */
    function rentalBalance(
        address metahub,
        address warper,
        address renter
    ) external view returns (uint256);

    /**
     * @dev Get the rental status of a specific token.
     *      Used in Warper->Metahub communication.
     * @param metahub Address of the metahub.
     * @param warper Address of the warper.
     * @param tokenId The token ID to be checked for status.
     */
    function rentalStatus(
        address metahub,
        address warper,
        uint256 tokenId
    ) external view returns (Rentings.RentalStatus);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../asset/Assets.sol";
import "../asset/IAssetController.sol";
import "../listing/IListingController.sol";
import "./Listings.sol";

interface IListingManager {
    /**
     * @dev Thrown when the message sender doesn't match the asset lister address.
     */
    error CallerIsNotAssetLister();

    /**
     * @dev Thrown when the original asset cannot be withdrawn because of active rentals
     * or other activity that requires asset to stay in the vault.
     */
    error AssetIsLocked();

    /**
     * @dev Emitted when a new asset is listed for renting.
     * @param listingId Listing ID.
     * @param listingGroupId Listing group ID.
     * @param lister Lister account address.
     * @param asset Listing asset.
     * @param params Listing strategy parameters.
     * @param maxLockPeriod The maximum amount of time the original asset owner can wait before getting the asset back.
     */
    event AssetListed(
        uint256 indexed listingId,
        uint256 indexed listingGroupId,
        address indexed lister,
        Assets.Asset asset,
        Listings.Params params,
        uint32 maxLockPeriod
    );

    /**
     * @dev Emitted when the asset is no longer available for renting.
     * @param listingId Listing ID.
     * @param lister Lister account address.
     * @param unlocksAt The earliest possible time when the asset can be returned to the owner.
     */
    event AssetDelisted(uint256 indexed listingId, address indexed lister, uint32 unlocksAt);

    /**
     * @dev Emitted when the asset is returned to the `lister`.
     * @param listingId Listing ID.
     * @param lister Lister account address.
     * @param asset Returned asset.
     */
    event AssetWithdrawn(uint256 indexed listingId, address indexed lister, Assets.Asset asset);

    /**
     * @dev Emitted when the listing is paused.
     * @param listingId Listing ID.
     */
    event ListingPaused(uint256 indexed listingId);

    /**
     * @dev Emitted when the listing pause is lifted.
     * @param listingId Listing ID.
     */
    event ListingUnpaused(uint256 indexed listingId);

    /**
     * @dev Performs new asset listing.
     * Emits an {AssetListed} event.
     * @param asset Asset to be listed.
     * @param params Listing strategy parameters.
     * @param maxLockPeriod The maximum amount of time the original asset owner can wait before getting the asset back.
     * @param immediatePayout Indicates whether the rental fee must be transferred to the lister on every renting.
     * If FALSE, the rental fees get accumulated until withdrawn manually.
     * @return listingId New listing ID.
     * @return listingGroupId Listing group ID.
     */
    function listAsset(
        Assets.Asset calldata asset,
        Listings.Params calldata params,
        uint32 maxLockPeriod,
        bool immediatePayout
    ) external returns (uint256 listingId, uint256 listingGroupId);

    /**
     * @dev Marks the asset as being delisted. This operation in irreversible.
     * After delisting, the asset can only be withdrawn when it has no active rentals.
     * Emits an {AssetDelisted} event.
     * @param listingId Listing ID.
     */
    function delistAsset(uint256 listingId) external;

    /**
     * @dev Returns the asset back to the lister.
     * Emits an {AssetWithdrawn} event.
     * @param listingId Listing ID.
     */
    function withdrawAsset(uint256 listingId) external;

    /**
     * @dev Puts the listing on pause.
     * Emits a {ListingPaused} event.
     * @param listingId Listing ID.
     */
    function pauseListing(uint256 listingId) external;

    /**
     * @dev Lifts the listing pause.
     * Emits a {ListingUnpaused} event.
     * @param listingId Listing ID.
     */
    function unpauseListing(uint256 listingId) external;

    /**
     * @dev Returns the listing details by the listing ID.
     * @param listingId Listing ID.
     * @return Listing details.
     */
    function listingInfo(uint256 listingId) external view returns (Listings.Listing memory);

    /**
     * @dev Returns the number of currently registered listings.
     * @return Listing count.
     */
    function listingCount() external view returns (uint256);

    /**
     * @dev Returns the paginated list of currently registered listings.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return Listing IDs.
     * @return Listings.
     */
    function listings(uint256 offset, uint256 limit)
        external
        view
        returns (uint256[] memory, Listings.Listing[] memory);

    /**
     * @dev Returns the number of currently registered listings for the particular lister account.
     * @param lister Lister address.
     * @return Listing count.
     */
    function userListingCount(address lister) external view returns (uint256);

    /**
     * @dev Returns the paginated list of currently registered listings for the particular lister account.
     * @param lister Lister address.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return Listing IDs.
     * @return Listings.
     */
    function userListings(
        address lister,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listings.Listing[] memory);

    /**
     * @dev Returns the number of currently registered listings for the particular original asset address.
     * @param original Original asset address.
     * @return Listing count.
     */
    function assetListingCount(address original) external view returns (uint256);

    /**
     * @dev Returns the paginated list of currently registered listings for the particular original asset address.
     * @param original Original asset address.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return Listing IDs.
     * @return Listings.
     */
    function assetListings(
        address original,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listings.Listing[] memory);

    /**
     * @dev Returns listing strategy controller.
     * @param strategyId Listing strategy ID.
     * @return Listing controller address.
     */
    function listingController(bytes4 strategyId) external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Rentings.sol";

interface IRentingManager {
    /**
     * @dev Thrown when the message sender doesn't match the renter address.
     */
    error CallerIsNotRenter();

    /**
     * @dev Emitted when the warped asset is rented.
     * @param rentalId Rental agreement ID.
     * @param renter The renter account address.
     * @param listingId The corresponding ID of the original asset listing.
     * @param warpedAsset Rented warped asset.
     * @param startTime The rental agreement staring time.
     * @param endTime The rental agreement ending time.
     */
    event AssetRented(
        uint256 indexed rentalId,
        address indexed renter,
        uint256 indexed listingId,
        Assets.Asset warpedAsset,
        uint32 startTime,
        uint32 endTime
    );

    /**
     * @dev Returns token amount from specific collection rented by particular account.
     * @param warpedCollectionId Warped collection ID.
     * @param renter The renter account address.
     * @return Rented value.
     */
    function collectionRentedValue(bytes32 warpedCollectionId, address renter) external view returns (uint256);

    /**
     * @dev Returns the rental status of a given warped asset.
     * @param warpedAssetId Warped asset ID.
     * @return The asset rental status.
     */
    function assetRentalStatus(Assets.AssetId calldata warpedAssetId) external view returns (Rentings.RentalStatus);

    /**
     * @dev Evaluates renting params and returns rental fee breakdown.
     * @param rentingParams Renting parameters.
     * @return Rental fee breakdown.
     */
    function estimateRent(Rentings.Params calldata rentingParams) external view returns (Rentings.RentalFees memory);

    /**
     * @dev Performs renting operation.
     * @param rentingParams Renting parameters.
     * @param maxPaymentAmount Maximal payment amount the renter is willing to pay.
     * @return New rental ID.
     */
    function rent(Rentings.Params calldata rentingParams, uint256 maxPaymentAmount) external returns (uint256);

    /**
     * @dev Returns the rental agreement details.
     * @param rentalId Rental agreement ID.
     * @return Rental agreement details.
     */
    function rentalAgreementInfo(uint256 rentalId) external view returns (Rentings.Agreement memory);

    /**
     * @dev Returns the number of currently registered rental agreements for particular renter account.
     * @param renter Renter address.
     * @return Rental agreement count.
     */
    function userRentalCount(address renter) external view returns (uint256);

    /**
     * @dev Returns the paginated list of currently registered rental agreements for particular renter account.
     * @param renter Renter address.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return Rental agreement IDs.
     * @return Rental agreements.
     */
    function userRentalAgreements(
        address renter,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Rentings.Agreement[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../warper/IWarperManager.sol";
import "../warper/IWarperController.sol";

interface IAssetManager {
    /**
     * @dev Register a new asset.
     * @param assetClass Asset class identifier.
     * @param original The original assets address.
     */
    function registerAsset(bytes4 assetClass, address original) external;

    /**
     * @dev Retrieve the asset class controller for a given assetClass.
     * @param assetClass Asset class identifier.
     * @return The asset class controller.
     */
    function assetClassController(bytes4 assetClass) external view returns (address);

    /**
     * @dev Check if the given account is the admin of a warper.
     * @param warper Address of the warper.
     * @param account The users account to checked for the admin permissions on the warper.
     * @return True if the account is the admin of the warper.
     */
    function isWarperAdmin(address warper, address account) external view returns (bool);

    /**
     * @dev Returns the number of currently supported assets.
     * @return Asset count.
     */
    function supportedAssetCount() external view returns (uint256);

    /**
     * @dev Returns the list of all supported asset addresses.
     * @param offset Starting index.
     * @param limit Max number of items.
     * @return List of original asset addresses.
     * @return List of asset config structures.
     */
    function supportedAssets(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory, Assets.AssetConfig[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Protocol.sol";
import "../warper/IWarperManager.sol";

interface IProtocolConfigManager {
    /**
     * @dev Raised when the caller is not the WarperManager contract.
     */
    error CallerIsNotWarperManager();

    /**
     * @dev Emitted when a protocol rental fee is changed.
     * @param rentalFeePercent New protocol rental fee percentage.
     */
    event ProtocolRentalFeeChanged(uint16 rentalFeePercent);

    /**
     * @dev Updates the protocol rental fee percentage.
     * @param rentalFeePercent New protocol rental fee percentage.
     */
    function setProtocolRentalFeePercent(uint16 rentalFeePercent) external;

    /**
     * @dev Returns the protocol rental fee percentage.
     * @return protocol fee percent.
     */
    function protocolRentalFeePercent() external view returns (uint16);

    /**
     * @dev Returns the base token that's used for stable price denomination.
     * @return The base token address.
     */
    function baseToken() external view returns (address);

    /**
     * @dev Get thee Warper Controller contracts address for a given warper.
     * @param warper the warper address.
     * @return The Warper Controller address.
     */
    function warperController(address warper) external view returns (address);
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Multicall.sol)

pragma solidity ^0.8.0;

import "./Address.sol";

/**
 * @dev Provides a function to batch together multiple calls in a single external call.
 *
 * _Available since v4.1._
 */
abstract contract Multicall {
    /**
     * @dev Receives and executes a batch of function calls on this contract.
     */
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract CallForwarder {
    /**
     * @dev Thrown when a call is forwarded to a zero address.
     */
    error CallForwardToZeroAddress();

    /**
     * @dev Forwards the current call to `target`.
     */
    function _forward(address target) internal {
        // Prevent call forwarding to the zero address.
        if (target == address(0)) {
            revert CallForwardToZeroAddress();
        }

        uint256 value = msg.value;
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the target.
            // out and outsize are 0 for now, as we don't know the out size yet.
            let result := call(gas(), target, value, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // call returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "../../metahub/IMetahub.sol";
import "./InitializationContext.sol";

abstract contract WarperContext is Context, InitializationContext {
    /**
     * @dev Thrown when the message sender doesn't match the Metahub address.
     */
    error CallerIsNotMetahub();

    /**
     * @dev Thrown when the message sender doesn't match the warper admin address.
     */
    error CallerIsNotWarperAdmin();

    /**
     * @dev Metahub address slot.
     */
    bytes32 private constant _METAHUB_SLOT = bytes32(uint256(keccak256("iq.warper.metahub")) - 1);

    /**
     * @dev Original asset address slot.
     */
    bytes32 private constant _ORIGINAL_SLOT = bytes32(uint256(keccak256("iq.warper.original")) - 1);

    /**
     * @dev Modifier to make a function callable only by the metahub contract.
     */
    modifier onlyMetahub() {
        if (_msgSender() != _metahub()) {
            revert CallerIsNotMetahub();
        }
        _;
    }
    /**
     * @dev Modifier to make a function callable only by the warper admin.
     */
    modifier onlyWarperAdmin() {
        if (!IMetahub(_metahub()).isWarperAdmin(address(this), _msgSender())) {
            revert CallerIsNotWarperAdmin();
        }
        _;
    }

    /**
     * @dev Sets warper original asset address.
     */
    function _setOriginal(address original) internal onlyInitializingWarper {
        StorageSlot.getAddressSlot(_ORIGINAL_SLOT).value = original;
    }

    /**
     * @dev Sets warper metahub address.
     */
    function _setMetahub(address metahub) internal onlyInitializingWarper {
        StorageSlot.getAddressSlot(_METAHUB_SLOT).value = metahub;
    }

    /**
     * @dev Returns warper original asset address.
     */
    function _original() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ORIGINAL_SLOT).value;
    }

    /**
     * @dev warper metahub address.
     */
    function _metahub() internal view returns (address) {
        return StorageSlot.getAddressSlot(_METAHUB_SLOT).value;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "@openzeppelin/contracts/utils/Address.sol";

abstract contract InitializationContext {
    /**
     * @dev Thrown upon attempt to initialize a contract again.
     */
    error ContractIsAlreadyInitialized();

    /**
     * @dev Thrown when a function is invoked outside of initialization transaction.
     */
    error ContractIsNotInitializing();

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bytes32 internal constant _INITIALIZED_SLOT = bytes32(uint256(keccak256("iq.context.initialized")) - 1);

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bytes32 internal constant _INITIALIZING_SLOT = bytes32(uint256(keccak256("iq.context.initializing")) - 1);

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier warperInitializer() {
        bool initialized = !(
            StorageSlot.getBooleanSlot(_INITIALIZING_SLOT).value
                ? _isConstructor()
                : !StorageSlot.getBooleanSlot(_INITIALIZED_SLOT).value
        );

        if (initialized) {
            revert ContractIsAlreadyInitialized();
        }

        bool isTopLevelCall = !StorageSlot.getBooleanSlot(_INITIALIZING_SLOT).value;
        if (isTopLevelCall) {
            StorageSlot.getBooleanSlot(_INITIALIZING_SLOT).value = true;
            StorageSlot.getBooleanSlot(_INITIALIZED_SLOT).value = true;
        }

        _;

        if (isTopLevelCall) {
            StorageSlot.getBooleanSlot(_INITIALIZING_SLOT).value = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializingWarper() {
        if (!StorageSlot.getBooleanSlot(_INITIALIZING_SLOT).value) {
            revert ContractIsNotInitializing();
        }
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Libraries
import "../warper/Warpers.sol";
import "../acl/IACL.sol";
import "../universe/IUniverseRegistry.sol";
import "../asset/Assets.sol";
import "../metahub/IMetahub.sol";

abstract contract WarperManagerStorage {
    /**
     * @dev ACL contract.
     */
    IACL internal _aclContract;

    Warpers.Registry internal _warperRegistry;

    IAssetClassRegistry internal _assetClassRegistry;

    IMetahub internal _metahub;

    IUniverseRegistry internal _universeRegistry;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/access/IAccessControlEnumerableUpgradeable.sol";

/**
 * @title Access Control List contract interface.
 */
interface IACL is IAccessControlEnumerableUpgradeable {
    /**
     * @dev Thrown when the Admin roles bytes is incorrectly formatted.
     */
    error RolesContractIncorrectlyConfigured();

    /**
     * @dev Thrown when the attempting to remove the very last admin from ACL.
     */
    error CannotRemoveLastAdmin();

    /**
     * @notice revert if the `account` does not have the specified role.
     * @param role the role specifier.
     * @param account the address to check the role for.
     */
    function checkRole(bytes32 role, address account) external view;

    /**
     * @notice Get the admin role describing bytes
     * return role bytes
     */
    function adminRole() external pure returns (bytes32);

    /**
     * @notice Get the supervisor role describing bytes
     * return role bytes
     */
    function supervisorRole() external pure returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
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
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

import "../warper/Warper.sol";
import "../warper/IWarperPreset.sol";

contract WarperPresetMock is IWarperPreset, Warper {
    uint256 internal _initValue;
    uint256 internal _extraValue;

    function __initialize(bytes calldata config) external warperInitializer {
        (address original, address metahub, bytes memory presetData) = abi.decode(config, (address, address, bytes));

        (uint256 initValue1, uint256 initValue2) = abi.decode(presetData, (uint256, uint256));
        _Warper_init(original, metahub);
        _initValue = initValue1 + initValue2;
    }

    function setExtraValue(uint256 value) external {
        _extraValue = value;
    }

    function extraValue() external view returns (uint256) {
        return _extraValue;
    }

    function initValue() external view returns (uint256) {
        return _initValue;
    }

    function __assetClass() external pure returns (bytes4) {
        return "";
    }

    function supportsInterface(bytes4 interfaceId) public view override(Warper, IERC165) returns (bool) {
        return interfaceId == type(IWarperPreset).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

import "./IWarper.sol";

interface IWarperPreset is IWarper {
    /**
     * @dev Warper generic initialization method.
     * @param config Warper configuration parameters.
     */
    function __initialize(bytes calldata config) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../acl/AccessControlledUpgradeable.sol";
import "./IWarperPresetFactory.sol";
import "./IWarperPreset.sol";
import "./WarperPresetFactoryStorage.sol";

/**
 * @title Warper preset factory contract.
 */
contract WarperPresetFactory is
    IWarperPresetFactory,
    UUPSUpgradeable,
    AccessControlledUpgradeable,
    WarperPresetFactoryStorage
{
    using ClonesUpgradeable for address;
    using AddressUpgradeable for address;
    using ERC165CheckerUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;

    /**
     * @dev Modifier to check that the preset is currently enabled.
     */
    modifier whenEnabled(bytes32 presetId) {
        if (!_presets[presetId].enabled) revert DisabledWarperPreset(presetId);
        _;
    }

    /**
     * @dev Modifier to check that the preset is currently disabled.
     */
    modifier whenDisabled(bytes32 presetId) {
        if (_presets[presetId].enabled) revert EnabledWarperPreset(presetId);
        _;
    }

    /**
     * @dev Modifier to check that the preset is registered.
     */
    modifier presetIsRegistered(bytes32 presetId) {
        if (_presets[presetId].implementation == address(0)) revert WarperPresetNotRegistered(presetId);
        _;
    }

    /**
     * @dev Constructor that gets called for the implementation contract.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() initializer {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev WarperPresetFactory initializer.
     * @param acl Address of the ACL contract.
     */
    function initialize(address acl) external initializer {
        __UUPSUpgradeable_init();

        _aclContract = IACL(acl);
    }

    /**
     * @inheritdoc IWarperPresetFactory
     */
    function addPreset(bytes32 presetId, address implementation) external onlySupervisor {
        // Check whether provided implementation address is a contract with the correct interface.
        if (!implementation.supportsInterface(type(IWarperPreset).interfaceId)) {
            revert InvalidWarperPresetInterface();
        }

        if (_presetIds.add(presetId)) {
            _presets[presetId] = WarperPreset(presetId, implementation, true);
            emit WarperPresetAdded(presetId, implementation);
        } else {
            revert DuplicateWarperPresetId(presetId);
        }
    }

    /**
     * @inheritdoc IWarperPresetFactory
     */
    function removePreset(bytes32 presetId) external onlySupervisor {
        if (_presetIds.remove(presetId)) {
            delete _presets[presetId];
            emit WarperPresetRemoved(presetId);
        }
    }

    /**
     * @inheritdoc IWarperPresetFactory
     */
    function enablePreset(bytes32 presetId)
        external
        presetIsRegistered(presetId)
        whenDisabled(presetId)
        onlySupervisor
    {
        _presets[presetId].enabled = true;
        emit WarperPresetEnabled(presetId);
    }

    /**
     * @inheritdoc IWarperPresetFactory
     */
    function disablePreset(bytes32 presetId)
        external
        presetIsRegistered(presetId)
        whenEnabled(presetId)
        onlySupervisor
    {
        _presets[presetId].enabled = false;
        emit WarperPresetDisabled(presetId);
    }

    /**
     * @inheritdoc IWarperPresetFactory
     */
    function deployPreset(bytes32 presetId, bytes calldata initData) external whenEnabled(presetId) returns (address) {
        // Init data must never be empty here, because all presets have mandatory init params.
        if (initData.length == 0) {
            revert EmptyPresetData();
        }

        // Deploy warper preset implementation proxy.
        address warper = _presets[presetId].implementation.clone();

        // Initialize warper.
        warper.functionCall(initData);
        emit WarperPresetDeployed(presetId, warper);

        return warper;
    }

    /**
     * @inheritdoc IWarperPresetFactory
     */
    function presetEnabled(bytes32 presetId) external view presetIsRegistered(presetId) returns (bool) {
        return _presets[presetId].enabled;
    }

    /**
     * @inheritdoc IWarperPresetFactory
     */
    function presets() external view returns (WarperPreset[] memory) {
        uint256 length = _presetIds.length();
        WarperPreset[] memory warperPresets = new WarperPreset[](length);
        for (uint256 i = 0; i < length; i++) {
            warperPresets[i] = _presets[_presetIds.at(i)];
        }
        return warperPresets;
    }

    /**
     * @inheritdoc IWarperPresetFactory
     */
    function preset(bytes32 presetId) external view presetIsRegistered(presetId) returns (WarperPreset memory) {
        return _presets[presetId];
    }

    /**
     * @inheritdoc UUPSUpgradeable
     */
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyAdmin {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @inheritdoc AccessControlledUpgradeable
     */
    function _acl() internal view virtual override returns (IACL) {
        return _aclContract;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library ClonesUpgradeable {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import "./Roles.sol";
import "./IACL.sol";

/**
 * @title Modifier provider for contracts that want to interact with the ACL contract.
 */
abstract contract AccessControlledUpgradeable is ContextUpgradeable {
    /**
     * @dev Modifier to make a function callable by the admin account.
     */
    modifier onlyAdmin() {
        _acl().checkRole(Roles.ADMIN, _msgSender());
        _;
    }

    /**
     * @dev Modifier to make a function callable by a supervisor account.
     */
    modifier onlySupervisor() {
        _acl().checkRole(Roles.SUPERVISOR, _msgSender());
        _;
    }

    /**
     * @dev return the IACL address
     */
    function _acl() internal view virtual returns (IACL);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import "../acl/IACL.sol";
import "./WarperPresetFactoryStorage.sol";
import "./IWarperPresetFactory.sol";

abstract contract WarperPresetFactoryStorage {
    /**
     * @dev The ACL contract address.
     */
    IACL internal _aclContract;

    /**
     * @dev Mapping presetId to preset struct.
     */
    mapping(bytes32 => IWarperPresetFactory.WarperPreset) internal _presets;

    /**
     * @dev Registered presets.
     */
    EnumerableSetUpgradeable.Bytes32Set internal _presetIds;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title Different role definitions used by the ACL contract.
 */
library Roles {
    /**
     * @dev This maps directly to the OpenZeppelins AccessControl DEFAULT_ADMIN
     */
    bytes32 public constant ADMIN = 0x00;
    bytes32 public constant SUPERVISOR = keccak256("SUPERVISOR_ROLE");
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Libraries
import "../accounting/Accounts.sol";
import "../universe/IUniverseRegistry.sol";
import "../asset/Assets.sol";
import "../warper/Warpers.sol";
import "../listing/Listings.sol";
import "./Protocol.sol";

import "../acl/IACL.sol";

abstract contract MetahubStorage {
    /**
     * @dev ACL contract.
     */
    IACL internal _aclContract;

    /**
     * @dev Protocol configuration.
     */
    Protocol.Config internal _protocolConfig;

    /**
     * @dev Account registry contains the data about participants' accounts and their current balances.
     */
    Accounts.Registry internal _accountRegistry;

    /**
     * @dev Universe registry contains the data about all registered universes and their settings.
     */
    IUniverseRegistry internal _universeRegistry;

    /**
     * @dev Asset registry contains the data about all registered assets and supported asset classes.
     */
    Assets.Registry internal _assetRegistry;

    /**
     * @dev Warper manager contains the data about all registered warpers.
     */
    IWarperManager internal _warperManager;

    /**
     * @dev Listing registry contains the data about all listings.
     */
    Listings.Registry internal _listingRegistry;

    /**
     * @dev Renting registry contains the data about all rentals.
     */
    Rentings.Registry internal _rentingRegistry;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../acl/IACL.sol";
import "./UniverseToken.sol";
import "./IUniverseRegistry.sol";

/**
 * @title Universe Registry storage contract.
 */
abstract contract UniverseRegistryStorage {
    struct Universe {
        string name;
        uint16 rentalFeePercent;
    }

    /**
     * @dev ACL contract address.
     */
    IACL internal _aclContract;

    /**
     * @dev Universe token address.
     */
    IUniverseToken internal _universeToken;

    /**
     * @dev Universe token base URI.
     */
    string internal _baseURI;

    /**
     * @dev Mapping from token ID to the Universe structure.
     */
    mapping(uint256 => Universe) internal _universes;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./IUniverseToken.sol";
import "./IUniverseRegistry.sol";

/**
 * @title Universe token contract.
 */
contract UniverseToken is IUniverseToken, ERC721 {
    using Counters for Counters.Counter;

    /**
     * @dev Thrown when the message sender doesn't match the registries address.
     */
    error CallerIsNotRegistry();

    /**
     * @dev Registry.
     */
    IUniverseRegistry private immutable _registry;

    /**
     * @dev Token ID counter.
     */
    Counters.Counter private _tokenIdTracker;

    /**
     * @dev Modifier to make a function callable only by the registry contract.
     */
    modifier onlyRegistry() {
        if (_msgSender() != address(_registry)) revert CallerIsNotRegistry();
        _;
    }

    /**
     * @dev UniverseToken constructor.
     * @param registry Universe registry.
     */
    constructor(IUniverseRegistry registry) ERC721("IQVerse", "IQV") {
        _registry = registry;
    }

    /**
     * @inheritdoc IUniverseToken
     */
    function mint(address to) external onlyRegistry returns (uint256 tokenId) {
        _tokenIdTracker.increment();
        tokenId = _tokenIdTracker.current();
        _safeMint(to, tokenId);
    }

    /**
     * @inheritdoc IUniverseToken
     */
    function currentId() external view returns (uint256) {
        return _tokenIdTracker.current();
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, IERC165) returns (bool) {
        return interfaceId == type(IUniverseToken).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc ERC721
     */
    function _baseURI() internal view override returns (string memory) {
        return _registry.universeTokenBaseURI();
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

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
     * by default, can be overridden in child contracts.
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
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
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

        _afterTokenTransfer(address(0), to, tokenId);
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

        _afterTokenTransfer(owner, address(0), tokenId);
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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
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

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";

interface IUniverseToken is IERC721Metadata {
    /**
     * @dev Mints new token and transfers it to `to` address.
     * @param to Universe owner address.
     * @return Minted token ID.
     */
    function mint(address to) external returns (uint256);

    /**
     * @dev Returns current token ID.
     */
    function currentId() external view returns (uint256);
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

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../universe/IUniverseToken.sol";
import "../warper/mechanics/asset-rentability/IAssetRentabilityMechanics.sol";
import "../warper/mechanics/availability-period/IAvailabilityPeriodMechanics.sol";
import "../warper/mechanics/rental-fee-premium/IRentalFeePremiumMechanics.sol";
import "../warper/mechanics/rental-period/IRentalPeriodMechanics.sol";
import "../warper/mechanics/renting-hook/IRentingHookMechanics.sol";
import "../warper/ERC721/IERC721Warper.sol";

contract SolidityInterfaces {
    struct Interface {
        string name;
        bytes4 id;
    }

    Interface[] internal _list;

    constructor() {
        _list.push(Interface("IUniverseToken", type(IUniverseToken).interfaceId));
        _list.push(Interface("IERC721", type(IERC721).interfaceId));
        _list.push(Interface("IAssetRentabilityMechanics", type(IAssetRentabilityMechanics).interfaceId));
        _list.push(Interface("IAvailabilityPeriodMechanics", type(IAvailabilityPeriodMechanics).interfaceId));
        _list.push(Interface("IRentalFeePremiumMechanics", type(IRentalFeePremiumMechanics).interfaceId));
        _list.push(Interface("IRentalPeriodMechanics", type(IRentalPeriodMechanics).interfaceId));
        _list.push(Interface("IRentingHookMechanics", type(IRentingHookMechanics).interfaceId));
        _list.push(Interface("IWarper", type(IWarper).interfaceId));
        _list.push(Interface("IERC721Warper", type(IERC721Warper).interfaceId));
    }

    function list() external view returns (Interface[] memory) {
        return _list;
    }
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

interface IAssetRentabilityMechanics {
    /**
     * @dev Thrown when the asset renting is rejected by warper due to the `reason`.
     */
    error AssetIsNotRentable(string reason);

    /**
     * Returns information if an asset is rentable.
     * @param renter The address of the renter.
     * @param tokenId The token ID.
     * @param amount The token amount.
     * @return isRentable True if asset is rentable.
     * @return errorMessage The reason of the asset not being rentable.
     */
    function __isRentableAsset(
        address renter,
        uint256 tokenId,
        uint256 amount
    ) external view returns (bool isRentable, string memory errorMessage);
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

interface IAvailabilityPeriodMechanics {
    /**
     * @dev Thrown when the current time is not withing the warper availability period.
     */
    error WarperIsNotAvailableForRenting(
        uint256 currentTime,
        uint32 availabilityPeriodStart,
        uint32 availabilityPeriodEnd
    );

    /**
     * @dev Returns warper availability period starting time.
     * @return Unix timestamp after which the warper is rentable.
     */
    function __availabilityPeriodStart() external view returns (uint32);

    /**
     * @dev Returns warper availability period ending time.
     * @return Unix timestamp after which the warper is NOT rentable.
     */
    function __availabilityPeriodEnd() external view returns (uint32);

    /**
     * @dev Returns warper availability period.
     * @return availabilityPeriodStart Unix timestamp after which the warper is rentable.
     * @return availabilityPeriodEnd Unix timestamp after which the warper is NOT rentable.
     */
    function __availabilityPeriodRange()
        external
        view
        returns (uint32 availabilityPeriodStart, uint32 availabilityPeriodEnd);
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

interface IRentalFeePremiumMechanics {
    /**
     * @dev Calculate extra premiums.
     * @param renter The renter address.
     * @param tokenId The token ID to calculate the extra premium for.
     * @param amount The token amount.
     * @param rentalPeriod The rental period in seconds.
     * @param universeFee The current universe fee.
     * @param listerFee The current lister fee.
     * @return universePremium The universe premium price to add.
     * @return listerPremium The lister premium price to add.
     */
    function __calculatePremiums(
        address renter,
        uint256 tokenId,
        uint256 amount,
        uint32 rentalPeriod,
        uint256 universeFee,
        uint256 listerFee
    ) external view returns (uint256 universePremium, uint256 listerPremium);
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

interface IRentalPeriodMechanics {
    /**
     * @dev Thrown when the requested rental period is not withing the warper allowed rental period range.
     */
    error WarperRentalPeriodIsOutOfRange(uint32 requestedRentalPeriod, uint32 minRentalPeriod, uint32 maxRentalPeriod);

    /**
     * @dev Returns warper minimal rental period.
     * @return Time is seconds.
     */
    function __minRentalPeriod() external view returns (uint32);

    /**
     * @dev Returns warper maximal rental period.
     * @return Time is seconds.
     */
    function __maxRentalPeriod() external view returns (uint32);

    /**
     * @dev Returns warper rental period range.
     * @return minRentalPeriod The minimal amount of time the warper can be rented for.
     * @return maxRentalPeriod The maximal amount of time the warper can be rented for.
     */
    function __rentalPeriodRange() external view returns (uint32 minRentalPeriod, uint32 maxRentalPeriod);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../IListingController.sol";

interface IFixedPriceListingController is IListingController {
    /**
     * @dev Decodes listing strategy params.
     * @param params Encoded listing strategy params.
     * @return baseRate Asset renting base rate (base tokens per second).
     */
    function decodeStrategyParams(Listings.Params memory params) external pure returns (uint256 baseRate);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../../../acl/AccessControlledUpgradeable.sol";
import "../../ListingController.sol";

import "./IFixedPriceListingController.sol";
import "./FixedPriceListingControllerStorage.sol";

contract FixedPriceListingController is
    IFixedPriceListingController,
    UUPSUpgradeable,
    AccessControlledUpgradeable,
    ListingController,
    FixedPriceListingControllerStorage
{
    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() initializer {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Contract initializer.
     * @param acl ACL contract address.
     */
    function initialize(address acl) external initializer {
        __UUPSUpgradeable_init();
        _aclContract = IACL(acl);
    }

    /**
     * @inheritdoc IListingController
     */
    function calculateRentalFee(Listings.Params calldata strategyParams, Rentings.Params calldata rentingParams)
        external
        pure
        returns (uint256)
    {
        uint256 baseRate = decodeStrategyParams(strategyParams);
        return rentingParams.rentalPeriod * baseRate;
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view override(ListingController, IERC165) returns (bool) {
        return interfaceId == type(IFixedPriceListingController).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IListingController
     */
    function strategyId() public pure override(ListingController, IListingController) returns (bytes4) {
        return Listings.FIXED_PRICE;
    }

    /**
     * @inheritdoc IFixedPriceListingController
     */
    function decodeStrategyParams(Listings.Params memory params)
        public
        pure
        compatibleStrategy(params.strategy)
        returns (uint256 baseRate)
    {
        return abi.decode(params.data, (uint256));
    }

    /**
     * @inheritdoc UUPSUpgradeable
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @inheritdoc AccessControlledUpgradeable
     */
    function _acl() internal view override returns (IACL) {
        return _aclContract;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./IListingController.sol";

abstract contract ListingController is IListingController, ERC165 {
    /**
     * @dev Modifier to check strategy compatibility.
     */
    modifier compatibleStrategy(bytes4 checkedStrategyId) {
        if (checkedStrategyId != strategyId()) revert ListingStrategyMismatch(checkedStrategyId, strategyId());
        _;
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IListingController).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IListingController
     */
    function strategyId() public pure virtual returns (bytes4);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../../acl/IACL.sol";

abstract contract FixedPriceListingControllerStorage {
    /**
     * @dev ACL contract.
     */
    IACL internal _aclContract;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../../../acl/AccessControlledUpgradeable.sol";
import "../../ListingController.sol";

import "./IFixedPriceWithRewardListingController.sol";
import "./FixedPriceWithRewardListingControllerStorage.sol";

contract FixedPriceWithRewardListingController is
    IFixedPriceWithRewardListingController,
    UUPSUpgradeable,
    AccessControlledUpgradeable,
    ListingController,
    FixedPriceWithRewardListingControllerStorage
{
    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() initializer {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Contract initializer.
     * @param acl ACL contract address.
     */
    function initialize(address acl) external initializer {
        __UUPSUpgradeable_init();
        _aclContract = IACL(acl);
    }

    /**
     * @inheritdoc IListingController
     */
    function calculateRentalFee(Listings.Params calldata strategyParams, Rentings.Params calldata rentingParams)
        external
        pure
        returns (uint256)
    {
        (uint256 baseRate, ) = decodeStrategyParams(strategyParams);
        return rentingParams.rentalPeriod * baseRate;
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view override(ListingController, IERC165) returns (bool) {
        return
            interfaceId == type(IFixedPriceWithRewardListingController).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IListingController
     */
    function strategyId() public pure override(ListingController, IListingController) returns (bytes4) {
        return Listings.FIXED_PRICE_WITH_REWARD;
    }

    /**
     * @inheritdoc IFixedPriceWithRewardListingController
     */
    function decodeStrategyParams(Listings.Params memory params)
        public
        pure
        compatibleStrategy(params.strategy)
        returns (uint256 baseRate, uint16 baseRewardPercent)
    {
        return abi.decode(params.data, (uint256, uint16));
    }

    /**
     * @inheritdoc UUPSUpgradeable
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @inheritdoc AccessControlledUpgradeable
     */
    function _acl() internal view override returns (IACL) {
        return _aclContract;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../IListingController.sol";

interface IFixedPriceWithRewardListingController is IListingController {
    /**
     * @dev Decodes listing strategy params.
     * @param params Encoded listing strategy params.
     * @return baseRate Asset renting base rate (base tokens per second).
     * @return baseRewardPercent Asset renting base reward percent.
     */
    function decodeStrategyParams(Listings.Params memory params)
        external
        pure
        returns (uint256 baseRate, uint16 baseRewardPercent);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../../acl/IACL.sol";

abstract contract FixedPriceWithRewardListingControllerStorage {
    /**
     * @dev ACL contract.
     */
    IACL internal _aclContract;
}

// SPDX-License-Identifier: MIT
// solhint-disable no-empty-blocks
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../acl/AccessControlledUpgradeable.sol";
import "./IWarperManager.sol";
import "./WarperManagerStorage.sol";

contract WarperManager is
    IWarperManager,
    Initializable,
    UUPSUpgradeable,
    AccessControlledUpgradeable,
    WarperManagerStorage
{
    using Warpers for Warpers.Registry;
    using Warpers for Warpers.Warper;
    using Assets for Assets.Asset;
    using Assets for Assets.Registry;

    /**
     * @dev Metahub initialization params.
     * @param warperPresetFactory Warper preset factory address.
     * @param assetClassRegistry
     * @param universeRegistry
     * @param acl
     */
    struct WarperManagerInitParams {
        IWarperPresetFactory warperPresetFactory;
        IAssetClassRegistry assetClassRegistry;
        IUniverseRegistry universeRegistry;
        IACL acl;
    }

    /**
     * @dev Modifier to make a function callable only by the warpers admin (universe owner).
     */
    modifier onlyWarperAdmin(address warper) {
        _checkWarperAdmin(warper, _msgSender());
        _;
    }

    /**
     * @dev Modifier to make sure that the warper has been registered beforehand.
     */
    modifier onlyRegisteredWarper(address warper) {
        _warperRegistry.checkRegisteredWarper(warper);
        _;
    }

    /**
     * @dev Modifier to make a function callable only by the universe owner.
     */
    modifier onlyUniverseOwner(uint256 universeId) {
        _universeRegistry.checkUniverseOwner(universeId, _msgSender());
        _;
    }

    /**
     * @dev Modifier to make a function callable only by the universe owner.
     */
    modifier whileMetahub(uint256 universeId) {
        _universeRegistry.checkUniverseOwner(universeId, _msgSender());
        _;
    }

    /**
     * @dev Metahub initializer.
     * @param params Initialization params.
     */
    function initialize(WarperManagerInitParams calldata params) external initializer {
        __UUPSUpgradeable_init();

        _aclContract = params.acl;

        _warperRegistry.presetFactory = params.warperPresetFactory;
        _assetClassRegistry = params.assetClassRegistry;
        _universeRegistry = params.universeRegistry;
    }

    /**
     * @dev Set Metahub post-initialization to avoid circular dependencies.
     */
    function setMetahub(IMetahub metahub_) external onlyAdmin {
        _metahub = metahub_;
    }

    /**
     * @inheritdoc IWarperManager
     */
    function registerWarper(address warper, WarperRegistrationParams calldata params)
        external
        onlyUniverseOwner(params.universeId)
    {
        (bytes4 assetClass, address original) = _warperRegistry.registerWarper(warper, params, _assetClassRegistry);

        _metahub.registerAsset(assetClass, original);

        emit WarperRegistered(params.universeId, warper, original, assetClass);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function deregisterWarper(address warper) external onlyWarperAdmin(warper) {
        _warperRegistry.remove(warper);
        emit WarperDeregistered(warper);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function pauseWarper(address warper) external onlyWarperAdmin(warper) {
        _warperRegistry.warpers[warper].pause();
        emit WarperPaused(warper);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function unpauseWarper(address warper) external onlyWarperAdmin(warper) {
        _warperRegistry.warpers[warper].unpause();
        emit WarperUnpaused(warper);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function setWarperController(address[] calldata warpers, address controller) external onlyAdmin {
        for (uint256 i = 0; i < warpers.length; i++) {
            address warper = warpers[i];
            _warperRegistry.checkRegisteredWarper(warper);
            IWarperController(controller).checkCompatibleWarper(warper);
            _warperRegistry.warpers[warper].controller = IWarperController(controller);
        }
    }

    /**
     * @inheritdoc IWarperManager
     */
    function warperPresetFactory() external view returns (address) {
        return address(_warperRegistry.presetFactory);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function metahub() external view returns (address) {
        return address(_metahub);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function universeWarperCount(uint256 universeId) external view returns (uint256) {
        return _warperRegistry.universeWarperCount(universeId);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function universeWarpers(
        uint256 universeId,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory, Warpers.Warper[] memory) {
        return _warperRegistry.universeWarpers(universeId, offset, limit);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function assetWarperCount(address original) external view returns (uint256) {
        return _warperRegistry.assetWarperCount(original);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function assetWarpers(
        address original,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory, Warpers.Warper[] memory) {
        return _warperRegistry.assetWarpers(original, offset, limit);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function isWarperAdmin(address warper, address account) external view onlyRegisteredWarper(warper) returns (bool) {
        return _universeRegistry.isUniverseOwner(_warperRegistry.warpers[warper].universeId, account);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function warperInfo(address warper) external view onlyRegisteredWarper(warper) returns (Warpers.Warper memory) {
        return _warperRegistry.warpers[warper];
    }

    /**
     * @inheritdoc IWarperManager
     */
    function checkSupportedAsset(address asset) external view {
        return _warperRegistry.checkSupportedAsset(asset);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function checkRegisteredWarper(address warper) external view {
        return _warperRegistry.checkRegisteredWarper(warper);
    }

    /**
     * @inheritdoc IWarperManager
     */
    function warperController(address warper) external view onlyRegisteredWarper(warper) returns (address) {
        return address(_warperRegistry.warpers[warper].controller);
    }

    /**
     * @inheritdoc UUPSUpgradeable
     * @dev Checks whether the caller is authorized to upgrade the Metahub implementation.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Reverts if the warpers universe owner is not the provided account address.
     * @param warper Warpers address.
     * @param account The address that's expected to be the warpers universe owner.
     */
    function _checkWarperAdmin(address warper, address account) internal view {
        _universeRegistry.checkUniverseOwner(_warperRegistry.warpers[warper].universeId, account);
    }

    /**
     * @inheritdoc AccessControlledUpgradeable
     */
    function _acl() internal view override returns (IACL) {
        return _aclContract;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
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
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";

import "../acl/AccessControlledUpgradeable.sol";
import "./IListingStrategyRegistry.sol";
import "./ListingStrategyRegistryStorage.sol";

contract ListingStrategyRegistry is
    IListingStrategyRegistry,
    UUPSUpgradeable,
    AccessControlledUpgradeable,
    ListingStrategyRegistryStorage
{
    using ERC165CheckerUpgradeable for address;

    /**
     * @dev Modifier to make a function callable only for the registered listing strategy.
     */
    modifier onlyRegisteredStrategy(bytes4 strategyId) {
        checkRegisteredListingStrategy(strategyId);
        _;
    }

    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() initializer {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Contract initializer.
     * @param acl ACL contract address.
     */
    function initialize(address acl) external initializer {
        __UUPSUpgradeable_init();
        _aclContract = IACL(acl);
    }

    /**
     * @inheritdoc IListingStrategyRegistry
     */
    function registerListingStrategy(bytes4 strategyId, StrategyConfig calldata config) external onlyAdmin {
        _checkValidListingController(strategyId, config.controller);
        if (isRegisteredListingStrategy(strategyId)) {
            revert ListingStrategyIsAlreadyRegistered(strategyId);
        }

        _strategies[strategyId] = config;
        emit ListingStrategyRegistered(strategyId, config.controller);
    }

    /**
     * @inheritdoc IListingStrategyRegistry
     */
    function setListingController(bytes4 strategyId, address controller)
        external
        onlySupervisor
        onlyRegisteredStrategy(strategyId)
    {
        _checkValidListingController(strategyId, controller);
        _strategies[strategyId].controller = controller;
        emit ListingStrategyControllerChanged(strategyId, controller);
    }

    /**
     * @inheritdoc IListingStrategyRegistry
     */
    function listingController(bytes4 strategyId) external view onlyRegisteredStrategy(strategyId) returns (address) {
        return _strategies[strategyId].controller;
    }

    /**
     * @inheritdoc IListingStrategyRegistry
     */
    function listingStrategy(bytes4 strategyId)
        external
        view
        onlyRegisteredStrategy(strategyId)
        returns (StrategyConfig memory)
    {
        return _strategies[strategyId];
    }

    /**
     * @inheritdoc IListingStrategyRegistry
     */
    function isRegisteredListingStrategy(bytes4 strategyId) public view returns (bool) {
        return _strategies[strategyId].controller != address(0);
    }

    /**
     * @inheritdoc IListingStrategyRegistry
     */
    function checkRegisteredListingStrategy(bytes4 strategyId) public view {
        if (!isRegisteredListingStrategy(strategyId)) revert UnregisteredListingStrategy(strategyId);
    }

    /**
     * @inheritdoc UUPSUpgradeable
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Reverts if provided address is not a valid listing controller.
     * @param strategyId Listing strategy ID.
     * @param controller Listing controller address.
     */
    function _checkValidListingController(bytes4 strategyId, address controller) internal view {
        if (!controller.supportsInterface(type(IListingController).interfaceId))
            revert InvalidListingControllerInterface();

        bytes4 contractStrategyId = IListingController(controller).strategyId();
        if (contractStrategyId != strategyId) revert ListingStrategyMismatch(contractStrategyId, strategyId);
    }

    /**
     * @inheritdoc AccessControlledUpgradeable
     */
    function _acl() internal view override returns (IACL) {
        return _aclContract;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../acl/IACL.sol";
import "./IListingStrategyRegistry.sol";

abstract contract ListingStrategyRegistryStorage {
    /**
     * @dev ACL contract.
     */
    IACL internal _aclContract;

    /**
     * @dev Mapping from listing strategy ID to the listing strategy configuration.
     */
    mapping(bytes4 => IListingStrategyRegistry.StrategyConfig) internal _strategies;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./IAssetController.sol";

abstract contract AssetController is IAssetController, ERC165 {
    /**
     * The fallback function is needed to ensure forward compatibility with Metahub.
     * When introducing a new version of controller with additional external functions,
     * it must be safe to call the those new functions on previous generation of controllers and it must not cause
     * the transaction revert.
     */
    fallback() external {
        // solhint-disable-previous-line no-empty-blocks, payable-fallback
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IAssetController).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC721.sol";

import "../Assets.sol";
import "../utils/DelegateContext.sol";
import "./ERC721AssetVault.sol";
import "../AssetController.sol";

/**
 * @title Asset controller for the ERC721 tokens
 */
contract ERC721AssetController is AssetController, DelegateContext {
    using Assets for Assets.AssetId;

    /**
     * @dev Thrown when the asset value is invalid for ERC721 token standard.
     */
    error InvalidERC721Value(uint256 value);

    /**
     * @inheritdoc IAssetController
     */
    function assetClass() public pure returns (bytes4) {
        return Assets.ERC721;
    }

    /**
     * @inheritdoc IAssetController
     */
    function transferAssetToVault(
        Assets.Asset memory asset,
        address assetOwner,
        address vault
    ) external onlyDelegatecall {
        _transferAsset(asset, assetOwner, vault, "");
    }

    /**
     * @inheritdoc IAssetController
     */
    function returnAssetFromVault(Assets.Asset memory asset, address vault) external onlyDelegatecall {
        _validateAsset(asset);
        // Decode asset ID to extract identification data.
        (address token, uint256 tokenId) = _decodeAssetId(asset.id);
        IERC721AssetVault(vault).returnToOwner(token, tokenId);
    }

    /**
     * @inheritdoc IAssetController
     */
    function transfer(
        Assets.Asset memory asset,
        address from,
        address to,
        bytes memory data
    ) external onlyDelegatecall {
        _transferAsset(asset, from, to, data);
    }

    /**
     * @inheritdoc IAssetController
     */
    function collectionId(Assets.AssetId memory assetId) external pure returns (bytes32) {
        if (assetId.class != assetClass()) revert AssetClassMismatch(assetId.class, assetClass());
        return _collectionId(assetId.token());
    }

    /**
     * @dev Calculates collection ID.
     * Foe ERC721 tokens, the collection ID is calculated by hashing the contract address itself.
     */
    function _collectionId(address token) internal pure returns (bytes32) {
        return keccak256(abi.encode(token));
    }

    /**
     * @dev Executes asset transfer.
     */
    function _transferAsset(
        Assets.Asset memory asset,
        address from,
        address to,
        bytes memory data
    ) internal {
        // Make user the asset is valid before decoding and transferring.
        _validateAsset(asset);

        // Decode asset ID to extract identification data, required for transfer.
        (address token, uint256 tokenId) = _decodeAssetId(asset.id);

        // Execute safe transfer.
        IERC721(token).safeTransferFrom(from, to, tokenId, data);
        emit AssetTransfer(asset, from, to, data);
    }

    /**
     * @dev Decodes asset ID and extracts identification data.
     * @param id Asset ID structure.
     * @return token Token contract address.
     * @return tokenId Token ID.
     */
    function _decodeAssetId(Assets.AssetId memory id) internal pure returns (address token, uint256 tokenId) {
        return abi.decode(id.data, (address, uint256));
    }

    /**
     * @dev Encodes asset ID.
     * @param token Token contract address.
     * @param tokenId Token ID.
     * @return Asset ID structure.
     */
    function _encodeAssetId(address token, uint256 tokenId) internal pure returns (Assets.AssetId memory) {
        return Assets.AssetId(assetClass(), abi.encode(token, tokenId));
    }

    /**
     * @dev Reverts if the asset params are not valid.
     * @param asset Asset structure.
     */
    function _validateAsset(Assets.Asset memory asset) internal pure {
        // Ensure correct class.
        if (asset.id.class != assetClass()) revert AssetClassMismatch(asset.id.class, assetClass());
        // Ensure correct value, must be 1 for NFT.
        if (asset.value != 1) revert InvalidERC721Value(asset.value);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract DelegateContext {
    /**
     * @dev Thrown when a function is called directly and not through a delegatecall.
     */
    error FunctionMustBeCalledThroughDelegatecall();

    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call.
     */
    modifier onlyDelegatecall() {
        if (address(this) == __self) revert FunctionMustBeCalledThroughDelegatecall();
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "../AssetVault.sol";
import "../Assets.sol";
import "./IERC721AssetVault.sol";

contract ERC721AssetVault is IERC721AssetVault, AssetVault {
    /**
     * @dev Vault inventory
     * Mapping token address -> token ID -> owner.
     */
    mapping(address => mapping(uint256 => address)) private _inventory;

    /**
     * @dev Constructor.
     * @param operator First operator account.
     * @param acl ACL contract address
     */
    constructor(address operator, address acl) AssetVault(operator, acl) {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @inheritdoc IERC721Receiver
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external whenAssetDepositAllowed(operator) returns (bytes4) {
        // Associate received asset with the original owner address.
        // Here message sender is a token address.
        _inventory[_msgSender()][tokenId] = from;

        return this.onERC721Received.selector;
    }

    /**
     * @inheritdoc IERC721AssetVault
     */
    function returnToOwner(address token, uint256 tokenId) external whenAssetReturnAllowed {
        // Check if the asset is registered and the original asset owner is known.
        address owner = _inventory[token][tokenId];
        if (owner == address(0)) revert AssetNotFound();

        // Return asset to the owner.
        delete _inventory[token][tokenId];
        IERC721(token).transferFrom(address(this), owner, tokenId);
    }

    /**
     * @inheritdoc IAssetVault
     */
    function assetClass() external pure returns (bytes4) {
        return Assets.ERC721;
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AssetVault, IERC165) returns (bool) {
        return interfaceId == type(IERC721AssetVault).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../acl/AccessControlled.sol";
import "./IAssetVault.sol";

/**
 * @dev During the normal operation time, only Metahub contract is allowed to initiate asset return to the original
 * asset owner. In case of emergency, the vault admin can switch vault to recovery mode, therefore allowing anyone to
 * initiate asset return.
 *
 * NOTE: There is no way to transfer asset from the vault to an arbitrary address. The asset can only be returned to
 * the rightful owner.
 *
 * Warning: All tokens transferred to the vault contract directly (not by Metahub contract) will be lost forever!!!
 *
 */
abstract contract AssetVault is IAssetVault, AccessControlled, Pausable, ERC165 {
    using SafeERC20 for IERC20;

    /**
     * @dev Vault recovery mode state.
     */
    bool private _recovery;

    /**
     * @dev Metahub address.
     */
    address private _metahub;

    /**
     * @dev ACL contract.
     */
    IACL private _aclContract;

    /**
     * @dev Modifier to check asset deposit possibility.
     */
    modifier whenAssetDepositAllowed(address operator) {
        if (operator == _metahub && !paused() && !_recovery) _;
        else revert AssetDepositIsNotAllowed();
    }

    /**
     * @dev Modifier to check asset return possibility.
     */
    modifier whenAssetReturnAllowed() {
        if ((_msgSender() == _metahub && !paused()) || _recovery) _;
        else revert AssetReturnIsNotAllowed();
    }

    /**
     * @dev Modifier to make a function callable only when the vault is not in recovery mode.
     */
    modifier whenNotRecovery() {
        if (_recovery) revert VaultIsInRecoveryMode();
        _;
    }

    /**
     * @dev Constructor.
     * @param metahubContract Metahub contract address.
     * @param aclContract ACL contract address.
     */
    constructor(address metahubContract, address aclContract) {
        _recovery = false;

        _metahub = metahubContract;
        _aclContract = IACL(aclContract);
    }

    /**
     * @inheritdoc IAssetVault
     */
    function pause() external onlySupervisor whenNotRecovery {
        _pause();
    }

    /**
     * @inheritdoc IAssetVault
     */
    function unpause() external onlySupervisor whenNotRecovery {
        _unpause();
    }

    /**
     * @inheritdoc IAssetVault
     */
    function switchToRecoveryMode() external onlyAdmin whenNotRecovery {
        _recovery = true;
        emit RecoveryModeActivated(_msgSender());
    }

    /**
     * @inheritdoc IAssetVault
     */
    function withdrawERC20Tokens(
        IERC20 token,
        address to,
        uint256 amount
    ) external override onlyAdmin {
        token.safeTransfer(to, amount);
    }

    /**
     * @inheritdoc IAssetVault
     */
    function metahub() external view returns (address) {
        return _metahub;
    }

    /**
     * @inheritdoc IAssetVault
     */
    function isRecovery() external view returns (bool) {
        return _recovery;
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IAssetVault).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc AccessControlled
     */
    function _acl() internal view override returns (IACL) {
        return _aclContract;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "../IAssetVault.sol";

interface IERC721AssetVault is IAssetVault, IERC721Receiver {
    /**
     * @dev Transfers the asset to the original owner, registered upon deposit.
     * NOTE: The asset is always returns to the owner. There is no way to send the `asset` to an arbitrary address.
     * @param token Token address.
     * @param tokenId Token ID.
     */
    function returnToOwner(address token, uint256 tokenId) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (access/AccessControl.sol)

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
        _checkRole(role);
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
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
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
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Context.sol";

import "./Roles.sol";
import "./IACL.sol";

/**
 * @title Modifier provider for contracts that want to interact with the ACL contract.
 */
abstract contract AccessControlled is Context {
    /**
     * @dev Modifier to make a function callable by the admin account.
     */
    modifier onlyAdmin() {
        _acl().checkRole(Roles.ADMIN, _msgSender());
        _;
    }

    /**
     * @dev Modifier to make a function callable by a supervisor account.
     */
    modifier onlySupervisor() {
        _acl().checkRole(Roles.SUPERVISOR, _msgSender());
        _;
    }

    /**
     * @dev return the IACL address
     */
    function _acl() internal view virtual returns (IACL);
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
// solhint-disable code-complexity
pragma solidity ^0.8.13;

import "../../asset/ERC721/ERC721AssetController.sol";
import "../../accounting/Accounts.sol";
import "../../renting/IRentingManager.sol";
import "../mechanics/availability-period/IAvailabilityPeriodMechanics.sol";
import "../mechanics/rental-period/IRentalPeriodMechanics.sol";
import "../mechanics/asset-rentability/IAssetRentabilityMechanics.sol";
import "../mechanics/rental-fee-premium/IRentalFeePremiumMechanics.sol";
import "../mechanics/renting-hook/IRentingHookMechanics.sol";
import "./IERC721WarperController.sol";
import "./IERC721Warper.sol";

contract ERC721WarperController is IERC721WarperController, ERC721AssetController {
    using Assets for Assets.Asset;

    /**
     * @inheritdoc IWarperController
     * @dev Needs to be called with `delegatecall` from Metahub,
     * otherwise warpers will reject the call.
     */
    function warp(
        Assets.Asset calldata asset,
        address warper,
        address to
    ) external onlyDelegatecall returns (bytes32 warpedCollectionId, Assets.Asset memory warpedAsset) {
        _validateAsset(asset);
        (address original, uint256 tokenId) = _decodeAssetId(asset.id);
        // Make sure the correct warper is used for the asset.
        if (original != IWarper(warper).__original()) revert InvalidAssetForWarper(warper, original);

        // Encode warped asset. The tokenId of the warped asset is identical to the original one,
        // but the address is changed to warper contract.
        warpedAsset = Assets.Asset(_encodeAssetId(warper, tokenId), asset.value);
        warpedCollectionId = _collectionId(warper);

        // If the warped asset has never been rented before, create new instance, otherwise transfer existing one.
        if (rentalStatus(address(this), warper, tokenId) == Rentings.RentalStatus.NONE) {
            IERC721Warper(warper).mint(to, tokenId, new bytes(0));
        } else {
            _transferAsset(warpedAsset, address(this), to, new bytes(0));
        }
    }

    /**
     * @inheritdoc IWarperController
     */
    function executeRentingHooks(
        uint256 rentalId,
        Rentings.Agreement calldata rentalAgreement,
        Accounts.RentalEarnings calldata rentalEarnings
    ) external onlyDelegatecall {
        _validateAsset(rentalAgreement.warpedAsset);
        (address warper, uint256 tokenId) = _decodeAssetId(rentalAgreement.warpedAsset.id);
        if (IWarper(warper).supportsInterface(type(IRentingHookMechanics).interfaceId)) {
            (bool success, string memory errorMessage) = IRentingHookMechanics(warper).__onRent(
                rentalId,
                tokenId,
                rentalAgreement.warpedAsset.value,
                rentalAgreement,
                rentalEarnings
            );
            if (!success) revert IRentingHookMechanics.RentingHookError(errorMessage);
        }
    }

    /**
     * @inheritdoc IWarperController
     */
    function checkCompatibleWarper(address warper) external view {
        if (!isCompatibleWarper(warper)) revert IncompatibleWarperInterface();
    }

    /**
     * @inheritdoc IWarperController
     */
    function validateRentingParams(Assets.Asset calldata asset, Rentings.Params calldata rentingParams) external view {
        _validateAsset(asset);

        // Ensure the warped asset is not rented.
        address warper = rentingParams.warper;
        (, uint256 tokenId) = _decodeAssetId(asset.id);
        if (rentalStatus(IWarper(warper).__metahub(), warper, tokenId) == Rentings.RentalStatus.RENTED) {
            revert AlreadyRented();
        }

        // Analyse warper functionality by checking the supported mechanics.
        bytes4[] memory mechanics = new bytes4[](3);
        mechanics[0] = type(IAvailabilityPeriodMechanics).interfaceId;
        mechanics[1] = type(IRentalPeriodMechanics).interfaceId;
        mechanics[2] = type(IAssetRentabilityMechanics).interfaceId;
        bool[] memory supportedMechanics = IWarper(warper).__supportedInterfaces(mechanics);

        // Handle availability period mechanics.
        if (supportedMechanics[0]) {
            (uint32 start, uint32 end) = IAvailabilityPeriodMechanics(warper).__availabilityPeriodRange();
            if (block.timestamp < start || (block.timestamp + rentingParams.rentalPeriod) > end) {
                revert IAvailabilityPeriodMechanics.WarperIsNotAvailableForRenting(block.timestamp, start, end);
            }
        }

        // Handle rental period mechanics.
        if (supportedMechanics[1]) {
            (uint32 min, uint32 max) = IRentalPeriodMechanics(warper).__rentalPeriodRange();
            if (rentingParams.rentalPeriod < min || rentingParams.rentalPeriod > max) {
                revert IRentalPeriodMechanics.WarperRentalPeriodIsOutOfRange(rentingParams.rentalPeriod, min, max);
            }
        }

        // Handle asset rentability mechanics.
        if (supportedMechanics[2]) {
            (bool isRentable, string memory errorMessage) = IAssetRentabilityMechanics(warper).__isRentableAsset(
                rentingParams.renter,
                tokenId,
                asset.value
            );
            if (!isRentable) revert IAssetRentabilityMechanics.AssetIsNotRentable(errorMessage);
        }
    }

    /**
     * @inheritdoc IWarperController
     */
    function calculatePremiums(
        Assets.Asset calldata asset,
        Rentings.Params calldata rentingParams,
        uint256 universeFee,
        uint256 listerFee
    ) external view virtual returns (uint256 universePremium, uint256 listerPremium) {
        _validateAsset(asset);
        if (IWarper(rentingParams.warper).supportsInterface(type(IRentalFeePremiumMechanics).interfaceId)) {
            (, uint256 tokenId) = _decodeAssetId(asset.id);
            return
                IRentalFeePremiumMechanics(rentingParams.warper).__calculatePremiums(
                    rentingParams.renter,
                    tokenId,
                    asset.value,
                    rentingParams.rentalPeriod,
                    universeFee,
                    listerFee
                );
        }
        return (0, 0);
    }

    /**
     * @inheritdoc IERC721WarperController
     */
    function rentalBalance(
        address metahub,
        address warper,
        address renter
    ) external view returns (uint256) {
        return IRentingManager(metahub).collectionRentedValue(_collectionId(warper), renter);
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AssetController, IERC165)
        returns (bool)
    {
        return interfaceId == type(IERC721WarperController).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IWarperController
     */
    function isCompatibleWarper(address warper) public view returns (bool) {
        return IWarper(warper).supportsInterface(type(IERC721Warper).interfaceId);
    }

    /**
     * @inheritdoc IERC721WarperController
     */
    function rentalStatus(
        address metahub,
        address warper,
        uint256 tokenId
    ) public view returns (Rentings.RentalStatus) {
        return IRentingManager(metahub).assetRentalStatus(_encodeAssetId(warper, tokenId));
    }
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

import "./IRentalPeriodMechanics.sol";

interface IConfigurableRentalPeriodExtension is IRentalPeriodMechanics {
    /**
     * @dev Thrown when the the min rental period is not strictly lesser than max rental period
     */
    error InvalidMinRentalPeriod();

    /**
     * @dev Thrown when the max rental period is not greater or equal than min rental period
     */
    error InvalidMaxRentalPeriod();

    /**
     * @dev Sets warper min rental period.
     * @param minRentalPeriod New min rental period value.
     */
    function __setMinRentalPeriod(uint32 minRentalPeriod) external;

    /**
     * @dev Sets warper max rental period.
     * @param maxRentalPeriod New max rental period value.
     */
    function __setMaxRentalPeriod(uint32 maxRentalPeriod) external;
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore, func-name-mixedcase, ordering
pragma solidity ^0.8.13;

import "../../Warper.sol";
import "./IConfigurableRentalPeriodExtension.sol";

abstract contract ConfigurableRentalPeriodExtension is IConfigurableRentalPeriodExtension, Warper {
    /**
     * @dev Warper rental period.
     * @dev It contains both - the min and max values (uint32) - in a concatenated form.
     */
    bytes32 private constant _RENTAL_PERIOD_SLOT = bytes32(uint256(keccak256("iq.warper.params.rentalPeriod")) - 1);

    uint256 private constant _MAX_PERIOD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000;
    uint256 private constant _MIN_PERIOD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFF;
    uint256 private constant _MAX_PERIOD_BITSHIFT = 0;
    uint256 private constant _MIN_PERIOD_BITSHIFT = 32;

    /**
     * @dev Extension initializer.
     */
    function _ConfigurableRentalPeriodExtension_init() internal onlyInitializingWarper {
        // Store default values.
        _setRentalPeriods(0, type(uint32).max);
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(Warper) returns (bool) {
        return
            interfaceId == type(IConfigurableRentalPeriodExtension).interfaceId ||
            interfaceId == type(IRentalPeriodMechanics).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc IConfigurableRentalPeriodExtension
     */
    function __setMinRentalPeriod(uint32 minRentalPeriod) external virtual onlyWarperAdmin {
        (, uint32 maxRentalPeriod) = _rentalPeriods();
        if (minRentalPeriod > maxRentalPeriod) revert InvalidMinRentalPeriod();

        _setRentalPeriods(minRentalPeriod, maxRentalPeriod);
    }

    /**
     * @inheritdoc IConfigurableRentalPeriodExtension
     */
    function __setMaxRentalPeriod(uint32 maxRentalPeriod) external virtual onlyWarperAdmin {
        (uint32 minRentalPeriod, ) = _rentalPeriods();
        if (minRentalPeriod > maxRentalPeriod) revert InvalidMaxRentalPeriod();

        _setRentalPeriods(minRentalPeriod, maxRentalPeriod);
    }

    /**
     * @inheritdoc IRentalPeriodMechanics
     */
    function __minRentalPeriod() external view virtual returns (uint32) {
        (uint32 minRentalPeriod, ) = _rentalPeriods();
        return minRentalPeriod;
    }

    /**
     * @inheritdoc IRentalPeriodMechanics
     */
    function __maxRentalPeriod() external view virtual override returns (uint32) {
        (, uint32 maxRentalPeriod) = _rentalPeriods();
        return maxRentalPeriod;
    }

    /**
     * @inheritdoc IRentalPeriodMechanics
     */
    function __rentalPeriodRange() external view returns (uint32 minRentalPeriod, uint32 maxRentalPeriod) {
        (minRentalPeriod, maxRentalPeriod) = _rentalPeriods();
    }

    /**
     * @dev Stores warper rental period.
     */
    function _setRentalPeriods(uint32 minRentalPeriod, uint32 maxRentalPeriod) internal {
        uint256 data = (0 & _MAX_PERIOD_MASK) | (uint256(maxRentalPeriod) << _MAX_PERIOD_BITSHIFT);
        data = (data & _MIN_PERIOD_MASK) | (uint256(minRentalPeriod) << _MIN_PERIOD_BITSHIFT);

        StorageSlot.getUint256Slot(_RENTAL_PERIOD_SLOT).value = data;
    }

    /**
     * @dev Returns warper rental periods.
     */
    function _rentalPeriods() internal view returns (uint32 minRentalPeriod, uint32 maxRentalPeriod) {
        uint256 data = StorageSlot.getUint256Slot(_RENTAL_PERIOD_SLOT).value;
        minRentalPeriod = uint32((data & ~_MIN_PERIOD_MASK) >> _MIN_PERIOD_BITSHIFT);
        maxRentalPeriod = uint32((data & ~_MAX_PERIOD_MASK) >> _MAX_PERIOD_BITSHIFT);
    }
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

import "../ERC721Warper.sol";
import "../../IWarperPreset.sol";
import "../../mechanics/availability-period/ConfigurableAvailabilityPeriodExtension.sol";
import "../../mechanics/rental-period/ConfigurableRentalPeriodExtension.sol";

contract ERC721PresetConfigurable is
    IWarperPreset,
    ERC721Warper,
    ConfigurableAvailabilityPeriodExtension,
    ConfigurableRentalPeriodExtension
{
    /**
     * @inheritdoc IWarperPreset
     */
    function __initialize(bytes memory config) public virtual warperInitializer {
        // Decode config
        (address original, address metahub) = abi.decode(config, (address, address));
        _Warper_init(original, metahub);
        _ConfigurableAvailabilityPeriodExtension_init();
        _ConfigurableRentalPeriodExtension_init();
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Warper, ConfigurableAvailabilityPeriodExtension, ConfigurableRentalPeriodExtension, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IWarperPreset).interfaceId ||
            ERC721Warper.supportsInterface(interfaceId) ||
            ConfigurableAvailabilityPeriodExtension.supportsInterface(interfaceId) ||
            ConfigurableRentalPeriodExtension.supportsInterface(interfaceId);
    }

    /**
     * @inheritdoc ERC721Warper
     */
    function _validateOriginal(address original) internal virtual override(ERC721Warper, Warper) {
        return ERC721Warper._validateOriginal(original);
    }
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore, func-name-mixedcase, ordering
pragma solidity ^0.8.13;

import "../../Warper.sol";
import "./IConfigurableAvailabilityPeriodExtension.sol";

abstract contract ConfigurableAvailabilityPeriodExtension is IConfigurableAvailabilityPeriodExtension, Warper {
    /**
     * @dev Warper availability period.
     */
    bytes32 private constant _AVAILABILITY_PERIOD_SLOT =
        bytes32(uint256(keccak256("iq.warper.params.availabilityPeriod")) - 1);

    uint256 private constant _MAX_PERIOD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000;
    uint256 private constant _MIN_PERIOD_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFF;
    uint256 private constant _MAX_PERIOD_BITSHIFT = 0;
    uint256 private constant _MIN_PERIOD_BITSHIFT = 32;

    /**
     * Extension initializer.
     */
    function _ConfigurableAvailabilityPeriodExtension_init() internal onlyInitializingWarper {
        _setAvailabilityPeriods(0, type(uint32).max);
    }

    /**
     * @inheritdoc IConfigurableAvailabilityPeriodExtension
     */
    function __setAvailabilityPeriodStart(uint32 availabilityPeriodStart) external virtual onlyWarperAdmin {
        (, uint32 availabilityPeriodEnd) = _availabilityPeriods();
        if (availabilityPeriodStart >= availabilityPeriodEnd) revert InvalidAvailabilityPeriodStart();

        _setAvailabilityPeriods(availabilityPeriodStart, availabilityPeriodEnd);
    }

    /**
     * @inheritdoc IConfigurableAvailabilityPeriodExtension
     */
    function __setAvailabilityPeriodEnd(uint32 availabilityPeriodEnd) external virtual onlyWarperAdmin {
        (uint32 availabilityPeriodStart, ) = _availabilityPeriods();
        if (availabilityPeriodStart >= availabilityPeriodEnd) revert InvalidAvailabilityPeriodEnd();

        _setAvailabilityPeriods(availabilityPeriodStart, availabilityPeriodEnd);
    }

    /**
     * @inheritdoc IAvailabilityPeriodMechanics
     */
    function __availabilityPeriodStart() external view virtual returns (uint32) {
        (uint32 availabilityPeriodStart, ) = _availabilityPeriods();
        return availabilityPeriodStart;
    }

    /**
     * @inheritdoc IAvailabilityPeriodMechanics
     */
    function __availabilityPeriodEnd() external view virtual returns (uint32) {
        (, uint32 availabilityPeriodEnd) = _availabilityPeriods();
        return availabilityPeriodEnd;
    }

    /**
     * @inheritdoc IAvailabilityPeriodMechanics
     */
    function __availabilityPeriodRange()
        external
        view
        virtual
        returns (uint32 availabilityPeriodStart, uint32 availabilityPeriodEnd)
    {
        (availabilityPeriodStart, availabilityPeriodEnd) = _availabilityPeriods();
    }

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(Warper) returns (bool) {
        return
            interfaceId == type(IConfigurableAvailabilityPeriodExtension).interfaceId ||
            interfaceId == type(IAvailabilityPeriodMechanics).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Stores warper availability period.
     */
    function _setAvailabilityPeriods(uint32 availabilityPeriodStart, uint32 availabilityPeriodEnd) internal {
        uint256 data = (0 & _MAX_PERIOD_MASK) | (uint256(availabilityPeriodEnd) << _MAX_PERIOD_BITSHIFT);
        data = (data & _MIN_PERIOD_MASK) | (uint256(availabilityPeriodStart) << _MIN_PERIOD_BITSHIFT);

        StorageSlot.getUint256Slot(_AVAILABILITY_PERIOD_SLOT).value = data;
    }

    /**
     * @dev Returns warper availability period.
     */
    function _availabilityPeriods()
        internal
        view
        returns (uint32 availabilityPeriodStart, uint32 availabilityPeriodEnd)
    {
        uint256 data = StorageSlot.getUint256Slot(_AVAILABILITY_PERIOD_SLOT).value;
        availabilityPeriodStart = uint32((data & ~_MIN_PERIOD_MASK) >> _MIN_PERIOD_BITSHIFT);
        availabilityPeriodEnd = uint32((data & ~_MAX_PERIOD_MASK) >> _MAX_PERIOD_BITSHIFT);
    }
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity ^0.8.13;

import "./IAvailabilityPeriodMechanics.sol";

interface IConfigurableAvailabilityPeriodExtension is IAvailabilityPeriodMechanics {
    /**
     * @dev Thrown when the availability period start time is not strictly lesser than the end time
     */
    error InvalidAvailabilityPeriodStart();

    /**
     * @dev Thrown when the availability period end time is not greater or equal than the start time
     */
    error InvalidAvailabilityPeriodEnd();

    /**
     * @dev Sets warper availability period starting time.
     * @param availabilityPeriodStart Unix timestamp after which the warper is rentable.
     */
    function __setAvailabilityPeriodStart(uint32 availabilityPeriodStart) external;

    /**
     * @dev Sets warper availability period ending time.
     * @param availabilityPeriodEnd Unix timestamp after which the warper is NOT rentable.
     */
    function __setAvailabilityPeriodEnd(uint32 availabilityPeriodEnd) external;
}

// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../warper/ERC721/presets/ERC721PresetConfigurable.sol";

contract WarperExtendingPreset is ERC721PresetConfigurable, UUPSUpgradeable, OwnableUpgradeable {
    uint8 public initValue;

    function __initialize(bytes calldata config) public virtual override initializer warperInitializer {
        super.__initialize(config);
        __Ownable_init();

        (, , uint8 _initValue) = abi.decode(config, (address, address, uint8));
        initValue = _initValue;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {
        // solhint-disable-previous-line no-empty-blocks
    }

    // NOTE: override because we inherit both - OZ Upgradeable and non upgradeable context
    function _msgData() internal view virtual override(Context, ContextUpgradeable) returns (bytes calldata) {
        return ContextUpgradeable._msgData();
    }

    // NOTE: override because we inherit both - OZ Upgradeable and non upgradeable context
    function _msgSender() internal view virtual override(Context, ContextUpgradeable) returns (address) {
        return ContextUpgradeable._msgSender();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../acl/AccessControlledUpgradeable.sol";
import "./IUniverseRegistry.sol";
import "./UniverseToken.sol";
import "./UniverseRegistryStorage.sol";

/**
 * @title Universe Registry contract.
 */
contract UniverseRegistry is IUniverseRegistry, UUPSUpgradeable, AccessControlledUpgradeable, UniverseRegistryStorage {
    /**
     * @dev Modifier to make a function callable only by the universe owner.
     */
    modifier onlyUniverseOwner(uint256 universeId) {
        _checkUniverseOwner(universeId, _msgSender());
        _;
    }

    /**
     * @dev Modifier to check if the universe name is valid.
     */
    modifier onlyValidUniverseName(string memory universeNameToCheck) {
        if (bytes(universeNameToCheck).length == 0) revert EmptyUniverseName();
        _;
    }

    /**
     * @dev Modifier to check that the universe has been registered.
     */
    modifier onlyRegisteredUniverse(uint256 universeId) {
        _checkUniverseRegistered(universeId);
        _;
    }

    /**
     * @dev Constructor that gets called for the implementation contract.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() initializer {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev UniverseRegistry initializer.
     * @param acl Address of the ACL contract.
     */
    function initialize(address acl) external initializer {
        __UUPSUpgradeable_init();

        _aclContract = IACL(acl);

        _universeToken = new UniverseToken(this);
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function setUniverseTokenBaseURI(string calldata baseURI) external onlySupervisor {
        _baseURI = baseURI;
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function createUniverse(UniverseParams calldata params)
        external
        onlyValidUniverseName(params.name)
        returns (uint256)
    {
        uint256 universeId = _universeToken.mint(_msgSender());
        _universes[universeId] = Universe({name: params.name, rentalFeePercent: params.rentalFeePercent});

        emit UniverseCreated(universeId, params.name);

        return universeId;
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function setUniverseName(uint256 universeId, string memory name)
        external
        onlyRegisteredUniverse(universeId)
        onlyValidUniverseName(name)
        onlyUniverseOwner(universeId)
    {
        _universes[universeId].name = name;

        emit UniverseNameChanged(universeId, name);
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function setUniverseRentalFeePercent(uint256 universeId, uint16 rentalFeePercent)
        external
        onlyRegisteredUniverse(universeId)
        onlyUniverseOwner(universeId)
    {
        _universes[universeId].rentalFeePercent = rentalFeePercent;

        emit UniverseRentalFeeChanged(universeId, rentalFeePercent);
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function universe(uint256 universeId)
        external
        view
        onlyRegisteredUniverse(universeId)
        returns (string memory name, uint16 rentalFeePercent)
    {
        name = _universes[universeId].name;
        rentalFeePercent = _universes[universeId].rentalFeePercent;
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function universeToken() external view returns (address) {
        return address(_universeToken);
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function universeTokenBaseURI() external view returns (string memory) {
        return _baseURI;
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function universeRentalFeePercent(uint256 universeId)
        external
        view
        onlyRegisteredUniverse(universeId)
        returns (uint16 rentalFeePercent)
    {
        return _universes[universeId].rentalFeePercent;
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function universeName(uint256 universeId) external view onlyRegisteredUniverse(universeId) returns (string memory) {
        return _universes[universeId].name;
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function checkUniverseOwner(uint256 universeId, address account) external view onlyRegisteredUniverse(universeId) {
        _checkUniverseOwner(universeId, account);
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function universeOwner(uint256 universeId) external view onlyRegisteredUniverse(universeId) returns (address) {
        return _universeToken.ownerOf(universeId);
    }

    /**
     * @inheritdoc IUniverseRegistry
     */
    function isUniverseOwner(uint256 universeId, address account)
        external
        view
        onlyRegisteredUniverse(universeId)
        returns (bool)
    {
        return _isUniverseOwner(universeId, account);
    }

    /**
     * @inheritdoc UUPSUpgradeable
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @inheritdoc AccessControlledUpgradeable
     */
    function _acl() internal view override returns (IACL) {
        return _aclContract;
    }

    /**
     * @dev Revert if the passed account is not the owner of the universe.
     */
    function _checkUniverseOwner(uint256 universeId, address account) internal view {
        if (!_isUniverseOwner(universeId, account)) revert AccountIsNotUniverseOwner(account);
    }

    /**
     * @dev Revert if the universe has been registered properly.
     */
    function _checkUniverseRegistered(uint256 universeId) internal view {
        if (!_isValidUniverseName(universeId)) revert QueryForNonexistentUniverse(universeId);
    }

    /**
     * @dev Return `true` if the universe name is valid.
     */
    function _isValidUniverseName(uint256 universeId) internal view returns (bool) {
        return bytes(_universes[universeId].name).length != 0;
    }

    /**
     * @dev Return `true` if the account is the owner of the universe.
     */
    function _isUniverseOwner(uint256 universeId, address account) internal view returns (bool) {
        return _universeToken.ownerOf(universeId) == account;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../acl/AccessControlledUpgradeable.sol";
import "./IMetahub.sol";
import "./MetahubStorage.sol";

contract Metahub is IMetahub, Initializable, UUPSUpgradeable, AccessControlledUpgradeable, MetahubStorage {
    using Address for address;
    using Accounts for Accounts.Account;
    using Accounts for Accounts.Registry;
    using Assets for Assets.Asset;
    using Assets for Assets.Registry;
    using Listings for Listings.Listing;
    using Listings for Listings.Registry;
    using Rentings for Rentings.Registry;
    using Warpers for Warpers.Warper;
    using Warpers for Warpers.Registry;

    /**
     * @dev Metahub initialization params.
     * @param warperManager Warper manager contract address.
     * @param listingStrategyRegistry Listing strategy registry contract address.
     * @param universeRegistry Universe registry contract address.
     * @param assetClassRegistry Asset class registry contract address.
     * @param acl Protocol access control contract address.
     * @param baseToken Protocol base token (ERC20) address.
     * @param rentalFeePercent Default protocol rental fee percentage.
     */
    struct MetahubInitParams {
        IWarperManager warperManager;
        IListingStrategyRegistry listingStrategyRegistry;
        IUniverseRegistry universeRegistry;
        IAssetClassRegistry assetClassRegistry;
        IACL acl;
        IERC20Upgradeable baseToken;
        uint16 rentalFeePercent;
    }

    /**
     * @dev Modifier to make a function callable only by the universe owner.
     */
    modifier onlyUniverseOwner(uint256 universeId) {
        _universeRegistry.checkUniverseOwner(universeId, _msgSender());
        _;
    }

    /**
     * @dev Modifier to make a function callable only by the WarperManager contract.
     */
    modifier onlyWarperManager() {
        if (_msgSender() != address(_warperManager)) revert CallerIsNotWarperManager();
        _;
    }

    /**
     * @dev Modifier to make a function callable only by the asset lister (original owner).
     */
    modifier onlyLister(uint256 listingId) {
        if (_msgSender() != _listingRegistry.listings[listingId].lister) revert CallerIsNotAssetLister();
        _;
    }

    /**
     * @dev Modifier to make sure the function is called for the active listing.
     */
    modifier listed(uint256 listingId) {
        _listingRegistry.checkListed(listingId);
        _;
    }

    /**
     * @dev Modifier to make sure the function is called for a listing that has been registered.
     */
    modifier listingExists(uint256 listingId) {
        _listingRegistry.checkRegisteredListing(listingId);
        _;
    }

    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() initializer {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Metahub initializer.
     * @param params Initialization params.
     */
    function initialize(MetahubInitParams calldata params) external initializer {
        __UUPSUpgradeable_init();

        _aclContract = params.acl;
        _protocolConfig = Protocol.Config({baseToken: params.baseToken, rentalFeePercent: params.rentalFeePercent});

        _warperManager = params.warperManager;
        _universeRegistry = params.universeRegistry;
        _assetRegistry.classRegistry = params.assetClassRegistry;
        _listingRegistry.strategyRegistry = params.listingStrategyRegistry;
    }

    /**
     * @inheritdoc IProtocolConfigManager
     */
    function setProtocolRentalFeePercent(uint16 rentalFeePercent) external onlyAdmin {
        _protocolConfig.rentalFeePercent = rentalFeePercent;
        emit ProtocolRentalFeeChanged(rentalFeePercent);
    }

    /**
     * @inheritdoc IListingManager
     */
    function listAsset(
        Assets.Asset calldata asset,
        Listings.Params calldata params,
        uint32 maxLockPeriod,
        bool immediatePayout
    ) external returns (uint256 listingId, uint256 listingGroupId) {
        // Check that asset is supported.
        _warperManager.checkSupportedAsset(asset.token());

        // Check that listing strategy is supported.
        _listingRegistry.checkSupportedListingStrategy(params.strategy);

        // Register listing.
        Listings.Listing memory listing = Listings.Listing({
            asset: asset,
            params: params,
            lister: _msgSender(),
            maxLockPeriod: maxLockPeriod,
            lockedTill: 0,
            immediatePayout: immediatePayout,
            delisted: false,
            paused: false,
            groupId: 0
        });

        (listingId, listingGroupId) = _listingRegistry.register(listing);

        // Transfer asset from lister account to the vault.
        _assetRegistry.transferAssetToVault(asset, _msgSender());

        emit AssetListed(
            listingId,
            listingGroupId,
            listing.lister,
            listing.asset,
            listing.params,
            listing.maxLockPeriod
        );
    }

    /**
     * @inheritdoc IAssetManager
     */
    function registerAsset(bytes4 assetClass, address original) external onlyWarperManager {
        // Register the original asset if it is seen for the first time.
        if (!_assetRegistry.isRegisteredAsset(original)) {
            _assetRegistry.registerAsset(assetClass, original);
        }
    }

    /**
     * @inheritdoc IListingManager
     */
    function delistAsset(uint256 listingId) external listed(listingId) onlyLister(listingId) {
        Listings.Listing storage listing = _listingRegistry.listings[listingId];
        listing.delisted = true;
        emit AssetDelisted(listingId, listing.lister, listing.lockedTill);
    }

    /**
     * @inheritdoc IListingManager
     */
    function withdrawAsset(uint256 listingId) external onlyLister(listingId) {
        Listings.Listing memory listing = _listingRegistry.listings[listingId];
        // Check whether the asset can be returned to the owner.
        if (uint32(block.timestamp) < listing.lockedTill) revert AssetIsLocked();

        // Delete listing record.
        _listingRegistry.remove(listingId);

        // Transfer asset from the vault to the original owner.
        _assetRegistry.returnAssetFromVault(listing.asset);

        emit AssetWithdrawn(listingId, listing.lister, listing.asset);
    }

    /**
     * @inheritdoc IListingManager
     */
    function pauseListing(uint256 listingId) external listed(listingId) onlyLister(listingId) {
        _listingRegistry.listings[listingId].pause();
        emit ListingPaused(listingId);
    }

    /**
     * @inheritdoc IListingManager
     */
    function unpauseListing(uint256 listingId) external listed(listingId) onlyLister(listingId) {
        _listingRegistry.listings[listingId].unpause();
        emit ListingUnpaused(listingId);
    }

    /**
     * @inheritdoc IPaymentManager
     */
    function withdrawProtocolFunds(
        address token,
        uint256 amount,
        address to
    ) external onlyAdmin {
        _accountRegistry.protocol.withdraw(token, amount, to);
    }

    /**
     * @inheritdoc IPaymentManager
     */
    function withdrawUniverseFunds(
        uint256 universeId,
        address token,
        uint256 amount,
        address to
    ) external onlyUniverseOwner(universeId) {
        _accountRegistry.universes[universeId].withdraw(token, amount, to);
    }

    /**
     * @inheritdoc IPaymentManager
     */
    function withdrawFunds(
        address token,
        uint256 amount,
        address to
    ) external {
        _accountRegistry.users[_msgSender()].withdraw(token, amount, to);
    }

    /**
     * @inheritdoc IRentingManager
     */
    function rent(Rentings.Params calldata rentingParams, uint256 maxPaymentAmount) external returns (uint256) {
        // Validate renting parameters.
        Rentings.validateRentingParams(rentingParams, _protocolConfig, _listingRegistry, _warperManager);

        // Warp the asset and deliver to to the renter.
        (bytes32 warpedCollectionId, Assets.Asset memory warpedAsset) = _warpListedAsset(
            rentingParams.listingId,
            rentingParams.warper,
            rentingParams.renter
        );

        // Register new rental agreement.
        uint32 blockTimestamp = uint32(block.timestamp);
        Listings.Params storage listingParams = _listingRegistry.listings[rentingParams.listingId].params;
        Rentings.Agreement memory rentalAgreement = Rentings.Agreement({
            warpedAsset: warpedAsset,
            collectionId: warpedCollectionId,
            listingId: rentingParams.listingId,
            renter: rentingParams.renter,
            startTime: blockTimestamp,
            endTime: blockTimestamp + rentingParams.rentalPeriod,
            listingParams: listingParams
        });

        // Register new rental agreement.
        uint256 rentalId = _rentingRegistry.register(rentalAgreement);

        // Update listing lock time.
        _listingRegistry.listings[rentingParams.listingId].addLock(rentalAgreement.endTime);

        // Clean up x2 expired rental agreements.
        _rentingRegistry.deleteExpiredUserRentalAgreements(rentingParams.renter, warpedCollectionId, 2);

        // Handle rental payments.
        Accounts.RentalEarnings memory rentalEarnings = _handleRentalPayment(
            rentingParams,
            _msgSender(),
            maxPaymentAmount
        );

        // Execute rental hook.
        _executeWarperRentalHook(rentingParams.warper, rentalId, rentalAgreement, rentalEarnings);

        emit AssetRented(
            rentalId,
            rentalAgreement.renter,
            rentalAgreement.listingId,
            rentalAgreement.warpedAsset,
            rentalAgreement.startTime,
            rentalAgreement.endTime
        );

        return rentalId;
    }

    /**
     * @inheritdoc IAssetManager
     */
    function assetClassController(bytes4 assetClass) external view returns (address) {
        return _assetRegistry.assetClassController(assetClass);
    }

    /**
     * @inheritdoc IAssetManager
     */
    function supportedAssetCount() external view returns (uint256) {
        return _assetRegistry.assetCount();
    }

    /**
     * @inheritdoc IAssetManager
     */
    function supportedAssets(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory, Assets.AssetConfig[] memory)
    {
        return _assetRegistry.supportedAssets(offset, limit);
    }

    /**
     * @inheritdoc IAssetManager
     */
    function isWarperAdmin(address warper, address account) external view returns (bool) {
        return _warperManager.isWarperAdmin(warper, account);
    }

    /**
     * @inheritdoc IRentingManager
     */
    function estimateRent(Rentings.Params calldata rentingParams) external view returns (Rentings.RentalFees memory) {
        Rentings.validateRentingParams(rentingParams, _protocolConfig, _listingRegistry, _warperManager);
        return
            Rentings.calculateRentalFees(
                rentingParams,
                _protocolConfig,
                _listingRegistry,
                _warperManager,
                _universeRegistry
            );
    }

    /**
     * @inheritdoc IProtocolConfigManager
     */
    function protocolRentalFeePercent() external view returns (uint16) {
        return _protocolConfig.rentalFeePercent;
    }

    /**
     * @inheritdoc IProtocolConfigManager
     */
    function baseToken() external view returns (address) {
        return address(_protocolConfig.baseToken);
    }

    /**
     * @inheritdoc IProtocolConfigManager
     */
    function warperController(address warper) external view returns (address) {
        return _warperManager.warperController(warper);
    }

    /**
     * @inheritdoc IRentingManager
     */
    function rentalAgreementInfo(uint256 rentalId) external view returns (Rentings.Agreement memory) {
        return _rentingRegistry.agreements[rentalId];
    }

    /**
     * @inheritdoc IRentingManager
     */
    function userRentalCount(address renter) external view returns (uint256) {
        return _rentingRegistry.userRentalCount(renter);
    }

    /**
     * @inheritdoc IRentingManager
     */
    function userRentalAgreements(
        address renter,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Rentings.Agreement[] memory) {
        return _rentingRegistry.userRentalAgreements(renter, offset, limit);
    }

    /**
     * @inheritdoc IRentingManager
     */
    function collectionRentedValue(bytes32 warpedCollectionId, address renter) external view returns (uint256) {
        return _rentingRegistry.collectionRentedValue(renter, warpedCollectionId);
    }

    /**
     * @inheritdoc IRentingManager
     */
    function assetRentalStatus(Assets.AssetId calldata warpedAssetId) external view returns (Rentings.RentalStatus) {
        return _rentingRegistry.assetRentalStatus(warpedAssetId);
    }

    /**
     * @inheritdoc IListingManager
     */
    function listingInfo(uint256 listingId) external view listingExists(listingId) returns (Listings.Listing memory) {
        return _listingRegistry.listings[listingId];
    }

    /**
     * @inheritdoc IListingManager
     */
    function listingCount() external view returns (uint256) {
        return _listingRegistry.listingCount();
    }

    /**
     * @inheritdoc IListingManager
     */
    function listings(uint256 offset, uint256 limit)
        external
        view
        returns (uint256[] memory, Listings.Listing[] memory)
    {
        return _listingRegistry.allListings(offset, limit);
    }

    /**
     * @inheritdoc IListingManager
     */
    function userListingCount(address lister) external view returns (uint256) {
        return _listingRegistry.userListingCount(lister);
    }

    /**
     * @inheritdoc IListingManager
     */
    function userListings(
        address lister,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listings.Listing[] memory) {
        return _listingRegistry.userListings(lister, offset, limit);
    }

    /**
     * @inheritdoc IListingManager
     */
    function assetListingCount(address original) external view returns (uint256) {
        return _listingRegistry.assetListingCount(original);
    }

    /**
     * @inheritdoc IListingManager
     */
    function assetListings(
        address original,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256[] memory, Listings.Listing[] memory) {
        return _listingRegistry.assetListings(original, offset, limit);
    }

    /**
     * @inheritdoc IListingManager
     */
    function listingController(bytes4 strategyId) external view returns (address) {
        return _listingRegistry.strategyRegistry.listingController(strategyId);
    }

    /**
     * @inheritdoc IPaymentManager
     */
    function protocolBalance(address token) external view returns (uint256) {
        return _accountRegistry.protocol.balance(token);
    }

    /**
     * @inheritdoc IPaymentManager
     */
    function protocolBalances() external view returns (Accounts.Balance[] memory) {
        return _accountRegistry.protocol.balances();
    }

    /**
     * @inheritdoc IPaymentManager
     */
    function universeBalance(uint256 universeId, address token) external view returns (uint256) {
        return _accountRegistry.universes[universeId].balance(token);
    }

    /**
     * @inheritdoc IPaymentManager
     */
    function universeBalances(uint256 universeId) external view returns (Accounts.Balance[] memory) {
        return _accountRegistry.universes[universeId].balances();
    }

    /**
     * @inheritdoc IPaymentManager
     */
    function balance(address account, address token) external view returns (uint256) {
        return _accountRegistry.users[account].balance(token);
    }

    /**
     * @inheritdoc IPaymentManager
     */
    function balances(address account) external view returns (Accounts.Balance[] memory) {
        return _accountRegistry.users[account].balances();
    }

    /**
     * @inheritdoc UUPSUpgradeable
     * @dev Checks whether the caller is authorized to upgrade the Metahub implementation.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Finds the listed asset and warps it, using corresponding warper controller.
     * @param listingId Listing ID.
     * @param warper Warper address.
     * @param renter Renter address.
     * @return collectionId Warped collection ID.
     * @return warpedAsset Warped asset structure.
     */
    function _warpListedAsset(
        uint256 listingId,
        address warper,
        address renter
    ) internal returns (bytes32 collectionId, Assets.Asset memory warpedAsset) {
        Assets.Asset memory asset = _listingRegistry.listings[listingId].asset;
        address controller = _warperManager.warperController(warper);
        (collectionId, warpedAsset) = abi.decode(
            controller.functionDelegateCall(
                abi.encodeWithSelector(IWarperController.warp.selector, asset, warper, renter)
            ),
            (bytes32, Assets.Asset)
        );
    }

    /**
     * @dev Handles all rental payments.
     */
    function _handleRentalPayment(
        Rentings.Params calldata rentingParams,
        address payer,
        uint256 maxPaymentAmount
    ) internal returns (Accounts.RentalEarnings memory rentalEarnings) {
        // Get precise estimation.
        Rentings.RentalFees memory fees = Rentings.calculateRentalFees(
            rentingParams,
            _protocolConfig,
            _listingRegistry,
            _warperManager,
            _universeRegistry
        );

        rentalEarnings = _accountRegistry.handleRentalPayment(
            rentingParams,
            fees,
            payer,
            maxPaymentAmount,
            _warperManager,
            _listingRegistry
        );

        // Emit events
        for (uint256 i = 0; i < rentalEarnings.userEarnings.length; i++) {
            Accounts.UserEarning memory userEarning = rentalEarnings.userEarnings[i];
            emit UserEarned(userEarning.account, userEarning.earningType, userEarning.token, userEarning.value);
        }

        emit UniverseEarned(
            rentalEarnings.universeId,
            rentalEarnings.universeEarningToken,
            rentalEarnings.universeEarningValue
        );
        emit ProtocolEarned(rentalEarnings.protocolEarningToken, rentalEarnings.protocolEarningValue);
    }

    /**
     * @dev Executes warper rental hook using the corresponding controller.
     * @param warper Warper address.
     * @param rentalId Rental Agreement ID.
     * @param rentalAgreement Newly registered rental agreement details.
     * @param rentalEarnings The rental earnings breakdown.
     */
    function _executeWarperRentalHook(
        address warper,
        uint256 rentalId,
        Rentings.Agreement memory rentalAgreement,
        Accounts.RentalEarnings memory rentalEarnings
    ) internal {
        address controller = _warperManager.warperController(warper);

        controller.functionDelegateCall(
            abi.encodeWithSelector(
                IWarperController.executeRentingHooks.selector,
                rentalId,
                rentalAgreement,
                rentalEarnings
            )
        );
    }

    /**
     * @inheritdoc AccessControlledUpgradeable
     */
    function _acl() internal view override returns (IACL) {
        return _aclContract;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../metahub/Metahub.sol";

contract MetahubV2Mock is Metahub {
    function version() external pure returns (string memory) {
        return "V2";
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";

import "../acl/AccessControlledUpgradeable.sol";
import "./AssetClassRegistryStorage.sol";

contract AssetClassRegistry is
    IAssetClassRegistry,
    UUPSUpgradeable,
    AccessControlledUpgradeable,
    AssetClassRegistryStorage
{
    using ERC165CheckerUpgradeable for address;

    /**
     * @dev Modifier to make a function callable only for the registered asset class.
     */
    modifier onlyRegisteredAssetClass(bytes4 assetClass) {
        checkRegisteredAssetClass(assetClass);
        _;
    }

    /**
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() initializer {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev AssetClassRegistry initializer.
     * @param acl ACL contract address.
     */
    function initialize(address acl) external initializer {
        __UUPSUpgradeable_init();
        _aclContract = IACL(acl);
    }

    /**
     * @inheritdoc IAssetClassRegistry
     */
    function registerAssetClass(bytes4 assetClass, ClassConfig calldata config) external onlyAdmin {
        _checkValidAssetController(assetClass, config.controller);
        _checkValidAssetVault(assetClass, config.vault);

        // Check if not already registered.
        if (isRegisteredAssetClass(assetClass)) revert AssetClassIsAlreadyRegistered(assetClass);

        _classes[assetClass] = config;
        emit AssetClassRegistered(assetClass, config.controller, config.vault);
    }

    /**
     * @inheritdoc IAssetClassRegistry
     */
    function setAssetClassVault(bytes4 assetClass, address vault)
        external
        onlyAdmin
        onlyRegisteredAssetClass(assetClass)
    {
        _checkValidAssetVault(assetClass, vault);
        _classes[assetClass].vault = vault;
        emit AssetClassVaultChanged(assetClass, vault);
    }

    /**
     * @inheritdoc IAssetClassRegistry
     */
    function setAssetClassController(bytes4 assetClass, address controller)
        external
        onlyAdmin
        onlyRegisteredAssetClass(assetClass)
    {
        _checkValidAssetController(assetClass, controller);
        _classes[assetClass].controller = controller;
        emit AssetClassControllerChanged(assetClass, controller);
    }

    /**
     * @inheritdoc IAssetClassRegistry
     */
    function assetClassConfig(bytes4 assetClass)
        external
        view
        onlyRegisteredAssetClass(assetClass)
        returns (ClassConfig memory)
    {
        return _classes[assetClass];
    }

    /**
     * @inheritdoc IAssetClassRegistry
     */
    function isRegisteredAssetClass(bytes4 assetClass) public view returns (bool) {
        // The registered asset must have controller.
        return address(_classes[assetClass].controller) != address(0);
    }

    /**
     * @inheritdoc IAssetClassRegistry
     */
    function checkRegisteredAssetClass(bytes4 assetClass) public view {
        if (!isRegisteredAssetClass(assetClass)) revert UnregisteredAssetClass(assetClass);
    }

    /**
     * @inheritdoc UUPSUpgradeable
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyAdmin {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Reverts if provided address is not a valid asset controller address.
     * @param assetClass Asset class ID.
     * @param controller Asset controller address.
     */
    function _checkValidAssetController(bytes4 assetClass, address controller) internal view {
        if (!controller.supportsInterface(type(IAssetController).interfaceId)) revert InvalidAssetControllerInterface();
        bytes4 contractAssetClass = IAssetController(controller).assetClass();
        if (contractAssetClass != assetClass) revert AssetClassMismatch(contractAssetClass, assetClass);
    }

    /**
     * @dev Reverts if provided address is not a valid asset vault address.
     * @param assetClass Asset class ID.
     * @param vault Asset vault address.
     */
    function _checkValidAssetVault(bytes4 assetClass, address vault) internal view {
        if (!vault.supportsInterface(type(IAssetVault).interfaceId)) revert InvalidAssetVaultInterface();
        bytes4 contractAssetClass = IAssetVault(vault).assetClass();
        if (contractAssetClass != assetClass) revert AssetClassMismatch(contractAssetClass, assetClass);
    }

    /**
     * @inheritdoc AccessControlledUpgradeable
     */
    function _acl() internal view override returns (IACL) {
        return _aclContract;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../acl/IACL.sol";
import "./IAssetClassRegistry.sol";

abstract contract AssetClassRegistryStorage {
    /**
     * @dev ACL contract.
     */
    IACL internal _aclContract;

    /**
     * @dev Mapping from asset class ID to the asset class configuration.
     */
    mapping(bytes4 => IAssetClassRegistry.ClassConfig) internal _classes;
}

// SPDX-License-Identifier: MIT
// solhint-disable-next-line
// Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/b0cf6fbb7a70f31527f36579ad644e1cf12fdf4e/contracts/mocks/ERC721ReceiverMock.sol

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";

contract ERC721ReceiverMock is IERC721Receiver {
    enum Error {
        NONE,
        REVERT_WITH_MESSAGE,
        REVERT_WITHOUT_MESSAGE,
        PANIC
    }

    bytes4 private immutable _retval;
    Error private immutable _error;

    event Received(address operator, address from, uint256 tokenId, bytes data);

    constructor(bytes4 retval, Error error) {
        _retval = retval;
        _error = error;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public override returns (bytes4) {
        if (_error == Error.REVERT_WITH_MESSAGE) {
            revert("ERC721ReceiverMock: reverting");
        } else if (_error == Error.REVERT_WITHOUT_MESSAGE) {
            revert();
        } else if (_error == Error.PANIC) {
            uint256 a = uint256(0) / uint256(0);
            a;
        }
        emit Received(operator, from, tokenId, data); // NOTE: The original version has `gasLeft()` call here as well
        return _retval;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721Mock is ERC721 {
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/interfaces/IERC721.sol";

import "../warper/ERC721/ERC721WarperController.sol";

contract ERC721WarperControllerMock is ERC721WarperController {
    uint256 internal _universePremium;
    uint256 internal _listerPremium;

    function setPremiums(uint256 universePremium, uint256 listerPremium) external {
        _universePremium = universePremium;
        _listerPremium = listerPremium;
    }

    function calculatePremiums(
        Assets.Asset calldata,
        Rentings.Params calldata,
        uint256,
        uint256
    ) external view override returns (uint256, uint256) {
        return (_universePremium, _listerPremium);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

import "./IACL.sol";
import "./AccessControlledUpgradeable.sol";
import "./Roles.sol";

/**
 * @title Access Control List contract
 */
contract ACL is IACL, AccessControlEnumerableUpgradeable, AccessControlledUpgradeable, UUPSUpgradeable {
    /**
     * @dev Constructor that gets called for the implementation contract.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() initializer {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev ACL initializer.
     */
    function initialize() external initializer {
        __AccessControlEnumerable_init();
        __UUPSUpgradeable_init();

        if (Roles.ADMIN != DEFAULT_ADMIN_ROLE) revert RolesContractIncorrectlyConfigured();

        _grantRole(Roles.ADMIN, msg.sender);
        _grantRole(Roles.SUPERVISOR, msg.sender);
    }

    /**
     * @inheritdoc IACL
     */
    function checkRole(bytes32 role, address account) external view {
        _checkRole(role, account);
    }

    /**
     * @inheritdoc IACL
     */
    function adminRole() external pure override returns (bytes32) {
        return Roles.ADMIN;
    }

    /**
     * @inheritdoc IACL
     */
    function supervisorRole() external pure override returns (bytes32) {
        return Roles.SUPERVISOR;
    }

    /**
     * @inheritdoc UUPSUpgradeable
     */
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyAdmin {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @inheritdoc AccessControlEnumerableUpgradeable
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        if (Roles.ADMIN == role && getRoleMemberCount(role) == 1) revert CannotRemoveLastAdmin();

        super._revokeRole(role, account);
    }

    /**
     * @inheritdoc AccessControlledUpgradeable
     */
    function _acl() internal view virtual override returns (IACL) {
        return IACL(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerableUpgradeable.sol";
import "./AccessControlUpgradeable.sol";
import "../utils/structs/EnumerableSetUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal onlyInitializing {
    }

    function __AccessControlEnumerable_init_unchained() internal onlyInitializing {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    uint8 internal _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_,
        uint256 totalSupply
    ) ERC20(name, symbol) {
        _decimals = decimals_;
        _mint(msg.sender, totalSupply);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @notice An NFT contract used for internal testing purposes.
 */
contract ERC721InternalTest is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function mint(string memory newTokenURI) public {
        _mint(msg.sender, _tokenIdTracker.current());
        _tokenURIs[_tokenIdTracker.current()] = newTokenURI;
        _tokenIdTracker.increment();
    }

    function setTokenURI(uint256 tokenId, string memory newTokenURI) public {
        _tokenURIs[tokenId] = newTokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return _tokenURIs[tokenId];
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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract ERC721AssetVaultMock is ERC721Holder {
    // solhint-disable-previous-line no-empty-blocks
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;

import "../Proxy.sol";
import "./ERC1967Upgrade.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

// Importing `ERC1967Proxy` so we can access it from our deploy scripts
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";