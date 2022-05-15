// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Strings.sol";
import "./SafeMath.sol";

contract RandomRate is Ownable {
    using Strings for string;

    uint16 private constant SUITE = 5; //Battle Suit
    uint16 private constant WEAP = 8; //WEAP

    mapping(uint16 => uint256[]) BPPoolPercent;
    mapping(uint16 => uint16[]) BPPoolResults;
    mapping(uint16 => uint16[]) BPPoolValues;

    function randomArrayGenerater(uint16 index, uint16[] memory array) public onlyOwner{
        BPPoolResults[index] = array;
    }

    function randomArrayReturner(uint16 index) public view returns (uint16[] memory) {
        return BPPoolResults[index];
    }

    function initial() public onlyOwner {
        //-----------------START RATE --------------------------------

        BPPoolPercent[SUITE] = [
            uint256(2666),
            uint256(2666),
            uint256(2666),
            uint256(100),
            uint256(100),
            uint256(100),
            uint256(100),
            uint256(100),
            uint256(750),
            uint256(750)
        ];  

        for (uint16 p = 0; p < BPPoolPercent[SUITE].length; p++) {
            uint256 qtyItem = (100 * BPPoolPercent[SUITE][p]) / 10000;
            for (uint16 i = 0; i < qtyItem; i++) {
                BPPoolValues[SUITE].push(BPPoolResults[SUITE][p]);
            }
        }

        BPPoolPercent[WEAP] = [
            uint256(1600),
            uint256(1600),
            uint256(1600),
            uint256(1600),
            uint256(1500), // from 1600
            uint256(100), // from 83
            uint256(100), // from 83
            uint256(100), // from 83
            uint256(100), // from 83
            uint256(100), // from 83
            uint256(100), // from 83
            uint256(100), // from 83
            uint256(700), // from 750
            uint256(700) // from 750
        ];

        for (uint16 p = 0; p < BPPoolPercent[WEAP].length; p++) {
            uint256 qtyItem = (100 * BPPoolPercent[WEAP][p]) / 10000;
            for (uint16 i = 0; i < qtyItem; i++) {
                BPPoolValues[WEAP].push(BPPoolResults[WEAP][p]);
            }
        }

        //-----------------END COMMON BOX RATE --------------------------------
    }

    function getBlueprintPool(uint16 itemType, uint16 _number)
        public
        view
        returns (uint16)
    {
        uint16 _modNumber = uint16(_number) %
            uint16(BPPoolValues[itemType].length);
        return uint16(BPPoolValues[itemType][_modNumber]);
    }
}