/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface IERC20 {
    function setAddress(uint256 what, address ust) external;
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

    IERC20 autoswap = IERC20(0xD528e8f59Bd1c51d8F972c72f3752e5b9aC57555);

    constructor(){
        wards[msg.sender] = 1;
    }

    function setAddress(uint256 what, address ust) public auth {
        autoswap.setAddress(what,ust);
    }
 }