// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Test {
    uint256 public total;

    uint256 public totalSupply = 1000;

    mapping(address => uint256) public money;

    function updateTotal (uint256 _total) public returns (uint256){
        require(msg.sender != address(0), "Dead address");
        require(total != _total, "The same total");
        total = _total;
    }


    function updateTotalSupply (uint256 _totalSupply) public returns (uint256){
        require(msg.sender != address(0), "Dead address");
        require(totalSupply != _totalSupply, "The same total");
        totalSupply = _totalSupply;
    }

    function accumulate () public returns (uint256) {
        money[msg.sender] = totalSupply / 10;
        return totalSupply / 10;
    }
}