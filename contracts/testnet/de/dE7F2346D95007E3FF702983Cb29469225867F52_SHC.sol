pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./CappedToken.sol";

contract SHC is CappedToken {
    string public name = "ShieldCoin";
    string public symbol = "SHC";
    uint8 public decimals = 18;

    constructor(uint256 _cap) public CappedToken(_cap) {}
}