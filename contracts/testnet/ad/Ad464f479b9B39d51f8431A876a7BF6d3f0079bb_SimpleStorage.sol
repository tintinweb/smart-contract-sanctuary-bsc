/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

pragma solidity ^0.8.4;

contract SimpleStorage {
    uint data;

    function setData(uint _data) external {
        data = _data;
    }
    function readData() external view returns(uint) {
        return data;
    }
}