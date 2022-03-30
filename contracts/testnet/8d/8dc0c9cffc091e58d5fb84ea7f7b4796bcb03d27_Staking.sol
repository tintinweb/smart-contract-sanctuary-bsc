/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

//SPDX-License-Identifier: none
pragma solidity ^0.8.7;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface BEP20{
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Staking {
    using SafeMath for uint;
    
    // Variables
    address private owner;
    address private txAddress;
    uint private endTime;
    uint private stakedUsers;
    uint private totalStakedTokens;
    address private contractAddr = address(this);
    uint private totalRewardTokens;

    uint private stakeEndTime;
    
    BEP20 token;
    
    struct Stake {
        uint amount;
        uint stakedAt;
        bool status;
    }
    
    mapping(address => Stake) user;
    
    
    event Staked(address from, uint amount, uint time);
    event Unstaked(address user, uint time);
    event OwnershipTransferred(address to);
    event Received(address, uint);
    
    // Constructor to set initial values for contract
    constructor() {
        owner = msg.sender;
        endTime = 100;
        token = BEP20(0x0e9991A8481D11E70CaB742800B252dF58f8c766);  
        txAddress = msg.sender;
        stakeEndTime = block.timestamp + 100 days;
        totalRewardTokens = 500000000 * 10**18;
    }

    
    
    // Modifier 
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyStakedUser {
        require(user[msg.sender].status == true, "User has not staked");
        _;
    }
    
    // Stake function 
    function stakeTokens(uint _amount) public {
        require(_amount >= 100000 * 10**18, "Stake minimum 100k tokens");
        address sender = msg.sender;
        require(user[sender].amount == 0, "User has already staked");
        require(token.allowance(sender,contractAddr) >= _amount, "Insufficient allowance");
        require(token.balanceOf(sender) >= _amount, "Insufficient balance of user");

        user[sender].amount = _amount;
        user[sender].stakedAt = block.timestamp;
        user[sender].status = true;

        stakedUsers++;
        totalStakedTokens += _amount;
        
        token.transferFrom(sender, contractAddr, _amount);
        emit Staked(sender, _amount, block.timestamp);
    }
    

    function perDayReward() public view returns(uint _perDayReward) {
        // _perDayReward = totalRewardTokens.div(endTime.mul(stakedUsers));
        _perDayReward = totalRewardTokens.div(endTime);
        return _perDayReward;
    }

    function withdrawable(address addr) public view returns(uint _userReward) {
        // uint _userPercentShare = user[addr].amount.div(totalStakedTokens).mul(100000);
        uint _userPercentShare = totalStakedTokens.div(user[addr].amount);
        _userPercentShare = 100000 / (_userPercentShare);
        
        _userReward = totalRewardTokens.mul(_userPercentShare).div(100000);
        
        return _userReward;
    }

    function userPercentShare(address addr) public view returns (uint) {
        uint userAmount = user[addr].amount;
        // uint _userPercentShare = (userAmount.div(totalStakedTokens)).mul(100);
        uint _userPercentShare = (totalStakedTokens / userAmount);
        _userPercentShare = 100000 / (_userPercentShare);
        return _userPercentShare;   
    }
    
    /**
    * Unstake function   
    */
    function unstake() public {
        address receiver = msg.sender;
        Stake storage stk = user[receiver];
        require(stk.amount != 0, "Not staked or already unstaked");
        uint userReward = withdrawable(receiver);
        uint actualReward;
        uint totalSendAmount;

        // Write conditions for time difference
        uint userTime = stk.stakedAt;
        uint timeDifference = stakeEndTime.sub(userTime);

        if(timeDifference > 30 days) {
            totalSendAmount = stk.amount;
        }
        else if(timeDifference < 30 days && timeDifference > 60 days) {
            actualReward = userReward.mul(10).div(100);
            totalSendAmount = stk.amount.add(userReward);
        }
        else if(timeDifference < 60 days && timeDifference > 90 days) {
            actualReward = userReward.mul(20).div(100);
            totalSendAmount = stk.amount.add(userReward);
        }
        else if(timeDifference < 90 days && timeDifference > 100 days) {
            actualReward = userReward.mul(30).div(100);
            totalSendAmount = stk.amount.add(userReward);
        }
        else {
            totalSendAmount = stk.amount.add(userReward);
        }
        
        totalRewardTokens -= actualReward;
        require(token.balanceOf(contractAddr) >= totalSendAmount, "Insufficient balance on contract");
        token.transfer(receiver, totalSendAmount);
        totalStakedTokens -= stk.amount;
        stakedUsers--;
        stk.status = false;
        stk.amount = 0;
        emit Unstaked(receiver, totalSendAmount);
    }

    
    // View user details
    function details(address addr) public view returns(uint amount, uint earnedAmt, uint time, bool stat) {
        Stake storage stk = user[addr];
        
        amount = stk.amount;
        earnedAmt = withdrawable(addr);
        time = stk.stakedAt;
        stat = stk.status;
        return (amount, earnedAmt, time, stat);
    }

    // View stake end time 
    function viewStakeEndTime() public view returns(uint) {
        return stakeEndTime;
    }

    function changeTotalRewardTokens(uint newRewardTokens) external onlyOwner {
        require(newRewardTokens != 0, "cannot set to zero");
        totalRewardTokens = newRewardTokens;
    }
    
    // View owner
    function getOwner() public view returns (address) {
        return owner;
    }

    // View total staked tokens
    function getTotalStakedTokens() public view returns (uint) {
        return totalStakedTokens;
    }

    // View total reward tokens
    function getTotalRewardTokens() public view returns (uint) {
        return totalRewardTokens;
    }
    
    // View number of user who have staked on this contract
    function getStakedUserCount() public view returns (uint) {
        return stakedUsers;
    }
    
    // Transfer ownership 
    // Only owner can do that
    function ownershipTransfer(address to) public onlyOwner {
        require(to != address(0), "Zero address error");
        owner = to;
        emit OwnershipTransferred(to);
    }
    
    // Owner token withdraw 
    function ownerTokenWithdraw(address tokenAddr, uint amount) public onlyOwner {
        BEP20 _token = BEP20(tokenAddr);
        require(amount != 0, "Zero withdrawal");
        _token.transfer(msg.sender, amount);
    }
    
    // Owner BNB withdrawal
    function ownerBnbWithdraw(uint amount) public onlyOwner {
        require(amount != 0, "Zero withdrawal");
        address payable to = payable(msg.sender);
        to.transfer(amount);
    }
    
    // Fallback
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}