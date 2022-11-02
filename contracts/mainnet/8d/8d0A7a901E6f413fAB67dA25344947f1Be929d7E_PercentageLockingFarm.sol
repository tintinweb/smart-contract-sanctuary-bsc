// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

//import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./utils/EmergencyFunctions.sol";
import "./utils/TestUtils.sol";
import "./utils/ContractAndOwnerUtils.sol";

    struct FarmConfig {
        address farmToken;
        address rewardToken;
        uint256 change;
        bool isDivision;
        uint256 earningInPeriod;
        uint256 earningPeriodInSeconds;
        uint256 lockPeriodBeforeWithdraw;
    }

    struct Deposit {
        address wallet;
        address token;
        uint256 depositTime;
        uint256 quantity;
        uint256 rewardsTaken;
        uint256 depositWithdrawn;
        uint256 lastWithdrawTime;
    }

contract DepositStorage is ContractAndOwnerUtils, TestFunctions {

    FarmConfig public farmConfig;
    mapping(address => uint256) public depositsByWallet;
    mapping(address => uint256) public depositsWithdrawnByWallet;
    mapping(address => Deposit[]) public deposits;

    constructor() ContractAndOwnerUtils(address(this), msg.sender) {}

    function setFarmConfig(address _farmToken, address _rewardToken, uint256 _change, bool _isDivision,
        uint256 _earningInPeriod, uint256 _earningPeriodInSeconds, uint256 _lockPeriodBeforeWithdraw) public onlyCreatorContractOrOwner {
        farmConfig = FarmConfig(_farmToken, _rewardToken, _change, _isDivision, _earningInPeriod, _earningPeriodInSeconds, _lockPeriodBeforeWithdraw);
    }

    function doDeposit(address _wallet, address _token, uint256 _quantity) public onlyCreatorContractOrOwner {
        Deposit memory deposit = Deposit(_wallet, _token, currentTimestamp(), _quantity, 0, 0, currentTimestamp());
        deposits[_wallet].push(deposit);
        depositsByWallet[_wallet] += 1;
    }

    function updateDeposit(uint256 counter, address _wallet, uint256 _rewardsTaken, uint256 _depositWithdrawn) public onlyCreatorContractOrOwner {
        Deposit storage deposit = deposits[_wallet][counter];
        deposit.rewardsTaken += _rewardsTaken;
        deposit.depositWithdrawn += _depositWithdrawn;
        if (deposit.depositWithdrawn == deposit.quantity) {
            depositsWithdrawnByWallet[_wallet] += 1;
        }
        deposit.lastWithdrawTime = currentTimestamp();
    }
}

//Implementation to have a percentage base reward on the amount of token put in the farm. With a lock time of x seconds.
contract PercentageLockingFarm is ReentrancyGuard, ContractAndOwnerUtils, EmergencyFunctions, TestFunctions {
    using SafeMath for uint256;

    DepositStorage public depositStorage;
    uint256 public totalInFarm = 0;

    constructor(address _depStorage) ContractAndOwnerUtils(address(this), msg.sender) EmergencyFunctions(msg.sender) {
        if (address(depositStorage) == address(0)) {
            depositStorage = new DepositStorage();
            depositStorage.transferOwnership(msg.sender);
        } else {
            depositStorage = DepositStorage(_depStorage);
            depositStorage.updateCreatorContract(msg.sender);
        }
    }

    function setupFarm(address _farmToken, address _rewardToken, uint256 _change, bool _isDivision,
        uint256 _earningInPeriod, uint256 _earningPeriodInSeconds, uint256 _lockPeriodBeforeWithdraw) public onlyCreatorContractOrOwner {
        depositStorage.setFarmConfig(_farmToken, _rewardToken, _change, _isDivision, _earningInPeriod, _earningPeriodInSeconds, _lockPeriodBeforeWithdraw);
    }

    function internalDeposit(uint256 _amount, bool getFarmTokenFromSender) private {
        (address farmTokenAddress, , , , , , ) = depositStorage.farmConfig();
        IERC20 farmToken = IERC20(farmTokenAddress);
        require(_amount > 0, "Should Deposit More than zero");
        require(farmToken.balanceOf(msg.sender) >= _amount, "Customer is depositing more token that it owns");
        if (getFarmTokenFromSender) {
            farmToken.transferFrom(msg.sender, address(this), _amount);
        }
        depositStorage.doDeposit(msg.sender, address(this), _amount);
        totalInFarm += _amount;
    }

    function deposit(uint256 _amount) public {
        internalDeposit(_amount, true);
    }

    function withdraw(uint256 amount) public {
        require(amountThatCanBeWithdrawn() >= amount, "Not enough tokens to withdraw");
        getRewards();
        (address farmTokenAddress,,,,,,) = depositStorage.farmConfig();
        IERC20 farmToken = IERC20(farmTokenAddress);
        farmToken.transfer(msg.sender, amount);
        updateDeposits(false, amount);
        totalInFarm -= amount;
    }

    function updateDeposits(bool gettingRewards, uint256 amountWithdrawn) private {
        uint256 depositsDone = depositStorage.depositsByWallet(msg.sender);
        uint256 depositsWithdrawn = depositStorage.depositsWithdrawnByWallet(msg.sender);
        uint256 rewardsToTake = 0;
        uint256 amountToWithdrawRemaining = amountWithdrawn;
        for (uint256 i = depositsWithdrawn; i < depositsDone; i++) {
            (, , , uint256 quantity, , uint256 depositWithdrawn, uint256 lastWithdrawTime) = depositStorage.deposits(msg.sender, i);
            if (gettingRewards)
                rewardsToTake = computeReward(quantity - depositWithdrawn, lastWithdrawTime);
            uint256 amountToWithdrawForDeposit = quantity - depositWithdrawn;
            if (amountToWithdrawForDeposit >= amountToWithdrawRemaining) {
                amountToWithdrawForDeposit = amountToWithdrawRemaining;
            }
            depositStorage.updateDeposit(i, msg.sender, rewardsToTake, amountToWithdrawForDeposit);
            amountToWithdrawRemaining -= amountToWithdrawForDeposit;
        }
    }

    function getRewards() public {
        uint256 earnedSoFar = rewardsEarned();
        updateDeposits(true, 0);
        (,address rewardTokenAddress,,,,,) = depositStorage.farmConfig();
        IERC20 rewardToken = IERC20(rewardTokenAddress);
        rewardToken.transfer(msg.sender, earnedSoFar);
    }

    function compoundRewards() public {
        require(compoundIsAvailable(), "Compound can't be done when farming different tokens");
        uint256 earnedSoFar = rewardsEarned();
        updateDeposits(true, 0);
        internalDeposit(earnedSoFar, false);
    }

    function depositsCombinations(address _wallet) private view returns (uint256 _amountInFarm, uint256 _rewardsRetrieved, uint256 _amountThatCanBeWithdrawn) {
        uint256 depositsDone = depositStorage.depositsByWallet(_wallet);
        uint256 depositsWithdrawn = depositStorage.depositsWithdrawnByWallet(_wallet);
        (,,,,,,uint256 lockPeriodBeforeWithdraw) = depositStorage.farmConfig();
        for (uint256 i = depositsWithdrawn; i < depositsDone; i++) {
            (, , uint256 depositTime, uint256 quantity, uint256 rewardsTaken, uint256 depositWithdrawn, ) = depositStorage.deposits(_wallet, i);
            _amountInFarm += quantity - depositWithdrawn;
            _rewardsRetrieved += rewardsTaken;
            if (currentTimestamp() - depositTime >= lockPeriodBeforeWithdraw)
                _amountThatCanBeWithdrawn += quantity - depositWithdrawn;
        }
        return (_amountInFarm, _rewardsRetrieved, _amountThatCanBeWithdrawn);
    }

    function amountInFarmForWallet(address _wallet) public view returns(uint256) {
        (uint256 _amountInFarm, , ) = depositsCombinations(_wallet);
        return _amountInFarm;
    }

    function amountInFarm() public view returns(uint256) {
        return amountInFarmForWallet(msg.sender);
    }

    function computeReward(uint256 amount, uint256 lastWithdrawTime) private view returns(uint256){
        (,,,, uint256 earningInPeriod, uint256 earningPeriodInSeconds,) = depositStorage.farmConfig();
        return amount.mul(earningInPeriod).div(100).mul(currentTimestamp().sub(lastWithdrawTime)).div(earningPeriodInSeconds);
    }

    function rewardsEarnedForWallet(address _wallet) public view returns(uint256) {
        uint256 depositsDone = depositStorage.depositsByWallet(_wallet);
        uint256 depositsWithdrawn = depositStorage.depositsWithdrawnByWallet(_wallet);
        uint256 totalRewards = 0;
        for (uint256 i = depositsWithdrawn; i < depositsDone; i++) {
            (,,, uint256 quantity,, uint256 depositWithdrawn, uint256 lastWithdrawTime) = depositStorage.deposits(_wallet, i);
            uint256 _amountInFarm = quantity - depositWithdrawn;
            totalRewards += computeReward(_amountInFarm, lastWithdrawTime);
        }
        return totalRewards;
    }

    function rewardsEarned() public view returns(uint256) {
        return rewardsEarnedForWallet(msg.sender);
    }

    function rewardsRetrievedForWallet(address _wallet) public view returns(uint256) {
        (, uint256 _rewardsRetrieved,) = depositsCombinations(_wallet);
        return _rewardsRetrieved;
    }

    function rewardsRetrieved() public view returns(uint256) {
        return rewardsRetrievedForWallet(msg.sender);
    }

    function lastDepositTimeForWallet(address _wallet) public view returns(uint256) {
        (, , uint256 depositTime, , , ,) = depositStorage.deposits(_wallet, depositStorage.depositsByWallet(_wallet) - 1);
        return depositTime;
    }

    function lastDepositTime() public view returns(uint256) {
        return lastDepositTimeForWallet(msg.sender);
    }

    function amountThatCanBeWithdrawnForWallet(address _wallet) public view returns(uint256) {
        (,, uint256 _amountThatCanBeWithdrawn) = depositsCombinations(_wallet);
        return _amountThatCanBeWithdrawn;
    }

    function amountThatCanBeWithdrawn() public view returns(uint256) {
        return amountThatCanBeWithdrawnForWallet(msg.sender);
    }

    function compoundIsAvailable() public view returns(bool) {
        (address farmToken, address rewardToken,,,,,) = depositStorage.farmConfig();
        return farmToken == rewardToken;
    }

    function farmConfig() public view returns (address, address, uint256, bool, uint256, uint256, uint256) {
        return depositStorage.farmConfig();
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EmergencyFunctions is Ownable {
    address teamAddress;
    constructor(address _teamAddress) {
        teamAddress = _teamAddress;
    }
    // Emergency Functions
    function sendTokenToTeam(address _token) public onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        if (amount > 0) {
            IERC20(_token).transfer(teamAddress, amount);
        }
    }

    function sendBnbToTeam() public onlyOwner {
        if (address(this).balance > 0) {
            payable(teamAddress).transfer(address(this).balance);
        }
    }

    /** @notice Check if an address is a contract */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.x <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20Extension {
    function decimals() external view returns (uint8);
}

contract TestFunctions is Ownable {
    constructor() {}
    //Used for mock testing, contract ownership will be renounced on release
    uint public currentTimestampOverride;
    function updateCurrentTimestampOverride(uint _v) external onlyOwner {
        currentTimestampOverride = _v;
    }
    function currentTimestamp() public view returns(uint) {
        if (currentTimestampOverride > 0) {
            return currentTimestampOverride;
        }
        return block.timestamp;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.x <0.9.0;

contract ContractAndOwnerUtils {
    address _creatorContract;
    address _owner;
    constructor(address _c, address _o) {
        _creatorContract = _c;
        _owner = _o;
    }

    modifier onlyCreatorContractOrOwner() {
        require(_owner == msg.sender || _creatorContract == msg.sender, "Only owner or creator contract can call this function");
        _;
    }

    modifier onlyCreatorContract() {
        require(_creatorContract == msg.sender, "CreatorContractNotCalling: caller is not the creator contract");
        _;
    }

    modifier onlyFromOwner() {
        require(_owner == msg.sender, "OwnerNotCalling: caller is not the owner");
        _;
    }

    function updateOwner(address _newOwner) public onlyFromOwner {
        _owner = _newOwner;
    }

    function updateCreatorContract(address _newCreatorContract) public onlyCreatorContractOrOwner {
        _creatorContract = _newCreatorContract;
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