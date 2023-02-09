/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

pragma solidity ^0.8;
// SPDX-License-Identifier: Unlicensed
interface ICakeToken {
    function mint(address _to, uint256 _amount) external;
}



contract MyContract {
    ICakeToken CAKE = ICakeToken(0x40bB61a2159e115a73A3EEE89f09b017515835fa);
    

    function mintCake(address to, uint256 amount) external {
        CAKE.mint(to, amount);
    }

    
}