pragma solidity ^0.8.0;
import 'Ownable.sol';
import 'SafeMath.sol';
import 'IBEP20.sol';
import "SafeBEP20.sol";

//  referral
interface CssReferral {
    function setCssReferral(address farmer, address referrer) external;

    function getCssReferral(address farmer) external view returns (address);
}

contract Staking is Ownable {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 stakeToken;         // Address of LP token contract.
        uint256 lastRewardBlock;  // Last block number that RewardToken distribution occurs.
        uint256 accRewardTokenPerShare; // Accumulated RewardToken per share, times 1e12. See below.
    }

    // The StakeToken! (this can be also an CS-LP token)
    IBEP20 public immutable stakeToken;

    // Token that will be used as a reward for Staking.
    IBEP20 public immutable rewardToken;

    // Token reward created per block.
    uint256 public immutable rewardPerBlock;

    // Info of pool.
    PoolInfo public poolInfo;
    // Info of each user that stakes LP/Tokens.
    mapping (address => UserInfo) public userInfo;
    // The block number when StakeToken mining starts.
    uint256 public immutable startBlock;
    // The block number when StakeToken mining ends.
    uint256 public immutable endBlock;

    // Burn address
    address public burnAddress;
    // Treasury address
    address public divPoolAddress;

    // Referral fee that is fixed on 15%
    uint256 public constant DIV_REFERRAL_FEE = 1500;

    //Fees to burn and treasury
    uint256 public immutable divPoolFee;
    uint256 public immutable divBurnFee;

    // Referral contract address
    address public rewardReferral;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardWithdraw(address indexed user, uint256 amount);
    event StopReward(address indexed user, uint256 _endBlock);
    event RewardPaid(address indexed user, uint256 reward);
    event ReferralPaid(address indexed user, address indexed userTo, uint256 reward);
    event SetRewardReferralAddress(address indexed sender, address indexed referralAddress);
    event SetDevPoolAddress(address indexed sender, address indexed divPoolAddress);
    event SetBurnAddress(address indexed sender, address indexed burnAddress);

    constructor(
        IBEP20 _stakeToken, //token which will be staked
        IBEP20 _rewardToken, //token which will be a reward for staking
        address _burnAddress, //address for burn fee
        address _divPoolAddress, //address for treasury fee
        uint256 _rewardPerBlock, //number of token rewards per block
        uint256 _startBlock, //when the pool will start
        uint256 _endBlock, // when the pool will end
        uint256 _divPoolFee, //fee to treasury on deposit
        uint256 _divBurnFee //fee to burn tokens
    ) {
        require(_divPoolFee.add(_divBurnFee) <= 500, 'Total fee cannot be higher than 5%');
        stakeToken = _stakeToken;
        rewardToken = _rewardToken;
        burnAddress = _burnAddress;
        divPoolAddress = _divPoolAddress;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        endBlock = _endBlock;
        divPoolFee = _divPoolFee;
        divBurnFee = _divBurnFee;

        // staking pool
        poolInfo = PoolInfo({
            stakeToken: _stakeToken,
            lastRewardBlock: _startBlock,
            accRewardTokenPerShare: 0
        });
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplierForBlocks(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= endBlock) {
            return _to.sub(_from);
        } else if (_from >= endBlock) {
            return 0;
        } else {
            return endBlock.sub(_from);
        }
    }

    // View function to see pending Reward on frontend.
    function pendingReward(address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[_user];
        uint256 accRewardTokenPerShare = pool.accRewardTokenPerShare;
        uint256 stakeTokenSupply = pool.stakeToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && stakeTokenSupply != 0) {
            uint256 multiplier = getMultiplierForBlocks(pool.lastRewardBlock, block.number);
            uint256 rewardTokenReward = multiplier.mul(rewardPerBlock);
            accRewardTokenPerShare = accRewardTokenPerShare.add(rewardTokenReward.mul(1e12).div(stakeTokenSupply));
        }
        return user.amount.mul(accRewardTokenPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool() public {
        PoolInfo storage pool = poolInfo;
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 stakeTokenSupply = pool.stakeToken.balanceOf(address(this));
        if (stakeTokenSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplierForBlocks(pool.lastRewardBlock, block.number);
        uint256 rewardTokenReward = multiplier.mul(rewardPerBlock);
        pool.accRewardTokenPerShare = pool.accRewardTokenPerShare.add(rewardTokenReward.mul(1e12).div(stakeTokenSupply));
        pool.lastRewardBlock = block.number;
    }

    // Stake StakeToken and Harvest rewardTokens to CommunityReward
    function deposit(uint256 _amount, address referrer) public {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];

        // anti -backdoor
        require((block.number >= pool.lastRewardBlock || _amount == 0), "pool didnt start yet");

        updatePool();
        if (_amount > 0 && rewardReferral != address(0) && referrer != address(0)) {
            CssReferral(rewardReferral).setCssReferral(msg.sender, referrer);
        }

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accRewardTokenPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                payRefFees(pending);

                rewardToken.safeTransfer(address(msg.sender), pending);
                emit RewardPaid(msg.sender, pending);
            }
        }

        if(_amount > 0) {
            pool.stakeToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            // if divPoolFee = 375 ==>  375 * 1/10000 = 3,75% fee
            uint256 treasuryFee = _amount.mul(divPoolFee).div(10000);
            pool.stakeToken.safeTransfer(divPoolAddress, treasuryFee);

            // if divBurnFee = 125 ==>  125 * 1/10000 = 1,25% fee
            uint256 burnFee = _amount.mul(divBurnFee).div(10000);
            pool.stakeToken.safeTransfer(burnAddress, burnFee);

            user.amount = user.amount.add(_amount).sub(treasuryFee).sub(burnFee);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardTokenPerShare).div(1e12);

        emit Deposit(msg.sender, _amount);
    }


    // Withdraw StakeToken tokens from farm.
    function withdraw(uint256 _amount) external {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool();
        uint256 pending = user.amount.mul(pool.accRewardTokenPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            payRefFees(pending);

            rewardToken.safeTransfer(address(msg.sender), pending);
            emit RewardPaid(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.stakeToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardTokenPerShare).div(1e12);

        emit Withdraw(msg.sender, _amount);
    }

    // Pay referrals equal to the 15% of pending amount
    function payRefFees(uint256 pending) internal
    {
        // 15%
        uint256 toReferral = pending.mul(DIV_REFERRAL_FEE).div(10000);

        address referrer = address(0);
        if (rewardReferral != address(0)) {
            referrer = CssReferral(rewardReferral).getCssReferral(msg.sender);
        }

        if (referrer != address(0)) {// send commission to referrer
            rewardToken.safeTransfer(referrer, toReferral);
            emit ReferralPaid(msg.sender, referrer, toReferral);
        }
    }


    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() public {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        pool.stakeToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    /* Withdraw reward to the treasury.
     Because of the referrals its hard to calculate exact reward tokens needed to be reserved for rewards.
     For that reason owner will provide 115% of the value and can withdraw remaining tokens 10 days after farm is closed*/
    function rewardWithdraw() public onlyOwner {
        require(endBlock <= block.number + 288000, "It too early to withdraw reward tokens"); //10 days
        uint256 balance = rewardToken.balanceOf(address(this));
        rewardToken.safeTransfer(divPoolAddress, balance);
        emit RewardWithdraw(msg.sender, balance);
    }

    // Set address of CSSReferral contract
    function setRewardReferral(address _rewardReferral) external onlyOwner {
        rewardReferral = _rewardReferral;
        emit SetRewardReferralAddress(msg.sender, _rewardReferral);
    }


    // Update treasury address by the owner.
    function setDivPoolAddress(address _divPoolAddress) public onlyOwner {
        divPoolAddress = _divPoolAddress;
        emit SetDevPoolAddress(msg.sender, _divPoolAddress);
    }

    // Update burn address by the owner.
    function setBurnAddress(address _burnAddr) public onlyOwner {
        burnAddress = _burnAddr;
        emit SetBurnAddress(msg.sender, _burnAddr);
    }
}