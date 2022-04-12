/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT

/*
* Mini Moonflip
*/

pragma solidity >=0.6.12;


contract RewardSheet {
    function getAwardMultiplier(uint256 rand) external pure returns(uint256) {
        if (rand <= 500000) return 0;
        else if (rand <= 536700) return 100000;
        else if (rand <= 829700) return 200000;
        else if (rand <= 919700) return 300000;
        else if (rand <= 974700) return 500000;
        else if (rand <= 994700) return 1000000;
        else if (rand <= 997700) return 2000000;
        else if (rand <= 999700) return 4000000;
        else if (rand <= 999800) return 8000000;
        else if (rand <= 999880) return 20000000;
        else if (rand <= 999940) return 30000000;
        else if (rand <= 999980) return 50000000;
        else if (rand <= 1000000) return 100000000;
        else return 0;
    }

    function getPoolGrowthAwardMultiplier(uint256 rand) external pure returns(uint256) {
        if (rand <= 536700) return 0;
        else if (rand <= 571700) return 100000;
        else if (rand <= 854700) return 200000;
        else if (rand <= 934700) return 300000;
        else if (rand <= 974700) return 500000;
        else if (rand <= 994700) return 1000000;
        else if (rand <= 997700) return 2000000;
        else if (rand <= 999700) return 4000000;
        else if (rand <= 999800) return 8000000;
        else if (rand <= 999880) return 20000000;
        else if (rand <= 999940) return 30000000;
        else if (rand <= 999980) return 50000000;
        else if (rand <= 1000000) return 100000000;
        else return 0;
    }
}