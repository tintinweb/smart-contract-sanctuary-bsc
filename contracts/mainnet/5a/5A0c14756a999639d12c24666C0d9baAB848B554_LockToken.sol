// "SPDX-License-Identifier: UNLICENSED"

pragma solidity 0.6.12;

import "./ModifiedOwnable.sol";
import "./openzeppelin/v3/token/ERC20/IERC20.sol";
import "./openzeppelin/v3/token/ERC20/SafeERC20.sol";
import "./openzeppelin/v3/math/SafeMath.sol";

contract LockToken is ModifiedOwnable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public constant PERCENT_PRECISION = 1e18; // 1%

    IERC20 public token;

    uint256 public startLockTime;
    uint256 public totalReward;

    uint256[] public unlockSteps;

    // unlock step => unlock percent
    mapping(uint256 => uint256) public unlockPercents;

    // wallet address =>  amount
    mapping(address => uint256) public rewards;

    // wallet address => step => claimed?
    mapping(address => mapping(uint256 => bool)) public claimStatus;

    constructor(address _token) public {
        require(_token != address(0), "_token cannot be the zero address");
        token = IERC20(_token);

        // #1 release Thursday, December 1, 2022 12:00:00 AM GMT+07:00 2%
        unlockSteps.push(1669827600);
        // #2 release Sunday, January 1, 2023 12:00:00 AM GMT+07:00 2%
        unlockSteps.push(1672506000);
        // #3 release Wednesday, February 1, 2023 12:00:00 AM GMT+07:00 2%
        unlockSteps.push(1675184400);

        unlockSteps.push(1677603600);
        unlockSteps.push(1680282000);
        unlockSteps.push(1682874000);
        unlockSteps.push(1685552400);
        unlockSteps.push(1688144400);
        unlockSteps.push(1690822800);
        unlockSteps.push(1693501200);

        unlockSteps.push(1696093200);
        unlockSteps.push(1698771600);
        unlockSteps.push(1701363600);
        unlockSteps.push(1704042000);
        unlockSteps.push(1706720400);
        unlockSteps.push(1709226000);
        unlockSteps.push(1711904400);
        unlockSteps.push(1714496400);
        unlockSteps.push(1717174800);
        unlockSteps.push(1719766800);

        unlockSteps.push(1722445200);
        unlockSteps.push(1725123600);
        unlockSteps.push(1727715600);
        unlockSteps.push(1730394000);
        unlockSteps.push(1732986000);
        unlockSteps.push(1735664400);
        unlockSteps.push(1738342800);
        unlockSteps.push(1740762000);
        unlockSteps.push(1743440400);
        unlockSteps.push(1746032400);

        unlockSteps.push(1748710800);
        unlockSteps.push(1751302800);
        unlockSteps.push(1753981200);
        unlockSteps.push(1756659600);
        unlockSteps.push(1759251600);
        unlockSteps.push(1761930000);
        unlockSteps.push(1764522000);
        unlockSteps.push(1767200400);
        unlockSteps.push(1769878800);
        unlockSteps.push(1772298000);

        unlockSteps.push(1774976400);
        unlockSteps.push(1777568400);
        unlockSteps.push(1780246800);
        unlockSteps.push(1782838800);
        unlockSteps.push(1785517200);
        unlockSteps.push(1788195600);
        unlockSteps.push(1790787600);
        unlockSteps.push(1793466000);
        unlockSteps.push(1796058000);
        unlockSteps.push(1798736400);


        unlockPercents[0] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[1] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[2] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[3] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[4] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[5] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[6] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[7] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[8] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[9] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[10] = (20 * PERCENT_PRECISION) / 10;   
        unlockPercents[11] = (20 * PERCENT_PRECISION) / 10; 
        unlockPercents[12] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[13] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[14] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[15] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[16] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[17] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[18] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[19] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[20] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[21] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[22] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[23] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[24] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[25] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[26] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[27] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[28] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[29] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[30] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[31] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[32] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[33] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[34] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[35] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[36] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[37] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[38] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[39] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[40] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[41] = (20 * PERCENT_PRECISION) / 10;     
        unlockPercents[42] = (20 * PERCENT_PRECISION) / 10;   
        unlockPercents[43] = (20 * PERCENT_PRECISION) / 10; 
        unlockPercents[44] = (20 * PERCENT_PRECISION) / 10;
        unlockPercents[45] = (20 * PERCENT_PRECISION) / 10; 
        unlockPercents[46] = (20 * PERCENT_PRECISION) / 10; 
        unlockPercents[47] = (20 * PERCENT_PRECISION) / 10; 
        unlockPercents[48] = (20 * PERCENT_PRECISION) / 10; 
        unlockPercents[49] = (20 * PERCENT_PRECISION) / 10; 
        
    }

    function lock(address _wallet, uint256 _amount) external onlyOwner {
        require(_wallet != address(0), "_wallet cannot be the zero address");
        require(_amount != 0, "_amount cannnot be zero");
        require(currentTime() < unlockSteps[0], "Timeout");
        rewards[_wallet] = rewards[_wallet].add(_amount);
        totalReward = totalReward.add(_amount);
        require(
            token.balanceOf(address(this)) >= totalReward,
            "token is not enough"
        );
    }

    function batchLock(address[] calldata _wallets, uint256[] calldata _amounts)
        external
        onlyOwner
    {
        require(
            _wallets[0] != address(0),
            "element cannot be the zero address"
        );
        require(_amounts[0] != 0, "element cannot be the zero");
        require(currentTime() < unlockSteps[0], "Timeout");
        require(_wallets.length == _amounts.length);
        for (uint256 i; i < _wallets.length; i++) {
            rewards[_wallets[i]] = rewards[_wallets[i]].add(_amounts[i]);
            totalReward = totalReward.add(_amounts[i]);
        }
        require(
            token.balanceOf(address(this)) >= totalReward,
            "token is not enough"
        );
    }

    function claim(uint256 _step) external {
        require(_step < 50, "There can be fifty step");
        require(!claimStatus[msg.sender][_step], "Already claimed");
        uint256 _amount = claimableReward(msg.sender, _step);
        require(_amount > 0, "No reward");
        claimStatus[msg.sender][_step] = true;
        totalReward = totalReward.sub(_amount);
        token.safeTransfer(msg.sender, _amount);
    }

    function claimableReward(address _wallet, uint256 _step)
        public
        view
        returns (uint256 rewardAmount)
    {
        require(_wallet != address(0), "_wallet cannot be the zero address");
        require(_step < 50, "There can be fifty step");
        uint256 _lockAmount = rewards[_wallet];
        uint256 _unlockTime = unlockSteps[_step];
        rewardAmount = 0;
        if (currentTime() >= _unlockTime && !claimStatus[_wallet][_step]) {
            rewardAmount = _lockAmount.mul(unlockPercents[_step]).div(
                PERCENT_PRECISION.mul(100)
            );
        }
    }

    function currentTime() public view virtual returns (uint256) {
        return now;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./openzeppelin/v3/utils/Context.sol";

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
abstract contract ModifiedOwnable is Context {
    address private _owner;
    address private _candidateOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event NewCandidateOwner(address indexed newCandidateOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the candidate owner.
     */
    function candidateOwner() public view virtual returns (address) {
        return _candidateOwner;
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newCandidateOwner)
        external
        virtual
        onlyOwner
    {
        require(
            newCandidateOwner != address(0),
            "Ownable: candidate owner is the zero address"
        );
        _candidateOwner = newCandidateOwner;
        emit NewCandidateOwner(newCandidateOwner);
    }

    function claimOwnership() external {
        require(
            candidateOwner() == _msgSender(),
            "Ownable: caller is not the candidate owner"
        );
        emit OwnershipTransferred(_owner, _candidateOwner);
        _owner = _candidateOwner;
        _candidateOwner = address(0);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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