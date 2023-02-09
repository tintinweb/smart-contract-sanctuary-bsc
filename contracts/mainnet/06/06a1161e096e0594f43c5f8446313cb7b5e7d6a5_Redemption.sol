/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/RED/Redemption.sol


pragma solidity 0.8.17;


contract Redemption {
    IERC20 constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    address constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    IERC20 constant BTDMD = IERC20(0x669288ADA63ed65Eb3770f1c9eeB8956deDAaa47); // BitDiamond ERC20
    uint256 constant BTDMD_REDEMPTION_RATE = 6000000000000000; // 0.0060 BUSD per BTDMD, current price is 0.0046 after 4% tax (so a ~30% premium)

    event BitDiamondRedemption(uint256 BitDiamondAmount, uint256 BUSDAmount);

    constructor() {}

    function redeem(uint256 amountBTDMD) external {
        // Check that something is being redeemed:
        require(amountBTDMD != 0, "No amount entered");

        uint256 redemptionAmount = (amountBTDMD * BTDMD_REDEMPTION_RATE) /
            10**8;

        require(redemptionAmount != 0, "Amount to small for redemption");

        // Burn the BTDMD
        BTDMD.transferFrom(msg.sender, BURN_ADDRESS, amountBTDMD);

        // Payout the redemption amount:
        BUSD.transfer(msg.sender, redemptionAmount);

        // Emit the details:
        emit BitDiamondRedemption(amountBTDMD, redemptionAmount);
    }
}