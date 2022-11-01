# @version 0.3.7

# HOLOWRAP


from vyper.interfaces import ERC20
from vyper.interfaces import ERC20Detailed

implements: ERC20
implements: ERC20Detailed

interface iHoloYield:
	def transfer(_to: address, _val: uint256) -> bool: nonpayable
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable
	def index() -> uint256: view
	def balanceOf(_who: address) -> uint256: view
	def mint(to: address, _val: uint256) -> bool: nonpayable


event Transfer:
	sender: indexed(address)
	receiver: indexed(address)
	value: uint256

event Approval:
	owner: indexed(address)
	spender: indexed(address)
	value: uint256

name: public(String[64])
symbol: public(String[32])
decimals: public(uint8)

owner: immutable(address)
holoyield: iHoloYield

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)

# ===== INIT ===== #

@external
def __init__(_name: String[64], _symbol: String[32], _decimals: uint8):

	self.name = _name
	self.symbol = _symbol
	self.decimals = _decimals
	owner = msg.sender


# ===== SET PARAMETERS ===== # 

@external
def set_holoyield( _holoyield_address: address):

	assert msg.sender == owner

	self.holoyield = iHoloYield(_holoyield_address)


# ===== MUTATIVE ===== #

@external
def transfer(_to : address, _value : uint256) -> bool:

	assert _to != empty(address)

	self.balanceOf[msg.sender] -= _value
	self.balanceOf[_to] += _value
	log Transfer(msg.sender, _to, _value)
	return True


@external
def transferFrom(_from : address, _to : address, _value : uint256) -> bool:

	assert _to != empty(address)
	assert _from != empty(address)

	self.balanceOf[_from] -= _value
	self.balanceOf[_to] += _value

	if self.allowance[_from][msg.sender] != max_value(uint256):
		self.allowance[_from][msg.sender] -= _value

		log Approval(_from, msg.sender, self.allowance[_from][msg.sender])
	
	log Transfer(_from, _to, _value)
	
	return True

@internal
def _approve(_owner: address, _spender: address, _val: uint256) -> bool:

	assert _spender != empty(address)
	assert _owner != empty(address)
	
	self.allowance[_owner][_spender] = _val

	log Approval(_owner, _spender, self.allowance[_owner][_spender])

	return True

@external
def approve(_spender: address, _val: uint256) -> bool:

	self._approve(msg.sender, _spender, _val)

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
def _mint(_to: address, _value: uint256):

	assert _to != empty(address)
	self.totalSupply += _value
	self.balanceOf[_to] += _value
	log Transfer(empty(address), _to, _value)

@external
def mint(_to: address, _value: uint256):

	assert msg.sender == owner

	self._mint(_to, _value)


@internal
def _burn(_to: address, _value: uint256):

	assert _to != empty(address)
	self.totalSupply -= _value
	self.balanceOf[_to] -= _value
	log Transfer(_to, empty(address), _value)


@external
def burn(_value: uint256):

	self._burn(msg.sender, _value)


@external
def burnFrom(_to: address, _value: uint256):

	if self.allowance[_to][msg.sender] != max_value(uint256):
		self.allowance[_to][msg.sender] -= _value

		log Approval(_to, msg.sender, self.allowance[_to][msg.sender])

	self._burn(_to, _value)

@external
@nonreentrant('lock')
def wrap(_amount: uint256) -> uint256:

	self.holoyield.transferFrom(msg.sender, self, _amount)

	_value: uint256 = self._yield_to_wrap(_amount)

	self._mint(msg.sender, _value)

	return _value

@external
@nonreentrant('lock')
def unwrap(_amount: uint256) -> uint256:

	self._burn(msg.sender, _amount)

	_value: uint256 = self._wrap_to_yield(_amount)

	_hy_balance: uint256 = self.holoyield.balanceOf(self)

	if _value > _hy_balance:
		_amount_to_mint: uint256 = _value - _hy_balance
		self.holoyield.mint(self, _amount_to_mint)

	self.holoyield.transfer(msg.sender, _value)

	return _value

@view
@internal
def _wrap_to_yield(_amount: uint256) -> uint256:

	_idx: uint256 = self.holoyield.index()

	return (_amount * _idx) / 10 ** 18

@view
@internal
def _yield_to_wrap(_amount: uint256) -> uint256:

	_idx: uint256 = self.holoyield.index()

	return (_amount * 10 ** 18) / _idx