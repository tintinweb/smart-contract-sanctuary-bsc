/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

pragma solidity ^0.8.0;

contract ArbitrageBot {
    address owner;

    struct Token {
        string name;
        address contractAddress;
    }

    struct Exchange {
        string name;
        address contractAddress;
    }

    Token[] public tokens;
    Exchange[] public exchanges;

    constructor() public {
        owner = msg.sender;
    }

    function addToken(string memory name, address contractAddress) public onlyOwner {
        Token memory newToken = Token({
            name: name,
            contractAddress: contractAddress
        });
        tokens.push(newToken);
    }

    function addExchange(string memory name, address contractAddress) public onlyOwner {
        Exchange memory newExchange = Exchange({
            name: name,
            contractAddress: contractAddress
        });
        exchanges.push(newExchange);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner of this contract.");
        _;
    }
}