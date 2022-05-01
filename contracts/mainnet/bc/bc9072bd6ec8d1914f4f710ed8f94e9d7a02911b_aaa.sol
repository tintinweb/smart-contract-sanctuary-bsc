/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

pragma solidity 0.8.7;

contract aaa {
    address public owner;
    mapping (address => uint) public balances;
    mapping (address => uint) public entries;

    constructor() {
        owner = msg.sender;
        balances[address(this)] = 100000000;
    }

    function refill(uint amount) public {
        require(msg.sender == owner, "Only the owner can refill.");
        balances[address(this)] += amount;
    }

    function entry(string memory content) public {
        
    }
}