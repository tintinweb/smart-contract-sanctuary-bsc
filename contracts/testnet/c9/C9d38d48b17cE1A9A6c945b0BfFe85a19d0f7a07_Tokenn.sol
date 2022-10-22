pragma solidity ^0.8.0;

contract Tokenn {
    mapping(address => uint256) public balances;
    address public minter;

    constructor() {
        minter = msg.sender;
    }

    function mint(address receiver, uint256 amount) public {
        require(msg.sender == minter);

        balances[receiver] += amount;
    }

    function send(address receiver, uint256 amount) public {
        require(amount <= balances[msg.sender]);
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
    }
}