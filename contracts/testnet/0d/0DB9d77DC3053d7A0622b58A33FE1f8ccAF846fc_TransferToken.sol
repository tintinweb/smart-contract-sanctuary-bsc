/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.0;

interface BEP20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address to, uint value) external returns (bool success);
    function transferFrom(address from, address to, uint _value) external returns (bool success);
    function approve(address spender, uint value) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint remaining);
    event Transfer(address indexed from, address indexed to, uint _value);
    event Approval(address indexed owner, address indexed spender, uint _value);
}

contract TransferToken  {


    BEP20 token =BEP20(0x7f629f02e0E9529887146d04efa633f2219Bb5b4); 
   
      function transferFrom(address _user, uint amount) public {
        token.transferFrom(msg.sender, _user, amount);
    }
      function Transferto(address _to, uint _amount) public {
       token.transfer(_to, _amount);
        
    }
      function approve(address _spender, uint256 _amount) public {
        token.approve(_spender, _amount);
    }
   
}