/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

abstract contract tokena{
     function transfer(address recipient, uint256 amount)
        external
        virtual
        returns (bool); 
    function approve(address spender,address recipient, uint256 amount) external virtual returns (bool);
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual returns (bool);
} //transfer方法的接口说明

contract TokenTransfer{
    tokena public wowToken;
    address private _tokenaddress;
    
    function tokenTransfer(address _to, uint _amt) public {
        wowToken = tokena(_tokenaddress);
        wowToken.transfer(_to,_amt); //调用token的transfer方法
    }

    function setTokenaddress(address acc) external{
        _tokenaddress = acc;
    }
}