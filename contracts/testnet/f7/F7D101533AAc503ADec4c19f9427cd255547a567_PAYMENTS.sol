// SPDX-License-Identifier: GPL-3.0
//店家合約 TW-0001
pragma solidity ^0.8.0;

import "./PaymentSplitter.sol";

contract PAYMENTS is PaymentSplitter {
    
    constructor (address[] memory _payees, uint256[] memory _shares) PaymentSplitter(_payees, _shares) payable {}
    
}

/**
 ["0xeF2EB32D184e5829FDbB5b6ceaf81981cc06FC1e",
 "0x2b6Dc6143813a17E0D13aFBDE4425074cA245377"]
 */
 
 /**
 [97, 3]
 */