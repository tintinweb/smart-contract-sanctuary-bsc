/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IDEXRouter {
    function factory() external view returns (address);

    function WETH() external view returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountDCMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountDC,
            uint liquidity
        );

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract DarkWallet {
    string constant _name = "Dark Wallet";
    string constant _symbol = "DARK";
    address token;
    address ETH;
    IDEXRouter router;

    constructor (address routerAddress, address purchaseToken) {
        router = IDEXRouter(routerAddress);
        token = purchaseToken;
        ETH = router.WETH();
    }

    function darkBuy() external payable { 
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = token;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}