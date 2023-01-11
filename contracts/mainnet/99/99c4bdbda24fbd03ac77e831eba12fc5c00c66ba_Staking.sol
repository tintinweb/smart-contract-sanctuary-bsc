/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

//SPDX-License-Identifier: MIT
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
    uint private poolFourCount;
    address private contractAddr = address(this);
    
    BEP20 token;
    
    struct Stake {
        uint[] pool;
        uint[] amounts;
        uint[] stakedAt;
        uint[] withdrawnRoi;
        bool[] status;
    }

    struct Pool {
        uint time;
        uint percent;
        uint endTime;
    }

    Pool[] public pools;
    
    mapping(address => Stake) user;
    mapping(address => bool) public stakeStatus;
    mapping(address => uint) public userStakeNum;
    
    event Staked(address from, uint amount, uint time);
    event OwnershipTransferred(address to);
    event Received(address, uint);
    event Unstaked(address, uint);
    
    // Constructor to set initial values for contract
    constructor() {
        owner = msg.sender;
        endTime = 365 days;
        token = BEP20(0x04c8238663631cD88C0a2Dd9f27B6655B6a83496);  //mainnet
        txAddress = msg.sender;

        pools.push(Pool(365 days, 5, 365 days));
        pools.push(Pool(365 days, 10, 548 days));
        pools.push(Pool(365 days, 14, 730 days));
        pools.push(Pool(365 days, 24, 1095 days));
    }
    
    // Modifier 
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    // Stake function 
    function stakeTokens(uint _amount, uint _pool) public {
        // uint txAmount;
        uint stakeAmount = _amount;
        address sender = msg.sender;
        // require(token.allowance(sender,contractAddr) >= _amount, "Insufficient allowance");
        require(token.balanceOf(sender) >= _amount, "Insufficient balance of user");

        user[sender].pool.push(_pool);
        user[sender].amounts.push(stakeAmount);
        user[sender].stakedAt.push(block.timestamp);
        user[sender].status.push(true);
        user[sender].withdrawnRoi.push(0);
        userStakeNum[sender] += 1;
        
        if(stakeStatus[sender] != true){
            stakeStatus[sender] = true;
            stakedUsers += 1;
        }

        token.transferFrom(sender, contractAddr, stakeAmount);
        // token.transferFrom(sender, txAddress, txAmount);
        emit Staked(sender, stakeAmount, block.timestamp);
    }
    
    // View withdrawable amount 
    function withdrawable(address addr, uint index) public view returns (uint reward) {

        Stake storage stk = user[addr];
        Pool storage _pools = pools[index];
        uint pool = stk.pool[index];
        uint amount = stk.amounts[index];
        uint end;
        uint percent;
        if(stk.status[index] == true){
            if(pool == 0) {
                end = stk.stakedAt[index].add(_pools.endTime);
                percent = _pools.percent;
            }
            else if(pool == 1) {
                end = stk.stakedAt[index].add(_pools.endTime);
                percent = _pools.percent;
            }
            else if(pool == 2) {
                end = stk.stakedAt[index].add(_pools.endTime);
                percent = _pools.percent;
            }
            else if(pool == 3) {
                end = stk.stakedAt[index].add(_pools.endTime);
                percent = _pools.percent;
            }

            uint since = stk.stakedAt[index];
            uint till = block.timestamp > end ? end : block.timestamp;
            reward = amount.mul(till.sub(since)).mul(percent).div(_pools.time).div(100);
            // reward = amount.mul(end.sub(since)).mul(percent).div(_pools.time).div(100);
            reward = reward.sub(stk.withdrawnRoi[index]);
        }
        else{
            reward = 0;
        }
        return reward;
    }
    
    // Withdraw ROI 
    function withdrawRoi(uint index) public {
        address rec = msg.sender;
        Stake storage stk = user[rec];
        require(stk.status[index] == true, "User has not staked or has unstaked");
        uint amount = withdrawable(rec, index);
         
        require(token.balanceOf(contractAddr) >= amount, "Insufficient balance on contract");
        stk.withdrawnRoi[index] = stk.withdrawnRoi[index].add(amount);
        token.transfer(rec, amount);
    }
    
    /**
    * Unstake function   
    */
    function unstake(uint index) public {
        address receiver = msg.sender;
        Stake storage stk = user[receiver];
        require(stk.amounts[index] != 0, "Not staked or already unstaked");
        uint poolId = stk.pool[index];
        uint timeDiff = block.timestamp.sub(stk.stakedAt[index]);
        uint amount = stk.amounts[index].add(withdrawable(receiver, index)).sub(stk.withdrawnRoi[index]);
        
        if(poolId == 1){
            if(timeDiff < 180 days){
                revert('Unstake time not reached');
            }
        }
        if(poolId == 2){
            if(timeDiff < 365 days){
                revert('Unstake time not reached');
            }
        }
        if(poolId == 3){
            if(timeDiff < 545 days){
                revert('Unstake time not reached');
            }
        }
        if(poolId == 4){
            if(timeDiff < 730 days){
                revert('Unstake time not reached');
            }
            poolFourCount--;
        }
        
        require(token.balanceOf(contractAddr) >= amount, "Insufficient balance on contract");
        token.transfer(receiver, amount);
        userStakeNum[receiver] -= 1;
        stk.status[index] = false;
        delete stk.amounts[index];
        emit Unstaked(receiver, amount);
    }

    // View user details
    function details(address addr) public view returns(uint[] memory amount, uint[] memory earnedAmt, uint[] memory time, bool[] memory stat, uint[] memory pool) {
        Stake storage stk = user[addr];
        uint length = stk.amounts.length;
        amount = new uint[](length);
        earnedAmt = new uint[](length);
        time = new uint[](length);
        stat = new bool[](length);
        pool = new uint[](length);
        
        for(uint i = 0; i < length; i++){
            amount[i] = stk.amounts[i];
            earnedAmt[i] = withdrawable(addr, i);
            time[i] = stk.stakedAt[i];
            stat[i] = stk.status[i];
            pool[i] = stk.pool[i];
        }
        return (amount, earnedAmt, time, stat, pool);
    }
    
    // View owner
    function getOwner() public view returns (address) {
        return owner;
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