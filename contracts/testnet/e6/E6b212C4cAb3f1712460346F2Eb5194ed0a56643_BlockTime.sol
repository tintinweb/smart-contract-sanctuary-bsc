// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0 <0.8.0;

contract BlockTime {
    function getBlockNumber(uint256 _time) public view returns (uint256 _block) {
        uint256 timeNow = block.timestamp;
        uint256 blockNumber = block.number;
        if(_time == timeNow){
            return blockNumber;
        } else if(_time > timeNow){
            uint256 calBlock = (_time - timeNow) / 3;
            return blockNumber + calBlock;
        } else {
            uint256 calBlock = (timeNow - _time) / 3;
            return blockNumber - calBlock;
        }
    }
}