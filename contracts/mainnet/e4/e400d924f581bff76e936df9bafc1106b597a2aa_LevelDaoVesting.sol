/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ILevelStake {
    function userInfo(address _user) external view returns (uint256, uint256, uint256);
    function stake(address _to, uint256 _amount) external;
    function unstake(address _to, uint256 _amount) external;
    function cooldown() external;
    function claimRewards(address _to) external;
    function pendingReward(address _to) external view returns (uint256);
    function LVL() external view returns (IERC20);
    function LGO() external view returns (IERC20);
    function COOLDOWN_SECONDS() external view returns (uint256);
    function UNSTAKE_WINDOWN() external view returns (uint256);
}


/// @title Level Dao Vesting
/// @author Level
/// @notice Hold investor LVL to stake to LevelStake contract. These LVL will be unlocked after a certain period
contract LevelDaoVesting {

    IERC20 public LVL;
    IERC20 public LGO;
    ILevelStake public LEVEL_STAKE;

    uint256 public locked_duration;
    uint256 public vesting_duration;
    uint256 public start;

    uint256 public lvl_amount;
    uint256 public claimed_amount;
    address public investor;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyInvestor() {
        require(msg.sender == investor, "Only Investor");
        _;
    }

    constructor(
        address _levelStake,
        address _investor,
        uint256 _start,
        uint256 _locked_duration,
        uint256 _vesting_duration) {
        LEVEL_STAKE = ILevelStake(_levelStake);
        LVL = LEVEL_STAKE.LVL();
        LGO = LEVEL_STAKE.LGO();
        investor = _investor;
        start = _start;
        locked_duration = _locked_duration;
        vesting_duration = _vesting_duration;
        owner = msg.sender;
    }

    function get_vesting_speed() public view returns (uint256) {
        if (vesting_duration == 0) {
            return 0;
        }
        return lvl_amount / vesting_duration; // number of LVL per second
    }

    function get_vesting_end() public view returns (uint256) {
        return start + locked_duration + vesting_duration;
    }

    function get_vested_duration() public view returns (uint256) {
        uint256 _now = block.timestamp;
        if (_now <= start + locked_duration) {
            return 0;
        } else if (_now >= get_vesting_end()) {
            return vesting_duration;
        } else {
            return _now - start - locked_duration;
        }
    }

    /* ========== VIEW FUNCTIONS ========== */

    /// @notice calculate amount of LVL can be claimed
    function claimable_LVL() public view returns (uint256) {
        uint256 _vested_duration = get_vested_duration();
        uint256 _vesting_speed = get_vesting_speed();
        uint256 _vested_amount = _vesting_speed * _vested_duration;
        return _vested_amount - claimed_amount;
    }

    function claimable_LGO() public view returns (uint256) {
        return LEVEL_STAKE.pendingReward(address(this)) + LGO.balanceOf(address(this));
    }

    function getUnstakeTime() public view returns (uint256 _start, uint256 _end) {
        (,, uint256 cooldowns) = LEVEL_STAKE.userInfo(address(this));
        if (cooldowns != 0) {
            _start = cooldowns + LEVEL_STAKE.COOLDOWN_SECONDS();
            _end = cooldowns + LEVEL_STAKE.COOLDOWN_SECONDS() + LEVEL_STAKE.UNSTAKE_WINDOWN();
        }
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    function claim_LVL(uint256 _amount) external onlyInvestor {
        require(
            (_amount != 0 && _amount <= claimable_LVL()),
            "LevelDaoVesting::claim_LVL: invalid amount"
        );
        claimed_amount += _amount;
        LVL.transfer(investor, _amount);
        emit Withdrawn(investor, _amount);
    }

    function stake(uint256 _amount) external onlyInvestor {
        _stake(_amount);
    }

    function unstake(uint256 _amount) external onlyInvestor {
        require(_amount > 0 , "LevelDaoVesting::unstake: invalid amount");
        LEVEL_STAKE.unstake(address(this), _amount);
        emit Unstaked(_amount);
    }

    function cooldown() external onlyInvestor {
        LEVEL_STAKE.cooldown();
        emit Cooldown(msg.sender);
    }

    function claim_LGO(uint256 _amount) external onlyInvestor {
        LEVEL_STAKE.claimRewards(address(this));
        LGO.transfer(investor, _amount);
        emit LGOClaimed(investor, _amount);
    }

    function claim_all_LGO() external onlyInvestor {
        LEVEL_STAKE.claimRewards(address(this));
        uint256 _amount = LGO.balanceOf(address(this));
        LGO.transfer(investor, _amount);
        emit LGOClaimed(investor, _amount);
    }

    function deposit_and_stake(uint256 _amount) external onlyOwner {
        LVL.transferFrom(msg.sender, address(this), _amount);
        lvl_amount = lvl_amount + _amount;
        _stake(_amount);
        emit StakedForInvestor(_amount);
    }

    function emergency_withdraw() external onlyOwner {
        uint256 _amount = LVL.balanceOf(address(this));
        claimed_amount += _amount;
        LVL.transfer(investor, _amount);
        emit Withdrawn(investor, _amount);
    }

    function transfer_ownership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function _stake(uint256 _amount) internal {
        LVL.approve(address(LEVEL_STAKE), 0);
        LVL.approve(address(LEVEL_STAKE), _amount);
        LEVEL_STAKE.stake(address(this), _amount);
        emit Staked(_amount);
    }

    /* ========== EVENTS ========== */

    event StakedForInvestor(uint256 _amount);
    event Staked(uint256 _amount);
    event Unstaked(uint256 _amount);
    event Cooldown(address indexed _user);
    event EmergencyEnabled();
    event Withdrawn(address indexed _receiver, uint256 _amount);
    event LGOClaimed(address indexed _receiver, uint256 _amount);
}