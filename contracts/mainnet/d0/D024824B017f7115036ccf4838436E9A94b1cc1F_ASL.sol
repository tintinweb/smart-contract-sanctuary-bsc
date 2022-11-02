// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./ERC777.sol";
import "./referrals.sol";

contract ASL is Referral{
    constructor(
        uint256 initialSupply,
        address[] memory at
    )
    ERC777("Africa Startup League", "ASL", at)
   
    {
        _mint(msg.sender, initialSupply, "","");
    }

}