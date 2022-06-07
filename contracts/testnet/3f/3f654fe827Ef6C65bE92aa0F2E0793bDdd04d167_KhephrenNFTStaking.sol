// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../Interfaces/IProject721.sol';
import '../Interfaces/IKhephrenNFTStaking.sol';
import "./Clones.sol";

contract KhephrenNFTStaking is IKhephrenNFTStaking{
    address private immutable projectImplementation;
    address[] public projects721;
    mapping(address => address[]) public mapProject721;

    address private owner;
    uint256 public price;

    modifier onlyOwner(address _caller){
        require(owner == _caller, "Caller is not the owner");
        _;
    }

    constructor(uint256 _price, address _projectImplementation){
        projectImplementation = _projectImplementation;
        _setPlatformInfo(msg.sender, _price);
    }

    // owner function
    function _setPlatformInfo(address _owner, uint256 _price) private{
        owner = _owner;
        price = _price;
    }

    function getBalance() external onlyOwner(msg.sender) view returns (uint256){
        return address(this).balance;
    }

    function withdraw(address _to, uint256 _amount) external onlyOwner(msg.sender){
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(_to).transfer(_amount);
        emit withdrawFund(block.timestamp, _amount);
    }

    /* 
        Project part
    */

    function createProject(address _nftAddress) payable external returns (address){
        address _clone = Clones.clone(projectImplementation);
        IProject721(_clone).setProjectDetails(_nftAddress);
        projects721.push(_clone);
        mapProject721[msg.sender].push(_clone);
        emit projectCreated(msg.sender, _clone, block.timestamp);
        return _clone;
    }

    function getAllProject() view external returns(address[] memory){
        return mapProject721[msg.sender];
    }

}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IProject721{
    function setProjectDetails(address _nftAddress) external;
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IKhephrenNFTStaking{
    event projectCreated(address creator,address project,uint256 time);
    event withdrawFund(uint256 time,uint256 amount);
    event depositFund(uint256 time,uint256 amount);
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