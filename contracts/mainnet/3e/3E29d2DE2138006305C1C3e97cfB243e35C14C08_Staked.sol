//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./security/ReEntrancyGuard.sol";
import "./Stakeable.sol";

contract Staked is Context, Ownable, ReEntrancyGuard, Stakeable {
    IERC20 private BEB20Token;

    struct TypeStake {
        uint256 rewardRate;
        uint256 rewardPerMonth;
        uint256 day;
        bool status;
    }

    // @dev minimum tokens for staking
    uint256 public minStaked = 0; // 100 Token

    mapping(uint256 => TypeStake) _Stake;
    uint256 public _stakeCount;

    constructor(address _dlyTokenAddress) {
        BEB20Token = IERC20(_dlyTokenAddress);
        _stakeCount = 0;
    }

    // @dev  register staking types
    function registerStake(
        uint256 _rewardRate,
        uint256 _rewardPerMonth,
        uint256 _day,
        bool _status
    ) external onlyOwner {
        _Stake[_stakeCount] = TypeStake(
            _rewardRate,
            _rewardPerMonth,
            _day,
            _status
        );
        _stakeCount++;
    }

    // @dev we return all registered staking types
    function stakeList() external view returns (TypeStake[] memory) {
        unchecked {
            TypeStake[] memory stakes = new TypeStake[](_stakeCount);
            for (uint256 i = 0; i < _stakeCount; i++) {
                TypeStake storage s = _Stake[i];
                stakes[i] = s;
            }
            return stakes;
        }
    }

    // @dev we get the blocking days of a staking type
    function getDays(uint256 _day) public pure returns (uint256) {
        return _day * 1 days;
    }

    // we deactivate establishment
    function disableStake(uint256 id)
        external
        onlyOwner
        returns (bool success)
    {
        _Stake[id].status = false;
        return true;
    }

    // we deactivate establishment
    function enableStake(uint256 id) external onlyOwner returns (bool success) {
        _Stake[id].status = true;
        return true;
    }

    // ---------- STAKES ----------

    // @dev Add functionality like "burn" to the _stake afunction
    function stake(uint256 _amount, uint256 _idStake)
        external
        noReentrant
        returns (bool)
    {
        // @dev Make sure staker actually is good for it
        require(
            _amount < balanceOfdly(_msgSender()),
            "Cannot stake more than you own"
        );

        // @dev the initial amount must be greater than 100 token
        require(
            _amount >= minStaked,
            "the initial amount must be greater than 100 token"
        );

        // @dev
        TypeStake storage s = _Stake[_idStake];

        // @dev
        require(s.status, "not available");

        // "Burn" the amount of tokens on the sender
        require(BEB20Token.transferFrom(
            _msgSender(),
            address(this),
            _amount
        ), "Failed to transfer tokens from user to vendor");

        // @dev Add the stake to the stake array
        _stake(_amount, getDays(s.day), s.rewardRate, s.rewardPerMonth);

        return true;
    }

    // @dev  withdrawStake is used to withdraw stakes from the account holder
    function withdrawStake(uint256 amount, uint256 stake_index)
        external
        noReentrant
        returns (bool)
    {
        uint256 amount_to_mint = _withdrawStake(amount, stake_index);

        // Return staked tokens to user
        // Transfer token to the msg.sender
        bool sent = BEB20Token.transfer(_msgSender(), amount_to_mint);
        require(sent, "Failed to transfer token to user");

        return true;
    }

    /**
     * @notice A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */

    function totalStakes() external view returns (uint256) {
        return _totalStakes();
    }

    /**
     * @dev change minimum purchase amount
     */
    function changeMinStaked(uint256 _minStaked)
        public
        onlyOwner
        returns (bool)
    {
        minStaked = _minStaked;
        return true;
    }

    // @dev balanceOf will return the account balance for the given account
    function balanceOfdly(address _address) public view returns (uint256) {
        return BEB20Token.balanceOf(_address);
    }

    // @dev  we remove the liquidity of the contract
    function withdraw(uint256 amount)
        external
        onlyOwner
        noReentrant
        returns (bool)
    {
        // Transfer token to the msg.sender
        bool sent = BEB20Token.transfer(_msgSender(), amount);
        require(sent, "Failed to transfer token to user");
        return sent;
    }

    // This fallback/receive function
    // will keep all the Ether
    fallback() external payable {
        // Do nothing
    }

    receive() external payable {
        // Do nothing
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
pragma solidity 0.8.9;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @notice Stakeable is a contract who is ment to be inherited by other contract that wants Staking capabilities
 */
contract Stakeable is Context, Ownable {
    using SafeMath for uint256;

    /**
     * @notice Constructor since this contract is not ment to be used without inheritance
     * push once to stakeholders for it to work proplerly
     */
    constructor() {
        // This push is needed so we avoid index 0 causing bug of index-1
        stakeholders.push();
    }

    /**
     * @notice
     * A stake struct is used to represent the way we store stakes,
     * A Stake will contain the users address, the amount staked and a timestamp,
     * Since which is when the stake was made
     */
    struct Stake {
        address user;
        uint256 amount;
        uint256 sinceBlock;
        uint256 untilBlock;
        uint256 rewardRate;
        uint256 rewardPerMonth;
        // This claimable field is new and used to tell how big of a reward is currently available
        uint256 claimable;
    }
    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }
    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */
    struct StakingSummary {
        uint256 total_amount;
        Stake[] stakes;
    }

    /**
     * @notice
     *   This is a array where we store all Stakes that are performed on the Contract
     *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
     */
    Stakeholder[] internal stakeholders;
    /**
     * @notice
     * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;
    /**
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 sinceBlock,
        uint256 untilBlock,
        uint256 indexed rewardRate,
        uint256 indexed rewardPerMonth
    );

    // ---------- STAKES ----------

    /**
     * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker) internal returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex;
    }

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID
     */
    function _stake(
        uint256 _amount,
        uint256 _untilBlock,
        uint256 _rewardRate,
        uint256 _rewardPerMonth
    ) internal {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");

        // Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[_msgSender()];
        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 sinceBlock = getTime();
        // See if the staker already has a staked index or if its the first time
        if (index == 0) {
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeholder(_msgSender());
        }

        uint256 timeToDistribute = sinceBlock + _untilBlock;

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        stakeholders[index].address_stakes.push(
            Stake(
                _msgSender(),
                _amount,
                sinceBlock,
                timeToDistribute,
                _rewardRate,
                _rewardPerMonth,
                0
            )
        );
        // Emit an event that the stake has occured
        emit Staked(
            _msgSender(),
            _amount,
            index,
            sinceBlock,
            timeToDistribute,
            _rewardRate,
            _rewardPerMonth
        );
    }

    /**
     * @notice A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function _totalStakes() internal view returns (uint256) {
        uint256 __totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            __totalStakes =
                __totalStakes +
                stakeholders[s].address_stakes.length;
        }

        return __totalStakes;
    }

    /**
     * @notice
     * calculateStakeReward is used to calculate how much a user should be rewarded for their stakes
     * and the duration the stake has been active
     */

    function calculateStakeRewardBlock(Stake memory _current_stake)
        internal
        pure
        returns (uint256)
    {
        // @dev take profit percentagee
        return
            (_current_stake.amount * _current_stake.rewardRate) /
            100000000000000000000;
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
     */
    function _withdrawStake(uint256 amount, uint256 index)
        internal
        returns (uint256)
    {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[_msgSender()];
        Stake memory current_stake = stakeholders[user_index].address_stakes[
            index
        ];

        require(
            getTime() >= current_stake.untilBlock,
            "Staking: You cannot withdraw, it is still in its authorized blocking time"
        );

        require(
            current_stake.amount >= amount,
            "Staking: Cannot withdraw more than you have staked"
        );

        // Calculate available Reward first before we start modifying data
        uint256 reward = calculateStakeRewardBlock(current_stake);

        // Remove by subtracting the money unstaked
        current_stake.amount = current_stake.amount - amount;
        // If stake is empty, 0, then remove it from the array of stakes
        if (current_stake.amount == 0) {
            delete stakeholders[user_index].address_stakes[index];
        } else {
            // If not empty then replace the value of it
            stakeholders[user_index]
                .address_stakes[index]
                .amount = current_stake.amount;
            // Reset timer of stake
            stakeholders[user_index]
                .address_stakes[index]
                .sinceBlock = getTime();
        }

        return amount + reward;
    }

    /**
     * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker)
        public
        view
        returns (StakingSummary memory)
    {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(
            0,
            stakeholders[stakes[_staker]].address_stakes
        );

        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateStakeRewardBlock(
                summary.stakes[s]
            );
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        return summary;
    }

    // @dev timestamp of the current block in seconds since the epoch
    function getTime() public view returns (uint256 time) {
        return block.timestamp;
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