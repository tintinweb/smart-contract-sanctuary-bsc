/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface Interface {
    event deposit(uint indexed id);
}

contract Piramid is Interface {

    address public comisionsWallet;
    uint internal multiplier = 15;

    uint public coversId1 = 0;
    bool public prev1 = false;
    address public investor1;
    address public nextToCollect1;
    mapping(uint => address) public covers1;
    mapping(address => uint) public getId1;

    uint public coversId2 = 0;
    bool public prev2 = false;
    address public investor2;
    address public nextToCollect2;
    mapping(uint => address) public covers2;
    mapping(address => uint) public getId2;

    uint public coversId3 = 0;
    bool public prev3 = false;
    address public investor3;
    address public nextToCollect3;
    mapping(uint => address) public covers3;
    mapping(address => uint) public getId3;

    mapping(address => uint8) public permisions;

    uint public price1 =   20*10**multiplier;
    uint public reguard1 = 38*10**multiplier;
    uint public comision1 = price1*2-reguard1;

    uint public price2 =   40*10**multiplier;
    uint public reguard2 = 66*10**multiplier;
    uint public comision2 = price2*2-reguard2;

    uint public price3 =   80*10**multiplier;
    uint public reguard3 = 126*10**multiplier;
    uint public comision3 = price3*2-reguard3;

    constructor() payable {
        comisionsWallet = payable(msg.sender);
    }

    function depsit1() public payable returns (uint){
        if(prev1 == false && coversId1 == 0){
            (bool success3,) = comisionsWallet.call{value: price1}("");
            require(success3, "Failed to send Ether to comision");
            coversId1 = 1;
            covers1[1] = msg.sender;
            getId1[msg.sender] = coversId1+1;
            nextToCollect1 = msg.sender;
        }else {
            require(msg.value == price1,"Invalid amount to deposit");

            if(!prev1){
                investor1 = msg.sender;
                prev1 = true;
                getId1[msg.sender] = coversId1+1;
            }else{
                (bool success,) = covers1[coversId1].call{value: reguard1}("");
                require(success, "Failed to send Ether to user");
                (bool success2,) = comisionsWallet.call{value: comision1}("");
                require(success2, "Failed to send Ether to comision");
                nextToCollect1 = investor1;
                investor1 = msg.sender;
                prev1 = false;
                covers1[coversId1+1] = investor1;
                covers1[coversId1+2] = msg.sender;
                coversId1 = coversId1+2;
                getId1[msg.sender] = coversId1+1;
            }
        }
        if(permisions[msg.sender] == 0 ) permisions[msg.sender] = 1;
        uint id = coversId1;
        emit deposit(id);
        return id;
    }

    function depsit2() public payable returns (uint){
        require(permisions[msg.sender] > 0,"You don heve permisions");
        if(prev2 == false && coversId2 == 0){
            (bool success3,) = comisionsWallet.call{value: price2}("");
            require(success3, "Failed to send Ether to comision");
            coversId2 = 1;
            covers2[1] = msg.sender;
            nextToCollect2 = msg.sender;
            getId2[msg.sender] = coversId2+1;
        }else {
            require(msg.value == price2,"Invalid amount to deposit");

            if(!prev2){
                investor2 = msg.sender;
                prev2 = true;
                getId2[msg.sender] = coversId2+1;
            }else{
                (bool success,) = covers2[coversId2].call{value: reguard2}("");
                require(success, "Failed to send Ether to user");
                (bool success2,) = comisionsWallet.call{value: comision2}("");
                require(success2, "Failed to send Ether to comision");
                nextToCollect2 = investor2;
                investor2 = msg.sender;
                prev2 = false;
                covers2[coversId2+1] = investor2;
                covers2[coversId2+2] = msg.sender;
                coversId2 = coversId2+2;
                getId2[msg.sender] = coversId2+1;
            }
        }
        permisions[msg.sender] = permisions[msg.sender] + 1;
        uint id = coversId2;
        emit deposit(id);
        return id;
    }

    function depsit3() public payable returns (uint){
        require(permisions[msg.sender] > 1,"You don heve permisions");
        if(prev3 == false && coversId3 == 0){
            (bool success3,) = comisionsWallet.call{value: price3}("");
            require(success3, "Failed to send Ether to comision");
            coversId3 = 1;
            covers3[1] = msg.sender;
            nextToCollect3 = msg.sender;
            getId3[msg.sender] = coversId3+1;
        }else {
            require(msg.value == price3,"Invalid amount to deposit");

            if(!prev3){
                investor3 = msg.sender;
                prev3 = true;
                getId3[msg.sender] = coversId3+1;
            }else{
                (bool success,) = covers3[coversId3].call{value: reguard3}("");
                require(success, "Failed to send Ether to user");
                (bool success2,) = comisionsWallet.call{value: comision3}("");
                require(success2, "Failed to send Ether to comision");
                nextToCollect3 = investor3;
                investor3 = msg.sender;
                prev3 = false;
                covers3[coversId3+1] = investor3;
                covers3[coversId3+2] = msg.sender;
                coversId3 = coversId3+2;
                getId3[msg.sender] = coversId3+1;
            }
        }
        uint id = coversId3;
        emit deposit(id);
        return id;
    }
}