/**
 *Submitted for verification at BscScan.com on 2023-01-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract permission {
    mapping(address => mapping(string => bytes32)) private permit;

    function newpermit(address adr,string memory str) internal { permit[adr][str] = bytes32(keccak256(abi.encode(adr,str))); }

    function clearpermit(address adr,string memory str) internal { permit[adr][str] = bytes32(keccak256(abi.encode("null"))); }

    function checkpermit(address adr,string memory str) public view returns (bool) {
        if(permit[adr][str]==bytes32(keccak256(abi.encode(adr,str)))){ return true; }else{ return false; }
    }
}

contract ERC20N is permission {

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed from, address indexed to, uint amount);

    string public name = "GCR COIN";
    string public symbol = "GCR";
    uint256 public decimals = 8;
    uint256 public totalSupply = 15_600_000_000 * (10**decimals);

    address public owner;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    constructor() {
        balances[msg.sender] = totalSupply;
        newpermit(msg.sender,"owner");
        owner = msg.sender;
    }
    
    function balanceOf(address adr) public view returns(uint) { return balances[adr]; }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender,to,amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns(bool) {
        allowance[from][msg.sender] -= amount;
        _transfer(from,to,amount);
        return true;
    }
    
    function approve(address to, uint256 amount) public returns (bool) {
        require(to != address(0));
        allowance[msg.sender][to] = amount;
        emit Approval(msg.sender, to, amount);
        return true;
    }

    function _transfer(address from,address to, uint256 amount) internal {
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function transferOwnership(address adr) public returns (bool) {
        require(checkpermit(msg.sender,"owner"));
        newpermit(adr,"owner");
        clearpermit(msg.sender,"owner");
        owner = adr;
        return true;
    }
}