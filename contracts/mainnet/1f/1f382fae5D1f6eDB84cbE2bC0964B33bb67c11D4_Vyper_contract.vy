# @version 0.2.16

"""
@title Mirrored Voting Escrow
@author Hundred Finance
@license MIT
"""

interface VotingEscrow:
    def user_point_epoch(_user: address) -> uint256: view
    def get_last_user_slope(_addr: address) -> int128: view
    def user_point_history__ts(_addr: address, _idx: uint256) -> uint256: view
    def locked__end(_addr: address) -> uint256: view
    def totalSupply(_t: uint256) -> uint256: view
    def balanceOf(_addr: address, _t: uint256) -> uint256: view
    def decimals() -> uint256: view
    def locked(_addr: address) -> LockedBalance: view

struct Point:
    bias: int128
    slope: int128  # - dweight / dt
    ts: uint256
    blk: uint256  # block

struct LockedBalance:
    amount: int128
    end: uint256

struct MirroredChain:
    chain_id: uint256
    escrow_count: uint256

event MirrorLock:
    provider: indexed(address)
    chain_id: uint256
    escrow_id: uint256
    value: uint256
    locktime: indexed(uint256)

event CommitOwnership:
    admin: address

event ApplyOwnership:
    admin: address

event SetMirrorWhitelist:
    addr: address
    is_whitelisted: bool

event AddVotingEscrow:
    addr: address

admin: public(address)
future_admin: public(address)

whitelisted_mirrors: public(HashMap[address, bool])

voting_escrow_count: public(uint256)
voting_escrows: public(address[100])

mirrored_chains_count: public(uint256)
mirrored_chains: public(MirroredChain[100])

# user -> chain -> escrow_id -> lock
mirrored_locks: public(HashMap[address, HashMap[uint256, HashMap[uint256, LockedBalance]]])

# user -> chain -> escrow_id -> Point[user_epoch]
mirrored_user_point_history: public(HashMap[address, HashMap[uint256, HashMap[uint256, Point[1000000000]]]])
mirrored_user_point_epoch: public(HashMap[address, HashMap[uint256, HashMap[uint256, uint256]]])

mirrored_epoch: public(uint256)
mirrored_point_history: public(Point[100000000000000000000000000000])  # epoch -> unsigned point
mirrored_slope_changes: public(HashMap[uint256, int128])  # time -> signed slope change

name: public(String[64])
symbol: public(String[32])
version: public(String[32])
decimals: public(uint256)

WEEK: constant(uint256) = 7 * 86400  # all future times are rounded by week
MAXTIME: constant(uint256) = 4 * 365 * 86400  # 4 years
MULTIPLIER: constant(uint256) = 10 ** 18

@external
def __init__(_admin: address, _voting_escrow: address, _name: String[64], _symbol: String[32], _version: String[32]):
    self.admin = _admin

    self.name = _name
    self.symbol = _symbol
    self.version = _version
    self.decimals = 18 #VotingEscrow(_voting_escrow).decimals()

    self.voting_escrows[0] = _voting_escrow
    self.voting_escrow_count = 1


@internal
def _checkpoint(addr: address, _chain: uint256, _escrow_id: uint256, old_locked: LockedBalance, new_locked: LockedBalance):
    """
    @notice Record global and per-user data to checkpoint
    @param addr User's wallet address. No user checkpoint if 0x0
    @param old_locked Pevious locked amount / end lock time for the user
    @param new_locked New locked amount / end lock time for the user
    """
    u_old: Point = empty(Point)
    u_new: Point = empty(Point)
    old_dslope: int128 = 0
    new_dslope: int128 = 0
    _epoch: uint256 = self.mirrored_epoch

    if addr != ZERO_ADDRESS:
        # Calculate slopes and biases
        # Kept at zero when they have to
        if old_locked.end > block.timestamp and old_locked.amount > 0:
            u_old.slope = old_locked.amount / MAXTIME
            u_old.bias = u_old.slope * convert(old_locked.end - block.timestamp, int128)
        if new_locked.end > block.timestamp and new_locked.amount > 0:
            u_new.slope = new_locked.amount / MAXTIME
            u_new.bias = u_new.slope * convert(new_locked.end - block.timestamp, int128)

        # Read values of scheduled changes in the slope
        # old_locked.end can be in the past and in the future
        # new_locked.end can ONLY by in the FUTURE unless everything expired: than zeros
        old_dslope = self.mirrored_slope_changes[old_locked.end]
        if new_locked.end != 0:
            if new_locked.end == old_locked.end:
                new_dslope = old_dslope
            else:
                new_dslope = self.mirrored_slope_changes[new_locked.end]

    last_point: Point = Point({bias: 0, slope: 0, ts: block.timestamp, blk: block.number})
    if _epoch > 0:
        last_point = self.mirrored_point_history[_epoch]
    last_checkpoint: uint256 = last_point.ts
    # initial_last_point is used for extrapolation to calculate block number
    # (approximately, for *At methods) and save them
    # as we cannot figure that out exactly from inside the contract
    initial_last_point: Point = last_point
    block_slope: uint256 = 0  # dblock/dt
    if block.timestamp > last_point.ts:
        block_slope = MULTIPLIER * (block.number - last_point.blk) / (block.timestamp - last_point.ts)
    # If last point is already recorded in this block, slope=0
    # But that's ok b/c we know the block in such case

    # Go over weeks to fill history and calculate what the current point is
    t_i: uint256 = (last_checkpoint / WEEK) * WEEK
    for i in range(255):
        # Hopefully it won't happen that this won't get used in 5 years!
        # If it does, users will be able to withdraw but vote weight will be broken
        t_i += WEEK
        d_slope: int128 = 0
        if t_i > block.timestamp:
            t_i = block.timestamp
        else:
            d_slope = self.mirrored_slope_changes[t_i]
        last_point.bias -= last_point.slope * convert(t_i - last_checkpoint, int128)
        last_point.slope += d_slope
        if last_point.bias < 0:  # This can happen
            last_point.bias = 0
        if last_point.slope < 0:  # This cannot happen - just in case
            last_point.slope = 0
        last_checkpoint = t_i
        last_point.ts = t_i
        last_point.blk = initial_last_point.blk + block_slope * (t_i - initial_last_point.ts) / MULTIPLIER
        _epoch += 1
        if t_i == block.timestamp:
            last_point.blk = block.number
            break
        else:
            self.mirrored_point_history[_epoch] = last_point

    self.mirrored_epoch = _epoch
    # Now point_history is filled until t=now

    if addr != ZERO_ADDRESS:
        # If last point was in this block, the slope change has been applied already
        # But in such case we have 0 slope(s)
        last_point.slope += (u_new.slope - u_old.slope)
        last_point.bias += (u_new.bias - u_old.bias)
        if last_point.slope < 0:
            last_point.slope = 0
        if last_point.bias < 0:
            last_point.bias = 0

    # Record the changed point into history
    self.mirrored_point_history[_epoch] = last_point

    if addr != ZERO_ADDRESS:
        # Schedule the slope changes (slope is going down)
        # We subtract new_user_slope from [new_locked.end]
        # and add old_user_slope to [old_locked.end]
        if old_locked.end > block.timestamp:
            # old_dslope was <something> - u_old.slope, so we cancel that
            old_dslope += u_old.slope
            if new_locked.end == old_locked.end:
                old_dslope -= u_new.slope  # It was a new deposit, not extension
            self.mirrored_slope_changes[old_locked.end] = old_dslope

        if new_locked.end > block.timestamp:
            if new_locked.end > old_locked.end:
                new_dslope -= u_new.slope  # old slope disappeared at this point
                self.mirrored_slope_changes[new_locked.end] = new_dslope
            # else: we recorded it already in old_dslope

        # Now handle user history
        user_epoch: uint256 = self.mirrored_user_point_epoch[addr][_chain][_escrow_id] + 1

        self.mirrored_user_point_epoch[addr][_chain][_escrow_id] = user_epoch
        u_new.ts = block.timestamp
        u_new.blk = block.number
        self.mirrored_user_point_history[addr][_chain][_escrow_id][user_epoch] = u_new


@external
def mirror_lock(_user: address, _chain: uint256, _escrow_id: uint256, _value: uint256, _unlock_time: uint256):
    assert self.whitelisted_mirrors[msg.sender] == True # dev: only whitelisted address can mirror locks

    old_locked: LockedBalance = self.mirrored_locks[_user][_chain][_escrow_id]

    new_locked: LockedBalance = empty(LockedBalance)
    new_locked.amount = convert(_value, int128)
    new_locked.end = _unlock_time

    self.mirrored_locks[_user][_chain][_escrow_id] = new_locked

    chain_already_mirrored: bool = False
    for i in range(99):
        if i >= self.mirrored_chains_count:
            break

        if self.mirrored_chains[i].chain_id == _chain:
            chain_already_mirrored = True
            self.mirrored_chains[i].escrow_count = max(self.mirrored_chains[i].escrow_count, _escrow_id + 1)

            break
    
    if not chain_already_mirrored:
        self.mirrored_chains[self.mirrored_chains_count] = empty(MirroredChain)
        self.mirrored_chains[self.mirrored_chains_count].chain_id = _chain
        self.mirrored_chains[self.mirrored_chains_count].escrow_count = _escrow_id + 1

        self.mirrored_chains_count += 1
    
    self._checkpoint(_user, _chain, _escrow_id, old_locked, new_locked)

    log MirrorLock(_user, _chain, _escrow_id, _value, _unlock_time)


@external
def checkpoint():
    """
    @notice Record global data to checkpoint
    """
    self._checkpoint(ZERO_ADDRESS, 0, 0, empty(LockedBalance), empty(LockedBalance))


@external
@view
def user_point_epoch(_user: address, _chain: uint256 = 0, _escrow_id: uint256 = 0) -> uint256:
    if _chain == 0:
        return VotingEscrow(self.voting_escrows[_escrow_id]).user_point_epoch(_user)

    return self.mirrored_user_point_epoch[_user][_chain][_escrow_id]
    

@external
@view
def user_point_history__ts(_addr: address, _idx: uint256, _chain: uint256 = 0, _escrow_id: uint256 = 0) -> uint256:
    if _chain == 0:
        return VotingEscrow(self.voting_escrows[_escrow_id]).user_point_history__ts(_addr, _idx)

    return self.mirrored_user_point_history[_addr][_chain][_escrow_id][_idx].ts


@external
@view
def user_last_checkpoint_ts(_user: address) -> uint256:
    _epoch: uint256 = 0
    _ts: uint256 = 0

    for i in range(99):
        if i >= self.voting_escrow_count:
            break

        _escrow_epoch: uint256 = VotingEscrow(self.voting_escrows[i]).user_point_epoch(_user)
        _escrow_ts: uint256 = VotingEscrow(self.voting_escrows[i]).user_point_history__ts(_user, _epoch)

        if _escrow_ts < _ts or _ts == 0:
            _ts = _escrow_ts

    for i in range(99):
        if i >= self.mirrored_chains_count:
            break

        _chain: MirroredChain = self.mirrored_chains[i]

        for j in range(499):
            if j >= _chain.escrow_count:
                break

            _escrow_epoch: uint256 = self.mirrored_user_point_epoch[_user][_chain.chain_id][j]
            _escrow_ts: uint256 = self.mirrored_user_point_history[_user][_chain.chain_id][j][_escrow_epoch].ts

            if _escrow_ts < _ts or _ts == 0:
                _ts = _escrow_ts
    
    return _ts


@internal
@view
def mirrored_supply_at(point: Point, t: uint256) -> uint256:
    """
    @notice Calculate total voting power at some point in the past
    @param point The point (bias/slope) to start search from
    @param t Time to calculate the total voting power at
    @return Total voting power at that time
    """
    last_point: Point = point
    t_i: uint256 = (last_point.ts / WEEK) * WEEK
    for i in range(255):
        t_i += WEEK
        d_slope: int128 = 0
        if t_i > t:
            t_i = t
        else:
            d_slope = self.mirrored_slope_changes[t_i]
        last_point.bias -= last_point.slope * convert(t_i - last_point.ts, int128)
        if t_i == t:
            break
        last_point.slope += d_slope
        last_point.ts = t_i

    if last_point.bias < 0:
        last_point.bias = 0
    return convert(last_point.bias, uint256)


@external
@view
def total_mirrored_supply(t: uint256 = block.timestamp) -> uint256:
    """
    @notice Calculate total voting power
    @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
    @return Total voting power
    """
    _epoch: uint256 = self.mirrored_epoch
    last_point: Point = self.mirrored_point_history[_epoch]
    return self.mirrored_supply_at(last_point, t)


@external
@view
def totalSupply(_t: uint256 = block.timestamp) -> uint256:
    _local_supply: uint256 = 0

    for i in range(99):
        if i >= self.voting_escrow_count:
            break

        _local_supply += VotingEscrow(self.voting_escrows[i]).totalSupply(_t)

    _epoch: uint256 = self.mirrored_epoch
    _last_point: Point = self.mirrored_point_history[_epoch]
    _mirrored_supply: uint256 = self.mirrored_supply_at(_last_point, _t)

    return _local_supply + _mirrored_supply


@internal
@view
def _mirrored_balance_of(addr: address, _t: uint256) -> uint256:
    _chain_count: uint256 = self.mirrored_chains_count
    _mirrored_balance: uint256 = 0

    for i in range(99):
        if i >= _chain_count:
            break

        _chain: MirroredChain = self.mirrored_chains[i]

        for j in range(499):
            if j >= _chain.escrow_count:
                break

            _escrow_epoch: uint256 = self.mirrored_user_point_epoch[addr][_chain.chain_id][j]
            if _escrow_epoch > 0:
                _last_point: Point = self.mirrored_user_point_history[addr][_chain.chain_id][j][_escrow_epoch]
                _last_point.bias -= _last_point.slope * convert(_t - _last_point.ts, int128)
                if _last_point.bias < 0:
                    _last_point.bias = 0
                _mirrored_balance += convert(_last_point.bias, uint256)

    return _mirrored_balance

@external
@view
def locked(_addr: address) -> int128:
    _local_locked: int128 = 0
    _local_locked_t: int128 = 0 
    unused: uint256 = 0
    
    _locked: LockedBalance = empty(LockedBalance)

    for i in range(100):
        if(i >= self.voting_escrow_count):
            break
        _locked =  VotingEscrow(self.voting_escrows[i]).locked(_addr)
        _local_locked += _locked.amount

    totChains: uint256 = self.mirrored_chains_count
    totEscrow: uint256 = 0
    _chainId: uint256 = 0

    for i in range(100):
        if(i >= totChains):
            break
        _chainId = self.mirrored_chains[i].chain_id
        totEscrow = self.mirrored_chains[i].escrow_count

        if(_chainId != 0):
            for j in range(100):
                if(j >= totEscrow):
                    break
                _locked = self.mirrored_locks[_addr][_chainId][j]
                _local_locked += _locked.amount
    
    return _local_locked
    

@external
@view
def balanceOf(_addr: address, _t: uint256 = block.timestamp) -> uint256:
    _local_balance: uint256 = 0
    for i in range(99):
        if i >= self.voting_escrow_count:
            break

        _local_balance += VotingEscrow(self.voting_escrows[i]).balanceOf(_addr, _t)

    _mirrored_balance: uint256 = self._mirrored_balance_of(_addr, _t)

    return _local_balance + _mirrored_balance


@external
@view
def mirrored_balance_of(addr: address, _t: uint256) -> uint256:
    return self._mirrored_balance_of(addr, _t)


@external
@view
def locked__end(_addr: address, _chain: uint256 = 0, _escrow_id: uint256 = 0) -> uint256:

    if _chain == 0:
        return VotingEscrow(self.voting_escrows[_escrow_id]).locked__end(_addr)

    return self.mirrored_locks[_addr][_chain][_escrow_id].end


@external
@view
def nearest_locked__end(_addr: address) -> uint256:
    _lock_end: uint256 = 0

    for i in range(99):
        if i >= self.voting_escrow_count:
            break

        _escrow_lock_end: uint256 = VotingEscrow(self.voting_escrows[i]).locked__end(_addr)
        if _escrow_lock_end < _lock_end or _lock_end == 0:
            _lock_end = _escrow_lock_end

    _chain_count: uint256 = self.mirrored_chains_count
    for i in range(99):
        if i >= _chain_count:
            break
        
        _chain: MirroredChain = self.mirrored_chains[i]
        for j in range(499):
            if j >= _chain.escrow_count:
                break

            _escrow_lock_end: uint256 = self.mirrored_locks[_addr][_chain.chain_id][j].end
            if _escrow_lock_end != 0 and (_escrow_lock_end < _lock_end or _lock_end == 0):
                _lock_end = _escrow_lock_end
    
    return _lock_end

@external
@view
def get_last_user_slope(_addr: address, _chain: uint256 = 0, _escrow_id: uint256 = 0) -> int128:
    if _chain == 0:
        return VotingEscrow(self.voting_escrows[_escrow_id]).get_last_user_slope(_addr)
    
    _chain_uepoch: uint256 = self.mirrored_user_point_epoch[_addr][_chain][_escrow_id]
    return self.mirrored_user_point_history[_addr][_chain][_escrow_id][_chain_uepoch].slope


@external
def commit_transfer_ownership(addr: address):
    """
    @notice Transfer ownership to `addr`
    @param addr Address to have ownership transferred to
    """
    assert msg.sender == self.admin  # dev: admin only
    self.future_admin = addr
    log CommitOwnership(addr)


@external
def apply_transfer_ownership():
    """
    @notice Apply pending ownership transfer
    """
    assert msg.sender == self.admin  # dev: admin only
    _admin: address = self.future_admin
    assert _admin != ZERO_ADDRESS  # dev: admin not set
    self.admin = _admin
    log ApplyOwnership(_admin)


@external
def set_mirror_whitelist(_addr: address, _is_whitelisted: bool):
    assert msg.sender == self.admin # dev: only admin

    self.whitelisted_mirrors[_addr] = _is_whitelisted
    log SetMirrorWhitelist(_addr, _is_whitelisted)


@external
def add_voting_escrow(_addr: address):
    assert msg.sender == self.admin # dev: only admin

    self.voting_escrows[self.voting_escrow_count] = _addr
    self.voting_escrow_count += 1
    log AddVotingEscrow(_addr)