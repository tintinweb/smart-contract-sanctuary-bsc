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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./interfaces/IPancakeSwapPair.sol";
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
    uint256 public minBetAmountInBNB = 0.1 * 10**18;
    uint256 public createBetFeeInBUSD = 10 * 10**18;
    uint256 public emergencyCancelReceivePercent = 900;

    uint256 public betId = 0;
    mapping(string => Match) public _matchs;
    mapping(uint256 => BetMatch) public _betMatchs;

    address public busdToken;
    address public wBnbToken;
    IPancakeSwapPair public bnbBusdPair;
    IPancakeSwapPair public tokenBnbPair;

    address public feeReceiver;
    IERC20 public token;

    constructor(
        address tokenAddress,
        address receiver,
        address _bnbBusdPair,
        address _tokenBnbPair,
        address _busdToken,
        address _wBnbToken
    ) {
        token = IERC20(tokenAddress);
        feeReceiver = receiver;
        bnbBusdPair = IPancakeSwapPair(_bnbBusdPair);
        tokenBnbPair = IPancakeSwapPair(_tokenBnbPair);
        busdToken = _busdToken;
        wBnbToken = _wBnbToken;
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
        uint256 feeAmount = busdToToken(createBetFeeInBUSD);
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

        require(
            token.transferFrom(msg.sender, feeReceiver, feeAmount),
            "Failure"
        );

        emit CreateBet(
            betId,
            matchId,
            msg.sender,
            betType,
            hostFee,
            serviceFee,
            feeAmount
        );
    }

    function placeBet(uint256 _betId, uint256 result)
        external
        payable
        nonReentrant
    {
        uint256 amount = msg.value;
        require(amount >= minBetAmountInBNB, "Min amount");
        require(result > 0, "Invalid result");

        (BetMatch storage _bet, Match storage _match) = getBetAndMatch(_betId);
        validateBet(_match);
        require(_bet.playerBets[msg.sender].amount == 0, "Exist place bet");

        _bet.playerBets[msg.sender] = PlayerBet(amount, result, false);
        _bet.totalBetAmount += amount;
        _bet.resultAmounts[result] += amount;
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

        (bool success, ) = payable(msg.sender).call{
            value: refundAmount,
            gas: 30000
        }("");
        require(success, "Failt refund");
        (success, ) = payable(feeReceiver).call{value: feeAmount, gas: 30000}(
            ""
        );
        require(success, "Failt send fee");
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
        (bool success, ) = payable(msg.sender).call{
            value: claimAmount,
            gas: 30000
        }("");
        require(success, "ERROR");

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

        (bool success, ) = payable(_bet.host).call{
            value: hostClaimAmount,
            gas: 30000
        }("");
        require(success, "ERROR1");
        (success, ) = payable(feeReceiver).call{
            value: serviceAmount,
            gas: 30000
        }("");
        require(success, "ERROR2");
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

    function setMinBetAmountInBNB(uint256 value) external onlyOwner {
        minBetAmountInBNB = value;
    }

    function setCreateBetFeeInBUSD(uint256 value) external onlyOwner {
        createBetFeeInBUSD = value;
    }

    function setTokenBnbPair(address pair) external onlyOwner {
        tokenBnbPair = IPancakeSwapPair(pair);
    }

    function setBnbBusdPair(address pair) external onlyOwner {
        bnbBusdPair = IPancakeSwapPair(pair);
    }

    function setEmergencyCancelReceivePercent(
        uint256 _emergencyCancelReceivePercent
    ) external onlyOwner {
        require(_emergencyCancelReceivePercent <= 500, "Max 50%");
        emergencyCancelReceivePercent = _emergencyCancelReceivePercent;
    }

    function busdToToken(uint256 amount) public view returns (uint256) {
        uint256 bnbAmount = convertPrice(bnbBusdPair, wBnbToken, amount);
        return convertPrice(tokenBnbPair, address(token), bnbAmount);
    }

    function convertPrice(
        IPancakeSwapPair pair,
        address token0,
        uint256 amountToken1
    ) public view returns (uint256) {
        (uint256 _reserve0, uint256 _reserve1, ) = pair.getReserves();
        uint256 price = pair.token0() == token0
            ? (_reserve1 * 10**18) / _reserve0
            : (_reserve0 * 10**18) / _reserve1;
        return (amountToken1 * 10**18) / price;
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
        uint256 serviceFee,
        uint256 feeAmount
    );

    event PlaceBet(
        uint256 betId,
        address bettor,
        uint256 amount,
        uint256 result
    );

    event EmergencyCancelPlaceBet(
        uint256 betId,
        address bettor,
        uint256 refund,
        uint256 fee
    );

    event ClaimBet(
        uint256 betId,
        address bettor,
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
pragma solidity ^0.8.0;

interface IPancakeSwapPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

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

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
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