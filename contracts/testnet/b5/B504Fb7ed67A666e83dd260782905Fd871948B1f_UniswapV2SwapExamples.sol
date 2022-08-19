/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract UniswapV2SwapExamples {
    address private constant UNISWAP_V2_ROUTER =
        0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    address private constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address private constant DAI = 0x8a9424745056Eb399FD19a0EC26A14316684e274;
    address constant USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;

    IUniswapV2Router private router = IUniswapV2Router(UNISWAP_V2_ROUTER);
    IERC20 private wbnb = IERC20(WBNB);
    IERC20 private dai = IERC20(DAI);

    // Swap WBNB to DAI
    function swapSingleHopExactAmountIn(uint amountIn, uint amountOutMin)
        external
        returns (uint amoutnOut)
    {
        wbnb.transferFrom(msg.sender, address(this), amountIn);
        wbnb.approve(address(router), amountIn);

        address[] memory path;
        path = new address[](2);
        path[0] = WBNB;
        path[1] = DAI;

        uint[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        // amounts[0] = WBNB amount, amounts[1] = DAI amount
        return amounts[1];
    }

    // Swap DAI -> WBNB -> USDT
    function swapMultiHopExactAmountIn(uint amountIn, uint amountOutMin)
        external
        returns (uint amoutnOut)
    {
        dai.transferFrom(msg.sender, address(this), amountIn);
        dai.approve(address(router), amountIn);

        address[] memory path;
        path = new address[](3);
        path[0] = DAI;
        path[1] = WBNB;
        path[2] = USDT;

        uint[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        // amounts[0] = DAI amount
        // amounts[1] = WBNB amount
        // amounts[2] = USDT amount
        return amounts[2];
    }

    // Swap WBNB to DAI
    function swapSingleHopExactAmountOut(uint amountOutDesired, uint amountInMax)
        external
        returns (uint amountOut)
    {
        wbnb.transferFrom(msg.sender, address(this), amountInMax);
        wbnb.approve(address(router), amountInMax);

        address[] memory path;
        path = new address[](2);
        path[0] = WBNB;
        path[1] = DAI;

        uint[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired,
            amountInMax,
            path,
            msg.sender,
            block.timestamp
        );

        // Refund WBNB to msg.sender
        if (amounts[0] < amountInMax) {
            wbnb.transfer(msg.sender, amountInMax - amounts[0]);
        }

        return amounts[1];
    }

    // Swap DAI -> WBNB -> USDT
    function swapMultiHopExactAmountOut(uint amountOutDesired, uint amountInMax)
        external
        returns (uint amountOut)
    {
        dai.transferFrom(msg.sender, address(this), amountInMax);
        dai.approve(address(router), amountInMax);

        address[] memory path;
        path = new address[](3);
        path[0] = DAI;
        path[1] = WBNB;
        path[2] = USDT;

        uint[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired,
            amountInMax,
            path,
            msg.sender,
            block.timestamp
        );

        // Refund DAI to msg.sender
        if (amounts[0] < amountInMax) {
            dai.transfer(msg.sender, amountInMax - amounts[0]);
        }

        return amounts[2];
    }
}

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint amount) external;
}