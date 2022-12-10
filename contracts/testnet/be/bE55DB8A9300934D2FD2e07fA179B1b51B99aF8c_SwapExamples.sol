// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

contract SwapExamples {
    address private constant ROUTER =
        0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    address private constant BRT = 0x48727D58a875769669F7987E163044EF1aB693bB;
    address private constant BR2 = 0xd3f4D48A3A6A5DC7151AA893200547E06219F6A0;
    address constant UST = 0xA844B8Dccf5C0Eb16a0920c86073F2A3fF5a2CA8;

    IUniswapV2Router private router = IUniswapV2Router(ROUTER);
    IERC20 private ust = IERC20(UST);

    // Swap DAI -> WETH -> USDC
    function swap(uint amountIn, uint amountOutMin)
        external
        returns (uint amountOut)
    {
        ust.transferFrom(msg.sender, address(this), amountIn);
        ust.approve(address(router), amountIn);

        address[] memory path;
        path = new address[](3);
        path[0] = UST;
        path[1] = BRT;
        path[2] = BR2;

        uint[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        // amounts[0] = DAI amount
        // amounts[1] = WETH amount
        // amounts[2] = USDC amount
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