/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// File: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol

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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

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

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.8.0;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.8.0;

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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

pragma solidity ^0.8.0;

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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/interfaces/IGianniEsportBetting.sol

pragma solidity ^0.8.4;

interface IGianniEsportBetting {
    struct Team {
        string name;
        string flag;
    }

    enum Bet {
        Pending,
        Win,
        Draw,
        Lose
    }

    /**
     * @notice release Bet for the current performance
     * @param _performanceId: performanceId
     * @param _betting: item of Bet
     * @param _amount: number GDE in Bet
     * @dev Callable by users
     */
    function bet(uint256 _performanceId, Bet _betting, uint256 _amount) external;

    /**
     * @notice Claim a set of winning Bet for a Performance
     * @param _performanceId: Performance id
     * @param _betIds: array of Bet ids
     * @dev Callable by users only, not contract!
     */
    function claimBetting(
        uint256 _performanceId,
        uint256[] calldata _betIds
    ) external;

    /**
     * @notice Draw the final number, calculate reward in GDE per group, and make Performance claimable
     * @param _performanceId: performance id
     * @param _homeGoal: The goal number of home in performance
     * @param _awayGoal: The goal number of away in performance
     * @dev Callable by operator
     */
    function makePerformanceClaimable(uint256 _performanceId, uint32 _homeGoal, uint32 _awayGoal) external;

    /**
     * @notice Start the performance
     * @dev Callable by operator
     * @param _startTime: startTime of the performance
     * @param _home: home team of the performance
     * @param _away: away team of the performance
     * @param _treasuryFee: treasury fee (10,000 = 100%, 100 = 1%)
     */
    function startPerformance(
        uint256 _startTime,
        Team calldata _home,
        Team calldata _away,
        uint256 _treasuryFee
    ) external;
}

// File: contracts/GianniEsportBetting.sol

pragma solidity ^0.8.4;
pragma abicoder v2;

/** @title GianniEsport Betting.
 * @notice It is a contract for a Performance system using
 * randomness provided externally.
 */
contract GianniEsportBetting is ReentrancyGuard, IGianniEsportBetting, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public operatorAddress = 0xBe06E72BB324DBa42D15F6e8BFe3780F070D864d;
    address public treasuryAddress = 0xBe06E72BB324DBa42D15F6e8BFe3780F070D864d;
    uint256 public latestTicketId = 0;
    uint256 public latestPerformanceId = 0;

    uint256 public maxPriceBetInGde = 5000000 ether;
    uint256 public minPriceBetInGde = 1 ether;

    uint256 public constant MAX_TREASURY_FEE = 3000; // 30%

    IERC20 public gdeToken;

    enum Status {
        Pending,
        Open,
        Close,
        Claimable
    }

    struct Performance {
        uint256 id;
        Team home;
        Team away;
        Status status;

        uint32 homeGoal;
        uint32 awayGoal;
        uint256 endTime;
        uint256 startTime;
        uint256 treasuryFee; // 500: 5% // 200: 2% // 50: 0.5%
        uint256 amountCollected;
        uint256 amountWinCollected;
        uint256 amountDrawCollected;
        uint256 amountLoseCollected;
        Bet finalBet;
    }

    struct Ticket {
        address owner;
        uint256 amount;
        Bet bet;
    }

    // Mapping are cheaper than arrays
    mapping(uint256 => Performance) private _performances;
    mapping(uint256 => Ticket) private _tickets;

    // Keeps track of number of bet per unique combination for each performanceId
    mapping(uint256 => mapping(uint32 => uint256)) private _numberBetPerPerformanceId;

    // Keep track of user bet ids for a given performanceId
    mapping(address => mapping(uint256 => uint256[])) private _userBetIdsPerPerformanceId;

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }

    event AdminTokenRecovery(address token, uint256 amount);
    event PerformanceOpen(
        uint256 indexed performanceId,
        uint256 startTime,
        uint256 endTime,
        Team home,
        Team away
    );
    event PerformanceTicketResult(uint256 indexed performanceId, Bet _bet);
    event NewOperatorAndTreasuryddresses(address operator, address treasury);
    event BetTicket(address indexed oracle, uint256 indexed performanceId, Bet _bet);
    event TicketClaim(address indexed claimer, uint256 amount, uint256 indexed performanceId, uint256 _ticket);
    event TicketClose(uint256 performanceId);

    /**
     * @notice Constructor
     * @param _gdeTokenAddress: address of the GDE token
     */
    constructor(address _gdeTokenAddress) {
        gdeToken = IERC20(_gdeTokenAddress);
    }

    /**
    * Flow
    */

    /**
     * @notice Start the performance
     * @dev Callable by operator
     * @param _startTime: startTime of the performance
     * @param _home: home team of the performance
     * @param _away: away team of the performance
     * @param _treasuryFee: treasury fee (10,000 = 100%, 100 = 1%)
     */
    function startPerformance(
        uint256 _startTime,
        Team calldata _home,
        Team calldata _away,
        uint256 _treasuryFee
    ) external override onlyOperator {
        require(_treasuryFee <= MAX_TREASURY_FEE, "Treasury fee too high");

        _performances[latestPerformanceId] = Performance({
            id: latestPerformanceId,
            home: _home,
            away: _away,

            status: Status.Open,
            endTime: 0,
            startTime: _startTime,
            treasuryFee: _treasuryFee,
            amountCollected: 0,
            amountWinCollected: 0,
            amountDrawCollected: 0,
            amountLoseCollected: 0,
            homeGoal: 0,
            awayGoal: 0,
            finalBet: Bet.Pending
        });

        emit PerformanceOpen(
            latestPerformanceId,
            _startTime,
            0,
            _home,
            _away
        );

        latestPerformanceId += 1;
    }

    /**
     * @notice release Bet for the current performance
     * @param _performanceId: performanceId
     * @param _betting: item of Bet
     * @param _amount: number GDE in Bet
     * @dev Callable by users
     */
    function bet(uint256 _performanceId, Bet _betting, uint256 _amount)
        external
        override
        notContract
        nonReentrant
    {
        require(_betting == Bet.Win || _betting == Bet.Draw || _betting == Bet.Lose, "No Bet specified");
        require(_performances[_performanceId].status == Status.Open, "Performance is not open");
        require(_performances[_performanceId].startTime >= block.timestamp, "Performance is started");
        require(_amount >= minPriceBetInGde && _amount <= maxPriceBetInGde, "Outside of limits");

        // Transfer GDE tokens to this contract
        gdeToken.safeTransferFrom(address(msg.sender), address(this), _amount);

        // Increment the total amount collected for the lottery round
        _performances[_performanceId].amountCollected += _amount;

        if (_betting == Bet.Win) {
            _performances[_performanceId].amountWinCollected += _amount;
            _numberBetPerPerformanceId[_performanceId][0]++;
        } else if (_betting == Bet.Draw) {
            _performances[_performanceId].amountDrawCollected += _amount;
            _numberBetPerPerformanceId[_performanceId][1]++;
        } else if (_betting == Bet.Lose) {
            _performances[_performanceId].amountLoseCollected += _amount;
            _numberBetPerPerformanceId[_performanceId][2]++;
        }

        _tickets[latestTicketId] = Ticket({
            bet: _betting,
            amount: _amount,
            owner: msg.sender
        });

        _userBetIdsPerPerformanceId[msg.sender][_performanceId].push(latestTicketId);

        latestTicketId++;
        emit BetTicket(msg.sender, _performanceId, _betting);
    }

    /**
     * @notice Claim a set of winning bet for a lottery
     * @param _performanceId: Performance id
     * @param _betIds: array of bet ids
     * @dev Callable by users only, not contract!
     */
    function claimBetting(
        uint256 _performanceId,
        uint256[] calldata _betIds
    ) external override notContract nonReentrant {
        require(_betIds.length != 0, "Length must be >0");
        require(_performances[_performanceId].status == Status.Claimable, "Performance not claimable");

        // Initializes the rewardInGdeToTransfer
        uint256 rewardInGdeToTransfer;
        uint256 sourceInGdeToTransfer;

        for (uint256 i = 0; i < _betIds.length; i++) {
            uint256 thisBetId = _betIds[i];
            require(msg.sender == _tickets[thisBetId].owner, "Not the owner");

            // Update the lottery ticket owner to 0x address
            _tickets[thisBetId].owner = address(0);

            uint256 rewardForBetId = _calculateRewardsForBetId(_performanceId, thisBetId);

            // Check user is claiming the correct bet
            require(rewardForBetId != 0, "No prize for this bet");

            // Increment the reward to transfer
            rewardInGdeToTransfer = rewardInGdeToTransfer.add(rewardForBetId);

            // Return source funds
            sourceInGdeToTransfer = sourceInGdeToTransfer.add(_tickets[thisBetId].amount);
        }

        uint256 rewardFeeInGdeToTransfer = rewardInGdeToTransfer.mul(_performances[_performanceId].treasuryFee).div(10000);
        uint256 rewardReceiveInGdeToTransfer = sourceInGdeToTransfer.add(rewardInGdeToTransfer).sub(rewardFeeInGdeToTransfer);

        // Transfer money to msg.sender
        gdeToken.safeTransfer(msg.sender, rewardReceiveInGdeToTransfer);

        emit TicketClaim(msg.sender, rewardReceiveInGdeToTransfer, _performanceId, _betIds.length);
    }

    /**
     * @notice Draw the final number, calculate reward in GDE per group, and make lottery claimable
     * @param _performanceId: performance id
     * @param _homeGoal: The goal number of home in performance
     * @param _awayGoal: The goal number of away in performance
     * @dev Callable by operator
     */
    function makePerformanceClaimable(uint256 _performanceId, uint32 _homeGoal, uint32 _awayGoal)
        external
        override
        onlyOperator
        nonReentrant
    {
        require(_performances[_performanceId].status == Status.Open, "Performance not open");

        Bet _betting = _homeGoal > _awayGoal ? Bet.Win : _homeGoal < _awayGoal ? Bet.Lose : Bet.Draw;
        // Update internal statuses for performance
        _performances[_performanceId].finalBet = _betting;
        _performances[_performanceId].status = Status.Claimable;
        _performances[_performanceId].homeGoal = _homeGoal;
        _performances[_performanceId].awayGoal = _awayGoal;

        uint256 amountFunding = _performances[_performanceId].amountWinCollected;

        if (_betting == Bet.Draw) {
            amountFunding = _performances[_performanceId].amountDrawCollected;
        } else if (_betting == Bet.Lose) {
            amountFunding = _performances[_performanceId].amountLoseCollected;
        }

        // Calculate the amount to share post-treasury fee
        uint256 amountToShareToWinners = (
            (amountFunding * (10000 - _performances[_performanceId].treasuryFee))
        ) / 10000;

        // Initializes the amount to withdraw to treasury
        uint256 amountToWithdrawToTreasury = amountFunding.sub(amountToShareToWinners);

        // Transfer GDE to treasury address
        gdeToken.safeTransfer(treasuryAddress, amountToWithdrawToTreasury);

        emit PerformanceTicketResult(_performanceId, _betting);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev Only callable by owner.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(gdeToken), "Cannot be GDE token");

        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /**
     * @notice Set GDE price ticket upper/lower limit
     * @dev Only callable by owner
     * @param _minPriceBetInGde: minimum price of a ticket in GDE
     * @param _maxPriceBetInGde: maximum price of a ticket in GDE
     */
    function setMinAndMaxTicketPriceInGde(uint256 _minPriceBetInGde, uint256 _maxPriceBetInGde)
        external
        onlyOwner
    {
        require(_minPriceBetInGde <= _maxPriceBetInGde, "minPrice must be < maxPrice");

        minPriceBetInGde = _minPriceBetInGde;
        maxPriceBetInGde = _maxPriceBetInGde;
    }

    /**
     * @notice Set operator, treasury, and injector addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     * @param _treasuryAddress: address of the treasury
     */
    function setOperatorAndTreasuryddresses(
        address _operatorAddress,
        address _treasuryAddress
    ) external onlyOwner {
        require(_operatorAddress != address(0), "Cannot be zero address");
        require(_treasuryAddress != address(0), "Cannot be zero address");

        operatorAddress = _operatorAddress;
        treasuryAddress = _treasuryAddress;

        emit NewOperatorAndTreasuryddresses(_operatorAddress, _treasuryAddress);
    }

    /**
     * @notice View performance information
     * @param _performanceId: performance id
     */
    function viewPerformance(uint256 _performanceId) external view returns (Performance memory) {
        return _performances[_performanceId];
    }

    /**
     * @notice View bet information
     * @param _bettingId: bet id
     */
    function viewTicket(uint256 _bettingId) external view returns (Ticket memory) {
        return _tickets[_bettingId];
    }

    /**
     * @notice View ticker statuses and numbers for an array of Ticket ids
     * @param _betIds: array of _bettingId
     */
    function viewStatusesForTicketIds(uint256[] calldata _betIds)
        external
        view
        returns (Bet[] memory, bool[] memory)
    {
        uint256 length = _betIds.length;
        Bet[] memory ticketResult = new Bet[](length);
        bool[] memory betStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            ticketResult[i] = _tickets[_betIds[i]].bet;

            if (_tickets[_betIds[i]].owner == address(0)) {
                betStatuses[i] = true;
            } else {
                betStatuses[i] = false;
            }
        }

        return (ticketResult, betStatuses);
    }

    /**
     * @notice View rewards for a given bet, providing a bracket, and performance id
     * @dev Computations are mostly offchain. This is used to verify a bet!
     * @param _performanceId: performance id
     * @param _bettingId: bet id
     */
    function viewRewardsForBetId(
        uint256 _performanceId,
        uint256 _bettingId
    ) external view returns (uint256) {
        // Check performance is in claimable status
        if (_performances[_performanceId].status != Status.Claimable) {
            return 0;
        }

        return _calculateRewardsForBetId(_performanceId, _bettingId);
    }

    /**
     * @notice View user ticket ids, numbers, and statuses of user for a given performance
     * @param _user: user address
     * @param _performanceId: performance id
     * @param _cursor: cursor to start where to retrieve the tickets
     * @param _size: the number of tickets to retrieve
     */
    function viewUserInfoForPerformanceId(
        address _user,
        uint256 _performanceId,
        uint256 _cursor,
        uint256 _size
    )
        external
        view
        returns (
            uint256[] memory,
            Bet[] memory,
            bool[] memory,
            uint256
        )
    {
        uint256 length = _size;
        uint256 numberTicketsBoughtAtPerformanceId = _userBetIdsPerPerformanceId[_user][_performanceId].length;

        if (length > (numberTicketsBoughtAtPerformanceId - _cursor)) {
            length = numberTicketsBoughtAtPerformanceId - _cursor;
        }

        uint256[] memory performanceTicketIds = new uint256[](length);
        Bet[] memory ticketResult = new Bet[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            performanceTicketIds[i] = _userBetIdsPerPerformanceId[_user][_performanceId][i + _cursor];
            ticketResult[i] = _tickets[performanceTicketIds[i]].bet;

            // True = ticket claimed
            if (_tickets[performanceTicketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                // ticket not claimed (includes the ones that cannot be claimed)
                ticketStatuses[i] = false;
            }
        }

        return (performanceTicketIds, ticketResult, ticketStatuses, _cursor + length);
    }

    /**
     * @notice Calculate rewards for a given bet
     * @param _performanceId: performance id
     * @param _bettingId: bet id
     */
    function _calculateRewardsForBetId(
        uint256 _performanceId,
        uint256 _bettingId
    ) internal view returns (uint256) {
        // Retrieve the winning number combination
        Bet finalBet = _performances[_performanceId].finalBet;

        uint256 amountCollected = _performances[_performanceId].amountCollected;
        uint256 amountWinCollected = _performances[_performanceId].amountWinCollected;
        uint256 amountDrawCollected = _performances[_performanceId].amountDrawCollected;
        uint256 amountLoseCollected = _performances[_performanceId].amountLoseCollected;

        // Retrieve the user number combination from the ticketId
        Bet winningBet = _tickets[_bettingId].bet;
        uint256 winningAmount = _tickets[_bettingId].amount;

        // Confirm that the two transformed numbers are the same, if not throw
        if (finalBet == winningBet) {
            uint256 totalAllocWinner = finalBet == Bet.Win ? amountWinCollected : finalBet == Bet.Lose ? amountLoseCollected : amountDrawCollected;
            uint256 totalAllocShare = amountCollected - totalAllocWinner;

            return winningAmount.mul(totalAllocShare).div(totalAllocWinner);
        } else {
            return 0;
        }
    }

    /**
     * @notice Calculate final price for bulk of tickets
     * @param _discountDivisor: divisor for the discount (the smaller it is, the greater the discount is)
     * @param _priceTicket: price of a ticket
     * @param _numberTickets: number of tickets purchased
     */
    function _calculateTotalPriceForBulkTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) internal pure returns (uint256) {
        return (_priceTicket * _numberTickets * (_discountDivisor + 1 - _numberTickets)) / _discountDivisor;
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}