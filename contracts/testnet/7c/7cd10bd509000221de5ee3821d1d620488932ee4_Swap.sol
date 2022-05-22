/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function factory() external pure returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract Swap {
    struct T {
        address Address;
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 reserve;
    }

    struct P {
        address pair;
        address factory;
        string symbol;
        uint256 totalSupply;
        uint32 blockTimestampLast;
        T token0;
        T token1;
    }

    function token(address account) public view virtual  returns (T memory) {
        T memory t;
        IERC20 uni = IERC20(account);
        t.decimals = uni.decimals();
        t.symbol = uni.symbol();
        t.totalSupply = uni.totalSupply();
        return t;
    }

    function pair(address account) public view virtual  returns (P memory) {
        P memory p;
        p.pair = account;
        IERC20 uni = IERC20(account);
        p.token0 = token(uni.token0());
        p.token1 = token(uni.token1());
        (p.token0.reserve, p.token1.reserve, p.blockTimestampLast) = uni.getReserves();
        p.totalSupply = uni.totalSupply();
        p.symbol = uni.symbol();
        return p;
    }
}