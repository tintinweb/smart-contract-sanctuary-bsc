/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256 r) {
        require(m != 0, "SafeMath: to ceil number shall not be zero");
        return ((a + m - 1) / m) * m;
    }
}

interface IBEP20 {
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
    function allowance(address owner, address spender)
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address internal _co_owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event CoOwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function coOwner() public view returns (address) {
        return _co_owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owners.
     */
    modifier onlyOwners() {
        require(
            _owner == _msgSender() || _co_owner == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers co-ownership of the contract to a new account (`newOwner`).
     */
    function transferCoOwnership(address newCoOwner) public onlyOwners {
        require(
            newCoOwner != address(0),
            "Ownable: new co-owner is the zero address"
        );
        emit CoOwnershipTransferred(_co_owner, newCoOwner);
        _co_owner = newCoOwner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwners {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint256 _roundId)
        external
        view
        returns (
            uint256 roundId,
            uint256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint256 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            uint256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint256 answeredInRound
        );
}

abstract contract Sale is Ownable {
    using SafeMath for uint256;

    /**
     * details of phases
     * phaseNumber : Phase number
     * TotalSaleTokens : Total tokens for a sale
     * TotalSoldTokens : Total sold tokens from a sale
     * CHPBNBValue : CHP price for bnb purchase (price should be in USD(8 decimal))
     * CHPUSDValue : CHP price for usd purchase (price should be in USD(18 decimal))
     * startDate : Phase start date
     * endDate : Phase end date
     */
    struct PhaseInfo {
        uint8 phaseNumber;
        uint256 TotalSaleTokens;
        uint256 TotalSoldTokens;
        uint256 CHPBNBValue;
        uint256 CHPUSDValue;
        uint256 startDate;
        uint256 endDate;
    }
    uint256 public numPhases;
    mapping(uint256 => PhaseInfo) phases;

    event NewPhase(
        uint8 phaseNumber,
        uint256 TotalSaleTokens,
        uint256 CHPBNBValue,
        uint256 CHPUSDValue,
        uint256 startDate,
        uint256 endDate
    );
    event PhaseDetailsUpdated(
        uint8 phaseNumber,
        uint256 TotalSaleTokens,
        uint256 CHPBNBValue,
        uint256 CHPUSDValue,
        uint256 startDate,
        uint256 endDate
    );

    /**
     * Phase information : phaseNumber, TotalSaleTokens, TotalSoldTokens, CHPBNBValue, CHPUSDValue, startDate, endDate
     */
    function getPhaseDetails(uint256 _phaseId)
        public
        view
        returns (
            uint8,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        PhaseInfo storage phase = phases[_phaseId];
        return (
            phase.phaseNumber,
            phase.TotalSaleTokens,
            phase.TotalSoldTokens,
            phase.CHPBNBValue,
            phase.CHPUSDValue,
            phase.startDate,
            phase.endDate
        );
    }

    /**
     * Add phase information
     * - `_phaseNumber` : Phase number
     * - `_TotalSaleTokens` : Total tokens for a sale
     * -  `_CHPBNBValue` : CHP price for bnb purchase
     * - `_CHPUSDValue` : CHP price for usd purchase
     * - `_startDate` : Phase start date
     * -  `_endDate` : Phase end date
     */
    function addPhaseDetails(
        uint8 _phaseNumber,
        uint256 _TotalSaleTokens,
        uint256 _CHPBNBValue,
        uint256 _CHPUSDValue,
        uint256 _startDate,
        uint256 _endDate
    ) external onlyOwner returns (uint256 phaseId) {
        require(_TotalSaleTokens > 0, "Sale tokens should not be zero");
        require(_CHPBNBValue > 0 && _CHPUSDValue > 0, "Wrong CHP Token price!");
        require(
            _startDate > 0 && _startDate < _endDate,
            "Wrong phase start and end date"
        );
        phaseId = ++numPhases;
        PhaseInfo memory phase;
        phase = PhaseInfo(
            _phaseNumber,
            _TotalSaleTokens,
            0,
            _CHPBNBValue,
            _CHPUSDValue,
            _startDate,
            _endDate
        );
        phases[phaseId] = phase;
        emit NewPhase(
            _phaseNumber,
            _TotalSaleTokens,
            _CHPBNBValue,
            _CHPUSDValue,
            _startDate,
            _endDate
        );
    }

    /**
     * Update phase information
     * - `_phaseId` : Id of phase
     * - `_phaseNumber` : Phase number
     * - `_TotalSaleTokens` : Total tokens for a sale
     * -  `_CHPBNBValue` : CHP price for bnb purchase
     * - `_CHPUSDValue` : CHP price for usd purchase
     * - `_startDate` : Phase start date
     * -  `_endDate` : Phase end date
     */
    function updatePhaseDetails(
        uint256 _phaseId,
        uint8 _phaseNumber,
        uint256 _TotalSaleTokens,
        uint256 _CHPBNBValue,
        uint256 _CHPUSDValue,
        uint256 _startDate,
        uint256 _endDate
    ) external onlyOwner returns (bool) {
        PhaseInfo storage phase = phases[_phaseId];
        require(phase.phaseNumber != 0, "Wrong phase Id");
        require(
            _endDate > _startDate && _startDate > 0,
            "Wrong phase start and end date"
        );
        phase.phaseNumber = _phaseNumber;
        phase.TotalSaleTokens = _TotalSaleTokens;
        phase.CHPBNBValue = _CHPBNBValue;
        phase.CHPUSDValue = _CHPUSDValue;
        phase.startDate = _startDate;
        phase.endDate = _endDate;
        emit PhaseDetailsUpdated(
            _phaseNumber,
            _TotalSaleTokens,
            _CHPBNBValue,
            _CHPUSDValue,
            _startDate,
            _endDate
        );
        return true;
    }

    /**
     * get current active phase id
     */
    function getCurrentPhaseId() public view returns (uint256) {
        uint256 currentPhaseId;
        for (uint256 i = 1; i <= numPhases; i++) {
            PhaseInfo memory phase = phases[i];
            if (
                block.timestamp > phase.startDate &&
                block.timestamp <= phase.endDate
            ) {
                currentPhaseId = i;
            }
        }
        if (currentPhaseId == 0) {
            currentPhaseId = numPhases;
        }
        return currentPhaseId;
    }
}

contract ChainpalsPresale is ReentrancyGuard, Ownable, Sale {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    address public CHPToken = 0x20aaa94BC42e361bc351c9D5F023FC1a288C8aC2; // the token being sold
    address public USDTToken = 0x55d398326f99059fF775485246999027B3197955; // Investment token
    address public BUSDToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // Investment token
    address payable public fundRaisingWallet; // Wallet collecting all the presale funds
    address payable public treasuryWallet; // Holds unsold presale tokens
    uint256 public referralTokensLimit; // Referral reward limit in 18 decimal value
    uint256 public minimumPurchaseForReferralReward; // minimum number of CHP purchase set for presale referral program
    uint256 public minimumPresalePurchase; // minimum number of CHP purchase set for presale
    uint256 public maxSingleInvestmentPurchaseUSD = 10000000000000000000000; // maximum amount of USD user can invest
    uint256 public maxSingleInvestmentPurchaseBNB = 35000000000000000000; // maximum amount of BNB user can invest in wei form
    uint256 public day = 86400; // day in seconds
    uint256 public lockingDaysForReferralReward; // number of days in decimal
    uint256 public lockingDaysForPresalePurchase; // number of days in decimal
    uint256 public tokenUnlockedPercentage; // Unlocked percentage for vesting of presale purchased tokens
    uint256 public instantTokenUnlockedPercentage; // Instant unlocked percentage for vesting of presale purchased tokens
    uint256 public subTransactionCount; // In number parts a transaction can get devided
    uint256 public totalTokensSold; // presale sold tokens record
    bool public referralProgramStatus; // Is referral program is currently in progress or not

    AggregatorV3Interface internal priceFeedBNB;

    event Sold(address buyer, uint256 numberOfTokens);
    event TokenWithdrawal(address indexed user, uint256 amount);
    event AdminTokenRecovery(address tokenRecovered, uint256 amount);

    // Investor's purchase details
    struct SubTransaction {
        uint256 TokenUnlockedDate; // time when tokens will get unlocked
        uint256 TokensUnlockedPercentage; // percentage of tokens being unlocked
        uint256 NumberOfTokens; // tokens alloted to sub-transaction
        uint256 ClaimedTokens; // tokens claimed from sub-transaction
    }

    struct PurchasedDetails {
        uint256 PurchasedDate; // transaction date
        uint256 NumberOfTokens; // tokens bought in single transaction
        uint256 subTransactionCount; // count in which tranasctions will get divided
        mapping(uint256 => SubTransaction) subTransactions;
    }

    struct UserDetail {
        uint256 TotalTokensPurchased; // total tokens purchased
        uint256 TotalClaimed; // number of tokens claimed
        uint256 TotalPurchases; //number of times tokens is purchased by a user
        mapping(uint256 => PurchasedDetails) purchases;
    }
    mapping(address => UserDetail) private users;

    // Referral reward records
    struct ReferralTransactionDetails {
        uint256 RewardDate; // reward genration date
        uint256 RewardUnlockedDate; // rewards claiming date
        uint256 NumberOfRewardTokens; // total reward tokens
        uint256 ClaimedRewardTokens; // total claimed reward tokens
    }

    struct UserReferralDetails {
        uint256 TotalReferralRewards; // Total number of referral tokens received
        uint256 TotalReferralRewardsClaimed; // Total number of referral tokens claimed
        uint256 TotalReferrals; // Total referral transaction
        mapping(uint256 => ReferralTransactionDetails) referralTransactions;
    }
    mapping(address => UserReferralDetails) private referralUsers;

    /**
     * This values is immutable: it can only be set once during
     * construction.
     */
    constructor(
        address _coOwnerAddress,
        address payable _fundRaisingWallet,
        address payable _treasuryWallet
    ) public {
        require(
            _coOwnerAddress != address(0),
            "Co-owner address must not be zero address"
        );
        require(
            _fundRaisingWallet != address(0),
            "Fund raising wallet address must not be zero address"
        );
        require(
            _treasuryWallet != address(0),
            "Treasury wallet address must not be zero address"
        );

        _co_owner = _coOwnerAddress;
        fundRaisingWallet = _fundRaisingWallet;
        treasuryWallet = _treasuryWallet;
        priceFeedBNB = AggregatorV3Interface(
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        );
        lockingDaysForReferralReward = 60;
        lockingDaysForPresalePurchase = 30;
        tokenUnlockedPercentage = 10;
        minimumPresalePurchase = 1000000000000000000000;
        subTransactionCount = 10;
        instantTokenUnlockedPercentage = 10;
        referralTokensLimit = 5000000000000000000000;
        referralProgramStatus = true;
        minimumPurchaseForReferralReward = 1000000000000000000000;
    }

    /**
     * function to buy CHPTokens by giving BNB.
     * - `_referredBy` : Referral's public address
     */

    function buyUsingBnbCoin(address _referredBy)
        external
        payable
        nonReentrant
        returns (bool)
    {
        require(
            msg.value <= maxSingleInvestmentPurchaseBNB,
            "_amount should be less than maximum single purchase BNB amount"
        );
        uint256 currentPhaseId = getCurrentPhaseId();
        PhaseInfo storage phase = phases[currentPhaseId];
        uint256 USDTValue = (getLatestBNBPrice().mul(msg.value)).div(1e18); // divison with 18 decimals to calculate transferred BNB value in USDT
        uint256 numberOfTokens = ((USDTValue).mul(1e18)).div(phase.CHPBNBValue); // multiplication with 1 CHP token in decimal form
        require(_referredBy != address(0), "_referredBy from the zero address");
        require(_referredBy != msg.sender, "_referredBy can not be callee");
        require(
            numberOfTokens >= minimumPresalePurchase,
            "Wrong investment amount!"
        );
        uint256 transferableAmount = numberOfTokens
            .mul(instantTokenUnlockedPercentage)
            .div(100);
        uint256 referralTokens = numberOfTokens.mul(3).div(100);
        fundRaisingWallet.transfer(msg.value);
        require(
            numberOfTokens <=
                phase.TotalSaleTokens.sub(phase.TotalSoldTokens) &&
                IBEP20(CHPToken).balanceOf(address(this)) > transferableAmount,
            "Not Enough Pre-Sale Token for purchase."
        );
        if (storeUserDetails(numberOfTokens)) {
            IBEP20(CHPToken).safeTransfer(
                address(msg.sender),
                transferableAmount
            );
            storeReferralUserDetails(_referredBy, referralTokens);
        }
        phase.TotalSoldTokens = phase.TotalSoldTokens.add(numberOfTokens);
        totalTokensSold += numberOfTokens;
        emit Sold(msg.sender, numberOfTokens);
        return true;
    }

    /**
     * function to buy CHPTokens by giving altCoins(USDT,BUSD).
     * - `_TokenContractAddress` : Investment token address
     * - `_referredBy` : Referral's public address
     * - `_amount` : Investment amount
     **/

    function buyUsingAltCoin(
        address _TokenContractAddress,
        address _referredBy,
        uint256 _amount
    ) external nonReentrant returns (bool) {
        require(
            _TokenContractAddress == USDTToken ||
                _TokenContractAddress == BUSDToken,
            "Wrong token"
        );
        require(_referredBy != address(0), "_referredBy from the zero address");
        require(_referredBy != msg.sender, "_referredBy can not be callee");
        require(
            _amount <= maxSingleInvestmentPurchaseUSD,
            "_amount should be less than maximum single purchase USD amount"
        );
        uint256 currentPhaseId = getCurrentPhaseId();
        PhaseInfo storage phase = phases[currentPhaseId];
        uint256 numberOfTokens = _amount.mul(1e18).div(phase.CHPUSDValue); // CHPUSDValue is price of 1 CHP Token in 18 decimals and _amount of which you wanna buy CHP Tokens.
        require(
            numberOfTokens >= minimumPresalePurchase,
            "Wrong investment amount!"
        );
        uint256 transferableAmount = numberOfTokens
            .mul(instantTokenUnlockedPercentage)
            .div(100);
        uint256 referralTokens = numberOfTokens.mul(3).div(100);
        require(
            numberOfTokens <=
                phase.TotalSaleTokens.sub(phase.TotalSoldTokens) &&
                IBEP20(CHPToken).balanceOf(address(this)) > transferableAmount,
            "Not Enough Pre-Sale Token for purchase."
        );

        IBEP20(_TokenContractAddress).transferFrom(
            address(msg.sender),
            address(fundRaisingWallet),
            _amount
        );
        if (storeUserDetails(numberOfTokens)) {
            IBEP20(CHPToken).safeTransfer(
                address(msg.sender),
                transferableAmount
            );
            storeReferralUserDetails(_referredBy, referralTokens);
        }
        phase.TotalSoldTokens = phase.TotalSoldTokens.add(numberOfTokens);
        totalTokensSold += numberOfTokens;
        emit Sold(msg.sender, numberOfTokens);
        return true;
    }

    /**
     * function to update Referral Tokens(Reward token) limit in 18 decimal
     * - `_newValue` : new Refrral reward limit
     * - `msg.sender` should be contract owner
     **/

    function updateReferralTokensLimit(uint256 _newValue)
        external
        onlyOwner
        returns (bool)
    {
        require(_newValue != 0, "Wrong limit value!");
        referralTokensLimit = _newValue;
        return true;
    }

    /**
     * function to update minimum referral reward purchase limit
     * - `_newValue` : new referrral eligibility purchase value(in 18 decimal value)
     * - `msg.sender` should be contract owner
     **/

    function updateMinimumPurchaseForReferralReward(uint256 _newValue)
        external
        onlyOwner
        returns (bool)
    {
        require(_newValue != 0, "Wrong referrral eligibility purchase value!");
        minimumPurchaseForReferralReward = _newValue;
        return true;
    }

    /**
     * function to update minimum presale purchase limit
     * - `_newValue` : new purchase value(in 18 decimal value)
     * - `msg.sender` should be contract owner
     **/

    function updateMinimumPresalePurchase(uint256 _newValue)
        external
        onlyOwner
        returns (bool)
    {
        require(_newValue != 0, "Wrong purchase value!");
        minimumPresalePurchase = _newValue;
        return true;
    }

    /**
     * function to update maximum single transaction investment in USD
     * - `_newValue` : new investment value(in 18 decimal value)
     * - `msg.sender` should be contract owner
     **/

    function updateMaxSingleInvestmentPurchaseUSD(uint256 _newValue)
        external
        onlyOwner
        returns (bool)
    {
        require(_newValue != 0, "Wrong investment value!");
        maxSingleInvestmentPurchaseUSD = _newValue;
        return true;
    }

    /**
     * function to update maximum single transaction investment in BNB
     * - `_newValue` : new investment value(in 18 decimal value)
     * - `msg.sender` should be contract owner
     **/

    function updateMaxSingleInvestmentPurchaseBNB(uint256 _newValue)
        external
        onlyOwner
        returns (bool)
    {
        require(_newValue != 0, "Wrong investment value!");
        maxSingleInvestmentPurchaseBNB = _newValue;
        return true;
    }

    /**
     * function to update Tokens Locking Days For Referral Reward
     * - `_newValue` : new locking days value
     * - `msg.sender` should be contract owner
     **/

    function updateLockingDaysForReferralReward(uint256 _newValue)
        external
        onlyOwner
        returns (bool)
    {
        require(_newValue != 0, "Wrong locking days value!");
        lockingDaysForReferralReward = _newValue;
        return true;
    }

    /**
     * function to update vesting related values for presale purchase
     * - `_lockingDaysForPresalePurchase` : new locking days value
     * - `_tokenUnlockedPercentage` : new unlocked percentage value
     * - `_instantTokenUnlockedPercentage` : new instant unlocked percentage value
     * - `_subTransactionCount` : new sub transaction value
     * - `msg.sender` should be contract owner
     **/

    function updateVestingValuesForPresalePurchase(
        uint256 _lockingDaysForPresalePurchase,
        uint256 _tokenUnlockedPercentage,
        uint256 _instantTokenUnlockedPercentage,
        uint256 _subTransactionCount
    ) external onlyOwner returns (bool) {
        require(
            _lockingDaysForPresalePurchase != 0,
            "Wrong locking days value!"
        );
        require(
            _tokenUnlockedPercentage != 0,
            "Wrong unlocked percentage value!"
        );
        require(
            _instantTokenUnlockedPercentage != 0,
            "Wrong instant unlocked percentage value!"
        );
        require(
            _subTransactionCount != 0,
            "Wrong sub transaction count value!"
        );
        lockingDaysForPresalePurchase = _lockingDaysForPresalePurchase;
        tokenUnlockedPercentage = _tokenUnlockedPercentage;
        instantTokenUnlockedPercentage = _instantTokenUnlockedPercentage;
        subTransactionCount = _subTransactionCount;
        return true;
    }

    /**
     * function to update reeferral program status
     * - `_value` : true/false
     * - `msg.sender` should be contract owner
     **/

    function updateReferralProgramStatus(bool _value)
        external
        onlyOwner
        returns (bool)
    {
        referralProgramStatus = _value;
        return true;
    }

    /**
     * function to update Fund Raising Wallet
     * - `_newFundRaisingWallet` : new non-zero wallet address
     * - `msg.sender` should be contract owner
     **/

    function updateFundRaisingWallet(address payable _newFundRaisingWallet)
        external
        onlyOwner
        returns (bool)
    {
        require(
            _newFundRaisingWallet != address(0),
            "Fund raising wallet is zero address"
        );
        fundRaisingWallet = _newFundRaisingWallet;
        return true;
    }

    /**
     * function to update Treasury Wallet
     * - `_newTreasuryWallet` : new non-zero wallet address
     * - `msg.sender` should be contract owner
     **/

    function updateTreasuryWallet(address payable _newTreasuryWallet)
        external
        onlyOwner
        returns (bool)
    {
        require(
            _newTreasuryWallet != address(0),
            "Treasury wallet is zero address"
        );
        require(
            _newTreasuryWallet != owner(),
            "Treasury wallet should not be a owner address"
        );
        treasuryWallet = _newTreasuryWallet;
        return true;
    }

    /**
     * function to withdraw CHP tokens and BNB from the contract
     * - `msg.sender` should be contract owner
     **/

    function withdrawFunds() external onlyOwner returns (bool) {
        // Send unsold tokens to the owner.
        IBEP20(CHPToken).safeTransfer(
            address(treasuryWallet),
            IBEP20(CHPToken).balanceOf(address(this))
        );
        treasuryWallet.transfer(address(this).balance);
        return true;
    }

    /**
     * It allows the admin to recover wrong tokens sent to the contract
     * -`_tokenAddress`: the address of the token to withdraw
     * - This function is only callable by admin.
     */

    function recoverWrongTokens(address _tokenAddress) external onlyOwner {
        require(
            _tokenAddress != address(0),
            "Token address must not be zero address"
        );
        uint256 _tokenAmount = IBEP20(_tokenAddress).balanceOf(address(this));
        IBEP20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /**
     * Function using which we can get current price of BNB
     */
    function getLatestBNBPrice() public view returns (uint256) {
        (
            uint256 roundID,
            uint256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint256 answeredInRound
        ) = priceFeedBNB.latestRoundData();
        return price;
    }

    /**
     * function to get user's presale purchase data
     * - `_user` : public address of user
     **/

    function getUserDetails(address _user)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        UserDetail storage user = users[_user];
        return (
            user.TotalTokensPurchased,
            user.TotalClaimed,
            user.TotalPurchases
        );
    }

    /**
     * function to get user's transaction details
     * - `_user` : public address of user
     * - `_transactionIndex` : Index of the transaction record
     **/

    function getUserTransactionDetails(address _user, uint256 _transactionIndex)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        UserDetail storage user = users[_user];
        return (
            user.purchases[_transactionIndex].PurchasedDate,
            user.purchases[_transactionIndex].NumberOfTokens,
            user.purchases[_transactionIndex].subTransactionCount
        );
    }

    /**
     * function to get user's transaction details
     * - `_user` : public address of user
     * - `_transactionIndex` : Index of the transaction record
     * - `_subTransactionIndex` : Index of the sub-transaction
     **/

    function getUserSubTransactionDetails(
        address _user,
        uint256 _transactionIndex,
        uint256 _subTransactionIndex
    )
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        UserDetail storage user = users[_user];
        return (
            user
                .purchases[_transactionIndex]
                .subTransactions[_subTransactionIndex]
                .TokenUnlockedDate,
            user
                .purchases[_transactionIndex]
                .subTransactions[_subTransactionIndex]
                .TokensUnlockedPercentage,
            user
                .purchases[_transactionIndex]
                .subTransactions[_subTransactionIndex]
                .NumberOfTokens,
            user
                .purchases[_transactionIndex]
                .subTransactions[_subTransactionIndex]
                .ClaimedTokens
        );
    }

    /**
     * function to get total available tokens for withdrawal
     * - `_user` : public address of user
     **/

    function AvailableTokensForWithdrawl(address _user)
        public
        view
        returns (uint256)
    {
        UserDetail storage user = users[_user];
        uint256 availableTokens;

        for (uint8 i = 0; i < user.TotalPurchases; i++) {
            for (uint8 j = 0; j < user.purchases[i].subTransactionCount; j++) {
                if (
                    user.purchases[i].subTransactions[j].TokenUnlockedDate <
                    block.timestamp
                ) {
                    availableTokens += user
                        .purchases[i]
                        .subTransactions[j]
                        .NumberOfTokens
                        .sub(
                            user.purchases[i].subTransactions[j].ClaimedTokens
                        );
                }
            }
        }
        return availableTokens;
    }

    /**
     * function to withdraw unlocked/available tokens from the smart contract
     * - `_amount` : Number of unlocked tokens wants to withdraw from smart contract
     **/

    function withdrawTokens(uint256 _amount)
        public
        nonReentrant
        returns (bool)
    {
        uint256 availableTokensToClaim = AvailableTokensForWithdrawl(
            msg.sender
        );
        require(_amount <= availableTokensToClaim, "Wrong withdrawal amount");
        require(
            IBEP20(CHPToken).balanceOf(address(this)) > _amount,
            "Not Enough Pre-Sale Token"
        );

        if (updateWithdrawalRecord(address(msg.sender), _amount)) {
            IBEP20(CHPToken).safeTransfer(address(_msgSender()), _amount);
        }
        emit TokenWithdrawal(_msgSender(), _amount);
        return true;
    }

    /**
     * function to get user's referral reward data
     * - `_user` : public address of user
     **/

    function getUserReferralDetails(address _user)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        UserReferralDetails storage user = referralUsers[_user];
        return (
            user.TotalReferralRewards,
            user.TotalReferralRewardsClaimed,
            user.TotalReferrals
        );
    }

    /**
     * function to get user's referral transaction details
     * - `_user` : public address of user
     * - `_transactionIndex` : Index of the transaction record
     **/

    function getReferralTransactionInfo(
        address _user,
        uint256 _transactionIndex
    )
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        UserReferralDetails storage user = referralUsers[_user];
        return (
            user.referralTransactions[_transactionIndex].RewardDate,
            user.referralTransactions[_transactionIndex].RewardUnlockedDate,
            user.referralTransactions[_transactionIndex].NumberOfRewardTokens,
            user.referralTransactions[_transactionIndex].ClaimedRewardTokens
        );
    }

    /**
     * function to get total available referral reward tokens for withdrawal
     * - `_user` : public address of user
     **/

    function availableReferralTokensForWithdrawl(address _user)
        public
        view
        returns (uint256)
    {
        UserReferralDetails storage user = referralUsers[_user];
        uint256 availableReferralTokens;

        for (uint256 i = 0; i < user.TotalReferrals; i++) {
            if (
                user.referralTransactions[i].RewardUnlockedDate <
                block.timestamp
            ) {
                availableReferralTokens += user
                    .referralTransactions[i]
                    .NumberOfRewardTokens
                    .sub(user.referralTransactions[i].ClaimedRewardTokens);
            }
        }
        return availableReferralTokens;
    }

    /**
     * function to withdraw unlocked/available referral reward tokens from the smart contract
     * - `_amount` : Number of unlocked tokens wants to withdraw from smart contract
     **/

    function withdrawReferraltokens(uint256 _amount)
        public
        nonReentrant
        returns (bool)
    {
        uint256 AvailableReferralTokensToClaim = availableReferralTokensForWithdrawl(
                msg.sender
            );
        require(
            _amount <= AvailableReferralTokensToClaim,
            "Wrong withdrawal amount"
        );
        require(
            IBEP20(CHPToken).balanceOf(address(this)) > _amount,
            "Not Enough Pre-Sale Token"
        );

        if (updateReferralWithdrawlRecord(address(msg.sender), _amount)) {
            IBEP20(CHPToken).safeTransfer(address(_msgSender()), _amount);
        }
        emit TokenWithdrawal(_msgSender(), _amount);
        return true;
    }

    /**
     * function to store user's presale purchase details
     * - `_totalTokens` : Bought tokens
     **/

    function storeUserDetails(uint256 _totalTokens) internal returns (bool) {
        UserDetail storage user = users[msg.sender];

        // user details
        user.TotalTokensPurchased = user.TotalTokensPurchased.add(_totalTokens);
        user.TotalClaimed += _totalTokens
            .mul(instantTokenUnlockedPercentage)
            .div(100);

        // purchase details
        user.purchases[user.TotalPurchases].PurchasedDate = block.timestamp;
        user.purchases[user.TotalPurchases].NumberOfTokens = _totalTokens;
        user
            .purchases[user.TotalPurchases]
            .subTransactionCount = subTransactionCount;

        for (uint256 i = 0; i < subTransactionCount; i++) {
            if (i == 0) {
                user.purchases[user.TotalPurchases].subTransactions[
                        i
                    ] = SubTransaction(
                    block.timestamp,
                    instantTokenUnlockedPercentage,
                    _totalTokens.mul(instantTokenUnlockedPercentage).div(100),
                    _totalTokens.mul(instantTokenUnlockedPercentage).div(100)
                );
            } else {
                user.purchases[user.TotalPurchases].subTransactions[
                        i
                    ] = SubTransaction(
                    block.timestamp.add(
                        day.mul(i).mul(lockingDaysForPresalePurchase)
                    ),
                    tokenUnlockedPercentage,
                    _totalTokens.mul(tokenUnlockedPercentage).div(100),
                    0
                );
            }
        }
        user.TotalPurchases += 1;
        return true;
    }

    /**
     * function to store user's referral rewards
     * - `_referralUser` : public address
     * - `_totalTokens` : Reward tokens
     **/

    function storeReferralUserDetails(
        address _referralUser,
        uint256 _totalTokens
    ) internal returns (bool) {
        // referral program is on
        if (referralProgramStatus && address(_referralUser) != address(this)) {
            UserDetail storage user = users[_referralUser];
            if (user.TotalTokensPurchased >= minimumPurchaseForReferralReward) {
                UserReferralDetails storage referralUser = referralUsers[
                    _referralUser
                ];
                // condition for referral reward limit
                if (
                    referralUser.TotalReferralRewards <= referralTokensLimit &&
                    referralUser.TotalReferralRewards.add(_totalTokens) <=
                    referralTokensLimit
                ) {
                    referralUser.TotalReferralRewards = referralUser
                        .TotalReferralRewards
                        .add(_totalTokens);

                    referralUser.referralTransactions[
                            referralUser.TotalReferrals
                        ] = ReferralTransactionDetails(
                        block.timestamp,
                        block.timestamp.add(
                            day.mul(lockingDaysForReferralReward)
                        ),
                        _totalTokens,
                        0
                    );
                    referralUser.TotalReferrals += 1;
                } else if (
                    referralUser.TotalReferralRewards <= referralTokensLimit &&
                    referralUser.TotalReferralRewards.add(_totalTokens) >
                    referralTokensLimit
                ) {
                    // if limit exceed by adding new rewards
                    uint256 rewardDifference = referralTokensLimit.sub(
                        referralUser.TotalReferralRewards
                    );

                    referralUser.TotalReferralRewards = referralUser
                        .TotalReferralRewards
                        .add(rewardDifference);

                    referralUser.referralTransactions[
                            referralUser.TotalReferrals
                        ] = ReferralTransactionDetails(
                        block.timestamp,
                        block.timestamp.add(
                            day.mul(lockingDaysForReferralReward)
                        ),
                        rewardDifference,
                        0
                    );
                    referralUser.TotalReferrals += 1;
                }
            }
        }
        return true;
    }

    /**
     * function to update user's record after successful withdrawal
     * - `_user` : public address
     * - `_amount` : amount of tokens purchased from presale
     **/

    function updateWithdrawalRecord(address _user, uint256 _amount)
        internal
        returns (bool)
    {
        uint256 claimedAmount = _amount;
        UserDetail storage user = users[_user];
        for (uint256 i = 0; i < user.TotalPurchases; i++) {
            for (
                uint256 j = 0;
                j < user.purchases[i].subTransactionCount;
                j++
            ) {
                uint256 remainingTokens = user
                    .purchases[i]
                    .subTransactions[j]
                    .NumberOfTokens
                    .sub(user.purchases[i].subTransactions[j].ClaimedTokens);

                if (
                    remainingTokens > 0 &&
                    _amount > 0 &&
                    user.purchases[i].subTransactions[j].TokenUnlockedDate <
                    block.timestamp
                ) {
                    if (remainingTokens > _amount) {
                        user
                            .purchases[i]
                            .subTransactions[j]
                            .ClaimedTokens = user
                            .purchases[i]
                            .subTransactions[j]
                            .ClaimedTokens
                            .add(_amount);
                        _amount = 0;
                        break;
                    } else if (remainingTokens <= _amount) {
                        user
                            .purchases[i]
                            .subTransactions[j]
                            .ClaimedTokens = user
                            .purchases[i]
                            .subTransactions[j]
                            .ClaimedTokens
                            .add(remainingTokens);
                        _amount -= remainingTokens;
                    }
                }
            }
        }
        user.TotalClaimed = user.TotalClaimed.add(claimedAmount);
        return true;
    }

    /**
     * function to update user's record after successful withdrawal of referral rewards
     * - `_user` : public address
     * - `_amount` : amount of rewards get from presale
     **/

    function updateReferralWithdrawlRecord(address _user, uint256 _amount)
        internal
        returns (bool)
    {
        uint256 claimedAmount = _amount;
        UserReferralDetails storage user = referralUsers[_user];
        for (uint256 i = 0; i < user.TotalReferrals; i++) {
            uint256 remainingReferralTokens = user
                .referralTransactions[i]
                .NumberOfRewardTokens
                .sub(user.referralTransactions[i].ClaimedRewardTokens);

            if (
                remainingReferralTokens > 0 &&
                _amount > 0 &&
                user.referralTransactions[i].RewardUnlockedDate <
                block.timestamp
            ) {
                if (remainingReferralTokens > _amount) {
                    user.referralTransactions[i].ClaimedRewardTokens = user
                        .referralTransactions[i]
                        .ClaimedRewardTokens
                        .add(_amount);
                    _amount = 0;
                    break;
                } else if (remainingReferralTokens <= _amount) {
                    user.referralTransactions[i].ClaimedRewardTokens = user
                        .referralTransactions[i]
                        .ClaimedRewardTokens
                        .add(remainingReferralTokens);
                    _amount -= remainingReferralTokens;
                }
            }
        }
        user.TotalReferralRewardsClaimed = user.TotalReferralRewardsClaimed.add(
            claimedAmount
        );
        return true;
    }
}