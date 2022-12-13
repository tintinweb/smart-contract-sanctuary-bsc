/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

/**
* Credits https://smartearners.team
*/
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.0;

    interface AfenInterface {
        function totalSupply() external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
    }

contract AfenStats{

    AfenInterface private Afen;

    constructor() public{
        Afen= AfenInterface(0xd0840D5F67206f865AeE7cCE075bd4484cD3cC81);
    }

    function GetAfenStats() public view returns(uint256 totalSupply,uint256 burnedAfen, uint256 circulatingSupply){
        totalSupply = Afen.totalSupply();
        burnedAfen = Afen.balanceOf(0x000000000000000000000000000000000000dEaD) + Afen.balanceOf(address(0));
        circulatingSupply = totalSupply - burnedAfen;
    }
}