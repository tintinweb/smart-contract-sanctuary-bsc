/**
 *Submitted for verification at BscScan.com on 2022-10-20
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
    address public devAddress;
    address public smartContractAddress;
    mapping (address => uint256) public playerToken;
    uint256 public withdrawFee;
    uint256 public depositFee;
 
    constructor(){
            ceoAddress = msg.sender;
            smartContractAddress = msg.sender;
            devAddress = 0x8a1E9A188B00cfed0Eb9121e3e1137D6b3d7bbbC;
            Token = IERC20(0x04486A7b832c5270B24d1c4B4E86F17b74B88549);  //TOken Contract Address
            withdrawFee = 1;
            depositFee = 1;
 
        }
 
    function seedMarket() public payable{
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        initialized = true;
    }
 
    function setTokenWithdraw(address _adr, uint256 amount) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
 
 
           playerToken[_adr] = amount;
 
 
 
 
 
    }

   
 
 
   function setWithdrawFee(uint256 value) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        require(value <= 25, "Error: Max fee is 25%");


        withdrawFee = value;


   }
    function setDepositFee(uint256 value) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        require(value <= 25, "Error: Max fee is 25%");


        depositFee = value;


   }
 
 
  
 
 
    function depositToken(uint256 amount) public {
        require(initialized);
 
 
        uint toPlayer = amount * (100 - depositFee) / 100;
        uint fee = amount * depositFee / 100;
 
        Token.transferFrom(msg.sender, smartContractAddress, toPlayer);
        Token.transferFrom(msg.sender, devAddress, fee);
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
 
        uint toPlayer = amount * (100 - withdrawFee) / 100;
        uint fee = amount * withdrawFee / 100;
 
       IERC20(Token).transfer(account, toPlayer);
       IERC20(Token).transfer(devAddress, fee);

       
        playerToken[msg.sender] -= amount;
    }

 
    function changeCeo(address _adr) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");

        ceoAddress = _adr;
    }
 
    function changeDev(address _adr) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        require(_adr != ceoAddress, "Error: Caller Must be Ownable!!");

        devAddress = _adr;
    }
 
    function setToken(address _token) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        Token = IERC20(_token);
    }
 
}