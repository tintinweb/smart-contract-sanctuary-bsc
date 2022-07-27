/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IERC20 {
    function balanceOf(address owner) external view returns(uint256);
}


contract BatchBalance {
    function getBalances(address token, address[] memory addrs) public view returns(uint256[] memory amounts) {
        require(token != address(0), "BatchBalance: token is 0");

        uint256 length = addrs.length;
        require(length > 0, "BatchBalance: addresses length is 0");

        amounts = new uint256[](length);

        IERC20 t = IERC20(token);
        for(uint256 i ; i < length ; i++) {
            amounts[i] = t.balanceOf(addrs[i]);
        }
    }
}