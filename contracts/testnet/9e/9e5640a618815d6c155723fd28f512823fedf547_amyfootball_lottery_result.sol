/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
contract amyfootball_lottery_result {
    function checklottery(uint256 _blockN,uint256 lottoType) view public returns(uint256, uint256,uint256) {
        uint256 crew = uint256(blockhash(_blockN)) % lottoType;
            return (crew, _blockN,lottoType);
    }
}