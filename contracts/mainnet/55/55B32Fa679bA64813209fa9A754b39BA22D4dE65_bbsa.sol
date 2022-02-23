/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract bbsa{
    
    address public contractAddress;
    address public ownerAddress;
    address  public ZeroAddress= address(0);
    uint public contractbalance; 

    constructor(){
        ownerAddress = msg.sender;
        contractAddress = address (this);
    }


    function makevalue() public payable{
        contractbalance += msg.value ;
    }
    function getballanceofcontract() public view returns(uint) {
        return contractbalance;
    }

    function ownerpay() public payable {
        if(msg.sender==ownerAddress){
            contractbalance += msg.value ;
        }
    }
}