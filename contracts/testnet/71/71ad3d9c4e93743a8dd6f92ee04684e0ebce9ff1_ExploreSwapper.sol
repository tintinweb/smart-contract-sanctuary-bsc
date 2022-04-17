/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;


contract ExploreSwapper {

    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function getBalance(
        address token
    ) external view returns(uint256) {
        return IBEP20(token).balanceOf(address(this));
    }

    function extractFunds(
        address token,
        uint256 amount
    ) external {
        IBEP20(token).transfer(_owner, amount);
    }

    function getAmounts(
        uint256 amountIn,
        address[] memory pairs,
        uint256[] memory mults,
        address[] memory route
    )  public view returns (
        uint256[] memory amounts
    ) {
        amounts = new uint256[](route.length);
        amounts[0] = amountIn;

        for (uint256 i = 0; i < pairs.length; i++) {
            amounts[i+1] = UniswapRouter.getAmountOut(pairs[i],
                route[i], route[i+1], mults[i], amounts[i]);
        }
    }

    function swap(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory pairs,
        uint256[] memory mults,
        address[] memory route
    ) external {
        uint256[] memory amounts = getAmounts(amountIn, pairs, mults, route);
        require(amounts[amounts.length - 1] >= amountOutMin, "ExploreSwapper: output error");

        for (uint256 i = 0; i < pairs.length; i++) {
            if(i==0){
                IBEP20(route[i]).transfer(pairs[i], amounts[i]);
            }
            address recipient = getUniswapRecipient(i, pairs);
            UniswapRouter.swap(pairs[i], route[i],
                route[i+1], amounts[i+1], recipient);
        }
    }

    function getUniswapRecipient(
        uint256 i,
        address[] memory pairs
    ) private view returns(
        address recipient
    ) {
        if (i+1 == pairs.length) {
            recipient = address(this);
        } else {
            recipient = pairs[i+1];
        }
    }
}

library UniswapRouter {

    using SafeMath for uint256;
    uint256 private constant BASE_MULT = 10000;

    function swap(
        address pair,
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        address recipient
    ) internal {
        address token0 = tokenIn < tokenOut ? tokenIn : tokenOut;
        (uint amount0Out, uint amount1Out) = tokenIn == token0 ?
        (uint256(0), amountOut) : (amountOut, uint256(0));

        IPancakePair(pair).swap(amount0Out,
            amount1Out, recipient, new bytes(0));
    }

    function getAmountOut(
        address pair,
        address tokenIn,
        address tokenOut,
        uint256 feeMult,
        uint256 amountIn
    ) internal view returns (
        uint256 amountOut
    ) {
        (uint256 reserveIn, uint256 reserveOut) =
        getReserves(pair, tokenIn, tokenOut);

        uint256 amountInWithFee = amountIn.mul(feeMult);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(BASE_MULT).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getReserves(
        address pair,
        address tokenIn,
        address tokenOut
    ) internal view returns (
        uint256 reserveIn,
        uint256 reserveOut
    ) {
        address token0 = tokenIn < tokenOut ? tokenIn : tokenOut;
        (uint256 r0, uint256 r1, ) = IPancakePair(pair).getReserves();
        (reserveIn, reserveOut) = tokenIn == token0 ? (r0, r1) : (r1, r0);
    }
}

interface IPancakePair {

    function swap(
        uint amount0Out,
        uint amount1Out,
        address recipient,
        bytes calldata data
    ) external;

    function getReserves() external view
    returns (uint256, uint256, uint256);

    function swapFee() external view
    returns (uint256);
}

interface IBEP20 {

    function balanceOf(
        address whom
    ) external view returns (uint256);

    function approve(
        address spender,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

library SafeMath {

    function add(uint x, uint y)
    internal pure returns (uint z) {
        require((z = x + y) >= x,
            "SafeMath: add overflow");
    }

    function mul(uint x, uint y)
    internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x,
            "SafeMath: mul overflow");
    }
}