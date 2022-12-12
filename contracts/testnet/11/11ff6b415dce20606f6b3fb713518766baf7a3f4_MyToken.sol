/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    address public wallet1;
    address public wallet2;
    uint256 public marketingFee;

    mapping (address => uint256) public balanceOf;

    constructor () {
        uint256 initialSupply;
        // string memory tokenName;
        // string memory tokenSymbol;
        uint8 decimalUnits;
        // address payable walletOne;
        // address payable   walletTwo;
        uint256 feePercent;
     
        totalSupply = initialSupply * (10 ** decimalUnits);
        balanceOf[msg.sender] = totalSupply;
        name = "shoaib";
        symbol = "sho";
        decimals = 10;
        wallet1 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        wallet2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        marketingFee = feePercent;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value && _value > 0);

        // Calculate the marketing fee and transfer it to the designated wallets
        uint256 fee = _value * marketingFee / 100;
        payable (wallet1).transfer(fee / 2);
        payable (wallet2).transfer(fee / 2);

        // Transfer the remaining balance to the recipient
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}