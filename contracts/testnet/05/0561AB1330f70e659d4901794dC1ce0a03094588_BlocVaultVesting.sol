// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BlocVaultVesting is Ownable, ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public     isActive = false;
    bool private    initialized = false;

    IERC20  public  vestingToken;
    address public  reflectionToken;
    uint256 private accReflectionPerShare;
    uint256 private allocatedReflections;
    uint256 private reflectionDebt;

    uint256[4] public duration = [90, 180, 240, 360];
    uint256 public rewardCycle = 30;    // 30 days
    uint256 public rewardRate = 1000;   // 10% per 30 days

    uint256 public harvestCycle = 7; // 7 days

    uint256 private PRECISION_FACTOR = 1 ether;
    // uint256 private TIME_UNIT = 1 days;
    uint256 private TIME_UNIT = 1;

    struct UserInfo {
        uint256 counts;          // number of vesting
        uint256 totalVested;     // vested total amount in wei
    }

    struct VestingInfo {
        uint256 amount;             // vested amount
        uint256 duration;           // lock duration in day
        uint256 lockedTime;         // timestamp that user locked tokens
        uint256 releaseTime;        // timestamp that user can unlock tokens
        uint256 lastHarvestTime;    // last timestamp that user harvested reflections of vested tokens
        uint256 tokenDebt;          // amount that user havested reward
        uint256 reflectionDebt;
        uint8   status;
    }
   
    uint256 public totalVested = 0;
    uint256 private totalEarned;
    mapping(address => UserInfo) public userInfo;
    mapping(address => mapping(uint256 => VestingInfo))  public vestingInfos;

    event Vested(address user, uint256 id, uint256 amount, uint256 duration);
    event Released(address user, uint256 id, uint256 amount);
    event Revoked(address user, uint256 id, uint256 amount);
    event RewardClaimed(address user, uint256 amount);
    event DividendClaimed(address user, uint256 amount);
    event EmergencyWithdrawn(address indexed user, uint256 amount);
    event DurationUpdated(uint256 idx, uint256 duration);
    event RateUpdated(uint256 rate);
        
    modifier onlyActive() {
        require(isActive == true, "not active");
        _;
    }

    constructor () {}

    function initialize(IERC20 _token, address _reflectionToken) external onlyOwner {
        require(initialized == false, "already initialized");
        initialized = true;

        vestingToken = _token;
        reflectionToken = _reflectionToken;
    }

    function vest(uint256 _amount, uint256 _type) external onlyActive nonReentrant {
        require(_amount > 0, "Invalid amount");
        require(_type < 4, "Invalid vesting type");

        _updatePool();
        
        uint256 beforeAmount = vestingToken.balanceOf(address(this));
        vestingToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmount = vestingToken.balanceOf(address(this));
        uint256 realAmount = afterAmount.sub(beforeAmount);
        
        UserInfo storage _userInfo = userInfo[msg.sender];
        
        uint256 lastIndex = _userInfo.counts;
        vestingInfos[msg.sender][lastIndex] = VestingInfo(
            realAmount,
            duration[_type],
            block.timestamp,
            block.timestamp.add(duration[_type].mul(TIME_UNIT)),
            block.timestamp,
            0,
            realAmount.mul(accReflectionPerShare).div(PRECISION_FACTOR),
            0
        );
        
        _userInfo.counts = lastIndex.add(1);
        _userInfo.totalVested = _userInfo.totalVested.add(realAmount);

        totalVested = totalVested.add(realAmount);

        emit Vested(msg.sender, lastIndex, _amount, duration[_type]);
    }

    function revoke(uint256 _vestId) external onlyActive nonReentrant {
        VestingInfo storage _vest = vestingInfos[msg.sender][_vestId];
        require(_vest.amount > 0 && _vest.status == 0, "Not available");

        vestingToken.safeTransfer(msg.sender, _vest.amount);

        _vest.status = 2;

        UserInfo storage _userInfo = userInfo[msg.sender];
        _userInfo.totalVested = _userInfo.totalVested.sub(_vest.amount);
        totalVested = totalVested.sub(_vest.amount);

        emit Revoked(msg.sender, _vestId, _vest.amount);
    }

    function release(uint256 _vestId) external onlyActive nonReentrant {
        VestingInfo storage _vest = vestingInfos[msg.sender][_vestId];

        require(_vest.amount > 0 && _vest.status == 0, "Not available");
        require(_vest.releaseTime < block.timestamp, "Not Releasable");

        _updatePool();

        uint pending = calcReward(_vest.amount, _vest.lockedTime, _vest.releaseTime, _vest.tokenDebt);
        require(pending <= availableRewardTokens(), "Insufficient reward");

        uint256 claimAmt = _vest.amount.add(pending);
        if(claimAmt > 0) {
            vestingToken.safeTransfer(msg.sender, claimAmt);
            emit RewardClaimed(msg.sender, pending);
        }

        if(totalEarned > pending) {
            totalEarned = totalEarned.sub(pending);
        } else {
            totalEarned = 0;
        }

        uint256 reflectionAmt = _vest.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(_vest.reflectionDebt);
        if(reflectionAmt > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(reflectionAmt);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, reflectionAmt);
            }
            allocatedReflections = allocatedReflections.sub(reflectionAmt);
            emit DividendClaimed(msg.sender, reflectionAmt);
        }

        _vest.tokenDebt = _vest.tokenDebt.add(pending);
        _vest.reflectionDebt = _vest.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);
        _vest.status = 1;

        UserInfo storage _userInfo = userInfo[msg.sender];
        _userInfo.totalVested = _userInfo.totalVested.sub(_vest.amount);
        totalVested = totalVested.sub(_vest.amount);

        emit Released(msg.sender, _vestId, _vest.amount);
    }

    function claimDividend(uint256 _vestId) external onlyActive nonReentrant {
        VestingInfo storage _vest = vestingInfos[msg.sender][_vestId];
        require(_vest.amount > 0 && _vest.status == 0, "Not available");
        require(block.timestamp.sub(_vest.lastHarvestTime) > harvestCycle.mul(TIME_UNIT), "Cannot harvest in 7 days after last harvest");

        _updatePool();

        uint256 reflectionAmt = _vest.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(_vest.reflectionDebt);
        if(reflectionAmt > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(reflectionAmt);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, reflectionAmt);
            }

            allocatedReflections = allocatedReflections.sub(reflectionAmt);
            emit DividendClaimed(msg.sender, reflectionAmt);
        }

        _vest.lastHarvestTime = block.timestamp;
        _vest.reflectionDebt = _vest.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);
    }

    function claimReward(uint256 _vestId) external onlyActive nonReentrant {
        VestingInfo storage _vest = vestingInfos[msg.sender][_vestId];
        require(_vest.amount > 0 && _vest.status == 0, "Not available");
        require(block.timestamp.sub(_vest.lastHarvestTime) > harvestCycle.mul(TIME_UNIT), "Cannot harvest in 7 days after last harvest");

        uint pending = calcReward(_vest.amount, _vest.lockedTime, _vest.releaseTime, _vest.tokenDebt);
        require(pending <= availableRewardTokens(), "Insufficient reward");

        if(pending > 0) {
            vestingToken.safeTransfer(msg.sender, pending);
            emit RewardClaimed(msg.sender, pending);

            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned = 0;
            }
        }        

        _vest.lastHarvestTime = block.timestamp;
        _vest.tokenDebt = _vest.tokenDebt.add(pending);
    }

    function calcReward(uint256 _amount, uint256 _lockedTime, uint256 _releaseTime, uint256 _rewardDebt) internal view returns(uint256 reward) {
        if(_lockedTime > block.timestamp) return 0;

        uint256 passTime = block.timestamp.sub(_lockedTime);
        if(_releaseTime < block.timestamp) {
            passTime = _releaseTime.sub(_lockedTime);
        }

        reward = _amount.mul(rewardRate).div(10000)
                        .mul(passTime).div(rewardCycle.mul(TIME_UNIT))
                        .sub(_rewardDebt);
    }

    function pendingClaim(address _user, uint256 _vestId) external view returns (uint256 pending) {
        VestingInfo storage _vest = vestingInfos[_user][_vestId];
        if(_vest.status > 0 || _vest.amount == 0) return 0;

        pending = calcReward(_vest.amount, _vest.lockedTime, _vest.releaseTime, _vest.tokenDebt);
    }

    function pendingDividend(address _user, uint256 _vestId) external view returns (uint256 pending) {
        VestingInfo storage _vest = vestingInfos[_user][_vestId];
        if(_vest.status > 0 || _vest.amount == 0) return 0;

        uint256 tokenAmt = vestingToken.balanceOf(address(this));
        if(tokenAmt == 0) return 0;

        uint256 reflectionAmt = availableDividendTokens();
        reflectionAmt = reflectionAmt.sub(allocatedReflections);
        uint256 _accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(tokenAmt));

        pending = _vest.amount.mul(_accReflectionPerShare).div(PRECISION_FACTOR).sub(_vest.reflectionDebt);
    }

    /**
     * @notice Available amount of reflection token
     */
    function availableDividendTokens() public view returns (uint256) {
        if(address(reflectionToken) == address(0x0)) {
            return address(this).balance;
        }

        if(address(reflectionToken) == address(vestingToken)) {
            uint256 _amount = IERC20(reflectionToken).balanceOf(address(this));
            if(_amount < totalEarned.add(totalVested)) return 0;
            return _amount.sub(totalEarned).sub(totalVested);
        } else {
            uint256 _amount = address(this).balance;
            if(reflectionToken != address(0x0)) {
                _amount = IERC20(reflectionToken).balanceOf(address(this));
            }
            return _amount;
        }
    }
    
    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        if(address(vestingToken) == address(reflectionToken)) return totalEarned;

        uint256 _amount = vestingToken.balanceOf(address(this));
        if (_amount < totalVested) return 0;
        return _amount.sub(totalVested);
    }

     /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external nonReentrant {
        require(_amount > 0);

        uint256 beforeAmt = vestingToken.balanceOf(address(this));
        vestingToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = vestingToken.balanceOf(address(this));

        totalEarned = totalEarned.add(afterAmt).sub(beforeAmt);
    }

    function harvest() external onlyOwner {
        _updatePool();

        uint256 tokenAmt = availableRewardTokens();
        uint256 reflectionAmt = (tokenAmt).mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(reflectionDebt);
        if(reflectionAmt > 0) {
            payable(msg.sender).transfer(reflectionAmt);
        } else {
            IERC20(reflectionToken).safeTransfer(msg.sender, reflectionAmt);
        }

        reflectionDebt = (tokenAmt.sub(totalVested)).mul(accReflectionPerShare).div(PRECISION_FACTOR);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = vestingToken.balanceOf(address(this));
        if(tokenAmt > 0) {
            vestingToken.transfer(msg.sender, tokenAmt.sub(totalVested));
        }

        if(address(reflectionToken) != address(vestingToken)) {
            uint256 reflectionAmt = address(this).balance;
            if(reflectionToken != address(0x0)) {
                reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
            }

            if(reflectionAmt > 0) {
                if(reflectionToken == address(0x0)) {
                    payable(msg.sender).transfer(reflectionAmt);
                } else {
                    IERC20(reflectionToken).transfer(msg.sender, reflectionAmt);
                }
            }
        }

        totalEarned = 0;

        allocatedReflections = 0;
        accReflectionPerShare = 0;
        reflectionDebt = 0;
    }

    function recoverWrongToken(address _token) external onlyOwner {
        require(_token != address(vestingToken), "Cannot recover locked token");
        require(_token != reflectionToken, "Cannot recover reflection token");

        if(_token == address(0x0)) {
            uint256 amount = address(this).balance;
            payable(msg.sender).transfer(amount);
        } else {
            uint256 amount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(address(msg.sender), amount);
        }
    }

    function setDuration(uint256 _type, uint256 _duration) external onlyOwner {
        require(isActive == false, "Vesting was started");

        duration[_type] = _duration;
        emit DurationUpdated(_type, _duration);
    }

    function setRewardRate(uint256 _rate) external onlyOwner {
        require(isActive == false, "Vesting was started");

        rewardRate = _rate;
        emit RateUpdated(_rate);
    }

    function setStatus(bool _isActive) external onlyOwner {
        isActive = _isActive;
    }

    function _updatePool() internal {
        uint256 tokenAmt = availableRewardTokens();
        tokenAmt = tokenAmt.add(totalVested);
        if(tokenAmt == 0) return;

        uint256 reflectionAmt = availableDividendTokens();
        reflectionAmt = reflectionAmt.sub(allocatedReflections);

        accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(tokenAmt));
        allocatedReflections = allocatedReflections.add(reflectionAmt);
    }
}

// SPDX-License-Identifier: MIT

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

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
    function transferFrom(
        address sender,
        address recipient,
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

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}