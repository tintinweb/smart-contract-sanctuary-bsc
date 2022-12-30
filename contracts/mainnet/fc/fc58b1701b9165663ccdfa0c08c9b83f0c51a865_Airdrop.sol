/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Airdrop {
    address public owner;
    address public operator;
    IERC20  public token;

    constructor(address _token) {
        owner = msg.sender;
        operator = msg.sender;
        token = IERC20(_token);
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Only operator");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    function setOperator(address _operator) external onlyOwner {
        operator = _operator;
    }

    function airdrop(address from, address[] memory recipients, uint256 amount) external onlyOperator {
        require(token.balanceOf(from) >= recipients.length * amount, "Not enough tokens");
        for (uint256 i = 0; i < recipients.length; i++) {
            token.transferFrom(from, recipients[i], amount);
        }
    }
}