/**
 *Submitted for verification at BscScan.com on 2022-02-06
*/

// SPDX-License-Identifier: GPL-3.0


pragma solidity >=0.8.11;

contract Token{

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address payable public owner;

    //create mapping w/all balances
    mapping(address => uint256) public balanceOf;

    //create mapping of accounts with allowances
    mapping(address => mapping(address => uint256)) public allowance;

    //event fired on a successfull call of transfer, transferfrom, mint, burn methods
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approve(address indexed owner, address indexed to, uint256 value);

    constructor(){
        name = "Swell";
        symbol = "SWELL";
        decimals = 18;
        uint256 _initialSupply = 1000000 ether;

        //sets owner to whoever deployed it
        owner = payable(msg.sender);

        //transfer all tokens to owner
        balanceOf[owner] = _initialSupply;

        //set total supply of tokens
        totalSupply = _initialSupply;

        //fired when tokens are transferred (created/burnt/transferred/etc.)
        emit Transfer(address(0), msg.sender, _initialSupply);
        }

        function getOwner() public view returns (address){
            return owner;
        }

        function transfer (address _to, uint256 _value) public returns (bool success){
            uint256 senderBalance = balanceOf[msg.sender];
            uint256 receiverBalance = balanceOf[_to];

            //receiver address is invalid
            require(_to != address(0), "Receiver address invalid");

            //value must be > 0
            require(_value >=0 , "Value must be greater than or equal to 0");

            //Not enough balance
            require(senderBalance > _value, "Not enough balance");

            balanceOf[msg.sender] = senderBalance - _value;
            balanceOf[_to] = receiverBalance + _value;

            emit Transfer(msg.sender, _to, _value);
            return true;
        }

        function transferfrom(address _from, address _to, uint256 _value) public returns (bool success){
            uint256 senderBalance = balanceOf[msg.sender];
            uint256 fromAllowance = allowance[_from][msg.sender];
            uint256 receiverBalance = balanceOf[_to];

            require(_to != address(0), "Receiver address invalid");
            require(_value >= 0, "Value must be greater or equal to 0");
            require(senderBalance > _value, "Not enough balance");
            require(fromAllowance >= _value, "Not enough allowance");
            balanceOf[_from] = senderBalance - _value;
            balanceOf[_to] = receiverBalance + _value;
            allowance[_from][msg.sender] = fromAllowance - _value;

            emit Transfer(_from, _to, _value);
            return true;
        }

        function approve(address _spender, uint256 _value) public returns(bool success){
            require(_value > 0, "Value must be greater than 0");
            allowance[msg.sender][_spender] = _value;
            emit Approve(msg.sender, _spender, _value);
            return true;
        }

        function mint(uint256 _amount) public returns (bool success){
            require(msg.sender == owner, "Owner unauthorized");
            totalSupply += _amount;
            balanceOf[msg.sender] += _amount;
            
            emit Transfer(address(0), msg.sender, _amount);
            return true;
        }

        function burn(uint256 _amount) public returns(bool success){
            require(msg.sender != address(0), "Invalid burn recipient");

            uint256 accountBalance = balanceOf[msg.sender];
            require(accountBalance > _amount, "Burn amount exceeds balance");

            balanceOf[msg.sender] -= _amount;
            totalSupply -= _amount;

            emit Transfer(msg.sender, address(0), _amount);
            return true;
        }
    }