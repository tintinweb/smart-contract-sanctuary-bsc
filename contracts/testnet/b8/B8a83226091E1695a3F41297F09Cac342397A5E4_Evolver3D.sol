// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IPotion3D {
    function consume(uint256 potionId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface IHappyMonkey {
    function setNftLevel(uint256 tokenId, uint256 level) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract Evolver3D {
    address public potion3DCollection;
    address public happyMonkeyCollection;

    constructor(
        address _potion3DCollection,
        address _happyMonkeyCollection
    ) {
        potion3DCollection = _potion3DCollection;
        happyMonkeyCollection = _happyMonkeyCollection;
    }
    
    function evolve(uint256 nftId, uint256 potionId) external {
        require(IPotion3D(potion3DCollection).ownerOf(potionId) == msg.sender, "Potion nft is not owned");
        require(IHappyMonkey(happyMonkeyCollection).ownerOf(nftId) == msg.sender, "Happy monkey nft is not owned");
        IPotion3D(potion3DCollection).consume(potionId);
        IHappyMonkey(happyMonkeyCollection).setNftLevel(nftId, 1);
    }
}