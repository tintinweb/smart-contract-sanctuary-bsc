/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: kxnc_pro/Token_Gold_Staking_v3_dev.sol


pragma solidity >= 0.5.0;



/**
* @title Staking Token (STK)
* @author Alberto Cuesta Canada
* @notice Implements a basic ERC20 staking token with incentive distribution.
*/
interface Token {
	function mint(address to, uint256 amount) external;	
    function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool success);
}

contract TokenGoldStaking is Ownable {
	using SafeMath for uint256;

	/**
	 * @notice the seconds for one day
	 */
	uint256 constant _DaySeconds = 86400;
	
	/**
	 * @notice the token for stake
	 */
	Token internal _token;
	
	/**
	 * @notice the minimum for a stakeholder to create a stake
	 */
	uint256 internal _stakeMin;
	
	/**
	 * Reward calculation ratio (a/b)
	 */
	uint256 internal _rewardRatioA;
	uint256 internal _rewardRatioB;
	
	/**
	 * @notice We usually require to know who are all the stakeholders.
	 */
	address[] internal stakeholders;
   
	/**
	 * @notice The stakes for each stakeholder.
	 */
	mapping(address => uint256) internal stakes;
   
	/**
	 * @notice The accumulated rewards for each stakeholder.
	 */
	mapping(address => uint256) internal rewards;

	/**
	 * @notice The last timestamp for sucessful call  distributeRewards()
	 */
	uint256 internal _lastDistributeTime = 0;
	
	/**
	 * @notice the statistics for distribute rewards
	 */
	uint256 internal _distributeTotal = 0;
	uint256 internal _distributeTimes = 0;
	
	/**
     * @notice The constructor for the Staking Token.
     * @param _tokenAddress The address to receive token on construction.
     */
	constructor(address _tokenAddress, uint256 _stakeMinVal, uint256 _rewardRatioAVal, uint256 _rewardRatioBVal){
		_token = Token(_tokenAddress);
		_stakeMin = _stakeMinVal;
		_rewardRatioA = _rewardRatioAVal;
		_rewardRatioB = _rewardRatioBVal;
	}

	event SetStakeMin(uint256 _stakeMinVal);
	function setStakeMin(uint256 _stakeMinVal) public onlyOwner
	{
		_stakeMin = _stakeMinVal;
		emit SetStakeMin(_stakeMin);
	}

	event SetRewardRatio(uint256 _rewardRatioAVal, uint256 _rewardRatioBVal);
	function setRewardRatio(uint256 _rewardRatioAVal, uint256 _rewardRatioBVal) public onlyOwner
	{
		_rewardRatioA = _rewardRatioAVal;
		_rewardRatioB = _rewardRatioBVal;
		emit SetRewardRatio(_rewardRatioA, _rewardRatioB);
	}

	function token() public view returns(address)
	{
		return address(_token);
	}

	function stakeMin() public view returns (uint256)
	{
		return _stakeMin;
	}

	function rewardRatio() public view returns (uint256, uint256)
	{
		return (_rewardRatioA, _rewardRatioB);
	}

	/**
	 * @notice A method to check if an address is a stakeholder.
     * @param _address The address to verify.
     * @return bool, uint256 Whether the address is a stakeholder,
     * and if so its position in the stakeholders array.
     */
	function isStakeholder(address _address) public view returns(bool, uint256)
	{
		for (uint256 s = 0; s < stakeholders.length; s += 1){
			if (_address == stakeholders[s]) return (true, s);
		}
		return (false, 0);
	}

	/**
	 * @notice A method to add a stakeholder. only owner request
	 * @param _stakeholder The stakeholder to add.
	 */
	function addStakeholder(address _stakeholder) public onlyOwner
	{
		(bool _isStakeholder, ) = isStakeholder(_stakeholder);
		if(!_isStakeholder) stakeholders.push(_stakeholder);
	}

	/**
	 * @notice A method to remove a stakeholder. only owner request
	 * @param _stakeholder The stakeholder to remove.
	 */
	function removeStakeholder(address _stakeholder) public onlyOwner
	{
		(bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
		if(_isStakeholder){
			stakeholders[s] = stakeholders[stakeholders.length - 1];
			stakeholders.pop();
		}
	}
   
	event StakeChange(address _stakeholder, uint256 _stake, bool _isAdd, uint256 _value);
	/**
	 * @notice A method for a stakeholder to create a stake.
	 * @param _stake The size of the stake to be created.
	 */
	function createStake(uint256 _stake) public
	{
		(bool _isStakeholder, ) = isStakeholder(msg.sender);
		require(true == _isStakeholder, "staking: unauthorized holder");
		_token.transferFrom(address(msg.sender), address(this), _stake);
		stakes[msg.sender] = stakes[msg.sender].add(_stake);
		
		emit StakeChange(address(msg.sender), stakes[msg.sender], true, _stake);
	}

	/**
	 * @notice A method for a stakeholder to remove a stake.
	 * @param _stake The size of the stake to be removed.
	 */
	function removeStake(uint256 _stake) public
	{
		require(stakes[msg.sender] >= _stake, "staking: remove value more than stake amount");
		_token.transfer(address(msg.sender),_stake);
		stakes[msg.sender] = stakes[msg.sender].sub(_stake);
		
		emit StakeChange(address(msg.sender), stakes[msg.sender], false, _stake);
	}
   
	/**
	 * @notice A method to retrieve the stake for a stakeholder.
	 * @param _stakeholder The stakeholder to retrieve the stake for.
	 * @return uint256 The amount of wei staked.
	 */
	function stakeOf(address _stakeholder) public view returns(uint256)
	{
		return stakes[_stakeholder];
	}

	/**
	 * @notice A method to the aggregated stakes from all stakeholders.
	 * @return uint256 The aggregated stakes from all stakeholders.
	 */
	function totalStakes() public view returns(uint256)
	{
		uint256 _totalStakes = 0;
		for (uint256 s = 0; s < stakeholders.length; s += 1){
			_totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
		}
		return _totalStakes;
	}
   
	/**
	 * @notice A method to allow a stakeholder to check his rewards.
	 * @param _stakeholder The stakeholder to check rewards for.
	 */
	function rewardOf(address _stakeholder) public view returns(uint256)
	{
		return rewards[_stakeholder];
	}

	/**
	 * @notice A method to the aggregated rewards from all stakeholders.
	 * @return uint256 The aggregated rewards from all stakeholders.
	 */
	function totalRewards() public view returns(uint256)
	{
		uint256 _totalRewards = 0;
		for (uint256 s = 0; s < stakeholders.length; s += 1){
			_totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
		}
		return _totalRewards;
	}
   
	/**
	 * @notice A simple method that calculates the rewards for each stakeholder.
	 * @param _stakeholder The stakeholder to calculate rewards for.
	 */
	function calculateReward(address _stakeholder) public view returns(uint256)
	{
		if(_stakeMin > stakes[_stakeholder]){
			return 0;
		}
		return stakes[_stakeholder]  / _rewardRatioB * _rewardRatioA;
	}

	function getDistributeTimeInfo() public view returns(uint256, uint256, uint256)
	{
		uint256 currDayStartTime = (block.timestamp/_DaySeconds)*_DaySeconds;
		return (block.timestamp, currDayStartTime, _lastDistributeTime);
	}

	function getDistributeTotalInfo() public view returns(uint256, uint256)
	{
		return (_distributeTotal, _distributeTimes);
	}

	event DistributeRewards(uint256 _reward, uint256 _validHolders, uint256 _validStakes, uint256 _totalHolders, uint256 totalStakes, uint256 _distributeTime);
	/**
	 * @notice A method to distribute rewards to all stakeholders. only owner request
	 */
	function distributeRewards() public onlyOwner
	{
		(,uint256 currDayStartTime,) = getDistributeTimeInfo();
		require(currDayStartTime > _lastDistributeTime, "staking: rewards have been distributed today");
		uint256 amount = 0;
		uint256 validHolderNum = 0;
		uint256 validStakeNum = 0;
		uint256 totalStakeNum = 0;
		for (uint256 s = 0; s < stakeholders.length; s += 1){
			address stakeholder = stakeholders[s];
			// holder's stake amount must more than _stakeMin
			uint256 reward = calculateReward(stakeholder);
			if(0 < reward){
				rewards[stakeholder] = rewards[stakeholder].add(reward);
				amount = amount.add(reward);
				validStakeNum = validStakeNum.add(stakes[stakeholder]);
				validHolderNum += 1;
			}
			totalStakeNum = totalStakeNum.add(stakes[stakeholder]);
		}
		_distributeTotal = _distributeTotal.add(amount);
		_distributeTimes = _distributeTimes.add(1);
		_lastDistributeTime = currDayStartTime;

		emit DistributeRewards(amount, validHolderNum, validStakeNum, stakeholders.length, totalStakeNum, _lastDistributeTime);
	}

	event WithdrawReward(address _sender, address _to, uint256 _amount);
	/**
	 * @notice A method to allow a stakeholder to withdraw his rewards.
	 */
	function withdrawReward() public
	{
		uint256 reward = rewards[msg.sender];
		rewards[msg.sender] = 0;
		_token.mint(address(msg.sender), reward);

		emit WithdrawReward(address(msg.sender), address(msg.sender), reward);
	}
	
	function withdrawSuperReward(address _recipient) public {
		uint256 reward = rewards[msg.sender];
		rewards[msg.sender] = 0;
		_token.mint(address(_recipient), reward);
		
		emit WithdrawReward(address(msg.sender), address(_recipient), reward);
	}
}