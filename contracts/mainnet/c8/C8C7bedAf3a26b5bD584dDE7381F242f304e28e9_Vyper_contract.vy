# @version 0.3.7
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

interface iVault:
    def update_lottery(_to: address): nonpayable

struct Gilt:
	idx: uint256
	market: bytes32
	maturity_period: uint256
	bonus: uint256
	min_amount: uint256
	market_address: address
	live: bool


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

owner: immutable(address)
bank: address
vault: iVault
BUSD: address
lottery: address
has_init: bool
holoclear: iHoloClear
holoyield: iHoloYield
marketoracle: iMarketOracle
router: iRouter

GiltInfoMap: public(HashMap[address, HashMap[uint256, Claim]])
gilt_info_id: public(HashMap[address, uint256])
MY_GILTS_DISPLAY_ITERATOR: constant(uint256) = 4096
lp_exists: public(HashMap[bytes32, bool])
market_quote_mapping: HashMap[bytes32, bytes32]
current_gilt_balance: public(HashMap[address, uint256])
bonus_denom: constant(uint256) = 10 ** 18
lottery_fraction: public(uint256)

GiltMap: public(HashMap[uint256, Gilt])
GiltKeys: public(DynArray[uint256, 128])
gilt_index: uint256
GILTS_DISPLAY_ITERATOR: constant(uint256) = 512

# ===== INIT ===== #


@external
def __init__():

	owner = msg.sender

# ===== SET PARAMETERS ===== #

@external
def initialise(_bank: address, _vault: address, _busd: address, _lottery: address, _holoclear_address: address, _holoyield_address: address, market_oracle_address: address, router_address: address):
	
	assert msg.sender == owner
	assert not self.has_init

	self.bank = _bank
	self.vault = iVault(_vault)
	self.BUSD = _busd
	self.lottery = _lottery
	self.holoclear = iHoloClear(_holoclear_address)
	self.holoyield = iHoloYield(_holoyield_address)
	self.marketoracle = iMarketOracle(market_oracle_address)
	self.router = iRouter(router_address)
	self.has_init = True

@external
def set_lottery_fraction(_fraction: uint256):

	assert msg.sender == owner

	self.lottery_fraction = _fraction

@external
def add_gilt(_market: bytes32, _market_address: address, _maturity_period: uint256, _bonus: uint256, _min_amount: uint256):

	assert msg.sender == owner

	self.GiltMap[self.gilt_index] = Gilt({idx: self.gilt_index, market: _market, maturity_period: _maturity_period, bonus: _bonus, min_amount: _min_amount,  market_address: _market_address, live: True})

	self.GiltKeys.append(self.gilt_index)

	self.gilt_index += 1

@external
def amend_gilt_bonus(_index: uint256, _bonus: uint256):

	assert msg.sender == owner

	_gilt: Gilt = self.GiltMap[_index]

	self.GiltMap[_index] = Gilt({idx: _gilt.idx, market: _gilt.market, maturity_period: _gilt.maturity_period, bonus: _bonus, min_amount: _gilt.min_amount,  market_address: _gilt.market_address, live: _gilt.live})

@external
def set_gilt_live(_index: uint256, _bool: bool):

	assert msg.sender == owner

	_gilt: Gilt = self.GiltMap[_index]

	self.GiltMap[_index] = Gilt({idx: _gilt.idx, market: _gilt.market, maturity_period: _gilt.maturity_period, bonus: _gilt.bonus, min_amount: _gilt.min_amount, market_address: _gilt.market_address, live: _bool})

@external
def set_lp_exists(_market: bytes32, _bool: bool):

	assert msg.sender == owner
	
	self.lp_exists[_market] = _bool

@external
def set_market_quote_mapping(_market: bytes32, _quote: bytes32):

	assert msg.sender == owner

	self.market_quote_mapping[_market] = _quote

event Rate:
	_rate: uint256

# ===== MUTATIVE ===== #

@payable
@external
@nonreentrant('lock')
def mint(_gilt_index: uint256, _to: address, _amount: uint256):

	_sent_amount: uint256 = 0

	_gilt: Gilt = self.GiltMap[_gilt_index]

	assert _gilt.live == True

	if _gilt.market == convert(b"HOLOBNB", bytes32):
		_sent_amount = self._send_bnb(msg.value, _gilt)

	else:
		_sent_amount = self._send_quote(_amount, _gilt)

	_rate: uint256 = self._get_rate(_gilt)

	log Rate(_rate)

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

	if self.lp_exists[_gilt.market]:

		_price_data: PriceData = self.marketoracle.get_price_data(_gilt.market)

		if _price_data.token0 == self.holoclear.address:
			return _price_data.price1_rate_last

		else: 
			return _price_data.price0_rate_last

	else:

		_holobnb: PriceData = self.marketoracle.get_price_data(convert(b"HOLOBNB", bytes32))

		_holobnb_rate: uint256 = 0

		if _holobnb.token0 == self.holoclear.address:
			_holobnb_rate = _holobnb.price1_rate_last
		else: 
			_holobnb_rate = _holobnb.price0_rate_last

		_bnb_quote_bytes: bytes32 = self.market_quote_mapping[_gilt.market]

		_bnbquote: PriceData = self.marketoracle.get_price_data(_bnb_quote_bytes)

		_bnbquote_rate: uint256 = 0

		if _bnbquote.token0 == self.router.WETH():
			_bnbquote_rate = _bnbquote.price0_rate_last
		else: 
			_bnbquote_rate = _bnbquote.price1_rate_last

		return _holobnb_rate * 10 ** 18 / _bnbquote_rate

	
@internal
def _add_claim(_to: address, _holo_amount: uint256, _gilt: Gilt):

	_amount_holoyield_mint: uint256 = self._apply_bonus(_holo_amount, _gilt.bonus)

	self.holoyield.mint(self, _amount_holoyield_mint)

	_maturity_time: uint256 = _gilt.maturity_period + block.timestamp

	_id: uint256 = self.gilt_info_id[_to]

	gons: uint256 =self.holoyield.gonsForBalance(_amount_holoyield_mint)

	self.GiltInfoMap[_to][_id] = Claim({_id: _id, deposit: _holo_amount, discount: _gilt.bonus, gons: gons, maturity_time: _maturity_time, redeemed: False})

	self.gilt_info_id[_to] += 1

	self.current_gilt_balance[_to] += gons

	self.vault.update_lottery(_to)

@external
def add_claim(_to: address, _holo_amount: uint256, _gilt_index: uint256):

	assert msg.sender == owner

	_gilt: Gilt = self.GiltMap[_gilt_index]

	self._add_claim(_to, _holo_amount, _gilt)

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

		if claim.gons > self.current_gilt_balance[_to]:
			self.current_gilt_balance[_to] = 0

		else:
			self.current_gilt_balance[_to] -= claim.gons

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

		if (gilt.market != _market) or (not gilt.live):
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