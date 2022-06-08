// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SafeERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract LetsFuckToken {
    string public constant name = 'LetsFuckToken';
    string public constant symbol = 'LFT';
    uint256 private totalSupply_ = 100000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).init(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}