/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function factory() external pure returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract Swap {

    function token(address account) public view virtual returns (string memory symbol, uint8 decimals, uint256 totalSupply) {
        IERC20 uni = IERC20(account);
        return (uni.symbol(), uni.decimals(), uni.totalSupply());
    }

    function pair(address account) public view virtual returns (
        string memory amm,
        string memory symbol0,
        uint8 decimals0,
        uint256 totalSupply0,
        uint256 reserve0,
        string memory symbol1,
        uint8 decimals1,
        uint256 totalSupply1,
        uint256 reserve1,
        uint256 supply,
        uint32 blockTimestampLast
    ) {
        IERC20 uni = IERC20(account);
        amm = uni.symbol();
        supply = uni.totalSupply();
        (reserve0, reserve1, blockTimestampLast) = uni.getReserves();
        (symbol0, decimals0, totalSupply0) = token(uni.token0());
        (symbol1, decimals1, totalSupply1) = token(uni.token1());
        return (amm,symbol0,decimals0,totalSupply0,reserve0,symbol1,decimals1,totalSupply1,reserve1,supply,blockTimestampLast);
    }
}