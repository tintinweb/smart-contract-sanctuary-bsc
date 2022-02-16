/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

// SPDX-License-Identifier: UNLICENSED

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


interface IPresale {
  function getPresaleTokensToRedeem(address wallet) external view returns (uint256);

  function getPresaleTokensSold() external view returns (uint256);

  function getPresaleHasEnded() external view returns (bool);
}

contract Vesting is Ownable {
  IERC20 token;
  IPresale presale;

  // set to true when the contract owns all the required token
  bool public initialized;
  uint256 public deployTimestamp;

  uint256 public totalRedeemed;
  mapping(address => uint256) public redeemed;

  uint64[] public tickCompoundedDurationInSec;
  uint64[] public tickCompoundedPercentageUnlocked;

  constructor(
    address _token,
    address _presaleAddress,
    uint64[] memory _tickCompoundedPercentageUnlocked,
    uint64[] memory _tickCompoundedDurationInSec) {
    // input validation
    require(_tickCompoundedPercentageUnlocked.length == _tickCompoundedDurationInSec.length, "Tick duration & percentages need to have the same size.");
    require(_tickCompoundedPercentageUnlocked.length > 0, "Must have at least one tick.");

    token = IERC20(_token);
    presale = IPresale(_presaleAddress);
    tickCompoundedPercentageUnlocked = _tickCompoundedPercentageUnlocked;
    tickCompoundedDurationInSec = _tickCompoundedDurationInSec;

    // last % tick is 100
    require(_tickCompoundedPercentageUnlocked[_tickCompoundedPercentageUnlocked.length - 1] == 100, "Need to give out exactly 100 percentages.");

    // make sure all compounded entries are increasing
    for (uint256 i = 1; i < _tickCompoundedDurationInSec.length; i++) {
      require(_tickCompoundedDurationInSec[i] > _tickCompoundedDurationInSec[i - 1], "Ticks compound duration needs to increase.");
      require(_tickCompoundedPercentageUnlocked[i] > _tickCompoundedPercentageUnlocked[i - 1], "Ticks compound percentage needs to increase.");
    }
  }

  function initialize() external {
    require(initialized == false, "Already initialized.");
    require(presale.getPresaleHasEnded() == true, "Presale has not ended yet.");
    // Ensure the contract owns all the token that it needs to give out - this should never happen.
    require(token.balanceOf(address(this)) >= presale.getPresaleTokensSold(), "Insufficient tokens in contract. Add more.");

    // Transfer back the extra tokens to the owner - this should never happen, but again just as a safety net.
    token.transfer(owner(), token.balanceOf(address(this)) - presale.getPresaleTokensSold());

    initialized = true;
    deployTimestamp = block.timestamp;
  }

  function initialToRedeem(address wallet) public view returns (uint256) {
    return presale.getPresaleTokensToRedeem(wallet);
  }

  function initialTotalToRedeem() public view returns (uint256) {
    return presale.getPresaleTokensSold();
  }

  function _unlockedPercentageFromTimestamp(uint256 timestamp) private view returns (uint256) {
    if (timestamp < deployTimestamp) {
      return 0;
    }
    uint256 diff = timestamp - deployTimestamp;
    if (tickCompoundedDurationInSec[0] > diff) {
      return 0;
    }
    // TODO: Why this casting? I didn't use it in other contracts.
    for (int256 i = int256(tickCompoundedDurationInSec.length) - 1; i >= 0; i--) {
      if (diff >= tickCompoundedDurationInSec[uint256(i)]) {
        return tickCompoundedPercentageUnlocked[uint256(i)];
      }
    }

    require(false, "Impossible scenario.");
    return 0;
  }

  function _unlockedBalanceFromTimestamp(address wallet, uint256 timestamp) private view returns (uint256) {
    if (initialized == false) {
      return 0;
    }

    uint256 total = initialToRedeem(wallet);
    if (total == 0) {
      return 0;
    }

    uint256 redeemedPercentage = _unlockedPercentageFromTimestamp(timestamp);
    return total * redeemedPercentage / 100;
  }

  function availableToRedeem(address wallet) external view returns (uint256) {
    return _unlockedBalanceFromTimestamp(wallet, block.timestamp) - redeemed[wallet];
  }

  function redeem() external returns (bool) {
    require(initialized == true, "Contract is not initialized.");

    uint256 currentRedeemable = this.availableToRedeem(msg.sender);
    if (currentRedeemable == 0) {
      return false;
    }

    redeemed[msg.sender] += currentRedeemable;
    totalRedeemed += currentRedeemable;
    token.transfer(msg.sender, currentRedeemable);
    return true;
  }
}