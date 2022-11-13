// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./ERC20.sol";
import "./Ownable.sol";

contract BSCToken is ERC20("Okrum", "OKR"), Ownable {
    constructor(address beneficiary) {
        require(
            beneficiary != address(0),
            "beneficiary cannot be the 0 address"
        );
        uint256 supply = 100000000000 ether;
        _mint(beneficiary, supply);
    }

    function getOwner() external view returns (address) {
        return owner();
    }
}