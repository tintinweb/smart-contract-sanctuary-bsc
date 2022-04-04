// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ICurrencyManager.sol";
import "./interfaces/IERC20Burnable.sol";

contract ElpisRaidBoss is
    ContextUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable
{

    struct RaidBoss {
        uint256 startTime;
        uint256 endTime;
        uint256 baseTicketPrice;
        bool claimable;
    }

    IERC20 public EBA;
    IERC20Burnable public MEG;
    ICurrencyManager public currencyManager;

    bytes32 public constant ESTONE =
        0x4553544f4e450000000000000000000000000000000000000000000000000000;

    //Since `unlimitedDay`, we will not limit the number of tickets an account can purchase
    uint256 public unlimitedDay;
    //Before the unlimited day, we limit the number of tickets that can be purchased in a day to `maxPurchaseAmount` tickets
    uint256 public maxPurchaseAmount;
    //The current raid-boss id
    uint256 private _currentRaidBossId;

    //List of price multipliers. Price formula: (basePrice * pricemultiplier)/100
    //125: 1.25, 150: 1.5
    uint256[] public priceMultipliers;
    //Info of each pool.
    RaidBoss[] private _raidBosses;

    //Mapping raidBossId to user to dayOfRaidBoss to number of tickets purchased.
    mapping(uint256 => mapping(address => mapping(uint256 => uint256)))
        private _balances;
    //Mapping raidBossId to rewards in eStone of user
    mapping(uint256 => mapping(address => uint256)) private _rewardsEstone;
    //Mapping raidBossId to rewards in EBA of user
    mapping(uint256 => mapping(address => uint256)) private _rewardsEBA;

    ///@dev Emitted when an raid-boss event is started.
    event Start(
        uint256 raidBossId,
        uint256 startTime,
        uint256 endTime,
        uint256 baseTicketPrice
    );

    ///@dev Emitted when raid-boss start time is changed.
    event StartTimeChanged(uint256 raidBossId, uint256 startTime);

    ///@dev Emitted when raid-boss end time is changed.
    event EndTimeChanged(uint256 raidBossId, uint256 endTime);

    ///@dev Emitted when raid-boss end time is changed.
    event BasePriceTicketChanged(uint256 raidBossId, uint256 endTime);

    ///@dev Emitted when day unlimited purchase is changed.
    event UnlimitedDayChanged(uint256 unlimitedDay);

    ///@dev Emitted when maximum purchase amount is changed.
    event MaxPurchaseAmountChanged(uint256 maxPurchaseAmount);

    ///@dev Emitted when price multipliers is changed.
    event PriceMultipliersChanged(uint256[] priceMultipliers);

    ///@dev Emitted when `amount` tickets is purchased in `raidBossId` from `purchaser`.
    event PurchaseBatch(
        uint256 indexed raidBossId,
        address indexed purchaser,
        address[] recipients,
        uint256[] amounts
    );

    ///@dev Emitted when eStone and EBA is rewarded for multi `accounts`.
    event RewardsDistributed(
        address[] accounts,
        uint256[] eStoneAmounts,
        uint256[] ebaAmounts
    );

    ///@dev Emitted when claimable state of `raidBossId` raid-boss event is changed.
    event ClaimableStateChanged(uint256 raidBossId, bool claimable);

    ///@dev Emitted when eStone and MEG rewards is claimed from `account`.
    event RewardsClaimed(
        address account,
        uint256 eStoneAmount,
        uint256 ebaAmount
    );

    modifier onlyActive(uint256 raidBossId) {
        require(
            block.timestamp >= _raidBosses[raidBossId].startTime,
            "The event has not started yet"
        );
        require(
            block.timestamp <= _raidBosses[raidBossId].endTime,
            "The event has ended"
        );
        _;
    }

    modifier onlyEnded(uint256 raidBossId) {
        if (_raidBosses.length > 0) {
            require(
                block.timestamp > _raidBosses[raidBossId].endTime,
                "The event has not ended yet"
            );
        }
        _;
    }

    modifier onlyNonZeroValue(uint256 value) {
        require(value > 0, "TZV"); // The zero value
        _;
    }

    modifier onlyNonZeroAddress(address addr) {
        require(addr != address(0), "TZA"); // The zero address
        _;
    }

    modifier dayOfRaidBossValid(uint256 _raidBossId, uint256 dayOfRaidBoss) {
        RaidBoss memory boss = _raidBosses[_raidBossId];
        uint256 daysOfEvent = (boss.endTime - boss.startTime) / 1 days;
        require(dayOfRaidBoss <= daysOfEvent, "Invalid day of raid-boss");
        _;
    }

    modifier onlyRaidBossExist(uint256 _raidBossId) {
        require(
            _raidBosses.length > 0 && _raidBossId <= _raidBosses.length - 1,
            "Query for nonexistent raid boss"
        );
        _;
    }

    function initialize(
        IERC20 _EBA,
        IERC20Burnable _MEG,
        ICurrencyManager _currencyManager
    ) public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();

        EBA = _EBA;
        MEG = _MEG;
        currencyManager = _currencyManager;
    }

    function raidBossLength() external view returns (uint256) {
        return _raidBosses.length;
    }

    function priceMultiplierLength() external view returns (uint256) {
        return priceMultipliers.length;
    }

    ///@dev View raid-boss event information.
    function viewRaidBoss(uint256 _raidBossId)
        external
        view
        onlyRaidBossExist(_raidBossId)
        returns (RaidBoss memory)
    {
        return _raidBosses[_raidBossId];
    }

    ///@dev View the balance of an account for today.
    function balanceOf(
        uint256 _raidBossId,
        address _account,
        uint256 _dayOfRaidBoss
    )
        external
        view
        onlyRaidBossExist(_raidBossId)
        dayOfRaidBossValid(_raidBossId, _dayOfRaidBoss)
        returns (uint256)
    {
        return _balances[_raidBossId][_account][_dayOfRaidBoss];
    }

    ///@dev View how many tickets an account can purchase at `raidBossId event in `_dayOfRaidBoss` time.
    function availableTicketsOf(
        uint256 _raidBossId,
        address _account,
        uint256 _dayOfRaidBoss
    )
        external
        view
        onlyActive(_raidBossId)
        dayOfRaidBossValid(_raidBossId, _dayOfRaidBoss)
        returns (uint256)
    {
        if (_dayOfRaidBoss < unlimitedDay) {
            return
                maxPurchaseAmount -
                _balances[_raidBossId][_account][_dayOfRaidBoss];
        } else {
            return type(uint256).max;
        }
    }

    ///@dev View the rewards of an account of each raid-boss even in `raidBossIds`.
    function rewardsOf(address _account, uint256[] calldata _raidBossIds)
        external
        view
        returns (uint256[] memory, uint256[] memory)
    {
        uint256 length = _raidBossIds.length;
        uint256[] memory eStones = new uint256[](length);
        uint256[] memory ebas = new uint256[](length);
        for (uint256 i = 0; i < length; ++i) {
            eStones[i] = _rewardsEstone[_raidBossIds[i]][_account];
            ebas[i] = _rewardsEBA[_raidBossIds[i]][_account];
        }
        return (eStones, ebas);
    }

    ///@dev Updates the unlimited day purchase.
    ///@dev the caller is owner.
    function updateUnlimitedDay(uint256 _unlimitedDay) external onlyOwner {
        if (unlimitedDay != _unlimitedDay) {
            unlimitedDay = _unlimitedDay;
            emit UnlimitedDayChanged(_unlimitedDay);
        }
    }

    ///@dev Updates the maximum purchase amount.
    ///@dev `maxPurchaseAmount` should not be a zero value.
    ///@dev the caller is owner.
    function updateMaxPurchaseAmount(uint256 _maxPurchaseAmount)
        external
        onlyOwner
        onlyNonZeroValue(_maxPurchaseAmount)
    {
        if (maxPurchaseAmount != _maxPurchaseAmount) {
            maxPurchaseAmount = _maxPurchaseAmount;
            emit MaxPurchaseAmountChanged(_maxPurchaseAmount);
        }
    }

    ///@dev Updates the maximum purchase amount.
    ///@dev Each multiplier in `multipliers` should not be a zero value.
    ///@dev the caller is owner.
    function updatePriceMultipliers(uint256[] calldata _multipliers)
        external
        onlyOwner
    {
        uint256 length = _multipliers.length;
        for (uint256 i = 0; i < length; ++i) {
            require(_multipliers[i] > 0, "TZV"); // The zero value
        }
        priceMultipliers = _multipliers;
        emit PriceMultipliersChanged(_multipliers);
    }

    ///@dev Pauses the contract.
    ///@dev See {Pausable-pause}.
    function pause() external onlyOwner {
        _pause();
    }

    ///@dev Unpauses the contract.
    ///@dev See {Pausable-unpause}.
    function unpause() external onlyOwner {
        _unpause();
    }

    ///@dev Starts an raid-boss event.
    ///@dev The current event has ended.
    ///@dev The caller is owner.
    function startRaidBoss(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _baseTicketPrice
    ) external onlyOwner onlyEnded(_currentRaidBossId) {
        require(_startTime > block.timestamp, "Invalid start time");
        require(_endTime > _startTime, "Invalid end time");
        require(_baseTicketPrice > 0, "TZV"); // The zero value

        _raidBosses.push(
            RaidBoss({
                startTime: _startTime,
                endTime: _endTime,
                baseTicketPrice: _baseTicketPrice,
                claimable: false
            })
        );
        _currentRaidBossId = _raidBosses.length - 1;

        emit Start(
            _currentRaidBossId,
            _startTime,
            _endTime,
            _baseTicketPrice
        );
    }

    ///@dev Updates the start time of `_raidBossId` raid-boss event.
    ///@dev The current event must not have started yet.
    ///@dev the caller is owner.
    function updateStartTime(uint256 _raidBossId, uint256 _startTime)
        external
        onlyOwner
        onlyRaidBossExist(_raidBossId)
    {
        RaidBoss storage boss = _raidBosses[_raidBossId];
        require(boss.startTime > block.timestamp, "The event has started");
        require(_startTime > block.timestamp, "Invalid start time");

        if (boss.startTime != _startTime) {
            boss.startTime = _startTime;
            emit StartTimeChanged(_raidBossId, _startTime);
        }
    }

    ///@dev Updates the end time of `_raidBossId` raid-boss event.
    ///@dev The current event must not have ended yet.
    ///@dev the caller is owner.
    function updateEndTime(uint256 _raidBossId, uint256 _endTime)
        external
        onlyOwner
        onlyRaidBossExist(_raidBossId)
    {
        RaidBoss storage boss = _raidBosses[_raidBossId];
        require(boss.endTime > block.timestamp, "The event has ended");
        require(_endTime > boss.startTime, "Invalid end time");

        if (boss.endTime != _endTime) {
            boss.endTime = _endTime;
            emit EndTimeChanged(_raidBossId, _endTime);
        }
    }

    ///@dev Updates the base ticket price in MEG of `_raidBossId` raid-boss event.
    ///@dev The current event must not have started yet.
    ///@dev the caller is owner.
    function updatebaseTicketPrice(
        uint256 _raidBossId,
        uint256 _baseTicketPrice
    )
        external
        onlyOwner
        onlyRaidBossExist(_raidBossId)
        onlyNonZeroValue(_baseTicketPrice)
    {
        RaidBoss storage boss = _raidBosses[_raidBossId];
        require(boss.startTime > block.timestamp, "The event has started");

        if (boss.baseTicketPrice != _baseTicketPrice) {
            boss.baseTicketPrice = _baseTicketPrice;
            emit BasePriceTicketChanged(_raidBossId, _baseTicketPrice);
        }
    }

    ///@dev Distributes rewards in eStone and MEG for multi `accounts` in `raidBossId` raid-boss.
    ///@dev The `raidBossId` raid-boss event has ended.
    ///@dev the caller is owner.
    function distributeRewards(
        uint256 _raidBossId,
        address[] calldata _accounts,
        uint256[] calldata _eStoneAmounts,
        uint256[] calldata _ebaAmounts
    ) external onlyOwner onlyRaidBossExist(_raidBossId) onlyEnded(_raidBossId) {
        require(
            _accounts.length == _eStoneAmounts.length &&
                _accounts.length == _ebaAmounts.length,
            "Invalid parameters"
        );

        uint256 length = _accounts.length;
        for (uint256 i = 0; i < length; ++i) {
            require(_eStoneAmounts[i] != 0, "TVZ"); //The zero value
            require(_ebaAmounts[i] != 0, "TVZ"); //The zero value

            _rewardsEstone[_raidBossId][_accounts[i]] = _eStoneAmounts[i];
            _rewardsEBA[_raidBossId][_accounts[i]] = _ebaAmounts[i];
        }
        emit RewardsDistributed(_accounts, _eStoneAmounts, _ebaAmounts);
    }

    ///@dev Updates `claimable` state of `raidBoosId` raid-boss event.
    ///@dev The `raidBossId` raid-boss event has ended.
    ///@dev the caller is owner.
    function updateClaimableState(uint256 _raidBossId, bool _claimable)
        external
        onlyOwner
        onlyRaidBossExist(_raidBossId)
        onlyEnded(_raidBossId)
    {
        RaidBoss storage raidBoss = _raidBosses[_raidBossId];
        if (raidBoss.claimable != _claimable) {
            raidBoss.claimable = _claimable;
            emit ClaimableStateChanged(_raidBossId, _claimable);
        }
    }

    ///@dev Claims rewards of multi `raidBossIds` raid-boss events.
    ///@dev The `contract` is not paused.
    ///@dev the caller is anyone.
    function claimRewards(uint256[] calldata _raidBossIds)
        external
        whenNotPaused
    {
        uint256 totalEstones;
        uint256 totalEBAs;
        uint256 length = _raidBossIds.length;
        for (uint256 i = 0; i < length; ++i) {
            uint256 raidBossId = _raidBossIds[i];
            if (_raidBosses[raidBossId].claimable) {
                totalEstones += _rewardsEstone[raidBossId][_msgSender()];
                _rewardsEstone[raidBossId][_msgSender()] = 0;
                totalEBAs += _rewardsEBA[raidBossId][_msgSender()];
                _rewardsEBA[raidBossId][_msgSender()] = 0;
            }
        }
        if (totalEstones > 0) {
            currencyManager.increase(ESTONE, _msgSender(), totalEstones);
        }
        if (totalEBAs > 0) {
            EBA.transfer(_msgSender(), totalEBAs);
        }
        emit RewardsClaimed(_msgSender(), totalEstones, totalEBAs);
    }

    ///@dev Purchases batch tickets for multiple `recipients`.
    ///@dev Current event is active.
    ///@dev The caller should not be a contract.
    function purchaseBatchTickets(
        uint256 _raidBossId,
        address[] calldata _recipients,
        uint256[] calldata _amounts
    )
        external
        whenNotPaused
        onlyRaidBossExist(_raidBossId)
        onlyActive(_raidBossId)
    {
        require(
            _amounts.length == _recipients.length && _amounts.length > 0,
            "Invalid parameters"
        );

        RaidBoss memory boss = _raidBosses[_raidBossId];
        uint256 totalPrice;
        uint256 dayOfRaidBoss = (block.timestamp - boss.startTime) / 1 days;
        uint256 length = _amounts.length;
        for (uint256 i = 0; i < length; ++i) {
            require(_recipients[i] != address(0), "TZA");
            require(_amounts[i] > 0, "TZV");

            uint256 currentBalance = _balances[_raidBossId][_recipients[i]][
                dayOfRaidBoss
            ];
            totalPrice += _calculateTotalPrice(
                dayOfRaidBoss,
                boss.baseTicketPrice,
                currentBalance,
                _amounts[i]
            );
            _balances[_raidBossId][_recipients[i]][dayOfRaidBoss] =
                currentBalance +
                _amounts[i];
        }
        MEG.transferFrom(_msgSender(), address(this), totalPrice);
        MEG.burn(totalPrice);
        emit PurchaseBatch(_raidBossId, _msgSender(), _recipients, _amounts);
    }

    ///@dev Calculates the total price for `amount` tickets.
    ///@dev Current event is happening.
    ///@dev `amount` should not be a zero value.
    function calculateTotalPrice(
        uint256 _raidBossId,
        uint256 _amount,
        address _recipient
    )
        external
        view
        onlyRaidBossExist(_raidBossId)
        onlyActive(_raidBossId)
        onlyNonZeroValue(_amount)
        onlyNonZeroAddress(_recipient)
        returns (uint256)
    {
        RaidBoss memory boss = _raidBosses[_raidBossId];
        uint256 dayOfRaidBoss = (block.timestamp - boss.startTime) / 1 days;
        return
            _calculateTotalPrice(
                dayOfRaidBoss,
                boss.baseTicketPrice,
                _balances[_raidBossId][_recipient][dayOfRaidBoss],
                _amount
            );
    }

    function _calculateTotalPrice(
        uint256 _dayOfRaidBoss,
        uint256 _baseTicketPrice,
        uint256 _currentBalance,
        uint256 _amount
    ) internal view returns (uint256) {
        if (_dayOfRaidBoss < unlimitedDay) {
            require(
                _currentBalance + _amount <= maxPurchaseAmount,
                "Purchase amount exceeds maximum"
            );
        }
        uint256 total;
        for (uint256 i = 0; i < _amount; ++i) {
            uint256 times = _currentBalance >= priceMultipliers.length
                ? priceMultipliers.length - 1
                : _currentBalance;
            total += (_baseTicketPrice * priceMultipliers[times]) / 100;
            ++_currentBalance;
        }
        return total;
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface ICurrencyManager {
    function increase(
        bytes32 currency,
        address account,
        uint256 amount
    ) external;

    function decrease(
        bytes32 currency,
        address account,
        uint256 amount
    ) external;

    function balanceOf(address account, bytes32 currency)
        external
        view
        returns (uint256);

    function totalSupply(bytes32 currency) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Burnable is IERC20 {
    function burn(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
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
        return !AddressUpgradeable.isContract(address(this));
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