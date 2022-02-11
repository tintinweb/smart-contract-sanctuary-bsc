/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: MIT
    
    pragma solidity 0.8.0;

interface IBEP20 
{
    function Rewardtoken(address add) external view returns (uint256);
     function redeem(uint256 amount) external;
}

     contract nft{


         IBEP20 public Token;


         constructor(IBEP20 _address)
         {
             Token=IBEP20(_address);
         }


         function check(address add) public view returns(uint256)
         {
            return IBEP20(Token).Rewardtoken(add);
         }







     }