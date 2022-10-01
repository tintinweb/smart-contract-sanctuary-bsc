# @version ^0.3.0

# VAULT

interface iHoloClear:
	def transfer(_to: address, _val: uint256) -> bool: nonpayable
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable
	def balanceOf(_who: address) -> uint256: view
	def mint(to: address, _val: uint256) -> bool: nonpayable

interface iHoloYield:
	def initialise(_vault: address, _escrow: address): nonpayable
	def set_index(_index: uint256): nonpayable
	def balanceOf(_who: address) -> uint256: view
	def circulatingSupply() -> uint256: view
	def index() -> uint256: view
	def gonsForBalance(_amount: uint256) -> uint256: view
	def balanceForGons(_gons: uint256) -> uint256: view
	def rebase() -> uint256: nonpayable
	def transfer(_to: address, _val: uint256) -> bool: nonpayable
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable
	def approve(_spender: address, _val: uint256) -> bool: nonpayable
	def increaseAllowance(_spender: address, _val: uint256) -> bool: nonpayable
	def decreaseAllowance(_spender: address, _val: uint256) -> bool: nonpayable
	def name() -> String[64]: view
	def symbol() -> String[32]: view
	def decimals() -> uint8: view
	def totalSupply() -> uint256: view
	def allowance(arg0: address, arg1: address) -> uint256: view
	def vault() -> address: view
	def escrow() -> address: view
	def RebaseHistory(arg0: uint256) -> Rebase: view


interface iEscrow:
	def retrieve(_to: address, _amount: uint256) -> bool: nonpayable

# ===== EVENTS ===== #

event LogStake:
	_from: indexed(address)
	_to: indexed(address)
	_value: uint256

event Approval:
	_owner: indexed(address)
	_spender: indexed(address)
	_value: uint256

event LogTime:
	_epoch_end: uint256
	_timestamp: uint256

event LogSupply:
	_epoch: indexed(uint256)
	_totalSupply: uint256

event LogClaim:
	_to: indexed(address)
	_amount: uint256

event LogForfeit:
	_to: indexed(address)
	_amount: uint256


# ===== DATA STRUCTURE ===== #

struct Rebase:
	epoch: uint256
	rebase_pct: uint256
	totalStakedBefore: uint256
	totalStakedAfter: uint256
	amountRebased: uint256
	index: uint256
	blockNumberOccured: uint256

struct Epoch:
	length: uint256 # In seconds
	num: uint256 # Since inception
	end: uint256 # Timestamp

struct Claim:
	deposit: uint256
	expiry: uint256

# ===== STATE VARIABLES ===== #

holoclear: iHoloClear
holoyield: iHoloYield
escrow: iEscrow

epoch: public(Epoch)
stakeInfo: public(HashMap[address, Claim])
owner: public(address)
escrowPeriod: public(uint256)
minimum_stake_amount: public(uint256)


eligible_index_count: public(uint256)
EligibleAddressMap: public(HashMap[address, uint256])
EligibleIndexMap: public(HashMap[uint256, address])

# ===== INIT ===== #

@external
def __init__():

	self.owner = msg.sender


@external
def initialise(holoclear_address: address, 
			 holoyield_address: address,
			 escrow_address: address,
			 epoch_length: uint256, 
			 _first_epoch_end: uint256):

	assert msg.sender == self.owner

	self.holoclear = iHoloClear(holoclear_address)
	self.holoyield = iHoloYield(holoyield_address)
	self.escrow = iEscrow(escrow_address)
	self.epoch = Epoch({length: epoch_length, 
						num: 0, 
						end: _first_epoch_end})


# ===== SET PARAMETERS ===== #

@external
def set_escrow_address(_escrow_address: address):

	assert msg.sender == self.owner

	self.escrow = iEscrow(_escrow_address)

@external
def set_escrowPeriod(_period: uint256):

	assert msg.sender == self.owner

	self.escrowPeriod = _period

@external
def set_minimum_stake_amount(_amount: uint256):

	assert msg.sender == self.owner

	self.minimum_stake_amount = _amount

@external
def update_epoch(_epoch_length: uint256, _num: uint256, _end: uint256):

	assert (msg.sender == self.owner) or (msg.sender == self.holoyield.address)

	self.epoch = Epoch({length: _epoch_length, 
					num: _num, 
					end: _end})

# ===== STATE VARIABLES ===== #

@internal
def _rebase():

	if self.epoch.end < block.timestamp:

		self.epoch.end += self.epoch.length
		self.epoch.num += 1

		self.holoyield.rebase()

@nonreentrant('lock')
@external
def stake(_to: address, _amount: uint256) -> bool:

	assert _amount >= self.minimum_stake_amount

	self._rebase()

	self.holoclear.transferFrom(msg.sender, self, _amount)

	self.holoyield.transfer(_to, _amount)

	self.update_lottery(_to)

	log LogStake(msg.sender, _to, _amount)

	return True

@internal
def update_lottery(_to: address):

	_index: uint256 = self.EligibleAddressMap[_to]

	_balance: uint256 = self.holoyield.balanceOf(_to)

	if _index == 0:
		
		self.EligibleAddressMap[_to] = self.eligible_index_count

		self.EligibleIndexMap[self.eligible_index_count] = _to

		self.eligible_index_count += 1


@nonreentrant('lock')
@external
def claim(_to: address) -> bool:
	
	info: Claim = self.stakeInfo[_to]

	if (info.deposit > 0) and (block.timestamp > info.expiry):

		_amount: uint256 = info.deposit

		self.stakeInfo[_to] = Claim({deposit: 0,
			expiry: 0})

		self.escrow.retrieve(_to, _amount)

		log LogClaim(_to, _amount)

		return True

	else:

		raise "Nothing to claim"


@nonreentrant('lock')
@external
def unstake(_to: address, _amount: uint256) -> bool:

	self.holoyield.transferFrom(msg.sender, self, _amount)

	balance_vault: uint256 = self.holoclear.balanceOf(self)

	if balance_vault < _amount:
		_amount_to_mint: uint256 = _amount - balance_vault

		self.holoclear.mint(self, _amount_to_mint)

	info: Claim = self.stakeInfo[_to]

	expiry_time: uint256 = block.timestamp + self.escrowPeriod

	if self.escrowPeriod > 0:

		self.stakeInfo[_to] = Claim({deposit: info.deposit + _amount,
									expiry: expiry_time})

		self.holoclear.transfer(self.escrow.address, _amount)

	else:

		self.holoclear.transfer(_to, _amount)

	self._rebase()

	return True