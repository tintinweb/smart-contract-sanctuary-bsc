/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

pragma solidity ^0.5.16;


contract TestX {
    uint number = 5;
}


contract Test is TestX {

    address admin;

    constructor() public {
        admin = msg.sender;

    }

    
}