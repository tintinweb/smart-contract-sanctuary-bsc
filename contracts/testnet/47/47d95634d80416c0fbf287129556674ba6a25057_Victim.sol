/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

//SPDX-License-Identifier: GPL-3.0 
pragma solidity ^0.6.12;
contract Victim{
    address public bidder;
    uint public currentbid;
    mapping(address=>uint)public balances;
    
    function bid()public payable{
        require(msg.value>currentbid,"you must pay currentbid in Auction");
        (bool sent,)=bidder.call{value:currentbid,gas:20000}("");
         require(sent,"Faied sent to ether");
         bidder=msg.sender;
         currentbid=msg.value;
     }
     function withdraw()public{
         require(msg.sender !=bidder,"Current king cannot withdrw");
         uint amount= balances[msg.sender];
         balances[msg.sender]=0;
    (bool sent,)=msg.sender.call{value:amount}("");
         require(sent,"Failed to send Ether");
     }
}