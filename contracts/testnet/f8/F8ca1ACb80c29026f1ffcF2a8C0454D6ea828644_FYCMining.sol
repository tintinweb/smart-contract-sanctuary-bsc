// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract FYCMining {
    struct User {
        address inviter;
        uint inviterReward;
        UserSlot[3] slots; 
    }
    
    struct UserSlot {
        uint debt;
        uint toClaim;
        uint lastStakeTime;
        uint releaseTime;
        uint stakeAmount;
        uint stakePower;
        uint totalClaimed;
    }

    struct Slot {
        uint lockTime;
        uint power;
    }
    Slot[3] public slots;

    struct Meta {
        uint startTime;
        address pair;
        address fyc;
        uint totalClaimed;
        uint totalInviterReward;
        address owner;
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
        uint endDebted;
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
    event Deposit(address indexed account, uint indexed amount, uint indexed reward);

    constructor () {
        pool.rate = 100000 * 1e18 / (uint(86400 * 30 * 6));
        meta.pair = 0x928C72A8B58A08be10166B19673c336CF88Bd5B9;
        meta.fyc = 0xE0BF38a1773b58b5bBE8Ca45C567C2569695181A;
        meta.owner = msg.sender;

        slots[0] = Slot({
            lockTime: 0,
            power: 10
        });
        slots[1] = Slot({
            lockTime: 86400 * 15,
            power: 15
        });
        slots[2] = Slot({
            lockTime: 86400 * 30,
            power: 30
        });
    }

    modifier checkTime() {
        if (pool.startTime == 0 && pool.totalValue == 0) {
            uint month = 86400 * 30;
            pool.startTime = block.timestamp;
            pool.endTime = block.timestamp + month * 3;
            pool.stage1Time = block.timestamp + month;
            pool.stage2Time = pool.stage1Time + month;
        }

        if (pool.stage1Debt == 0 && block.timestamp >= pool.stage1Time) {
            pool.stage1Debt = coutingDebt();
        }

        if (pool.stage2Debt == 0 && block.timestamp >= pool.stage2Time) {
            pool.stage2Debt = coutingDebt();
        }

        if (pool.endDebted == 0 && block.timestamp >= pool.endTime)  {
            pool.endDebted = coutingDebt();
        }
        _;
    }

    modifier checkSlot(uint slotId_) {
        require(slotId_ >= 0 && slotId_ < 3, "wrong pool Id");
        _;
    }

    function setStartTime(uint tm_) external {
        require(msg.sender == meta.owner, "not owner");
        require(tm_ > block.timestamp, "wrong time");

        meta.startTime = tm_;
        meta.owner = address(0);
    }

    function coutingDebt() public view returns (uint) {
        if (pool.endDebted != 0) {
            return pool.endDebted;
        }
        uint newDebt = pool.totalValue > 0 ? pool.rate * (block.timestamp - pool.lastTime) * acc / pool.totalValue + pool.debted : 0 + pool.debted;
        return newDebt;
    }

    function validationInviter(address account_) public view returns(bool) {
        if (account_ == address(this) || account_ == address(0)) {
            return true;
        }

        for (uint i = 0; i < 3; i++) {
            if (userInfo[account_].slots[i].stakeAmount > 0) {
                return true;
            }
        }
        return false;
    }

    function viewReward(address account_, uint slotId_) public view returns(uint, uint) {
        UserSlot memory userSlot = userInfo[account_].slots[slotId_];
        if (userSlot.stakeAmount == 0) {
            return (0, userSlot.totalClaimed);
        }

        uint reward;
        uint userDebt = userSlot.debt;

        uint adjustRate = 3;
        if (pool.stage1Debt != 0 ) {
            if (userSlot.debt < pool.stage1Debt) {
                reward += adjustRate * userSlot.stakePower * (pool.stage1Debt - userSlot.debt) / acc;
                userDebt = pool.stage1Debt;
            }
            adjustRate = 2;
        }
        if (pool.stage2Debt != 0) {
            if (userSlot.debt < pool.stage2Debt) {
                reward += adjustRate * userSlot.stakePower * (pool.stage2Debt - userDebt) / acc;
                userDebt = pool.stage2Debt;
            }
            adjustRate = 1;
        }

        reward += adjustRate * userSlot.stakePower * (coutingDebt() - userDebt) / acc;
        return (userSlot.toClaim + reward, userSlot.totalClaimed);
    }

    function viewUserInfoBatch(address account_) external view returns(uint inviterReward, uint stakeAmount, uint stakePower, uint reward, uint rewarded, uint[6][4] memory info) {
        inviterReward = userInfo[account_].inviterReward;
        UserSlot memory userSlot;
        for (uint i = 0; i < 4; i++) {
            uint[6] memory slotInfo;
            userSlot = userInfo[account_].slots[i];
            slotInfo[0] = userSlot.stakeAmount;
            slotInfo[1] = userSlot.stakePower;
            slotInfo[2] = userSlot.lastStakeTime;
            slotInfo[3] = userSlot.releaseTime;
            (slotInfo[4], slotInfo[5]) = viewReward(account_, i);

            stakeAmount += slotInfo[0];
            stakePower += slotInfo[1];
            reward += slotInfo[4];
            rewarded += slotInfo[5];
            info[i] = slotInfo;
        }
    }

    function stake(uint amount_, uint slotId_, address inviter_) external checkSlot(slotId_) checkTime  {
        require(amount_ > 0, "amount cannot be zero");
        require(block.timestamp >=  meta.startTime, "not open");

        if (pool.startTime != 0) {
            require(block.timestamp < pool.endTime, "ended");
        }

        if (userInfo[msg.sender].inviter == address(0) && inviter_ != address(0) && inviter_ != msg.sender) {
            require(validationInviter(inviter_), "wrong inviter");
            userInfo[msg.sender].inviter = inviter_;
        }

        UserSlot storage userSlot = userInfo[msg.sender].slots[slotId_];
        if (userSlot.stakeAmount > 0) {
            (uint reward,) = viewReward(msg.sender, slotId_);
            userSlot.toClaim = reward;
        }

        IERC20(meta.pair).transferFrom(msg.sender, address(this), amount_);

        uint newDebt = coutingDebt();

        uint stakeValue = amount_ * slots[slotId_].power / 10;
        pool.totalValue += stakeValue;
        pool.debted = newDebt;
        pool.lastTime = block.timestamp;

        userSlot.debt = newDebt;
        userSlot.lastStakeTime = block.timestamp;
        userSlot.releaseTime = block.timestamp + slots[slotId_].lockTime;
        userSlot.stakeAmount += amount_;
        userSlot.stakePower += stakeValue;

        emit Stake(msg.sender, amount_);
    }


    function unStake(uint slotId_) external checkSlot(slotId_) checkTime {
        UserSlot storage userSlot = userInfo[msg.sender].slots[slotId_];
        require(userSlot.stakeAmount > 0, "not stake");

        if ( block.timestamp < pool.endTime) {
            require(block.timestamp >= userSlot.releaseTime, "not expired");
        }

        _claimReward(msg.sender, slotId_);
        IERC20(meta.pair).transfer(msg.sender, userSlot.stakeAmount);
        
        uint newDebt = coutingDebt();
        pool.totalValue -= userSlot.stakeAmount;
        pool.debted = newDebt;
        pool.lastTime = block.timestamp;
        
        userSlot.debt = 0;
        userSlot.stakeAmount = 0;
        userSlot.stakePower = 0;
        userSlot.releaseTime = 0;
        userSlot.lastStakeTime = 0;

        emit UnStake(msg.sender, userSlot.stakeAmount);
    }

    function claimReward(uint slotId_) external checkSlot(slotId_) checkTime {
        (uint stakeReward,) = viewReward(msg.sender, slotId_);
        require(stakeReward > 0, "not reward");

        _claimReward(msg.sender, slotId_);
    }

    function climAllReward() external checkTime {
        for (uint i = 0; i < 4; i++) {
            _claimReward(msg.sender, i);
        }
    }

    // make sure the user gets their money back
    function _deposit(uint slotId_) external {
        UserSlot storage userSlot = userInfo[msg.sender].slots[slotId_];
        require(block.timestamp >= userSlot.releaseTime, "not expired");

        (uint stakeReward,) = viewReward(msg.sender, slotId_);
        if (stakeReward == 0 || IERC20(meta.fyc).balanceOf(address(this)) > stakeReward) {
            require(true, "error");
        }

        IERC20(meta.pair).transfer(msg.sender, userSlot.stakeAmount);
        
        uint newDebt = coutingDebt();
        pool.totalValue -= userSlot.stakeAmount;
        pool.debted = newDebt;
        pool.lastTime = block.timestamp;
        
        userSlot.debt = 0;
        userSlot.toClaim = 0;
        userSlot.stakeAmount = 0;
        userSlot.stakePower = 0;
        userSlot.releaseTime = 0;
        userSlot.lastStakeTime = 0;

        emit Deposit(msg.sender, userSlot.stakeAmount, stakeReward);
    }

    function _claimReward(address account_, uint slotId_) private {
        (uint stakeReward,) = viewReward(account_, slotId_);
        if (stakeReward == 0) {
            return;
        }

        uint inviterReward = stakeReward / 10;
        uint reward = stakeReward - inviterReward;

        address inviter = userInfo[account_].inviter;
        if (inviter == address(0) || inviter == address(this)) {
            userInfo[address(this)].inviterReward += inviterReward;
        } else {
            IERC20(meta.fyc).transfer(inviter, inviterReward);
        }

        IERC20(meta.fyc).transfer(account_, reward);

        UserSlot storage info = userInfo[account_].slots[slotId_];
        info.totalClaimed += reward;
        info.debt = coutingDebt();
        info.toClaim = 0;

        userInfo[inviter].inviterReward += inviterReward;
        meta.totalClaimed += reward;
        meta.totalInviterReward += inviterReward;

        emit ClaimReward(account_, stakeReward);
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