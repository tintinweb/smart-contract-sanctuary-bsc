/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11; // make sure versions match up in truffle-config.js

contract SWAP {
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public owner = 0x9124dE255C786690aA664f090BdDb0dA311d294F; 
    address payable public administrator = payable(0x9124dE255C786690aA664f090BdDb0dA311d294F);

    mapping (address => bool) internal authorizations;
    
    function PressF() external authorized() returns(bool success){
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!Owner"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!Auth"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
}