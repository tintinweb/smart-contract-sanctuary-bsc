pragma solidity ^0.8.4;

contract Test {

  string private _name;
  uint256 private _age;

  constructor(string memory name_, uint256 age_) public {
      _name = name_;
      _age = age_;
  }

  function changeName(string memory name_) public {
      _name = name_;
  }

  function changeAge(uint256 age_) public {
      _age = age_;
  }

  function name() public view returns (string memory) {
      return _name;
  }

  function age() public view returns (uint256) {
      return _age;
  }
}