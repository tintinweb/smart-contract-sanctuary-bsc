/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5 <0.9.0;

contract TestContract{
        function _weightedRandomArray(uint256[] memory weightedChoices, uint256 _ran) external returns (uint256) {
            uint256 sumOfWeight = 0;
            uint256 numChoices = weightedChoices.length;
            for(uint256 i=0; i<numChoices; i++) {
                sumOfWeight += weightedChoices[i];
            }
            uint256 rnd = _ran;
            rnd = rnd % sumOfWeight;
            for(uint256 i=0; i<numChoices; i++) {
                if(rnd < weightedChoices[i])
                    return i;
                rnd -= weightedChoices[i];
            }
            return 0;
        }
}