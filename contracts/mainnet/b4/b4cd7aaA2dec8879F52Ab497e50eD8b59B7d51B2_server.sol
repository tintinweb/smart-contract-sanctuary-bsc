/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

pragma solidity ^0.8.0;


contract server {
    
    address public owner;

    string public url;

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address to) public {
        require(msg.sender == owner);
        owner = to;
    }

    function setServerUrl(string memory uri) public {
        require(msg.sender == owner);
        url = uri;
    }


}