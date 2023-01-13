/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT

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

    uint256 public constant ENDTIME = 1705204800; // Sun Jan 14 2024 04:00:00 UTC

    uint256 public claimedAmount;
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

    constructor(address _levelStake, address _investor) {
        LEVEL_STAKE = ILevelStake(_levelStake);
        investor = _investor;
        owner = msg.sender;
        LVL = LEVEL_STAKE.LVL();
        LGO = LEVEL_STAKE.LGO();
    }

    /* ========== VIEW FUNCTIONS ========== */

    function claimableLVL() public view returns (uint256) {
        if ( block.timestamp <= ENDTIME) {
            return 0;
        }
        return LVL.balanceOf(address(this));
    }

    function claimableLGO() public view returns (uint256) {
        return LEVEL_STAKE.pendingReward(address(this)) + LGO.balanceOf(address(this));
    }

    function getUnstakeTime() public view returns (uint256 start, uint256 end) {
        (,, uint256 cooldowns) = LEVEL_STAKE.userInfo(address(this));
        if (cooldowns != 0) {
            start = cooldowns + LEVEL_STAKE.COOLDOWN_SECONDS();
            end = cooldowns + LEVEL_STAKE.COOLDOWN_SECONDS() + LEVEL_STAKE.UNSTAKE_WINDOWN();
        }
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    function withdraw(uint256 _amount) external onlyInvestor {
        require(
            (_amount != 0 && _amount <= claimableLVL()),
            "LevelDaoVesting::withdraw: invalid amount"
        );
        claimedAmount += _amount;
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

    function claimLGO(uint256 _amount) external onlyInvestor {
        LEVEL_STAKE.claimRewards(address(this));
        LGO.transfer(investor, _amount);
        emit LGOClaimed(investor, _amount);
    }

    function claimAllLGO() external onlyInvestor {
        LEVEL_STAKE.claimRewards(address(this));
        uint256 _amount = LGO.balanceOf(address(this));
        LGO.transfer(investor, _amount);
        emit LGOClaimed(investor, _amount);
    }

    function stakeForInvestor(uint256 _amount) external onlyOwner {
        LVL.transferFrom(msg.sender, address(this), _amount);
        _stake(_amount);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 _amount = LVL.balanceOf(address(this));
        claimedAmount += _amount;
        LVL.transfer(investor, _amount);
        emit Withdrawn(investor, _amount);
    }

    function transferInvestor(address _investor) external onlyOwner {
        require(_investor != address(0), "Invalid address");
        investor = _investor;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
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

    event Staked(uint256 _amount);
    event Unstaked(uint256 _amount);
    event Cooldown(address indexed _user);
    event EmergencyEnabled();
    event Withdrawn(address indexed _receiver, uint256 _amount);
    event LGOClaimed(address indexed _receiver, uint256 _amount);
}