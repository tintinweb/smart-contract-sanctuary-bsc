// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interfaces/IWhiteKnight.sol";
import "./interfaces/IKnightPool.sol";
import "./libs/Owner.sol";

//import IERC20 from @openzeppelin

contract WhiteKnight is Owner, IWhiteKnight {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _playerNumber;

    string public name = "White Knight";
    string public symbol = "WK";
    address contractAddress = address(this);
    address knightPoolAddress;
    IKnightPool knightPoolContract;
    IERC20 public KINGDOMToken;
    uint256 depositeMinLimit = 3 * 1e18;
    uint256 registerBonus = 5 * 1e18;
    uint256 withdrawBonus = 10 * 1e18;
    uint256 depositeBonus = 20 * 1e18;

    mapping(address => Player) public player;

    constructor(address KINGDOM, address KnightPool) {
        knightPoolAddress = KnightPool;
        knightPoolContract = IKnightPool(knightPoolAddress);
        KINGDOMToken = IERC20(KINGDOM);
    }

    /**
    **********************************************
    ----------------------------------------------
    ---------------- Read Function ---------------
    ----------------------------------------------
    **********************************************
    */

    function getContractAddress() public view override returns (address) {
        return contractAddress;
    }

    function viewPlayerInfo(address from)
        public
        view
        override
        returns (Player memory)
    {
        return player[from];
    }

    function viewRegisteredPlayersNumber()
        public
        view
        override
        returns (uint256)
    {
        return _playerNumber.current();
    }

    function viewDepositeMinLimit() public view returns (uint256) {
        return depositeMinLimit;
    }

    function viewRegisterBonus() public view returns (uint256) {
        return registerBonus;
    }

    function viewWithdrawBonus() public view returns (uint256) {
        return withdrawBonus;
    }

    function viewDepositeBonus() public view returns (uint256) {
        return depositeBonus;
    }

    /**
    **********************************************
    ----------------------------------------------
    --------------- Write Function ---------------
    ----------------------------------------------
    **********************************************
    */

    function createProfile(string memory username)
        public
        override
        returns (Player memory)
    {
        _playerNumber.increment();
        uint256 newPlayerId = _playerNumber.current();

        Player storage ply = player[msg.sender];
        ply.playerId = newPlayerId;
        ply.level = 0;
        ply.name = username;
        // give bonus at first registering
        ply.amount += registerBonus;

        emit CreateProfile(msg.sender, username);

        return ply;
    }

    function depositeToContract(uint256 amount)
        public
        override
        returns (bool success)
    {
        require(
            depositeMinLimit <= amount,
            "player can play game with 10 KINGDOM coin at least"
        );

        KINGDOMToken.transferFrom(msg.sender, knightPoolAddress, amount);

        Player storage ply = player[msg.sender];
        ply.amount += amount;
        ply.depositeCount += 1;
        ply.totalDepositeAmount += amount;
        ply.lastDepositeTime = block.timestamp;
        // calculate rewards for deposite
        uint256 count = ply.depositeCount;
        uint256 downValue = count.mod(10);
        if (count >= 10 && downValue == 0) {
            notifyDepositeRewards(msg.sender);
        }

        emit DepositToContract(msg.sender, amount);

        return true;
    }

    function withdrawFromContract(uint256 amount)
        public
        override
        returns (bool success)
    {
        Player storage ply = player[msg.sender];

        require(
            ply.amount >= amount,
            "withdraw coin must be bigger or same than player's current deposited coin."
        );

        uint256 withdrawAmount = knightPoolContract.transferFromPoolForWithdraw(
            amount
        );

        require(withdrawAmount == amount, "withdraw amount must have amount");

        _transferKGToUser(msg.sender, amount);

        ply.amount -= amount;
        ply.withdrawCount += 1;
        ply.totalWithdrawAmount += amount;
        ply.lastWithdrawTime = block.timestamp;
        // calculate rewards for withdraw
        uint256 count = ply.withdrawCount;
        uint256 downValue = count.mod(10);
        if (count >= 10 && downValue == 0) {
            notifyWithdrawRewards(msg.sender);
        }

        emit WithdrawFromContract(msg.sender, amount);

        return true;
    }

    function _transferKGToUser(address to, uint256 amount)
        private
        returns (uint256)
    {
        KINGDOMToken.transfer(to, amount);
        return amount;
    }

    function notifyDepositeRewards(address to) private {
        uint256 amountFromPool = knightPoolContract.transferFromPoolForWithdraw(
            depositeBonus
        );

        require(
            amountFromPool == depositeBonus,
            "withdraw amount must have amount"
        );

        _transferKGToUser(to, depositeBonus);
        player[to].amount += depositeBonus;

        emit NotifyDepositeRewards(to);
    }

    function notifyWithdrawRewards(address to) private {
        uint256 amountFromPool = knightPoolContract.transferFromPoolForWithdraw(
            withdrawBonus
        );

        require(
            amountFromPool == withdrawBonus,
            "withdraw amount must have amount"
        );

        _transferKGToUser(to, withdrawBonus);
        player[to].amount += withdrawBonus;

        emit NotifyWithdrawRewards(to);
    }

    /**
    **********************************************
    ----------------------------------------------
    --------------- Admin Function ---------------
    ----------------------------------------------
    **********************************************
     */

    function setRegisterBonus(uint256 amount)
        public
        onlyOperator
        returns (bool success)
    {
        require(amount > 0, "amount must be bigger than 0");
        registerBonus = amount;

        return true;
    }

    function setDepositeBonus(uint256 amount)
        public
        onlyOperator
        returns (bool success)
    {
        require(amount > 0, "amount must be bigger than 0");
        depositeBonus = amount;

        return true;
    }

    function setWithdrawBonus(uint256 amount)
        public
        onlyOperator
        returns (bool success)
    {
        require(amount > 0, "amount must be bigger than 0");
        withdrawBonus = amount;

        return true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
pragma solidity ^0.8.4;

interface IWhiteKnight {
    struct Player {
        uint256 playerId;
        uint32 level;
        uint256 lastDepositeTime;
        uint256 lastWithdrawTime;
        string name;
        uint256 amount;
        uint256 depositeCount;
        uint256 withdrawCount;
        uint256 totalDepositeAmount;
        uint256 totalWithdrawAmount;
    }

    function getContractAddress() external view returns (address);

    function viewPlayerInfo(address from) external view returns (Player memory);

    function viewRegisteredPlayersNumber() external view returns (uint256);

    function createProfile(string memory username)
        external
        returns (Player memory);

    function depositeToContract(uint256 amount) external returns (bool success);

    function withdrawFromContract(uint256 amount)
        external
        returns (bool success);

    event CreateProfile(address indexed from, string username);
    event DepositToContract(address from, uint256 amount);
    event WithdrawFromContract(address to, uint256 amount);
    event NotifyDepositeRewards(address to);
    event NotifyWithdrawRewards(address to);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IKnightPool {
    function getPoolBalance() external view returns (uint256);

    function depositeToPool(uint256 amount) external returns (bool success);

    function transferFromPoolForWithdraw(uint256 amount)
        external
        returns (uint256);

    event WithdrawFromPool(uint256 amount);
    event DepositeToPool(uint256 amount);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

contract Owner {
    address public operator;

    constructor() {
        operator = msg.sender;
    }

    function getOperator() public view returns (address) {
        return operator;
    }

    function transferOwnership(address newOperator)
        public
        onlyOperator
        returns (bool success)
    {
        require(
            newOperator != address(0) || operator != newOperator,
            "Ownable: new operator is the zero address, new operator can't be same with current operator"
        );
        operator = newOperator;

        return true;
    }

    modifier onlyOperator() {
        require(msg.sender == operator);
        _;
    }
}