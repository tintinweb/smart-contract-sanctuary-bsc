// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

library Erc20C12SettingsPrivilegeLibrary {
    struct ThisStorage {
        address contractOwner;
        mapping(address => uint256) privilegeAddressStamps;
    }

    bytes32 constant tsPosition = keccak256("erc20c09.settings.privilege");

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

    function initialize()
    external
    {
        ts().contractOwner = msg.sender;
    }

    function getPrivilegeStamp(address account)
    external
    view
    returns (uint256)
    {
        return ts().privilegeAddressStamps[account];
    }

    function setPrivilegeStamp(address account, uint256 privilegeStamp)
    external
    onlyOwner
    {
        ts().privilegeAddressStamps[account] = privilegeStamp;
    }

    function setPrivilegeStamps(address[] memory accounts, uint256 privilegeStamp)
    external
    onlyOwner
    {
        uint256 length = accounts.length;
        for (uint256 i = 0; i < length; i++) {
            ts().privilegeAddressStamps[accounts[i]] = privilegeStamp;
        }
    }
}