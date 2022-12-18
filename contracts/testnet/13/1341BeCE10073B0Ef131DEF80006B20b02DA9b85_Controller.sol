// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './IController.sol';


contract Controller is IController
{


// Roles
mapping(address => bool) private _owners;
uint8 private _ownersCount;
mapping(address => bool) private _admins;
mapping(address => bool) private _moders;

// Represents backend actions
mapping(address => bool) private _dispatchers;

// Represents players actions
mapping(address => bool) private _relayers;

// FCC/FCG exchanges
bool public fccToFcgExchangeEnabled;
bool public fcgToFccExchangeEnabled;

// Modules
address public aFCG;
address public aFCC;
address public aPlayers;
address public aCars;
address public aRaces;
bool private _initialized;


constructor(address owner_, address admin_)
{
	_owners[owner_] = true;
	_ownersCount = 1;

	if (admin_ != address(0)) _admins[admin_] = true;
}

function init(
	address fcg_,
	address fcc_,
	address players_,
	address cars_,
	address races_
) external
{
	require(!_initialized, 'Controller: initialized');

	aFCG = fcg_;
	aFCC = fcc_;
	aPlayers = players_;
	aCars = cars_;
	aRaces = races_;

	_initialized = true;
}


modifier onlyOwner()
{ require(isOwner(msg.sender), 'Controller: not allowed'); _; }


function isOwner(address account) public view returns(bool)
{ return _owners[account]; }

function isAdmin(address account) public view returns(bool)
{ return _admins[account] || isOwner(account); }

function isModer(address account) public view returns(bool)
{ return _moders[account] || isAdmin(account); }

function isDispatcher(address account) public view returns(bool)
{ return _dispatchers[account]; }

function isRelayer(address account) public view returns(bool)
{ return _relayers[account]; }


function onlyDispatcher(address account) external view
{ require(_dispatchers[account], 'Controller: not allowed'); }

function onlyRelayer(address account) external view
{ require(_relayers[account], 'Controller: not allowed'); }


function setOwner(address account, bool itIs) external onlyOwner
{
	require(account != address(0), 'Controller: invalid address');
	require(_owners[account] != itIs, 'Controller: already');
	if (!itIs) require(_ownersCount > 1, 'Controller: owners count');

	_owners[account] = itIs;
	if (itIs) _ownersCount++;
	else _ownersCount--;
}

function setAdmin(address account, bool itIs) external onlyOwner
{
	require(account != address(0), 'Controller: invalid address');
	require(_admins[account] != itIs, 'Controller: already');

	_admins[account] = itIs;
}

function setModer(address account, bool itIs) external onlyOwner
{
	require(account != address(0), 'Controller: invalid address');
	require(_moders[account] != itIs, 'Controller: already');

	_moders[account] = itIs;
}

function setDispatchers(address[] memory accounts, bool[] memory itIses) external onlyOwner
{
	require(accounts.length > 0 && accounts.length == itIses.length, 'Controller: invalid arrays');

	for (uint i; i < accounts.length; i++)
	{
		if (accounts[i] != address(0))
			_dispatchers[accounts[i]] = itIses[i];
	}
}

function setRelayers(address[] memory accounts, bool[] memory itIses) external onlyOwner
{
	require(accounts.length > 0 && accounts.length == itIses.length, 'Controller: invalid arrays');

	for (uint i; i < accounts.length; i++)
	{
		if (accounts[i] != address(0))
			_relayers[accounts[i]] = itIses[i];
	}
}


function setFcgToFccExchangeEnabled(bool enabled) external onlyOwner
{
	require(fcgToFccExchangeEnabled != enabled, 'Controller: already');
	fcgToFccExchangeEnabled = enabled;
}

function setFccToFcgExchangeEnabled(bool enabled) external onlyOwner
{
	require(fccToFcgExchangeEnabled != enabled, 'Controller: already');
	fccToFcgExchangeEnabled = enabled;
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