/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

pragma solidity ^0.8.17;

contract SimpleStorage {
    uint data;

    function updateData(uint _data) external {
        data = _data;
    }

    function readData() external view returns(uint) {
        return data;
    }
}