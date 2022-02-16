pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract ALO is CappedToken {
    string public name = "SALO";
    string public symbol = "$ALO";
    uint8 public decimals = 18;

    constructor(uint256 _cap) public CappedToken(_cap) {}
}