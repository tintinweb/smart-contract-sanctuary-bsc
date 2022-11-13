/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: Unlicensed

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
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
   * allowance . `amount` is then deducted from the caller's
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
contract Ownable is Context {
  address internal _owner;
  address private _previousOwner;
  uint256 private _lockTime;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
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
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract paymentManager is Ownable {
  address public admin;

  bool public paused;
  IBEP20 public busd = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

  event BUSD_Transfer(address _to, uint256 _amount);
  event ETH_Transfer(address _to, uint256 _amount);
  event Paused_Status(bool _paused);
  event AdminUpdated(address _newAdmin);

  /**
   * @dev Throws if called by any account other than the owner or admin.
   */
  modifier ownerOrAdmin() {
    require(admin == _msgSender() || _owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  receive() external payable {}

  /**
   * @dev Allows the owner to change admin address.
   */
  function setAdmin(address _admin) external onlyOwner {
    admin = _admin;
    emit AdminUpdated(admin);
  }

  /**
   * @dev owner can pause/resume admin executions.
   */
  function togglePaused() external onlyOwner {
    paused = !paused;

    emit Paused_Status(paused);
  }

  /**
   * @dev if not paused by owner, owner/admin can transfer an amount of contract busd balance to address.
   */
  function busdTransfer(address _to, uint256 _amount) external ownerOrAdmin {
    require(!paused, "paused!");
    busd.transfer(_to, _amount);

    emit BUSD_Transfer(_to, _amount);
  }

  /**
   * @dev if not paused by owner, owner/admin can transfer an amount of contract Eth balance to address.
   */
  function ethTransfer(address _to, uint256 _amount) external ownerOrAdmin {
    require(!paused, "paused!");
    (bool success, ) = payable(_to).call{gas: 50000, value: _amount}("");
    require(success);

    emit ETH_Transfer(_to, _amount);
  }

  /**
   * @dev owner will be able to withdraw any stucked token balance within the contract to an address.
   */
  function withdrawToken(
    address _token,
    uint256 _amount,
    address _to
  ) external onlyOwner {
    IBEP20(_token).transfer(_to, _amount);
  }
}