/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


/** APOCALYPSE RANDOMIZER **/

contract ApocalypseRandomizer {


    /** DATA **/
    
    uint256 internal constant maskLast8Bits = uint256(0xff);
    uint256 internal constant maskFirst248Bits = type(uint256).max;

    /** FUNCTION **/
       
    function sliceNumber(uint256 _n, uint256 _base, uint256 _index, uint256 _offset) public pure returns (uint256) {
        return _sliceNumber(_n, _base, _index, _offset);
    }

    /**
     * @dev Given a number get a slice of any bits, at certain offset.
     * 
     * @param _n a number to be sliced
     * @param _base base number
     * @param _index how many bits long is the new number
     * @param _offset how many bits to skip
     */
    function _sliceNumber(uint256 _n, uint256 _base, uint256 _index, uint256 _offset) internal pure returns (uint256) {
        uint256 mask = uint256((_base**_index) - 1) << _offset;
        return uint256((_n & mask) >> _offset);
    }

    function randomNGenerator(uint256 _param1, uint256 _param2, uint256 _targetBlock) public view returns (uint256) {
        return _randomNGenerator(_param1, _param2, _targetBlock);
    }

    /**
     * @dev Generate random number from the hash of the "target block".
     */
    function _randomNGenerator(uint256 _param1, uint256 _param2, uint256 _targetBlock) internal view returns (uint256) {
        uint256 randomN = uint256(blockhash(_targetBlock));
        
        if (randomN == 0) {
            _targetBlock = (block.number & maskFirst248Bits) + (_targetBlock & maskLast8Bits);
        
            if (_targetBlock >= block.number) {
                _targetBlock -= 256;
            }
            
            randomN = uint256(blockhash(_targetBlock));
        }

        randomN = uint256(keccak256(abi.encodePacked(randomN, _param1, _param2, _targetBlock)));

        return randomN;
    }

}