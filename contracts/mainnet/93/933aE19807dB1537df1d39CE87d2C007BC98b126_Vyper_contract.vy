# @version 0.3.7

# MARKET ORACLE

interface IPair:
	def getReserves() -> (uint256, uint256, uint256): view
	def price0CumulativeLast() -> uint256: view
	def price1CumulativeLast() -> uint256: view
	def token0() -> address: view
	def token1() -> address: view
	def sync(): nonpayable

struct PriceData:
	_address: address
	_token0: address
	_token1: address
	cum_price0_last: uint256
	cum_price1_last: uint256
	price0_rate_last: uint256
	price1_rate_last: uint256
	blocktime_last: uint256

PriceData_map: public(HashMap[bytes32, PriceData])

PriceData_keys: DynArray[bytes32, 32]

controller: immutable(address)


@external
def __init__():

	controller = msg.sender


@external
def addLP(_name: bytes32, _lp_address: address):

	assert msg.sender == controller

	_LP: IPair	= IPair(_lp_address)

	reserve0: uint256 = _LP.getReserves()[0]
	reserve1: uint256 = _LP.getReserves()[1]

	price0_rate: uint256 = 0
	price1_rate: uint256 = 0

	if reserve0 == 0 or reserve1 == 0:

		price0_rate = 0
		price1_rate = 0

	else:

		price0_rate = 10 ** 18 * reserve1 / reserve0
		price1_rate = 10 ** 18 * reserve0 / reserve1

	self.PriceData_map[_name] = PriceData({_address: _lp_address,
		_token0: _LP.token0(),
		_token1: _LP.token1(),
		cum_price0_last: _LP.price0CumulativeLast(),
		cum_price1_last: _LP.price1CumulativeLast(),
		price0_rate_last: price0_rate,
		price1_rate_last: price1_rate,
		blocktime_last: _LP.getReserves()[2]})

	self.PriceData_keys.append(_name)


@internal
@view
def currentBlockTimestamp() -> uint256:
	return block.timestamp

@internal
@view
def _currentCumulativePrice(_LP: IPair) -> (uint256, uint256, uint256):

	price0Cumulative: uint256 = _LP.price0CumulativeLast()
	price1Cumulative: uint256 = _LP.price1CumulativeLast()
	blockTimestamp: uint256 = self.currentBlockTimestamp()

	reserve0: uint256 = 0
	reserve1: uint256 = 0
	reserveTimestamp: uint256 = 0

	(reserve0, reserve1, reserveTimestamp) = _LP.getReserves()

	if blockTimestamp != reserveTimestamp:

		timeElapsed: uint256 = blockTimestamp - reserveTimestamp

		price0Cumulative += (shift(reserve1, 112)/reserve0) * timeElapsed
		price1Cumulative += (shift(reserve0, 112)/reserve1) * timeElapsed


	return price0Cumulative, price1Cumulative, blockTimestamp

@external
@view
def currentCumulativePrice(LP: IPair) -> (uint256, uint256, uint256):

	return self._currentCumulativePrice(LP)

@internal
@view
def _get_price_data(_lp_address: address, _name: bytes32) -> PriceData:

	_LP: IPair = IPair(_lp_address)

	price0Cumulative: uint256 = 0
	price1Cumulative: uint256 = 0
	blockTimestamp: uint256 = 0

	price0Cumulative, price1Cumulative, blockTimestamp = self._currentCumulativePrice(_LP)

	price_data: PriceData = self.PriceData_map[_name]

	if blockTimestamp == price_data.blocktime_last:

		return price_data

	else:

		price0_rate_uint: uint256 = 10 ** 18 * (price0Cumulative -  price_data.cum_price0_last) / (blockTimestamp - price_data.blocktime_last)

		price1_rate_uint: uint256 = 10 ** 18 * (price1Cumulative -  price_data.cum_price1_last) / (blockTimestamp - price_data.blocktime_last)

		price0_rate: uint256 = shift(price0_rate_uint, -112)

		price1_rate: uint256 = shift(price1_rate_uint, -112)

		return PriceData({_address: _lp_address,
			_token0: _LP.token0(),
			_token1: _LP.token1(),
			cum_price0_last: price0Cumulative,
			cum_price1_last: price1Cumulative,
			price0_rate_last: price0_rate,
			price1_rate_last: price1_rate,
			blocktime_last: blockTimestamp})

@external
@view
def get_price_data(_name: bytes32) -> PriceData:

	_lp_address: address = self.PriceData_map[_name]._address	

	return self._get_price_data(_lp_address, _name)

@external
def update(_name: bytes32) -> bool:

	assert msg.sender == controller

	_lp_address: address = self.PriceData_map[_name]._address

	price_data: PriceData = self._get_price_data(_lp_address, _name)

	self.PriceData_map[_name] = price_data

	return True

@external
@view
def sortTokens(tokenA: address, tokenB: address) -> (address, address):

	assert tokenA != tokenB

	token0: address = empty(address)
	token1: address = empty(address)

	if convert(tokenA, uint256) < convert(tokenB, uint256):
		token0 = tokenA
		token1 = tokenB

	else:
		token0 = tokenB
		token1 = tokenA

	assert token0 != empty(address)

	return token0, token1