// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract TestBigIndex {
    event SomethingWithBigIndex(
        address[] indexed tokenAddresses,
        uint256[] indexed tokenIds,
        address[] froms,
        address[] tos,
        uint256[] amounts
    );

    function callSomethingBig(
        address[] memory tokenAddresses,
        uint256[] memory tokenIds,
        address[] memory froms,
        address[] memory tos,
        uint256[] memory amounts
    ) external {
        emit SomethingWithBigIndex(tokenAddresses, tokenIds, froms, tos, amounts);
    }
}