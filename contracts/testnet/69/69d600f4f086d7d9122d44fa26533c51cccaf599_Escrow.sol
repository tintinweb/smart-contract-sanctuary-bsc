/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: MIT
// File: contracts/IERC20.sol


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

// File: contracts/escrow2P2P.sol


pragma solidity 0.8.6;


contract Escrow {
  address admin;
  uint256 public totalBalance;

  // this is the P2PM erc20 contract address
  IERC20 p2pmAddress;

  struct Transaction {
    address buyer;
    uint256 amount;
    bool locked;
    bool spent;
  }

  mapping(address => mapping(address => Transaction)) public balances;

  modifier onlyAdmin {
    require(msg.sender == admin, "Only admin can unlock escrow.");
    _;
  }

  constructor(IERC20 _p2pmAddress) {
    p2pmAddress = _p2pmAddress;
    admin = msg.sender;
  }

  // seller accepts a trade, erc20 tokens
  // get moved to the escrow (this contract)
  function accept(address _tx_id, address _buyer, uint256 _amount) external returns (uint256) {
    IERC20 token = IERC20(p2pmAddress);
    token.transferFrom(msg.sender, address(this), _amount);
    totalBalance += _amount;
    balances[msg.sender][_tx_id].amount = _amount;
    balances[msg.sender][_tx_id].buyer = _buyer;
    balances[msg.sender][_tx_id].locked = true;
    balances[msg.sender][_tx_id].spent = false;
    return token.balanceOf(msg.sender);
  }

  // retrieve current state of transaction in escrow
  function transaction(address _seller, address _tx_id) external view returns (uint256, bool, address) {
    return ( balances[_seller][_tx_id].amount, balances[_seller][_tx_id].locked, balances[_seller][_tx_id].buyer );
  }

  // admin unlocks tokens in escrow for a transaction
  function release(address _tx_id, address _seller) onlyAdmin external returns(bool) {
    balances[_seller][_tx_id].locked = false;
    return true;
  }

  // seller is able to withdraw unlocked tokens
  function withdraw(address _tx_id) external returns(bool) {
    require(balances[msg.sender][_tx_id].locked == false, 'This escrow is still locked');
    require(balances[msg.sender][_tx_id].spent == false, 'Already withdrawn');

    IERC20 token = IERC20(p2pmAddress);
    token.transfer(msg.sender, balances[msg.sender][_tx_id].amount);

    totalBalance -= balances[msg.sender][_tx_id].amount;
    balances[msg.sender][_tx_id].spent = true;
    return true;
  }

  // admin can send funds to buyer if dispute resolution is in buyer's favor
  function resolveToBuyer(address _seller, address _tx_id) onlyAdmin external returns(bool) {
    IERC20 token = IERC20(p2pmAddress);
    token.transfer(balances[_seller][_tx_id].buyer, balances[msg.sender][_tx_id].amount);

    balances[_seller][_tx_id].spent = true;
    totalBalance -= balances[_seller][_tx_id].amount;
    return true;
  }


}