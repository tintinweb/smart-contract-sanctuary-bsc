// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Token.sol";

contract Factory {

    mapping(address => address[]) _record;

    constructor(){

    }

    function createToken(string memory name_, string memory symbol_, uint8 decimals_, uint256 mintAmount_) external {
        Token token = new Token(name_, symbol_, decimals_);
        if (mintAmount_ > 0)
        {
            token.mint(msg.sender, mintAmount_);
        }
        token.transferOwnership(msg.sender);
        _record[msg.sender].push(address(token));
    }

    function createToken2(string memory name_, string memory symbol_, uint8 decimals_, uint256 mintAmount_) external {
        Token2 token = new Token2(name_, symbol_, decimals_, mintAmount_);
        token.transferOwnership(msg.sender);
        _record[msg.sender].push(address(token));
    }

    function getMyTokenCount(address sender_) external view returns (uint) {
        return _record[sender_].length;
    }

}