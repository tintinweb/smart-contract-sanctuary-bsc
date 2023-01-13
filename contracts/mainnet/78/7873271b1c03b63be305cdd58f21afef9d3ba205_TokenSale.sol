/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier:  MIT

pragma solidity ^0.6.0;

contract TokenSale {
    // Declare variables for token name, symbol, and total supply
    string public name;
    string public symbol;
    uint256 public totalSupply;

    // Declare mapping to store the balance of each address
    mapping(address => uint256) public balanceOf;

    // Declare event for token purchase
    event TokenPurchase(address indexed _buyer, uint256 _amount);

    // Declare variables for start and end date
    uint256 startDate;
    uint256 endDate;

    // Declare mapping to store commission percentage for each affiliate
    mapping(address => uint256) public commissionPercentage;

    // Declare variable to store token price
    uint256 public tokenPrice;

    // Declare address of the owner
    address payable public owner;

constructor() public {
    owner = msg.sender;
}

function sellTokens(uint256 _value, address _wallet) public payable {
    require(isSaleActive());
    require(_value > 0);

    // Check if the user has enough ether to buy tokens
    uint256 cost = _value * tokenPrice;
    require(msg.value >= cost);

    // Update the balance of the seller
    balanceOf[_wallet] += _value;

    // Transfer ether to the contract owner
    owner.transfer(msg.value);

    // Handle affiliate commission
    address affiliate = msg.sender;
    if (commissionPercentage[affiliate] > 0) {
        handleAffiliateCommission(affiliate, _value);
    }

    // Trigger the "TokenPurchase" event
    emit TokenPurchase(_wallet, _value);
}


    // Declare modifier to check if the user is the owner
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // Declare function to set start and end date
    function setSalePeriod(uint256 _startDate, uint256 _endDate) public onlyOwner {
        startDate = _startDate;
        endDate = _endDate;
    }

    // Declare function to check if the sale period is active
    function isSaleActive() public view returns (bool) {
        return now >= startDate && now <= endDate;
    }

    // Declare function to add or update an affiliate's commission percentage
    function setAffiliateCommission(address _affiliate, uint256 _percentage) public onlyOwner {
        require(_percentage <= 100);
        commissionPercentage[_affiliate] = _percentage;
    }

    // Declare function to check the balance of an address
    function checkBalance(address _owner) public view returns (uint256) {
        return balanceOf[_owner];
    }

    function setTokenPrice(uint256 _tokenPrice) public onlyOwner {
        tokenPrice = _tokenPrice;
    }

    // Declare function to transfer tokens
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value && _value > 0);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
    }
    // Declare function to handle affiliate commission
    function handleAffiliateCommission(address _affiliate, uint256 _value) public {
        uint256 commissionAmount = _value * commissionPercentage[_affiliate] / 100;

    // Transfer commission to affiliate
    balanceOf[_affiliate] += commissionAmount;

    // Trigger the "CommissionEarned" event
    emit CommissionEarned(_affiliate, commissionAmount);
    }

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event CommissionEarned(address indexed affiliate, uint256 commissionAmount);
    }