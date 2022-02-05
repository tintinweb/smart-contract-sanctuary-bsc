// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";

contract HyperavaxStake is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 poolBal;
        uint40 pool_deposit_time;
        uint256 total_deposits;
        uint256 pool_payouts;
        uint256 rewardEarned;
        uint256 totalEarned;
    }

    struct PoolInfo {
        IERC20 stakeToken;
        IERC20 rewardToken;
        uint256 poolNumber;
        uint256 poolStaked;
        uint256 poolPercentage;
        bool active;
    }

    uint256 public totalPools = 0;
    uint256 public totalStaked;

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event TokenTransfer(address beneficiary, uint256 amount);
    event PoolTransfer(address beneficiary, uint256 amount);
    event RewardClaimed(address beneficiary, uint256 amount);

    mapping(address => uint256) public balances;

    constructor() {}

    /* Recieve Accidental BNB Transfers */
    receive() external payable {}

    function add(
        IERC20 _stakeToken,
        IERC20 _rewardToken,
        uint256 poolPercent

    ) external onlyOwner {
        require(
            isContract(address(_stakeToken)),
            "Enter correct LP contract address"
        );
        require(
            isContract(address(_rewardToken)),
            "Enter correct Reward contract address"
        );
        require(
            _stakeToken.decimals() == _rewardToken.decimals(),
            "Decimals should be equal"
        );

        poolInfo.push(
            PoolInfo({
                stakeToken: _stakeToken,
                rewardToken: _rewardToken,
                poolNumber: totalPools,
                poolStaked: 0,
                poolPercentage: poolPercent,
                active: true
            })
        );
        totalPools = totalPools + 1;
    }

    function poolActivation(uint256 _poolId, bool status) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        pool.active = status;
    }

    /* Stake Token Function */
    function stakePool(uint256 _poolId, uint256 _amount)
        external
        nonReentrant
        returns (bool)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];
        
        require(pool.active, "Pool not Active");
        require(
            _amount <= IERC20(pool.stakeToken).balanceOf(msg.sender),
            "Token Balance of user is less"
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
        user.pool_payouts = 0;
        user.rewardEarned = 0;
        user.pool_deposit_time = uint40(block.timestamp);
        emit PoolTransfer(msg.sender, _amount);
        return true;
    }

    /* Deactivate Pool */
    function deactivatePool(uint256 _poolId, bool _active)
        external
        nonReentrant
        onlyOwner
        returns (bool)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        pool.active = _active;
        return true;
    }

    /* Deactivate Pool */
    function changeRewardPercent(uint256 _poolId, uint256 _percentage)
        external
        nonReentrant
        onlyOwner
        returns (bool)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        pool.poolPercentage = _percentage;
        return true;
    }

    /* Claims Principal Token and Rewards Collected */
    function claimReward(uint256 _poolId) external nonReentrant returns (bool) {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];

        require(
            user.poolBal > 0,
            "There is no deposit for this address in Pool"
        );
        uint256 calculatedRewards = rewardsCalculate(_poolId, msg.sender);

        uint256 totalReward = calculatedRewards;
        user.rewardEarned += totalReward;
        user.totalEarned += totalReward;
        emit RewardClaimed(msg.sender, totalReward);
        
        pool.rewardToken.safeTransfer(
            address(msg.sender),
            totalReward
        );
        return true;
    }


    /* Claims Principal Token and Rewards Collected */
    function claimPool(uint256 _poolId) external nonReentrant returns (bool) {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];

        require(
            user.poolBal > 0,
            "There is no deposit for this address in Pool"
        );
        uint256 calculatedRewards = rewardsCalculate(_poolId, msg.sender);

        uint256 amount = user.poolBal;
        uint256 totalReward = calculatedRewards;
        user.rewardEarned += totalReward;
        user.totalEarned += totalReward;
        emit RewardClaimed(msg.sender, totalReward);
        uint256 principalBalance = user.poolBal;
        user.poolBal = 0;
        user.pool_deposit_time = 0;
        user.pool_payouts += amount;

        pool.stakeToken.safeTransfer(
            address(msg.sender),
            principalBalance
        );
        pool.rewardToken.safeTransfer(
            address(msg.sender),
            totalReward
        );

        emit TokenTransfer(msg.sender, amount);
        return true;
    }

    function calculateRewards(
        uint256 _poolId,
        uint256 _amount,
        address userAdd
    ) internal view returns (uint256) {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][userAdd];
        return ((_amount * ((block.timestamp - user.pool_deposit_time)/ 5 minutes) * pool.poolPercentage ) / 100) - user.rewardEarned;
            
    }

    function rewardsCalculate(uint256 _poolId, address userAddress)
        public
        view
        returns (uint256)
    {
        uint256 rewards=0;
        UserInfo storage user = userInfo[_poolId][userAddress];

        uint256 calculatedRewards = calculateRewards(
            _poolId,
            user.poolBal,
            userAddress
        );
        if (user.poolBal > 0) {
            rewards = calculatedRewards;
        }
        return rewards;
    }


    /* Check Token Balance inside Contract */
    function tokenBalance(address tokenAddr) public view returns (uint256) {
        return IERC20(tokenAddr).balanceOf(address(this));
    }

    /* Check BSC Balance inside Contract */
    function bnbBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function retrieveBnbStuck(address payable wallet)
        public
        nonReentrant
        onlyOwner
        returns (bool)
    {
        wallet.transfer(address(this).balance);
        return true;
    }

    function retrieveBEP20TokenStuck(
        address _tokenAddr,
        uint256 amount,
        address toWallet
    ) public nonReentrant onlyOwner returns (bool) {
        IERC20(_tokenAddr).transfer(toWallet, amount);
        return true;
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