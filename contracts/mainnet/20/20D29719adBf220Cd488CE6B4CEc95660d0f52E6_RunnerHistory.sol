// SPDX-License-Identifier: Elastic-2.0
pragma solidity 0.8.9;

import '../interfaces/IBlock.sol';
import '../common/access/OwnableClone.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

/**
 * @title Holds historical data on Strategy Runner runs
 */
contract RunnerHistory is OwnableClone {
	using SafeMath for uint256;

	struct RunSnapshot {
		// Time snapshot was taken
		uint256 timestamp;
		// The balance of each block
		uint256[] blockBalance;
		// The total value of deposits since the last run.
		uint256[] deposits;
		// The total value of withdrawals since the last run.
		uint256[] withdrawals;
	}

	// Keeps track of the running deposit and withdrawals totals for each block
	uint256[] runningDeposits;
	uint256[] runningWithdrawals;

	// Stores the balance data snaphots of each run.
	// The new snaphots are appended to the end of the array.
	RunSnapshot[] snapshots;

	// The number of snapshots saved
	uint256 public numSnapshots = 0;

	function initialize(IBlock[] memory _blocks) external onlyOwner {
		runningDeposits = new uint256[](_blocks.length);
		runningWithdrawals = new uint256[](_blocks.length);

		snapshots.push(
			RunSnapshot(
				block.timestamp,
				new uint256[](_blocks.length),
				new uint256[](_blocks.length),
				new uint256[](_blocks.length)
			)
		);
		numSnapshots = numSnapshots.add(1);

		for (uint256 i = 0; i < _blocks.length; i++) {
			snapshots[0].blockBalance[i] = 0;
			snapshots[0].deposits[i] = 0;
			snapshots[0].withdrawals[i] = 0;
		}
	}

	/**
	 * @dev Saves a snapshot into the history
	 */
	function snapshot(IBlock[] memory _blocks) external onlyOwner {
		snapshots.push(
			RunSnapshot(
				block.timestamp,
				new uint256[](_blocks.length),
				new uint256[](_blocks.length),
				new uint256[](_blocks.length)
			)
		);
		numSnapshots = numSnapshots.add(1);

		for (uint256 i = 0; i < _blocks.length; i++) {
			snapshots[numSnapshots.sub(1)].blockBalance[i] = _blocks[i]
				.balance();

			snapshots[numSnapshots.sub(1)].deposits[i] = runningDeposits[i].sub(
				snapshots[numSnapshots.sub(2)].deposits[i]
			);
			snapshots[numSnapshots.sub(1)].withdrawals[i] = runningWithdrawals[
				i
			].sub(snapshots[numSnapshots.sub(2)].withdrawals[i]);
		}
	}

	/**
	 * @dev Updates the tracked deposited amount for a block
	 */
	function logDeposit(uint256 _blockIndex, uint256 _amount)
		external
		onlyOwner
	{
		runningDeposits[_blockIndex] = runningDeposits[_blockIndex].add(
			_amount
		);
	}

	/**
	 * @dev Updates the tracked withdrawan amount for a block
	 */
	function logWithdrawal(uint256 _blockIndex, uint256 _amount)
		external
		onlyOwner
	{
		runningWithdrawals[_blockIndex] = runningWithdrawals[_blockIndex].add(
			_amount
		);
	}

	/**
	 * @dev Returns the running total of deposits for each block.
	 */
	function getRunningDeposits() external view returns (uint256[] memory) {
		return runningDeposits;
	}

	/**
	 * @dev Returns the running total of withdrawals for each block.
	 */
	function getRunningWithdrawals() external view returns (uint256[] memory) {
		return runningWithdrawals;
	}

	/**
	 * @dev Returns the snapshots up to the limit specified in the parameter
	 * Results are ordered from oldest to newest
	 */
	function getSnapshots(uint256 _limit)
		external
		view
		returns (RunSnapshot[] memory _snapshotsData)
	{
		require(_limit > 0, 'limit cannot be zero');

		uint256 maxLimit = _limit < numSnapshots ? _limit : numSnapshots;
		_snapshotsData = new RunSnapshot[](maxLimit);
		for (uint256 i = 1; i <= maxLimit; i++) {
			_snapshotsData[maxLimit.sub(i)] = snapshots[
				snapshots.length.sub((i))
			];
		}
		return _snapshotsData;
	}
}

// SPDX-License-Identifier: Elastic-2.0
pragma solidity 0.8.9;

/**
 * @dev Common data and variables for strategy settings
 */
library StrategySettings {
	// Avalaible Actions for Blocks
	uint256 constant NONE = 0;
	uint256 constant TAKE_PROFIT = 1;
	uint256 constant AUTOCOMPOUND = 2;
	uint256 constant REINVEST = 3;

	/**
	 * Represents an action to apply to a block
	 */
	struct Action {
		// The token to apply the action to
		address token;
		// The action to apply (see constants above)
		uint256 action;
		// The percentage to use - 1% = 100
		uint256 percent;
		// The block Id to divert the action to.
		// Block Ids start from 0
		uint256 toBlockId;
	}

	/**
	 * Represents a fail action to apply to a block
	 */
	struct FailAction {
		// The action to apply (see constants above)
		uint256 action;
		// The block Id to divert the action to.
		// Block Ids start from 0
		uint256 toBlockId;
	}

	/**
	 * Represents an adaptor config for strategy creation
	 */
	struct Adaptor {
		// The adaptor type. See the adaptors section in
		// StratConfigLookUpKeys.sol
		uint256 adaptorType;
		// The out tokens configuration. This is specific to
		// the adaptor type
		address[] outConfig;
	}
}

// SPDX-License-Identifier: Elastic-2.0
pragma solidity 0.8.9;

import '../lib/StrategySettings.sol';
import '@openzeppelin/contracts/utils/introspection/IERC165.sol';

/**
 * @dev For interaction directly with blocks in the strategy
 */
interface IBlock is IERC165 {
	function initialize(address _strategyConfig) external;

	function tag() external view returns (uint256);

	function setTag(uint256 _strategyTag) external;

	function depositAdaptors(uint256) external view returns (address);

	function getDepositAdaptors() external view returns (address[] memory);

	function setDepositAdaptors(StrategySettings.Adaptor[] memory _adaptors)
		external;

	function depositPush(
		address _token,
		uint256 _amount,
		uint256 _minOutAmount
	) external returns (bool);

	function depositPull(
		address _token,
		uint256 _amount,
		uint256 _minOutAmount
	) external returns (bool);

	function depositPullFrom(
		address _sender,
		address _token,
		uint256 _amount,
		uint256 _minOutAmount
	) external returns (bool);

	function depositEther(uint256 _minOutAmount)
		external
		payable
		returns (bool);

	function depositEtherSelf(uint256 _amount, uint256 _minOutAmount)
		external
		returns (bool);

	function transferEther(uint256 _amount) external;

	function withdrawAll() external returns (bool);

	function withdraw(uint256 _amount) external returns (bool);

	function run() external returns (bool);

	function getDepositToken() external view returns (address);

	function getOutTokens() external view returns (address[] memory);

	function getAllTokens() external view returns (address[] memory);

	function isLPToken(address _token) external view returns (bool);

	function balance() external view returns (uint256);

	function approveTokens() external;

	function approveSpendIfNoAllowance(
		address _spender,
		address _token,
		uint256 _amount
	) external;
}

// SPDX-License-Identifier: Elastic-2.0
pragma solidity 0.8.9;

contract OwnableClone {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = __msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    function initOwnerAfterCloning(address newOwner) public {
        require(_owner == address(0), "Ownable: owner has already been initialized");
        emit OwnershipTransferred(address(0), newOwner);
        _owner = newOwner;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == __msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0x000000000000000000000031337000b017000d0114);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function __msgSender() private view returns (address payable) {
        return payable(msg.sender);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}