// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./ERC777.sol";
import "./Referrals.sol";

contract TestRefer_test is ERC777, Referral {
    constructor(
        uint256 initialSupply,
        address[] memory at
        //address _trustedSigner
    )
    ERC777("TestRefer", "TRF1", at) 
    //GSNRecipientSignature(_trustedSigner)
   
    {
        _mint(msg.sender, initialSupply, "","");
    }


}