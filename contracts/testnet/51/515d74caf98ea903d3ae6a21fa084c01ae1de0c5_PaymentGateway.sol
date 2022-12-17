/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// File: Dsl.sol


pragma solidity >=0.5.0 <0.9.0;

contract PaymentGateway
{
    
    event LogDepositeMade(address from,address to ,uint amount );

        

        function deposit(address payable receipent, uint _amonut) external payable  
        {
         receipent.transfer(_amonut);
         emit LogDepositeMade(msg.sender , receipent, msg.value);
       
        } 

}