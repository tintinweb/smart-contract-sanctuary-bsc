# @version ^0.3.0

# HOLO eco-system presale fund raising management contract!

# ===== INTERFACES ===== #

interface IpHOLO:
	def mint(_to: address, _val: uint256) -> bool: nonpayable

interface IGRVSNAP:
	def balanceOf(_who: address) -> uint256: view
	def approve(spender: address, tokens: uint256) -> bool: nonpayable
	def transferFrom(frm: address, to: address, token: uint256) -> bool: nonpayable
	def allowance(token_owner: address, spender: address) -> uint256: view


# ===== EVENTS ===== #

event TokenPurchase:
    _from: indexed(address)
    _to: indexed(address)
    _bnb: uint256
    _pholo: uint256

# ===== STATE VARIABLES ===== #

price_sf: constant(uint256) = 10 ** 18

owner: address

pHOLO: IpHOLO

GRVSNAP: IGRVSNAP
GRVSNAP_bonus: public(HashMap[address, uint256])
GRVSNAP_redeem: public(bool)
redeem_rate: uint256

price: public(uint256)

BNB_remaining: public(uint256)
BNB_raised: public(uint256)

tranche_cap: public(uint256)

min_purchase_amount: public(uint256)
max_purchase_amount: public(uint256)
max_per_wallet: public(uint256)

purchases_per_wallet: HashMap[address, uint256]

opening_time: public(uint256)
closing_time: public(uint256)

wallet: address

# ===== INIT ===== #

@external
def __init__(_pHOLO: address, _BNB_remaining: uint256, _opening_time: uint256, _closing_time: uint256, _price: uint256, _max_per_wallet: uint256, _min_purchase_amount: uint256, _max_purchase_amount: uint256, _wallet: address,
	grv_snap_address: address):

	self.owner = msg.sender

	self.pHOLO = IpHOLO(_pHOLO)
	self.GRVSNAP = IGRVSNAP(grv_snap_address)
	self.GRVSNAP_redeem = False
	self.BNB_remaining = _BNB_remaining
	self.tranche_cap = _BNB_remaining
	self.opening_time = _opening_time
	self.closing_time = _closing_time
	self.price = _price
	self.min_purchase_amount = _min_purchase_amount
	self.max_purchase_amount = _max_purchase_amount
	self.max_per_wallet = _max_per_wallet
	self.wallet = _wallet

# ===== MANAGEMENT FUNCTIONS ===== #

@external
def setOpeningTime(_opening_time: uint256) -> bool:

	assert msg.sender == self.owner

	self.opening_time = _opening_time

	return True

@external
def setClosingTime(_closing_time: uint256) -> bool:

	assert msg.sender == self.owner

	self.closing_time = _closing_time

	return True

@external
def setMinPurchaseAmount(_min_purchase_amount: uint256) -> bool:

	assert msg.sender == self.owner

	self.min_purchase_amount = _min_purchase_amount

	return True

@external
def setMaxPurchaseAmount(_max_purchase_amount: uint256) -> bool:

	assert msg.sender == self.owner

	self.max_purchase_amount = _max_purchase_amount

	return True

@external
def setMaxPerWallet(_max_per_wallet: uint256) -> bool:

	assert msg.sender == self.owner

	self.max_per_wallet = _max_per_wallet

	return True

@external
def setBNBRemaining(_BNB_remaining: uint256) -> bool:

	assert msg.sender == self.owner

	self.BNB_remaining = _BNB_remaining

	return True

@external
def setTrancheCap(_tranche_cap: uint256) -> bool:

	assert msg.sender == self.owner

	self.tranche_cap = _tranche_cap

	return True


@external
def setGRVSNAPRedeemOpen(_bool: bool) -> bool:

	assert msg.sender == self.owner

	self.GRVSNAP_redeem = _bool

	return True

@external
def setRedeemRate(_rate: uint256) -> bool:

	assert msg.sender == self.owner

	self.redeem_rate = _rate

	return True

@external
def setPrice(_price: uint256) -> bool:

	assert msg.sender == self.owner

	self.price = _price

	return True


# ===== MUTATIVE ===== #

@internal
def validatePurchase(_purchase_amount: uint256, _beneficiary: address) -> bool:

	assert block.timestamp >= self.opening_time, "Not open yet"
	assert block.timestamp < self.closing_time, "Closed"
	assert _purchase_amount > 0
	assert _purchase_amount >= self.min_purchase_amount, "Purchase under min size"
	assert _purchase_amount <= self.max_purchase_amount, "Purchase over max size"
	assert self.BNB_remaining >= _purchase_amount, "Purchase amount over hard cap"
	assert self.purchases_per_wallet[_beneficiary] <= self.max_per_wallet

	return True

@internal
def mintTokens(_to: address, _val: uint256) -> bool:

	self.pHOLO.mint(_to, _val)

	return True


@internal
def forwardFunds(_purchase_amount: uint256) -> bool:

	send(self.wallet, _purchase_amount)

	return True


@external
def redeemGRVSNAPBonus(_beneficiary: address) -> bool:

	assert self.GRVSNAP_redeem == True

	bal: uint256 = self.GRVSNAP_bonus[_beneficiary]

	num_tokens: uint256 = bal * self.redeem_rate / price_sf

	self.mintTokens(_beneficiary, num_tokens)

	return True


@external
@payable
@nonreentrant('lock')
def buyTokens(_beneficiary: address):

	purchase_amount: uint256 = msg.value

	self.purchases_per_wallet[_beneficiary] += purchase_amount

	num_tokens: uint256 = (purchase_amount * self.price) / price_sf

	self.validatePurchase(purchase_amount, _beneficiary)

	grv_allowance: uint256 = self.GRVSNAP.allowance(msg.sender, self)

	if grv_allowance > 0:

		self.GRVSNAP.transferFrom(msg.sender, self, grv_allowance)

		self.GRVSNAP_bonus[_beneficiary] += grv_allowance

	self.BNB_remaining -= purchase_amount
	self.BNB_raised += purchase_amount

	self.mintTokens(_beneficiary, num_tokens)

	self.forwardFunds(purchase_amount)