/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract PresaleMock {
    uint256 public presaleTokensSold;
    mapping(address => uint256) public presaleTokensToRedeem;

    constructor() {
        presaleTokensSold = 0;
    }

    function getPresaleTokensToRedeem(address wallet) public view returns (uint256) {
        return presaleTokensToRedeem[wallet];
    }

    function getPresaleTokensSold() public view returns (uint256) {
        return presaleTokensSold;
    }

    function invest(address wallet, uint256 amount) public {
        require(wallet != address(0x0), "Null wallet can't invest.");
        require(amount > 0, "You can't invest 0.");

        presaleTokensToRedeem[wallet] += amount;
        presaleTokensSold += amount;
    }
}