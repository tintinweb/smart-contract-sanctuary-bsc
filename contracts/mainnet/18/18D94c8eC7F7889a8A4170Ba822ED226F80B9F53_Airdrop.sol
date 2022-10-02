/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Airdrop {
    function airdrop(address token, address[] calldata holders, uint256[] calldata amounts) external {

        uint len = holders.length;
        for (uint i = 0; i < len;) {
            IERC20(token).transferFrom(
                msg.sender,
                holders[i],
                amounts[i]
            );
            unchecked { ++i; }
        }
    }
}