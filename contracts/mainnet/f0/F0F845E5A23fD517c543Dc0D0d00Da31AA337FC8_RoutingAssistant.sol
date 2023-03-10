// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;
//import "hardhat/console.sol";
import "./interfaces/IAmmRouter02.sol";

contract RoutingAssistant {
    IAmmRouter02 public router =
        IAmmRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address[5] public intermediateTokens;

    address public CZUSD = address(0xE68b79e51bf826534Ff37AA9CeE71a3842ee9c70);
    address public WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    constructor() {
        intermediateTokens[0] = address(
            0x55d398326f99059fF775485246999027B3197955
        ); //USDT
        intermediateTokens[1] = address(
            0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
        ); //BUSD
        intermediateTokens[2] = address(
            0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82
        ); //CAKE
        intermediateTokens[3] = address(
            0x2170Ed0880ac9A755fd29B2688956BD959F933F8
        ); //WETH
        intermediateTokens[4] = address(
            0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c
        ); //BTCB
    }

    function getIntermediatePairedTokenRate(address _tradingToken)
        public
        view
        returns (uint256 rateWad_, address intermediateToken_)
    {
        uint256[7] memory amountOuts; //intermediateTokens.length+2
        address[] memory path3 = new address[](3);
        address[] memory path4 = new address[](4);

        //Direct swap
        amountOuts[0] = getCzusdPairedTokenRate(_tradingToken);

        //Thru WBNB
        if (_tradingToken != WBNB) {
            path3[0] = CZUSD;
            path3[1] = WBNB;
            path3[2] = _tradingToken;
            amountOuts[1] = router.getAmountsOut(1 ether, path3)[2];
        }

        //Thru intermediates
        path4[0] = CZUSD;
        path4[1] = WBNB;
        path4[3] = _tradingToken;
        for (
            uint256 i;
            i < 5; /* 5 int tokens*/
            i++
        ) {
            if (_tradingToken != intermediateTokens[i]) {
                path4[2] = intermediateTokens[i];
                amountOuts[i + 2] = router.getAmountsOut(1 ether, path4)[3];
            }
        }

        uint256 winningIndex = 7; //If no one wins, this will be 7
        uint256 winningAmountOut = 7; //If no one wins, this will be 7
        for (
            uint256 i;
            i < 7; /* 7 amtout*/
            i++
        ) {
            if (amountOuts[i] > winningAmountOut) {
                winningAmountOut = amountOuts[i];
                winningIndex = i;
            }
        }

        rateWad_ = winningAmountOut;
        if (winningIndex == 0) {
            intermediateToken_ = CZUSD;
        } else if (winningIndex == 1) {
            intermediateToken_ = WBNB;
        } else if (winningIndex < 7) {
            intermediateToken_ = intermediateTokens[winningIndex];
        }
    }

    function getCzusdPairedTokenRate(address _tradingToken)
        public
        view
        returns (uint256 rateWad_)
    {
        address[] memory path2 = new address[](2);

        //Direct swap
        path2[0] = CZUSD;
        path2[1] = _tradingToken;
        rateWad_ = router.getAmountsOut(1 ether, path2)[1];
    }
}

// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
// Credit to Pancakeswap
pragma solidity ^0.8.4;

import "./IAmmRouter01.sol";

interface IAmmRouter02 is IAmmRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
// Credit to Pancakeswap
pragma solidity ^0.8.4;

interface IAmmRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}