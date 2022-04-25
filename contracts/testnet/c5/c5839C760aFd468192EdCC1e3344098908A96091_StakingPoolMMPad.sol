// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import "./IBEP20.sol";

contract StakingPoolMMPad is OwnableUpgradeable, PausableUpgradeable {
    using MathUpgradeable for uint256;
    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    mapping(uint256 => CountersUpgradeable.Counter) public totalStakingInfos;
    uint16 public totalPoolConfig;
    mapping(uint32 => PoolConfig) public poolConfigs;
    mapping(uint32 => TokenPoolConfig) public tokenPoolConfigs;
    mapping(uint32 => TimePoolConfig) public timePoolConfigs;
    mapping(uint32 => RatePoolConfig) public ratePoolConfigs;
    mapping(uint256 => StakingInfo) public stakingInfos;

    struct PoolConfig {
        uint32 id;
        uint256 amount;
        uint256 maxAmount;
        uint256 minStake;
        uint256 minCheckBalance;
        bool isActive;
        
    }

    struct TokenPoolConfig {
        IBEP20 tokenStake;
        IBEP20 tokenClaim;
        IBEP20 tokenCheckBalance;
        string imageUrl; 
    }

    struct TimePoolConfig {
        uint32 totalSecond;
        uint32 timeCycle;
        uint16 totalDays;
        uint32 startTime;
        uint32 endTime;
    }

    struct RatePoolConfig {
        uint16 numeratorRateOneDay; // 130
        uint16 denominatorRateOneDay; // 100 // is mean 130% => 1.3
        uint16 numeratorStake; // rate  example  1000 TOKEN  = 1 BNB  set numeratorStake = 1000 denominatorClaim = 1
        uint16 denominatorClaim;
        
    }

    struct StakingInfo {
        uint32 id;
        address sender;
        uint32 poolConfig;
        uint256 amount;
        uint256 createdAt;
        bool isReceived;
        uint256 totalReceived; 
        uint256 timesReceived;
        uint256 timesMaxReceived;
        uint16 numeratorStake; // rate  example  1000 TOKEN  = 1 BNB  set numeratorStake = 1000 denominatorClaim = 1
        uint16 denominatorClaim; 
    }

    function initialize() public initializer {

        // TEST CLAIM
        // poolConfigs[1].timeCycle =  60; // 60s 
        // poolConfigs[1].id = 1;
        // poolConfigs[1].totalSecond = 60*10; //10 minutes
        // poolConfigs[1].amount = 0;
        // poolConfigs[1].numeratorRateOneDay  = 1;
        // poolConfigs[1].denominatorRateOneDay = 1; // 40
        // poolConfigs[1].isActive = true;
        // poolConfigs[1].numeratorStake = 1;
        // poolConfigs[1].denominatorClaim = 1;
        // poolConfigs[1].timeUnit=86400;

        // poolConfigs[2].timeCycle=  60;
        // poolConfigs[2].id = 2;
        // poolConfigs[2].totalSecond = 60*5; // 5 minutes
        // poolConfigs[2].amount = 0;
        // poolConfigs[2].numeratorRateOneDay = 1;
        // poolConfigs[2].denominatorRateOneDay = 1; // 20
        // poolConfigs[2].isActive = true;
        // poolConfigs[2].numeratorStake = 1;
        // poolConfigs[2].denominatorClaim = 1;
        // poolConfigs[2].timeUnit=86400;
        // totalPoolConfig = 2;
       
        __Ownable_init();
    }

    /**
     * @dev _startTime, _endTime, _startflashSaleTime are unix time
     * _startflashSaleTime should be equal _startTime - 300(s) [5 min]
     */
    // function initByOwner() public onlyOwner {
    // }

    function stake(uint256 _amount, uint32 _poolConfigId)
        external
        whenNotPaused
        returns (uint256)
    {
        
        require(poolConfigs[_poolConfigId].id > 0, "Pool not found");
        require(_amount > 0, "Amount must be greater than 0");
        require(poolConfigs[_poolConfigId].isActive == true, "Pool not active");
        require(
            _amount >= poolConfigs[_poolConfigId].minStake,
            "Amount must be greater than min Staking"
        );
        IBEP20 tokenCheckBalance =  IBEP20(tokenPoolConfigs[_poolConfigId].tokenCheckBalance);
        IBEP20 tokenStake =  IBEP20(tokenPoolConfigs[_poolConfigId].tokenStake);
        uint256 amountCheck = tokenCheckBalance.balanceOf(msg.sender);
        require(amountCheck >= poolConfigs[_poolConfigId].minCheckBalance, "Amount must be greater than checking balance");
        require(_amount + poolConfigs[_poolConfigId].amount <= poolConfigs[_poolConfigId].maxAmount, "Can not stake more than max amount");

        uint256 current = block.timestamp;
        totalStakingInfos[_poolConfigId].increment();
        uint32 id = uint32(totalStakingInfos[_poolConfigId].current());
        stakingInfos[id].id = id;
        stakingInfos[id].sender = msg.sender;
        stakingInfos[id].poolConfig = _poolConfigId;
        stakingInfos[id].amount = _amount;
        stakingInfos[id].createdAt = current;
        stakingInfos[id].isReceived = false;
        stakingInfos[id].totalReceived = 0;
        stakingInfos[id].timesReceived = 0;
        stakingInfos[id].numeratorStake = ratePoolConfigs[_poolConfigId].numeratorStake;
        stakingInfos[id].denominatorClaim = ratePoolConfigs[_poolConfigId].denominatorClaim;
        
        stakingInfos[id].timesMaxReceived = uint256(timePoolConfigs[_poolConfigId].totalSecond).div(timePoolConfigs[_poolConfigId].timeCycle);
        tokenStake.approve(address(this), _amount);
        tokenStake.transferFrom(msg.sender, address(this), _amount);
        poolConfigs[_poolConfigId].amount =
            poolConfigs[_poolConfigId].amount.add(_amount);
        return id;
    }

    function claim(uint32 _stakingInfoId) external whenNotPaused {
        require(stakingInfos[_stakingInfoId].id > 0, "Staking Info not found");
        require(
            stakingInfos[_stakingInfoId].sender == msg.sender,
            "Staking Info not found"
        );
        require(
            stakingInfos[_stakingInfoId].isReceived == false,
            "Staking Info is received"
        );
        uint256 current = block.timestamp;
        uint32 poolConfigId = stakingInfos[_stakingInfoId].poolConfig;
        RatePoolConfig memory ratePoolConfig = ratePoolConfigs[poolConfigId];
        TimePoolConfig memory  timePoolConfig = timePoolConfigs[poolConfigId];

        uint256 createdAt = stakingInfos[_stakingInfoId].createdAt;
        uint256 amount = stakingInfos[_stakingInfoId].amount;
       
        uint256 reward = amount
            .mul(ratePoolConfig.numeratorRateOneDay)
            .div(ratePoolConfig.denominatorRateOneDay)
            .mul(timePoolConfig.totalDays)
            .mul(stakingInfos[_stakingInfoId].numeratorStake)
            .div(stakingInfos[_stakingInfoId].denominatorClaim);

        uint256 timesMaxReceived = stakingInfos[_stakingInfoId].timesMaxReceived;
        uint256 timesReceived = stakingInfos[_stakingInfoId].timesReceived;
        uint256 timesSatisfy = (current - createdAt) / timePoolConfig.timeCycle;
        if (timesSatisfy > timesMaxReceived) {
            timesSatisfy = timesMaxReceived;
        }

        require(timesReceived < timesSatisfy, "Current dont have reward");
        uint256 total = reward * (timesSatisfy - timesReceived);

        stakingInfos[_stakingInfoId].timesReceived = timesSatisfy;
        stakingInfos[_stakingInfoId].totalReceived =
            stakingInfos[_stakingInfoId].totalReceived +
            total;
        if (current >= createdAt + timePoolConfigs[poolConfigId].totalSecond) {
            if (stakingInfos[_stakingInfoId].isReceived == false) {
                IBEP20 tokenStake= IBEP20(tokenPoolConfigs[poolConfigId].tokenStake);
                tokenStake.approve(address(this), amount);
                tokenStake.transferFrom(address(this), msg.sender, amount);
                stakingInfos[_stakingInfoId].isReceived = true;
            }
        }
        require(timesReceived < timesSatisfy, "Can't not claim");

        IBEP20 tokenClaim= IBEP20(tokenPoolConfigs[poolConfigId].tokenClaim);
        tokenClaim.approve(address(this), total);
        tokenClaim.transferFrom(address(this), msg.sender, total);
    }

    function getTimes(uint32 _stakingInfoId)
        public
        view
        returns (
            uint256 timesMaxReceived,
            uint256 timesReceived,
            uint256 timesSatisfy,
            uint256 reward
        )
    {
        uint256 current = block.timestamp;
        uint32 poolConfigId = stakingInfos[_stakingInfoId].poolConfig;
        timesMaxReceived = stakingInfos[_stakingInfoId].timesMaxReceived;
        uint256 createdAt = stakingInfos[_stakingInfoId].createdAt;
        timesSatisfy = (current - createdAt) / timePoolConfigs[poolConfigId].timeCycle;
        timesReceived = stakingInfos[_stakingInfoId].timesReceived;
        if (timesSatisfy > timesMaxReceived) {
            timesSatisfy = timesMaxReceived;
        }
        
        uint256 amount = stakingInfos[_stakingInfoId].amount;
        reward = amount
            .mul(ratePoolConfigs[poolConfigId].numeratorRateOneDay)
            .div(ratePoolConfigs[poolConfigId].denominatorRateOneDay)
            .mul(timePoolConfigs[poolConfigId].totalDays)
            .mul(stakingInfos[_stakingInfoId].numeratorStake)
            .div(stakingInfos[_stakingInfoId].denominatorClaim);
    }

    function getPoolConfig(uint32 _poolConfigId) public view returns (PoolConfig memory poolConfig,
    TimePoolConfig memory timePoolConfig, 
    RatePoolConfig memory ratePoolConfig,
    TokenPoolConfig memory tokenPoolConfig)
    {
      poolConfig= poolConfigs[_poolConfigId];
      timePoolConfig=timePoolConfigs[_poolConfigId];
      ratePoolConfig=ratePoolConfigs[_poolConfigId];
      tokenPoolConfig=tokenPoolConfigs[_poolConfigId];
    }

    function setPoolConfig(
        uint32 _id,
        uint256 _amount,
        uint256 _maxAmount,
        uint256 _minStake,
        uint256 _minCheckBalance,
        bool _isActive
    ) public onlyOwner {
        poolConfigs[_id].id = _id;
        poolConfigs[_id].amount = _amount;
        poolConfigs[_id].maxAmount = _maxAmount;
        poolConfigs[_id].isActive = _isActive;
        poolConfigs[_id].minStake = _minStake;
        poolConfigs[_id].minCheckBalance = _minCheckBalance;
    }

    function setTimePoolConfig(
        uint32 _id,
        uint32 _totalSecond,
        uint32 _timeCycle,
        uint16 _totalDays,
        uint32 _startTime,
        uint32 _endTime
    ) public onlyOwner {
        poolConfigs[_id].id = _id;
        timePoolConfigs[_id].totalSecond = _totalSecond;
        timePoolConfigs[_id].timeCycle = _timeCycle;
        timePoolConfigs[_id].totalDays = _totalDays;
        timePoolConfigs[_id].startTime=_startTime;
        timePoolConfigs[_id].endTime=_endTime;
    }

    function setRatePoolConfig(
        uint32 _id,
        uint16 _numeratorRateOneDay,
        uint16 _denominatorRateOneDay,
        uint16 _numeratorStake,
        uint16 _denominatorClaim
    ) public onlyOwner {
        ratePoolConfigs[_id].numeratorRateOneDay = _numeratorRateOneDay;
        ratePoolConfigs[_id].denominatorRateOneDay = _denominatorRateOneDay;
        ratePoolConfigs[_id].numeratorStake = _numeratorStake;
        ratePoolConfigs[_id].denominatorClaim = _denominatorClaim;
    }

    function setTokenPoolConfig(
        uint32 _id,
        IBEP20 _tokenStake,
        IBEP20 _tokenClaim,
        IBEP20 _tokenCheckBalance,
        string memory _imageUrl
    ) public onlyOwner {
        tokenPoolConfigs[_id].tokenStake = _tokenStake;
        tokenPoolConfigs[_id].tokenClaim = _tokenClaim;
        tokenPoolConfigs[_id].tokenCheckBalance = _tokenCheckBalance;
        tokenPoolConfigs[_id].imageUrl = _imageUrl;
    }

    function setMinStakePoolConfig(
        uint32 _id,
        uint256 _minStake
    ) public onlyOwner {
        poolConfigs[_id].minStake = _minStake;
    }

    function setMinCheckBalancePoolConfig(
        uint32 _id,
        uint256 _minCheckBalance
    ) public onlyOwner {
        poolConfigs[_id].minCheckBalance = _minCheckBalance;
    }

    function setActivePoolConfig(
        uint32 _id,
        bool _isActive
    ) public onlyOwner {
        poolConfigs[_id].isActive = _isActive;
    }

    function getStakingInfo(uint32 _stakingInfoId) public view returns (StakingInfo memory)
    {
        return stakingInfos[_stakingInfoId];
    }

    function getStakingInfos(uint32 _poolConfigId, address sender)
        external
        view
        returns (StakingInfo[] memory)
    {
        uint256 range = totalStakingInfos[_poolConfigId].current();
        uint256 i = 1;
        uint256 index = 0;
        uint256 x = 0;
        for (i; i <= range; i++) {
            if (stakingInfos[i].sender == sender) {
                if (stakingInfos[i].poolConfig == _poolConfigId) {
                    index++;
                }
            }
        }
        StakingInfo[] memory result = new StakingInfo[](index);
        i = 1;
        for (i; i <= range; i++) {
            if (stakingInfos[i].sender == sender) {
                if (stakingInfos[i].poolConfig == _poolConfigId) {
                    result[x] = stakingInfos[i];
                    x++;
                }
            }
        }
        return result;
    }

    function getAllStakingInfos(uint32 _poolConfigId)
        external
        view
        returns (StakingInfo[] memory)
    {
        uint256 range = totalStakingInfos[_poolConfigId].current();
        uint256 i = 1;
        uint256 index = 0;
        uint256 x = 0;
        for (i; i <= range; i++) {
            if (stakingInfos[i].poolConfig == _poolConfigId) {
                index++;
            }
        }
        StakingInfo[] memory result = new StakingInfo[](index);
        i = 1;
        for (i; i <= range; i++) {
            if (stakingInfos[i].poolConfig == _poolConfigId) {
                result[x] = stakingInfos[i];
                x++;
            }
        }
        return result;
    }

    function getPoolConfigs() external view returns (PoolConfig[] memory) {
        uint32 range = totalPoolConfig;
        PoolConfig[] memory result = new PoolConfig[](range);
        uint32 i = 1;
        uint32 index = 0;
        for (i; i <= range; i++) {
            result[index] = poolConfigs[i];
            index++;
        }
        return result;
    }

    function getTokenPoolConfigs() external view returns (TokenPoolConfig[] memory) {
        uint32 range = totalPoolConfig;
        TokenPoolConfig[] memory result = new TokenPoolConfig[](range);
        uint32 i = 1;
        uint32 index = 0;
        for (i; i <= range; i++) {
            result[index] = tokenPoolConfigs[i];
            index++;
        }
        return result;
    }

    function getRatePoolConfigs() external view returns (RatePoolConfig[] memory) {
        uint32 range = totalPoolConfig;
        RatePoolConfig[] memory result = new RatePoolConfig[](range);
        uint32 i = 1;
        uint32 index = 0;
        for (i; i <= range; i++) {
            result[index] = ratePoolConfigs[i];
            index++;
        }
        return result;
    }

    function getTimePoolConfigs() external view returns (TimePoolConfig[] memory) {
        uint32 range = totalPoolConfig;
        TimePoolConfig[] memory result = new TimePoolConfig[](range);
        uint32 i = 1;
        uint32 index = 0;
        for (i; i <= range; i++) {
            result[index] = timePoolConfigs[i];
            index++;
        }
        return result;
    }

    function setTotalPoolConfig(uint16 _totalPoolConfig) public onlyOwner {
        totalPoolConfig = _totalPoolConfig;
    }

    function getTotalPoolConfig() public view returns (uint16) {
        return totalPoolConfig;
    }

    function withdraw(uint256 amount, address _token) public onlyOwner {
        IBEP20 bep20=IBEP20(_token);
        require(amount <= bep20.balanceOf(address(this)));
        bep20.approve(address(this), amount);
        bep20.transferFrom(address(this), msg.sender, amount);
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        _unpause();
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
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
library SafeMathUpgradeable {
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