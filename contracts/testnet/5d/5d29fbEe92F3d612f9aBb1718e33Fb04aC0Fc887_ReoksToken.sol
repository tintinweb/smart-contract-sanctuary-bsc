/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ReoksToken {
    string public name = "REOKS TOKEN";
    string public symbol = "REO";
    uint256 public totalSupply = 1000000000000000000;
    uint256 public decimals = 18;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    constructor() {
        uint256 publicSale = totalSupply * 15 / 100;
        uint256 privateSale = totalSupply * 5 / 100;
        uint256 marketing = totalSupply * 10 / 100;
        uint256 team = totalSupply * 17 / 100;
        uint256 airdrop = totalSupply * 3 / 100;
        uint256 rewards = totalSupply * 20 / 100;
        uint256 liquidityPool = totalSupply * 20 / 100;
        uint256 staking = totalSupply * 15 / 100;

        balances[msg.sender] = publicSale + privateSale + marketing + team + airdrop + rewards + liquidityPool + staking;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
    }

    function transferFrom(address _from, address _to, uint256 _value) public {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value, "Insufficient balance or allowance");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
    }

    function approve(address _spender, uint256 _value) public {
        allowed[msg.sender][_spender] = _value;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
}