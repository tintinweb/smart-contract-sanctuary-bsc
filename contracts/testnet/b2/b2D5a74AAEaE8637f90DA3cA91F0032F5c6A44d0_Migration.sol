// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Migration {
    uint256 usd;
    event test(uint256 userAmount);
    function change(address _gymNetAddress) external returns (uint256) {
        address sender = msg.sender;
        uint256 userBallance;
        (bool success, bytes memory response) = _gymNetAddress.call(
            abi.encodeWithSignature("balanceOf(address)", sender)
        );
        userBallance = abi.decode(response, (uint256));
        emit test(userBallance);
        return userBallance;
    }
}