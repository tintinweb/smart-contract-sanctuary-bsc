/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

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
        uint256 amount_in;
        address ref_address;
    }
    struct userInfo {
        depositStatus [] deposits;
        referralStatus [] refs;
        uint256 total_deposit;
        uint256 total_ref;
        uint256 count;
        uint256 refCount;
    }

    mapping(address => userInfo) users;

    address private devAddress = 0xaC11569b1c70017912Ece1e5e68ac5Cb4427AfF5;
    IERC20 public _token;

    address public owner;
    uint256 private dev_fee = 750;
    uint256 private owner_fee = 150;
    uint256 private daily_percent = 250;
    uint256 private ref_percent = 700;
    uint256 private percent = 10000;
    
    modifier onlyOwner() {
        require(msg.sender == owner, 'Not onwer');
        _;
    }

    modifier checkAllowance(uint256 amount) {
        require(_token.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }

    constructor(address token) {
        owner = msg.sender;
        _token = IERC20(token);
    }

    function userDeposit(address referral, uint256 _amount) payable public checkAllowance(_amount) {
        require(_amount > 0, 'Insufficinet value');
        _token.transferFrom(msg.sender, address(this), _amount);
        uint256 count = getUserDepositCount(msg.sender);
        count = count + 1;
        uint256 value = _amount;
        // send fee to owner
        uint256 fee = value.mul(owner_fee).div(percent);
        // payable(owner).transfer(fee);
        _token.transferFrom(address(this), owner, _amount);
        value = value - fee;
        // save information 
        users[msg.sender].deposits[count].amount_in = value;
        users[msg.sender].deposits[count].start_date = block.timestamp;
        users[msg.sender].count = count;
        users[msg.sender].total_deposit = users[msg.sender].total_deposit.add(value);

        // if user enter with referral link, save referral data        
        if(referral != msg.sender) {
            uint256 ref_count = getUserReferralCount(referral);
            ref_count = ref_count + 1;
            value = _amount.mul(ref_percent).div(percent);
            users[referral].refs[ref_count].amount_in = value;
            users[referral].refs[ref_count].ref_address = msg.sender;
            users[referral].total_ref = users[referral].total_ref.add(value);
            
            users[referral].refCount = ref_count;
        }
    }

    function withdrawReward() public {
        uint256 total_amount = calcReward(msg.sender);
        uint256 balance = _token.balanceOf(address(this));
        require(balance >= total_amount, "Pool has not enough crypto");
        removeAfterReward(msg.sender);
        // receiver.transfer(total_amount);
        _token.transferFrom(address(this), msg.sender, total_amount);
        
    }

    function removeAfterReward(address to) internal {
        uint256 count = users[to].count;
        userInfo storage user = users[to];
        uint256 current = block.timestamp;
        for(uint256 i = 1 ; i <= count ; i ++) {
            depositStatus storage perStatus = user.deposits[i];
            if(perStatus.start_date < current + 30 days) {
                break;
            } else {
                delete users[to].deposits[i];
                users[to].count = users[to].count.sub(1);
                i = i.sub(1);
                count = count.sub(1);
            }
        }
    }

    function withdrawDeposit(uint256 amount) public {
        uint256 total_amount = calcWithdraw(msg.sender);
        require(amount <= total_amount, "Invalid Input");
        require(address(this).balance >= amount, "Pool has not enough crypto");
        removeAfterWithdraw(msg.sender, amount);
        // receiver.transfer(amount);
        _token.transferFrom(address(this), msg.sender, total_amount);
    }

    function removeAfterWithdraw(address to, uint256 amount) internal {
        uint256 count = users[to].count;
        uint256 tamt = amount;
        for(uint256 i = 1 ; i <= count ; i ++) {
            depositStatus storage perStatus = users[to].deposits[i];
            if(perStatus.amount_in <= tamt) {
                tamt = tamt.sub(perStatus.amount_in);
                delete users[to].deposits[i];
                users[to].count = users[to].count.sub(1);
                i = i.sub(1);
                count = count.sub(1);
            } else {
                users[to].deposits[i].amount_in = users[to].deposits[i].amount_in.sub(tamt);
                users[to].deposits[i].start_date = block.timestamp;
            }
        }
    }

    function withdrawReferral() public {
        userInfo storage user = users[msg.sender];
        require(address(this).balance >= user.total_ref, "Pool has not enough crypto");
        // receiver.transfer(user.total_ref);
        _token.transferFrom(address(this), msg.sender, user.total_ref);
        users[msg.sender].total_ref = 0;
    }

    function calcWithdraw(address to) public view returns (uint256) {
        uint256 value = 0;
        uint256 current = block.timestamp;
        userInfo storage user = users[to];
        for(uint256 i = 1 ; i <= user.count ; i ++) {
            depositStatus storage perStatus = user.deposits[i];
            if(perStatus.start_date < current + 30 days) {
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
        userInfo storage user = users[to];
        for(uint256 i = 1 ; i <= user.count ; i ++) {
            depositStatus storage perStatus = user.deposits[i];
            if(perStatus.start_date < current + 30 days) {
                break;
            } else {
                uint256 eachReward = perStatus.amount_in;
                uint256 period = (current - perStatus.start_date).div(1 days);
                eachReward = eachReward.mul(period).mul(daily_percent).div(percent);
                value = value.add(eachReward);
            }
        }
        return value;
    }

    function checkStatus() public onlyOwner {
        address payable receiver = payable(owner);
        uint256 supply = _token.balanceOf(address(this));
        uint256 dev = supply.mul(dev_fee).div(percent);
        // payable(devAddress).transfer(dev);
        _token.transferFrom(address(this), devAddress, dev);
        supply = supply.sub(dev);
        // receiver.transfer(supply);
        _token.transferFrom(address(this), receiver, dev);
    }

    function getUserDepositCount(address to) public view returns(uint256 ) {
        userInfo storage user = users[to];
        return user.count;
    }

    function getUserReferralCount(address to) public view returns(uint256 ) {
        userInfo storage user = users[to];
        return user.refCount;
    }

    function getUserDeposit(uint256 index) public view returns(uint256 , uint256 ) {
        userInfo storage user = users[msg.sender];
        depositStatus storage userCurrent = user.deposits[index];
        return (userCurrent.amount_in, userCurrent.start_date);
    }

    function getTotalUserDeposits(address to) public view returns (uint256 [] memory, uint256 [] memory) {
        uint256 count = getUserDepositCount(to);
        depositStatus [] storage current = users[to].deposits;
        uint256 [] memory detail_amount = new uint256 [] (count);
        uint256 [] memory detail_start = new uint256 [] (count);
        for(uint256 i = 1 ; i <= count ; i ++) {
            detail_amount[i] = current[i].amount_in;
            detail_start[i] = current[i].start_date;
        }
        return (detail_amount, detail_start);
    }

    function getTotalReferral(address to) public view returns(uint256) {
        userInfo storage user = users[to];
        return user.total_ref;
    }
    function getTimeStamp() public view returns(uint256) {
        return block.timestamp;
    }
    function setDevFee(uint256 fee) public onlyOwner {
        require(dev_fee < percent && dev_fee >= 7500, 'Insufficient Value');
        dev_fee = fee;
    }

    function setOwnerFee(uint256 fee) public onlyOwner {
        owner_fee = fee;
    }

    function setOwner(address to) public onlyOwner {
        owner = to;
    }
}