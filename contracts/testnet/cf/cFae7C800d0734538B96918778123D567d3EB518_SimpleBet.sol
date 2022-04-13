/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/SimpleBet.sol



pragma solidity 0.8.2;



contract SimpleBet is Ownable {
    enum MatchResult {
        PENDING,
        LOCAL_WIN,
        VISITOR_WIN,
        DRAW,
        LOCAL_WIN_BY_PENALTY,
        VISITOR_WIN_BY_PENALTY
    }

    /** Definition of the Match */
    struct MatchContainer {
        uint256 matchId;
        uint256 date;
        uint256 localTeam;
        uint256 visitorTeam;
        uint256 betAmount;
        bool openForBets;
        uint256 numberOfWinners;
        uint256 rewardPool;
        uint256 feePool;
        MatchResult result;
        uint256 fee;
        uint256 minBet;
    }

    mapping(uint256 => MatchContainer) private matchDefinitions; // Key is Match ID
    mapping(uint256 => mapping(MatchResult => uint256)) private betRewardPool; // Key is Match ID (Resultado => PozoAcumulado)
    mapping(uint256 => mapping(address => MatchResult)) private userBets; // Key is Match ID (usuario => Resultado)
    mapping(uint256 => mapping(address => bool)) private usersClaims;
    uint256 private totalBets;
    uint256 private totalClaims;

    //uint256 public constant MIN_WEI_AMOUNT = 10000000000000000;
    //uint256 public constant FEE = 10;
    //uint256 public constant POOL = 90;
    uint256 public constant TOTAL = 100;
    //--------------------------- E V E N T S -----------------------------
    event NewMatchCreated(uint256 _matchId);
    event MatchOpenedForBets(uint256 _matchId);
    event MatchClosedForBets(uint256 _matchId);
    event MatchFinished(uint256 _matchId, MatchResult _result);

    event MatchBetPlaced(
        address _sender,
        uint256 _matchId,
        MatchResult _result
    );
    event UserClaimedBet(address _player, uint256 _matchId, uint256 _amount);

    //--------------------------- C O N S T R U C T O R -----------------------------
    constructor() {
        totalBets = 0;
        totalClaims = 0;
    }

    //--------------------------- A D M I N -----------------------------
    function createMatchDefinition(
        uint256 _matchId,
        uint256 _betAmount,
        uint256 _localTeam,
        uint256 _visitorTeam,
        uint256 _matchDate,
        uint256 _fee
    ) external onlyOwner {

        MatchContainer memory betCont;
        betCont.matchId = _matchId;
        betCont.openForBets = false;
        betCont.date = _matchDate;
        betCont.localTeam = _localTeam;
        betCont.visitorTeam = _visitorTeam;
        betCont.result = MatchResult.PENDING;
        betCont.betAmount = _betAmount;
        betCont.fee = _fee;

        matchDefinitions[_matchId] = betCont;
        emit NewMatchCreated(_matchId);
    }

    function enableMatch(uint256 _matchId) external onlyOwner {
        require(
            matchDefinitions[_matchId].openForBets == false,
            "Match is already open for bets"
        );
        matchDefinitions[_matchId].openForBets = true;
        emit MatchOpenedForBets(_matchId);
    }

    function disableMatch(uint256 _matchId) external onlyOwner {
        require(
            matchDefinitions[_matchId].openForBets,
            "Match is already disabled for bets"
        );
        matchDefinitions[_matchId].openForBets = false;
        emit MatchClosedForBets(_matchId);
    }

    function withdraw(uint256 _amount) external onlyOwner{
        require(this.balance()>= _amount, "Not enougth balance");
        (bool success, ) = owner().call{value: _amount}("");

        require(success, "Transfer failed.");
    }

    function balance() external view onlyOwner returns (uint256){
        return address(this).balance;
    }

    function getTotalBets() external view onlyOwner returns (uint256){
        return totalBets;
    }

    function getTotalClaims() external view onlyOwner returns (uint256){
        return totalClaims;
    }

    function getMatchDefinition(uint256 _matchId) external view returns (MatchContainer memory){
        return matchDefinitions[_matchId];
    }

    function getMatchRewardPool(uint256 _matchId, MatchResult _result)
        private
        view onlyOwner
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        mapping(MatchResult => uint256) storage rewards = betRewardPool[
            _matchId
        ];
        uint256 totalReward = rewards[MatchResult.LOCAL_WIN] +
            rewards[MatchResult.VISITOR_WIN] +
            rewards[MatchResult.DRAW] +
            rewards[MatchResult.LOCAL_WIN_BY_PENALTY] +
            rewards[MatchResult.VISITOR_WIN_BY_PENALTY];


        uint256 feePercentage = matchDefinitions[_matchId].fee;
        uint256 poolPercentage = SafeMath.sub(TOTAL,feePercentage);
        uint256 pool = SafeMath.mul(SafeMath.div(totalReward, TOTAL), poolPercentage);
        uint256 fee = SafeMath.mul(SafeMath.div(totalReward, TOTAL), feePercentage);
        uint256 winnerPool = rewards[_result];
        return (pool, fee, winnerPool);
    }

    //Evento de partido creado
    function setMatchResult(uint256 _matchId, MatchResult _result) external onlyOwner{
        //buscar el match, setear el resultado.
        //validar que no este cerrado, validar que el resultado no este seteado...
        //calcular el pozo ganador para el Claim?
        uint256 pool;
        uint256 fee;
        uint256 winnerPool;
        (pool, fee, winnerPool) = getMatchRewardPool(_matchId, _result);
        matchDefinitions[_matchId].result = _result;
        matchDefinitions[_matchId].rewardPool = pool;
        matchDefinitions[_matchId].feePool = fee;
        matchDefinitions[_matchId].numberOfWinners = SafeMath.div(
            winnerPool,
            matchDefinitions[_matchId].betAmount
        );
        matchDefinitions[_matchId].openForBets = false;
        //Enviar Evento
        emit MatchFinished(_matchId, _result);
    }

    //--------------------------- P L A Y E R -----------------------------
    //Hacer pagable esta funcion
    function userBetToMatch(uint256 _matchId, MatchResult _result)
        public
        payable
    {
        require(
            matchDefinitions[_matchId].openForBets,
            "Match is not open for bets"
        );
        require(
            matchDefinitions[_matchId].date > block.timestamp,
            "Match already started"
        );
        require(
            msg.value == matchDefinitions[_matchId].betAmount,
            "Bet amount is incorrect "
        );
        require(
            userBets[_matchId][msg.sender] == MatchResult.PENDING,
            "User already bet for this match"
        );

        userBets[_matchId][msg.sender] = _result;
        betRewardPool[_matchId][_result] += matchDefinitions[_matchId]
            .betAmount;
        totalBets +=1;
        emit MatchBetPlaced(msg.sender, _matchId, _result);
    }

    /*
    User claims winner bet
    */
    function userClaimMatch(uint256 _matchId) external {
        MatchResult actualResult = matchDefinitions[_matchId].result;
        require(
            actualResult != MatchResult.PENDING,
            "Match result has not been set yet."
        );
        require(
            userBets[_matchId][msg.sender] == actualResult,
            "User did not got the correct result"
        );
        require(
            usersClaims[_matchId][msg.sender] == false,
            "User already clamied the reward"
        );

        uint256 valueToPay = SafeMath.div(matchDefinitions[_matchId].rewardPool,
            matchDefinitions[_matchId].numberOfWinners);
        usersClaims[_matchId][msg.sender] = false;
        (bool success, ) = msg.sender.call{value: valueToPay}("");

        require(success, "Transfer failed.");
        totalClaims +=1;
        emit UserClaimedBet(msg.sender, _matchId, valueToPay);
    }

    //--------------------------- I N V E S T O R -----------------------------
}