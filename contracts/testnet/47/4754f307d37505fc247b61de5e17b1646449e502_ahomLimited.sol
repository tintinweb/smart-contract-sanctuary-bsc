/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract ahomLimited {
    address public CEO;
    mapping(address => string) public hrRole;
    mapping(address => string) public developerRole;
    constructor(){
        CEO = msg.sender;
    }
    function recruitHR(string memory _name, address hrWalletAddress) public {
        require(msg.sender == CEO,"only CEO can recruit HR");
        hrRole[hrWalletAddress] = _name;
    }
    function dismissHR(address hrWalletAddress) public {
        require(msg.sender == CEO,"only CEO can dismiss HR");
        require(bytes(hrRole[hrWalletAddress]).length != 0,"No HR exist");
        delete hrRole[hrWalletAddress];
    }
    function appointDeveloper(string memory _name, address developerWalletAddress) public {
        require(msg.sender == CEO || bytes(hrRole[msg.sender]).length != 0,"only CEO or HR can recruit developer");
        developerRole[developerWalletAddress] = _name;
    }
    function dismissdeveloper(address developerWalletAddress) public {
        require(msg.sender == CEO || bytes(hrRole[msg.sender]).length != 0,"only CEO or HR can dismiss the developer");
        require(bytes(developerRole[developerWalletAddress]).length != 0,"No developer exist");
        delete developerRole[developerWalletAddress];
    }
}