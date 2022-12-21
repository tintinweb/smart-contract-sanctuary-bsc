/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract MyContract {
    address profitAddress;
    address owner;
    uint256 profitPercent;

    modifier onlyOwner {
        require(owner == msg.sender, 'Not owner');
        _;
    }
    constructor(address _addr, uint256 _percent) {
        profitAddress = _addr;
        profitPercent = _percent;
        owner = msg.sender;
    }
    function setProfit(address _addr) public onlyOwner{
        profitAddress = _addr;
    }

    function setPercent(uint256 _percent) public onlyOwner {
        profitPercent = _percent;
    }

    function getProfit() external view returns(address) {
        return profitAddress;
    }

    function getPercent() external view returns (uint256) {
        return profitPercent;
    }

    function transferOwner(address to) public onlyOwner {
        owner = to;
    }
}