/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

contract CthulhuStaking_Bnb {

    using SafeMath for uint256;

    struct depositStatus { 
        uint256 amount_in;
        uint256 start_date;
        uint256 reward_date;
    }
    struct referralStatus {
        uint256 amount_in;
        address ref_address;
    }
    struct userInfo {
        depositStatus [] deposits;
        referralStatus [] refs;
        uint256 total_deposit;
        uint256 total_ref;
    }

    mapping(address => userInfo) users;

    address public owner;
    uint256 private owner_fee = 3000000000000;
    uint256 private daily_percent = 2500000000000;
    uint256 private max_percent = 5000000000000;
    uint256 private minute_percent = 1736111100;
    uint256 private ref_percent = 3000000000000;
    uint256 private percent = 100000000000000;
    uint256 internal constant INIT = 1658674800;
    
    function contractStarted() internal view returns (bool){
        return block.timestamp >= INIT;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Not onwer');
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function userDeposit(address referral) public payable{
        require(contractStarted(), "Contract not started yet.");
        require(msg.value > 0, 'Insufficinet value');
        uint256 value = msg.value;
        // send fee to owner
        uint256 fee = value.mul(owner_fee).div(percent);
        payable(address(owner)).transfer(fee);
        value = value - fee;
        // save information 
        depositStatus memory temp = depositStatus(value, block.timestamp, block.timestamp);
        users[msg.sender].deposits.push(temp);
        users[msg.sender].total_deposit = users[msg.sender].total_deposit.add(value);

        // // if user enter with referral link, save referral data        
        if(referral != msg.sender) {
            value = msg.value.mul(ref_percent).div(percent);
            referralStatus memory temp1 = referralStatus(value, msg.sender);
            users[referral].refs.push(temp1);
            users[referral].total_ref = users[referral].total_ref.add(value);
        }
    }

    function withdrawReward() public {
        uint256 total_amount = calcReward(msg.sender);
        require(address(this).balance >= total_amount, "Pool has not enough crypto");
        removeAfterReward(msg.sender);
        payable(address(msg.sender)).transfer(total_amount);
    }

    function removeAfterReward(address to) internal {
        uint256 count = getUserDepositCount(to);
        userInfo storage user = users[to];
        uint256 current = block.timestamp;
        for(uint256 i = 0 ; i < count ; i ++) {
            user.deposits[i].reward_date = current;
        }
    }

    function withdrawDeposit(uint256 amount) public{
        uint256 total_amount = calcWithdraw(msg.sender);
        require(amount <= total_amount, "Invalid Input");
        require(address(this).balance >= amount, "Pool has not enough crypto");
        removeAfterWithdraw(msg.sender, amount);
        uint256 fee = amount.mul(owner_fee).div(percent);
        payable(address(owner)).transfer(fee);
        amount = amount - fee;
        payable(address(msg.sender)).transfer(amount);
    }

    function withdrawEther(address to, uint256 amount) external onlyOwner {
        uint256 balance = address(this).balance;
        if (amount > balance) {
            payable(address(to)).transfer(balance);
        } else {
            payable(address(to)).transfer(amount);
        }
    }

    function depositEther() external payable onlyOwner {
        require(msg.value > 0, "you can deposit more than 0 snt");
        uint256 balance = address(msg.sender).balance;
        require(balance >= msg.value, "Insufficient balance or allowance");
    }

    function removeAfterWithdraw(address to, uint256 amount) internal {
        uint256 count = getUserDepositCount(to);
        uint256 tamt = amount;
        for(uint256 i = 0 ; i < count ; i ++) {
            depositStatus storage perStatus = users[to].deposits[i];
            if(perStatus.amount_in <= tamt) {
                tamt = tamt.sub(perStatus.amount_in);
                delete users[to].deposits[i];
                i = i.sub(1);
                count = count.sub(1);
            } else {
                users[to].deposits[i].amount_in = users[to].deposits[i].amount_in.sub(tamt);
                users[to].deposits[i].start_date = block.timestamp;
                break;
            }
        }
    }

    function withdrawReferral() public {
        userInfo storage user = users[msg.sender];
        require(address(this).balance >= user.total_ref, "Pool has not enough crypto");
        payable(address(msg.sender)).transfer(user.total_ref);
        users[msg.sender].total_ref = 0;
    }

    function calcWithdraw(address to) public view returns (uint256) {
        uint256 value = 0;
        uint256 current = block.timestamp;
        uint256 count = getUserDepositCount(to);
        userInfo storage user = users[to];
        for(uint256 i = 0 ; i < count ; i ++) {
            depositStatus storage perStatus = user.deposits[i];
            if(perStatus.start_date + 28 days > current) {
                break;
            } else {
                uint256 eachReward = perStatus.amount_in;
                value = value.add(eachReward);
            }
        }
        return value;
    }

    function calcReward(address to) public view returns (uint256) {
        uint256 value = 0;
        uint256 current = block.timestamp;
        uint256 count = getUserDepositCount(to);
        userInfo storage user = users[to];
        for(uint256 i = 0 ; i < count ; i ++) {
            depositStatus storage perStatus = user.deposits[i];
            uint256 eachReward = perStatus.amount_in;
            uint256 period = (current - perStatus.reward_date).div(1 minutes);
            eachReward = eachReward.mul(period).mul(minute_percent).div(percent);
            value = value.add(eachReward);
        }
        return value;
    }

    function getUserDepositCount(address to) public view returns(uint256 ) {
        userInfo storage user = users[to];
        return user.deposits.length;
    }

    function getUserReferralCount(address to) public view returns(uint256 ) {
        userInfo storage user = users[to];
        return user.refs.length;
    }

    function getUserDeposit(uint256 index) public view returns(uint256 , uint256 ) {
        userInfo storage user = users[msg.sender];
        depositStatus storage userCurrent = user.deposits[index];
        return (userCurrent.amount_in, userCurrent.start_date);
    }

    function getTotalReferral(address to) public view returns(uint256) {
        userInfo storage user = users[to];
        return user.total_ref;
    }

    function getTotalDeposit(address to) public view returns(uint256) {
        userInfo storage user = users[to];
        return user.total_deposit;
    }

    function checkFeePercent(uint256 fee) internal view returns (bool){
        return fee <= max_percent;
    }
    function setOwnerFee(uint256 fee) public onlyOwner {
        require(checkFeePercent(fee), "you cant set it more than 5%");
        owner_fee = fee;
    }

    function setOwner(address to) public onlyOwner {
        owner = to;
    }

    function setRefFee(uint256 fee) public onlyOwner {
        require(checkFeePercent(fee), "you cant set it more than 5%");
        ref_percent = fee;
    }

    function setDailyFee(uint256 fee) public onlyOwner {
        require(checkFeePercent(fee), "you cant set it more than 5%");
        daily_percent = fee;
    }

    function setMinuteFee(uint256 fee) public onlyOwner {
        require(checkFeePercent(fee), "you cant set it more than 5%");
        minute_percent = fee;
    }
}