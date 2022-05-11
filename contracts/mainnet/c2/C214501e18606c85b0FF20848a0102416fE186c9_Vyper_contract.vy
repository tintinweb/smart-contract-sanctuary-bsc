# @version 0.3.1
"""
@title "Zap" Depositer for permissionless factory metapools
@notice Compatible with metapools using valbtcEPS and btcEPS as a base
@author Curve.Fi
@license Copyright (c) Curve.Fi, 2021 - all rights reserved
"""

interface ERC20:
    def approve(_spender: address, _amount: uint256): nonpayable
    def balanceOf(_owner: address) -> uint256: view
    def transfer(_to: address, _amount: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _amount: uint256) -> bool: nonpayable

interface CurveMeta:
    def add_liquidity(amounts: uint256[N_COINS], min_mint_amount: uint256) -> uint256: nonpayable
    def remove_liquidity(_amount: uint256, min_amounts: uint256[N_COINS]): nonpayable
    def remove_liquidity_one_coin(_token_amount: uint256, i: int128, min_amount: uint256) -> uint256: nonpayable
    def remove_liquidity_imbalance(amounts: uint256[N_COINS], max_burn_amount: uint256) -> uint256: nonpayable
    def calc_withdraw_one_coin(_token_amount: uint256, i: int128) -> uint256: view
    def calc_token_amount(amounts: uint256[N_COINS], deposit: bool) -> uint256: view
    def lp_token() -> address: view
    def coins(i: uint256) -> address: view

interface CurveBase:
    def add_liquidity(amounts: uint256[BASE_N_COINS], min_mint_amount: uint256): nonpayable
    def remove_liquidity(_amount: uint256, min_amounts: uint256[BASE_N_COINS]): nonpayable
    def remove_liquidity_one_coin(_token_amount: uint256, i: int128, min_amount: uint256): nonpayable
    def remove_liquidity_imbalance(amounts: uint256[BASE_N_COINS], max_burn_amount: uint256): nonpayable
    def calc_withdraw_one_coin(_token_amount: uint256, i: int128) -> uint256: view
    def calc_token_amount(amounts: uint256[BASE_N_COINS], deposit: bool) -> uint256: view
    def coins(i: uint256) -> address: view
    def fee() -> uint256: view


BASE_N_COINS: constant(int128) = 2
BASE_COINS: constant(address[BASE_N_COINS]) = [
    0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c,  # BTCB
    0xfCe146bF3146100cfe5dB4129cf6C82b0eF4Ad8c,  # renBTC
]
N_COINS: constant(int128) = 2
MAX_COIN: constant(int128) = N_COINS-1
N_ALL_COINS: constant(int128) = N_COINS + BASE_N_COINS - 1

FEE_DENOMINATOR: constant(uint256) = 10 ** 10
FEE_IMPRECISION: constant(uint256) = 100 * 10 ** 8  # % of the fee

# coin -> pool -> is approved to transfer?
is_approved: HashMap[address, HashMap[address, bool]]

lp_token_to_base_pool: public(HashMap[address, address])
pool_to_base_pool: public(HashMap[address, address[2]])

owner: public(address)


@external
def __init__():
    self.owner = msg.sender


@external
def add_base_pool(_pool: address, _lp_token: address):
    assert msg.sender == self.owner
    self.lp_token_to_base_pool[_lp_token] = _pool


@external
def recover_tokens(_token: address, _amount: uint256):
    assert msg.sender == self.owner
    response: Bytes[32] = raw_call(
        _token,  # metapool coin 0
        _abi_encode(
            msg.sender,
            _amount,
            method_id=method_id("transfer(address,uint256)"),
        ),
        max_outsize=32
    )
    if len(response) != 0:
        assert convert(response, bool)



@internal
def _get_base_pool(_pool: address) -> (address, address):
    base_pool: address[2] = self.pool_to_base_pool[_pool]

    if base_pool[0] == ZERO_ADDRESS:
        base_pool[1] = CurveMeta(_pool).coins(1)
        base_pool[0] = self.lp_token_to_base_pool[base_pool[1]]
        assert base_pool[0] != ZERO_ADDRESS, "Zap does not support this base pool"
        self.pool_to_base_pool[_pool] = base_pool
        for coin in BASE_COINS:
            ERC20(coin).approve(base_pool[0], MAX_UINT256)

    return base_pool[0], base_pool[1]


@external
def add_liquidity(
    _pool: address,
    _deposit_amounts: uint256[N_ALL_COINS],
    _min_mint_amount: uint256,
    _receiver: address = msg.sender,
) -> uint256:
    """
    @notice Wrap underlying coins and deposit them into `_pool`
    @param _pool Address of the pool to deposit into
    @param _deposit_amounts List of amounts of underlying coins to deposit
    @param _min_mint_amount Minimum amount of LP tokens to mint from the deposit
    @param _receiver Address that receives the LP tokens
    @return Amount of LP tokens received by depositing
    """
    meta_amounts: uint256[N_COINS] = empty(uint256[N_COINS])
    base_amounts: uint256[BASE_N_COINS] = empty(uint256[BASE_N_COINS])
    deposit_base: bool = False
    base_coins: address[BASE_N_COINS] = BASE_COINS

    if _deposit_amounts[0] != 0:
        coin: address = CurveMeta(_pool).coins(0)
        if not self.is_approved[coin][_pool]:
            ERC20(coin).approve(_pool, MAX_UINT256)
            self.is_approved[coin][_pool] = True
        response: Bytes[32] = raw_call(
            coin,
            _abi_encode(
                msg.sender,
                self,
                _deposit_amounts[0],
                method_id=method_id("transferFrom(address,address,uint256)"),
            ),
            max_outsize=32
        )
        if len(response) != 0:
            assert convert(response, bool)
        # hand fee on transfer
        meta_amounts[0] = ERC20(coin).balanceOf(self)

    for i in range(1, N_ALL_COINS):
        amount: uint256 = _deposit_amounts[i]
        if amount == 0:
            continue
        deposit_base = True
        base_idx: uint256 = i - 1
        coin: address = base_coins[base_idx]

        response: Bytes[32] = raw_call(
            coin,
            _abi_encode(
                msg.sender,
                self,
                amount,
                method_id=method_id("transferFrom(address,address,uint256)"),
            ),
            max_outsize=32
        )
        if len(response) != 0:
            assert convert(response, bool)

        # Handle potential transfer fees (i.e. Tether/renBTC)
        base_amounts[base_idx] = ERC20(coin).balanceOf(self)

    # Deposit to the base pool
    if deposit_base:
        base_pool: address = ZERO_ADDRESS
        base_token: address = ZERO_ADDRESS
        base_pool, base_token = self._get_base_pool(_pool)
        CurveBase(base_pool).add_liquidity(base_amounts, 0)
        meta_amounts[MAX_COIN] = ERC20(base_token).balanceOf(self)
        if not self.is_approved[base_token][_pool]:
            ERC20(base_token).approve(_pool, MAX_UINT256)
            self.is_approved[base_token][_pool] = True

    # Deposit to the meta pool
    received: uint256 = CurveMeta(_pool).add_liquidity(meta_amounts, _min_mint_amount)
    lp_token: address = CurveMeta(_pool).lp_token()
    ERC20(lp_token).transfer(_receiver, received)
    return received


@external
def remove_liquidity(
    _pool: address,
    _burn_amount: uint256,
    _min_amounts: uint256[N_ALL_COINS],
    _receiver: address = msg.sender
) -> uint256[N_ALL_COINS]:
    """
    @notice Withdraw and unwrap coins from the pool
    @dev Withdrawal amounts are based on current deposit ratios
    @param _pool Address of the pool to deposit into
    @param _burn_amount Quantity of LP tokens to burn in the withdrawal
    @param _min_amounts Minimum amounts of underlying coins to receive
    @param _receiver Address that receives the LP tokens
    @return List of amounts of underlying coins that were withdrawn
    """
    lp_token: address = CurveMeta(_pool).lp_token()
    ERC20(lp_token).transferFrom(msg.sender, self, _burn_amount)

    min_amounts_base: uint256[BASE_N_COINS] = empty(uint256[BASE_N_COINS])
    amounts: uint256[N_ALL_COINS] = empty(uint256[N_ALL_COINS])

    # Withdraw from meta
    meta_received: uint256[N_COINS] = empty(uint256[N_COINS])
    CurveMeta(_pool).remove_liquidity(_burn_amount, [_min_amounts[0], convert(0, uint256)])

    coins: address[N_COINS] = empty(address[N_COINS])
    for i in range(N_COINS):
        coin: address = CurveMeta(_pool).coins(i)
        coins[i] = coin
        # Handle fee on transfer for the first coin
        meta_received[i] = ERC20(coin).balanceOf(self)

    # Withdraw from base
    for i in range(BASE_N_COINS):
        min_amounts_base[i] = _min_amounts[MAX_COIN+i]

    base_pool: address = self._get_base_pool(_pool)[0]
    CurveBase(base_pool).remove_liquidity(meta_received[MAX_COIN], min_amounts_base)

    # Transfer all coins out
    response: Bytes[32] = raw_call(
        coins[0],  # metapool coin 0
        _abi_encode(
            _receiver,
            meta_received[0],
            method_id=method_id("transfer(address,uint256)"),
        ),
        max_outsize=32
    )
    if len(response) != 0:
        assert convert(response, bool)

    amounts[0] = meta_received[0]

    base_coins: address[BASE_N_COINS] = BASE_COINS
    for i in range(1, N_ALL_COINS):
        coin: address = base_coins[i-1]
        # handle potential fee on transfer
        amounts[i] = ERC20(coin).balanceOf(self)
        response = raw_call(
            coin,
            _abi_encode(
                _receiver,
                amounts[i],
                method_id=method_id("transfer(address,uint256)"),
            ),
            max_outsize=32
        )
        if len(response) != 0:
            assert convert(response, bool)


    return amounts


@external
def remove_liquidity_one_coin(
    _pool: address,
    _burn_amount: uint256,
    i: int128,
    _min_amount: uint256,
    _receiver: address=msg.sender
) -> uint256:
    """
    @notice Withdraw and unwrap a single coin from the pool
    @param _pool Address of the pool to deposit into
    @param _burn_amount Amount of LP tokens to burn in the withdrawal
    @param i Index value of the coin to withdraw
    @param _min_amount Minimum amount of underlying coin to receive
    @param _receiver Address that receives the LP tokens
    @return Amount of underlying coin received
    """
    lp_token: address = CurveMeta(_pool).lp_token()
    response: Bytes[32] = raw_call(
        lp_token,
        _abi_encode(
            msg.sender,
            self,
            _burn_amount,
            method_id=method_id("transferFrom(address,address,uint256)"),
        ),
        max_outsize=32
    )
    if len(response) != 0:
        assert convert(response, bool)


    coin_amount: uint256 = 0
    coin: address = ZERO_ADDRESS
    if i == 0:
        coin_amount = CurveMeta(_pool).remove_liquidity_one_coin(_burn_amount, i, _min_amount)
        coin = CurveMeta(_pool).coins(0)
    else:
        base_coins: address[BASE_N_COINS] = BASE_COINS
        coin = base_coins[i - MAX_COIN]
        # Withdraw a base pool coin
        coin_amount = CurveMeta(_pool).remove_liquidity_one_coin(_burn_amount, MAX_COIN, 0)
        base_pool: address = self._get_base_pool(_pool)[0]
        CurveBase(base_pool).remove_liquidity_one_coin(coin_amount, i-MAX_COIN, _min_amount)
        coin_amount = ERC20(coin).balanceOf(self)

    response = raw_call(
        coin,
        _abi_encode(
            _receiver,
            coin_amount,
            method_id=method_id("transfer(address,uint256)"),
        ),
        max_outsize=32
    )
    if len(response) != 0:
        assert convert(response, bool)

    return coin_amount


@external
def remove_liquidity_imbalance(
    _pool: address,
    _amounts: uint256[N_ALL_COINS],
    _max_burn_amount: uint256,
    _receiver: address=msg.sender
) -> uint256:
    """
    @notice Withdraw coins from the pool in an imbalanced amount
    @param _pool Address of the pool to deposit into
    @param _amounts List of amounts of underlying coins to withdraw
    @param _max_burn_amount Maximum amount of LP token to burn in the withdrawal
    @param _receiver Address that receives the LP tokens
    @return Actual amount of the LP token burned in the withdrawal
    """
    base_pool: address = ZERO_ADDRESS
    base_token: address = ZERO_ADDRESS
    base_pool, base_token = self._get_base_pool(_pool)
    fee: uint256 = CurveBase(base_pool).fee() * BASE_N_COINS / (4 * (BASE_N_COINS - 1))
    fee += fee * FEE_IMPRECISION / FEE_DENOMINATOR  # Overcharge to account for imprecision
    lp_token: address = CurveMeta(_pool).lp_token()
    # Transfer the LP token in
    ERC20(lp_token).transferFrom(msg.sender, self, _max_burn_amount)

    withdraw_base: bool = False
    amounts_base: uint256[BASE_N_COINS] = empty(uint256[BASE_N_COINS])
    amounts_meta: uint256[N_COINS] = empty(uint256[N_COINS])

    # determine amounts to withdraw from base pool
    for i in range(BASE_N_COINS):
        amount: uint256 = _amounts[MAX_COIN + i]
        if amount != 0:
            amounts_base[i] = amount
            withdraw_base = True

    # determine amounts to withdraw from metapool
    amounts_meta[0] = _amounts[0]
    if withdraw_base:
        amounts_meta[MAX_COIN] = CurveBase(base_pool).calc_token_amount(amounts_base, False)
        amounts_meta[MAX_COIN] += amounts_meta[MAX_COIN] * fee / FEE_DENOMINATOR + 1

    # withdraw from metapool and return the remaining LP tokens
    burn_amount: uint256 = CurveMeta(_pool).remove_liquidity_imbalance(amounts_meta, _max_burn_amount)
    ERC20(lp_token).transfer(msg.sender, _max_burn_amount - burn_amount)

    # withdraw from base pool
    if withdraw_base:
        CurveBase(base_pool).remove_liquidity_imbalance(amounts_base, amounts_meta[MAX_COIN])
        leftover: uint256 = ERC20(base_token).balanceOf(self)

        if leftover > 0:
            # if some base pool LP tokens remain, re-deposit them for the caller
            if not self.is_approved[base_token][_pool]:
                ERC20(base_token).approve(_pool, MAX_UINT256)
                self.is_approved[base_token][_pool] = True
            burn_amount -= CurveMeta(_pool).add_liquidity([convert(0, uint256), leftover], 0)

        # transfer withdrawn base pool tokens to caller
        base_coins: address[BASE_N_COINS] = BASE_COINS
        for i in range(BASE_N_COINS):
            response: Bytes[32] = raw_call(
                base_coins[i],
                _abi_encode(
                    _receiver,
                    ERC20(base_coins[i]).balanceOf(self),  # handle potential transfer fees
                    method_id=method_id("transfer(address,uint256)"),
                ),
                max_outsize=32
            )
            if len(response) != 0:
                assert convert(response, bool)


    # transfer withdrawn metapool tokens to caller
    if _amounts[0] > 0:
        coin: address = CurveMeta(_pool).coins(0)
        response: Bytes[32] = raw_call(
            coin,
            _abi_encode(
                _receiver,
                ERC20(coin).balanceOf(self),  # handle potential fees
                method_id=method_id("transfer(address,uint256)"),
            ),
            max_outsize=32
        )
        if len(response) != 0:
            assert convert(response, bool)


    return burn_amount


@view
@external
def calc_withdraw_one_coin(_pool: address, _token_amount: uint256, i: int128) -> uint256:
    """
    @notice Calculate the amount received when withdrawing and unwrapping a single coin
    @param _pool Address of the pool to deposit into
    @param _token_amount Amount of LP tokens to burn in the withdrawal
    @param i Index value of the underlying coin to withdraw
    @return Amount of coin received
    """
    if i < MAX_COIN:
        return CurveMeta(_pool).calc_withdraw_one_coin(_token_amount, i)
    else:
        _base_tokens: uint256 = CurveMeta(_pool).calc_withdraw_one_coin(_token_amount, MAX_COIN)
        base_pool: address = self.lp_token_to_base_pool[CurveMeta(_pool).coins(1)]
        return CurveBase(base_pool).calc_withdraw_one_coin(_base_tokens, i-MAX_COIN)


@view
@external
def calc_token_amount(_pool: address, _amounts: uint256[N_ALL_COINS], _is_deposit: bool) -> uint256:
    """
    @notice Calculate addition or reduction in token supply from a deposit or withdrawal
    @dev This calculation accounts for slippage, but not fees.
         Needed to prevent front-running, not for precise calculations!
    @param _pool Address of the pool to deposit into
    @param _amounts Amount of each underlying coin being deposited
    @param _is_deposit set True for deposits, False for withdrawals
    @return Expected amount of LP tokens received
    """
    meta_amounts: uint256[N_COINS] = empty(uint256[N_COINS])
    base_amounts: uint256[BASE_N_COINS] = empty(uint256[BASE_N_COINS])

    meta_amounts[0] = _amounts[0]
    for i in range(BASE_N_COINS):
        base_amounts[i] = _amounts[i + MAX_COIN]

    base_pool: address = self.lp_token_to_base_pool[CurveMeta(_pool).coins(1)]
    base_tokens: uint256 = CurveBase(base_pool).calc_token_amount(base_amounts, _is_deposit)
    meta_amounts[MAX_COIN] = base_tokens

    return CurveMeta(_pool).calc_token_amount(meta_amounts, _is_deposit)