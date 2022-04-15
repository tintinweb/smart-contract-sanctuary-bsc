/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract MyToken {

    string public name = "MPU Token";
    string public symbol = "MPU";
    uint256 public totalSupply = 10**12; // 1 Trillion   1 000 000 000 000
    uint8 public decimal = 18;
    mapping (address => uint256) public balanceOf;
    address private owner;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    //  _seed = will be taken from token contract
    //  company = will be taken from token contract
    //  liquidity pool = will be taken from token contract
    // address charity = 
    // address presale
    // address sale
    address deadWallet = 0x000000000000000000000000000000000000dEaD;
    // address marketing1 = 0x583031D1113aD414F02576BD6afaBfb302140225;
    // address marketing2 = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
    // address team1 = 0xDdb6f995B2b9B9B533BA283693e888682EB0CEEc;
    // address team2 = 0xDdb6f995B2b9B9B533BA283693e888682EB0CEEc;

    // vesting 


    constructor() {
        owner = msg.sender;
        // balanceOf[marketing1] = totalSupply * 19 / 2 / 100;
        // balanceOf[marketing2] = totalSupply * 19 / 2 / 100;
        // balanceOf[team1] = totalSupply * 11 / 100;
        // balanceOf[team2] = totalSupply * 11 / 100;
        // balanceOf[owner] = totalSupply - balanceOf[marketing1] - balanceOf[marketing2] - balanceOf[team1] - balanceOf[team2];
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function isOwner() private view returns (bool _isOwner) {
        require(owner == msg.sender);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[msg.sender], "Not enough amount to transfer");
        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        return true;        
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

    }

    /**
        regular burn until the amount reaches 10 ** 6
    **/
    function burn(uint256 _amount) public returns (bool success) {
        require(isOwner(), "Only owner can execute this transaction");
        require (_amount <= totalSupply * 5 / 100, "is not allowed to burn more than 5%");
        require (totalSupply > 10**6);
        balanceOf[owner] -= _amount;
        balanceOf[deadWallet] += _amount;
        return true;
    }
}