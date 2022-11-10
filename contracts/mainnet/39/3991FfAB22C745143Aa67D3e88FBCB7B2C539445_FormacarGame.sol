// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './ISwap.sol';
import './Governance.sol';


contract FormacarGame is ERC20, Governance
{


struct WhaleData
{
	uint buyPeriod;
	uint buyVolume1;
	uint buyVolume2;
	uint buyVolume3;
	uint buyVolumeTemp;
	uint sellPeriod;
	uint sellVolume1;
	uint sellVolume2;
	uint sellVolume3;
	uint sellVolumeTemp;
}

struct Market
{
	bool isMarket;

	bool antiBotEnabled;
	bool launchAllowed;
	uint launchedAt;

	uint buyFeeMillis;
	uint sellFeeMillis;

	uint minWhaleLimit;
	uint buyWhaleLimit;
	uint sellWhaleLimit;

	// To fix compilation stack error
	WhaleData whale;
}

struct Trader
{
	uint firstBuyAt;
	uint8 buyCount;
}


// Trading fees
address public feeReceiver;
bool private _feeReceiverLocked;
mapping(address => bool) public isFeeExcluded;

// Antiwhale
mapping(address => bool) public isWhaleExcluded;
uint8 public whaleRatePercents = 3; // Max deal volume from whole trade volume by market

// AMMs
mapping(address => Market) public markets;
mapping(address => bool) public isDexPeriphery;

// Antisnipe
mapping(address => bool) public isSnipeExcluded;
mapping(address => Trader) public traders;
uint8 public snipeTargetBuyCount = 5; // On what antisnipe will triggered
uint16 public snipeMonitorPeriod = 60;
uint16 public snipeWholePeriod = 360; // Monitor + lock periods

// Antidump
uint16 public dumpDurationSeconds = 3600;
uint16 public dumpThresholdPercents = 175; // 100 + real difference (for calculations)
uint8 public dumpFeePercents = 60;
uint public dumpMinControlVolume = 25000 ether; // 25K FCG;
uint public dumpActivatedAt;
uint private ad_currentPeriod;
uint private ad_buyVolume;
uint private ad_sellVolume;
uint private ad_buyVolumeTemp;
uint private ad_sellVolumeTemp;

// Low market fee temps
uint private _lowFeeAt;
uint16 private _lowFeeBuyMillis;
uint16 private _lowFeeSellMillis;
address private _lowFeePair;


event MarketFeeUpdated(address indexed pair, uint buyMillis, uint sellMillis);
event FeeExcluded(address indexed account, bool isExcluded);
event AntiWhaleExcluded(address indexed account, bool isExcluded);
event AntiSnipeExcluded(address indexed account, bool isExcluded);
event AntiDumpActivated();
event NewMarket(address indexed pair);
event MarketRemoved(address indexed pair);
event NewDexPeriphery(address indexed thing);
event DexPeripheryRemoved(address indexed thing);
event MarketLaunched(address indexed pair);


constructor(
	address[] memory validators_,
	address[] memory workers_,
	uint[] memory levels_,
	address feeReceiver_
)
	ERC20('FormacarGame', 'FCG')
	Governance(validators_, workers_, levels_)
{
	_mint(workers_[0], 1000000000 ether); // 1B FCG, whole supply to first worker

	for (uint i; i < validators_.length; i++) _excludeFromAll(validators_[i]);
	for (uint i; i < workers_.length; i++) _excludeFromAll(workers_[i]);

	require(feeReceiver_ != address(0), 'FCG: invalid fee receiver');
	_excludeFromAll(feeReceiver_);
	feeReceiver = feeReceiver_;

	_excludeFromAll(address(this));
}


function _excludeFromAll(address account) private
{
	isFeeExcluded[account] = true;
	isWhaleExcluded[account] = true;
	isSnipeExcluded[account] = true;

	emit FeeExcluded(account, true);
	emit AntiWhaleExcluded(account, true);
	emit AntiSnipeExcluded(account, true);
}


function _setFeeReceiver(address account) private
{
	require(account != address(0) && account != feeReceiver, 'FCG: invalid address');
	require(!_feeReceiverLocked, 'FCG: locked');

	_excludeFromAll(account);
	feeReceiver = account;
}

function _allowLaunchMarket(address pair) private
{
	Market storage market = markets[pair];
	require(market.isMarket, 'FCG: not exist');
	require(!market.launchAllowed, 'FCG: already allowed');

	market.launchAllowed = true;
}

function _setMarketFee(address pair, uint buyMillis, uint sellMillis) private
{
	Market storage market = markets[pair];

	require(market.isMarket, 'FCG: not exist');
	require(sellMillis >= 20 && sellMillis <= 1000 &&
		buyMillis >= 20 && buyMillis <= 1000, 'FCG: limit is 20-1000 millis');

	if (market.buyFeeMillis != buyMillis) market.buyFeeMillis = buyMillis;
	if (market.sellFeeMillis != sellMillis) market.sellFeeMillis = sellMillis;

	emit MarketFeeUpdated(pair, buyMillis, sellMillis);
}

function _setLowMarketFeeTemps(address pair, uint buyMillis, uint sellMillis) private
{
	require(markets[pair].isMarket, 'FCG: not exist');
	require(sellMillis < 1000 && buyMillis < 1000, 'FCG: limit is 1000 millis');

	_lowFeePair = pair;
	_lowFeeBuyMillis = uint16(buyMillis);
	_lowFeeSellMillis = uint16(sellMillis);
	_lowFeeAt = block.timestamp;
}

function getLowMarketFeeTemps() external view returns(address pair, uint buyMillis, uint sellMillis, uint at)
{
	if (_lowFeeAt + 1 hours > block.timestamp)
	{
		pair = _lowFeePair;
		buyMillis = _lowFeeBuyMillis;
		sellMillis = _lowFeeSellMillis;
		at = _lowFeeAt;
	}
}

function acceptLowMarketFee() external
{
	require(msg.sender == feeReceiver, 'FCG: only fee receiver');
	require(_lowFeeAt + 1 hours > block.timestamp, 'FCG: expired');

	Market storage market = markets[_lowFeePair];
	require(market.isMarket, 'FCG: is not market');

	if (market.buyFeeMillis != _lowFeeBuyMillis) market.buyFeeMillis = _lowFeeBuyMillis;
	if (market.sellFeeMillis != _lowFeeSellMillis) market.sellFeeMillis = _lowFeeSellMillis;
	_lowFeeAt = 0;

	emit MarketFeeUpdated(_lowFeePair, _lowFeeBuyMillis, _lowFeeSellMillis);
}

function _setFeeExcluded(address account, bool isExcluded) private
{
	require(account != address(0), 'FCG: invalid address');

	isFeeExcluded[account] = isExcluded;
	emit FeeExcluded(account, isExcluded);
}

function _setFeeExcludedMany(address[] memory accounts, bool[] memory isExcludeds) private
{
	require(accounts.length > 0 && accounts.length == isExcludeds.length,
		'FCG: invalid input arrays');

	for (uint i; i < accounts.length; i++)
	{
		if (accounts[i] == address(0)) continue;
		
		isFeeExcluded[accounts[i]] = isExcludeds[i];
		emit FeeExcluded(accounts[i], isExcludeds[i]);
	}
}


/// Anti whale ///

function _setWhaleExcluded(address account, bool isExcluded) private
{
	require(account != address(0), 'FCG: invalid address');

	isWhaleExcluded[account] = isExcluded;
	emit AntiWhaleExcluded(account, isExcluded);
}

function _setWhaleExcludedMany(address[] memory accounts, bool[] memory isExcludeds)
	private
{
	require(accounts.length > 0 && accounts.length == isExcludeds.length,
		'FCG: invalid input arrays');

	for (uint256 i; i < accounts.length; i++)
	{
		if (accounts[i] != address(0))
		{
			isWhaleExcluded[accounts[i]] = isExcludeds[i];
			emit AntiWhaleExcluded(accounts[i], isExcludeds[i]);
		}
	}
}

function _setWhaleMinLimit(address pair, uint newValue) private
{
	Market storage market = markets[pair];
	require(market.isMarket, 'FCG: invalid pair');
	require(newValue != market.minWhaleLimit, 'FCG: same value');

	market.minWhaleLimit = newValue;
	if (market.buyWhaleLimit < newValue) market.buyWhaleLimit = newValue;
	if (market.sellWhaleLimit < newValue) market.sellWhaleLimit = newValue;
}

function _setWhaleRatePercents(uint ratePercents) private
{
	require(ratePercents >= 1 && ratePercents <= 15, 'FCG: invalid rate');
	require(whaleRatePercents != ratePercents, 'FCG: same');

	whaleRatePercents = uint8(ratePercents);
}


/// Anti snipe ///

function _setSnipeExcluded(address account, bool isExcluded) private
{
	require(account != address(0), 'FCG: invalid address');

	isSnipeExcluded[account] = isExcluded;
	emit AntiSnipeExcluded(account, isExcluded);
}

function _setSnipeExcludedMany(address[] memory accounts, bool[] memory isExcludeds) private
{
	require(accounts.length > 0 && accounts.length == isExcludeds.length,
		'FCG: invalid input arrays');

	for (uint256 i; i < accounts.length; i++)
	{
		if (accounts[i] != address(0))
		{
			isSnipeExcluded[accounts[i]] = isExcludeds[i];
			emit AntiSnipeExcluded(accounts[i], isExcludeds[i]);
		}
	}
}

function _setSnipeControlValues(uint targetBuyCount, uint monitorPeriod, uint lockPeriod) private
{
	require(targetBuyCount >= 1 && targetBuyCount <= 25, 'FCG: invalid count');
	require(monitorPeriod >= 12 && monitorPeriod <= 300, 'FCG: invalid monitor');
	require(lockPeriod >= 60 && targetBuyCount <= 1500, 'FCG: invalid lock');

	if (snipeTargetBuyCount != targetBuyCount) snipeTargetBuyCount = uint8(targetBuyCount);
	if (snipeMonitorPeriod != monitorPeriod) snipeMonitorPeriod = uint16(monitorPeriod);

	uint wholePeriod = monitorPeriod + lockPeriod;
	if (snipeWholePeriod != wholePeriod) snipeWholePeriod = uint16(wholePeriod);
}


/// Antidump ///

function _setDumpControlValues(uint thresholdPercents, uint minControlVolume, uint durationSeconds, uint feePercents) private
{
	require(thresholdPercents >= 15 && thresholdPercents <= 375, 'FCG: invalid threshold');
	require(minControlVolume >= 100 ether, 'FCG: invalid volume');
	require(durationSeconds >= 720 && durationSeconds <= 18000, 'FCG: invalid duration');
	require(feePercents >= 12 && feePercents <= 100, 'FCG: invalid fee');

	thresholdPercents += 100; // For calculations
	if (dumpThresholdPercents != thresholdPercents) dumpThresholdPercents = uint16(thresholdPercents);
	if (dumpMinControlVolume != minControlVolume) dumpMinControlVolume = minControlVolume;
	if (dumpDurationSeconds != durationSeconds) dumpDurationSeconds = uint16(durationSeconds);
	if (dumpFeePercents != feePercents) dumpFeePercents = uint8(feePercents);
}


/// Trading markets management ///

// Add/remove an important contract of certain DEX (router, NPM)
function _addDexPeriphery(address thing) private
{
	require(thing != address(0), 'FCG: invalid address');
	require(!isDexPeriphery[thing], 'FCG: already');
	require(!markets[thing].isMarket, 'FCG: is market');

	isDexPeriphery[thing] = true;
	emit NewDexPeriphery(thing);
}

function _removeDexPeriphery(address thing) private
{
	require(isDexPeriphery[thing], 'FCG: not exist');

	isDexPeriphery[thing] = false;
	emit DexPeripheryRemoved(thing);
}

// Create new pair on factory and add it
function _createMarketV2(address factory, address token) private
{
	require(factory != address(0) && token != address(0)
		&& factory != token && token != address(this), 'FCG: invalid address');

	address pair = ISwapFactoryV2(factory).createPair(address(this), token);
	_insertMarket(pair, 0);
}

function _createMarketV3(address factory, address token, uint24 fee) private
{
	require(factory != address(0) && token != address(0)
		&& factory != token && token != address(this), 'FCG: invalid address');

	address pool = ISwapFactoryV3(factory).createPool(address(this), token, fee);
	_insertMarket(pool, 0);
}

// Add previously created pair/pool to control list
function _addMarket(address pair, bool force) private
{
	require(pair != address(0), 'FCG: invalid address');
	require(!isDexPeriphery[pair], 'FCG: is periphery');

	if (!force)
	{
		ISwapPair swapPair = ISwapPair(pair);
		require(swapPair.token0() == address(this) || swapPair.token1() == address(this), 'FCG: invalid pair');
	}

	_insertMarket(pair, 1);
}

// Main adding logic, also insert new router
function _insertMarket(address pair, uint launchedAt) private
{
	Market storage market = markets[pair];
	require(!market.isMarket, 'FCG: market exist');

	market.isMarket = true;
	market.launchedAt = launchedAt;
	market.buyFeeMillis = 20;
	market.sellFeeMillis = 20;
	market.minWhaleLimit = 10000 ether;
	market.buyWhaleLimit = market.minWhaleLimit;
	market.sellWhaleLimit = market.minWhaleLimit;
	emit NewMarket(pair);
}

function _removeMarket(address pair) private
{
	Market storage market = markets[pair];
	require(market.isMarket, 'FCG: not exist');

	market.isMarket = false;
	emit MarketRemoved(pair);
}


// Override transfering to process protection and fee cases
function _transfer(address from, address to, uint256 amount) internal virtual override
{
	// Basic ERC20 checks
	require(from != address(0), 'ERC20: transfer from the zero address');
	require(to != address(0), 'ERC20: transfer to the zero address');
	require(balanceOf(from) >= amount, 'ERC20: transfer amount exceeds balance');


	// Detect DEX relations
	Market storage toAsMarket = markets[to];
	Market storage fromAsMarket = markets[from];

	bool isSell = toAsMarket.isMarket;
	bool isBuy = fromAsMarket.isMarket;


	// Detect when add first liq to protected pair
	if (toAsMarket.isMarket && toAsMarket.launchedAt == 0)
	{
		require(getWorkerLevel(msg.sender) > 0, 'FCG: not permitted to launch this pair');
		require(toAsMarket.launchAllowed, 'FCG: launch not allowed');

		toAsMarket.launchedAt = block.timestamp;
		toAsMarket.antiBotEnabled = true;

		emit MarketLaunched(to);
	}


	// Detect trading case and set trader address at one time
	address traderAddress = isBuy != isSell ? (isBuy ? to : from) : address(0);
	
	// If it's trading case and not interact with periphery
	if (traderAddress != address(0) && !isDexPeriphery[traderAddress])
	{
		Market storage market = isBuy ? fromAsMarket : toAsMarket;


		// Anti snipe
		if (!isSnipeExcluded[traderAddress])
		{
			Trader storage trader = traders[traderAddress];
			uint timePassed = block.timestamp - trader.firstBuyAt;

			if (timePassed > snipeMonitorPeriod)
			{
				// Block the sniper
				if (timePassed < snipeWholePeriod)
					require(trader.buyCount < snipeTargetBuyCount, 'FCG: antisnipe lock');

				// Else init new control period
				if (isBuy)
				{
					trader.firstBuyAt = block.timestamp;
					trader.buyCount = 1;
				}
			}
			else if (isBuy) trader.buyCount++;
		}


		// Check amount limit by daily volume (antiwhale)
		if (!isWhaleExcluded[traderAddress]) require(
			amount <= (isBuy ? market.buyWhaleLimit : market.sellWhaleLimit), 'FCG: anti whale limit');


		// Process daily trading volume of this market for antiwhale limit
		uint period = block.timestamp / 21600; // 6 hours, 4 periods per day
		if (isBuy)
		{
			WhaleData storage whale = market.whale;
			if (whale.buyPeriod < period)
			{
				uint whaleLimit = (whale.buyVolume1 + whale.buyVolume2
					+ whale.buyVolume3 + whale.buyVolumeTemp) * whaleRatePercents / 100;

				if (whaleLimit > market.minWhaleLimit) market.buyWhaleLimit = whaleLimit;
				else market.buyWhaleLimit = market.minWhaleLimit;

				whale.buyVolume1 = whale.buyVolume2;
				whale.buyVolume2 = whale.buyVolume3;
				whale.buyVolume3 = whale.buyVolumeTemp;
				whale.buyVolumeTemp = amount;
				whale.buyPeriod = period;
			}
			else whale.buyVolumeTemp += amount;
		}
		else
		{
			WhaleData storage whale = market.whale;
			if (whale.sellPeriod < period)
			{
				uint whaleLimit = (whale.sellVolume1 + whale.sellVolume2
					+ whale.sellVolume3 + whale.sellVolumeTemp) * whaleRatePercents / 100;

				if (whaleLimit > market.minWhaleLimit) market.sellWhaleLimit = whaleLimit;
				else market.sellWhaleLimit = market.minWhaleLimit;

				whale.sellVolume1 = whale.sellVolume2;
				whale.sellVolume2 = whale.sellVolume3;
				whale.sellVolume3 = whale.sellVolumeTemp;
				whale.sellVolumeTemp = amount;
				whale.sellPeriod = period;
			}
			else whale.sellVolumeTemp += amount;
		}


		// Process antidump
		period = block.timestamp / 1800; // Half of hour
		if (ad_currentPeriod < period)
		{
			uint hourlyBuyVolume = ad_buyVolume + ad_buyVolumeTemp;
			uint hourlySellVolume = ad_sellVolume + ad_sellVolumeTemp;

			// Activation
			if (hourlyBuyVolume + hourlySellVolume > dumpMinControlVolume &&
				hourlySellVolume > hourlyBuyVolume * dumpThresholdPercents / 100)
			{
				dumpActivatedAt = block.timestamp;
				emit AntiDumpActivated();
			}

			ad_currentPeriod = period;
			ad_buyVolume = ad_buyVolumeTemp;
			ad_sellVolume = ad_sellVolumeTemp;
			ad_buyVolumeTemp = isBuy ? amount : 0;
			ad_sellVolumeTemp = isSell ? amount : 0;
		}
		else
		{
			if (isBuy) ad_buyVolumeTemp += amount;
			else ad_sellVolumeTemp += amount;
		}


		// Process fees
		if (!isFeeExcluded[traderAddress])
		{
			// Calculate fee
			uint feeAmount = amount * (isBuy ? market.buyFeeMillis : market.sellFeeMillis) / 1000;

			if (isSell)
			{
				// Bot penalties on sell at market launch (antibot)
				if (market.antiBotEnabled)
				{
					if (market.launchedAt + 3600 > block.timestamp) feeAmount *= 20;
					else market.antiBotEnabled = false;
				}

				// Antidump applying
				if (dumpActivatedAt + dumpDurationSeconds > block.timestamp)
					feeAmount += amount * dumpFeePercents / 100;
			}
				

			// Apply fee
			if (feeAmount > 0)
			{
				// Clamp overflowed fee
				if (feeAmount > amount) feeAmount = amount;

				// Subtract from amount
				if (isBuy) amount -= feeAmount;

				// Get extra fee
				else require(balanceOf(from) >= amount + feeAmount, 'FCG: not enough balance for fee');
				
				super._transfer(from, feeReceiver, feeAmount);
			}
		}
	}


	// Do main transfer
	if (amount > 0) super._transfer(from, to, amount);
}


/// Governance actions

// Governance actions descriptions
function _getActionDescription(uint actionId) internal pure virtual override returns(string memory)
{
	if (actionId == 3) return 'SetFeeExcluded/Many (account/s, isExcluded/s)';
	if (actionId == 4) return 'SetWhaleExcluded/Many (account/s, isExcluded/s)';
	if (actionId == 5) return 'SetSnipeExcluded/Many (account/s, isExcluded/s)';
	if (actionId == 6) return 'ExcludeFromAll (account)';
	if (actionId == 7) return 'SetMarketFee (pair, buyFeeMillis, sellFeeMillis)';
	if (actionId == 8) return 'SetDumpControlValues (thresholdPercents, minControlVolume, durationSeconds, feePercents)';
	if (actionId == 9) return 'SetWhaleMinLimit (pair, newValue)';
	if (actionId == 10) return 'CreateMarketV2 (factory, token)';
	if (actionId == 11) return 'CreateMarketV3 (factory, token, fee)';
	if (actionId == 12) return 'AddMarket (pair)';
	if (actionId == 13) return 'AllowLaunchMarket (pair)';
	if (actionId == 14) return 'RemoveMarket (pair)';
	if (actionId == 15) return 'AddDexPeriphery (thing)';
	if (actionId == 16) return 'RemoveDexPeriphery (thing)';
	if (actionId == 17) return 'SetFeeReceiver (account)';
	if (actionId == 18) return 'LockFeeReceiver ()';
	if (actionId == 19) return 'SetLowMarketFeeTemps (pair, buyMillis, sellMillis)';
	if (actionId == 20) return 'SetSnipeControlValues (targetBuyCount, monitorPeriod, lockPeriod)';
	if (actionId == 21) return 'SetWhaleRatePercents (ratePercents)';
	return super._getActionDescription(actionId);
}

// Governance actions importance level that workers need to have
function _getActionLevel(uint actionId) internal pure virtual override returns(uint)
{
	if (actionId == 3) return 1; // SetFeeExcluded/Many
	if (actionId == 4) return 1; // SetWhaleExcluded/Many
	if (actionId == 5) return 1; // SetSnipeExcluded/Many
	if (actionId == 6) return 1; // ExcludeFromAll
	if (actionId == 7) return 2; // SetMarketFee
	if (actionId == 8) return 2; // SetDumpControlValues
	if (actionId == 9) return 2; // SetWhaleMinLimit
	if (actionId == 10) return 2; // CreateMarketV2
	if (actionId == 11) return 2; // CreateMarketV3
	if (actionId == 12) return 2; // AddMarket
	if (actionId == 13) return 2; // AllowLaunchMarket
	if (actionId == 14) return 2; // RemoveMarket
	if (actionId == 15) return 2; // AddDexPeriphery
	if (actionId == 16) return 2; // RemoveDexPeriphery
	if (actionId == 17) return 3; // SetFeeReceiver
	if (actionId == 18) return 3; // LockFeeReceiver
	if (actionId == 19) return 2; // SetLowMarketFeeTemps
	if (actionId == 20) return 2; // SetSnipeControlValues
	if (actionId == 21) return 2; // SetWhaleRatePercents
	return super._getActionLevel(actionId);
}

// Governance validators count that need to accept action
function _getActionApproveCount(uint actionId) internal pure virtual override returns(uint)
{
	if (actionId == 3) return 1; // SetFeeExcluded/Many
	if (actionId == 4) return 1; // SetWhaleExcluded/Many
	if (actionId == 5) return 1; // SetSnipeExcluded/Many
	if (actionId == 6) return 1; // ExcludeFromAll
	if (actionId == 7) return 2; // SetMarketFee
	if (actionId == 8) return 3; // SetDumpControlValues
	if (actionId == 9) return 2; // SetWhaleMinLimit
	if (actionId == 10) return 2; // CreateMarketV2
	if (actionId == 11) return 2; // CreateMarketV3
	if (actionId == 12) return 2; // AddMarket
	if (actionId == 13) return 3; // AllowLaunchMarket
	if (actionId == 14) return 3; // RemoveMarket
	if (actionId == 15) return 3; // AddDexPeriphery
	if (actionId == 16) return 3; // RemoveDexPeriphery
	if (actionId == 17) return 4; // SetFeeReceiver
	if (actionId == 18) return 4; // LockFeeReceiver
	if (actionId == 19) return 2; // SetLowMarketFeeTemps
	if (actionId == 20) return 3; // SetSnipeControlValues
	if (actionId == 21) return 3; // SetWhaleRatePercents
	return super._getActionApproveCount(actionId);
}

// Governance decrees applying
function _acceptDecree(uint decreeId, uint actionId) internal virtual override
{
	if (actionId == 3) // SetFeeExcluded/Many
	{
		address[] memory dudes = _getAddressArrayParam(decreeId);
		if (dudes.length > 0) _setFeeExcludedMany(dudes, _getBoolArrayParam(decreeId));
		else _setFeeExcluded(_getAddressParam(decreeId), _getBoolParam(decreeId));
	}

	else if (actionId == 4) // SetWhaleExcluded/Many
	{
		address[] memory dudes = _getAddressArrayParam(decreeId);
		if (dudes.length > 0) _setWhaleExcludedMany(dudes, _getBoolArrayParam(decreeId));
		else _setWhaleExcluded(_getAddressParam(decreeId), _getBoolParam(decreeId));
	}

	else if (actionId == 5) // SetSnipeExcluded/Many
	{
		address[] memory dudes = _getAddressArrayParam(decreeId);
		if (dudes.length > 0) _setSnipeExcludedMany(dudes, _getBoolArrayParam(decreeId));
		else _setSnipeExcluded(_getAddressParam(decreeId), _getBoolParam(decreeId));
	}

	else if (actionId == 6) // ExcludeFromAll
		_excludeFromAll(_getAddressParam(decreeId));

	else if (actionId == 7) // SetMarketFee
	{
		uint[] memory fees = _getUintArrayParam(decreeId);
		require(fees.length == 2, 'FCG: invalid fees array');

		_setMarketFee(_getAddressParam(decreeId), fees[0], fees[1]);
	}

	else if (actionId == 8) // SetDumpControlValues
	{
		uint[] memory vals = _getUintArrayParam(decreeId);
		require(vals.length == 4, 'FCG: invalid values array');

		_setDumpControlValues(vals[0], vals[1], vals[2], vals[3]);
	}

	else if (actionId == 9) // SetWhaleMinLimit
		_setWhaleMinLimit(_getAddressParam(decreeId), _getUintParam(decreeId));

	else if (actionId == 10) // CreateMarketV2
	{
		address[] memory factoryAndToken = _getAddressArrayParam(decreeId);
		require(factoryAndToken.length == 2, 'FCG: invalid params');

		_createMarketV2(factoryAndToken[0], factoryAndToken[1]);
	}

	else if (actionId == 11) // CreateMarketV3
	{
		address[] memory factoryAndToken = _getAddressArrayParam(decreeId);
		require(factoryAndToken.length == 2, 'FCG: invalid params');

		_createMarketV3(factoryAndToken[0], factoryAndToken[1], uint24(_getUintParam(decreeId)));
	}

	else if (actionId == 12) // AddMarket
		_addMarket(_getAddressParam(decreeId), _getBoolParam(decreeId));

	else if (actionId == 13) // AllowLaunchMarket
		_allowLaunchMarket(_getAddressParam(decreeId));

	else if (actionId == 14) // RemoveMarket
		_removeMarket(_getAddressParam(decreeId));

	else if (actionId == 15) // AddDexPeriphery
		_addDexPeriphery(_getAddressParam(decreeId));

	else if (actionId == 16) // RemoveDexPeriphery
		_removeDexPeriphery(_getAddressParam(decreeId));

	else if (actionId == 17) // SetFeeReceiver
		_setFeeReceiver(_getAddressParam(decreeId));

	else if (actionId == 18) // LockFeeReceiver
		_feeReceiverLocked = true;

	else if (actionId == 19) // SetLowMarketFeeTemps
	{
		uint[] memory fees = _getUintArrayParam(decreeId);
		require(fees.length == 2, 'FCG: invalid fees array');

		_setLowMarketFeeTemps(_getAddressParam(decreeId), fees[0], fees[1]);
	}

	else if (actionId == 20) // SetSnipeControlValues
	{
		uint[] memory vals = _getUintArrayParam(decreeId);
		require(vals.length == 3, 'FCG: invalid values array');

		_setSnipeControlValues(vals[0], vals[1], vals[2]);
	}

	else if (actionId == 21) // SetWhaleRatePercents
		_setWhaleRatePercents(_getUintParam(decreeId));

	else super._acceptDecree(decreeId, actionId);
}


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


/// Uniswap V2 ///

interface ISwapFactoryV2
{
	function createPair(address tokenA, address tokenB) external returns (address pair);
}

/*interface ISwapRouter
{
	function WETH() external pure returns (address);
	function factory() external pure returns (address);
}*/

interface ISwapPair // We use this for V3 pools also
{
	function factory() external view returns (address);
	function token0() external view returns (address);
	function token1() external view returns (address);
}


/// Uniswap V3 ///

interface ISwapFactoryV3
{
	function createPool(address tokenA, address tokenB, uint24 fee) external returns (address pool);
}

/*interface ISwapNPM // NonfungiblePositionManager
{
	function factory() external view returns (address);
	function WETH9() external view returns (address);
}*/

/*interface ISwapPool
{
	function factory() external view returns (address);
	function token0() external view returns (address);
	function token1() external view returns (address);
}*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract Governance
{


struct Decree
{
	uint8 actionId;
	address[] approvers;
	uint createdAt;
}

struct DecreeData
{
	uint actionId;
	string actionDescription;
	uint createdAt;
	bool accepted;
	address[] approvers;
	uint approvesNeed;
	uint uintParam;
	uint[] uintParams;
	bool boolParam;
	bool[] boolParams;
	address addressParam;
	address[] addressParams;
}


mapping(address => uint8) private _workers;
uint private _highWorkersCount;

mapping(address => bool) private _validators;
uint private _validatorsCount;

uint public decreesCounter;
mapping(uint => Decree) private _decrees;

mapping(uint => uint) private _uintParams;
mapping(uint => uint[]) private _uintArrayParams;
mapping(uint => bool) private _boolParams;
mapping(uint => bool[]) private _boolArrayParams;
mapping(uint => address) private _addressParams;
mapping(uint => address[]) private _addressArrayParams;


event ValidatorUpdated(address indexed account, bool itIs);
event WorkerUpdated(address indexed account, uint8 newLevel);
event DecreeCreated(uint decreeId, address indexed creator);
event DecreeApproved(uint decreeId, address indexed approver);
event DecreeAccepted(uint decreeId);


constructor(address[] memory validators_, address[] memory workers_, uint[] memory levels_)
{
	require(validators_.length > 4 && workers_.length > 2 && levels_.length == workers_.length,
		'Governance: invalid arrays');

	for (uint i; i < validators_.length; i++)
	{
		require(validators_[i] != address(0), 'Governance: invalid validator');
		require(!_validators[validators_[i]], 'Governance: duplicated validator');

		_validators[validators_[i]] = true;
	}

	for (uint i; i < workers_.length; i++)
	{
		require(workers_[i] != address(0), 'Governance: invalid worker');
		require(levels_[i] > 0 && levels_[i] < 10, 'Governance: invalid worker level');
		require(_workers[workers_[i]] == uint8(0), 'Governance: duplicated worker');

		_workers[workers_[i]] = uint8(levels_[i]);

		if (levels_[i] > 2) _highWorkersCount++;
	}

	require(_highWorkersCount > 1, 'Governance: need at least 2 high workers');
	_validatorsCount = validators_.length;
}

function isValidator(address account) public view returns(bool)
{ return _validators[account]; }

function getWorkerLevel(address account) public view returns(uint)
{ return uint(_workers[account]); }

function _getActionDescription(uint actionId) internal pure virtual returns(string memory)
{
	if (actionId == 1) return 'SetValidator (account, itIs)';
	if (actionId == 2) return 'SetWorker (account, level)';
	return 'INVALID';
}

function _getActionLevel(uint actionId) internal pure virtual returns(uint)
{
	if (actionId == 1) return 3; // setValidator
	if (actionId == 2) return 3; // setWorker
	return 100;
}

function _getActionApproveCount(uint actionId) internal pure virtual returns(uint)
{
	if (actionId == 1) return 4; // setValidator
	if (actionId == 2) return 4; // setWorker
	return 100;
}

function _acceptDecree(uint decreeId, uint actionId) internal virtual
{
	if (actionId == 1) _setValidator(_addressParams[decreeId], _boolParams[decreeId]);
	else if (actionId == 2) _setWorker(_addressParams[decreeId], uint8(_uintParams[decreeId]));
	else require(false, 'Governance: invalid action');
}

function _setValidator(address account, bool itIs) private
{
	require(account != address(0), 'Governance: invalid address');
	require(_validators[account] != itIs, 'Governance: already');

	if (itIs) _validatorsCount++;
	else
	{
		require(_validatorsCount > 5, 'Governance: need at least 5 validators');
		_validatorsCount--;
	}

	_validators[account] = itIs;
	emit ValidatorUpdated(account, itIs);
}

function _setWorker(address account, uint8 level) private
{
	require(account != address(0), 'Governance: invalid address');
	require(level < uint8(10), 'Governance: invalid level');

	uint8 prev = _workers[account];
	require(prev != level, 'Governance: already');

	uint8 high = uint8(3);
	if (prev >= high && level < high || prev < high && level >= high)
	{
		if (level < high)
		{
			require(_highWorkersCount > 2, 'Governance: need at least 2 high workers');
			_highWorkersCount--;
		}
		else _highWorkersCount++;
	}

	_workers[account] = level;
	emit WorkerUpdated(account, level);
}

function createDecree(
	uint8 actionId,
	uint[] memory uints,
	bool[] memory bools,
	address[] memory addresses
) external
{
	require(_getActionLevel(uint(actionId)) <= uint(_workers[msg.sender]), 'Governance: not allowed');

	Decree storage decree = _decrees[++decreesCounter];
	decree.actionId = actionId;
	decree.createdAt = block.timestamp;

	if (uints.length > 0)
	{
		if (uints.length > 1)
		{
			uint[] storage arr = _uintArrayParams[decreesCounter];
			for (uint i; i < uints.length; i++) arr.push(uints[i]);
		}
		else _uintParams[decreesCounter] = uints[0];
	}

	if (bools.length > 0)
	{
		if (bools.length > 1)
		{
			bool[] storage arr = _boolArrayParams[decreesCounter];
			for (uint i; i < bools.length; i++) arr.push(bools[i]);
		}
		else _boolParams[decreesCounter] = bools[0];
	}

	if (addresses.length > 0)
	{
		if (addresses.length > 1)
		{
			address[] storage arr = _addressArrayParams[decreesCounter];
			for (uint i; i < addresses.length; i++) arr.push(addresses[i]);
		}
		else _addressParams[decreesCounter] = addresses[0];
	}

	emit DecreeCreated(decreesCounter, msg.sender);
}

function approveDecree(uint decreeId) external
{
	require(_validators[msg.sender], 'Governance: not allowed');

	Decree storage decree = _decrees[decreeId];
	require(decree.createdAt + 3600 > block.timestamp, 'Governance: deprecated');

	uint countNeed = _getActionApproveCount(uint(decree.actionId));
	require(decree.approvers.length < countNeed, 'Governance: accepted');

	for (uint i; i < decree.approvers.length; i++)
		require(decree.approvers[i] != msg.sender, 'Governance: approved');

	decree.approvers.push(msg.sender);
	emit DecreeApproved(decreeId, msg.sender);

	if (decree.approvers.length >= countNeed)
	{
		_acceptDecree(decreeId, uint(decree.actionId));
		emit DecreeAccepted(decreeId);
	}
}

function _getUintParam(uint decreeId) internal view returns(uint)
{ return _uintParams[decreeId]; }

function _getUintArrayParam(uint decreeId) internal view returns(uint[] memory)
{ return _uintArrayParams[decreeId]; }

function _getBoolParam(uint decreeId) internal view returns(bool)
{ return _boolParams[decreeId]; }

function _getBoolArrayParam(uint decreeId) internal view returns(bool[] memory)
{ return _boolArrayParams[decreeId]; }

function _getAddressParam(uint decreeId) internal view returns(address)
{ return _addressParams[decreeId]; }

function _getAddressArrayParam(uint decreeId) internal view returns(address[] memory)
{ return _addressArrayParams[decreeId]; }


function getDecreeData(uint decreeId) external view returns(DecreeData memory)
{
	Decree memory decree = _decrees[decreeId];
	return DecreeData(
		uint(decree.actionId),
		_getActionDescription(decree.actionId),
		decree.createdAt,
		decree.approvers.length >= _getActionApproveCount(decree.actionId),
		decree.approvers,
		_getActionApproveCount(decree.actionId),
		_uintParams[decreeId],
		_uintArrayParams[decreeId],
		_boolParams[decreeId],
		_boolArrayParams[decreeId],
		_addressParams[decreeId],
		_addressArrayParams[decreeId]
	);
}


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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