// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/ILBlockFactory.sol";

contract LBlockFactoryV3 is ILBlockFactory {
    address private admin;
    address[] private lotteryAddresses;
    mapping(string => address) private originalLotteries;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the owner or admin");
        _;
    }

    constructor(address _admin) {
        require(_admin != address(0x0), "Admin address can't be zero");
        admin = _admin;
    }

    function createLottery(string memory _lotteryVersion)
        external
        onlyAdmin
        returns (address newLotteryAddress)
    {
        require(
            originalLotteries[_lotteryVersion] != address(0x0),
            "Invalid _lotteryVersion value"
        );

        newLotteryAddress = Clones.clone(originalLotteries[_lotteryVersion]);

        lotteryAddresses.push(newLotteryAddress);

        emit LotteryCreated(newLotteryAddress, msg.sender);
    }

    function getLotteryAddresses() external view returns (address[] memory) {
        return lotteryAddresses;
    }

    function addOriginLottery(address _originLottery, string memory _version)
        external
        onlyAdmin
    {
        originalLotteries[_version] = _originLottery;
    }

    function getLastLotteryAddress() external view returns (address) {
        require(lotteryAddresses.length > 0, "No any lottery was found");
        address lastLotteryAddress = lotteryAddresses[
            lotteryAddresses.length - 1
        ];
        return lastLotteryAddress;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

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
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
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
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
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
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/// @title The interface to describe LBlock Factory functions
interface ILBlockFactory {
    /// @notice The event to emmit after a new lottery created
    event LotteryCreated(address lotteryAddress, address owner);

    /// @notice The function to create a new lottery
    /// @param _lotteryVersion The lottery version (implementation version)
    /// @return newLotteryAddress - Address of the new lottery
    /// @dev Technically the creating lottery is a cloning lottery with provided version
    function createLottery(string memory _lotteryVersion)
        external
        returns (address newLotteryAddress);

    /// @notice The function to get array of the lotteries that were created
    /// @return Returns array of all lottery addresses
    function getLotteryAddresses() external view returns (address[] memory);

    /// @notice The function to set new version of a lottery
    /// @param _originLottery Address of the new deployed lottery
    /// @param _version Version of the lottery implementation
    function addOriginLottery(address _originLottery, string memory _version)
        external;

    /// @notice The function to return last lottery address
    function getLastLotteryAddress() external view returns (address);
}