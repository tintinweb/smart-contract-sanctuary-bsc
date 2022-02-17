// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Auth.sol";

contract ShoujoDirectory is Auth {

	address public cryptoShoujo;
	address public shoujoStats;
	address public shoujoBattle;
	address public damageCalc;
	address public shoujoRewards;
	address public shoujoNaming;
	address public randomness;
	address public gacha;

	constructor(
		address _cryptoShoujo, address _shoujoStats, address _shoujoBattle,
		address _damageCalc, address _shoujoRewards, address _shoujoNaming,
		address _randomness, address _gacha
	) Auth(msg.sender) {
		cryptoShoujo = _cryptoShoujo;
		shoujoStats = _shoujoStats;
		shoujoBattle = _shoujoBattle;
		damageCalc = _damageCalc;
		shoujoRewards = _shoujoRewards;
		shoujoNaming = _shoujoNaming;
		randomness = _randomness;
		gacha = _gacha;
	}

	function setCryptoShoujo(address _cryptoShoujo) external authorized {
		cryptoShoujo = _cryptoShoujo;
	}

	function setShoujoStats(address _shoujoStats) external authorized {
		shoujoStats = _shoujoStats;
	}

	function setShoujoBattle(address _shoujoBattle) external authorized {
		shoujoBattle = _shoujoBattle;
	}

	function setDamageCalc(address _damageCalc) external authorized {
		damageCalc = _damageCalc;
	}

	function setShoujoRewards(address _shoujoRewards) external authorized {
		shoujoRewards = _shoujoRewards;
	}

	function setShoujoNaming(address _shoujoNaming) external authorized {
		shoujoNaming = _shoujoNaming;
	}

	function setRandomness(address rand) external authorized {
		randomness = rand;
	}

	function setGacha(address _gacha) external authorized {
		gacha = _gacha;
	}
}