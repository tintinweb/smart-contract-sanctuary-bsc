/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

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

    mapping(uint256 => MatchContainer) private matchDefinitions; // Key is Match ID
    mapping(uint256 => mapping(MatchResult => uint256)) private betRewardPool; // Key is Match ID (Resultado => PozoAcumulado)
    mapping(uint256 => mapping(address => MatchResult)) private userBets; // Key is Match ID (usuario => Resultado)
    mapping(uint256 => mapping(address => bool)) private usersClaims;

    address private owner;
    uint256 public constant MIN_WEI_AMOUNT = 10000000000000000;

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
        owner = msg.sender;
    }

    //--------------------------- A D M I N -----------------------------
    function createMatchDefinition(
        uint256 _matchId,
        uint256 _betAmount,
        uint256 _localTeam,
        uint256 _visitorTeam,
        uint256 _matchDate
    ) external {
        require(
            _betAmount >= MIN_WEI_AMOUNT,
            "Bet amount is less than minimun amount."
        );

        MatchContainer memory betCont;
        betCont.matchId = _matchId;
        betCont.openForBets = false;
        betCont.date = _matchDate;
        betCont.localTeam = _localTeam;
        betCont.visitorTeam = _visitorTeam;
        betCont.result = MatchResult.PENDING;
        betCont.betAmount = _betAmount;

        matchDefinitions[_matchId] = betCont;
        emit NewMatchCreated(_matchId);
    }

    function enableMatch(uint256 _matchId) external {
        matchDefinitions[_matchId].openForBets = true;
        emit MatchOpenedForBets(_matchId);
    }

    function disableMatch(uint256 _matchId) external {
        matchDefinitions[_matchId].openForBets = true;
        emit MatchClosedForBets(_matchId);
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


    //--------------------------- I N V E S T O R -----------------------------
}