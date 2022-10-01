# @version ^0.3.0

# PRESALE TRANSFER

interface iPresale:
	def transfer(_to: address, _val: uint256) -> bool: nonpayable
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable
	def balanceOf(_who: address) -> uint256: view


interface iHoloYield:
	def transfer(_to: address, _val: uint256) -> bool: nonpayable
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable
	def balanceOf(_who: address) -> uint256: view
	def mint(to: address, _val: uint256) -> bool: nonpayable
	def gonsForBalance(_amount: uint256) -> uint256: view
	def balanceForGons(_gons: uint256) -> uint256: view


event Redemption:
	_time: uint256
	_mul: uint256
	_amount: uint256

struct Claim:
	deposit: uint256
	deposit_gons: uint256
	released: uint256
	previous_claim: uint256
	next_claim: uint256
	stake_time: uint256
	gons: uint256
	expiry: uint256
	reedemed: bool

owner: address

holoyield: iHoloYield
pholo: iPresale
qholo: iPresale
vault: address
conversion_factor: uint256

denom: constant(uint256) = 10 ** 18

stakeInfo: public(HashMap[address, Claim])

vesting_period: uint256
vesting_fraction: uint256
interval: uint256

@external
def __init__():

	self.owner = msg.sender


@external
def initialise(_holoyield_address: address, _pholo_address: address, _vault_address: address):

	assert msg.sender == self.owner

	self.holoyield = iHoloYield(_holoyield_address)
	self.pholo = iPresale(_pholo_address)
	self.vault = _vault_address


@external
def set_conversion_factor(_conversion_factor: uint256):

	assert msg.sender == self.owner

	self.conversion_factor = _conversion_factor

@external
def set_interval(_interval: uint256):

	assert msg.sender == self.owner

	self.interval = _interval

@external
def set_vesting_period(_vesting_period: uint256):

	assert msg.sender == self.owner

	self.vesting_period = _vesting_period

@external
def set_vesting_fraction(_vesting_fraction: uint256):

	assert msg.sender == self.owner

	self.vesting_fraction = _vesting_fraction

@nonreentrant('lock')
@external
def swap(_to: address):

	_amount: uint256 = self.pholo.balanceOf(_to)

	self.pholo.transferFrom(msg.sender, self, _amount)

	_amount_holo: uint256 = _amount * self.conversion_factor / denom

	expiry_time: uint256 = block.timestamp + self.vesting_period

	next_claim: uint256 = block.timestamp + self.interval

	self.stakeInfo[_to] = Claim({deposit: _amount_holo,
			deposit_gons: self.holoyield.gonsForBalance(_amount_holo),
			released: 0,
			previous_claim: block.timestamp,
			next_claim: next_claim,
			stake_time: block.timestamp,
			gons: self.holoyield.gonsForBalance(_amount_holo),
			expiry: expiry_time,
			reedemed: False})

@nonreentrant('lock')
@external
def claim(_to: address):

	info: Claim = self.stakeInfo[_to]

	if (block.timestamp > info.expiry) and (info.gons > 0) and (not info.reedemed):

		self._send_all(_to, info)

	elif (block.timestamp > info.next_claim) and (info.gons > 0) and (not info.reedemed):

		_send_amount: uint256 = self._amount_claimable(info)

		if self.holoyield.gonsForBalance(_send_amount) > info.gons:

			self._send_all(_to, info)

		else:

			self._send_partial(_to, info, _send_amount)

	else:

		raise "Nothing to claim" 

@view
@internal
def _amount_claimable(info: Claim) -> uint256:

	_time_since_last_claim: uint256 = block.timestamp - info.previous_claim

	_multiplier: uint256 = _time_since_last_claim / self.interval

	_send_amount: uint256 = self.holoyield.balanceForGons(info.deposit_gons) * min(_multiplier * self.vesting_fraction, 10 ** 18) / denom

	log Redemption(_time_since_last_claim, _multiplier, _send_amount)

	return _send_amount

@internal
def _send_partial(_to: address, info: Claim, _send_amount: uint256):

	self.stakeInfo[_to] = Claim({deposit: info.deposit,
		deposit_gons: info.deposit_gons,
		released: info.released + _send_amount,
		previous_claim: block.timestamp,
		next_claim: block.timestamp + self.interval,
		stake_time: info.stake_time,
		gons: info.gons - self.holoyield.gonsForBalance(_send_amount),
		expiry: info.expiry,
		reedemed: False})

	self.holoyield.transferFrom(self.vault, _to, _send_amount)



@internal
def _send_all(_to: address, info: Claim):

	_amount: uint256 = self.holoyield.balanceForGons(info.gons)

	self.stakeInfo[_to] = Claim({deposit: info.deposit,
	deposit_gons: info.deposit_gons,
	released: _amount,
	previous_claim: block.timestamp,
	next_claim: 0,
	stake_time: info.stake_time,
	gons: 0,
	expiry: info.expiry,
	reedemed: True})

	self.holoyield.transferFrom(self.vault, _to, _amount)


@view
@external
def time_to_next_claim(_to: address) -> uint256:

	info: Claim = self.stakeInfo[_to]

	return info.next_claim - block.timestamp