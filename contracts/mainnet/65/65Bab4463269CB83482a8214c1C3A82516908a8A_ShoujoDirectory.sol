/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract ShoujoDirectory is Auth {

	address public cryptoShoujo;
	address public shoujoStats;
	address public shoujoBattle;
	address public damageCalc;
	address public shoujoRewards;
	address public shoujoNaming;
	address public randomness;
	address public gacha;
	address public raid;

	constructor(
		address _cryptoShoujo, address _shoujoStats, address _shoujoBattle,
		address _damageCalc, address _shoujoRewards, address _shoujoNaming,
		address _randomness, address _gacha, address _raid
	) Auth(msg.sender) {
		cryptoShoujo = _cryptoShoujo;
		shoujoStats = _shoujoStats;
		shoujoBattle = _shoujoBattle;
		damageCalc = _damageCalc;
		shoujoRewards = _shoujoRewards;
		shoujoNaming = _shoujoNaming;
		randomness = _randomness;
		gacha = _gacha;
		raid = _raid;
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

	function setRaid(address _raid) external authorized {
		raid = _raid;
	}
}