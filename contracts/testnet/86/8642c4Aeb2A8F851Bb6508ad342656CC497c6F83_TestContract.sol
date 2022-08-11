// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

/**
 * @title Call
 * @dev
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract TestContract {
    address public addrG;
    string public nameG;
    uint256 public valueG;

    function func1(address addr, string memory name)
        external
        returns (address result1, string memory result2)
    {
        addrG = addr;
        nameG = name;
        result1 = addr;
        result2 = name;
    }

    function func2(uint256 value, address addr)
        external
        returns (uint256 result1, address result2)
    {
        valueG = value;
        addrG = addr;
        result1 = value;
        result2 = addr;
    }

    function func3(string memory name, uint256 value)
        external
        returns (string memory result1, uint256 result2)
    {
        nameG = name;
        valueG = value;
        result1 = name;
        result2 = value;
    }
}