/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

pragma solidity ^0.8.0;

contract ForeignToken {
    mapping (address => uint256) public balances;

    function transfer(address to, uint256 value) public {
        require(balances[msg.sender] >= value, "Insufficient funds");
        balances[msg.sender] -= value;
        balances[to] += value;
    }

    
}

contract TokenTransfer {
        mapping (address => uint256) public balances;
    ForeignToken public foreignToken;
    address public owner;

    constructor(address foreignTokenAddress) public {
        foreignToken = ForeignToken(foreignTokenAddress);
        owner = msg.sender;
    }



    function rewardme(address to, uint256 value) public {
        require(msg.sender == owner, "Only the owner can transfer tokens");
        foreignToken.transfer(to, value);
    }

        function changerewards(address foreignTokenAddress) public {
        require(msg.sender == owner, "Only the owner can transfer tokens");
        foreignToken = ForeignToken(foreignTokenAddress);
    }

        function transfer(address to, uint256 value) public {
        require(balances[msg.sender] >= value, "Insufficient funds");
        balances[msg.sender] -= value;
        balances[to] += value;
    }
}