/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IdgtlzStaking {
  function staking(uint amount, uint256 duration) external;
  function claim(uint256 duration) external;
  function withdrawBenefit() external;
  function unStake(uint256 duration) external;
  
  event Staking(address indexed user, uint amount, uint timestamp, uint endStakeDay);
  event Claim(address indexed user, uint rewardedAmount, uint timestamp);
  event Benefit(uint benefitAmount, uint teamAmount, uint airdropAmount);
  event Unstaking(address indexed user, uint timestamp);
  event WithdrawAll(address indexed user, uint timestamp);
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
     * @dev Moves `amount` tokens from the caller"s account to `to`.
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
     * @dev Sets `amount` as the allowance of `spender` over the caller"s tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender"s allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller"s
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
        require(b >= 0, errorMessage);
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

// File @openzeppelin/contracts/utils/[email protected]

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

// File @openzeppelin/contracts/access/[email protected]
pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract dgtlzStaking is IdgtlzStaking, Ownable {
  using SafeMath for uint256;
  
  IERC20 constant BUSD = IERC20(0xDD179A9C6ae89080bc107987305732e190Ea200c);
  mapping(address => mapping(uint256 => uint256)) public stakeAmount;
  mapping(address => mapping(uint256 => uint256)) public rewardAmount;
  mapping(address => mapping(uint256 => uint256)) public _rewardAmount;
  mapping(address => mapping(uint256 => uint256)) public withdrawAmountForStaker;
  mapping(address => mapping(uint256 => uint256)) public rewardedAmount;
  mapping(address => mapping(uint256 => uint256)) public lockDuration; 
  mapping(address => mapping(uint256 => uint256)) public stakingDate;
  mapping(address => mapping(uint256 => uint256)) public interestPeriod;
  mapping(address => mapping(uint256 => uint256)) public interestRate;
  mapping(address => mapping(uint256 => uint256)) public claimDate;
  mapping(address => mapping(uint256 => uint256)) public plan;
  uint public _withdrawAmount;
  uint public totalStakeAmount;
  uint public totalRewardAmount;
  uint public totalAmount_;
  uint256 public unStakableAmount;
  uint public lockPeriod;
  uint256 public _6month = 180 * 1 days;
  uint256 public _1year = 365 * 1 days;
  uint public claimPeriod;
  uint256 public _pastTime;
  uint256 public getPenalty;
  uint public penaltyAmount;
  uint public decimals = 10 ** 18;
  address public teamWallet;
  address public airdropWallet;
  mapping(address => bool) internal stakeholders;

  constructor (
    uint256 _claimPeriod,
    address _teamWallet,
    address _airdropWallet
  ) {
    teamWallet = _teamWallet;
    airdropWallet = _airdropWallet;
    claimPeriod = _claimPeriod * 1 days;
  }

  function isStakeholder(address _address) public view returns(bool) {
      return stakeholders[_address];
  }

  function addStakeholder(address _stakeholder) private {
    stakeholders[_stakeholder] = true;
  }

  function getPercent(uint256 amount, uint256 periodUp) private view returns(uint256) {
    uint256 restTime = periodUp - block.timestamp;
    uint256 penalty =  restTime.div(periodUp).mul(amount).div(10);
    return penalty;
  }

  function staking(uint amount, uint duration) external {
    require(amount <= BUSD.balanceOf(msg.sender), "Not enough BUSD token to stake");
    require(amount >= 500 * decimals , "Cannot stake nothing");
    require(duration >= 0, 'Have to input Staking Duration');
    lockPeriod = duration * 30 * 1 days;
    if (duration == 1) {
      require(amount >= 2000 * decimals, "Stake amount has to more than 5000BUSD");
      if (amount >= 500 * decimals && amount < 2000 * decimals) {
        rewardAmount[msg.sender][duration] += amount / 100;
        interestRate[msg.sender][duration] = 1;
      } else if (amount >= 2000 * decimals && amount <= 5000 * decimals) {
        rewardAmount[msg.sender][duration] += amount / 100;
        interestRate[msg.sender][duration] = 1;
      } else if (amount >= 5000 * decimals) {
        rewardAmount[msg.sender][duration] += amount * 2 / 100;
        interestRate[msg.sender][duration] = 2;
      }
    } else if (duration == 3) {
      if (amount <= 2000) {
        rewardAmount[msg.sender][duration] += amount * 2 / 100;
        interestRate[msg.sender][duration] = 2;
      } else if (amount >= 2000 * decimals && amount <= 5000 * decimals) {
        rewardAmount[msg.sender][duration] += amount * 4 / 100;
        interestRate[msg.sender][duration] = 4;
      } else if (amount >= 5000 * decimals) {
        rewardAmount[msg.sender][duration] += amount * 55 / 1000;
        interestRate[msg.sender][duration] = uint(11) / 2;
      }
    } else if (duration == 6) {
      if (amount <= 2000) {
        rewardAmount[msg.sender][duration] += amount * 55 / 1000;
        interestRate[msg.sender][duration] = uint(11) / 2;
      } else if (amount >= 2000 * decimals && amount <= 5000 * decimals) {
        rewardAmount[msg.sender][duration] += amount * 85 / 1000;
        interestRate[msg.sender][duration] = uint(17) / 2;
      } else if (amount >= 5000 * decimals) {
        rewardAmount[msg.sender][duration] += amount * 115 / 10000;
        interestRate[msg.sender][duration] = uint(23) / 2;
      }
    } else if (duration == 12) {
      if (amount <= 2000) {
        rewardAmount[msg.sender][duration] += amount * 13 / 1000;
        interestRate[msg.sender][duration] = 13;
      } else if (amount >= 2000 * decimals && amount <= 5000 * decimals) {
        rewardAmount[msg.sender][duration] += amount * 21 / 100;
        interestRate[msg.sender][duration] = 21;
      } else if (amount >= 5000 * decimals) {
        rewardAmount[msg.sender][duration] += amount * 25 / 1000;
        interestRate[msg.sender][duration] = 25;
      }
    }

    addStakeholder(msg.sender);
    plan[msg.sender][duration] = duration;
    BUSD.transferFrom(msg.sender, address(this), amount);
    stakeAmount[msg.sender][duration] += amount;
    stakingDate[msg.sender][duration] = block.timestamp;
    claimDate[msg.sender][duration] = block.timestamp;
    totalStakeAmount += amount;
    totalRewardAmount += rewardAmount[msg.sender][duration];
    withdrawAmountForStaker[msg.sender][duration] = amount + rewardAmount[msg.sender][duration];
    lockDuration[msg.sender][duration] = block.timestamp + lockPeriod;
    interestPeriod[msg.sender][duration] = block.timestamp + claimPeriod;

    emit Staking(msg.sender, amount, block.timestamp, lockDuration[msg.sender][duration]);
  }

  
    
  function withdrawBenefit() external onlyOwner {
    totalAmount_ = BUSD.balanceOf(address(this));
    require(totalAmount_ >= 0, "Balance empty");
    require(totalStakeAmount >= 0, "No staked amount");
    require(totalRewardAmount >= 0, "No reward amount");
    if(totalAmount_ >= totalStakeAmount + totalRewardAmount) {
      uint _deltaAmount = totalAmount_ - totalStakeAmount - totalRewardAmount;
      uint airdropAmount = _deltaAmount.div(40).mul(100);
      uint teamAmount = _deltaAmount - airdropAmount;
      BUSD.transfer(airdropWallet, airdropAmount);
      BUSD.transfer(teamWallet, teamAmount);
      emit Benefit(_deltaAmount, teamAmount, airdropAmount);
    } else {
      BUSD.transfer(owner(), totalAmount_);
    }
  }

  
  function _calculationReward(uint pastTime, uint256 amount, uint256 interestPercent) internal view returns(uint256) {
    return pastTime.mul(amount).mul(interestPercent).div(lockPeriod).div(100);
  }

  function claim(uint256 duration) external {
    require(rewardAmount[msg.sender][duration] >= 0, "Nothing to claim");
    require(block.timestamp >= interestPeriod[msg.sender][duration], "Have to wait until interest period");
    interestPeriod[msg.sender][duration] = block.timestamp + claimPeriod;
    _pastTime = block.timestamp - claimDate[msg.sender][duration];
    claimDate[msg.sender][duration] = block.timestamp;
    _rewardAmount[msg.sender][duration] = _calculationReward(_pastTime, stakeAmount[msg.sender][duration], interestRate[msg.sender][duration]);
    BUSD.transfer(msg.sender, _rewardAmount[msg.sender][duration]);
    rewardAmount[msg.sender][duration] -= _rewardAmount[msg.sender][duration];
    withdrawAmountForStaker[msg.sender][duration] -= _rewardAmount[msg.sender][duration];
    totalRewardAmount -= _rewardAmount[msg.sender][duration];
    rewardedAmount[msg.sender][duration] += _rewardAmount[msg.sender][duration];

    emit Claim(msg.sender, rewardAmount[msg.sender][duration], block.timestamp);
  }

  function withdrawAll() external onlyOwner{
    uint totalAmount = BUSD.balanceOf(address(this));
    BUSD.transfer(owner(), totalAmount);

    emit WithdrawAll(msg.sender, block.timestamp);
  }

  function unStake(uint256 duration) external {
    require(stakeAmount[msg.sender][duration] >= 0, "There is not amount to withdraw");
    if(lockDuration[msg.sender][duration] >= block.timestamp) {
      if (plan[msg.sender][duration] == 1) {
        unStakableAmount = stakeAmount[msg.sender][duration].mul(80).div(100);
      } else if (plan[msg.sender][duration] == 3) {
        unStakableAmount = stakeAmount[msg.sender][duration].mul(85).div(100);
        BUSD.transfer(msg.sender, unStakableAmount);
      } else {
        getPenalty = getPercent(stakeAmount[msg.sender][duration], lockDuration[msg.sender][duration]);
        unStakableAmount = stakeAmount[msg.sender][duration] - getPenalty;
      }
      BUSD.transfer(msg.sender, unStakableAmount);
    } else {
      BUSD.transfer(msg.sender, withdrawAmountForStaker[msg.sender][duration]);
    }
    totalStakeAmount -= stakeAmount[msg.sender][duration];
    withdrawAmountForStaker[msg.sender][duration] = 0;
    totalRewardAmount -= rewardAmount[msg.sender][duration];
    stakeAmount[msg.sender][duration] = 0;
    rewardAmount[msg.sender][duration] = 0;

    emit Unstaking(msg.sender, block.timestamp);
  }
}