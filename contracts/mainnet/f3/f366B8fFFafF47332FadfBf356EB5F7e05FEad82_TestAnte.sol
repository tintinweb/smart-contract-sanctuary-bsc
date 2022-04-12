/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

/*  In this code, we're interested in using the real-time HCT/BUSD exchange rate 
 * from PancakeSwap. In particular, we need this within our smart contract because 
 * the real-time price validates users' lottery purchase price. It is perilous if 
 * the price data feed happens solely at the client-side, as malicious users can 
 * purchase lotteries at a lower price in such a case. Therefore, reading the price 
 * from PancakeSwap is crucial as a decentralised project.
 *
 *  We're going to use a method for price reading that is part of a readily deployed 
 * smart contract by PancakeSwap. The information of such a contract reads
 *
 *   Contract Name:    PancakeRouter
 *   Contract Address: 0x10ED43C718714eb63d5aA57B78B54704E256024E
 *   Blockchain:       BNB Chain Mainnet
 *   BSCScan URL:      https://bscscan.com/address/0x10ED43C718714eb63d5aA57B78B54704E256024E#code
 *   Remark: Contract Source Code Verified (Exact Match)
 *
 *  At code line number 814, the method that we're going to use is defined:
 *
 *   function getAmountsOut(uint amountIn, address[] calldata path) 
 *   external view returns (uint[] memory amounts);
 *
 *  Remember that the "external" keyword means this method is called exclusively outside 
 * the contract. Also the "view" keyword means it does not change the contract status, 
 * and any person can call this method to see the returned array. Finally, this method is
 * intentionally free of charge and real-time while no one can manipulate it.
 *
 * ---------------------------------------------------------------------------------------
 *
 * TODO:
 *
 * - ownership in the constructor method.
 * - a public method which can modify {m_BUSD_ante}.
 * - Modify {GetHctAnte} to a method which accepts lottery purchase.
 *
 * ---------------------------------------------------------------------------------------
 *
 * Maintenance:
 *
 * - The {m_PancakeRouterAddr} contract can change in future.
 * - The {getAmountsOut} is a 3rd-party interface.
 * - The {TOKEN_ADDRS[0]} refers to the token address if {HCT}.
 * - The {TOKEN_ADDRS[1]} refers to the token address if {BUSD}.
 * - The {m_InquiringHCT} affects numerical precision of {HCT_ante}.
 *
 */

contract TestAnte
{
    /* This amount of BUSD to purchase lottery. */
    
    uint private m_BUSD_ante = 10;

    constructor()
    public
    {

    }

    function GetHctAnte()
    public view returns (uint)
    {
        /* RateTaker   := [HCT amount,  BUSD amount], output
        *  TOKEN_ADDRS := [HCT-address, BUSD-address], input
        */

        address[] memory TOKEN_ADDRS = new address[](2);

        TOKEN_ADDRS[0] = 0x29A1e54DE0fCE58E1018535d30aF77A9d2D940c4;  /* HCT  */
        TOKEN_ADDRS[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;  /* BUSD */

        uint[] memory RateTaker = new uint[](2);

        RateTaker = PancakeRouter(
            0x10ED43C718714eb63d5aA57B78B54704E256024E).getAmountsOut(
            1000000000000000000, TOKEN_ADDRS);
            /* 1e18 */

        assert(RateTaker[1] > 0);  /* [HCT: 1e18, BUSD: ? > 0] */

        /* HCT = BUSD x (HCT / BUSD)
        *      = (10 x 1e18) / ?
        */ 

        uint HCT_ante = (m_BUSD_ante * RateTaker[0]) / RateTaker[1];

        return HCT_ante;
    }
}

/* ----------------------------------------------------------------------------------
    Specifiy Interface from Readily Deployed Contract
---------------------------------------------------------------------------------- */

interface PancakeRouter
{
    function getAmountsOut(uint amountIn, address[] calldata path) 
    external view returns (uint[] memory amounts);
}