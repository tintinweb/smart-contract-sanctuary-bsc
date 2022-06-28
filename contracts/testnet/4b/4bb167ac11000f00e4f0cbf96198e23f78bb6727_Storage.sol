/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Storage {

    string secretkey;
    
    address public owner;

    // modifiers
    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }


    function store(string memory sk) public onlyOwner {
        secretkey = sk;

    }


    function retrieve() public onlyOwner view returns (string memory){
        return secretkey;
    }
    

    // 初始化，创建合约的人叫owner
    constructor() {
        owner = msg.sender;
    }
}