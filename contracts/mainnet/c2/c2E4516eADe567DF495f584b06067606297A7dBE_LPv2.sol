/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

interface IToken is IERC20 {
    function totalSupply() external override view returns (uint256);

    function balanceOf(address _owner) external override view returns (uint256);

    function transfer(address _to, uint256 _amount) override external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external override returns (bool);

    function mint(address _to, uint256 _amount) external;

    function burn(uint256 _amount) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface ITokenMinter {
    function tokenLimit() external pure returns (uint256);
}

abstract contract TokenMinter is ERC165, Ownable {
    uint256 constant NO_LIMIT = 0;

    function supportsInterface(bytes4 interfaceId)
        public
        pure
        override
        returns (bool)
    {
        return interfaceId == type(ITokenMinter).interfaceId;
    }

    function tokenLimit() external pure virtual returns (uint256) {
        return NO_LIMIT;
    }
}

contract LPv2 is TokenMinter {
    constructor(
        IToken _token,
        IERC20 _lp,
        address _recycler,
        address _operator,
        uint256 _perSecLimit
    ) {
        require(_token != _lp);

        token = _token;
        lp = _lp;
        lastUpdateTime = getTime();
        changeOperator(_operator);
        setFeeAddress(_recycler);
        setPerSecLimit(_perSecLimit);
    }

    modifier onlyOperator() {
        require(operator == _msgSender(), "caller is not the operator");
        _;
    }

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IToken token;
    IERC20 lp;
    address public recycler;
    address public operator;

    uint256 public accPerShare = 0;
    uint256 public totalShares = 0;
    uint256 public totalAmount = 0;
    uint256 public lastUpdateTime = 0;
    uint256 public stakingStartTime = 0;

    uint256 public withdrawFee = 100; // 100/10000  1%
    uint256 public withdrawFeePeriod = 7 days;

    uint256 public stakingPerSec = 0;
    uint256 public perSecLimit;
    bool public emergencyWithdrawSwitch = false;

    uint256 decimals = 18;
    uint256 constant ONE = 10**18;
    mapping(address => UserInfo) public userInfo;

    event Deposit(
        address indexed sender,
        uint256 amount,
        uint256 shares,
        uint256 lastDepositedTime
    );
    event Withdraw(address indexed sender, uint256 amount, uint256 shares);
    event WithdrawTokenFeeUpdated(uint256 amount);
    event FeeAddressUpdated(address indexed newAddress);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event StakingPerSecChanged(uint256 oldValue, uint256 newValue);
    event WithdrawToken(address indexed sender, uint256 amount);

    struct UserInfo {
        uint256 shares;
        uint256 lastDepositedTime;
        uint256 lastUserActionTime;
        uint256 coinAtlastUserAction;
        uint256 rewardDebt;
        uint256 rewards;
        uint256 amount;
    }

    function divFloor(uint256 target, uint256 d)
        internal
        pure
        returns (uint256)
    {
        return target.mul(ONE).div(d);
    }

    function decimalMul(uint256 target, uint256 d)
        internal
        pure
        returns (uint256)
    {
        return target.mul(d) / ONE;
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Nothing to deposit");

        updatePool();
        uint256 bal = lpBalance();

        UserInfo storage user = userInfo[_msgSender()];

        if (user.amount > 0) {
            uint256 pending = decimalMul(user.amount, accPerShare).sub(
                user.rewardDebt
            );
            user.rewards = user.rewards.add(pending);
        } else user.rewards = 0;

        lp.safeTransferFrom(_msgSender(), address(this), _amount);

        uint256 currentShares = 0;
        if (totalShares != 0)
            currentShares = (_amount.mul(totalShares)).div(bal);
        else currentShares = _amount.mul(getEther());

        user.shares = user.shares.add(currentShares);
        totalShares = totalShares.add(currentShares);
        user.coinAtlastUserAction = user.rewards;

        user.amount = user.amount.add(_amount);
        user.rewardDebt = decimalMul(user.amount, accPerShare);

        user.lastUserActionTime = getTime();
        user.lastDepositedTime = getTime();

        emit Deposit(_msgSender(), _amount, currentShares, block.timestamp);
    }

    function emergencyWithdraw() public {
        require(emergencyWithdrawSwitch);

        UserInfo storage user = userInfo[_msgSender()];

        require(user.shares > 0, "no shares");

        updatePool();

        uint256 userTotalAmount = decimalMul(user.amount, accPerShare)
            .sub(user.rewardDebt)
            .add(user.rewards);

        IERC20(token).safeTransfer(owner(), userTotalAmount);

        totalShares = totalShares.sub(user.shares);
        user.lastUserActionTime = getTime();
        user.rewardDebt = 0;
        user.rewards = 0;
        user.shares = 0;
        user.coinAtlastUserAction = 0;

        lp.safeTransfer(_msgSender(), user.amount);
        emit EmergencyWithdraw(_msgSender(), user.amount);

        user.amount = 0;
    }

    function withdraw(uint256 _shares) public {
        UserInfo storage user = userInfo[_msgSender()];
        require(_shares > 0, "Nothing to withdraw");
        require(_shares <= user.shares, "Withdraw amount exceeds balance");

        updatePool();

        uint256 userTotalAmount = decimalMul(user.amount, accPerShare)
            .sub(user.rewardDebt)
            .add(user.rewards);
        uint256 withdrawAmount = userTotalAmount;

        uint256 curLp = user.amount.mul(_shares).div(user.shares);
        user.shares = user.shares.sub(_shares);
        totalShares = totalShares.sub(_shares);

        require(
            totalAmount >= withdrawAmount,
            "Withdraw amount exceeds balance"
        );

        totalAmount = totalAmount.sub(withdrawAmount);

        user.rewards = userTotalAmount.sub(withdrawAmount);

        user.amount = user.amount.sub(curLp);

        if (getTime() < user.lastDepositedTime.add(withdrawFeePeriod)) {
            uint256 fee = curLp.mul(100).div(10000);
            curLp = curLp.sub(fee);

            uint256 tokenFee = withdrawAmount.mul(withdrawFee).div(10000);
            withdrawAmount = withdrawAmount.sub(tokenFee);

            lp.safeTransfer(recycler, fee);
            IERC20(token).safeTransfer(recycler, tokenFee);
        }

        lp.safeTransfer(_msgSender(), curLp);
        IERC20(token).safeTransfer(_msgSender(), withdrawAmount);

        if (user.shares > 0) {
            user.rewardDebt = decimalMul(user.amount, accPerShare);
            user.coinAtlastUserAction = user.rewards;
        } else {
            user.rewardDebt = 0;
            user.coinAtlastUserAction = 0;
        }
        user.lastUserActionTime = getTime();

        emit Withdraw(_msgSender(), withdrawAmount, _shares);
    }

    function withdrawToken() public {
        UserInfo storage user = userInfo[_msgSender()];

        updatePool();

        uint256 userTotalAmount = decimalMul(user.amount, accPerShare)
            .sub(user.rewardDebt)
            .add(user.rewards);
        uint256 withdrawAmount = userTotalAmount;

        if (getTime() < user.lastDepositedTime.add(withdrawFeePeriod)) {
            uint256 tokenFee = withdrawAmount.mul(withdrawFee).div(10000);
            withdrawAmount = withdrawAmount.sub(tokenFee);

            IERC20(token).safeTransfer(recycler, tokenFee);
        }

        IERC20(token).safeTransfer(_msgSender(), withdrawAmount);

        user.lastUserActionTime = getTime();
        user.rewardDebt = decimalMul(user.amount, accPerShare);
        user.rewards = 0;
        user.coinAtlastUserAction = 0;
        

        emit WithdrawToken(_msgSender(), withdrawAmount);
    }

    function lpBalance() public view returns (uint256) {
        return lp.balanceOf(address(this));
    }

    function updatePool() public {
        uint256 curTime = getTime();
        if (curTime <= lastUpdateTime) {
            return;
        }
        uint256 lpb = lpBalance();
        if (lpb <= 0) {
            lastUpdateTime = curTime;
            return;
        }

        uint256 multiplier = getTime() - lastUpdateTime;
        uint256 reward = multiplier.mul(getStakingCoinPerSec());
        lastUpdateTime = curTime;
        totalAmount = totalAmount.add(reward);
        accPerShare = accPerShare.add(divFloor(reward, lpb));
        token.mint(address(this), reward);
    }

    function pendingCoin() public view returns (uint256) {
        uint256 curTime = getTime();
        if (lpBalance() <= 0) {
            return 0;
        }
        uint256 multiplier = curTime - lastUpdateTime;
        uint256 reward = multiplier.mul(getStakingCoinPerSec());
        return reward;
    }

    function totalStakingAmount() public view returns (uint256) {
        return this.pendingCoin().add(totalAmount);
    }

    function myBenefits() public view returns (uint256) {
        if (totalShares == 0) return 0;
        UserInfo storage user = userInfo[_msgSender()];
        uint256 computePer = accPerShare.add(
            divFloor(this.pendingCoin(), lpBalance())
        );
        uint256 ben = decimalMul(user.amount, computePer);

        if (ben > user.rewardDebt) return ben.sub(user.rewardDebt);
        else return 0;
    }

    function myValue() public view returns (uint256) {
        uint256 computePer = accPerShare.add(
            divFloor(this.pendingCoin(), lpBalance())
        );
        UserInfo storage user = userInfo[_msgSender()];
        if (user.shares == 0) return 0;
        return
            decimalMul(user.amount, computePer).sub(user.rewardDebt).add(
                user.rewards
            );
    }

    function sharesPrice() public view returns (uint256) {
        uint256 lpb = lpBalance();
        if (lpb == 0) return 0;
        uint256 computePer = accPerShare.add(divFloor(this.pendingCoin(), lpb));
        return lpb.mul(getEther()).mul(computePer).div(totalShares);
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function getPkBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getEther() public view returns (uint256) {
        return 10**uint256(decimals);
    }

    function getStakingCoinPerSec() public view returns (uint256) {
        return stakingPerSec;
    }

    function setFeeAddress(address newAddress) public onlyOwner {
        require(newAddress != address(0), "set to 0");
        require(newAddress != address(0xdead), "set to 0xdead");
        require(newAddress != address(this), "set to this");

        recycler = newAddress;
        emit FeeAddressUpdated(newAddress);
    }

    function setWithdrawFee(uint256 newTokenWithdrawFee) public onlyOwner {
        require(newTokenWithdrawFee >= 0 && newTokenWithdrawFee <= 2000);

        withdrawFee = newTokenWithdrawFee;
        emit WithdrawTokenFeeUpdated(newTokenWithdrawFee);
    }

    function setStakingPerSec(uint256 _value) public onlyOperator {
        if (_value > perSecLimit) _value = perSecLimit;
        updatePool();
        stakingStartTime = getTime();
        emit StakingPerSecChanged(stakingPerSec, _value);
        stakingPerSec = _value;
    }

    function switchemergencyWithdraw() public onlyOwner {
        emergencyWithdrawSwitch = !emergencyWithdrawSwitch;
    }

    function changeOperator(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        operator = newOperator;
    }

    function setPerSecLimit(uint256 newLimit) public onlyOwner {
        require(newLimit <= 1000000 * 10**18); //1 million
        perSecLimit = newLimit;
    }
}