// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library Erc20C12SettingsBaseLibrary {
    struct ThisStorage {
        address contractOwner;
        address addressBaseOwner;
        address addressBaseToken;
        address addressWrap;
        address addressMarketing;
    }

    bytes32 constant tsPosition = keccak256("erc20c12.settings.base");

    // 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    // 115792089237316195423570985008687907853269984665640564039457584007913129639935
    uint256 public constant maxUint256 = type(uint256).max;
    address public constant addressPinkSaleLock = address(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE);
    address public constant addressNull = address(0x0);
    address public constant addressDead = address(0xdead);

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

    function initialize(address addressBaseOwner, address addressBaseToken)
    external
    {
        ts().contractOwner = msg.sender;
        ts().addressBaseOwner = addressBaseOwner;
        ts().addressBaseToken = addressBaseToken;
    }

    function setContractOwner(address contractOwner)
    external
    onlyOwner
    {
        ts().contractOwner = contractOwner;
    }

    function getAddressBaseOwner()
    external
    view
    returns (address)
    {
        return ts().addressBaseOwner;
    }

    function getAddressBaseToken()
    external
    view
    returns (address)
    {
        return ts().addressBaseToken;
    }

    function getAddressWrap()
    external
    view
    returns (address)
    {
        return ts().addressWrap;
    }

    function setAddressWrap(address addressWrap)
    external
    onlyOwner
    {
        ts().addressWrap = addressWrap;
    }

    function getAddressMarketing()
    external
    view
    returns (address)
    {
        return ts().addressMarketing;
    }

    function setAddressMarketing(address addressMarketing)
    external
    onlyOwner
    {
        ts().addressMarketing = addressMarketing;
    }
}