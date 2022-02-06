// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./interfaces/IPulsedoge.sol";

/// @title Contract to hold EchoStake reward tokens.
contract MasterRewardHolder {
    address owner;

    constructor() {
        /*
         * This contract must be launched from EchoStake, i.e owner
         * is EchoStake
         */
        owner = address(msg.sender);
    }

    /// @notice Approve reward tokens to be used by EchoStake contract
    /// @dev Must be called from EchoStake contract
    /// @param pulsedoge pulsedoge token contract address
    /// @param amount Number to tokens to approve
    function approveRewards(address pulsedoge, uint256 amount) external {
        require(msg.sender == owner, "Caller must be EchoStake");

        IPulsedoge pulse = IPulsedoge(pulsedoge);

        pulse.approve(msg.sender, amount);
    }
}

/// @title EchoStake contract.
contract EchoStake {
    struct Stake {
        uint256 stakedAmount;
        uint256 numDays;
        uint256 stakedAt;
        uint256 rewardAmount;
        uint256 lotteryRewardPercent;
        uint8 status;
    }

    /*
     * 50% of pre-mature end staking rewards/penalty amount is 'BURNED',
     */
    /// Maximum active stakes per user at any point of time
    uint256 public constant MAX_NUM_OF_STAKES_PER_USER = 10;
    /// Minimum number of staking days
    uint256 public constant MIN_NUM_OF_DAYS = 1;
    /// Maximum number of staking days
    uint256 public constant MAX_NUM_OF_DAYS = 369;
    /// Base Percentage of interest per day. 0.0816 %.
    uint256 public constant BASE_REWARD_INTEREST = 816;
    /// Maximum reward tokens per year
    uint256 public constant MAX_REWARDS_PER_YEAR = 369e5 ; //36.9M rewards per year
    /// Owner of the contract, can be renounced.
    address owner;
    /// Lottery Token Reward percentage for staker. This is the percentage of user stake reward amount
    /// Staker gets lottery reward amount equal to lotteryRewardPercent% of reward amount.
    uint256 public lotteryRewardPercent;

    /// pulsedoge token address
    IPulsedoge public immutable pulsedoge;
    /// xPulsedoge token address
    IPulsedoge public immutable xPulsedoge;

    /// Reward holder contract where rewards are sent to, by reward adders
    MasterRewardHolder public masterRewardHolder;

    /// Remaining number of reward tokens in yearly reward pool
    uint256 public yearlyRewardPool;
    /// total active staked amount by all stakers
    uint256 public totalStakedAmount;
    /// Last time when the yearly reward pool was reset
    uint256 lastYearlyPoolUpdate;
    /// All stakes
    mapping(address => Stake[MAX_NUM_OF_STAKES_PER_USER]) internal stakes;

    /// @notice Emitted when a user enters into staking
    /// @param user user/staker address
    /// @param stakedAmount number of tokens staked
    /// @param rewardAmount reward amount that a user can get after end of the staking period.
    /// @param numDays number of days that user staked for
    /// @param stakeId stake index assigned for this stake
    event EnterStake(
        address indexed user,
        uint256 indexed stakedAmount,
        uint256 rewardAmount,
        uint256 lotteryRewardAmount,
        uint256 numDays,
        uint256 stakeId
    );

    /// @notice Emitted when a user leaves from staking
    /// @param user user/staker address
    /// @param stakeId staking index that left the stake
    /// @param amount number of staked tokens returned to user/staker address.
    ///        it could be less than actual staked amount due to pre-mature penalty.
    /// @param reward reward tokens given to user. It could be ZERO due to pre-mature leave from stake
    event LeaveStake(
        address indexed user,
        uint256 indexed stakeId,
        uint256 amount,
        uint256 reward,
        uint256 lotteryReward
    );

    /// @notice Emitted when a owner sets lottery reward percentage
    /// @param lotteryRewardPercent  lottery reward percentage
    event SetLotteryReward(uint256 lotteryRewardPercent);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /// @param _pulsedogeToken pulsedoge Token address
    /// @param _xPulsedogeToken xPulsedoge Token address
    constructor(address _pulsedogeToken, address _xPulsedogeToken) {
        /* deploy MasterRewardHolder */
        masterRewardHolder = new MasterRewardHolder();
        pulsedoge = IPulsedoge(_pulsedogeToken);
        xPulsedoge = IPulsedoge(_xPulsedogeToken);

        yearlyRewardPool = MAX_REWARDS_PER_YEAR;
        lastYearlyPoolUpdate = block.timestamp;

        owner = msg.sender;
    }

    /// @notice staking function.
    /// @param amount number of pulsedoge tokens the user wants to stake
    /// @param numDays number of days the user wants stake for
    function enterStaking(uint256 amount, uint256 numDays) external {
        require(amount >= 1 , "too less amount for staking");
        require(
            (numDays > 0) && (numDays <= MAX_NUM_OF_DAYS),
            "Invalid number of days"
        );

        Stake[MAX_NUM_OF_STAKES_PER_USER] storage userStakes = stakes[
            msg.sender
        ];

        uint256 i;

        for (i = 0; i < MAX_NUM_OF_STAKES_PER_USER; i++) {
            if (userStakes[i].status == 0) break;
        }

        require(
            i < MAX_NUM_OF_STAKES_PER_USER,
            "Reached per user maximum limit"
        );

        /* Precalculate the rewards for the given days */
        uint256 rewardAmount = _calculateFixedReward(amount, numDays);

        /* Reset maximum rewards-per-year pool */
        if (
            block.timestamp >
            (lastYearlyPoolUpdate + (MAX_NUM_OF_DAYS * 1 days))
        ) {
            yearlyRewardPool = MAX_REWARDS_PER_YEAR;
            lastYearlyPoolUpdate =
                lastYearlyPoolUpdate +
                (MAX_NUM_OF_DAYS * 1 days);
        }

        /* Rewards in a year cannot exceed MAX_REWARDS_PER_YEAR */
        require(
            rewardAmount <= yearlyRewardPool,
            "Maximum rewards reached this year"
        );

        /* Underflow will revert the transaction */
        yearlyRewardPool -= rewardAmount;

        userStakes[i].numDays = numDays;
        userStakes[i].stakedAt = block.timestamp;
        userStakes[i].stakedAmount = amount;
        userStakes[i].rewardAmount = rewardAmount;
        userStakes[i].lotteryRewardPercent = lotteryRewardPercent;
        userStakes[i].status = 1;

        totalStakedAmount += amount;

        uint256 lotteryRewardAmount = 0;

        if (lotteryRewardPercent != 0) {
            lotteryRewardAmount = (rewardAmount * lotteryRewardPercent) / 100;
        }

        emit EnterStake(
            msg.sender,
            amount,
            rewardAmount,
            lotteryRewardAmount,
            numDays,
            i
        );

        /*
         * Receive staking amount into this contract, user must
         * have approved 'amount' of pulsedoge tokens to this contract.
         * it will revert if transfer fails.
         */
        pulsedoge.transferFrom(msg.sender, address(this), amount);

        /*
         * Now, transfer reward amount from MasterRewardHolder address, it
         * will revert if transfer fails.
         */
        pulsedoge.transferFrom(
            address(masterRewardHolder),
            address(this),
            rewardAmount
        );

        /*
         * Transfer lottery reward amount from MasterRewardHolder address, it
         * will revert if transfer fails.
         */

        if (lotteryRewardAmount != 0) {
            xPulsedoge.transferFrom(
                address(masterRewardHolder),
                address(this),
                lotteryRewardAmount
            );
        }
    }

    /// @notice leave staking function.
    /// @param stakeId index of the stake to leave from
    function leaveStaking(uint256 stakeId) external {
        require(stakeId < MAX_NUM_OF_STAKES_PER_USER, "Invalid stake index");

        Stake storage stake = stakes[msg.sender][stakeId];

        require(stake.status == 1, "Not staked");

        stake.status = 0;

        uint256 stakedAmount = stake.stakedAmount;
        uint256 stakedAt = stake.stakedAt;
        uint256 numDays = stake.numDays;
        uint256 rewardAmount = stake.rewardAmount;
        uint256 lotteryRewardPercentage = stake.lotteryRewardPercent;

        /* Calculate rewards and staked tokens to transfer to the staker.
         * Rewards could be ZERO and staked amount also can be less due to
         * premature end of the stake.
         */
        (uint256 reward, uint256 amount) = _calculateRewards(
            stakedAmount,
            stakedAt,
            numDays,
            rewardAmount
        );

        totalStakedAmount -= stakedAmount;

        /*
         * if total tokens to user is less than precalculated rewards + stakedAmount,
         * Send back 50% to reward pool and  burn left over 50%.
         */
        uint256 leftOver = (rewardAmount + stakedAmount) - (reward + amount);
        uint256 toBurn = 0;
        uint256 toRewardPool = 0;

        if (leftOver > 0) {
            toBurn = leftOver / 2;
            toRewardPool = leftOver - toBurn;

            /*
             * Add back leftOver rewards to yearly Reward Pool
             * if staking and unstaking done in the same year.
             */
            if (stakedAt > lastYearlyPoolUpdate) {
                /* Make sure yearlyRewardPool will not exceed MAX_REWARDS_PER_YEAR per year */
                if ((yearlyRewardPool + toRewardPool) < MAX_REWARDS_PER_YEAR)
                    yearlyRewardPool += toRewardPool;
                else yearlyRewardPool = MAX_REWARDS_PER_YEAR;
            }
        }

        uint256 lotteryReward = 0;
        if (lotteryRewardPercentage != 0) {
            lotteryReward = (reward * lotteryRewardPercentage) / 100;
        }

        emit LeaveStake(msg.sender, stakeId, amount, reward, lotteryReward);

        if (leftOver > 0) {
            pulsedoge.burn(address(this), toBurn);
            pulsedoge.transfer(address(masterRewardHolder), toRewardPool);
        }

        /* transfer reward and stake amount to user */
        pulsedoge.transfer(msg.sender, reward + amount);

        /* transfer lottery reward amount to user*/
        if (lotteryRewardPercentage != 0) {
            if (lotteryReward != 0) {
                xPulsedoge.transfer(msg.sender, lotteryReward);
            }

            /* For early un-stakes, user gets less reward so transfring remaining reward amount
             * to masterRewardHolder.
             */
            if (rewardAmount != reward) {
                uint256 LeftOverLotteryReward = ((rewardAmount - reward) *
                    lotteryRewardPercentage) / 100;
                xPulsedoge.transfer(
                    address(masterRewardHolder),
                    LeftOverLotteryReward
                );
            }
        }
    }

    /// @notice Get active stakeIds of a user
    /// @param user user/staker address
    /// @return stakeIds array of stakes indices
    /// @return numStakes number of stakes
    function getUserStakeIds(address user)
        external
        view
        returns (uint256[] memory stakeIds, uint256 numStakes)
    {
        uint256 i;
        uint256 j = 0;

        for (i = 0; i < MAX_NUM_OF_STAKES_PER_USER; i++) {
            if (stakes[user][i].status == 1) numStakes++;
        }

        if (numStakes > 0) {
            stakeIds = new uint256[](numStakes);
            for (i = 0; i < MAX_NUM_OF_STAKES_PER_USER; i++) {
                if (stakes[user][i].status == 1) {
                    stakeIds[j] = i;
                    j++;
                }
            }
        }
    }

    /**
     * @notice Get a stake info of a stake holder given stake index/id
     * @param user user/staker address
     * @param stakeId Index of the stake
     * @return stakedAmount staked amount
     * @return stakedAt timestamp(in Epoch) when the stake was created/entered
     * @return numDays number of staking days
     * @return rewardAmount reward tokens user gets after successful end of the stake
     * @return lotteryRewardAmount Lottery reward tokens user gets after successful end of the stake
     */
    function getUserStakeInfo(address user, uint256 stakeId)
        external
        view
        returns (
            uint256 stakedAmount,
            uint256 stakedAt,
            uint256 numDays,
            uint256 rewardAmount,
            uint256 lotteryRewardAmount
        )
    {
        if (
            stakeId < MAX_NUM_OF_STAKES_PER_USER &&
            stakes[user][stakeId].status == 1
        ) {
            stakedAmount = stakes[user][stakeId].stakedAmount;
            stakedAt = stakes[user][stakeId].stakedAt;
            numDays = stakes[user][stakeId].numDays;
            rewardAmount = stakes[user][stakeId].rewardAmount;
            lotteryRewardAmount =
                (rewardAmount * stakes[user][stakeId].lotteryRewardPercent) /
                100;
            return (
                stakedAmount,
                stakedAt,
                numDays,
                rewardAmount,
                lotteryRewardAmount
            );
        } else {
            return (0, 0, 0, 0, 0);
        }
    }

    /// @notice Find rewards and staked amount that a user gets by ending
    ///         a stake 'now'. This is just a helper function to get how much user may
    ///         get by ending stake at any point of time.
    /// @param user user/staker address
    /// @param stakeId stake index
    /// @return reward reward amount user may get by ending the stake 'now'
    /// @return amount staked amount user may get by ending the stake 'now'
    /// @return lotteryReward Lottery reward amount user may get by ending the stake 'now'
    function getUserClaimableRewards(address user, uint256 stakeId)
        external
        view
        returns (
            uint256 reward,
            uint256 amount,
            uint256 lotteryReward
        )
    {
        if (
            stakeId < MAX_NUM_OF_STAKES_PER_USER &&
            stakes[user][stakeId].status == 1
        ) {
            Stake storage stake = stakes[user][stakeId];
            (reward, amount) = _calculateRewards(
                stake.stakedAmount,
                stake.stakedAt,
                stake.numDays,
                stake.rewardAmount
            );
            lotteryReward = (reward * stake.lotteryRewardPercent) / 100;
            return (reward, amount, lotteryReward);
        } else {
            return (0, 0, 0);
        }
    }

    /// @notice Find user penalty info if any if a user ends
    ///         a stake 'now'. This is just a helper function to get know any penalty user may
    ///         get by ending stake ealry at any point of time.
    /// @param user user/staker address
    /// @param stakeId stake index
    /// @return amount staked amount user may get by ending the stake 'now'
    function getUserPenalty(address user, uint256 stakeId)
        external
        view
        returns (
            uint256 
        )
    {
        if (
            stakeId < MAX_NUM_OF_STAKES_PER_USER &&
            stakes[user][stakeId].status == 1
        ) {
            Stake storage stake = stakes[user][stakeId];
            ( , uint256 amount) = _calculateRewards(
                stake.stakedAmount,
                stake.stakedAt,
                stake.numDays,
                stake.rewardAmount
            );
            return (stake.stakedAmount  - amount);
        } else {
            return 0;
        }
    }

    /// @notice Approve tokens from masterRewardHolder to this contract
    /// @dev All reward tokens are with 'MasterRewardHolder'. Owner of this
    ///      contract must call this function once before users start staking
    ///      to allow this contract to withdraw reward tokens. Make sure maximum
    ///      number of tokens are approved before 'renouncing the ownership'.
    /// @param amount Number to tokens to approve for
    function approveRewards(uint256 amount) external {
        require(msg.sender == owner, "Call from non owner");
        masterRewardHolder.approveRewards(address(pulsedoge), amount);
    }

    /// @notice Approve Lottery tokens from masterRewardHolder to this contract
    /// @dev All Lottery reward tokens are with 'MasterRewardHolder'. Owner of this
    ///      contract must call this function once before users start staking
    ///      to allow this contract to withdraw reward tokens. Make sure maximum
    ///      number of tokens are approved before 'renouncing the ownership'.
    /// @param amount Number to tokens to approve for
    function approveLotteryRewards(uint256 amount) external {
        require(msg.sender == owner, "Call from non owner");
        masterRewardHolder.approveRewards(address(xPulsedoge), amount);
    }

    /// @notice Renounce Ownership of this contract
    /// @dev Once renounced, owner doesn't have any more control on this contract,
    ///      make sure you call approveRewards() before this.
    function renounceOwnership() external {
        require(msg.sender == owner, "Must be owner");
        owner = address(0);
    }

    /**
     * Following functions calculate rewards and penalty.
     * Rewards are calculated as follows:
     * 1. One can stake for 1 to 369 days.
     * 2. And, per each day:
     *      1 days - 0.0816
     *      2 days - 1 days % + 0.0817 %
     *      3 days - 2 days % + 0.0818 %
     *      ...
     *      369 days =  368 days % + 0.1184
     *
     * But, for premature ending of the stake:
     *
     * If the stake is ended before half of the mature days:
     *       * ZERO rewards are given
     *       * A PENALTY on staked amount is applied. Penalty equation as follows:
     *              D = Number of staked days
     *              E = Number of days by the time of unstaking, it will < D/2
     *              X = per day penalty % = 100 / (D/2)
     *              Y = Number of days to apply penalty on = D/2 - E
     *
     *             Penalty percentage =  X * Y
     *
     * If the stake is ended after half of the mature days and less the mature days:
     *       * ZERO rewards are given
     *       * Full staked amount is given
     * If the stake is ended after mature days:
     *       * Full rewards are given
     *       * Full staked amount is given
     */
    function _calculateFixedReward(uint256 _amount, uint256 _numDays)
        internal
        pure
        returns (uint256)
    {
        uint256 interest = (BASE_REWARD_INTEREST * _numDays) +
            ((_numDays * (_numDays - 1)) / 2);
        return ((_amount * interest) / 1e6);
    }

    function _calculateRewards(
        uint256 stakedAmount,
        uint256 stakedAt,
        uint256 numDays,
        uint256 rewardAmount
    ) internal view returns (uint256, uint256) {
        /* Multiplying with 2 to accommodate 'odd' number of matured days */
        uint256 elapsedTime = ((block.timestamp - stakedAt) * 2) / 1 days;
        uint256 matureTime = numDays * 2;

        if (elapsedTime >= matureTime) return (rewardAmount, stakedAmount);
        else if (elapsedTime < (matureTime / 2)) {
            uint256 penalty = _caclulatePenalty(
                stakedAmount,
                elapsedTime,
                matureTime
            );
            return (0, stakedAmount - penalty);
        } else return (0, stakedAmount);
    }

    /*
     * Calculates penalty amount on the stakedAmount on pre-matured ends.
     * This function is called only when 'Elapsed time is < half of mature time'.
     */
    function _caclulatePenalty(
        uint256 amount,
        uint256 elapsedTime,
        uint256 matureTime
    ) internal pure returns (uint256) {
        return (amount * (matureTime - (2 * elapsedTime))) / matureTime;
    }

    /*
     * set Lottery reward percentage.
     */
    function setLotteryReward(uint256 lotteryRewardPercent_)
        external
        onlyOwner
    {
        lotteryRewardPercent = lotteryRewardPercent_;
        emit SetLotteryReward(lotteryRewardPercent_);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPulsedoge {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function burn(address account, uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}