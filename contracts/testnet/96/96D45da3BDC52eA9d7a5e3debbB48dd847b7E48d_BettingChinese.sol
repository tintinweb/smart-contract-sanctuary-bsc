// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

abstract contract BetTokenWrapper is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    function betToContract(
        uint256 amount_,
        address userAddress_,
        address tokenAddress_
    ) internal {
        IERC20 betToken = IERC20(tokenAddress_);
        betToken.safeTransferFrom(userAddress_, address(this), amount_);
    }

    function transferProtocolFee(
        address DAO_,
        uint256 daoValue_,
        address REVENUE_,
        uint256 revenueValue_,
        address tokenAddress_
    ) internal {
        if (daoValue_ != 0) {
            transfer(DAO_, daoValue_, tokenAddress_);
        }

        if (revenueValue_ != 0) {
            transfer(REVENUE_, revenueValue_, tokenAddress_);
        }
    }

    function transferHostCommission(
        address host_,
        uint256 amount_,
        address tokenAddress_
    ) internal {
        transfer(host_, amount_, tokenAddress_);
    }

    function adminTransfer(
        address receiver_,
        uint256 amount_,
        address tokenAddress_
    ) public onlyOwner {
        transfer(receiver_, amount_, tokenAddress_);
    }

    function transfer(
        address receiver_,
        uint256 amount_,
        address tokenAddress_
    ) private {
        require(
            receiver_ != address(0),
            "Error: receiver can not be address 0"
        );

        IERC20 betToken = IERC20(tokenAddress_);

        betToken.safeTransfer(receiver_, amount_);
    }

    function withdraw(uint256 amount_, address tokenAddress_) internal {
        IERC20 betToken = IERC20(tokenAddress_);

        betToken.safeTransfer(msg.sender, amount_);
    }
}

contract BettingChinese is ReentrancyGuard, Ownable, BetTokenWrapper {
    string public _name;
    address public _DAO;
    address public _REVENUE;
    uint256 public _DAO_RATE; // 1/10000
    uint256 public _REVENUE_RATE; // 1/10000
    uint256 public _HOST_COMMISSION_RATE; // 1/10000
    uint256 public _NOT_REVEAL_RESULT_PENALTY_RATE = 10000;
    uint256 public _ODD_RATE_DENOMINATOR = 100;
    uint256 public _RATE_DENOMINATOR = 10000;
    uint256 public _MAXIMUM_BET_AMOUNT;
    uint256 public _MINIMUM_BET_AMOUNT;
    uint256 public _REQUEST_ADMIN_CHECK_RATE = 3000;
    uint256 public _REPORT_CUT_OFF_TIME = 1 days;
    uint256 public _MINIMUM_DEADLINE = 1 days;

    enum Result {
        HIDDEN,
        RIGHT,
        WRONG
    }

    enum GameStatus {
        NOT_CREATED,
        OPEN,
        REPORT_PERIOD,
        CLOSE,
        TERMINATE
    }

    struct PlayerBettingInfo {
        uint256 bettingAmount;
        uint256 index;
        bool joined;
        bool claimed;
    }

    struct PlayersManager {
        mapping(address => PlayerBettingInfo) playerBettingInfo;
        address[] players;
        uint256 totalBettingAmount;
    }

    struct PlayerReport {
        address player;
        Result resultReport;
    }

    struct Report {
        uint256 total;
        mapping(address => bool) reported;
        PlayerReport[] playerReports;
    }

    struct Game {
        address creator;
        Result creatorInitResult;
        uint256 counterpartPoolCap;
        uint256 creatorInitAmount;
        Result result;
        mapping(Result => PlayersManager) pools;
        uint256 deadline;
        uint256 reportTimeEnd;
        Report reports;
        GameStatus status;
        address betToken;
        bool penalty;
        uint256 gameMinBetAmount;
        uint256 gameMaxBetAmount;
        uint256 hostOdd;
        uint256 counterpartOdd;
    }

    struct GameInfo {
        address creator;
        Result creatorInitResult;
        uint256 counterpartPoolCap;
        uint256 creatorInitAmount;
        Result result;
        uint256 wrongTotalBettingAmount;
        uint256 rightTotalBettingAmount;
        uint256 deadline;
        uint256 reportTimeEnd;
        uint256 reportCount;
        GameStatus status;
        address betToken;
        bool penalty;
        uint256 gameMinBetAmount;
        uint256 gameMaxBetAmount;
        uint256 hostOdd;
        uint256 counterpartOdd;
    }

    mapping(uint256 => Game) internal games;

    struct WhitelistToken {
        mapping(address => bool) accepted;
        address[] tokens;
    }

    WhitelistToken whitelistTokens;

    modifier onlyGameOwner(uint256 gameContentHash_) {
        require(
            games[gameContentHash_].creator == msg.sender,
            "Error: You are not the game's owner"
        );
        _;
    }

    mapping(address => bool) public operators;

    event CreateGame(
        address indexed gameOwner_,
        uint256 gameId_,
        uint256 deadline_,
        uint256 hostOdd_,
        uint256 counterpartOdd_
    );
    event PlayerBet(
        address indexed player_,
        uint256 gameId_,
        uint256 amount_,
        Result predictResult_
    );
    event FinalizeGame(uint256 gameId_, Result result_);
    event Claim(address indexed player_, uint256 gameId_, uint256 amount_);
    event HostCommission(
        address indexed player_,
        uint256 gameId_,
        uint256 commission_
    );
    event ChargeProtocolFee(
        address indexed player_,
        uint256 gameId_,
        uint256 daoFee_,
        uint256 revenueFee_
    );

    event ReportGame(address indexed player_, uint256 gameId_, Result result_);
    event RequestAdminCheck(uint256 indexed gameId_);
    event TerminateGame(uint256 indexed gameId_);
    event GetRefund(
        uint256 indexed gameId_,
        address indexed player_,
        uint256 refundAmount_
    );

    event AdminResolveReport(uint256 indexed gameId_, Result correctResult_);

    event AllowClaim(uint256 indexed gameId_, Result finalResult_);

    event Penalty(
        uint256 indexed gameId_,
        address gameOwner_,
        uint256 penaltyAmount_
    );

    constructor(
        string memory name_,
        address DAO_,
        address REVENUE_,
        uint256 daoRate_,
        uint256 revenueRate_,
        uint256 hostCommissionRate_,
        uint256 minBet_,
        uint256 maxBet_,
        address[] memory whitelistTokens_
    ) {
        _name = name_;
        _DAO = DAO_;
        _REVENUE = REVENUE_;
        _DAO_RATE = daoRate_;
        _REVENUE_RATE = revenueRate_;
        _HOST_COMMISSION_RATE = hostCommissionRate_;
        _MINIMUM_BET_AMOUNT = minBet_;
        _MAXIMUM_BET_AMOUNT = maxBet_;

        operators[msg.sender] = true;

        uint256 length = whitelistTokens_.length;

        for (uint256 index = 0; index < length; index++) {
            whitelistTokens.accepted[whitelistTokens_[index]] = true;
            whitelistTokens.tokens.push(whitelistTokens_[index]);
        }
    }

    function setWhitelistToken(address tokenAddress_) public onlyOwner {
        require(
            whitelistTokens.accepted[tokenAddress_] == false,
            "Can not remove the un-existed token"
        );

        whitelistTokens.accepted[tokenAddress_] = true;

        whitelistTokens.tokens.push(tokenAddress_);
    }

    function removeTokenFromWhitelist(address tokenAddress_) public onlyOwner {
        require(
            whitelistTokens.accepted[tokenAddress_] == true,
            "Can not remove the un-existed token"
        );
        whitelistTokens.accepted[tokenAddress_] = false;

        uint256 length = whitelistTokens.tokens.length;
        for (uint256 index = 0; index < length; index++) {
            if (whitelistTokens.tokens[index] == tokenAddress_) {
                whitelistTokens.tokens[index] = whitelistTokens.tokens[
                    length - 1
                ];
                whitelistTokens.tokens.pop();
                break;
            }
        }
    }

    function setOperators(
        address[] memory removeAddrs,
        address[] memory newAddrs
    ) public onlyOwner {
        uint256 len = removeAddrs.length;
        for (uint256 index = 0; index < len; index++) {
            operators[removeAddrs[index]] = false;
        }

        len = newAddrs.length;
        for (uint256 index = 0; index < len; index++) {
            operators[newAddrs[index]] = true;
        }
    }

    function setDaoRate(uint256 rate_) public onlyOwner {
        require(
            rate_ <= 10000,
            "Error: can not set rate that is greater than 10000"
        );
        _DAO_RATE = rate_;
    }

    function setRevenueRate(uint256 rate_) public onlyOwner {
        require(
            rate_ <= 10000,
            "Error: can not set rate that is greater than 10000"
        );
        _REVENUE_RATE = rate_;
    }

    function setReportCutOffTime(uint256 time_) public onlyOwner {
        _REPORT_CUT_OFF_TIME = time_;
    }

    function setHostCommissionRate(uint256 rate_) public onlyOwner {
        require(
            rate_ <= 10000,
            "Error: can not set rate that is greater than 10000"
        );
        _HOST_COMMISSION_RATE = rate_;
    }

    function setMinimumBetAmount(uint256 amount_) public onlyOwner {
        _MINIMUM_BET_AMOUNT = amount_;
    }

    function setMaximumBetAmount(uint256 amount_) public onlyOwner {
        _MAXIMUM_BET_AMOUNT = amount_;
    }

    function setMinimumDeadline(uint256 minDeadline_) public onlyOwner {
        _MINIMUM_DEADLINE = minDeadline_;
    }

    function setRequestAdminCheckRate(uint256 requestCheckRate_)
        public
        onlyOwner
    {
        require(
            requestCheckRate_ <= 10000,
            "Error: can not set rate that is greater than 10000"
        );
        _REQUEST_ADMIN_CHECK_RATE = requestCheckRate_;
    }

    function setDaoAddress(address dao_) public onlyOwner {
        require(dao_ != address(0), "Error: DAO can not be address 0x00");
        _DAO = dao_;
    }

    function setRevenueAddress(address revenue_) public onlyOwner {
        require(
            revenue_ != address(0),
            "Error: Revenue can not be address 0x00"
        );
        _REVENUE = revenue_;
    }

    function setPenaltyRate(uint256 rate_) public onlyOwner {
        require(
            rate_ <= 10000,
            "Error: can not set rate that is greater than 10000"
        );
        _NOT_REVEAL_RESULT_PENALTY_RATE = rate_;
    }

    function getTokenWhitelist() public view returns (address[] memory) {
        return whitelistTokens.tokens;
    }

    /**
     * @notice This function is used to get report info of the game
     * @param gameId_ game id
     */
    function getReportList(uint256 gameId_)
        public
        view
        returns (PlayerReport[] memory)
    {
        return games[gameId_].reports.playerReports;
    }

    /**
     * @notice This function is used by player to bet on the game
     * @notice Player have to approve amount_ token before call this function
     * @param gameId_ game id
     * @param initFee_ the fee that host have to bet on this game first to init the game
     * @param predictResult_ predict result is base on Result enum
     * @param deadline_ unixtimestamp that is the deadline of this game
     */

    function createGame(
        uint256 gameId_,
        uint256 initFee_,
        Result predictResult_,
        uint256 deadline_,
        address betToken_,
        uint256 gameMinBetAmount_,
        uint256 hostOdd_,
        uint256 counterpartOdd_
    ) public {
        require(
            whitelistTokens.accepted[betToken_] == true,
            "Error: your token isn't in whitelist"
        );

        require(
            games[gameId_].status == GameStatus.NOT_CREATED,
            "Error: Your game was created!"
        );
        require(
            hostOdd_ > 0 && counterpartOdd_ > 0,
            "Error: odd is not greater than 0"
        );
        require(
            gameMinBetAmount_ >= _MINIMUM_BET_AMOUNT &&
                gameMinBetAmount_ <= _MAXIMUM_BET_AMOUNT,
            "Error: gameMinBetAmount_ is not greater than minimum bet and lower than Maximum bet"
        );

        require(
            initFee_ >= (_MAXIMUM_BET_AMOUNT * hostOdd_) / counterpartOdd_,
            "Error: initFee is not greater than  (_MAXIMUM_BET_AMOUNT * hostOdd_) / counterpartOdd_"
        );

        require(
            (deadline_ - block.timestamp) >= _MINIMUM_DEADLINE,
            "Error: Your betting period is smaller than _MINIMUM_DEADLINE!"
        );

        games[gameId_].status = GameStatus.OPEN;
        //Set deadline
        games[gameId_].deadline = deadline_;

        games[gameId_].creatorInitResult = predictResult_;

        games[gameId_].creator = msg.sender;

        games[gameId_].betToken = betToken_;

        games[gameId_].gameMinBetAmount = gameMinBetAmount_;

        games[gameId_].creatorInitAmount = initFee_;

        games[gameId_].hostOdd = hostOdd_;
        games[gameId_].counterpartOdd = counterpartOdd_;
        games[gameId_].counterpartPoolCap =
            (initFee_ * counterpartOdd_) /
            hostOdd_;

        emit CreateGame(
            msg.sender,
            gameId_,
            deadline_,
            hostOdd_,
            counterpartOdd_
        );
        //init betting by host
        bet(gameId_, predictResult_, initFee_);
    }

    /**
     * @notice This function is used by player to bet on the game
     * @notice Player have to approve amount_ token before call this function
     * @param gameId_ game id
     * @param predictResult_ predict result is base on Result enum
     * @param amount_ amount that player bet on game
     */
    function bet(
        uint256 gameId_,
        Result predictResult_,
        uint256 amount_
    ) public nonReentrant {
        require(
            games[gameId_].status == GameStatus.OPEN,
            "Error: Your game is not open!"
        );

        require(
            amount_ >= games[gameId_].gameMinBetAmount,
            "Error: Please betting with an amount token that is greater than game min bet amount!"
        );

        require(
            block.timestamp < games[gameId_].deadline,
            "Error: your game is timeout!"
        );

        require(predictResult_ != Result.HIDDEN, "Error: Result can not be 0");

        if (predictResult_ != games[gameId_].creatorInitResult) {
            require(
                getPoolRemainOfCounterpart(gameId_) >= amount_,
                "Error: Your amount is greater than remain of counterpart's pool"
            );
        }

        super.betToContract(amount_, msg.sender, games[gameId_].betToken);

        //update pool
        if (
            games[gameId_]
                .pools[predictResult_]
                .playerBettingInfo[msg.sender]
                .joined == false
        ) {
            games[gameId_]
                .pools[predictResult_]
                .playerBettingInfo[msg.sender]
                .joined = true;

            games[gameId_]
                .pools[predictResult_]
                .playerBettingInfo[msg.sender]
                .index = games[gameId_].pools[predictResult_].players.length;

            games[gameId_].pools[predictResult_].players.push(msg.sender);
        }

        games[gameId_]
            .pools[predictResult_]
            .playerBettingInfo[msg.sender]
            .bettingAmount += amount_;

        //Check if game creator keeps stake in host pool
        if (
            predictResult_ == games[gameId_].creatorInitResult &&
            msg.sender == games[gameId_].creator
        ) {
            require(
                games[gameId_]
                    .pools[predictResult_]
                    .playerBettingInfo[msg.sender]
                    .bettingAmount -
                    games[gameId_].creatorInitAmount <=
                    _MAXIMUM_BET_AMOUNT,
                "Error: your total bet on this result is greater than MAX BET AMOUNT"
            );
        } else {
            require(
                games[gameId_]
                    .pools[predictResult_]
                    .playerBettingInfo[msg.sender]
                    .bettingAmount <= _MAXIMUM_BET_AMOUNT,
                "Error: your total bet on this result is greater than MAX BET AMOUNT"
            );
        }

        games[gameId_].pools[predictResult_].totalBettingAmount += amount_;

        //update counterpart pool cap when player bet on creator's side
        if (predictResult_ == games[gameId_].creatorInitResult) {
            // counterpartPoolCap = odd * totalBettingAmountOfHostSide
            games[gameId_].counterpartPoolCap =
                (games[gameId_]
                    .pools[games[gameId_].creatorInitResult]
                    .totalBettingAmount * games[gameId_].counterpartOdd) /
                games[gameId_].hostOdd;
        }

        emit PlayerBet(msg.sender, gameId_, amount_, predictResult_);
    }

    /**
     * @notice This function get game counterpart
     * @param gameId_ game id
     */
    function getPoolRemainOfCounterpart(uint256 gameId_)
        public
        view
        returns (uint256)
    {
        if (games[gameId_].creatorInitResult == Result.RIGHT) {
            return
                games[gameId_].counterpartPoolCap -
                games[gameId_].pools[Result.WRONG].totalBettingAmount;
        } else {
            return
                games[gameId_].counterpartPoolCap -
                games[gameId_].pools[Result.RIGHT].totalBettingAmount;
        }
    }

    /**
     * @notice This function get game info
     * @param gameId_ game id
     */
    function getGame(uint256 gameId_) public view returns (GameInfo memory) {
        GameInfo memory gameInfo;

        gameInfo.creator = games[gameId_].creator;
        gameInfo.result = games[gameId_].result;
        gameInfo.counterpartPoolCap = games[gameId_].counterpartPoolCap;
        gameInfo.creatorInitAmount = games[gameId_].creatorInitAmount;
        gameInfo.wrongTotalBettingAmount = games[gameId_]
            .pools[Result.WRONG]
            .totalBettingAmount;
        gameInfo.rightTotalBettingAmount = games[gameId_]
            .pools[Result.RIGHT]
            .totalBettingAmount;
        gameInfo.status = games[gameId_].status;
        gameInfo.deadline = games[gameId_].deadline;
        gameInfo.reportCount = games[gameId_].reports.total;
        gameInfo.betToken = games[gameId_].betToken;
        gameInfo.reportTimeEnd = games[gameId_].reportTimeEnd;
        gameInfo.penalty = games[gameId_].penalty;
        gameInfo.gameMinBetAmount = games[gameId_].gameMinBetAmount;

        return gameInfo;
    }

    /**
     * @notice This function list players address that bet in right by game id
     * @param gameId_ game id
     */

    function getRightPlayers(uint256 gameId_)
        public
        view
        returns (address[] memory)
    {
        return games[gameId_].pools[Result.RIGHT].players;
    }

    /**
     * @notice This function list players address that bet in wrong by game id
     * @param gameId_ game id
     */
    function getWrongPlayers(uint256 gameId_)
        public
        view
        returns (address[] memory)
    {
        return games[gameId_].pools[Result.WRONG].players;
    }

    /**
     * @notice This function gets player info by game id
     * @param gameId_ game id
     */
    function getPlayerInfo(uint256 gameId_)
        public
        view
        returns (PlayerBettingInfo memory right, PlayerBettingInfo memory wrong)
    {
        right = games[gameId_].pools[Result.RIGHT].playerBettingInfo[
            msg.sender
        ];
        wrong = games[gameId_].pools[Result.WRONG].playerBettingInfo[
            msg.sender
        ];
        return (right, wrong);
    }

    /**
     * @notice This function is used to get player betting amount
     * @param player_ player address
     * @param gameId_ game id
     */

    function betBalanceOf(address player_, uint256 gameId_)
        public
        view
        returns (uint256 right, uint256 wrong)
    {
        return (
            games[gameId_]
                .pools[Result.RIGHT]
                .playerBettingInfo[player_]
                .bettingAmount,
            games[gameId_]
                .pools[Result.WRONG]
                .playerBettingInfo[player_]
                .bettingAmount
        );
    }

    /**
     * @notice This function is used by admin who has joined the game to finalize the game with result
     * @param gameId_ game id
     * @param result_ game result
     */

    function finalizeGame(uint256 gameId_, Result result_) public nonReentrant {
        require(
            operators[msg.sender] || games[gameId_].creator == msg.sender,
            "Error: you are not game's host or admin"
        );

        require(
            games[gameId_].status == GameStatus.OPEN,
            "Error: Your game is not open!"
        );

        require(
            games[gameId_].deadline < block.timestamp,
            "Error: Your game doesn't reach the deadline!"
        );

        require(result_ != Result.HIDDEN, "Error: Result can not be 0");

        //Terminate the game when there isn't any people bet on counterpart
        if (
            games[gameId_].pools[Result.RIGHT].totalBettingAmount +
                games[gameId_].pools[Result.WRONG].totalBettingAmount ==
            games[gameId_]
                .pools[games[gameId_].creatorInitResult]
                .totalBettingAmount
        ) {
            games[gameId_].status = GameStatus.TERMINATE;
            emit TerminateGame(gameId_);
            return;
        }

        games[gameId_].status = GameStatus.REPORT_PERIOD;
        games[gameId_].reportTimeEnd = block.timestamp + _REPORT_CUT_OFF_TIME;

        games[gameId_].result = result_;

        emit FinalizeGame(gameId_, result_);

        if (
            games[gameId_].creator != msg.sender
        ) // Penalize if host doesn't reveal the result
        {
            // Mark that host of this game was be penalized
            games[gameId_].penalty = true;
            //allow claim

            games[gameId_].status = GameStatus.CLOSE;

            emit AllowClaim(gameId_, games[gameId_].result);
        }
    }

    function penalty(uint256 gameId_) private returns (uint256) {
        address host = games[gameId_].creator;
        uint256 totalPenalty;
        //calculate penalty

        totalPenalty =
            (games[gameId_]
                .pools[games[gameId_].creatorInitResult]
                .playerBettingInfo[host]
                .bettingAmount * _NOT_REVEAL_RESULT_PENALTY_RATE) /
            _RATE_DENOMINATOR;

        if (totalPenalty != 0) {
            // transfer to DAO
            super.transferProtocolFee(
                _DAO,
                totalPenalty,
                _REVENUE,
                0,
                games[gameId_].betToken
            );
            emit Penalty(gameId_, host, totalPenalty);
        }

        return totalPenalty;
    }

    /**
     * @notice This function is used by player who has joined the game to report game result
     * @param gameId_ game id
     */

    function reportGame(uint256 gameId_, Result result_) public {
        require(result_ != Result.HIDDEN, "Error: Result can not be 0");

        require(
            games[gameId_].creator != msg.sender,
            "Error: Host can not report game"
        );

        require(
            games[gameId_].status == GameStatus.REPORT_PERIOD,
            "Error: your game is not in report period!"
        );

        require(
            (games[gameId_]
                .pools[Result.RIGHT]
                .playerBettingInfo[msg.sender]
                .joined == true) ||
                (games[gameId_]
                    .pools[Result.WRONG]
                    .playerBettingInfo[msg.sender]
                    .joined == true),
            "Error: you did not join this game!"
        );

        require(
            games[gameId_].reports.reported[msg.sender] == false,
            "Error: you have reported!"
        );

        games[gameId_].reports.reported[msg.sender] = true;

        //if still in report period
        if (games[gameId_].reportTimeEnd > block.timestamp) {
            games[gameId_].reports.total += 1;

            //store report result
            games[gameId_].reports.playerReports.push(
                PlayerReport(msg.sender, result_)
            );

            emit ReportGame(msg.sender, gameId_, result_);

            uint256 totalPlayer = games[gameId_]
                .pools[Result.WRONG]
                .players
                .length + games[gameId_].pools[Result.RIGHT].players.length;

            if (
                (games[gameId_].reports.total * _RATE_DENOMINATOR) /
                    totalPlayer >=
                _REQUEST_ADMIN_CHECK_RATE
            ) {
                emit RequestAdminCheck(gameId_);
            }
        }
        //else, the report time is end but game's status is still REPORT_PERIOD => winner can not claim their reward => request admin check
        else {
            emit ReportGame(msg.sender, gameId_, result_);
            emit RequestAdminCheck(gameId_);
        }
    }

    /**
     * @notice This function is used by admin to resolve the report
     * @param gameId_ game id
     * @param newResult_ the correct result
     */
    function adminResolveReport(uint256 gameId_, Result newResult_) public {
        require(operators[msg.sender], "Error: you are not admin");

        require(
            games[gameId_].status == GameStatus.REPORT_PERIOD,
            "Error: your game is not in report period!"
        );

        require(newResult_ != Result.HIDDEN, "Error: Result can not be 0");

        games[gameId_].status = GameStatus.CLOSE;

        games[gameId_].result = newResult_;

        emit AdminResolveReport(gameId_, newResult_);
    }

    /**
     * @notice This function is used by admin to allow player claim reward
     * @param gameId_ game id
     */

    function allowClaim(uint256 gameId_) public {
        require(operators[msg.sender], "Error: you are not admin");

        require(
            games[gameId_].status == GameStatus.REPORT_PERIOD,
            "Error: your game is not in report period!"
        );

        require(
            games[gameId_].reportTimeEnd < block.timestamp,
            "Error: Please wait because your game is in report time!"
        );

        games[gameId_].status = GameStatus.CLOSE;

        emit AllowClaim(gameId_, games[gameId_].result);
    }

    /**
     * @notice calculates protocol fee and host commission
     * @param claimAmount_ amount will be claimed
     */
    function computeProtocolFee(uint256 claimAmount_)
        internal
        view
        returns (
            uint256 DAOFee,
            uint256 revenueFee,
            uint256 hostCommission
        )
    {
        DAOFee = (claimAmount_ * _DAO_RATE) / _RATE_DENOMINATOR;
        revenueFee = (claimAmount_ * _REVENUE_RATE) / _RATE_DENOMINATOR;
        hostCommission =
            (claimAmount_ * _HOST_COMMISSION_RATE) /
            _RATE_DENOMINATOR;

        // return (DAOFee, revenueFee, hostCommission);
    }

    /**
     * @notice player claim reward by game
     * @param gameId_ game id that player will claim
     */

    function claim(uint256 gameId_) public nonReentrant {
        require(
            games[gameId_].status == GameStatus.CLOSE,
            "Error:Game result is processing"
        );

        // uint256 award;
        uint256 totalLoserBetting;
        uint256 totalWinnerBetting;
        uint256 winnerbettingAmount;
        uint256 claimAmount;
        uint256 totalDAOFee;
        uint256 totalRevenueFee;

        require(
            games[gameId_]
                .pools[Result.RIGHT]
                .playerBettingInfo[msg.sender]
                .joined ==
                true ||
                games[gameId_]
                    .pools[Result.WRONG]
                    .playerBettingInfo[msg.sender]
                    .joined ==
                true,
            "Error: you didn't join this game!"
        );

        require(
            games[gameId_]
                .pools[Result.RIGHT]
                .playerBettingInfo[msg.sender]
                .claimed ==
                false &&
                games[gameId_]
                    .pools[Result.WRONG]
                    .playerBettingInfo[msg.sender]
                    .claimed ==
                false,
            "Error: you have claimed on this game!"
        );

        //mark claimed
        games[gameId_]
            .pools[Result.RIGHT]
            .playerBettingInfo[msg.sender]
            .claimed = true;

        games[gameId_]
            .pools[Result.WRONG]
            .playerBettingInfo[msg.sender]
            .claimed = true;

        totalWinnerBetting = games[gameId_]
            .pools[games[gameId_].result]
            .totalBettingAmount;

        totalLoserBetting =
            games[gameId_].pools[Result.RIGHT].totalBettingAmount +
            games[gameId_].pools[Result.WRONG].totalBettingAmount -
            totalWinnerBetting;

        winnerbettingAmount = games[gameId_]
            .pools[games[gameId_].result]
            .playerBettingInfo[msg.sender]
            .bettingAmount;

        //winner award and fee calculate
        if (
            games[gameId_]
                .pools[games[gameId_].result]
                .playerBettingInfo[msg.sender]
                .joined == true
        ) {
            (
                uint256 winnerAward,
                uint256 winnerDAOFee,
                uint256 winnerRevenueFee,
                uint256 hostCommission
            ) = winnerClaimCalculate(
                    gameId_,
                    totalWinnerBetting,
                    totalLoserBetting,
                    winnerbettingAmount
                );

            {
                //transfer host commission
                super.transferHostCommission(
                    games[gameId_].creator,
                    hostCommission,
                    games[gameId_].betToken
                );
                emit HostCommission(msg.sender, gameId_, hostCommission);
            }

            {
                uint256 winnerTotalFee = winnerDAOFee +
                    winnerRevenueFee +
                    hostCommission;
                //DAO fee
                totalDAOFee += winnerDAOFee;
                //revenue fee
                totalRevenueFee += winnerRevenueFee;
                //total claim amount
                claimAmount +=
                    winnerbettingAmount +
                    winnerAward -
                    winnerTotalFee;
            }
        }

        //calculate host pool remain claim in case creator side lose
        if (
            games[gameId_]
                .pools[games[gameId_].creatorInitResult]
                .playerBettingInfo[msg.sender]
                .joined ==
            true &&
            games[gameId_].creatorInitResult != games[gameId_].result
        ) {
            uint256 refund = creatorPoolLoserRemainCalculator(
                gameId_,
                totalWinnerBetting,
                totalLoserBetting
            );

            if (refund > 0) {
                claimAmount += refund;
                emit GetRefund(gameId_, msg.sender, refund);
            }
        }

        //calculate host penalty amount
        if (
            msg.sender == games[gameId_].creator && //game creator claim
            games[gameId_].creatorInitResult == games[gameId_].result && //host pool is winner
            games[gameId_].penalty //host get penalty
        ) {
            uint256 penaltyAmount = penalty(gameId_);
            claimAmount -= penaltyAmount;
        }
        // transfer protocol fee
        super.transferProtocolFee(
            _DAO,
            totalDAOFee,
            _REVENUE,
            totalRevenueFee,
            games[gameId_].betToken
        );

        // //claim
        super.withdraw(claimAmount, games[gameId_].betToken);

        emit ChargeProtocolFee(
            msg.sender,
            gameId_,
            totalDAOFee,
            totalRevenueFee
        );
        emit Claim(msg.sender, gameId_, claimAmount);
    }

    function winnerClaimCalculate(
        uint256 gameId_,
        uint256 totalWinnerBetting_,
        uint256 totalLoserBetting_,
        uint256 winnerbettingAmount_
    )
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 award;
        uint256 DAOFee;
        uint256 revenueFee;
        uint256 hostCommission;
        //calculate winner award
        //game creator win case
        if (games[gameId_].result == games[gameId_].creatorInitResult) {
            award =
                (totalLoserBetting_ * winnerbettingAmount_) /
                totalWinnerBetting_;
        } else {
            //counterpart win case
            award =
                (winnerbettingAmount_ * games[gameId_].hostOdd) /
                games[gameId_].counterpartOdd;
        }

        (DAOFee, revenueFee, hostCommission) = computeProtocolFee(award);

        return (award, DAOFee, revenueFee, hostCommission);
    }

    function creatorPoolLoserRemainCalculator(
        uint256 gameId_,
        uint256 totalWinnerBetting_,
        uint256 totalLoserBetting_
    ) private view returns (uint256 creatorPoolLoserRemainClaimAmount) {
        uint256 loserBettingAmount = games[gameId_]
            .pools[games[gameId_].creatorInitResult]
            .playerBettingInfo[msg.sender]
            .bettingAmount;

        uint256 totalCreatorPoolLoserRemain = totalLoserBetting_ -
            (totalWinnerBetting_ * games[gameId_].hostOdd) /
            games[gameId_].counterpartOdd;

        creatorPoolLoserRemainClaimAmount =
            (totalCreatorPoolLoserRemain * loserBettingAmount) /
            totalLoserBetting_;
    }

    /**
     * @notice player claims all reward by list of game ids
     * @param gameIds_ list of game ids that player will claim
     */
    function claimAll(uint256[] memory gameIds_) public {
        uint256 length = gameIds_.length;

        for (uint256 index = 0; index < length; index++) {
            claim(gameIds_[index]);
        }
    }

    /**
     * @notice player claims all refund of terminate games by list of game ids
     * @param gameIds_ list of game ids that player will claim
     */
    function claimAllRefundTeminateGames(uint256[] memory gameIds_) public {
        uint256 length = gameIds_.length;

        for (uint256 index = 0; index < length; index++) {
            getRefundTerminateGame(gameIds_[index]);
        }
    }

    /**
     * @notice admin terminates the game before this game is closed
     * @param gameId_ game id that admin will terminate
     */

    function terminateGame(uint256 gameId_) public {
        require(operators[msg.sender], "Error: you are not admin");

        require(
            games[gameId_].status != GameStatus.CLOSE,
            "Error: you can not terminate a closed game"
        );

        games[gameId_].status = GameStatus.TERMINATE;
        emit TerminateGame(gameId_);
    }

    /**
     * @notice player gets refund from terminated game
     * @param gameId_ game id that player will get refund
     */
    function getRefundTerminateGame(uint256 gameId_) public {
        require(
            games[gameId_].status == GameStatus.TERMINATE,
            "Error: your game is not terminated!"
        );

        require(
            games[gameId_]
                .pools[Result.RIGHT]
                .playerBettingInfo[msg.sender]
                .claimed ==
                false &&
                games[gameId_]
                    .pools[Result.WRONG]
                    .playerBettingInfo[msg.sender]
                    .claimed ==
                false,
            "Error: You have gotten the refund on this game!"
        );

        games[gameId_]
            .pools[Result.RIGHT]
            .playerBettingInfo[msg.sender]
            .claimed = true;

        games[gameId_]
            .pools[Result.WRONG]
            .playerBettingInfo[msg.sender]
            .claimed = true;

        uint256 refund = games[gameId_]
            .pools[Result.RIGHT]
            .playerBettingInfo[msg.sender]
            .bettingAmount +
            games[gameId_]
                .pools[Result.WRONG]
                .playerBettingInfo[msg.sender]
                .bettingAmount;

        super.withdraw(refund, games[gameId_].betToken);

        emit GetRefund(gameId_, msg.sender, refund);
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

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