// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Auth.sol";

enum ItemType {
    POTION,
    WEAPON,
    SHIELD,
    ARMOR,
    LEGS,
    HELMET,
    NECKLACE,
    BOOTS,
    TRINKET,
    RING,
    MATERIAL
}

struct Item {
    uint16 id;
    string name;
    uint8 typ;
}

contract ItemData is Auth {

    mapping (uint16 => Item) public items;
    mapping (uint16 => mapping (uint16 => uint16)) public itemStats;

    constructor() Auth(msg.sender) {
        setItem(1, "Plot Armor", uint8(ItemType.ARMOR));
    }

    function setItem(uint16 id, string memory name, uint8 typing) public authorized {
        items[id] = Item(id, name, typing);
    }

    function getItem(uint16 spellId) public view returns(Item memory) {
        return items[spellId];
    }

    function setItemStat(uint16 itemId, uint16 statId, uint16 statValue) external authorized {
        itemStats[itemId][statId] = statValue;
    }

    function getItemStat(uint16 itemId, uint16 statId) public view returns (uint16) {
        return itemStats[itemId][statId];
    }
}