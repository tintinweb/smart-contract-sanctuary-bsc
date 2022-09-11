// SPDX-License-Identifier: None
pragma solidity ^0.8.9;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct Order {
  uint256 amount;
  uint256 pricePerImage;
  address customer;
  uint256 deadline;
  address verifier;
  string url;
}

contract DDAAImplementation {
  uint256 public orderId;
  IERC20 internal Coin;
  //orderId => Order
  mapping (uint256 => Order) public orders;
  //orderId => amountLeft
  mapping (uint256 => uint256) internal orderBalance;
  //address => url
  mapping (address => string) public verifiersURL;

  constructor (address verifier, string memory url, address coinAddress) {
    verifiersURL[verifier] = url;
    Coin = IERC20(coinAddress);
  }

  function submitOrder(
    uint256 amount,
    uint256 pricePerImage,
    address verifier,
    uint256 deadline,
    string memory endpointUrl
  ) external {
    //Transfer funds to the contract
    require(Coin.allowance(msg.sender, address(this)) >= amount, 
      "DDAA: Insufficient amount of funds allocated");
    Coin.transferFrom(msg.sender, address(this), amount);
    //Create an order
    orderBalance[orderId] = amount;
    orders[orderId] = Order(
      {
        amount: amount,
        pricePerImage: pricePerImage,
        customer: msg.sender,
        deadline: deadline, 
        verifier: verifier,
        url: endpointUrl
      }
    );
    orderId++;
    emit orderSubmitted(orderId, verifier);
  }

  function payToAnnotator(
    address annotator, 
    uint256 order,
    uint256 amount
  ) external {
    require(orders[order].verifier == msg.sender, 
      "DDAA: This verifier is not assigned to this order");
    require(orderBalance[order] >= amount, 
      "DDAA: This order has insuffisient amount of funds left");

    orderBalance[order] -= amount;
    Coin.transfer(annotator, amount);
    emit paymentToAnnotator(order, annotator, amount);
  }

  function getUrlFromOrder(uint256 order) external view returns (string memory) {
    return orders[order].url;
  }

  event orderSubmitted(uint256 orderId, address verifier);
  event paymentToAnnotator(uint256 orderId, address annotator, uint256 amount);
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