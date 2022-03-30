/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

pragma solidity 0.5.16;

contract Test {
    event Tested(uint256 indexed amount, uint256 time);
    uint256 public count;

    function Tets() public {
        count++;
        emit Tested(count, block.timestamp);
    }
}