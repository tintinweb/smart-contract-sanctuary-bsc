/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

pragma solidity 0.8.15;
// SPDX-License-Identifier: MIT

interface Pair {
    function userBalanceInternal(address _addr) external view returns (uint256, uint256);
}

contract userInternalBalance{
    function userBalance(address CA_of_token, address Wallet_address) external view returns(uint256 token, uint256 fwrap){
        return Pair(CA_of_token).userBalanceInternal(Wallet_address);
    }
}