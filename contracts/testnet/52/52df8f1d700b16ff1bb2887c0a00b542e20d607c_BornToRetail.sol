/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

contract BornToRetail {
    address payable public Owner;

    constructor() { 
        Owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == Owner, 'Not owner'); 
        _;
    }

    function deposit() public payable {}

    function withdraw(uint _amount) public onlyOwner { 
        transfer(Owner, _amount);
    }

    function balanceOf() public view returns(uint){
        return address(this).balance;
    }

    function transfer(address payable _to, uint _amount) public onlyOwner {
        require(balanceOf() > _amount, "balance insufficient");
        _to.transfer(_amount);
    }
}