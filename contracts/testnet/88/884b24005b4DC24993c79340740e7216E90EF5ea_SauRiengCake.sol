/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT


// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


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

// File: contracts/SauRiengCake.sol

contract SauRiengCake {
    IERC20 tokenXu;
    IERC20 tokenXeng;
    uint buyXuRatio = 1000000; 
    uint buyXengRatio = 2000000;
    uint xuPerXengRatio = 2;
    uint minXu = 1000;
    uint minXeng = 2000;

    constructor(address tokenXu_Address, address tokenXeng_Address) {
        tokenXu = IERC20(tokenXu_Address);
        tokenXeng = IERC20(tokenXeng_Address);
    }

    function buyXuWithXeng() public payable {
        require(msg.value >= minXu * 10**18, "Minimum purchase of 1000 XU required!");

        uint xuAmount = msg.value / xuPerXengRatio;
        require(tokenXu.balanceOf(address(this)) >= xuAmount, "Sorry, XU balance not enough to transfer!");

        require(tokenXeng.allowance(msg.sender, address(this)) >= msg.value, "Please approve to transfer XENG first!");

        tokenXeng.transferFrom(msg.sender, address(this), msg.value); // Get XENG
        tokenXu.transferFrom(address(this), msg.sender, xuAmount); // Send XU
    }

    function buyXengWithXu() public payable {
        require(msg.value >= minXeng * 10**18, "Minimum purchase of 2000 XENG required!");

        uint xengAmount = msg.value * xuPerXengRatio;
        require(tokenXeng.balanceOf(address(this)) >= xengAmount, "Sorry, XENG balance not enough to transfer!");

        require(tokenXu.allowance(msg.sender, address(this)) >= msg.value, "Please approve to transfer XU first!");

        tokenXu.transferFrom(msg.sender, address(this), msg.value); // Get XU
        tokenXeng.transferFrom(address(this), msg.sender, xengAmount); // Send XENG
    }
}


// 1: 0x44decC21d0B3C5F466A937D4eB59581EA3A34766
// 2: 0xafb728AC88533E0FE79044cdcb5afe800473B574
// 3: 0x9eB11A5703068B2FBFCDCe1E9EEA0e727a570FF5

// XU: 0x49A33dB6A2e4C3322A107571275eF5CF68504C5c
// XENG: 0xFB14c5a0E2119E3fFA3c7CBd4546e153022A4C5e