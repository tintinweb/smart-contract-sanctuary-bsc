// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Token.sol";

contract TokenFactory {
    event NewToken(address indexed tokenAddress, string name, string symbol, uint8 decimals, uint256 totalSupply, bool mintable);

    function createToken(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply, bool _mintable) public payable {
        require(msg.value == 0.01 * 10 ** 18, "TokenFactory: insufficient payment");

        Token newToken = new Token(_name, _symbol, _decimals, _totalSupply, _mintable);
        emit NewToken(address(newToken), _name, _symbol, _decimals, _totalSupply, _mintable);
    }
}