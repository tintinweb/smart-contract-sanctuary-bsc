/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

pragma solidity 0.8.7;
// SPDX-License-Identifier: MIT

interface Pair {
    function _loansBase(address _addr)  external view returns (uint256);
    function _loansToken(address _addr) external view returns(uint256);
}

contract loanInspector{
    function userLoan(address CA_of_token, address Wallet_address) external view returns(uint256 token, uint256 fwrap){
        return (Pair(CA_of_token)._loansToken(Wallet_address),Pair(CA_of_token)._loansBase(Wallet_address));
    }

    

}