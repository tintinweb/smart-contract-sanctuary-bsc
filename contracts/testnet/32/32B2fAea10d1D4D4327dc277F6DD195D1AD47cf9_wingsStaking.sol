//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract wingsStaking is Ownable {
    using SafeMath for uint256;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 duration;
    }

    IERC20 public REWARD;
    IERC20 public STAKING;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;

    mapping(address => Share) public shares;
    mapping(address => Stake) public stakeDetails;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;

    uint256 public totalStaking;
    uint256 public rewardPerShare;

    uint256 public penaltyPercentage = 30;

    uint256 public minTokenPerShare = 2 * (10**9);

    uint256 public _7daysApr;
    uint256 public _14DaysApr;
    uint256 public _30DaysApr;
    uint256 public _60daysApr;
    uint256 public _unlimitedDaysApr;

    uint256 public _7daysApy;
    uint256 public _14DaysApy;
    uint256 public _30DaysApy;
    uint256 public _60daysApy;
    uint256 public _unlimitedDaysApy;

    uint256 public _max7daysApy = 50;
    uint256 public _max14DaysApy = 60;
    uint256 public _max30DaysApy = 70;
    uint256 public _max60daysApy = 80;
    uint256 public _maxUnlimitedDaysApy = 30;

    uint256 public _min7daysApy = 10;
    uint256 public _min14DaysApy = 20;
    uint256 public _min30DaysApy = 30;
    uint256 public _min60daysApy = 40;
    uint256 public _minUnlimitedDaysApy = 5;

    uint256 public minStakeAmount = 1 * (10**9);

    uint256 secondsForDay = 86400;
    uint256 currentIndex;

    event NewStake(address staker, uint256 amount, uint256 time);
    event WithdrawAndExit(address staker, uint256 amount);
    event EmergencyWithdraw(address staker, uint256 amount);

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor() {
        _token = msg.sender;
        REWARD = IERC20(0xD08F70d859463494dbBCAE7D41843290477B4932);
        STAKING = IERC20(0xD08F70d859463494dbBCAE7D41843290477B4932);
    }

    receive() external payable {}

    function purge(address receiver) external onlyOwner {
        uint256 balance = REWARD.balanceOf(address(this));
        REWARD.transfer(receiver, balance);
    }

    function changePenaltyPercentage(uint256 _percentage) external onlyOwner {
        penaltyPercentage = _percentage;
    }

    function changeMinimumStakeAmount(uint256 _amount) external onlyOwner {
        minStakeAmount = _amount;
    }

    function changeMinimumtokenPerShare(uint256 _amount) external onlyOwner {
        minTokenPerShare = _amount;
    }

    function changeMaxApy(
        uint256 _7days,
        uint256 _14days,
        uint256 _30days,
        uint256 _60days,
        uint256 unlimitedDays
    ) external onlyOwner {
        _max7daysApy = _7days;
        _max14DaysApy = _14days;
        _max30DaysApy = _30days;
        _max60daysApy = _60days;
        _maxUnlimitedDaysApy = unlimitedDays;
    }

    function changeMinApy(
        uint256 _7days,
        uint256 _14days,
        uint256 _30days,
        uint256 _60days,
        uint256 unlimitedDays
    ) external onlyOwner {
        _min7daysApy = _7days;
        _min14DaysApy = _14days;
        _min30DaysApy = _30days;
        _min60daysApy = _60days;
        _minUnlimitedDaysApy = unlimitedDays;
    }

    function setShare(
        address shareholder,
        uint256 amount,
        uint256 time
    ) internal {
        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            totalShares = totalShares.sub(shares[shareholder].amount);
            removeShareholder(shareholder);
        }
        uint256 totalShareAmount = 0;
        if (time > 0) {
            totalShareAmount = amount.mul(time);
        } else {
            totalShareAmount = amount;
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(
            totalShareAmount
        );
        shares[shareholder].amount = totalShareAmount;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return shareholders.length;
    }

    function getShareHoldersList() external view returns (address[] memory) {
        return shareholders;
    }

    function totalDistributedRewards() external view returns (uint256) {
        return totalDistributed;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    // staking

    function newStake(uint256 amount, uint256 time) public {
        require(
            stakeDetails[msg.sender].amount == 0,
            "You Already have another running staking"
        );
        require(
            amount >= minStakeAmount,
            "You should stake more than minimum balance"
        );
        require(
            STAKING.balanceOf(msg.sender) >= amount,
            "You don't have enough balance"
        );
        // set time as 0 for unlimited time staking
        require(
            time == 7 || time == 14 || time == 30 || time == 60 || time == 0,
            "Invalid time"
        );
        STAKING.transferFrom(address(msg.sender), address(this), amount);
        totalStaking = totalStaking + amount;
        setShare(msg.sender, amount, time);
        // stake time in seconds
        uint256 stakeTimeInSeconds = time.mul(secondsForDay);
        // set stake details
        stakeDetails[msg.sender].amount = amount;
        stakeDetails[msg.sender].startTime = block.timestamp;
        stakeDetails[msg.sender].endTime = block.timestamp.add(
            stakeTimeInSeconds
        );
        stakeDetails[msg.sender].duration = time;

        emit NewStake(msg.sender, amount, time);
        // update pool
        updatePool();
    }

    // remove
    function withdrawAndExit() public {
        require(
            stakeDetails[msg.sender].amount > 0,
            "You don't have any staking in this pool"
        );
        require(
            stakeDetails[msg.sender].endTime <= block.timestamp,
            "You can not use normal withdraw"
        );
        updatePool();
        // get staked amount
        uint256 amountToSend = stakeDetails[msg.sender].amount;
        // calculate reward token
        uint256 rewardTokens = 0;
        if (stakeDetails[msg.sender].duration == 7) {
            // calculate yearly tokens values
            uint256 tokensPerYear = _7daysApy
                .mul(stakeDetails[msg.sender].amount)
                .div(100);
            // calculate tokens per time
            rewardTokens = tokensPerYear.div(secondsForDay.mul(365)).mul(
                secondsForDay.mul(7)
            );
        } else if (stakeDetails[msg.sender].duration == 14) {
            // calculate yearly tokens values
            uint256 tokensPerYear = _14DaysApy
                .mul(stakeDetails[msg.sender].amount)
                .div(100);
            // calculate tokens per time
            rewardTokens = tokensPerYear.div(secondsForDay.mul(365)).mul(
                secondsForDay.mul(14)
            );
        } else if (stakeDetails[msg.sender].duration == 30) {
            // calculate yearly tokens values
            uint256 tokensPerYear = _30DaysApy
                .mul(stakeDetails[msg.sender].amount)
                .div(100);
            // calculate tokens per time
            rewardTokens = tokensPerYear.div(secondsForDay.mul(365)).mul(
                secondsForDay.mul(30)
            );
        } else if (stakeDetails[msg.sender].duration == 60) {
            // calculate yearly tokens values
            uint256 tokensPerYear = _60daysApy
                .mul(stakeDetails[msg.sender].amount)
                .div(100);
            // calculate tokens per time
            rewardTokens = tokensPerYear.div(secondsForDay.mul(365)).mul(
                secondsForDay.mul(60)
            );
        } else {
            // calculate yearly tokens values
            uint256 tokensPerYear = _unlimitedDaysApy
                .mul(stakeDetails[msg.sender].amount)
                .div(100);
            // calculate tokens per time
            rewardTokens = tokensPerYear.div(secondsForDay.mul(365)).mul(
                block.timestamp.sub(stakeDetails[msg.sender].startTime)
            );
        }
        totalDistributed = totalDistributed.add(rewardTokens);
        // total amount to send user
        amountToSend = amountToSend.add(rewardTokens);

        require(
            REWARD.balanceOf(address(this)) >= amountToSend,
            "No enough tokens in the pool"
        );

        setShare(msg.sender, 0, 0);

        totalStaking = totalStaking.sub(stakeDetails[msg.sender].amount);

        // reset stake details
        stakeDetails[msg.sender].amount = 0;
        stakeDetails[msg.sender].startTime = 0;
        stakeDetails[msg.sender].endTime = 0;
        // send tokens
        REWARD.transfer(msg.sender, amountToSend);

        emit WithdrawAndExit(msg.sender, amountToSend);
        updatePool();
    }

    function emergencyWithdraw() public {
        require(
            stakeDetails[msg.sender].amount > 0,
            "You don't have any staking in this pool"
        );
        require(
            stakeDetails[msg.sender].endTime > block.timestamp,
            "You can not use emergency withdraw"
        );
        // get staked amount
        uint256 amountToSend = stakeDetails[msg.sender].amount;
        // calculate reward token
        uint256 rewardTokens = 0;
        if (stakeDetails[msg.sender].duration == 7) {
            // calculate yearly tokens values
            uint256 tokensPerYear = _7daysApy
                .mul(stakeDetails[msg.sender].amount)
                .div(100);
            // calculate tokens per time
            rewardTokens = tokensPerYear.div(secondsForDay.mul(365)).mul(
                block.timestamp.sub(stakeDetails[msg.sender].startTime)
            );
        } else if (stakeDetails[msg.sender].duration == 14) {
            // calculate yearly tokens values
            uint256 tokensPerYear = _14DaysApy
                .mul(stakeDetails[msg.sender].amount)
                .div(100);
            // calculate tokens per time
            rewardTokens = tokensPerYear.div(secondsForDay.mul(365)).mul(
                block.timestamp.sub(stakeDetails[msg.sender].startTime)
            );
        } else if (stakeDetails[msg.sender].duration == 30) {
            // calculate yearly tokens values
            uint256 tokensPerYear = _30DaysApy
                .mul(stakeDetails[msg.sender].amount)
                .div(100);
            // calculate tokens per time
            rewardTokens = tokensPerYear.div(secondsForDay.mul(365)).mul(
                block.timestamp.sub(stakeDetails[msg.sender].startTime)
            );
        } else if (stakeDetails[msg.sender].duration == 60) {
            // calculate yearly tokens values
            uint256 tokensPerYear = _60daysApy
                .mul(stakeDetails[msg.sender].amount)
                .div(100);
            // calculate tokens per time
            rewardTokens = tokensPerYear.div(secondsForDay.mul(365)).mul(
                block.timestamp.sub(stakeDetails[msg.sender].startTime)
            );
        }
        uint256 penaltyAmount = rewardTokens.mul(penaltyPercentage).div(100);

        amountToSend = amountToSend.add(rewardTokens).sub(penaltyAmount);

        require(
            REWARD.balanceOf(address(this)) >= amountToSend,
            "No enough tokens in the pool"
        );

        setShare(msg.sender, 0, 0);

        totalStaking = totalStaking.sub(stakeDetails[msg.sender].amount);

        // reset stake details
        stakeDetails[msg.sender].amount = 0;
        stakeDetails[msg.sender].startTime = 0;
        stakeDetails[msg.sender].endTime = 0;

        // send tokens
        REWARD.transfer(msg.sender, amountToSend);

        emit EmergencyWithdraw(msg.sender, amountToSend);
        updatePool();
    }

    // update stake pool
    function updatePool() public {
        uint256 currentTokenBalance = REWARD.balanceOf(address(this));
        totalDividends = currentTokenBalance.sub(totalStaking);
        if (totalShares > 0) {
            rewardPerShare = totalDividends.div(totalShares);
            updateApr();
            updateApy();
        } else {
            rewardPerShare = minTokenPerShare;
            updateApr();
            updateApy();
        }
    }

    function getUserInfo(address _wallet)
        public
        view
        returns (
            uint256 _amount,
            uint256 _startTime,
            uint256 _endTime
        )
    {
        _amount = stakeDetails[_wallet].amount;
        _startTime = stakeDetails[_wallet].startTime;
        _endTime = stakeDetails[_wallet].endTime;
    }

    function updateApr() internal {
        _7daysApr = rewardPerShare.div(100).mul(7);
        _14DaysApr = rewardPerShare.div(100).mul(14);
        _30DaysApr = rewardPerShare.div(100).mul(30);
        _60daysApr = rewardPerShare.div(100).mul(60);
        _unlimitedDaysApr = rewardPerShare.div(100);
    }

    function updateApy() internal {
        _7daysApy = ((_7daysApr.div(60)).add(1)).mul(60).sub(1);
        if (_7daysApy > _max7daysApy) {
            _7daysApy = _max7daysApy;
        } else if (_7daysApy < _min7daysApy) {
            _7daysApy = _min7daysApy;
        }
        _14DaysApy = ((_14DaysApr.div(60)).add(1)).mul(60).sub(1);
        if (_14DaysApy > _max14DaysApy) {
            _14DaysApy = _max14DaysApy;
        } else if (_14DaysApy < _min14DaysApy) {
            _14DaysApy = _min14DaysApy;
        }
        _30DaysApy = ((_30DaysApr.div(60)).add(1)).mul(60).sub(1);
        if (_30DaysApy > _max30DaysApy) {
            _30DaysApy = _max30DaysApy;
        } else if (_30DaysApy < _min30DaysApy) {
            _30DaysApy = _min30DaysApy;
        }
        _60daysApy = ((_60daysApr.div(60)).add(1)).mul(60).sub(1);
        if (_60daysApy > _max60daysApy) {
            _60daysApy = _max60daysApy;
        } else if (_60daysApy < _min60daysApy) {
            _60daysApy = _min60daysApy;
        }
        _unlimitedDaysApy = ((_unlimitedDaysApr.div(60)).add(1)).mul(60).sub(1);
        if (_unlimitedDaysApy > _maxUnlimitedDaysApy) {
            _unlimitedDaysApy = _maxUnlimitedDaysApy;
        } else if (_unlimitedDaysApy < _minUnlimitedDaysApy) {
            _unlimitedDaysApy = _minUnlimitedDaysApy;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}