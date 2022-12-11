// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

contract Swap {
    address private constant ROUTER =
        0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    IUniswapV2Router private router = IUniswapV2Router(ROUTER);
    

    function swap(uint amountIn, uint amountOutMin, address[] calldata path)
        external
        returns (uint amountOut)
    {
        IERC20 token = IERC20(path[0]);
        token.transferFrom(msg.sender, address(this), amountIn);
        token.approve(address(router), amountIn);

        uint[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );

        return amounts[path.length - 1];
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