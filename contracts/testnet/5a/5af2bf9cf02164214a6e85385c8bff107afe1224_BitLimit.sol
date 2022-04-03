/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

pragma solidity ^0.8.13;


contract BitLimit {
    function max(uint16 _bits) external pure returns (uint256) {
        require(_bits < 256, "max 256 bits");
        return 2**_bits;
    }
}