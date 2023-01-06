/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

pragma solidity >=0.4.22 <0.9.0;


contract MaidaanToken {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    uint256 amount1;

    constructor() {
        name = "Maidaan";
        symbol = "MDC";
        decimals = 18;
        totalSupply = 50000000 * (10 ** uint256(decimals));
        // set the owner to msg.sender
        owner = msg.sender;
        // assign the totalSupply to msg.sender
        balanceOf[msg.sender] = totalSupply;
    }

    mapping(address => uint256) public balanceOf;

   function transfer(address recipient, uint256 amount) public returns (bool) {
        // calculate the commission
        uint256 commission = amount/100000;
        // subtract the commission from the amount
        amount1 = amount-commission;
        // require that the sender has enough balance to cover the commission
        require(balanceOf[msg.sender] >= commission, "Insufficient balance to cover the commission.");
        // transfer the commission to the owner
        balanceOf[owner] = balanceOf[owner]+commission;
        // require that the sender has enough balance to cover the remaining amount
        require(balanceOf[msg.sender] >= amount1, "Insufficient balance.");
        balanceOf[msg.sender] = balanceOf[msg.sender]-amount;
        balanceOf[recipient] = balanceOf[recipient]+amount1;
        return true;
    }
}