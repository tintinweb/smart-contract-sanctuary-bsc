/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IAsset {
    function balanceOf(address user) external view returns (uint256);
}

contract BurnWallet {

    function amountBurned(address token) external view returns (uint256) {
        return IAsset(token).balanceOf(address(this));
    }

}