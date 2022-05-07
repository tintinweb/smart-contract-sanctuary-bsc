/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

/**
 *Token-less Fundraiser contract for Skeptic Token (SKP)
 *A DeFi Skeptic product
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract FirstSkeptics is Ownable{
    uint256 public amountCollected = 0 ether;
    
    uint256 public hardCap = 250 ether;

    uint256 public maxTransaction = 1 ether;
    uint256 public minTransaction = 0.5 ether;

    mapping(address => uint256) sentAmounts;

    function depositBNB() public payable{
        require(amountCollected + msg.value <= hardCap, "Max BNB reached!");
        require(msg.value >= minTransaction, "Transaction too small");
        require(msg.value <= maxTransaction, "Transaction too big");
        amountCollected += msg.value;
        sentAmounts[msg.sender] += msg.value;
        
    }
    function addAmountCollected(uint256 amount) public onlyOwner {
        amountCollected += amount * 10 ** 18;
    }
    function subtractAmountCollected(uint256 amount) public onlyOwner {
        amountCollected -= amount * 10 ** 18;
    }
    function setAmountCollected(uint256 amount) public onlyOwner {
        amountCollected = amount * 10 ** 18;
    }
    function setHardCap(uint256 amount) public onlyOwner {
        hardCap = amount * 10 ** 18;
    }
    function setMinTX(uint256 amount) public onlyOwner {
        minTransaction = amount * 10 ** 18;
    }
    function setMaxTX(uint256 amount) public onlyOwner {
        maxTransaction = amount * 10 ** 18;
    }

    function transferBNBToOwner() public onlyOwner  {
        require(address(this).balance > 0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
        hardCap = 0 ether;
    }

    function howMuchSent(address user) public view returns(uint256) {
        return sentAmounts[user];
    }

    receive() external payable {}

}