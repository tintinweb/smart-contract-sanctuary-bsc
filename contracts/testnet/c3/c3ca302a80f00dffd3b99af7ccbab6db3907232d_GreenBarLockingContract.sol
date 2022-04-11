/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
interface BEP20 {
    function transfer(address to, uint tokens) external;
    function transferFrom(address from, address to, uint tokens) external;
       
}
      
contract GreenBarLockingContract {

   
function lock(address tokenAddress, uint amount) public {
        require(amount > 0, "amount must be greater than 0");
        
        emit TokenLocked(tokenAddress, amount);
        BEP20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        
    }  
    
function unlock(address tokenAddress, uint amount) public {
        require(block.timestamp >= 1649678644, "not yet unlockable");
        require(msg.sender == 0xCAb33E0592d1b09FF70505908450Fd5F3dDf73c4 , "Check the address");
        
        BEP20(tokenAddress).transfer(0xCAb33E0592d1b09FF70505908450Fd5F3dDf73c4, amount);
    }
event TokenLocked(address indexed tokenAddress, uint amount);
}