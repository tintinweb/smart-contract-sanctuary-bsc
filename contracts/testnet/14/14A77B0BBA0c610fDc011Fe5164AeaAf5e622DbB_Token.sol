/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract Token {
    string public name; 
    string public symbol;
    uint8 public decimals; //Holds the decimal places of the token
    uint256 public totalSupply;
    address payable public owner;

    /*Creating a mapping with all balances*/
    mapping(address => uint256) public balanceOf;

    /*Creating a mapping of accounts with allowances*/
    mapping(address => mapping(address => uint256)) public allowance;

    /*This event is fired on a succesfull call of the mint and burn methods*/
    event Transfer(address indexed from,address indexed to, uint256 value);

    /*This event is always fired on succesfull call of the approved method*/
    event Approve(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "Random";
        symbol = "RND";
        decimals = 18;
        uint256 _initialSupply = 1000000000; // Holds the initial supply

        owner = payable(msg.sender);

        balanceOf[owner] = _initialSupply;
        totalSupply = _initialSupply;

        emit Transfer(address(0),msg.sender,_initialSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transfer(address _to,uint256 _value) public returns (bool success){
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[msg.sender];

        require(_to != address(0),"Receiver address is invalid !");
        require(_value >= 0,"Value must be greater or equal to 0");
        require(senderBalance>_value, "Not enough balance");

        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender,_to,_value);
        return true;
    }

    /* allows an account to transfer tokens on behalf of another account, smart contract, charge fees*/
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 fromAllowance = allowance[_from][msg.sender];
        uint256 receiverBalance = balanceOf[_to];
         
        require(_to != address(0),"Receiver address invalid !");
        require(_value>=0,"Value must be greater or equal to 0");
        require(senderBalance > _value,"Not enough balance");
        require(fromAllowance >= _value,"Not enough allowance");

        balanceOf[_from] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;
        allowance[_from][msg.sender] = fromAllowance - _value;

        emit Transfer(_from, _to, _value);
        return true;

    }

    function approve(address _spender,uint256 _value) public returns(bool success) {
        require(_value > 0,"Value must be greater than 0");

        allowance[msg.sender][_spender] = _value;

        emit Approve(msg.sender, _spender, _value);

        return true;
    }

    function mint(uint256 _amount) public returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");

        totalSupply += _amount;
        balanceOf[msg.sender]+=_amount;

        emit Transfer(address(0),msg.sender, _amount);
        return true;
    }

    function burn(uint256 _amount) public returns (bool success) { 
        require(msg.sender != address(0),"Invalid burn recipient");

        uint256 accountBalance = balanceOf[msg.sender];
        require(accountBalance > _amount, "Burn amount exceeds balance");

        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;

        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }
}