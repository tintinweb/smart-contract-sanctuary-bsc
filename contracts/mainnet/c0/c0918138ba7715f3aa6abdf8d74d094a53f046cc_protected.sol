/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract protected {

    mapping (address => bool) is_auth;

    function authorized(address addy) public view returns(bool) {
        return is_auth[addy];
    }

    function set_authorized(address addy, bool booly) public onlyAuth {
        is_auth[addy] = booly;
    }

    modifier onlyAuth() {
        require( is_auth[msg.sender] || msg.sender==owner, "not auth");
        _;
    }

    address owner;
    modifier onlyOwner() {
        require(msg.sender==owner, "not owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      owner = newOwner;
    }

    bool locked;
    modifier safe() {
        require(!locked, "reentrant");
        locked = true;
        _;
        locked = false;
    }

    
    uint cooldown = 5 seconds;

    mapping(address => uint) cooldown_block;
    mapping(address => bool) cooldown_free;

    modifier cooled() {
        if(!cooldown_free[msg.sender]) { 
            require(cooldown_block[msg.sender] < block.timestamp);
            _;
            cooldown_block[msg.sender] = block.timestamp + cooldown;
        }
    }

    receive() external payable {}
    fallback() external payable {}
}