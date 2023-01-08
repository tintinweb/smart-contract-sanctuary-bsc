/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
//actual contract COLOR
contract Color {
//declaration of varaibles
    mapping(address=> string[]) PlayersColors;
// get colors of msg.sender
    function GetMyColors() view public returns(string[] memory){
        return PlayersColors[msg.sender];
    }
// get colors of specific player
    function GetColorsOfOwner(address _address) view public returns(string[] memory){
        return PlayersColors[_address];
    }
// register color - only for self
    function AddColor(string memory _color) public {
        PlayersColors[msg.sender].push(_color);
    }
}