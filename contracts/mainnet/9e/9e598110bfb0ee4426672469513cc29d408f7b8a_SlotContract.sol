/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SlotContract{

    bool public initialized = false;
    IERC20 public Token;
    address public ceoAddress;
    address public devAddress;
    mapping (address => uint256) public playerWallet;
 
    constructor(){
            ceoAddress = msg.sender;
            devAddress = 0x55A3ADde4E3FFFe38447AEb583E2DE6ea7694f22;
            Token = IERC20(0xF03E02AcbC5eb22de027eA4F59235966F5810D4f);  //TOken Contract Address

        }
 
    function seedMarket() public payable{
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        initialized = true;
    }


    function changeAmount(uint256 amount) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");

         if(amount >= 0){

           playerWallet[msg.sender] = amount;
         }

        if(amount < 0){

           
            playerWallet[msg.sender] = 0;

         }
    }

    
    function deposit(uint256 amount) public {
        require(initialized);
        Token.transferFrom(msg.sender, devAddress,amount);
        uint NinetyNinePercent = amount * 99 / 100;
        uint OnePercent = amount * 1 /100;
        playerWallet[msg.sender] += NinetyNinePercent;
        Token.transfer(devAddress,OnePercent);
    }
 
    function withdrawMyCustomToken(uint256 amount) public {
        require(initialized);
        require(playerWallet[msg.sender] <= amount,"Cannot Withdraw more then your Balance!!");

        uint NinetyNinePercent = amount * 99 / 100;
        uint OnePercent = amount * 1 /100;

        Token.transfer(msg.sender,NinetyNinePercent);
        Token.transfer(devAddress,OnePercent);
        playerWallet[msg.sender] -= amount;
    }

    function changeCeo(address _adr) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        ceoAddress = _adr;
    }

    function changeDev(address _adr) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        devAddress = _adr;
    }

    function setToken(address _token) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        Token = IERC20(_token);
    }
 
}