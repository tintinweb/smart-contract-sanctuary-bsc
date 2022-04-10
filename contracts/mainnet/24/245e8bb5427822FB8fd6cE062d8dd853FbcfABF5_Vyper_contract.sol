# @version 0.3.1
"""
@title StableSwap
@author Curve.Fi
@license Copyright (c) Curve.Fi, 2020-2021 - all rights reserved
@notice valToken/val3EPS metapool
"""

interface ERC20:
    def approve(_spender: address, _amount: uint256) -> bool: nonpayable
    def balanceOf(_owner: address) -> uint256: view
    def transfer(_to: address, _amount: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _amount: uint256) -> bool: nonpayable
    def decimals() -> uint256: view

interface Curve:
    def coins(i: uint256) -> address: view
    def get_virtual_price() -> uint256: view
    def calc_token_amount(amounts: uint256[BASE_N_COINS], deposit: bool) -> uint256: view
    def calc_withdraw_one_coin(_token_amount: uint256, i: int128) -> uint256: view
    def fee() -> uint256: view
    def get_dy(i: int128, j: int128, dx: uint256) -> uint256: view
    def exchange(i: int128, j: int128, dx: uint256, min_dy: uint256): nonpayable
    def add_liquidity(amounts: uint256[BASE_N_COINS], min_mint_amount: uint256): nonpayable
    def remove_liquidity_one_coin(_token_amount: uint256, i: int128, min_amount: uint256): nonpayable

interface Factory:
    def fee_receiver() -> address: view
    def admin() -> address: view

interface CurveToken:
    def totalSupply() -> uint256: view
    def mint(_to: address, _value: uint256) -> bool: nonpayable
    def burnFrom(_to: address, _value: uint256) -> bool: nonpayable

interface FeeDistributor:
    def depositFee(_token: address, _amount: uint256) -> bool: nonpayable

interface RewardsToken:
    def getReward(): nonpayable
    def notifyRewardAmount(_reward: address, _amount: uint256): nonpayable

interface AToken:
    def UNDERLYING_ASSET_ADDRESS() -> address: view

interface LendingPool:
    def withdraw(_underlying_asset: address, _amount: uint256, _receiver: address): nonpayable

interface ValasStaking:
    def exit(_claim_rewards: bool): nonpayable


event TokenExchange:
    buyer: indexed(address)
    sold_id: int128
    tokens_sold: uint256
    bought_id: int128
    tokens_bought: uint256

event TokenExchangeUnderlying:
    buyer: indexed(address)
    sold_id: int128
    tokens_sold: uint256
    bought_id: int128
    tokens_bought: uint256

event AddLiquidity:
    provider: indexed(address)
    token_amounts: uint256[N_COINS]
    fees: uint256[N_COINS]
    invariant: uint256
    token_supply: uint256

event RemoveLiquidity:
    provider: indexed(address)
    token_amounts: uint256[N_COINS]
    fees: uint256[N_COINS]
    token_supply: uint256

event RemoveLiquidityOne:
    provider: indexed(address)
    token_amount: uint256
    coin_amount: uint256
    token_supply: uint256

event RemoveLiquidityImbalance:
    provider: indexed(address)
    token_amounts: uint256[N_COINS]
    fees: uint256[N_COINS]
    invariant: uint256
    token_supply: uint256

event RampA:
    old_A: uint256
    new_A: uint256
    initial_time: uint256
    future_time: uint256

event StopRampA:
    A: uint256
    t: uint256


BASE_POOL: constant(address) = 0x19EC9e3F7B21dd27598E7ad5aAe7dC0Db00A806d
BASE_LP: constant(address) = 0x5b5bD8913D766D005859CE002533D4838B0Ebbb5
BASE_COINS: constant(address[3]) = [
    0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56,  # BUSD
    0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d,  # USDC
    0x55d398326f99059fF775485246999027B3197955,  # USDT
]

VALAS_TOKEN: constant(address) = 0xB1EbdD56729940089Ecc3aD0BBEEB12b6842ea6F
VALAS_REWARDS: constant(address) = 0xB7c1d99069a4eb582Fc04E7e1124794000e7ecBF
VALAS_STAKING: constant(address) = 0x685D3b02b9b0F044A3C01Dbb95408FC2eB15a3b3
LENDING_POOL: constant(address) = 0xE29A55A6AEFf5C8B1beedE5bCF2F0Cb3AF8F91f5


N_COINS: constant(int128) = 2
MAX_COIN: constant(int128) = N_COINS - 1
BASE_N_COINS: constant(int128) = 3
PRECISION: constant(uint256) = 10 ** 18

FEE_DENOMINATOR: constant(uint256) = 10 ** 10
ADMIN_FEE: constant(uint256) = 5000000000

A_PRECISION: constant(uint256) = 100
MAX_A: constant(uint256) = 10 ** 6
MAX_A_CHANGE: constant(uint256) = 10
MIN_RAMP_TIME: constant(uint256) = 86400

factory: public(address)

lp_token: public(address)
wrapped_coins: public(address[N_COINS])
coins: public(address[N_COINS])
admin_balances: public(uint256[N_COINS])
fee: public(uint256)  # fee * 1e10

initial_A: public(uint256)
future_A: public(uint256)
initial_A_time: public(uint256)
future_A_time: public(uint256)

rate_multiplier: uint256

is_killed: bool
kill_deadline: uint256
KILL_DEADLINE_DT: constant(uint256) = 2 * 30 * 86400

@external
def __init__(
    _lp_token: address,
    _wrapped_coin: address,
    _factory: address,
    _A: uint256,
    _fee: uint256
):
    """
    @notice Contract constructor
    @param _wrapped_coin Valas lending token to be used in the pool
    @param _A Amplification coefficient multiplied by n ** (n - 1)
    @param _fee Fee to charge for exchanges
    """
    A: uint256 = _A * A_PRECISION
    underlying_coin: address = AToken(_wrapped_coin).UNDERLYING_ASSET_ADDRESS()
    ERC20(underlying_coin).approve(LENDING_POOL, MAX_UINT256)
    self.wrapped_coins = [_wrapped_coin, BASE_LP]
    self.coins = [underlying_coin, BASE_LP]
    self.rate_multiplier = 10 ** (36 - ERC20(_wrapped_coin).decimals())
    self.initial_A = A
    self.future_A = A
    self.fee = _fee
    self.factory = _factory
    self.lp_token = _lp_token
    self.kill_deadline = block.timestamp + KILL_DEADLINE_DT

    assert ERC20(VALAS_TOKEN).approve(_lp_token, MAX_UINT256)
    for coin in BASE_COINS:
        ERC20(coin).approve(BASE_POOL, MAX_UINT256)


@view
@internal
def _balances() -> uint256[N_COINS]:
    result: uint256[N_COINS] = empty(uint256[N_COINS])
    for i in range(N_COINS):
        result[i] = ERC20(self.wrapped_coins[i]).balanceOf(self) - self.admin_balances[i]
    return result


@view
@external
def balances(i: uint256) -> uint256:
    """
    @notice Get the current balance of a coin within the
            pool, less the accrued admin fees
    @param i Index value for the coin to query balance of
    @return Token balance
    """
    return self._balances()[i]


@view
@external
def get_balances() -> uint256[N_COINS]:
    return self._balances()


@view
@internal
def _A() -> uint256:
    """
    Handle ramping A up or down
    """
    t1: uint256 = self.future_A_time
    A1: uint256 = self.future_A

    if block.timestamp < t1:
        A0: uint256 = self.initial_A
        t0: uint256 = self.initial_A_time
        # Expressions in uint256 cannot have negative numbers, thus "if"
        if A1 > A0:
            return A0 + (A1 - A0) * (block.timestamp - t0) / (t1 - t0)
        else:
            return A0 - (A0 - A1) * (block.timestamp - t0) / (t1 - t0)

    else:  # when t1 == 0 or block.timestamp >= t1
        return A1


@view
@external
def admin_fee() -> uint256:
    return ADMIN_FEE


@view
@external
def A() -> uint256:
    return self._A() / A_PRECISION


@view
@external
def A_precise() -> uint256:
    return self._A()


@pure
@internal
def _xp_mem(_rates: uint256[N_COINS], _balances: uint256[N_COINS]) -> uint256[N_COINS]:
    result: uint256[N_COINS] = empty(uint256[N_COINS])
    for i in range(N_COINS):
        result[i] = _rates[i] * _balances[i] / PRECISION
    return result


@pure
@internal
def get_D(_xp: uint256[N_COINS], _amp: uint256) -> uint256:
    """
    D invariant calculation in non-overflowing integer operations
    iteratively

    A * sum(x_i) * n**n + D = A * D * n**n + D**(n+1) / (n**n * prod(x_i))

    Converging solution:
    D[j+1] = (A * n**n * sum(x_i) - D[j]**(n+1) / (n**n prod(x_i))) / (A * n**n - 1)
    """
    S: uint256 = 0
    Dprev: uint256 = 0
    for x in _xp:
        S += x
    if S == 0:
        return 0

    D: uint256 = S
    Ann: uint256 = _amp * N_COINS
    for i in range(255):
        D_P: uint256 = D
        for x in _xp:
            D_P = D_P * D / (x * N_COINS)  # If division by 0, this will be borked: only withdrawal will work. And that is good
        Dprev = D
        D = (Ann * S / A_PRECISION + D_P * N_COINS) * D / ((Ann - A_PRECISION) * D / A_PRECISION + (N_COINS + 1) * D_P)
        # Equality with the precision of 1
        if D > Dprev:
            if D - Dprev <= 1:
                return D
        else:
            if Dprev - D <= 1:
                return D
    # convergence typically occurs in 4 rounds or less, this should be unreachable!
    # if it does happen the pool is borked and LPs can withdraw via `remove_liquidity`
    raise


@view
@internal
def get_D_mem(_rates: uint256[N_COINS], _balances: uint256[N_COINS], _amp: uint256) -> uint256:
    xp: uint256[N_COINS] = self._xp_mem(_rates, _balances)
    return self.get_D(xp, _amp)


@view
@external
def get_virtual_price() -> uint256:
    """
    @notice The current virtual price of the pool LP token
    @dev Useful for calculating profits
    @return LP token virtual price normalized to 1e18
    """
    amp: uint256 = self._A()
    balances: uint256[N_COINS] = self._balances()
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    xp: uint256[N_COINS] = self._xp_mem(rates, balances)
    D: uint256 = self.get_D(xp, amp)
    # D is in the units similar to DAI (e.g. converted to precision 1e18)
    # When balanced, D = n * x_u - total virtual value of the portfolio
    return D * PRECISION / CurveToken(self.lp_token).totalSupply()


@view
@external
def calc_token_amount(_amounts: uint256[N_COINS], _is_deposit: bool) -> uint256:
    """
    @notice Calculate addition or reduction in token supply from a deposit or withdrawal
    @dev This calculation accounts for slippage, but not fees.
         Needed to prevent front-running, not for precise calculations!
    @param _amounts Amount of each coin being deposited
    @param _is_deposit set True for deposits, False for withdrawals
    @return Expected amount of LP tokens received
    """
    amp: uint256 = self._A()
    balances: uint256[N_COINS] = self._balances()
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]

    D0: uint256 = self.get_D_mem(rates, balances, amp)
    for i in range(N_COINS):
        amount: uint256 = _amounts[i]
        if _is_deposit:
            balances[i] += amount
        else:
            balances[i] -= amount
    D1: uint256 = self.get_D_mem(rates, balances, amp)
    diff: uint256 = 0
    if _is_deposit:
        diff = D1 - D0
    else:
        diff = D0 - D1
    return diff * CurveToken(self.lp_token).totalSupply() / D0


@external
def claim_rewards():
    # push VALAS rewards into the reward receiver
    raw_call(
        VALAS_REWARDS,
        concat(
            method_id("claim(address,address[])"),
            convert(self, bytes32),
            convert(32 * 2, bytes32),
            convert(1, bytes32),
            convert(self.wrapped_coins[0], bytes32),
        )
    )
    ValasStaking(VALAS_STAKING).exit(False)
    RewardsToken(BASE_LP).getReward()
    amount: uint256 = ERC20(VALAS_TOKEN).balanceOf(self)
    if amount > 0:
        RewardsToken(self.lp_token).notifyRewardAmount(VALAS_TOKEN, amount)


@external
@nonreentrant('lock')
def add_liquidity(
    _amounts: uint256[N_COINS],
    _min_mint_amount: uint256,
    _use_wrapped: bool = False
) -> uint256:
    """
    @notice Deposit coins into the pool
    @param _amounts List of amounts of coins to deposit
    @param _min_mint_amount Minimum amount of LP tokens to mint from the deposit
    @param _use_wrapped if True, add liquidity using `wrapped_coins`
    @return Amount of LP tokens received by depositing
    """
    assert not self.is_killed  # dev: is killed

    amp: uint256 = self._A()
    old_balances: uint256[N_COINS] = self._balances()
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]

    # Initial invariant
    D0: uint256 = self.get_D_mem(rates, old_balances, amp)
    new_balances: uint256[N_COINS] = old_balances

    total_supply: uint256 = CurveToken(self.lp_token).totalSupply()

    # Take coins from the sender
    for i in range(N_COINS):
        amount: uint256 = _amounts[i]
        if amount == 0:
            assert total_supply > 0
        else:
            if _use_wrapped or i == 1:
                assert ERC20(self.wrapped_coins[i]).transferFrom(msg.sender, self, amount)
            else:
                coin: address = self.coins[0]
                # transfer underlying coin from msg.sender to self
                assert ERC20(coin).transferFrom(msg.sender, self, amount)
                # deposit to aave lending pool
                raw_call(
                    LENDING_POOL,
                    concat(
                        method_id("deposit(address,uint256,address,uint16)"),
                        convert(coin, bytes32),
                        convert(amount, bytes32),
                        convert(self, bytes32),
                        EMPTY_BYTES32,
                    )
                )
            new_balances[i] += amount

    # Invariant after change
    D1: uint256 = self.get_D_mem(rates, new_balances, amp)
    assert D1 > D0

    # We need to recalculate the invariant accounting for fees
    # to calculate fair user's share
    fees: uint256[N_COINS] = empty(uint256[N_COINS])
    mint_amount: uint256 = 0
    if total_supply > 0:
        # Only account for fees if we are not the first to deposit
        base_fee: uint256 = self.fee * N_COINS / (4 * (N_COINS - 1))
        for i in range(N_COINS):
            ideal_balance: uint256 = D1 * old_balances[i] / D0
            difference: uint256 = 0
            new_balance: uint256 = new_balances[i]
            if ideal_balance > new_balance:
                difference = ideal_balance - new_balance
            else:
                difference = new_balance - ideal_balance
            fees[i] = base_fee * difference / FEE_DENOMINATOR
            self.admin_balances[i] += fees[i] * ADMIN_FEE / FEE_DENOMINATOR
            new_balances[i] -= fees[i]
        D2: uint256 = self.get_D_mem(rates, new_balances, amp)
        mint_amount = total_supply * (D2 - D0) / D0
    else:
        mint_amount = D1  # Take the dust if there was any

    assert mint_amount >= _min_mint_amount

    # Mint pool tokens
    CurveToken(self.lp_token).mint(msg.sender, mint_amount)

    log AddLiquidity(msg.sender, _amounts, fees, D1, total_supply + mint_amount)

    return mint_amount


@view
@internal
def get_y(i: int128, j: int128, x: uint256, xp: uint256[N_COINS]) -> uint256:
    # x in the input is converted to the same price/precision

    assert i != j       # dev: same coin
    assert j >= 0       # dev: j below zero
    assert j < N_COINS  # dev: j above N_COINS

    # should be unreachable, but good for safety
    assert i >= 0
    assert i < N_COINS

    amp: uint256 = self._A()
    D: uint256 = self.get_D(xp, amp)
    S_: uint256 = 0
    _x: uint256 = 0
    y_prev: uint256 = 0
    c: uint256 = D
    Ann: uint256 = amp * N_COINS

    for _i in range(N_COINS):
        if _i == i:
            _x = x
        elif _i != j:
            _x = xp[_i]
        else:
            continue
        S_ += _x
        c = c * D / (_x * N_COINS)

    c = c * D * A_PRECISION / (Ann * N_COINS)
    b: uint256 = S_ + D * A_PRECISION / Ann  # - D
    y: uint256 = D

    for _i in range(255):
        y_prev = y
        y = (y*y + c) / (2 * y + b - D)
        # Equality with the precision of 1
        if y > y_prev:
            if y - y_prev <= 1:
                return y
        else:
            if y_prev - y <= 1:
                return y
    raise


@view
@external
def get_dy(i: int128, j: int128, dx: uint256) -> uint256:
    """
    @notice Calculate the current output dy given input dx
    @dev Index values can be found via the `coins` public getter method
    @param i Index value for the coin to send
    @param j Index valie of the coin to recieve
    @param dx Amount of `i` being exchanged
    @return Amount of `j` predicted
    """
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    xp: uint256[N_COINS] = self._xp_mem(rates, self._balances())

    x: uint256 = xp[i] + (dx * rates[i] / PRECISION)
    y: uint256 = self.get_y(i, j, x, xp)
    dy: uint256 = xp[j] - y - 1
    fee: uint256 = self.fee * dy / FEE_DENOMINATOR
    return (dy - fee) * PRECISION / rates[j]


@view
@external
def get_dy_underlying(i: int128, j: int128, dx: uint256) -> uint256:
    """
    @notice Calculate the current output dy given input dx on underlying
    @dev Index values can be found via the `coins` public getter method
    @param i Index value for the coin to send
    @param j Index valie of the coin to recieve
    @param dx Amount of `i` being exchanged
    @return Amount of `j` predicted
    """
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    xp: uint256[N_COINS] = self._xp_mem(rates, self._balances())

    x: uint256 = 0
    base_i: int128 = 0
    base_j: int128 = 0
    meta_i: int128 = 0
    meta_j: int128 = 0

    if i != 0:
        base_i = i - MAX_COIN
        meta_i = 1
    if j != 0:
        base_j = j - MAX_COIN
        meta_j = 1

    if i == 0:
        x = xp[i] + dx * (rates[0] / 10**18)
    else:
        if j == 0:
            # i is from BasePool
            # At first, get the amount of pool tokens
            base_inputs: uint256[BASE_N_COINS] = empty(uint256[BASE_N_COINS])
            base_inputs[base_i] = dx
            # Token amount transformed to underlying "dollars"
            x = Curve(BASE_POOL).calc_token_amount(base_inputs, True) * rates[1] / PRECISION
            # Accounting for deposit/withdraw fees approximately
            x -= x * Curve(BASE_POOL).fee() / (2 * FEE_DENOMINATOR)
            # Adding number of pool tokens
            x += xp[MAX_COIN]
        else:
            # If both are from the base pool
            return Curve(BASE_POOL).get_dy(base_i, base_j, dx)

    # This pool is involved only when in-pool assets are used
    y: uint256 = self.get_y(meta_i, meta_j, x, xp)
    dy: uint256 = xp[meta_j] - y - 1
    dy = (dy - self.fee * dy / FEE_DENOMINATOR)

    # If output is going via the metapool
    if j == 0:
        dy /= (rates[0] / 10**18)
    else:
        # j is from BasePool
        # The fee is already accounted for
        dy = Curve(BASE_POOL).calc_withdraw_one_coin(dy * PRECISION / rates[1], base_j)

    return dy


@external
@nonreentrant('lock')
def exchange(
    i: int128,
    j: int128,
    _dx: uint256,
    _min_dy: uint256,
    _use_wrapped: bool = False,
) -> uint256:
    """
    @notice Perform an exchange between two coins
    @dev Index values can be found via the `coins` public getter method
    @param i Index value for the coin to send
    @param j Index valie of the coin to recieve
    @param _dx Amount of `i` being exchanged
    @param _min_dy Minimum amount of `j` to receive
    @param _use_wrapped if True, swap between `wrapped_coins`
    @return Actual amount of `j` received
    """
    assert not self.is_killed  # dev: is killed

    old_balances: uint256[N_COINS] = self._balances()
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]

    xp: uint256[N_COINS] = self._xp_mem(rates, old_balances)


    if _use_wrapped or i == 1:
        assert ERC20(self.wrapped_coins[i]).transferFrom(msg.sender, self, _dx)
    else:
        coin: address = self.coins[0]
        assert ERC20(coin).transferFrom(msg.sender, self, _dx)
        raw_call(
            LENDING_POOL,
            concat(
                method_id("deposit(address,uint256,address,uint16)"),
                convert(coin, bytes32),
                convert(_dx, bytes32),
                convert(self, bytes32),
                EMPTY_BYTES32,
            )
        )

    x: uint256 = xp[i] + _dx * rates[i] / PRECISION
    dy: uint256 = xp[j] - self.get_y(i, j, x, xp) - 1  # -1 just in case there were some rounding errors
    dy_fee: uint256 = dy * self.fee / FEE_DENOMINATOR

    # Convert all to real units
    dy = (dy - dy_fee) * PRECISION / rates[j]
    assert dy >= _min_dy

    self.admin_balances[j] += (dy_fee * ADMIN_FEE / FEE_DENOMINATOR) * PRECISION / rates[j]

    if _use_wrapped or j == 1:
        assert ERC20(self.wrapped_coins[j]).transfer(msg.sender, dy)
    else:
        LendingPool(LENDING_POOL).withdraw(self.coins[0], dy, msg.sender)

    log TokenExchange(msg.sender, i, _dx, j, dy)

    return dy


@external
@nonreentrant('lock')
def exchange_underlying(
    i: int128,
    j: int128,
    _dx: uint256,
    _min_dy: uint256
) -> uint256:
    """
    @notice Perform an exchange between two underlying coins
    @dev Underlying refers to the base pool coins, not the wrapped/underlying within this contract
    @param i Index value for the underlying coin to send
    @param j Index valie of the underlying coin to receive
    @param _dx Amount of `i` being exchanged
    @param _min_dy Minimum amount of `j` to receive
    @return Actual amount of `j` received
    """
    assert not self.is_killed  # dev: is killed

    old_balances: uint256[N_COINS] = self._balances()
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    xp: uint256[N_COINS] = self._xp_mem(rates, old_balances)

    base_coins: address[3] = BASE_COINS

    dy: uint256 = 0
    base_i: int128 = 0
    base_j: int128 = 0
    meta_i: int128 = 0
    meta_j: int128 = 0
    x: uint256 = 0
    input_coin: address = ZERO_ADDRESS
    output_coin: address = ZERO_ADDRESS

    if i == 0:
        input_coin = self.coins[0]
    else:
        base_i = i - MAX_COIN
        meta_i = 1
        input_coin = base_coins[base_i]
    if j == 0:
        output_coin = self.coins[0]
    else:
        base_j = j - MAX_COIN
        meta_j = 1
        output_coin = base_coins[base_j]


    assert ERC20(input_coin).transferFrom(msg.sender, self, _dx)
    dx: uint256 = _dx

    if i == 0 or j == 0:
        if i == 0:
            raw_call(
                LENDING_POOL,
                concat(
                    method_id("deposit(address,uint256,address,uint16)"),
                    convert(input_coin, bytes32),
                    convert(dx, bytes32),
                    convert(self, bytes32),
                    EMPTY_BYTES32,
                )
            )
            x = xp[i] + dx * rates[i] / PRECISION
        else:
            # i is from BasePool
            # At first, get the amount of pool tokens
            base_inputs: uint256[BASE_N_COINS] = empty(uint256[BASE_N_COINS])
            base_inputs[base_i] = dx
            coin_i: address = self.coins[MAX_COIN]
            # Deposit and measure delta
            x = ERC20(coin_i).balanceOf(self)
            Curve(BASE_POOL).add_liquidity(base_inputs, 0)
            # Need to convert pool token to "virtual" units using rates
            # dx is also different now
            dx = ERC20(coin_i).balanceOf(self) - x
            x = dx * rates[MAX_COIN] / PRECISION
            # Adding number of pool tokens
            x += xp[MAX_COIN]

        y: uint256 = self.get_y(meta_i, meta_j, x, xp)

        # Either a real coin or token
        dy = xp[meta_j] - y - 1  # -1 just in case there were some rounding errors
        dy_fee: uint256 = dy * self.fee / FEE_DENOMINATOR

        # Convert all to real units
        # Works for both pool coins and real coins
        dy = (dy - dy_fee) * PRECISION / rates[meta_j]

        dy_admin_fee: uint256 = dy_fee * ADMIN_FEE / FEE_DENOMINATOR
        dy_admin_fee = dy_admin_fee * PRECISION / rates[meta_j]

        self.admin_balances[meta_j] += dy_admin_fee

        # Withdraw from the base pool if needed
        if j > 0:
            out_amount: uint256 = ERC20(output_coin).balanceOf(self)
            Curve(BASE_POOL).remove_liquidity_one_coin(dy, base_j, 0)
            dy = ERC20(output_coin).balanceOf(self) - out_amount

        assert dy >= _min_dy

    else:
        # If both are from the base pool
        dy = ERC20(output_coin).balanceOf(self)
        Curve(BASE_POOL).exchange(base_i, base_j, dx, _min_dy)
        dy = ERC20(output_coin).balanceOf(self) - dy

    if j == 0:
        LendingPool(LENDING_POOL).withdraw(output_coin, dy, msg.sender)
    else:
        assert ERC20(output_coin).transfer(msg.sender, dy)

    log TokenExchangeUnderlying(msg.sender, i, dx, j, dy)

    return dy


@external
@nonreentrant('lock')
def remove_liquidity(
    _burn_amount: uint256,
    _min_amounts: uint256[N_COINS],
    _use_wrapped: bool = False
) -> uint256[N_COINS]:
    """
    @notice Withdraw coins from the pool
    @dev Withdrawal amounts are based on current deposit ratios
    @param _burn_amount Quantity of LP tokens to burn in the withdrawal
    @param _min_amounts Minimum amounts of underlying coins to receive
    @param _use_wrapped if True, remove liquidity in `wrapped_coins`
    @return List of amounts of coins that were withdrawn
    """
    total_supply: uint256 = CurveToken(self.lp_token).totalSupply()
    amounts: uint256[N_COINS] = empty(uint256[N_COINS])
    balances: uint256[N_COINS] = self._balances()

    for i in range(N_COINS):
        value: uint256 = balances[i] * _burn_amount / total_supply
        assert value >= _min_amounts[i]
        amounts[i] = value
        if _use_wrapped or i == 1:
            assert ERC20(self.wrapped_coins[i]).transfer(msg.sender, value)
        else:
            LendingPool(LENDING_POOL).withdraw(self.coins[0], value, msg.sender)

    CurveToken(self.lp_token).burnFrom(msg.sender, _burn_amount)

    log RemoveLiquidity(msg.sender, amounts, empty(uint256[N_COINS]), total_supply - _burn_amount)

    return amounts


@external
@nonreentrant('lock')
def remove_liquidity_imbalance(
    _amounts: uint256[N_COINS],
    _max_burn_amount: uint256,
    _use_wrapped: bool = False
) -> uint256:
    """
    @notice Withdraw coins from the pool in an imbalanced amount
    @param _amounts List of amounts of underlying coins to withdraw
    @param _max_burn_amount Maximum amount of LP token to burn in the withdrawal
    @param _use_wrapped if True, remove liquidity in `wrapped_coins`
    @return Actual amount of the LP token burned in the withdrawal
    """
    assert not self.is_killed  # dev: is killed

    amp: uint256 = self._A()
    old_balances: uint256[N_COINS] = self._balances()
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    D0: uint256 = self.get_D_mem(rates, old_balances, amp)

    new_balances: uint256[N_COINS] = old_balances
    for i in range(N_COINS):
        amount: uint256 = _amounts[i]
        if amount != 0:
            new_balances[i] -= amount
            if _use_wrapped or i == 1:
                assert ERC20(self.wrapped_coins[i]).transfer(msg.sender, amount)
            else:
                LendingPool(LENDING_POOL).withdraw(self.coins[0], amount, msg.sender)

    D1: uint256 = self.get_D_mem(rates, new_balances, amp)

    fees: uint256[N_COINS] = empty(uint256[N_COINS])
    base_fee: uint256 = self.fee * N_COINS / (4 * (N_COINS - 1))
    for i in range(N_COINS):
        ideal_balance: uint256 = D1 * old_balances[i] / D0
        difference: uint256 = 0
        new_balance: uint256 = new_balances[i]
        if ideal_balance > new_balance:
            difference = ideal_balance - new_balance
        else:
            difference = new_balance - ideal_balance
        fees[i] = base_fee * difference / FEE_DENOMINATOR
        self.admin_balances[i] += fees[i] * ADMIN_FEE / FEE_DENOMINATOR
        new_balances[i] -= fees[i]
    D2: uint256 = self.get_D_mem(rates, new_balances, amp)

    total_supply: uint256 = CurveToken(self.lp_token).totalSupply()
    burn_amount: uint256 = ((D0 - D2) * total_supply / D0) + 1
    assert burn_amount > 1  # dev: zero tokens burned
    assert burn_amount <= _max_burn_amount

    CurveToken(self.lp_token).burnFrom(msg.sender, burn_amount)
    log RemoveLiquidityImbalance(msg.sender, _amounts, fees, D1, total_supply - burn_amount)

    return burn_amount


@view
@internal
def get_y_D(A: uint256, i: int128, xp: uint256[N_COINS], D: uint256) -> uint256:
    """
    Calculate x[i] if one reduces D from being calculated for xp to D

    Done by solving quadratic equation iteratively.
    x_1**2 + x1 * (sum' - (A*n**n - 1) * D / (A * n**n)) = D ** (n + 1) / (n ** (2 * n) * prod' * A)
    x_1**2 + b*x_1 = c

    x_1 = (x_1**2 + c) / (2*x_1 + b)
    """
    # x in the input is converted to the same price/precision

    assert i >= 0  # dev: i below zero
    assert i < N_COINS  # dev: i above N_COINS

    S_: uint256 = 0
    _x: uint256 = 0
    y_prev: uint256 = 0
    c: uint256 = D
    Ann: uint256 = A * N_COINS

    for _i in range(N_COINS):
        if _i != i:
            _x = xp[_i]
        else:
            continue
        S_ += _x
        c = c * D / (_x * N_COINS)

    c = c * D * A_PRECISION / (Ann * N_COINS)
    b: uint256 = S_ + D * A_PRECISION / Ann
    y: uint256 = D

    for _i in range(255):
        y_prev = y
        y = (y*y + c) / (2 * y + b - D)
        # Equality with the precision of 1
        if y > y_prev:
            if y - y_prev <= 1:
                return y
        else:
            if y_prev - y <= 1:
                return y
    raise


@view
@internal
def _calc_withdraw_one_coin(_burn_amount: uint256, i: int128) -> uint256[2]:
    # First, need to calculate
    # * Get current D
    # * Solve Eqn against y_i for D - _token_amount
    amp: uint256 = self._A()
    rates: uint256[N_COINS] = [self.rate_multiplier, Curve(BASE_POOL).get_virtual_price()]
    xp: uint256[N_COINS] = self._xp_mem(rates, self._balances())
    D0: uint256 = self.get_D(xp, amp)

    total_supply: uint256 = CurveToken(self.lp_token).totalSupply()
    D1: uint256 = D0 - _burn_amount * D0 / total_supply
    new_y: uint256 = self.get_y_D(amp, i, xp, D1)

    base_fee: uint256 = self.fee * N_COINS / (4 * (N_COINS - 1))
    xp_reduced: uint256[N_COINS] = empty(uint256[N_COINS])

    for j in range(N_COINS):
        dx_expected: uint256 = 0
        xp_j: uint256 = xp[j]
        if j == i:
            dx_expected = xp_j * D1 / D0 - new_y
        else:
            dx_expected = xp_j - xp_j * D1 / D0
        xp_reduced[j] = xp_j - base_fee * dx_expected / FEE_DENOMINATOR

    dy: uint256 = xp_reduced[i] - self.get_y_D(amp, i, xp_reduced, D1)
    dy_0: uint256 = (xp[i] - new_y) * PRECISION / rates[i]  # w/o fees
    dy = (dy - 1) * PRECISION / rates[i]  # Withdraw less to account for rounding errors

    return [dy, dy_0 - dy]


@view
@external
def calc_withdraw_one_coin(_burn_amount: uint256, i: int128) -> uint256:
    """
    @notice Calculate the amount received when withdrawing a single coin
    @param _burn_amount Amount of LP tokens to burn in the withdrawal
    @param i Index value of the coin to withdraw
    @return Amount of coin received
    """
    return self._calc_withdraw_one_coin(_burn_amount, i)[0]


@external
@nonreentrant('lock')
def remove_liquidity_one_coin(
    _burn_amount: uint256,
    i: int128,
    _min_received: uint256,
    _use_wrapped: bool = False
) -> uint256:
    """
    @notice Withdraw a single coin from the pool
    @param _burn_amount Amount of LP tokens to burn in the withdrawal
    @param i Index value of the coin to withdraw
    @param _min_received Minimum amount of coin to receive
    @param _use_wrapped if True, remove liquidity in `wrapped_coins`
    @return Amount of coin received
    """
    assert not self.is_killed  # dev: is killed

    dy: uint256[2] = self._calc_withdraw_one_coin(_burn_amount, i)
    assert dy[0] >= _min_received

    self.admin_balances[i] += dy[1] * ADMIN_FEE / FEE_DENOMINATOR
    CurveToken(self.lp_token).burnFrom(msg.sender, _burn_amount)
    total_supply: uint256 = CurveToken(self.lp_token).totalSupply()

    if _use_wrapped or i == 1:
        assert ERC20(self.wrapped_coins[i]).transfer(msg.sender, dy[0])
    else:
        LendingPool(LENDING_POOL).withdraw(self.coins[0], dy[0], msg.sender)

    log RemoveLiquidityOne(msg.sender, _burn_amount, dy[0], total_supply)

    return dy[0]


@external
def ramp_A(_future_A: uint256, _future_time: uint256):
    assert msg.sender == Factory(self.factory).admin()  # dev: only owner
    assert block.timestamp >= self.initial_A_time + MIN_RAMP_TIME
    assert _future_time >= block.timestamp + MIN_RAMP_TIME  # dev: insufficient time

    _initial_A: uint256 = self._A()
    _future_A_p: uint256 = _future_A * A_PRECISION

    assert _future_A > 0 and _future_A < MAX_A
    if _future_A_p < _initial_A:
        assert _future_A_p * MAX_A_CHANGE >= _initial_A
    else:
        assert _future_A_p <= _initial_A * MAX_A_CHANGE

    self.initial_A = _initial_A
    self.future_A = _future_A_p
    self.initial_A_time = block.timestamp
    self.future_A_time = _future_time

    log RampA(_initial_A, _future_A_p, block.timestamp, _future_time)


@external
def stop_ramp_A():
    assert msg.sender == Factory(self.factory).admin()  # dev: only owner

    current_A: uint256 = self._A()
    self.initial_A = current_A
    self.future_A = current_A
    self.initial_A_time = block.timestamp
    self.future_A_time = block.timestamp
    # now (block.timestamp < t1) is always False, so we return saved A

    log StopRampA(current_A, block.timestamp)


@external
def withdraw_admin_fees():
    receiver: address = Factory(self.factory).fee_receiver()

    for i in range(N_COINS):
        amount: uint256 = self.admin_balances[i]
        if amount != 0:
            self.admin_balances[i] = 0
            underlying_coin: address = self.coins[i]
            if i == 0:
                LendingPool(LENDING_POOL).withdraw(underlying_coin, amount, self)
            ERC20(underlying_coin).approve(receiver, amount)
            FeeDistributor(receiver).depositFee(underlying_coin, amount)


@external
def kill_me():
    assert msg.sender == Factory(self.factory).admin()  # dev: only owner
    assert self.kill_deadline > block.timestamp  # dev: deadline has passed
    self.is_killed = True


@external
def unkill_me():
    assert msg.sender == Factory(self.factory).admin()  # dev: only owner
    self.is_killed = False