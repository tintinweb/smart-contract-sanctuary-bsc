/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;


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

interface IPancakeSwapRouter {
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn, 
        uint256 amountOutMin, 
        address[] calldata path, 
        address to, 
        uint256 deadline
    ) external returns (uint[] memory amounts);
}

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}


contract tokenSwap {
    address private constant PANCAKESWAP_V2_FACTORY = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
    address private constant PANCAKESWAP_V2_ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address private constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    receive() external payable { }
    fallback() external payable { }

    function reverse(address[] memory a) internal pure returns (address[] memory) {
        address[] memory reversed = new address[](a.length);
        for (uint i=0; i<a.length; i++) {
            reversed[a.length-1-i] = a[i];
        }
        return reversed;
    }

    event Pls(uint256[2][2] indexed results);
    function swapAndBack(address[] calldata path) external payable returns (uint256[2][2] memory) {
        IPancakeSwapRouter router = IPancakeSwapRouter(PANCAKESWAP_V2_ROUTER);

        uint256[2][2] memory results;

        uint256[] memory grossAmountsBuy = router.swapExactETHForTokens { value: msg.value } (0, path, address(this), block.timestamp);
        uint256 netAmountBuy = IERC20(path[path.length -1]).balanceOf(address(this));
        results[0] = [grossAmountsBuy[grossAmountsBuy.length -1], netAmountBuy];

        address[] memory reversePath = reverse(path);

        //address pancakePairSell = IPancakeFactory(PANCAKESWAP_V2_FACTORY).getPair(reversePath[0], reversePath[1]);
        //IERC20(reversePath[0]).approve(pancakePairSell, netAmountBuy); // approve WBNB/Token pair
        IERC20(reversePath[0]).approve(PANCAKESWAP_V2_ROUTER, netAmountBuy); // approve PancakeSwap Router

        uint256[] memory grossAmountsSell = router.swapExactTokensForETH(netAmountBuy, 0, reversePath, address(this), block.timestamp);
        uint256 netAmountSell = IERC20(path[path.length -1]).balanceOf(address(this));
        results[1] = [grossAmountsSell[grossAmountsSell.length -1], netAmountSell];
        emit Pls(results);
        return results;
    }
}