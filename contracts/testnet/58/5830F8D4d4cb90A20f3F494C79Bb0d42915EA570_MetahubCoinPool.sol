// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../Operator.sol";
import "./lib/Types.sol";
import "./lib/Reward.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MetahubCoinPool is Operator {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Reward for Structs.user;

    Structs.poolData[100] public poolDatas;
    mapping (address => Structs.user) public users;
    
    address rewardWallet;
    uint256 public shareBase;
    uint256 constant decimal = 10 ** 18;
    uint256 public shareThreshold;
    //IERC20 immutable MHB = IERC20(0x04d6F8c1fF83A4B7886A1B543E4a5Fda69d8ea7B);
    IERC20 MHB; //TODO:test
    uint256 public userCount;
    uint256 public withdrawFeeRate;

    event Register(address indexed account, address indexed referrer);
    event Deposit(address indexed account, uint256 indexed pool, uint256 amount, uint256 id);
    event Ransom(address indexed account, uint256 indexed pool, uint256 amount, uint256 id);
    event Withdraw(address indexed account, uint256 indexed pool, uint256 amount);

    constructor(uint256 shareBase_, address root, address rewardWallet_, uint256 shareThreshold_, address mhb) {
        shareBase = shareBase_;
        rewardWallet = rewardWallet_;
        shareThreshold = shareThreshold_;
        MHB = IERC20(mhb);//TODO:test
        shareThreshold = 2000 * decimal;

        Structs.user storage u = users[root];
        u.exists = true;
        u.referrer = address(0);
        u.totalDepositAmount = 0;
        u.teamTotalDepositAmount = 0;
        userCount++;

        poolDatas[0] = Structs.poolData(true, true, 2000 * decimal, 20000 * decimal, 2000000 * decimal, 2592000, 0, 300);
        poolDatas[1] = Structs.poolData(true, true, 30000 * decimal, 300000 * decimal, 30000000 * decimal, 5184000, 0, 250);
        poolDatas[2] = Structs.poolData(true, true, 100000 * decimal, 1000000 * decimal, 100000000 * decimal, 7776000, 0, 243);
        poolDatas[3] = Structs.poolData(true, true, 500000 * decimal, 5000000 * decimal, 500000000 * decimal, 15552000, 0, 216);
    }

    function setRewardWallet(address newWallet) external onlyOperator returns (bool) {
        rewardWallet = newWallet;

        return true;
    }

    function setPoolData(
        uint256 pool,
        bool open, 
        bool display,  
        uint256 eachAccountMinAmount, 
        uint256 eachAccountMaxAmount, 
        uint256 maxTotalAmount,
        uint256 lockTime,
        uint256 coefficient
    ) external onlyOperator returns (bool) {
        poolDatas[pool].open = open;
        poolDatas[pool].display = display;
        poolDatas[pool].eachAccountMinAmount = eachAccountMinAmount;
        poolDatas[pool].eachAccountMaxAmount = eachAccountMaxAmount;
        poolDatas[pool].maxTotalAmount = maxTotalAmount;
        poolDatas[pool].lockTime = lockTime;
        poolDatas[pool].coefficient = coefficient;

        return true;
    }

    function setShareThreshold(uint256 newShareThreshold) external onlyOperator returns (bool) {
        shareThreshold = newShareThreshold;

        return true;
    }

    function setWithdrawFeeRate(uint256 newWithdrawFeeRate) external onlyOperator returns (bool) {
        withdrawFeeRate = newWithdrawFeeRate;

        return true;
    }

    /***************************************************************************************************************************************/

    function register(address ref) external returns (bool) {
        require(users[ref].exists, "Ref not exist");
        require(!users[_msgSender()].exists, "Registered");
        Structs.user storage u = users[_msgSender()];
        u.exists = true;
        u.referrer = ref;
        u.totalDepositAmount = 0;
        u.teamTotalDepositAmount = 0;

        users[ref].team.push(_msgSender());
        userCount++;

        emit Register(_msgSender(), ref);
        return true;
    }

    function deposit(uint256 pool, uint256 amount) external returns (bool) {
        require(users[_msgSender()].exists, "Not register");
        require(poolDatas[pool].open, "Not open");
        require(amount >= poolDatas[pool].eachAccountMinAmount, "Insufficient amount");
        require(amount <= poolDatas[pool].eachAccountMaxAmount, "Aamount too large");


        uint256 coefficient = poolDatas[pool].coefficient;
        users[_msgSender()].setMineReward(pool, coefficient, amount, true, shareThreshold);
        
        Structs.depositRecord storage dr = users[_msgSender()].depositRecords.push();
        dr.exists = true;
        dr.id = users[_msgSender()].depositRecords.length - 1;
        dr.amount = amount;
        dr.pool = pool;
        dr.time = block.timestamp;
        dr.unlockTime = block.timestamp.add(poolDatas[pool].lockTime);
        dr.status = 0;
        uint8 depType = 0;
        if (users[_msgSender()].totalDepositAmount == amount) {
            depType = 1;
        }
        
        setRefShareReward(_msgSender(), amount, pool, true, depType);
        
        poolDatas[pool].currentAmount = poolDatas[pool].currentAmount.add(amount);
        require(poolDatas[pool].currentAmount <= poolDatas[pool].maxTotalAmount, "Pool is full");

        MHB.safeTransferFrom(_msgSender(), address(this), amount);

        emit Deposit(_msgSender(), pool, amount, dr.id);
        return true;
    }

    function ransom(uint256 id) external returns (bool) {
        require(users[_msgSender()].depositRecords[id].exists, "Not exist");
        require(users[_msgSender()].depositRecords[id].status == 0, "Ransomed");
        require(users[_msgSender()].depositRecords[id].unlockTime <= block.timestamp, "Cannot ransom");

        uint256 pool = users[_msgSender()].depositRecords[id].pool;
        uint256 coefficient = poolDatas[pool].coefficient;
        uint256 amount = users[_msgSender()].depositRecords[id].amount;

        users[_msgSender()].setMineReward(pool, coefficient, amount, false, shareThreshold);
        
        Structs.depositRecord storage dr = users[_msgSender()].depositRecords[id];
        dr.status = 1;

        uint8 depType = 0;
        if (users[_msgSender()].totalDepositAmount == 0) {
            depType = 2;
        }

        setRefShareReward(_msgSender(), amount, pool, false, depType);

        poolDatas[pool].currentAmount = poolDatas[pool].currentAmount.sub(amount);
        MHB.safeTransfer(_msgSender(), amount);

        emit Ransom(_msgSender(), pool, amount, id);
        return true;
    }

    function withdraw(uint256 pool) external returns (bool) {
        uint256 mineReward = getMineReward(_msgSender(), pool);
        uint256 shareReward = getShareReward(_msgSender(), pool);
        users[_msgSender()].lastMineReward[pool] = 0;
        users[_msgSender()].lastMineCalTime[pool] = block.timestamp;
        users[_msgSender()].lastShareReward[pool] = 0;
        users[_msgSender()].lastShareCalTime[pool] = block.timestamp;

        uint256 amount = mineReward.add(shareReward);
        uint256 fee = amount.mul(withdrawFeeRate).div(1000);
        amount = amount.sub(fee);

        MHB.safeTransferFrom(rewardWallet, _msgSender(), amount);

        emit Withdraw(_msgSender(), pool, amount);
        return true;
    }

    /****************************************************************************************************************************************/

    function getUserDepositRecord(address account, uint256 start) external view returns (Structs.depositRecord[20] memory list, uint256 total) {
        require(users[account].exists, "Not register");
        total = users[account].depositRecords.length;
        if (total == 0) {
            return (list, total);
        }
        if (start > total - 1) {
            return (list, total);
        }

        for (uint256 i = 0; i < 20; i++) {
            if (i + start > total - 1) {
                return (list, total);
            }
            list[i] = users[account].depositRecords[i+start];
        }
    }

    function getMineReward(address account, uint256 pool) public view returns (uint256) {
        require(users[account].exists, "Not register");
        return users[account].calMineReward(pool, poolDatas[pool].coefficient);
    }

    function getShareReward(address account, uint256 pool) public view returns (uint256) {
        require(users[account].exists, "Not register");
        return users[account].calShareReward(pool, poolDatas[pool].coefficient, shareThreshold);
    }

    function getTeamList(address account, uint256 start) external view returns (Structs.teamData[20] memory list, uint256 total) {
        require(users[account].exists, "Not register");
        total = users[account].team.length;
        if (total == 0) {
            return (list, total);
        }
        if (start > total - 1) {
            return (list, total);
        }

        for (uint256 i = 0; i < 20; i++) {
            if (i + start > total - 1) {
                return (list, total);
            }
            list[i].account = users[account].team[i+start];
            list[i].depositAmount = users[users[account].team[i+start]].totalDepositAmount;
        }
    }

    function getTeamData(address account) external view returns (uint256, uint256) {
        require(users[account].exists, "Not register");
        return (users[account].teamDepCount, users[account].teamTotalDepositAmount);
    }

    function getPoolData() external view returns (Structs.poolData[100] memory) {
        return poolDatas;
    }

    function getDepositAmount(address account, uint256 pool) external view returns (uint256) {
        require(users[account].exists, "Not register");
        return users[account].depositAmount[pool];
    }

    function isRegister(address account) external view returns (bool) {
        return users[account].exists;
    }

    // function getPower(address account, uint256 pool) external view returns (uint256) {
    //     return users[account].power[pool];
    // }

    /********************************************************************************************************************************************/

    function setRefShareReward(address account, uint256 amount, uint256 pool, bool isAdd, uint8 depType) internal {
        uint256 coefficient = poolDatas[pool].coefficient;
        address ref = users[account].referrer;
        uint256 baseAmount = amount.mul(shareBase).div(1000);
        for (uint256 i = 0; i < 10; i++) {
            uint256 powerAmount = baseAmount.div(2**i);
            users[ref].setShareReward(pool, coefficient, amount, powerAmount, shareThreshold, depType, isAdd);
            
            ref = users[ref].referrer;
            if (ref == address(0)) {
                break;
            }
        }
    }
}

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Operator is Ownable {
    mapping (address => bool) private operators;
    
    // event for EVM logging
    event OperatorAdd(address indexed oldOperator);
    event OperatorDel(address indexed oldOperator);
    
    // modifier to check if caller is operator
    modifier onlyOperator() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(operators[msg.sender], "Caller is not operator");
        _;
    }
    
    /**
     * @dev Set contract deployer as operator
     */
    constructor() {
        operators[msg.sender] = true; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OperatorAdd(msg.sender);
    }

    /**
     * @dev Add operator
     * @param newOperator address of new operator
     */
    function addOperator(address newOperator) public onlyOwner {
        operators[newOperator] = true;
        emit OperatorAdd(newOperator);
    }

    function delOperator(address operator) public onlyOwner {
        operators[operator] = false;
        emit OperatorDel(operator);
    }

    /**
     * @dev Return if a address is opreator
     * @return bool
     */
    function isOperator(address account) external view returns (bool) {
        return operators[account];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Structs {
    struct teamData {
        address account;
        uint256 depositAmount;
    }

    struct poolData {
        bool    open;
        bool    display;
        uint256 eachAccountMinAmount;
        uint256 eachAccountMaxAmount;
        uint256 maxTotalAmount;
        uint256 lockTime;
        uint256 currentAmount;
        uint256 coefficient;
    }

    struct depositRecord {
        bool exists;
        uint256 id;
        uint256 pool;
        uint256 amount;
        uint256 time;
        uint256 unlockTime;
        uint8 status;
    }

    struct user {
        bool            exists;
        address         referrer;
        address[]       team;
        uint256         teamDepCount;
        uint256[100]     depositAmount;
        uint256[100]     lastMineCalTime;
        uint256[100]     lastMineReward;
        uint256         totalDepositAmount;
        depositRecord[] depositRecords;

        uint256         teamTotalDepositAmount;
        uint256[100]     power;
        uint256[100]     lastShareCalTime;
        uint256[100]     lastShareReward;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./Types.sol";

library Reward {
    function calMineReward(Structs.user storage u, uint256 pool, uint256 coefficient) public view returns (uint256) {
        if (u.depositAmount[pool] == 0) {
            return u.lastMineReward[pool];
        }
        uint256 intervalSeconds = block.timestamp - u.lastMineCalTime[pool];
        uint256 intervalHours = intervalSeconds / 3600;
        
        uint256 eachHourReward = u.depositAmount[pool] / (coefficient * 24);
        return u.lastMineReward[pool] + (eachHourReward * intervalHours);
    }

    function setMineReward(
        Structs.user storage u, 
        uint256 pool, 
        uint256 coefficient,
        uint256 amount,
        bool isAdd,
        uint256 shareThreshold
    ) public {
        uint256 mineReward = calMineReward(u, pool, coefficient);
        u.lastMineReward[pool] = mineReward;
        
        u.lastMineCalTime[pool] = block.timestamp;
        uint256 newTotalDepositAmount = u.totalDepositAmount + amount;
        if (isAdd) {
            if (u.totalDepositAmount < shareThreshold && newTotalDepositAmount >= shareThreshold) {
                u.lastShareCalTime[pool] = block.timestamp;
            }
            u.depositAmount[pool] = u.depositAmount[pool] + amount;
        } else {
            newTotalDepositAmount = u.totalDepositAmount - amount;
            u.depositAmount[pool] = u.depositAmount[pool] - amount;
            if (u.totalDepositAmount >= shareThreshold && newTotalDepositAmount < shareThreshold) {
                if (u.power[pool] > 0) {
                    u.lastShareReward[pool] = calShareReward(u, pool, coefficient, shareThreshold);
                }
                u.lastShareCalTime[pool] = block.timestamp;
            }
        }
        u.totalDepositAmount = newTotalDepositAmount;
    }

    function calShareReward(Structs.user storage u, uint256 pool, uint256 coefficient, uint256 shareThreshold) public view returns (uint256) {
        if (u.totalDepositAmount < shareThreshold) {
            return u.lastShareReward[pool];
        }
        uint256 intervalSeconds = block.timestamp - u.lastShareCalTime[pool];
        uint256 intervalHours = intervalSeconds / 3600;
        
        uint256 eachHourReward = u.power[pool] / (coefficient * 24);
        return u.lastShareReward[pool] + (eachHourReward * intervalHours);
    }

    function setShareReward(Structs.user storage u, 
        uint256 pool, 
        uint256 coefficient,
        uint256 amount,
        uint256 powerAmount, 
        uint256 shareThreshold,
        uint256 depType,
        bool isAdd
    ) public {
        if (u.power[pool] > 0 && u.totalDepositAmount >= shareThreshold) {
            u.lastShareReward[pool] = calShareReward(u, pool, coefficient, shareThreshold);
        }
        u.lastShareCalTime[pool] = block.timestamp;
        if (isAdd) {
            u.teamTotalDepositAmount = u.teamTotalDepositAmount + amount;
            u.power[pool] = u.power[pool] + powerAmount;
        } else {
            u.teamTotalDepositAmount = u.teamTotalDepositAmount - amount;
            u.power[pool] = u.power[pool] - powerAmount;
        }

        if (depType == 1) {
            u.teamDepCount++;
        } else if (depType == 2) {
            u.teamDepCount--;
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