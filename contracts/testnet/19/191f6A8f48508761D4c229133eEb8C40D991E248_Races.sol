// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './IRaces.sol';
import '../controller/IController.sol';
import '../fcoin/IFCoin.sol';
import '../players/IPlayers.sol';


contract Races is IRaces
{


uint public raceCounter;

IController public immutable CONTROLLER;
IFCoin public FCG;
IFCoin public FCC;
IPlayers public PLAYERS;
bool private _initialized;


event RaceCompleted(uint raceNumber);


constructor(address controller_)
{
	CONTROLLER = IController(controller_);
}

function init() external
{
	require(!_initialized, 'Players: initialized');

	FCG = IFCoin(CONTROLLER.aFCG());
	FCC = IFCoin(CONTROLLER.aFCC());
	PLAYERS = IPlayers(CONTROLLER.aPlayers());

	_initialized = true;
}


function raceComplete(
	address[] memory players,
	uint[] memory exps,
	uint[] memory fccs,
	uint[] memory fcgs
) external
{
	CONTROLLER.onlyDispatcher(msg.sender);
	require(players.length > 0 && players.length == exps.length
		&& exps.length == fccs.length && fccs.length == fcgs.length, 'Races: invalid arrays');

	for (uint i; i < players.length; i++)
	{
		address player = players[i];
		require(player != address(0), 'Races: invalid address');

		if (exps[i] > 0) PLAYERS.raceFinished(player, exps[i]);
		if (fccs[i] > 0) FCC.fcMint(player, fccs[i]);
		if (fcgs[i] > 0) FCG.fcMint(player, fcgs[i]);
	}

	emit RaceCompleted(++raceCounter);
}


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IController
{
	function aFCG() external view returns(address);
	function aFCC() external view returns(address);
	function aPlayers() external view returns(address);
	function aCars() external view returns(address);
	function aRaces() external view returns(address);

	function isOwner(address account) external view returns(bool);
	function isAdmin(address account) external view returns(bool);
	function isModer(address account) external view returns(bool);
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
	function raceFinished(address account, uint value) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IRaces
{
	
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IFCoin
{
	function fcMint(address to, uint amount) external;
	function fcBurn(address from, uint amount) external;
	function fcTransfer(address from, address to, uint amount) external;
}