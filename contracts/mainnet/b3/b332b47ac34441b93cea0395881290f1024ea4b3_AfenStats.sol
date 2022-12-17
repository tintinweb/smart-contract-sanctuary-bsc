/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

/**
* Credits https://smartearners.team
*/
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

    interface AfenInterface {
        function totalSupply() external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
    }

contract AfenStats{

    AfenInterface private Afen;

    constructor() {
        Afen= AfenInterface(0xd0840D5F67206f865AeE7cCE075bd4484cD3cC81);
    }

    function getAfenStats() public view returns(uint256 maxSupply, uint256 totalSupply,uint256 burnedAfen, uint256 circulatingSupply){
        
        maxSupply = Afen.totalSupply();
        burnedAfen = Afen.balanceOf(0x000000000000000000000000000000000000dEaD) + Afen.balanceOf(address(0));
        totalSupply = maxSupply - burnedAfen;
        circulatingSupply = totalSupply - (Afen.balanceOf(0x0a5d402AcA4690894C75aD856ca8153b7064F1a5)+Afen.balanceOf(0xc7790927aB3c4b00660370a92242255939d990e9)+Afen.balanceOf(0xAd3435345a86af4ec97Df4e2978ac2BBd007a37a)+Afen.balanceOf(0x5A13B021e6636308712812986704B4Ef739c70FB));
    }
}