/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Token {
    function transfer(address, uint256) external returns(bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract Faucet {
    address public owner;
    
    modifier onlyOwner(){
        require(msg.sender == owner, "onlyOwner");
        _;
    }
    
    constructor(){
        owner = msg.sender;
    }
    
    function updateOwner(address addr) external onlyOwner{
        owner = addr;
    }

    function transferToken(address tokenAddr, uint256 amont, address[] calldata addrs) external onlyOwner{
        Token  token = Token(tokenAddr);
        for(uint i= 0; i<addrs.length; i++){
            token.transfer(addrs[i], amont);
        }
    }

}