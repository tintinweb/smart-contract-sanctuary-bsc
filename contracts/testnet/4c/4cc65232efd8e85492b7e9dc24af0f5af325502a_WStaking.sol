/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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


contract WStaking {
    using SafeMath for uint256;

    struct Xei3 { 
        uint256 duration;
        uint256 interest;
   }

    struct Staking { 
        uint256 begin;
        uint256 finish;
        uint256 amount;
        uint256 interest;
        uint256 dailyReward;
        uint256 reward;
        uint256 total;
   }

    mapping(string => Xei3) private _duration;

    address private _owner;
    address private _developer;

    address private _tokenStakeAddress;

    mapping(address => uint256) private _tokenSell;

    uint256 private _investers;
    uint256 private _totalStaking;
    uint256 private _totalReward;

    uint256 private _rate;
    uint256 private _bonusRate = 1;
    uint256 private _minStake = 10000000000000000000000;

    mapping(address => uint256) private _totalInvesterStaking;
    mapping(address => Staking[]) private _investorStaking;

    event NewStake (
        address investor,
        uint256 amount,
        uint256 finish
    );

    constructor(address owner, address developer, address tokenStake) {
        _owner = owner;
        _developer = developer;
        _tokenStakeAddress = tokenStake;

        _duration['18m'] =  Xei3(545 days, 162);
    }

    function totalInvesterStaking(address addr) public view returns (uint256) {
        return _totalInvesterStaking[addr];
    }

    function getStakeList(address addr) public view returns(Staking[] memory){
        return _investorStaking[addr];
    }

    function getStake(address addr, uint256 index) public view returns (Staking memory) {
        return _investorStaking[addr][index];
    }
    
    function totalStaking() public view returns (uint256) {
        return _totalStaking;
    }
    
    function totalReward() public view returns (uint256) {
        return _totalReward;
    }

    function duration(string calldata key) public view returns (Xei3 memory) {
        return _duration[key];
    }
       
    function rate() public view returns (uint256) {
        return _rate;
    }

    function tokenSell(address addr) public view returns (uint256) {
        return _tokenSell[addr];
    }

    function iStake(uint256 amount, string calldata dur) external {
        require(amount >= _minStake, 'Need more funds');

        if(_totalInvesterStaking[msg.sender] == 0) {
            _investers = _investers.add(1); 
        }

        Xei3 memory d = _duration[dur];
        require(d.duration > 0, 'Duration invalid');

        uint256 begin = block.timestamp;
        uint256 finish = begin.add(d.duration); 
        uint256 reward = d.interest.mul(amount / 100);
        uint256 dailyReward = reward.div(finish.sub(begin) / 1 days); 

        Staking memory stake = Staking(begin, finish, amount, d.interest, dailyReward, reward, reward.add(amount));
        _investorStaking[msg.sender].push(stake);

        _totalInvesterStaking[msg.sender] = _totalInvesterStaking[msg.sender].add(amount);
        _totalStaking = _totalStaking.add(amount);
        _totalReward = _totalReward.add(reward);

        emit NewStake(msg.sender, amount, finish);   

        IERC20(_tokenStakeAddress).transferFrom(msg.sender, address(this), amount);
    }

    function buyAndStake(address sellToken, uint256 amountBuy, string calldata dur) external {
        require(amountBuy > 0, 'Amount > 0'); 
        require(_tokenSell[sellToken] == 1, 'Token not support'); 

        uint256 amount = amountBuy.div(_rate);
        amount = amount.mul(1 ether);

        require(amount >= _minStake, 'Need more funds');

        uint256 bonus = _bonusRate.mul(amount / 100);
        amount = amount.add(bonus);

        Xei3 memory d = _duration[dur];
        require(d.duration > 0, 'Duration invalid');

        if(_totalInvesterStaking[msg.sender] == 0) {
            _investers = _investers.add(1);
        }

        uint256 begin = block.timestamp;
        uint256 finish = begin.add(d.duration); 
        uint256 reward = d.interest.mul(amount / 100);
        uint256 dailyReward = reward.div(finish.sub(begin) / 1 days); 

        Staking memory stake = Staking(begin, finish, amount, d.interest, dailyReward, reward, reward.add(amount));
        _investorStaking[msg.sender].push(stake);

        _totalInvesterStaking[msg.sender] = _totalInvesterStaking[msg.sender].add(amount);
        _totalStaking = _totalStaking.add(amount);
        _totalReward = _totalReward.add(reward);

        emit NewStake(msg.sender, amount, finish);   

        IERC20(sellToken).transferFrom(msg.sender, address(this), amountBuy);
    }

    function unstake(uint index) external {
        Staking memory stake = _investorStaking[msg.sender][index];

        require(stake.amount > 0, 'Stake invalid');
        require(block.timestamp >= stake.finish, "Stake not finished yet");

        uint256 amount = stake.amount;
      
        stake.amount = 0;
        _investorStaking[msg.sender][index] = stake;
        _totalInvesterStaking[msg.sender] = _totalInvesterStaking[msg.sender].sub(amount);
        _totalStaking = _totalStaking.sub(amount);
        
        stake.reward = stake.interest * (amount / 100);
        amount = amount.add(stake.reward);

        IERC20(_tokenStakeAddress).transfer(msg.sender, amount);
    }

    function setRate(uint256 price) external {
        require(msg.sender == _developer, 'Permission denied');
        _rate = price;
    }

    function setMinStake(uint256 min) external {
        require(msg.sender == _developer, 'Permission denied');
        _minStake = min;
    }

    function setDuration(string calldata key, uint256 dur, uint256 interest) external {
        require(msg.sender == _developer, 'Permission denied');
        _duration[key] = Xei3(dur, interest);
    }

    function setTokenBuy(address token, uint256 enable) external {
        require(msg.sender == _developer, 'Permission denied');
        _tokenSell[token] = enable;
    }
    
    function setTokenStakeAddress(address token) external {
        require(msg.sender == _developer, 'Permission denied');
        _tokenStakeAddress = token;
    }

    function setBonusRate(uint256 bonus) external {
        require(msg.sender == _developer, 'Permission denied');
        _bonusRate = bonus;
    }

   function withdraw(address token, address addr, uint256 amount) external {
        require(msg.sender == _owner, 'Not owner');
        require(token != _tokenStakeAddress, 'Not token staking');

        IERC20(token).transfer(addr, amount);
    }
     
    function changeOwner(address _newOwner) external {
        require(msg.sender == _owner, 'Not owner');
        _owner = _newOwner;
    }
}