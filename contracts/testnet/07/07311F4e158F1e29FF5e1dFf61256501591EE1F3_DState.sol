/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// SPDX-License-Identifier: MIT
// pragma solidity >=0.4.21 <8.10.0; 
pragma solidity ^0.8.11;


contract DState
{
    
     event WithdrawMoney(address _to,uint256 toPay);
     event BuyEvent(address _to,uint256 toPay);

      function buy(address _to,uint256 toPay) external {

        emit BuyEvent(_to, toPay);
    }

      function withdraw(address _to,uint256 toPay) external {

        emit WithdrawMoney(_to, toPay);
    }
}