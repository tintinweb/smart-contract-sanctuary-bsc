/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

    IBEP20 public _token;

    address public owner;
    uint256 private dev_fee = 7500000000000;
    uint256 private owner_fee = 3000000000000;
    uint256 private daily_percent = 2500000000000;
    uint256 private minute_percent = 1736111100;
    uint256 private ref_percent = 3000000000000;
    uint256 private percent = 100000000000000;
    
    modifier onlyOwner() {
        require(msg.sender == owner, 'Not onwer');
        _;
    }

    modifier checkAllowance(uint256 amount) {
        require(_token.allowance(msg.sender, address(this)) >= amount, "Allowance Error");
        _;
    }

    constructor(address token) {
        owner = msg.sender;
        _token = IBEP20(token);
    }

    function userDeposit(address referral, uint256 _amount) public checkAllowance(_amount) {
        require(_amount > 0, 'Insufficinet value');
        _token.transferFrom(msg.sender, address(this), _amount);
        uint256 value = _amount;
        // send fee to owner
        uint256 fee = value.mul(owner_fee).div(percent);
        _token.transfer(owner, fee);
        value = value - fee;
        // save information 
        depositStatus memory temp = depositStatus(value, block.timestamp, block.timestamp);
        users[msg.sender].deposits.push(temp);
        users[msg.sender].total_deposit = users[msg.sender].total_deposit.add(value);

        // // if user enter with referral link, save referral data        
        if(referral != msg.sender) {
            value = _amount.mul(ref_percent).div(percent);
            referralStatus memory temp1 = referralStatus(value, msg.sender);
            users[referral].refs.push(temp1);
            users[referral].total_ref = users[referral].total_ref.add(value);
        }
    }

    function withdrawReward() public {
        uint256 total_amount = calcReward(msg.sender);
        uint256 balance = _token.balanceOf(address(this));
        require(balance >= total_amount, "Pool has not enough crypto");
        removeAfterReward(msg.sender);
        _token.transfer(msg.sender, total_amount);
    }

    function removeAfterReward(address to) internal {
        uint256 count = getUserDepositCount(to);
        userInfo storage user = users[to];
        uint256 current = block.timestamp;
        for(uint256 i = 0 ; i < count ; i ++) {
            user.deposits[i].reward_date = current;
        }
    }

    function withdrawDeposit(uint256 amount) public {
        uint256 total_amount = calcWithdraw(msg.sender);
        require(amount <= total_amount, "Invalid Input");
        require(_token.balanceOf(address(this)) >= amount, "Pool has not enough crypto");
        removeAfterWithdraw(msg.sender, amount);
        uint256 fee = amount.mul(owner_fee).div(percent);
        _token.transfer(owner, fee);
        amount = amount - fee;
        _token.transfer(msg.sender, amount);
    }

    function withdrawBUSD(address to, uint256 amount) external onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        if (amount > balance) {
            _token.transfer(to, balance);
        } else {
            _token.transfer(to, amount);
        }
    }

    function depositBUSD(uint256 amount) external onlyOwner {
        require(amount > 0, "you can deposit more than 0 snt");

        uint256 balance = _token.balanceOf(msg.sender);
        uint256 allowance = _token.allowance(msg.sender, address(this));

        require(balance >= amount && allowance >= amount, "Insufficient balance or allowance");

        _token.transferFrom(msg.sender, address(this), amount);
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
        require(_token.balanceOf(address(this)) >= user.total_ref, "Pool has not enough crypto");
        _token.transfer(msg.sender, user.total_ref);
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

    function setOwnerFee(uint256 fee) public onlyOwner {
        owner_fee = fee;
    }

    function setOwner(address to) public onlyOwner {
        owner = to;
    }

    function setRefFee(uint256 fee) public onlyOwner {
        ref_percent = fee;
    }

    function setDailyFee(uint256 fee) public onlyOwner {
        daily_percent = fee;
    }

    function setMinuteFee(uint256 fee) public onlyOwner {
        minute_percent = fee;
    }
}