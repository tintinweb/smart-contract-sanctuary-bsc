// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.3;
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPinkSalePool} from "./interfaces/IPinkSalePool.sol";
import {IBallToken} from "./interfaces/IBallToken.sol";
import {IReferral} from "./interfaces/IReferral.sol";

contract SiuMultisend is Pausable, Ownable {
    using SafeMath for uint256;

    IERC20 public siu;
    IBallToken public ball;
    IPinkSalePool public pinkSale;
    IReferral public referral;
    mapping(address => bool) public minted;
    uint256 public siuPerBall = 10;
    uint256 public siuPerUSDT = 1130 * 10**18;

    constructor(
        address _ball,
        address _siu,
        address _pinkSale,
        address _ref
    ) {
        siu = IERC20(_siu);
        ball = IBallToken(_ball);
        pinkSale = IPinkSalePool(_pinkSale);
        referral = IReferral(_ref);
    }

    function airdrop(
        address[] memory _users,
        uint256 _amountBall,
        uint256 _amountSiu
    ) public onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            siu.transfer(_users[i], _amountSiu);
            ball.mint(_users[i], _amountBall);
        }
    }

    function sendBallPinkSale(uint256 _startIndex, uint256 _endIndex) public onlyOwner {
        require(_startIndex < _endIndex, "startIndex must be less than endIndex");
        address[] memory users = pinkSale.getContributors(_startIndex, _endIndex);
        for (uint256 i = 0; i < users.length; i++) {
            if(!minted[users[i]]){
                uint256 amountUSDT = pinkSale.contributionOf(users[i]);
                uint256 amountBall = getBallAmountReceive(amountUSDT);
                minted[users[i]] = true;
                ball.mint(users[i], amountBall);
                referral.setIsRecevicedAddress(users[i]);
            }
        }
    }

    function totalContribution() public view returns (uint256) {
        return pinkSale.getContributorCount();
    }

    function getBallAmountReceive(uint256 _usdt) public view returns (uint256) {
        uint256 siuuuAmount = _usdt.mul(siuPerUSDT).div(10**18);
        return siuuuAmount.div(1e18).div(siuPerBall);
    }

    function safu() public onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }

    function safuToken(address _token) public onlyOwner {
        IERC20(_token).transfer(owner(), IERC20(_token).balanceOf(address(this)));
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface IPinkSalePool {
    event Cancelled(uint256 timestamp);
    event Claimed(address indexed user, uint256 volume, uint256 total);
    event Contributed(address indexed user, uint256 amount, uint256 volume, uint256 total, uint256 timestamp);
    event EmergencyWithdrawContribution(address indexed user, uint256 amount, uint256 total, uint256 timestamp);
    event FinalizedAndListed(uint256 liquidity, uint256 timestamp);
    event FinalizedAndWithdrawFund(uint256 fund, uint256 timestamp);
    event KycUpdated(string kycDetails, uint256 timestamp);
    event LiquidityWithdrawn(uint256 amount, uint256 timestamp);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PoolUpdated(uint256 timestamp);
    event VestingTokenWithdrawn(uint256 amount, uint256 timestamp);
    event WithdrawnContribution(address indexed user, uint256 amount);

    function cancel() external;

    function claim() external;

    function claimedOf(address) external view returns (uint256);

    function contribute() external payable;

    function contributeCustomCurrency(uint256 amount) external;

    function contributionOf(address) external view returns (uint256);

    function contributorVestingSettings()
        external
        view
        returns (
            uint256 tgeReleasePct,
            uint256 cycleReleasePct,
            uint256 cycle
        );

    function convert(uint256 amountInWei) external view returns (uint256);

    function distributePurchasedTokens(uint256 start, uint256 end) external;

    function distributeRefund(uint256 start, uint256 end) external;

    function distributionCompleted(uint8 distributedType) external view returns (bool);

    function emergencyWithdraw(address to_, address token_) external;

    function emergencyWithdrawContribution() external;

    function factory() external view returns (address);

    function finalizeAndList() external;

    function finalizeAndWithdrawFund() external;

    function getContributionAmount(address user_) external view returns (uint256, uint256);

    function getContributionSettings() external view returns (uint256 min, uint256 max);

    function getContributorCount() external view returns (uint256);

    function getContributors(uint256 start, uint256 end) external view returns (address[] memory);

    function getNumberOfWhitelistedUsers() external view returns (uint256);

    function getRequiredListingTokens() external view returns (uint256);

    function getRequiredPresaleTokens() external view returns (uint256);

    function getUndistributedIndexes(uint8 distributedType) external view returns (uint256[] memory);

    function getWhitelistedUsers(uint256 startIndex, uint256 endIndex) external view returns (address[] memory);

    function initialize(
        PoolStorageLibrary.PoolSettings memory _poolSettings,
        address _router,
        address _owner,
        uint256 _publicSaleStartTime,
        string memory _poolDetails
    ) external;

    function initializeContributorVesting(
        PoolStorageLibrary.ContributorVestingSettings memory _contributorVestingSettings
    ) external;

    function initializeOwnerVesting(PoolStorageLibrary.OwnerVestingSettings memory _ownerVestingSettings) external;

    function isGovernor(address user) external view returns (bool);

    function isUserWhitelisted(address user) external view returns (bool);

    function owner() external view returns (address);

    function ownerVestingSettings()
        external
        view
        returns (
            uint256 totalVestingTokens,
            uint256 tgeLockDuration,
            uint256 cycle,
            uint256 tgeReleasePct,
            uint256 cycleReleasePct
        );

    function poolSettings()
        external
        view
        returns (
            address token,
            address currency,
            uint256 startTime,
            uint256 endTime,
            uint256 softCap,
            uint256 maxOwnerReceive,
            uint256 totalSellingTokens,
            uint256 liquidityLockDays,
            uint128 liquidityPercent
        );

    function poolStates()
        external
        view
        returns (
            uint8 state,
            uint256 finishTime,
            uint256 totalRaised,
            uint256 totalVolumePurchased,
            uint256 publicSaleStartTime,
            uint256 liquidityUnlockTime,
            uint256 totalVestedTokens,
            int256 lockId,
            string memory poolDetails,
            string memory kycDetails
        );

    function purchasedOf(address) external view returns (uint256);

    function refundedOf(address) external view returns (uint256);

    function renounceOwnership() external;

    function router() external view returns (address);

    function setPublicSaleStartTime(uint256 _publicSaleStartTime) external;

    function setSellingToken(address _token) external;

    function setWhitelistedUsers(address[] memory users, bool add) external;

    function setupHoldToken(address _token, uint256 _minAmount) external;

    function tgeTime() external view returns (uint256);

    function tokenHoldSettings() external view returns (address token, uint256 amount);

    function transferListingTokens() external;

    function transferOwnership(address newOwner) external;

    function transferPresaleTokens() external;

    function updateKycDetails(string memory kycDetails_) external;

    function updatePoolDetails(string memory details_) external;

    function version() external pure returns (uint256);

    function withdrawCancelledTokens() external;

    function withdrawContribution() external;

    function withdrawVestingToken() external;

    function withdrawableContributorVestingTokens(address user) external view returns (uint256);

    function withdrawableTokens() external view returns (uint256);
}

interface PoolStorageLibrary {
    struct PoolSettings {
        address token;
        address currency;
        uint256 startTime;
        uint256 endTime;
        uint256 rate;
        uint256[2] contributionSetting;
        uint256 softCap;
        uint256 hardCap;
        uint256 liquidityListingRate;
        uint256 liquidityLockDays;
        uint256 liquidityPercent;
        uint128 ethFeePercent;
        uint128 tokenFeePercent;
    }

    struct ContributorVestingSettings {
        uint256 tgeReleasePct;
        uint256 cycleReleasePct;
        uint256 cycle;
    }

    struct OwnerVestingSettings {
        uint256 totalVestingTokens;
        uint256 tgeLockDuration;
        uint256 cycle;
        uint256 tgeReleasePct;
        uint256 cycleReleasePct;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

interface IBallToken {
    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

interface IReferral {
    function setReferral(address _from, address _to) external;

    function setIsRecevicedAddress(address _to) external;

    function sendRewards(address siuuuer, uint256 _amount) external;

    function getRelations(address _address) external view returns (address[5] memory);
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