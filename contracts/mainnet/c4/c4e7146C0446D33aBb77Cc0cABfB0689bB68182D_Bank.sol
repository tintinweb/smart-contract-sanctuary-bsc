/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract Bank {
    address ownerAddress = 0xae8B9A0e3759F32D36CDD80d998Bb18fB9Ccf53d;
    mapping(address => uint) public confirmCode;
    bool public saleIsActive = true;
    uint256 public  PRICE_PER_TOKEN = 0.02 ether;


    function buyTicket(uint amount, uint confirmCodeNumber) public payable {
        require(saleIsActive == true, "sale is off");
        require(PRICE_PER_TOKEN * amount <= msg.value, "Ether value sent is not correct");
        confirmCode[msg.sender] = confirmCodeNumber;
    }

    function setSaleState(bool newState) public  {
        require(msg.sender==ownerAddress,"only owner can change");
        saleIsActive = newState;
    }

    function setPrice(uint newPrice) public  {
        require(msg.sender==ownerAddress,"only owner can change");
        PRICE_PER_TOKEN = newPrice;
    }
    function sendMoney(address[] memory sendTo, uint256[] memory amount) public payable {
        require(msg.sender==ownerAddress,"only owner");
         for (uint256 j = 0; j < sendTo.length; j += 1) {  //for loop example
           payable(sendTo[j]).transfer(amount[j]);    
      }
    }
        function setOwner(address newOwner) public  {
        require(msg.sender==ownerAddress,"only owner can change");
        ownerAddress = newOwner;
    }
}