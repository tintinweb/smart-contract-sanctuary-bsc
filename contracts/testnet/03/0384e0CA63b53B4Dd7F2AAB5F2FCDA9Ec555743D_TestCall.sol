// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract TestCall {
    uint256 public x;

    function updateX(uint256 _x) external {
        bytes memory data = abi.encodeWithSignature("setX(uint256)", _x);

        (bool success, ) = address(this).call(data);

        require(success, "Failed to call");
    }

    function setX(uint256 _x) internal {
        x = _x;
    }
}