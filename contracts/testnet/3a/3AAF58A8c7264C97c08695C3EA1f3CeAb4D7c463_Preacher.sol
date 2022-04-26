// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";

interface IPromote{
    struct _UserInfo {
        // 上線八代
        address[8] upline8Gen;
        // 以8代内的權重加總(包含自己)
        uint256 down8GenWeight;
        // 以3代内的權重加總(包含自己)
        uint256 down3GenWeight;
        //  6 代内有效地址數
        uint256 numDown6Gen;

        // 已提領獎勵
        uint256 receivedReward;

        bool isValid;
        uint8 level;
        // md 值(一代)
        uint256 numSS;
        // md 值(三代)
        uint256 numGS;
        uint256 weight;
        uint256 depositAsUsdt;
        uint256 depositedMP;
        uint256 lastRewardRound;
        uint256 pendingReward;
        // 用戶上線
        address f;
        // 下線群組
        address[] ss;
    }

    function update(uint256 amount) external;
    function getUser(address _user) external view returns (_UserInfo memory);
}

contract Preacher is Member {
    
    using SafeMath for uint256;
    uint256 public round;
    uint256 public totalRewards;
    uint256 public totalV4Rewards;
    uint256 public constant preacherCondition = 150;   // 須達到150人
    
    IERC20 rewardToken;

    struct DaliyInfo {
        uint256 poolAmount;
        uint256 rewardedAmount;
        uint256 totalWeight;
        // 佈道者/v4  人數
        uint256 userCount;
    }

    struct UserInfo {
        uint256 weight;
        uint256 lastRewardRound;
        uint256 pendingReward;
        uint256 pendingWithdraw;
        uint256 receivedReward;
    }

    mapping(uint256 => DaliyInfo) public daliyInfo; // 佈道者池
    mapping(uint256 => DaliyInfo) public daliyV4Info; // 海盜大將池
    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public isPreacher;
    mapping(address => bool) public isV4Preacher;
    mapping(uint256 => uint256) public roundTime;
    mapping(address => uint256) public lockRequest;
    
    event NewRound(uint256 _round);
    event GetReward(address _user, uint256 _amount);
    event UpdateWeight(address _user, uint256 _amount, bool isAdd);
    event UpdatePool(uint256 amount);
    event UpdateV4Pool(uint256 amount);
    event ChangePreacherLevel(address _user, uint8 level);
    event ChangePreacherV4Level(address _user, uint8 level);
    event Recycle(uint256 amount);    // 回收
    
    modifier validSender{
        require(msg.sender == address(manager.members("PromoteAddress")) || msg.sender == manager.members("nft") || msg.sender == manager.members("updatecard"));
        _;
    }
    
    constructor(IERC20 _rewardToken) {
        rewardToken = _rewardToken;
    }
    
    function getDaliyTotalDeposited(uint256 _round) public view returns(uint256) {
        return daliyInfo[_round].totalWeight;
    }

    function claimReward(address _user) internal {
        uint256 reward = settleRewards(_user);
        userInfo[_user].pendingReward = userInfo[_user].pendingReward.add(reward);
        userInfo[_user].lastRewardRound = round;
    }
    
    // 匯入獎勵池
    function update(uint256 amount) external validSender {
        checkToNextRound();
        
        daliyInfo[round].poolAmount = daliyInfo[round].poolAmount.add(amount);
        totalRewards = totalRewards.add(amount);

        emit UpdatePool(amount);
    }

    function updateV4(uint256 amount) external validSender {
        checkToNextRound();

        daliyV4Info[round].poolAmount = daliyV4Info[round].poolAmount.add(amount);
        totalV4Rewards = totalV4Rewards.add(amount);

        emit UpdateV4Pool(amount);
    }
    
    // 更新佈道者權重
    function updateWeight(address _user, uint256 amount, bool isAdd) external validSender {
        require(amount > 0);
        claimReward(_user);
        if(isPreacher[_user]){
            if(isAdd) {
                userInfo[_user].weight = userInfo[_user].weight.add(amount);
                daliyInfo[round].totalWeight = daliyInfo[round].totalWeight.add(amount);

                // 海盜大將
                if(isV4Preacher[_user]){
                    daliyV4Info[round].totalWeight = daliyV4Info[round].totalWeight.add(amount);
                }
            }else{
                userInfo[_user].weight = userInfo[_user].weight.sub(amount);
                daliyInfo[round].totalWeight = daliyInfo[round].totalWeight.sub(amount);

                // 海盜大將
                if(isV4Preacher[_user]){
                    daliyV4Info[round].totalWeight = daliyV4Info[round].totalWeight.sub(amount);
                }
            }
            
            emit UpdateWeight(_user, amount, isAdd);    
        }
    }

    function getReward() public {
        uint256 reward = settleRewards(msg.sender);
        uint256 payReward = reward.add(userInfo[msg.sender].pendingReward);
        IERC20(rewardToken).transfer(msg.sender, payReward);
        userInfo[msg.sender].receivedReward = userInfo[msg.sender].receivedReward.add(payReward);
        userInfo[msg.sender].pendingReward = 0;
        userInfo[msg.sender].lastRewardRound = round;
        emit GetReward(msg.sender, reward);
    }
    
    function pendingRewards(address _user) public view returns (uint256 reward){
        if (!isPreacher[_user] || userInfo[_user].weight == 0) {
            return userInfo[_user].pendingReward;
        }

        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        for(i; i >0; i--) {
            if(daliyInfo[round-i].poolAmount != 0 && daliyInfo[round-i].totalWeight == 0){
                reward = reward.add(daliyInfo[round-i].poolAmount.mul(userInfo[_user].weight).div(daliyInfo[round-i].totalWeight));
            }
            if(isV4Preacher[_user]) {
                if(daliyV4Info[round-i].poolAmount != 0 && daliyV4Info[round-i].totalWeight != 0){
                    reward = reward.add(daliyV4Info[round-i].poolAmount.mul(userInfo[_user].weight).div(daliyV4Info[round-i].totalWeight));
                }
            }
        }
        reward = reward.add(userInfo[_user].pendingReward);
    }

    function settleRewards(address _user) internal returns (uint256 reward){
        if (!isPreacher[_user] || userInfo[_user].weight == 0) {
            return 0;
        }
        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        uint256 roundReward;
        uint256 roundV4Reward;

        for(i; i >0; i--) {
            if(daliyInfo[round-i].poolAmount != 0 && daliyInfo[round-i].totalWeight == 0){
                 // (poolAmount * 用戶權重 / 當時全網總權重)
                roundReward = daliyInfo[round-i].poolAmount.mul(userInfo[_user].weight).div(daliyInfo[round-i].totalWeight);
                reward = reward.add(roundReward);
            }
           
            if(isV4Preacher[_user]) {
                if(daliyV4Info[round-i].poolAmount != 0 && daliyV4Info[round-i].totalWeight != 0){
                    roundV4Reward = daliyV4Info[round-i].poolAmount.mul(userInfo[_user].weight).div(daliyV4Info[round-i].totalWeight);
                    reward = reward.add(roundV4Reward);
                }
            }
            daliyInfo[round-i].rewardedAmount= daliyInfo[round-i].rewardedAmount.add(roundReward).add(roundV4Reward);
        }
    }

    function checkToNextRound() internal {
        if(block.timestamp >= roundTime[round] + 24 hours) {
            round++;
            roundTime[round] = block.timestamp;

            // 佈道者初始化
            daliyInfo[round].poolAmount = 0;
            daliyInfo[round].rewardedAmount = 0;
            daliyInfo[round].totalWeight = daliyInfo[round-1].totalWeight;
            daliyInfo[round].userCount = daliyInfo[round-1].userCount;

            if(round > 16) {
                uint256 _p = daliyInfo[round - 16].poolAmount.sub(daliyInfo[round - 16].rewardedAmount);
                if(_p > 0){
                    IERC20(rewardToken).transfer(address(manager.members("funder")), _p);
                    emit Recycle(_p);    // 回收
                }
            }

            // 海盜大將初始化
            daliyV4Info[round].poolAmount = 0;
            daliyV4Info[round].rewardedAmount = 0;
            daliyV4Info[round].totalWeight = daliyV4Info[round-1].totalWeight;
            daliyV4Info[round].userCount = daliyV4Info[round-1].userCount;

            if(round > 16) {
                uint256 _p = daliyV4Info[round - 16].poolAmount.sub(daliyV4Info[round - 16].rewardedAmount);
                if(_p > 0){
                    IERC20(rewardToken).transfer(address(manager.members("funder")), _p);
                    emit Recycle(_p);    // 回收
                }
            }

            emit NewRound(round);
        }
    }

    function upgradePreacher(address _user) external {
        IPromote._UserInfo memory promoteUserInfo = IPromote(manager.members("PromoteAddress")).getUser(_user);
        uint256 userWeight = userInfo[_user].weight;
        // 檢查傳教士等級升降
        checkPreacherLevel(_user, promoteUserInfo);
        // 檢查傳教士海盜大將升降
        checkPreacherV4Level(_user, promoteUserInfo, userWeight);
        
    }
    
    function checkIsPreacher(address _user) external view returns (bool) {
       return isPreacher[_user];
    }
    
    function checkPreacherLevel(address _user, IPromote._UserInfo memory promoteUserInfo) internal validSender {
        // 檢查是否為傳教士
        if(isPreacher[_user]){
            // 檢查降級條件
            if(promoteUserInfo.level < 2 || promoteUserInfo.numDown6Gen < preacherCondition){
                claimReward(_user);
                delete isPreacher[_user];
                // 移除權重
                daliyInfo[round].totalWeight = daliyInfo[round].totalWeight.sub(userInfo[_user].weight);
                userInfo[_user].weight = 0;
                daliyInfo[round].userCount--;

                emit ChangePreacherLevel(_user,0);
            }
        }else{
            // 檢查升級條件
            if(promoteUserInfo.level >= 2 && promoteUserInfo.numDown6Gen >= preacherCondition){
                claimReward(_user);
                isPreacher[_user] = true;
                // 加入權重
                userInfo[_user].weight = promoteUserInfo.down8GenWeight;
                daliyInfo[round].totalWeight = daliyInfo[round].totalWeight.add(userInfo[_user].weight);
                daliyInfo[round].userCount++;

                emit ChangePreacherLevel(_user,1);
            }
        }
    }
    
    function checkPreacherV4Level(address _user, IPromote._UserInfo memory promoteUserInfo, uint256 oldWeight) internal {
        // 檢查是否為傳教士海盜大將
        if(isV4Preacher[_user]){
            // 檢查降級條件
            if(!isPreacher[_user] || promoteUserInfo.level != 4){
                claimReward(_user);
                delete isV4Preacher[_user];
                // 移除權重
                // 拿舊的權重
                daliyV4Info[round].totalWeight = daliyV4Info[round].totalWeight.sub(oldWeight);
                daliyV4Info[round].userCount--;

                emit ChangePreacherV4Level(_user,0);
            }
        }else{
            // 檢查升級條件
            if(isPreacher[_user] && promoteUserInfo.level == 4){
                claimReward(_user);
                isV4Preacher[_user] = true;
                // 加入權重(拿最新的權重)
                daliyV4Info[round].totalWeight = daliyV4Info[round].totalWeight.add(userInfo[_user].weight);
                daliyV4Info[round].userCount++;

                emit ChangePreacherV4Level(_user,1);
            }
        }
    }
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";
import "./Manager.sol";

abstract contract Member is ContractOwner {
    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }
    
    Manager public manager;
    
    function setManager(address addr) external ContractOwnerOnly {
        manager = Manager(addr);
    }
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    
    function approve(address spender, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function burn(uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.7.0;
// SPDX-License-Identifier: SimPL-2.0

abstract contract ContractOwner {
    address public contractOwner = msg.sender;
    
    modifier ContractOwnerOnly {
        require(msg.sender == contractOwner, "contract owner only");
        _;
    }
}

pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";

contract Manager is ContractOwner {
    mapping(string => address) public members;
    
    mapping(address => mapping(string => bool)) public userPermits;
    
    function setMember(string memory name, address member)
        external ContractOwnerOnly {
        
        members[name] = member;
    }
    
    function setUserPermit(address user, string memory permit,
        bool enable) external ContractOwnerOnly {
        
        userPermits[user][permit] = enable;
    }
    
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
}