// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./ERC20.sol";

contract BENZTOO is ERC20("BENZTOO", "BZT", 18) {

    uint256 public mintAmount = 75000000 ether;
    address public _owner;

    constructor (address __owner) {
        _owner = __owner;
        _mint(_owner, mintAmount);
        _transferOwnership(__owner);
    }

    function mintBZT() external onlyOwner {
        _mint(_owner, mintAmount);
    }
}