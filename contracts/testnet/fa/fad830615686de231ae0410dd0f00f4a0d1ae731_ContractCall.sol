/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

contract ContractCall {
    address private MainCoin;

    function setMainCoin(address _coinAddr) public {
        require(_coinAddr != address(0), "coin is 0");
        MainCoin = _coinAddr;
        MainCoin.call(abi.encodeWithSignature("setMainPool(address)",this));
    }

    function allocation(address _dest) public {
        require(MainCoin != address(0), "please set MainCoin");
        require(_dest != address(0), "please set _dest");

        //bytes4 methodId = bytes4(keccak256("mint(address)"));
        MainCoin.call(abi.encodeWithSignature("mint(address)",_dest));
    }
}