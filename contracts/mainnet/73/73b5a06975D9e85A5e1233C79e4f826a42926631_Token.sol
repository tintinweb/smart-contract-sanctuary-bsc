/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.2;
contract Token {
    string public name = "QATAR 2022 TOKEN";
    string public symbol = "QWC";
    uint8 public decimals = 8;
    uint256 public totalSupply = 202200000000000000;
    address public owner;
    modifier restricted {
        require(msg.sender == owner, "This function is restricted to owner");
        _;
    }
    modifier issuerOnly {
        require(isIssuer[msg.sender], "You do not have issuer rights");
        _;
    }
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isIssuer;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event IssuerRights(address indexed issuer, bool value);
    event TransferOwnership(address indexed previousOwner, address indexed newOwner);

    function getOwner() public view returns (address) {
        return owner;
    }

    function mint(address _to, uint256 _amount) public issuerOnly returns (bool success) {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function burn(uint256 _amount) public issuerOnly returns (bool success) {
        totalSupply -= _amount;
        balanceOf[msg.sender] -= _amount;
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }

    function burnFrom(address _from, uint256 _amount) public issuerOnly returns (bool success) {
        allowance[_from][msg.sender] -= _amount;
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
        emit Transfer(_from, address(0), _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom( address _from, address _to, uint256 _amount) public returns (bool success) {
        allowance[_from][msg.sender] -= _amount;
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function transferOwnership(address _newOwner) public restricted {
        require(_newOwner != address(0), "Invalid address: should not be 0x0");
        emit TransferOwnership(owner, _newOwner);
        owner = _newOwner;
    }

    function setIssuerRights(address _issuer, bool _value) public restricted {
        isIssuer[_issuer] = _value;
        emit IssuerRights(_issuer, _value);
    }

    constructor() {
        name = "QATAR 2022 TOKEN"; // Sets the name of the token, i.e Ether
        symbol = "QWC"; // Sets the symbol of the token, i.e ETH
        decimals = 8; // Sets the number of decimal places
        uint256 _initialSupply = 202200000000000000; // Holds an initial supply of coins

        /* Sets the owner of the token to whoever deployed it */
        owner = payable(msg.sender);

        balanceOf[owner] = _initialSupply; // Transfers all tokens to owner
        totalSupply = _initialSupply; // Sets the total supply of tokens

        /* Whenever tokens are created, burnt, or transfered,
            the Transfer event is fired */
        emit Transfer(address(0), msg.sender, _initialSupply);
    }
}