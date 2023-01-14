/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


library StorageSlot {
    function getAddressAt(bytes32 slot) internal view returns (address a) {
        assembly {
            a := sload(slot)
        }
    }

    function setAddressAt(bytes32 slot, address address_) internal {
        assembly {
            sstore(slot, address_)
        }
    }
}
contract Proxy {
    bytes32 private constant _IMPL_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 private constant _ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    constructor (){
        _changeAdmin(getAdmin(), msg.sender);
    }

    event AdminChanged(address previousAdmin, address newAdmin);
    function getAdmin() public view returns (address) {
        return StorageSlot.getAddressAt(_ADMIN_SLOT);
    }
    function setAdmin(address newAdmin) public payable onlyAdmin {
        _changeAdmin(getAdmin(), newAdmin);
    }
    function _changeAdmin(address from, address to) internal{
        emit AdminChanged(from, to);
        StorageSlot.setAddressAt(_ADMIN_SLOT, to);
    }
    modifier onlyAdmin(){
        require(getAdmin() == msg.sender, "Not allowed");
        _;
    }
    function setImplementation(address implementation_) public onlyAdmin {
        StorageSlot.setAddressAt(_IMPL_SLOT, implementation_);
    }
    function getImplementation() public view returns (address) {
        return StorageSlot.getAddressAt(_IMPL_SLOT);
    }
    fallback() external payable {
        _delegate(StorageSlot.getAddressAt(_IMPL_SLOT));
    }
    function _delegate(address impl) internal virtual {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)

            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }
}