// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Auth.sol";

enum Stats {
    HP,
    MP,
    LEVEL,
    EXPERIENCE,
    STRENGTH,
    INTELLIGENCE,
    WISDOM,
    AGILITY,
    SPEED,
    CHANCE
}

enum Vocation {
    MAGE,
    KNIGHT,
    PALADIN,
    ARCHER
}

contract MidknightsStats is Auth {

    mapping (uint256 => mapping (uint16 => uint16)) public stats;
    mapping (uint8 => uint16) public hpPerLevel;
    mapping (uint8 => uint16) public mpPerLevel;
    mapping (uint8 => uint16) public strPerLevel;
    mapping (uint8 => uint16) public intPerLevel;
    mapping (uint8 => uint16) public agiPerLevel;

    constructor() Auth(msg.sender) {
        // Health
        hpPerLevel[uint8(Vocation.MAGE)] = 5;
        hpPerLevel[uint8(Vocation.KNIGHT)] = 15;
        hpPerLevel[uint8(Vocation.PALADIN)] = 10;
        hpPerLevel[uint8(Vocation.ARCHER)] = 8;
        // Mana
        mpPerLevel[uint8(Vocation.MAGE)] = 15;
        mpPerLevel[uint8(Vocation.KNIGHT)] = 5;
        mpPerLevel[uint8(Vocation.PALADIN)] = 10;
        mpPerLevel[uint8(Vocation.ARCHER)] = 12;
        // Strength
        strPerLevel[uint8(Vocation.MAGE)] = 1;
        strPerLevel[uint8(Vocation.KNIGHT)] = 9;
        strPerLevel[uint8(Vocation.PALADIN)] = 4;
        strPerLevel[uint8(Vocation.ARCHER)] = 3;
        // Intelligence
        intPerLevel[uint8(Vocation.MAGE)] = 9;
        intPerLevel[uint8(Vocation.KNIGHT)] = 1;
        intPerLevel[uint8(Vocation.PALADIN)] = 4;
        intPerLevel[uint8(Vocation.ARCHER)] = 1;
        // Agility
        agiPerLevel[uint8(Vocation.MAGE)] = 0;
        agiPerLevel[uint8(Vocation.KNIGHT)] = 0;
        agiPerLevel[uint8(Vocation.PALADIN)] = 2;
        agiPerLevel[uint8(Vocation.ARCHER)] = 6;
        // Rest of stats do not go up by level. 
    }

    function setStat(uint256 charId, uint16 stat, uint16 value) external authorized {
        stats[charId][stat] = value;
    }

    function getStat(uint256 charId, uint16 stat) external view returns (uint16) {
        return stats[charId][stat];
    }

    function getBaseHp(uint8 vocation, uint8 level) external view returns (uint16) {
        if (level == 1) {
            return 10;
        }
        return 10 + hpPerLevel[vocation] * level;
    }

    function getBaseMp(uint8 vocation, uint8 level) external view returns (uint16) {
        if (level == 1) {
            return 5;
        }
        return 5 + mpPerLevel[vocation] * level;
    }

    function getBaseStr(uint8 vocation, uint8 level) external view returns (uint16) {
        if (level == 1) {
            return 1;
        }
        return 1 + strPerLevel[vocation] * level;
    }

    function getBaseAgi(uint8 vocation, uint8 level) external view returns (uint16) {
        if (level == 1) {
            return 1;
        }
        return 1 + agiPerLevel[vocation] * level;
    }

    function getBaseInt(uint8 vocation, uint8 level) external view returns (uint16) {
        if (level == 1) {
            return 1;
        }
        return 1 + intPerLevel[vocation] * level;
    }
}