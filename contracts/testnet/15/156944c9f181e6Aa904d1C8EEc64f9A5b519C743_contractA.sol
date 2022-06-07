// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract contractA   {
  IERC20 public tracker_0x_address = IERC20(0x50FE8A546037986C281Aa03451E2eB3B555A7141); // token Address
  address public immutable owner = msg.sender;
  uint256 public cooldownWithdrawal = 30 minutes;
  mapping(address => uint256) public lastTimeWithdraw;
  mapping ( address => uint256 ) public balances;
  
  event Withdraw(address indexed user, uint256 amount, uint256 eventTime);
  event Deposit(address indexed user, uint256 amount, uint256 eventTime);

  function deposit(uint amount) public {
    require(amount > 0);
    require(tracker_0x_address.balanceOf(msg.sender) >= amount);
    (tracker_0x_address).transferFrom(msg.sender, owner, amount);
    balances[msg.sender]+= amount;
    emit Deposit(msg.sender, amount, block.timestamp);
  }

  function withdraw(uint256 amount) external {
      require(amount > 0);
      require(balances[msg.sender] >= amount && tracker_0x_address.balanceOf(owner) >= amount);
      require(lastTimeWithdraw[msg.sender] + cooldownWithdrawal <= block.timestamp);
      unchecked {
          balances[msg.sender]-= amount;
      }
      tracker_0x_address.transferFrom(owner, msg.sender, amount);
      emit Withdraw(msg.sender, amount, block.timestamp);
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