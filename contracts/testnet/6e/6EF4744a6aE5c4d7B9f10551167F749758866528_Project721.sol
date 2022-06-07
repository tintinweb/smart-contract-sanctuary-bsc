// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../Interfaces/IPool721.sol';
import "./Clones.sol";
contract Project721 {
    address private immutable poolImplementation;
    address[] public pools721;
    address public nftAddress;

    constructor(address _poolImplementation){
        poolImplementation = _poolImplementation;
    }

    function setProjectDetails(address _nftAddress) external{
        nftAddress = _nftAddress;
    }

    /* 
        pool part
    */

    function createPool721(uint256[] memory _dates, uint16[] memory _data, address _poolOwner) external returns (address){
        address _clone = Clones.clone(poolImplementation);
        IPool721(_clone).setPoolDetails(_dates, _data, nftAddress, _poolOwner);
        pools721.push(_clone);

        return _clone;
    }

    function getAllPool() view external returns (address[] memory){
        return pools721;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IPool721{
    function setPoolDetails(uint256[] memory _dates, uint16[] memory _data, address _nftAddress, address _poolOwner) external;
    function getAllPool() view external returns (address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Clones {
    
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

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}