/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

// SPDX-License-Identifier: MIT

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

contract dex {
    IERC20 private _token;
    address private _owner;

    event Withdraw(address indexed address_, uint256 amount_);
    event ClaimWithDraw(
        address indexed address_,
        uint256 amount_,
        uint256 idGame
    );
    event Deposit(address indexed address_, uint256 amount_, uint256 idGame);

    constructor(IERC20 token_) {
        _token = token_;
        _owner = msg.sender;
    }

    function withdraw(uint256 amount_) public isOwner {
        require(amount_ > 0, "Amount is  grater than 0");
        uint256 totalAmount = _token.balanceOf(address(this));
        require(
            amount_ < totalAmount,
            "Amount is greater than total Amount of SM"
        );
        _token.transfer(msg.sender, amount_);
        emit Withdraw(msg.sender, amount_);
    }

    function claimWithdraw(
        address spender_,
        uint256 amount_,
        uint256 idGame
    ) public isOwner {
        require(amount_ > 0, "Amount is  grater than 0");
        uint256 totalAmount = _token.balanceOf(address(this));
        require(
            amount_ < totalAmount,
            "Amount is less than total Amount of SM"
        );
        _token.transfer(spender_, amount_);
        emit ClaimWithDraw(spender_, amount_, idGame);
    }

    function deposit(uint256 amount_, uint256 idGame) public {
        require(msg.sender != _owner, "Only user use this function!");
        require(amount_ > 0, "Amount is  grater than 0");
        uint256 userAmount = _token.balanceOf(msg.sender);
        require(amount_ < userAmount, "Your Amount is not enought");
        _token.transferFrom(msg.sender, address(this), amount_);
        emit Deposit(msg.sender, amount_, idGame);
    }

    modifier isOwner() {
        require(msg.sender == _owner, "You're not Owner");
        _;
    }
}