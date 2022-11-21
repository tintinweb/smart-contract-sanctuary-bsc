//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IUniswapV2Router02.sol";
import "./IERC20.sol";

/**
    Daylight Swapper Contract
 */
contract DaylightSwapper {

    // Token
    address public immutable token;

    // DEX Router
    IUniswapV2Router02 public router;
    address[] buyPath;
    address[] sellPath;

    // Only Token Can Call
    modifier onlyToken() {
        require(
            msg.sender == token, 
            'Only Token'
        );
        _;
    }

    constructor(
        address token_,
        address router_
    ) {
        require(
            token_ != address(0) &&
            router_ != address(0),
            'Zero Check'
        );
        
        // initialize token
        token = token_;

        // initialize router
        router = IUniswapV2Router02(router_);

        // initialize buy path
        buyPath = new address[](2);
        buyPath[0] = router.WETH();
        buyPath[1] = token_;

        // initialize sell path
        sellPath = new address[](2);
        sellPath[0] = token_;
        sellPath[1] = router.WETH();
    }

    function buy(address user) external payable onlyToken {
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
            0, buyPath, user, block.timestamp + 10
        );
    }

    function sell(address user) external onlyToken {
        uint balance = IERC20(token).balanceOf(address(this));
        IERC20(token).approve(
            address(router),
            balance
        );
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            balance, 
            0, 
            sellPath, 
            user, 
            block.timestamp + 10
        );
    }
}