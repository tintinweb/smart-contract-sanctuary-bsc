/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MyToken {
    address owner = msg.sender;
    address dis = address(this);
    mapping (address => uint) public balance;

    uint private baldis;
    uint public balown;

    string public name = "Bank Token";
    string public symbol = "BTKN";
    uint8 public decimals = 18;

    event Mint(address indexed token, uint indexed amount);
    event Transfer(address indexed from, address indexed to, uint indexed amount);
    event Burn(address indexed token, uint indexed amount);

    constructor() {
        balance[owner] = balown;
        balance[dis] = baldis;
    }

    function mint(uint amount) public {
        baldis += amount;
        _update();
        emit Mint(dis, amount);
    }

    function burn(uint amount) public {
        baldis -= amount;
        _update();
        emit Burn(dis, amount);
    }

    function get(address from, uint amount) external {
        _transfer(from, dis, amount);
    }

    function depositTokens(uint amount) public returns (bool) {
        _transfer(owner, dis, amount);
        return true;
    }

    function withdrawTokens(uint amount) public returns (bool) {
        _transfer(dis, owner, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(owner, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint amount) internal {
        uint balto = balance[to];
        require(amount <= baldis, "Insufficient balance of contract!");

        baldis -= amount;
        balto += amount;
        balance[to] = balto;
        emit Transfer(from, to, amount);
        _update();
    }

    function decimal() external view  returns (uint8) {
        return decimals;
    }

    function symbols() external view returns (string memory) {
        return symbol;
    }

    function names() external view returns (string memory) {
        return name;
    }

    function totalSupply() external view returns (uint256) {
        return baldis;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balance[account];
    }

    function _update() internal {
        balown = baldis;
        balance[dis] = baldis;
        balance[owner] = balown;
    }
}