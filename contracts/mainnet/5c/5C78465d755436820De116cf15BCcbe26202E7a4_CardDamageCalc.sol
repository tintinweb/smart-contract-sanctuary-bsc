/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

/**
 * Cryptoshoujo damage calculator for card vs card.
 *
 * https://hibiki.finance
 * https://cryptoshoujo.io
 *
 * @hibikifinance - Telegram community
 * @fuwafuwataimu - Dev
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

struct Card {
	uint256 id;
	uint8 rarity;
	uint8 personality;
	uint16 hp;
	uint16 attack;
	uint16 attackModifier;
	uint16 defence;
	uint16 defenceModifier;
	uint16 speed;
}

enum Effectiveness {
	RESISTANT,
	NORMAL,
	EFFECTIVE
}

contract CardDamageCalc {

	/**
	 * @dev Resulting damage from a card attacking another card.
	 * This is the base deterministic damage, which could be then varied with different inputs in different modes.
	 */
	function damageCalculation(Card memory attacker, Card memory defender) external pure returns (uint256) {
		return damageCalculation(
			attacker.attack, attacker.attackModifier, attacker.personality,
			defender.defence, defender.defenceModifier, defender.personality
		);
    }

	function damageCalculation(uint256 attack, uint256 attackMod, uint8 atkType, uint256 def, uint256 defMod, uint8 defType) public pure returns (uint256) {
		Effectiveness typing = typeChart(atkType, defType);
        uint256 kougeki = attack * (attackMod / 2) + 1;
        if (typing == Effectiveness.RESISTANT) {
            kougeki = (kougeki / 2) + 1;
        }
        if (typing == Effectiveness.EFFECTIVE) {
            kougeki *= 2;
        }
		uint256 tate = ((def * (defMod / 2) + 1) / 2) + 1;
		if (tate >= kougeki) {
			return 1;
		}

        return kougeki - tate;
	}

    function typeChart(uint8 type1, uint8 type2) public pure returns (Effectiveness) {
        // Shundere always deals and receives super effective damage.
        if (type1 == 9 || type2 == 9) {
            return Effectiveness.EFFECTIVE;
        }

        // Himedere deals and receives resistant damage from everyone except Shundere.
        if (type1 == 4 || type2 == 4) {
            return Effectiveness.RESISTANT;
        }

        // Tsundere
        if (type1 == 0) {
            // Strong against derere, dandere, kamidere, kuudere
            if (type2 == 2 || type2 == 3 || type2 == 6 || type2 == 7) {
                return Effectiveness.EFFECTIVE;
            }
            // Not very effective against yandere, bakadere, sadodere, tomboy
            if (type2 == 1 || type2 == 5 || type2 == 8 || type2 == 10) {
                return Effectiveness.RESISTANT;
            }
        }

        // Yandere
        if (type1 == 1) {
            // SE against tsundere, deredere, dandere, tomboy
            if (type2 == 0 || type2 == 2 || type2 == 3 || type2 == 10) {
                return Effectiveness.EFFECTIVE;
            }
            // Not ef. against bakadere, kuudere, sadodere, itself
            if (type2 == 5 || type2 == 7 || type2 == 8 || type2 == 1) {
                return Effectiveness.RESISTANT;
            }
        }

        // Deredere
        if (type1 == 2) {
            if (type2 == 7 || type2 == 5 || type2 == 6 || type2 == 8) {
                return Effectiveness.EFFECTIVE;
            }
            if (type2 == 0 || type2 == 1 || type2 == 10 || type2 == 3) {
                return Effectiveness.RESISTANT;
            }
        }

        // Dandere
        if (type1 == 3) {
            if (type2 == 2 || type2 == 5 || type2 == 6 || type2 == 7) {
                return Effectiveness.EFFECTIVE;
            }
            if (type2 == 0 || type2 == 1 || type2 == 10 || type2 == 8) {
                return Effectiveness.RESISTANT;
            }
        }

        // Bakadere
        if (type1 == 5) {
            if (type2 == 10 || type2 == 7 || type2 == 8) {
                return Effectiveness.EFFECTIVE;
            }
            if (type2 == 2 || type2 == 3) {
                return Effectiveness.RESISTANT;
            }
        }

        // Kamidere
        if (type1 == 6) {
            if (type2 == 10 || type2 == 8) {
                return Effectiveness.EFFECTIVE;
            }
            if (type2 == 2 || type2 == 3 || type2 == 0 || type2 == 7) {
                return Effectiveness.RESISTANT;
            }
        }

        // Kuudere
        if (type1 == 7) {
            if (type2 ==  1|| type2 == 6 || type2 == 8) {
                return Effectiveness.EFFECTIVE;
            }
            if (type2 == 0 || type2 == 3 || type2 == 5) {
                return Effectiveness.RESISTANT;
            }
        }

        // Sadodere
        if (type1 == 8) {
            if (type2 == 1 || type2 == 3 || type2 == 10) {
                return Effectiveness.EFFECTIVE;
            }
            if (type2 == 2 || type2 == 5 || type2 == 6 || type2 == 7) {
                return Effectiveness.RESISTANT;
            }
        }

        // Tomboy
        if (type1 == 10) {
            if (type2 == 2 || type2 == 3) {
                return Effectiveness.EFFECTIVE;
            }
            if (type2 == 1 || type2 == 5 || type2 == 6 || type2 == 8) {
                return Effectiveness.RESISTANT;
            }
        }

        // Everything else is normal.
        return Effectiveness.NORMAL;
    }
}