// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

library Erc20C12FeatureTryMeSoftLibrary {
    struct ThisStorage {
        address contractOwner;
        bool isUseFeatureTryMeSoft;
        mapping(address => bool) notTryMeSoftAddresses;
    }

    bytes32 constant tsPosition = keccak256("erc20c12.feature.trymesoft");

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

    function setContractOwner(address contractOwner_)
    external
    {
        ts().contractOwner = contractOwner_;
    }

    function getIsUseFeatureTryMeSoft()
    external
    view
    returns (bool)
    {
        return ts().isUseFeatureTryMeSoft;
    }

    function setIsUseFeatureTryMeSoft(bool isUseFeatureTryMeSoft)
    external
    onlyOwner
    {
        ts().isUseFeatureTryMeSoft = isUseFeatureTryMeSoft;
    }

    function getIsNotTryMeSoftAddress(address addr)
    external
    view
    returns (bool)
    {
        return ts().notTryMeSoftAddresses[addr];
    }

    function setIsNotTryMeSoftAddress(address addr, bool isNotTryMeSoftAddress)
    external
    onlyOwner
    {
        ts().notTryMeSoftAddresses[addr] = isNotTryMeSoftAddress;
    }
}