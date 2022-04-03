/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

pragma solidity ^0.8.13;


contract BitLimit {
    function max(uint16 _bits) external pure returns (uint256) {
        require(_bits <= 256, "max 256 bits");
        if (_bits == 0) {
            return 0;
        } else if (_bits == 256) {
            return ~uint256(0);
        } else {
            return 2**_bits - 1;
        }
    }
}