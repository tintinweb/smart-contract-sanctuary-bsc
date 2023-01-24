// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVault {

    function safeTransfer(IERC20 from, address to, uint amount) external;

    function safeTransfer(address _to, uint _value) external;

    function getTokenAddressBalance(address token) external view returns (uint);

    function getTokenBalance(IERC20 token) external view returns (uint);

    function getBalance() external view returns (uint);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./StakingState.sol";
import "./IVault.sol";


contract tokenStaking is StakingState, ReentrancyGuard {
	using SafeMath for uint;
	IERC20 public token; // 0x83d3C2D1A55687498Df6800c5F173EC6a7556089
    IVault public vault;

    // Info of each user.
    struct UserInfo {
        address user;
        uint amount;
        uint rewardLockedUp;
        uint totalDeposit;
        uint totalWithdrawn;
        uint nextWithdraw;
        uint depositCheckpoint;
    }

    mapping(address => UserInfo) public users;
	mapping (address => uint) public lastBlock;

    
	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
	event Reinvestment(address indexed user, uint256 amount);
	event ForceWithdraw(address indexed user, uint256 amount);

    constructor(address _vault, address _token) {
        devAddress = msg.sender;
        vault = IVault(_vault);
        token = IERC20(_token);
    }

    modifier tenBlocks() {
        require(
            block.number.sub(lastBlock[msg.sender]) > 10,
            "wait 10 blocks"
        );
        _;
    }


    function invest(uint amount) external nonReentrant whenNotPaused tenBlocks {
        lastBlock[msg.sender] = block.number;
        UserInfo storage user = users[msg.sender];
        if(user.user == address(0)) {
            user.user = msg.sender;
            investors[totalUsers] = msg.sender;
			totalUsers++;
            emit Newbie(msg.sender);
        }
        updateDeposit(msg.sender);
        users[msg.sender].amount += amount;
        users[msg.sender].totalDeposit += amount;

        totalInvested += amount;
        totalDeposits++;

        if(user.nextWithdraw == 0) {
            user.nextWithdraw = block.timestamp + BLOCK_TIME_STEP;
        }

        token.transferFrom(msg.sender, address(vault), amount);
        
    }

    function payToUser(bool _withdraw) internal {
        require(userCanwithdraw(msg.sender), "User cannot withdraw");
        updateDeposit(msg.sender);
        uint fromVault;
        if(_withdraw) {
            fromVault = users[msg.sender].amount;
            delete users[msg.sender].amount;
            delete users[msg.sender].nextWithdraw;
        } else {
            users[msg.sender].nextWithdraw = block.timestamp + BLOCK_TIME_STEP;
        }
        uint formThis = users[msg.sender].rewardLockedUp;
        delete users[msg.sender].rewardLockedUp;        
        uint _toWithdraw = fromVault + formThis;
        totalWithdrawn += _toWithdraw;
        users[msg.sender].totalWithdrawn += _toWithdraw;
        if(fromVault > 0) {
            vault.safeTransfer(token, msg.sender, fromVault);
        }
        token.transfer(msg.sender, formThis);
        emit Withdrawn(msg.sender, _toWithdraw);
    }

    function harvest() external nonReentrant whenNotPaused tenBlocks {
        lastBlock[msg.sender] = block.number;
        payToUser(false);
    }

    function withdraw() external nonReentrant whenNotPaused tenBlocks {
        lastBlock[msg.sender] = block.number;
        payToUser(true);
    }


    function reinvest() external nonReentrant whenNotPaused tenBlocks {
        lastBlock[msg.sender] = block.number;
        require(userCanwithdraw(msg.sender), "User cannot reinvest");
        updateDeposit(msg.sender);
        users[msg.sender].nextWithdraw = block.timestamp + BLOCK_TIME_STEP;
        uint pending = users[msg.sender].rewardLockedUp;
        users[msg.sender].amount += pending;
        delete users[msg.sender].rewardLockedUp;
        totalReinvested += pending;
        totalReinvestCount++;
        token.transfer(address(vault), pending);
    }

    function forceWithdraw() external nonReentrant whenNotPaused tenBlocks {
        lastBlock[msg.sender] = block.number;
        require(userCanwithdraw(msg.sender), "User cannot withdraw");
        uint toTransfer = users[msg.sender].amount;
        delete users[msg.sender].rewardLockedUp;
        delete users[msg.sender].amount;
        delete users[msg.sender].nextWithdraw;
        users[msg.sender].totalWithdrawn += toTransfer;
        users[msg.sender].depositCheckpoint = block.timestamp;
        totalWithdrawn += toTransfer;
        vault.safeTransfer(token, msg.sender, toTransfer);
    }

    function takeTokens(uint _bal) external onlyOwner {
        token.transfer(msg.sender, _bal);
    }


    function getReward(uint _weis, uint _seconds) public pure returns(uint) {
        return (_weis * _seconds * ROI) / (TIME_STEP * PERCENT_DIVIDER);
    }


    function userCanwithdraw(address user) public view returns(bool) {
        if(block.timestamp > users[user].nextWithdraw) {
            if(users[user].amount > 0) {
                return true;
            }
        }
        return false;
    }

    function getDeltaPendingRewards(address _user) public view returns(uint) {
        if(users[_user].depositCheckpoint == 0) {
            return 0;
        }
        return getReward(users[_user].amount, block.timestamp.sub(users[_user].depositCheckpoint));
    }

    function getUserTotalPendingRewards(address _user) public view returns(uint) {
        return users[_user].rewardLockedUp + getDeltaPendingRewards(_user);
    }

    function updateDeposit(address _user) internal {
        users[_user].rewardLockedUp = getUserTotalPendingRewards(_user);
        users[_user].depositCheckpoint = block.timestamp;
    }

    function getUser(address _user) external view returns(UserInfo memory userInfo_, 
    uint pendingRewards) {
        userInfo_ = users[_user];   
        pendingRewards=getUserTotalPendingRewards(_user);        
    }

    function getAllUsers() external view returns(UserInfo[] memory) {
        UserInfo[] memory result = new UserInfo[](totalUsers);
        for(uint i = 0; i < totalUsers; i++) {
            result[i] = users[investors[i]];
        }
        return result;
    }

    function getUserByIndex(uint _index) external view returns(UserInfo memory) {
        require(_index < totalUsers, "Index out of bounds");
        return users[investors[_index]];
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingState {
    uint internal constant TIME_STEP = 1 days;
    uint internal constant BLOCK_TIME_STEP = 1 days;
	uint internal constant PERCENT_DIVIDER = 1000;
	uint internal constant ROI = 5;


	uint public initDate;


	mapping(uint => address) public investors;
	uint internal totalUsers;
	uint internal totalInvested;
	uint internal totalWithdrawn;
	uint internal totalDeposits;
	uint internal totalReinvested;
	uint internal totalReinvestCount;



	address public devAddress;

	event Paused(address account);
	event Unpaused(address account);

	modifier onlyOwner() {
		require(devAddress == msg.sender, "Ownable: caller is not the owner");
		_;
	}

	modifier whenNotPaused() {
		require(initDate > 0, "Pausable: paused");
		_;
	}

	modifier whenPaused() {
		require(initDate == 0, "Pausable: not paused");
		_;
	}

	function unpause() external whenPaused onlyOwner{
		initDate = block.timestamp;
		emit Unpaused(msg.sender);
	}

	function isPaused() public view returns(bool) {
		return initDate == 0;
	}

	function getDAte() external view returns(uint) {
		return block.timestamp;
	}

	function getPublicData() external view returns(
		uint totalUsers_,
		uint totalInvested_,
		uint totalDeposits_,
		uint totalReinvested_,
		uint totalReinvestCount_,
		uint totalWithdrawn_,
		bool isPaused_
		) {
		totalUsers_=totalUsers;
		totalInvested_=totalInvested;
		totalDeposits_=totalDeposits;
		totalReinvested_=totalReinvested;
		totalReinvestCount_=totalReinvestCount;
		totalWithdrawn_=totalWithdrawn;
		isPaused_=isPaused();		
	}

	function getAllInvestors() external view returns(address[] memory) {
		address[] memory investorsList = new address[](totalUsers);
		for(uint i = 0; i < totalUsers; i++) {
			investorsList[i] = investors[i];
		}
		return investorsList;
	}

	function getInvestorByIndex(uint index) external view returns(address) {
		require(index < totalUsers, "Index out of range");
		return investors[index];
	}

}