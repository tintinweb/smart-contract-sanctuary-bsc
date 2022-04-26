//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Greetertest {
    string private greeting;
    mapping(uint256 => uint256) public pool;
    mapping(address => uint256) public user;
    constructor(string memory _greeting) {
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        greeting = _greeting;
    }

    function setPool(uint256 _index,uint256 _val) public returns (uint256 val) {
        val = _val;
        pool[_index] = _val;
    }

    function tranVal() public payable returns (uint256 val) {
         require(msg.value >0,"val < 0");
         val  =   msg.value;
    }

    function tranValTwo(address _user) public payable returns (address useraddress,uint256 val) {
        require(msg.value >0,"val < 0");
        val  =   msg.value;
        useraddress = _user;
        user[_user] = msg.value;
        return (_user,val);
    }


}