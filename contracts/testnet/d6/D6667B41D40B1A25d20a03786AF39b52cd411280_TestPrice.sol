/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IUniswapV2Router01 {
    function getAmountsOut(uint256 amountIn, address[3] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract TestPrice {
    IUniswapV2Router01 public uniswapV1Router =
        IUniswapV2Router01(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address public BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    address public MFET = 0xe5C06Ed88c8cCE4667946FdA10ae2cb69dEaaA96;

    function getPrice(uint256 _amount)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory _price = uniswapV1Router.getAmountsOut(
            _amount,
            [MFET, WBNB, BUSD]
        );
        return _price;
    }
}