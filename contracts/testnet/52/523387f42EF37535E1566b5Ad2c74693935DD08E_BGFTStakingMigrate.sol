pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IBGOFStakingOld.sol";

interface IBGOFStaking {
  function bgftStake(
    address user,
    uint256 _amount,
    uint256 _packageId
  ) external;
}

contract BGFTStakingMigrate is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
  string public name = "BGOF Staking";

  uint256 profileId;
  uint256 packageId;
  uint256 public totalStaking;
  uint256 public totalClaimedStaking;
  uint256 public totalProfit;
  uint256 public totalClaimedProfit;
  address public accountReward;
  address public accountStake;
  address public bgofStaking;
  IERC20 public stakeToken;
  IERC20 public rewardToken;
  // @todo switch back to mainnet
  uint256 public PERIOD = 30 days;
  // uint256 public PERIOD = 600;
  uint256 public rateReward = 100;

  bool public paused = false;

  bool public isRestake = true;

  mapping(uint256 => uint256[]) public lockups;

  IBGOFStakingOld.UserInfo[] public userInfo;

  mapping(uint256 => IBGOFStakingOld.Package) public packages;

  event Deposit(address by, uint256 amount);
  event ClaimProfit(address by, uint256 amount);
  event ClaimStaking(address by, uint256 amount);

  function initialize(address oldBGFTStaking, address _bgofStaking) public initializer {
    __ReentrancyGuard_init();
    __Ownable_init();

    bgofStaking = _bgofStaking;

    IBGOFStakingOld oldBgft = IBGOFStakingOld(oldBGFTStaking);

    stakeToken = IERC20(oldBgft.stakeToken());
    rewardToken = IERC20(oldBgft.rewardToken());

    accountReward = oldBgft.accountReward();
    accountStake = oldBgft.accountStake();

    packages[1] = oldBgft.packages(1);
    lockups[1] = oldBgft.getLockups(1);

    packages[2] = oldBgft.packages(2);
    lockups[2] = oldBgft.getLockups(2);

    packages[3] = oldBgft.packages(3);
    lockups[3] = oldBgft.getLockups(3);

    packageId = 4;

    uint256 profileLength = oldBgft.getProfilesLength();

    profileId = profileLength;

    for (uint256 i = 0; i < profileLength; i++) {
      IBGOFStakingOld.UserInfo memory _data = oldBgft.userInfo(i);
      userInfo.push(_data);
    }

    totalClaimedProfit = oldBgft.totalClaimedProfit();
    totalProfit = oldBgft.totalProfit();
    totalStaking = oldBgft.totalStaking();
    totalClaimedStaking = oldBgft.totalClaimedStaking();
  }

  function sync(address oldBGOFStaking) public {
    IBGOFStakingOld oldBgof = IBGOFStakingOld(oldBGOFStaking);

    stakeToken = IERC20(oldBgof.stakeToken());
    rewardToken = IERC20(oldBgof.rewardToken());

    accountReward = oldBgof.accountReward();
    accountStake = oldBgof.accountStake();

    packages[1] = oldBgof.packages(1);
    lockups[1] = oldBgof.getLockups(1);

    packages[2] = oldBgof.packages(2);
    lockups[2] = oldBgof.getLockups(2);

    packages[3] = oldBgof.packages(3);
    lockups[3] = oldBgof.getLockups(3);

    packageId = 4;

    uint256 profileLength = oldBgof.getProfilesLength();

    profileId = profileLength;

    for (uint256 i = 0; i < profileLength; i++) {
      IBGOFStakingOld.UserInfo memory _data = oldBgof.userInfo(i);
      userInfo.push(_data);
    }

    totalClaimedProfit = oldBgof.totalClaimedProfit();
    totalProfit = oldBgof.totalProfit();
    totalStaking = oldBgof.totalStaking();
    totalClaimedStaking = oldBgof.totalClaimedStaking();
  }

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() public onlyOwner {
    paused = true;
  }

  function setReskate(bool _isRestake) public onlyOwner {
    isRestake = _isRestake;
  }

  function unpause() public onlyOwner {
    paused = false;
  }

  // Add package
  function addPackage(
    uint256 _totalPercentProfit,
    uint256 _vestingTime,
    uint256[] memory _lockups
  ) public onlyOwner {
    require(_totalPercentProfit > 0, "Profit can not be 0");
    require(_vestingTime > 0, "Vesting time can not be 0");
    packages[packageId] = IBGOFStakingOld.Package(_totalPercentProfit, _vestingTime, true);
    lockups[packageId] = _lockups;
    packageId++;
  }

  function setPackage(uint256 _packageId, bool _isActive) public onlyOwner {
    require(packages[_packageId].totalPercentProfit > 0, "Invalid package id");
    packages[_packageId].isActive = _isActive;
  }

  function setStakeToken(IERC20 _stakeToken) public onlyOwner {
    stakeToken = _stakeToken;
  }

  function setRewardToken(IERC20 _rewardToken) public onlyOwner {
    rewardToken = _rewardToken;
  }

  function setRateReward(uint256 _rate) public onlyOwner {
    require(_rate > 0, "Reward can not be 0");
    rateReward = _rate;
  }

  function getLockups(uint256 _packageId) public view returns (uint256[] memory) {
    return lockups[_packageId];
  }

  function getProfilesByAddress(address user)
    public
    view
    returns (IBGOFStakingOld.UserInfo[] memory)
  {
    uint256 total = 0;
    for (uint256 i = 0; i < userInfo.length; i++) {
      if (userInfo[i].user == user) {
        total++;
      }
    }

    require(total > 0, "Invalid profile address");

    IBGOFStakingOld.UserInfo[] memory profiles = new IBGOFStakingOld.UserInfo[](total);
    uint256 j;

    for (uint256 i = 0; i < userInfo.length; i++) {
      if (userInfo[i].user == user) {
        profiles[j] = userInfo[i]; // step 3 - fill the array
        j++;
      }
    }

    return profiles;
  }

  function getProfilesLength() public view returns (uint256) {
    return userInfo.length;
  }

  function stake(uint256 _amount, uint256 _packageId) public payable {
    require(_amount > 0, "Amount cannot be 0");
    require(packages[_packageId].totalPercentProfit > 0, "Invalid package id");
    require(packages[_packageId].isActive == true, "This package is not available");

    stakeToken.transferFrom(msg.sender, accountStake, _amount);

    _stake(msg.sender, _amount, _packageId);

    // uint256 profit = (_amount * packages[_packageId].totalPercentProfit) / 100;

    // IBGOFStakingOld.UserInfo memory profile;
    // profile.id = profileId;
    // profile.packageId = _packageId;
    // profile.user = msg.sender;
    // profile.amount = _amount;
    // profile.profitClaimed = 0;
    // profile.stakeClaimed = 0;
    // profile.vestingStart = block.timestamp;
    // profile.vestingEnd = block.timestamp + packages[_packageId].vestingTime * PERIOD;
    // profile.refunded = false;
    // profile.totalProfit = profit;
    // userInfo.push(profile);

    // profileId++;

    // totalStaking += _amount;

    // totalProfit += profit;

    // emit Deposit(msg.sender, _amount);
  }

  function _stake(
    address user,
    uint256 _amount,
    uint256 _packageId
  ) internal {
    uint256 profit = (_amount * packages[_packageId].totalPercentProfit) / 100;

    IBGOFStakingOld.UserInfo memory profile;
    profile.id = profileId;
    profile.packageId = _packageId;
    profile.user = user;
    profile.amount = _amount;
    profile.profitClaimed = 0;
    profile.stakeClaimed = 0;
    profile.vestingStart = block.timestamp;
    profile.vestingEnd = block.timestamp + packages[_packageId].vestingTime * PERIOD;
    profile.refunded = false;
    profile.totalProfit = profit;
    userInfo.push(profile);

    profileId++;

    totalStaking += _amount;

    totalProfit += profit;

    emit Deposit(user, _amount);
  }

  function getCurrentProfit(uint256 _profileId) public view returns (uint256) {
    require(userInfo[_profileId].packageId != 0, "Invalid profile");

    IBGOFStakingOld.UserInfo memory info = userInfo[_profileId];

    if (block.timestamp > info.vestingEnd) {
      return info.totalProfit;
    }

    uint256 profit = ((block.timestamp - info.vestingStart) * info.totalProfit) /
      (info.vestingEnd - info.vestingStart);
    return profit;
  }

  function claimProfit(uint256 _profileId) public nonReentrant whenNotPaused {
    require(userInfo[_profileId].user == msg.sender, "You are not onwer");
    IBGOFStakingOld.UserInfo storage info = userInfo[_profileId];

    uint256 profit = getCurrentProfit(_profileId);
    uint256 remainProfit = profit - info.profitClaimed;

    require(remainProfit > 0, "No profit");

    uint256 netReward = (remainProfit * rateReward) / 100;

    if (isRestake) {
      IBGOFStaking(bgofStaking).bgftStake(msg.sender, netReward, 3);
    } else {
      rewardToken.transferFrom(accountReward, msg.sender, netReward);
      info.profitClaimed += remainProfit;

      // Update total profit claimed
      totalClaimedProfit += profit;

      emit ClaimProfit(msg.sender, remainProfit);
    }
  }

  function getCurrentStakeUnlock(uint256 _profileId) public view returns (uint256) {
    require(userInfo[_profileId].packageId != 0, "Invalid profile");

    IBGOFStakingOld.UserInfo memory info = userInfo[_profileId];

    uint256[] memory pkgLockups = getLockups(info.packageId);

    if (block.timestamp < info.vestingEnd) {
      return 0;
    }

    // Not lockup, can withdraw 100% after vesting time
    if (pkgLockups.length == 1 && pkgLockups[0] == 100) {
      return info.amount;
    }

    uint256 length = pkgLockups.length;

    for (uint256 i = length - 1; i >= 0; i--) {
      // Index + 1 = amount of months
      uint256 limitWithdrawTime = info.vestingEnd + (i + 1) * PERIOD;
      if (block.timestamp > limitWithdrawTime) {
        return (pkgLockups[i] * info.amount) / 100;
      }
    }

    return 0;
  }

  function claimStaking(uint256 _profileId) public nonReentrant whenNotPaused {
    require(userInfo[_profileId].user == msg.sender, "You are not onwer");
    require(userInfo[_profileId].vestingEnd < block.timestamp, "Can not claim before vesting end");

    IBGOFStakingOld.UserInfo storage info = userInfo[_profileId];
    uint256 amountUnlock = getCurrentStakeUnlock(_profileId);

    uint256 remainAmount = amountUnlock - info.stakeClaimed;

    require(remainAmount > 0, "No staking");

    stakeToken.transferFrom(accountStake, msg.sender, remainAmount);
    info.stakeClaimed += remainAmount;

    // Update total staking
    totalClaimedStaking += remainAmount;

    emit ClaimStaking(msg.sender, remainAmount);
  }

  function withdraw(uint256 _amount) public onlyOwner {
    stakeToken.transfer(msg.sender, _amount);
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (proxy/utils/Initializable.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

pragma solidity >=0.8.1;

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

pragma solidity >=0.8.1;

interface IBGOFStakingOld {
  struct UserInfo {
    uint256 id;
    address user;
    uint256 amount; // How many tokens the user has provided.
    uint256 profitClaimed; // default false
    uint256 stakeClaimed; // default false
    uint256 vestingStart;
    uint256 vestingEnd;
    uint256 totalProfit;
    uint256 packageId;
    bool refunded;
  }

  struct Package {
    uint256 totalPercentProfit; // 5 = 5%
    uint256 vestingTime; // 1 = 1 month
    bool isActive;
  }

  function totalStaking() external view returns (uint256);

  function totalProfit() external view returns (uint256);

  function totalClaimedStaking() external view returns (uint256);

  function totalClaimedProfit() external view returns (uint256);

  function stakeToken() external view returns (address);

  function rewardToken() external view returns (address);

  function rateReward() external view returns (uint256);

  function accountStake() external view returns (address);

  function accountReward() external view returns (address);

  function packages(uint256 index) external view returns (Package memory);

  function getLockups(uint256 index) external view returns (uint256[] memory);

  function getProfilesLength() external view returns (uint256);

  function userInfo(uint256 input) external view returns (UserInfo memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0-rc.1) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
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