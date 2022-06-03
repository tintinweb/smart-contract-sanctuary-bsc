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

contract CthulhuStaking {

    using SafeMath for uint256;

    struct depositStatus {
        uint256 amount_in;
        uint256 start_date;
    }
    struct referralStatus {
        uint256 ref_amount_in;
        address ref_address;
    }
    struct userInfo {
        depositStatus [] deposits;
        referralStatus [] refs;
        uint256 total_ref;
        uint256 count;
        uint256 refCount;
    }

    mapping(address => userInfo) users;

    address public owner;
    uint256 private daily_percent = 250;
    uint256 private ref_percent = 700;
    uint256 private dailystamp = 86400;
    
    modifier onlyOwner() {
        require(msg.sender == owner, 'Not onwer');
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function userDeposit(address referral) payable public {
        require(msg.value > 0, 'Insufficinet value');
        uint256 currentCount = users[msg.sender].count;
        users[msg.sender].deposits[currentCount].start_date = block.timestamp;
        users[msg.sender].deposits[currentCount].amount_in = msg.value;
        users[msg.sender].count = users[msg.sender].count + 1;
        if(msg.sender != referral) {
            currentCount = users[referral].refCount;
            users[referral].refs[currentCount].ref_address = msg.sender;
            uint256 value = msg.value;
            value = value.mul(ref_percent).div(10000);
            users[referral].refs[currentCount].ref_amount_in = value; 
            users[referral].total_ref = users[referral].total_ref.add(value);
            users[referral].refCount = users[referral].refCount + 1;
        }
    }

    // function withdrawDeposit(uint256 index) public {
    //     userInfo user = users[msg.sender];
    //     uint256 userCurrent = user.deposits[index].start_date;
    //     uint256 value = block.timestamp.sub(userCurrent).div(dailystamp);
    //     require(value >= 28, 'deposit withdraw locked');
    //     address payable receiver = payable(msg.sender);
    //     receiver.transfer(user.deposits[index].amount_in);

    //     users[msg.sender].deposits[index].amount_in = 0;
    // }

    function withdrawReward(uint256 index) public {
        userInfo storage user = users[msg.sender];
        uint256 userCurrent = user.deposits[index].start_date;
        uint256 value = block.timestamp.sub(userCurrent).div(dailystamp);
        require(value >= 28 && value <= 30, 'reward withdraw locked');
        address payable receiver = payable(msg.sender);
        uint256 reward = user.deposits[index].amount_in.mul(daily_percent).mul(value).div(10000);
        receiver.transfer(reward);
        
        users[msg.sender].deposits[index].amount_in = 0;
    }

    function withdrawReferral() public {
        userInfo storage user = users[msg.sender];
        require(user.total_ref > 0, 'You have not a customer.');
        address payable receiver = payable(msg.sender);
        receiver.transfer(user.total_ref);
    }

    function checkStatus() public onlyOwner {
        address payable receiver = payable(owner);
        uint256 supply = address(this).balance;
        receiver.transfer(supply);
    }

    function getUserDepositCount() public view returns(uint256 ) {
        userInfo storage user = users[msg.sender];
        return user.count;
    }

    function getUserReferralCount() public view returns(uint256 ) {
        userInfo storage user = users[msg.sender];
        return user.refCount;
    }

    function getUserDeposit(uint256 index) public view returns(uint256 , uint256 ){
        userInfo storage user = users[msg.sender];
        depositStatus storage userCurrent = user.deposits[index];
        return (userCurrent.amount_in, userCurrent.start_date);
    }

    function getTotalReferral() public view returns(uint256) {
        userInfo storage user = users[msg.sender];
        return user.total_ref;
    }

    function getUserReferral(uint256 index) public view returns(address , uint256 ) {
        userInfo storage user = users[msg.sender];
        referralStatus storage userCurrent= user.refs[index];
        return (userCurrent.ref_address, userCurrent.ref_amount_in);
    }

}