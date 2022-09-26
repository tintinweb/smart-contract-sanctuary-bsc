/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

contract Temp {
    event winner(uint256, uint256);
    struct LottResObj {
        uint256 lott_id;
        uint256 timestamp;
    }

    mapping(uint256 => LottResObj) public results;

    function get_winner(uint256 lott_id)
        public
        view
        returns (uint256, uint256)
    {
        LottResObj memory res = results[lott_id];
        return (res.lott_id, res.timestamp);
    }
}