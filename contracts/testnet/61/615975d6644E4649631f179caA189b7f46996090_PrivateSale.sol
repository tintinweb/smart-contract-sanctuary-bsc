/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import "hardhat/console.sol";

/*
 * @title Contract to handle private sale. Receive BNB, record amount. The contract is not aware of the token price and distribution schedule.
 */
contract PrivateSale {
    uint MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    address payable public owner;

    bool public whitelistEnabled;
    mapping(address => uint) public whitelist; //0: not wl, 1: wl

    bool public maxCapEnabled;
    uint public maxCap;
    uint public minSaleAmount;
    uint public maxSaleAmount; //per wallet

    mapping(address => uint) public saleRecords;
    address[] buyers;
    uint public saleCount;

    constructor() {
        owner = payable(msg.sender);
        whitelistEnabled = false;
        maxCapEnabled = false;
        maxCap = 1000 * 1e18;
        minSaleAmount = 1 * 1e17; //0.1 BNB
        maxSaleAmount = MAX_INT;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner!");
        _;
    }

    event toggledWhitelist(address _by, bool _newStatus);

    function toggleWhitelist() public onlyOwner {
        whitelistEnabled = !whitelistEnabled;
        emit toggledWhitelist(msg.sender, whitelistEnabled);
    }

    event toggledMaxCap(address _by, bool _newStatus);

    function toggleMaxCap() public onlyOwner {
        maxCapEnabled = !maxCapEnabled;
        emit toggledMaxCap(msg.sender, maxCapEnabled);
    }

    event maxCapSet(address _by, uint _amount);

    function setMaxCap(uint amount) public onlyOwner {
        maxCap = amount;
        emit maxCapSet(msg.sender, amount);
    }

    event minSaleAmountSet(address _by, uint _amount);

    function setMinSaleAmount(uint amount) public onlyOwner {
        minSaleAmount = amount;
        emit minSaleAmountSet(msg.sender, amount);
    }

    event maxSaleAmountSet(address _by, uint _amount);

    function setMaxSaleAmount(uint amount) public onlyOwner {
        maxSaleAmount = amount;
        emit maxSaleAmountSet(msg.sender, amount);
    }

    event addedToWhitelist(address _by, address _address);

    function addToWhitelist(address _address) public onlyOwner {
        whitelist[_address] = 1;
        emit addedToWhitelist(msg.sender, _address);
    }

    event removedFromWhitelist(address _by, address _address);

    function removeFromWhitelist(address _address) public onlyOwner {
        whitelist[_address] = 0;
        emit removedFromWhitelist(msg.sender, _address);
    }

    event purchased(address _by, uint _amount);

    function purchase() public payable {
        uint amountBNB = msg.value;
        require(
            amountBNB >= minSaleAmount && amountBNB <= maxSaleAmount && (saleRecords[msg.sender] + amountBNB) <= maxSaleAmount,
            "Amount is either too small or too high!"
        );
        if (whitelistEnabled) {
            require(
                whitelist[msg.sender] == 1,
                "You are not in the whitelist!"
            );
        }
        if(maxCapEnabled){
            require(address(this).balance <= maxCap, "Exceed max cap!");
        }
        saleRecords[msg.sender] += amountBNB;
        if (saleRecords[msg.sender] == amountBNB) {
            buyers.push(msg.sender); //if new buyer, register the address into buyers list
        }
        saleCount++;
        emit purchased(msg.sender, amountBNB);
    }

    event withdrew(address _by, uint _amount);

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        owner.transfer(balance);
        emit withdrew(msg.sender, balance);
    }

    function getAllBuyers() public view returns (address[] memory) {
        return buyers;
    }

    function getBuyer(uint index) public view returns (address) {
        return buyers[index];
    }

    function countBuyers() public view returns (uint) {
        return buyers.length;
    }
}