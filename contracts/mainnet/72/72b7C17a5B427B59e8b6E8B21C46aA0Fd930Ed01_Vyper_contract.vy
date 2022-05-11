# @version 0.3.1
"""
@title Ellipsis Registry
@license MIT
"""

MAX_COINS: constant(int128) = 8

struct PoolArray:
    location: uint256
    decimals: uint256
    underlying_decimals: uint256
    base_pool: address
    coins: address[MAX_COINS]
    ul_coins: address[MAX_COINS]
    n_coins: uint256
    asset_type: uint256


interface ERC20:
    def balanceOf(_addr: address) -> uint256: view
    def decimals() -> uint256: view
    def totalSupply() -> uint256: view

interface CurvePool:
    def A() -> uint256: view
    def fee() -> uint256: view
    def admin_fee() -> uint256: view
    def coins(i: uint256) -> address: view
    def underlying_coins(i: uint256) -> address: view
    def balances(i: uint256) -> uint256: view
    def get_virtual_price() -> uint256: view

interface CurveMetapool:
    def base_pool() -> address: view

interface Factory:
    def find_pool_for_coins(_from: address, _to: address, i: uint256) -> address: view
    def get_base_pool(_pool: address) -> address: view
    def get_n_coins(_pool: address) -> uint256: view
    def get_meta_n_coins(_pool: address) -> (uint256, uint256): view
    def get_coins(_pool: address) -> address[MAX_COINS]: view
    def get_underlying_coins(_pool: address) -> address[MAX_COINS]: view
    def get_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_balances(_pool: address) -> uint256[MAX_COINS]: view
    def _get_pool_from_lp_token(_token: address) -> address: view
    def get_admin_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_coin_indices(
        _pool: address,
        _from: address,
        _to: address
    ) -> (int128, int128, bool): view
    def is_meta(_pool: address) -> bool: view
    def get_pool_asset_type(_pool: address) -> uint256: view
    def pool_list(i: uint256) -> address: view
    def pool_count() -> uint256: view
    def get_pool_from_lp_token(_token: address) -> address: view
    def get_lp_token(_pool: address) -> address: view


event PoolAdded:
    pool: indexed(address)

event PoolRemoved:
    pool: indexed(address)


_pool_list: address[65536]   # master list of pools
_pool_count: uint256         # actual length of pool_list

pool_data: HashMap[address, PoolArray]

# lp token -> pool
_get_pool_from_lp_token: HashMap[address, address]

# pool -> lp token
_get_lp_token: HashMap[address, address]

# mapping of coins -> pools for trading
# a mapping key is generated for each pair of addresses via
# `bitwise_xor(convert(a, uint256), convert(b, uint256))`
markets: HashMap[uint256, address[65536]]
market_counts: HashMap[uint256, uint256]

owner: public(address)
factory: public(Factory)

@external
def __init__(_factory: Factory):
    """
    @notice Constructor function
    """
    self.owner = msg.sender
    self.factory = _factory


# internal functionality for getters

@view
@internal
def _unpack_decimals(_packed: uint256, _n_coins: uint256) -> uint256[MAX_COINS]:
    # decimals are tightly packed as a series of uint8 within a little-endian bytes32
    # the packed value is stored as uint256 to simplify unpacking via shift and modulo
    decimals: uint256[MAX_COINS] = empty(uint256[MAX_COINS])
    n_coins: int128 = convert(_n_coins, int128)
    for i in range(MAX_COINS):
        if i == n_coins:
            break
        decimals[i] = shift(_packed, -8 * i) % 256

    return decimals


@view
@internal
def _get_balances(_pool: address) -> uint256[MAX_COINS]:
    balances: uint256[MAX_COINS] = empty(uint256[MAX_COINS])
    for i in range(MAX_COINS):
        if self.pool_data[_pool].coins[i] == ZERO_ADDRESS:
            assert i != 0
            break

        balances[i] = CurvePool(_pool).balances(i)

    return balances


@view
@internal
def _get_meta_underlying_balances(_pool: address, _base_pool: address) -> uint256[MAX_COINS]:
    base_coin_idx: uint256 = shift(self.pool_data[_pool].n_coins, -128) - 1
    base_total_supply: uint256 = ERC20(self._get_lp_token[_base_pool]).totalSupply()

    underlying_balances: uint256[MAX_COINS] = empty(uint256[MAX_COINS])
    ul_balance: uint256 = 0
    underlying_pct: uint256 = 0
    if base_total_supply > 0:
        underlying_pct = CurvePool(_pool).balances(base_coin_idx) * 10**36 / base_total_supply

    for i in range(MAX_COINS):
        if self.pool_data[_pool].ul_coins[i] == ZERO_ADDRESS:
            break
        if i < base_coin_idx:
            ul_balance = CurvePool(_pool).balances(i)
        else:
            ul_balance = CurvePool(_base_pool).balances(i-base_coin_idx)
            ul_balance = ul_balance * underlying_pct / 10**36
        underlying_balances[i] = ul_balance

    return underlying_balances


@view
@internal
def _get_coin_indices(
    _pool: address,
    _from: address,
    _to: address
) -> uint256[3]:
    """
    Convert coin addresses to indices for use with pool methods.
    """
    # the return value is stored as `uint256[3]` to reduce gas costs
    # from index, to index, is the market underlying?
    result: uint256[3] = empty(uint256[3])

    found_market: bool = False

    # check coin markets
    for x in range(MAX_COINS):
        coin: address = self.pool_data[_pool].coins[x]
        if coin == ZERO_ADDRESS:
            # if we reach the end of the coins, reset `found_market` and try again
            # with the underlying coins
            found_market = False
            break
        if coin == _from:
            result[0] = x
        elif coin == _to:
            result[1] = x
        else:
            continue

        if found_market:
            # the second time we find a match, break out of the loop
            break
        # the first time we find a match, set `found_market` to True
        found_market = True

    if not found_market:
        # check underlying coin markets
        for x in range(MAX_COINS):
            coin: address = self.pool_data[_pool].ul_coins[x]
            if coin == ZERO_ADDRESS:
                raise "No available market"
            if coin == _from:
                result[0] = x
            elif coin == _to:
                result[1] = x
            else:
                continue

            if found_market:
                result[2] = 1
                break
            found_market = True

    return result


# targetted external getters, optimized for on-chain calls

@view
@external
def pool_list(i: uint256) -> address:
    count: uint256 = self._pool_count
    if i >= count:
        return self.factory.pool_list(i - count)
    return self._pool_list[i]


@view
@external
def pool_count() -> uint256:
    return self._pool_count + self.factory.pool_count()


@view
@external
def get_pool_from_lp_token(_token: address) -> address:
    pool: address = self._get_pool_from_lp_token[_token]
    if pool == ZERO_ADDRESS:
        return self.factory.get_pool_from_lp_token(_token)
    return pool


@view
@external
def get_lp_token(_pool: address) -> address:
    token: address = self._get_lp_token[_pool]
    if token == ZERO_ADDRESS:
        return self.factory.get_lp_token(_pool)
    return token


@view
@external
def find_pool_for_coins(_from: address, _to: address, i: uint256 = 0) -> address:
    """
    @notice Find an available pool for exchanging two coins
    @param _from Address of coin to be sent
    @param _to Address of coin to be received
    @param i Index value. When multiple pools are available
            this value is used to return the n'th address.
    @return Pool address
    """

    key: uint256 = bitwise_xor(convert(_from, uint256), convert(_to, uint256))
    count: uint256 = self.market_counts[key]
    if i >= count:
        return self.factory.find_pool_for_coins(_from, _to, i-count)
    return self.markets[key][i]


@view
@external
def get_base_pool(_pool: address) -> address:
    """
    @notice Get the base pool for a given factory metapool
    @param _pool Metapool address
    @return Address of base pool
    """
    base_pool: address = self.pool_data[_pool].base_pool
    if base_pool == ZERO_ADDRESS:
        return self.factory.get_base_pool(_pool)
    return base_pool


@view
@external
def get_n_coins(_pool: address) -> uint256:
    """
    @notice Get the number of coins in a pool
    @dev For non-metapools, both returned values are identical
         even when the pool does not use wrapping/lending
    @param _pool Pool address
    @return Number of wrapped coins, number of underlying coins
    """
    n_coins: uint256 = self.pool_data[_pool].n_coins
    if n_coins == 0:
        return self.factory.get_n_coins(_pool)
    return n_coins

@view
@external
def get_meta_n_coins(_pool: address) -> (uint256, uint256):
    """
    @notice Get the number of coins in a metapool
    @param _pool Pool address
    @return Number of wrapped coins, number of underlying coins
    """
    base_pool: address = self.pool_data[_pool].base_pool
    if base_pool == ZERO_ADDRESS:
        return self.factory.get_meta_n_coins(_pool)
    return 2, self.pool_data[base_pool].n_coins + 1


@view
@external
def get_coins(_pool: address) -> address[MAX_COINS]:
    """
    @notice Get the coins within a pool
    @dev For pools using lending, these are the wrapped coin addresses
    @param _pool Pool address
    @return List of coin addresses
    """
    n_coins: uint256 = self.pool_data[_pool].n_coins
    if n_coins == 0:
        return self.factory.get_coins(_pool)

    coins: address[MAX_COINS] = empty(address[MAX_COINS])
    for i in range(MAX_COINS):
        if i == n_coins:
            break
        coins[i] = self.pool_data[_pool].coins[i]

    return coins


@view
@external
def get_underlying_coins(_pool: address) -> address[MAX_COINS]:
    """
    @notice Get the underlying coins within a pool
    @dev For pools that do not lend, returns the same value as `get_coins`
    @param _pool Pool address
    @return List of coin addresses
    """
    base_pool: address = self.pool_data[_pool].base_pool
    if base_pool == ZERO_ADDRESS:
        return self.factory.get_underlying_coins(_pool)

    coins: address[MAX_COINS] = empty(address[MAX_COINS])
    coins[0] = self.pool_data[_pool].coins[0]
    for i in range(1, MAX_COINS):
        coins[i] = self.pool_data[base_pool].coins[i - 1]
        if coins[i] == ZERO_ADDRESS:
            break

    return coins


@view
@external
def get_decimals(_pool: address) -> uint256[MAX_COINS]:
    """
    @notice Get decimal places for each coin within a pool
    @dev For pools using lending, these are the wrapped coin decimal places
    @param _pool Pool address
    @return uint256 list of decimals
    """
    n_coins: uint256 = self.pool_data[_pool].n_coins
    if n_coins == 0:
        return self.factory.get_decimals(_pool)
    return self._unpack_decimals(self.pool_data[_pool].decimals, n_coins)


@view
@external
def get_underlying_decimals(_pool: address) -> uint256[MAX_COINS]:
    """
    @notice Get decimal places for each underlying coin within a pool
    @dev For pools that do not lend, returns the same value as `get_decimals`
    @param _pool Pool address
    @return uint256 list of decimals
    """
    n_coins: uint256 = self.pool_data[_pool].n_coins
    if n_coins == 0:
        return self.factory.get_underlying_decimals(_pool)
    return self._unpack_decimals(self.pool_data[_pool].underlying_decimals, n_coins)


@view
@external
def get_balances(_pool: address) -> uint256[MAX_COINS]:
    """
    @notice Get balances for each coin within a pool
    @dev For pools using lending, these are the wrapped coin balances
    @param _pool Pool address
    @return uint256 list of balances
    """
    if self.pool_data[_pool].n_coins == 0:
        return self.factory.get_balances(_pool)
    return self._get_balances(_pool)


@view
@external
def get_underlying_balances(_pool: address) -> uint256[MAX_COINS]:
    """
    @notice Get balances for each underlying coin within a pool
    @dev  For non-metapools returns the same value as `get_balances`
    @param _pool Pool address
    @return uint256 list of underlyingbalances
    """
    if self.pool_data[_pool].n_coins == 0:
        return self.factory.get_underlying_balances(_pool)

    base_pool: address = self.pool_data[_pool].base_pool
    if base_pool == ZERO_ADDRESS:
        return self._get_balances(_pool)
    return self._get_meta_underlying_balances(_pool, base_pool)


@view
@external
def get_virtual_price_from_lp_token(_token: address) -> uint256:
    """
    @notice Get the virtual price of a pool LP token
    @param _token LP token address
    @return uint256 Virtual price
    """
    pool: address = self._get_pool_from_lp_token[_token]
    if pool == ZERO_ADDRESS:
        pool = self.factory._get_pool_from_lp_token(_token)
    return CurvePool(pool).get_virtual_price()


@view
@external
def get_A(_pool: address) -> uint256:
    return CurvePool(_pool).A()


@view
@external
def get_fees(_pool: address) -> uint256[2]:
    """
    @notice Get the fees for a pool
    @dev Fees are expressed as integers
    @return Pool fee as uint256 with 1e10 precision
            Admin fee as 1e10 percentage of pool fee
    """
    return [CurvePool(_pool).fee(), CurvePool(_pool).admin_fee()]


@view
@external
def get_admin_balances(_pool: address) -> uint256[MAX_COINS]:
    """
    @notice Get the current admin balances (uncollected fees) for a pool
    @param _pool Pool address
    @return List of uint256 admin balances
    """
    n_coins: uint256 = self.pool_data[_pool].n_coins
    if n_coins == 0:
        return self.factory.get_admin_balances(_pool)

    balances: uint256[MAX_COINS] = self._get_balances(_pool)
    for i in range(MAX_COINS):
        coin: address = self.pool_data[_pool].coins[i]
        if i == n_coins:
            break
        if coin == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE:
            balances[i] = _pool.balance - balances[i]
        else:
            balances[i] = ERC20(coin).balanceOf(_pool) - balances[i]

    return balances


@view
@external
def get_coin_indices(
    _pool: address,
    _from: address,
    _to: address
) -> (int128, int128, bool):
    """
    @notice Convert coin addresses to indices for use with pool methods
    @param _from Coin address to be used as `i` within a pool
    @param _to Coin address to be used as `j` within a pool
    @return int128 `i`, int128 `j`, boolean indicating if `i` and `j` are underlying coins
    """
    if self.pool_data[_pool].n_coins == 0:
        return self.factory.get_coin_indices(_pool, _from, _to)

    result: uint256[3] = self._get_coin_indices(_pool, _from, _to)
    return convert(result[0], int128), convert(result[1], int128), result[2] > 0


@view
@external
def is_meta(_pool: address) -> bool:
    """
    @notice Verify `_pool` is a metapool
    @param _pool Pool address
    @return True if `_pool` is a metapool
    """
    if self.pool_data[_pool].base_pool != ZERO_ADDRESS:
        return True
    return self.factory.is_meta(_pool)


@view
@external
def get_pool_asset_type(_pool: address) -> uint256:
    """
    @notice Query the asset type of `_pool`
    @param _pool Pool Address
    @return The asset type as an unstripped string
    """
    asset_type: uint256 = self.pool_data[_pool].asset_type
    if asset_type == 0:
        return self.factory.get_pool_asset_type(_pool)
    return asset_type


# internal functionality used in admin setters

@internal
def _add_pool(
    _sender: address,
    _pool: address,
    _n_coins: uint256,
    _lp_token: address,
):
    assert _sender == self.owner
    assert _lp_token != ZERO_ADDRESS
    assert self.pool_data[_pool].coins[0] == ZERO_ADDRESS, "Pool already added"
    assert self._get_pool_from_lp_token[_lp_token] == ZERO_ADDRESS, "LP token already added"
    assert self.factory.get_lp_token(_pool) == ZERO_ADDRESS, "Pool exists in factory"
    assert self.factory.get_pool_from_lp_token(_lp_token) == ZERO_ADDRESS, "LP token exists in factory"

    # add pool to pool_list
    length: uint256 = self._pool_count
    self._pool_list[length] = _pool
    self._pool_count = length + 1
    self.pool_data[_pool].location = length
    self.pool_data[_pool].n_coins = _n_coins

    # update public mappings
    self._get_pool_from_lp_token[_lp_token] = _pool
    self._get_lp_token[_pool] = _lp_token

    log PoolAdded(_pool)


@internal
def _get_new_pool_coins(
    _pool: address,
    _n_coins: uint256,
    _is_underlying: bool,
) -> address[MAX_COINS]:
    coin_list: address[MAX_COINS] = empty(address[MAX_COINS])
    coin: address = ZERO_ADDRESS
    for i in range(MAX_COINS):
        if i == _n_coins:
            break
        if _is_underlying:
            coin = CurvePool(_pool).underlying_coins(i)
            self.pool_data[_pool].ul_coins[i] = coin
        else:
            coin = CurvePool(_pool).coins(i)
            self.pool_data[_pool].coins[i] = coin
        coin_list[i] = coin

    for i in range(MAX_COINS):
        if i == _n_coins:
            break

        # add pool to markets
        i2: uint256 = i + 1
        for x in range(i2, i2 + MAX_COINS):
            if x == _n_coins:
                break

            key: uint256 = bitwise_xor(convert(coin_list[i], uint256), convert(coin_list[x], uint256))
            length: uint256 = self.market_counts[key]
            self.markets[key][length] = _pool
            self.market_counts[key] = length + 1

    return coin_list


@view
@internal
def _get_new_pool_decimals(_coins: address[MAX_COINS], _n_coins: uint256) -> uint256:
    packed: uint256 = 0
    value: uint256 = 0

    n_coins: int128 = convert(_n_coins, int128)
    for i in range(MAX_COINS):
        if i == n_coins:
            break
        coin: address = _coins[i]
        if coin == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE:
            value = 18
        else:
            value = ERC20(coin).decimals()
            assert value < 256  # dev: decimal overflow

        packed += shift(value, i * 8)

    return packed


@internal
def _remove_market(_pool: address, _coina: address, _coinb: address):
    key: uint256 = bitwise_xor(convert(_coina, uint256), convert(_coinb, uint256))
    length: uint256 = self.market_counts[key] - 1
    for i in range(65536):
        if i > length:
            break
        if self.markets[key][i] == _pool:
            if i < length:
                self.markets[key][i] = self.markets[key][length]
            self.markets[key][length] = ZERO_ADDRESS
            self.market_counts[key] = length
            break


# admin functions

@external
def add_pool(
    _pool: address,
    _n_coins: uint256,
    _lp_token: address,
):
    """
    @notice Add a pool to the registry
    @dev Only callable by admin
    @param _pool Pool address to add
    @param _n_coins Number of coins in the pool
    @param _lp_token Pool deposit token address
    """
    self._add_pool(
        msg.sender,
        _pool,
        _n_coins,
        _lp_token,
    )

    coins: address[MAX_COINS] = self._get_new_pool_coins(_pool, _n_coins, False)
    self.pool_data[_pool].ul_coins = coins

    decimals: uint256 = self._get_new_pool_decimals(coins, _n_coins)
    self.pool_data[_pool].decimals = decimals
    self.pool_data[_pool].underlying_decimals = decimals


@external
def add_metapool(
    _pool: address,
    _n_coins: uint256,
    _lp_token: address,
    _base_pool: address = ZERO_ADDRESS
):
    """
    @notice Add a pool to the registry
    @dev Only callable by admin
    @param _pool Pool address to add
    @param _n_coins Number of coins in the pool
    @param _lp_token Pool deposit token address
    @param _base_pool Address of the base_pool useful for adding factory pools
    """
    base_coin_offset: uint256 = _n_coins - 1

    base_pool: address = _base_pool
    if base_pool == ZERO_ADDRESS:
        base_pool = CurveMetapool(_pool).base_pool()
    base_n_coins: uint256 = self.pool_data[base_pool].n_coins
    assert base_n_coins > 0  # dev: base pool unknown

    self._add_pool(
        msg.sender,
        _pool,
        _n_coins,
        _lp_token,
    )

    coins: address[MAX_COINS] = self._get_new_pool_coins(_pool, _n_coins, False)

    decimals: uint256 = self._get_new_pool_decimals(coins, _n_coins)

    self.pool_data[_pool].decimals = decimals
    self.pool_data[_pool].base_pool = base_pool

    base_coins: address[MAX_COINS] = empty(address[MAX_COINS])
    coin: address = ZERO_ADDRESS
    for i in range(MAX_COINS):
        if i == base_n_coins + base_coin_offset:
            break
        if i < base_coin_offset:
            coin = coins[i]
        else:
            x: uint256 = i - base_coin_offset
            coin = self.pool_data[base_pool].coins[x]
            base_coins[x] = coin
        self.pool_data[_pool].ul_coins[i] = coin

    underlying_decimals: uint256 = shift(
        self.pool_data[base_pool].decimals, 8 * convert(base_coin_offset, int128)
    )
    underlying_decimals += decimals % 256 ** base_coin_offset

    self.pool_data[_pool].underlying_decimals = underlying_decimals

    for i in range(MAX_COINS):
        if i == base_coin_offset:
            break
        for x in range(MAX_COINS):
            if x == base_n_coins:
                break
            key: uint256 = bitwise_xor(convert(coins[i], uint256), convert(base_coins[x], uint256))
            length: uint256 = self.market_counts[key]
            self.markets[key][length] = _pool
            self.market_counts[key] = length + 1


@external
def remove_pool(_pool: address):
    """
    @notice Remove a pool to the registry
    @dev Only callable by admin
    @param _pool Pool address to remove
    """
    assert msg.sender == self.owner
    assert self.pool_data[_pool].coins[0] != ZERO_ADDRESS  # dev: pool does not exist


    self._get_pool_from_lp_token[self._get_lp_token[_pool]] = ZERO_ADDRESS
    self._get_lp_token[_pool] = ZERO_ADDRESS

    # remove _pool from pool_list
    location: uint256 = self.pool_data[_pool].location
    length: uint256 = self._pool_count - 1

    if location < length:
        # replace _pool with final value in pool_list
        addr: address = self._pool_list[length]
        self._pool_list[location] = addr
        self.pool_data[addr].location = location

    # delete final pool_list value
    self._pool_list[length] = ZERO_ADDRESS
    self._pool_count = length

    self.pool_data[_pool].underlying_decimals = 0
    self.pool_data[_pool].decimals = 0
    self.pool_data[_pool].n_coins = 0
    self.pool_data[_pool].asset_type = 0

    coins: address[MAX_COINS] = empty(address[MAX_COINS])
    ucoins: address[MAX_COINS] = empty(address[MAX_COINS])

    for i in range(MAX_COINS):
        coins[i] = self.pool_data[_pool].coins[i]
        ucoins[i] = self.pool_data[_pool].ul_coins[i]
        if ucoins[i] == ZERO_ADDRESS and coins[i] == ZERO_ADDRESS:
            break
        if coins[i] != ZERO_ADDRESS:
            # delete coin address from pool_data
            self.pool_data[_pool].coins[i] = ZERO_ADDRESS
        if ucoins[i] != ZERO_ADDRESS:
            # delete underlying_coin from pool_data
            self.pool_data[_pool].ul_coins[i] = ZERO_ADDRESS

    is_meta: bool = self.pool_data[_pool].base_pool != ZERO_ADDRESS
    for i in range(MAX_COINS):
        coin: address = coins[i]
        ucoin: address = ucoins[i]
        if coin == ZERO_ADDRESS:
            break

        # remove pool from markets
        i2: uint256 = i + 1
        for x in range(i2, i2 + MAX_COINS):
            ucoinx: address = ucoins[x]
            if ucoinx == ZERO_ADDRESS:
                break

            coinx: address = coins[x]
            if coinx != ZERO_ADDRESS:
                self._remove_market(_pool, coin, coinx)

            if coin != ucoin or coinx != ucoinx:
                self._remove_market(_pool, ucoin, ucoinx)

    self.pool_data[_pool].base_pool = ZERO_ADDRESS
    log PoolRemoved(_pool)


@external
def set_pool_asset_type(_pool: address, _asset_type: uint256):
    """
    @notice Set the asset type name for a curve pool
    @dev This is a simple way to setting the cache of categories instead of
        performing some computation for no reason. Pool's don't necessarily
        change once they are deployed.
    @param _pool Pool address
    @param _asset_type String of asset type
    """
    assert msg.sender == self.owner

    self.pool_data[_pool].asset_type = _asset_type


@external
def batch_set_pool_asset_type(_pools: address[32], _asset_types: uint256[32]):
    """
    @notice Batch set the asset type name for curve pools
    @dev This is a simple way of setting the cache of categories instead of
        performing some computation for no reason. Pool's don't necessarily
        change once they are deployed.
    """
    assert msg.sender == self.owner

    for i in range(32):
        if _pools[i] == ZERO_ADDRESS:
            break
        self.pool_data[_pools[i]].asset_type = _asset_types[i]


@external
def transfer_ownership(_new_owner: address):
    assert msg.sender == self.owner
    self.owner = _new_owner