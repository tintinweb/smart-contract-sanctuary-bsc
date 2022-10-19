// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";

contract CapitalLock is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 poolBal;
        uint40 pool_deposit_time;
        uint256 total_deposits;
        uint256 pool_payouts;
        uint256 rewardEarned;
        uint256 rewardWithdrawn;
    }

    struct PoolInfo {
        IERC20 stakeToken;
        IERC20 rewardToken;
        uint256 poolRewardPercent;
        uint256 poolDays;
        uint256 fullMaturityTime;
        uint256 poolLimit;
        uint256 poolStaked;
        uint256 minStake;
        uint256 maxStake;
        bool active;
    }

    uint256 public totalStaked;
    uint256 private _poolId = 0;

    // Info of each pool.
    PoolInfo[] public poolInfo;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event PrincipalClaimed(address beneficiary, uint256 amount);
    event PoolStaked(address beneficiary, uint256 amount);
    event RewardClaimed(address beneficiary, uint256 amount);

    // Pool Reward Percent APY Input Example:
    // 12500 = 125%,
    // 12055 = 120.55%,
    // 5500 = 55%,
    // 7055 = 70.55%%

    constructor(
        IERC20 _stakeToken,
        uint256 _poolRewardPercentAPY,
        uint256 _poolDays,
        uint256 _poolLimit,
        uint256 _minStake,
        uint256 _maxStake
    ) {
        require(
            isContract(address(_stakeToken)),
            "Enter a Valid Token contract address"
        );
        poolInfo.push(
            PoolInfo({
                stakeToken: _stakeToken,
                rewardToken: _stakeToken,
                poolRewardPercent: _poolRewardPercentAPY,
                poolDays: _poolDays,
                fullMaturityTime: _poolDays.mul(60),
                poolLimit: _poolLimit * 10**_stakeToken.decimals(),
                poolStaked: 0,
                minStake: _minStake * 10**_stakeToken.decimals(),
                maxStake: _maxStake * 10**_stakeToken.decimals(),
                active: true
            })
        );
    }

    /* Recieve Accidental ETH Transfers */
    receive() external payable {}

    function poolActivation(bool status) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        pool.active = status;
    }

    function changePoolLimit(uint256 amount) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        pool.poolLimit = amount * 10**(pool.stakeToken).decimals();
    }

    /* Stake Token Function */
    function PoolStake(uint256 _amount) external nonReentrant returns (bool) {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];
        require(pool.active, "Pool not Active");
        require(
            _amount <= IERC20(pool.stakeToken).balanceOf(msg.sender),
            "Token Balance of user is less"
        );
        require(
            pool.poolLimit >= pool.poolStaked + _amount,
            "Pool Limit Exceeded"
        );
        require(
            _amount >= pool.minStake,
            "Minimum Stake Condition should be Satisfied"
        );
        require(
            _amount <= pool.maxStake,
            "Maximum Stake Condition should be Satisfied"
        );
        require(user.poolBal == 0, "Already Staked in this Pool");

        pool.stakeToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        pool.poolStaked += _amount;
        totalStaked += _amount;
        user.poolBal = _amount;
        user.total_deposits += _amount;
        user.pool_deposit_time = uint40(block.timestamp);
        emit PoolStaked(msg.sender, _amount);
        return true;
    }

    /* Claims Rewards Collected */
    function claim() external nonReentrant returns (bool) {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];

        require(
            user.poolBal > 0,
            "There is no deposit for this address in Pool"
        );

        uint256 calculatedRewards = rewardsCalculate(msg.sender);

        user.rewardEarned += calculatedRewards;
        user.rewardWithdrawn += calculatedRewards;

        if (calculatedRewards > 0) {
            pool.rewardToken.safeTransfer(
                address(msg.sender),
                calculatedRewards
            );
        }

        emit RewardClaimed(msg.sender, calculatedRewards);
        return true;
    }

    /* Claims Rewards Collected */
    function unstake() external nonReentrant returns (bool) {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];

        require(
            user.poolBal > 0,
            "There is no deposit for this address in Pool"
        );
        require(
            (block.timestamp - user.pool_deposit_time) >= pool.fullMaturityTime,
            "Pool Unstake Duration Not Reached"
        );

        uint256 calculatedRewards = rewardsCalculate(msg.sender);
        uint256 amount = user.poolBal;

        user.rewardWithdrawn += calculatedRewards;
        user.pool_payouts += amount;

        user.rewardEarned = 0;
        user.poolBal = 0;
        user.pool_deposit_time = 0;

        pool.stakeToken.safeTransfer(address(msg.sender), amount);
        if (calculatedRewards > 0) {
            pool.rewardToken.safeTransfer(
                address(msg.sender),
                calculatedRewards
            );
        }

        emit RewardClaimed(msg.sender, calculatedRewards);
        emit PrincipalClaimed(msg.sender, amount);
        return true;
    }

    function calculateRewards(uint256 _amount, address userAdd)
        internal
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][userAdd];
        return
            (((_amount * pool.poolRewardPercent) / 10000) / 360) *
            ((block.timestamp - user.pool_deposit_time) / 1 minutes);
    }

    function rewardsCalculate(address userAddress)
        public
        view
        returns (uint256)
    {
        uint256 rewards = 0;
        UserInfo storage user = userInfo[_poolId][userAddress];

        uint256 max_payout = this.maxPayoutOf(user.poolBal);
        uint256 calculatedRewards = (
            calculateRewards(user.poolBal, userAddress)
        ).sub(user.rewardEarned);
        if (user.rewardEarned < max_payout) {
            if ((calculatedRewards + user.rewardEarned) > max_payout) {
                rewards = max_payout.sub(user.rewardEarned);
            } else {
                rewards = calculatedRewards;
            }
        }
        return rewards;
    }

    function maxPayoutOf(uint256 _amount) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_poolId];
        return
            (((_amount * pool.poolRewardPercent) / 10000) / 360) *
            pool.poolDays;
    }

    /* Check Token Balance inside Contract */
    function tokenBalance(address tokenAddr) public view returns (uint256) {
        return IERC20(tokenAddr).balanceOf(address(this));
    }

    /* Check BSC Balance inside Contract */
    function ethBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function retrieveEthStuck() external nonReentrant onlyOwner returns (bool) {
        payable(owner()).transfer(address(this).balance);
        return true;
    }

    function retrieveERC20TokenStuck(address _tokenAddr, uint256 amount)
        external
        nonReentrant
        onlyOwner
        returns (bool)
    {
        IERC20(_tokenAddr).transfer(owner(), amount);
        return true;
    }

    /* Maturity Date */
    function maturityDate(address userAdd) public view returns (uint256) {
        UserInfo storage user = userInfo[_poolId][userAdd];
        PoolInfo storage pool = poolInfo[_poolId];

        return (user.pool_deposit_time + pool.fullMaturityTime);
    }

    function fullMaturityReward(address _userAdd)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][_userAdd];
        uint256 fullReward = (((user.poolBal * pool.poolRewardPercent) /
            10000) / 360) * pool.poolDays;
        return fullReward;
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}