# @version ^0.3.0
# GILTS

interface IQuote:
	def transfer(_to: address, _val: uint256) -> bool: nonpayable
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable

interface iHoloClear:
	def transfer(_to: address, _val: uint256) -> bool: nonpayable
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable
	def balanceOf(_who: address) -> uint256: view
	def mint(to: address, _val: uint256) -> bool: nonpayable

interface iHoloYield:
	def transfer(_to: address, _val: uint256) -> bool: nonpayable
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable
	def balanceOf(_who: address) -> uint256: view
	def mint(to: address, _val: uint256) -> bool: nonpayable
	def gonsForBalance(_amount: uint256) -> uint256: view
	def balanceForGons(_gons: uint256) -> uint256: view

interface iMarketOracle:
    def get_price_data(_name: bytes32) -> PriceData: view

interface iRouter:
	def WETH() -> address: view
	def swapExactETHForTokens(amountOutMin: uint256, path:  DynArray[address, 5], to: address, deadline: uint256) -> DynArray[uint256, 5]: payable

struct Gilt:
	market: bytes32
	market_address: address
	maturity_period: uint256
	bonus: uint256
	min_amount: uint256


struct Claim:
	_id: uint256
	deposit: uint256
	discount: uint256
	gons: uint256
	maturity_time: uint256
	redeemed: bool

struct PriceData:
	_address: address
	token0: address
	token1: address
	cum_price0_last: uint256
	cum_price1_last: uint256
	price0_rate_last: uint256
	price1_rate_last: uint256
	blocktime_last: uint256


# ===== STATE VARIABLES ===== #

owner: address
bank: address
vault: address
BUSD: address
lottery: address
holoclear: iHoloClear
holoyield: iHoloYield
marketoracle: iMarketOracle
router: iRouter

GiltInfoMap: public(HashMap[address, HashMap[uint256, Claim]])
gilt_info_id: public(HashMap[address, uint256])
MY_GILTS_DISPLAY_ITERATOR: constant(uint256) = 65536


bonus_denom: constant(uint256) = 10 ** 18
lottery_fraction: public(uint256)

GiltMap: public(HashMap[uint256, Gilt])
GiltKeys: public(DynArray[uint256, 128])
gilt_index: uint256
GILTS_DISPLAY_ITERATOR: constant(uint256) = 512

# ===== INIT ===== #


@external
def __init__():

	self.owner = msg.sender

# ===== SET PARAMETERS ===== #

@external
def initialise(_bank: address, _vault: address, _busd: address, _lottery: address, _holoclear_address: address, _holoyield_address: address, market_oracle_address: address, router_address: address):
	
	assert msg.sender == self.owner

	self.bank = _bank
	self.vault = _vault
	self.BUSD = _busd
	self.lottery = _lottery
	self.holoclear = iHoloClear(_holoclear_address)
	self.holoyield = iHoloYield(_holoyield_address)
	self.marketoracle = iMarketOracle(market_oracle_address)
	self.router = iRouter(router_address)

@external
def set_lottery_fraction(_fraction: uint256):

	assert msg.sender == self.owner

	self.lottery_fraction = _fraction

@external
def add_gilt(_market: bytes32, _market_address: address, _maturity_period: uint256, _bonus: uint256, _min_amount: uint256):

	assert msg.sender == self.owner

	self.GiltMap[self.gilt_index] = Gilt({market: _market, market_address: _market_address, maturity_period: _maturity_period, bonus: _bonus, min_amount: _min_amount})

	self.GiltKeys.append(self.gilt_index)

	self.gilt_index += 1

@external
def amend_gilt_bonus(_index: uint256, _bonus: uint256):

	assert msg.sender == self.owner

	_gilt: Gilt = self.GiltMap[_index]

	self.GiltMap[_index] = Gilt({market: _gilt.market, market_address: _gilt.market_address, maturity_period: _gilt.maturity_period, bonus: _bonus, min_amount: _gilt.min_amount})

	
# ===== MUTATIVE ===== #

@payable
@external
@nonreentrant('lock')
def mint(_gilt_index: uint256, _to: address, _amount: uint256):

	_sent_amount: uint256 = 0

	_gilt: Gilt = self.GiltMap[_gilt_index]

	if _gilt.market == convert(b"HOLOBNB", bytes32):
		_sent_amount = self._send_bnb(msg.value, _gilt)

	else:
		_sent_amount = self._send_quote(_amount, _gilt)

	_rate: uint256 = self._get_rate(_gilt)

	_holo_amount: uint256 = _sent_amount * _rate / bonus_denom

	self._add_claim(_to, _holo_amount, _gilt)

@payable
@internal
def _send_bnb(_amount: uint256, _gilt: Gilt) -> uint256:

	assert _amount >= _gilt.min_amount

	path: DynArray[address, 5] = []         

	path.append(self.router.WETH())
	path.append(self.BUSD)

	lottery_amount: uint256 = _amount * self.lottery_fraction / bonus_denom
	remaining_amount: uint256 = _amount - lottery_amount

	self.router.swapExactETHForTokens(0, path, self.lottery, block.timestamp + 100, value = lottery_amount)

	send(self.bank, remaining_amount)

	return _amount

@internal
def _send_quote(_amount: uint256, _gilt: Gilt) -> uint256:

	assert _amount >= _gilt.min_amount

	quote: IQuote = IQuote(_gilt.market_address)

	lottery_amount: uint256 = _amount * self.lottery_fraction / bonus_denom
	remaining_amount: uint256 = _amount - lottery_amount

	quote.transferFrom(msg.sender, self.bank, remaining_amount)
	quote.transferFrom(msg.sender, self.lottery, lottery_amount)

	return _amount

@internal
def _get_rate(_gilt: Gilt) -> uint256:

	_price_data: PriceData = self.marketoracle.get_price_data(_gilt.market)

	if _price_data.token0 == self.holoclear.address:

		return _price_data.price1_rate_last

	else: 

		return _price_data.price0_rate_last
	
@internal
def _add_claim(_to: address, _holo_amount: uint256, _gilt: Gilt):

	_amount_holoyield_mint: uint256 = self._apply_bonus(_holo_amount, _gilt.bonus)

	self.holoyield.mint(self, _amount_holoyield_mint)

	_maturity_time: uint256 = _gilt.maturity_period + block.timestamp

	_id: uint256 = self.gilt_info_id[_to]

	self.GiltInfoMap[_to][_id] = Claim({_id: _id, deposit: _holo_amount, discount: _gilt.bonus, gons: self.holoyield.gonsForBalance(_amount_holoyield_mint), maturity_time: _maturity_time, redeemed: False})

	self.gilt_info_id[_to] += 1

@internal
def _apply_bonus(_amount: uint256, _bonus: uint256) -> uint256:

	return _amount * _bonus / bonus_denom

@external
@nonreentrant('lock')
def claim(_to: address, _id: uint256):

	claim: Claim = self.GiltInfoMap[_to][_id]

	if (not claim.redeemed) and (claim.maturity_time < block.timestamp) and (claim.deposit > 0):

		_amount: uint256 = self.holoyield.balanceForGons(claim.gons)

		self.holoyield.transfer(_to, _amount)

		self.GiltInfoMap[_to][_id] = Claim({_id: _id, deposit: claim.deposit, discount: claim.discount, gons: claim.gons, maturity_time: claim.maturity_time, redeemed: True})

	else:

		raise 'Nothing to claim'

@view
@external
def view_gilts(_market: bytes32) -> DynArray[Gilt, GILTS_DISPLAY_ITERATOR]:

	gilts_array: DynArray[Gilt, GILTS_DISPLAY_ITERATOR] = []

	for i in range(GILTS_DISPLAY_ITERATOR):

		if i == self.gilt_index:
			break
		
		gilt: Gilt = self.GiltMap[i]

		if gilt.market != _market:
			continue

		else:
			gilts_array.append(gilt)

	return gilts_array

@view
@external
def view_my_gilts(_address: address) -> DynArray[Claim, MY_GILTS_DISPLAY_ITERATOR]:

	num_gilts: uint256 = self.gilt_info_id[_address]

	my_gilts_array: DynArray[Claim, MY_GILTS_DISPLAY_ITERATOR] = []

	for i in range(MY_GILTS_DISPLAY_ITERATOR):

		if i == num_gilts:
			break

		gilt_info: Claim = self.GiltInfoMap[_address][i]

		my_gilts_array.append(gilt_info)

	return my_gilts_array