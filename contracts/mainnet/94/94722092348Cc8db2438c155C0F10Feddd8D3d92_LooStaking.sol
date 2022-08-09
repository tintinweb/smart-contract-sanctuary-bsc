/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./console.sol";
interface IERC20 {
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

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IStakingPool{
    function unStake(address _token, address _rec, uint256 _amount) external;
}
contract StakingPool is IStakingPool{
    using SafeMath for uint256;
    address public stakingMain;
 
    constructor(address _stakingMain){
        stakingMain = _stakingMain;
    }

    modifier onlyStaking(){
        require(msg.sender == stakingMain, "OnlyStakingMain");
        _;
    }

    function unStake(address _token, address _rec, uint256 _amount) external override onlyStaking {
        IERC20(_token).transfer(_rec, _amount);
    }

}

interface IUserManager {
    function registerUser(address _user, address _boss) external;
    function userBoss(address _user) external view returns(address);
    function userMembers(address _boss, uint256 _index) external view returns(address);
    function userMembersCount(address _boss) external view returns(uint256);
}

contract LooStaking is Ownable{

    using SafeMath for uint256;

    uint256 public MIN_STAKING_AMT = 1000 * 10 ** 18;

    function setMinStakingAmt(uint256 _min) external onlyOwner {
        MIN_STAKING_AMT = _min;
    }

    // pro
    address public marketWallet = 0xd7E84402729655aC314EfDd6075602e90D196f89;
    address public looTokenAddress = 0xfDB0fE3dD8F7e9A671f63b7e7db0935A955659ab;
    address public rewardsWallet = 0x174cFA6A0c3CE3470baE89e8A03b0eF64Fe2Cf4f;
    address public pairAddress;

    mapping(address => uint256) public userReward;

    IUserManager private userService;
    IStakingPool private stakingPool;

    /**
     * The staking plan structure
    **/
    struct StakePlan {
        uint256 id;
        uint256 period;
        uint256 apr; // x‰
        uint256 staked;
    }
    /**
    * User staking order
    **/
    struct UserStakingItem{
        uint256 itemId;
        uint256 planId;
        uint256 stakingAmt;
        uint256 stakingStartTime;
        uint256 stakingEndTime;
        uint256 lastSettleTime;
        uint256 sharePerSecond;
        address staker;
        bool closed;
        uint256 pureSharePerSecond;
    }

    // all the staking plan
    mapping(uint256 => StakePlan) public stakePlans;
    uint256[] public allPlanIds;
    // all user's staking 
    UserStakingItem[] public allUserStakings;
    
    // user => ids of stakingItem
    mapping(address => uint256[]) public userStakingItems;

    function getUserStakings(address _userAddres) public view returns(uint256[] memory) {
        return userStakingItems[_userAddres];
    }

    constructor(){
        stakingPool = new StakingPool(address(this));
        userService = IUserManager(0x43D84C85545f216cfBdA9C723c175Af23fe63b18);
        initStakingPlan();

    }

    function userStakingItemById(uint256 _id) public view returns(UserStakingItem memory) {
        require(_id < allUserStakings.length, "NotExistStaking");
        return allUserStakings[_id];
    }
    event Staking(address indexed staker, uint256 planId, uint256 stakingAmt);
    
    /**
     * Staking token
     */
    function staking(uint256 _planId, uint256 _stakingAmt, address _boss) lock external{
        require(_planId == 0 || _planId == 1 || _planId == 2 || _planId == 3, "NoStakingPlan");
        require(_stakingAmt >= MIN_STAKING_AMT, "MinStakingError");
        uint256 userBalance = IERC20(looTokenAddress).balanceOf(msg.sender);
        require(userBalance >= _stakingAmt, "PoorMan");
        require(_boss != address(0), "NullBoss");
        require(_boss != msg.sender, "InvalidBoss");
        require(userStakingItems[_boss].length > 0 || _boss == owner(), "InvalidBoss");
        // register user
        address userBoss = userService.userBoss(msg.sender);
        if (userBoss == address(0)) {
            userService.registerUser(msg.sender, _boss);
        }

        IERC20(looTokenAddress).transferFrom(msg.sender, address(stakingPool), _stakingAmt);

        StakePlan storage stakePlan = stakePlans[_planId];

        uint256 profit = _stakingAmt.div(1000).mul(stakePlan.apr);
        uint256 pureProfit = profit;
        // the more you staking , the more you get.
        uint256 extraPercent = getExtraEarning(_stakingAmt);
        if (extraPercent > 0) {
            uint256 extraProfit = profit.mul(extraPercent).div(100);
            profit = profit.add(extraProfit);
        }
        uint256 stakingItemId = allUserStakings.length;
        
        UserStakingItem memory stakingItem = UserStakingItem({
            itemId: stakingItemId,
            planId: _planId,
            stakingAmt: _stakingAmt,
            stakingStartTime: block.timestamp,
            stakingEndTime: block.timestamp + stakePlan.period,
            lastSettleTime: block.timestamp,
            sharePerSecond: profit.div(stakePlan.period),
            staker: msg.sender,
            closed: false,
            pureSharePerSecond: pureProfit.div(stakePlan.period)
        });
        allUserStakings.push(stakingItem);
        userStakingItems[msg.sender].push(stakingItemId);
        stakePlan.staked = stakePlan.staked.add(_stakingAmt);
        emit Staking(msg.sender, _planId, _stakingAmt);
    }

    event WithdrawProfit(address indexed staker, uint256 amount);
    function withdrawProfit() lock external {
        (uint256 profit, uint256 reward) = calculateProfitAndSettle();
        if (profit > 0) {
            IERC20(looTokenAddress).transfer(msg.sender, profit);
            emit WithdrawProfit(msg.sender, profit);
        }
        _distributeRewards(reward);
    }

    function _distributeRewards(uint256 _reward) private {

        if (_reward > 0) {
            uint256 onePercent = _reward.div(60);
            address level1Address = userService.userBoss(msg.sender);
            address level2Address;
            address level3Address;
            if (level1Address != address(0)) {
                level2Address = userService.userBoss(level1Address);
                if (level2Address != address(0)) {
                    level3Address = userService.userBoss(level2Address);
                }
            }
            if (level1Address == address(0)) {
                level1Address = marketWallet;
            }
            if (level2Address == address(0)) {
                level2Address = marketWallet;
            }
            if (level3Address == address(0)) {
                level3Address = marketWallet;
            }
            // To level1
            uint256 level1 = onePercent.mul(18);
            // IERC20(looTokenAddress).transferFrom(rewardsWallet, level1Address, level1);
            userReward[level1Address] += level1;
            // To level2
            uint256 level2 = onePercent.mul(4);
            // IERC20(looTokenAddress).transferFrom(rewardsWallet, level2Address, level2);
            userReward[level2Address] += level2;
            // To level3
            uint256 level3 = onePercent.mul(3);
            // IERC20(looTokenAddress).transferFrom(rewardsWallet, level3Address, level3);
            userReward[level3Address] += level3;

            
            // To Dao
            uint256 dao = onePercent.mul(10);
            IERC20(looTokenAddress).transferFrom(rewardsWallet, marketWallet, dao);
           
            // To Pair
            uint pair = onePercent.mul(5);
            IERC20(looTokenAddress).transferFrom(rewardsWallet, pairAddress, pair);
            
        }
    }
    event ClaimReward(address indexed user, uint256 amount);

    function claimReward() external {
        require(userReward[msg.sender] > 0, "NoReward");
        uint256 reward = userReward[msg.sender];
        userReward[msg.sender] = 0;
        IERC20(looTokenAddress).transferFrom(rewardsWallet, msg.sender, reward);
        emit ClaimReward(msg.sender, reward);
    }

    

    function setPairAddress(address _pair) external onlyOwner{
        pairAddress = _pair;
    }
    function setRewardWallet(address _rewardWallet) external onlyOwner {
        rewardsWallet = _rewardWallet;
    }
    // 
    function calculateProfit() public view returns(uint256){
        uint256[] memory ids = userStakingItems[msg.sender];
        uint256 totalProfit = 0;
        if (ids.length > 0) {
            uint256 i = 0;
            for(i = 0; i < ids.length; i++) {
                UserStakingItem storage stakingItem = allUserStakings[ids[i]];
                // thisProfit = ( now - lastSettle ) * sharePersecod
                if (stakingItem.lastSettleTime < stakingItem.stakingEndTime) {
                    // if efficient
                    if (stakingItem.stakingEndTime <= block.timestamp) {
                        uint256 tmp = stakingItem.stakingEndTime.sub(stakingItem.lastSettleTime).mul(stakingItem.sharePerSecond);
                        totalProfit = totalProfit.add(tmp);
                    } else {
                        totalProfit = totalProfit.add(block.timestamp.sub(stakingItem.lastSettleTime).mul(stakingItem.sharePerSecond));
                    }
                }
            }
            return totalProfit;
        } else {
            return 0;
        }
    }

    function calculateProfitAndSettle() private returns(uint256 totalProfit, uint256 reward){
        uint256[] memory ids = userStakingItems[msg.sender];

        if (ids.length > 0) {
            uint256 i = 0;
            for(i = 0; i < ids.length; i++) {
                UserStakingItem storage stakingItem = allUserStakings[ids[i]];
                // thisProfit = ( now_or_endTime - lastSettle ) * sharePersecod
                if (stakingItem.lastSettleTime < stakingItem.stakingEndTime) {
                    // if efficient
                    if (stakingItem.stakingEndTime <= block.timestamp) {
                        totalProfit = totalProfit.add(stakingItem.stakingEndTime.sub(stakingItem.lastSettleTime).mul(stakingItem.sharePerSecond));
                        reward = reward.add(stakingItem.stakingEndTime.sub(stakingItem.lastSettleTime).mul(stakingItem.pureSharePerSecond));
                        stakingItem.lastSettleTime = stakingItem.stakingEndTime;
                        
                    } else {
                        totalProfit = totalProfit.add(block.timestamp.sub(stakingItem.lastSettleTime).mul(stakingItem.sharePerSecond));
                        reward = reward.add(block.timestamp.sub(stakingItem.lastSettleTime).mul(stakingItem.pureSharePerSecond));
                        stakingItem.lastSettleTime = block.timestamp;
                        
                    }
                }
            }
        }
    }
    function calculateUnStakeAmt() public view returns(uint256){
        uint256[] memory ids = userStakingItems[msg.sender];
        uint256 totalUnStake = 0;
        if (ids.length > 0) {
            uint256 i = 0;
            for(i = 0; i < ids.length; i++) {
                UserStakingItem storage stakingItem = allUserStakings[ids[i]];
                if (stakingItem.stakingEndTime <= block.timestamp && !stakingItem.closed) {
                    totalUnStake = totalUnStake.add(stakingItem.stakingAmt);
                }
            }
        }
        return totalUnStake;
    }
    function calculateUnStakeAmtAndSettle() private returns(uint256 totalUnStake, uint256 totalProfit, uint256 rewards){
        uint256[] memory ids = userStakingItems[msg.sender];
        if (ids.length > 0) {
            uint256 i = 0;
            for(i = 0; i < ids.length; i++) {
                UserStakingItem storage stakingItem = allUserStakings[ids[i]];
                if (stakingItem.stakingEndTime <= block.timestamp && !stakingItem.closed) {
                    totalUnStake = totalUnStake.add(stakingItem.stakingAmt);
                    StakePlan storage stakePlan = stakePlans[stakingItem.planId];
                    stakePlan.staked = stakePlan.staked.sub(stakingItem.stakingAmt);
                    stakingItem.closed = true;
                    if (stakingItem.lastSettleTime < stakingItem.stakingEndTime) {
                        totalProfit = totalProfit.add(stakingItem.stakingEndTime.sub(stakingItem.lastSettleTime).mul(stakingItem.sharePerSecond));
                        rewards = rewards.add(stakingItem.stakingEndTime.sub(stakingItem.lastSettleTime).mul(stakingItem.pureSharePerSecond));
                        stakingItem.lastSettleTime = stakingItem.stakingEndTime;
                    }
                }
            }
        }
    }
    event UnStaking(address indexed staker, uint256 amount);
    function unStaking() lock external {
        (uint256 totalUnStake, uint256 totalProfit, uint256 rewards) = calculateUnStakeAmtAndSettle();
        if (totalProfit > 0) {
            IERC20(looTokenAddress).transfer(msg.sender, totalProfit);
            emit WithdrawProfit(msg.sender, totalProfit);
        }
        if (totalUnStake > 0) {
            stakingPool.unStake(looTokenAddress, msg.sender, totalUnStake);
            emit UnStaking(msg.sender, totalUnStake);
        }
        if (rewards > 0) {
            _distributeRewards(rewards);
        }
    }

    function getStakingPool() external view returns(uint256){
        return IERC20(looTokenAddress).balanceOf(address(stakingPool));
    }
    function getStakingPoolAddress() external view returns(address){
        return address(stakingPool);
    }

    function setUserService(address _userService) external onlyOwner{
        userService = IUserManager(_userService);
    }

    

    function getExtraEarning(uint256 stakingAmt) private pure returns(uint256){
        if (stakingAmt > 10000000 * 10 ** 18) {
            return 50;
        } else if (stakingAmt > 3000000 * 10 ** 18) {
            return 40;
        } else if (stakingAmt > 500000 * 10 ** 18) {
            return 30;
        } else if (stakingAmt > 150000 * 10 ** 18) {
            return 20;
        } else if (stakingAmt > 30000 * 10 ** 18) {
            return 10;
        } else {
            return 0;
        }
    }

    function initStakingPlan() private {
        StakePlan storage plan1 = stakePlans[0];
        plan1.id = 0;
        plan1.period = 30 * 24 * 60 * 60;
        plan1.apr = 108;
        plan1.staked = 0;

        StakePlan storage plan2 = stakePlans[1];
        plan2.id = 1;
        plan2.period = 90 * 24 * 60 * 60;
        plan2.apr = 480;
        plan2.staked = 0;

        StakePlan storage plan3 = stakePlans[2];
        plan3.id = 2;
        plan3.period = 180 * 24 * 60 * 60;
        plan3.apr = 1080;
        plan3.staked = 0;

        StakePlan storage plan4 = stakePlans[3];
        plan4.id = 3;
        plan4.period = 360 * 24 * 60 * 60;
        plan4.apr = 3240;
        plan4.staked = 0;

        allPlanIds.push(0);
        allPlanIds.push(1);
        allPlanIds.push(2);
        allPlanIds.push(3);

    }

    function setMarketWallet(address _newMarketWallet) external onlyOwner{
        marketWallet = _newMarketWallet;
    }
    function setLooTokenAddr(address _tokenAddress) external onlyOwner{
        looTokenAddress = _tokenAddress;
    }
    // Should never happen 
    function forceStopMineWhenAccidental() external onlyOwner {
        IERC20(looTokenAddress).transfer(owner(), IERC20(looTokenAddress).balanceOf(address(this)));
    }
    // When accident happened protect user when perm of contract is available. 
    function forceUnStakingByIdWhenAccidental(uint256 _stakeId) public onlyOwner {
        
        UserStakingItem storage stakingItem = allUserStakings[_stakeId];
        stakingItem.closed = true;
        uint256 totalUnStake = stakingItem.stakingAmt;
        if (totalUnStake > 0) {
            stakingPool.unStake(looTokenAddress, stakingItem.staker, totalUnStake);
            
        }
    }

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }


}