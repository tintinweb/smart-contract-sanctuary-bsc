// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TestERC20 {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        mint(msg.sender, 100000000000 ether);
    }

    function decimals() external pure returns (uint256) {
        return 18;
    }

    function mint(address to, uint256 amount) public {
        uint256 balanceNext = balanceOf[to] + amount;
        require(balanceNext >= amount, 'overflow balance');
        balanceOf[to] = balanceNext;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        uint256 balanceBefore = balanceOf[msg.sender];
        require(balanceBefore >= amount, 'insufficient balance');
        balanceOf[msg.sender] = balanceBefore - amount;

        uint256 balanceRecipient = balanceOf[recipient];
        require(balanceRecipient + amount >= balanceRecipient, 'recipient balance overflow');
        if (!isDeflationary) {
            balanceOf[recipient] = balanceRecipient + amount;
        } else {
            balanceOf[recipient] = balanceRecipient + (amount - (amount * 5) / 100);
        }

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    bool isDeflationary = false;

    function setDefl() external {
        isDeflationary = true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        uint256 allowanceBefore = allowance[sender][msg.sender];
        require(allowanceBefore >= amount, 'allowance insufficient');

        allowance[sender][msg.sender] = allowanceBefore - amount;

        uint256 balanceRecipient = balanceOf[recipient];
        require(balanceRecipient + amount >= balanceRecipient, 'overflow balance recipient');
        if (!isDeflationary) {
            balanceOf[recipient] = balanceRecipient + amount;
        } else {
            balanceOf[recipient] = balanceRecipient + (amount - (amount * 5) / 100);
        }
        uint256 balanceSender = balanceOf[sender];
        require(balanceSender >= amount, 'underflow balance sender');
        balanceOf[sender] = balanceSender - amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }
}