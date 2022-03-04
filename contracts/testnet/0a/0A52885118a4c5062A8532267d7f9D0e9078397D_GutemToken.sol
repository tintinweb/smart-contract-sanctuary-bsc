// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

contract Books {
    function safe_Transfer(address from, address to, uint256 amount) public returns (uint256, uint256);
    function safe_balanceOf(address who) public view returns (uint256);
    function safe_setup(address token, uint256 supply) public returns (bool);
}

contract GutemToken {
    
    string public constant name = "Try";
    string public constant symbol = "Try";
    uint8 public constant decimals = 18;
    address private Books_address;
    address private deployer;
    uint256 totalSupply_;
    mapping(address => mapping (address => uint256)) allowed;

    constructor(address _book) public {
        totalSupply_ = 1000*10**18;
        deployer = msg.sender;
        Books_address = _book;
        Books(Books_address).safe_setup(address(this), totalSupply_);
    }

        function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return Books(Books_address).safe_balanceOf(tokenOwner);
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        (uint256 am, uint256 burn) = Books(Books_address).safe_Transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, am);
        if (burn>0)
        {
            emit Transfer(msg.sender, address(0), burn);
        }
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender]>=amount, "Not allowed");
        (uint256 am, uint256 burn) = Books(Books_address).safe_Transfer(from, to, amount);
        emit Transfer(from, to, am);
        if (burn>0)
        {
            emit Transfer(from, address(0), burn);
        }
        return true;
    }
}