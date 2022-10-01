# @version ^0.3.0

# ESCROW

interface iHoloClear:
    def transfer(_to: address, _val: uint256) -> bool: nonpayable


# ===== STATE VARIABLES ===== #

holoclear: iHoloClear
vault_address: address

owner: address

@external
def __init__():

	self.owner = msg.sender

@external
def initialise(vault_address: address, 
			 holoclear_address: address):

	assert msg.sender == self.owner

	self.holoclear = iHoloClear(holoclear_address)
	self.vault_address = vault_address


@external
def retrieve(_to: address, _amount: uint256) -> bool:

	assert msg.sender == self.vault_address

	self.holoclear.transfer(_to, _amount)

	return True