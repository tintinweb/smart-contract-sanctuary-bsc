from vyper.interfaces import ERC20
from vyper.interfaces import ERC20Detailed

implements: ERC20
implements: ERC20Detailed

event Transfer:
	_from: indexed(address)
	_to: indexed(address)
	_value: uint256

event Approval:
	_owner: indexed(address)
	_spender: indexed(address)
	_value: uint256

event Mint:
	_to: indexed(address)
	_value: uint256

name: public(String[64])
symbol: public(String[32])
decimals: public(uint8)

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)

owner: address
presale_address: address
allow_minting: bool

@external
def __init__(_name: String[64], _symbol: String[32], _decimals: uint8):
	self.name = _name
	self.symbol = _symbol
	self.decimals = _decimals
	self.allow_minting = False
	self.owner = msg.sender

@external
def setAllowMint(_allow_minting: bool) -> bool:
	assert msg.sender == self.owner
	self.allow_minting = _allow_minting
	return True

@external
def setPresaleAddress(_presale_address: address) -> bool:
	assert msg.sender == self.owner
	self.presale_address = _presale_address
	return True

@external
def transfer(_to: address, _val: uint256) -> bool:
	self.balanceOf[msg.sender] -= _val
	self.balanceOf[_to] += _val
	log Transfer(msg.sender, _to, _val)
	return True

@external
def transferFrom(_from: address, _to: address, _val: uint256) -> bool:
	self.allowance[_from][msg.sender] -= _val
	log Approval(_from, msg.sender, self.allowance[_from][msg.sender])
	self.balanceOf[_from] -= _val
	self.balanceOf[_to] += _val
	log Transfer(_from, _to, _val)
	return True

@external
def approve(_spender: address, _val: uint256) -> bool:
	self.allowance[msg.sender][_spender] = _val
	log Approval(msg.sender, _spender, _val)
	return True

@external
def mint(_to: address, _val: uint256) -> bool:
	assert (msg.sender == self.owner) or (msg.sender == self.presale_address)
	assert _to != ZERO_ADDRESS
	assert self.allow_minting == True
	self.totalSupply += _val
	self.balanceOf[_to] += _val
	log Mint(_to, _val)
	return True