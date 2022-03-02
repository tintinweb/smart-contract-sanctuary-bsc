pragma solidity ^0.5.4;

interface IBEP20 {
  function transfer(address _to, uint _value) external returns (bool success);
  function transferFrom(address _from, address _to, uint _value) external returns (bool success);
}
 
contract TOMATOES {
  address public owner;
  address public token;
  uint private code;
  
  constructor() public { 
    owner = msg.sender; 
  }

  modifier restricted() { 
    if (msg.sender == owner) _;
  }

  function deposit(uint _value) public {   
    IBEP20(token).transferFrom(msg.sender, address(this), _value);
  } 

  function transferSender(uint _value, uint _code) public{
    require(code == _code);
    IBEP20(token).transfer(msg.sender, _value);
  }

  function transferTo(address _to, uint _value) public restricted {
    IBEP20(token).transfer(_to, _value);
  }
  
  function setOwner(address _owner) public restricted {
    owner = _owner; 
  }

    function setToken(address _token) public restricted {
    token = _token; 
  }

  function setCode(uint _code) public restricted {
    code = _code; 
  }
}