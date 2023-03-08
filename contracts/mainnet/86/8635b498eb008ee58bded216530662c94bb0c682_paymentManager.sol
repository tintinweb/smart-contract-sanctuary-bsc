/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

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

contract paymentManager{
  address public timelock;

  bool public paused;
  IBEP20 public busd = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

  event BUSD_Transfer(address _to, uint256 _amount);
  event ETH_Transfer(address _to, uint256 _amount);
  event Paused_Status(bool _paused);
  event AdminUpdated(address _newAdmin);

  constructor(address _timelock) {
    timelock = _timelock;
  }
  /**
   * @dev Throws if called by any account other than the timelock.
   */
  modifier onlyTimelock() {
    require(timelock == msg.sender, "caller is not the timelock");
    _;
  }

  receive() external payable {}

  /**
   * @dev timelock can pause/resume admin executions.
   */
  function togglePaused() external onlyTimelock {
    paused = !paused;

    emit Paused_Status(paused);
  }

  /**
   * @dev if not paused by timelock, timelock can transfer an amount of contract busd balance to address.
   */
  function busdTransfer(address _to, uint256 _amount) external onlyTimelock {
    require(!paused, "paused!");
    busd.transfer(_to, _amount);

    emit BUSD_Transfer(_to, _amount);
  }

  /**
   * @dev if not paused by timelock, timelock can transfer an amount of contract Eth balance to address.
   */
  function ethTransfer(address _to, uint256 _amount) external onlyTimelock {
    require(!paused, "paused!");
    (bool success, ) = payable(_to).call{gas: 50000, value: _amount}("");
    require(success);

    emit ETH_Transfer(_to, _amount);
  }

  /**
   * @dev timelock will be able to withdraw any stucked token balance within the contract to an address.
   */
  function withdrawToken(
    address _token,
    uint256 _amount,
    address _to
  ) external onlyTimelock {
    IBEP20(_token).transfer(_to, _amount);
  }
}