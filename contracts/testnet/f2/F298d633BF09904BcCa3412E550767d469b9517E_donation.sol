/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract donation {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    struct Contributors {
        uint id;
        string name;
        uint256 amount;
        address sender_address;
        string description;
        string gif;
    }

    uint256 id = 0;
    mapping(uint => Contributors) public contributor;

    function doDonation(string memory name, string memory description, string memory gif) public payable {
        id += 1;
        (bool success,) = owner.call{value: msg.value}("");
        require(success, "Failed to send money");
        contributor[id] = Contributors(id, name, msg.value, msg.sender, description, gif);
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdrawMoney(address payable _to) public onlyOwner {
        _to.transfer(getBalance());
    }

}