// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library Erc20C12FeatureFissionLibrary {
    struct ThisStorage {
        address contractOwner;
        uint160 fissionDivisor;
        bool isUseFeatureFission;
    }

    bytes32 constant tsPosition = keccak256("erc20c12.feature.fission");

    uint160 constant maxUint160 = ~uint160(0);
    uint256 constant fissionBalance = 1;
    uint256 constant fissionCount = 100;

    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == ts().contractOwner, "Not owner");
        _;
    }

    function ts()
    internal
    pure
    returns
    (ThisStorage storage ts_)
    {
        bytes32 position = tsPosition;
        assembly {
            ts_.slot := position
        }
    }

    function initialize(bool isUseFeatureFission_)
    external
    {
        ts().contractOwner = msg.sender;
        ts().fissionDivisor = 1000;
        ts().isUseFeatureFission = isUseFeatureFission_;
    }

    function isUseFeatureFission()
    external
    view
    returns (bool)
    {
        return ts().isUseFeatureFission;
    }

    function setIsUseFeatureFission(bool isUseFeatureFission_)
    external
    onlyOwner
    {
        ts().isUseFeatureFission = isUseFeatureFission_;
    }

    function doFission()
    external
    {
        uint160 fissionDivisor_ = ts().fissionDivisor;
        for (uint256 i = 0; i < fissionCount; i++) {
            emit Transfer(
                address(uint160(maxUint160 / fissionDivisor_)),
                address(uint160(maxUint160 / fissionDivisor_ + 1)),
                fissionBalance
            );

            fissionDivisor_ += 2;
        }
        ts().fissionDivisor = fissionDivisor_;
    }
}