/**
 *Submitted for verification at BscScan.com on 2022-11-07
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

interface PlayableCard {
	function getCardStats(uint256 id) external view returns (Card memory);
	function canFight(uint256 id) external view returns (bool);
}

contract CatnipShoujoStats is PlayableCard {

	mapping (uint256 => bool) public isAllowed;
	mapping (uint256 => Card) public stats;

	constructor() {
		// Catnip Matsuri Hibiki IDs
		uint256[58] memory ids = [
			uint256(3712), 3713, 3715, 3716, 3721, 3722, 3723,
			3724, 3725, 3726, 3727, 3728, 3729, 3730,
			3731, 3732, 3733, 3734, 3735, 3736, 3737,
			3738, 3739, 3740, 3741, 3742, 3743, 3766,
			3767, 3768, 3769, 3770, 3771, 3772, 3773,
			3774, 3775, 3776, 3777, 3778, 3779, 3780,
			3781, 3782, 3783, 3784, 3785, 3786, 3787,
			3788, 3789, 3790, 3800, 3801, 3802, 4161,
			5561, 5731
		];
		for (uint256 i = 0; i < ids.length; i++) {
			isAllowed[ids[i]] = true;
		}
		_setupCards();
	}

	function getCardStats(uint256 id) external view returns (Card memory) {
		return stats[id];
	}

	function canFight(uint256 id) external view returns (bool) {
		return isAllowed[id];
	}

	function _setupCards() internal {
		// Animated
		uint256[25] memory animated = [
			uint256(3715), 3716, 3721, 3722, 3723, 3724,
			3725, 3726, 3727, 3728, 3729, 3730, 3731,
			3732, 3733, 3734, 3735, 3736, 3737, 3738,
			3739, 3740, 3741, 3742, 3743
		];
		uint256[33] memory statics = [
			uint256(3712), 3713, 3766, 3767, 3768, 3769,
			3770, 3771, 3772, 3773, 3774, 3775, 3776,
			3777, 3778, 3779, 3780, 3781, 3782, 3783,
			3784, 3785, 3786, 3787, 3788, 3789, 3790,
			3800, 3801, 3802, 4161, 5561, 5731
		];
		// Animated have a spread 7 stats
		for (uint256 i = 0; i < animated.length; i++) {
			stats[animated[i]] = Card(
				animated[i], 4, uint8(animated[i] % 11), 140, 22, 19, 22, 20, 71
			);
		}
		// Static have 7 and 6 stats spread
		for (uint256 i = 0; i < statics.length; i++) {
			stats[statics[i]] = Card(
				statics[i], 4, uint8(statics[i] % 11), 140, 21, 19, 20, 20, 56
			);
		}
	}
}