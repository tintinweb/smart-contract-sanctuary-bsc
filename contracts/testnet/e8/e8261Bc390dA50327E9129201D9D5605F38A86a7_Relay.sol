// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IController
{
	function aPlayers() external view returns(address);
	function aCars() external view returns(address);
	function onlyDispatcher(address account) external view;
	function onlyRelayer(address account) external view;
}

interface IPlayers
{
	function registerNewPlayer(address account, uint fccAmount) external;
	function challengeComplete(address player, uint fccAmount, uint fcgAmount) external;
	function raceComplete(address account, uint expAmount, uint fccAmount, uint fcgAmount, uint place) external;
	function exchangeFccToFcg(address player, uint fccAmount, uint fcgAmount) external;
	function exchangeFcgToFcc(address player, uint fcgAmount, uint fccAmount) external;
}

interface ICars
{
	function totalSupply() external view returns (uint);
	function buyCar(address player, uint8 modelId, uint payAmount) external;
	function tuneCar(uint carId, uint32 brandId, uint[] memory typeIds, uint32[] memory detailIds, uint payAmount) external;
	function paintCar(uint carId, string memory paint, uint payAmount) external;
	function buyPaint(address player, uint payAmount) external;
	function mixPaint(address player, uint payAmount) external;
}


contract Relay
{


IController public immutable CONTROLLER;
IPlayers public immutable PLAYERS;
ICars public immutable CARS;

mapping (bytes32 => bool) public txs;
mapping (address => uint[]) private garages;


constructor(address controller_)
{	
	CONTROLLER = IController(controller_);
	require(CONTROLLER.aPlayers() != address(0), 'Relay: Invalid controller');

	PLAYERS = IPlayers(CONTROLLER.aPlayers());
	CARS = ICars(CONTROLLER.aCars());
}


modifier onceDisp(bytes32 id)
{
	require(!txs[id], 'Relay: Tx ID not unique');
	CONTROLLER.onlyDispatcher(msg.sender);
	_;
	txs[id] = true;
}

modifier onceRel(bytes32 id)
{
	require(!txs[id], 'Relay: Tx ID not unique');
	CONTROLLER.onlyRelayer(msg.sender);
	_;
	txs[id] = true;
}


function getGarage(address player) external view returns (uint[] memory)
{ return garages[player]; }


function registerNewPlayer(bytes32 txid, address account, uint fccAmount) external onceDisp(txid)
{ PLAYERS.registerNewPlayer(account, fccAmount); }

function challengeComplete(bytes32 txid, address player, uint fccAmount, uint fcgAmount) external onceDisp(txid)
{ PLAYERS.challengeComplete(player, fccAmount, fcgAmount); }

function raceComplete(bytes32 txid, address account, uint expAmount, uint fccAmount, uint fcgAmount, uint place) external onceDisp(txid)
{ PLAYERS.raceComplete(account, expAmount, fccAmount, fcgAmount, place); }

function exchangeFccToFcg(bytes32 txid, address player, uint fccAmount, uint fcgAmount) external onceRel(txid)
{ PLAYERS.exchangeFccToFcg(player, fccAmount, fcgAmount); }

function exchangeFcgToFcc(bytes32 txid, address player, uint fcgAmount, uint fccAmount) external onceRel(txid)
{ PLAYERS.exchangeFcgToFcc(player, fcgAmount, fccAmount); }


function buyCar(bytes32 txid, address player, uint8 modelId, uint payAmount) external onceRel(txid)
{
	CARS.buyCar(player, modelId, payAmount);
	garages[player].push(CARS.totalSupply());
}

function tuneCar(bytes32 txid, uint carId, uint32 brandId, uint[] memory typeIds, uint32[] memory detailIds, uint payAmount) external onceRel(txid)
{ CARS.tuneCar(carId, brandId, typeIds, detailIds, payAmount); }

function paintCar(bytes32 txid, uint carId, string memory paint, uint payAmount) external onceRel(txid)
{ CARS.paintCar(carId, paint, payAmount); }

function buyPaint(bytes32 txid, address player, uint payAmount) external onceRel(txid)
{ CARS.buyPaint(player, payAmount); }

function mixPaint(bytes32 txid, address player, uint payAmount) external onceRel(txid)
{ CARS.mixPaint(player, payAmount); }


}