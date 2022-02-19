/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

contract ERC20MultiSender {
  event IncreaseAmount(address account, address token, uint256 amount);
  event MuitiSend(address account, address token, uint256 amount, uint256 count);

  mapping(address => mapping(address => uint256)) private _availableAmounts;

  function increaseAmount(address token, uint256 amount) external {
    address self = address(this);
    address sender = msg.sender;
    IERC20 erc20 = IERC20(token);

    uint256 balance = erc20.balanceOf(self);
    erc20.transferFrom(sender, self, amount);
    uint256 actualAmount = erc20.balanceOf(self) - balance;

    _availableAmounts[sender][token] += actualAmount;

    emit IncreaseAmount(sender, token, actualAmount);
  }

  function multiSend(address token, address[] calldata accounts, uint256[] calldata amounts) external {
    require(accounts.length == amounts.length && accounts.length > 0, "ERC20MultiSender: invalid length");

    address sender = msg.sender;
    uint256 length = accounts.length;
    uint256 total;
    uint256 i;

    for(; i < length; i++) {
      total += amounts[i];
    }

    require(_availableAmounts[sender][token] >= total, "ERC20MultiSender: insufficient balance");

    IERC20 erc20 = IERC20(token);
    _availableAmounts[sender][token] -= total;
    for(i = 0; i < length; i++) {
      erc20.transfer(accounts[i], amounts[i]);
    }

    emit MuitiSend(sender, token, total, length);
  }

  function availableAmount(address account, address token) external view returns (uint256) {
    return _availableAmounts[account][token];
  }
}