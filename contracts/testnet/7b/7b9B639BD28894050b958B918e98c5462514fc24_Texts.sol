/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract Texts {

    address payable public owner; 
    mapping(string => string[]) public stories;

    constructor() {
        owner = payable(msg.sender);
    }
    
    function createStory(string memory _title) public payable {
        require(msg.value >= 0.000001 ether, "please transfer a sufficient amount");
        stories[_title].push("");
    }
    function addText(string memory _title, string memory _text) public payable{
        require(msg.value >= 0.000001 ether, "please transfer a sufficient amount");
        stories[_title].push(_text);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawToOwner(uint256 _amount) payable public {
        require(msg.sender == owner, "This funcion can only be used by the owner!");
        require(_amount <= getBalance());
        owner.transfer(_amount);
    }

    /*function complete() public payable {
        require(msg.value >= 0.000001 ether, "please transfer a sufficient amount");
        stories.push(Story("", true));
    }*/

}