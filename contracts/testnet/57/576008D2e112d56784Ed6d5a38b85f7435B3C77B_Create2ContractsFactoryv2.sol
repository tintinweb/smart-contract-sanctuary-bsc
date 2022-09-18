//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

import "../interfaces/factory/ICreate2ContractsFactory.sol";
import "../libraries/LibCreate2Factory.sol";

contract Create2ContractsFactoryv2 is ICreate2ContractsFactory {
    /**
     * @dev Deploys any contract using create2 asm opcode creating the same address for same bytecode
     * @param bytecode - bytecode packed with params to deploy
     * @param constructorParams - ctor params encoded with abi.encode
     * @param salt - salt required by create2
     */
    function deployCreate2WithParams(
        bytes memory bytecode,
        bytes memory constructorParams,
        bytes32 salt
    ) public virtual override returns (address) {
        return
            LibCreate2Factory.deployCreate2WithParams(
                bytecode,
                constructorParams,
                salt
            );
    }

    /**
     * @dev Deploys any contract using create2 asm opcode creating the same address for same bytecode
     * @param bytecode - bytecode packed with params to deploy
     * @param salt - salt required by create2
     */
    function deployCreate2(bytes memory bytecode, bytes32 salt)
        public
        virtual
        override
        returns (address)
    {
        return LibCreate2Factory.deployCreate2(bytecode, salt);
    }
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

interface ICreate2ContractsFactory {
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
    ) external returns (address);

    function deployCreate2(bytes memory bytecode, bytes32 salt)
        external
        returns (address);
}

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