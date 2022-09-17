//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

library LibCreate2Factory {
    event NewContractDeployed(
        address indexed contractAddress,
        bytes bytecode,
        bytes constructorParams,
        bytes32 salt
    );

    function deployCreate2WithParams(
        bytes memory bytecode,
        bytes memory constructorParams,
        bytes32 salt
    ) public returns (address) {
        address newContract = _deployCreate2(
            abi.encodePacked(bytecode, constructorParams),
            salt
        );

        emit NewContractDeployed(
            newContract,
            bytecode,
            constructorParams,
            salt
        );

        return newContract;
    }

    function _deployCreate2(bytes memory bytecode, bytes32 salt)
        public
        returns (address)
    {
        address newContract;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            newContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        require(_isContract(newContract), "Deploy failed");

        return newContract;
    }

    function deployCreate2(bytes memory bytecode, bytes32 salt)
        external
        returns (address)
    {
        return deployCreate2WithParams(bytecode, "", salt);
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}