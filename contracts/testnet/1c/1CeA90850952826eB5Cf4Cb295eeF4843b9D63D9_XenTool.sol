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
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
// import "hardhat/console.sol";
interface IXen {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function claimRank(uint256 term) external;
    function claimMintReward() external;
}

contract XenTool  {
    address private owner;
    mapping(address => mapping(uint256 => uint256)) public countMap;
    mapping(address => mapping(uint256 => mapping(uint256 => address))) public addressMap;

    // address xenAddress = 0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e; // bsc
    address public immutable xenAddress;


    constructor(address _xenAddress) {
        owner = msg.sender;
        xenAddress = _xenAddress;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function setOwner(address _owner) internal {
        require(owner == address(0), "owner must 0");
        owner = _owner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    receive() external payable {
        // console.log("receive:", msg.sender, msg.value);
        claimRank(1, 1, owner);
        payable(owner).transfer(msg.value);
    }

    function claimRank(uint256 term, uint256 total) external {
        claimRank(term, total, msg.sender);
    }

    function claimRank(uint256 term, uint256 total, address _owner) internal {
        uint256 oldCount = countMap[_owner][term];
        for (uint256 i = 0; i < total; i++) {
            uint256 index = oldCount + i;
            bytes32 salt = keccak256(abi.encodePacked(_owner, term, index));
            address cloneAddress = Clones.cloneDeterministic(address(this), salt);
            addressMap[_owner][term][index] = cloneAddress;
            XenTool(payable(cloneAddress)).subClaimRank(address(this), term);
            // console.log("sub contract:", cloneAddress, 'owner:', XenTool(payable(cloneAddress)).getOwner());
            countMap[_owner][term]++;
        }
    }


    function subClaimRank(address _owner, uint256 term) external {
        setOwner(_owner);
        IXen(xenAddress).claimRank(term);
    }

    function claimMintReward(uint256 term, uint256[] calldata ids) external {
         for (uint256 i = 0; i < ids.length; i++) {
            address cloneAddress = addressMap[msg.sender][term][ids[i]];
            XenTool(payable(cloneAddress)).subClaimMintReward();
        }
    }

    function subClaimMintReward() external onlyOwner {
        // console.log(address(this), tx.origin, msg.sender, owner);
        IXen(xenAddress).claimMintReward();
        uint256 amount = IXen(xenAddress).balanceOf(address(this));
        IXen(xenAddress).transfer(tx.origin, amount);
    }

}