// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IRaceKingdom.sol";
import "./IRKVesting.sol";

contract RKStaking is Context, Ownable {
    using SafeMath for uint256;

    struct Record {
        uint256 count;
        mapping(uint256 => uint256) time;
        mapping(uint256 => uint256) amount;
    }

    mapping (uint256 => address) internal _stakeholders;
    mapping (address => uint256) internal _stakeholderIndex;
    mapping (address => Record) internal _stakes;
    mapping(address => uint256) internal _lastClaimedTime;
    mapping(address => Record) internal _claimed;
    uint256 internal _stakeholdersCount;


    

    IRaceKingdom _racekingdom;
    IRKVesting _rkvesting;


    constructor (address RaceKingdomAddr, address RKVestingAddr) {
        _racekingdom = IRaceKingdom(RaceKingdomAddr);
        _rkvesting = IRKVesting(RKVestingAddr);
    }

    function quarter () internal view returns(uint256) {
        return ((_rkvesting.Month().add(2)).div(3));
    }

    function getQuarter (uint256 time) internal view returns (uint256) {
        return ((_rkvesting.getMonth(time).add(2)).div(3));
    }

    function  isStakeholder(address addr) public view returns(bool) {
        if(_stakeholderIndex[addr] > 0) return (true);
        else return (false);
    }

    function addStakeholder (address holder) internal {
        require(!isStakeholder(holder), "Already exists in holders list.");
        _stakeholdersCount = _stakeholdersCount.add(1);
        _stakeholders[_stakeholdersCount] = holder;
        _stakeholderIndex[holder] = _stakeholdersCount;
    }

    function removeStakeholder(address holder) internal {
        require(isStakeholder(holder), "Not a stake holder address.");
        uint256 index = _stakeholderIndex[holder];
        address lastHolder = _stakeholders[_stakeholdersCount];
        delete _stakeholderIndex[holder];
        delete _stakeholders[index];
        delete _stakeholderIndex[lastHolder];
        delete _stakeholders[_stakeholdersCount];
        _stakeholders[index] = lastHolder;
        _stakeholderIndex[lastHolder] = index;
        _stakeholdersCount = _stakeholdersCount.sub(1);
    }

    function stakeOf (address holder) public view returns(uint256) {
        require(isStakeholder(holder), "Not a stake holder address.");
        uint256 stakes = 0;
        for (uint256 i = 1; i <= _stakes[holder].count; i++) {
            stakes = stakes.add(_stakes[holder].amount[i]);
        }

        return stakes;
    }

    function quarterStakeOf (address holder, uint256 quar) internal view returns(uint256) {
        require(isStakeholder(holder), "Not a stake holder address.");
        uint256 stakes = 0;
        for (uint256 i = 1; i <= _stakes[holder].count; i++) {
            if(getQuarter(_stakes[holder].time[i]) == quar) {
                stakes = stakes.add(_stakes[holder].amount[i]);
            }
        }
        return stakes;
    }

    function totalStakes() public view returns(uint256) {
        uint256 _totalStakes = 0;
        for (uint256 i=1; i <= _stakeholdersCount; i++) {
            _totalStakes = _totalStakes.add(stakeOf(_stakeholders[i]));
        }
        return _totalStakes;
    }

    function quarterTotalStaked(uint256 quar) internal view returns (uint256) {
        uint256 _quaterStakes = 0;
        for (uint256 i=1; i <= _stakeholdersCount; i++) {
            _quaterStakes = _quaterStakes.add(quarterStakeOf(_stakeholders[i], quar));
        }
        return _quaterStakes;
    }

    function getAPY (uint256 quar) internal view returns (uint256) {
        uint256 quarterStaked = quarterTotalStaked(quar);
        uint256 minStaked = _rkvesting.quarterTotalVestingAmount(quar).mul(5).div(100);
        if (quarterStaked < minStaked) quarterStaked = minStaked;
        uint256 quarterVestingAmountOfStakingReward = _rkvesting.quarterVestingAmountOfStakingReward(quar.add(1));
        uint256 apy = quarterVestingAmountOfStakingReward.mul(10000).div(quarterStaked);
        return apy;
    }

    function createStake(uint256 amount) public returns (bool) {
        require(_racekingdom.transferFrom(msg.sender, address(this), amount), "transfer Failed!");
        if(!isStakeholder(msg.sender)) addStakeholder(msg.sender);
        _stakes[msg.sender].count = _stakes[msg.sender].count.add(1);
        _stakes[msg.sender].time[_stakes[msg.sender].count] = block.timestamp;
        _stakes[msg.sender].amount[_stakes[msg.sender].count] = amount;
        return true;
    }

    function removableStake (address holder) public view returns (uint256) {
        require(isStakeholder(holder), "Not a stake holder address");
        uint256 stakes = 0;
        for (uint256 i = 1; i <= _stakes[holder].count; i++) {
            if (block.timestamp.sub(_stakes[holder].time[i]) >= 90 days) {
                stakes = stakes.add(_stakes[holder].amount[i]);
            }
        }
        return stakes;

    }

    function removeStake (uint256 amount) public {
        require(isStakeholder(msg.sender), "Not a stake holder address");
        require(amount > 0, "Removing zero amount.");
        require(amount <= stakeOf(msg.sender), "Removing Exeeded Amount");
        uint256 usualAmount;
        uint256 earlyAmount;
        uint256 _usualAmount;
        uint256 _earlyAmount;
        if(amount > removableStake(msg.sender)) {
            usualAmount = removableStake(msg.sender);
            earlyAmount = amount.sub(removableStake(msg.sender));
            _earlyAmount = earlyAmount;
        }
        else {
            usualAmount = amount;
        }
        _usualAmount = usualAmount;
        

        claimReward();

        for (uint256 i = _stakes[msg.sender].count; i > 0; i--) {
            if(_usualAmount == 0 && _earlyAmount == 0) break;
            if (block.timestamp.sub(_stakes[msg.sender].time[i]) >= 90 days) {
                if(_usualAmount > 0) {
                    if(_stakes[msg.sender].amount[i] > _usualAmount) {
                        _stakes[msg.sender].amount[i] = _stakes[msg.sender].amount[i].sub(_usualAmount);
                        _usualAmount = 0;
                    }else {
                        _usualAmount = _usualAmount.sub(_stakes[msg.sender].amount[i]);
                        _stakes[msg.sender].amount[i] = _stakes[msg.sender].amount[_stakes[msg.sender].count];
                        _stakes[msg.sender].time[i] = _stakes[msg.sender].time[_stakes[msg.sender].count];
                        delete _stakes[msg.sender].amount[_stakes[msg.sender].count];
                        delete _stakes[msg.sender].time[_stakes[msg.sender].count];
                        _stakes[msg.sender].count = _stakes[msg.sender].count.sub(1);
                    }
                }
            } else {
                if (_earlyAmount > 0) {
                    if(_stakes[msg.sender].amount[i] > _earlyAmount) {
                        _stakes[msg.sender].amount[i] = _stakes[msg.sender].amount[i].sub(_earlyAmount);
                        _earlyAmount = 0;
                    }else {
                        _earlyAmount = _earlyAmount.sub(_stakes[msg.sender].amount[i]);
                        _stakes[msg.sender].amount[i] = _stakes[msg.sender].amount[_stakes[msg.sender].count];
                        _stakes[msg.sender].time[i] = _stakes[msg.sender].time[_stakes[msg.sender].count];
                        delete _stakes[msg.sender].amount[_stakes[msg.sender].count];
                        delete _stakes[msg.sender].time[_stakes[msg.sender].count];
                        _stakes[msg.sender].count = _stakes[msg.sender].count.sub(1);
                    }
                }
            }
        }
        if(stakeOf(msg.sender) == 0) removeStakeholder(msg.sender);
        _claimed[msg.sender].count = _claimed[msg.sender].count.add(1);
        _claimed[msg.sender].time[_claimed[msg.sender].count] = block.timestamp.sub(2 days);
        _claimed[msg.sender].amount[_claimed[msg.sender].count] = usualAmount;

        if (earlyAmount > 0) {
            _claimed[msg.sender].count = _claimed[msg.sender].count.add(1);
            _claimed[msg.sender].time[_claimed[msg.sender].count] = block.timestamp;
            _claimed[msg.sender].amount[_claimed[msg.sender].count] = earlyAmount;
        }
    }

    function rewardsOf (address holder) public view returns(uint256) {
        require(isStakeholder(holder), "Not a stake holder address");
        uint256 rewards = 0;
        for (uint256 i = 1; i <= _stakes[holder].count; i++) {
            if(_lastClaimedTime[holder] > _stakes[holder].time[i]) {
                if (block.timestamp.sub(_stakes[holder].time[i]) >= 90 days && _lastClaimedTime[holder].sub(_stakes[holder].time[i]) < 90 days) {
                    rewards = rewards.add(_stakes[holder].amount[i].mul(getAPY(getQuarter(_stakes[holder].time[i]))).div(10000));
                }
            }else{
                if (block.timestamp.sub(_stakes[holder].time[i]) >= 90 days) {
                    rewards = rewards.add(_stakes[holder].amount[i].mul(getAPY(getQuarter(_stakes[holder].time[i]))).div(10000));
                }
            }
        }
        return rewards;
    }

    function totalRewards () public view returns(uint256) {
        uint256 _totalRewards = 0;
        for (uint256 i=1; i <= _stakeholdersCount; i++) {
            _totalRewards = _totalRewards.add(rewardsOf(_stakeholders[i]));
        }
        return _totalRewards;
    }

    function claimReward () public returns (bool) {
        uint256 reward = rewardsOf(msg.sender);
        if(reward > 0) {
            _claimed[msg.sender].count = _claimed[msg.sender].count.add(1);
            _claimed[msg.sender].time[_claimed[msg.sender].count] = block.timestamp.sub(2 days);
            _claimed[msg.sender].amount[_claimed[msg.sender].count] = reward;
            _lastClaimedTime[msg.sender] = block.timestamp;
            return true;
        }
        else return false;

    }

    function claim () public {
        removeStake(removableStake(msg.sender));
    }

    function withdrawClaimed () public returns(bool) {
        uint256 withdrawable;
        for (uint256 i = _claimed[msg.sender].count; i >= 1; i--) {
            if(block.timestamp.sub(_claimed[msg.sender].time[i]) >= 3 days) {
                withdrawable = withdrawable.add(_claimed[msg.sender].amount[i]);
                _claimed[msg.sender].time[i] = _claimed[msg.sender].time[_claimed[msg.sender].count];
                _claimed[msg.sender].amount[i] = _claimed[msg.sender].amount[_claimed[msg.sender].count];
                delete _claimed[msg.sender].time[_claimed[msg.sender].count];
                delete _claimed[msg.sender].amount[_claimed[msg.sender].count];
                _claimed[msg.sender].count = _claimed[msg.sender].count.sub(1);
            }
        }
        if (withdrawable > 0) {
            _racekingdom.transfer(msg.sender, withdrawable);
        }
        return true;
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () { }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    // Solidity only automatically asserts when dividing by 0
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";

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
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRaceKingdom {
    function getOwner() external view returns (address);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint256 amount) external returns (bool);


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRKVesting {
    function  Month () external view returns(uint256);

    function getMonth (uint256 time) external view returns (uint256);

    function quarterVestingAmount (uint256 quarter) external view returns (uint256);

    function quarterVestingAmountOfStakingReward (uint256 quarter) external view returns (uint256);

    function quarterTotalVestingAmount (uint256 quarter) external view returns (uint256);
}