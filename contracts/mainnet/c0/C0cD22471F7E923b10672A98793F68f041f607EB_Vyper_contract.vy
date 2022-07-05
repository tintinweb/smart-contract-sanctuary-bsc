# @version 0.3.3
"""
@title Ellipsis Registry Exchange Contract
@license MIT
@notice Find pools, query exchange rates and perform swaps
"""

from vyper.interfaces import ERC20


interface AddressProvider:
    def owner() -> address: view
    def get_registry() -> address: view
    def get_address(idx: uint256) -> address: view

interface CurvePool:
    def exchange(i: int128, j: int128, dx: uint256, min_dy: uint256): payable
    def exchange_underlying(i: int128, j: int128, dx: uint256, min_dy: uint256): payable
    def get_dy(i: int128, j: int128, amount: uint256) -> uint256: view
    def get_dy_underlying(i: int128, j: int128, amount: uint256) -> uint256: view

interface Registry:
    def address_provider() -> address: view
    def get_A(_pool: address) -> uint256: view
    def get_fees(_pool: address) -> uint256[2]: view
    def get_coin_indices(_pool: address, _from: address, _to: address) -> (int128, int128, bool): view
    def get_n_coins(_pool: address) -> uint256[2]: view
    def get_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_rates(_pool: address) -> uint256[MAX_COINS]: view
    def get_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def find_pool_for_coins(_from: address, _to: address, i: uint256) -> address: view
    def get_lp_token(_pool: address) -> address: view


event TokenExchange:
    buyer: indexed(address)
    receiver: indexed(address)
    pool: indexed(address)
    token_sold: address
    token_bought: address
    amount_sold: uint256
    amount_bought: uint256


ETH_ADDRESS: constant(address) = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
MAX_COINS: constant(int128) = 4
EMPTY_POOL_LIST: constant(address[8]) = [
    ZERO_ADDRESS,
    ZERO_ADDRESS,
    ZERO_ADDRESS,
    ZERO_ADDRESS,
    ZERO_ADDRESS,
    ZERO_ADDRESS,
    ZERO_ADDRESS,
    ZERO_ADDRESS,
]


address_provider: public(AddressProvider)
is_killed: public(bool)

is_approved: HashMap[address, HashMap[address, bool]]


@external
def __init__(_address_provider: AddressProvider):
    """
    @notice Constructor function
    """
    self.address_provider = _address_provider


@external
@payable
def __default__():
    pass


@view
@internal
def _get_exchange_amount(
    _registry: address,
    _pool: address,
    _from: address,
    _to: address,
    _amount: uint256
) -> uint256:
    """
    @notice Get the current number of coins received in an exchange
    @param _registry Registry address
    @param _pool Pool address
    @param _from Address of coin to be sent
    @param _to Address of coin to be received
    @param _amount Quantity of `_from` to be sent
    @return Quantity of `_to` to be received
    """
    i: int128 = 0
    j: int128 = 0
    is_underlying: bool = False
    success: bool = False
    response: Bytes[32] = b""

    i, j, is_underlying = Registry(_registry).get_coin_indices(_pool, _from, _to) # dev: no market

    if is_underlying:
        success, response = raw_call(
            _pool,
            _abi_encode(i, j, _amount, method_id=method_id("get_dy_underlying(int128,int128,uint256)")),
            is_static_call=True,
            max_outsize=32,
            revert_on_failure=False,
        )
    else:
        success, response = raw_call(
            _pool,
            _abi_encode(i, j, _amount, method_id=method_id("get_dy(int128,int128,uint256)")),
            is_static_call=True,
            max_outsize=32,
            revert_on_failure=False,
        )

    if success:
        return convert(response, uint256)
    else:
        return 0


@internal
def _exchange(
    _registry: address,
    _pool: address,
    _from: address,
    _to: address,
    _amount: uint256,
    _expected: uint256,
    _sender: address,
    _receiver: address,
) -> uint256:

    assert not self.is_killed

    initial_balance: uint256 = 0
    eth_amount: uint256 = 0
    received_amount: uint256 = 0

    i: int128 = 0
    j: int128 = 0
    is_underlying: bool = False
    i, j, is_underlying = Registry(_registry).get_coin_indices(_pool, _from, _to)  # dev: no market

    # record initial balance
    if _to == ETH_ADDRESS:
        initial_balance = self.balance
    else:
        initial_balance = ERC20(_to).balanceOf(self)

    # perform / verify input transfer
    if _from == ETH_ADDRESS:
        eth_amount = _amount
    else:
        response: Bytes[32] = raw_call(
            _from,
            _abi_encode(_sender, self, _amount, method_id=method_id("transferFrom(address,address,uint256)")),
            max_outsize=32,
        )
        if len(response) != 0:
            assert convert(response, bool)

    # approve input token
    if not self.is_approved[_from][_pool]:
        response: Bytes[32] = raw_call(
            _from,
            _abi_encode(_pool, MAX_UINT256, method_id=method_id("approve(address,uint256)")),
            max_outsize=32,
        )
        if len(response) != 0:
            assert convert(response, bool)
        self.is_approved[_from][_pool] = True

    # perform coin exchange
    if is_underlying:
        CurvePool(_pool).exchange_underlying(i, j, _amount, _expected, value=eth_amount)
    else:
        CurvePool(_pool).exchange(i, j, _amount, _expected, value=eth_amount)

    # perform output transfer
    if _to == ETH_ADDRESS:
        received_amount = self.balance - initial_balance
        raw_call(_receiver, b"", value=received_amount)
    else:
        received_amount = ERC20(_to).balanceOf(self) - initial_balance
        response: Bytes[32] = raw_call(
            _to,
            _abi_encode(_receiver, received_amount, method_id=method_id("transfer(address,uint256)")),
            max_outsize=32,
        )
        if len(response) != 0:
            assert convert(response, bool)

    log TokenExchange(_sender, _receiver, _pool, _from, _to, _amount, received_amount)

    return received_amount


@payable
@external
@nonreentrant("lock")
def exchange_with_best_rate(
    _from: address,
    _to: address,
    _amount: uint256,
    _expected: uint256,
    _receiver: address = msg.sender,
) -> uint256:
    """
    @notice Perform an exchange using the pool that offers the best rate
    @dev Prior to calling this function, the caller must approve
         this contract to transfer `_amount` coins from `_from`
         Does NOT check rates in factory-deployed pools
    @param _from Address of coin being sent
    @param _to Address of coin being received
    @param _amount Quantity of `_from` being sent
    @param _expected Minimum quantity of `_from` received
           in order for the transaction to succeed
    @param _receiver Address to transfer the received tokens to
    @return uint256 Amount received
    """
    if _from == ETH_ADDRESS:
        assert _amount == msg.value, "Incorrect BNB amount"
    else:
        assert msg.value == 0, "Incorrect BNB amount"

    registry: address = self.address_provider.get_registry()
    best_pool: address = ZERO_ADDRESS
    max_dy: uint256 = 0
    for i in range(65536):
        pool: address = Registry(registry).find_pool_for_coins(_from, _to, i)
        if pool == ZERO_ADDRESS:
            break
        dy: uint256 = self._get_exchange_amount(registry, pool, _from, _to, _amount)
        if dy > max_dy:
            best_pool = pool
            max_dy = dy

    return self._exchange(registry, best_pool, _from, _to, _amount, _expected, msg.sender, _receiver)


@payable
@external
@nonreentrant("lock")
def exchange(
    _pool: address,
    _from: address,
    _to: address,
    _amount: uint256,
    _expected: uint256,
    _receiver: address = msg.sender,
) -> uint256:
    """
    @notice Perform an exchange using a specific pool
    @dev Prior to calling this function, the caller must approve
         this contract to transfer `_amount` coins from `_from`
         Works for both regular and factory-deployed pools
    @param _pool Address of the pool to use for the swap
    @param _from Address of coin being sent
    @param _to Address of coin being received
    @param _amount Quantity of `_from` being sent
    @param _expected Minimum quantity of `_from` received
           in order for the transaction to succeed
    @param _receiver Address to transfer the received tokens to
    @return uint256 Amount received
    """
    if _from == ETH_ADDRESS:
        assert _amount == msg.value, "Incorrect BNB amount"
    else:
        assert msg.value == 0, "Incorrect BNB amount"

    registry: address = self.address_provider.get_registry()
    return self._exchange(registry, _pool, _from, _to, _amount, _expected, msg.sender, _receiver)


@view
@external
def get_best_rate(
    _from: address, _to: address, _amount: uint256, _exclude_pools: address[8] = EMPTY_POOL_LIST
) -> (address, uint256):
    """
    @notice Find the pool offering the best rate for a given swap.
    @dev Checks rates for regular and factory pools
    @param _from Address of coin being sent
    @param _to Address of coin being received
    @param _amount Quantity of `_from` being sent
    @param _exclude_pools A list of up to 8 addresses which shouldn't be returned
    @return Pool address, amount received
    """
    best_pool: address = ZERO_ADDRESS
    max_dy: uint256 = 0
    registry: address = self.address_provider.get_registry()
    for i in range(65536):
        pool: address = Registry(registry).find_pool_for_coins(_from, _to, i)
        if pool == ZERO_ADDRESS:
            break
        elif pool in _exclude_pools:
            continue
        dy: uint256 = self._get_exchange_amount(registry, pool, _from, _to, _amount)
        if dy > max_dy:
            best_pool = pool
            max_dy = dy

    return best_pool, max_dy


@view
@external
def get_exchange_amount(_pool: address, _from: address, _to: address, _amount: uint256) -> uint256:
    """
    @notice Get the current number of coins received in an exchange
    @dev Works for both regular and factory-deployed pools
    @param _pool Pool address
    @param _from Address of coin to be sent
    @param _to Address of coin to be received
    @param _amount Quantity of `_from` to be sent
    @return Quantity of `_to` to be received
    """
    registry: address = self.address_provider.get_registry()
    return self._get_exchange_amount(registry, _pool, _from, _to, _amount)


@external
def claim_balance(_token: address) -> bool:
    """
    @notice Transfer an ERC20 or BNB balance held by this contract
    @dev The entire balance is transferred to the owner
    @param _token Token address
    @return bool success
    """
    assert msg.sender == self.address_provider.owner(), "Only owner"

    if _token == ETH_ADDRESS:
        raw_call(msg.sender, b"", value=self.balance)
    else:
        amount: uint256 = ERC20(_token).balanceOf(self)
        response: Bytes[32] = raw_call(
            _token,
            _abi_encode(msg.sender, amount, method_id=method_id("transfer(address,uint256)")),
            max_outsize=32,
        )
        if len(response) != 0:
            assert convert(response, bool)

    return True


@external
def set_killed(_is_killed: bool) -> bool:
    """
    @notice Kill or unkill the contract
    @param _is_killed Killed status of the contract
    @return bool success
    """
    assert msg.sender == self.address_provider.owner(), "Only owner"
    self.is_killed = _is_killed

    return True