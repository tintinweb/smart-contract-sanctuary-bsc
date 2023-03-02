//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";

contract NFTDatabase is Ownable {

    address[] public allCollections;

    struct Collection {
        uint112 index;
        address implementation;
        address creator;
    }
    mapping ( address => Collection ) public collections;
    mapping ( address => address[] ) public collectionsByOwner;
    mapping ( address => address[] ) public collectionsByImplementation;

    address public generator;
    modifier onlyGenerator {
        require(msg.sender == generator, 'Only Generator');
        _;
    }


    function add(address nft, address implementation, address creator) external onlyGenerator {

        // set collections data
        collections[nft].implementation = implementation;
        collections[nft].index = uint112(allCollections.length);
        collections[nft].creator = creator;

        // map creator to nft
        collectionsByOwner[creator].push(nft);

        // map implementation to nft
        collectionsByImplementation[implementation].push(nft);

        // push to list of collections
        allCollections.push(nft);
    }

    function remove(address nft) external onlyOwner {
        require(
            allCollections[collections[nft].index] == nft,
            'NFT Not Added'
        );
        address lastNFT = allCollections[allCollections.length - 1];
        uint112 rmIndex = collections[nft].index;

        collections[lastNFT].index = rmIndex;
        allCollections[rmIndex] = lastNFT;
        allCollections.pop();

    }

    function viewAllCollections() external view returns (address[] memory) {
        return allCollections;
    }

    function numCollections() external view returns (uint256) {
        return allCollections.length;
    }

    function viewAllCollectionsData() external view returns (address[] memory, address[] memory implementations) {
        uint len = allCollections.length;
        implementations = new address[](len);
        for (uint i = 0; i < len;) {
            implementations[i] = collections[allCollections[i]].implementation;
            unchecked { ++i; }
        }
        return (allCollections, implementations);
    }

    function viewNFTsByImplementation(address implementation) external view returns (address[] memory) {
        return collectionsByImplementation[implementation];
    }

    function viewNFTsByOwner(address creator) external view returns (address[] memory) {
        return collectionsByOwner[creator];
    }

    function owner() external view returns (address) {
        return this.getOwner();
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}