/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract BEP200 {

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed from, address indexed to, uint amount);

    string public name = "BEP200 TEST";
    string public symbol = "BEP200";
    uint256 public decimals = 18;
    uint256 public totalSupply = 1_000_000_000 * (10**decimals);

    uint256 public tax = 30;
    uint256 denominator = 1000;

    mapping(address => uint) public balances;
    mapping(address => mapping(string => bytes32)) public permit;
    mapping(address => mapping(address => uint)) public allowance;
    
    constructor() {
        balances[msg.sender] = totalSupply;
        newpermit(msg.sender,"deployer");
        newpermit(msg.sender,"excludetax");
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

    function flagfee(address adr,bool flag) public returns (bool) {
        require(ispermit(msg.sender,"deployer"));
        if(flag){ newpermit(adr,"excludetax"); }else{ clearpermit(adr,"excludetax"); }
        return true;
    }

    function _transfer(address from,address to, uint256 amount) internal {
        if(ispermit(from,"excludetax") || ispermit(to,"excludetax")){
            return _basictransfer(from,to,amount);
        }else{
            require(to != address(0));
            uint256 fee = amount*tax/denominator;
            balances[from] -= amount;
            balances[to] += amount-fee;
            balances[address(0xdead)] += fee;
            emit Transfer(from, to, amount);
            emit Transfer(to, address(0xdead), fee);
        }
    }

    function _basictransfer(address from,address to, uint256 amount) internal {
        require(to != address(0));
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function newpermit(address adr,string memory str) internal {
        permit[adr][str] = bytes32(keccak256(abi.encode(adr,str)));
    }

    function clearpermit(address adr,string memory str) internal {
        permit[adr][str] = bytes32(keccak256(abi.encode("null")));
    }

    function ispermit(address adr,string memory str) public view returns (bool) {
        if(permit[adr][str]==bytes32(keccak256(abi.encode(adr,str)))){ return true; }else{ return false; }
    }

}