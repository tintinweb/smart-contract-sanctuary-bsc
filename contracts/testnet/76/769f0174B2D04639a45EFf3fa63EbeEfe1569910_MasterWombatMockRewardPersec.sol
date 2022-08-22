pragma solidity ^0.8.0;

import "../interfaces/IStandardTokenMock.sol";
import "../../interfaces/wombat/IMasterWombat.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MasterWombatMockRewardPersec is IMasterWombat {

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 available; // in case of locking
    }

    // Info of each pool.
    struct PoolInfo {
        address lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. MGPs to distribute per second.
        uint256 lastRewardTimestamp; // Last timestamp that MGPs distribution occurs.
        uint256 accRewardPerShare; // Accumulated MGPs per share, times 1e12. See below.
    }

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    mapping(uint256 => PoolInfo) public pidToPoolInfo;
    // amount everytime deposit or withdraw will get

    mapping (address => uint256) public lpToPid;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    address public rewardToken;
    // MGP tokens created per second.
    uint256 public rewardPerSec;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // reward upon each deposit and withdraw call;
    

    // The timestamp when MGP mining starts.
    uint256 public startTimestamp;    

    constructor(address _rewardToken,
                uint256 _rewardPerSec
    ) {
        rewardToken = _rewardToken;
        rewardPerSec = _rewardPerSec;
        startTimestamp = block.timestamp;
        totalAllocPoint = 10;
    }

    function getAssetPid(address lp) override external view returns(uint256) {
        return lpToPid[lp];
    }

    /// @notice Deposit LP tokens to Master Magpie for MGP allocation.
    /// @dev it is possible to call this function with _amount == 0 to claim current rewards
    function depositFor(uint256 _pid, uint256 _amount, address _account) override external {
        _deposit(_pid, _amount, _account);
    }

    function deposit(uint256 _pid, uint256 _amount) override external returns (uint256, uint256) {
        _deposit(_pid, _amount, msg.sender);
    }

    function _deposit(uint256 _pid, uint256 _amount, address _account) internal {
        updatePool(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_account];
        
        IERC20 poolLpToken = IERC20(pool.lpToken);        
        
        poolLpToken.transferFrom(address(msg.sender), address(this), _amount);

        if (user.amount > 0) {
            _harvest(_pid, _account);
            user.rewardDebt = (user.amount * pool.accRewardPerShare) / 1e12;
        }

        user.amount += _amount;
    }
 
    function withdraw(uint256 _pid, uint256 _amount) override external returns (uint256, uint256) {
        updatePool(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount && user.amount > 0,  'withdraw: not good');
        
        _harvest(_pid, msg.sender);
        user.rewardDebt = (user.amount * pool.accRewardPerShare) / 1e12;
        user.amount = user.amount - _amount;

        IERC20 poolLpToken = IERC20(pool.lpToken);
        poolLpToken.transfer(address(msg.sender), _amount);
    }

    function multiClaim(uint256[] memory _pids) override external returns (
        uint256,
        uint256[] memory,
        uint256[] memory
    ) {
        uint256[] memory amounts = new uint256[](_pids.length);
        uint256[] memory additionalRewards= new uint256[](_pids.length);
        uint256 transfered;

        for (uint256 i = 0; i < _pids.length; i++) {            
            PoolInfo storage pool = poolInfo[_pids[i]];
            UserInfo storage user = userInfo[_pids[i]][msg.sender];
            updatePool(_pids[i]);
            if (user.amount > 0)
                _harvest(_pids[i], msg.sender);
            user.rewardDebt = (user.amount * pool.accRewardPerShare) / 1e12;
        }
        
        return (0, amounts, additionalRewards); // return value is wrong
    }


    function safeWOMTransfer(address payable to, uint256 _amount) internal {
        IStandardTokenMock(rewardToken).mint(to, _amount);
    }

    function addPool(address lp, uint256 _allocpoint) external returns (uint256) {
        PoolInfo memory newPool = PoolInfo(lp, _allocpoint, block.timestamp, 0);
        poolInfo.push(newPool);
        uint256 poolId = poolInfo.length - 1;
        pidToPoolInfo[poolId] = newPool;        
        lpToPid[lp] = poolId;
        return poolId;
    }

    function pendingTokens(uint256 _pid, address _user) override public view
        returns (
            uint256 pendingMGP,
            address bonusTokenAddress,
            string memory bonusTokenSymbol,
            uint256 pendingBonusToken
        ) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = IERC20(pool.lpToken).balanceOf(address(this));
        
        if (block.timestamp > pool.lastRewardTimestamp && lpSupply != 0) {
            uint256 multiplier = block.timestamp - pool.lastRewardTimestamp;
            uint256 rewards = (multiplier * accRewardPerShare * pool.allocPoint) /
            totalAllocPoint;
            accRewardPerShare = accRewardPerShare + (rewards * 1e12) / lpSupply;
        }

        pendingMGP = (user.amount * accRewardPerShare) / 1e12 - user.rewardDebt;
    }

    function rewardAmounts(uint256 _pid) external view returns(uint256) {
        this.pendingTokens(_pid, msg.sender);
    }

    /// @notice Harvest MGP for an account
    function _harvest(uint256 _pid, address _account) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_account]; 
        // Harvest MGP
        uint256 pending = (user.amount * pool.accRewardPerShare) /
            1e12 -
            user.rewardDebt;
        IStandardTokenMock(rewardToken).mint(_account, pending);
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTimestamp) {
            return;
        }
        uint256 lpSupply = IERC20(pool.lpToken).balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardTimestamp = block.timestamp;
            return;
        }
        uint256 multiplier = block.timestamp - pool.lastRewardTimestamp;
        uint256 mgpReward = (multiplier * rewardPerSec * pool.allocPoint) /
            totalAllocPoint;
        
        pool.accRewardPerShare = pool.accRewardPerShare + ((rewardPerSec * 1e12) / lpSupply);
        pool.lastRewardTimestamp = block.timestamp;
    }        


}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStandardTokenMock is IERC20 {

    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;
}

pragma solidity ^0.8.0;

interface IMasterWombat {

    function getAssetPid(address lp) external view returns(uint256);
    
    function depositFor(uint256 pid, uint256 amount, address account) external;

    function deposit(uint256 _pid, uint256 _amount) external returns (uint256, uint256);

    function withdraw(uint256 _pid, uint256 _amount) external returns (uint256, uint256);

    function multiClaim(uint256[] memory _pids) external returns (
        uint256 transfered,
        uint256[] memory amounts,
        uint256[] memory additionalRewards
    );

    function pendingTokens(uint256 _pid, address _user) external view
        returns (
            uint256 pendingMGP,
            address bonusTokenAddress,
            string memory bonusTokenSymbol,
            uint256 pendingBonusToken
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}