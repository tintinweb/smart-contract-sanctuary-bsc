pragma solidity =0.8.7;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "./ERC20.sol";
import "./ChainlinkClient.sol";

contract ffwc22lotto_router is ChainlinkClient {
    //chainlink PART
    using Chainlink for Chainlink.Request;
    event RequestFulfilledString(bytes32 indexed requestId, string response);
    event RequestFulfilledUint256(bytes32 indexed requestId, uint256 response);
    event RequestFulfilledBytes(bytes32 indexed requestId, bytes response);

    address public _owner;
    address public _announcer;
    address public _USD;

    //for marking if the result is announced
    bool public _isAnnounced;
    uint8 private _teamLength = 32;

    //percents
    uint8 private _superChampionPrizePercent;
    uint8 private _championPrizePercent;
    uint8 private _runnerupPrizePercent;
    uint8 private _devPercent;
    uint8 private _announcerPercent;

    //start sale time
    uint256 public _startedSaleTimestamp;
    //deadline sale time
    uint32 private _closedSaleTimestamp;

    //start ticket price
    uint256 private _initTicketPrice;
    //start ticket price
    uint256 private _ticketPriceRisePerDay;

    //prize pool
    uint256 private _prizePool;

    //reward that give to all holders // normally all in prizePool - dev part
    uint256 private _rewardAmount;

    //ticket_index => ticket's number (that is sold)
    mapping(uint32 => uint32) private _ticketSoldList;
    //recent length of _ticketSoldList
    uint32 private _ticketSoldLength;

    //ticket's number => status (true = sold,false = available)
    mapping(uint32 => bool) private _isTicketSold;
    //ticket's number => status (true = claimed, false = unclaimed)
    mapping(uint32 => bool) private _isTicketClaimed;

    //holder's address => ticket_index => number
    mapping(address => mapping(uint32 => uint32)) private _ticketHoldingList;
    //recent length of _ticketHoldingList[ holder's address ]
    mapping(address => uint32) private _ticketHoldingLength;

    //to count how many holder in each nation_id
    //nation_id to #ticket
    mapping(uint8 => uint32) private _nationIdTicketHolderLength;

    mapping(string => uint8) public _nationCodeToNationId;

    //matchId of the final match
    string private _SEASONID;
    //team name in final
    string private _HOMENATIONCODE;
    bytes32 private _HOMENATIONCODEReqId;
    string private _AWAYNATIONCODE;
    bytes32 private _AWAYNATIONCODEReqId;
    //team #goal in final of sportdataapi
    uint8 private _HOMEGOAL = 255; // to check if #goal is fulfilled in case #goal is 0
    bytes32 private _HOMEGOALReqId;
    uint8 private _AWAYGOAL = 255; // to check if #goal is fulfilled in case #goal is 0
    bytes32 private _AWAYGOALReqId;
    // AWAY starting XI
    uint8 private _SCORENO1;
    bytes32 private _SCORENO1ReqId;
    uint8 private _SCORENO2;
    bytes32 private _SCORENO2ReqId;
    uint8 private _SCORENO3;
    bytes32 private _SCORENO3ReqId;
    uint8 private _SCORENO4;
    bytes32 private _SCORENO4ReqId;


    //number that won super prize
    uint16 private _superChampionCodeWC22;
    //nation_id that won the prize
    uint8 private _championNationIdWC22;
    uint8 private _runnerupNationIdWC22;
    uint32 private _lastFulFillTimestampWC22;

    //old winning prize (WC2018)
    uint16 private _superChampionCodeWC18;
    uint8 private _championNationIdWC18;
    uint8 private _runnerupNationIdWC18;
    uint32 private _lastFulFillTimestampWC18;

    //sportapi MatchId
    // string WC22FinalMatchID = "429770"; 
    string WC22SeasonID = "3072"; 
    string WC22DateFrom = "2022-12-18"; 
    // string WC18FinalMatchID = "129920"; 
    string WC18SeasonID = "1193"; 
    string WC18DateFrom = "2018-07-15"; 
    
    //chainlink jobId for HTTP GET
    bytes32 jobIdString = "7d80a6386ef543a3abb52817f6707e3b";
    bytes32 jobIdUint256 = "ca98366cc7314957b8c012c72f05aeeb";
    bytes32 jobIdBytes = "7da2702f37fd48e5b1b9a5715e3509b6";
    //chainlink fee per request = 0.1 LINK
    uint256 LINK_fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)


    modifier ensure(uint32 deadline) {
        require(deadline >= block.timestamp, "TicketRouter: EXPIRED");
        _;
    }
    modifier isOwner() {
        require(msg.sender == _owner, "TicketRouter: AUTHORIZATION_FAILED");
        _;
    }

    /**
     * @notice Initialize the link token and target oracle
     *
     * Goerli Testnet details:
     * Link Token: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Oracle: 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7 (Chainlink DevRel)
     *
     */
    /**
     * @notice Initialize the link token and target oracle
     *
     * Binance Testnet details:
     * Link Token: 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06
     * Oracle: 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7 (Chainlink DevRel)
     *
     */
    /**
     * @notice Initialize the link token and target oracle
     *
     * Mumbai Testnet details:
     * Link Token: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Oracle: 0x40193c8518BB267228Fc409a613bDbD8eC5a97b3 (Chainlink DevRel)
     *
     */
    constructor() {
        _owner = msg.sender;
        //setup currency token for ticket purchasing
        _USD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;

        //setup Chainlick oracle for pulling result
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0xCC79157eb46F5624204f47AB42b3906cAA40eaB7);

        //setup ticket price
        _initTicketPrice = 2000000000000000000; //2 USD / Per ticket
        _ticketPriceRisePerDay = 1000000000000000000; // rise 1 USD / Per day

        //setup percents
        _superChampionPrizePercent = 20;
        _championPrizePercent = 60;
        _runnerupPrizePercent = 15;
        _devPercent = 4;
        _announcerPercent = 1;

        //set sale period
        _startedSaleTimestamp = block.timestamp; // deploy time
        _closedSaleTimestamp = 1671375600; // FIFA World Cup 2022 Final start

        //setup nation code to ID (Order by string as frontend)
        _nationCodeToNationId["ARG"] = 0;
        _nationCodeToNationId["AUS"] = 1;
        _nationCodeToNationId["BEL"] = 2;
        _nationCodeToNationId["BRA"] = 3;
        _nationCodeToNationId["CMR"] = 4;
        _nationCodeToNationId["CAN"] = 5;
        _nationCodeToNationId["CRC"] = 6;
        _nationCodeToNationId["CRO"] = 7;
        _nationCodeToNationId["DEN"] = 8;
        _nationCodeToNationId["ECU"] = 9;
        _nationCodeToNationId["ENG"] = 10;
        _nationCodeToNationId["FRA"] = 11;
        _nationCodeToNationId["GER"] = 12;
        _nationCodeToNationId["GHA"] = 13;
        _nationCodeToNationId["IRN"] = 14;
        _nationCodeToNationId["JPN"] = 15;
        _nationCodeToNationId["MEX"] = 16;
        _nationCodeToNationId["MAR"] = 17;
        _nationCodeToNationId["NED"] = 18;
        _nationCodeToNationId["POL"] = 19;
        _nationCodeToNationId["POR"] = 20;
        _nationCodeToNationId["QAT"] = 21;
        _nationCodeToNationId["KSA"] = 22;
        _nationCodeToNationId["SEN"] = 23;
        _nationCodeToNationId["SRB"] = 24;
        _nationCodeToNationId["KOR"] = 25;
        _nationCodeToNationId["ESP"] = 26;
        _nationCodeToNationId["SUI"] = 27;
        _nationCodeToNationId["TUN"] = 28;
        _nationCodeToNationId["USA"] = 29;
        _nationCodeToNationId["URU"] = 30;
        _nationCodeToNationId["WAL"] = 31;
    }

    function numberToNationId(uint32 number)
        private
        view
        returns (uint8 nationId)
    {
        return uint8(number % _teamLength);
    }

    function numberToTicketCode(uint32 number)
        private
        view
        returns (uint16 code)
    {
        return uint16(number / _teamLength);
    }

    function getIfOnSale() public view virtual returns (bool isOnSale) {
        return (block.timestamp < _closedSaleTimestamp);
    }

    function getPriceNow() public view virtual returns (uint256 price) {
        uint256 passedDays = (block.timestamp - _startedSaleTimestamp) / 86400;
        if(passedDays < 3){
            return _initTicketPrice;
        }
        return _initTicketPrice + (passedDays * _ticketPriceRisePerDay);
    }

    function getPriceTomorrow()
        public
        view
        virtual
        returns (uint256 price)
    {
        uint256 passedDays = 1 + ((block.timestamp - _startedSaleTimestamp) / 86400);
        if(passedDays < 3){
            return _initTicketPrice;
        }
        return _initTicketPrice + (passedDays * _ticketPriceRisePerDay);
    }

    function getSaleDeadline()
        public
        view
        virtual
        returns (uint32 saleDeadline)
    {
        return (_closedSaleTimestamp);
    }

    function getHolderLengthByNationId(uint8 nationId)
        public
        view
        virtual
        returns (uint32 holderLength)
    {
        return (_nationIdTicketHolderLength[nationId]);
    }

    function getAllTicketsByHolder(address holder)
        public
        view
        virtual
        returns (uint32[] memory number)
    {
        number = new uint32[](_ticketHoldingLength[holder]);
        for (uint32 i = 0; i < _ticketHoldingLength[holder]; i++) {
            number[i] = _ticketHoldingList[holder][i];
        }
        return (number);
    }

    function getAllSoldTickets()
        public
        view
        virtual
        returns (uint32[] memory number)
    {
        number = new uint32[](_ticketSoldLength);
        for (uint32 i = 0; i < _ticketSoldLength; i++) {
            number[i] = _ticketSoldList[i];
        }
        return (number);
    }

    function getPrizePool() public view virtual returns (uint256 prizePool) {
        return (_prizePool);
    }

    function getSharePercents()
        public
        view
        virtual
        returns (
            uint8 superChampionPrizePercent,
            uint8 championPrizePercent,
            uint8 runnerupPrizePercent,
            uint8 devPercent,
            uint8 announcerPercent
        )
    {
        return (
            _superChampionPrizePercent,
            _championPrizePercent,
            _runnerupPrizePercent,
            _devPercent,
            _announcerPercent
        );
    }

    function getAllClaimableAmountByHolder(address holder)
        public
        view
        virtual
        returns (uint256 claimable)
    {
        if (!_isAnnounced) {
            return 0;
        }
        claimable = 0;
        for (uint32 i = 0; i < _ticketHoldingLength[holder]; i++) {
            uint32 number = _ticketHoldingList[holder][i];
            //check if this ticket is claimed
            if (!_isTicketClaimed[number]) {
                claimable += getClaimableAmountByTicket(number);
            }
        }
    }

    function getClaimableAmountByTicket(uint32 number)
        public
        view
        virtual
        returns (uint256 claimable)
    {
        if (!_isAnnounced) {
            return 0;
        }
        //check if this ticket is claimed
        if (_isTicketClaimed[number]) {
            return 0;
        }
        claimable = 0;
        uint8 nationId = numberToNationId(number);
        //check if winning Super Champion Prize
        {
            uint16 ticketCode = numberToTicketCode(number);
            if (
                nationId == _championNationIdWC22 &&
                ticketCode == _superChampionCodeWC22
            ) {
                //super champion win xx% of Pool
                claimable += (_prizePool * (_superChampionPrizePercent)) / (100);
            }
        }
        //check if winning Other Prizes
        {
            uint256 wholePrize = 0;
            if (nationId == _championNationIdWC22) {
                //champion prize win yy% of Pool
                wholePrize = (_prizePool * (_championPrizePercent)) / (100);
            } else if (nationId == _runnerupNationIdWC22) {
                //runnerup prize win zz% of Pool
                wholePrize = (_prizePool * (_runnerupPrizePercent)) / (100);
            }
            //add reward ( wholePrize of the share / number of that nation's ticket holder)
            claimable += wholePrize / (getHolderLengthByNationId(nationId));
        }
        return claimable;
    }

    function buyTicket(
        uint32 number,
        uint256 ticketPrice,
        uint32 deadline
    ) external virtual ensure(deadline) returns (bool success) {
        require(
            !_isAnnounced,
            "TicketRouter: TICKETS_ARE_NOT_ON_SALE_AFTER_ANNOUNCING"
        );
        require(
            !_isTicketSold[number],
            "TicketRouter: THIS_TICKET_IS_SOLD_OUT"
        );
        //cannot buy ticket after deadline
        require(getIfOnSale(), "TicketRouter: TICKET_SALE_IS_CLOSED");
        //cannot buy ticket with price lower than getTicketPriceNow()
        require(
            ticketPrice >= getPriceNow(),
            "TicketRouter: OFFERED_TICKET_PRICE_IS_TOO_LOW"
        );

        //transfer token to this contract
        IERC20(_USD).transferFrom(msg.sender, address(this), ticketPrice);

        //add ticket to this owner
        //check how many tickets this owner has
        uint32 curLength = _ticketHoldingLength[msg.sender];
        //save ticket data for this owner
        _ticketHoldingList[msg.sender][curLength] = number;
        _ticketHoldingLength[msg.sender] = curLength + 1;

        //add this ticket to the sold ticket list
        uint32 curSoldLength = _ticketSoldLength;
        _ticketSoldList[curSoldLength] = number;
        _ticketSoldLength = curSoldLength + 1;

        //increase #holders of this nation_id
        _nationIdTicketHolderLength[numberToNationId(number)] += 1;

        //increase _prizePool
        _prizePool += ticketPrice;

        return true;
    }

    function claimTicket(uint32 number, uint32 deadline)
        external
        virtual
        ensure(deadline)
        returns (uint256 amounts)
    {
        require(
            !_isTicketClaimed[number],
            "TicketRouter: THIS_TICKET_IS_CLAIMED"
        );

        amounts = getClaimableAmountByTicket(number);
        //transfer reward to the ticket holder
        IERC20(_USD).transfer(msg.sender, amounts);
        //mark that this ticket is claimed
        _isTicketClaimed[number] = true;

        return amounts;
    }

    function claimAllTickets(uint32 deadline)
        external
        virtual
        ensure(deadline)
        returns (uint256 amounts)
    {
        amounts = 0;
        for (uint32 i = 0; i < _ticketHoldingLength[msg.sender]; i++) {
            uint32 number = _ticketHoldingList[msg.sender][i];
            //check if this ticket is claimed
            if (!_isTicketClaimed[number]) {
                amounts += getClaimableAmountByTicket(number);
                //mark that this ticket is claimed
                _isTicketClaimed[number] = true;
            }
        }
        //transfer reward to the ticket holder
        IERC20(_USD).transfer(msg.sender, amounts);

        return amounts;
    }

    function devClaimReward(uint32 deadline)
        external
        virtual
        ensure(deadline)
        isOwner
        returns (uint256 amounts)
    {
        require(
            _isAnnounced,
            "TicketRouter: DEV_CAN_CLAIM_ONLY_AFTER_ANNOUNCING"
        );
        require(_devPercent > 0, "TicketRouter: NO_REWARD_FOR_DEV");

        amounts = (_prizePool * _devPercent) / (100);

        //transfer the reward to the dev
        IERC20(_USD).transfer(_owner, amounts);

        return amounts;
    }

    function getWC22()
        public
        view
        virtual
        returns (
            uint32 lastFulFillTimestampWC22,
            uint16 superChampionCodeWC22,
            uint8 championNationIdWC22,
            uint8 runnerupNationIdWC22
        )
    {
        require( _isAnnounced, "TicketRouter: THE_RESULT_IS_NOT_ANNOUCED_YET");
        return ( _lastFulFillTimestampWC22, _superChampionCodeWC22, _championNationIdWC22, _runnerupNationIdWC22);
    }
    
    function getWC18()
        public
        view
        virtual
        returns (
            uint32 lastFulFillTimestampWC18,
            uint16 superChampionCodeWC18,
            uint8 championNationIdWC18,
            uint8 runnerupNationIdWC18
        )
    {
        return ( _lastFulFillTimestampWC18, _superChampionCodeWC18, _championNationIdWC18, _runnerupNationIdWC18 );
    }

    function getWCSCORENOs()
        public
        view
        virtual
        returns (
            uint8 SCORENO1,
            uint8 SCORENO2,
            uint8 SCORENO3,
            uint8 SCORENO4
        ){
         return (
            _SCORENO1,
            _SCORENO2,
            _SCORENO3,
            _SCORENO4
        );
    }

    function getWCRAW()
        public
        view
        virtual
        returns (
            string memory SEASONID,
            string memory HOMENATIONCODE,
            string memory AWAYNATIONCODE,
            uint8 HOMEGOAL,
            uint8 AWAYGOAL,
            uint256 SQUAREMULSCORE
        ){

        SQUAREMULSCORE = uint256 ( _SCORENO1 *_SCORENO1 * _SCORENO2 *_SCORENO2 * _SCORENO3 * _SCORENO3 * _SCORENO4 * _SCORENO4 );

        return (
            _SEASONID,
            _HOMENATIONCODE,
            _AWAYNATIONCODE,
            _HOMEGOAL,
            _AWAYGOAL,
            SQUAREMULSCORE
        );
    }

    //===================================
    //chainlink PART
    //===================================
    function reqWC22(string memory sportdataAPIKEY, uint32 deadline)
        external
        virtual
        ensure(deadline)
        returns (bool success)
    {
        require(
            block.timestamp - _closedSaleTimestamp > 86400,
            "TicketRouter : ANNOUNCING_IS_ONLY_ABLE_24HRS_AFTER_CLOSED"
        );
        require(
            !_isAnnounced,
            "TicketRouter : THE_RESULT_IS_ALREADY_ANNOUNCED"
        );

        //only reward to the first announcer
        if(_announcer == address(0)){
            _announcer = msg.sender;
            //transfer the reward to the annoucer
            uint256 annoucerReward = ( _prizePool * _announcerPercent) / 100;
            IERC20(_USD).transfer( _announcer , annoucerReward);
        }

        //chainlink => sportdataapi
        return reqSportdataWithChainLink( sportdataAPIKEY, WC22SeasonID, WC22DateFrom);
    }
    function reqWC18( string memory sportdataAPIKEY, uint32 deadline)
        external
        virtual
        ensure(deadline)
        returns (bool success)
    {
        require(
            block.timestamp < _closedSaleTimestamp ,
            "TicketRouter : DEMO_ANNOUNCING_IS_ONLY_ABLE_BEFORE_MARKET_CLOSED"
        );

        //chainlink => sportdataapi
        return reqSportdataWithChainLink( sportdataAPIKEY, WC18SeasonID, WC18DateFrom);
    }

    function reqSportdataWithChainLink(string memory APIKEY,string memory seasonID, string memory dateFrom)
        private
        returns (bool success)
    {
        string memory matchUrl = string( abi.encodePacked( "https://app.sportdataapi.com/api/v1/soccer/matches?apikey=", APIKEY, "&season_id=", seasonID, "&date_from=", dateFrom));        
        string memory topscorerUrl = string( abi.encodePacked( "https://app.sportdataapi.com/api/v1/soccer/topscorers?apikey=", APIKEY, "&season_id=", seasonID));        
        
        Chainlink.Request memory req;

        //set seasonId (String)
        _SEASONID = seasonID;

        //reset 2 team nation code (String)
        _HOMENATIONCODE = "";
        _AWAYNATIONCODE = "";
        //get 2 team nation code (String)
        {
            //get HOMENATIONCODE
            req = buildChainlinkRequest(
                jobIdString,
                address(this),
                this.fulfillString.selector
            );
            req.add("get", matchUrl);
            req.add("path", "data,0,home_team,short_code");
            _HOMENATIONCODEReqId = sendChainlinkRequest(req, LINK_fee);

            //get AWAYNATIONCODE
            req = buildChainlinkRequest(
                jobIdString,
                address(this),
                this.fulfillString.selector
            );
            req.add("get", matchUrl);
            req.add("path", "data,0,away_team,short_code");
            _AWAYNATIONCODEReqId = sendChainlinkRequest(req, LINK_fee);
        }
        
        //reset 2 team #goal (Int)
        _HOMEGOAL = 255;
        _AWAYGOAL = 255;
        //get 2 team #goal (Int)
        {
            //get HOME #GOAL
            req = buildChainlinkRequest(
                jobIdUint256,
                address(this),
                this.fulfillUint256.selector
            );
            req.add("get", matchUrl);
            req.add("path", "data,0,stats,home_score");
            req.addInt("times", 1);
            _HOMEGOALReqId = sendChainlinkRequest(req, LINK_fee);

            //get AWAY #GOAL
            req = buildChainlinkRequest(
                jobIdUint256,
                address(this),
                this.fulfillUint256.selector
            );
            req.add("get", matchUrl);
            req.add("path", "data,0,stats,away_score");
            req.addInt("times", 1);
            _AWAYGOALReqId = sendChainlinkRequest(req, LINK_fee);
        }

        //reset first 4 top scorer #goal (Int)
        _SCORENO1 = 0;
        _SCORENO2 = 0;
        _SCORENO3 = 0;
        _SCORENO4 = 0;
        //get first 4 top scorer #goal (Int)
        {
            //get SCORENO1
            req = buildChainlinkRequest(
                jobIdUint256,
                address(this),
                this.fulfillUint256.selector
            );
            req.add("get", topscorerUrl);
            req.add("path", "data,0,goals,overall");
            req.addInt("times", 1);
            _SCORENO1ReqId  = sendChainlinkRequest(req, LINK_fee);

            //get SCORENO2
            req = buildChainlinkRequest(
                jobIdUint256,
                address(this),
                this.fulfillUint256.selector
            );
            req.add("get", topscorerUrl);
            req.add("path", "data,1,goals,overall");
            req.addInt("times", 1);
            _SCORENO2ReqId  = sendChainlinkRequest(req, LINK_fee);

            //get SCORENO3
            req = buildChainlinkRequest(
                jobIdUint256,
                address(this),
                this.fulfillUint256.selector
            );
            req.add("get", topscorerUrl);
            req.add("path", "data,2,goals,overall");
            req.addInt("times", 1);
           _SCORENO3ReqId  = sendChainlinkRequest(req, LINK_fee);

           //get SCORENO4
            req = buildChainlinkRequest(
                jobIdUint256,
                address(this),
                this.fulfillUint256.selector
            );
            req.add("get", topscorerUrl);
            req.add("path", "data,3,goals,overall");
            req.addInt("times", 1);
           _SCORENO4ReqId  = sendChainlinkRequest(req, LINK_fee);
        }

        return true;
    }

    function fulfillString(bytes32 requestId, string memory response)
        public
        recordChainlinkFulfillment(requestId)
    {
        emit RequestFulfilledString(requestId, response);

        if (requestId == _HOMENATIONCODEReqId) {
            _HOMENATIONCODE = response;
        } else if (requestId == _AWAYNATIONCODEReqId) {
            _AWAYNATIONCODE = response;
        }

        updateIffullyfulfill();
    }

    function fulfillUint256(bytes32 requestId, uint256 response)
        public
        recordChainlinkFulfillment(requestId)
    {
        emit RequestFulfilledUint256(requestId, response);

        if (requestId == _HOMEGOALReqId) {
            _HOMEGOAL = uint8(response);
        } else if (requestId == _AWAYGOALReqId) {
            _AWAYGOAL = uint8(response);
        } else if (requestId == _SCORENO1ReqId ) {
            _SCORENO1 = uint8(response);
        } else if (requestId == _SCORENO2ReqId ) {
            _SCORENO2 = uint8(response);
        } else if (requestId == _SCORENO3ReqId ) {
            _SCORENO3 = uint8(response);
        } else if (requestId == _SCORENO4ReqId ) {
            _SCORENO4 = uint8(response);
        }

        updateIffullyfulfill();
    }
    
    function updateIffullyfulfill() private {

        //all 4 top scorer #goal square multiplied , if there is any 0 => result = 0
        uint256 SQUAREMULSCORE = uint256 ( _SCORENO1 *_SCORENO1 * _SCORENO2 *_SCORENO2 * _SCORENO3 * _SCORENO3 * _SCORENO4 * _SCORENO4 );
        
        //UPDATE PRIZING NUMBER if data is enough to know who is the winner and the champion code
        if(
            SQUAREMULSCORE > 0 && //all SCOREs must not be 0
            (
                keccak256(abi.encodePacked(_SEASONID)) == keccak256(abi.encodePacked(WC22SeasonID)) || //SEASONID is either WC18 / WC22
                keccak256(abi.encodePacked(_SEASONID)) == keccak256(abi.encodePacked(WC18SeasonID))
            ) && 
            bytes(_HOMENATIONCODE).length != 0 &&
            bytes(_AWAYNATIONCODE).length != 0 &&
            _HOMEGOAL != 255 && //means _HOMEGOAL is fulfilled
            _AWAYGOAL != 255 &&  //means _AWAYGOAL is fulfilled
            _HOMEGOAL != _AWAYGOAL //ended match shouldn't have equal scores
        ){
            //READY TO ANNOUNCE
            bool isWC22 =  (keccak256(abi.encodePacked((_SEASONID))) == keccak256(abi.encodePacked((WC22SeasonID)))); // else WC18
            uint8 homeNationId = _nationCodeToNationId[_HOMENATIONCODE];
            uint8 awayNationId = _nationCodeToNationId[_AWAYNATIONCODE];
            uint8 championNationId;
            uint8 runnerupNationId;
            if( _HOMEGOAL > _AWAYGOAL){//home won
                championNationId = homeNationId;
                runnerupNationId = awayNationId;
            }else{//away won
                championNationId = awayNationId;
                runnerupNationId = homeNationId;
            }
            uint256 SUMSCORE = uint256 ( _SCORENO1 + _SCORENO2 + _SCORENO3 + _SCORENO4 );
            uint16 superChampionCode = uint16 ( (SQUAREMULSCORE + SUMSCORE) % 31250 );

            if(isWC22){//save data for WC22
                _championNationIdWC22 = championNationId;
                _runnerupNationIdWC22 = runnerupNationId;  
                _superChampionCodeWC22 = superChampionCode;                          
                _lastFulFillTimestampWC22 = uint32( block.timestamp );
        
                //mark that the result is announced
                _isAnnounced = true;
            }else{//save data for WC18
                _championNationIdWC18 = championNationId;
                _runnerupNationIdWC18 = runnerupNationId;
                _superChampionCodeWC18 = superChampionCode;
                _lastFulFillTimestampWC18 = uint32( block.timestamp );
            }
        }
    }
}