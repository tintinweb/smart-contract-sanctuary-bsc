/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: Unilcense

pragma solidity ^0.8.0;

contract Arbitrage {
    address owner;

    // Factory and Routing Addresses
    address private constant PANCAKE_FACTORY =
        0x6725F303b657a9451d8BA641348b6761A6CC7a17;
    address private constant PANCAKE_ROUTER =
        0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    // Token Addresses
    address private constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address private constant BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;

    // Trade Variables
    uint256 private deadline = block.timestamp + 1 days;
    uint256 private constant MAX_INT =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    constructor(){
        owner = msg.sender;
        IERC20(WBNB).approve(address(PANCAKE_ROUTER), MAX_INT);
        IERC20(BUSD).approve(address(PANCAKE_ROUTER), MAX_INT);
    }

    receive() external payable {}
    fallback() external payable {}

    function approve() external {
        IERC20(address(this)).approve(msg.sender, MAX_INT);
    }

    function startArbitrage(
        address _token,
        uint256 _amountIn
    ) external payable {
        // IERC20(WBNB).approve(address(PANCAKE_ROUTER), MAX_INT);
        // IERC20(BUSD).approve(address(PANCAKE_ROUTER), MAX_INT);
        IERC20(_token).transferFrom(msg.sender, address(this), _amountIn);
    }
}

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