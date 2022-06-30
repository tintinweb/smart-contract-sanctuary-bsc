/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

// Creating a contract object for our token
contract Token {
    // Token public parameters
    string public name; // token name
    string public symbol; // token symbol
    uint8 public decimals; // token decimal places
    uint256 public totalSupply; // total supply of the token
    address payable public owner; // token owner address

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approve(address indexed owner, address indexed spender, uint256 value);

    // functions : name(), symbol(), decimals(), totalSupply(), owner(), balanceOf(), allowance()

    // TODO: increaseAllowance, decreaseAllowance, 

    // contructor function
    constructor() {
        name = "KIMI Token";
        symbol = "KIMI";
        decimals = 18;
        uint256 _initialSupply = 1000000000; //initial supply of coins

        // setting the owner to the address to the orginator's address
        owner = payable(msg.sender);

        balanceOf[owner] = _initialSupply; // Transfering all tokens to owner
        totalSupply = _initialSupply; // Setting the total supply of tokens

        // for buring the token
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    // returns the owner's address 
    function getOwner() public view returns (address) {
        return owner;
    }

    // transfer function
    function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");

        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // transfer from function
    function transferFrom(address _from, address _to, uint256 _value)
      public returns (bool success) {
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

    // approve function
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0, "Value must be greater than 0");

        allowance[msg.sender][_spender] = _value;

        emit Approve(msg.sender, _spender, _value);
        return true;
    }

    //  mint function
    function mint(uint256 _amount) public returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");

        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }

    // burn function
    function burn(uint256 _amount) public returns (bool success) {
      require(msg.sender != address(0), "Invalid burn recipient");

      uint256 accountBalance = balanceOf[msg.sender];
      require(accountBalance > _amount, "Burn amount exceeds balance");

      balanceOf[msg.sender] -= _amount;
      totalSupply -= _amount;

      emit Transfer(msg.sender, address(0), _amount);
      return true;
    }
}