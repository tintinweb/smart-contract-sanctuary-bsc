# @version ^0.3.0

# LPManager

interface iAddLP:
	def add_LP_pair(_name: bytes32, _token: address, _cross: bool, _router: address) -> bool: nonpayable

# ===== EVENTS ===== #

event LPAdded:
	_name: bytes32
	token: address
	cross: bool
	router: address


# ===== STATE VARIABLES ===== #

contracts: public(DynArray[address, 32])
owner: public(address)

@external
def __init__():

	self.owner = msg.sender
	self.contracts = []

@external
def add_contract(contract_address: address):

	assert msg.sender == self.owner

	self.contracts.append(contract_address)

@external
def add_LP_pair(_name: bytes32, _token: address, _cross: bool, _router: address) -> bool:
	
	assert msg.sender == self.owner

	for contract_address in self.contracts:

		contract: iAddLP = iAddLP(contract_address)

		contract.add_LP_pair(_name, _token, _cross, _router)

	return True