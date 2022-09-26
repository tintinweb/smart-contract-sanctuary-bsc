// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./ERC20.sol";

contract BCAT is ERC20("BABY CATTUS", "BCAT", 18) {

    uint256 public mintAmount = 10000000000 ether;
    address public _owner;

    constructor (address __owner) {
        _owner = __owner;
        _mint(_owner, mintAmount);
        _transferOwnership(__owner);
    }

    function mintBCAT() external onlyOwner {
        _mint(_owner, mintAmount);
    }
}