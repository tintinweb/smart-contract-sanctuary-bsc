// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IRaceKingdom.sol";

contract RKVesting is Context, Ownable {
    using SafeMath for uint256;

    event Released(uint256 fundId, uint256 amount);

    mapping(uint256 => uint256[]) private _vestingAmount;
    mapping(uint256 => address) private _beneficiary;
    mapping(uint256 => uint256) private released;
    mapping(uint256 => uint256) private allocation;

    uint256 private constant _seedRound = 1;
    uint256 private constant _privateRound = 2;
    uint256 private constant _publicRound = 3;
    uint256 private constant _team = 4;
    uint256 private constant _advisors = 5;
    uint256 private constant _p2e = 6;
    uint256 private constant _staking = 7;
    uint256 private constant _ecosystem = 8;
    uint256 private constant _staking30 = 9;
    uint256 private constant _staking60 = 10;
    uint256 private constant _staking90 = 11;

    bool private _isTriggered;

    uint256 private _start;

    IRaceKingdom _racekingdom;


    constructor (address RaceKingdomAddr) {
        _racekingdom = IRaceKingdom(RaceKingdomAddr);
        _isTriggered = false;
        allocation[_seedRound] = 296000000;
        allocation[_privateRound] = 444000000;
        allocation[_publicRound] = 148000000;
        allocation[_team] = 555000000;
        allocation[_advisors] = 185000000;
        allocation[_p2e] = 1110000000;
        allocation[_staking] = 555000000;
        allocation[_ecosystem] = 407000000;
    }

    function start () external view returns (uint256) {
        return (_start);
    }

    function SeedRoundVestingAmount () external view returns (uint256[] memory) {
        return(_vestingAmount[_seedRound]);
    }

    function seedRoundBeneficiary() public view returns (address) {
        return _beneficiary[_seedRound];
    }

    function SetSeedRoundVestingAmount (uint256[] memory vestingAmount) public onlyOwner returns (bool) {
        _vestingAmount[_seedRound] = vestingAmount;
        return true;
    }

    function setSeedRoundBeneficiary (address beneficiary) public onlyOwner returns (bool) {
        _beneficiary[_seedRound] = beneficiary;
        return true;
    }

    function PrivateRoundVestingAmount () external view returns ( uint256[] memory) {
        return( _vestingAmount[_privateRound]);
    }

    function privateRoundBeneficiary() public view returns (address) {
        return _beneficiary[_privateRound];
    }

    function SetPrivateRoundVestingAmount (uint256[] memory vestingAmount) public onlyOwner returns (bool) {
        _vestingAmount[_privateRound] = vestingAmount;
        return true;
    }

    function setPrivateRoundBeneficiary (address beneficiary) public onlyOwner returns (bool) {
        _beneficiary[_privateRound] = beneficiary;
        return true;
    }

    function PublicRoundVestingAmount () external view returns (uint256[] memory) {
        return(_vestingAmount[_publicRound]);
    }

    function publicRoundBeneficiary() public view returns (address) {
        return _beneficiary[_publicRound];
    }

    function SetPublicRoundVestingAmount (uint256[] memory vestingAmount) public onlyOwner returns (bool) {
        _vestingAmount[_publicRound] = vestingAmount;
        return true;
    }

    function setPublicRoundBeneficiary (address beneficiary) public onlyOwner returns (bool) {
        _beneficiary[_publicRound] = beneficiary;
        return true;
    }

    function TeamVestingAmount () external view returns (uint256[] memory) {
        return(_vestingAmount[_team]);
    }

    function teamBeneficiary() public view returns (address) {
        return _beneficiary[_team];
    }

    function SetTeamVestingAmount (uint256[] memory vestingAmount) public onlyOwner returns (bool) {
        _vestingAmount[_team] = vestingAmount;
        return true;
    }

    function setTeamBeneficiary (address beneficiary) public onlyOwner returns (bool) {
        _beneficiary[_team] = beneficiary;
        return true;
    }

    function AdvisorsVestingAmount () external view returns (uint256[] memory) {
        return(_vestingAmount[_advisors]);
    }

    function advisorsBeneficiary() public view returns (address) {
        return _beneficiary[_advisors];
    }

    function SetAdvisorsVestingAmount (uint256[] memory vestingAmount) public onlyOwner returns (bool) {
        _vestingAmount[_advisors] = vestingAmount;
        return true;
    }

    function setAdvisorsBeneficiary (address beneficiary) public onlyOwner returns (bool) {
        _beneficiary[_advisors] = beneficiary;
        return true;
    }

    function P2EVestingAmount () external view returns (uint256[] memory) {
        return(_vestingAmount[_p2e]);
    }

    function p2eBeneficiary() public view returns (address) {
        return _beneficiary[_p2e];
    }

    function SetP2EVestingAmount (uint256[] memory vestingAmount) public onlyOwner returns (bool) {
        _vestingAmount[_p2e] = vestingAmount;
        return true;
    }

    function setP2EBeneficiary (address beneficiary) public onlyOwner returns (bool) {
        _beneficiary[_p2e] = beneficiary;
        return true;
    }

    function StakingVestingAmount () external view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
        return(_vestingAmount[_staking30], _vestingAmount[_staking60], _vestingAmount[_staking90], _vestingAmount[_staking]);
    }

    function stakingBeneficiary() public view returns (address) {
        return _beneficiary[_staking];
    }

    function SetStakingVestingAmount (uint256[] memory vestingAmount30, uint256[] memory vestingAmount60, uint256[] memory vestingAmount90) public onlyOwner returns (bool) {
        _vestingAmount[_staking30] = vestingAmount30;
        _vestingAmount[_staking60] = vestingAmount60;
        _vestingAmount[_staking90] = vestingAmount90;
        for (uint256 i = 0; i < vestingAmount90.length; i++) {
            _vestingAmount[_staking].push(vestingAmount30[i].add(vestingAmount60[i]).add(vestingAmount90[i]));
        }
        return true;
    }

    function setStakingBeneficiary (address beneficiary) public onlyOwner returns (bool) {
        _beneficiary[_staking] = beneficiary;
        return true;
    }

    function EcosystemVestingAmount () external view returns (uint256[] memory) {
        return(_vestingAmount[_ecosystem]);
    }

    function ecosystemBeneficiary() public view returns (address) {
        return _beneficiary[_ecosystem];
    }

    function SetEcosystemVestingAmount (uint256[] memory vestingAmount) public onlyOwner returns (bool) {
        _vestingAmount[_ecosystem] = vestingAmount;
        return true;
    }

    function setEcosystemBeneficiary (address beneficiary) public onlyOwner returns (bool) {
        _beneficiary[_ecosystem] = beneficiary;
        return true;
    }

    function Trigger () public onlyOwner returns (bool) {
        require(!_isTriggered, "Already triggered");
        _isTriggered = true;
        _start = block.timestamp;
        return true;
    }

    function  Month () public view returns(uint256) {
        require(_isTriggered, "Not triggered yet");
        return getMonth(block.timestamp);
    }

    function getMonth (uint256 time) public view returns (uint256) {
        require(_isTriggered, "Not triggered yet");
        uint256 month = (time.sub(_start)).div(30 days).add(1);
        return month;
    } 

    function vestedAmount (uint256 fundId) public view returns (uint256) {
        uint256 vested = 0;
        for (uint256 i = 0; i < Month(); i.add(1)) {
            vested = vested.add(_vestingAmount[fundId][i]);
        }
        return vested;
    }

    function quarterVestingAmount (uint256 quarter) public view returns (uint256) {
        uint256 amount = 0;
        for (uint256 i = quarter.mul(3).sub(3); i < quarter.mul(3); i++){
            for(uint256 fundId = 1; fundId <= 8; fundId++) {
                amount = amount.add(_vestingAmount[fundId][i]);
            }
        }
        return amount;
    }

    function quarterTotalVestingAmount (uint256 quarter) public view returns (uint256) {
        uint256 amount = 0;
        for (uint256 i = 0; i < quarter.mul(3); i++){
            for(uint256 fundId = 1; fundId <= 8; fundId++) {
                amount = amount.add(_vestingAmount[fundId][i]);
            }
        }
        return amount;
    }

    function tillMonthTotalVestingAmount (uint256 month) public view returns (uint256) {
        uint256 amount = 0;
        for (uint256 i = 0; i < month; i++){
            for(uint256 fundId = 1; fundId <= 8; fundId++) {
                amount = amount.add(_vestingAmount[fundId][i]);
            }
        }
        return amount;
    }

    function quarterVestingAmountOfStakingReward (uint256 quarter) public view returns (uint256) {
        uint256 amount = 0;
        for (uint256 i = quarter.mul(3).sub(3); i < quarter.mul(3); i++){
            amount = amount.add(_vestingAmount[_staking][i]);
        }
        return amount;
    }

    function monthVestingAmountOfStakingReward30 (uint256 month) public view returns (uint256) {
        return _vestingAmount[_staking30][month.sub(1)];
    }

    function bimonthVestingAmountOfStakingReward60 (uint256 bimonth) public view returns (uint256) {
        uint256 amount = 0;
        for (uint256 i = bimonth.mul(2).sub(2); i < bimonth.mul(2); i++){
            amount = amount.add(_vestingAmount[_staking60][i]);
        }
        return amount;
    }

    function quarterVestingAmountOfStakingReward90 (uint256 quarter) public view returns (uint256) {
        uint256 amount = 0;
        for (uint256 i = quarter.mul(3).sub(3); i < quarter.mul(3); i++){
            amount = amount.add(_vestingAmount[_staking90][i]);
        }
        return amount;
    }

    function releasableAmount (uint256 fundId) public view returns (uint256) {
        return vestedAmount(fundId).sub(released[fundId]);
    }

    function releaseSeedRound() public onlyOwner returns (bool) {
        return _release(_seedRound);
    }

    function releasePrivateRound() public onlyOwner returns (bool) {
        return _release(_privateRound);
    }

    function releasePublicRound() public onlyOwner returns (bool) {
        return _release(_publicRound);
    }

    function releaseTeam() public onlyOwner returns (bool) {
        return _release(_team);
    }

    function releaseP2E() public onlyOwner returns (bool) {
        return _release(_p2e);
    }

    function releaseStaking() public onlyOwner returns (bool) {
        return _release(_staking);
    }

    function releaseEcosystem() public onlyOwner returns (bool) {
        return _release(_ecosystem);
    }

    function releaseAdvisors() public onlyOwner returns (bool) {
        return _release(_advisors);
    }

    function _release (uint256 fundId) internal onlyOwner returns (bool) {
        uint256 unreleased = releasableAmount(fundId);
        require(_isTriggered, "Not triggered yet");
        require(unreleased > 0, "No releasable amount");
        require(released[fundId].add(unreleased) <= allocation[fundId], "This release would exceed the allocated amount");
        require(_beneficiary[fundId] != address(0), "Beneficiary address not set");
        released[fundId] = released[fundId].add(unreleased);
        _racekingdom.transfer(_beneficiary[fundId], unreleased);
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