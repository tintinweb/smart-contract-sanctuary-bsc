// SPDX-License-Identifier: GPL-3.0
//活動合約
pragma solidity ^0.8.0;

import "./PaymentSplitter.sol";

contract PAYMENTS is PaymentSplitter {
    
    constructor (address[] memory _payees, uint256[] memory _shares) PaymentSplitter(_payees, _shares) payable {}
    
}

/**
 ["0x6921042C4E1661497253Ed4ce2061b9701289F1c",
 "0xade3Ce867A306F809A5b71Fad44022F059e839F2"]
 */
 
 /**
 [50, 50]
 */