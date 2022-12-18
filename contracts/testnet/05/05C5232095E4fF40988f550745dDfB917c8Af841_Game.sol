// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import './controller/Controller.sol';
import './fcoin/FCoin.sol';
import './players/Players.sol';
import './cars/Cars.sol';
import './races/Races.sol';


contract Game
{

address public immutable aController;

constructor(address owner_, address admin_)
{
	// Default access
	if (owner_ == address(0)) owner_ = msg.sender;

	// Deploy controller
	Controller CONTROLLER = new Controller(owner_, admin_);
	aController = address(CONTROLLER);

	// Deploy other modules
	FCoin FCG = new FCoin('FormacarGame', 'FCG', aController, owner_, 1000000 ether); // 1M
	FCoin FCC = new FCoin('FormacarCoin', 'FCC', aController, owner_, 100000000 ether); // 100M
	Players PLAYERS = new Players(aController);
	Cars CARS = new Cars(aController);
	Races RACES = new Races(aController);

	// Init controller
	CONTROLLER.init(
		address(FCG),
		address(FCC),
		address(PLAYERS),
		address(CARS),
		address(RACES)
	);

	// Init other modules
	FCG.init();
	FCC.init();
	PLAYERS.init();
	CARS.init();
	RACES.init();
}


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import './IFCoin.sol';
import '../controller/IController.sol';


contract FCoin is IERC20, IERC20Metadata, IFCoin
{


string private _name;
string private _symbol;

mapping(address => uint256) private _balances;

// Modules
IController public immutable CONTROLLER;
address public aPlayers;
address public aCars;
address public aRaces;
bool private _initialized;


constructor(string memory name_, string memory symbol_, address controller_, address mintTo_, uint mintAmount_)
{
	_name = name_;
	_symbol = symbol_;

	CONTROLLER = IController(controller_);

	// Optional initial mint
	if (mintTo_ != address(0) && mintAmount_ > 0)
		_mint(mintTo_, mintAmount_);
}

function init() external
{
	require(!_initialized, 'FCC: initialized');

	aPlayers = CONTROLLER.aPlayers();
	aCars = CONTROLLER.aCars();
	aRaces = CONTROLLER.aRaces();

	_initialized = true;
}


function _isManager(address account) private view returns(bool)
{
	return account == aPlayers
		|| account == aCars
		|| account == aRaces;
}

function fcMint(address to, uint amount) external
{
	require(_isManager(msg.sender), 'FCC: not allowed');
	_mint(to, amount);
}

function fcBurn(address from, uint amount) external
{
	require(_isManager(msg.sender), 'FCC: not allowed');
	_burn(from, amount);
}

function fcTransfer(address from, address to, uint amount) external
{
	require(_isManager(msg.sender) || (msg.sender == from && CONTROLLER.isAdmin(from)),
		'FCC: not allowed');
	_transfer(from, to, amount);
}


function name() public view virtual override returns (string memory)
{ return _name; }

function symbol() public view virtual override returns (string memory)
{ return _symbol; }

function decimals() public view virtual override returns (uint8)
{ return 18; }

function totalSupply() public view virtual override returns (uint256)
{ return 1000000000 ether; }

function balanceOf(address account) public view virtual override returns (uint256)
{ return _balances[account]; }

function transfer(address to, uint256 amount) public virtual override returns (bool)
{ require(false, 'FCC: disabled'); return false; }

function allowance(address owner, address spender) public view virtual override returns (uint256)
{ return 0; }

function approve(address spender, uint256 amount) public virtual override returns (bool)
{ require(false, 'FCC: disabled'); return false; }

function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool)
{ require(false, 'FCC: disabled'); return false; }

function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool)
{ require(false, 'FCC: disabled'); return false; }

function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool)
{ require(false, 'FCC: disabled'); return false; }

function _transfer(address from, address to, uint256 amount) internal virtual
{
	require(to != address(0), 'ERC20: transfer to the zero address');

	require(_balances[from] >= amount, 'ERC20: transfer amount exceeds balance');
	unchecked {
		_balances[from] -= amount;
	}
	_balances[to] += amount;

	emit Transfer(from, to, amount);
}

function _mint(address account, uint256 amount) internal virtual
{
	require(account != address(0), 'ERC20: mint to the zero address');

	_balances[account] += amount;
	emit Transfer(address(0), account, amount);
}

function _burn(address account, uint256 amount) internal virtual
{
	require(_balances[account] >= amount, 'ERC20: burn amount exceeds balance');
	unchecked {
		_balances[account] -= amount;
	}

	emit Transfer(account, address(0), amount);
}


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './Cars721.sol';
import '../controller/IController.sol';
import '../fcoin/IFCoin.sol';


contract Cars is Cars721
{


struct CarModel
{
	string name;
	uint8 class;
	uint16 speed;
	uint16 acceleration;
	uint16 steerability;
}

struct Car
{
	address owner;
	uint8 modelId;
}

struct Tuning
{
	TuningBody body;
	string exhaust;
	string lightFront;
	string lightRear;
	string mirrors;
	string roof;
	string spoiler;
	string wheel;
	string paint;
	string decals;
}

struct TuningBody
{
	string bamperFront;
	string bamperRear;
	string bonnet;
	string chassis;
	string doors;
	string skirts;
	string trunk;
}


// List of existing car models
CarModel[] private carModels;

// All car instances by id
mapping(uint => Car) private cars;

// Tuning setup info of certain car
mapping(uint => Tuning) private tuningOf;


// Modules
IController public immutable CONTROLLER;
IFCoin public FCC;
bool private _initialized;


event CarBought(uint indexed carId);
event CarTuned(uint indexed carId);
event CarPainted(uint indexed carId);
event CarDecaled(uint indexed carId);


constructor(address controller_)
{
	CONTROLLER = IController(controller_);

	carModels.push(CarModel({ // modelId: 0
		name: '', // BMW M3 E36 1997
		class: 1,
		speed: 208,
		acceleration: 312,
		steerability: 283
	}));
	carModels.push(CarModel({ // modelId: 1
		name: '', // Subaru BRZ
		class: 2,
		speed: 215,
		acceleration: 283,
		steerability: 312
	}));
	carModels.push(CarModel({ // modelId: 2
		name: '', // Nissan GT-R
		class: 3,
		speed: 245,
		acceleration: 360,
		steerability: 376
	}));
	carModels.push(CarModel({ // modelId: 3
		name: '', // Lamborghini Aventador
		class: 3,
		speed: 268,
		acceleration: 424,
		steerability: 392
	}));
	carModels.push(CarModel({ // modelId: 4
		name: '', // Koenigsegg Agera RS
		class: 4,
		speed: 320,
		acceleration: 488,
		steerability: 536
	}));
	carModels.push(CarModel({ // modelId: 5
		name: '', // Bugatti Chiron
		class: 4,
		speed: 350,
		acceleration: 600,
		steerability: 552
	}));
}

function init() external
{
	require(!_initialized, 'Cars: initialized');

	FCC = IFCoin(CONTROLLER.aFCC());

	_initialized = true;
}


// ERC721
function _ownerOf(uint tokenId) internal view virtual override returns(address)
{
	require(tokenId <= carsCounter, 'ERC721: invalid token ID');
	return cars[tokenId].owner;
}


function getCarModel(uint modelId) external view returns(CarModel memory)
{ return carModels[modelId]; }

function getCarModels() external view returns(CarModel[] memory)
{ return carModels; }

function getCar(uint carId) external view returns(Car memory)
{ return cars[carId]; }

function getCarTuning(uint carId) external view returns(Tuning memory)
{ return tuningOf[carId]; }

function totalSupply() external view returns (uint)
{ return carsCounter; }

function _validateCarId(uint carId) private view
{ require(carId > 0 && carId <= carsCounter, 'Cars: invalid car id'); }

function getFullCarInfo(uint carId) external view returns(Car memory, CarModel memory, Tuning memory)
{
	_validateCarId(carId);

	Car memory car = cars[carId];
	return (car, carModels[car.modelId], tuningOf[carId]);
}


function buyCar(address player, uint8 modelId, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	require(modelId < carModels.length, 'Cars: invalid model id');

	// Pay
	if (payAmount > 0) FCC.fcBurn(player, payAmount);

	Car storage car = cars[++carsCounter];
	car.owner = player;
	car.modelId = modelId;

	// Mint NFT
	_mint(player, carsCounter);

	emit CarBought(carsCounter);
}

function tuneCar(uint carId, uint[] memory typeIds, string[] memory details, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	_validateCarId(carId);
	require(typeIds.length > 0 && typeIds.length == details.length, 'Cars: invalid arrays');

	// Pay for
	if (payAmount > 0) FCC.fcBurn(cars[carId].owner, payAmount);

	Tuning storage tun = tuningOf[carId];
	for (uint i; i < typeIds.length; i++)
	{
		string memory detail = details[i];
		require(bytes(detail).length < 16, 'Cars: invalid detail length');

		uint typeId = typeIds[i];
		if (typeId == 0) tun.body.bamperFront = detail;
		else if (typeId == 1) tun.body.bamperRear = detail;
		else if (typeId == 2) tun.body.bonnet = detail;
		else if (typeId == 3) tun.body.chassis = detail;
		else if (typeId == 4) tun.body.doors = detail;
		else if (typeId == 5) tun.body.skirts = detail;
		else if (typeId == 6) tun.body.trunk = detail;
		else if (typeId == 7) tun.exhaust = detail;
		else if (typeId == 8) tun.lightFront = detail;
		else if (typeId == 9) tun.lightRear = detail;
		else if (typeId == 10) tun.mirrors = detail;
		else if (typeId == 11) tun.roof = detail;
		else if (typeId == 12) tun.spoiler = detail;
		else if (typeId == 13) tun.wheel = detail;
	}

	emit CarTuned(carId);
}

function paintCar(uint carId, string memory paint, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	_validateCarId(carId);
	require(bytes(paint).length < 16, 'Cars: invalid paint');

	// Pay for
	if (payAmount > 0) FCC.fcBurn(cars[carId].owner, payAmount);

	tuningOf[carId].paint = paint;
	emit CarPainted(carId);
}

function decalCar(uint carId, string memory decals, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	_validateCarId(carId);
	require(bytes(decals).length < 1024, 'Cars: invalid paint');

	// Pay for
	if (payAmount > 0) FCC.fcBurn(cars[carId].owner, payAmount);

	tuningOf[carId].decals = decals;
	emit CarDecaled(carId);
}

function buyTuning(address player, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	if (payAmount > 0) FCC.fcBurn(player, payAmount);
}

function buyDecal(address player, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	if (payAmount > 0) FCC.fcBurn(player, payAmount);
}

function buyPaint(address player, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	if (payAmount > 0) FCC.fcBurn(player, payAmount);
}

function mixPaint(address player, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	if (payAmount > 0) FCC.fcBurn(player, payAmount);
}


}

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

import './IPlayers.sol';
import '../controller/IController.sol';
import '../fcoin/IFCoin.sol';
import '../races/IRaces.sol';


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
IRaces public RACES;
bool private _initialized;


event PlayerRegistered(address indexed account);
event PlayerLevelUp(address indexed account, uint level);
event ChallengeComplete(address indexed player);


constructor(address controller_)
{
	CONTROLLER = IController(controller_);
}

function init() external
{
	require(!_initialized, 'Players: initialized');

	FCG = IFCoin(CONTROLLER.aFCG());
	FCC = IFCoin(CONTROLLER.aFCC());
	RACES = IRaces(CONTROLLER.aRaces());

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

function raceFinished(address account, uint exp) external
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
}

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


interface IFCoin
{
	function fcMint(address to, uint amount) external;
	function fcBurn(address from, uint amount) external;
	function fcTransfer(address from, address to, uint amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";


contract Cars721 is ERC165, IERC721, IERC721Metadata
{
	using Address for address;
	using Strings for uint256;

	uint internal carsCounter;
	string internal _baseURI;
	mapping(uint256 => address) private _owners;
	mapping(address => uint256) private _balances;

	
	constructor() {}

	
	function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
		return
			interfaceId == type(IERC721).interfaceId ||
			interfaceId == type(IERC721Metadata).interfaceId ||
			super.supportsInterface(interfaceId);
	}

	function balanceOf(address owner) public view virtual override returns (uint256) {
		require(owner != address(0), "ERC721: address zero is not a valid owner");
		return _balances[owner];
	}

	function name() public view virtual override returns (string memory)
	{ return "FormacarCar"; }

	function symbol() public view virtual override returns (string memory)
	{ return "FCAR"; }

	function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
	{
		require(tokenId <= carsCounter, 'ERC721: invalid token ID');
		return bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenId.toString())) : "";
	}

	function _ownerOf(uint tokenId) internal view virtual returns(address)
	{ return address(0); }
	function ownerOf(uint256 tokenId) public view virtual override returns (address)
	{ return _ownerOf(tokenId); }
	
	function _setBaseURI(string memory uri) internal
	{ _baseURI = uri; }

	function approve(address to, uint256 tokenId) public virtual override
	{ require(false, 'FCAR: disabled'); }

	function getApproved(uint256 tokenId) public view virtual override returns (address)
	{ return address(0); }

	function setApprovalForAll(address operator, bool approved) public virtual override
	{ require(false, 'FCAR: disabled'); }

	function isApprovedForAll(address owner, address operator) public view virtual override returns (bool)
	{ return false; }

	function transferFrom(address from, address to, uint256 tokenId) public virtual override
	{ require(false, 'FCAR: disabled'); }

	function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override
	{ require(false, 'FCAR: disabled'); }

	function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override
	{ require(false, 'FCAR: disabled'); }

	function _mint(address to, uint256 tokenId) internal virtual
	{
		_balances[to] += 1;

		emit Transfer(address(0), to, tokenId);
	}

	/*function _burn(uint256 tokenId) internal virtual {
		address owner = ownerOf(tokenId);

		_balances[owner] -= 1;
		delete _owners[tokenId];

		emit Transfer(owner, address(0), tokenId);
	}

	function _transfer(
		address from,
		address to,
		uint256 tokenId
	) internal virtual {
		require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
		require(to != address(0), "ERC721: transfer to the zero address");

		_balances[from] -= 1;
		_balances[to] += 1;
		_owners[tokenId] = to;

		emit Transfer(from, to, tokenId);
	}*/
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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