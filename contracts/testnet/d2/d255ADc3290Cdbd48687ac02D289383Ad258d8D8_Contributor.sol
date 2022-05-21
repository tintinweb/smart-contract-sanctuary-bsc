/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
contract Contributor {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Contributor/not-authorized");
        _;
    }
    mapping (address => bool)     public contributor;
    constructor() public {
        wards[msg.sender] = 1;
    }
    function setFree(address _usr) external auth {
        contributor[_usr] = !contributor[_usr];
    }
 }