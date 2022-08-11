// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

/**
 * @title Call
 * @dev
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract TestContract {
    function func1(address addr, string memory name)
        external
        pure
        returns (address result1, string memory result2)
    {
        result1 = addr;
        result2 = name;
    }

    function func2(uint256 value, address addr)
        external
        pure
        returns (uint256 result1, address result2)
    {
        result1 = value;
        result2 = addr;
    }

    function func3(string memory name, uint256 value)
        external
        pure
        returns (string memory result1, uint256 result2)
    {
        result1 = name;
        result2 = value;
    }
}