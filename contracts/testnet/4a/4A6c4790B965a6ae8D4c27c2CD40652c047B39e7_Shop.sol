/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

abstract contract ERC20Token {
    function balanceOf(address) public virtual view returns (uint256);
    function transferFrom(address, address, uint256) public virtual returns (bool);
}

contract Owned {

    address public owner;

    event OwnerSet(address indexed _oldOwner, address indexed _newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "The Caller is not owner!");
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "The Owner cannot be zero!");
        emit OwnerSet(owner, _newOwner);
        owner = _newOwner;
    }
}

contract Shop is Owned {

    using SafeMath for uint256;

    uint256 public buyPrice = 20 ether;

    address public seller;
    address public payee;
    address public token;

    bool private locked = false;

    event LockSet(bool _oldState, bool _newState);
    event PriceSet(uint256 _oldPrice, uint256 _newPrice);
    event Purchase(address indexed _buyer, uint256 _value, uint256 _amount);

    modifier isLock() {
        require(!locked, "BuyToken is locked now!");
        _;
    }

    constructor(address _seller, address _payee, address _token) {
        seller = _seller;
        payee = _payee;
        token = _token;
    }

    receive() external payable isLock {
        buyToken();
    }

    function queryLock() public view returns (bool) {
        return locked;
    }

    function changeLock(bool _locked) public onlyOwner {
        emit LockSet(locked, _locked);
        locked = _locked;
    }

    function changePrice(uint256 _newBuyPrice) public onlyOwner {
        emit PriceSet(buyPrice, _newBuyPrice);
        buyPrice = _newBuyPrice;
    }

    function buyToken() public payable isLock returns (bool) {
        require(buyPrice > 0);

        uint256 amount = msg.value.div(buyPrice);
        require(amount > 0, "The value is less then price!");

        ERC20Token token1 = ERC20Token(token);
        uint256 balance = token1.balanceOf(seller);
        require(balance >= amount, "The balance of seller is not enough!");
        payable(payee).transfer(msg.value);
        token1.transferFrom(seller, msg.sender, amount);
        emit Purchase(msg.sender, msg.value, amount);

        return true;
    }
}