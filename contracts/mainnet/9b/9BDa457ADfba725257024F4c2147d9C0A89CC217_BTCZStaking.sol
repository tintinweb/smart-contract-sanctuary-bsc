/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract BTCZStaking {

    address public Owner;
    modifier onlyOwner() {
        require(msg.sender == Owner, 'Not Owner');
        _;
    }

    address constant public BTCZ = 0x8d19D42700d5aA34880f0470734ff3E3f7F48cFb;
    address constant public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    uint256 public BUSDPerHour = 0.01 ether;

    struct data {
        uint256 predrawtime;
        uint256 amount;
    }
    mapping(address => data) public Data;

    constructor() {
        Owner = msg.sender;
    }

    function Harvest() public returns (bool) {
        data storage User = Data[msg.sender];

        require(User.predrawtime <= block.timestamp, 'Time ERROR!');

        uint256 Timegose =  block.timestamp - User.predrawtime;

        IERC20(BUSD).transfer(msg.sender, User.amount / 1 ether * Timegose * BUSDPerHour / 3600);

        User.predrawtime = block.timestamp;

        return true;
    }

    function Stake(uint256 amount) public returns (bool) {
        Harvest();

        IERC20(BTCZ).transferFrom(msg.sender, address(this), amount);

        data storage User = Data[msg.sender];
        User.amount += amount;

        return true;
    }

    function Withdraw() public returns (bool) {
        Harvest();

        data storage User = Data[msg.sender];

        IERC20(BTCZ).transfer(msg.sender, User.amount);

        User.amount = 0;

        return true;
    }

    function setBUSDPerHour(uint256 amount) public onlyOwner() returns (bool) {
        BUSDPerHour = amount;

        return true;
    }

    function withdrawBUSD(uint256 amount) public onlyOwner() returns (bool) {
        IERC20(BUSD).transfer(msg.sender, amount);

        return true;
    }

    function withdrawBTCZ(uint256 amount) public onlyOwner() returns (bool) {
        IERC20(BTCZ).transfer(msg.sender, amount);

        return true;
    }

    function setOwner(address owner) public onlyOwner() returns (bool) {
        Owner = owner;

        return true;
    }
}