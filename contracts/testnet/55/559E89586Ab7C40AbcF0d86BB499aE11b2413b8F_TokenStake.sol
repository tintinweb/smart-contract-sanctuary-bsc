// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "../Manager/Member.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";
contract TokenStake is Member {
    
    using SafeMath for uint256;
    uint256 public totalDepositedAmount;
    uint256 public round;
    uint256 public totalRewards;
    uint256 public totalStakers;

    uint256 public timeLock = 15 days;
    
    IERC20 mp;
    IERC20 stakeToken;

    struct DaliyInfo {
        uint256 daliyDividends;
        uint256 rewardedAmount;
        uint256 totalDeposited;
    }

    struct UserInfo {
        uint256 depositedToken;
        uint256 lastRewardRound;
        uint256 pendingReward;
        uint256 receivedReward;
        uint256 pendingWithdraw;
    }
    
    mapping(uint256 => DaliyInfo) public daliyInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => uint256) public roundTime;
    mapping(address => uint256) public lockRequest;

    event NewRound(uint256 _round);
    event WithdrawRequest(address _user);
    event Withdraw(address _user, uint256 _amount);
    event GetReward(address _user, uint256 _amount);
    event Deposit(address _user, uint256 _amount);
    
    modifier validSender{
        require(msg.sender == address(manager.members("nftMasterChef")) || msg.sender == manager.members("nft") || msg.sender == manager.members("updatecard") || msg.sender == manager.members("owner"));
        _;
    }
    
    constructor(IERC20 _mp, IERC20 _stakeToken) {
        mp = _mp;
        stakeToken = _stakeToken;
        // init();
    }
    
    function init() internal {
    }

    function getDaliyTotalDeposited(uint256 _round) public view returns(uint256) {
        return daliyInfo[_round].totalDeposited;
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
            daliyInfo[round].daliyDividends = 0;
            daliyInfo[round].rewardedAmount = 0;
            daliyInfo[round].totalDeposited = 0;

            if(round > 16) {
                IERC20(mp).transfer(address(manager.members("funder")), daliyInfo[round - 16].daliyDividends.sub(daliyInfo[round - 16].rewardedAmount));
            }
            emit NewRound(round);
        }
        daliyInfo[round].daliyDividends = daliyInfo[round].daliyDividends.add(amount);
        totalRewards = totalRewards.add(amount);
    }
    
    function deposit(uint256 amount) public {
        require(lockRequest[msg.sender] == 0, "is in pending");
        require(amount > 0);
        IERC20(stakeToken).transferFrom(msg.sender, address(this), amount);
        claimReward(msg.sender);
        if(userInfo[msg.sender].depositedToken == 0) {
            totalStakers++;
        }
        userInfo[msg.sender].depositedToken = userInfo[msg.sender].depositedToken.add(amount);
        totalDepositedAmount = totalDepositedAmount.add(amount);
        daliyInfo[round].totalDeposited = daliyInfo[round].totalDeposited.add(amount);
        emit Deposit(msg.sender, amount);
    }

    function getReward() public {
        uint256 reward = settleRewards(msg.sender);
        uint256 payReward = reward.add(userInfo[msg.sender].pendingReward);
        IERC20(mp).transfer(msg.sender, payReward);
        userInfo[msg.sender].receivedReward = userInfo[msg.sender].receivedReward.add(payReward);
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
        uint256 pendingWithdraw = userInfo[msg.sender].pendingWithdraw;
        uint256 fee = pendingWithdraw.mul(2).div(100);
        IERC20(stakeToken).transfer(msg.sender, pendingWithdraw.sub(fee));
        IERC20(stakeToken).transfer(address(manager.members("OfficalAddress")), fee);
        
        lockRequest[msg.sender] = 0;
        totalDepositedAmount = totalDepositedAmount.sub(pendingWithdraw);
        userInfo[msg.sender].pendingWithdraw = 0;
        emit Withdraw(msg.sender, pendingWithdraw);
    }

    function withdrawRequest() public {
        require(lockRequest[msg.sender] == 0, "is in pending");
        getReward();

        uint256 userDeposited = userInfo[msg.sender].depositedToken;
        daliyInfo[round].totalDeposited = daliyInfo[round].totalDeposited.sub(userDeposited);
        userInfo[msg.sender].depositedToken = 0;
        userInfo[msg.sender].pendingWithdraw = userDeposited;
        totalStakers--;
        lockRequest[msg.sender] = block.timestamp;
        emit WithdrawRequest(msg.sender);
    }
    
    function pendingRewards(address _user) public view returns (uint256 reward){
        if(userInfo[_user].depositedToken == 0){
            return 0;
        }
        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        for(i; i >0; i--) {
            if(daliyInfo[round-i].daliyDividends == 0){
                continue;
            }
            reward = reward.add(daliyInfo[round-i].daliyDividends.mul(userInfo[_user].depositedToken).div(daliyInfo[round-i].totalDeposited));
        }
        reward = reward.add(userInfo[_user].pendingReward);
    }

    function settleRewards(address _user) internal returns (uint256 reward){
        if(userInfo[_user].depositedToken == 0){
            return 0;
        }
        uint8 i = round.sub(userInfo[_user].lastRewardRound) >= 15 ? 15: uint8(round.sub(userInfo[_user].lastRewardRound));
        uint256 roundReward;

        for(i; i >0; i--) {
            if(daliyInfo[round-i].daliyDividends == 0){
                continue;
            }
            // (daliyDividends * 用戶質押數 / 當時全網總質押)
            roundReward = daliyInfo[round-i].daliyDividends.mul(userInfo[_user].depositedToken).div(daliyInfo[round-i].totalDeposited);
            reward = reward.add(roundReward);
            daliyInfo[round-i].rewardedAmount+=roundReward;
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