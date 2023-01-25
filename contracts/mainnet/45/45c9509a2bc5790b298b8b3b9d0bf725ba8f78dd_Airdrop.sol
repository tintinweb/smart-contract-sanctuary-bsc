// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "./IERC20.sol";
import "./Ownable.sol";


contract Airdrop is Ownable {

    IERC20 public token;

    bool public initialized;

    function initialize(address _token) public onlyOwner {
        require(!initialized, "Already Intialized");
        token = IERC20(_token);
        initialized = true;
    }

    function airdrop(address[] memory _recipients, uint256[] memory _values) public onlyOwner {
        require(_recipients.length == _values.length, "Total number of recipients and values are not equal"); 
        for(uint i= 0; i < _recipients.length; i++) {
            token.transfer(_recipients[i], _values[i]);
        }    
    }

    function withdrawTokens() public onlyOwner{
        token.transfer(owner(), token.balanceOf(address(this)));
    }  
}