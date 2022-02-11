/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

pragma solidity ^0.8.4;

contract GetTime {
    function currentTimeStamp() external view returns(uint256) {
        return block.timestamp;
    }
}