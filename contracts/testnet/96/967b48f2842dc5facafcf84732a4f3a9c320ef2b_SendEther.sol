/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

pragma solidity ^0.8.11;

contract SendEther {

    address payable public owner;

    
    constructor() payable {
        owner = payable(msg.sender);   
    }


    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can do this.");
        _;
    }


    function withdraw() external payable {
     (bool success,)=owner.call{value:address(this).balance}("");
    // if it is not success, throw error
     require(success,"Transfer failed!");
   }


    function sendViaTransfer(address payable _to) public payable {
        // This function is no longer recommended for sending Ether.
        _to.transfer(msg.value);
    }

    function sendViaSend(address payable _to) public payable {
        // Send returns a boolean value indicating success or failure.
        // This function is not recommended for sending Ether.
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function sendViaCall(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent,) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
    function getBalance() public view returns (uint) {
        return msg.sender.balance;
    }
}