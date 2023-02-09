/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract TIC {
    IERC20 public token;
    address projectOwner;

    constructor(address _token, address _projectOwner) {
        token = IERC20(_token);
        projectOwner = _projectOwner;
    }

    mapping(address => uint256) public tokens;

    function increment() public {
        tokens[msg.sender] += 10 * 10**18;
    }

    function claim(uint256 amount) public {
        require(
            tokens[msg.sender] >= amount,
            "Insufficient funds in your accounts"
        );
        token.transferFrom(projectOwner, msg.sender, amount);
        tokens[msg.sender] -= amount;
    }

    function deposit(uint256 amount) public {
        require(
            amount <= token.balanceOf(msg.sender),
            "Insufficient funds in accounts"
        );
        token.transferFrom(msg.sender, projectOwner, amount);
        tokens[msg.sender] += amount * 2;
    }
}