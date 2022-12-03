/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract vendor {
    using SafeMath for uint256;
    uint256 owner_percentage = 15;
    uint256 seller_percentage = 85;
    address payable owner;

    constructor() {
        owner == payable(msg.sender);
    }

    function buy(
        uint256 price,
        address payable seller
    ) public payable returns (bool) {
        require(msg.value == price, "value should be equal to price");
        uint256 sellerAmt = price.mul(seller_percentage).div(100);
        uint256 onwerAmt = price.mul(owner_percentage).div(100);
        seller.transfer(sellerAmt);
        owner.transfer(onwerAmt);
        return true;
    }

    function change_percentage(
        uint256 _ownerpercentage,
        uint256 _sellerpercentage
    ) public returns (bool) {
        require(msg.sender == owner, "owner can call");
        owner_percentage = _ownerpercentage;
        seller_percentage = _sellerpercentage;
        return true;
    }
}