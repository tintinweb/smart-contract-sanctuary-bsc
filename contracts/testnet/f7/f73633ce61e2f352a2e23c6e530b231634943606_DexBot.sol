/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-17
 */

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

library SafeMathUpgradeable {
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

library AddressUpgradeable {
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

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
        // solhint-disable-next-line max-line-length
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
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
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

contract DexBot is Initializable {
    using SafeERC20 for IERC20;

    struct User {
        uint256 userid;
        address parent;
        uint256 referalCount;
        uint256 plan;
        uint256 totalRewardsQbt;
        uint256 totalRewardsBusd;
        bool stakeRefereReward;
    }

    struct Stake {
        uint256 amount;
        uint256 date;
        uint256 rewards;
    }

    struct Mine {
        uint256 amount;
        uint256 date;
        uint256 rewards;
    }

    address public BusdAddresss;
    address public QbtAddresss;
    uint256 public MiningPercentage;
    uint256 public DirectRefferalPercentage;
    uint256 public TokenPricePerBusd;
    uint256 public lastUserId;
    address public contractOwner;

    mapping(uint256 => uint256) public price;
    mapping(uint256 => uint256) public Reward;
    mapping(uint256 => uint256) public referalEarnings;
    mapping(uint256 => uint256) public lockingPeriod;
    mapping(address => User) public users;
    mapping(address => mapping(uint256 => Stake)) public usersStake;
    mapping(address => Mine) public usersMine;
    mapping(address => address[]) public referals;

    function initialize(
        address _busdAddresss,
        address _qbtAddress,
        uint256 _miningPercentage,
        uint256 _directRefferalPercentage,
        uint256 _kingsPrice,
        uint256 _queensPrice,
        uint256 _3monthStakeRewards,
        uint256 _6monthStakeRewards,
        uint256 _12monthStakeRewards,
        uint256 _tokenPricePerBusd,
        address ownerAddress
    ) public initializer {
        BusdAddresss = _busdAddresss;
        QbtAddresss = _qbtAddress;
        MiningPercentage = _miningPercentage * 1e18;
        DirectRefferalPercentage = _directRefferalPercentage * 1e18;
        TokenPricePerBusd = _tokenPricePerBusd * 1e18;

        User storage user = users[msg.sender];
        user.userid = 1;
        user.plan = _queensPrice * 1e18;

        contractOwner = ownerAddress;

        lockingPeriod[3] = _3monthStakeRewards * 1e18;
        lockingPeriod[6] = _6monthStakeRewards * 1e18;
        lockingPeriod[12] = _12monthStakeRewards * 1e18;

        price[1] = _kingsPrice * 1e18;
        price[2] = _queensPrice * 1e18;

        referalEarnings[1] = 20e18;
        referalEarnings[2] = 10e18;
        referalEarnings[3] = 10e18;
        referalEarnings[4] = 10e18;
        referalEarnings[5] = 5e18;
        referalEarnings[6] = 5e18;
        referalEarnings[7] = 5e18;
        referalEarnings[8] = 5e18;
        referalEarnings[9] = 5e18;

        Reward[1] = 1e18;
        Reward[2] = 1e18;
        Reward[3] = 1e18;
        Reward[4] = 1e18;
        Reward[5] = 1e18;
        Reward[6] = 1e18;
        Reward[7] = 1e18;
        Reward[8] = 1e18;
        Reward[9] = 1e18;
        Reward[10] = 3e18;
        Reward[11] = 3e18;
        Reward[12] = 3e18;
        Reward[13] = 3e18;
        Reward[14] = 3e18;
        Reward[15] = 3e18;
        Reward[16] = 3e18;
        Reward[17] = 3e18;
        Reward[18] = 3e18;

        lastUserId = 2;
    }

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "onlyOwner");
        _;
    }

    function updateMintingPercentage(uint256 _miningPercentage)
        public
        onlyContractOwner
    {
        MiningPercentage = _miningPercentage;
    }

    function updateDirectReferalPercentage(uint256 _directRefferalPercentage)
        public
        onlyContractOwner
    {
        DirectRefferalPercentage = _directRefferalPercentage;
    }

    function updateTokenPricePerBusd(uint256 _tokenPricePerBusd)
        public
        onlyContractOwner
    {
        TokenPricePerBusd = _tokenPricePerBusd;
    }

    function updateLockingRewards(
        uint256 _lockingPeriod,
        uint256 _percentageReward
    ) public onlyContractOwner {
        lockingPeriod[_lockingPeriod] = _percentageReward;
    }

    function updateReferalEarnings(uint256 _level, uint256 _percentageReward)
        public
        onlyContractOwner
    {
        referalEarnings[_level] = _percentageReward;
    }

    function updateReward(uint256 _plan, uint256 _percentageReward) public {
        Reward[_plan] = _percentageReward;
    }

    function buyPlan(address referrerAddress, uint256 plan) public {
        require(!isUserExists(msg.sender), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        IERC20(BusdAddresss).transferFrom(
            msg.sender,
            address(this),
            price[plan]
        );

        User storage user = users[msg.sender];
        user.userid = lastUserId;
        user.parent = referrerAddress;
        user.referalCount = 0;
        user.plan = price[plan];
        user.totalRewardsQbt = 0;
        user.stakeRefereReward = false;

        User storage referer = users[referrerAddress];
        referer.referalCount = referer.referalCount + 1;

        uint256 totalrewardPercentage = DirectRefferalPercentage +
            referalEarnings[1];
        referer.totalRewardsQbt =
            referer.totalRewardsQbt +
            ((((totalrewardPercentage * price[plan]) / 1e20) *
                TokenPricePerBusd) / 1e18);

        getReferalPercent(referer.parent, 2, price[plan]);

        referals[referrerAddress].push(msg.sender);
        lastUserId++;
    }

    function getReferalPercent(
        address _parent,
        uint256 cnt,
        uint256 plan
    ) internal {
        if (cnt < 10 && _parent != 0x0000000000000000000000000000000000000000) {
            User storage referer = users[_parent];
            referer.totalRewardsQbt =
                referer.totalRewardsQbt +
                ((((referalEarnings[cnt] * plan) / 1e20) * TokenPricePerBusd) /
                    1e18);
            cnt++;
            getReferalPercent(referer.parent, cnt, plan);
        }
    }

    function stake(uint256 amount, uint256 plan) public {
        IERC20(QbtAddresss).transferFrom(msg.sender, address(this), amount);
        Stake storage userstake = usersStake[msg.sender][plan];
        User storage user = users[msg.sender];
        if (user.stakeRefereReward == false) {
            getReferalAmount(user.parent, user.plan, 1);
            user.stakeRefereReward = true;
        }
        if (userstake.amount > 0) {
            userstake.rewards =
                userstake.rewards +
                ((userstake.amount *
                    ((lockingPeriod[plan] * 1e8) / (2592000 * plan))) / 1e28) *
                (block.timestamp - userstake.date);
        }
        userstake.amount = userstake.amount + amount;
        userstake.date = block.timestamp;
    }

    function getReferalAmount(
        address _parent,
        uint256 _plan,
        uint256 cnt
    ) internal {
        if (
            _plan == price[1] &&
            cnt < 10 &&
            _parent != 0x0000000000000000000000000000000000000000
        ) {
            User storage referer = users[_parent];
            referer.totalRewardsBusd = referer.totalRewardsBusd + Reward[cnt];
            cnt++;
            getReferalAmount(referer.parent, _plan, cnt);
        } else if (
            _plan == price[2] &&
            cnt < 10 &&
            _parent != 0x0000000000000000000000000000000000000000
        ) {
            User storage referer = users[_parent];
            referer.totalRewardsBusd = referer.totalRewardsBusd + Reward[cnt];
            cnt++;
            getReferalAmount(referer.parent, _plan, cnt);
        }
    }

    function mine(uint256 amount) public {
        Mine storage usermine = usersMine[msg.sender];
        uint256 userPerviousState = usermine.date + 1 days;
        require(block.timestamp > userPerviousState, "Mine after 24 hrs");
        if (usermine.amount > 0) {
            usermine.rewards =
                usermine.rewards +
                (((usermine.amount * ((MiningPercentage * 1e8) / 31536000)) /
                    1e28) * (block.timestamp - usermine.date));
        }
        usermine.amount = usermine.amount + amount;
        usermine.date = block.timestamp;
    }

    function withdrawMineRewards(uint256 plan) public {
        Mine storage usermine = usersMine[msg.sender];
        require(usermine.amount > 0, "amount must be greate than zero");
        uint256 userPerviousState = usermine.date + 1 days;
        if (block.timestamp > userPerviousState) {
            usermine.rewards =
                usermine.rewards +
                (((usermine.amount * ((MiningPercentage * 1e8) / 31536000)) /
                    1e28) * (block.timestamp - usermine.date));
        }

        Stake storage userstake = usersStake[msg.sender][plan];
        require(userstake.amount > 0, "amount must be greate than zero");
        uint256 remainingdays = userstake.date + plan * 30 days;
        require(block.timestamp > remainingdays, "Plan is not completed");
        if (userstake.amount > 0) {
            userstake.rewards =
                userstake.rewards +
                ((userstake.amount *
                    ((lockingPeriod[plan] * 1e8) / (2592000 * plan))) / 1e28) *
                (remainingdays - userstake.date);
        }

        User storage user = users[msg.sender];

        uint256 amount = usermine.amount +
            usermine.rewards +
            userstake.amount +
            userstake.rewards +
            user.totalRewardsQbt;

        IERC20(QbtAddresss).transfer(msg.sender, amount);

        if (user.totalRewardsBusd > 0) {
            IERC20(BusdAddresss).transfer(msg.sender, user.totalRewardsBusd);
        }
    }

    function withdrawLostTokens() public onlyContractOwner {
        IERC20(BusdAddresss).transfer(
            contractOwner,
            IERC20(BusdAddresss).balanceOf(address(this))
        );
        IERC20(QbtAddresss).transfer(
            contractOwner,
            IERC20(QbtAddresss).balanceOf(address(this))
        );
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].userid != 0);
    }
}