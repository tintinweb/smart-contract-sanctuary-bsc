# @version ^0.3.0

# SWAP

interface IRouter:
	def factory() -> address: view
	def WETH() -> address: view
	def swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn: uint256, amountOutMin: uint256, path:  DynArray[address, 5], to: address, deadline: uint256): nonpayable
	def swapExactTokensForETH(amountIn: uint256, amountOutMin: uint256, path:  DynArray[address, 5], to: address, deadline: uint256): nonpayable
	def swapExactETHForTokensSupportingFeeOnTransferTokens(amountOutMin: uint256, path:  DynArray[address, 5], to: address, deadline: uint256) -> DynArray[uint256, 5]: payable
	def swapExactETHForTokens(amountOutMin: uint256, path:  DynArray[address, 5], to: address, deadline: uint256) -> DynArray[uint256, 5]: payable
	def swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn: uint256, amountOutMin: uint256, path:  DynArray[address, 5], to: address, deadline: uint256): nonpayable

interface iHoloClear:
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable
	def approve(_spender: address, _val: uint256) -> bool: nonpayable

interface IQuote:
	def transfer(_to: address, _val: uint256) -> bool: nonpayable
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable
	def approve(_spender: address, _val: uint256) -> bool: nonpayable
	def balanceOf(_who: address) -> uint256: view

event Payment:
	_value: uint256
	_sender: address

event Received:
	_amount: uint256

owner: address
router: IRouter
bank: address
holoclear: iHoloClear

fee: public(uint256)
demom: constant(uint256) = 10**18

@external
@payable
def __default__():
	log Payment(msg.value, msg.sender)
	

# ===== INIT ===== #

@external
def __init__():

	self.owner = msg.sender

@external
def initialise(_router: address, _bank: address, _holoclear: address):

	assert msg.sender == self.owner
	self.router = IRouter(_router)
	self.bank = _bank
	self.holoclear = iHoloClear(_holoclear)

# ===== SET PARAMETERS ===== #

@external
def set_fee(_fee: uint256):

	assert msg.sender == self.owner
	self.fee = _fee

# ===== MUTATIVE ===== #

@payable
@external
@nonreentrant('lock')
def swap_bnb_to_holo(_to: address):

	_fee: uint256 = msg.value * self.fee / demom
	_amount: uint256 = (msg.value - _fee )/ 10

	send(self.bank, _fee)

	_path: DynArray[address, 5] = []
	_path.append(self.router.WETH())
	_path.append(self.holoclear.address)

	self.router.swapExactETHForTokens(0, _path, _to, block.timestamp, value = _amount)

@payable
@external
@nonreentrant('lock')
def swap_holo_to_bnb(_to: address, _amount: uint256):

	self.holoclear.transferFrom(_to, self, _amount)

	_balance_before: uint256 = self.balance

	_path: DynArray[address, 5] = [self.holoclear.address, self.router.WETH()]

	self.holoclear.approve(self.router.address, _amount)

	self.router.swapExactTokensForETHSupportingFeeOnTransferTokens(_amount, 0, _path, self, block.timestamp + 100)

	_received: uint256 = self.balance - _balance_before

	log Received(_received)

	_fee: uint256 = _received * self.fee / demom

	send(self.bank, _fee)

	send(_to, _received - _fee)


@external
@nonreentrant('lock')
def swap_quote_to_holo(_to: address, _amount: uint256, _quote: address):

	quote: IQuote = IQuote(_quote)

	quote.transferFrom(_to, self, _amount)

	_fee: uint256 = _amount * self.fee / demom

	quote.transfer(self.bank, _fee)

	_swap_amount: uint256 = _amount - _fee

	_path: DynArray[address, 5] = [_quote, self.router.WETH(), self.holoclear.address]

	quote.approve(self.router.address, _swap_amount)

	self.router.swapExactTokensForTokensSupportingFeeOnTransferTokens(_swap_amount, 0, _path, _to, block.timestamp + 100)

@external
@nonreentrant('lock')
def swap_holo_to_quote(_to: address, _amount: uint256, _quote: address):

	quote: IQuote = IQuote(_quote)

	self.holoclear.transferFrom(_to, self, _amount)

	_balance_before: uint256 = quote.balanceOf(self)

	self.holoclear.approve(self.router.address, _amount)

	_path: DynArray[address, 5] = [self.holoclear.address, self.router.WETH(), _quote]

	self.router.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amount, 0, _path, self, block.timestamp + 100)

	_received: uint256 = quote.balanceOf(self) - _balance_before

	log Received(_received)

	_fee: uint256 = _received * self.fee / demom

	quote.transfer(self.bank, _fee)

	quote.transfer(_to, _received - _fee)