// SPDX-License-Identifier: Unlicensed


pragma solidity ^0.8.4;

contract Lottery{
    
    struct product {
        uint256 price;
        bool sold;
    }

    address btestnet = address(0);

    mapping(uint256 => product)   public Products;

    constructor(){
        Products[1].price = 1000;
        Products[1].sold = false;

    }
    
    function buy(uint256 id_item) payable public{
        require(Products[id_item].price <= msg.value, "Doesnt have money");
        Products[id_item].sold = true;
    }
    
    
}