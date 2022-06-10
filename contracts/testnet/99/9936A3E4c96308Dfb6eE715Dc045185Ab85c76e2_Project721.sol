// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../Interfaces/IPool721.sol';
import '../Interfaces/IProject721.sol';
import "./Clones.sol";

contract Project721 is IProject721{
    address private immutable poolImplementation;
    address[] private pools721;
    address private nftAddress;
    address private setterAddress;
    address private project721Owner;

    /*
        events
    */
    event createPool721EVT(address owner, address poolAddress, uint256 time);

    constructor(address _poolImplementation){
        poolImplementation = _poolImplementation;
    }

    function setSetterAddress(address _setter) virtual override external{
        require(setterAddress == address(0),"Project721: Setter already set");
        setterAddress = _setter;
    }

    function setPoolAddress(address poolAddress) external{
        IPool721(poolAddress).setSetterAddress(address(this));
    }

    function setProjectDetails(address _nftAddress, address _project721Owner) external virtual override{
        require(setterAddress == msg.sender, "Project721: Caller is not a setter");
        require(project721Owner == address(0), "Project721: Pool already initialize");

        nftAddress = _nftAddress;
        project721Owner = _project721Owner;
    }

    /* 
        pool part
    */

    function createPool721(uint256[] memory _dates, uint16[] memory _data) external virtual override returns (address){
        address _clone = Clones.clone(poolImplementation);
        IPool721(_clone).setPoolDetails(_dates, _data, nftAddress, msg.sender);
        pools721.push(_clone);
        emit createPool721EVT(msg.sender, _clone, block.timestamp);
        return _clone;
    }

    function getAllPool() view external virtual override returns (address[] memory){
        return pools721;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IPool721{
    function setPoolDetails(uint256[] memory _dates, uint16[] memory _data, address _nftAddress, address _poolOwner) external;
    function setSetterAddress(address _setter) external;
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IProject721{
    function setProjectDetails(address _nftAddress, address _project721Owner) external;
    function createPool721(uint256[] memory _dates, uint16[] memory _data) external returns (address);
    function getAllPool() view external returns (address[] memory);
    function setSetterAddress(address _setter) external;
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