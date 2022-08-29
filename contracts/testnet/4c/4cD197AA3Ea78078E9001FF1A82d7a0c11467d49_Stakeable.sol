// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IToken{

  function balanceOf(address account) external returns (uint256);
  function transfer(address to, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external returns (uint256);

}

contract Stakeable is Ownable, ReentrancyGuard {

  struct Staker {
    uint256 deposited;
    uint256 timeOfLastUpdate;
    uint256 unclaimedRewards;
    uint256 harvestedRewards;
  }

  // The token being staked
  IToken public token;

  uint256 public stakingStart;
  uint256 public stakingEnd;
  uint256 public rewardsPerHour = 285; // 0.00285%/h or 25% APY
  uint256 public currentAPY = 250; // % * 10 = 25%

  uint256 public prevStakingStart;
  uint256 public prevStakingEnd;
  uint256 public prevRewardsPerHour;

  // Minimum amount to stake
  uint256 public minStake = 0;

  // Amount of wei raised
  uint256 public weiHarvested;
  uint256 public weiStaked;

  uint256 public emergencyWithdrawTax = 50;

  // Mapping of address to Staker info
  mapping(address => Staker) internal stakers;

  event NewStakingStarted(uint256 _stakingStart, uint256 _stakingEnd, uint256 _rewardsPerHour);

  event TokensStaked(
    address indexed staker,
    uint256 value
  );

  event TokensWithdrawn(
    address indexed staker,
    uint256 value
  );

  event TokensHarvested(
    address indexed staker,
    uint256 value
  );

  /**
   * @param _token Address of the token being staked
   */
  constructor(address _token)
  {
    token = IToken(_token);
  }

  function setStakingPeriod(uint256 _stakingStart, uint256 _stakingEnd, uint256 _apy) public onlyOwner {
    require(stakingEnd < block.timestamp, "Current staking period has not ended");
    require(_stakingEnd > _stakingStart && _stakingEnd > block.timestamp, "Invalid period specified");
    if (stakingStart > 0 && stakingEnd > 0 && rewardsPerHour > 0) {
      prevStakingStart = stakingStart;
      prevStakingEnd = stakingEnd;
      prevRewardsPerHour = rewardsPerHour;
    }
    stakingStart = _stakingStart;
    stakingEnd = _stakingEnd;
    currentAPY = _apy;
    rewardsPerHour = ( _apy * 10_000 ) / 8760;
    emit NewStakingStarted(stakingStart, stakingEnd, rewardsPerHour);
  }

  function setAPY(uint256 _apy) public onlyOwner {
    currentAPY = _apy;
    rewardsPerHour = ( _apy * 10_000 ) / 8760;
  }

  /**
   * @dev Set the minimum amount for staking in wei
   */
  function setMinStake(uint256 _minStake) public onlyOwner {
    minStake = _minStake;
  }

  function setEmergencyWithdrawTax(uint256 _taxPercent) public onlyOwner {
    require(_taxPercent <= 50, "Tax needs to be less than 50%");
    emergencyWithdrawTax = _taxPercent;
  }

  // If address has no Staker struct, initiate one. If address already was a stake,
  // calculate the rewards and add them to unclaimedRewards, reset the last time of
  // deposit and then add _amount to the already deposited amount.
  // Burns the amount staked.
  /**
   * @dev Deposit amount
   */
  function deposit(uint256 _amount) external nonReentrant {
    require(_amount >= minStake, "Amount smaller than minimum deposit");
    require(token.balanceOf(msg.sender) >= _amount, "Can't stake more than you own");
    require(token.allowance(msg.sender, address(this)) >= _amount, "Not enough allowance");
    token.transferFrom(msg.sender, address(this), _amount);
    if (stakers[msg.sender].deposited == 0) {
      stakers[msg.sender].deposited = _amount;
      stakers[msg.sender].timeOfLastUpdate = block.timestamp;
      stakers[msg.sender].unclaimedRewards = 0;
    } else {
      uint256 rewards = getRewards(msg.sender);
      stakers[msg.sender].unclaimedRewards += rewards;
      stakers[msg.sender].deposited += _amount;
      stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    }
    weiStaked += _amount;
  }

  /**
   * @dev Transfers rewards to msg.sender
   */
  function harvest() external nonReentrant {
    uint256 rewards = getRewards(msg.sender) + stakers[msg.sender].unclaimedRewards;
    require(rewards > 0, "You have no rewards");
    require(rewards <= token.balanceOf(address(this)), "Insufficient reward funds");
    stakers[msg.sender].harvestedRewards += stakers[msg.sender].unclaimedRewards;
    stakers[msg.sender].unclaimedRewards = 0;
    stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    token.transfer(msg.sender, rewards);
    weiHarvested += rewards;
  }

  /**
   * @dev Withdraw specified amount of staked tokens
   */
  function withdraw(uint256 _amount) external nonReentrant {
    require(
      stakers[msg.sender].deposited >= _amount,
      "Can't withdraw more than you have"
    );
    uint256 _rewards = getRewards(msg.sender);
    stakers[msg.sender].deposited -= _amount;
    // if new staking period started and not yet finished apply emergency tax
    if (block.timestamp > stakingStart && block.timestamp < stakingEnd
      && stakers[msg.sender].timeOfLastUpdate > prevStakingEnd) {
      _amount -= ( _amount * emergencyWithdrawTax ) / 100;
    }
    require(_amount <= token.balanceOf(address(this)), "Insufficient pool funds");
    stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    stakers[msg.sender].unclaimedRewards = _rewards;
    token.transfer(msg.sender, _amount);
    weiStaked -= _amount;
  }

  /**
   * @dev Get deposit info
   */
  function getDepositInfo(address _addr)
  public
  view
  returns (uint256 _stake, uint256 _rewards, uint256 _harvested)
  {
    _stake = stakers[_addr].deposited;
    _harvested = stakers[_addr].harvestedRewards;
    _rewards = getRewards(_addr) + stakers[msg.sender].unclaimedRewards;
    return (_stake, _rewards, _harvested);
  }

  /**
   * @dev Get rewards info
   */
  function getRewards(address addr)
  internal
  view
  returns (uint256)
  {
    uint256 rewards = 0;
    if (stakers[addr].deposited > 0) {
      uint256 lastUpdate = stakers[addr].timeOfLastUpdate;
      if (lastUpdate < prevStakingEnd) {
        if (lastUpdate < prevStakingStart) {
          lastUpdate = prevStakingStart;
        }
        rewards += calculateRewards(addr, prevStakingEnd - lastUpdate, prevRewardsPerHour);
      }
      if (block.timestamp >= stakingStart) {
        if (lastUpdate < stakingStart) {
          lastUpdate = stakingStart;
        }
        rewards += calculateRewards(
          addr,
          (stakingEnd < block.timestamp ? stakingEnd : block.timestamp) - lastUpdate,
          rewardsPerHour
        );
      }
    }
    return rewards;
  }

  /**
   * @dev Calculate the rewards since the last update on Deposit info
   */
  function calculateRewards(address addr, uint256 timeInSeconds, uint256 _rewardsPerHour)
  internal
  view
  returns (uint256 rewards)
  {
    return ((((
      timeInSeconds
      * stakers[addr].deposited)
      * _rewardsPerHour)
      / 3600)
      / 10_000_000
    );
  }

  function rescueBNB() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function withdrawTaxes() external onlyOwner {
    require(token.balanceOf(address(this)) - weiStaked > 0, "Taxes vault empty");
    token.transfer(msg.sender, token.balanceOf(address(this)) - weiStaked);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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