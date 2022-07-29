/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;



contract SPORTXPAYMENT {
    address contract_owner;
    event Pay(string indexed orderid,address indexed sender,uint256 amount);
    event Withdraw(address indexed target,uint256 amount);
    constructor() {
        if(contract_owner!=address(0)){
            return;
        }
        contract_owner=msg.sender;
    }
    function pay(string memory orderid) public payable {
        emit Pay(orderid,msg.sender, msg.value);
    }
    function withdraw(address payable target_address,uint256 amount) public{
        require(
            msg.sender==contract_owner,
            "Only contract owner can calling this function."
        );
        if(target_address==address(0)){
            return;
        }
        target_address.transfer(amount);
        emit Withdraw(target_address, amount);
    }
}