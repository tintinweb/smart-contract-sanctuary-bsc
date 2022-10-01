# @version ^0.3.0

# HOLOYIELD

from vyper.interfaces import ERC20
from vyper.interfaces import ERC20Detailed

implements: ERC20
implements: ERC20Detailed

interface IFactory:
	def createPair(tokenA: address, tokenB: address) -> address: nonpayable
	def getPair(tokenA: address, tokenB: address) -> address: view

interface IRouter:
	def factory() -> address: view
	def WETH() -> address: view
	def swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn: uint256, amountOutMin: uint256, path: address[2], to: address, deadline: uint256): nonpayable

interface IVault:
	def update_epoch(_epoch_length: uint256, _num: uint256, _end: uint256): nonpayable
	def epoch() -> Epoch: view

# ===== EVENTS ===== #

event Transfer:
	_from: indexed(address)
	_to: indexed(address)
	_value: uint256

event Approval:
	_owner: indexed(address)
	_spender: indexed(address)
	_value: uint256

event LogRebase:
	_epoch: indexed(uint256)
	_totalSupply: uint256
	_supplyDelta: uint256
	_index: uint256

event LogSupply:
	_epoch: indexed(uint256)
	_totalSupply: uint256

# ===== DATA STRUCTURE ===== #

struct Rebase:
	epoch: uint256
	rate: uint256
	supply_delta: int128
	total_supply: uint256
	index: uint256
	blockNumberOccured: uint256

struct Epoch:
	length: uint256 # In seconds
	num: uint256 # Since inception
	end: uint256 # Timestamp


# ===== STATE VARIABLES ===== #

name: public(String[64])
symbol: public(String[32])
decimals: public(uint8)
totalSupply: public(uint256)

INITIAL_FRAGMENTS_SUPPLY: uint256
TOTAL_GONS: public(uint256)
INDEX: uint256

gonsPerFragment: public(uint256)
gonBalances: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])

rate: public(uint256)
rate_denom: constant(uint256) = 10 ** 18

owner: address
vault: public(IVault)
escrow: public(address)
gilts: public(address)
lp_manager: address

RebaseHistory: public(HashMap[uint256, Rebase])
rebase_hist_idx: uint256

struct LPData:
	_address: address
	_cross: bool
	_router: address

LP_map: public(HashMap[bytes32, LPData])
LP_keys: public(DynArray[bytes32, 32])

has_interacted: public(HashMap[address, bool])

# ===== INIT ===== #

@external
def __init__(_name: String[64], _symbol: String[32], _decimals: uint8, _init_supply: uint256):

	self.name = _name
	self.symbol = _symbol
	self.owner = msg.sender
	self.decimals = _decimals

	self.INITIAL_FRAGMENTS_SUPPLY = _init_supply * 10 ** convert(self.decimals, uint256)
	self.TOTAL_GONS = 2**245 - (2**245 % self.INITIAL_FRAGMENTS_SUPPLY)

	self.totalSupply = self.INITIAL_FRAGMENTS_SUPPLY

	self.gonsPerFragment = self.TOTAL_GONS / self.totalSupply


@external
def initialise(_vault: address, presale: address, _escrow: address, _gilts: address, _rate: uint256):

	assert msg.sender == self.owner

	self.vault = IVault(_vault)
	self.escrow = _escrow
	self.gilts = _gilts
	self.rate = _rate

	self.gonBalances[self.vault.address] = self.TOTAL_GONS

	self.allowance[_vault][presale] = max_value(uint256)

	log Transfer(empty(address), msg.sender, self.totalSupply)

# ===== SET PARAMETERS ====== #


@external
def add_LP_pair(_name: bytes32, _token: address, _cross: bool, _router: address) -> bool:

	assert (msg.sender == self.owner) or (msg.sender == self.lp_manager)

	router: IRouter = IRouter(_router)

	factory_address: address = router.factory()

	factory: IFactory = IFactory(factory_address)

	_pair_address: address = factory.getPair(self, _token)

	if _pair_address == empty(address):

		_pair_address = factory.createPair(self, _token)

	self.LP_map[_name] = LPData({_address: _pair_address, _cross: _cross, _router: _router})

	self.LP_keys.append(_name)

	return True

@external
def set_index(_index: uint256):

	assert msg.sender == self.owner
	assert self.INDEX == 0
	self.INDEX = _index * self.gonsPerFragment


@external
def set_rate(_rate: uint256):

	assert msg.sender == self.owner
	self.rate = _rate

@external
def set_lp_manager(_lp_manager: address):

	assert msg.sender == self.owner

	self.lp_manager = _lp_manager


# ===== VIEWS ===== #


@view
@internal
def _balanceOf(_who: address) -> uint256:

	return self.gonBalances[_who] / self.gonsPerFragment    

@view
@external
def balanceOf(_who: address) -> uint256:

	return self._balanceOf(_who)


@view
@internal
def _circulatingSupply() -> uint256:
	
	return self.totalSupply - self._balanceOf(self.vault.address)

@view
@external
def circulatingSupply() -> uint256:
	
	return self._circulatingSupply()


@view
@internal
def _index() -> uint256:
	
	return self.INDEX / self.gonsPerFragment

@view
@external
def index() -> uint256:
	
	return self._index()

@view
@external
def gonsForBalance(_amount: uint256) -> uint256:
	return _amount * self.gonsPerFragment

@view
@external
def balanceForGons(_gons: uint256) -> uint256:
	return _gons / self.gonsPerFragment

# ===== REBASE ===== #

@internal
def _storeRebase(_supply_delta: int128, _epoch: uint256):


	rebase_log: Rebase = Rebase({epoch: _epoch, 
								rate: self.rate, 
								supply_delta: _supply_delta,
								total_supply: self.totalSupply,
								index: self._index(),
								blockNumberOccured: block.number})



	self.RebaseHistory[self.rebase_hist_idx] = rebase_log

	self.rebase_hist_idx += 1


@external
def rebase() -> uint256:

	assert (msg.sender == self.owner) or (msg.sender == self.vault.address)

	if msg.sender == self.owner:

		_length: uint256 = self.vault.epoch().length
		_num: uint256 = self.vault.epoch().num + 1
		_end: uint256 = self.vault.epoch().end + self.vault.epoch().length

		self.vault.update_epoch(_length, _num, _end)

	new_totalSupply: uint256 = self.totalSupply * self.rate / rate_denom

	supply_delta: int128 = convert(new_totalSupply, int128) - convert(self.totalSupply, int128)

	self.totalSupply = new_totalSupply

	if self.totalSupply > max_value(int128):
		self.totalSupply = max_value(int128)

	self.gonsPerFragment = self.TOTAL_GONS / self.totalSupply

	self._storeRebase(supply_delta, self.vault.epoch().num)

	return self.totalSupply
	

# ===== MUTATIVE ===== #


@external
def transfer(_to: address, _val: uint256) -> bool:

	gon_value: uint256 = _val * self.gonsPerFragment
	self.gonBalances[msg.sender] -= gon_value
	self.gonBalances[_to] += gon_value

	log Transfer(msg.sender, _to, _val)

	return True

@external
def transferFrom(_from: address, _to: address, _val: uint256) -> bool:

	self.allowance[_from][msg.sender] -= _val

	log Approval(_from, msg.sender, self.allowance[_from][msg.sender])

	gon_value: uint256 = _val * self.gonsPerFragment
	self.gonBalances[_from] -= gon_value
	self.gonBalances[_to] += gon_value

	log Transfer(_from, _to, _val)

	return True

@external
def approve(_spender: address, _val: uint256) -> bool:

	self.allowance[msg.sender][_spender] = _val

	log Approval(msg.sender, _spender, _val)

	return True

@external
def approve_max(_spender: address) -> bool:

	self.allowance[msg.sender][_spender] = max_value(uint256)

	log Approval(msg.sender, _spender, max_value(uint256))

	self.has_interacted[msg.sender] = True

	return True


@external
def increaseAllowance(_spender: address, _val: uint256) -> bool:

	self.allowance[msg.sender][_spender] += _val

	log Approval(msg.sender, _spender, self.allowance[msg.sender][_spender])

	return True

@external
def decreaseAllowance(_spender: address, _val: uint256) -> bool:

	self.allowance[msg.sender][_spender] -= _val

	log Approval(msg.sender, _spender, self.allowance[msg.sender][_spender])

	return True


@external
def mint(_to: address, _val: uint256) -> bool:

	assert (msg.sender == self.owner) or (msg.sender == self.gilts)
	assert _to != empty(address)

	self.totalSupply += _val
	
	self.TOTAL_GONS = self.gonsPerFragment * self.totalSupply

	gon_value: uint256 = _val * self.gonsPerFragment

	self.gonBalances[_to] += gon_value

	log Transfer(empty(address), _to, _val)

	return True