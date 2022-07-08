/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

/*
 * Waifu stats for MrGreenCrypto.com
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IShoujoStats {
    struct Shoujo {
        uint16 nameIndex;
        uint16 surnameIndex;
        uint8 rarity;
        uint8 personality;
        uint8 cuteness;
        uint8 lewd;
        uint8 intelligence;
        uint8 aggressiveness;
        uint8 talkative;
        uint8 depression;
        uint8 genki;
        uint8 raburabu; 
        uint8 boyish;
    }
    function tokenStatsByIndex(uint256 index) external view returns (Shoujo memory);
}

contract WaifuStats {

	address _shoujoStats = 0x12fDECb39E134BD96fa8E4d0F7Aa31580dC6b641;
    IShoujoStats waifuStats = IShoujoStats(0x12fDECb39E134BD96fa8E4d0F7Aa31580dC6b641);

	constructor(){}

    function checkStats(uint256 waifuIDToCheck) public view returns (uint256,uint256,uint256,uint256,uint256,uint256,uint8[] memory) {
        IShoujoStats.Shoujo memory waifuToCheck = waifuStats.tokenStatsByIndex(waifuIDToCheck);
        return (
            waifuToCheck.rarity, //Rarity 0-4 (5 if you count mythic)
            waifuToCheck.personality, // Personality 0-9
            waifuToCheck.genki + waifuToCheck.aggressiveness + waifuToCheck.boyish + 1, //attack
            (waifuToCheck.aggressiveness + 1) * (waifuToCheck.genki + 1) + waifuToCheck.boyish, // speed
            waifuToCheck.lewd + waifuToCheck.intelligence + waifuToCheck.raburabu + 1, // defense
            10 + waifuToCheck.rarity * 2, // multiplier
            checkEnemies(waifuToCheck.personality)); // 2 = effective attack, 0 = weak attack , 1 = normal attack
    }



    function checkEnemies(uint8 personality) public pure returns (uint8[] memory){
        uint8[] memory stats = new uint8[](11);
        for (uint8 i = 0; i <= 10; i++){
          stats[i] = typeChart(personality, i);
        }
        return stats;
    }


	/**
     * @dev 0 resist 1 normal 2 super effective
     */
    function typeChart(uint8 type1, uint8 type2) public pure returns (uint8) {
        // Shundere deals always super effective damage and receives always super effective damage.
        if (type1 == 9 || type2 == 9) {
            return 2;
        }
        // Himedere deals and receives resistant damage
        if (type1 == 4 || type2 == 4) {
            return 0;
        }
        // Tsundere attacker
        if (type1 == 0) {
            // Strong against derere, dandere, kamidere, kuudere
            if (type2 == 2 || type2 == 3 || type2 == 6 || type2 == 7) {
                return 2;
            }
            // Not very effective against yandere, bakadere, sadodere, tomboy
            if (type2 == 1 || type2 == 5 || type2 == 8 || type2 == 10) {
                return 0;
            }
        }
        // Yandere attacker
        if (type1 == 1) {
            // SE against tsundere, deredere, dandere, tomboy
            if (type2 == 0 || type2 == 2 || type2 == 3 || type2 == 10) {
                return 2;
            }
            // NotE against bakadere, kuudere, sadodere, itself
            if (type2 == 5 || type2 == 7 || type2 == 8 || type2 == 1) {
                return 0;
            }
        }
        // Deredere attacker
        if (type1 == 2) {
            if (type2 == 7 || type2 == 5 || type2 == 6 || type2 == 8) {
                return 2;
            }
            if (type2 == 0 || type2 == 1 || type2 == 10 || type2 == 3) {
                return 0;
            }
        }
        // Dandere attacker
        if (type1 == 3) {
            if (type2 == 2 || type2 == 5 || type2 == 6 || type2 == 7) {
                return 2;
            }
            if (type2 == 0 || type2 == 1 || type2 == 10 || type2 == 8) {
                return 0;
            }
        }
        // Bakadere attacker
        if (type1 == 5) {
            if (type2 == 10 || type2 == 7 || type2 == 8) {
                return 2;
            }
            if (type2 == 2 || type2 == 3) {
                return 0;
            }
        }
        // Kamidere attacker
        if (type1 == 6) {
            if (type2 == 10 || type2 == 8) {
                return 2;
            }
            if (type2 == 2 || type2 == 3 || type2 == 0 || type2 == 7) {
                return 0;
            }
        }
        // Kuudere attacker
        if (type1 == 7) {
            if (type2 ==  1|| type2 == 6 || type2 == 8) {
                return 2;
            }
            if (type2 == 0 || type2 == 3 || type2 == 5) {
                return 0;
            }
        }
        // Sadodere attacker
        if (type1 == 8) {
            if (type2 == 1 || type2 == 3 || type2 == 10) {
                return 2;
            }
            if (type2 == 2 || type2 == 5 || type2 == 6 || type2 == 7) {
                return 0;
            }
        }
        // Tomboy attacker
        if (type1 == 10) {
            if (type2 == 2 || type2 == 3) {
                return 2;
            }
            if (type2 == 1 || type2 == 5 || type2 == 6 || type2 == 8) {
                return 0;
            }
        }

        // All of himedere attacks and defences are always normal effectivity.
        // Rest of attacks.
        return 1;
    }
}