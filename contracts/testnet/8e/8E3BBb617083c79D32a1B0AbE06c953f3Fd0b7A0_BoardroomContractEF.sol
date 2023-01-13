// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "IERC20.sol";
import "IERC721.sol";
import "SafeERC20.sol";
import "SafeMath.sol";
import "ReentrancyGuard.sol";
import "AccessControl.sol";


contract BoardroomContractEF is ReentrancyGuard, AccessControl {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // governance
    bool public isInitialized;

    // Info of each user.
    struct UserInfo {
        bool status; //walletStatus
        uint256 lastClaimedEpoch;
        uint256 amount; // How many  tokens the user has provided.
        uint256 accruedCoin; // Interest accrued till date.
        uint256 claimedCoin; // Interest claimed till date
        uint256 lastAccrued; // Last date when the interest was claimed
        uint256 lastAccruedBlock; //Last block user intracted
    }

    // Info for rates at different dates
    struct rateInfoStruct {
        uint256 timestamp;
        uint256 rate;
    }

    // Info of each pool
    struct PoolInfo {
        address token; // Address of investment token contract.
        bool isStarted; // if lastRewardTime has passed
        uint256 maximumStakingAllowed;
        uint256 epoch_length;
        uint256 minimum_lockup_blocks;
    }

    //snapshot struct`
    struct Snapshot {
        uint blockNumber;
        uint nextReward;
        uint totalMinerStaked;
    }

    rateInfoStruct[][] public rateInfo;

    IERC20 public miner;
    IERC20 public e_usd;
    IERC721 public nft_token;


    // Info of each pool.
    PoolInfo[] public poolInfo;

    mapping(uint256 => Snapshot[]) public snapshots;
    mapping(uint256 => uint256) public next_reward;
    mapping(uint256 => uint256) public lastRun;

    // Info of each user that stakes tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // The time when miner mining starts.
    uint256 public poolStartTime;

    // The time when miner mining ends.
    uint256 public poolEndTime;

    uint256 public rewardsBalance = 0;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant TRANSFER_OUT_ROLE = keccak256("TRANSFER_OUT_OPERATOR_ROLE");

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);

    function initialize(address _miner, address _e_usd, address _nft_token, uint256 _poolStartTime, uint256 _poolEndTime) external {
        require(!isInitialized, "Already Initialized");
        if (_miner != address(0)) miner = IERC20(_miner);
        if (_e_usd != address(0)) e_usd = IERC20(_e_usd);
        if (_nft_token != address(0)) nft_token = IERC721(_nft_token);
        poolStartTime = _poolStartTime;
        poolEndTime = _poolEndTime;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OPERATOR_ROLE,  msg.sender);
        _setupRole(TRANSFER_OUT_ROLE,  msg.sender);
        isInitialized = true;
    }

    function checkRole(address account, bytes32 role) public view {
        require(hasRole(role, account), "Role Does Not Exist");
    }

    function giveRole(address wallet, uint256 _roleId) public {
        require(_roleId >= 0 && _roleId <= 2, "Invalid roleId");
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        bytes32 _role;
        if (_roleId == 0) {
            _role = OPERATOR_ROLE;
        } else if (_roleId == 1) {
            _role = TRANSFER_OUT_ROLE;
        }
        grantRole(_role, wallet);
    }

    function revokeRole(address wallet, uint256 _roleId) public {
        require(_roleId >= 0 && _roleId <= 2, "Invalid roleId");
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        bytes32 _role;
        if (_roleId == 0) {
            _role = OPERATOR_ROLE;
        } else if (_roleId == 1) {
            _role = TRANSFER_OUT_ROLE;
        }
        revokeRole(_role, wallet);
    }

     function renounceOwnership() public {
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function checkPoolDuplicate(address _token) internal view {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            require(poolInfo[pid].token != _token, "Pool exists!");
        }
    }

    function poolLength() public view returns (uint256){
        return poolInfo.length;
    }

    // Add a new farm to the pool. Can only be called by the owner.
    function add(
        address _token,
        uint256 _rate,
        uint256 _maximumStakingAllowed,
        uint256 _epoch_length,
        uint256 _minimum_lockup_blocks
    ) public {
        checkRole(msg.sender, OPERATOR_ROLE);

        checkPoolDuplicate(_token);
        poolInfo.push(PoolInfo({
            token : _token,
            isStarted : false,
            maximumStakingAllowed : _maximumStakingAllowed,
            minimum_lockup_blocks : _minimum_lockup_blocks,
            epoch_length : _epoch_length
        }));
        rateInfo.push().push(rateInfoStruct({
            rate : _rate,
            timestamp : block.timestamp
        }));

    }

    // Enable or disable Wallet
    function setWalletStatus(uint256 _pid, address _user, bool _setStatus) public {
        checkRole(msg.sender, OPERATOR_ROLE);
        UserInfo storage user = userInfo[_pid][_user];
        user.status = _setStatus;
    }


    // Public function to be called both internally and externally
    function allocateSeigniorage(uint256 _pid) public {
        if (block.number >= lastRun[_pid] + poolInfo[_pid].epoch_length) {
            // Calculate the number of times allocateSeigniorageHelper should be called
            uint numRuns = ((block.number).sub(lastRun[_pid])).div(poolInfo[_pid].epoch_length);
            for (uint i = 1; i <= numRuns; i++) {
                // Call allocateSeigniorageHelper with the block number for each run
                allocateSeigniorageHelper(_pid, lastRun[_pid] + (poolInfo[_pid].epoch_length * i));
            }
            lastRun[_pid] += numRuns.mul(poolInfo[_pid].epoch_length);
            // Update lastRun to current block number
        }
    }


    // Internal function to take a snapshot
    function allocateSeigniorageHelper(uint256 _pid, uint256 blockNumber) internal {
        // Create a new snapshot and store it in the array
        snapshots[_pid].push(Snapshot({
            blockNumber : blockNumber,
            nextReward : next_reward[_pid],
            totalMinerStaked : miner.balanceOf(address(this))// Total number of miner staked at this block
        }));
    }


    function setNextReward(uint256 _pid, uint256 _amount) public {
        checkRole(msg.sender, OPERATOR_ROLE);
        // allocateSeigniorage(_pid);
        next_reward[_pid] = _amount;

    }

    // Update maxStaking. Can only be called by the owner.
    function setMaximumStakingAllowed(uint256 _pid, uint256 _maximumStakingAllowed) external {
        checkRole(msg.sender, OPERATOR_ROLE);
        PoolInfo storage pool = poolInfo[_pid];
        pool.maximumStakingAllowed = _maximumStakingAllowed;
    }

    function setInterestRate(uint256 _pid, uint256 _date, uint256 _rate) external {
        checkRole(msg.sender, OPERATOR_ROLE);
        require(_date >= poolStartTime, "Interest date can not be earlier than pool start date");
        require(rateInfo[_pid][rateInfo[_pid].length - 1].timestamp < _date, "The date should be greater than the current last date of interest ");

        rateInfo[_pid].push(rateInfoStruct({
            rate : _rate,
            timestamp : _date
        }));
    }
    //      Ensure to set the dates in ascending order
    function setInterestRatePosition(uint256 _pid, uint256 _position, uint256 _date, uint256 _rate) external {
        checkRole(msg.sender, OPERATOR_ROLE);
        //        assert if date is less than pool start time.
        require(_date >= poolStartTime, "Interest date can not be earlier than pool start date");
        // If position is zero just update

        // first record
        if ((rateInfo[_pid].length > 1) && (_position == 0))
        {
            require(_date <= rateInfo[_pid][_position + 1].timestamp, "The date should be in ascending order");
        }


        // middle records
        if ((_position > 0) && (_position + 1 < rateInfo[_pid].length))
        {
            require(_date >= rateInfo[_pid][_position - 1].timestamp, "The date should be in ascending order");
            require(_date <= rateInfo[_pid][_position + 1].timestamp, "The date should be in ascending order");

        }
        else if ((_position + 1 == rateInfo[_pid].length) && (_position > 0))
        {
            require(_date >= rateInfo[_pid][_position - 1].timestamp, "The date should be in ascending order");
        }

        rateInfo[_pid][_position].timestamp = _date;
        rateInfo[_pid][_position].rate = _rate;

    }

    // Return accumulate rewards over the given _from to _to block.
    function getGeneratedReward(uint _poolindex, uint _amount, uint256 _fromTime, uint256 _toTime) public view returns (uint256) {

        uint256 reward = 0;
        // invalid cases
        if ((_fromTime >= _toTime) || (_fromTime >= poolEndTime) || (_toTime <= poolStartTime)) {
            return 0;
        }

        // if from time < pool start then from time = pool start time
        if (_fromTime < poolStartTime) {
            _fromTime = poolStartTime;
        }
        //  if to time > pool end then to time = pool end time
        if (_toTime > poolEndTime) {
            _toTime = poolEndTime;
        }
        uint256 rateSums = 0;
        uint256 iFromTime = _fromTime;
        uint256 iToTime = _toTime;

        if (rateInfo[_poolindex].length == 1) {
            iFromTime = max(_fromTime, rateInfo[_poolindex][0].timestamp);
            // avoid any negative numbers
            iToTime = max(_toTime, iFromTime);
            rateSums = (iToTime - iFromTime) * rateInfo[_poolindex][0].rate;
        } else {
            // the loop start from 1 and not from zero; ith record and i-1 record are considered for processing.
            for (uint256 i = 1; i < rateInfo[_poolindex].length; i++) {
                if (rateInfo[_poolindex][i - 1].timestamp <= _toTime && rateInfo[_poolindex][i].timestamp >= _fromTime) {
                    if (rateInfo[_poolindex][i - 1].timestamp <= _fromTime) {
                        iFromTime = _fromTime;
                    } else {
                        iFromTime = rateInfo[_poolindex][i - 1].timestamp;
                    }
                    if (rateInfo[_poolindex][i].timestamp >= _toTime) {
                        iToTime = _toTime;
                    } else {
                        iToTime = rateInfo[_poolindex][i].timestamp;
                    }
                    rateSums += (iToTime - iFromTime) * rateInfo[_poolindex][i - 1].rate;
                }

                // Process last block
                if (i == (rateInfo[_poolindex].length - 1)) {
                    if (rateInfo[_poolindex][i].timestamp <= _fromTime) {
                        iFromTime = _fromTime;
                    } else {
                        iFromTime = rateInfo[_poolindex][i].timestamp;
                    }
                    if (rateInfo[_poolindex][i].timestamp >= _toTime) {
                        iToTime = rateInfo[_poolindex][i].timestamp;
                    } else {
                        iToTime = _toTime;
                    }

                    rateSums += (iToTime - iFromTime) * rateInfo[_poolindex][i].rate;
                }
            }
        }
        reward = (rateSums * _amount);
        reward = reward / (1000000000000000000);
        return reward;
    }


    // Claim reward function(dipanshu)
    // I am claimReward arg from uint256 _pid, address _user to only uint256 _pid.
    function claimRewards(uint256 _pid) public nonReentrant {

        allocateSeigniorage(_pid);
        address _sender = msg.sender;
        // retrieve user's information
        UserInfo storage user = userInfo[_pid][_sender];
        require(nft_token.balanceOf(_sender) >= 1, "You must have a NFT");
        require(!user.status, "Your wallet is disabled by admin");
        require(user.amount != 0, "Can't generate reward: No miner staked in pool");
        require(block.number >= user.lastAccruedBlock + poolInfo[_pid].minimum_lockup_blocks, "PreGenesisRewardPoolFixedYield: lockup period not over");

        // calculate the current block epoch

        uint256 currentEpoch = block.number.div(poolInfo[_pid].epoch_length);
        // epoch_length is the number of blocks per epoch

        // // loop through the snapshot array backwards until we reach the user's last claimed epoch
        // uint256 totalRewards = 0;
        // for (uint256 i = (snapshots[_pid].length) - 1; i >= user.lastClaimedEpoch; i--) {

        //     Snapshot storage snapshot = snapshots[_pid][i];

        //     // calculate the user's share of the rewards
        //     uint256 rewards = (snapshot.nextReward.mul(user.amount)).div(snapshot.totalMinerStaked);
        //     totalRewards = totalRewards.add(rewards);
        //       if(i==0){
        //         break;   //using break statement
        //      }
        // }
        uint256 _pending = getReward(_pid, _sender);
        //getGeneratedReward(_pid, user.amount, user.lastAccrued, block.timestamp);

        user.accruedCoin += _pending;
        user.lastAccrued = block.timestamp;
        user.lastAccruedBlock = block.number;
        _pending = (user.accruedCoin).sub(user.claimedCoin);
        if (_pending > 0) {
            user.claimedCoin += _pending;
            user.lastClaimedEpoch = currentEpoch;
            //updating the lastClaimedEpoch of a user(dipanshu)
            safeECoinTransfer(_sender, _pending);
            emit RewardPaid(_sender, _pending);
        }

        // pay the user their rewards and update their last claimed epoch
        // e_usd.safeTransfer(_user, totalRewards);
        // user.lastClaimedEpoch = currentEpoch;
    }


    // View function to see pending miner on frontend.
    function pendingShare(uint256 _pid, address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_pid][_user];
        return getGeneratedReward(_pid, user.amount, user.lastAccrued, block.timestamp);
    }

    // Deposit LP tokens.
    // need to add claim reward and remove getGeneratedReward() function
    function deposit(uint256 _pid, uint256 _amount) external {
        allocateSeigniorage(_pid);
        // NEED to palce at right place to avoid Zero total miner snapshot
        address _sender = msg.sender;
        require(block.timestamp >= poolStartTime, "Pool has not started yet!");
        require(nft_token.balanceOf(_sender) >= 1, "You must have a NFT");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_sender];
        require(!user.status, "Your wallet is disabled by admin");
        require(user.amount + _amount <= pool.maximumStakingAllowed, "Maximum staking limit reached");

        if (user.amount > 0) {
            uint256 _pending = getReward(_pid, _sender);
            if (_pending > 0) {
                user.accruedCoin += _pending;
                user.lastAccrued = block.timestamp;
                user.lastAccruedBlock = block.number;
                _pending = (user.accruedCoin).sub(user.claimedCoin);
                user.claimedCoin += _pending;
                user.lastClaimedEpoch = (block.number / pool.epoch_length);
                //updating the lastClaimedEpoch of a user(dipanshu)
                safeECoinTransfer(_sender, _pending);
                emit RewardPaid(_sender, _pending);
            }
        } else {
            user.lastClaimedEpoch = block.number / pool.epoch_length;
            user.lastAccruedBlock = block.number;
        }
        if (_amount > 0) {
            user.amount = user.amount.add(_amount);
            user.lastAccrued = block.timestamp;
            user.lastAccruedBlock = block.number;
            IERC20(pool.token).safeTransferFrom(_sender, address(this), _amount);
        }
        // allocateSeigniorage(_pid);
        emit Deposit(_sender, _pid, _amount);
    }

    // Withdraw  tokens.
    // Check lockup period
    // Update lockup block number
    // Force user to call claimReward function
    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        allocateSeigniorage(_pid);
        address _sender = msg.sender;
        require(nft_token.balanceOf(_sender) >= 1, "You must have a NFT");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_sender];
        require(!user.status, "Your wallet is disabled by admin");
        require(user.amount >= _amount, "Withdrawal: Invalid");
        // Check lockup period
        require(block.number >= user.lastAccruedBlock + pool.minimum_lockup_blocks, "PreGenesisRewardPoolFixedYield: lockup period not over");
        uint256 _pending = getReward(_pid, _sender);
        //getGeneratedReward(_pid, user.amount, user.lastAccrued, block.timestamp);

        user.accruedCoin += _pending;
        user.lastAccrued = block.timestamp;
        user.lastAccruedBlock = block.number;
        _pending = (user.accruedCoin).sub(user.claimedCoin);
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
        }
        if (_pending > 0) {
            user.claimedCoin += _pending;
        }
        if (_pending > 0) {
            user.lastClaimedEpoch = (block.number / pool.epoch_length);
            //updating the lastClaimedEpoch of a user(dipanshu)
            safeECoinTransfer(_sender, _pending);

            emit RewardPaid(_sender, _pending);
        }
        if (_amount > 0) {
            IERC20(pool.token).safeTransfer(_sender, _amount);
        }
        emit Withdraw(_sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external {
        checkRole(msg.sender, OPERATOR_ROLE);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount = user.amount;
        user.amount = 0;
        IERC20(pool.token).safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(msg.sender, _pid, _amount);
    }

    // Safe miner transfer function, just in case if rounding error causes pool to not have enough miner.
    // need to change for eusd coin(dipanshu)
    function safeECoinTransfer(address _to, uint256 _amount) internal {
        uint256 _eusd_CoinBal = e_usd.balanceOf(address(this));
        require(_eusd_CoinBal >= _amount && rewardsBalance >= _amount, "Insufficient rewards balance, ask dev to add more miner to the gen pool");


        if (_eusd_CoinBal > 0) {
            if (_amount > _eusd_CoinBal) {
                rewardsBalance -= _eusd_CoinBal;
                e_usd.safeTransfer(_to, _eusd_CoinBal);
            } else {
                rewardsBalance -= _amount;
                e_usd.safeTransfer(_to, _amount);
            }
        }
    }

    function getReward(uint256 _pid, address _user) public view returns (uint256) {

        // retrieve user's information
        UserInfo storage user = userInfo[_pid][_user];
        require(!user.status, "Your wallet is disabled by admin");
        require(nft_token.balanceOf(_user) >= 1, "You must have a NFT");
        uint256 totalRewards = 0;
        if (snapshots[_pid].length > 0) {

            // loop through the snapshot array backwards until we reach the user's last claimed epoch

            for (uint256 i = snapshots[_pid].length - 1; i >= user.lastClaimedEpoch; i--) {
                Snapshot storage snapshot = snapshots[_pid][i];

                // calculate the user's share of the rewards
                uint256 rewards = (snapshot.nextReward.mul(user.amount)).div(snapshot.totalMinerStaked);
                totalRewards = totalRewards.add(rewards);
                if (i == 0) {
                    break;
                    //using break statement
                }
            }
        }
        return totalRewards;

    }

    // @notice Sets the pool end time to extend the gen pools if required.
    function setPoolEndTime(uint256 _pool_end_time) external {
        checkRole(msg.sender, OPERATOR_ROLE);
        poolEndTime = _pool_end_time;
    }

    function setPoolStartTime(uint256 _pool_start_time) external {
        checkRole(msg.sender, OPERATOR_ROLE);
        poolStartTime = _pool_start_time;
    }

    // @notice imp. only use this function to replenish rewards
    // need to change for eusd coin(dipanshu)
    function replenishReward(uint256 _value) external {
        checkRole(msg.sender, OPERATOR_ROLE);
        require(_value > 0, "replenish value must be greater than 0");
        IERC20(e_usd).safeTransferFrom(msg.sender, address(this), _value);
        rewardsBalance += _value;
    }


    // @notice can only transfer out the rewards balance and not user fund.
    function transferOutECoin(address _to, uint256 _value) external {
        checkRole(msg.sender, TRANSFER_OUT_ROLE);
        require(_value <= rewardsBalance, "Trying to transfer out more miner than available");
        rewardsBalance -= _value;
        IERC20(miner).safeTransfer(_to, _value);
    }

    // @notice sets a pool's isStarted to true and increments total allocated points
    function startPool(uint256 _pid) public {
        checkRole(msg.sender, OPERATOR_ROLE);
        PoolInfo storage pool = poolInfo[_pid];
        if (!pool.isStarted)
        {
            pool.isStarted = true;
        }
    }

    // @notice calls startPool for all pools
    function startAllPools() external {
        checkRole(msg.sender, OPERATOR_ROLE);
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            startPool(pid);
        }
    }

    // View function to see rewards balance.
    function getRewardsBalance() external view returns (uint256) {
        return rewardsBalance;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function getLatestRate(uint256 _pid) external view returns (uint256){
        return rateInfo[_pid][rateInfo[_pid].length - 1].rate;
    }


    function getBlocksSinceLastAction(uint256 _pid, address _user) public view returns (uint256) {
        return block.number - userInfo[_pid][_user].lastAccruedBlock;
        //  lockupBlockNumbers[user];
    }
}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "IERC20.sol";
import "Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "Context.sol";
import "ERC165.sol";

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}