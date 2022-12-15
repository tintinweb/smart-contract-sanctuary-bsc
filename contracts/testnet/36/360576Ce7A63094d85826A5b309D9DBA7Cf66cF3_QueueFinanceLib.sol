// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "IERC20.sol";
import "SafeMath.sol";

library QueueFinanceLib {
    using SafeMath for uint256;

    struct Level {
        uint256 amount;
        uint256 level; // 0 is the highest level; n is the lowest level
    }

    struct DepositInfo {
        address wallet;
        uint256 depositDateTime; // UTC
        uint256 initialStakedAmount;
        uint256 iCoinValue;
        uint256 stakedAmount;
        uint256 accuredCoin;
        uint256 claimedCoin;
        uint256 lastUpdated;
        uint256 nextSequenceID;
        uint256 previousSequenceID;
        uint256 inactive;
    }

    struct UserInfo {
        uint256 initialStakedAmount;
        uint256 totalAmount; // How many  tokens the user has provided.
        uint256 totalAccrued; // Interest accrued till date.
        uint256 totalClaimedCoin; // Interest claimed till date
        uint256 lastAccrued; // Last date when the interest was claimed
        uint256[] depositSequences;
        address referral;
    }

    struct RateInfoStruct {
        uint256 timestamp;
        uint256 rate;
    }

    struct LevelInfo {
        uint256 levelStakingLimit;
        uint256 levelStaked;
    }

    struct PoolInfo {
        // bytes32 name; //Pool name
        uint256 totalStaked; //
        uint256 eInvestCoinValue;
        IERC20 depositToken; // Address of investment token contract.
        IERC20 rewardToken; // Address of reward token contract.
        bool isStarted;
        uint256 maximumStakingAllowed;
        uint256 currentSequence;
        // The time when miner mining starts.
        uint256 poolStartTime;
        // // The time when miner mining ends.
        uint256 poolEndTime;
        uint256 rewardsBalance; // = 0;
        uint256 levels;
        uint256 lastActiveSequence;
        uint256[] taxRates;
    }

    struct Threshold {
        uint256 sequence;
        uint256 amount;
    }

    struct RequestedClaimInfo {
        uint256 claimId;
        uint256 claimTime;
        uint256 claimAmount;
        uint256 depositAmount;
        uint256 claimInterest;
        uint256[] sequenceIds;
    }

    //===========================Structures for Deposits===========================
    struct AddDepositInfo {
        uint256 sequenceId;
        DepositInfo depositInfo;
    }

    struct AllDepositData {
        PoolInfo poolInfo;
        uint256 sequenceId;
        AddDepositInfo depositInfo;
        LevelInfo[] levelInfo;
        UserInfo userInfo;
        Threshold[] thresholdInfo;
    }

    struct AddDepositData {
        uint256 poolId;
        uint256 seqId;
        address sender;
        uint256 prevSeqId;
        uint256 poolTotalStaked;
        uint256 poolLastActiveSequence;
        uint256 blockTime;
    }

    struct AddDepositData1 {
        uint8[] levelsAffected;
        QueueFinanceLib.AddDepositInfo updateDepositInfo;
        uint256[] updatedLevelsForDeposit;
        QueueFinanceLib.LevelInfo[] levelsInfo;
        QueueFinanceLib.Threshold[] threshold;
    }

    struct AddDepositModule {
        AddDepositData addDepositData;
        AddDepositData1 addDepositData1;
    }

    //===========================*Ended for Deposits*===========================

    //===========================Structures for Admin===========================

    struct AddLevelData {
        uint256 poolId;
        uint8 levelId;
        LevelInfo levelInfo;
        RateInfoStruct rateInfo;
        Threshold threshold;
    }

    struct DepositsBySequence {
        uint256 sequenceId;
        DepositInfo depositInfo;
    }

    struct FetchUpdateLevelData {
        LevelInfo[] levelsInfo;
        Threshold[] thresholds;
        DepositsBySequence[] depositsInfo;
    }

    struct DepositDetailsForUser{
        DepositInfo depositInfo;
        uint256[] lastUpdateLevelsForDeposit;
        uint256 seqId;
    }
    //===========================*Ended for Admin*===========================

    //===========================*Structures for withdraw*===========================
    struct FetchLastUpdatedLevelsForDeposits {
        uint256 sequenceId;
        uint256[] lastUpdatedLevelsForDeposits;
    }

    struct LastUpdatedLevelsPendings {
        uint256 sequenceId;
        uint256 accruedCoin;
    }

    struct FetchWithdrawData {
        // DepositsBySequence[] depositsByThresholdId;
        DepositsBySequence[] depositsInfo;
        PoolInfo poolInfo;
        FetchLastUpdatedLevelsForDeposits[] lastUpdatedLevelsForDeposit;
        RateInfoStruct[][] rateInfo;
        Threshold[] threshold;
        uint256 withdrawTime;
        uint256 requestedClaimInfoIncrementer;
        LevelInfo[] levelInfo;
        // UserInfo userInfo;
    }


    struct UpdateWithdrawDataInALoop {
        uint256 poolId;
        uint256 currSeqId;
        uint256 depositPreviousNextSequenceID;
        uint256 depositNextPreviousSequenceID;
        uint256 curDepositPrevSeqId;
        uint256 curDepositNextSeqId;
        uint256 interest;
        QueueFinanceLib.Threshold[] thresholds;
        QueueFinanceLib.LevelInfo[] levelsInfo;
        address user;
    }

    //===========================*Ended for withdraw*================================

    function min(uint256 a, uint256 b) public pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) public pure returns (uint256) {
        return a > b ? a : b;
    }

    function pickDepositBySequenceId(
        DepositsBySequence[] memory deposits,
        uint256 _seqId
    ) public pure returns (DepositInfo memory) {
        for (uint256 i = 0; i < deposits.length; i++) {
            if (deposits[i].sequenceId == _seqId) {
                return deposits[i].depositInfo;
            }
        }
        revert("Invalid Deposit value");
    }

    function pickLastUpdatedLevelsBySequenceId(
        FetchLastUpdatedLevelsForDeposits[] memory _arrData,
        uint256 _seqId
    ) public pure returns (uint256[] memory) {
        for (uint256 i = 0; i < _arrData.length; i++) {
            if (_arrData[i].sequenceId == _seqId) {
                return _arrData[i].lastUpdatedLevelsForDeposits;
            }
        }
        revert("Invalid Data");
    }

    function getRemoveIndex(
        uint256 _sequenceID,
        uint256[] memory depositSequences
    ) internal pure returns (uint256, bool) {
        for (uint256 i = 0; i < depositSequences.length; i++) {
            if (_sequenceID == depositSequences[i]) {
                return (i, true);
            }
        }
        return (0, false);
    }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}