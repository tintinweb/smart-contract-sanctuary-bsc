// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeSwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IPancakeSwapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(msg.sender);
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// SPDX-License-Identifier: MIT
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

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

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Ownable.sol";

contract Runnable is Ownable {
    modifier whenRunning() {
        require(_isRunning, "Paused");
        _;
    }

    modifier whenNotRunning() {
        require(!_isRunning, "Running");
        _;
    }

    bool public _isRunning;

    constructor() {
        _isRunning = true;
    }

    function toggleRunning() external onlyOwner {
        _isRunning = !_isRunning;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./abstracts/Context.sol";
import "./access/Operator.sol";
import "./security/ReentrancyGuard.sol";

contract Bet is Context, Operator, ReentrancyGuard {
    enum MATCH_STATUS {
        NONE,
        ACTIVE,
        ENDED,
        CANCELED
    }

    enum BET_TYPE {
        NONE,
        WINNER,
        BIG_AND_SMALL
    }

    enum WINNER_RESULT {
        NONE,
        TEAM_A,
        DRAW,
        TEAM_B
    }

    enum BIG_AND_SMALL_RESULT {
        NONE,
        BIG,
        SMALL
    }

    struct BetResult {
        bool enable;
        uint8 result;
    }

    struct Match {
        string id;
        MATCH_STATUS status;
        uint256 startTime;
        uint256 endTime;
        mapping(BET_TYPE => BetResult) betResult;
    }

    struct BetMatch {
        uint256 id;
        string matchId;
        address host;
        uint256 hostFee;
        uint256 serviceFee;
        uint256 totalBetAmount;
        uint256 hostAmount;
        uint256 serviceAmount;
        uint256 claimAmount;
        bool hostClaim;
        BET_TYPE betType;
        mapping(uint256 => uint256) resultAmounts;
        mapping(address => PlayerBet) playerBets;
    }

    struct PlayerBet {
        uint256 amount;
        uint256 result;
        bool claim;
    }

    uint256 public serviceFee = 25;
    uint256 public maxHostFee = 100;
    uint256 public denominator = 1000;
    uint256 public minBetAmount = 10 * 10**18;
    uint256 public emergencyCancelReceivePercent = 900;

    uint256 public betId = 0;
    mapping(string => Match) public _matchs;
    mapping(uint256 => BetMatch) public _betMatchs;

    address public feeReceiver;
    IERC20 public token;

    constructor(address tokenAddress, address receiver) {
        token = IERC20(tokenAddress);
        feeReceiver = receiver;
    }

    function createMatch(
        string memory matchId,
        uint256 startTime,
        uint256 endTime,
        BET_TYPE[] memory betTypes
    ) external onlyOperator {
        bytes memory strBytes = bytes(matchId);
        require(strBytes.length > 0, "Invalid match id");
        require(betTypes.length > 0, "Invalid bet types");
        require(_matchs[matchId].status == MATCH_STATUS.NONE, "Exist");
        require(
            startTime > 0 &&
                endTime > 0 &&
                endTime > startTime &&
                endTime > block.timestamp,
            "Invalid time"
        );

        for (uint32 i = 0; i < betTypes.length; i++) {
            require(betTypes[i] != BET_TYPE.NONE, "Invalid bet type");
            _matchs[matchId].betResult[betTypes[i]] = BetResult(true, 0);
        }
        _matchs[matchId].id = matchId;
        _matchs[matchId].status = MATCH_STATUS.ACTIVE;
        _matchs[matchId].startTime = startTime;
        _matchs[matchId].endTime = endTime;

        emit CreateMatch(matchId, startTime, endTime, betTypes);
    }

    function cancelMatch(string memory matchId) external onlyOperator {
        Match storage _match = _matchs[matchId];
        require(_match.status == MATCH_STATUS.ACTIVE, "Can't update");
        _matchs[matchId].status = MATCH_STATUS.CANCELED;
        emit CancelMatch(matchId);
    }

    function finishMatch(
        string memory matchId,
        BET_TYPE[] calldata betTypes,
        uint8[] calldata results
    ) external onlyOperator {
        Match storage _match = _matchs[matchId];
        require(_match.status == MATCH_STATUS.ACTIVE, "Can't finish");
        require(betTypes.length == results.length, "Invalid result");
        _matchs[matchId].status = MATCH_STATUS.ENDED;
        for (uint8 i = 0; i < betTypes.length; i++) {
            require(_match.betResult[betTypes[i]].enable, "Invalid bet type");
            _matchs[matchId].betResult[betTypes[i]].result = results[i];
        }
        emit FinishMatch(matchId, betTypes, results);
    }

    function createBet(
        string memory matchId,
        BET_TYPE betType,
        uint256 hostFee
    ) external nonReentrant {
        Match storage _match = _matchs[matchId];
        require(_match.status == MATCH_STATUS.ACTIVE, "Match not active");
        require(_match.betResult[betType].enable, "Bet type not support");
        require(block.timestamp < _match.endTime, "Invalid time");
        require(hostFee <= maxHostFee, "Invalid host fee");

        betId += 1;
        _betMatchs[betId].id = betId;
        _betMatchs[betId].matchId = matchId;
        _betMatchs[betId].host = msg.sender;
        _betMatchs[betId].hostFee = hostFee;
        _betMatchs[betId].betType = betType;
        _betMatchs[betId].serviceFee = serviceFee;

        emit CreateBet(
            betId,
            matchId,
            msg.sender,
            betType,
            hostFee,
            serviceFee
        );
    }

    function placeBet(
        uint256 _betId,
        uint256 amount,
        uint256 result
    ) external nonReentrant {
        require(amount > 0 && amount >= minBetAmount, "Min amount");

        (BetMatch storage _bet, Match storage _match) = getBetAndMatch(_betId);
        validateBet(_match);
        require(_bet.playerBets[msg.sender].amount == 0, "Exist place bet");

        _bet.playerBets[msg.sender] = PlayerBet(amount, result, false);
        _bet.totalBetAmount += amount;
        _bet.resultAmounts[result] += amount;
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Failure"
        );
        emit PlaceBet(_betId, msg.sender, amount, result);
    }

    function emergencyCancelPlaceBet(uint256 _betId) external nonReentrant {
        (BetMatch storage _bet, Match storage _match) = getBetAndMatch(_betId);
        validateBet(_match);
        require(_bet.playerBets[msg.sender].amount > 0, "Place bet not exist");

        uint256 amount = _bet.playerBets[msg.sender].amount;
        uint256 refundAmount = (amount * emergencyCancelReceivePercent) /
            denominator;
        uint256 feeAmount = amount - refundAmount;
        _bet.totalBetAmount -= amount;
        _bet.resultAmounts[_bet.playerBets[msg.sender].result] -= amount;
        _bet.playerBets[msg.sender].amount = 0;

        require(token.transfer(msg.sender, refundAmount), "Failure");
        require(token.transfer(feeReceiver, feeAmount), "Failure");
        emit EmergencyCancelPlaceBet(
            _betId,
            msg.sender,
            refundAmount,
            feeAmount
        );
    }

    function claimBet(uint256 _betId) external nonReentrant {
        (BetMatch storage _bet, Match storage _match) = getBetAndMatch(_betId);
        require(
            _match.status == MATCH_STATUS.ENDED ||
                _match.status == MATCH_STATUS.CANCELED,
            "Match not ended"
        );

        PlayerBet memory playerBet = _bet.playerBets[msg.sender];
        require(playerBet.amount > 0, "Not bet");
        require(!playerBet.claim, "Claimed");

        uint256 claimAmount;
        if (_match.status == MATCH_STATUS.ENDED) {
            require(
                playerBet.result == _match.betResult[_bet.betType].result,
                "Not win"
            );
            uint256 claimRate = calcWinRate(_betId, playerBet.result);
            claimAmount = (playerBet.amount * claimRate) / denominator;
        } else {
            claimAmount = playerBet.amount;
        }

        _betMatchs[_betId].playerBets[msg.sender].claim = true;
        _betMatchs[_betId].claimAmount += claimAmount;
        require(token.transfer(msg.sender, claimAmount), "ERROR");

        emit ClaimBet(_betId, msg.sender, playerBet.amount, claimAmount);
    }

    function claimFee(uint256 _betId) external nonReentrant {
        (BetMatch storage _bet, Match storage _match) = getBetAndMatch(_betId);
        require(_match.status == MATCH_STATUS.ENDED, "Match not ended");
        require(
            _bet.host == msg.sender || msg.sender == owner(),
            "Not host or owner"
        );
        require(!_bet.hostClaim, "Claimed");

        uint8 betResult = _match.betResult[_bet.betType].result;
        uint256 amountTakeFee = _bet.totalBetAmount -
            _bet.resultAmounts[betResult];
        require(amountTakeFee > 0, "Nothing to claim");

        uint256 hostClaimAmount = (amountTakeFee * _bet.hostFee) / denominator;
        uint256 serviceAmount = (amountTakeFee * _bet.serviceFee) / denominator;
        _betMatchs[_betId].hostClaim = true;
        _betMatchs[_betId].serviceAmount = serviceAmount;
        _betMatchs[_betId].hostAmount = hostClaimAmount;

        require(token.transfer(_bet.host, hostClaimAmount), "ERROR");
        require(token.transfer(feeReceiver, serviceAmount), "ERROR");
        emit HostClaim(_betId, _bet.host, hostClaimAmount, serviceAmount);
    }

    function getBetAndMatch(uint256 _betId)
        internal
        view
        returns (BetMatch storage, Match storage)
    {
        BetMatch storage _bet = _betMatchs[_betId];
        return (_bet, _matchs[_bet.matchId]);
    }

    function validateBet(Match storage _match) internal view {
        require(_match.status == MATCH_STATUS.ACTIVE, "Match not active");
        require(
            block.timestamp > _match.startTime &&
                block.timestamp < _match.endTime,
            "Not yet open to cancel place a bet"
        );
    }

    function calcWinRate(uint256 _betId, uint256 result)
        public
        view
        returns (uint256)
    {
        BetMatch storage _bet = _betMatchs[_betId];
        uint256 resultAmount = _bet.resultAmounts[result];
        if (resultAmount == 0) return 0;

        uint256 total = _bet.totalBetAmount - resultAmount;
        uint256 rateWithoutFee = denominator - _bet.hostFee - _bet.serviceFee;
        return
            ((resultAmount + ((total * rateWithoutFee) / denominator)) *
                denominator) / resultAmount;
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        feeReceiver = _feeReceiver;
    }

    function setServiceFee(uint256 _serviceFee) external onlyOwner {
        serviceFee = _serviceFee;
    }

    function setMaxHostFee(uint256 _maxHostFee) external onlyOwner {
        maxHostFee = _maxHostFee;
    }

    function setMinBetAmount(uint256 _minBetAmount) external onlyOwner {
        minBetAmount = _minBetAmount;
    }

    function setEmergencyCancelReceivePercent(
        uint256 _emergencyCancelReceivePercent
    ) external onlyOwner {
        require(_emergencyCancelReceivePercent <= 500, "Max 50%");
        emergencyCancelReceivePercent = _emergencyCancelReceivePercent;
    }

    event CreateMatch(
        string matchId,
        uint256 startTime,
        uint256 endTime,
        BET_TYPE[] betTypes
    );

    event CancelMatch(string matchId);

    event FinishMatch(string matchId, BET_TYPE[] betTypes, uint8[] results);
    
    event CreateBet(
        uint256 betId,
        string matchId,
        address host,
        BET_TYPE betType,
        uint256 hostFee,
        uint256 serviceFee
    );

    event PlaceBet(
        uint256 betId,
        address better,
        uint256 amount,
        uint256 result
    );

    event EmergencyCancelPlaceBet(
        uint256 betId,
        address better,
        uint256 refund,
        uint256 fee
    );

    event ClaimBet(
        uint256 betId,
        address better,
        uint256 amount,
        uint256 winAmount
    );

    event HostClaim(
        uint256 betId,
        address host,
        uint256 hostAmount,
        uint256 serviceAmount
    );
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Ownable.sol";

abstract contract Operator is Ownable {
    mapping(address => bool) private _operators;

    constructor() {
        _setOperator(msg.sender, true);
    }

    modifier onlyOperator() {
        require(_operators[msg.sender], "Forbidden");
        _;
    }

    function _setOperator(address operatorAddress, bool value) private {
        _operators[operatorAddress] = value;
        emit OperatorSetted(operatorAddress, value);
    }

    function setOperator(address operatorAddress, bool value)
        external
        onlyOwner
    {
        _setOperator(operatorAddress, value);
    }

    function isOperator(address operatorAddress) external view returns (bool) {
        return _operators[operatorAddress];
    }

    event OperatorSetted(address operatorAddress, bool value);
}