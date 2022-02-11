// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "./Member.sol";

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    function burn(uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

contract Promote is Member {
    
    using SafeMath for uint256;
    uint256 public totalDepositedAmount;
    uint256 public round;
    uint256 public totalRewards;

    uint256 public timeLock = 15 days;

    IERC20 usdt;
    IERC20 era;
    IUniswapV2Pair public pair;

    struct DaliyInfo {
        uint256 round;
        uint256 daliyDividends;
        uint256 rewardedAmount;
        uint256[] perNodeNum;
        uint256[] perValidNum;
        uint256[] perValidWeight;
    }

    struct UserInfo {
        bool isValid;
        uint8 level;
        uint256 num;
        uint256 weight;
        uint256 depositAsUsdt;
        uint256 depositedERA;
        uint256 lastRewardRound;
        uint256 pendingReward;
        address f;
        address[] ss;
        address[] gs;
    }

    struct pendingDeposit{
        uint256 pendingERA;
        uint256 pendingAsUsdt;
    }

    mapping(address=>pendingDeposit) public userPending;
    
    mapping(uint256 => DaliyInfo) public daliyInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public isGamer;
    mapping(uint256 => uint256) public roundTime;
    mapping(address => uint256) public lockRequest;
    
    uint256[] internal numThreshold = [10,30,50,100];
    uint256[] internal amountThreshould = [1000*1e18, 2000*1e18, 3000*1e18, 4000*1e18];
    uint256[] internal rewardPrecent = [30, 25, 30, 15];

    event LevelChange(address _user, uint8 beforeLv, uint8 curLv);
    event NewRound(uint256 _round);
    event NewValid(address _user, address _f);
    event Invalid(address _user, address _f);
    event NewJoin(address _user, address _f);
    event WithdrawRequest(address _user);
    event Withdraw(address _user, uint256 _amount);
    event GetReward(address _user, uint256 _amount);
    event Deposit(address _user, uint256 _amount);

    modifier onlyPool{
        require(msg.sender == address(manager.members("pool")), "this function can only called by pool address!");
        _;
    }
    
    modifier validSender{
        require(msg.sender == address(manager.members("updatecard")) || msg.sender == manager.members("nft") || msg.sender == manager.members("owner"));
        _;
    }
    
    constructor(IERC20 _era, IERC20 _usdt, IUniswapV2Pair _pair, address genesis) {
        era = _era;
        usdt = _usdt;
        pair = _pair;
        isGamer[genesis] = true;
        init();
    }
    
    function init() internal {
        daliyInfo[0].perNodeNum.push(0);
        daliyInfo[0].perNodeNum.push(0);
        daliyInfo[0].perNodeNum.push(0);
        daliyInfo[0].perNodeNum.push(0);
        daliyInfo[0].perValidNum.push(0);
        daliyInfo[0].perValidNum.push(0);
        daliyInfo[0].perValidNum.push(0);
        daliyInfo[0].perValidNum.push(0);
        daliyInfo[0].perValidWeight.push(0);
        daliyInfo[0].perValidWeight.push(0);
        daliyInfo[0].perValidWeight.push(0);
        daliyInfo[0].perValidWeight.push(0);
    }

    function getSS(address _user) public view returns (address[] memory) {
        return userInfo[_user].ss;
    }
    
    function getGS(address _user) public view returns (address[] memory) {
        return userInfo[_user].gs;
    }
    
    function getDaliyPerNode(uint256 _round) public view returns(uint256[] memory) {
        return daliyInfo[_round].perNodeNum;
    }

    function getDaliyValidNum(uint256 _round) public view returns(uint256[] memory) {
        return daliyInfo[_round].perValidNum;
    }

    function getDaliyValidWeight(uint256 _round) public view returns(uint256[] memory) {
        return daliyInfo[_round].perValidWeight;
    }

    function getPrice() public view returns(uint256){
        uint256 usd_balance;
        uint256 era_balance;
        if (pair.token0() == address(usdt)) {
          (usd_balance, era_balance , ) = pair.getReserves();   
        }  
        else{
          (era_balance, usd_balance , ) = pair.getReserves();           
        }
        uint256 token_price = usd_balance.mul(1e18).div(era_balance);
        return token_price;
    }

    function bind(address binding) public {
        UserInfo storage user = userInfo[msg.sender];
        require(isGamer[binding] == true, "origin must in game!");
        require(msg.sender != binding, "can not bindself");
        
        require(user.f == address(0) && isGamer[msg.sender] == false, "Already bound before, please do not bind repeatedly");
        user.f = binding;
        isGamer[msg.sender] = true;
        address ff = userInfo[user.f].f;
        userInfo[user.f].ss.push(msg.sender);
        if (ff != address(0)){
            userInfo[ff].gs.push(msg.sender);
        }
        emit NewJoin(msg.sender, user.f);
    }

    function redem(address sender, uint256 weight, uint256 amount) external onlyPool {
        UserInfo storage user = userInfo[sender];
        require(isGamer[sender] == true, "origin must in game!");
        address f = user.f;
        address ff = userInfo[user.f].f;
        if (f != address(0)) {
            claimReward(f);
            userInfo[f].weight -= amount;
            if (userInfo[f].level > 0) {
                    daliyInfo[round].perValidWeight[userInfo[f].level - 1] -= amount;
                }
        }
        if (ff != address(0)) {
            claimReward(ff);
            userInfo[ff].weight -= amount;
            if (userInfo[ff].level > 0) {
                    daliyInfo[round].perValidWeight[userInfo[ff].level - 1] -= amount;
                }
        }
        if(user.isValid && weight.sub(amount) < 20) {
            userDown(sender);
            evoDown(f);
            if(ff != address(0)) {
                evoDown(ff);
            }

            emit Invalid(sender, f);
        }
        
    }

    function userDown(address sender) internal {
        if (userInfo[sender].level > 0) {
            claimReward(sender);
            daliyInfo[round].perNodeNum[userInfo[sender].level-1]--;
            daliyInfo[round].perValidNum[userInfo[sender].level-1]-= userInfo[sender].num;
            daliyInfo[round].perValidWeight[userInfo[sender].level-1]-= userInfo[sender].weight;
            userInfo[sender].level = 0;
        }
        userInfo[sender].isValid = false;
    }

    function evoDown(address _user) internal {
        uint8 level = userInfo[_user].level;
        uint256 weight = userInfo[_user].weight;
        userInfo[_user].num--;
        if (userInfo[_user].level > 0) {
            daliyInfo[round].perValidNum[level - 1]--;
        }
        if ( level > 0 && userInfo[_user].num < numThreshold[level - 1]) {
            
            daliyInfo[round].perNodeNum[level - 1]--;
            userInfo[_user].level--;
            daliyInfo[round].perValidNum[level - 1] -= userInfo[_user].num;
            daliyInfo[round].perValidWeight[level - 1] -= weight;
            if (userInfo[_user].level > 0) {
                daliyInfo[round].perNodeNum[userInfo[_user].level - 1]++;
                daliyInfo[round].perValidNum[userInfo[_user].level - 1] += userInfo[_user].num;
                daliyInfo[round].perValidWeight[userInfo[_user].level - 1] += weight;
            }
            emit LevelChange(_user, level, level - 1);
        }
    }
    
    function newDeposit(address sender,uint256 weight, uint256 amount) external onlyPool {
        require(isGamer[sender] == true, "origin must in game!");
        UserInfo storage user = userInfo[sender];
        address f = user.f;
        address ff = userInfo[f].f;
        if (f != address(0)) {
            claimReward(f);
            userInfo[f].weight += amount;
            if (userInfo[f].level > 0) {
                    daliyInfo[round].perValidWeight[userInfo[f].level - 1] += amount;
                }
        }
        if (ff != address(0)) {
            claimReward(ff);
            userInfo[ff].weight += amount;
            if (userInfo[ff].level > 0) {
                    daliyInfo[round].perValidWeight[userInfo[ff].level - 1] += amount;
                }
        }
        if(!user.isValid && weight.add(amount) >= 20) {
            userUp(sender);
            evo(f);
            if (ff != address(0)) {
                evo(ff);
            }
            emit NewValid(sender, user.f);
        }  

    }

    function userUp(address sender) internal {
        uint8 level1 = userInfo[sender].level;
        uint8 level2 = updateLevel(sender);
        if (userInfo[sender].isValid == false && level2 > 0) {
            claimReward(sender);
            userInfo[sender].level = level2;
            daliyInfo[round].perNodeNum[level2 -1]++;
            daliyInfo[round].perValidNum[level2 -1] += userInfo[sender].num;
            daliyInfo[round].perValidWeight[level2 -1] += userInfo[sender].weight;
            emit LevelChange(sender, level1, level2);
        }
        userInfo[sender].isValid = true;
    }

    // 更新节点信息（如果提升了等级将沉淀奖励）
    function evo(address _user) internal {
        uint8 level = userInfo[_user].level;
        uint256 weight = userInfo[_user].weight;
        userInfo[_user].num++;
        if (userInfo[_user].level > 0) {
            daliyInfo[round].perValidNum[level - 1]++;
        }
        // 如果升级了， 更新用户等级以及当前轮的节点数量
        if ( 
            userInfo[_user].isValid &&
            level <= 3 && 
            userInfo[_user].num == numThreshold[level] && 
            userInfo[_user].depositAsUsdt >= amountThreshould[level]) {
                if (level > 0) {
                    daliyInfo[round].perNodeNum[level - 1]--;
                    daliyInfo[round].perValidNum[level - 1] -= userInfo[_user].num;
                    daliyInfo[round].perValidWeight[level - 1] -= weight;
                }
                daliyInfo[round].perNodeNum[level]++;
                userInfo[_user].level++;
                daliyInfo[round].perValidNum[level] += userInfo[_user].num;
                daliyInfo[round].perValidWeight[level] += weight;
                emit LevelChange(_user, level, userInfo[_user].level);
        }
    }

    function claimReward(address _user) internal {
        uint256 reward = settleRewards(_user);
        userInfo[_user].pendingReward = userInfo[_user].pendingReward.add(reward);
        userInfo[_user].lastRewardRound = round;
    }
    
    function update(uint256 amount) external validSender {
        if(block.timestamp >= roundTime[round] + 24 hours) {
            round++;
            roundTime[round] = block.timestamp;
            if (round > 0) {
                daliyInfo[round] = daliyInfo[round -1];
                daliyInfo[round].perNodeNum = daliyInfo[round -1].perNodeNum;
                daliyInfo[round].perValidNum = daliyInfo[round -1].perValidNum;
                daliyInfo[round].perValidWeight = daliyInfo[round -1].perValidWeight;
            }
            // daliyInfo[round].round = round;
            daliyInfo[round].daliyDividends = 0;
            daliyInfo[round].rewardedAmount = 0;
            if(round > 16) {
                IERC20(era).transfer(address(manager.members("funder")), daliyInfo[round - 16].daliyDividends.sub(daliyInfo[round - 16].rewardedAmount));
            }
            emit NewRound(round);
        }
        if (msg.sender == manager.members("owner")) {
            amount = 0;
        }
        daliyInfo[round].daliyDividends = daliyInfo[round].daliyDividends.add(amount);
        totalRewards = totalRewards.add(amount);
    }
    
    function deposit(uint256 amount) public {
        require(lockRequest[msg.sender] == 0, "In withdraw");
        require(amount > 0);
        require(isGamer[msg.sender] == true);
        IERC20(era).transferFrom(msg.sender, address(this), amount);
        userInfo[msg.sender].depositedERA = userInfo[msg.sender].depositedERA.add(amount);
        userInfo[msg.sender].depositAsUsdt = userInfo[msg.sender].depositAsUsdt.add(amount.mul(getPrice()).div(1e18));
        uint8 old = userInfo[msg.sender].level;
        uint8 newlevel = updateLevel(msg.sender);
        if (old != newlevel && userInfo[msg.sender].isValid) {
            claimReward(msg.sender);
            userInfo[msg.sender].level = newlevel;
            daliyInfo[round].perNodeNum[newlevel -1]++;
            daliyInfo[round].perValidNum[newlevel -1] += userInfo[msg.sender].num;
            daliyInfo[round].perValidWeight[newlevel -1] += userInfo[msg.sender].weight;
            if (old > 0) {
                daliyInfo[round].perNodeNum[old -1]--;
                daliyInfo[round].perValidNum[old -1] -= userInfo[msg.sender].num;
                daliyInfo[round].perValidWeight[old -1] -= userInfo[msg.sender].weight;
            }
            emit LevelChange(msg.sender, old, newlevel);
        }
        totalDepositedAmount = totalDepositedAmount.add(amount);
        emit Deposit(msg.sender, amount);
    }

    function updateLevel(address user) internal view returns (uint8){
        uint8 level1;
        uint8 level2;
        uint256 amount = userInfo[user].depositAsUsdt;
        if ( amount >= amountThreshould[3]){
            level1 = 4;
        } else if (amount >= amountThreshould[2]) {
            level1 = 3;
        } else if (amount >= amountThreshould[1]) {
            level1 = 2;
        } else if (amount >= amountThreshould[0]) {
            level1 = 1;
        } else {
            level1 = 0;
        }
        if (userInfo[user].num >= numThreshold[3]){
            level2 = 4;
        } else if (userInfo[user].num >= numThreshold[2]) {
            level2 = 3;
        } else if (userInfo[user].num >= numThreshold[1]) {
            level2 = 2;
        } else if (userInfo[user].num >= numThreshold[0]) {
            level2 = 1;
        } else {
            level2 = 0;
        }
        return level1 < level2 ? level1:level2;
    }
    
    function getReward() public {
        uint256 reward = settleRewards(msg.sender);
        IERC20(era).transfer(msg.sender, reward.add(userInfo[msg.sender].pendingReward));
        userInfo[msg.sender].pendingReward = 0;
        userInfo[msg.sender].lastRewardRound = round;
        emit GetReward(msg.sender, reward);
    }

    function timeLockChange(uint256 _period) public {
        require(msg.sender == manager.members("owner"), "onlyOwner");
        timeLock = _period;
    }
    
    function withdraw() public {
        require(lockRequest[msg.sender] !=0 && block.timestamp >= lockRequest[msg.sender].add(timeLock), "locked");
        IERC20(era).transfer(msg.sender, userPending[msg.sender].pendingERA);
        lockRequest[msg.sender] = 0;
        totalDepositedAmount = totalDepositedAmount.sub(userInfo[msg.sender].depositedERA);
        delete userPending[msg.sender];
        emit Withdraw(msg.sender, userInfo[msg.sender].depositedERA);
    }

    function withdrawRequest() public {
        require(lockRequest[msg.sender] == 0, "is in pending");
        getReward();
        if (userInfo[msg.sender].level > 0) {
            daliyInfo[round].perNodeNum[userInfo[msg.sender].level-1]--;
            daliyInfo[round].perValidNum[userInfo[msg.sender].level-1]-= userInfo[msg.sender].num;
            daliyInfo[round].perValidWeight[userInfo[msg.sender].level-1]-= userInfo[msg.sender].weight;
        }
        userPending[msg.sender].pendingERA = userInfo[msg.sender].depositedERA;
        userPending[msg.sender].pendingAsUsdt = userInfo[msg.sender].depositAsUsdt;
        userInfo[msg.sender].level = 0;
        userInfo[msg.sender].depositedERA = 0;
        userInfo[msg.sender].depositAsUsdt = 0;
        lockRequest[msg.sender] = block.timestamp;
        emit WithdrawRequest(msg.sender);
    }
    
    function pendingRewards(address _user) public view returns (uint256 reward){
        if (userInfo[_user].level == 0) {
            return 0;
        }
        // uint256 num = userInfo[_user].num;
        uint8 level = userInfo[_user].level;
        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        for(i; i >0; i--) {
            reward = reward.add(daliyInfo[round-i].daliyDividends.
            mul(rewardPrecent[userInfo[_user].level-1]).div(100).
            mul(userInfo[_user].weight).div(daliyInfo[round-i].perValidWeight[level-1]));
        }
        reward = reward.add(userInfo[_user].pendingReward);
    }

    function settleRewards(address _user) internal returns (uint256 reward){
        if (userInfo[_user].level == 0) {
            return 0;
        }
        // uint256 num = userInfo[_user].num;
        uint8 level = userInfo[_user].level;
        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        uint256 roundReward;
        for(i; i >0; i--) {
            roundReward = daliyInfo[round-i].daliyDividends.
            mul(rewardPrecent[userInfo[_user].level-1]).div(100).
            mul(userInfo[_user].weight).div(daliyInfo[round-i].perValidWeight[level-1]);
            reward = reward.add(roundReward);
            daliyInfo[round-i].rewardedAmount+=roundReward;
        }
    }
    
}