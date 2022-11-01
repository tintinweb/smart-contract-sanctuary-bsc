# @version 0.3.7

# GRVSNAP BONUS


interface iOldManager:
	def GRVSNAP_bonus(arg0: address) -> uint256: view


# External Interfaces
interface iPHOLO:
	def mint(_to: address, _val: uint256) -> bool: nonpayable
	def balanceOf(arg0: address) -> uint256: view


old_manager: iOldManager
pholo: iPHOLO

owner: address

redeem_open: bool

has_interacted: public(HashMap[address, bool])

has_redeemed: public(HashMap[address, bool])

price_sf: constant(uint256) = 10 ** 18

redeem_rate: public(uint256)

@external
def __init__():

	self.owner = msg.sender


@external
def initialise(_old_manager: address, _pholo_address: address, _redeem_bool: bool, _rate: uint256):

	assert msg.sender == self.owner

	self.old_manager = iOldManager(_old_manager)
	self.pholo = iPHOLO(_pholo_address)
	self.redeem_open = _redeem_bool
	self.redeem_rate = _rate

@external
@nonreentrant('lock')
def redeem() -> uint256:

	assert self.has_redeemed[msg.sender] == False
	assert self.redeem_open == True
	assert self.old_manager.GRVSNAP_bonus(msg.sender) > 0

	bal: uint256 = self.old_manager.GRVSNAP_bonus(msg.sender)

	num_tokens: uint256 = bal * self.redeem_rate / price_sf

	self.pholo.mint(msg.sender, num_tokens)

	self.has_redeemed[msg.sender] = True

	return self.pholo.balanceOf(msg.sender)

@view
@external
def view_bonus(_to: address) -> uint256:

	return self.old_manager.GRVSNAP_bonus(_to)