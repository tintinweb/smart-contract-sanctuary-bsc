// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./SafeMath.sol";
import "./DataStorage.sol";
import "./Events.sol";
import "./Utils.sol";
import "./IBEP20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./Pausable.sol";

contract Staking is
    Ownable,
    ReentrancyGuard,
    Pausable,
    DataStorage,
    Events,
    Utils
{
    using SafeMath for uint256;

    /**
     * @dev Constructor function
     */
    constructor(address payable wallet, IBEP20 _bep20) public {
        commissionWallet = wallet;
        stakingToken = _bep20;
        plans.push(Plan(0, 16, 0 ether, 90000000 ether));
        plans.push(Plan(30, 33, 0 ether, 90000000 ether));
        plans.push(Plan(90, 50, 0 ether, 90000000 ether));
        plans.push(Plan(180, 66, 0 ether, 90000000 ether));
        plans.push(Plan(365, 116, 0 ether, 90000000 ether));
    }

    function invest(uint8 plan, uint256 _amount, address _refferer)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        require(_amount > plans[plan].minInvest, "Invest amount isn't enough");
        require(_amount <= plans[plan].maxInvest, "Invest amount too much");

        require(plan < 6, "Invalid plan");
        require(
            stakingToken.allowance(msg.sender, address(this)) >= _amount,
            "Token allowance too low"
        );
        _invest(plan, msg.sender, _amount, _refferer);
        if (PROJECT_FEE > 0) {
            commissionWallet.transfer(PROJECT_FEE);
            emit FeePayed(msg.sender, PROJECT_FEE);
        }
    }

    function _invest(
        uint8 plan,
        address userAddress,
        uint256 _amount,
        address _refferer
    ) internal {
        User storage user = users[userAddress];
        user.refferer = _refferer;
        uint256 currentTime = block.timestamp;
        require(
            user.lastStake.add(TIME_STAKE) <= currentTime,
            "Required: Must be take time to stake"
        );
        _safeTransferFrom(userAddress, address(this), _amount);
        user.lastStake = currentTime;
        user.owner = userAddress;
        user.registerTime = currentTime;
        user.isImport = false;

        if (user.deposits.length == 0 && !user.isImport) {
            user.checkpoint = currentTime;
            emit Newbie(userAddress, currentTime);
            totalUser.push(user);
        }

        (uint256 percent, uint256 finish) = getResult(plan);
        user.deposits.push(
            Deposit(
                plan,
                percent,
                _amount,
                currentTime,
                finish,
                userAddress,
                PROJECT_FEE,
                false
            )
        );
        totalStakedAmount = totalStakedAmount.add(_amount);
        totalDeposits.push(
            Deposit(
                plan,
                percent,
                _amount,
                currentTime,
                finish,
                userAddress,
                PROJECT_FEE,
                false
            )
        );

        emit NewDeposit(
            userAddress,
            plan,
            percent,
            _amount,
            currentTime,
            finish,
            PROJECT_FEE
        );
    }

    function _safeTransferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        bool sent = stakingToken.transferFrom(_sender, _recipient, _amount);
        require(sent, "Token transfer failed");
    }

    function investNoFee(UserNoFee[] memory userNoFee)
        external
        onlyOwner
    {
        _investNoFee(userNoFee);
    }

    function _investNoFee(UserNoFee[] memory userNoFee) internal {
        for (uint256 index = 0; index < userNoFee.length; index++) {
            User storage user = users[userNoFee[index].userAddress];
            if (user.registerTime == 0) {
                user.owner = userNoFee[index].userAddress;
                user.registerTime = block.timestamp;

                user.isImport = true;

                if (user.deposits.length == 0) {
                    user.checkpoint = block.timestamp;
                }

                totalUser.push(user);
            }
        }
    }

    function withdraw() external nonReentrant whenNotPaused {
        User storage user = users[msg.sender];
        uint256 totalAmount = getUserDividends(msg.sender);

        require(
            user.checkpoint.add(TIME_WITHDRAWN) <= block.timestamp,
            "Required: Withdrawn one time every day"
        );
        uint256 commissionF1;
        if (user.refferer != address(0)) {
            commissionF1 = totalAmount.mul(PERCENT_COM).div(PERCENTS_DIVIDER);
            stakingToken.transfer(user.refferer, commissionF1);
            emit Commission(user.refferer, commissionF1);
        }
        user.checkpoint = block.timestamp;
        stakingToken.transfer(user.owner, totalAmount.sub(commissionF1));
        user.totalPayout = user.totalPayout.add(totalAmount);
        emit Withdrawn(msg.sender, totalAmount);
    }

    function unStake(uint256 start)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        require(msg.value == UNLOCK_FEE, "Required: Pay fee for unlock stake");
        User storage user = users[msg.sender];
        uint256 totalAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                user.deposits[i].start == start &&
                user.deposits[i].isUnStake == false &&
                (user.deposits[i].finish > user.checkpoint ||
                    user.deposits[i].plan == 0)
            ) {
                uint256 share = user
                    .deposits[i]
                    .amount
                    .mul(user.deposits[i].percent)
                    .div(PERCENTS_DIVIDER);
                uint256 from = user.deposits[i].start > user.checkpoint
                    ? user.deposits[i].start
                    : user.checkpoint;
                uint256 to = user.deposits[i].finish < block.timestamp
                    ? user.deposits[i].finish
                    : block.timestamp;

                if (user.deposits[i].plan == 0) {
                    to = block.timestamp;
                }
                totalAmount = totalAmount.add(
                    share.mul(to.sub(from)).div(TIME_STEP)
                );
            }

            if (
                user.deposits[i].start == start &&
                user.deposits[i].isUnStake == false &&
                (block.timestamp >= user.deposits[i].finish ||
                    user.deposits[i].plan == 0)
            ) {
                user.deposits[i].isUnStake = true;
                totalAmount = totalAmount.add(user.deposits[i].amount);
                uint256 commissionF1;
                if (user.refferer != address(0)) {
                    commissionF1 = totalAmount.mul(PERCENT_COM).div(
                        PERCENTS_DIVIDER
                    );
                    stakingToken.transfer(user.refferer, commissionF1);
                    emit Commission(user.refferer, commissionF1);
                }
                stakingToken.transfer(
                    user.owner,
                    totalAmount.sub(commissionF1)
                );
                user.totalPayout = user.totalPayout.add(totalAmount);
                emit UnStake(msg.sender, start, user.deposits[i].amount);
                commissionWallet.transfer(UNLOCK_FEE);
                emit FeePayed(msg.sender, UNLOCK_FEE);
            }
        }
    }

    function setFeeSystem(uint256 _fee) external onlyOwner {
        PROJECT_FEE = _fee;
    }

    function setUnlockFeeSystem(uint256 _fee) external onlyOwner {
        UNLOCK_FEE = _fee;
    }

    function setTime_Step(uint256 _timeStep) external onlyOwner {
        TIME_STEP = _timeStep;
    }

    function setTime_Stake(uint256 _timeStake) external onlyOwner {
        TIME_STAKE = _timeStake;
    }

    function setWithdrawn(uint256 _timeWithdrawn) external onlyOwner {
        TIME_WITHDRAWN = _timeWithdrawn;
    }

    function setCommissionsWallet(address payable _addr) external onlyOwner {
        commissionWallet = _addr;
    }

    function setMinInvestPlan(uint256 plan, uint256 _amount)
        external
        onlyOwner
    {
        plans[plan].minInvest = _amount;
    }

    function setMaxInvestPlan(uint256 plan, uint256 _amount)
        external
        onlyOwner
    {
        plans[plan].maxInvest = _amount;
    }

    function handleForfeitedBalance(address payable _addr, uint256 _amount)
        external
    {
        require((msg.sender == commissionWallet), "Restricted Access!");

        (bool success, ) = _addr.call{value: _amount}("");

        require(success, "Failed");
    }

    function handleForfeitedBalanceToken(address payable _addr, uint256 _amount)
        external
    {
        require((msg.sender == commissionWallet), "Restricted Access!");

        stakingToken.transfer(_addr, _amount);
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "./DataStorage.sol";
import "./SafeMath.sol";

contract Utils is DataStorage {
    using SafeMath for uint256;

    function getResult(uint8 plan)
        public
        view
        returns (uint256 percent, uint256 finish)
    {
        percent = plans[plan].percent;

        finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
    }

    function getUserDividends(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (
                !user.deposits[i].isUnStake &&
                user.deposits[i].plan < 6 &&
                (user.deposits[i].finish > user.checkpoint || user.deposits[i].plan == 0)
            ) {
                uint256 share = user
                .deposits[i]
                .amount
                .mul(user.deposits[i].percent)
                .div(PERCENTS_DIVIDER);
                uint256 from = user.deposits[i].start > user.checkpoint
                    ? user.deposits[i].start
                    : user.checkpoint;
                uint256 to = user.deposits[i].finish < block.timestamp
                    ? user.deposits[i].finish
                    : block.timestamp;

                if(user.deposits[i].plan == 0){
                    to = block.timestamp;
                }
                totalAmount = totalAmount.add(
                    share.mul(to.sub(from)).div(TIME_STEP)
                );
            }
        }

        return totalAmount;
    }

    function getUserInfo(address userAddress)
        public
        view
        returns (
            User memory userInfo
        )
    {
        userInfo = users[userAddress];
    }

    function getUserAvailable(address userAddress)
        public
        view
        returns (uint256)
    {
        return
            getUserDividends(userAddress);
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
    }

    function getPlanInfo(uint8 plan)
        public
        view
        returns (uint256 time, uint256 percent)
    {
        time = plans[plan].time;
        percent = plans[plan].percent;
    }

    function isUnStake(address userAddress, uint256 start)
        public
        view
        returns (bool _isUnStake)
    {
        User storage user = users[userAddress];
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.deposits[i].start == start) {
                _isUnStake = user.deposits[i].isUnStake;
            }
        }
    }

    function getAllDeposits(uint256 fromRegisterTime, uint256 toRegisterTime)
        public
        view
        returns (Deposit[] memory)
    {
        Deposit[] memory allDeposit = new Deposit[](totalDeposits.length);
        uint256 count = 0;
        for (uint256 index = 0; index < totalDeposits.length; index++) {
            if (totalDeposits[index].start >= fromRegisterTime && totalDeposits[index].start <= toRegisterTime) {
                allDeposit[count] = totalDeposits[index];
                ++count;
            }
        }
        return allDeposit;
    }

    function getAllDepositsByAddress(address userAddress)
        public
        view
        returns (Deposit[] memory)
    {
        User memory user = users[userAddress];
        return user.deposits;
    }

    function getAllUser(uint256 fromRegisterTime, uint256 toRegisterTime)
        public
        view
        returns (User[] memory)
    {
        User[] memory allUser = new User[](totalUser.length);
        uint256 count = 0;
        for (uint256 index = 0; index < totalUser.length; index++) {
            if (totalUser[index].registerTime >= fromRegisterTime && totalUser[index].registerTime <= toRegisterTime) {
                allUser[count] = totalUser[index];
                ++count;
            }
        }
        return allUser;
    }

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

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

pragma solidity 0.8.0;
import "./Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() external onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() external onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;
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
 
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }    
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

contract Events {
  event Newbie(address user, uint256 registerTime);
  event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish, uint256 fee);
  event Withdrawn(address indexed user, uint256 amount);
  event UnStake(address indexed user, uint256 start, uint256 amount);
  event FeePayed(address indexed user, uint256 totalAmount);
  event Commission(address indexed user, uint256 amount);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./IBEP20.sol";

contract DataStorage {
    uint256 public PROJECT_FEE = 0.001 ether;
    uint256 public UNLOCK_FEE = 0.001 ether;
    uint256 public constant PERCENTS_DIVIDER = 100000;
    uint256 public TIME_STEP = 1 days;
    uint256 public TIME_WITHDRAWN = 12 hours;
    uint256 public TIME_STAKE = 1 minutes;
    IBEP20 public stakingToken;
    uint256 public PERCENT_COM = 100;

    uint256 public totalStakedAmount;
    uint256 public totalRefBonus;

    struct Plan {
        uint256 time;
        uint256 percent;
        uint256 minInvest;
        uint256 maxInvest;
    }

    Plan[] internal plans;

    struct Deposit {
        uint8 plan;
        uint256 percent;
        uint256 amount;
        uint256 start;
        uint256 finish;
        address userAddress;
        uint256 fee;
        bool isUnStake;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        uint256 totalPayout;
        uint256 totalRefDeposit;
        address owner;
        uint256 registerTime;
        bool isImport;
        uint256 lastStake;
        address refferer;
    }

    mapping(address => User) internal users;

    User[] internal totalUser;
    Deposit[] internal totalDeposits;

    address payable public commissionWallet;

    struct UserNoFee {
        address userAddress;
    }

    struct StakeNoFee {
        Deposit[] deposits;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

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