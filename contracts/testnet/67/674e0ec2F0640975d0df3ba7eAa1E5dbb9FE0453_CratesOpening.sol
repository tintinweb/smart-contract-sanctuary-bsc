// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface Crates {
    function ownerOf(uint tokenId) external returns (address);
    function transferFrom(address from, address to, uint tokenId) external;
}

interface Items {
    function mint(address user) external returns (uint);
}

contract CratesOpening {
    Crates public immutable crates;
    Items public immutable items;

    string public name;
    
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    mapping(uint => uint) public itemIdToCrateId;

    constructor(string memory name_, Crates crates_, Items items_) {
        name = name_;
        crates = crates_;
        items = items_;
    }

    /**
     * @notice Opens crates.
     * @param crateIds user crate ids to open.
     */
    function openCrates(uint[] calldata crateIds) external {
          for (uint i = 0; i < crateIds.length; i++) {
            uint crateId = crateIds[i];
            require(crates.ownerOf(crateId) == msg.sender, "sender isn't the owner");

            crates.transferFrom(msg.sender, BURN_ADDRESS, crateId);
            uint itemId = items.mint(msg.sender);

            itemIdToCrateId[itemId] = crateId;

            emit CrateOpened(msg.sender, crateId, itemId);
        }
    }

    event CrateOpened(address indexed user, uint crateId, uint itemId);
}