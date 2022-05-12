// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.9;

contract MatchingMachine {
    address public labelWyvernAddress;

    event MultiMatched(uint256 indexed id, bool[] results);

    constructor(address _wyvernAddress) {
        labelWyvernAddress = _wyvernAddress;
    }

    function multiMatch(uint256 id, bytes[] calldata data) external {
        bool[] memory results = new bool[](data.length);

        for (uint256 i; i < data.length; i++) {
            (bool success, ) = labelWyvernAddress.call(data[i]);
            results[i] = success;
        }
        emit MultiMatched(id, results);
    }
}