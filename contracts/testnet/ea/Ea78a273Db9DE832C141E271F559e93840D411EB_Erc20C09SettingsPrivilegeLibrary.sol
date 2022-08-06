// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

library Erc20C09SettingsPrivilegeLibrary {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("erc20c09.privilege");

    struct DiamondStorage {
        address contractOwner;
        mapping(address => uint256) privilegeAddressStamps;
    }

    modifier onlyOwner() {
        require(msg.sender == diamondStorage().contractOwner, "Not owner");
        _;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function setContractOwner(address _newOwner) internal {
        DiamondStorage storage ds = diamondStorage();
        emit OwnershipTransferred(ds.contractOwner, _newOwner);
        ds.contractOwner = _newOwner;
    }

    function contractOwner()
    public
    view
    returns
    (address)
    {
        return diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {
        require(msg.sender == diamondStorage().contractOwner, "Not owner");
    }

    function getPrivilegeStamp(address account)
    public
    view
    returns (uint256)
    {
        return diamondStorage().privilegeAddressStamps[account];
    }

    function setPrivilegeStamp(address account, uint256 privilegeStamp)
    public
    onlyOwner
    {
        diamondStorage().privilegeAddressStamps[account] = privilegeStamp;
    }

    function batchSetPrivilegeStamps(address[] memory accounts, uint256 privilegeStamp)
    public
    onlyOwner
    {
        uint256 length = accounts.length;
        for (uint256 i = 0; i < length; i++) {
            diamondStorage().privilegeAddressStamps[accounts[i]] = privilegeStamp;
        }
    }
}