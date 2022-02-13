/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/SimpleBet.sol



pragma solidity >=0.7.0 <0.9.0;


contract SimpleBet {
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
    }

    // mapping(string => uint256) teams;
    mapping(uint256 => MatchContainer) private matchDefinitions; // Key is Match ID
    mapping(uint256 => mapping(MatchResult => uint256)) private betRewardPool; // Key is Match ID (Resultado => PozoAcumulado)
    mapping(uint256 => mapping(address => MatchResult)) private userBets; // Key is Match ID (usuario => Resultado)
    mapping(uint256 => mapping(address => bool)) private usersClaims;

    address private owner;
    uint256 public constant MIN_WEI_AMOUNT = 10000000000000000;
    IERC20 private rewardsToken;
    //--------------------------- E V E N T S -----------------------------
    event NewMatchCreated(uint256 _matchId);
    event MatchOpenedForBets(uint256 _matchId);
    event MatchFinished(uint256 _matchId, MatchResult _result);

    event MatchBetPlaced(
        address _sender,
        uint256 _matchId,
        MatchResult _result
    );
    event UserClaimedBet(address _player, uint256 _matchId, uint256 _amount);

    //--------------------------- C O N S T R U C T O R -----------------------------
    constructor(address _rewardsToken) {
        owner = msg.sender;
        rewardsToken = IERC20(_rewardsToken);
    }

    //--------------------------- A D M I N -----------------------------
    function createMatchDefinition(
        uint256 _matchId,
        uint256 _betAmmout,
        uint256 _localTeam,
        uint256 _visitorTeam,
        uint256 _matchDate
    ) external {
        require(
            _betAmmout >= MIN_WEI_AMOUNT,
            "Bet amount is less than minimun amount."
        );

        MatchContainer memory betCont;
        betCont.matchId = _matchId;
        betCont.openForBets = false;
        betCont.date = _matchDate;
        betCont.localTeam = _localTeam;
        betCont.visitorTeam = _visitorTeam;
        betCont.result = MatchResult.PENDING;
        betCont.betAmount = _betAmmout;

        matchDefinitions[_matchId] = betCont;
        emit NewMatchCreated(_matchId);
    }

    function enableMatch(uint256 _matchId) external {
        matchDefinitions[_matchId].openForBets = true;
        emit MatchOpenedForBets(_matchId);
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }

    function getMatchRewardPool(uint256 _matchId, MatchResult _result)
        private
        view
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
        uint256 pool = (totalReward / 100) * 90;
        uint256 fee = (totalReward / 100) * 10;
        uint256 winnerPool = rewards[_result];
        return (pool, fee, winnerPool);
    }

    //Evento de partido creado
    function setMatchResult(uint256 _matchId, MatchResult _result) external {
        //buscar el match, setear el resultado.

        //calcular el pozo ganador para el Claim?
        uint256 pool;
        uint256 fee;
        uint256 winnerPool;
        (pool, fee, winnerPool) = getMatchRewardPool(_matchId, _result);
        matchDefinitions[_matchId].result = _result;
        matchDefinitions[_matchId].rewardPool = pool;
        matchDefinitions[_matchId].feePool = fee;
        matchDefinitions[_matchId].numberOfWinners =
            winnerPool /
            matchDefinitions[_matchId].betAmount;
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

        emit MatchBetPlaced(msg.sender, _matchId, _result);
    }

    function userBetToUSDT(
        uint256 _matchId,
        MatchResult _result,
        uint256 _amount
    ) public {
        require(
            matchDefinitions[_matchId].openForBets,
            "Match is not open for bets"
        );
        require(
            _amount == matchDefinitions[_matchId].betAmount,
            "Bet amount is incorrect "
        );
        require(
            userBets[_matchId][msg.sender] == MatchResult.PENDING,
            "User already bet for this match"
        );
        require(rewardsToken.allowance(msg.sender, address(this)) >= matchDefinitions[_matchId]
            .betAmount,
            "Allowance is lower than required"
        );
        rewardsToken.transferFrom(msg.sender, address(this), _amount);
        userBets[_matchId][msg.sender] = _result;
        betRewardPool[_matchId][_result] += matchDefinitions[_matchId]
            .betAmount;

        emit MatchBetPlaced(msg.sender, _matchId, _result);
    }

    function aproveUSDT(uint256 _amount) external returns (bool) {
        return rewardsToken.approve(address(this), _amount);
    }

    /*
    User claims winner bet
    */
    function claimMatch(uint256 _matchId) external {
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

        uint256 valueToPay = matchDefinitions[_matchId].rewardPool /
            matchDefinitions[_matchId].numberOfWinners;
        usersClaims[_matchId][msg.sender] = false;
        (bool success, ) = msg.sender.call{value: valueToPay}("");

        require(success, "Transfer failed.");

        emit UserClaimedBet(msg.sender, _matchId, valueToPay);
    }

    function claimMatchUSDT(uint256 _matchId) external {
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

        uint256 valueToPay = matchDefinitions[_matchId].rewardPool /
            matchDefinitions[_matchId].numberOfWinners;
        usersClaims[_matchId][msg.sender] = false;
        bool success = rewardsToken.transfer(msg.sender, valueToPay);

        require(success, "Transfer failed.");

        emit UserClaimedBet(msg.sender, _matchId, valueToPay);
    }

    //--------------------------- I N V E S T O R -----------------------------
}