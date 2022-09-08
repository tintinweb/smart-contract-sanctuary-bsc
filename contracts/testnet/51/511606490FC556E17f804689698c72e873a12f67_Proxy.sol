// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;

interface IFundingGetter {
    function fundingModule() external view returns (address);
}

contract Proxy {

    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    modifier authorizedOnly() {
        require(msg.sender == IFundingGetter(implementation()).fundingModule(), "unauthorized caller");
        _;
    }

    constructor(address _perpetual) {
        setImplementation(_perpetual);
    }

    fallback() payable external {
        _call(implementation());
    }

    /**
    * @return impl The Address of the implementation.
    */
    function implementation() public view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    /**
    * @dev Set the Address of the implementation.
    *
    * @param newImplementation Address of implementation.
    */
    function setImplementation(address newImplementation) internal {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }

    /**
    * @dev Delegates execution to an implementation contract.
    * This is a low level function that doesn't return to its internal call site.
    * It will return to the external caller whatever the implementation returns.
    * @param _implementation Address to delegate.
    */
    function _call(address _implementation) internal authorizedOnly {
        uint256 _value = msg.value;
        assembly {
        // Copy msg.data. We take full control of memory in this inline assembly
        // block because it will not return to Solidity code. We overwrite the
        // Solidity scratch pad at memory position 0.
        calldatacopy(0, 0, calldatasize())

        // Call the implementation.
        // out and outsize are 0 because we don't know the size yet.
        // let result := delegatecall(gas, _implementation, 0, calldatasize, 0, 0)
        let result := call(gas(), _implementation, _value, 0, calldatasize(), 0, 0)

        // Copy the returned data.
        returndatacopy(0, 0, returndatasize())

        switch result
        // delegatecall returns 0 on error.
        case 0 { revert(0, returndatasize()) }
        default { return(0, returndatasize()) }
        }
    }
}