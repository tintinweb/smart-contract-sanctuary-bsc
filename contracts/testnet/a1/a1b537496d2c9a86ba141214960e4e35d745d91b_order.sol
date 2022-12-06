/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
contract order{

    uint idGenerator;
    struct customer{
        string productName;
        uint productId;
        bool status;
        address customerAddress;
    }
    mapping(address=>customer) orders;

    function doOrder(string memory _productName) public {
        idGenerator +1;
        orders[msg.sender].productName=_productName;
        orders[msg.sender].productId=idGenerator;
        orders[msg.sender].customerAddress=msg.sender;
    }
    function cancelOrder() public{
        delete orders[msg.sender];
    }
    function getOrders(address _customerAddress) public view returns(customer memory){
    return orders[_customerAddress];
    }
}