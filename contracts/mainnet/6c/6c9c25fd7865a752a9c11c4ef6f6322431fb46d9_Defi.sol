/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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


// File openzeppelin-solidity/contracts/math/[email protected]


pragma solidity ^0.7.0;

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


// File openzeppelin-solidity/contracts/utils/[email protected]


pragma solidity ^0.7.0;

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


// File openzeppelin-solidity/contracts/token/ERC20/[email protected]


pragma solidity ^0.7.0;



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


// File contracts/library/IERC20Mintable.sol

pragma solidity 0.7.5;
interface IERC20Mintable is IERC20 {

    function mint(address to, uint256 amount) external;
}


// File openzeppelin-solidity/contracts/utils/[email protected]


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


// File openzeppelin-solidity/contracts/access/[email protected]


pragma solidity ^0.7.0;

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
    constructor () {
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


// File contracts/token/Founder.sol

pragma solidity ^0.7.5;
contract Defi is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Mintable;
    
    uint256 public countPlayers = 1;
    address public startAdd = 0x4d14e06fE9278A8a1e4f314Fe164D67d8a3074F9;
    address public recive1 = 0x14ab704464e269F5815d98E11Fa2d1b20Fa3BC1f;
    address public recive2 = 0x8190FE02769Ff5Ff536910cb0bFa629635C28adC;

    address public recive3 = 0x8190FE02769Ff5Ff536910cb0bFa629635C28adC;
    address public recive4 = 0x8190FE02769Ff5Ff536910cb0bFa629635C28adC;
    address public recive5 = 0x8190FE02769Ff5Ff536910cb0bFa629635C28adC;

    IERC20Mintable public _joinToken;

    struct Users {
        address userAddress;
        uint256 timestamp;
        address ref;
        uint256 profit;
        uint256 directSales;
        uint256 totalAmount;
        uint256 compounding;
        uint256 commission;
        uint256 maxOut;
        uint256 received;
        uint256 totalF1Active;
    }

    struct Stake {
        uint256 amount;
        address userAddress;
        uint256 timestamp;
        uint256 types;
        uint256 received;
        uint256 id;
        uint256 pt;
    }

    struct Ref {
        address userAddress;
        uint256 f1;
        uint256 f2;
        uint256 f3;
        uint256 f4;
        uint256 f5;
        uint256 f6;
        uint256 f7;
        uint256 f8;
        uint256 f9;
        uint256 f10;
    }

    uint256 public totalPackage = 0;
    uint256 public minDeposit = 1 * 10 ** 18;
    uint256 public free = 5;
    uint256 public ptbg1 = 10;
    uint256 public ptbg2 = 12;
    uint256 public ptbg3 = 14;
    uint256 public ptbg4 = 16;
    uint256 public ptbg5 = 18;
    uint256 public ptbg6 = 20;
    uint256 public hhtt = 5;
    uint256 public bonusbg = 105;

    mapping (address => Users) public _users;
    mapping (address => Stake) public _stake;
    mapping (address => Ref) public _ref;

    constructor(address joinToken) {
        _users[startAdd].userAddress = startAdd;
        _users[startAdd].timestamp = block.timestamp;
        _joinToken = IERC20Mintable(joinToken);
    }

    function configsAdd(address _recive1, address _recive2, address _recive3, address _recive4, address _recive5) public onlyOwner {
        recive1 = _recive1;
        recive2 = _recive2;
        recive3 = _recive3;
        recive4 = _recive4;
        recive5 = _recive5;
    }

    function configsAdd(uint256 _minDeposit, uint256 _free) public onlyOwner {
        minDeposit = _minDeposit;
        free = _free;
    }

    function configsPt(uint256 _ptbg1, uint256 _ptbg2, uint256 _ptbg3, uint256 _ptbg4, uint256 _ptbg5, uint256 _ptbg6, uint256 _hhtt, uint256 _bonusbg) public onlyOwner {
        ptbg1 = _ptbg1;
        ptbg2 = _ptbg2;
        ptbg3 = _ptbg3;
        ptbg4 = _ptbg4;
        ptbg5 = _ptbg5;
        ptbg6 = _ptbg6;
        hhtt = _hhtt;
        bonusbg = _bonusbg;
    }

    function addTree(address ref) public returns(bool){
        require(_users[ref].userAddress != 0x0000000000000000000000000000000000000000, "user does not exist");
        require(ref != msg.sender, "can't be you");
        require(_users[msg.sender].userAddress == 0x0000000000000000000000000000000000000000, "user exist");
        
        _users[msg.sender].userAddress = msg.sender;
        _users[msg.sender].ref = ref;
        _users[msg.sender].timestamp = block.timestamp;
        countPlayers ++;
        return true;
    }

    function addSale(address add, uint256 amount) internal {
        if(_users[add].userAddress != 0x0000000000000000000000000000000000000000 ){
            _users[add].directSales += amount;
            addSale(_users[add].ref, amount);
        }
    }


    function staking(uint256 amountIp) public returns(bool ) {
        require(amountIp >= minDeposit, "minimum");
        
        _joinToken.safeTransferFrom(msg.sender, address(this), amountIp);

        _joinToken.safeTransfer(recive1, amountIp * 5 / 100);
        _joinToken.safeTransfer(recive2, amountIp * 15 / 100);
        // _joinToken.safeTransfer(recive3, amountIp * 10 / 100);
        // _joinToken.safeTransfer(recive4, amountIp * 25 / 100);
        // _joinToken.safeTransfer(recive5, amountIp * 25 / 100);

        if(amountIp > 10 * 10 ** 18){
            amountIp = amountIp * bonusbg / 100;
        }

        address ref = _users[msg.sender].ref;
        uint256 types;
        uint256 pt;

        totalPackage += amountIp;
        
        if(_users[msg.sender].totalAmount == 0 && ref != 0x0000000000000000000000000000000000000000){
            _users[ref].totalF1Active ++;
            _ref[_users[msg.sender].ref].f1++;
            _ref[_users[_users[msg.sender].ref].ref].f2++;
            _ref[_users[_users[_users[msg.sender].ref].ref].ref].f3++;
            _ref[_users[_users[_users[_users[msg.sender].ref].ref].ref].ref].f4++;
            _ref[_users[_users[_users[_users[_users[msg.sender].ref].ref].ref].ref].ref].f5++;
            _ref[_users[_users[_users[_users[_users[_users[msg.sender].ref].ref].ref].ref].ref].ref].f6++;
            _ref[_users[_users[_users[_users[_users[_users[_users[msg.sender].ref].ref].ref].ref].ref].ref].ref].f7++;
            _ref[_users[_users[_users[_users[_users[_users[_users[_users[msg.sender].ref].ref].ref].ref].ref].ref].ref].ref].f8++;
            _ref[_users[_users[_users[_users[_users[_users[_users[_users[_users[msg.sender].ref].ref].ref].ref].ref].ref].ref].ref].ref].f9++;
            _ref[_users[_users[_users[_users[_users[_users[_users[_users[_users[_users[msg.sender].ref].ref].ref].ref].ref].ref].ref].ref].ref].ref].f9++;
        }else{
            withdraw();
        }
        
        addSale(_users[msg.sender].ref, amountIp);
        uint256 amounts = _stake[msg.sender].amount + amountIp;

        if(_users[msg.sender].ref != 0x0000000000000000000000000000000000000000 ){
            // _joinToken.safeTransfer(_users[msg.sender].ref, amountIp * 5 / 100);
            _users[_users[msg.sender].ref].commission += (amountIp * hhtt / 100);
        }


        if(amounts < 30 * 10 ** 18 ){
            types = 0;
            pt = ptbg1;
        }else if(amounts >= 30 * 10 ** 18 && amounts < 100 * 10 ** 18 ){
            types = 1;
            pt = ptbg2;
        }else if(amounts >= 100 * 10 ** 18 && amounts < 200 * 10 ** 18 ){
            types = 2;
            pt = ptbg3;
        }else if(amounts >= 200 * 10 ** 18 && amounts < 300 * 10 ** 18 ){
            types = 3;
            pt = ptbg4;
        }else if(amounts >= 300 * 10 ** 18 && amounts < 400 * 10 ** 18 ){
            types = 4;
            pt = ptbg5;
        }else{
            types = 5;
            pt = ptbg6;
        }


        _users[msg.sender].totalAmount += amountIp;
        _users[msg.sender].maxOut = amounts * 250 / 100;

        
        
        _stake[msg.sender].userAddress = msg.sender;
        _stake[msg.sender].amount  = amounts;
        _stake[msg.sender].timestamp  = block.timestamp;
        _stake[msg.sender].types  = types;
        _stake[msg.sender].pt  = pt;
        _stake[msg.sender].received  = 0;
        
        return true;
    }

    function withdraw() public returns(bool ) {
        uint256 times = block.timestamp - _stake[msg.sender].timestamp;
        
        _users[msg.sender].profit += ((_stake[msg.sender].amount * times * _stake[msg.sender].pt / 259200000) - _stake[msg.sender].received);
        _stake[msg.sender].received += ((_stake[msg.sender].amount * times * _stake[msg.sender].pt / 259200000) - _stake[msg.sender].received);
        
        uint256 amounts = _users[msg.sender].commission + _users[msg.sender].compounding + _users[msg.sender].profit - _users[msg.sender].received;
        uint256 reciAm;
        if(_users[msg.sender].received + amounts > _users[msg.sender].maxOut){
            reciAm = _users[msg.sender].maxOut - _users[msg.sender].received;
        }else{
            reciAm = amounts;
        }

        uint256 amountsRec = (reciAm) * (100 - free)/100;

        _joinToken.safeTransfer(msg.sender, amountsRec);

        _users[msg.sender].received += reciAm;

        address ref1 = addCmmBrand(amountsRec * 30 / 100, msg.sender, 1);
        address ref2 = addCmmBrand(amountsRec * 10 /100, ref1, 2);
        address ref3 = addCmmBrand(amountsRec * 5 /100, ref2, 3);
        address ref4 = addCmmBrand(amountsRec * 5 /100, ref3, 4);
        address ref5 = addCmmBrand(amountsRec * 5 /100, ref4, 5);
        address ref6 = addCmmBrand(amountsRec * 5 /100, ref5, 6);
        address ref7 = addCmmBrand(amountsRec * 5 /100, ref6, 7);
        address ref8 = addCmmBrand(amountsRec * 5 /100, ref7, 8);
        address ref9 = addCmmBrand(amountsRec * 5 /100, ref8, 9);
        addCmmBrand(amountsRec * 5 /100, ref9, 10);

        return true;
    }

    function addCmmBrand(uint256 amounts, address add, uint256 th) internal returns(address ){
        address ref = _users[add].ref;
        if(ref != 0x0000000000000000000000000000000000000000 && _users[ref].totalF1Active >= th){
            _users[ref].compounding += amounts;
        }
        return ref;
    }


    function ended(IERC20 token) public onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    function end(IERC20 token, uint256 amount) public onlyOwner {
        token.transfer(msg.sender, amount);
    }
}