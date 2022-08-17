# @version 0.3.3
"""
@title Ellipsis Registry
@license MIT
"""

MAX_COINS: constant(int128) = 4


interface AddressProvider:
    def owner() -> address: view

interface CurvePool:
    def A() -> uint256: view
    def fee() -> uint256: view
    def admin_fee() -> uint256: view
    def coins(i: uint256) -> address: view
    def underlying_coins(i: uint256) -> address: view
    def balances(i: uint256) -> uint256: view
    def get_virtual_price() -> uint256: view

interface Registry:
    def get_market_count(_from: address, _to: address) -> uint256: view
    def find_pool_for_coins(_from: address, _to: address, i: uint256) -> address: view
    def get_base_pool(_pool: address) -> address: view
    def get_n_coins(_pool: address) -> uint256: view
    def get_coins(_pool: address) -> address[MAX_COINS]: view
    def get_underlying_coins(_pool: address) -> address[MAX_COINS]: view
    def get_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_decimals(_pool: address) -> uint256[MAX_COINS]: view
    def get_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_underlying_balances(_pool: address) -> uint256[MAX_COINS]: view
    def get_pool_from_lp_token(_token: address) -> address: view
    def get_coin_indices(
        _pool: address,
        _from: address,
        _to: address
    ) -> (int128, int128, bool): view
    def is_meta(_pool: address) -> bool: view
    def get_pool_asset_type(_pool: address) -> uint256: view
    def pool_list(i: uint256) -> address: view
    def pool_count() -> uint256: view
    def get_lp_token(_pool: address) -> address: view


address_provider: public(AddressProvider)
registries: DynArray[Registry, 8]


@external
def __init__(_address_provider: AddressProvider, _registries: DynArray[Registry, 8]):
    """
    @notice Constructor function
    """
    self.address_provider = _address_provider
    self.registries = _registries


@view
@external
def pool_list(i: uint256) -> address:
    offset: uint256 = 0
    for registry in self.registries:
        count: uint256 = registry.pool_count()
        if count + offset > i:
            return registry.pool_list(i - offset)
        offset += count

    return ZERO_ADDRESS


@view
@external
def pool_count() -> uint256:
    count: uint256 = 0
    for registry in self.registries:
        count += registry.pool_count()
    return count


@view
@external
def get_pool_from_lp_token(_token: address) -> address:
    pool: address = ZERO_ADDRESS
    for registry in self.registries:
        pool = registry.get_pool_from_lp_token(_token)
        if pool != ZERO_ADDRESS:
            break
    return pool


@view
@external
def get_lp_token(_pool: address) -> address:
    token: address = ZERO_ADDRESS
    for registry in self.registries:
        token = registry.get_lp_token(_pool)
        if token != ZERO_ADDRESS:
            break
    return token


@view
@external
def get_market_count(_from: address, _to: address) -> uint256:
    total: uint256 = 0
    for registry in self.registries:
        total += registry.get_market_count(_from, _to)
    return total


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
    offset: uint256 = 0
    for registry in self.registries:
        count: uint256 = registry.get_market_count(_from, _to)
        if count + offset > i:
            return registry.find_pool_for_coins(_from, _to, i - offset)
        offset += count
    return ZERO_ADDRESS


@view
@external
def get_base_pool(_pool: address) -> address:
    """
    @notice Get the base pool for a given factory metapool
    @param _pool Metapool address
    @return Address of base pool
    """
    base_pool: address = ZERO_ADDRESS
    for registry in self.registries:
        base_pool = registry.get_base_pool(_pool)
        if base_pool != ZERO_ADDRESS:
            break
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
    n_coins: uint256 = 0
    for registry in self.registries:
        n_coins = registry.get_n_coins(_pool)
        if n_coins != 0:
            break
    return n_coins


@view
@external
def get_coins(_pool: address) -> address[MAX_COINS]:
    """
    @notice Get the coins within a pool
    @dev For pools using lending, these are the wrapped coin addresses
    @param _pool Pool address
    @return List of coin addresses
    """
    coins: address[MAX_COINS] = empty(address[MAX_COINS])
    for registry in self.registries:
        coins = registry.get_coins(_pool)
        if coins[0] != ZERO_ADDRESS:
            break
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
    coins: address[MAX_COINS] = empty(address[MAX_COINS])
    for registry in self.registries:
        coins = registry.get_underlying_coins(_pool)
        if coins[0] != ZERO_ADDRESS:
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
    decimals: uint256[MAX_COINS] = empty(uint256[MAX_COINS])
    for registry in self.registries:
        decimals = registry.get_decimals(_pool)
        if decimals[0] != 0:
            break
    return decimals


@view
@external
def get_underlying_decimals(_pool: address) -> uint256[MAX_COINS]:
    """
    @notice Get decimal places for each underlying coin within a pool
    @dev For pools that do not lend, returns the same value as `get_decimals`
    @param _pool Pool address
    @return uint256 list of decimals
    """
    decimals: uint256[MAX_COINS] = empty(uint256[MAX_COINS])
    for registry in self.registries:
        decimals = registry.get_underlying_decimals(_pool)
        if decimals[0] != 0:
            break
    return decimals


@view
@external
def get_balances(_pool: address) -> uint256[MAX_COINS]:
    """
    @notice Get balances for each coin within a pool
    @dev For pools using lending, these are the wrapped coin balances
    @param _pool Pool address
    @return uint256 list of balances
    """
    for registry in self.registries:
        if registry.get_lp_token(_pool) != ZERO_ADDRESS:
            return registry.get_balances(_pool)

    return empty(uint256[MAX_COINS])


@view
@external
def get_underlying_balances(_pool: address) -> uint256[MAX_COINS]:
    """
    @notice Get balances for each underlying coin within a pool
    @dev  For non-metapools returns the same value as `get_balances`
    @param _pool Pool address
    @return uint256 list of underlyingbalances
    """
    balances: uint256[MAX_COINS] = empty(uint256[MAX_COINS])
    for registry in self.registries:
        balances = registry.get_underlying_balances(_pool)
        if balances[0] != 0:
            break
    return balances


@view
@external
def get_virtual_price_from_lp_token(_token: address) -> uint256:
    """
    @notice Get the virtual price of a pool LP token
    @param _token LP token address
    @return uint256 Virtual price
    """
    pool: address = ZERO_ADDRESS
    for registry in self.registries:
        pool = registry.get_pool_from_lp_token(_token)
        if pool != ZERO_ADDRESS:
            break
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
    for registry in self.registries:
        if registry.get_n_coins(_pool) != 0:
            return registry.get_coin_indices(_pool, _from, _to)
    raise "No available market"


@view
@external
def is_meta(_pool: address) -> bool:
    """
    @notice Verify `_pool` is a metapool
    @param _pool Pool address
    @return True if `_pool` is a metapool
    """
    for registry in self.registries:
        if registry.get_n_coins(_pool) != 0:
            return registry.is_meta(_pool)
    return False


@view
@external
def get_pool_asset_type(_pool: address) -> uint256:
    """
    @notice Query the asset type of `_pool`
    @param _pool Pool Address
    @return The asset type as an unstripped string
    """
    asset_type: uint256 = 0
    for registry in self.registries:
        asset_type = registry.get_pool_asset_type(_pool)
        if asset_type != 0:
            break
    return asset_type


@view
@external
def get_registries() -> DynArray[Registry, 8]:
    return self.registries


@external
def set_registries(_registries: DynArray[Registry, 8]):
    assert msg.sender == self.address_provider.owner()
    self.registries = _registries