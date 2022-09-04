/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;
    
interface TokenTransfer {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value) external;
}
abstract contract owned {
    address public owner;

    constructor() {
        owner = 0xB884099d5DDD146716d0886625Fc13f96762eb4b;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}
    
contract FsbDapp is owned {
    
    uint256 public releaseAmount = 7 * 10 ** 13;
    uint256 public withdrawalTime;
    address public tokenAddress = 0xe460074C4Ca3A7dDBF25d0ccB1627C70c67FE84f;
   
    function withdrawal(address withdrawalAddress) external onlyOwner{
        uint256 dTime = block.timestamp - withdrawalTime;
        uint256 amount = dTime * releaseAmount;
        TokenTransfer(tokenAddress).transfer(withdrawalAddress,amount);
        withdrawalTime = block.timestamp;
    }
    function getAmount() external view returns(uint256 withdrawalAmount){
        uint256 dTime = block.timestamp - withdrawalTime;
        withdrawalAmount = dTime * releaseAmount;
    }
    function onpen() external onlyOwner{
        withdrawalTime = block.timestamp;
    }
}