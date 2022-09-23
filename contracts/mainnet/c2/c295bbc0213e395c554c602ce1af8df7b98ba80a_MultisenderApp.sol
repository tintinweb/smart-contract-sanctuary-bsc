/**
 *Submitted for verification at BscScan.com on 2022-09-23
*/

// contracts/BEP20.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract MultisenderApp {
    uint public tax;
    address public owner;
    address public tax_address;

    constructor(uint _tax, address _tax_address) {
        tax = _tax;
        owner = msg.sender;
        tax_address = _tax_address;
    }

    function changeTax(uint _tax) public {
        require(msg.sender == owner);
        tax = _tax;
    }

    function changeTaxAddress(address _tax_address) public {
        require(msg.sender == owner);
        tax_address = _tax_address;
    }

    function multisendEther(address[] calldata _contributors) external payable {
        uint256 total = msg.value;
        uint256 tax_amount = total * tax / 100;
        uint256 i = 0;

        uint256 averageAmount = (total - tax_amount) / _contributors.length;

        (bool tax_success, ) = tax_address.call{value: tax_amount}("");
        require(tax_success, "Error While Taxing");

        for (i; i < _contributors.length; i++) {
            (bool success, ) = _contributors[i].call{value: averageAmount}("");
            require(success, "Transfer failed.");
        }
    }    
}