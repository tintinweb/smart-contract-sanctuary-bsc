/**
 *Submitted for verification at BscScan.com on 2022-12-10
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

pragma solidity >=0.6.0;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract DexBot is Initializable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 userid;
        address parent;
        uint256 amount;
        uint256 plan;
        uint256 totalRefrerRewards;
        uint256 stakeReward;
        uint256 mineReward;
        uint256 lastStaked;
        uint256 gainReward;
        uint256 gainBusd;
        bool isUser;
    }

    struct StakePoolInfo {
        uint256 rewardPercent; // 1 means 1000
        uint256 duration; // if mine means put 0
        uint256 minStakeAmount;
        bool isActve;
        bool isMine;
    }

    address public BusdAddresss;
    address public QbtAddresss;
    uint256 public DirectRefferalPercentage;
    uint256 public currUserId;
    address public contractOwner;
    StakePoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(address => UserInfo) public userData;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(uint256 => uint256) public price;
    mapping(uint256 => uint256) public queenReward;
    mapping(uint256 => uint256) public kingReward;
    mapping(uint256 => uint256) public referalEarnings;
    mapping(address => address[]) public referals;
    uint256 public tokenbusdprice;
    address public receivar;
    uint256 public withdrawMinLimit;
    uint256 public withdrawMinLimitStaking;
    AggregatorV3Interface public priceProvider;

    uint256 test1;
    uint256 test2;
    uint256 test3;
    uint256 test4;
    uint256 test5;
    uint256 test6;

    event purchasePlan(
        address indexed referrerAddress,
        address indexed user,
        uint256 plan,
        uint256 referalIncome
    );

    event deposit(
        bool isBNB,
        address indexed user,
        uint256 amount,
        uint256 reward
    );

    event withdraw(address indexed user, uint256 amount, uint256 withdrawtype);

    function initialize(
        address _busdAddresss,
        address _qbtAddress,
        uint256 _directRefferalPercentage,
        uint256 _kingsPrice,
        uint256 _queensPrice,
        address ownerAddress,
        uint256 _tokenbusdprice,
        address _receivar,
        AggregatorV3Interface pp
    ) public initializer {
        BusdAddresss = _busdAddresss;
        QbtAddresss = _qbtAddress;
        DirectRefferalPercentage = _directRefferalPercentage;
        UserInfo storage user = userData[msg.sender];
        user.userid = 1;
        user.plan = 2;
        user.isUser = true;
        contractOwner = ownerAddress;
        price[1] = _kingsPrice * 1e18; // King
        price[2] = _queensPrice * 1e18; // Queen
        tokenbusdprice = _tokenbusdprice;
        priceProvider = pp;
        receivar = _receivar;
        referalEarnings[0] = 80;
        referalEarnings[1] = 4;
        referalEarnings[2] = 2;
        referalEarnings[3] = 2;
        referalEarnings[4] = 2;
        referalEarnings[5] = 1;
        referalEarnings[6] = 1;
        referalEarnings[7] = 1;
        referalEarnings[8] = 1;
        referalEarnings[9] = 1;
        referalEarnings[10] = 5;

        queenReward[1] = 1e18;
        queenReward[2] = 1e18;
        queenReward[3] = 1e18;
        queenReward[4] = 1e18;
        queenReward[5] = 1e18;
        queenReward[6] = 1e18;
        queenReward[7] = 1e18;
        queenReward[8] = 1e18;
        queenReward[9] = 1e18;
        kingReward[10] = 3e18;
        kingReward[11] = 3e18;
        kingReward[13] = 3e18;
        kingReward[14] = 3e18;
        kingReward[15] = 3e18;
        kingReward[16] = 3e18;
        kingReward[17] = 3e18;
        kingReward[18] = 3e18;
        withdrawMinLimit = 24 * 3600; // Hours convert into seconds (24 hours)
        withdrawMinLimitStaking = 24 * 3600; // Hours convert into seconds (24 hours)
    }

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "onlyOwner");
        _;
    }

    function depositBUSD(uint256 _amount) public {
        require(_amount > 0, "need amount > 0");
        IERC20(BusdAddresss).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        IERC20(BusdAddresss).transfer(receivar, _amount);
        uint256 perToken = tokenbusdprice * _amount;
        uint256 swapToken = perToken / (1000000);
        IERC20(QbtAddresss).transfer(msg.sender, swapToken);

        emit deposit(false, msg.sender, _amount, swapToken);
    }

    function depositBNB() public payable {
        require(msg.value > 0, "need amount > 0");
        payable(receivar).transfer(msg.value);
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 currentPrice = uint256(latestPrice);
        uint256 perBnb = currentPrice / 100000000;
        uint256 _amount = perBnb * msg.value;
        uint256 perToken = tokenbusdprice * _amount;
        uint256 swapToken = perToken / 1000000;
        IERC20(QbtAddresss).transfer(msg.sender, swapToken);

        emit deposit(true, msg.sender, msg.value, swapToken);
    }

    function getTokenfromBusd(uint256 _amount) public view returns (uint256) {
        uint256 perToken = tokenbusdprice * _amount;
        return perToken / 1000000;
    }

    function getTokenfromBnb(uint256 _amountval) public view returns (uint256) {
        _amountval = _amountval / 1000000;
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 currentPrice = uint256(latestPrice);
        uint256 perBnb = currentPrice / 100000000;
        uint256 _amount = perBnb * _amountval;
        uint256 perToken = tokenbusdprice * _amount;
        uint256 swapToken = perToken / 1000000;
        return swapToken;
    }

    function getBnbPrice() public view returns (uint256) {
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 currentPrice = uint256(latestPrice) * 100000000;
        return currentPrice;
    }

    function updateDirectReferalPercentage(uint256 _directRefferalPercentage)
        public
        onlyContractOwner
    {
        DirectRefferalPercentage = _directRefferalPercentage;
    }

    function tokenPriceUpdate(uint256 _tokenbusdprice)
        public
        onlyContractOwner
    {
        tokenbusdprice = _tokenbusdprice;
    }

    function updateReferalEarnings(uint256 _level, uint256 _percentageReward)
        public
        onlyContractOwner
    {
        referalEarnings[_level] = _percentageReward;
    }

    function updateQueenReward(uint256 _plan, uint256 _percentageReward)
        public
    {
        queenReward[_plan] = _percentageReward * 1e18;
    }

    function updateKingReward(uint256 _plan, uint256 _percentageReward) public {
        kingReward[_plan] = _percentageReward * 1e18;
    }

    function updatePrice(uint256 _plan, uint256 _amount) public {
        price[_plan] = _amount * 1e18;
    }

    function updateWithdrawLimit(uint256 _minLimit) public {
        withdrawMinLimit = _minLimit * 3600;
    }

    function updateWithdrawStakingLimit(uint256 _minLimit) public {
        withdrawMinLimitStaking = _minLimit * 3600;
    }

    function buyPlan(address referrerAddress, uint256 plan) public {
        require(plan == 1 || plan == 2, "Plan Not exist");
        UserInfo storage user = userData[msg.sender];
        UserInfo storage parent = userData[referrerAddress];
        require(parent.isUser, "Referrer not exists");
        require(!user.isUser, "user already exists");
        IERC20(BusdAddresss).safeTransferFrom(
            msg.sender,
            address(this),
            price[plan]
        );
        currUserId++;
        user.userid = currUserId;
        user.parent = referrerAddress;
        user.plan = plan;
        user.isUser = true;
        user.lastStaked = 0;
        parent.totalRefrerRewards +=
            (DirectRefferalPercentage * price[plan]) /
            100;
        referals[referrerAddress].push(msg.sender);

        emit purchasePlan(
            referrerAddress,
            msg.sender,
            plan,
            DirectRefferalPercentage
        );
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        internal
        pure
        returns (uint256)
    {
        return _to - _from;
    }

    function stake(uint256 amount, uint256 _pid) public {
        StakePoolInfo storage pool = poolInfo[_pid];
        require(amount > pool.minStakeAmount, "Minimum error");
        require(pool.isActve, "Admin disable new stake");
        IERC20(QbtAddresss).safeTransferFrom(msg.sender, address(this), amount);
        UserInfo storage parent = userData[msg.sender];
        UserInfo storage userstake = userInfo[_pid][msg.sender];
        if (block.timestamp > userstake.lastStaked && userstake.amount > 0) {
            uint256 multiplier = getMultiplier(
                userstake.lastStaked,
                block.timestamp
            );
            uint256 perMonthsec = 86400 * pool.duration;
            if (!pool.isMine) {
                uint256 pendingReward = (userstake.amount *
                    multiplier *
                    pool.rewardPercent) / (perMonthsec * 100000);
                userstake.stakeReward += pendingReward;
            } else {
                uint256 pendingReward = (userstake.amount *
                    multiplier *
                    pool.rewardPercent) / (perMonthsec * 100000);
                userstake.mineReward += pendingReward;
            }
        }
        if (userstake.amount == 0 && userstake.lastStaked == 0) {
            distributeStakeReferral(parent.parent, 1);
        }
        userstake.amount += amount;
        userstake.lastStaked = block.timestamp;
    }

    function add(
        uint256 _rewardPercent,
        uint256 _duration,
        uint256 _minStakeAmount,
        bool _isActve,
        bool _isMine
    ) public onlyContractOwner {
        poolInfo.push(
            StakePoolInfo({
                rewardPercent: _rewardPercent, // 5 or 6
                duration: _duration, // 30,60
                minStakeAmount: _minStakeAmount * 1e18, //  120
                isActve: _isActve, // true
                isMine: _isMine // false
            })
        );
    }

    function set(
        uint256 _pid,
        uint256 _rewardPercent,
        uint256 _duration,
        uint256 _minStakeAmount,
        bool _isActve,
        bool _isMine
    ) public onlyContractOwner {
        StakePoolInfo storage pool = poolInfo[_pid];
        pool.rewardPercent = _rewardPercent;
        pool.duration = _duration;
        pool.minStakeAmount = _minStakeAmount * 1e18;
        pool.isActve = _isActve;
        pool.isMine = _isMine;
    }

    function getPoollength() public view returns (uint256) {
        return poolInfo.length;
    }

    function distributeStakeReferral(address userNew, uint256 cnt) internal {
        if (cnt < 10 && userNew != 0x0000000000000000000000000000000000000000) {
            UserInfo storage userstake = userData[userNew];
            uint256 busdPending;
            test1 = userstake.plan;
            if (userstake.plan == 1) {
                busdPending = kingReward[cnt];
            } else {
                busdPending = queenReward[cnt];
            }
            test2 = busdPending;
            test3 = cnt;
            userstake.gainBusd += busdPending;
            cnt++;
            test4 = cnt;
            distributeStakeReferral(userstake.parent, cnt);
        }
    }

    function withdrawStakeRewards(uint8 _pid) public {
        StakePoolInfo storage pool = poolInfo[_pid];
        UserInfo storage parent = userData[msg.sender];
        UserInfo storage userstake = userInfo[_pid][msg.sender];
        require(userstake.amount > 0, "amount must be greate than zero");

        if (userstake.stakeReward > 0 || userstake.mineReward > 0) {
            uint256 userPending = 0;
            uint256 companyPending = 0;

            uint256 multiplier = getMultiplier(
                userstake.lastStaked,
                block.timestamp
            );
            uint256 perMonthsec = 86400 * pool.duration;

            if (!pool.isMine) {
                require(
                    block.timestamp >
                        userstake.lastStaked +
                            (pool.duration * withdrawMinLimitStaking),
                    "Still withdraw locked."
                );

                userstake.stakeReward +=
                    (userstake.amount * multiplier * pool.rewardPercent) /
                    (perMonthsec * 100000);

                userPending =
                    (userstake.stakeReward * referalEarnings[0]) /
                    100;
                companyPending =
                    (userstake.stakeReward * referalEarnings[10]) /
                    100;
                userstake.stakeReward = 0;
            } else {
                require(
                    block.timestamp > userstake.lastStaked + withdrawMinLimit,
                    "Still withdraw locked."
                );

                userstake.mineReward +=
                    (userstake.amount * multiplier * pool.rewardPercent) /
                    (perMonthsec * 100000);

                userPending = (userstake.mineReward * referalEarnings[0]) / 100;
                companyPending =
                    (userstake.mineReward * referalEarnings[10]) /
                    100;
                userstake.mineReward = 0;
            }
            userPending += userstake.gainReward; //gainReward means from the referral earnings.
            userstake.gainReward = 0;
            IERC20(QbtAddresss).transfer(msg.sender, userPending);
            IERC20(QbtAddresss).transfer(contractOwner, companyPending);
            emit withdraw(msg.sender, userPending, (pool.isMine) ? 1 : 2);
            emit withdraw(contractOwner, companyPending, (pool.isMine) ? 3 : 4);
            distributeEarnings(parent.parent, 1, _pid);
        }
    }

    function getrewardAmount(uint8 _pid) public view returns (uint256) {
        StakePoolInfo storage pool = poolInfo[_pid];
        UserInfo storage userstake = userInfo[_pid][msg.sender];
        uint256 userPending = 0;
        if (!pool.isMine) {
            userPending = (userstake.stakeReward * referalEarnings[0]) / 100;
        } else {
            userPending = (userstake.mineReward * referalEarnings[0]) / 100;
        }
        userPending += userstake.gainReward; //gainReward means from the referral earnings.
        return userPending;
    }

    function distributeEarnings(
        address _user,
        uint256 cnt,
        uint256 _pid
    ) internal {
        UserInfo storage user = userData[msg.sender];
        StakePoolInfo storage pool = poolInfo[_pid];
        if (cnt < 10 && _user != 0x0000000000000000000000000000000000000000) {
            uint256 amountShare = 0;
            if (pool.isMine) {
                amountShare = (user.stakeReward * referalEarnings[cnt]) / 100;
            } else {
                amountShare = (user.mineReward * referalEarnings[cnt]) / 100;
            }
            user.gainReward += amountShare;
            cnt++;
            distributeEarnings(user.parent, cnt, _pid);
        }
    }

    function withdrawBusdRewards() public {
        UserInfo storage user = userData[msg.sender];
        if (user.gainBusd > 0) {
            IERC20(BusdAddresss).transfer(msg.sender, user.gainBusd);
            emit withdraw(msg.sender, user.gainBusd, 5);
            user.gainBusd = 0;
        }
    }

    function withdrawLostTokens(uint256 amountBusd, uint256 amountQbt)
        public
        onlyContractOwner
    {
        IERC20(BusdAddresss).transfer(contractOwner, amountBusd);
        IERC20(QbtAddresss).transfer(contractOwner, amountQbt);
    }

    function withdrawReferalReward() public {
        UserInfo storage parent = userData[msg.sender];
        uint256 totalRefrerRewards = parent.totalRefrerRewards;
        require(totalRefrerRewards > 0, "Insufficient referal rewards.");
        IERC20(QbtAddresss).transfer(msg.sender, totalRefrerRewards);
        parent.totalRefrerRewards = 0;
        emit withdraw(msg.sender, totalRefrerRewards, 6);
    }
}