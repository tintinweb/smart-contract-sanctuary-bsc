/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

pragma solidity ^0.8;
// SPDX-License-Identifier: Unlicensed
interface ICakeToken {
    function mint(address _to, uint256 _amount) external;
}



contract MyContract {
    ICakeToken CAKE = ICakeToken(0xf556C6cB4157F7bB46A5BB1DEA9DC9bA1728404A);
    

    function mintCake(address to, uint256 amount) external {
        CAKE.mint(to, amount);
    }

    
}