// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./libraries/Ownable.sol";
import "./libraries/EnumerableSet.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IToken.sol";

contract PresaleSettings is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    EnumerableSet.AddressSet private EARLY_ACCESS_TOKENS;

    mapping(address => bool) private ALLOWED_BASE_TOKENS;

    mapping(address => AccessTokens) public accessToken;
    struct AccessTokens {
        bool ownedBalance;
        uint256 level1TokenAmount;
        uint256 level2TokenAmount;
        uint256 level3TokenAmount;
        uint256 level4TokenAmount;
    }
    
    EnumerableSet.AddressSet private ALLOWED_REFERRERS;
    
    struct Settings {
        uint256 BASE_FEE; // base fee divided by 1000
        uint256 TOKEN_FEE; // token fee divided by 1000
        uint256 REFERRAL_FEE; // a referrals percentage of the presale profits divided by 1000
        address payable ETH_FEE_ADDRESS;
        address payable TOKEN_FEE_ADDRESS;
        uint256 ETH_CREATION_FEE; // fee to generate a presale contract on the platform
        uint256 LEVEL_4_ROUND_LENGTH; // length of round level4 in seconds
        uint256 LEVEL_3_ROUND_LENGTH; // length of round level2 in seconds
        uint256 LEVEL_2_ROUND_LENGTH; // length of round level3 in seconds
        uint256 LEVEL_1_ROUND_LENGTH; // length of round level1 in seconds
        uint256 MAX_PRESALE_LENGTH; // maximum difference between start and endblock
        uint256 MIN_EARLY_ACCESS_ALLOWANCE;
        uint256 MIN_SOFTCAP_RATE;
        uint256 MIN_PERCENT_PYESWAP;
    }
    
    Settings public SETTINGS;
    
    constructor() {
        SETTINGS.BASE_FEE = 20; // 2.0%
        SETTINGS.TOKEN_FEE = 20; // 2.0%
        SETTINGS.REFERRAL_FEE = 200; // 20%
        SETTINGS.ETH_CREATION_FEE = 1e18; // 1 bnb
        SETTINGS.ETH_FEE_ADDRESS = payable(msg.sender);
        SETTINGS.TOKEN_FEE_ADDRESS = payable(msg.sender);
        SETTINGS.LEVEL_4_ROUND_LENGTH = 3 hours;
        SETTINGS.LEVEL_3_ROUND_LENGTH = 2 hours; 
        SETTINGS.LEVEL_2_ROUND_LENGTH = 1 hours; 
        SETTINGS.LEVEL_1_ROUND_LENGTH = 30 minutes; 
        SETTINGS.MAX_PRESALE_LENGTH = 2 weeks; 
        SETTINGS.MIN_EARLY_ACCESS_ALLOWANCE = 2500; // 25%
        SETTINGS.MIN_SOFTCAP_RATE = 5000; // 50%
        SETTINGS.MIN_PERCENT_PYESWAP = 500; // 50%
        ALLOWED_BASE_TOKENS[0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c] = true;
        ALLOWED_BASE_TOKENS[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = true;
    }
    
    function getLevel4RoundLength () external view returns (uint256) {
        return SETTINGS.LEVEL_4_ROUND_LENGTH;
    }

    function getLevel3RoundLength () external view returns (uint256) {
        return SETTINGS.LEVEL_3_ROUND_LENGTH;
    }

    function getLevel2RoundLength () external view returns (uint256) {
        return SETTINGS.LEVEL_2_ROUND_LENGTH;
    }

    function getLevel1RoundLength () external view returns (uint256) {
        return SETTINGS.LEVEL_1_ROUND_LENGTH;
    }

    function getMaxPresaleLength () external view returns (uint256) {
        return SETTINGS.MAX_PRESALE_LENGTH;
    }

    function getMinSoftcapRate() external view returns (uint256) {
        return SETTINGS.MIN_SOFTCAP_RATE;
    }

    function getMinEarlyAllowance() external view returns (uint256){
        return SETTINGS.MIN_EARLY_ACCESS_ALLOWANCE;
    }
    
    function getBaseFee () external view returns (uint256) {
        return SETTINGS.BASE_FEE;
    }
    
    function getTokenFee () external view returns (uint256) {
        return SETTINGS.TOKEN_FEE;
    }
    
    function getReferralFee () external view returns (uint256) {
        return SETTINGS.REFERRAL_FEE;
    }
    
    function getEthCreationFee () external view returns (uint256) {
        return SETTINGS.ETH_CREATION_FEE;
    }
    
    function getEthAddress () external view returns (address payable) {
        return SETTINGS.ETH_FEE_ADDRESS;
    }
    
    function getTokenAddress () external view returns (address payable) {
        return SETTINGS.TOKEN_FEE_ADDRESS;
    }

    function getMinimumPercentToPYE () external view returns (uint256) {
        return SETTINGS.MIN_PERCENT_PYESWAP;
    }
    
    function setFeeAddresses(address payable _ethAddress, address payable _tokenFeeAddress) external onlyOwner {
        SETTINGS.ETH_FEE_ADDRESS = _ethAddress;
        SETTINGS.TOKEN_FEE_ADDRESS = _tokenFeeAddress;
    }
    
    function setFees(uint256 _baseFee, uint256 _tokenFee, uint256 _ethCreationFee, uint256 _referralFee) external onlyOwner {
        SETTINGS.BASE_FEE = _baseFee;
        SETTINGS.TOKEN_FEE = _tokenFee;
        SETTINGS.REFERRAL_FEE = _referralFee;
        SETTINGS.ETH_CREATION_FEE = _ethCreationFee;
    }
    
    function setLevel4RoundLength(uint256 _level4RoundLength) external onlyOwner {
        SETTINGS.LEVEL_4_ROUND_LENGTH = _level4RoundLength;
    }

    function setLevel3RoundLength(uint256 _level2RoundLength) external onlyOwner {
        SETTINGS.LEVEL_3_ROUND_LENGTH = _level2RoundLength;
    }

    function setLevel2RoundLength(uint256 _level3RoundLength) external onlyOwner {
        SETTINGS.LEVEL_2_ROUND_LENGTH = _level3RoundLength;
    }

    function setLevel1RoundLength(uint256 _level1RoundLength) external onlyOwner {
        SETTINGS.LEVEL_1_ROUND_LENGTH = _level1RoundLength;
    }

    function setMaxPresaleLength(uint256 _maxLength) external onlyOwner {
        SETTINGS.MAX_PRESALE_LENGTH = _maxLength;
    }

    function setMinSoftcapRate(uint256 _minSoftcapRate) external onlyOwner {
        SETTINGS.MIN_SOFTCAP_RATE = _minSoftcapRate;
    }

    function setMinPercentToPYESwap(uint256 _minPercentToPYE) external onlyOwner {
        require(_minPercentToPYE <= 1000);
        SETTINGS.MIN_PERCENT_PYESWAP = _minPercentToPYE;
    }

    function setMinEarlyAllowance(uint256 _minEarlyAllowance) external onlyOwner {
        SETTINGS.MIN_EARLY_ACCESS_ALLOWANCE = _minEarlyAllowance;
    }
    
    function editAllowedReferrers(address payable _referrer, bool _allow) external onlyOwner {
        if (_allow) {
            ALLOWED_REFERRERS.add(_referrer);
        } else {
            ALLOWED_REFERRERS.remove(_referrer);
        }
    }
    
    function editEarlyAccessTokens(address _token, uint256 _level1Amount, uint256 _level2Amount, uint256 _level3Amount, uint256 _level4Amount, bool _ownedBalance, bool _allow) external onlyOwner {
        if (_allow) {
            EARLY_ACCESS_TOKENS.add(_token);
        } else {
            EARLY_ACCESS_TOKENS.remove(_token);
        }
        accessToken[_token].level1TokenAmount = _level1Amount;
        accessToken[_token].level2TokenAmount = _level2Amount;
        accessToken[_token].level3TokenAmount = _level3Amount;
        accessToken[_token].level4TokenAmount = _level4Amount;
        accessToken[_token].ownedBalance = _ownedBalance;
    }
    
    // there will never be more than 10 items in this array. Care for gas limits will be taken.
    // We are aware too many tokens in this unbounded array results in out of gas errors.
    function userAllowlistLevel (address _user) external view returns (uint8) {
        if (earlyAccessTokensLength() == 0) {
            return 0;
        }
        uint256 userBalance;
        for (uint i = 0; i < earlyAccessTokensLength(); i++) {
          (address token) = getEarlyAccessTokenAtIndex(i);
            if(accessToken[token].ownedBalance) {
                userBalance = IToken(token).getOwnedBalance(_user);
            } else {
                userBalance = IERC20(token).balanceOf(_user);
            }

            if (userBalance < accessToken[token].level1TokenAmount) {
                return 0;
            } else if (userBalance < accessToken[token].level2TokenAmount) {
                return 1;
            } else if (userBalance < accessToken[token].level3TokenAmount) {
                return 2;
            } else if (userBalance < accessToken[token].level4TokenAmount) {
                return 3;
            } else if (userBalance >= accessToken[token].level4TokenAmount) {
                return 4;
            }
        }
        return 0;
    }
    
    function getEarlyAccessTokenAtIndex(uint256 _index) public view returns (address) {
        address tokenAddress = EARLY_ACCESS_TOKENS.at(_index);
        return (tokenAddress);
    }
    
    function earlyAccessTokensLength() public view returns (uint256) {
        return EARLY_ACCESS_TOKENS.length();
    }
    
    // Referrers
    function allowedReferrersLength() external view returns (uint256) {
        return ALLOWED_REFERRERS.length();
    }
    
    function getReferrerAtIndex(uint256 _index) external view returns (address) {
        return ALLOWED_REFERRERS.at(_index);
    }
    
    function referrerIsValid(address _referrer) external view returns (bool) {
        return ALLOWED_REFERRERS.contains(_referrer);
    }

    function baseTokenIsValid(address _baseToken) external view returns (bool) {
        return ALLOWED_BASE_TOKENS[_baseToken];
    }

    function setAllowedBaseToken(address _baseToken, bool _flag) external onlyOwner {
        ALLOWED_BASE_TOKENS[_baseToken] = _flag;
    }
    
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IToken {
    function getFee() external returns (uint256);
    function getOwnedBalance(address account) external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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