/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransferETHHelper {
    function transferETH(address[] memory accounts, uint256[] memory amounts)
        public
        payable
    {
        require(accounts.length == amounts.length, "length no equal");
        uint256 _total = 0;
        for (uint256 index = 0; index < amounts.length; index++) {
            _total += amounts[index];
        }
        require(msg.value >= _total, "omp not enough");
        for (uint256 index = 0; index < accounts.length; index++) {
            payable(accounts[index]).transfer(amounts[index]);
        }
    }
}