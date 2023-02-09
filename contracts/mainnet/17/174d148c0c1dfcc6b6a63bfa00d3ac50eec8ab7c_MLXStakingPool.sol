/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: GPL-3.0
// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// File: contracts/mlx-staking.sol


pragma solidity ^0.8.4;

interface ERC20 {
    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}



// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


// import "hardhat/console.sol";

contract MLXStakingPool is Ownable, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    // using SafeERC20 for IERC20;

    /**
     * @dev Emitted when funding Staking Pool balance.
     * @param sender address of the funder
     * @param amount amount of token sent
     * @param poolBalance current pool balance.
     */
    event FundStakingPool(address sender, uint256 amount, uint256 poolBalance);

    /**
     * @dev Emitted when deposit Staking Pool.
     * @param sender address of the deposit sender
     * @param depositBalance current deposit balance
     * @param rewardInfo current reward info.
     */
    event DepositStakingPool(
        address sender,
        uint256 depositBalance,
        uint256 rewardInfo
    );

    /**
     * @dev Emitted when withdraw Staking Pool.
     * @param sender address of the deposit sender
     * @param depositBalance current deposit balance
     * @param rewardInfo current reward info.
     */
    event WithdrawStakingPool(
        address sender,
        uint256 depositBalance,
        uint256 rewardInfo
    );

    /**
     * @dev Emitted when Claiming Staking Pool Reward.
     * @param sender address of the deposit sender
     * @param depositBalance current deposit balance
     * @param rewardInfo current reward info.
     */
    event ClaimStakingPoolReward(
        address sender,
        uint256 depositBalance,
        uint256 rewardInfo
    );

    /**
     * @dev Emitted when Comounding Staking Pool Reward.
     * @param sender address of the deposit sender
     * @param depositBalance current deposit balance
     * @param rewardInfo current reward info.
     */
    event CompoundStakingPoolReward(
        address sender,
        uint256 depositBalance,
        uint256 rewardInfo
    );

    uint256 public constant PCT_BASE = 100000;
    uint256 public constant DAYS_IN_YEAR = 365;
    uint256 public constant SECONDS_IN_DAY = 86400;
    uint256 public minDeposit = 5000 ether;
    uint256 public maxPoolLimit = 10000000 ether;
    uint256 public refPercentage = 9;
    uint256 public rewardLock = 7 days;
    uint256 public withdrawLock = 180 days;

    ERC20 public immutable token;
    ERC20 public immutable rewardToken;
    uint256 public aprLevel1;
    uint256 public depositFee;
    uint256 public withdrawFee;

    uint256 public feesPool;
    uint256 public poolBalance;
    uint256 public totalStaked;

    struct timelock {
        uint256 time;
    }

    struct referralInfo {
        uint256 reward;
        uint256 amount;
    }

    // The deposit balances of users
    mapping(address => uint256) public balances;

    // The dates of users' last deposit/withdraw
    mapping(address => uint256) public lastActionTime;

    // Unclaimed reward
    mapping(address => uint256) public unclaimedReward;

    mapping(address => timelock) public swaplock;

    mapping(address => referralInfo) public referralRewards;

    mapping(address => uint256) public depositTime;

    //Array of stakers' addresses
    address[] public stakerList;

    /**
     * @dev Staking Pool constructor
     * @param _depositFee deposit fee percenatge with percentage base 100000 (i.e. 0.75% => 750 )
     * @param _withdrawFee withdraw fee percenatge with percentage base 100000 (i.e. 0.75% => 750 )
     */
    constructor(uint256 _depositFee, uint256 _withdrawFee) {
        token = ERC20(0x7Ad0972c488B6372c6657776e6B6Ce594372CFEF);
        rewardToken = ERC20(0x5851Ca8d980ecb041CF4202Cf43a7CbFa593dcD0);
        aprLevel1 = 410800;
        depositFee = _depositFee;
        withdrawFee = _withdrawFee;
    }

    /**
     * @dev Method is used to retreive current balance for the user
     * @param _userAddress user's address.
     */
    function getBalance(address _userAddress) public view returns (uint256) {
        return balances[_userAddress];
    }

    /**
     * @dev Method is used to retreive last action time for the user
     * @param _userAddress user's address.
     */
    function getLastActionTime(address _userAddress)
        public
        view
        returns (uint256)
    {
        return lastActionTime[_userAddress];
    }

    /**
     * @dev Method is used to retreive accumulated unclaimed reward
     * @param _userAddress user's address.
     */
    function getUnclaimedReward(address _userAddress)
        public
        view
        returns (uint256)
    {
        return unclaimedReward[_userAddress];
    }

    /**
     * @dev Internal method is add unclaimed rewards to balance
     *
     */
    function addUnclaimedRewards() internal returns (uint256) {
        (, , uint256 reward) = getRewardInfo(msg.sender);
        if (balances[msg.sender] > 0) {
            // add unclaim reward
            unclaimedReward[msg.sender] += reward;
        }
        return reward;
    }

    /**
     * @dev Internal method is add staker address to the stakerList
     * @param _userAddress user's address.
     */
    function addStakerAddress(address _userAddress) internal {
        for (uint256 i = 0; i < stakerList.length; ++i) {
            if (stakerList[i] == _userAddress) {
                return;
            }
        }
        stakerList.push(_userAddress);
    }

    /**
     * @dev This method is used to depost tokens
     *
     * @param _amount amount to deposit.
     */
    function deposit(address _ref, uint256 _amount) public {
        require(_ref != msg.sender, "Referral cannot be your own address");
        require(totalStaked <= maxPoolLimit, "Max pool limit reached");
        require(
            _amount >= minDeposit,
            "Amount is below minimum deposit amount"
        );
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "transfer failed"
        );
        if (_ref != 0x0000000000000000000000000000000000000000) {
            uint256 ref_amount = (_amount.mul(refPercentage)).div(100);
            referralRewards[_ref].reward = ref_amount;
            referralRewards[_ref].amount++;
            require(
                token.transferFrom(address(this), _ref, ref_amount),
                "transfer failed"
            );
        }
        depositTime[msg.sender] = block.timestamp;
        swaplock[msg.sender].time = block.timestamp + rewardLock;
        uint256 reward = addUnclaimedRewards();

        uint256 _fee = getDepositFee(_amount);
        feesPool = feesPool.add(_fee);

        uint256 _balance = balances[msg.sender];
        balances[msg.sender] = _balance.add(_amount.sub(_fee));
        totalStaked = totalStaked.add(_amount.sub(_fee));
        lastActionTime[msg.sender] = block.timestamp;

        addStakerAddress(msg.sender);

        emit DepositStakingPool(msg.sender, balances[msg.sender], reward);
    }

    /**
     * @dev This method is used to withdraw tokens
     *
     */
    function withdrawCapital() public {
        require(block.timestamp >= depositTime[msg.sender] + withdrawLock, "You can withdraw after 6 months of deposit only.");
        uint256 _amount = balances[msg.sender];
        require(_amount > 0, "can't withdraw 0 amount");

        uint256 _fee = getWithdrawFee(_amount);
        uint256 _amountToSend = _amount.sub(_fee);

        require(totalStaked >= _amountToSend, "not enough pool balance");

        token.approve(address(this), _amountToSend);

        require(
            token.transferFrom(address(this), msg.sender, _amountToSend),
            "transfer failed"
        );

        uint256 reward = addUnclaimedRewards();

        feesPool = feesPool.add(_fee);

        uint256 _balance = balances[msg.sender];
        balances[msg.sender] = _balance.sub(_amount);
        totalStaked = totalStaked.sub(_amount);
        lastActionTime[msg.sender] = block.timestamp;

        emit WithdrawStakingPool(msg.sender, balances[msg.sender], reward);
    }

    function withdrawFees() public onlyOwner {
        require(feesPool > 0, "can't withdraw 0 amount");
        require(token.transfer(msg.sender, feesPool), "transfer failed");
    }

    /**
     * @dev This method is used to compund reward tokens to user's wallet
     *
     */
    function compoundReward() public {
        (, , uint256 rewardToCompound) = getRewardInfo(msg.sender);

        balances[msg.sender] += rewardToCompound;
        unclaimedReward[msg.sender] = 0;
        lastActionTime[msg.sender] = block.timestamp;

        totalStaked = totalStaked.add(rewardToCompound);
        emit CompoundStakingPoolReward(
            msg.sender,
            balances[msg.sender],
            rewardToCompound
        );
    }

    /**
     * @dev This method is used to claim reward tokens to user's wallet
     *
     */
    function claimReward() public {
        (, , uint256 rewardToSend) = getRewardInfo(msg.sender);

        require(
            block.timestamp >= swaplock[msg.sender].time,
            "You can only swap once per week!"
        );
        require(poolBalance >= rewardToSend, "not enough pool balance");
        swaplock[msg.sender].time = block.timestamp + rewardLock;

        rewardToken.approve(address(this), rewardToSend);

        require(
            rewardToken.transferFrom(address(this), msg.sender, rewardToSend),
            "transfer failed"
        );

        unclaimedReward[msg.sender] = 0;
        lastActionTime[msg.sender] = block.timestamp;
        poolBalance = poolBalance.sub(rewardToSend);

        emit ClaimStakingPoolReward(
            msg.sender,
            balances[msg.sender],
            rewardToSend
        );
    }

    /**
     * @dev Internal  method to calculate depost fee from staking amount
     *
     * @param _amount amount to stake.
     */
    function getDepositFee(uint256 _amount) public view returns (uint256) {
        return (_amount * depositFee) / PCT_BASE;
    }

    /**
     * @dev Internal method to calculate withdraw fee from staking amount
     *
     * @param _amount amount to stake.
     */
    function getWithdrawFee(uint256 _amount) internal view returns (uint256) {
        return (_amount * withdrawFee) / PCT_BASE;
    }

    /**
     * @dev Method is used to get current rewards info
     * Tuple of
     * - staking period in days,
     * - current APR
     * - total unclaumed reward based on balance and lastActionTime for the user
     *
     * @param _userAddress user's address.
     */
    function getRewardInfo(address _userAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 stakingPeriod = getStackingPeriodDays(_userAddress);
        uint256 annualPercetangeRate = aprLevel1;
        uint256 totalReward = unclaimedReward[_userAddress] +
            (balances[_userAddress] * annualPercetangeRate * stakingPeriod) /
            DAYS_IN_YEAR /
            PCT_BASE;
        return (stakingPeriod, annualPercetangeRate, totalReward);
    }

    /**
     * @dev Method is used to calculate days since last action for the user
     * @param _userAddress user's address.
     */
    function getStackingPeriodDays(address _userAddress)
        public
        view
        returns (uint256)
    {
        if (
            lastActionTime[_userAddress] < 1 ||
            block.timestamp < lastActionTime[_userAddress]
        ) {
            return 0;
        }
        return
            (block.timestamp - lastActionTime[_userAddress]) / SECONDS_IN_DAY;
    }

    /**
     * @dev Test Method is used  days since last action for the user
     * @param _userAddress user's address.
     * @param _days number of days to age balance.
     */
    function _AGE_DEPOSIT_(address _userAddress, uint256 _days) public {
        require(
            lastActionTime[_userAddress] > _days * SECONDS_IN_DAY,
            "Too many days"
        );
        uint256 curTime = lastActionTime[_userAddress];
        lastActionTime[_userAddress] = curTime.sub(_days * SECONDS_IN_DAY);
    }

    /**
     * @dev Fund the pool balance to be used by the staking pool
     * @notice must be an owner
     * @param _amount amount to fund.
     */
    function fund(uint256 _amount) public onlyOwner {
        require(
            rewardToken.transferFrom(msg.sender, address(this), _amount),
            "transfer failed"
        );
        poolBalance = poolBalance.add(_amount);
        emit FundStakingPool(msg.sender, _amount, poolBalance);
    }

    /**
     * @dev Get total unclaimed reward for all stakers
     * @notice must be an owner
     */
    function getTotalUnclaimedReward() public view onlyOwner returns (uint256) {
        uint256 totalUnclaimedReward = 0;
        for (uint256 i = 0; i < stakerList.length; ++i) {
            (, , uint256 reward) = getRewardInfo(stakerList[i]);
            totalUnclaimedReward += reward;
        }
        return totalUnclaimedReward;
    }

    function setMaxPoolLimit(uint256 _value) external onlyOwner {
        maxPoolLimit = _value;
    }

    function setRefPercentage(uint256 _value) external onlyOwner {
        refPercentage = _value;
    }

    function setRewardLock(uint256 _value) external onlyOwner {
        rewardLock = _value;
    }

    function setWithdrawLock(uint256 _value) external onlyOwner {
        withdrawLock = _value;
    }

    function sendValueTo(address to_, uint256 value) internal {
        address payable to = payable(to_);
        (bool success, ) = to.call{value: value}("");
        require(success, "Transfer failed.");
    }

    function withdraw() public onlyOwner {
        sendValueTo(msg.sender, address(this).balance);
    }

    function withdraw_token(address _token) public onlyOwner {
        uint256 balance = ERC20(_token).balanceOf(address(this));
        require(balance > 0, "zero amount");
        ERC20(_token).transfer(msg.sender, balance);
    }

    function setAprLevel(uint256 _value) external onlyOwner {
        aprLevel1 = _value;
    }

    function setWithdrawFee(uint256 _value) external onlyOwner {
        withdrawFee = _value;
    }

    function setDepositFee(uint256 _value) external onlyOwner {
        depositFee = _value;
    }

    function setMinimumDeposit(uint256 _value) external onlyOwner {
        minDeposit = _value;
    }
}