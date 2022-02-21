// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./IERC20.sol";
import "./IERC3156FlashBorrower.sol";

/*
 *  FlashBorrowerExample is a simple method that
 *  borrows and returns a flash loan.
 */
contract FlashBorrowerExample is IERC3156FlashBorrower {
    uint256 MAX_INT =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // @dev ERC-3156 Flash loan callback
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        // Set the allowance to payback the flash loan
        IERC20(token).approve(msg.sender, MAX_INT);

        // Build your trading business logic here
        // e.g., sell on uniswapv2
        // e.g., buy on uniswapv3

        // Return success to the lender, he will transfer get the funds back if allowance is set accordingly
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}