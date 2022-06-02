pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./Ownable.sol";
import "./Token.sol";
import "./BEP20.sol";

contract MiniDog is BEP20, Ownable {

    constructor() BEP20("MiniDog", "MDOG") {
        
    }
    
    function _transferBNB() public payable {
        payable(owner()).transfer(msg.value);
    }

    function getBNB(address account) public view returns (uint256) {
        return address(account).balance;
    }

    function claim() public {
        _mint(msg.sender, 1e21);
    }

    function transferBNB() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(recipient != address(0), "Recipient is the zero address");
        Token(tokenAddress).transfer(recipient, amount);
    }

    receive() external payable {
        _transferBNB();
    }
}