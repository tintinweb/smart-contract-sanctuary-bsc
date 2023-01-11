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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
pragma solidity ^0.8.7;

interface IStakingWallet {
    function deposit(address staker, uint256 amount) external;
    function withdraw(address staker, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IStakingWallet.sol";

contract StakingContract is Ownable, Pausable, ReentrancyGuard {

  struct StakerInfo {
    uint256 amount;
    uint256 startTime;
    uint256 stakeRewards;
  }

  struct RateInfo {
    uint256 apy; // in percent, 10%
    uint256 startBlock;
  }
  IStakingWallet public rewardWallet;
  IStakingWallet public depositWallet;

  uint256 public stakeFee; // in percent, 10%
  uint256 public maxStake;
  address public feeReceiver;

  // Staker Info
  mapping(address => StakerInfo) public staker;
  mapping(uint256 => address) private _stakerMap;

  uint256 public constant YEAR_SECOND = 31577600;
  IERC20 public immutable teletreonToken;
  RateInfo[] public rate;

  event LogStake(address indexed from, uint256 amount);
  event LogUnstake(address indexed from, uint256 amount, uint256 amountRewards);
  event LogRewardsWithdrawal(address indexed to, uint256 amount);
  event LogTokenRecovery(address tokenRecovered, uint256 amount);
  event LogChangeRewardWallet(IStakingWallet _old, IStakingWallet _new);
  event LogChangeDepositWallet(IStakingWallet _old, IStakingWallet _new);
  event LogFillReward(address filler, uint256 amount);
  event LogChangeRate(address changer, uint256 newRate);

  constructor(
    IERC20 _teletreonToken,
    uint256 _rate
  ) {
    teletreonToken = _teletreonToken;
    rate.push(RateInfo(block.timestamp, _rate));
  }

  function setRewardWallet(IStakingWallet _addr) external onlyOwner {
    emit LogChangeRewardWallet(rewardWallet, _addr);
    rewardWallet = _addr;
  }

  function setRate(uint256 _newRate) external onlyOwner {
    emit LogChangeRate(msg.sender, _newRate);
    rate.push(RateInfo(block.timestamp, _newRate));
  }

  function setFeeReceiver(address _addr) external onlyOwner {
    feeReceiver = _addr;
  }

  function setStakeFee(uint256 _fee) external onlyOwner {
    stakeFee = _fee;
  }

  function setDepositWallet(IStakingWallet _addr) external onlyOwner {
    emit LogChangeDepositWallet(depositWallet, _addr);
    depositWallet = _addr;
  }

  function stake(uint256 _amount) external whenNotPaused {
    require(address(rewardWallet) != address(0), "Reward Wallet not Set");
    require(address(depositWallet) != address(0), "Deposit Wallet not Set");
    require(_amount > 100 && _amount < maxStake, "Forbidden Amount");
    require(teletreonToken.allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance.");
    require(teletreonToken.balanceOf(msg.sender) >= _amount, "Insufficient teletreonToken balance");
    if (staker[msg.sender].amount > 0) {
      staker[msg.sender].stakeRewards = getTotalRewards(msg.sender);
    } 

    uint256 feeAmount = _amount * stakeFee / 100;
    uint256 stakedAmount = _amount - feeAmount;
    /**
     * Process fee
     */

    require(teletreonToken.transferFrom(msg.sender, feeReceiver, feeAmount), "Transferfrom Failed");
    require(teletreonToken.transferFrom(msg.sender, address(depositWallet), stakedAmount), "Transferfrom Failed");
    depositWallet.deposit(msg.sender, stakedAmount);

    staker[msg.sender].amount += stakedAmount;
    staker[msg.sender].startTime = block.timestamp;

    emit LogStake(msg.sender, _amount);
  }

  function unstake(uint256 _amount) external whenNotPaused nonReentrant {
    require(_amount > 0, "Unstaking amount must be greater than zero");
    require(staker[msg.sender].amount >= _amount, "Insufficient unstake");


    uint256 amountReward = _withdrawRewards();
    staker[msg.sender].amount -= _amount;
    staker[msg.sender].startTime = block.timestamp;
    staker[msg.sender].stakeRewards = 0;
    /**
     * withdraw first and then transfer back the fee 
     */
    depositWallet.withdraw(msg.sender, _amount);
    uint256 feeAmount = _amount * stakeFee / 100;
    require(teletreonToken.transferFrom(msg.sender, feeReceiver, feeAmount), "Transferfrom Failed");

    emit LogUnstake(msg.sender, _amount, amountReward);
  }

  function fillRewards(uint256 _amount) external whenNotPaused {
    require(address(rewardWallet) != address(0), "Reward Wallet not Set");
    require(_amount > 0, "reward amount must be greater than zero");
    require(teletreonToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");
    require(teletreonToken.transferFrom(msg.sender, address(rewardWallet), _amount), "TransferFrom fail");

    emit LogFillReward(msg.sender, _amount);
  }

  function _withdrawRewards() internal returns (uint256) {
    uint256 amountWithdraw = getTotalRewards(msg.sender);
    if (amountWithdraw > 0) {
      rewardWallet.withdraw(msg.sender, amountWithdraw);
    }
    return amountWithdraw;
  }

  function withdrawRewards() external whenNotPaused nonReentrant {
    uint256 amountWithdraw = _withdrawRewards();
    require(amountWithdraw > 0, "Insufficient rewards balance");
    staker[msg.sender].startTime = block.timestamp;
    staker[msg.sender].stakeRewards = 0;

    emit LogRewardsWithdrawal(msg.sender, amountWithdraw);
  }

  function getTotalRewards(address _staker) public view returns (uint256) {
    uint256 rateLenght = rate.length;
    uint256 newRewards = 0;

    for (uint256 i = 0; i < rateLenght; i++) {
      if (staker[_staker].startTime < rate[i].startBlock) {
        newRewards = newRewards + ((block.timestamp - staker[_staker].startTime) * staker[_staker].amount * rate[i].apy) /
      (YEAR_SECOND * 100);
      }
    }

    return newRewards + staker[_staker].stakeRewards;
  }

  function calculateRewards(uint256 _start, uint256 _amount) public view returns (uint256) {
    uint256 newRewards = ((block.timestamp - _start) * _amount * rate[rate.length - 1].apy) / (YEAR_SECOND * 100);
    return newRewards;
  }

  function getPendingRewards(address _staker) public view returns (uint256) {
    return staker[_staker].stakeRewards;
  }

  function setPause() external onlyOwner {
    _pause();
  }

  function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
    require(_tokenAddress != address(teletreonToken), "Cannot be staked token");
    IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);

    emit LogTokenRecovery(_tokenAddress, _tokenAmount);
  }

    

  function setUnpause() external onlyOwner {
    _unpause();
  }
}