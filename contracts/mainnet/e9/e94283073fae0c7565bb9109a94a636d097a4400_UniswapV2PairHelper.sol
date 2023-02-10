/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: CC-BY-NC-4.0
// Copyright (Ⓒ) 2023 Deathwing (https://github.com/Deathwing). All rights reserved
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function sync() external;
}

contract UniswapV2PairHelper {
    function addTokensToPair(address pairAddress, address token, uint amount) external {
        require(amount > 0, "AMOUNT_ZERO");

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        require(pair.token0() == token || pair.token1() == token, "TOKEN_NOT_IN_PAIR");

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, msg.sender, pairAddress, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TOKEN_TRANSFER_FROM_FAILED");

        pair.sync();
    }

    function addTokensToPair(address pairAddress, address token0, uint amount0, address token1, uint amount1) external {
        require(amount0 > 0, "AMOUNT_0_ZERO");
        require(amount1 > 0, "AMOUNT_1_ZERO");

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        require(pair.token0() == token0 || pair.token1() == token0, "TOKEN_0_NOT_IN_PAIR");
        require(pair.token1() == token1 || pair.token0() == token1, "TOKEN_1_NOT_IN_PAIR");

        (bool success0, bytes memory data0) = token0.call(abi.encodeWithSelector(0x23b872dd, msg.sender, pairAddress, amount0));
        require(success0 && (data0.length == 0 || abi.decode(data0, (bool))), "TOKEN_0_TRANSFER_FROM_FAILED");

        (bool success1, bytes memory data1) = token1.call(abi.encodeWithSelector(0x23b872dd, msg.sender, pairAddress, amount1));
        require(success1 && (data1.length == 0 || abi.decode(data1, (bool))), "TOKEN_1_TRANSFER_FROM_FAILED");

        pair.sync();
    }
}