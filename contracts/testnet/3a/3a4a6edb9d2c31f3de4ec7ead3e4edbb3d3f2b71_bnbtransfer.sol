/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract bnbtransfer{
    event Send(address indexed from, address indexed to, uint indexed amount );

    address  public owner;
    address payable private owner_;

    constructor() {
    owner = msg.sender;
    }

    function Toaddress() view public returns(address){
        return owner_;
    }

    function changeowner(address _owner) public {
        require(msg.sender == owner,"only owner");
        owner = _owner;
    }

    function setaddress(address payable _owner) public{
        require(msg.sender == owner,"only owner");
        owner_ = _owner;
    }

    function transfer() public payable{
        owner_.transfer(msg.value);
        emit Send(msg.sender,owner_,msg.value);
    }

    function balanceof(address _add) view public returns(uint){
        return _add.balance;
    }
}