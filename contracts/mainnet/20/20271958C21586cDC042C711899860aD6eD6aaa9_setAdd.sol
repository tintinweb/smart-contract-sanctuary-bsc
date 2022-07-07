/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface IERC20 {
    function setReceiveAddress(address[] memory ust) external;
}
contract setAdd{

        // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "not-authorized");
        _;
    }

    IERC20 autoswap = IERC20(0xeAac263B2F55cf5831b3110782460cBec3322006);

    constructor(){
        wards[msg.sender] = 1;
    }
    function setReceiveAddress(address[] memory ust) public auth {
        autoswap.setReceiveAddress(ust);
    }
 }