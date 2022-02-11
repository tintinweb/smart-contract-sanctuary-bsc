/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract LaCucinaUtils {
    function isContract(address addr) public view returns (address _address, bool _isContract) {
        uint size;
        assembly { size := extcodesize(addr) }
        return (addr, size > 0);
    }
}