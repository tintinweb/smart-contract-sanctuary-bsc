/*
    Copyright 2022 JOJO Exchange
    SPDX-License-Identifier: Apache-2.0
*/

pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

interface IChainlink {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestAnswer() external view returns (int256 answer);
}

contract ChainlinkExpandAdaptor {
    address public immutable chainlink;
    uint256 public immutable decimalsCorrection;
    uint256 public immutable heartbeatInterval;

    constructor(
        address _chainlink,
        uint256 _decimalsCorrection,
        uint256 _heartbeatInterval
    ) {
        chainlink = _chainlink;
        decimalsCorrection = 10**_decimalsCorrection;
        heartbeatInterval = _heartbeatInterval;
    }

    function getMarkPrice() external view returns (uint256 price) {
        int256 rawPrice;
        uint256 updatedAt;
        (, rawPrice, , updatedAt, ) = IChainlink(chainlink).latestRoundData();
        require(
            block.timestamp - updatedAt <= heartbeatInterval,
            "ORACLE_HEARTBEAT_FAILED"
        );
        return (uint256(rawPrice) * 1e18) / decimalsCorrection;
    }
}