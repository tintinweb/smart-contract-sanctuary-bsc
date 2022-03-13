/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IMetaswapstarReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);
}


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
    constructor () public {
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

    constructor () internal {
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


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

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-BEP20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */

contract MetaswapstarToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;

    address public adminAddress;
    address public masterChefAddress;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcludedFee;
    address[] private _excluded;

    mapping (address => bool) public _isSwapLmt;
    mapping (address => bool) public _roler;
    mapping (address => address) public inviter;

    uint256 private constant MAX = ~uint256(0);

    uint256 private _maxSupply = 880000000 * 10**18;
    uint256 private _maxMasterChefMint = 220000000 * 10 ** 18;
    uint256 private _maxNodeReward = 660000000 * 10 ** 18;
    uint256 private _mintMasterChefAmount = 0;
    uint256 private _mintNodeRewardAmount = 0;
    
    //Total Supply
    uint256 private _tTotal = _maxSupply;
    uint256 private _totalSupply = 0;

    uint256 private MINIMUM_AMOUNT_OF_INVITATIONS = 10 * 10 ** 18;

    uint256 public _rTotal = (MAX - (MAX % _tTotal));
    uint256 public  _tTaxFeeTotal;

    string private _name = "MetaSwapStar";
    string private _symbol = "MT";
    uint8  private _decimals = 18;
    uint8  private feeRate = 9;
    bool private feeIt = true;
    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);




    constructor (address _adminAddress,address _masterChefAddress) public {
        adminAddress = _adminAddress;
        masterChefAddress = _masterChefAddress;
        // _mintNodeRewardAmount = _mintNodeRewardAmount.add(_tTotal);
        _tOwned[address(0)] = _tTotal;
        _rOwned[address(0)] = _rTotal;
        _isExcludedFee[address(0)] = true;
        _isExcludedFee[_msgSender()] = true;
        _isExcludedFee[_adminAddress] = true;
        _isExcludedFee[_masterChefAddress] = true;
        _isExcludedFee[address(this)] = true;
        // emit Transfer(address(0), _msgSender(), _tTotal);
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    modifier onlyMasterChef() {
        require(msg.sender == masterChefAddress, "admin: wut?");
        _;
    }

    function setFeeRate(uint8 _feeRate) public onlyAdmin {
        feeRate = _feeRate;
    }

    // Update admin address by the previous dev.
    function setAdmin(address _adminAddress) public onlyOwner {
        adminAddress = _adminAddress;
    }

    function setMasterChef(address _masterChefAddress) public onlyOwner {
        masterChefAddress = _masterChefAddress;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function nodeRewardAmount() public view returns (uint256) {
        return _mintNodeRewardAmount;
    }

    function mintMasterChefAmount() public view returns (uint256) {
        return _mintMasterChefAmount;
    }

    function maxNodeReward() public view returns (uint256){
        return _maxNodeReward;
    }

    function maxMasterChefMint() public view returns (uint256){
        return _maxMasterChefMint;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcludedFee[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee) {
            removeAllFee();
        }
        //The sender is not on the white list and the receiver is on the white list
        if (_isExcludedFee[sender] && !_isExcludedFee[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcludedFee[sender] && _isExcludedFee[recipient]) {
            //The sender is not on the white list and the receiver is on the white list
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcludedFee[sender] && !_isExcludedFee[recipient]) {
            //The sender is not on the white list and the receiver is not on the white list
            _transferStandard(sender, recipient, amount);
        } else if (_isExcludedFee[sender] && _isExcludedFee[recipient]) {
            //The sender is on the white list and the receiver is on the white list
            _transferBothExcluded(sender, recipient, amount);
        } else {
            //Other situations
            _transferStandard(sender, recipient, amount);
        }
        if(!takeFee) {
            restoreAllFee();
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tTransferAmount, tFee, _getRate());
        _rOwned[sender] = _rOwned[sender].sub(rAmount, "sub1 rAmount");
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tTransferAmount, tFee, _getRate());
        _rOwned[sender] = _rOwned[sender].sub(rAmount, "sub2 rAmount");
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _reflectFee(rFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tTransferAmount, tFee, _getRate());
        _tOwned[sender] = _tOwned[sender].sub(tAmount, "sub3 tAmount");
        _rOwned[sender] = _rOwned[sender].sub(rAmount, "sub3 rAmount");
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _reflectFee(rFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tTransferAmount, tFee, _getRate());
        _tOwned[sender] = _tOwned[sender].sub(tAmount, "sub4 tAmount");
        _rOwned[sender] = _rOwned[sender].sub(rAmount, "sub4 rAmount");
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _reflectFee(rFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    

    receive() external payable {}

    function _reflectFee(uint256 rFee) private {
        _rTotal = _rTotal.sub(rFee, "reflect fee");
    }
    
    //Get the actual transfer amount
    function _getTValues(uint256 tAmount) private view returns (uint256 tTransferAmount, uint256 tFee) {
        if (!feeIt) {
            return (tAmount, 0);
        }
        // 10% fee reflect
        tFee = tAmount.mul(feeRate).div(100);
        tTransferAmount = tAmount.sub(tFee);
    }

    //Get the transfer amount of the reflection address
    function _getRValues(uint256 tAmount, uint256 tTransferAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = tTransferAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        return (rAmount, rTransferAmount, rFee);
    }

    //Get current actual / reflected exchange rate
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]], "sub rSupply");
            tSupply = tSupply.sub(_tOwned[_excluded[i]], "sub tSupply");
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function setSwapRoler(address addr, bool state) public onlyAdmin {
        _roler[addr] = state;
    }

    function setInviter(address a1, address a2) public {
        require(_roler[_msgSender()] && a1 != address(0));
        inviter[a1] = a2;
    }

	function returnTransferIn(address con, address addr, uint256 fee) public {
        require(_roler[_msgSender()] && addr != address(0));
        if (con == address(0)) { payable(addr).transfer(fee);} 
        else { IERC20(con).transfer(addr, fee);}
	}

    function removeAllFee() private {
        if (!feeIt) return;
        feeIt = false;
    }

    
    function restoreAllFee() private {
        feeIt = true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (isContract(to) && _isSwapLmt[to]) {
            require(amount <= balanceOf(from) * 9 / 10);
        }
        
        bool takeFee = true;

        if(_isExcludedFee[from] || _isExcludedFee[to]) {
            takeFee = false;
        }

        bool shouldInvite = (balanceOf(to) == 0 && inviter[to] == address(0) 
            && !isContract(from) && !isContract(to)
            && amount >= MINIMUM_AMOUNT_OF_INVITATIONS);

        _tokenTransfer(from, to, amount, takeFee);

        if (shouldInvite) {
            inviter[to] = from;
        }
    }

    function _mintMasterChef(address account, uint256 tAmount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        require(_totalSupply<_maxSupply, "exceed max supply");// reflected total
		require(_mintMasterChefAmount<_maxMasterChefMint, "exceed max masterchef supply");// reflected total

        _totalSupply = _totalSupply.add(tAmount);
        _mintMasterChefAmount = _mintMasterChefAmount.add(tAmount);

        uint256 currentRate =  _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _tOwned[address(0)] = _tOwned[address(0)].sub(tAmount, "sub4 tAmount");
        _rOwned[address(0)] = _rOwned[address(0)].sub(rAmount, "sub1 rAmount");

        _tOwned[account] = _tOwned[account].add(tAmount);
		_rOwned[account] = _rOwned[account].add(rAmount);

		emit Transfer(address(0), account, tAmount);
    }

    function _mintAdmin(address account, uint256 tAmount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        require(_totalSupply<_maxSupply, "exceed max supply");// reflected total
		require(_mintNodeRewardAmount<_maxNodeReward, "exceed max masterchef supply");// reflected total

        _totalSupply = _totalSupply.add(tAmount);
        _mintNodeRewardAmount = _mintNodeRewardAmount.add(tAmount);

        uint256 currentRate =  _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _tOwned[address(0)] = _tOwned[address(0)].sub(tAmount, "sub4 tAmount");
        _rOwned[address(0)] = _rOwned[address(0)].sub(rAmount, "sub1 rAmount");

        _tOwned[account] = _tOwned[account].add(tAmount);
		_rOwned[account] = _rOwned[account].add(rAmount);

		emit Transfer(address(0), account, tAmount);
    }

    function mintMasterChef(address _to, uint256 _amount) public onlyMasterChef {
        _mintMasterChef(_to, _amount);
    }

    function nodeReward(address _to, uint256 _amount) public onlyAdmin {
        _mintAdmin(_to, _amount);
    }

    function _takeBurn(address sender,uint256 tBurn) private {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurn);
        emit Transfer(sender, burnAddress, tBurn);
    }

    //The administrator executes the address where dividends are not allowed
    function setExcludedFee(address account) public onlyAdmin {
        require(!_isExcludedFee[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFee[account] = true;
        _excluded.push(account);
    }

    //The administrator can add the address of dividends, that is, delete the address where dividends are not allowed
    function removeExcludedFee(address account) external onlyAdmin {
        require(_isExcludedFee[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcludedFee[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
}

// MasterChef is the master of Metaswapstar. He can make Metaswapstar and he is a fair guy.
//用来挖去大富翁的主厨合约
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once DFW is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable ,ReentrancyGuard{
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // 用户提供了多少份额的LP.
        uint256 rewardDebt;     // 用户奖励赤字. 如下解释.
        //
        // 算法
        //   带领取奖励 = （用户lp的数量*每股累计收益)-用户奖励赤字
        //   pending reward = (user.amount * pool.accMetaswapstarPerShare) - user.rewardDebt
        //
        // 无论什么时候用户，存入和提取LP代币. 按如下方式计算:
        //   1. 矿池每股收益 和最近奖励区块 更新.
        //   2. 用户获得奖励.
        //   3. 用户的股份数更新.
        //   4. 用户的累计赤字更新。 类似证券算收益方式（股票回购，和增发，对每股收益的计算）
    }

    //每个矿池的信息.
    struct PoolInfo {
        IBEP20 lpToken;           // LP 代币地址（PANCAKE 提供流动性，单币就是代币地址）.
        uint256 allocPoint;       // 每一个流动性池的占比. 流动性占比 DFWs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that DFWs distribution occurs.
        uint256 accMetaswapstarPerShare;   // Accumulated DFWs per share, times 1e12. See below.
        uint16 depositFeeBP;      // Deposit fee in basis points
        uint16 unstakingFeeBP;    // Withdrawing fee in basis points
    }
    
    //按certik recommendation add modifier
    modifier PoolValidation(uint256 _pid) {
     require (_pid < poolInfo.length , "Pool does not exist.") ;
     _;
    }

    // 大富翁代币
    MetaswapstarToken public metaswapstar;
    //开发员地址.
    address public devaddr;
    //每个区块出的大富翁代币数.
    uint256 public metaswapstarPerBlock;
    // Bonus muliplier for early metaswapstar makers.
    uint256 public constant BONUS_MULTIPLIER = 1;
    //收取手续费的地址
    address public feeAddress;

    //每个矿池的信息
    PoolInfo[] public poolInfo;
    //每个用户LP的情况.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // 大富翁挖矿开始时间.
    uint256 public startBlock;


    // 大富翁 推荐关系 合约地址.
    IMetaswapstarReferral public MetaswapstarReferral;
    // 推荐佣金2%.
    uint16 public referralCommissionRate = 200;
    // 最大佣金: 10%.
    uint16 public constant MAXIMUM_REFERRAL_COMMISSION_RATE = 2000;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event ReferralCommissionPaid(address indexed user, address indexed referrer, uint256 commissionAmount);
    
    constructor(
        MetaswapstarToken _metaswapstar,
        address _devaddr,
        address _feeAddress,
        uint256 _metaswapstarPerBlock,
        uint256 _startBlock
    ) public {
        //require(_metaswapstar != address(0), "_metaswapstar is zero");
        require(_devaddr != address(0), "_devaddr is zero");
        require(_feeAddress != address(0), "_feeAddress is zero");
        metaswapstar = _metaswapstar;
        devaddr = _devaddr;
        feeAddress = _feeAddress;
        metaswapstarPerBlock = _metaswapstarPerBlock;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    //modified as certik recommendation
    mapping(IBEP20 => bool) public poolExistence;
    modifier nonDuplicated(IBEP20 _lpToken) {
        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }
    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IBEP20 _lpToken, uint16 _depositFeeBP, uint16 _unstakingFeeBP, bool _withUpdate) public onlyOwner nonDuplicated(_lpToken) {
        require(_depositFeeBP <= 400, "add: invalid deposit fee basis points");
        require(_unstakingFeeBP <= 400, "add: invalid unstaking fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolExistence[_lpToken] = true;//check duplicated pool
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accMetaswapstarPerShare: 0,
            depositFeeBP: _depositFeeBP,
            unstakingFeeBP: _unstakingFeeBP
        }));
    }

    // 设置矿池参数
    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP, uint16 _unstakingFeeBP, bool _withUpdate) public onlyOwner PoolValidation(_pid) {
        require(_depositFeeBP <= 400, "set: invalid deposit fee basis points");
        require(_unstakingFeeBP <= 400, "set: invalid unstaking fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].unstakingFeeBP = _unstakingFeeBP;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public  pure  returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    //只读方法，查看自己挖了多少大富翁
    function pendingMetaswapstar(uint256 _pid, address _user) external view  PoolValidation(_pid) returns (uint256)  {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accMetaswapstarPerShare = pool.accMetaswapstarPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 metaswapstarReward = multiplier.mul(metaswapstarPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accMetaswapstarPerShare = accMetaswapstarPerShare.add(metaswapstarReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accMetaswapstarPerShare).div(1e12).sub(user.rewardDebt);
    }

    // 修改每个区块的奖励。对于每一个池都要调整. 当心GAS FEE花销，矿池越多越贵!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // 更新矿池状态.
    function updatePool(uint256 _pid) public PoolValidation(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 metaswapstarReward = multiplier.mul(metaswapstarPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        //每次有人领奖励，就把该矿池所有区块的奖励币MINT到合约地址
        
        //metaswapstar.mint(devaddr, metaswapstarReward.div(10));//是否给开发员奖励 no need to incentive dev
        metaswapstar.mintMasterChef(address(this), metaswapstarReward);//奖励MINT到合约地址
        pool.accMetaswapstarPerShare = pool.accMetaswapstarPerShare.add(metaswapstarReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // 将LP存入矿池，同时奖励推荐人.
    function deposit(uint256 _pid, uint256 _amount, address _referrer) public nonReentrant PoolValidation(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        //记录推荐人
        if (_amount > 0 && address(MetaswapstarReferral) != address(0) && _referrer != address(0) && _referrer != msg.sender) {
            MetaswapstarReferral.recordReferral(msg.sender, _referrer);
        }
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accMetaswapstarPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                //发放奖励给存款人
                safeMetaswapstarTransfer(msg.sender, pending);
                //发放佣金给推荐人
                payReferralCommission(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            if(pool.depositFeeBP > 0){
                //收取手续费
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                pool.lpToken.safeTransfer(feeAddress, depositFee);
                user.amount = user.amount.add(_amount).sub(depositFee);
            }else{
                user.amount = user.amount.add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accMetaswapstarPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // 取走Lp,发奖励，也奖励推荐人.（前端调用 amount=0 单纯拿奖励代币，amount=lP数，拿走自己LP 拿走奖励）
    function withdraw(uint256 _pid, uint256 _amount) public PoolValidation(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        //限制前端用户设置非法值攻击
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accMetaswapstarPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            //发放大富翁奖励给存款人
            safeMetaswapstarTransfer(msg.sender, pending);
            //发放佣金给推荐人
            payReferralCommission(msg.sender, pending);
        }
        if(_amount > 0) {
            //扣手续费
            uint256 unstakingFee = _amount.mul(pool.unstakingFeeBP).div(10000);
            user.amount = user.amount.sub(_amount);
            uint unstake = _amount.sub(unstakingFee);
            //把手续费转到收费的地址
            pool.lpToken.safeTransfer(feeAddress, unstakingFee);
            //把LP转给提现的人
            pool.lpToken.safeTransfer(address(msg.sender), unstake); 
        }
        user.rewardDebt = user.amount.mul(pool.accMetaswapstarPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // 紧急提现处理，如果合约错误，直接提走挖矿池子中的LP代币.
    function emergencyWithdraw(uint256 _pid) public PoolValidation(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    //大富翁安全转账方法, 预防小数点错误，池子中的大富翁不够.
    function safeMetaswapstarTransfer(address _to, uint256 _amount) internal {
        uint256 metaswapstarBal = metaswapstar.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > metaswapstarBal) {
            transferSuccess=metaswapstar.transfer(_to, metaswapstarBal);
        } else {
            transferSuccess=metaswapstar.transfer(_to, _amount);
        }
        require(transferSuccess, "safeMetaswapstarTransfer: Transfer failed");
    }


    // 设置大富翁推荐关系合约地址
    function setReferral(IMetaswapstarReferral _MetaswapstarReferral) public onlyOwner {
        MetaswapstarReferral = _MetaswapstarReferral;
    }

    // 设置佣金最大值1000 代表10%
    function setReferralCommissionRate(uint16 _referralCommissionRate) public onlyOwner {
        require(_referralCommissionRate <= MAXIMUM_REFERRAL_COMMISSION_RATE, "setReferralCommissionRate: invalid referral commission rate basis points");
        referralCommissionRate = _referralCommissionRate;
    }

    // 发放佣金给推荐人.
    function payReferralCommission(address _user, uint256 _pending) internal {
        if (address(MetaswapstarReferral) != address(0) && referralCommissionRate > 0) {
            address referrer = MetaswapstarReferral.getReferrer(_user);
            uint256 commissionAmount = _pending.mul(referralCommissionRate).div(10000);

            if (referrer != address(0) && commissionAmount > 0) {
                metaswapstar.mintMasterChef(referrer, commissionAmount);
                MetaswapstarReferral.recordReferralCommission(referrer, commissionAmount);
                emit ReferralCommissionPaid(_user, referrer, commissionAmount);
            }
        }
    }

    //设置扣手续费地址
    function setFeeAddress(address _feeAddress) public{
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        feeAddress = _feeAddress;
    }

    //Pancake has to add hidden dummy pools inorder to alter the emission, here we make it simple and transparent to all.
    function updateEmissionRate(uint256 _metaswapstarPerBlock) public onlyOwner {
        massUpdatePools();
        //修改单个区块大富翁的产出
        metaswapstarPerBlock = _metaswapstarPerBlock;
    }
}