// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./PaymentSplitter.sol";

contract PAYMENTS is PaymentSplitter {
    
    constructor (address[] memory _payees, uint256[] memory _shares) PaymentSplitter(_payees, _shares) payable {}
    
}

/**
 ["0xeF2EB32D184e5829FDbB5b6ceaf81981cc06FC1e",
 "0x14cb82D95A585Ab60270934F83881e0d30ecf22A", 
 "0xA7CcD38806eAd384060b03C0883E76f7B716fE6a"]
 */
 
 /**
 [1, 
 1,
 98]
 */