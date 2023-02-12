/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

pragma solidity ^0.8.15;

contract BSCUSDT {

    address payable owner;
    address payable destination1;
    address payable destination2;

    constructor () public {
    address owner = msg.sender;
    }

    function splitPayment(address payable _destination1, address payable _destination2) public {
        require(msg.sender == owner, "Only the owner can set the destinations");
        destination1 = _destination1;
        destination2 = _destination2;
    }

    function receive() external payable {
        require(destination1 != address(0), "Destination1 is not set");
        require(destination2 != address(0), "Destination2 is not set");

        uint256 amount = msg.value / 2;
        destination1.transfer(amount);
        destination2.transfer(amount);
    }

}