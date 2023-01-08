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

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Round is Ownable {
  uint256 public immutable LOCK_PERIOD;
  uint256 public immutable TGE;                            
  uint256 public immutable CLIFF;                       
  uint256 public immutable CLAIM_PERCENT;              
  uint256 public immutable NUM_CLAIMS;                      

  /// @notice token interfaces
  address public immutable TokenAddress;
  IERC20 public immutable TOKEN;

  /// @notice round state
  uint256 public availableTreasury;

  /// @notice user state structure
  struct User {
    uint256 totalTokenBalance;  // total num of tokens user have bought through the contract
    uint256 tokensToIssue;      // num of tokens user have bought in current vesting period (non complete unlock cycle)
    uint256 liquidBalance;      // amount of tokens the contract already sent to user
    uint256 pendingForClaim;    // amount of user's tokens that are still locked
    uint256 nextUnlockDate;     // unix timestamp of next claim unlock (defined by LOCK_PERIOD)
    uint256 numUnlocks;          // months total
    uint256 initialPayout;      // takes into account TGE % for multiple purchases
    bool hasBought;             // used in token purchase mechanics
  }

  /// @notice keeps track of users
  mapping(address => User) public users;

  address[] public icoTokenHolders;
  mapping(address => uint256) public holderIndex;

  event TokenPurchased(address indexed user, uint256 amount);
  event TokenRemoved(address indexed user, uint256 amount);
  event TokenClaimed(
    address indexed user,
    uint256 amount,
    uint256 claimsLeft,
    uint256 nextUnlockDate
  );

  /// @param token => token address
  constructor(
    address token,
    uint256 lock_period,
    uint256 tge,
    uint256 cliff,
    uint256 claim_percent,
    uint256 num_claims
  ) {
    TokenAddress = token;
    TOKEN = IERC20(token);
    LOCK_PERIOD = lock_period;
    TGE = tge;
    CLIFF = cliff;
    CLAIM_PERCENT = claim_percent;
    NUM_CLAIMS = num_claims;
  }

  function replenishTreasury(uint256 amount) external onlyOwner {
    TOKEN.transferFrom(msg.sender, address(this), amount);
    availableTreasury += amount;
  }

  /// @notice checks whether user's tokens are locked
  modifier checkLock() {
    require(
      users[msg.sender].pendingForClaim > 0,
      "Nothing to claim!"
    );
    require(
      block.timestamp >= users[msg.sender].nextUnlockDate,
      "Tokens are still locked!"
    );
    _;
  }

  function getUnclaimed(address user) public view returns (
    uint256 amountToClaim, 
    uint256 unclaimedPeriods
  ) {
      User storage userStruct = users[user];

      if (users[user].nextUnlockDate > block.timestamp) return (0, 0);

      unclaimedPeriods = 1 + (block.timestamp - users[user].nextUnlockDate) / LOCK_PERIOD;

      if (userStruct.numUnlocks + unclaimedPeriods <= NUM_CLAIMS) {
        amountToClaim = (userStruct.tokensToIssue * CLAIM_PERCENT * unclaimedPeriods) / 10_000;
      } else amountToClaim = userStruct.pendingForClaim;
  }

  /// @notice checks if tokens are unlocked and transfers set % from pendingForClaim
  /// user will recieve all remaining tokens with the last claim
  function claimTokens() public checkLock() {
    address user = msg.sender;
    User storage userStruct = users[user];

    (uint256 amountToClaim, uint256 unclaimedPeriods) = getUnclaimed(user);

    userStruct.liquidBalance += amountToClaim;  
    userStruct.pendingForClaim -= amountToClaim;
    userStruct.nextUnlockDate += LOCK_PERIOD * unclaimedPeriods;
    userStruct.numUnlocks += unclaimedPeriods;
    TOKEN.transfer(user, amountToClaim);

    emit TokenClaimed(
      user,
      amountToClaim,
      NUM_CLAIMS > userStruct.numUnlocks ? NUM_CLAIMS - userStruct.numUnlocks : 0, // number of claims left to perform
      userStruct.nextUnlockDate
    );
  }

  /// @notice when user buys Token, TGE % is issued immediately
  /// @param _amount => amount of Token tokens to distribute
  /// @param _to => address to issue tokens to
  function _lockAndDistribute(uint256 _amount, address _to) private {
    require(availableTreasury >= _amount, "Treasury drained");

    User  storage userStruct = users[_to];
    uint256 timestampNow = block.timestamp;

    uint256 immediateAmount = (_amount / 100) * TGE;
    if (immediateAmount > 0) {
        TOKEN.transfer(_to, immediateAmount);  // issue TGE % immediately
        userStruct.initialPayout += immediateAmount;
        userStruct.liquidBalance += immediateAmount;  // issue TGE % immediately to struct
    }
                
    userStruct.pendingForClaim += _amount - immediateAmount;  // save the rest
    userStruct.tokensToIssue = _amount;
    userStruct.numUnlocks = 0;
    if (!userStruct.hasBought) {
      icoTokenHolders.push(_to);
      holderIndex[_to] = icoTokenHolders.length - 1;
      userStruct.hasBought = true;
    }

    userStruct.totalTokenBalance += _amount;
    availableTreasury -= _amount;
    userStruct.nextUnlockDate = timestampNow + (CLIFF > 0 ? CLIFF : LOCK_PERIOD); // lock tokens depends on cliff and lock period
  }

  /// @notice allows admin to issue tokens with vesting rules to address
  /// @param _amount => amount of Token tokens to issue
  /// @param _to => address to issue tokens to
  function issueTokens(uint256 _amount, address _to) external onlyOwner {
    _lockAndDistribute(_amount, _to);
    emit TokenPurchased(_to, _amount);
  }

  /// @notice remove data from user
  /// @param _from => user address
  /// @param _confirmation => confirmation to remove
  function removeTokens(address _from, bool _confirmation) external onlyOwner {
    require(_confirmation, "Confirmation needed");
    require(users[_from].hasBought, "Unknown user");

    uint256 residue = users[_from].pendingForClaim;

    delete users[_from];

    uint256 lastIdx = icoTokenHolders.length - 1;
    uint256 idx = holderIndex[_from];

    holderIndex[icoTokenHolders[lastIdx]] = idx;
    icoTokenHolders[idx] = icoTokenHolders[lastIdx];
    icoTokenHolders.pop();

    emit TokenRemoved(_from, residue);
  }
}