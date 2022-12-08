/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

contract Test {
    function pA(address tokenA, address tokenB, bytes memory hash) public returns (address) {
        require(tokenA != tokenB, 'Pattie: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        address pair;

        assembly {
            pair := create2(0, add(hash, 32), mload(hash), salt)
        }

        return pair;
    }
}