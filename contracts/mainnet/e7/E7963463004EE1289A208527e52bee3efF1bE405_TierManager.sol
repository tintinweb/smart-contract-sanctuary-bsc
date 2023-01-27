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
pragma solidity 0.8.4;

interface IETF {

    function rebase(uint256 epoch, uint256 supplyDelta, bool positive) external;
    function mint(address to, uint256 amount) external;
    function getPriorBalance(address account, uint blockNumber) external view returns (uint256);
    function mintForReferral(address to, uint256 amount) external;
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function transferForRewards(address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IReferralHandler {
    function initialize(address, address, address, uint256) external;
    function setTier(uint256 _tier) external;
    function setDepositBox(address) external;
    function checkExistence(uint256, address) external view returns (address);
    function coupledNFT() external view returns (address);
    function referredBy() external view returns (address);
    function ownedBy() external view returns (address);
    function getTier() external view returns (uint256);
    function getTransferLimit() external view returns(uint256);
    function remainingClaims() external view returns (uint256);
    function updateReferralTree(uint256 depth, uint256 NFTtier) external;
    function addToReferralTree(uint256 depth, address referred, uint256 NFTtier) external;
    function mintForRewarder(address recipient, uint256 amount ) external;
    function alertFactory(uint256 reward, uint256 timestamp) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IStakingPoolAggregator {
    function checkForStakedRequirements(address, uint256, uint256) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./interfaces/IReferralHandler.sol";
import "./interfaces/IETFNew.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IStakingPoolAggregator.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TierManager {
    using SafeMath for uint256;

    struct TierParamaters {
        uint256 stakedTokens;
        uint256 stakedDuration;
        uint256 tierZero;
        uint256 tierOne;
        uint256 tierTwo;
        uint256 tierThree;
    }

    address public admin;
    IStakingPoolAggregator public stakingPool;
    mapping(uint256 => TierParamaters) public levelUpConditions;
    mapping(uint256 => uint256) public transferLimits;
    mapping(uint256 => string) public tokenURI;

    modifier onlyAdmin() {
        // Change this to a list with ROLE library
        require(msg.sender == admin, "only admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function setStakingAggregator(address oracle) public onlyAdmin {
        stakingPool = IStakingPoolAggregator(oracle);
    }

    function scaleUpTokens(uint256 amount) public pure returns (uint256) {
        uint256 scalingFactor = 10 ** 18;
        return amount.mul(scalingFactor);
    }

    function setAdmin(address account) public onlyAdmin {
        admin = account;
    }

    function setConditions(
        uint256 tier,
        uint256 stakedTokens,
        uint256 stakedDurationInDays,
        uint256 tierZero,
        uint256 tierOne,
        uint256 tierTwo,
        uint256 tierThree
    ) public onlyAdmin {
        levelUpConditions[tier].stakedTokens = stakedTokens;
        levelUpConditions[tier].stakedDuration = stakedDurationInDays;
        levelUpConditions[tier].tierZero = tierZero;
        levelUpConditions[tier].tierOne = tierOne;
        levelUpConditions[tier].tierTwo = tierTwo;
        levelUpConditions[tier].tierThree = tierThree;
    }

    function validateUserTier(
        address owner,
        uint256 tier,
        uint256[5] memory tierCounts
    ) public view returns (bool) {
        // Check if user has valid requirements for the tier, if it returns true it means they have the requirement for the tier sent as parameter

        if (
            !isMinimumStaked(
                owner,
                levelUpConditions[tier].stakedTokens,
                levelUpConditions[tier].stakedDuration
            )
        ) return false;
        if (tierCounts[0] < levelUpConditions[tier].tierZero) return false;
        if (tierCounts[1] < levelUpConditions[tier].tierOne) return false;
        if (tierCounts[2] < levelUpConditions[tier].tierTwo) return false;
        if (tierCounts[3] < levelUpConditions[tier].tierThree) return false;
        return true;
    }

    function isMinimumStaked(
        address user,
        uint256 stakedAmount,
        uint256 stakedDuration
    ) internal view returns (bool) {
        return
            stakingPool.checkForStakedRequirements(
                user,
                stakedAmount,
                stakedDuration
            );
    }

    function setTokenURI(
        uint256 tier,
        string memory _tokenURI
    ) public onlyAdmin {
        tokenURI[tier] = _tokenURI;
    }

    function getTokenURI(uint256 tier) public view returns (string memory) {
        return tokenURI[tier];
    }

    function setTransferLimit(
        uint256 tier,
        uint256 limitPercent
    ) public onlyAdmin {
        require(limitPercent <= 100, "Limit cannot be above 100");
        transferLimits[tier] = limitPercent;
    }

    function getTransferLimit(uint256 tier) public view returns (uint256) {
        return transferLimits[tier];
    }

    function checkTierUpgrade(
        uint256[5] memory tierCounts
    ) public view returns (bool) {
        address owner = IReferralHandler(msg.sender).ownedBy();
        uint256 newTier = IReferralHandler(msg.sender).getTier().add(1);
        return validateUserTier(owner, newTier, tierCounts); // If it returns true it means user is eligible for an upgrade in tier
    }

    function recoverTokens(address token, address benefactor) public onlyAdmin {
        uint256 tokenBalance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(benefactor, tokenBalance);
    }
}