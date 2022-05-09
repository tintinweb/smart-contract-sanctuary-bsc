/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5 <0.9.0;

contract TestContract{
        uint8[] public slots =[4,5,6];
        uint8 public result;


        function _weightedRandomArray(uint256[] memory weightedChoices, uint256 _ran) internal pure returns (uint256) {
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

        function checkBug(uint256[] memory weightedChoices, uint256 randomNumber) external returns (uint8) {
            uint8 slotsDraw = slots[_weightedRandomArray(weightedChoices,randomNumber)];
            result = slotsDraw;
            return slotsDraw;
        }

}