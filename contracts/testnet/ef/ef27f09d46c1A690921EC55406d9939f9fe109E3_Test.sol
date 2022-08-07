// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Test {
    uint256 total;

    uint256 totalSupply = 1000;

    function updateTotal (uint256 _total) public returns (uint256 total){
        require(msg.sender != address(0), "Dead address");
        require(total != _total, "The same total");
        total = _total;
    }


    function updateTotalSupply (uint256 _totalSupply) public returns (uint256 totalSupply){
        require(msg.sender != address(0), "Dead address");
        require(totalSupply != _totalSupply, "The same total");
        totalSupply = _totalSupply;
    }
}