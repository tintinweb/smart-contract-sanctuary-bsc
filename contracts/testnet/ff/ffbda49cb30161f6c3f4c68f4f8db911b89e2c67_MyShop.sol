/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// File: MyShop.sol





pragma solidity ^0.8.0;



contract MyShop {



    address public owner;

    mapping (address => uint) public payments;



    constructor() {

        owner = msg.sender;

    }



    function payForItem() public payable {

        payments[msg.sender] = msg.value;

    }



    function withdrawAll() public {

        address payable _to = payable(owner);

        address _thisContract = address(this);

        _to.transfer(_thisContract.balance);

    }

}