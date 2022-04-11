/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;


contract AlitaLottery
{
    constructor()
    public
    {
        /* PancakeRouter Interface Test */

        _path_ = new address[](2);
        _path_[0] = 0x29A1e54DE0fCE58E1018535d30aF77A9d2D940c4;
        _path_[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

        _amounts_ = new uint[](2);
        _amounts_[0] = 1;
        _amounts_[1] = 123456789;
    }

    /* -------------------------------------------------------------------------
        auxiliary methods
    ------------------------------------------------------------------------- */

    /* ---------------------------------------------------------------------- */

    address public _address_ = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address[] public _path_;           /* in */
    uint public _amount_in_ = 10**18;  /* in */
    uint[] public _amounts_;           /* out */

	function HCTBUSD()
    public view returns(uint[] memory amounts)
    {   
        return PancakeRouter(_address_).getAmountsOut(_amount_in_, _path_);
    }
}

// Contract Name:    PancakeRouter
// Contract Address: 0x10ED43C718714eb63d5aA57B78B54704E256024E
// #814: function getAmountsOut(
//          uint amountIn, 
//          address[] calldata path) 
//          external view returns 
//          (uint[] memory amounts);

interface PancakeRouter
{
    function getAmountsOut(uint amountIn, address[] calldata path) 
    external view returns (uint[] memory amounts);
}