/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

//SPDX-License-Identifier: MIT
// produced by the Solididy File Flattener (c) David Appleton 2018 - 2020 and beyond
// contact : [email protected]
// source  : https://github.com/DaveAppleton/SolidityFlattery
// released under Apache 2.0 licence
// input  /Users/b0b0/code/sitx-token-v3-time-lock/for_consolidation.sol
// flattened :  Wednesday, 23-Feb-22 15:22:16 UTC
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
contract Timelock {
    event Withdraw(address indexed token, uint indexed amount, address indexed to);
    uint public immutable end;
    address payable public owner;
    uint public constant duration = 365 days;
    constructor() {
        owner = payable(msg.sender);
        end = block.timestamp + duration;
    }

    // function deposit(address token, uint256 amount) external {
    //     require(amount > 0, 'amount is zero');

    //     IERC20(token).transferFrom(msg.sender, address(this), amount);
    // }

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