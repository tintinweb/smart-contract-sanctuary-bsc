/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.13;
contract Testament{

    address _manager;
    mapping(address => address) _heir;
    mapping(address => uint) _balance;
    event createTest(address indexed owner,address indexed heir,uint amount);
    event ReportofDeath(address indexed owner,address indexed heir,uint amount);

    constructor(){
        _manager = msg.sender;
    }
    
    //owner call to create the testament
    function create(address heir) public payable{
        require(msg.value > 0, "please Enter the amount (Needs to be more than 0)");
        require(_balance[msg.sender]<=0,"Testament already created Please Exit");
        _heir[msg.sender] = heir;
        _balance[msg.sender] = msg.value;
        emit createTest(msg.sender, heir, msg.value);
    }
    function getTestament(address owner) public view returns(address heir, uint amount){
        return (_heir[owner],_balance[owner]);
    }

    function reportDeath(address owner) public{
        require(msg.sender == _manager,"Unauthorized");
        require(_balance[owner] > 0 , "No testament was created");
        emit ReportofDeath(owner, _heir[owner], _balance[owner]);
        payable(_heir[owner]).transfer(_balance[owner]);
        _balance[owner] = 0;
        _heir[owner] = address(0);
    }

}