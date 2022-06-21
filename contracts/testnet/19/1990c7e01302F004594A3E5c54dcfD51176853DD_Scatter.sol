/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-30
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract Scatter {
    event TransferFailed(address to, uint256 value);
    
    address public owner;
    
    
    constructor(){
        owner = msg.sender;
    }
    

    
    
    
        
    function returnExtraEth () internal {
        uint256 balance = address(this).balance;
        if (balance > 0){ 
            payable(msg.sender).transfer(balance); 
        }
    }
    
    
    function scatterEther(address[] memory recipients, uint256[] memory values, bool revertOnfail)  external payable  {
        uint totalSuccess = 0;
         for (uint256 i = 0; i < recipients.length; i++){
           (bool success,)= recipients[i].call{value:values[i],gas:3500}('');
           if(revertOnfail) require(success,'One of the transfers failed');
           else if(success==false){
               emit TransferFailed(recipients[i],values[i]);
           }
           if(success) totalSuccess++;
        }
        
        require(totalSuccess>=1,'all transfers failed');
        returnExtraEth();
    }
    
   
    
    
    modifier onlyOwner {
        require(msg.sender==owner,'Only owner can call this function');
        _;
    }
    
}