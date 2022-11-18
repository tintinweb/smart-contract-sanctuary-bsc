/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract Test {
    uint256 _numAvailableTokens = 100;
    uint256[100] _availableTokens;

    function useRandomAvailableToken(uint256 _numToFetch, uint256 _i) public returns (uint256 val){
        
        uint256 randomNum = uint256(
            keccak256(
                abi.encode(msg.sender,tx.gasprice,block.number,block.timestamp,blockhash(block.number - 1),_numToFetch,_i
                )
            )
        );
        uint256 randomIndex = randomNum % _numAvailableTokens;
        uint256 valAtIndex = _availableTokens[randomIndex];
        uint256 result;
        if (valAtIndex == 0) {
            result = randomIndex;
        } else {
            result = valAtIndex;
        }
        uint256 lastIndex = _numAvailableTokens - 1;
        if (randomIndex != lastIndex) {
            uint256 lastValInArray = _availableTokens[lastIndex];
            if (lastValInArray == 0) {
                _availableTokens[randomIndex] = lastIndex;
            } else {
                _availableTokens[randomIndex] = lastValInArray;
            }
        }
        _numAvailableTokens--;
        return result + 1;
    }
}