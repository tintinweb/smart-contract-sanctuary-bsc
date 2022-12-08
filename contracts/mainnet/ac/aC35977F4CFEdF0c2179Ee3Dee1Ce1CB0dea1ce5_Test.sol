/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

contract Test {
    function pA(address tokenA, address tokenB, address factory, bytes memory hash) public pure returns (address) {
        require(tokenA != tokenB, 'Pattie: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        address pair;
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hash
            ))));

        return pair;
    }
}