// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import  "./Token.sol";


contract Presale {
    Token public token;

    
    event TokenPurchased(
        address account,
        address token,
        uint amount
    );
   
    constructor(Token _token) public {
        token = _token;
    }
    
    function presale() public payable {
        uint tokenAmount = msg.value * 29620;
        require(token.balanceOf(address(this)) >= tokenAmount);
        token.transfer(msg.sender, tokenAmount);
        emit TokenPurchased(msg.sender, address(token), tokenAmount);
    }
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function endPresale(uint256 _amount) public {
        require(msg.sender == 0x44cF727792d9bcbCBD9D764FA00849Af688B67F6);
        token.transfer(msg.sender, _amount);
    }

    function listOnPancakeswap() public {
        require(msg.sender == 0x44cF727792d9bcbCBD9D764FA00849Af688B67F6);
        require(msg.sender.send(address(this).balance));

    }
    
}