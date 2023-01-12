/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
// File: Ownable.sol



pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence .
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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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

    function mint(address to, uint256 amount) external returns (bool);

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


// File: @openzeppelin\contracts\access\Ownable.sol

// Adding-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
// File: @openzeppelin\contracts\math\SafeMath.sol

// Adding-Identifier: MIT

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
    // Add Sqrt
    function sqrt(uint256 a) internal pure returns (uint256) {
        uint256 c = (a + 1) / 2;
        uint256 b = a;
        while (c < b) {
            b = c;
            c = (a / c + c) / 2;
        }
        return b;
    }
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

// File: @openzeppelin\contracts\utils\Address.sol

// Adding-Identifier: MIT

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

// File: contracts\libs\SafeBEP20.sol

// Adding-Identifier: MIT

pragma solidity ^0.6.0;




/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}
// File: WexRefferal.sol




pragma solidity >=0.4.0;

// File: contracts\libs\IWEXReferral.sol

// Adding-Identifier: MIT

pragma solidity 0.6.12;

interface IWedexReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address _user, address _referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission)
        external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);

    function addTotalFund(
        address _referrer,
        uint256 _amount,
        uint256 _loop
    ) external;

    function reduceTotalFund(
        address _referrer,
        uint256 _amount,
        uint256 _loop
    ) external;

    function getTeam(address _user) external view returns (address[] memory);

    function totalFund(address _referrer) external view returns (uint256);
}

// File: contracts\WEXReferral.sol

// Adding-Identifier: MIT

pragma solidity 0.6.12;

contract WEXReferral is IWedexReferral, Ownable {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    mapping(address => bool) public operators;
    mapping(address => address) public referrers; // user address => referrer address
    mapping(address => uint256) public referralsCount; // referrer address => referrals count
    mapping(address => uint256) public override totalFund; // referrer address => referrals count
    mapping(address => uint256) public totalReferralCommissions; // referrer address => total referral commissions
    mapping(address => address[]) public team; // return all member in the team
    mapping(address => bool) public blacklist; //mapping address to blacklist
    mapping(address => uint256) public vipLevel;

    uint256 public maximumLoop = 20;
    uint256[] public vipRequirement = [2e5 * 1e18, 5e5 * 1e18, 1e6 * 1e18];
    event ReferralRecorded(address indexed user, address indexed referrer);
    event ReferralCommissionRecorded(
        address indexed referrer,
        uint256 commission
    );
    event OperatorUpdated(address indexed operator, bool indexed status);
    event TotalFundAdd(address _referrer, uint256 _amount, uint256 _loop);
    event ReduceTotalFund(
        address _referrer,
        uint256 _amount,
        uint256 currentLoop
    );

    modifier onlyOperator() {
        require(operators[msg.sender], "Operator: caller is not the operator");
        _;
    }

    constructor() public {
        operators[_msgSender()] = true;
    }

    function noLoop(address _user, address _referrer) public returns (bool) {
        if (referrers[_referrer] == _user) {
            return false;
        }
        if (referrers[_referrer] == address(0)) {
            return true;
        } else {
            return noLoop(_referrer, referrers[_referrer]);
        }
    }

    function recordReferral(address _user, address _referrer)
        public
        override
        onlyOperator
    {
        if (
            _user != address(0) &&
            _referrer != address(0) &&
            _user != _referrer &&
            referrers[_user] == address(0) &&
            noLoop(_user, _referrer)
        ) {
            referrers[_user] = _referrer;
            referralsCount[_referrer] += 1;
            team[_referrer].push(_user);
            emit ReferralRecorded(_user, _referrer);
        }
    }

    function recordReferralCommission(address _referrer, uint256 _commission)
        public
        override
        onlyOperator
    {
        if (_referrer != address(0) && _commission > 0) {
            totalReferralCommissions[_referrer] += _commission;
            emit ReferralCommissionRecorded(_referrer, _commission);
        }
    }

    function addTotalFund(
        address _referrer,
        uint256 _amount,
        uint256 _loop
    ) public override onlyOperator {
        if (_referrer != address(0) && _amount > 0 && _loop < maximumLoop) {
            uint256 currentLoop = _loop.add(1);
            totalFund[_referrer] = totalFund[_referrer].add(_amount);

            if (vipLevel[_referrer] < 3) {
                uint256 maxTotalFunPerBranch = getMaxTotalFundPerBranch(
                    _referrer
                );
                uint256 _total = 0;
                for (uint256 i = 0; i < team[_referrer].length; i++) {
                    if (totalFund[team[_referrer][i]] > maxTotalFunPerBranch) {
                        _total = _total.add(maxTotalFunPerBranch);
                    } else {
                        _total = _total.add(totalFund[team[_referrer][i]]);
                    }
                }
                if (_total > vipRequirement[vipLevel[_referrer]]) {
                    vipLevel[_referrer] = vipLevel[_referrer] + 1;
                }
            }

            if (referrers[_referrer] != address(0)) {
                addTotalFund(referrers[_referrer], _amount, currentLoop);
            }
            emit TotalFundAdd(_referrer, _amount, _loop);
        }
    }

    function reduceTotalFund(
        address _referrer,
        uint256 _amount,
        uint256 _loop
    ) public override onlyOperator {
        if (
            _referrer != address(0) &&
            _amount > 0 &&
            _loop < maximumLoop &&
            totalFund[_referrer] > _amount
        ) {
            uint256 currentLoop = _loop.add(1);
            totalFund[_referrer] = totalFund[_referrer].sub(_amount);
            if (referrers[_referrer] != address(0)) {
                reduceTotalFund(referrers[_referrer], _amount, currentLoop);
            }
            emit ReduceTotalFund(_referrer, _amount, currentLoop);
        }
    }

    function setMaxloop(uint256 _maximumLoop) public onlyOperator {
        maximumLoop = _maximumLoop;
    }

    function addBlacklist(address user) external onlyOwner {
        blacklist[user] = true;
    }

    function removeReferrer(address _user) external onlyOwner {
        referrers[_user] = address(0);
    }

    function getReferrer(address _user) public view override returns (address) {
        return referrers[_user];
    }

    function getVipLevel(address user) public view returns (uint256) {
        return vipLevel[user];
    }

    function getMaxTotalFundPerBranch(address user)
        public
        view
        returns (uint256)
    {
        return vipRequirement[vipLevel[user]].div(2);
    }

    function setTotalFund(address _referrer, uint256 _amount)
        external
        onlyOperator
    {
        totalFund[_referrer] = _amount;
    }

    function getTeam(address _user)
        public
        view
        override
        returns (address[] memory)
    {
        return team[_user];
    }

    function setVipRequirement(uint256[] memory _vipRequirement)
        public
        onlyOwner
    {
        vipRequirement = _vipRequirement;
    }

    // Update the status of the operator
    function updateOperator(address _operator, bool _status)
        external
        onlyOwner
    {
        operators[_operator] = _status;
        emit OperatorUpdated(_operator, _status);
    }

    // Owner can drain tokens that are sent here by mistake
    function drainBEP20Token(
        IBEP20 _token,
        uint256 _amount,
        address _to
    ) external onlyOwner {
        _token.safeTransfer(_to, _amount);
    }
}

// File: Farm.sol


pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


pragma solidity >=0.6.0 <0.8.0;

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

    constructor() internal {
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

interface IMigratorChef {
    function migrate(
        uint256 _pid,
        address _user,
        uint256 _amount,
        uint256[] memory _investments_amount,
        uint256[] memory _investments_lock_until
    ) external;
}

// MasterChef is the master of Wedex. He can create new Wedex and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once Wedex is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract WedexChef is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct DepositAmount {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 lockUntil;
    }

    // Info of each user.
    struct UserInfo {
        uint256 amount;
        DepositAmount[] investments;
        uint256 lastHarvest;
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 rewardLockedUp; // Reward locked up.
        uint256 nextHarvestUntil; // When can the user harvest again.
        uint256 startInvestmentPosition; //The first position haven't withdrawed

        //
        // We do some fancy math here. Basically, any point in time, the amount of WEDEXES
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accWedexPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accWedexPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken; // Address of LP token contract.
        uint256 totalAmount; // Total amount in pool
        uint256 lastRewardBlock; // Last block number that WEDEX distribution occurs.
        uint256 accWedexPerShare; // Accumulated WEDEX per share, times 1e12. See below.
        uint16 depositFeeBP; // Deposit fee in basis points
        uint256 harvestInterval; // Harvest interval in seconds
        uint256 lockingPeriod;
        uint256 fixedApr;
        uint256 directCommission; //commission pay direct for the Leader;
    }

    struct UserPool {
        uint256 pid;
        address user;
    }

    // The WEDEX TOKEN!
    IBEP20 public wedex;
    address public rewardToken;

    // Dev address.
    address public devAddress;
    // Deposit Fee address
    address public feeAddress;

    // uint256 public wedexPerBlock;
    // Bonus muliplier for early Wedex Holder.
    uint256 public constant BONUS_MULTIPLIER = 1;
    // Max harvest interval: 14 days.
    uint256 public constant MAXIMUM_HARVEST_INTERVAL = 14 days;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // Total locked up rewards
    uint256 public totalLockedUpRewards;
    bool public emergencyLockingWithdrawEnable = false;
    // Wedex referral contract address.
    WEXReferral public wedexReferral;
    uint256 public referDepth = 5;
    uint256[] public referralCommissionTier = [5000, 4000, 3000, 2000, 1000];
    uint256[] public directCommissionForVip = [2, 3, 5];
    mapping(address => uint256) public commissionBalance;

    // variables for migrate
    IMigratorChef public newChefAddress;
    bool public isMigrating = false;
    uint256 constant SECONDS_PER_YEAR = 31536000;

    mapping(uint256 => mapping(address => bool)) public arrayAdded;
    UserPool[] public userArr;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event EmissionRateUpdated(
        address indexed caller,
        uint256 previousAmount,
        uint256 newAmount
    );
    event ReferralCommissionPaid(
        address indexed user,
        address indexed referrer,
        uint256 commissionAmount
    );
    event RewardLockedUp(
        address indexed user,
        uint256 indexed pid,
        uint256 amountLockedUp
    );

    constructor() public {
        devAddress = msg.sender;
        feeAddress = msg.sender;

        wedex = IBEP20(0x1dDa5A10A5fEd668807bD9Bb192095eaE8C36b8e);
        wedexReferral = WEXReferral(0x6dC9a9100740f5694BF68E5c182742570eA25ca4);
        rewardToken = 0x1dDa5A10A5fEd668807bD9Bb192095eaE8C36b8e;

        add(0, 0, 31536000, 12, 0);
        add(0, 0, 63072000, 24, 0);
        add(0, 0, 94608000, 36, 8);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(
        uint16 _depositFeeBP,
        uint256 _harvestInterval,
        uint256 _lockingPeriod,
        uint256 _fixedApr,
        uint256 _directCommission
    ) public onlyOwner {
        require(
            _depositFeeBP <= 10000,
            "add: invalid deposit fee basis points"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "add: invalid harvest interval"
        );

        poolInfo.push(
            PoolInfo({
                lpToken: IBEP20(wedex),
                accWedexPerShare: 0,
                depositFeeBP: _depositFeeBP,
                harvestInterval: _harvestInterval,
                lockingPeriod: _lockingPeriod,
                fixedApr: _fixedApr,
                totalAmount: 0,
                lastRewardBlock: 0,
                directCommission: _directCommission
            })
        );
    }

    // Update the given pool's Wedex allocation point and deposit fee. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint16 _depositFeeBP,
        uint256 _harvestInterval,
        uint256 _fixedApr,
        uint256 _directCommission
    ) public onlyOwner {
        require(
            _depositFeeBP <= 10000,
            "set: invalid deposit fee basis points"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "set: invalid harvest interval"
        );

        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].harvestInterval = _harvestInterval;
        poolInfo[_pid].fixedApr = _fixedApr;
        poolInfo[_pid].directCommission = _directCommission;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending Wedex on frontend.
    function pendingWedex(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 multiplier = getMultiplier(user.lastHarvest, block.timestamp);

        uint256 pending = multiplier.mul(user.amount).mul(pool.fixedApr).div(
            SECONDS_PER_YEAR.mul(100)
        );
        return pending.add(user.rewardLockedUp);
    }

    // View function to see if user can harvest Wedex.
    function canHarvest(uint256 _pid, address _user)
        public
        view
        returns (bool)
    {
        UserInfo storage user = userInfo[_pid][_user];
        return block.timestamp >= user.nextHarvestUntil;
    }

    function getUpperVip(address user, uint256 vipLevel)
        public
        view
        returns (address)
    {
        address referrer = wedexReferral.getReferrer(user);
        while (
            !(wedexReferral.vipLevel(referrer) == vipLevel ||
                referrer == address(0))
        ) {
            referrer = wedexReferral.getReferrer(referrer);
        }
        return referrer;
    }

    // Deposit LP tokens to MasterChef for Wedex allocation.
    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _referrer
    ) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (
            address(wedexReferral) != address(0) &&
            _referrer != address(0) &&
            _referrer != msg.sender &&
            wedexReferral.getReferrer(msg.sender) == address(0)
        ) {
            wedexReferral.recordReferral(msg.sender, _referrer);
        }

        payOrLockupPendingWedex(_pid);
        if (_amount > 0) {
            if (!arrayAdded[_pid][msg.sender]) {
                userArr.push(UserPool({pid: _pid, user: msg.sender}));
                arrayAdded[_pid][msg.sender] = true;
            }

            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );

            if (address(wedexReferral) != address(0)) {
                address referrer = wedexReferral.referrers(msg.sender);
                if (referrer != address(0)) {
                    uint256 totalFund = _amount;
                    wedexReferral.addTotalFund(referrer, totalFund, 0);
                    if (
                        pool.lockingPeriod > 0 &&
                        !emergencyLockingWithdrawEnable
                    ) {
                        payDirectCommission(_pid, _amount, referrer);
                    }
                }
            }

            if (pool.lockingPeriod > 0) {
                user.investments.push(
                    DepositAmount({
                        amount: _amount,
                        lockUntil: block.timestamp.add(pool.lockingPeriod)
                    })
                );
            }

            if (pool.lockingPeriod >= 94608000) {
                commissionBalance[msg.sender] = commissionBalance[msg.sender]
                    .add(_amount);
            }

            if (pool.depositFeeBP > 0) {
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                pool.lpToken.safeTransfer(feeAddress, depositFee);
                user.amount = user.amount.add(_amount).sub(depositFee);

                pool.totalAmount = pool.totalAmount.add(_amount).sub(
                    depositFee
                );
            } else {
                user.amount = user.amount.add(_amount);
                pool.totalAmount = pool.totalAmount.add(_amount);
            }
        }

        if (isMigrating && user.amount > 0) {
            uint256[] memory _investments_amount = new uint256[](
                user.investments.length
            );
            uint256[] memory _investments_lock_until = new uint256[](
                user.investments.length
            );

            for (uint256 i = 0; i < user.investments.length; i++) {
                _investments_amount[i] = user.investments[i].amount;
                _investments_lock_until[i] = user.investments[i].lockUntil;
            }

            pool.lpToken.approve(address(newChefAddress), user.amount);
            newChefAddress.migrate(
                _pid,
                msg.sender,
                user.amount,
                _investments_amount,
                _investments_lock_until
            );
            user.amount = 0;
        }
        emit Deposit(msg.sender, _pid, _amount);
    }

    function getInvestmentInfo(
        uint256 _pid,
        address _user,
        uint256 index
    ) public view returns (DepositAmount memory) {
        return userInfo[_pid][_user].investments[index];
    }

    function getInvestmentLength(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        return userInfo[_pid][_user].investments.length;
    }

    function setNewChefAddress(IMigratorChef _newChefAddress) public onlyOwner {
        newChefAddress = _newChefAddress;
    }

    function setIsMigrating(bool _isMigrating) public onlyOwner {
        isMigrating = _isMigrating;
    }

    function payDirectCommission(
        uint256 _pid,
        uint256 _amount,
        address referrer
    ) internal {
        PoolInfo storage pool = poolInfo[_pid];

        uint256 directCommissionAmount = _amount.mul(pool.directCommission).div(
            1e2
        );

        wedex.mint(address(referrer), directCommissionAmount);
        wedexReferral.recordReferralCommission(
            referrer,
            directCommissionAmount
        );

        if (pool.lockingPeriod >= 94608000) {
            for (uint256 i = 1; i <= 3; i++) {
                address upperVip = getUpperVip(msg.sender, i);

                uint256 directCommissionAmountForVip = _amount
                    .mul(directCommissionForVip[i - 1])
                    .div(1e2);

                if (upperVip != address(0)) {
                    wedex.mint(upperVip, directCommissionAmountForVip);
                    wedexReferral.recordReferralCommission(
                        upperVip,
                        directCommissionAmountForVip
                    );
                }
            }
        }
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "withdraw: not good");
        require(pool.lockingPeriod == 0, "withdraw: not good");

        payOrLockupPendingWedex(_pid);
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.totalAmount = pool.totalAmount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            if (
                address(wedexReferral) != address(0) &&
                wedexReferral.getReferrer(msg.sender) != address(0)
            ) {
                wedexReferral.reduceTotalFund(
                    wedexReferral.getReferrer(msg.sender),
                    _amount,
                    0
                );
            }
        }
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function withdrawInvestment(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(pool.lockingPeriod > 0, "withdraw: not good");

        payOrLockupPendingWedex(_pid);

        uint256 _startInvestmentPosition = 0;
        uint256 _totalWithdrawalAmount = 0;

        for (
            uint256 i = user.startInvestmentPosition;
            i < user.investments.length;
            i++
        ) {
            if (
                user.investments[i].amount > 0 &&
                user.investments[i].lockUntil <= block.timestamp
            ) {
                _totalWithdrawalAmount = _totalWithdrawalAmount.add(
                    user.investments[i].amount
                );
                user.investments[i].amount = 0;
                _startInvestmentPosition = i + 1;
            } else {
                break;
            }
        }

        if (_startInvestmentPosition > user.startInvestmentPosition) {
            user.startInvestmentPosition = _startInvestmentPosition;
        }
        if (
            _totalWithdrawalAmount > 0 && _totalWithdrawalAmount <= user.amount
        ) {
            user.amount = user.amount.sub(_totalWithdrawalAmount);
            pool.totalAmount = pool.totalAmount.sub(_totalWithdrawalAmount);
            pool.lpToken.safeTransfer(
                address(msg.sender),
                _totalWithdrawalAmount
            );

            if (
                address(wedexReferral) != address(0) &&
                wedexReferral.getReferrer(msg.sender) != address(0)
            ) {
                wedexReferral.reduceTotalFund(
                    wedexReferral.getReferrer(msg.sender),
                    _totalWithdrawalAmount,
                    0
                );
            }
        }
        emit Withdraw(msg.sender, _pid, _totalWithdrawalAmount);
    }

    function getFreeInvestmentAmount(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[_pid][_user];
        uint256 _total = 0;

        for (
            uint256 i = user.startInvestmentPosition;
            i < user.investments.length;
            i++
        ) {
            if (
                user.investments[i].amount > 0 &&
                user.investments[i].lockUntil <= block.timestamp
            ) {
                _total = _total.add(user.investments[i].amount);
            } else {
                break;
            }
        }

        return _total;
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(
            pool.lockingPeriod == 0 || emergencyLockingWithdrawEnable,
            "withdraw: not good"
        );
        uint256 amount = user.amount;
        user.amount = 0;
        pool.totalAmount = pool.totalAmount.sub(amount);
        user.lastHarvest = block.timestamp;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
        if (
            address(wedexReferral) != address(0) &&
            wedexReferral.getReferrer(msg.sender) != address(0)
        ) {
            wedexReferral.reduceTotalFund(
                wedexReferral.getReferrer(msg.sender),
                amount,
                0
            );
        }
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Pay or lockup pending Wedex.
    function payOrLockupPendingWedex(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
        }

        uint256 multiplier = getMultiplier(user.lastHarvest, block.timestamp);

        uint256 pending = multiplier.mul(user.amount).mul(pool.fixedApr).div(
            SECONDS_PER_YEAR.mul(100)
        );

        if (canHarvest(_pid, msg.sender)) {
            if (pending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pending.add(user.rewardLockedUp);

                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards.sub(
                    user.rewardLockedUp
                );
                user.rewardLockedUp = 0;
                user.nextHarvestUntil = block.timestamp.add(
                    pool.harvestInterval
                );

                // send rewards
                IBEP20(rewardToken).mint(msg.sender, totalRewards);

                if (pool.lockingPeriod >= 94608000) {
                    payReferralCommission(msg.sender, totalRewards, 0);
                }

                user.rewardDebt = user.rewardDebt.add(totalRewards);
            }
        } else if (pending > 0) {
            user.rewardLockedUp = user.rewardLockedUp.add(pending);
            totalLockedUpRewards = totalLockedUpRewards.add(pending);
            emit RewardLockedUp(msg.sender, _pid, pending);
        }

        user.lastHarvest = block.timestamp;
    }

    function setReferDepth(uint256 _depth) public onlyOwner {
        referDepth = _depth;
    }

    function setReferralCommissionTier(uint256[] memory _referralCommissionTier)
        public
        onlyOwner
    {
        referralCommissionTier = _referralCommissionTier;
    }

    // Update dev address by the previous dev.
    function setDevAddress(address _devAddress) public {
        require(msg.sender == devAddress, "setDevAddress: FORBIDDEN");
        require(_devAddress != address(0), "setDevAddress: ZERO");
        devAddress = _devAddress;
    }

    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        require(_feeAddress != address(0), "setFeeAddress: ZERO");
        feeAddress = _feeAddress;
    }

    // Update the Wedex referral contract address by the owner
    function setWedexReferral(WEXReferral _wedexReferral) public onlyOwner {
        wedexReferral = _wedexReferral;
    }

    //Update the EmergencyWithdrawEnable
    function setEmergencyWithdrawEnable(bool _emergencyWithdrawEnable)
        public
        onlyOwner
    {
        emergencyLockingWithdrawEnable = _emergencyWithdrawEnable;
    }

    function getReferralCommissionRate(uint256 depth)
        private
        view
        returns (uint256)
    {
        return referralCommissionTier[depth];
    }

    function setWexToken(IBEP20 _wedex) public onlyOwner {
        wedex = _wedex;
    }

    function setRewardToken(address _rewardToken) public onlyOwner {
        rewardToken = _rewardToken;
    }

    function setDirectCommissionForVip(uint256[] memory _value)
        public
        onlyOwner
    {
        directCommissionForVip = _value;
    }

    // Pay referral commission to the referrer who referred this user.
    function payReferralCommission(
        address _user,
        uint256 _pending,
        uint256 depth
    ) internal {
        if (depth < referDepth) {
            if (address(wedexReferral) != address(0)) {
                address _referrer = wedexReferral.getReferrer(_user);

                uint256 commissionAmount = _pending
                    .mul(getReferralCommissionRate(depth))
                    .div(10000);

                if (commissionAmount > 0 && _referrer != address(0)) {
                    if (commissionBalance[_referrer] < commissionAmount) {
                        commissionAmount = commissionBalance[_referrer];
                    }

                    if (commissionAmount > 0) {
                        commissionBalance[_referrer] = commissionBalance[_referrer].sub(commissionAmount);
                        IBEP20(rewardToken).mint(_referrer, commissionAmount);
                        wedexReferral.recordReferralCommission(
                            _referrer,
                            commissionAmount
                        );
                        emit ReferralCommissionPaid(
                            _user,
                            _referrer,
                            commissionAmount
                        );
                    }

                    payReferralCommission(_referrer, _pending, depth.add(1));
                }
            }
        }
    }

    function recoverLostBNB() public onlyOwner {
        address payable _owner = payable(msg.sender);
        _owner.transfer(address(this).balance);
    }

    function recoverLostTokensExceptOurTokens(address _token, uint256 amount)
        public
        onlyOwner
    {
        IBEP20(_token).transfer(msg.sender, amount);
    }
}