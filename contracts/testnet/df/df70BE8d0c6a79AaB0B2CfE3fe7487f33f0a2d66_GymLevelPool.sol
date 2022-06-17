// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

contract GymLevelPool is ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    struct QualifiedCandidates {
        uint256 totalGold;
        uint256 totalPlatin;
        uint256 totalBlack;
    }

    struct PendingRewardsFromSource {
        uint256 vault;
        uint256 farming;
        uint256 singlePool;
    }

    struct UserInfo {
        uint256 level;
        uint256 totalRewards;
        uint256 unclaimed;
        mapping(uint256 => uint256) levelReward;
    }

    uint256 public totalRewards;
    uint256 public totalUnclaimed;

    address public gymMLM;
    address public gymVault;
    address public gymFarming;
    address public gymSinglePool;

    uint256[3] public poolLevels;
    uint256[3] public poolLevelDividers;

    PendingRewardsFromSource private pendingRewardsFromSource;
    EnumerableSetUpgradeable.UintSet private dailyRewardHistory;

    mapping(address => bool) private whitelist;
    mapping(address => UserInfo) private users;
    mapping(uint256 => uint256) private dailyRewardsHistory;

    mapping(uint256 => EnumerableSetUpgradeable.AddressSet) private poolWallets;

    event Whitelisted(address indexed wallet, bool whitelist);
    event UserQualificationUpdated(address indexed user, uint256 level);
    event ClaimReward(address indexed user, uint256 level, uint256 amount);
    event DistributeRewards(address indexed executor, uint256 totalPool);
    event IncreasePool(address indexed executor, uint256 amount);
    event IncreasePoolFromSource(uint256 indexed sourceType, uint256 amount);

    modifier onlyWhitelisted() {
        require(
            whitelist[msg.sender] || msg.sender == owner(),
            "GymLevelPool: not whitelisted or owner"
        );
        _;
    }

    modifier onlyFromAllowed() {
        require(
            msg.sender == gymMLM ||
                msg.sender == gymVault ||
                msg.sender == gymFarming ||
                msg.sender == gymSinglePool,
            "GymLevelPool: not an allowed caller"
        );
        _;
    }

    modifier validLevel(uint256 _level) {
        require(
            _isValidLevel(_level),
            "GymLevelPool: wrong qualification level"
        );
        _;
    }

    receive() external payable {
        emit IncreasePool(msg.sender, msg.value);
    }

    fallback() external payable {}

    function initialize(
        address _gymMLMAddress,
        address _gymVaultAddress,
        address _gymFarmingAddress,
        address _gymSinglePoolAddress
    ) external initializer {
        poolLevels = [14, 15, 16];
        poolLevelDividers = [6, 3, 2];

        gymMLM = _gymMLMAddress;
        gymVault = _gymVaultAddress;
        gymFarming = _gymFarmingAddress;
        gymSinglePool = _gymSinglePoolAddress;

        __Ownable_init();
        __ReentrancyGuard_init();
    }

    function setGymMLMAddress(address _gymMLMAddress) external onlyOwner {
        gymMLM = _gymMLMAddress;
    }

    function setGymVaultAddress(address _gymVaultAddress) external onlyOwner {
        gymVault = _gymVaultAddress;
    }

    function setGymFarmingAddress(address _gymFarmingAddress)
        external
        onlyOwner
    {
        gymFarming = _gymFarmingAddress;
    }

    function setGymSinglePoolAddress(address _gymSinglePoolAddress)
        external
        onlyOwner
    {
        gymSinglePool = _gymSinglePoolAddress;
    }

    /**
     * @notice Add or remove wallet to/from whitelist, callable only by contract owner
     *         whitelisted wallet will be able to call functions
     *         marked with onlyWhitelisted modifier
     * @param _wallet wallet to whitelist
     * @param _whitelist boolean flag, add or remove to/from whitelist
     */
    function whitelistWallet(address _wallet, bool _whitelist)
        external
        onlyOwner
    {
        whitelist[_wallet] = _whitelist;

        emit Whitelisted(_wallet, _whitelist);
    }

    function seedUsers(address[] calldata _wallets, uint256[] calldata _levels)
        external
        onlyOwner
    {
        require(
            _wallets.length == _levels.length,
            "GymLevelPool: args length mismatch"
        );

        for (uint256 i = 0; i < _wallets.length; ++i) {
            _updateUserQualification(_wallets[i], _levels[i]);
        }
    }

    function updateUserQualification(address _wallet, uint256 _level)
        external
        onlyFromAllowed
    {
        _updateUserQualification(_wallet, _level);
    }

    /**
     * @notice Claim user rewards for specified pool (level)
     *         transfers tokens to user's wallet,
     *
     * @param _poolId id of level pool (14, 15, 16)
     */
    function claim(uint256 _poolId) external nonReentrant validLevel(_poolId) {
        _claim(_poolId);
    }

    /**
     * @notice Claim user rewards for all qualified pools
     *         transfers tokens to user's wallet
     */
    function claimAll() external nonReentrant {
        for (uint256 i = 0; i < poolLevels.length; ++i) {
            _claim(poolLevels[i]);
        }
    }

    /**
     * @notice Distribute collected tokens to level pool qualified candidates
     *         This function DOES NOT make transfers, only set pending rewards
     *         for each qualified user.
     *
     *         Reward pool distribution:
     *
     *         goldWalletsChunk   - lvl14 - 1/6 of total daily pool
     *         platinWalletsChunk - lvl15 - 1/3 of total daily pool
     *         blackWalletsChunk  - lvl16 - 1/2 of total daily pool
     *
     *         Wallet reward distribution in pools:
     *
     *         goldWalletReward   - lvl14 - goldWalletsChunk / count(lvl14 + lvl15 + lvl16)
     *         platinWalletReward - lvl15 - goldWalletsChunk / count(lvl15 + lvl16)
     *         blackWalletReward  - lvl16 - goldWalletsChunk / count(lvl16)
     *
     *         Must be called only by whitelisted addresses.
     */
    function distributeRewards() external onlyWhitelisted {
        uint256 amountToDistribute = address(this).balance - totalUnclaimed;
        uint256 totalDistributed = 0;

        if (amountToDistribute == 0) {
            return;
        }

        for (uint256 i = 0; i < poolLevels.length; ++i) {
            uint256 level = poolLevels[i];
            uint256 levelChunk = amountToDistribute / poolLevelDividers[i];

            uint256 walletsInPool = poolWallets[level].length();

            // in case if there are no wallets in pool just skip distribution
            if (walletsInPool == 0) {
                continue;
            }

            uint256 levelRewardPerWallet = levelChunk / walletsInPool;

            /**
             * In this function division operation will introduce lack of precision.
             * To keep amounts correct and not lose tokens, multiply
             * levelRewardPerWallet by walletsInPool to get actual distributed amount.
             * Division remainder will be grabbed by next distributeRewards call.
             */
            totalDistributed += levelRewardPerWallet * walletsInPool;

            _distributeLevelRewards(level, levelRewardPerWallet);
        }

        totalRewards += totalDistributed;
        totalUnclaimed += totalDistributed;
        dailyRewardHistory.add(totalDistributed);

        _resetPendingRewards();

        emit DistributeRewards(msg.sender, totalDistributed);
    }

    /**
     * @notice Get wallets qualified to specific _level by index
     * @param _level users level
     * @param _index index of user, starts with 0
     * @return address user wallet address
     */
    function qualifiedUsersByLevel(uint256 _level, uint256 _index)
        external
        view
        validLevel(_level)
        returns (address)
    {
        require(
            _index < poolWallets[_level].length(),
            "GymLevelPool: index out of bounds"
        );

        return poolWallets[_level].at(_index);
    }

    /**
     * @notice Get number of qualified candidates for each pool level
     * @return QualifiedCandidates struct with total candidates per each pool
     */
    function calculateQualifiedCandidates()
        external
        view
        returns (QualifiedCandidates memory)
    {
        uint256 goldWallets = poolWallets[14].length() -
            poolWallets[15].length();
        uint256 platinWallets = poolWallets[15].length() -
            poolWallets[16].length();

        return
            QualifiedCandidates({
                totalGold: goldWallets,
                totalPlatin: platinWallets,
                totalBlack: poolWallets[16].length()
            });
    }

    /**
     * @notice Get struct with amounts of rewards collected from different sources
     * @return PendingRewardsFromSource structured reward amounts
     */
    function getPendingRewardsFromSource()
        external
        view
        returns (PendingRewardsFromSource memory)
    {
        return pendingRewardsFromSource;
    }

    function getRewardsHistoryLength() external view returns (uint256) {
        return dailyRewardHistory.length();
    }

    function getDailyRewardsHistory(uint256 _day)
        external
        view
        returns (uint256)
    {
        require(
            _day < dailyRewardHistory.length(),
            "GymLevelPool: index out of bounds"
        );

        return dailyRewardHistory.at(_day);
    }

    function getPendingRewardsTotal() external view returns (uint256) {
        return totalUnclaimed;
    }

    function getUserLevelReward(address wallet, uint256 level)
        external
        view
        validLevel(level)
        returns (uint256)
    {
        require(
            users[wallet].level != 0,
            "GymSinglePool: user not qualified for any pool"
        );

        return users[wallet].levelReward[level];
    }

    function getUserLevel(address wallet) public view returns (uint256) {
        return users[wallet].level;
    }

    function getUserPendingRewards(address wallet)
        external
        view
        returns (uint256)
    {
        uint256 total = 0;

        require(
            users[wallet].level != 0,
            "GymSinglePool: user not qualified for any pool"
        );

        for (uint256 i = 0; i < poolLevels.length; ++i) {
            uint256 level = poolLevels[i];

            total += users[wallet].levelReward[level];
        }

        return total;
    }

    function isWhitelisted(address wallet) external view returns (bool) {
        return whitelist[wallet];
    }

    function _isValidLevel(uint256 _level) internal pure returns (bool) {
        return _level == 14 || _level == 15 || _level == 16;
    }

    function _getTotalWallets() internal view returns (uint256) {
        return poolWallets[14].length();
    }

    function _isUserQualified(address wallet) internal view returns (bool) {
        return poolWallets[14].contains(wallet);
    }

    /**
     * @notice Set pending rewards to zero after distribution
     */
    function _resetPendingRewards() internal {
        pendingRewardsFromSource = PendingRewardsFromSource(0, 0, 0);
    }

    /**
     * @notice Distribute _levelReward amount for each user qualified to _level pool
     * @param _level level (pool) id - 14, 15, 16
     * @param _levelReward amount to distribute
     */
    function _distributeLevelRewards(uint256 _level, uint256 _levelReward)
        internal
    {
        EnumerableSetUpgradeable.AddressSet storage wallets = poolWallets[
            _level
        ];

        for (uint256 i = 0; i < wallets.length(); ++i) {
            address wallet = wallets.at(i);

            users[wallet].levelReward[_level] += _levelReward;
            users[wallet].unclaimed += _levelReward;
        }
    }

    /**
     * @notice Tracks incoming tokens amount by source type
     * @param _amount amount of tokens that goes to the level pool
     * @param _type source of tokens (
            1 - VaultBank,
            2 - Farming,
            3 - SinglePool
       ) 
     */
    function _addPoolIncreaseStatistic(uint256 _amount, uint256 _type)
        internal
    {
        if (_type == 1) {
            pendingRewardsFromSource.vault += _amount;
        } else if (_type == 2) {
            pendingRewardsFromSource.farming += _amount;
        } else if (_type == 3) {
            pendingRewardsFromSource.singlePool += _amount;
        } else {
            revert("GymLevelPool: unsupported source type");
        }
    }

    function _disqualifyUser(address _wallet, uint256 _newLevel) internal {
        bool fullyDisqualify = _newLevel < poolLevels[0];

        uint256 currentLevel = users[_wallet].level;
        uint256 newLevel = fullyDisqualify ? poolLevels[0] - 1 : _newLevel;
        uint256 removedRewards = 0;

        for (uint256 i = currentLevel; i > newLevel; --i) {
            removedRewards += users[_wallet].levelReward[i];
            users[_wallet].levelReward[i] = 0;

            poolWallets[i].remove(_wallet);
        }

        users[_wallet].unclaimed -= removedRewards;

        totalUnclaimed -= removedRewards;

        if (fullyDisqualify) {
            delete users[_wallet];
        }
    }

    function _claim(uint256 _poolId) internal {
        EnumerableSetUpgradeable.AddressSet storage _poolWallets = poolWallets[
            _poolId
        ];

        if (!_poolWallets.contains(msg.sender)) {
            return;
        }

        uint256 rewardAmount = users[msg.sender].levelReward[_poolId];

        if (rewardAmount > 0) {
            payable(msg.sender).transfer(rewardAmount);

            users[msg.sender].levelReward[_poolId] = 0;
            users[msg.sender].unclaimed -= rewardAmount;
            users[msg.sender].totalRewards += rewardAmount;

            totalUnclaimed -= rewardAmount;

            emit ClaimReward(msg.sender, _poolId, rewardAmount);
        }
    }

    function _updateUserQualification(address _wallet, uint256 _level)
        internal
    {
        bool userQualified = _isUserQualified(_wallet);
        uint256 currentLevel = getUserLevel(_wallet);

        bool disqualify = userQualified && _level < currentLevel;

        if (!userQualified && _level < poolLevels[0]) {
            return;
        }

        if (!disqualify) {
            users[_wallet].level = _level;

            for (uint256 i = 14; i <= _level; ++i) {
                poolWallets[i].add(_wallet);
            }
        } else {
            _disqualifyUser(_wallet, _level);
        }

        emit UserQualificationUpdated(_wallet, _level);
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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