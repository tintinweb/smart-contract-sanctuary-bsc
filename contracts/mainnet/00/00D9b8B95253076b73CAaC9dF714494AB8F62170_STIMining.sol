// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract STIMining {
    struct User {
        address inviter;
        uint debt;
        uint toClaim;
        uint stakeAmount;
        uint totalClaimed;
        uint inviterReward;
    }
    struct Meta {
        uint startTime;
        address pair;
        address sti;
        uint totalClaimed;
        uint totalInviterReward;
    }
    struct Debt {
        uint startTime;
        uint stage1Time;
        uint stage2Time;
        uint stage1Debt;
        uint stage2Debt;
        uint endTime;
        uint lastTime;
        uint debted;
        uint rate;
        uint totalValue; 
    }
    uint constant acc = 1e10;
    Meta public meta;
    Debt public pool;
    
    mapping(address => User) public userInfo;
    
    event Stake(address indexed account, uint indexed amount);
    event UnStake(address indexed account, uint indexed amount);
    event ClaimReward(address indexed account, uint indexed amount);

    constructor () {
        pool.rate = 500000 * 10000000000 / (uint(86400 * 30 * 6));
        meta.pair = 0x928C72A8B58A08be10166B19673c336CF88Bd5B9;
        meta.sti = 0x4f5f7a7Dca8BA0A7983381D23dFc5eaF4be9C79a;
        meta.startTime = 1648641600;   // 2022-03-30 20:00:00
    }

    modifier checkTime() {
        if (pool.startTime == 0 && pool.totalValue == 0) {
            uint month = 86400 * 30;
            pool.startTime = block.timestamp;
            pool.endTime = block.timestamp + month * 18;
            pool.stage1Time = block.timestamp + month * 6;
            pool.stage2Time = pool.stage1Time + month * 6;
        }

        if (pool.stage1Debt == 0 && block.timestamp >= pool.stage1Time) {
            pool.stage1Debt = coutingDebt();
        }

        if (pool.stage2Debt == 0 && block.timestamp >= pool.stage2Time) {
            pool.stage2Debt = coutingDebt();
        }
        _;
    }


    function coutingDebt() public view returns (uint) {
        uint tm = block.timestamp;
        if (pool.endTime != 0 && tm > pool.endTime) {
            tm = pool.endTime;
        }
        uint newDebt = pool.totalValue > 0 ? pool.rate * (tm - pool.lastTime) * acc / pool.totalValue + pool.debted : 0 + pool.debted;
        return newDebt;
    }


    function viewReward(address account_) public view returns(uint) {
        User memory info = userInfo[account_];
        if (info.stakeAmount == 0) {
            return 0;
        }

        uint reward;
        uint userDebt = info.debt;

        uint adjustRate = 4;
        if (pool.stage1Debt != 0 ) {
            adjustRate = 2;
            if (info.debt < pool.stage1Debt) {
                reward += adjustRate * info.stakeAmount * (pool.stage1Debt - info.debt) / acc;
                userDebt = pool.stage1Debt;
            }
        }
        if (pool.stage2Debt != 0) {
            adjustRate = 1;
            if (info.debt < pool.stage2Debt) {
                reward += adjustRate * info.stakeAmount * (pool.stage2Debt - info.debt) / acc;
                userDebt = pool.stage2Debt;
            }
        }

        reward += info.stakeAmount * (coutingDebt() - userDebt) / acc;
        reward = adjustRate * reward;
        return (info.toClaim + reward);
    }

    function stake(uint amount_, address inviter_) external checkTime  {
        require(amount_ > 0, "amount cannot be zero");
        require(block.timestamp >=  meta.startTime, "not open");

        if (pool.startTime != 0) {
            require(block.timestamp < pool.endTime, "ended");
        }


        User storage user = userInfo[msg.sender];
        if (user.inviter == address(0) && inviter_ != address(0)) {
            if (inviter_ != address(this)) {
                require(userInfo[inviter_].inviter != address(0), "wrong inviter");
            }
            user.inviter = inviter_;
        }

        if (user.stakeAmount > 0) {
            user.toClaim = viewReward(msg.sender);
        }

        IERC20(meta.pair).transferFrom(msg.sender, address(this), amount_);


        uint newDebt = coutingDebt();

        pool.totalValue += amount_;
        pool.debted = newDebt;
        pool.lastTime = block.timestamp;

        userInfo[msg.sender].debt = newDebt;
        userInfo[msg.sender].stakeAmount += amount_;

        emit Stake(msg.sender, amount_);
    }

    function validationInviter(address account_) public view returns(bool) {
        if (account_ == address(this) || account_ == address(0)) {
            return true;
        }
        return userInfo[account_].inviter != address(0);
    }


    function unStake() external checkTime {
        uint stakeAmount = userInfo[msg.sender].stakeAmount;
        require(stakeAmount > 0, "not stake");

        claimReward();
        IERC20(meta.pair).transfer(msg.sender, stakeAmount);
        
        uint newDebt = coutingDebt();
        pool.totalValue -= stakeAmount;
        pool.debted = newDebt;
        pool.lastTime = block.timestamp;
        
        userInfo[msg.sender].debt = 0;
        userInfo[msg.sender].stakeAmount = 0;

        emit UnStake(msg.sender, stakeAmount);
    }

    function claimReward() public checkTime {
        uint stakeReward = viewReward(msg.sender);
        if (stakeReward == 0) {
            return;
        }

        uint inviterReward = stakeReward / 10;
        uint reward = stakeReward - inviterReward;

        address inviter = userInfo[msg.sender].inviter;
        if (inviter == address(0)) {
            inviter = 0xe12BA4fb6e863c89E9Bf9Db1B54Da225612Fd5a5;
        }

        IERC20(meta.sti).transfer(inviter, inviterReward);
        IERC20(meta.sti).transfer(msg.sender, reward);

        User storage user = userInfo[msg.sender];
        user.totalClaimed += reward;
        user.debt = coutingDebt();
        user.toClaim = 0;

        userInfo[inviter].inviterReward += inviterReward;
        meta.totalClaimed += reward;
        meta.totalInviterReward += inviterReward;

        emit ClaimReward(msg.sender, stakeReward);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}