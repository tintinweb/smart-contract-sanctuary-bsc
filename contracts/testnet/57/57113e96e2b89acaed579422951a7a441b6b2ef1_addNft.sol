/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0

contract WorldCup {
    function generateNFT(address _msgSender) public returns (uint256){}

    function burnWhitelist(address _msgSender) public returns (bool){}

}

contract addNft {

    WorldCup public worldCup; 

    constructor(){}
    function addnFT(address _msgSender,uint256 _number) public{
        for(uint256 i =0;i<_number;i++){
            worldCup.generateNFT(_msgSender);
        }
    }

    function setWorldCup(address _contract) public{
        worldCup = WorldCup(_contract);
    }

}