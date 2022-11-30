pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IBGOFStakingOld.sol";

interface IBGOFStaking {
  function bfgtStake(address user, uint256 _amount, uint256 _packageId) external;
}

contract FarmBFGTV3 is ReentrancyGuard, Ownable {
  string public name = "Farm BFGT V3";

  uint256 profileId;
  uint256 packageId = 4;
  uint256 public totalStaking = 0;
  uint256 public totalClaimedStaking = 0;
  uint256 public totalProfit = 0;
  uint256 public totalClaimedProfit = 0;
  address public accountReward;
  address public accountStake;
  address public bgofStaking;
  IERC20 public stakeToken;
  IERC20 public rewardToken;

  // @important mainnet
  uint256 public PERIOD = 30 days;
  uint256 public rateReward = 100;

  bool public paused = false;

  bool public isRestake = false;

  mapping(uint256 => uint256[]) public lockups;

  IBGOFStakingOld.UserInfo[] public userInfo;

  mapping(uint256 => IBGOFStakingOld.Package) public packages;

  event Deposit(address by, uint256 amount);
  event ClaimProfit(address by, uint256 amount);
  event ClaimStaking(address by, uint256 amount);

  constructor() {
    // @important mainnet
    stakeToken = IERC20(0x382978cB7c29CaCde95dbBCe97C291156217A058);
    rewardToken = IERC20(0x5f949De3131f00B296Fc4c99058D40960B90FAbC);
    // @important mainnet
    accountReward = 0xE3D9E6c5D5a70Fd96DF18362b5bC80BEe98Bc7e4;
    accountStake = 0xE3D9E6c5D5a70Fd96DF18362b5bC80BEe98Bc7e4;

    totalClaimedProfit = 1716376767674965277777700;
    totalProfit = 5939306190000000000000000;
    totalStaking = 13367895000000000000000000;
    totalClaimedStaking = 0;
    packages[1] = IBGOFStakingOld.Package(12, 6, true);
    lockups[1] = [5, 10, 25, 40, 65, 100];
    packages[2] = IBGOFStakingOld.Package(27, 9, true);
    lockups[2] = [20, 50, 100];
    packages[3] = IBGOFStakingOld.Package(48, 12, true);
    lockups[2] = [100];
  }

  function migrate(IBGOFStakingOld.UserInfo[] memory _data) public onlyOwner {
    require(profileId == _data[0].id, "Not migrating");
    for (uint i = 0; i < _data.length; i++) {
      userInfo.push(_data[i]);
    }

    profileId += _data.length;
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

  function setPeriod(uint256 _period) public onlyOwner {
    PERIOD = _period;
  }

  function setReskate(bool _isRestake) public onlyOwner {
    isRestake = _isRestake;
  }

  function unpause() public onlyOwner {
    paused = false;
  }

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

  function getProfilesByAddress(
    address user
  ) public view returns (IBGOFStakingOld.UserInfo[] memory) {
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
  }

  function _stake(address user, uint256 _amount, uint256 _packageId) internal {
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
      IBGOFStaking(bgofStaking).bfgtStake(msg.sender, netReward, 3);
    } else {
      rewardToken.transferFrom(accountReward, msg.sender, netReward);
    }
    info.profitClaimed += remainProfit;

    // Update total profit claimed
    totalClaimedProfit += profit;

    emit ClaimProfit(msg.sender, remainProfit);
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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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