// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ReentrancyGuard.sol";
import "./SingleCollection.sol";

/**
 * @title SingleUserCollectionFactory
 * @dev Anyone can create a collection from the factory
 */
contract SingleUserCollectionFactory is Ownable, ReentrancyGuard {
    // The rigistry for user's created collections.
    SingleUserCollection[] collections;
    mapping(address => SingleUserCollection[]) collectionByOwner;

    event CreateERC721Factory(
        address indexed creator,
        string name,
        string symbol,
        string contractURI,
        string tokenURIPrefix,
        address indexed collection
    );

    /// @notice The function to create a collection from a factory contract.
    /// @param name - The value for the `name`.
    /// @param symbol - The value for the `symbol`.
    /// @param contractURI - The URI with contract metadata.
    ///        The metadata should be a JSON object with fields: `id, name, description, image, external_link`.
    ///        If the URI containts `{address}` template in its body, then the template must be substituted with the contract address.
    /// @param tokenURIPrefix - The URI prefix for all the tokens. Usually set to ipfs gateway.
    function createCollection(
        string calldata name,
        string calldata symbol,
        string calldata contractURI,
        string calldata tokenURIPrefix
    ) external nonReentrant {
        SingleUserCollection newCollection = new SingleUserCollection(
            name,
            symbol,
            contractURI,
            tokenURIPrefix
        );
        newCollection.addSigner(msg.sender);
        newCollection.transferOwnership(msg.sender);
        collections.push(newCollection);
        collectionByOwner[msg.sender].push(newCollection);
        emit CreateERC721Factory(
            msg.sender,
            name,
            symbol,
            contractURI,
            tokenURIPrefix,
            address(newCollection)
        );
    }

    /// @notice The function to get from the rigistry a list of all collections created by all users.
    function getAllCollections()
        external
        view
        returns (SingleUserCollection[] memory)
    {
        return collections;
    }

    /// @notice The function to get from the rigistry a list of all collections created by a specific user.
    function getCollectionsByAddress(address creator)
        external
        view
        returns (SingleUserCollection[] memory)
    {
        return collectionByOwner[creator];
    }
}