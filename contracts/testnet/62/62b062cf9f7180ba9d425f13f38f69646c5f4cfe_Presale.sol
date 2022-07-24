/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IERC20{
//Functions
function totalSupply() external  view returns (uint256);
function balanceOf(address tokenOwner) external view returns (uint);
function allowance(address tokenOwner, address spender)external view returns (uint);
function transfer(address to, uint tokens) external returns (bool);
function approve(address spender, uint tokens)  external returns (bool);
function transferFrom(address from, address to, uint tokens) external returns (bool);
//Events
event Approval(address indexed tokenOwner, address indexed spender,uint tokens);
event Transfer(address indexed from, address indexed to,uint tokens);
}


contract Presale  {
   
    //State Variables 
     IERC20 token;
     uint public tokenQuantity;
     address presaleOwner;
     address tokenOwner;

     //Constructor
       
    constructor(address tokenAddress , address OwnerAddress, uint tokensInOneEther) payable{

        token = IERC20(address(tokenAddress));
        tokenQuantity=tokensInOneEther;
        presaleOwner=msg.sender;
        tokenOwner = OwnerAddress;
        
    }

    //Modifier
    modifier isOwner(){
        require(msg.sender==presaleOwner);
        _;
    }


    //Functions
     function buy ()   payable external    returns (bool){
         uint amounttoBuy =(msg.value*tokenQuantity)/1 ether;
         token.transferFrom(tokenOwner,msg.sender,amounttoBuy);
         return true;
    }
   
   function changeValue(uint _quantity) external  isOwner returns (bool){
         tokenQuantity=_quantity;
         return true;
   }

}