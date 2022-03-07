/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract StakingRewards {
    using SafeMath for uint256;
    IERC20 public rewardToken;
    IERC20 public stakingToken;
    
    // The fee collector.
    address public feeCollector;
    address public admin;

      // storing staking by user
    struct UserStake {
      address userWallet;
      uint256 amount;
      uint256 startStakeDate;
      uint256 stakingPeriod; 
    }

    mapping(uint256 => UserStake) public stakeDetails;

    // address to stakeIndex to value
    mapping(address => uint256[]) public userStakeIds;
    //user to stakedPeriod to amount staked
    mapping(address => mapping(uint256 => uint256)) public userPeriodAmount;
    mapping(address => uint256) public totalUserStaking;

    // staking type to unstaking fee percentage, 7days => 
    mapping(uint256 => uint256) public unstakingFees;
    mapping(uint256 => uint256) public stakeAPRs;

    // stake type to period, 7 days, 14 days, 30 days, 50 days, 60 days,...
    uint256[] public stakePeriods;
    uint256[] public feePeriods;
    
    uint256 public yearToSeconds;
    uint256 public stakeIndex;
    uint256 public stakePeriodCount;
    uint256 public feePeriodCount;
    uint256 public totalLocked;
    bool public poolStakingStatus; 
    // Whether it is initialized
    bool public isInitialized;

    event EventStake(address indexed user, uint256 amount, uint256 period);

    constructor() {
        admin = msg.sender;
        poolStakingStatus = true;
        yearToSeconds = 31556926;
    }

    modifier onlyOwner() {
        require(msg.sender == admin);
        _;
    }

     /*
     * @notice Initialize the contract
     * @param _stakedToken: staked token address
     * @param _rewardToken: reward token address
     * @param _rewardPerBlock: reward per block (in rewardToken)
     * @param _startBlock: start block
     * @param _bonusEndBlock: end block
     * @param _poolLimitPerUser: pool limit per user in stakedToken (if any, else 0)
     * @param _poolCap: pool cap in stakedToken (if any, else 0)
     * @param _admin: admin address with ownership
     */
    function initialize(
        address _stakingToken, 
        address _rewardToken,
        address _feeCollector,
        uint256[] memory _stakePeriods,
        uint256[] memory _stakeAprs
    ) external {
        require(_stakePeriods.length == _stakeAprs.length,"Invalid values");
        // Make this contract initialized
        isInitialized = true;
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        feeCollector = _feeCollector;

        for (uint256 j = 0; j < _stakePeriods.length; j++) {
            require(_stakeAprs[j] > 10, "Invalid apr");
            stakeAPRs[_stakePeriods[j]] = _stakeAprs[j];
            stakePeriods.push(_stakePeriods[j]);
        }
        stakePeriodCount = feePeriodCount = _stakePeriods.length;
    }

    function configAPR(uint256[] memory _stakePeriods, uint256[] memory _APRs) public onlyOwner {
        require(_stakePeriods.length == _APRs.length,"Invalid values");
        for (uint256 j = 0; j < _stakePeriods.length; j++) {
            require(_APRs[j] > 10, "Invalid apr");
            stakeAPRs[_stakePeriods[j]] = _APRs[j];
            stakePeriods.push(_stakePeriods[j]);
        }
    }

    function configUnstakeFee(
        uint256[] memory _feePeriods,  // 7 days, 14 days, ..
        uint256[] memory _feePercents // percent 1000 = 10%
    ) 
        public 
        onlyOwner 
    {
        require(_feePeriods.length == _feePercents.length,"Invalid values");

        for (uint256 j = 0; j < _feePeriods.length; j++) {
            unstakingFees[_feePeriods[j]] = _feePercents[j];
            feePeriods.push(_feePeriods[j]);
        }
    }

    function setSecondsInYear(uint256 _seconds) external onlyOwner {
        yearToSeconds = _seconds;
    }

    function setPoolStatus(bool _newPoolStatus) external onlyOwner {
        poolStakingStatus = _newPoolStatus;
    }

    function userStakeIndex() public view returns(uint256){
        return userStakeIds[msg.sender].length;
    }

    function earning(uint256 _stakeId) public view returns(uint256) {
       UserStake storage mstake = stakeDetails[_stakeId]; 
       uint256 stakedTime = block.timestamp - mstake.startStakeDate;
       return mstake.amount.mul(stakedTime).mul(stakeAPRs[mstake.stakingPeriod]).div(10000).div(yearToSeconds);
    } 

    function stake(uint256 _amount, uint256 _period) external{
        require(poolStakingStatus, "Pool is not ready");
        require(isInitialized,"Not yet initialized");
        require(_amount > 0, "Invalid amount");
        require(stakeAPRs[_period] > 0, "Not exists APR");
        require(stakingToken.balanceOf(msg.sender) >= _amount,"Not enough balance");

        UserStake storage currentStake = stakeDetails[stakeIndex]; 
        userStakeIds[msg.sender].push(stakeIndex);
        userPeriodAmount[msg.sender][_period] += _amount;
        stakeIndex++;

        totalUserStaking[msg.sender] += _amount;

        currentStake.userWallet = msg.sender;
        currentStake.amount = _amount;
        currentStake.startStakeDate = block.timestamp;
        currentStake.stakingPeriod = _period;
    
        totalLocked += _amount;
        
        IERC20(stakingToken).transferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        emit EventStake(msg.sender, _amount, _period);
    }

    function calcRewards(uint256 _stakeId) internal view returns(uint256) {
         UserStake storage mstake = stakeDetails[_stakeId];
         if (block.timestamp < (mstake.startStakeDate + mstake.stakingPeriod)) {
             return 0;
         } else {
            return mstake.amount.mul(stakeAPRs[mstake.stakingPeriod]).div(10000).div(yearToSeconds);
         }
    }

    function collectUnstakeFee(uint256 _stakeId) public view returns(uint256) {
        UserStake storage mstake = stakeDetails[_stakeId];
        uint256 stakedTime = block.timestamp - mstake.startStakeDate;
        if (stakedTime > mstake.stakingPeriod) {
            return 0;
        }
        uint256 feePeriod;
        for (uint256 i = 0; i < feePeriods.length; i++) {
            if (stakedTime < feePeriods[i] && feePeriod < feePeriods[i]) {
                feePeriod = feePeriods[i];
            }
        }
        if(feePeriod > 0 ) {
            return mstake.amount.mul(unstakingFees[feePeriod].div(10000));
        }
        else {
            return 0;
        }
    }

    function getIndexByStakeId(address _addr, uint256 _stakeId) internal view returns(uint256) {
        uint256 index;
        for(uint256 i = 0; i < userStakeIds[_addr].length; i++) {
            if (_stakeId == userStakeIds[_addr][i]) {
                index = i;
            }
        }
        return index;
    }

    function unstake(uint256[] memory _stakeIds) external{
        require(_stakeIds.length > 0, "Invalid ids");
        uint256 totalStaked;
        uint256 totalReward;
        uint256 totalUnstakeFee;
        UserStake storage nstake;
        for(uint256 i = 0; i < _stakeIds.length; i++) {
            nstake = stakeDetails[_stakeIds[i]];
            totalStaked += nstake.amount;
            totalReward += calcRewards(_stakeIds[i]);
            totalUnstakeFee += collectUnstakeFee(_stakeIds[i]);

            totalLocked -= nstake.amount;
            userPeriodAmount[msg.sender][nstake.stakingPeriod] -= nstake.amount;

            // removing stake elmenet
            delete stakeDetails[_stakeIds[i]];

            // removing stake id
            userStakeIds[msg.sender][getIndexByStakeId(msg.sender,_stakeIds[i])] = userStakeIds[msg.sender][userStakeIds[msg.sender].length -1];
            userStakeIds[msg.sender].pop();
        }

        if (totalStaked.sub(totalUnstakeFee) > 0) {
            stakingToken.transfer(msg.sender, totalStaked.sub(totalUnstakeFee));
        }

        if (feeCollector != address(0) && totalUnstakeFee > 0) {
            stakingToken.transfer(feeCollector, totalUnstakeFee);
        }
        if (totalReward > 0) {
            stakingToken.transfer(msg.sender, totalReward);
        }
    }

    function getExpiredTokens() public view returns(uint256){
        uint256 amount;
        uint256 rewards;
        UserStake storage mstake;
        for(uint256 i = 0; i < userStakeIds[msg.sender].length; i++) {
            mstake = stakeDetails[userStakeIds[msg.sender][i]];
            if (block.timestamp.sub(mstake.startStakeDate) >= mstake.stakingPeriod) {
                amount += mstake.amount;
                rewards += calcRewards(userStakeIds[msg.sender][i]);
            }
        }
        return amount + rewards;
    }

    function getUnexpiredTokens() public view returns(uint256 ){
        uint256 amount;
        UserStake storage mstake;
        for(uint256 i = 0; i < userStakeIds[msg.sender].length; i++) {
            mstake = stakeDetails[userStakeIds[msg.sender][i]];
            if (block.timestamp.sub(mstake.startStakeDate) > mstake.stakingPeriod) {
                amount += mstake.amount;
            }
        }
        return totalUserStaking[msg.sender] - amount;
    }

    function harvest() external{
        uint256 totalharvest;
        uint256 totalReward;
        UserStake storage nstake;
        for(uint256 i = 0; i < userStakeIds[msg.sender].length; i++) {
            nstake = stakeDetails[userStakeIds[msg.sender][i]];
             if (block.timestamp >= (nstake.startStakeDate + nstake.stakingPeriod)) {
                totalharvest += nstake.amount;
                totalReward += calcRewards(userStakeIds[msg.sender][i]);

                totalLocked -= nstake.amount;
                userPeriodAmount[msg.sender][nstake.stakingPeriod] -= nstake.amount;

                // removing stake elmenet
                delete stakeDetails[userStakeIds[msg.sender][i]];

                // removing stake id
                userStakeIds[msg.sender][i] = userStakeIds[msg.sender][userStakeIds[msg.sender].length -1];
                userStakeIds[msg.sender].pop();
             }
        }

        if (feeCollector != address(0) && totalharvest > 0) {
            stakingToken.transfer(msg.sender, totalharvest);
        }

        if (totalReward > 0) {
            rewardToken.transfer(msg.sender, totalReward);
        }
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}