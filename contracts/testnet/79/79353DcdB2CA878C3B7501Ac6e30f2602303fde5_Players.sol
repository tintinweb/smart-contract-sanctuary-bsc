// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './IPlayers.sol';
import '../controller/IController.sol';
import '../fcoin/IFCoin.sol';
//import '../races/IRaces.sol';


contract Players is IPlayers
{


struct Player
{
	uint id;
	uint races;
	uint experience;
	uint8 level;
	bool banned;
}


mapping(address => Player) private players;
mapping(uint => address) private playerIdToAddr;
uint public playersCount;

// Modules
IController public immutable CONTROLLER;
IFCoin public FCG;
IFCoin public FCC;
//IRaces public RACES;
bool private _initialized;


event PlayerRegistered(address indexed account);
event PlayerLevelUp(address indexed account, uint level);
event ChallengeComplete(address indexed player);
event RaceComplete(address indexed player, uint place);


constructor(address controller_)
{
	CONTROLLER = IController(controller_);
}

function init() external
{
	require(!_initialized, 'Players: initialized');

	FCG = IFCoin(CONTROLLER.aFCG());
	FCC = IFCoin(CONTROLLER.aFCC());
	//RACES = IRaces(CONTROLLER.aRaces());

	_initialized = true;
}


function getPlayer(address account) external view returns(Player memory)
{ return players[account]; }

function getPlayerAddressById(uint playerId) external view returns(address)
{ return playerIdToAddr[playerId]; }

function getPlayerById(uint playerId) external view returns(Player memory)
{ return players[playerIdToAddr[playerId]]; }



function registerNewPlayer(address account, uint fccAmount) external
{
	CONTROLLER.onlyDispatcher(msg.sender);
	require(account != address(0), 'Players: invalid address');

	Player storage player = players[account];
	require(player.id == 0, 'Players: already');

	player.id = ++playersCount;
	player.level = 1;
	playerIdToAddr[playersCount] = account;

	if (fccAmount > 0) FCC.fcMint(account, fccAmount);

	emit PlayerRegistered(account);
}

function raceComplete(address account, uint expAmount, uint fccAmount, uint fcgAmount, uint place) external
{
	CONTROLLER.onlyDispatcher(msg.sender);

	Player storage player = players[account];
	require(player.id > 0, 'Players: not exist');

	player.races++;

	if (fccAmount > 0) FCC.fcMint(account, fccAmount);
	if (fcgAmount > 0) FCG.fcMint(account, fcgAmount);

	if (expAmount > 0)
	{
		player.experience += expAmount;
		uint newLvl = _getLevelByExperience(player.experience);

		if (newLvl > player.level)
		{
			player.level = uint8(newLvl);
			emit PlayerLevelUp(account, player.level);
		}
	}
	
	emit RaceComplete(account, place);
}
/*function raceFinished(address account, uint exp) external
{
	require(msg.sender == address(RACES), 'Players: not allowed');

	Player storage player = players[account];
	require(player.id > 0, 'Players: not exist');

	// No need to add
	//if (player.level >= 5) return;

	player.races++;
	player.experience += exp;
	uint newLvl = _getLevelByExperience(player.experience);

	if (newLvl > player.level)
	{
		player.level = uint8(newLvl);
		emit PlayerLevelUp(account, player.level);
	}
}*/

function _getLevelByExperience(uint exp) private pure returns(uint)
{
	if (exp < 3000) return 1; // 3000 to 2
	if (exp < 12300) return 2; // 9300 to 3
	if (exp < 41200) return 3; // 28900 to 4
	if (exp < 130700) return 4; // 89500 to 5
	return 5;
}

function challengeComplete(address player, uint fccAmount, uint fcgAmount) external
{
	CONTROLLER.onlyDispatcher(msg.sender);
	require(players[player].id > 0, 'Players: not registered');

	if (fccAmount > 0) FCC.fcMint(player, fccAmount);
	if (fcgAmount > 0) FCG.fcMint(player, fcgAmount);

	emit ChallengeComplete(player);
}

function exchangeFccToFcg(address player, uint fccAmount, uint fcgAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	require(CONTROLLER.fccToFcgExchangeEnabled(), 'Players: disabled');
	require(fccAmount > 0 && fcgAmount > 0 && fccAmount > fcgAmount, 'Players: invalid amounts');

	FCC.fcBurn(player, fccAmount);
	FCG.fcMint(player, fcgAmount);
}

function exchangeFcgToFcc(address player, uint fcgAmount, uint fccAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	require(CONTROLLER.fcgToFccExchangeEnabled(), 'Players: disabled');
	require(fcgAmount > 0 && fccAmount > 0 && fcgAmount < fccAmount, 'Players: invalid amounts');

	FCG.fcBurn(player, fcgAmount);
	FCC.fcMint(player, fccAmount);
}


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IFCoin
{
	function fcMint(address to, uint amount) external;
	function fcBurn(address from, uint amount) external;
	function fcTransfer(address from, address to, uint amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IController
{
	function aFCG() external view returns(address);
	function aFCC() external view returns(address);
	function aPlayers() external view returns(address);
	function aCars() external view returns(address);
	//function aRaces() external view returns(address);

	function isOwner(address account) external view returns(bool);
	function isAdmin(address account) external view returns(bool);
	//function isModer(address account) external view returns(bool);
	function isDispatcher(address account) external view returns(bool);
	function isRelayer(address account) external view returns(bool);

	function onlyDispatcher(address account) external view;
	function onlyRelayer(address account) external view;

	function fccToFcgExchangeEnabled() external view returns(bool);
	function fcgToFccExchangeEnabled() external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IPlayers
{
	//function raceFinished(address account, uint value) external;
}