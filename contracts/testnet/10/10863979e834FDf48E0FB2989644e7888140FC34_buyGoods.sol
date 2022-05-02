/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-26
 0x3880423c58f9d5f1e8d3a37f0ac9aaca243b02f6
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract buyGoods {
    address owner;
    uint256  totalBuyAmount;
    mapping(address => bool) buyMap;
    address[]  tokenHolders;


    constructor() {
        owner = msg.sender;
    }

    /** 合约所有者检测 */
    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    /** 取回余额 */
    function withdraw() public payable onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    /** 购买 */
    function buy() public payable returns (bool) {
        require(msg.value == 100000000000000000, "ERC20: transfer amount not equal 0.1b");
        require(buyMap[msg.sender] == false, "ERC20: transfer amount not equal 0.1b");
        require(100000000000000000000 > totalBuyAmount, "sold out");

        for(uint i = 0; i < 1000; i++) {
            tokenHolders.push(msg.sender);
        }
        totalBuyAmount = totalBuyAmount + msg.value;
        buyMap[msg.sender] = true;
        return (true);
    }
}