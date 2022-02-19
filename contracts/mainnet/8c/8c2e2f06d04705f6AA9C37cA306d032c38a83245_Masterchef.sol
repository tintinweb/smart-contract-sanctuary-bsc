// SPDX-License-Identifier: GPL-3.0-or-later Or MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Masterchef is Ownable {
  IERC20 public token;
  mapping(address => uint) public userStakesFor6mo;
  mapping(address => uint) public userStakesFor9mo;
  mapping(address => uint) public userStakesFor12mo;

  uint public totalStakesFor6mo;
  uint public totalStakesFor9mo;
  uint public totalStakesFor12mo;

  mapping(address => uint) public lastClaimTimeFor6mo;
  mapping(address => uint) public lastClaimTimeFor9mo;
  mapping(address => uint) public lastClaimTimeFor12mo;

  mapping(address => uint) public lastStakeTimeFor6mo;
  mapping(address => uint) public lastStakeTimeFor9mo;
  mapping(address => uint) public lastStakeTimeFor12mo;

  mapping(address => uint) internal userRewardFor6mo;
  mapping(address => uint) internal userRewardFor9mo;
  mapping(address => uint) internal userRewardFor12mo;

  uint public rewardRate6mo = 14;
  uint public rewardRate9mo = 20;
  uint public rewardRate12mo = 30;

  uint immutable _6MO = 182 days;
  uint immutable _9MO = 273 days;
  uint immutable _12MO = 365 days;

  constructor(IERC20 _token) {
    token = _token;
  }

  function setRewardRates(uint _rate6mo, uint _rate9mo, uint _rate12mo) external onlyOwner {
    rewardRate6mo = _rate6mo;
    rewardRate9mo = _rate9mo;
    rewardRate12mo = _rate12mo;
  }

  function pendingRewardFor6mo(address user) public view returns (uint) {
    return userRewardFor6mo[user] + userStakesFor6mo[user] * (block.timestamp - lastClaimTimeFor6mo[user]) * rewardRate6mo / (_12MO * 100);
  }

  function pendingRewardFor9mo(address user) public view returns (uint) {
    return userRewardFor9mo[user] + userStakesFor9mo[user] * (block.timestamp - lastClaimTimeFor9mo[user]) * rewardRate9mo / (_12MO * 100);
  }

  function pendingRewardFor12mo(address user) public view returns (uint) {
    return userRewardFor12mo[user] + userStakesFor12mo[user] * (block.timestamp - lastClaimTimeFor12mo[user]) * rewardRate12mo / (_12MO * 100);
  }

  function withdraw(address to, uint amount) external onlyOwner {
    token.transfer(to, amount);
  }

  // stake functions
  function stakeFor6mo(uint _amount) external {
    require (_amount > 0, "ERROR! Invalid amount!");

    if (userStakesFor6mo[msg.sender] == 0) {
      lastStakeTimeFor6mo[msg.sender] = block.timestamp;
    }

    token.transferFrom(msg.sender, address(this), _amount);
    userRewardFor6mo[msg.sender] = pendingRewardFor6mo(msg.sender);
    userStakesFor6mo[msg.sender] += _amount;
    lastClaimTimeFor6mo[msg.sender] = block.timestamp;
    totalStakesFor6mo += _amount;
  }

  function stakeFor9mo(uint _amount) external {
    require (_amount > 0, "ERROR! Invalid amount!");

    if (userStakesFor9mo[msg.sender] == 0) {
      lastStakeTimeFor9mo[msg.sender] = block.timestamp;
    }

    token.transferFrom(msg.sender, address(this), _amount);
    userRewardFor9mo[msg.sender] = pendingRewardFor9mo(msg.sender);
    userStakesFor9mo[msg.sender] += _amount;
    lastClaimTimeFor9mo[msg.sender] = block.timestamp;
    totalStakesFor9mo += _amount;
  }

  function stakeFor12mo(uint _amount) external {
    require (_amount > 0, "ERROR! Invalid amount!");

    if (userStakesFor12mo[msg.sender] == 0) {
      lastStakeTimeFor12mo[msg.sender] = block.timestamp;
    }

    token.transferFrom(msg.sender, address(this), _amount);
    userRewardFor12mo[msg.sender] = pendingRewardFor12mo(msg.sender);
    userStakesFor12mo[msg.sender] += _amount;
    lastClaimTimeFor12mo[msg.sender] = block.timestamp;
    totalStakesFor12mo += _amount;
  }

  // unstake functions
  function unstakeFor6mo(uint amount) external {
    require (userStakesFor6mo[msg.sender] > 0 && amount <= userStakesFor6mo[msg.sender], "ERROR! You have no deposit");
    require (block.timestamp > lastStakeTimeFor6mo[msg.sender] + _6MO, "ERROR! You can't claim yet");

    _claim6(msg.sender);
    token.transfer(msg.sender, amount);
    userStakesFor6mo[msg.sender] -= amount;
    totalStakesFor6mo -= amount;
  }

  function unstakeFor9mo(uint amount) external {
    require (userStakesFor9mo[msg.sender] > 0 && amount <= userStakesFor9mo[msg.sender], "ERROR! You have no deposit");
    require (block.timestamp > lastStakeTimeFor9mo[msg.sender] + _9MO, "ERROR! You can't claim yet");

    _claim6(msg.sender);
    token.transfer(msg.sender, amount);
    userStakesFor9mo[msg.sender] -= amount;
    totalStakesFor9mo -= amount;
  }

  function unstakeFor12mo(uint amount) external {
    require (userStakesFor12mo[msg.sender] > 0 && amount <= userStakesFor12mo[msg.sender], "ERROR! You have no deposit");
    require (block.timestamp > lastStakeTimeFor12mo[msg.sender] + _12MO, "ERROR! You can't claim yet");

    _claim6(msg.sender);
    token.transfer(msg.sender, amount);
    userStakesFor12mo[msg.sender] -= amount;
    totalStakesFor12mo -= amount;
  }

  // claim functions
  function _claim6(address user) internal {
    uint reward = pendingRewardFor6mo(user);

    if (reward > 0) {
      token.transfer(user, reward);
      userRewardFor6mo[user] = 0;
      lastClaimTimeFor6mo[user] = block.timestamp;
    }
  }

  function _claim9(address user) internal {
    uint reward = pendingRewardFor6mo(user);

    if (reward > 0) {
      token.transfer(user, reward);
      userRewardFor9mo[user] = 0;
      lastClaimTimeFor9mo[user] = block.timestamp;
    }
  }

  function _claim12(address user) internal {
    uint reward = pendingRewardFor6mo(user);

    if (reward > 0) {
      token.transfer(user, reward);
      userRewardFor12mo[user] = 0;
      lastClaimTimeFor12mo[user] = block.timestamp;
    }
  }

  function claimFor6mo() external {
    _claim6(msg.sender);
  }

  function claimFor9mo() external {
    _claim9(msg.sender);
  }

  function claimFor12mo() external {
    _claim12(msg.sender);
  }

  // emergency unstake (30% fee)
  function forceUnstakeFor6mo(uint amount) external {
    require (userStakesFor6mo[msg.sender] > 0, "ERROR! You have no deposit");
    require (userStakesFor6mo[msg.sender] >= amount, "ERROR! You have not enough deposit");

    _claim6(msg.sender);
    token.transfer(msg.sender, amount * 7 / 10);
    userStakesFor6mo[msg.sender] -= amount;
    totalStakesFor6mo -= amount;
  }

  function forceUnstakeFor9mo(uint amount) external {
    require (userStakesFor9mo[msg.sender] > 0, "ERROR! You have no deposit");
    require (userStakesFor9mo[msg.sender] >= amount, "ERROR! You have not enough deposit");

    _claim9(msg.sender);
    token.transfer(msg.sender, amount * 7 / 10);
    userStakesFor9mo[msg.sender] -= amount;
    totalStakesFor9mo -= amount;
  }

  function forceUnstakeFor12mo(uint amount) external {
    require (userStakesFor12mo[msg.sender] > 0, "ERROR! You have no deposit");
    require (userStakesFor12mo[msg.sender] >= amount, "ERROR! You have not enough deposit");

    _claim12(msg.sender);
    token.transfer(msg.sender, amount * 7 / 10);
    userStakesFor12mo[msg.sender] -= amount;
    totalStakesFor12mo -= amount;
  }
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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