/**
 *Submitted for verification at BscScan.com on 2022-09-23
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
 
contract P2EGameContract{
 
    bool public initialized = false;
    IERC20 public Token;
 
    address public ceoAddress;
    address public smartContractAddress;
    mapping (address => uint256) public playerToken;
  
 
    constructor(){
            ceoAddress = msg.sender;
            smartContractAddress = msg.sender;
            Token = IERC20(0x1EB5f09F90e0435198871cF3d428Eb01dba0a375);  //TOken Contract Address
            
 
        }
 
    function seedMarket() public payable{
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        initialized = true;
    }
 
    function setTokenWithdraw(address _adr, uint256 amount) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
 
 
           playerToken[_adr] = amount;
 
 
 
 
 
    }

    

 
    function emergencyWithdrawBNB() public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        (bool os, ) = payable(msg.sender).call{value: address(this).balance}('');
        require(os);
    }

    function changeSmartContract(address smartContract) public{
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        smartContractAddress = smartContract;

    
    }
    function emergencyWithdrawToken(address _adr) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        uint256 bal = IERC20(_adr). balanceOf(address(this));
        IERC20(_adr).transfer(msg.sender, bal);
    }
    function withdrawToken(uint256 amount) public   {
        require(initialized);
        require(playerToken[msg.sender] >= amount,"Cannot Withdraw more then your Balance!!"); 


        address account = msg.sender;
 
        uint toPlayer = amount;
 
        IERC20(Token).transfer(account, toPlayer);

       
        playerToken[msg.sender] = 0;
    }

 
    function changeCeo(address _adr) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");

        ceoAddress = _adr;
    }
 
    

    function setToken(address _token) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        Token = IERC20(_token);
    }
 
}