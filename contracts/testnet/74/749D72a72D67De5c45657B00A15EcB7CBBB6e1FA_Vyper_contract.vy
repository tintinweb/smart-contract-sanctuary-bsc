# @version ^0.3.0

# HOLOCLEAR

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
	def swapExactTokensForETH(amountIn: uint256, amountOutMin: uint256, path:  DynArray[address, 5], to: address, deadline: uint256) -> DynArray[uint256, 5]: nonpayable
	def swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn: uint256, amountOutMin: uint256, path:  DynArray[address, 5], to: address, deadline: uint256): nonpayable


# ===== EVENTS ===== #

event Transfer:
	_from: indexed(address)
	_to: indexed(address)
	_value: uint256


event Approval:
	_owner: indexed(address)
	_spender: indexed(address)
	_value: uint256

event Liquify:
	_weth: DynArray[uint256, 5]

event Payment:
	amount: uint256
	sender: indexed(address)

event here:
	_here: bool

# ===== STATE VARIABLES ===== #

name: public(String[64])
symbol: public(String[32])
decimals: public(uint8)

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)

owner: address
vault: address
lp_manager: address
bank: address
gilts: address

struct LPData:
	_address: address
	_cross: bool
	_router: address

LP_map: public(HashMap[bytes32, LPData])
LP_keys: public(DynArray[bytes32, 32])


is_excluded: HashMap[address, bool]
has_interacted: public(HashMap[address, HashMap[address, bool]])

swap_limit: public(uint256)

buy_fee: public(uint256)
sell_fee: public(uint256)
fee_denom: constant(uint256) = 10 ** 18

liquify_enabled: public(bool)

swap_locked: bool

# ===== INIT ===== #

@external
def __init__(_name: String[64], _symbol: String[32], _decimals: uint8,  _supply: uint256):
	
	init_supply: uint256 = _supply * 10 ** convert(_decimals, uint256)

	self.name = _name
	self.symbol = _symbol
	self.decimals = _decimals

	self.balanceOf[msg.sender] = init_supply
	self.totalSupply = init_supply
	self.owner = msg.sender
	
	self.is_excluded[self.owner] = True
	self.is_excluded[self] = True
	
	self.liquify_enabled = False

	log Transfer(empty(address), msg.sender, init_supply)

# ===== SET PARAMETERS ===== #


@external
def set_buy_fee(_buy_fee: uint256):

	assert msg.sender == self.owner

	self.buy_fee = _buy_fee

@external
def set_sell_fee(_sell_fee: uint256):

	assert msg.sender == self.owner

	self.sell_fee = _sell_fee

@external
def set_vault(_vault: address):

	assert msg.sender == self.owner

	self.vault = _vault

@external
def set_swap_limit(_swap_limit: uint256):

	assert msg.sender == self.owner

	self.swap_limit = _swap_limit


@external
def excludeAddress(_who: address, _bool: bool):

	assert msg.sender == self.owner

	self.is_excluded[_who] = _bool

@external
def set_liquify_enabled(_bool: bool):

	assert msg.sender == self.owner

	self.liquify_enabled = _bool

@external
def set_lp_manager(_lp_manager: address):

	assert msg.sender == self.owner

	self.lp_manager = _lp_manager

@external
def set_bank(_bank: address):

	assert msg.sender == self.owner

	self.bank = _bank

@external
def set_gilts(_gilts: address):

	assert msg.sender == self.owner

	self.gilts = _gilts


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


# ===== MUTATIVE ===== #

@external
@payable
def __default__():
	log Payment(msg.value, msg.sender)
	

@internal
def _swap_tokens_for_bnb(_amount: uint256, _router: address):

	self._approve(self, _router, _amount)

	router: IRouter = IRouter(_router)

	path: DynArray[address, 5] = []         

	path.append(self)
	path.append(router.WETH())

	router.swapExactTokensForETHSupportingFeeOnTransferTokens(_amount, 0, path, self, block.timestamp + 100)

	send(self.bank, self.balance)


@internal
def _transfer(_from: address, _to: address, _val: uint256) -> bool:

	holobnb: bytes32 = convert(b"HOLOBNB", bytes32)

	holobnb_pair_address: address = self.LP_map[holobnb]._address

	holobnb_router: address = self.LP_map[holobnb]._router

	if (self.balanceOf[self] > self.swap_limit) and (not self.swap_locked) and (_from != holobnb_pair_address) and (self.liquify_enabled):
		self.swap_locked = True
		self._swap_tokens_for_bnb(self.swap_limit, holobnb_router)
		self.swap_locked = False

	self._token_transfer(_from, _to, _val)

	log Transfer(_from, _to, _val)

	return True

@internal
def _token_transfer(_from: address, _to: address, _val: uint256):

	if self.is_excluded[_to] or self.is_excluded[_from]:
		self._excluded_transfer(_from, _to, _val)

	else:
		self._standard_transfer(_from, _to, _val)

@internal
def _excluded_transfer(_from: address, _to: address, _val: uint256):

	self.balanceOf[_from] -= _val
	self.balanceOf[_to] += _val

@internal
def _standard_transfer(_from: address, _to: address, _val: uint256):

	fee_pct: uint256 = self.which_fee_pct(_from, _to)
	fee: uint256 = self.calculate_fee(_val, fee_pct)

	self.balanceOf[_from] -= _val
	self.balanceOf[_to] += (_val - fee)
	self.balanceOf[self] += fee

@external
def transfer(_to: address, _val: uint256) -> bool:

	self._transfer(msg.sender, _to, _val)

	return True

@external
def transferFrom(_from: address, _to: address, _val: uint256) -> bool:

	self._transfer(_from, _to, _val)
	self._approve(_from, msg.sender, self.allowance[_from][msg.sender] - _val)
	 
	return True

@internal
def _approve(_owner: address, _spender: address, _val: uint256) -> bool:
	
	self.allowance[_owner][_spender] = _val

	log Approval(_owner, _spender, self.allowance[_owner][_spender])

	return True


@external
def approve(_spender: address, _val: uint256) -> bool:

	self._approve(msg.sender, _spender, _val)

	return True

@external
def approve_max(_spender: address) -> bool:

	self._approve(msg.sender, _spender, max_value(uint256))

	self.has_interacted[msg.sender][_spender] = True

	return True

@external
def increaseAllowance( _spender: address, _val: uint256) -> bool:
	
	self._approve(msg.sender, _spender, self.allowance[msg.sender][_spender] + _val)

	return True

@external
def decreaseAllowance(_spender: address, _val: uint256) -> bool:

	self.allowance[msg.sender][_spender] -= _val

	log Approval(msg.sender, _spender, self.allowance[msg.sender][_spender])

	return True


@internal
def which_fee_pct(_from: address, _to: address) -> uint256:

	fee_pct: uint256 = 0

	for key in self.LP_keys:

		lp_data: LPData = self.LP_map[key]

		if (lp_data._address == empty(address)):
			
			return fee_pct

		elif _to == lp_data._address:

			fee_pct = self.sell_fee

			return fee_pct

		elif _from == lp_data._address:

			fee_pct = self.buy_fee

			return fee_pct

		else:

			fee_pct = 0

	return fee_pct

@internal
def calculate_fee(_val: uint256, _fee_pct: uint256) -> uint256:

	fee: uint256 = (_val * _fee_pct) / fee_denom

	return fee

@external
def mint(_to: address, _val: uint256) -> bool:

	assert (msg.sender == self.owner) or (msg.sender == self.vault) or (msg.sender == self.gilts)
	assert _to != empty(address)

	self.totalSupply += _val
	self.balanceOf[_to] += _val

	log Transfer(empty(address), _to, _val)

	return True

@internal
def _burn(_to: address, _val: uint256) -> bool:

	assert _to != empty(address)
	self.totalSupply -= _val
	self.balanceOf[_to] -= _val

	log Transfer(_to, empty(address), _val)

	return True


@external
def burn(_val: uint256) -> bool:

	self._burn(msg.sender, _val)

	return True

@external
def burnFrom(_to: address, _val: uint256) -> bool:

	self.allowance[_to][msg.sender] -= _val

	self._burn(_to, _val)

	return True