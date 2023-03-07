# @version 0.3.7

struct Deposit:
    depositor: address
    from_token: address
    to_token: address
    input_amount: uint256
    number_trades: uint256
    interval: uint256
    starting_time: uint256

interface PancakeswapRouter:
    def swapExactTokensForTokens(amountIn: uint256, amountOutMin: uint256, path: DynArray[address, 8], to: address, deadline: uint256): nonpayable
    def getAmountsOut(amountIn: uint256, path: DynArray[address, 8]) -> DynArray[uint256, 7]: view

compass_evm: public(address)
admin: public(address)
deposit_list: HashMap[uint256, Deposit]
next_deposit: public(uint256)
PANCAKESWAP_ROUTER: constant(address) = 0x10ED43C718714eb63d5aA57B78B54704E256024E

@external
def __init__(_compass_evm: address):
    self.compass_evm = _compass_evm
    self.admin = msg.sender

@internal
def _safe_transfer_from(_token: address, _from: address, _to: address, _value: uint256):
    _response: Bytes[32] = raw_call(
        _token,
        _abi_encode(_from, _to, _value, method_id=method_id("transferFrom(address,address,uint256)")),
        max_outsize=32
    )  # dev: failed transferFrom
    if len(_response) > 0:
        assert convert(_response, bool), "failed transferFrom"  # dev: failed transferFrom

@external
def deposit(from_token: address, to_token: address, input_amount: uint256, number_trades: uint256, interval: uint256, starting_time: uint256):
    self._safe_transfer_from(from_token, msg.sender, self, input_amount)
    _next_deposit: uint256 = self.next_deposit
    self.deposit_list[_next_deposit] = Deposit({
        depositor: msg.sender,
        from_token: from_token,
        to_token: to_token,
        input_amount: input_amount,
        number_trades: number_trades,
        interval: interval,
        starting_time: starting_time
    })
    _next_deposit += 1
    self.next_deposit = _next_deposit

@internal
def _safe_approve(_token: address, _to: address, _value: uint256):
    _response: Bytes[32] = raw_call(
        _token,
        _abi_encode(_to, _value, method_id=method_id("approve(address,uint256)")),
        max_outsize=32
    )  # dev: failed approve
    if len(_response) > 0:
        assert convert(_response, bool), "failed approve"  # dev: failed approve

@external
def swap(swap_id: uint256, amount_out_min: uint256):
    assert msg.sender == self.compass_evm, "not compass"
    _next_deposit: uint256 = self.next_deposit
    assert swap_id < _next_deposit
    _deposit: Deposit = self.deposit_list[swap_id]
    assert _deposit.number_trades > 0, "all traded"
    assert _deposit.starting_time + _deposit.interval <= block.timestamp
    _amount: uint256 = _deposit.input_amount / _deposit.number_trades
    _deposit.input_amount -= _amount
    _deposit.number_trades -= 1
    _deposit.starting_time = block.timestamp
    self._safe_approve(_deposit.from_token, PANCAKESWAP_ROUTER, _amount)
    PancakeswapRouter(PANCAKESWAP_ROUTER).swapExactTokensForTokens(_amount, amount_out_min, [_deposit.from_token, _deposit.to_token], _deposit.depositor, block.timestamp)
    if _deposit.number_trades == 0:
        if swap_id < _next_deposit - 1:
            self.deposit_list[swap_id] = self.deposit_list[_next_deposit - 1]
        self.next_deposit = _next_deposit - 1
    else:
        self.deposit_list[swap_id] = _deposit

@view
@external
def triggerable_deposit() -> (uint256, uint256, uint256):
    assert msg.sender == ZERO_ADDRESS
    _size: uint256 = self.next_deposit
    for i in range(1000000):
        if i == _size:
            return 0, 0, 0
        _deposit: Deposit = self.deposit_list[i]
        if _deposit.starting_time + _deposit.interval <= block.timestamp:
            _amount: uint256 = _deposit.input_amount / _deposit.number_trades
            _out_amount: DynArray[uint256, 7] = PancakeswapRouter(PANCAKESWAP_ROUTER).getAmountsOut(_amount, [_deposit.from_token, _deposit.to_token])
            return i, _out_amount[0] * 99 / 100, _deposit.number_trades
    return 0, 0, 0