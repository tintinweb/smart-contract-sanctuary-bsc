//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IUniswapV2Router02.sol";
import "./IERC20.sol";

/**
    Daylight Swapper Contract
 */
contract DaylightSwapper {

    // Token
    address public constant token = 0x62529D7dE8293217C8F74d60c8C0F6481DE47f0E;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // DEX Router
    IUniswapV2Router02 public router;
    address[] private buyPath;
    address[] private sellPath;

    // Only Token Can Call
    modifier onlyToken() {
        require(
            msg.sender == token, 
            'Only Token'
        );
        _;
    }

    constructor(
        address router_
    ) {
        require(
            router_ != address(0),
            'Zero Check'
        );
        
        // initialize router
        router = IUniswapV2Router02(router_);

        // initialize buy path
        buyPath = new address[](3);
        buyPath[0] = router.WETH();
        buyPath[1] = BUSD;
        buyPath[2] = token;

        // initialize sell path
        sellPath = new address[](3);
        sellPath[0] = token;
        sellPath[1] = BUSD;
        sellPath[2] = router.WETH();
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