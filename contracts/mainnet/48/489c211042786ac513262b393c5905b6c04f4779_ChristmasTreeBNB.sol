/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: MIT

// Christmas Tree BNB
interface ERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

contract ChristmasTreeBNB {
    struct Tree {
        uint256 money;
        uint256 timestamp;
        uint256 hrs;
    }

    mapping(address => Tree) public trees;

    uint256 public totalInvested;
    address public manager;
    address xmasbnb = 0xf7a51Ca1B6b483690bf00fd2BD9E8B5973BCD03a;

    uint256 immutable public denominator = 10;
    bool public init;

    constructor() {
       manager = msg.sender;
    }

    function initialize() external {
      require(manager == msg.sender);
      require(!init);
      init = true;
    }

    function addPresents(uint256 amount) public {
        ERC20(xmasbnb).transferFrom(address(msg.sender), address(this), amount);
        uint256 money = amount / 2e15; 
        require(money > 0, "Zero Presents");
        address user = msg.sender;
        totalInvested += amount;
        trees[user].money += money;
        trees[manager].money += (money * 5) / 100;
    }

    function withdrawMoney() public {
        address user = msg.sender;
        uint256 money = trees[user].money;
        trees[user].money = 0;
        uint256 amount;
        if (block.timestamp < 1671944400) {

            amount = (money * 2e15) / 2;

        } else {

             amount = money * 2e15;
        }
        payable(user).transfer(address(this).balance < amount ? address(this).balance : amount);
    }
}