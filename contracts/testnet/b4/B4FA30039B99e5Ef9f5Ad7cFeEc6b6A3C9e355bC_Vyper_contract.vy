# @version ^0.3.0

# BANK

interface IQuote:
	def transfer(_to: address, _val: uint256) -> bool: nonpayable
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable


event Payment:
	_value: uint256
	_sender: address

owner: address

@external
def __init__():

	self.owner = msg.sender

@external
@payable
def __default__():
	log Payment(msg.value, msg.sender)
	

@external
def withdraw(_to: address, _amount: uint256) -> bool:

	assert msg.sender == self.owner

	send(_to, _amount)
	
	return True

@external
def withdraw_quote(_to: address, _quote_address: address, _amount: uint256) -> bool:

	assert msg.sender == self.owner

	quote: IQuote = IQuote(_quote_address)

	quote.transfer(_to, _amount)

	return True