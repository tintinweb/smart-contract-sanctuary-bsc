// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

import "./ERC20.sol";
import "./ChainlinkClient.sol";

contract MYFANTASTIC5Router is ChainlinkClient {
    //========================================
    //dynamic PART (changed by round)
    //========================================
    string private constant round = "6";
    //deadline sale time for each round
    uint32 public _closedSaleTimestamp = 1676404800; //1st Leg before 1st matchday of the round
    uint8 private constant teamMax = 200; //can be more in the future
    uint8 private constant playerLength = 30; //can be more in the future
    //player Id in UCL official website
    string[playerLength] private _playerId = [
        "250076574",//Mbappé
        "250052469"//Salah
        "250103758",//Haaland
        "250061119",//Mané
        "93321",//Benzema
        "95803",//Messi
        "250008901",//De Bruyne
        "250016833",//Kane
        "250043463",//Son
        "250039508",//Neymar
        "250121533",//Vinícius Júnior
        "250003318",//Müller
        "250070687",//Mahrez
        "250024795",//Sterling
        "250063984",//Sané
        "250076654",//Nkunku
        "250080471",//Jota
        "250010802",//Lukaku
        "250116654",//Gonçalo Ramos
        "250132811",//Luis Díaz"
        "54694",//Aubameyang
        "250087938",//Havertz
        "250041770",//Gnabry
        "250129539",//Richarlison
        "250089228",//Rafael Leão
        "250063447",//Rafa Silva
        "250118281",//Lautaro Martínez
        "250101534",//Phil Foden
        "250144965",//Darwin Núñez
        "250059115"//Bernardo Silva
    ];
    //========================================
    //static PART (unchanged by round)
    //========================================
    struct fantasyTeam {
        address owner;
        uint8 captain;
        uint8 player2;
        uint8 player3;
        uint8 player4;
        uint8 player5;
        uint32 timestamp;
        bool isClaimed;
        uint16 point;
        uint32 rank;
    }
    address public _owner;

    //prize pool
    uint256 public _prizePool;
    //if this round is announced
    bool public _isAnnounced;
    //if dev has claimed reward
    bool private _isDevClaimed;

    //points for each stat
    uint8 private constant pointPerAssist = 3;
    uint8 private constant pointPerGoal = 6;

    //prize percents
    uint8 private constant _firstPrizePercent = 50;
    uint8 private constant _secondPrizePercent = 20;
    uint8 private constant _otherTop10PrizePercent = 24;
    uint8 private constant _devPercent = 6;

    //ticket_index => fantasyTeam
    mapping(uint32 => fantasyTeam) private _teamSubmitedList;
    //recent length of _teamSubmitedList
    uint32 public _teamSubmitedLength;

    //owner's address => recent length of _teamHeldList for this address
    mapping(address => uint32) public _teamHeldLength;

    //#goal for all playerLength players //inited with 255
    uint8[playerLength] private _goalScored = [
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255
    ];
    //#assist for all 30 players //inited with 255
    uint8[playerLength] private _assistMade = [
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255
    ];

    //========================================
    //chainlink params PART
    //========================================
    bytes32[playerLength] private _goalAssistReqId;
    address private constant _LINK = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;
    using Chainlink for Chainlink.Request;
    event RequestFulfilledUint256Pair(
        bytes32 indexed requestId,
        uint256 response1,
        uint256 response2
    );
    //chainlink fee per request
    uint256 constant LINK_fee = (LINK_DIVISIBILITY / 100) * 15; // 0.15 LINK

    //========================================
    //modifier & constructor PART
    //========================================
    modifier isOwner() {
        require(
            msg.sender == _owner,
            "MYFANTASTIC5Router: AUTHORIZATION_FAILED"
        );
        _;
    }

    constructor() {
        _owner = msg.sender;

        setChainlinkToken(_LINK);
        setChainlinkOracle(0x3d5552a177Fe380CDDe28a034EA93C2d30b80b2D);
    }

    //========================================
    //internal functions  PART
    //========================================

    function _isDataReady() private view returns (bool isDataReady) {
        isDataReady = true;
        for (uint32 i = 0; i < playerLength; i++) {
            if (_goalScored[i] == 255 || _assistMade[i] == 255) {
                isDataReady = false;
                break;
            }
        }
    }

    function _getPointByTeamIdx(uint32 teamIdx)
        private
        view
        returns (uint16 point)
    {
        point +=
            _goalScored[_teamSubmitedList[teamIdx].captain] *
            pointPerGoal *
            2;
        point += _goalScored[_teamSubmitedList[teamIdx].player2] * pointPerGoal;
        point += _goalScored[_teamSubmitedList[teamIdx].player3] * pointPerGoal;
        point += _goalScored[_teamSubmitedList[teamIdx].player4] * pointPerGoal;
        point += _goalScored[_teamSubmitedList[teamIdx].player5] * pointPerGoal;

        point +=
            _assistMade[_teamSubmitedList[teamIdx].captain] *
            pointPerAssist *
            2;
        point +=
            _assistMade[_teamSubmitedList[teamIdx].player2] *
            pointPerAssist;
        point +=
            _assistMade[_teamSubmitedList[teamIdx].player3] *
            pointPerAssist;
        point +=
            _assistMade[_teamSubmitedList[teamIdx].player4] *
            pointPerAssist;
        point +=
            _assistMade[_teamSubmitedList[teamIdx].player5] *
            pointPerAssist;
    }

    function _getRankByTeamIdx(uint32 teamIdx)
        private
        view
        returns (uint32 rank)
    {
        uint32 betterTeamCount = 0;
        for (uint32 k = 0; k < _teamSubmitedLength; k++) {
            if (teamIdx != k) {
                if (_getPointByTeamIdx(k) > _getPointByTeamIdx(teamIdx)) {
                    betterTeamCount++;
                } else if (
                    _getPointByTeamIdx(k) == _getPointByTeamIdx(teamIdx) &&
                    k < teamIdx
                ) {
                    betterTeamCount++;
                }
            }
        }
        rank = betterTeamCount + 1;
    }

    function _IsTeamValid(
        uint8 captain,
        uint8 player2,
        uint8 player3,
        uint8 player4,
        uint8 player5
    ) private pure returns (bool isValid) {
        if (captain == player2) {
            return false;
        } else if (captain == player3) {
            return false;
        } else if (captain == player4) {
            return false;
        } else if (captain == player5) {
            return false;
        } else if (player2 == player3) {
            return false;
        } else if (player2 == player4) {
            return false;
        } else if (player2 == player5) {
            return false;
        } else if (player3 == player4) {
            return false;
        } else if (player3 == player5) {
            return false;
        } else if (player4 == player5) {
            return false;
        }
        return true;
    }

    //========================================
    //external functions  PART
    //========================================
    function getPrice() public view virtual returns (uint256 price) {
        return 1 * (10**16);
    }

    function getSharePercents()
        public
        view
        virtual
        returns (
            uint8 firstPrizePercent,
            uint8 secondPrizePercent,
            uint8 otherTop10PrizePercent,
            uint8 devPercent
        )
    {
        return (
            _firstPrizePercent,
            _secondPrizePercent,
            _otherTop10PrizePercent,
            _devPercent
        );
    }

    function getGoalAndAssist()
        public
        view
        virtual
        returns (
            uint8[playerLength] memory goalScored,
            uint8[playerLength] memory assistMade
        )
    {
        return (_goalScored, _assistMade);
    }

    function getTeamsByLength(uint32 from, uint32 length)
        public
        view
        virtual
        returns (uint32[] memory indices, fantasyTeam[] memory teams)
    {
        teams = new fantasyTeam[](length);
        indices = new uint32[](length);
        uint32 counter;
        for (uint32 i = from; i < from + length; i++) {
            if (counter == length || i >= _teamSubmitedLength) {
                break;
            }
            teams[counter] = _teamSubmitedList[i];
            if (_isDataReady()) {
                teams[counter].point = _getPointByTeamIdx(i);
                teams[counter].rank = _getRankByTeamIdx(i);
            }
            indices[counter] = i;
            counter++;
        }
        return (indices, teams);
    }

    function getTeamsByHolderByLength(
        address holder,
        uint32 from,
        uint32 length
    )
        public
        view
        virtual
        returns (uint32[] memory indices, fantasyTeam[] memory teams)
    {
        teams = new fantasyTeam[](length);
        indices = new uint32[](length);
        uint32 counter;
        uint32 skipper;
        for (uint32 i = 0; i < _teamSubmitedLength; i++) {
            if (counter == length) {
                break;
            }
            if (_teamSubmitedList[i].owner == holder) {
                if (skipper != from) {
                    skipper++;
                } else {
                    teams[counter] = _teamSubmitedList[i];
                    if (_isDataReady()) {
                        teams[counter].point = _getPointByTeamIdx(i);
                        teams[counter].rank = _getRankByTeamIdx(i);
                    }
                    indices[counter] = i;
                    counter++;
                }
            }
        }
        return (indices, teams);
    }

    function getClaimableAmountByTeamIndex(uint32 teamIdx)
        public
        view
        virtual
        returns (uint256 claimable)
    {
        if (!_isAnnounced) {
            return 0;
        }
        uint32 rank = _getRankByTeamIdx(teamIdx);
        if (rank == 1) {
            claimable = (_prizePool * _firstPrizePercent) / 100;
        } else if (rank == 2) {
            claimable = (_prizePool * _secondPrizePercent) / 100;
        } else if (rank >= 3 && rank <= 10) {
            //share amoung 8 teams
            claimable = (_prizePool * _otherTop10PrizePercent) / 100 / 8;
        }
        return claimable;
    }

    function submitTeam(
        uint8 captain,
        uint8 player2,
        uint8 player3,
        uint8 player4,
        uint8 player5,
        address teamOwner
    ) external payable virtual{
        require(
            block.timestamp < _closedSaleTimestamp,
            "MYFANTASTIC5Router: TICKET_SALE_IS_CLOSED"
        );
        require(
            !_isAnnounced,
            "MYFANTASTIC5Router: TICKETS_ARE_NOT_ON_SALE_AFTER_ANNOUNCING"
        );
        require(
            msg.value >= getPrice(),
            "MYFANTASTIC5Router: OFFERED_PRICE_IS_TOO_LOW"
        );
        require(
            _teamSubmitedLength < teamMax,
            "MYFANTASTIC5Router: TEAM_SUBMITED_EXCEEDS"
        );
        require(
            _IsTeamValid(captain, player2, player3, player4, player5),
            "MYFANTASTIC5Router: TEAM_MEMBER_NOT_VALID"
        );

        //init fantasyTeam
        fantasyTeam memory thisTeam = fantasyTeam({
            owner: teamOwner,
            captain: captain,
            player2: player2,
            player3: player3,
            player4: player4,
            player5: player5,
            timestamp: uint32(block.timestamp),
            isClaimed: false,
            point: 0,
            rank: 0
        });

        //increment to this ticketTaker
        _teamHeldLength[teamOwner]++;

        //add this team to the sold ticket list
        uint32 curSoldLength = _teamSubmitedLength;
        _teamSubmitedList[curSoldLength] = thisTeam;
        _teamSubmitedLength = curSoldLength + 1;

        //increase _prizePool by offered ticketPrice
        _prizePool += msg.value;

    }

    function claimReward(uint16 teamIndex)
        external
        virtual
        returns (uint256 amount)
    {
        require(
            !_teamSubmitedList[teamIndex].isClaimed,
            "MYFANTASTIC5Router: THIS_TEAM_IS_CLAIMED"
        );
        require(
            _teamSubmitedList[teamIndex].owner == msg.sender,
            "MYFANTASTIC5Router: THIS_TEAM_IS_NOT_YOURS"
        );
        amount = getClaimableAmountByTeamIndex(teamIndex);
        //transfer reward to the ticket holder
        (bool success, ) = payable(_teamSubmitedList[teamIndex].owner).call{
            value: amount
        }("");
        require(success, "MYFANTASTIC5Router: TEAM_CLAIM_PAYMENT_FAILED");

        //mark that this team is claimed
        _teamSubmitedList[teamIndex].isClaimed = true;

        return amount;
    }

    function claimRewardDev()
        external
        virtual
        returns (uint256 amount)
    {
        require(
            _isAnnounced,
            "MYFANTASTIC5Router: DEVS_CANT_CLAIM_BEFORE_ANNOUNCING"
        );
        require(!_isDevClaimed, "MYFANTASTIC5Router: DEVS_CLAIMED_ALREADY");

        amount = (_prizePool * _devPercent) / 100;

        (bool success, ) = payable(_owner).call{value: amount}("");
        require(success, "MYFANTASTIC5Router: DEVS_CLAIM_PAYMENT_FAILED");

        //mark that devs claimed
        _isDevClaimed = true;

        return amount;
    }

    function announceIfReady() public {
        require(_isDataReady(), "MYFANTASTIC5Router: Data is not ready");
        _isAnnounced = true;
    }

    //========================================
    //chainlink functions PART
    //========================================
    function reqDataWithChainLink(bytes32 jobIdUint256Pair)
        public
        isOwner
        returns (bool success)
    {
        //check LINK amount in this contract
        require(
            IERC20(_LINK).balanceOf(address(this)) >= (LINK_fee * playerLength),
            "MYFANTASTIC5Router: NOT_ENOUGH_LINK_TO_PAY_AS_FEE(playerLength x FEE)"
        );
        //check if the round is over
        require(
            block.timestamp > _closedSaleTimestamp,
            "MYFANTASTIC5Router: REQ_IS_ALLOWED_AFTER_SALE_CLOSED"
        );

        Chainlink.Request memory req;
        for (uint32 i = 0; i < playerLength; i++) {
            string memory url = string(
                abi.encodePacked(
                    "https://gaming.uefa.com/en/uclfantasy/services/feeds/popupstats/popupstats_50_",
                    _playerId[i],
                    ".json"
                )
            );
            req = buildChainlinkRequest(
                jobIdUint256Pair,
                address(this),
                this.fulfillUint256Pair.selector
            );
            req.add("get", url);
            req.add(
                "path1",
                string(abi.encodePacked("data,value,stats,", round, ",gS"))
            );
            req.add(
                "path2",
                string(abi.encodePacked("data,value,stats,", round, ",gA"))
            );
            req.addInt("times", 1);
            _goalAssistReqId[i] = sendOperatorRequest(req, LINK_fee);
        }
        return true;
    }

    function fulfillUint256Pair(
        bytes32 requestId,
        uint256 response1,
        uint256 response2
    ) public recordChainlinkFulfillment(requestId) {
        emit RequestFulfilledUint256Pair(requestId, response1, response2);
        for (uint32 i = 0; i < playerLength; i++) {
            if (requestId == _goalAssistReqId[i]) {
                _goalScored[i] = uint8(response1);
                _assistMade[i] = uint8(response2);
                break;
            }
        }
    }

    // test fulfillUint256PairManual
    // function fulfillUint256PairManual(
    //     uint8[playerLength] memory goalScored,
    //     uint8[playerLength] memory assistMade
    // ) public {
    //     _goalScored = goalScored;
    //     _assistMade = assistMade;
    // }
}