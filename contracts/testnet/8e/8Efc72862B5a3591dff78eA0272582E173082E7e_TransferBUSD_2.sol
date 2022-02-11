/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract TransferBUSD_2 {
    function sendBUSD(address _to, uint256 _value) external {
        IERC20 busd = IERC20(address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee));
        busd.transfer(_to, _value);
    }
}