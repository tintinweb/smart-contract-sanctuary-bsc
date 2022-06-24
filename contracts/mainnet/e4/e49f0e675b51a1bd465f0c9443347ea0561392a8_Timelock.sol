/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

//SPDX-License-Identifier: MIT
//SitX token lock contract
//Locking period 60 days starts from June-24-2022

pragma solidity ^0.8.13;

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
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

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
contract Timelock {
    event Withdraw(address indexed token, uint indexed amount, address indexed to);
    uint public immutable end;
    address payable public owner;
    uint public constant duration = 60 days;
    constructor() {
        owner = payable(msg.sender);
        end = block.timestamp + duration;
    }

    receive() external payable {}  //to be able recieve blockchain native token 

    function withdraw(address token, uint amount) external {
        require(msg.sender == owner, 'Only owner');
        require(block.timestamp >= end, 'Too early');
        if (token == address(0)) {
            owner.transfer(amount);
        } else {
            IERC20(token).transfer(owner, amount);
            emit Withdraw(token, amount, msg.sender);
        }
    }

    function transferOwnership(address payable _newOwner) external {
        require(msg.sender == owner, 'Only owner');
        owner = _newOwner;
    }
}