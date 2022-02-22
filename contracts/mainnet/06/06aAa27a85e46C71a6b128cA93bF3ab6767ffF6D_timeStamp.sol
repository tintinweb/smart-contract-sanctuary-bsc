/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

pragma solidity^0.8.9;

contract timeStamp{
    function readTimeStamp() external view returns(uint256){
        return block.timestamp;
    }
}