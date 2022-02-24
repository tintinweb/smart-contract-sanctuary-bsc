// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";

contract Staking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint8[] public ref_bonuses;

    struct UserInfo {
        uint256 poolBal;
        uint256 pool_deposit_time;
        uint256 total_deposits;
        uint256 pool_payouts;
        uint256 rewardEarned;
        
    }

    struct User {
        address upline;
        uint256 referrals;
        uint256 total_structure;
        uint256 deposit_time;
        uint256 match_bonus;
        uint256 bonus;
    }

    struct PoolInfo {
        IERC20 stakingToken;
        IERC20 rewardToken;
        uint256 poolNumber;
        uint256 penaltyPercentage;
        uint256 stakingRewardPercentage;
        uint256 poolDays;
        uint256 poolLimit;
        uint256 poolStaked;
        bool active;
    }

    uint256 public totalPools = 0;
    uint256 public totalStaked;
    uint256 public total_users = 0;

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => User) public users;
    
    event Upline(address indexed addr, address indexed upline);
    event TokenTransfer(address beneficiary, uint256 amount);
    event PoolTransfer(address beneficiary, uint256 amount);
    event RewardClaimed(address beneficiary, uint256 amount);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);

    mapping(address => uint256) public balances;

    constructor() {
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(2);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
        ref_bonuses.push(1);
    }

    /* Recieve Accidental BNB Transfers */
    receive() external payable {}

     function _setUpline(address _addr, address _upline) private {
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != owner() && (users[_upline].deposit_time > 0 || _upline == owner())) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            emit Upline(_addr, _upline);

            total_users++;

            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                if(_upline == address(0)) break;
                users[_upline].total_structure++;
                _upline = users[_upline].upline;
            }
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            if(users[up].referrals >= i + 1) {
                uint256 bonus = _amount * ref_bonuses[i] / 100;
                users[up].bonus += bonus;
                
                emit MatchPayout(up, _addr, bonus);
            }

            up = users[up].upline;
        }
    }

    function add(
        IERC20 _stakingToken,
        IERC20 _rewardToken,
        uint256 _penaltyPercentage,
        uint256 _stakingRewardPercentage,
        uint256 _poolDays,
        uint256 _poolLimit
    ) external onlyOwner {
        require(
            isContract(address(_stakingToken)),
            "Enter correct LP contract address"
        );
        require(
            isContract(address(_rewardToken)),
            "Enter correct Reward contract address"
        );
        require(
            _stakingToken.decimals() == _rewardToken.decimals(),
            "Decimals should be equal"
        );

        poolInfo.push(
            PoolInfo({
                stakingToken: _stakingToken,
                rewardToken: _rewardToken,
                poolNumber: totalPools,
                penaltyPercentage: _penaltyPercentage,
                stakingRewardPercentage: _stakingRewardPercentage,
                poolDays: _poolDays,
                poolLimit: _poolLimit * 10**_stakingToken.decimals(),
                poolStaked: 0,
                active: true
            })
        );
        totalPools = totalPools + 1;
    }

    function poolActivation(uint256 _poolId, bool status) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        pool.active = status;
    }

    function setPenaltyPercentage(uint256 _poolId, uint256 value) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        pool.penaltyPercentage = value;
    }

    function setStakingRewardPercentage(uint256 _poolId, uint256 value) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        pool.stakingRewardPercentage = value;
    }

    /* Stake Token Function */
    function stakePool(uint256 _poolId, uint256 _amount, address _upline)
        external
        nonReentrant
        returns (bool)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];
        require(pool.active, "Pool not Active");
        require(
            _amount <= IERC20(pool.stakingToken).balanceOf(msg.sender),
            "Token Balance of user is less"
        );
        require(pool.poolLimit >= pool.poolStaked + _amount,"Pool Limit Exceeded");
        require(user.poolBal == 0, "Already Staked in this Pool");
        _setUpline(msg.sender, _upline);
        pool.stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 stakingReward = (_amount * pool.stakingRewardPercentage)/100;
        users[msg.sender].match_bonus = stakingReward;

        pool.stakingToken.safeTransfer(
            address(msg.sender),
            stakingReward
        );
        pool.poolStaked += _amount;
        totalStaked += _amount;
        user.poolBal = _amount;
        user.total_deposits += _amount;
        user.pool_deposit_time = uint40(block.timestamp);

        _refPayout(msg.sender, _amount);
        emit PoolTransfer(msg.sender, _amount);
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

        uint256 amount = user.poolBal;
        uint256 reward = users[msg.sender].match_bonus;
        user.rewardEarned += reward;

        if(block.timestamp < user.pool_deposit_time + (pool.poolDays * 60 * 5)){ // 15 Mins Testnet Configured
            if(pool.penaltyPercentage>0){
                amount = amount.sub((amount * (pool.penaltyPercentage))/100);
            }
            if(amount.sub(users[msg.sender].match_bonus) < 0){
                amount = 0;
            }else{
                amount = amount.sub(users[msg.sender].match_bonus);
            }
        }

        user.poolBal = 0;
        user.pool_deposit_time = 0;
        user.pool_payouts += amount;
        users[msg.sender].match_bonus = 0;

        pool.stakingToken.safeTransfer(
            address(msg.sender),
            amount
        );

        emit TokenTransfer(msg.sender, amount);
        return true;
    }

    function claimRewards(uint256 _poolId) public nonReentrant returns(bool){
        
        uint256 bonus = users[msg.sender].bonus;
        require(bonus>0,"No Referral Bonus Earned");
        users[msg.sender].bonus = 0;
        sendToken(_poolId,bonus,msg.sender);
        return true;
    }

    function sendToken(uint256 _poolId,uint256 amount, address _toAddress) internal{
        PoolInfo storage pool = poolInfo[_poolId];
        pool.rewardToken.safeTransfer(
            address(_toAddress),
            amount
        );
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