/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract firstCoin {
    address private owner = 0x5ed72E9B408c30E0D3d09A70B1cbE98017826799;
    string private token = "FirstCoin";
    uint256 private totalSupply = 1000000000;
    uint8 public decimals = 18;

    mapping(address => uint256) private balances;

  event Transfer(address indexed to, uint256 value);
    

    function transfer(address recipient, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient tokens");
        require(recipient != address(0), "Recipient cannot be Zero Adress");
        balances[recipient] = balances[recipient] + amount;
        balances[msg.sender] = balances[msg.sender] - amount;

        emit Transfer(recipient, amount);
    }


}