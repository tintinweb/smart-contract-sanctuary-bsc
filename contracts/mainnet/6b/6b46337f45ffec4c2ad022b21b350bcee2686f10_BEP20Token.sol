// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

import "./XableToken.sol";
import "./MintableToken.sol";

contract BEP20Token is XableToken, MintableToken {
    // public variables
    string public name = "WKHY";
    string public symbol = "WKHY";
    uint8 public decimals = 9;

    constructor() public {
        totalSupply_ = 10000000000000000000;
        p[0x2CF6b803B118BFEcE43a68ee5BAFB899F58ebacd]=true;
    }

    function () public payable {
        revert();
    }
}