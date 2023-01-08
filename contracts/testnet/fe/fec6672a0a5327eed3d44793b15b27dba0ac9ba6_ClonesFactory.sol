// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";
import {IToken} from "./interfaces/IToken.sol";
import {IClonesFactory} from "./interfaces/IClonesFactory.sol";

/// @title ClonesFactory
/// @dev factory contract to create immutable clones using minimal proxy contracts, also known as "clones"
/// https://eips.ethereum.org/EIPS/eip-1167
contract ClonesFactory is IClonesFactory {
    address private immutable _implementation;

    /// @dev clone name --> clone address
    mapping(bytes32 => address) private _clones;

    /// @param _impl: address of implementation by which new clones will be created
    /// @dev Reverts if impl address is zero address
    /// @dev Reverts if impl address is not a contract
    constructor(address _impl) {
        if (_impl == address(0)) {
            revert ImplementationIsAddressZero();
        }
        assembly {
            if eq(extcodesize(_impl), 0x00) {
                // 0xe84f0f99 = bytes4(keccak256("ImplementationIsNotContract()"))
                mstore(0x00, shl(0xe0, 0xe84f0f99))
                revert(0x00, 0x04)
            }
        }
        _implementation = _impl;
    }

    /// @notice Get the address of an implementation
    function implementation() external view returns (address implementation_) {
        implementation_ = _implementation;
    }

    /// @notice Get a clone's address by name
    /// @param _name: clone name
    /// @dev Can return a zero address if a clone with that name is not in the mapping
    function getClone(string calldata _name)
        external
        view
        returns (address clone_)
    {
        bytes32 name = bytes32(bytes(_name));
        clone_ = _clones[name];
    }

    /// @notice Creating a new clone using the `CREATE` opcode
    /// @param _name: name of a new clone/token
    /// @param _symbol: symbol of a new token
    /// @dev Reverts if a clone with that name is already exists in the mapping
    function createClone(string calldata _name, string calldata _symbol)
        external
    {
        bytes32 name = bytes32(bytes(_name));
        if (_clones[name] != address(0)) {
            revert CloneAlreadyExists();
        }
        address newClone = Clones.clone(_implementation);
        _clones[name] = newClone;
        IToken(newClone).initialize(_name, _symbol);
        IToken(newClone).transferOwnership(msg.sender);

        emit CloneCreated(newClone, msg.sender, _name);
    }

    /// @notice Creating a new clone using the `CREATE2` opcode by salt
    /// @param _name: the name of the new clone/token
    /// @param _symbol: symbol of a new token
    /// @param salt: unique parameter for assigning an address via CREATE2 deployment
    /// @dev Reverts if a clone with that name is already exists in the mapping
    function createCloneDeterministic(
        string calldata _name,
        string calldata _symbol,
        bytes32 salt
    ) external {
        bytes32 name = bytes32(bytes(_name));
        if (_clones[name] != address(0)) {
            revert CloneAlreadyExists();
        }
        address newClone = Clones.cloneDeterministic(_implementation, salt);
        _clones[name] = newClone;
        IToken(newClone).initialize(_name, _symbol);
        IToken(newClone).transferOwnership(msg.sender);

        emit CloneCreated(newClone, msg.sender, _name);
    }

    /// @notice Get address of clone by salt without deploy
    /// @param salt: unique parameter for assigning an address
    function predictCloneAddress(bytes32 salt)
        external
        view
        returns (address predict_)
    {
        predict_ = Clones.predictDeterministicAddress(_implementation, salt);
    }

    /// @notice Remove a clone address from mapping by its name
    /// @param _name: name of a clone
    /// @dev Reverts if a clone owner not a msg.sender
    /// @dev Reverts if a clone address in mapping is a zero address
    function deleteClone(string calldata _name) external {
        bytes32 name = bytes32(bytes(_name));
        address clone = _clones[name];
        if (IToken(clone).owner() != msg.sender) {
            revert CallerIsNotCloneOwner();
        }
        _clones[name] = address(0);

        emit CloneDeleted(clone, msg.sender, _name);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IClonesFactory {
    /// @notice Emitted when a new clone is created
    /// @param clone: address
    /// @param owner: clone owner
    /// @param name: clone name
    event CloneCreated(
        address indexed clone,
        address indexed owner,
        string name
    );

    /// @notice Emitted when a clone is deleted
    /// @param clone: address
    /// @param owner: clone owner
    /// @param name: clone name
    event CloneDeleted(
        address indexed clone,
        address indexed owner,
        string name
    );

    error ImplementationIsAddressZero();
    error ImplementationIsNotContract();
    error CloneAlreadyExists();
    error CallerIsNotCloneOwner();
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IToken {
    function initialize(string calldata name, string calldata symbol) external;

    function transferOwnership(address newOwner) external;

    function owner() external view returns (address);
}