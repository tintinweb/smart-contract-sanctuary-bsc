/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () { }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic register to join the system, where
 * the player is created and can get a reward token
 */

contract BetWorldcupRegister is Ownable {
  /**
  * Player
  * The user will be use this to join the system
  */

  IBEP20 public rewardToken;

  uint[] public rewards;
  uint256 public totalPlayers;
  uint256 private _rewardTokenRegister = 50 * 18;
  uint256 private _rewardTokenTier1 = _rewardTokenRegister / 100 * 5;
  uint256 private _rewardTokenTier2 = _rewardTokenRegister / 100 * 3;
  uint256 private _rewardTokenTier3 = _rewardTokenRegister / 100 * 2;
  uint256 private _rewardTokenTier4 = _rewardTokenRegister / 100 * 1;
  uint256 public totalrewards;

  /**
  * Player
  * The user will be use this to join the system
  */
  struct Player {
    address referer;
    uint256 tier1;
    uint256 tier2;
    uint256 tier3;
    uint256 tier4;
    uint256 claimed;
    address[] referered;
    uint256 registered;
  }

  mapping (address => Player) public players;


  /**
  * The event to notify a new reward
  */
  event Reward(address user, uint256 amount);


  /**
  * The event to notify a new player
  */
  event Registered(address user, address referer);

  constructor(address _rewardToken) {
    rewards.push(_rewardTokenTier1);
    rewards.push(_rewardTokenTier2);
    rewards.push(_rewardTokenTier3);
    rewards.push(_rewardTokenTier4);
    rewardToken = IBEP20(_rewardToken);
  }

  function register(address referer) external {
    if (players[msg.sender].registered == 0) {
      players[msg.sender].registered = block.timestamp;
      players[msg.sender].claimed = _rewardTokenRegister;

      totalPlayers++;

      if (players[referer].registered != 0 && referer != msg.sender) {
        address rec = referer;
        players[msg.sender].referer = referer;

        for (uint256 i = 0; i < rewards.length; i++) {
          if (players[rec].claimed == 0) {
            break;
          }

          if (i == 0) {
            players[rec].tier1++;
          }

          if (i == 1) {
            players[rec].tier2++;
          }

          if (i == 2) {
            players[rec].tier3++;
          }

          if (i == 3) {
            players[rec].tier3++;
          }

          rec = players[rec].referer;
        }

        rewardReferers(referer);
        rewardReferered(referer);
      }

      require(IBEP20(rewardToken).transfer(msg.sender, _rewardTokenRegister), "Register account is failed");

      emit Registered(msg.sender, referer);
    }
  }

  function rewardReferered(address referer) internal {
    bool exist = false;
    for (uint256 i = 0; i < players[referer].referered.length; i++) {
      if (players[referer].referered[i] == msg.sender) {
        exist = true;
        break;
      }
    }

    if (!exist) {
      players[referer].referered.push(msg.sender);
    }
  }

  function rewardReferers(address referer) internal {
    address rec = referer;

    for (uint256 i = 0; i < rewards.length; i++) {
      if (players[rec].registered == 0) {
        break;
      }

      uint256 rewardAmount = rewards[i];

      totalrewards += rewardAmount;
      players[rec].claimed += rewardAmount;

      require(IBEP20(rewardToken).transfer(rec, rewardAmount), "Reward for referral of register account is failed");

      emit Reward(rec, rewardAmount);

      rec = players[rec].referer;
    }
  }

  function changeRateReward(uint256 rewardTokenRegister_) public returns (bool) {
    _rewardTokenRegister = rewardTokenRegister_;
    return true;
  }

  function changeRateReferral(uint256[] calldata _rewards) public returns (bool) {
    rewards = _rewards;
    return true;
  }

  function changeReward(address _rewardToken) public returns (bool) {
    rewardToken = IBEP20(_rewardToken);
    return true;
  }

  function finish() external onlyOwner {
    IBEP20(rewardToken).transfer(msg.sender, IBEP20(rewardToken).balanceOf(address(this)));
  }

  function collectCurrency(address currency) external onlyOwner {
    IBEP20(currency).transfer(msg.sender, IBEP20(currency).balanceOf(address(this)));
  }

  function collect(uint amount) public onlyOwner {
    payable(msg.sender).transfer(amount);
  }

  function balanceOf(address user) public view returns (uint256) {
    return players[user].claimed;
  }

  function availabe() public view returns (uint256) {
    return IBEP20(rewardToken).balanceOf(address(this));
  }
}