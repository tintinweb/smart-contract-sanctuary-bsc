/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

interface ERC20 {
    function decimals() external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address spender, address to, uint256 amount) external returns (bool);
}

interface SmartWalletChecker {
    function check(address addr) external returns (bool);
}

library SafeCast {
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }
}

contract Booster {
    using SafeCast for int;

    struct Point {
        int128 bias;
        int128 slope;
        uint256 ts;
        uint256 blk;
    }

    struct LockedBalance {
        int128 amount;
        uint256 end;
    }

    int128 constant DEPOSIT_FOR_TYPE = 0;
    int128 constant CREATE_LOCK_TYPE = 1;
    int128 constant INCREASE_LOCK_AMOUNT = 2;
    int128 constant INCREASE_UNLOCK_TIME = 3;

    event CommitOwnership(address admin);
    event ApplyOwnership(address admin);
    event Deposit(
        address indexed provider,
        uint256 value,
        uint256 indexed locktime,
        int128 _type,
        uint256 ts
    );
    event Withdraw(
        address indexed provider,
        uint256 value,
        uint256 ts
    );
    event Supply(
        uint256 prevSupply,
        uint256 supply
    );

    uint256 constant WEEK = 7 * 86400;
    uint256 constant MAXTIME = 4 * 365 * 86400;
    uint256 constant MULTIPLIER = 10 ** 18;

    address public token;
    uint256 public supply;

    mapping(address => LockedBalance) public locked;

    uint256 public epoch;
    uint256 constant MAXIMUM = 100000000000000;
    Point[MAXIMUM] public point_history;

    mapping(address => Point[MAXIMUM]) public user_point_history;
    mapping(address => uint256) public user_point_epoch;
    mapping(uint256 => int128) public slope_changes;

    string public name;
    string public symbol;
    uint256 public decimals;

    address public future_smart_wallet_checker;
    address public smart_wallet_checker;
    address public admin;
    address public future_admin;
    
    bool public initialized;

    function initialize(address _admin, address token_addr, address _smart_wallet_checker, string memory _name, string memory _symbol) external {
        require(!initialized);

        initialized = true;
        require(_admin != address(0));
        admin = _admin;
        token = token_addr;
        smart_wallet_checker = _smart_wallet_checker;
        
        point_history[0].blk = block.number;
        point_history[0].ts = block.timestamp;

        uint256 _decimals = ERC20(token_addr).decimals();
        require(_decimals <= 255);

        decimals = _decimals;
        name = _name;
        symbol = _symbol;
    }

    function commit_transfer_ownership(address addr) external {
        require(msg.sender == admin);
        require(addr != address(0));
        future_admin = addr;
        emit CommitOwnership(addr);
    }

    function accept_transfer_ownership() external {
        address _admin = future_admin;
        require(msg.sender == _admin);
        admin = _admin;
        emit ApplyOwnership(_admin);
    }

    function apply_transfer_ownership() external {
        require(msg.sender == admin);
        address _admin = future_admin;
        require(_admin != address(0));
        admin = _admin;
        emit ApplyOwnership(_admin);
    }

    function commit_smart_wallet_checker(address addr) external {
        require(msg.sender == admin);
        future_smart_wallet_checker = addr;
    }

    function apply_smart_wallet_checker() external {
        require(msg.sender == admin);
        smart_wallet_checker = future_smart_wallet_checker;
    }

    function assert_not_contract(address addr) internal {
        if(addr != tx.origin) {
            address checker = smart_wallet_checker;
            if(checker != address(0)) {
                if(SmartWalletChecker(checker).check(addr)) {
                    return;
                }
            }
            revert("Smart contract depositors not allowed");
        }
    }

    function get_last_user_slope(address addr) external view returns (int128) {
        uint256 uepoch = user_point_epoch[addr];
        return user_point_history[addr][uepoch].slope;
    }
        
    function user_point_history__ts(address _addr, uint256 _idx) external view returns (uint256) {
        return user_point_history[_addr][_idx].ts;
    }   

    function locked__end(address addr) external view returns (uint256) {
        return locked[addr].end;
    }

    function _checkpoint(address addr, LockedBalance memory old_locked, LockedBalance memory new_locked) internal {
        Point[2] memory u;
        int128 old_dslope = 0;
        int128 new_dslope = 0;
        uint256 _epoch = epoch;

        if(addr != address(0)) {
            if(old_locked.end > block.timestamp && old_locked.amount > 0) {
                u[0].slope = int(uint(int(old_locked.amount)) / MAXTIME).toInt128();
                u[0].bias = u[0].slope * int128(int(old_locked.end - block.timestamp));
            }
            if(new_locked.end > block.timestamp && new_locked.amount > 0) {
                u[1].slope = int(uint(int(new_locked.amount)) / MAXTIME).toInt128();
                u[1].bias = u[1].slope * int128(int(new_locked.end - block.timestamp));
            }

            old_dslope = slope_changes[old_locked.end];
            if(new_locked.end != 0) {
                if(new_locked.end == old_locked.end) {
                    new_dslope = old_dslope;
                } else {
                    new_dslope = slope_changes[new_locked.end];
                }
            }
        }

        Point memory last_point  = Point({bias: 0, slope: 0, ts: block.timestamp, blk: block.number});
        
        if(_epoch > 0) {
            last_point = point_history[_epoch];
        }
            
        uint256 last_checkpoint = last_point.ts;
        Point memory initial_last_point  = last_point;
        uint256 block_slope = 0;

        if(block.timestamp > last_point.ts) {
            block_slope = MULTIPLIER * (block.number - last_point.blk) / (block.timestamp - last_point.ts);
        }

        uint256 t_i = (last_checkpoint / WEEK) * WEEK;

        for(uint i; i<255;i++) {
            t_i += WEEK;
            int128 d_slope = 0;
            if(t_i > block.timestamp) {
                t_i = block.timestamp;
            } else {
                d_slope = slope_changes[t_i];
            }

            last_point.bias -= last_point.slope * int128(int(t_i - last_checkpoint));
            last_point.slope += d_slope;
            
            if(last_point.bias < 0){
                last_point.bias = 0;
            }
            if(last_point.slope < 0) {
                last_point.slope = 0;
            }
            last_checkpoint = t_i;
            last_point.ts = t_i;
            last_point.blk = initial_last_point.blk + block_slope * (t_i - initial_last_point.ts) / MULTIPLIER;
            _epoch += 1;
            if(t_i == block.timestamp) {
                last_point.blk = block.number;
                break;
            }
            else {
                point_history[_epoch] = last_point;
            }
        }
        epoch = _epoch;
        
        if(addr != address(0)) {
            last_point.slope += (u[1].slope - u[0].slope);
            last_point.bias += (u[1].bias - u[0].bias);
            if(last_point.slope < 0) {
                last_point.slope = 0;
            }
            if(last_point.bias < 0){
                last_point.bias = 0;
            }
        }

        point_history[_epoch] = last_point;
        
        if(addr != address(0)) {
            if(old_locked.end > block.timestamp) {
                old_dslope += u[0].slope;
                if(new_locked.end == old_locked.end) {
                    old_dslope -= u[1].slope;
                }
                slope_changes[old_locked.end] = old_dslope;
            }
            if(new_locked.end > block.timestamp) {
                if(new_locked.end > old_locked.end) {
                    new_dslope -= u[1].slope;
                    slope_changes[new_locked.end] = new_dslope;
                }
            }

            uint256 user_epoch = user_point_epoch[addr] + 1;
            user_point_epoch[addr] = user_epoch;
            u[1].ts = block.timestamp;
            u[1].blk = block.number;
            user_point_history[addr][user_epoch] = u[1];
        }
    }

    function _deposit_for(address _addr, uint256 _value, uint256 unlock_time, LockedBalance memory locked_balance, int128 _type, address sender) internal {
        LockedBalance memory _locked = locked_balance;
        uint256 supply_before = supply;
        
        supply = supply_before + _value;
        LockedBalance memory old_locked = _locked;
        
        _locked.amount += int128(int(_value));
        if(unlock_time != 0) {
            _locked.end = unlock_time;
        }

        locked[_addr] = _locked;    
        _checkpoint(_addr, old_locked, _locked);

        if(_value != 0) {
            require(ERC20(token).transferFrom(sender, address(this), _value));
        }

        emit Deposit(_addr, _value, _locked.end, _type, block.timestamp);
        emit Supply(supply_before, supply_before + _value);
    }

    function checkpoint() external {
        LockedBalance memory a;
        LockedBalance memory b;
        _checkpoint(address(0), a,b);
    }

    function deposit_for(address _addr, uint256 _value) external /*nonreentrant("lock")*/ {
        LockedBalance memory _locked = locked[_addr];

        require(_value > 0);
        require(_locked.amount > 0, "No existing lock found");
        require(_locked.end > block.timestamp, "Cannot add to expired lock. Withdraw");

        _deposit_for(_addr, _value, 0, locked[_addr], DEPOSIT_FOR_TYPE, msg.sender);
    }

    function create_lock(uint256 _value, uint256 _unlock_time) external /*nonreentrant("lock")*/ {
        assert_not_contract(msg.sender);
        uint256 unlock_time = (_unlock_time / WEEK) * WEEK;
        LockedBalance memory _locked = locked[msg.sender];

        require(_value > 0);
        require(_locked.amount == 0, "Withdraw old tokens first");
        require(unlock_time > block.timestamp, "Can only lock until time in the future");
        require(unlock_time <= block.timestamp + MAXTIME, "Voting lock can be 4 years max");

        _deposit_for(msg.sender, _value, unlock_time, _locked, CREATE_LOCK_TYPE, msg.sender);
    }

    function increase_amount(uint256 _value) external /*nonreentrant("lock")*/ {
        assert_not_contract(msg.sender);
        LockedBalance memory _locked = locked[msg.sender];

        require(_value > 0);
        require(_locked.amount > 0, "No existing lock found");
        require(_locked.end > block.timestamp, "Cannot add to expired lock. Withdraw");

        _deposit_for(msg.sender, _value, 0, _locked, INCREASE_LOCK_AMOUNT, msg.sender);
    }

    function increase_unlock_time(uint256 _unlock_time) external /*nonreentrant("lock")*/ {
        assert_not_contract(msg.sender);
        LockedBalance memory _locked = locked[msg.sender];
        uint256 unlock_time  = (_unlock_time / WEEK) * WEEK;

        require(_locked.end > block.timestamp, "Lock expired");
        require(_locked.amount > 0, "Nothing is locked");
        require(unlock_time > _locked.end, "Can only increase lock duration");
        require(unlock_time <= block.timestamp + MAXTIME, "Voting lock can be 4 years max");

        _deposit_for(msg.sender, 0, unlock_time, _locked, INCREASE_UNLOCK_TIME, msg.sender);
    }

    function withdraw() external /*nonreentrant("lock")*/ {
        LockedBalance memory _locked = locked[msg.sender];
        require(block.timestamp >= _locked.end, "The lock didn't expire");
        uint256 value = uint256(int(_locked.amount));

        LockedBalance memory old_locked = _locked;
        _locked.end = 0;
        _locked.amount = 0;

        locked[msg.sender] = _locked;
        uint256 supply_before = supply;
        supply = supply_before - value;
        _checkpoint(msg.sender, old_locked, _locked);

        require(ERC20(token).transfer(msg.sender, value));

        emit Withdraw(msg.sender, value, block.timestamp);
        emit Supply(supply_before, supply_before - value);
    }

    function find_block_epoch(uint256 _block,uint256 max_epoch) internal view returns (uint256) {
        uint256 _min = 0;
        uint256 _max = max_epoch;
        for(uint i;i<128;i++) {
            if(_min >= _max) {
                break;
            }

            uint256 _mid = (_min + _max + 1) / 2;
            if(point_history[_mid].blk <= _block) {
                _min = _mid;
            }
            else {
                _max = _mid - 1;
            }
        }
        return _min;
    }

    function balanceOf(address addr) external view returns (uint256) {
        uint _t = block.timestamp;
        uint256 _epoch = user_point_epoch[addr];

        if(_epoch == 0) {
            return 0;
        } else{
            Point memory last_point = user_point_history[addr][_epoch];
            last_point.bias -= last_point.slope * int128(int(_t - last_point.ts));
            if(last_point.bias < 0) {
                last_point.bias = 0;
            }

            return uint256(int(last_point.bias));
        }
    }

    function _balanceOfAt(address addr, uint256 _block) internal view returns(uint256) {
        require(_block <= block.number);

        uint256 _min  = 0;
        uint256 _max = user_point_epoch[addr];

        for(uint i;i<128;i++){
            if(_min >= _max) {
                break;
            }
            uint256 _mid = (_min + _max + 1) / 2;
            if(user_point_history[addr][_mid].blk <= _block) {
                _min = _mid;
            } else {
                _max = _mid - 1;
            }
        }

        Point memory upoint = user_point_history[addr][_min];

        uint256 max_epoch = epoch;
        uint256 _epoch = find_block_epoch(_block, max_epoch);

        Point memory point_0  = point_history[_epoch];
        
        uint256 d_block = 0;
        uint256 d_t = 0;
        
        if(_epoch < max_epoch) {
            Point memory point_1 = point_history[_epoch + 1];
            d_block = point_1.blk - point_0.blk;
            d_t = point_1.ts - point_0.ts;
        } else {
            d_block = block.number - point_0.blk;
            d_t = block.timestamp - point_0.ts;
        }
        
        uint256 block_time = point_0.ts;
        
        if(d_block != 0) {
            block_time += d_t * (_block - point_0.blk) / d_block;
        }

        upoint.bias -= upoint.slope * int128(int(block_time - upoint.ts));
        if(upoint.bias >= 0) {
            return uint256(int(upoint.bias));
        }
        else {
            return 0;
        }
    }

    function balanceOfAt(address addr, uint256 _block) external view returns (uint256) {
        return _balanceOfAt(addr,_block);
    }

    function getPastVotes(address addr, uint256 _block) external view returns (uint256) {
        return _balanceOfAt(addr,_block);
    }

    function supply_at(Point memory point, uint256 t) internal view  returns (uint256) {
        Point memory last_point = point;
        uint256 t_i = (last_point.ts / WEEK) * WEEK;
        for(uint i;i<255;i++) {
            t_i += WEEK;
            int128 d_slope = 0;
            if(t_i > t) {
                t_i = t;
            } else {
                d_slope = slope_changes[t_i];
            }
            last_point.bias -= last_point.slope * int128(int(t_i - last_point.ts));
            if(t_i == t) {
                break;
            }
            last_point.slope += d_slope;
            last_point.ts = t_i;
        }

        if(last_point.bias < 0) {
            last_point.bias = 0;
        }
        return uint256(int(last_point.bias));
    }

    function totalSupply() external view returns (uint256) {
        uint t = block.timestamp;
        uint256 _epoch = epoch;
        Point memory last_point  = point_history[_epoch];
        return supply_at(last_point, t);
    }   

    function totalSupplyAt(uint256 _block) external view returns(uint256) {
        require(_block <= block.number);
        uint256 _epoch = epoch;
        uint256 target_epoch = find_block_epoch(_block, _epoch);

        Point memory point = point_history[target_epoch];
        uint256 dt = 0;
        if(target_epoch < _epoch) {
            Point memory point_next = point_history[target_epoch + 1];
            if(point.blk != point_next.blk) {
                dt = (_block - point.blk) * (point_next.ts - point.ts) / (point_next.blk - point.blk);
            }
        }
        else {
            if(point.blk != block.number) {
                dt = (_block - point.blk) * (block.timestamp - point.ts) / (block.number - point.blk);
            }
        }

        return supply_at(point, point.ts + dt);
    }
}