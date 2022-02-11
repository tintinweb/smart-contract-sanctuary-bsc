pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract AMPT is CappedToken {
    string public name = "Amptize";
    string public symbol = "AMPT";
    uint8 public decimals = 18;

    constructor(uint256 _cap) public CappedToken(_cap) {}
}