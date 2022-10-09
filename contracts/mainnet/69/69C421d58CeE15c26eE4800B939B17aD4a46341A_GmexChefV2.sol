/*
 * Global Market Exchange 
 * Official Site  : https://globalmarket.host
 * Private Sale   : https://globalmarketinc.io
 * Email          : [email protected]
 * Telegram       : https://t.me/gmekcommunity
 * Development    : Digichain Development Technology
 * Dev Is         : Tommy Chain & Team
 * Powering new equity blockchain on decentralized real and virtual projects
 * It is a revolutionary blockchain, DeFi and crypto architecture technology project
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./utils/Pausable.sol";

import "./lib/VotingPower.sol";

import "./GmexToken.sol";
import "./governance/GmexGovernance.sol";

// Master Contract of Global Market Exchange
contract GmexChefV2 is Initializable, OwnableUpgradeable, Pausable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for GmexToken;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 lastStakedDate; // quasi-last staked date
        uint256 lastDeposited; // last deposited timestamp
        uint256 lastDepositedAmount; // last deposited amount
        uint256 multiplier; // individual multiplier, times 10000. should not exceed 10000
        //
        // We do some fancy math here. Basically, any point in time, the amount of GMEXs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accGMEXPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accGMEXPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20Upgradeable lpToken; // Address of LP token contract.
        // uint256 allocPoint; // How many allocation points assigned to this pool. GMEXs to distribute per block.
        uint256 allocPoint; // Considering 1000 for equal share as other pools
        uint256 lastRewardBlock; // Last block number that GMEXs distribution occurs.
        // uint256 accGMEXPerShare; // Accumulated GMEXs per share, times 1e12. See below.
        uint256 accGMEXPerShareForValidator; // Reward for staking(Rs) + Commission Rate(root(Rs))
        uint256 accGMEXPerShareForNominator; // Reward for staking(Rs)
    }

    string public name;

    GmexToken public gmexToken;
    GmexGovernance public gmexGovernance;

    // Gmex tokens created per block.
    uint256 public gmexPerBlockForValidator;
    uint256 public gmexPerBlockForNominator;

    // Bonus muliplier for early Gmex makers.
    uint256 public bonusMultiplier;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    // The block number when mining starts.
    uint256 public startBlock;
    // Estimated Total Blocks per year.
    uint256 public blockPerYear;

    // penalty fee when withdrawing reward within 4 weeks of last deposit and after 4 weeks
    uint256 public penaltyFeeRate1;
    uint256 public penaltyFeeRate2;
    // Penalties period
    uint256 public penaltyPeriod;
    // Treasury address
    address public treasury;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    modifier onlyGmexGovernance() {
        require(
            msg.sender == address(gmexGovernance),
            "Only GmexGovernance can perform this action"
        );
        _;
    }

    modifier fridayOnly() {
        uint256 dayCount = block.timestamp / 1 days;
        uint256 dayOfWeek = (dayCount - 2) % 7;
        require(
            dayOfWeek == 5,
            "GmexChef: Operation is allowed only during Friday."
        );
        _;

        // Explanation
        // 1970 January 1 is Thrusday
        // So to get current day's index counting from Saturday as 0,
        // we are subtracting 2 from dayCount and modulo 7.
    }

    function initialize(
        GmexToken _gmexToken,
        address _treasury,
        uint256 _startBlock
    ) public initializer {
        __Ownable_init();
        __PausableUpgradeable_init();
        gmexToken = _gmexToken;
        treasury = _treasury;
        // gmexPerBlock = _gmexPerBlock;
        startBlock = _startBlock;

        // staking pool
        poolInfo.push(
            PoolInfo({
                lpToken: _gmexToken,
                allocPoint: 1000,
                lastRewardBlock: _startBlock,
                accGMEXPerShareForValidator: 0,
                accGMEXPerShareForNominator: 0
            })
        );
        totalAllocPoint = 1000;

        name = "Gmex Chef";
        bonusMultiplier = 1;
        blockPerYear = 31536000 / 5; // 1 year in seconds / 5 seconds(mean block time).
        penaltyFeeRate1 = 20; // withdraw penalty fee if last deposited is < 4 weeks
        penaltyFeeRate2 = 15; // fee if last deposited is > 4 weeks (always implemented)
        penaltyPeriod = 4 weeks;
    }

    function getCurrentBlock() public view returns (uint256) {
        return block.number;
    }

    function updateGmexGovernanceAddress(GmexGovernance _gmexGovernanceAddress)
        public
        onlyOwner
    {
        gmexGovernance = _gmexGovernanceAddress;
    }

    function updateMultiplier(uint256 multiplierNumber) external onlyOwner {
        require(multiplierNumber > 0, "Multipler is too less");
        bonusMultiplier = multiplierNumber;
        //determining the Gmex tokens allocated to each farm
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
        //Determine how many pools we have
    }

    function getPools() external view returns (PoolInfo[] memory) {
        return poolInfo;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        return _to.sub(_from).mul(bonusMultiplier);
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (block.number <= startBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 gmexRewardForValidator = multiplier
            .mul(gmexPerBlockForValidator)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        uint256 gmexRewardForNominator = multiplier
            .mul(gmexPerBlockForNominator)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        pool.accGMEXPerShareForValidator = pool.accGMEXPerShareForValidator.add(
            gmexRewardForValidator.mul(1e12).div(lpSupply)
        );
        pool.accGMEXPerShareForNominator = pool.accGMEXPerShareForNominator.add(
            gmexRewardForNominator.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() internal {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20Upgradeable _lpToken,
        bool _withUpdate
    ) external onlyOwner whenNotPaused {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accGMEXPerShareForValidator: 0,
                accGMEXPerShareForNominator: 0
            })
        );

        updateStakingPool();
    }

    // Update the given pool's Gmex allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external onlyOwner whenNotPaused {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(
                _allocPoint
            );
            updateStakingPool();
        }
    }

    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points.add(poolInfo[pid].allocPoint);
        }
        if (points != 0) {
            points = points.div(3);
            totalAllocPoint = totalAllocPoint.sub(poolInfo[0].allocPoint).add(
                points
            );
            poolInfo[0].allocPoint = points; //setting first pool allocation points to total pool allocation/3
        }
    }

    // To be called at the start of new 3 months tenure, after releasing the vested tokens to this contract.
    // function reallocPoint(bool _withUpdate) public onlyOwner {
    //     if (_withUpdate) {
    //         massUpdatePools();
    //     }
    //     uint256 totalAvailableGMEX = gmexToken.balanceOf(address(this));
    //     uint256 totalGmexPerBlock = (totalAvailableGMEX.mul(4)).div(
    //         blockPerYear
    //     );
    //     // gmexPerBlockForValidator =
    //     // gmexPerBlockForNominator
    // }

    // View function to see pending Rewards.
    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid]; //getting the specific pool with it id
        UserInfo storage user = userInfo[_pid][_user]; //getting user belongs to that pool
        //getting the accumulated gmex per share in that pool
        uint256 accGMEXPerShare = 0;
        uint256 gmexPerBlock = 0;
        if (gmexGovernance.getValidatorsExists(_user)) {
            accGMEXPerShare = pool.accGMEXPerShareForValidator;
            gmexPerBlock = gmexPerBlockForValidator;
        } else {
            accGMEXPerShare = pool.accGMEXPerShareForNominator;
            gmexPerBlock = gmexPerBlockForNominator;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this)); //how many lptokens are there in that pool
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 gmexReward = multiplier
                .mul(gmexPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint); //calculating the Gmex reward
            accGMEXPerShare = accGMEXPerShare.add(
                gmexReward.mul(1e12).div(lpSupply)
            ); //accumulated Gmex per each share
        }
        uint256 rewardDebt = getRewardDebt(user, accGMEXPerShare);
        return rewardDebt.sub(user.rewardDebt); //get the pending GMEXs which are rewarded to us to harvest
    }

    // Safe Gmex transfer function, just in case if rounding error causes pool to not have enough GMEXs.
    function safeGMEXTransfer(address _to, uint256 _amount) internal {
        uint256 gmexBal = gmexToken.balanceOf(address(this));
        if (_amount > gmexBal) {
            gmexToken.transfer(_to, gmexBal);
        } else {
            gmexToken.transfer(_to, _amount);
        }
    }

    // calculates last deposit timestamp for fair withdraw fee
    function getLastDepositTimestamp(
        uint256 lastDepositedTimestamp,
        uint256 lastDepositedAmount,
        uint256 currentAmount
    ) internal view returns (uint256) {
        if (lastDepositedTimestamp <= 0) {
            return block.timestamp;
        } else {
            uint256 currentTimestamp = block.timestamp;
            uint256 multiplier = currentAmount.div(
                (lastDepositedAmount.add(currentAmount))
            );
            return
                (currentTimestamp.sub(lastDepositedTimestamp))
                    .mul(multiplier)
                    .add(lastDepositedTimestamp);
        }
    }

    // to fetch staked amount in given pool of given user
    // this can be used to know if user has staked or not
    function getStakedAmountInPool(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        return userInfo[_pid][_user].amount;
    }

    // to fetch last staked date in given pool of given user
    function getLastStakedDateInPool(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        return userInfo[_pid][_user].lastStakedDate;
    }

    // to fetch if user is LP Token Staker or not
    function multiPoolOrNot(address _user) public view returns (bool) {
        uint256 length = poolInfo.length;
        for (uint256 pid = 1; pid < length; pid++) {
            if (userInfo[pid][_user].amount > 0) {
                return true;
            }
        }
        return false;
    }

    function transferRewardWithWithdrawFee(
        uint256 userLastDeposited,
        uint256 pending
    ) internal {
        uint256 withdrawFee = 0;
        uint256 currentTimestamp = block.timestamp;
        if (currentTimestamp < userLastDeposited.add(penaltyPeriod)) {
            withdrawFee = getWithdrawFee(pending, penaltyFeeRate1);
        } else {
            withdrawFee = getWithdrawFee(pending, penaltyFeeRate2);
        }

        uint256 rewardAmount = pending.sub(withdrawFee);

        require(
            pending == withdrawFee + rewardAmount,
            "Gmex::transfer: withdrawfee invalid"
        );

        safeGMEXTransfer(treasury, withdrawFee);
        safeGMEXTransfer(msg.sender, rewardAmount);
    }

    function getAccGMEXPerShare(PoolInfo memory pool)
        internal
        view
        returns (uint256)
    {
        if (gmexGovernance.getValidatorsExists(msg.sender)) {
            return pool.accGMEXPerShareForValidator;
        } else {
            return pool.accGMEXPerShareForNominator;
        }
    }

    function getRewardDebt(UserInfo memory user, uint256 accGMEXPerShare)
        internal
        pure
        returns (uint256)
    {
        return
            user.amount.mul(accGMEXPerShare).div(1e12).mul(user.multiplier).div(
                1e4
            );
    }

    // Deposit LP tokens to GmexChef for Gmex allocation.
    function deposit(uint256 _pid, uint256 _amount) external whenNotPaused {
        require(_pid != 0, "deposit Gmex by staking");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 accGMEXPerShare = getAccGMEXPerShare(pool);
        uint256 rewardDebt = getRewardDebt(user, accGMEXPerShare);
        if (user.amount > 0) {
            uint256 pending = rewardDebt.sub(user.rewardDebt);
            if (pending > 0) {
                transferRewardWithWithdrawFee(user.lastDeposited, pending);
            }
        }
        if (_amount > 0) {
            // pool.lpToken.safeTransferFrom(
            pool.lpToken.transferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
            user.lastStakedDate = getLastDepositTimestamp(
                user.lastDeposited,
                user.lastDepositedAmount,
                _amount
            );
            user.lastDeposited = block.timestamp;
            user.lastDepositedAmount = _amount;
        }

        user.rewardDebt = rewardDebt;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function getVotingPower(address _user) public view returns (uint256) {
        uint256 gmexStaked = getStakedAmountInPool(0, _user);
        require(gmexStaked > 0, "GmexChefV2: Stake not enough to vote");

        uint256 lastGmexStakedDate = getLastStakedDateInPool(0, _user);
        uint256 numberOfDaysStaked = block
            .timestamp
            .sub(lastGmexStakedDate)
            .div(86400);
        bool multiPool = multiPoolOrNot(_user);
        uint256 votingPower = VotingPower.calculate(
            numberOfDaysStaked,
            gmexStaked,
            multiPool
        );

        return votingPower;
    }

    // Withdraw LP tokens from GmexChef.
    function withdraw(uint256 _pid, uint256 _amount) external whenNotPaused {
        require(_pid != 0, "withdraw Gmex by unstaking");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 accGMEXPerShare = getAccGMEXPerShare(pool);
        uint256 rewardDebt = getRewardDebt(user, accGMEXPerShare);
        uint256 pending = rewardDebt.sub(user.rewardDebt);
        if (pending > 0) {
            transferRewardWithWithdrawFee(user.lastDeposited, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = rewardDebt;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Get Withdraw fee
    function getWithdrawFee(uint256 _amount, uint256 _penaltyFeeRate)
        internal
        pure
        returns (uint256)
    {
        return _amount.mul(_penaltyFeeRate).div(100);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external whenNotPaused {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Update treasury address by the previous treasury address holder.
    function updateTreasuryAddress(address _treasury) external {
        require(msg.sender == treasury, "Updating Treasury Forbidden !");
        treasury = _treasury;
    }

    //Update start reward block
    function updateStartBlock(uint256 _startBlock) external onlyOwner {
        startBlock = _startBlock;
    }

    // update gmex per block
    // function updateGmexPerBlock(uint256 _gmexPerBlock) public onlyOwner {
    //     gmexPerBlock = _gmexPerBlock;
    // }

    function updateGmexPerBlockForValidator(uint256 _gmexPerBlock)
        external
        onlyOwner
    {
        gmexPerBlockForValidator = _gmexPerBlock;
    }

    function updateGmexPerBlockForNominator(uint256 _gmexPerBlock)
        external
        onlyOwner
    {
        gmexPerBlockForNominator = _gmexPerBlock;
    }

    // Stake Gmex tokens to GmexChef
    function enterStaking(uint256 _amount) external whenNotPaused {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        uint256 accGMEXPerShare = getAccGMEXPerShare(pool);
        uint256 rewardDebt = getRewardDebt(user, accGMEXPerShare);
        if (user.amount > 0) {
            uint256 pending = rewardDebt.sub(user.rewardDebt);
            if (pending > 0) {
                transferRewardWithWithdrawFee(user.lastDeposited, pending);
            }
        }
        if (_amount > 0) {
            // pool.lpToken.safeTransferFrom(
            pool.lpToken.transferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
            user.lastStakedDate = getLastDepositTimestamp(
                user.lastDeposited,
                user.lastDepositedAmount,
                _amount
            );
            user.lastDeposited = block.timestamp;
            user.lastDepositedAmount = _amount;
        }
        user.rewardDebt = rewardDebt;
        emit Deposit(msg.sender, 0, _amount);
    }

    // Withdraw Gmex tokens from STAKING.
    function leaveStaking(uint256 _amount) external whenNotPaused {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 accGMEXPerShare = getAccGMEXPerShare(pool);
        uint256 rewardDebt = getRewardDebt(user, accGMEXPerShare);
        uint256 pending = rewardDebt.sub(user.rewardDebt);
        if (pending > 0) {
            transferRewardWithWithdrawFee(user.lastDeposited, pending);
        }
        if (_amount > 0) {
            // check for validator
            if (_amount > gmexGovernance.getValidatorsMinStake()) {
                gmexGovernance.leftStakingAsValidator(msg.sender);
            }

            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = rewardDebt;
        emit Withdraw(msg.sender, 0, _amount);
    }

    // function withdrawReward(uint256 _pid) external fridayOnly {
    function withdrawReward(uint256 _pid) external whenNotPaused {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "withdraw: not good");
        updatePool(_pid);
        uint256 accGMEXPerShare = getAccGMEXPerShare(pool);
        uint256 rewardDebt = getRewardDebt(user, accGMEXPerShare);
        uint256 pending = rewardDebt.sub(user.rewardDebt);
        if (pending > 0) {
            transferRewardWithWithdrawFee(user.lastDeposited, pending);
        }
        user.rewardDebt = rewardDebt;
    }

    function slashOfflineValidators(
        uint256 slashingParameter,
        address[] memory offlineValidators,
        address[] memory onlineValidators
    ) public onlyGmexGovernance whenNotPaused {
        require(
            msg.sender == address(gmexGovernance),
            "Only GmexGovernance can slash offline validators"
        );
        if (slashingParameter > 0) {
            for (uint256 i = 0; i < offlineValidators.length; i++) {
                address user = offlineValidators[i];
                uint256 userStake = getStakedAmountInPool(0, user);
                uint256 toBeSlashedAmount = userStake
                    .mul(7)
                    .mul(slashingParameter)
                    .div(10000);

                safeGMEXTransfer(treasury, toBeSlashedAmount);

                UserInfo storage userData = userInfo[0][user];
                userData.amount = userData.amount.sub(toBeSlashedAmount);
            }
        }

        // Reducing multiplier
        for (uint256 i = 0; i < offlineValidators.length; i++) {
            address user = offlineValidators[i];
            UserInfo storage userData = userInfo[0][user];
            userData.multiplier = 5000;
        }

        // Recovering multiplier
        for (uint256 i = 0; i < onlineValidators.length; i++) {
            address user = onlineValidators[i];
            UserInfo storage userData = userInfo[0][user];
            userData.multiplier = 10000;
        }
    }

    function evaluateThreeValidatorsNominatedByNominator(
        uint256 slashingParameter,
        address[] memory nominators
    ) public onlyGmexGovernance whenNotPaused {
        require(
            msg.sender == address(gmexGovernance),
            "Only GmexGovernance can evaluate three validators nominated by nominator"
        );
        for (uint256 i = 0; i < nominators.length; i++) {
            address nominator = nominators[i];
            UserInfo storage userData = userInfo[0][nominator];
            address[3] memory validatorsNominatedByNominator = gmexGovernance
                .getValidatorsNominatedByNominator(nominator);

            for (uint256 j = 0; j < 3; j++) {
                address validator = validatorsNominatedByNominator[j];
                if (gmexGovernance.haveCastedVote(validator)) {
                    userData.multiplier = 10000;

                    if (j != 0) {
                        gmexGovernance.vestVotesToDifferentValidator(
                            nominator,
                            validatorsNominatedByNominator[0],
                            validator
                        );
                    }

                    return;
                }
            }
            userData.multiplier = 5000;

            if (slashingParameter > 0) {
                uint256 userStake = getStakedAmountInPool(0, nominator);
                uint256 toBeSlashedAmount = userStake
                    .mul(7)
                    .mul(slashingParameter)
                    .div(10000);

                safeGMEXTransfer(treasury, toBeSlashedAmount);

                userData.amount = userData.amount.sub(toBeSlashedAmount);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract Pausable is PausableUpgradeable, OwnableUpgradeable {
    function __PausableUpgradeable_init() internal onlyInitializing {
        __Ownable_init();
        __Pausable_init_unchained();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Treasury handler interface
 * @dev Any class that implements this interface can be used for protocol-specific operations pertaining to the treasury.
 */
interface ITreasuryHandler {
    /**
     * @notice Perform operations before a transfer is executed.
     * @param benefactor Address of the benefactor.
     * @param beneficiary Address of the beneficiary.
     * @param amount Number of tokens in the transfer.
     */
    function beforeTransferHandler(
        address benefactor,
        address beneficiary,
        uint256 amount
    ) external;

    /**
     * @notice Perform operations after a transfer is executed.
     * @param benefactor Address of the benefactor.
     * @param beneficiary Address of the beneficiary.
     * @param amount Number of tokens in the transfer.
     */
    function afterTransferHandler(
        address benefactor,
        address beneficiary,
        uint256 amount
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Tax handler interface
 * @dev Any class that implements this interface can be used for protocol-specific tax calculations.
 */
interface ITaxHandler {
    /**
     * @notice Get number of tokens to pay as tax.
     * @param benefactor Address of the benefactor.
     * @param beneficiary Address of the beneficiary.
     * @param amount Number of tokens in the transfer.
     * @return Number of tokens to pay as tax.
     */
    function getTax(
        address benefactor,
        address beneficiary,
        uint256 amount
    ) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

library VotingPower {
    using SafeMathUpgradeable for uint256;

    function calculateAlpha(
        uint256 d,
        uint256 tv,
        uint256 m
    ) internal pure returns (uint256) {
        // 𝛼 = 1 + (1/(1 + 𝑒^((−𝑑+𝑡𝑣)/𝑚)))/4
        // ; 𝑤ℎ𝑒𝑟𝑒
        // 𝑑 = 𝑛𝑢𝑚𝑏𝑒𝑟 𝑜𝑓 𝑑𝑎𝑦𝑠 𝑠𝑡𝑎𝑘𝑒𝑑,
        // 𝑡𝑣 = 𝑡𝑖𝑚𝑒 𝑤𝑖𝑛𝑑𝑜𝑤 𝑓𝑜𝑟 𝑡ℎ𝑒 𝑠𝑖𝑔𝑚𝑜𝑖𝑑
        // 𝑚 = 𝑠𝑙𝑜𝑝𝑒 𝑜𝑓 𝑡ℎ𝑒 𝑐𝑢𝑟𝑣e

        // uint256 e = 2.7182818284590452353602874713527; // e
        uint256 eN = 2718281828459045; // e numerator
        uint256 eD = 1e15; // e denominator

        if (d == 0) return eD;

        /*
         *    𝛼 = 1 + (1/(1 + 𝑒^eP))/4 as eP = (−𝑑+𝑡𝑣)/𝑚
         *    𝛼 = 1 + (1/(1 + (eN^eP/eD^eP))/4
         *    𝛼 = 1 + (1/((eD^eP + eN^eP)/eD^eP)/4
         *    𝛼 = 1 + 1/4*((eD^eP + eN^eP)/eD^eP)
         *    𝛼 = 1 + eD^eP/4*(eD^eP + eN^eP)
         *    since eD^eP/4*(eD^eP + eN^eP) is always going to be decimal places in between 0 and 1,
         *    multipling eD for decimal places, we get
         *    eD + (eD**(eP + 1)) / (4 * (eD**eP + eN**eP));
         */

        if (tv > d) {
            uint256 eP = tv.sub(d).div(m); // e power
            return eD + (eD**(eP + 1)) / (4 * (eD**eP + eN**eP));
        } else {
            // (eN/eD)^(-eP) = (eD/eN)^eP
            uint256 eP = d.sub(tv).div(m); // e power
            return eD + (eN**(eP + 1)) / (4 * (eN**eP + eD**eP));
        }
    }

    function calculate(
        uint256 d,
        uint256 n,
        bool lpTokenStaker
    ) internal pure returns (uint256) {
        uint256 tv = 45;
        uint256 m = 12;
        uint256 alpha = calculateAlpha(d, tv, m);

        if (lpTokenStaker) {
            return (alpha * n * 12) / 10;
        } else {
            return alpha * n;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract GmexVoters {
    address[] private voters;
    mapping(address => bool) private delagatedValidator;
    mapping(address => address[3]) private votedToValidator; // addresses of the validators a nominator has choosen
    mapping(address => uint256) private votingPower;

    function getVoters() public view returns (address[] memory) {
        return voters;
    }

    function addVoter(address _voter) internal {
        voters.push(_voter);
    }

    function resetVoters() internal {
        delete voters;
    }

    function haveDelagatedValidator(address _voter) public view returns (bool) {
        return delagatedValidator[_voter];
    }

    function delegateValidator(address validator) public virtual {
        require(
            !delagatedValidator[msg.sender],
            "GmexGovernance: You have already delegated a validator"
        );
        votedToValidator[msg.sender][0] = validator;

        if (!delagatedValidator[msg.sender]) {
            addVoter(msg.sender);
            delagatedValidator[msg.sender] = true;
        }
    }

    function delegateMoreValidator(address validator) public {
        require(
            delagatedValidator[msg.sender],
            "GmexGovernance: Delegate one validator first"
        );
        if (votedToValidator[msg.sender][1] == address(0)) {
            votedToValidator[msg.sender][1] = validator;
        } else if (votedToValidator[msg.sender][2] == address(0)) {
            votedToValidator[msg.sender][2] = validator;
        } else {
            revert("GmexGovernance: You have already delegated 3 validators");
        }
    }

    function changeValidatorOrder(
        uint8 firstValidatorIndex,
        uint8 secondValidatorIndex
    ) public {
        require(
            firstValidatorIndex < 3,
            "GmexGovernance: First validator index out of bounds"
        );
        require(
            secondValidatorIndex < 3,
            "GmexGovernance: Second validator index out of bounds"
        );
        address temp = votedToValidator[msg.sender][firstValidatorIndex];
        votedToValidator[msg.sender][firstValidatorIndex] = votedToValidator[
            msg.sender
        ][secondValidatorIndex];
        votedToValidator[msg.sender][secondValidatorIndex] = temp;
    }

    function unDelegateValidator() internal {
        require(
            delagatedValidator[msg.sender],
            "GmexGovernance: You have not delegated a validator"
        );
        delete votedToValidator[msg.sender];
        delete delagatedValidator[msg.sender];
    }

    function getValidatorsNominatedByNominator(address _voter)
        public
        view
        returns (address[3] memory)
    {
        return votedToValidator[_voter];
    }

    function vestVotes(uint256 _votingPower) internal {
        votingPower[msg.sender] = _votingPower;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

abstract contract GmexValidators is OwnableUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    address[] private validators;
    mapping(address => bool) private validatorExists;
    uint256 private numberOfValidatorAllowed;
    uint256 private validatorMinStake;
    uint256 private castedVoteCount;
    mapping(address => bool) private castedVote;
    mapping(address => uint256) private voteCount;
    mapping(address => uint256) private votingPower;
    mapping(address => bool) private blocklisted;
    EnumerableSetUpgradeable.AddressSet private whitelisted;
    uint256 private previlegeForValidatorTill;

    modifier validValidatorsOnly() {
        require(
            validatorExists[msg.sender],
            "GmexGovernance: Only validators can cast a vote"
        );
        _;
    }

    modifier previlegedApplied() {
        require(
            block.timestamp > previlegeForValidatorTill ||
                whitelisted.contains(msg.sender),
            "GmexGovernance: You are not previleged for the action. Please wait"
        );
        _;
    }

    function __GmexValidators_init(address[] memory _whitelisted)
        public
        initializer
    {
        __Ownable_init();
        numberOfValidatorAllowed = 10;
        validatorMinStake = 200;

        for (uint256 i = 0; i < _whitelisted.length; i++) {
            whitelisted.add(_whitelisted[i]);
        }

        previlegeForValidatorTill = block.timestamp + 1 weeks;
    }

    function getValidators() public view returns (address[] memory) {
        return validators;
    }

    function getVoteCount(address validator) public view returns (uint256) {
        return voteCount[validator];
    }

    function getWhitelistedValidators() public view returns (address[] memory) {
        return whitelisted.values();
    }

    function getValidatorsWhoHaveNotCastedVotes()
        internal
        view
        returns (address[] memory)
    {
        address[] memory offlineValidators = new address[](
            validators.length - castedVoteCount
        );
        uint256 numberOfOfflineValidators = 0;
        for (uint256 i = 0; i < validators.length; i++) {
            if (!castedVote[validators[i]]) {
                offlineValidators[numberOfOfflineValidators] = validators[i];
                numberOfOfflineValidators++;
            }
        }
        return offlineValidators;
    }

    function getValidatorsWhoHaveCastedVotes()
        internal
        view
        returns (address[] memory)
    {
        address[] memory onlineValidators = new address[](castedVoteCount);
        uint256 numberOfOnlineValidators = 0;
        for (uint256 i = 0; i < validators.length; i++) {
            if (castedVote[validators[i]]) {
                onlineValidators[numberOfOnlineValidators] = validators[i];
                numberOfOnlineValidators++;
            }
        }
        return onlineValidators;
    }

    function getValidatorsExists(address _validator)
        public
        view
        returns (bool)
    {
        return validatorExists[_validator];
    }

    function updateCastedVote(bool _castedVote) internal {
        if (_castedVote && !castedVote[msg.sender]) {
            castedVoteCount++;
        } else if (!_castedVote && castedVote[msg.sender]) {
            castedVoteCount--;
        }
        castedVote[msg.sender] = _castedVote;
    }

    function haveCastedVote(address _validator) public view returns (bool) {
        return castedVote[_validator];
    }

    function getValidatorsMinStake() public view returns (uint256) {
        return validatorMinStake;
    }

    // update validator min stake
    function updateValidatorMinStake(uint256 _validatorMinStake)
        public
        onlyOwner
    {
        validatorMinStake = _validatorMinStake;
    }

    // apply for validator
    function applyForValidator() public virtual previlegedApplied {
        require(!blocklisted[msg.sender], "GmexGovernance: Blocklisted wallet");
        require(
            validators.length < numberOfValidatorAllowed,
            "Validators allowed exceeded"
        );

        validatorExists[msg.sender] = true;
        validators.push(msg.sender);
    }

    function leaveFromValidator() public {
        require(
            validatorExists[msg.sender],
            "GmexGovernance: Only validators can leave from validator"
        );
        require(
            validators.length > 1,
            "GmexGovernance: At least one validator must be present"
        );

        removeFromValidator(msg.sender);
    }

    // remove for validator
    function removeFromValidatorByIndex(uint256 index) public onlyOwner {
        require(
            index < validators.length,
            "GmexGovernance: Validator index out of bounds"
        );
        validatorExists[validators[index]] = false;
        validators[index] = validators[validators.length - 1];
        validators.pop();
    }

    function getValidatorIndex(address _validator)
        public
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < validators.length; i++) {
            if (validators[i] == _validator) {
                return i;
            }
        }
        return 0;
    }

    function removeFromValidator(address _validator) internal {
        removeFromValidatorByIndex(getValidatorIndex(_validator));
    }

    // update numberOfValidatorAllowed
    function updateNumberOfValidatorAllowed(uint256 _numberOfValidatorAllowed)
        public
        onlyOwner
    {
        numberOfValidatorAllowed = _numberOfValidatorAllowed;
    }

    function addToBlocklist(address _user) public {
        blocklisted[_user] = true;
    }

    function removeFromBlocklist(address _user) public {
        blocklisted[_user] = false;
    }

    function vestVotes(address validator, uint256 _votingPower) internal {
        voteCount[validator] += _votingPower;
        votingPower[msg.sender] = _votingPower;
    }

    function withdrawVotes(address validator) internal {
        voteCount[validator] -= votingPower[msg.sender];
    }

    function _vestVotesToDifferentValidator(
        address nominator,
        address previousValidator,
        address newValidator
    ) internal {
        voteCount[previousValidator] -= votingPower[nominator];
        voteCount[newValidator] += votingPower[nominator];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../utils/Pausable.sol";

import "../GmexChefV2.sol";
import "./GmexValidators.sol";
import "./GmexVoters.sol";

// Governance contract of Global Market Exchange
contract GmexGovernance is
    Initializable,
    OwnableUpgradeable,
    Pausable,
    GmexValidators,
    GmexVoters
{
    using SafeMathUpgradeable for uint256;

    // Info of each project.
    struct Project {
        string name;
        string shortDescription;
        string tokenSymbol;
        address tokenContract;
        string preferredDEXPlatform;
        int256 totalLiquidity;
        string projectWebsite;
        string twitterLink;
        string telegramLink;
        string discordLink;
        string mediumLink;
        bool approved;
        address[] validatorVoters;
    }

    // Info of each governance.
    struct Governance {
        uint256 governanceVotingStart;
        uint256 governanceVotingEnd;
        address[] validators;
        address[] voters;
        Project[] projects;
        uint256 mostVotedProjectIndex;
        uint256 winningVoteCount;
    }

    Governance[] public pastGovernances;
    Governance public currentGovernance;
    GmexChefV2 public gmexChef;

    modifier onlyGmexChef() {
        require(
            msg.sender == address(gmexChef),
            "GmexGovernance: Only GmexChef can perform this action"
        );
        _;
    }

    modifier runningGovernanceOnly() {
        require(
            currentGovernance.governanceVotingEnd == 0 ||
                block.timestamp < currentGovernance.governanceVotingEnd,
            "GmexGovernance: Voting has already ended"
        );
        require(
            block.timestamp >= currentGovernance.governanceVotingStart &&
                currentGovernance.governanceVotingStart != 0,
            "GmexGovernance: Voitng hasn't started yet"
        );
        _;
    }

    function initialize(
        uint256 _governanceVotingStart,
        uint256 _governanceVotingEnd,
        GmexChefV2 _gmexChef,
        address[] memory _whitelisted
    ) public initializer {
        __Ownable_init();
        __PausableUpgradeable_init();
        __GmexValidators_init(_whitelisted);
        currentGovernance.governanceVotingStart = _governanceVotingStart;
        currentGovernance.governanceVotingEnd = _governanceVotingEnd;
        gmexChef = _gmexChef;
    }

    function getSlashingParameter() internal view returns (uint256) {
        address[] memory currentValidators = getValidators();
        address[]
            memory offlineValidators = getValidatorsWhoHaveNotCastedVotes();

        uint256 x = offlineValidators.length.mul(100);
        uint256 n = currentValidators.length.mul(100);
        uint256 slashingParameter = x.sub(n.div(50)).mul(4).div(n.div(100));

        if (slashingParameter > 100) {
            slashingParameter = 100;
        }

        return slashingParameter;
    }

    function slashOfflineValidators() internal {
        uint256 slashingParameter = getSlashingParameter();
        address[]
            memory offlineValidators = getValidatorsWhoHaveNotCastedVotes();
        address[] memory onlineValidators = getValidatorsWhoHaveCastedVotes();

        gmexChef.slashOfflineValidators(
            slashingParameter,
            offlineValidators,
            onlineValidators
        );
    }

    function evaluateThreeValidatorsNominatedByNominator() internal {
        address[] memory nominators = getVoters();
        uint256 slashingParameter = getSlashingParameter();

        gmexChef.evaluateThreeValidatorsNominatedByNominator(
            slashingParameter,
            nominators
        );
    }

    function vestVotesToDifferentValidator(
        address nominator,
        address previousValidator,
        address newValidator
    ) public onlyGmexChef whenNotPaused {
        _vestVotesToDifferentValidator(
            nominator,
            previousValidator,
            newValidator
        );
    }

    // To be called at the end of a Governance period
    function applySlashing() internal onlyOwner {
        slashOfflineValidators();
        evaluateThreeValidatorsNominatedByNominator();
    }

    function startNewGovernance() external onlyOwner whenNotPaused {
        applySlashing();
        currentGovernance.validators = getValidators();
        currentGovernance.voters = getVoters();
        pastGovernances.push(currentGovernance);
        delete currentGovernance;
        resetVoters();

        currentGovernance.governanceVotingStart = block.timestamp;
        currentGovernance.governanceVotingEnd = block.timestamp + 7776000; // 90 days
    }

    function getPastGovernances() external view returns (Governance[] memory) {
        return pastGovernances;
    }

    function getProjects() external view returns (Project[] memory) {
        return currentGovernance.projects;
    }

    function addProject(
        string memory _name,
        string memory _description,
        string memory _tokenSymbol,
        address _tokenContract,
        string memory _preferredDEXPlatform,
        int256 _totalLiquidity,
        string memory _projectWebsite,
        string memory _twitterLink,
        string memory _telegramLink,
        string memory _discordLink,
        string memory _mediumLink
    ) external runningGovernanceOnly whenNotPaused {
        uint256 index = currentGovernance.projects.length;
        currentGovernance.projects.push();
        Project storage project = currentGovernance.projects[index];
        project.name = _name;
        project.shortDescription = _description;
        project.tokenSymbol = _tokenSymbol;
        project.tokenContract = _tokenContract;
        project.preferredDEXPlatform = _preferredDEXPlatform;
        project.totalLiquidity = _totalLiquidity;
        project.projectWebsite = _projectWebsite;
        project.twitterLink = _twitterLink;
        project.telegramLink = _telegramLink;
        project.discordLink = _discordLink;
        project.mediumLink = _mediumLink;
    }

    function approveProject(uint256 index)
        external
        runningGovernanceOnly
        onlyOwner
        whenNotPaused
    {
        require(
            index < currentGovernance.projects.length,
            "Project index out of bounds"
        );
        Project storage project = currentGovernance.projects[index];
        project.approved = true;
    }

    function delegateValidator(address validator)
        public
        override
        runningGovernanceOnly
        whenNotPaused
    {
        require(
            getValidatorsExists(validator),
            "GmexGovernance: Validator is not a valid"
        );
        super.delegateValidator(validator);

        uint256 votingPower = gmexChef.getVotingPower(msg.sender);
        GmexVoters.vestVotes(votingPower);
        GmexValidators.vestVotes(validator, votingPower);
    }

    function applyForValidator() public virtual override whenNotPaused {
        if (haveDelagatedValidator(msg.sender)) {
            withdrawVotes(getValidatorsNominatedByNominator(msg.sender)[0]); // using 0 index as votes were accumulated with the first validator among the three returned ones

            unDelegateValidator();
        }
        super.applyForValidator();
        uint256 gmexStaked = gmexChef.getStakedAmountInPool(0, msg.sender);
        require(
            gmexStaked >= getValidatorsMinStake(),
            "Stake not enough to become validator"
        );
    }

    function castVote(uint256 index)
        external
        validValidatorsOnly
        whenNotPaused
    {
        require(
            getValidatorsExists(msg.sender),
            "GmexGovernance: Only validators can cast a vote"
        );
        require(
            !haveCastedVote(msg.sender),
            "GmexGovernance: You have already voted"
        );
        require(
            index < currentGovernance.projects.length,
            "GmexGovernance: Project index out of bounds"
        );
        Project storage project = currentGovernance.projects[index];
        require(
            project.approved,
            "GmexGovernance: Project is not approved yet"
        );
        project.validatorVoters.push(msg.sender);
        updateCastedVote(true);
    }

    function rewardMostVotedProject()
        external
        onlyOwner
        runningGovernanceOnly
        whenNotPaused
    {
        uint256 mostVotes = 0;
        uint256 mostVotedIndex = 0;
        for (
            uint256 index = 0;
            index < currentGovernance.projects.length;
            index++
        ) {
            Project storage project = currentGovernance.projects[index];
            if (project.validatorVoters.length > mostVotes) {
                mostVotes = project.validatorVoters.length;
                mostVotedIndex = index;
            }
        }
        currentGovernance.mostVotedProjectIndex = mostVotedIndex;
        currentGovernance.winningVoteCount = mostVotes;
    }

    function leftStakingAsValidator(address _validator)
        external
        onlyGmexChef
        whenNotPaused
    {
        removeFromValidator(_validator);
    }
}

/*
 * Global Market Exchange 
 * Official Site  : https://globalmarket.host
 * Private Sale   : https://globalmarketinc.io
 * Email          : [email protected]
 * Telegram       : https://t.me/gmekcommunity
 * Development    : Digichain Development Technology
 * Dev Is         : Tommy Chain & Team
 * Powering new equity blockchain on decentralized real and virtual projects
 * It is a revolutionary blockchain, DeFi and crypto architecture technology project
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "./utils/Pausable.sol";

import "./tax/ITaxHandler.sol";
import "./treasury/ITreasuryHandler.sol";

/**
 * @title GmexToken
 * @notice This is Global Market Exchange Governance Token.
 */
contract GmexToken is
    Initializable,
    ERC20Upgradeable,
    OwnableUpgradeable,
    Pausable
{
    using SafeMathUpgradeable for uint256;

    uint256 private _cap;
    address public burnerAddress;
    address public gmexChefAddress;

    /// @notice The contract that performs treasury-related operations.
    ITreasuryHandler public treasuryHandler;

    /// @notice The contract that performs tax-related operations.
    ITaxHandler public taxHandler;

    /// @notice Emitted when the treasury handler contract is changed.
    event TreasuryHandlerChanged(address oldAddress, address newAddress);

    /// @notice Emitted when the treasury handler contract is changed.
    event TaxHandlerChanged(address oldAddress, address newAddress);

    /**
     * @param _burnerAddress Address of the burner.
     * @param _treasuryHandlerAddress Address of the GmexTaxHandler contract.
     */
    function initialize(
        address _burnerAddress,
        address _treasuryHandlerAddress,
        address _taxHandlerAddress
    ) public initializer {
        __ERC20_init("Gmex Token", "GMEX");
        __Ownable_init();
        __PausableUpgradeable_init();
        burnerAddress = _burnerAddress;
        _cap = 1e28; //10 billion
        treasuryHandler = ITreasuryHandler(_treasuryHandlerAddress);
        taxHandler = ITaxHandler(_taxHandlerAddress);
    }

    /**
     * @notice Get address of the owner.
     * @dev Required as per BEP20 standard.
     * @return Address of the owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the maximum amount of tokens that can be minted.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev Returns the address of the burner.
     */
    function burner() public view virtual returns (address) {
        return burnerAddress;
    }

    /**
     * @dev Returns the address of the gmex chef.
     */
    function gmexChef() public view virtual returns (address) {
        return gmexChefAddress;
    }

    modifier onlyBurner() {
        require(msg.sender == burner(), "Need Burner !");
        _;
    }

    modifier onlyGmexChefOrOwner() {
        require(
            msg.sender == gmexChef() || msg.sender == owner(),
            "Need GmexChef or Owner !"
        );
        _;
    }

    /// @notice Updates burner address. Must only be called by the burner.
    function updateBurnerAddress(address _newBurnerAddress) public onlyBurner {
        burnerAddress = _newBurnerAddress;
    }

    /// @notice Updates gmexchef address. Must only be called by the owner.
    function updateGmexChefAddress(address _newGmexChefAddress)
        public
        onlyGmexChefOrOwner
    {
        gmexChefAddress = _newGmexChefAddress;
    }

    /// @notice Updates treasury handler address. Must only be called by the owner.
    function updateTreasuryHandlerAddress(address _newTreasuryHandlerAddress)
        public
        onlyOwner
    {
        address oldTreasuryHandlerAddress = address(treasuryHandler);
        treasuryHandler = ITreasuryHandler(_newTreasuryHandlerAddress);
        emit TreasuryHandlerChanged(
            oldTreasuryHandlerAddress,
            _newTreasuryHandlerAddress
        );
    }

    /// @notice Updates tax handler address. Must only be called by the owner.
    function updateTaxHandlerAddress(address _newTaxHandlerAddress)
        public
        onlyOwner
    {
        address oldTaxHandlerAddress = address(taxHandler);
        taxHandler = ITaxHandler(_newTaxHandlerAddress);
        emit TaxHandlerChanged(oldTaxHandlerAddress, _newTaxHandlerAddress);
    }

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner.
    function mint(address _to, uint256 _amount) public onlyOwner whenNotPaused {
        require(totalSupply().add(_amount) <= cap(), "GmexToken: Cap exceeded");
        _mint(_to, _amount);
    }

    function burn(uint256 _amount) public onlyBurner whenNotPaused {
        _burn(msg.sender, _amount);
    }

    /**
     * @notice Transfer tokens from caller's address to another.
     * @param recipient Address to send the caller's tokens to.
     * @param amount The number of tokens to transfer to recipient.
     * @return True if transfer succeeds, else an error is raised.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {
        _spendAllowance(from, _msgSender(), amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override whenNotPaused {
        treasuryHandler.beforeTransferHandler(from, to, amount);

        uint256 tax = taxHandler.getTax(from, to, amount);
        uint256 taxedAmount = amount - tax;

        super._transfer(from, to, taxedAmount);

        if (tax > 0) {
            super._transfer(from, address(treasuryHandler), tax);
        }

        treasuryHandler.afterTransferHandler(from, to, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}