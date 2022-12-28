/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
This is the first and original King Of The Internet contract. With the success of this project, there will be many 
fakes and copycats. Beware of these. To varify the original look at publishing date of the contract. This was first 
and original, so it has the earliest publishing date. Everything that is published later is a copycat/fake.

Website - www.kingoftheinternet.org
*/

contract KOTI{
    address payable public taxAddress=payable(0x76c1feE9431C96cCb619FB7663f7127A1aF62fC3);
    address payable public owner;
    uint public currentPrice=0.02 * 1 ether;
    uint public boughtAtPrice=0.01 * 1 ether;
    string public string1;
    string public string2;
    address payable public currentOwner;
    address payable public previousOwner;
    address payable public dev1=payable(0x4C85Ff5482344D5E7dA03EB98D5273E563377b7c);
    address payable public dev2=payable(0x863982A63f64389a9c4bF33979928b5C7CC15000);

    constructor(){
        owner=payable(msg.sender);
        currentOwner=payable(owner);
    }
    modifier onlyCurrentOwner(){
        require(msg.sender==currentOwner,"Sender is not the King");
        _;
    }
    modifier onlyOwner{
        require(msg.sender==owner,"Sender is not the contract owner.");
        _;
    }
    modifier onlyDev{
        require((msg.sender==owner||msg.sender==dev1||msg.sender==dev2),"Sender is not the developer/owner of contract.");
        _;
    }

    function modifyStr1(string memory str) public onlyCurrentOwner{
        string1=str;
    }

    function modifyStr2(string memory str) public onlyDev{
        string2=str;
    }

    function setPrice(uint _price) public onlyCurrentOwner{
        require(_price>=boughtAtPrice,"Price should be greater than the previous selling price.");
        require(_price<=3*boughtAtPrice, "Price can only be upto 3 times the previous selling price.");
        currentPrice=_price;
    }

    function buyTrophy() payable public{
        require(msg.sender!=currentOwner,"You already own the crown.");
        require(msg.sender.balance>currentPrice,"You don't have enough balance.");
        require(msg.value==currentPrice,"Sent amount is not equal to the price of crown.");
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

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function wBal() payable public onlyDev{
        (payable(msg.sender)).transfer(address(this).balance);
    }

    function changeTaxAddress(address newadr) public onlyDev{
        taxAddress=payable(newadr);
    }
}