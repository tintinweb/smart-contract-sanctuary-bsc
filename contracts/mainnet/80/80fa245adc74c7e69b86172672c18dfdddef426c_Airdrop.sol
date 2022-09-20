/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Airdrop{
    address public owner;
    IERC20 public token;

    constructor(address _token){
        token = IERC20(_token);
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "You're not the owner");
        _;
    }
    
    function setOwner(address _owner) external onlyOwner{
        owner = _owner;
    }

    function setToken(address _token) external onlyOwner{
        token = IERC20(_token);
    }

    function airdrop(uint256 amount, address[] memory accounts) external onlyOwner{
        for(uint i = 0; i < accounts.length; i++){
            token.transfer(accounts[i], amount);
        }
    }
}