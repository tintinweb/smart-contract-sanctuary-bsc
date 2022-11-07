/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

/**
 * Stats interface so the madlads nft project can play in Cryptoshoujo modes.
 * https://cryptoshoujo.io
 * https://hibiki.finance
 * Telegram community in @hibikifinance
 * You can consult about any of these contracts or tools to the dev @fuwafuwataimu there.
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * Since structs are packed in storage but we don't fill the next slot anyway,
 * we use bigger numbers than we need in case we need to adapt the card usage
 * with different interfaces or collections.
 * Comments include the regular Cryptoshoujo value ranges when represented as a Card.
 */
struct Card {
	uint256 id;
	uint8 rarity; // 0-5
	uint8 personality; // Typing for battle effectiveness, CS has 11 types so 0-10.
	uint16 hp; // 100-150
	uint16 attack; // 1-31
	uint16 attackModifier; // 9-21
	uint16 defence; // 1-31
	uint16 defenceModifier; // 8-22
	uint16 speed; // 1-32
}

interface PlayableCard {
	function getCardStats(uint256 id) external view returns (Card memory);
	function canFight(uint256 id) external view returns (bool);
}

contract MadladsShoujoStats is PlayableCard {

	function getCardStats(uint256 id) external pure returns (Card memory) {
		uint8 rarity = getRarity(id);
		return Card(
			id,
			rarity,
			getPersonalityWithRarity(id, rarity),
			getHp(rarity),
			getAttack(id),
			getAttackModifier(id),
			getDefence(id),
			getDefenceModifier(id),
			getSpeedWithRarity(id, rarity)
		);
	}

	function canFight(uint256 id) external pure returns (bool) {
		return id < 4439;
	}

	function getPersonality(uint256 id) external pure returns(uint8) {
		return getPersonalityWithRarity(id, getRarity(id));
	}

	function getPersonalityWithRarity(uint256 id, uint8 rarity) public pure returns(uint8) {
		if (rarity == 0) {
			if (id & 1 == 0) {
				return 2;
			}
			if (id % 3 == 0) {
				return 0;
			}
			return 1;
		}
		return uint8(id % 11);
	}

	function getRarity(uint256 id) public pure returns (uint8) {
		// Anything above here is common or does not exist.
		if (id > 4437) {
			return 0;
		}
		// Skipping loading the rarities for the following IDs on the first 60.
		// This is faster since 0-16 are legendary, 17-48 epic, and besides
		// the pointed exceptions the rest are common.
		if (id == 49 || id == 59) {
			return 2;
		}
		if (id < 17) {
			return 4;
		}
		if (id < 49) {
			return 3;
		}
		if (id < 61) {
			return 0;
		}
		// We do not pack legendaries as it would cost an extra bit, so they are handled here.
		if (isLegendary(id) == 1) {
			return 4;
		}
		// Get the rarity from the packed data.
		return getRarityFromOffsetId(id - 61);
	}

	/**
	 * @dev There is a supply of 4,438 that can participate, IDs are 0 to 4437.
	 * The parameter must be ID - 61, as the stored packed rarities start from ID 61.
	 * This means there's 4,377 non-legendary rarities managed in-memory.
	 * There are 35 uint256 numbers holding all rarities, indexed from 0 to 34.
	 * Each one contains 128 rarities held in pairs of 2 bits.
	 * The uint256 to load is picked from an index.
	 */
	function getRarityFromOffsetId(uint256 id) internal pure returns (uint8) {
		// Gives 0 to 34 to access the proper uint256 holding the rarity.
		// This is because each entry holds 128 rarities in 256 bits, so the ids are in groups of 128.
		uint256 entryIndex = id / 128;
		uint256 entry = getPackedRarities(entryIndex);
		// Get the position of the 2 relevant bits in the uint256 with mod 128,
		// since each entry stores 128 rarities. Then multiply by 2 since each pair of bits has one rarity.
		uint256 position = (id % 128) * 2;
		// Using a mask and logical AND, shift the 2 relevant bits towards the rightmost position to get the value.
		// Logical AND discards all bits but the content of the last 2, which is what we want.
		// The mask contains a 0 for all but the 2 bits we want, so only those are preserved.
		uint256 mask = 3;
		uint256 realValue = mask & (entry >> position);

		return uint8(realValue);
	}

	/**
	 * @notice Ids below 100 are ignored here and should be managed on the proper place in getRarity.
	 */
	function isLegendary(uint256 id) internal pure returns (uint256) {
		if (
			id == 182 || id == 199 || id == 241 || id == 397 || id == 502 || id == 874
			|| id == 1153 || id == 1287 || id == 1399 || id == 1420 || id == 1433 || id == 1582
			|| id == 1930 || id == 1973 || id == 1992 || id == 2038 || id == 2366 || id == 2443
			|| id == 2468 || id == 2526 || id == 2605 || id == 2843 || id == 2908 || id == 3329
			|| id == 3330 || id == 3357 || id == 3405 || id == 3528 || id == 3842 || id == 3921
			|| id == 4029 || id == 4068 || id == 4345
		) {
			return 1;
		}
		return 0;
	}

	/**
	 * @dev We load a single uint256 depending on where the rarity we want is stored in.
	 * This is more cost effective both for deploying and getting the data from another contract.
	 */
	function getPackedRarities(uint256 index) internal pure returns (uint256) {
		if (index == 0) {
			return 0x45e010b04000018cd43c4715301070109a6a17640850010c5241d050920c0c1;
		}
		if (index == 1) {
			return 0x4b008470472fc0c244005900010a81d00742cfd4014e04180048491501304040;
		}
		if (index == 2) {
			return 0x5841800401145146c400c077cfe4bf7842a0b053322020704000a211481d9801;
		}
		if (index == 3) {
			return 0x442401305824149e141804c60040650365c502203aa0d018519500560540094;
		}
		if (index == 4) {
			return 0x3b5927504d00a12144000e029ee601ddc2818810180003c840070400024c804b;
		}
		if (index == 5) {
			return 0xc4101700a0484031819c0000a4c044000a110a10b1408067411620482110004c;
		}
		if (index == 6) {
			return 0x2c1600582346804197344561000244c4a0dc10201f8124801204040060841c44;
		}
		if (index == 7) {
			return 0x341913357f00ca54c9450b10cc3442750490214928180014491c188004040429;
		}
		if (index == 8) {
			return 0x42844644148310d057066558d013033148229000400038088224030442234121;
		}
		if (index == 9) {
			return 0xc883f03411445081612084d0267890640c505103934c58018504000c00098500;
		}
		if (index == 10) {
			return 0x5781415c400d9000470531ccc454401850750105000080084014100010103054;
		}
		if (index == 11) {
			return 0x5021720f00520540434304044400511021409047560df207d1d6e413441d1592;
		}
		if (index == 12) {
			return 0x50822911031014358c91915099c010949748b1703a49310420c080685020201;
		}
		if (index == 13) {
			return 0x61095082a0c05a41c50059000712155048b413c3111c012b004042100410c007;
		}
		if (index == 14) {
			return 0x8557c4220454220c162f44553cd9649004f0048e4605aad3101420c177049100;
		}
		if (index == 15) {
			return 0x7542213a551e00000430a06d020810114c8d326018114d18a0601105c8cb459a;
		}
		if (index == 16) {
			return 0x17184205226954474c4112414306a10fe034002155880c009454642e0099c040;
		}
		if (index == 17) {
			return 0x8059814080f601c5414410280b2701042d9001a0e0101142800310d009020000;
		}
		if (index == 18) {
			return 0xc05308134040e490d011001371c44048008500c4020108040883210044c5510c;
		}
		if (index == 19) {
			return 0xb02524e33050415422435408d4225192200d51821092820d2043444100106c01;
		}
		if (index == 20) {
			return 0x22aa8024c41114c9d100409c144444c0030410554000801020407f1674406029;
		}
		if (index == 21) {
			return 0x31c1d0001051040431741a24152050001449010014083a230400040800310010;
		}
		if (index == 22) {
			return 0x31b004104080240428601414013470251b1c45001550750cb0c805141410b13;
		}
		if (index == 23) {
			return 0xc0ec25045083400401021119001b40052082405010ab11141001b1e0c3382a61;
		}
		if (index == 24) {
			return 0x44406162d10121a4ac4980014000823685801311440570209900f965548810e;
		}
		if (index == 25) {
			return 0x46150809238504536051409455065f4940105bc05a7010250530046500201104;
		}
		if (index == 26) {
			return 0xcc014500070d0367000451c8004804a00009088004355883658946470104c115;
		}
		if (index == 27) {
			return 0x1404c4010210870015180808468d001443001314041110a930d0c7701ad00104;
		}
		if (index == 28) {
			return 0x2c04484090e900008c0442072010897820010100041c4035005104c000180848;
		}
		if (index == 29) {
			return 0x50100112294125020831112420110d03004580500610429043210a14d0913150;
		}
		if (index == 30) {
			return 0x44c04d50090a84014c38460c820000010053144528604185443bf8054008240;
		}
		if (index == 31) {
			return 0x370320c092a0a02844054c169271899b04300910e40d04009509400621001c7;
		}
		if (index == 32) {
			return 0x2800592080ac000185180803691d01104520428a0004430500751c2141144714;
		}
		if (index == 33) {
			return 0x140558124018a0317572744281c904e85310503c1409040c610b1050041c0b06;
		}
		if (index == 34) {
			return 0x200c5810f24a4;
		}
		return 0;
	}

	function getHp(uint8 rarity) public pure returns (uint16) {
		return 100 + rarity * 10;
	}

	function getSpeed(uint256 id) external pure returns (uint8) {
		return getSpeedWithRarity(id, getRarity(id));
	}

	function getSpeedWithRarity(uint256 id, uint8 rarity) public pure returns (uint8) {
		return rarity * 10 + uint8(id % 50);
	}

	function getAttack(uint256 id) public pure returns (uint16) {
		return uint16(id % 31) + 1;
	}

	function getDefence(uint256 id) public pure returns (uint16) {
		return uint16(~id % 31) + 1;
	}

	function getAttackModifier(uint256 id) public pure returns (uint8) {
		return uint8(id % 13) + 9;
	}

	function getDefenceModifier(uint256 id) public pure returns (uint8) {
		return uint8(~id % 14) + 8;
	}
}