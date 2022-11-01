# @version 0.3.7

# ESCROW

interface iHoloClear:
    def transfer(_to: address, _val: uint256) -> bool: nonpayable


# ===== STATE VARIABLES ===== #

holoclear: iHoloClear
vault_address: address

owner: immutable(address)
has_init: bool

@external
def __init__():

	owner = msg.sender

@external
def initialise(vault_address: address, 
			 holoclear_address: address):

	assert msg.sender == owner
	assert vault_address != empty(address)
	assert holoclear_address != empty(address)
	assert not self.has_init

	self.holoclear = iHoloClear(holoclear_address)
	self.vault_address = vault_address
	self.has_init = True


@external
def retrieve(_to: address, _amount: uint256) -> bool:

	assert msg.sender == self.vault_address
	assert _to != empty(address)

	self.holoclear.transfer(_to, _amount)

	return True