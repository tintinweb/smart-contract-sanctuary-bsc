/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface Main {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

interface Risky {
    function _mintOnBuy(address user, uint256 amount) external;
    function _burnOnSell(address user, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}



contract controller {

    Main main;
    Risky risky;
    address owner;
    constructor(address _risky) {
        main = Main(0x6c7fc3Fd4a9f1Cfa2a69B83F92b9DA7EC26240A2);
        risky = Risky(_risky);
        owner = msg.sender;
    }

    uint256 public buyprice = 1e16;
    uint256 public sellprice = 98e14;
    uint256 public priceIncrease = 50;

    function BuyRisk(uint256 amount) public {
        amount = amount * 1e18;
        require(main.transferFrom(msg.sender, address(this), amount));
        require(main.transfer(owner, amount / 100 * 99));
        uint256 a = amount / buyprice;
        uint256 b = priceIncrease * a;
        buyprice += ((buyprice / 100) * b) / 1e18;
        sellprice += ((sellprice / 100) * b) / 1e18;
        risky._mintOnBuy(msg.sender, ((amount * 1e18) / buyprice));
    }

    function checkbal(address _add) public view returns(uint256) {
        return risky.balanceOf(_add);
    }

    function SellPrice() public view returns(uint256) {
        return sellprice;
    }
    function BuyPrice() public view returns(uint256) {
        return buyprice;
    }
    function PriceIncrease() public view returns(uint256) {
        return priceIncrease;
    }
 
    function SellRisk(uint256 amount) public {
        amount = amount * 1e18;
        risky._burnOnSell(msg.sender, amount);
        uint256 b = priceIncrease * amount;
        buyprice -= ((buyprice / 100) * (b /  1e18)) / 1e18;
        sellprice -= ((sellprice / 100) * (b /  1e18)) / 1e18;
        uint256 a = sellprice * amount / 1e18;
        require(main.transfer(msg.sender, a));
    }
}