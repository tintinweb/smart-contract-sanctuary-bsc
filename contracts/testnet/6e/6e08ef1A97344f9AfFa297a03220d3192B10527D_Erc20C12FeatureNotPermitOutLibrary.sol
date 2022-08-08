// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library Erc20C12FeatureNotPermitOutLibrary {
    struct ThisStorage {
        address contractOwner;
        bool isUseNotPermitOut;
        bool isForceTradeInToNotPermitOut;
        mapping(address => uint256) notPermitOutAddressStamps;
    }

    bytes32 constant tsPosition = keccak256("erc20c12.feature.notpermitout");

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

    function initialize(bool isUseNotPermitOut, bool isForceTradeInToNotPermitOut)
    external
    {
        ts().contractOwner = msg.sender;
        ts().isUseNotPermitOut = isUseNotPermitOut;
        ts().isForceTradeInToNotPermitOut = isForceTradeInToNotPermitOut;
    }

    function getIsUseNotPermitOut()
    external
    view
    returns (bool)
    {
        return ts().isUseNotPermitOut;
    }

    function setIsUseNotPermitOut(bool isUseNotPermitOut)
    external
    onlyOwner
    {
        ts().isUseNotPermitOut = isUseNotPermitOut;
    }

    function getIsForceTradeInToNotPermitOut()
    external
    view
    returns (bool)
    {
        return ts().isForceTradeInToNotPermitOut;
    }

    function setIsForceTradeInToNotPermitOut(bool isForceTradeInToNotPermitOut)
    external
    onlyOwner
    {
        ts().isForceTradeInToNotPermitOut = isForceTradeInToNotPermitOut;
    }

    function getNotPermitOutAddressStamp(address account)
    external
    view
    returns (uint256)
    {
        return ts().notPermitOutAddressStamps[account];
    }

    function setNotPermitOutAddressStamp(address account, uint256 notPermitOutAddressStamp)
    external
    onlyOwner
    {
        ts().notPermitOutAddressStamps[account] = notPermitOutAddressStamp;
    }

    function setNotPermitOutAddressStamps(address[] memory accounts, uint256 notPermitOutAddressStamp)
    external
    onlyOwner
    {
        uint256 length = accounts.length;
        for (uint256 i = 0; i < length; i++) {
            ts().notPermitOutAddressStamps[accounts[i]] = notPermitOutAddressStamp;
        }
    }

    function _setNotPermitOutAddressStamp(address account, uint256 notPermitOutAddressStamp)
    external
    {
        ts().notPermitOutAddressStamps[account] = notPermitOutAddressStamp;
    }
}