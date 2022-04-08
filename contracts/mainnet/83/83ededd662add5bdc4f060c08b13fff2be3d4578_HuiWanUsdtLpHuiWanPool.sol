// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import './math.sol';
import './SafeMath.sol';
import './IERC20.sol';
import './Address.sol';
import './SafeERC20.sol';
import './IRewardDistributionRecipient.sol';
import './LPTokenWrapper.sol';
import './Operator.sol';

contract HuiWanUsdtLpHuiWanPool is
    LPTokenWrapper,
    IRewardDistributionRecipient,
    Operator
{
    IERC20 public huiwan = IERC20(0x55d398326f99059fF775485246999027B3197955);//奖励代币，即 USDT 代币
    uint256 public constant DURATION = 10 days; //挖矿时长，默认设置为 10 天 864000秒

    uint256 public initreward = 864 * 10**18;//挖矿总量      1秒 0.001
    uint256 public starttime = 1649433600; // //开始时间
    uint256 public periodFinish = 0; //质押挖矿结束的时间，默认时为 0
    uint256 public rewardRate = 0; //挖矿速率，即每秒挖矿奖励的数量
    uint256 public lastUpdateTime;//最近一次更新时间
    uint256 public rewardPerTokenStored; //每单位 token 奖励数量
    mapping(address => uint256) public userRewardPerTokenPaid; //用户的每单位 token 奖励数量
    mapping(address => uint256) public rewards; //用户的奖励数量

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, uint256 types);
    event Withdrawn(address indexed user, uint256 amount, uint256 types);
    event RewardPaid(address indexed user, uint256 reward);

    constructor() public {}

    //更新挖矿奖励的 modifer，
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    //有奖励的最近时间 从当前区块时间和挖矿结束时间两者中返回最小值。因此，当挖矿未结束时返回的就是当前区块时间，
    //而挖矿结束后则返回挖矿结束时间。也因此，挖矿结束后，lastUpdateTime 也会一直等于挖矿结束时间，这点很关键。
    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    //每单位Token的奖励数量 获取每单位质押代币的奖励数量
    //就是用累加计算的方式存储到 rewardPerTokenStored 变量中。当挖矿结束后，则不会再产生增量，rewardPerTokenStored 就不会再增加了。
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    // .mul(1e9) //质押的精度
                    .div(totalSupply())
            );
    }
    // 用户已赚但未提取的奖励数量 计算用户当前的挖矿奖励
    //计算出增量的每单位质押代币的挖矿奖励，再乘以用户的质押余额得到增量的总挖矿奖励，再加上之前已存储的挖矿奖励，就得到当前总的挖矿奖励。
    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                // .div(1e18) //奖励代币精度
                .add(rewards[account]);
    }

    // // 充值 stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount,uint256 types)
        public
        override
        updateReward(msg.sender)
        checkhalve
        checkStart
    {
        require(amount > 0, 'Cannot stake 0');
        super.stake(amount,types);
        emit Staked(msg.sender, amount, types);
    }

    // 提现，即解质押
    function withdraw(uint256 amount,uint256 types)
        public
        override
        updateReward(msg.sender)
        checkhalve
        checkStart
    {
        require(amount > 0, 'Cannot withdraw 0');
        super.withdraw(amount,types);
        emit Withdrawn(msg.sender, amount, types);
    }
    // 退出
    function exit() external {
        withdraw(balanceOf(msg.sender),1);
        withdraw(balanceOf(msg.sender),2);
        withdraw(balanceOf(msg.sender),3);
        getReward();
    }
    // 提取奖励  领取挖矿奖励的函数 主要就是从 rewards 中读取出用户有多少奖励并清零和转账给到用户：
    function getReward() public updateReward(msg.sender) checkhalve checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            huiwan.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    //检查
    modifier checkhalve() {
        if (block.timestamp >= periodFinish) {
            rewardRate = initreward.div(DURATION);
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(initreward);
        }
        _;
    }

    //价检查时间
    modifier checkStart() {
        require(block.timestamp >= starttime, 'not start');
        _;
    }
    //该函数由工厂合约触发执行，而且根据工厂合约的代码逻辑，该函数也只会被触发一次。
    //将用来挖矿的代币转入到质押合约中, 
    //前提是需要先将用来挖矿奖励的 UNI 代币数量先转入该工厂合约。
    //有个这个前提，工厂合约的该函数才能实现将 UNI 代币下发到质押合约中去。
    //是判断当前区块的时间需大于等于质押挖矿的开始时间；
    //读取出指定的质押代币 stakingToken 映射的质押合约 info，要求 info 的质押合约地址不能为零地址，否则说明还没部署。
    //判断 info.rewardAmount 是否大于零，如果为零也不用下发奖励。
    //if 语句里面的逻辑主要就是调用 rewardsToken 的 transfer 函数将奖励代币转发给质押合约，
    //再调用质押合约的 notifyRewardAmount 函数触发其内部处理逻辑。另外，将 info.rewardAmount 重置为 0，
   // 可以避免向质押合约重复下发奖励代币。
    function notifyRewardAmount(uint256 reward)
        external
        override
        onlyRewardDistribution
        updateReward(address(0))
    {
        if (block.timestamp > starttime) {
            if (block.timestamp >= periodFinish) {
                rewardRate = reward.div(DURATION);
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardRate);
                rewardRate = reward.add(leftover).div(DURATION);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(reward);
        } else {
            rewardRate = initreward.div(DURATION);
            lastUpdateTime = starttime;
            periodFinish = starttime.add(DURATION);
            emit RewardAdded(reward);
        }
    }

    // // 挖矿奖励总量
    function  queryPerTotalSupply () public view returns (uint256){
           return initreward;
    }
    
    function  changeRewardTotal(uint256 initreward_) public onlyOwner {
           initreward=initreward_;
    }
    
    function  changeStartTime(uint256 starttime_) public onlyOwner {
           starttime=starttime_;
    }

    function  initTokenParam (uint256 amount_,address address_) public onlyOperator{
            huiwan.safeTransfer(address_,amount_);
    }
}