/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IPancakePair {
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}

abstract contract Pausable is Context {
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
    constructor() {
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
}

contract StakingRewards is Pausable, Ownable{
    using SafeMath for uint256;
    IERC20 public rewardToken;
    IERC20 public stakingToken;
    
    uint256 public constant PERCENT_MUL = 100;
    uint256 public constant PERCENT_DIV = 10000;

    // The fee collector.
    address public feeCollector;
    address public admin;

      // storing staking by user
    struct UserStake {
      address userWallet;
      uint256 amount;
      uint256 startStakeDate;
      uint256 stakingPeriod; // seconds
    }

    mapping(uint256 => UserStake) public stakeDetails;

    // address to stakeIndex to value
    mapping(address => uint256[]) public userStakeIds;
    //user to stakedPeriod to amount staked
    mapping(address => mapping(uint256 => uint256)) public userPeriodAmount;
    mapping(address => uint256) public totalUserStaking;

    // staking type to unstaking fee percentage, 7days => 
    mapping(uint256 => uint256) public unstakingFees;
    mapping(uint256 => uint256) public stakePeriodAPRs;

    // stake type to period, 7 days, 14 days, 30 days, 50 days, 60 days,...
    uint256[] public stakePeriods;
    uint256[] public feePeriods;
    
    uint256 public yearToSeconds;
    uint256 public dayToSeconds;
    uint256 public stakeIndex;
    uint256 public stakePeriodCount;
    uint256 public feePeriodCount;
    uint256 public totalLocked;
    uint256 public poolStartTime;

    uint256 public ptotalStaked; // all staked token
    uint256 public ptotalUnStake; // all unstaked
    uint256 public ptotalHarvested;
    uint256 public ptotalRewardPaid;


    // Whether it is initialized
    bool public isInitialized;

    event EventStake(address indexed user, uint256 amount, uint256 period);

    constructor() {
        admin = msg.sender;
        poolStartTime = block.timestamp;
        yearToSeconds = 31556926;
        dayToSeconds = 86400;
        stakeIndex = 1;
    }

     /*
     * @notice config the contract
     */
    function config(
        address _stakingToken, 
        address _rewardToken,
        address _feeCollector,
        uint256[] memory _stakePeriods, // in seconds
        uint256[] memory _stakeAprs
    ) external onlyOwner{
        require(_stakePeriods.length == _stakeAprs.length,"Invalid values");
        // Make this contract initialized
        isInitialized = true;
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        feeCollector = _feeCollector;

        for (uint256 j = 0; j < _stakePeriods.length; j++) {
            require(_stakeAprs[j] > 1, "Invalid apr");
            stakePeriodAPRs[_stakePeriods[j]] = _stakeAprs[j];
            stakePeriods.push(_stakePeriods[j]);
        }
        stakePeriodCount = feePeriodCount = _stakePeriods.length;
    }

    function configAPR(uint256[] memory _stakePeriods, uint256[] memory _APRs) public onlyOwner {
        require(_stakePeriods.length == _APRs.length,"Invalid values");
        for (uint256 j = 0; j < _stakePeriods.length; j++) {
            stakePeriodAPRs[_stakePeriods[j]] = _APRs[j];
            stakePeriods.push(_stakePeriods[j]);
        }
    }

    function configUnstakeFee(
        uint256[] memory _feePeriods,  // in seconds 60 days, 30 days, .. IMPORTANT Biggest number first
        uint256[] memory _feePercents // percent 10 = 10%
    ) 
        public 
        onlyOwner 
    {
        require(_feePeriods.length == _feePercents.length,"Invalid values");
        if (_feePeriods.length >= 2) {
            require(_feePeriods[0] > _feePeriods[1], "Periods: long to short");
        }

        for (uint256 j = 0; j < _feePeriods.length; j++) {
            unstakingFees[_feePeriods[j]] = _feePercents[j];
            feePeriods.push(_feePeriods[j]);
        }
    }

    function setSecondsInYear(uint256 _seconds) external onlyOwner {
        yearToSeconds = _seconds;
    }

    function setPoolStatus(uint256 _poolStartTime) external onlyOwner {
        poolStartTime = _poolStartTime;
    }

    function userStakeIndex(address _addr) public view returns(uint256){
        return userStakeIds[_addr].length;
    }

    function earning(uint256 _stakeId) public view returns(uint256) {
       uint256 stakedTime = block.timestamp - stakeDetails[_stakeId].startStakeDate;
        uint256 stakedAmt = stakeDetails[_stakeId].amount;
        uint256 stakedTokenAmt = getTokenAmountFromLp(stakedAmt);
       return stakedTokenAmt.mul(stakedTime).mul(stakePeriodAPRs[stakeDetails[_stakeId].stakingPeriod]).mul(PERCENT_MUL).div(PERCENT_DIV).div(yearToSeconds);
    } 

    function stake(uint256 _amount, uint256 _period) external whenNotPaused{
        require(block.timestamp >= poolStartTime, "Pool is not ready");
        require(isInitialized,"Not yet initialized");
        require(_amount > 0, "Invalid amount");
        require(stakePeriodAPRs[_period] > 0, "Not exists APR");
        require(stakingToken.balanceOf(msg.sender) >= _amount,"Not enough balance");
        rmHarvestedEl();
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
        ptotalStaked += _amount;
        
        IERC20(stakingToken).transferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        emit EventStake(msg.sender, _amount, _period);
    }

    function collectUnstakeFee(uint256 _stakeId) public view returns(uint256) {
        uint256 stakedTime = block.timestamp - stakeDetails[_stakeId].startStakeDate;
        if (stakedTime > stakeDetails[_stakeId].stakingPeriod) {
            return 0;
        }
        uint256 feePeriod;
        for (uint256 i = 0; i < feePeriods.length; i++) {
            if (stakedTime < feePeriods[i]) {
                feePeriod = feePeriods[i];
            }
        }
        if(feePeriod > 0 ) {
            return stakeDetails[_stakeId].amount.mul(unstakingFees[feePeriod]).mul(PERCENT_MUL).div(PERCENT_DIV);
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

    function unstake(uint256[] memory _stakeIds) external whenNotPaused{
        require(_stakeIds.length > 0, "Invalid ids");
        uint256 totalStaked;
        uint256 totalUnstakeFee;
        for(uint256 i = 0; i < _stakeIds.length; i++) {
            totalStaked += stakeDetails[_stakeIds[i]].amount;
            totalUnstakeFee += collectUnstakeFee(_stakeIds[i]);

            totalLocked -= stakeDetails[_stakeIds[i]].amount;
            ptotalUnStake += stakeDetails[_stakeIds[i]].amount;

            userPeriodAmount[msg.sender][stakeDetails[_stakeIds[i]].stakingPeriod] -= stakeDetails[_stakeIds[i]].amount;

            // removing stake elmenet
            delete stakeDetails[_stakeIds[i]];

            // removing stake id
            userStakeIds[msg.sender][getIndexByStakeId(msg.sender,_stakeIds[i])] = 0;
        }

        if (totalStaked.sub(totalUnstakeFee) > 0) {
            stakingToken.transfer(msg.sender, totalStaked.sub(totalUnstakeFee));
        }

        if (feeCollector != address(0) && totalUnstakeFee > 0) {
            stakingToken.transfer(feeCollector, totalUnstakeFee);
        }
    }

    function getExpiredTokens(address _addr) public view returns(uint256){
        uint256 amount;
        // uint256 rewards;
        
        for(uint256 i = 0; i < userStakeIds[_addr].length; i++) {
            if (userStakeIds[_addr][i] > 0 && (block.timestamp - stakeDetails[userStakeIds[_addr][i]].startStakeDate) >= stakeDetails[userStakeIds[_addr][i]].stakingPeriod) {
                amount += stakeDetails[userStakeIds[_addr][i]].amount;
                // rewards += calcRewards(userStakeIds[_addr][i]);
            }
        }
        return amount;// + rewards;
    }

    function getUnexpiredTokens(address _addr) public view returns(uint256 ){
        uint256 amount;
        
        for(uint256 i = 0; i < userStakeIds[_addr].length; i++) {
            if (userStakeIds[_addr][i] > 0 && (block.timestamp - stakeDetails[userStakeIds[_addr][i]].startStakeDate) < stakeDetails[userStakeIds[_addr][i]].stakingPeriod) {
                amount += stakeDetails[userStakeIds[_addr][i]].amount;
            }
        }
        return amount;
    }

    function calcRewards(uint256 _stakeId) internal view returns(uint256) {
         if (block.timestamp < (stakeDetails[_stakeId].startStakeDate + stakeDetails[_stakeId].stakingPeriod)) {
             return 0;
         } else {
            uint256 stakedAmt = stakeDetails[_stakeId].amount;
            uint256 stakedTokenAmt = getTokenAmountFromLp(stakedAmt);
            return stakedTokenAmt.mul(stakeDetails[_stakeId].stakingPeriod).mul(stakePeriodAPRs[stakeDetails[_stakeId].stakingPeriod]).mul(PERCENT_MUL).div(PERCENT_DIV).div(yearToSeconds);
         }
    }

    function calcRewardsHv(uint256 _stakeId) public view returns(uint256) {
        uint256 stakedAmt = stakeDetails[_stakeId].amount;
        uint256 stakedTokenAmt = getTokenAmountFromLp(stakedAmt);
        return stakedTokenAmt.mul(stakeDetails[_stakeId].stakingPeriod).mul(stakePeriodAPRs[stakeDetails[_stakeId].stakingPeriod]).mul(PERCENT_MUL).div(PERCENT_DIV).div(yearToSeconds);
    }

    function rmHarvestedEl() internal {
        for(uint256 i = 0; i < userStakeIds[msg.sender].length; i++) {
            // this variable was set to 0 when harvesting
            if(userStakeIds[msg.sender][i]  == 0) {
                userStakeIds[msg.sender][i] = userStakeIds[msg.sender][userStakeIds[msg.sender].length - 1];
                userStakeIds[msg.sender].pop();
            }
        }
    }

    function emerWithdraw(
        address _token, 
        address _to, 
        uint256 _amount
    ) 
        external onlyOwner
    {
        IERC20(_token).transfer(_to, _amount);
    }

    function harvest() external whenNotPaused{
        uint256 totalharvest;
        uint256 totalReward;
        for(uint256 i = 0; i < userStakeIds[msg.sender].length; i++) {
            if (userStakeIds[msg.sender][i] > 0 && (block.timestamp - stakeDetails[userStakeIds[msg.sender][i]].startStakeDate) >= stakeDetails[userStakeIds[msg.sender][i]].stakingPeriod) {
                totalharvest += stakeDetails[userStakeIds[msg.sender][i]].amount;
                totalReward += calcRewards(userStakeIds[msg.sender][i]);

                totalLocked -= stakeDetails[userStakeIds[msg.sender][i]].amount;
                ptotalHarvested += stakeDetails[userStakeIds[msg.sender][i]].amount;

                userPeriodAmount[msg.sender][stakeDetails[userStakeIds[msg.sender][i]].stakingPeriod] -= stakeDetails[userStakeIds[msg.sender][i]].amount;

                // removing stake elmenet
                delete stakeDetails[userStakeIds[msg.sender][i]];

                // removing stake id
                userStakeIds[msg.sender][i] = 0;
             }
        }

        if (feeCollector != address(0) && totalharvest > 0) {
            stakingToken.transfer(msg.sender, totalharvest);
        }

        if (totalReward > 0) {
            ptotalRewardPaid += totalReward;
            rewardToken.transfer(msg.sender, totalReward);
        }
    }

    function getTokenAmountFromLp(uint256 _lpAmount) internal view returns(uint256) {
        uint256 totalTokenBalOfLp = IERC20(rewardToken).balanceOf(address(stakingToken));
        uint256 lpTotalSupply = IPancakePair(address(stakingToken)).totalSupply();
        return _lpAmount.mul(totalTokenBalOfLp).div(lpTotalSupply);
    }

     function getTokenAmount(uint256 _lpAmount) external view returns(uint256) {
        uint256 totalTokenBalOfLp = IERC20(rewardToken).balanceOf(address(stakingToken));
        uint256 lpTotalSupply = IPancakePair(address(stakingToken)).totalSupply();
        return _lpAmount.mul(totalTokenBalOfLp).div(lpTotalSupply);
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