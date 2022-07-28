/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;

contract sometest {
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bool init0;
    bool init1;
    address public lastSender;
    uint public ret;

    function add(uint256 a,uint256 b) external {
        lastSender=msg.sender;
        ret=a+b;
    }

    function getRet() public view returns(uint) {
        return ret;
    }

    function setInit(bool b0,bool b1) external {
        init0 = b0;
        init1 = b1;
    }

    

}