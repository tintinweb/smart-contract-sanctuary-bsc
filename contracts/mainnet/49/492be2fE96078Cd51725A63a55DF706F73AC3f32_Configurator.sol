// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IVestingWallet.sol";
import "./RecoverableFunds.sol";
import "./lib/Stages.sol";
import "./lib/Schedules.sol";
import "./interfaces/IDividendManager.sol";
import "./interfaces/IFeeManager.sol";
import "./interfaces/ICarboToken.sol";
import "./interfaces/ICrowdSale.sol";
import "./interfaces/IOwnable.sol";
import "./interfaces/IWithCallback.sol";

contract Configurator is RecoverableFunds {

    struct Amounts {
        uint256 owner;
        uint256 sale;
        uint256 team;
        uint256 marketingLocked;
        uint256 marketingUnlocked;
        uint256 reserve;
        uint256 liquidity;
        uint256 airdrop;
    }

    struct Addresses {
        address owner;
        address payable fundraising;
        address team;
        address marketing;
        address reserve;
        address liquidity;
        address airdrop;
        address treasury;
        address buyback;
    }

    ICarboToken token;
    IVestingWallet wallet;
    ICrowdSale sale;
    IDividendManager divs;
    IFeeManager fees;

    function init(address _token, address _sale, address _wallet, address _busd, address _pair, address _divs, address _fees) public onlyOwner {

        Schedules.Schedule[4] memory schedules;

        // Unlocked on start
        schedules[0].start =      1648818000;         // April 1 2022 13:00:00 UTC
        schedules[0].duration =   0;
        schedules[0].interval =   0;
        // Public sale
        schedules[1].start =      1648818000;         // April 1 2022 13:00:00 UTC
        schedules[1].duration =   0;
        schedules[1].interval =   0;
        // Team
        schedules[2].start =      1646830800;         // April 1 2022 13:00:00 UTC - 23 days delay
        schedules[2].duration =   750 days;
        schedules[2].interval =   30 days;
        // Marketing
        schedules[3].start =      1646830800;         // April 1 2022 13:00:00 UTC - 23 days delay
        schedules[3].duration =   450 days;
        schedules[3].interval =   90 days;

        Amounts memory amounts;

        amounts.sale =                 150_000_000 ether;
        amounts.team =                  50_000_000 ether;
        amounts.marketingLocked =       20_000_000 ether;
        amounts.marketingUnlocked =     20_000_000 ether;
        amounts.reserve =               25_000_000 ether;
        amounts.liquidity =            100_000_000 ether;
        amounts.airdrop =               35_000_000 ether;

        Addresses memory addresses;

        addresses.owner =           address(0x1425234cc5F42D2aAa2db1E2088CeC81E6caaF9E);
        addresses.fundraising =     payable(0x2c1524500bb8D2A2548eCF0b87e549b78B0E9625);
        addresses.team =            address(0x924bFf61da5B81ecCc58607e3CB76A00aa6201cf);
        addresses.marketing =       address(0xa48d081d79FB257eEA71791B99D535858Ad8B1DC);
        addresses.reserve =         address(0xA5B10a6A78dF992Fd06587400378010BD248278b);
        addresses.liquidity =       address(0x8441220eFF1370A24f1400f79C06558c3C5A48fa);
        addresses.airdrop =         address(0x1D2d2B2DddA02500B97f08f361AFb17751a27728);
        addresses.treasury =        address(0xA7E8cB251033990cFFC3C10131f35BB122b321fB);
        addresses.buyback =         address(0x5FF5763964aC663Ec6CDcCf9836306301AED64C0);

        token = ICarboToken(_token);
        wallet = IVestingWallet(_wallet);
        sale = ICrowdSale(_sale);
        divs = IDividendManager(_divs);
        fees = IFeeManager(_fees);

        // -------------------------------------------------------------------------------------------------------------
        // CarboToken
        // -------------------------------------------------------------------------------------------------------------

        {
            address _buyFeeHolder = fees.buyFeeHolder();
            address _sellFeeHolder = fees.sellFeeHolder();
            ICarboToken.Fees memory BUY_FEES;
            ICarboToken.Fees memory SELL_FEES;

            BUY_FEES.rfi = 0;
            BUY_FEES.dividends = 30;
            BUY_FEES.buyback = 5;
            BUY_FEES.treasury = 5;
            BUY_FEES.liquidity = 10;

            SELL_FEES.rfi = 40;
            SELL_FEES.dividends = 0;
            SELL_FEES.buyback = 0;
            SELL_FEES.treasury = 0;
            SELL_FEES.liquidity = 10;

            token.setFees(ICarboToken.FeeType.BUY, BUY_FEES.rfi, BUY_FEES.dividends, BUY_FEES.buyback, BUY_FEES.treasury, BUY_FEES.liquidity);
            token.setFees(ICarboToken.FeeType.SELL, SELL_FEES.rfi, SELL_FEES.dividends, SELL_FEES.buyback, SELL_FEES.treasury, SELL_FEES.liquidity);
            token.setFeeAddresses(ICarboToken.FeeType.BUY, _buyFeeHolder, _buyFeeHolder, _buyFeeHolder, _buyFeeHolder);
            token.setFeeAddresses(ICarboToken.FeeType.SELL, _sellFeeHolder, _sellFeeHolder, _sellFeeHolder, _sellFeeHolder);

            IWithCallback(_token).setCallbackContract(_divs);
            IWithCallback(_token).setCallbackFunction(IWithCallback.CallbackType.INCREASE_BALANCE, true);
            IWithCallback(_token).setCallbackFunction(IWithCallback.CallbackType.DECREASE_BALANCE, true);

            token.excludeFromRFI(_buyFeeHolder);
            token.excludeFromRFI(_sellFeeHolder);
            token.excludeFromRFI(_sale);
            token.excludeFromRFI(_wallet);
            token.excludeFromRFI(_pair);
            token.excludeFromRFI(addresses.owner);
            token.excludeFromRFI(addresses.fundraising);
            token.excludeFromRFI(addresses.team);
            token.excludeFromRFI(addresses.marketing);
            token.excludeFromRFI(addresses.reserve);
            token.excludeFromRFI(addresses.liquidity);
            token.excludeFromRFI(addresses.airdrop);
            token.excludeFromRFI(addresses.treasury);
            token.excludeFromRFI(addresses.buyback);

            token.setTaxable(_pair, true);

            token.setTaxExempt(_fees, true);
            token.setTaxExempt(addresses.owner, true);
            token.setTaxExempt(addresses.fundraising, true);
            token.setTaxExempt(addresses.team, true);
            token.setTaxExempt(addresses.marketing, true);
            token.setTaxExempt(addresses.reserve, true);
            token.setTaxExempt(addresses.liquidity, true);
            token.setTaxExempt(addresses.airdrop, true);
            token.setTaxExempt(addresses.treasury, true);
            token.setTaxExempt(addresses.buyback, true);

            token.transferFrom(msg.sender, address(this), token.balanceOf(msg.sender));
            IOwnable(_token).transferOwnership(msg.sender);
        }

        // -------------------------------------------------------------------------------------------------------------
        // VestingWallet
        // -------------------------------------------------------------------------------------------------------------

        {
            wallet.setToken(_token);
            for (uint256 i; i < schedules.length; i++) {
                wallet.setVestingSchedule(i, schedules[i].start,   schedules[i].duration,  schedules[i].interval);
            }
            token.approve(_wallet, amounts.team + amounts.marketingLocked);
            wallet.deposit(2, addresses.team, amounts.team);
            wallet.deposit(3, addresses.marketing, amounts.marketingLocked);
            IOwnable(_wallet).transferOwnership(msg.sender);
        }

        // -------------------------------------------------------------------------------------------------------------
        // CrowdSale
        // -------------------------------------------------------------------------------------------------------------

        {
            uint256 PRICE = 10_000 ether;
            Stages.Stage memory STAGE;
            STAGE.start = 1649595600;       // April 10 2022 13:00:00 UTC
            STAGE.end = 1650200400;         // April 17 2022 13:00:00 UTC
            STAGE.bonus = 0;
            STAGE.minInvestmentLimit = 1 ether;
            STAGE.maxInvestmentLimit = amounts.sale / PRICE;
            STAGE.hardcapInTokens = amounts.sale;
            STAGE.vestingSchedule = 1;
            STAGE.invested = 0;
            STAGE.tokensSold = 0;
            STAGE.whitelist = false;

            sale.setToken(_token);
            sale.setFundraisingWallet(addresses.fundraising);
            sale.setVestingWallet(_wallet);
            sale.setPrice(PRICE);
            sale.setStage(0, STAGE.start, STAGE.end, STAGE.bonus, STAGE.minInvestmentLimit, STAGE.maxInvestmentLimit, STAGE.hardcapInTokens, STAGE.vestingSchedule, STAGE.invested, STAGE.tokensSold, STAGE.whitelist);
            token.transfer(_sale, amounts.sale);
            IOwnable(_sale).transferOwnership(msg.sender);
        }

        // -------------------------------------------------------------------------------------------------------------
        // DividendManager
        // -------------------------------------------------------------------------------------------------------------

        {
            divs.setToken(_token);
            divs.setBUSD(_busd);
            divs.excludeFromDividends(_token);
            divs.excludeFromDividends(_sale);
            divs.excludeFromDividends(_wallet);
            divs.excludeFromDividends(_pair);
            divs.excludeFromDividends(addresses.owner);
            divs.excludeFromDividends(addresses.fundraising);
            divs.excludeFromDividends(addresses.team);
            divs.excludeFromDividends(addresses.marketing);
            divs.excludeFromDividends(addresses.reserve);
            divs.excludeFromDividends(addresses.liquidity);
            divs.excludeFromDividends(addresses.airdrop);
            divs.excludeFromDividends(addresses.treasury);
            divs.excludeFromDividends(addresses.buyback);
            IOwnable(_divs).transferOwnership(msg.sender);
        }

        // -------------------------------------------------------------------------------------------------------------
        // FeeManager
        // -------------------------------------------------------------------------------------------------------------

        {
            fees.setDividendManager(_divs);
            fees.setFeeAddresses(addresses.buyback, addresses.treasury, addresses.liquidity);
            IOwnable(_fees).transferOwnership(msg.sender);
        }

        // -------------------------------------------------------------------------------------------------------------
        // Token Distribution
        // -------------------------------------------------------------------------------------------------------------

        {
            token.transfer(addresses.marketing, amounts.marketingUnlocked);
            token.transfer(addresses.reserve, amounts.reserve);
            token.transfer(addresses.liquidity, amounts.liquidity);
            token.transfer(addresses.airdrop, amounts.airdrop);
            token.transfer(addresses.owner, token.balanceOf(address(this)));
        }
    }

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library Stages {

    using EnumerableSet for EnumerableSet.UintSet;

    struct Stage {
        uint256 start;
        uint256 end;
        uint256 bonus;
        uint256 minInvestmentLimit;
        uint256 maxInvestmentLimit;
        uint256 hardcapInTokens;
        uint256 vestingSchedule;
        uint256 invested;
        uint256 tokensSold;
        bool whitelist;
    }

    struct Map {
        EnumerableSet.UintSet _keys;
        mapping(uint256 => Stage) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Map storage map, uint256 key, Stage memory value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Map storage map, uint256 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Map storage map, uint256 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Map storage map) internal view returns (uint256) {
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
    function at(Map storage map, uint256 index) internal view returns (uint256, Stage storage) {
        uint256 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Map storage map, uint256 key) internal view returns (Stage storage) {
        Stage storage value = map._values[key];
        require(contains(map, key), "Stages.Map: nonexistent key");
        return value;
    }

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library Schedules {

    using EnumerableSet for EnumerableSet.UintSet;

    struct Schedule {
        uint256 start;
        uint256 duration;
        uint256 interval;
    }

    struct Map {
        EnumerableSet.UintSet _keys;
        mapping(uint256 => Schedule) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(Map storage map, uint256 key, Schedule memory value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Map storage map, uint256 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Map storage map, uint256 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Map storage map) internal view returns (uint256) {
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
    function at(Map storage map, uint256 index) internal view returns (uint256, Schedule storage) {
        uint256 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Map storage map, uint256 key) internal view returns (Schedule storage) {
        Schedule storage value = map._values[key];
        require(contains(map, key), "Vesting.Map: nonexistent key");
        return value;
    }

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of WithCallback contract.
 */
interface IWithCallback {

    enum CallbackType {
        REFLECT_INTERNAL,
        REFLECT_EXTERNAL,
        INCREASE_BALANCE,
        DECREASE_BALANCE,
        DECREASE_TOTAL_SUPPLY,
        TRANSFER,
        BURN
    }

    function setCallbackContract(address _callback) external;
    function setCallbackFunction(CallbackType callbackFunction, bool isActive) external;

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of MultiWallet contract.
 */
interface IVestingWallet {

    function setToken(address tokenAddress) external;
    function setVestingSchedule(uint256 id, uint256 start, uint256 duration, uint256 interval) external returns (bool);
    function deposit(uint256 schedule, address beneficiary, uint256 amount) external;
    function deposit(uint256 schedule, address[] calldata beneficiaries, uint256[] calldata amounts) external;

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of Ownable contract.
 */
interface IOwnable {

    function transferOwnership(address newOwner) external;

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of FeeManager
 */
interface IFeeManager {

    function setFeeAddresses(address buyback, address treasury, address liquidity) external;
    function setDividendManager(address _address) external;
    function buyFeeHolder() external returns (address);
    function sellFeeHolder() external returns (address);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of DividendManager
 */
interface IDividendManager {

    function distributeDividends(uint256 amount) external;
    function setBUSD(address _busd) external;
    function setToken(address _token) external;
    function excludeFromDividends(address account) external;

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of CrowdSale contract.
 */
interface ICrowdSale {

    function setToken(address newTokenAddress) external;
    function setVestingWallet(address newVestingWalletAddress) external;
    function setPercentRate(uint256 newPercentRate) external;
    function setFundraisingWallet(address payable newFundraisingWalletAddress) external;
    function setPrice(uint256 newPrice) external;
    function setStage(uint256 id,uint256 start, uint256 end, uint256 bonus, uint256 minInvestmentLimit, uint256 maxInvestmentLimit, uint256 hardcapInTokens, uint256 vestingSchedule, uint256 invested, uint256 tokensSold, bool whitelist) external returns (bool);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Interface of CarboToken
 */
interface ICarboToken is IERC20 {

    struct Amounts {
        uint256 sum;
        uint256 transfer;
        uint256 rfi;
        uint256 dividends;
        uint256 buyback;
        uint256 treasury;
        uint256 liquidity;
    }

    struct Fees {
        uint256 rfi;
        uint256 dividends;
        uint256 buyback;
        uint256 treasury;
        uint256 liquidity;
    }

    struct FeeAddresses {
        address dividends;
        address buyback;
        address treasury;
        address liquidity;
    }

    enum FeeType { BUY, SELL, NONE}

    event FeeTaken(uint256 rfi, uint256 dividends, uint256 buyback, uint256 treasury, uint256 liquidity);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external pure returns (uint8);
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function getFees(FeeType feeType) external view returns (Fees memory);
    function setFees(FeeType feeType, uint rfi, uint dividends, uint buyback, uint treasury, uint liquidity) external;
    function getFeeAddresses(FeeType feeType) external view returns (FeeAddresses memory);
    function setFeeAddresses(FeeType feeType, address dividends, address buyback, address treasury, address liquidity) external;
    function setTaxable(address account, bool value) external;
    function setTaxExempt(address account, bool value) external;
    function getROwned(address account) external view returns (uint256);
    function getRTotal() external view returns (uint256);
    function excludeFromRFI(address account) external;
    function includeInRFI(address account) external;
    function reflect(uint256 tAmount) external;
    function reflectionFromToken(uint256 tAmount) external view returns (uint256);
    function tokenFromReflection(uint256 rAmount) external view returns (uint256);

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Allows the owner to retrieve ETH or tokens sent to this contract by mistake.
 */
contract RecoverableFunds is Ownable {

    function retrieveTokens(address recipient, address tokenAddress) public virtual onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.transfer(recipient, token.balanceOf(address(this)));
    }

    function retriveETH(address payable recipient) public virtual onlyOwner {
        recipient.transfer(address(this).balance);
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