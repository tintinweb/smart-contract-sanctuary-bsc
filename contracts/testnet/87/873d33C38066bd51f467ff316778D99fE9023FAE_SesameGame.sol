// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IAccountant.sol";
import "./interfaces/IGovernance.sol";
import "./interfaces/IProduct.sol";
import "./interfaces/IRandomNumberGenerator.sol";
import "./interfaces/IWBNB.sol";

contract SesameGame is IProduct, ReentrancyGuard {
    using SafeERC20 for IERC20;

    enum STATE {
        CLOSED,
        OPEN,
        PENDING
    }
    mapping(uint256 => STATE) public state;

    IGovernance public governance;
    IRandomNumberGenerator public immutable rng;
    IAccountant public immutable accountant;
    AggregatorV3Interface public immutable priceFeed;
    IWBNB public immutable rewardToken;
    IERC20 public immutable gameToken;
    address payable public immutable collector;
    bool private immutable _native;

    uint256 public round;
    uint256 public lastRound;
    address public lastWinner;
    mapping(uint256 => address[]) public tickets;
    mapping(uint256 => mapping(address => uint256)) public ticketMap;
    mapping(uint256 => address) public winner;

    uint256 public immutable ticketPrice;
    uint256 public immutable ticketPerRound;
    uint256 public immutable feePercent = 5;

    uint256 public currentFees;
    uint256 public currentFund;
    uint256 public totalFeesCollected;
    uint256 public totalFeesEmitted;
    uint256 public totalFundCollected;
    uint256 public totalFundEmitted;
    string public version;

    event StartedRound(uint256 round);
    event EndedRound(uint256 round);
    event EnterTicket(address indexed player, uint256 round, uint256 tickets);
    event DeclareWinner(address indexed player, uint256 round, uint256 prize);
    event Refund(address indexed player, uint256 round, uint256 tickets);

    modifier onlyGovernance() {
        require(msg.sender == address(governance), "UNAUTHORIZED");
        _;
    }

    modifier onlyRNG() {
        require(msg.sender == address(rng), "UNAUTHORIZED");
        _;
    }

    constructor(
        address _governance,
        address _rewardToken,
        address _gameToken,
        address _priceFeed,
        uint256 _ticketPrice,
        uint256 _ticketPerRound,
        string memory _version
    ) {
        governance = IGovernance(_governance);
        rng = IRandomNumberGenerator(governance.randomNumberGenerator());
        accountant = IAccountant(governance.accountant());
        collector = payable(governance.feeCollector());

        _native = _rewardToken == _gameToken;
        rewardToken = IWBNB(_rewardToken);
        gameToken = IERC20(_gameToken);
        priceFeed = AggregatorV3Interface(_priceFeed);
        ticketPrice = _ticketPrice;
        ticketPerRound = _ticketPerRound;
        version = _version;
    }

    /**
     * @notice Players enters the current round and pays
     * for the number of tickets in native currency
     * @param ticket Number of tickets to enter
     */
    function enter(uint256 ticket) public payable nonReentrant {
        require(state[round] == STATE.OPEN, "NOT OPEN");
        if (_native)
            require(msg.value == ticket * netTicketPrice(), "BAD AMOUNT");

        if (ticket + tickets[round].length > ticketPerRound) {
            uint256 extra = ticket + tickets[round].length - ticketPerRound;
            ticket -= extra;

            // Product uses BNB, refund the extra part
            if (_native) {
                payable(msg.sender).transfer(extra * netTicketPrice());
                emit Refund(msg.sender, round, extra);
            }
        }

        // Product uses ERC20, do partial transfer
        if (!_native) {
            gameToken.safeTransferFrom(
                msg.sender,
                address(this),
                ticket * netTicketPrice()
            );
        }

        for (uint256 i = 0; i < ticket; i++) {
            tickets[round].push(msg.sender);
        }

        currentFund += ticket * ticketPrice;
        currentFees += ticket * feePerTicket();
        totalFundCollected += ticket * ticketPrice;
        totalFeesCollected += ticket * feePerTicket();
        ticketMap[round][msg.sender] += ticket;

        uint256 credit = getCredit(ticket * netTicketPrice());
        accountant.credit(msg.sender, credit, round, ticket);
        emit EnterTicket(msg.sender, round, ticket);
        if (tickets[round].length == ticketPerRound) {
            _endRound();
            _startRound();
        }
    }

    /**
     * @notice Callback for the random number generator
     * @param _rand Arary of random numbers
     */
    function pickWinner(uint256[] memory _rand, uint256 _round)
        external
        override
        onlyRNG
        nonReentrant
    {
        require(state[_round] == STATE.PENDING, "NOT OPEN");
        uint256 indexOfWinner = _rand[0] % ticketPerRound;
        address _winner = tickets[_round][indexOfWinner];
        winner[_round] = _winner;

        uint256 toWinner = ticketPerRound * ticketPrice;
        currentFund = 0;
        totalFundEmitted += toWinner;

        // Convert to reward rewardToken before transmit
        uint256 toShare = ticketPerRound * feePerTicket();
        currentFees = 0;
        totalFeesEmitted += toShare;

        if (_native) {
            payable(_winner).transfer(toWinner);
            rewardToken.deposit{value: toShare}();
            rewardToken.transfer(collector, toShare);
        } else {
            gameToken.safeTransfer(_winner, toWinner);
            gameToken.safeTransfer(collector, toShare);
        }

        lastWinner = _winner;
        emit DeclareWinner(_winner, _round, currentFund);

        lastRound = _round;
        _closeRound(_round);
    }

    /** @notice Activate product, only callable from governance */
    function activate() external override onlyGovernance {
        _startRound();
    }

    /** @notice Emergency: deactivate product, only callable from governance */
    function deactivate() external override onlyGovernance {
        require(state[round] != STATE.PENDING, "PENDING");
        _refund(round);
        _closeRound(round);

        // retrieve any remaining balance to avoid being trapped
        rewardToken.transfer(collector, rewardToken.balanceOf(address(this)));
        gameToken.safeTransfer(collector, gameToken.balanceOf(address(this)));
        selfdestruct(collector);
    }

    /** @notice Refund players of the given round */
    function _refund(uint256 _round) internal nonReentrant {
        for (uint256 i = 0; i < tickets[_round].length; i++) {
            address player = tickets[_round][i];
            uint256 amount = ticketMap[_round][player] * netTicketPrice();
            if (amount > 0) {
                ticketMap[_round][player] = 0;
                if (_native) {
                    payable(player).transfer(amount);
                } else {
                    gameToken.safeTransfer(player, amount);
                }
            }
        }
        totalFeesCollected -= currentFees;
        totalFundCollected -= currentFund;
        currentFees = 0;
        currentFund = 0;
    }

    /** @notice Start a new round */
    function _startRound() internal {
        round++;
        state[round] = STATE.OPEN;
        emit StartedRound(round);
    }

    /**
     * @notice Reached current round limit. Stop accepting
     * more ticket. Request random number.
     */
    function _endRound() internal {
        state[round] = STATE.PENDING;
        rng.requestRandomNumber(round);
        emit EndedRound(round);
    }

    /** @notice Mark current round closed, after picking winner */
    function _closeRound(uint256 _round) internal {
        state[_round] = STATE.CLOSED;
    }

    /** @notice Convert players' deposit to USD at market price */
    function getCredit(uint256 amount) public view returns (uint256) {
        return (amount * getPriceFeed()) / 1 ether;
    }

    /** @notice Get game rewardToken price quote in USD (18 decimals) */
    function getPriceFeed() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price) * 10**10;
    }

    /** @notice Price and fee for each ticket */
    function netTicketPrice() public view returns (uint256) {
        return ticketPrice + feePerTicket();
    }

    /** @notice Fee for each ticket */
    function feePerTicket() public view returns (uint256) {
        return (ticketPrice * feePercent) / 100;
    }

    /** @notice Number of tickets in current round */
    function getTicketCount() external view returns (uint256 count) {
        return tickets[round].length;
    }

    /** @notice Number of tickets bought by player at given round */
    function getUserTicketCount(uint256 _round, address _player)
        external
        view
        returns (uint256 count)
    {
        return ticketMap[_round][_player];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IAccountant {
    function credit(
        address player,
        uint256 point,
        uint256 round,
        uint256 ticket
    ) external;

    function playerReward(address player) external view returns (uint256);

    function totalUnclaimed() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IGovernance {
    function isVoter(address _voter) external view returns (bool);

    function isProduct(address _product) external view returns (bool);

    function accountant() external view returns (address);

    function feeCollector() external view returns (address);

    function randomNumberGenerator() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IProduct {
    function pickWinner(uint256[] memory _rand, uint256 _round) external;

    function activate() external;

    function deactivate() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IRandomNumberGenerator {
    function setGovernance(address _governance) external;

    function requestRandomNumber(uint256 _round) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;

    function balanceOf(address) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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