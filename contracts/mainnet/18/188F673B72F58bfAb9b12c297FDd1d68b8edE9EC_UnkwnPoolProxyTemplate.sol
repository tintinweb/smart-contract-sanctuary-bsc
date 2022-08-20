// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IImplementationSource {
    function implementationAddress() external view returns (address);
}

/**
 * @title UnkwnPoolProxy
 * @author Unknown
 * @notice Minimal non-upgradeable EIP-1967 proxy which reads implementation from an implementation source contract
 * @dev This allows governance to upgrade oxPool implementations
 * @dev When governance is killed oxPool implementations can no longer be upgraded
 */
contract UnkwnPoolProxyTemplate {
    bytes32 constant IMPLEMENTATION_SOURCE_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc; // keccak256('eip1967.proxy.implementation')

    function initialize(address _implementationAddress) external {
        require(
            implementationSourceAddress() == address(0),
            "Already initialized"
        );
        assembly {
            sstore(IMPLEMENTATION_SOURCE_SLOT, _implementationAddress)
        }
    }

    function implementationSourceAddress()
        public
        view
        returns (address _implementationAddress)
    {
        assembly {
            _implementationAddress := sload(IMPLEMENTATION_SOURCE_SLOT)
        }
    }

    fallback() external {
        address implementationAddress = IImplementationSource(
            implementationSourceAddress()
        ).implementationAddress();

        assembly {
            let contractLogic := implementationAddress
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(
                gas(),
                contractLogic,
                0x0,
                calldatasize(),
                0,
                0
            )
            let returnDataSize := returndatasize()
            returndatacopy(0, 0, returnDataSize)
            switch success
            case 0 {
                revert(0, returnDataSize)
            }
            default {
                return(0, returnDataSize)
            }
        }
    }
}