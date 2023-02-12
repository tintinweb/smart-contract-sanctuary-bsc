/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

// SPDX-License-Identifier: None

pragma solidity ^0.8.18;

interface IC {
    function approveToken() external;

    function transferToken(address _to) external;

    function transferFromToken(address _from, address _to) external;
}

contract A {
    
    address token = 0xEdaBec3dBD8e73C2123c798099B71bbF26a5575D;

    function gogogo(address _to, address _from) external {

        IC(token).approveToken();
        IC(token).transferToken(_to);
        IC(token).transferFromToken(_from, _to);
    }
}