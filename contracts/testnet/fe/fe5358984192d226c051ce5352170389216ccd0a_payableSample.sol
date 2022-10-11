/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

pragma solidity ^0.8.15; 

contract payableSample { 
    //to.transfer works because we made the address above payable. 
    function transfer(address payable _to1, address payable _to2, address payable _to3) public payable { 
        _to1.transfer(msg.value/3);
        _to2.transfer(msg.value/3);
        _to3.transfer(msg.value/3);
        //to.transfer works because we made the address above payable.
    }
}