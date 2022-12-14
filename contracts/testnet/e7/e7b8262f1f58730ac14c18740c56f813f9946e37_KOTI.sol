/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KOTI{
    address payable public taxAddress=payable(0x9673fdDA9E7dd92eC998841224a7999D278d5006);
    address payable public owner;
    uint public currentPrice=0.0002 * 1 ether;
    uint public boughtAtPrice=0.0001 * 1 ether;
    address payable public currentOwner;
    address payable public previousOwner;

    constructor(){
        owner=payable(msg.sender);
        currentOwner=payable(owner);
    }
    modifier onlyCurrentOwner(){
        require(msg.sender==currentOwner,"Sender is not the owner of trophy");
        _;
    }
    modifier onlyOwner{
        require(msg.sender==owner,"Sender is not the contract owner.");
        _;
    }

    function setPrice(uint _price) public onlyCurrentOwner{
        require(_price>=boughtAtPrice,"Price should be greater than the previous selling price.");
        require(_price<=3*boughtAtPrice, "Price can only be upto 3 times the previous selling price.");
        currentPrice=_price;
    }

    function buyTrophy() payable public{
        require(msg.sender!=currentOwner,"You already own the trophy.");
        require(msg.sender.balance>currentPrice,"You don't have enough ether.");
        require(msg.value==currentPrice,"Sent amount is not equal to the price of trophy.");
        (bool sent, bytes memory data)=currentOwner.call{value:msg.value-msg.value/10}("");
        require(sent);
        (bool sent2, bytes memory data2)=taxAddress.call{value:msg.value/10}("");
        require(sent2);
        data="aa";
        data2="bb";
        previousOwner=payable(currentOwner);
        currentOwner=payable(msg.sender);
        boughtAtPrice=msg.value;
        currentPrice=2*boughtAtPrice;
    }
}