/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

// File: Dsl.sol


pragma solidity 0.8.7;

contract PaymentGateway
{
    
    event LogDepositeMade(address from,address to ,uint amount );

        

        function deposit(address payable receipent) external payable  
        {
         receipent.transfer(msg.value);
         emit LogDepositeMade(msg.sender , receipent, msg.value);
       
        } 

}