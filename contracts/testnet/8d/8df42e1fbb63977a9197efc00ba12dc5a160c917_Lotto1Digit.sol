//SPDX-License-Identifier: LGPL-3.0-or-later

pragma solidity >=0.6.0 <0.9.0;

import "./Manageable.sol";
import "./VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2.sol";

contract Lotto1Digit is Manageable, VRFConsumerBaseV2{
    VRFCoordinatorV2Interface COORDINATOR;
    address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
    bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint256[] private s_randomWords;
    uint256 private s_requestId;
    uint64 private s_subscriptionId = 1891;
    
    uint256 public Draw = 1;
    uint16 public TicketNumber = 1;
    uint8 public winningTimes;
    uint public minumumBet;
    uint public maximumBet;
    uint public startTime;
    uint public totalStaked;

    struct Lotto{
        address payable user;
        uint betAmount;
        uint8 number;
    }

    enum LOTTO_STATE{
        OPEN,
        CLOSED
    }

    LOTTO_STATE private lottoState;

    enum STAKE_STATE{
        OPEN,
        CLOSED
    }

    STAKE_STATE private stakeState;

    address payable[] public feeAddress;

    mapping(uint => uint) public winningNumber;
    mapping(uint => uint) public amountInLot;
    mapping(uint => uint) public feeAmount;
    mapping(uint => bool) public getPayed;
    mapping(address => uint) public staked;
    mapping(address => uint) public stakedDay;
    mapping(address => uint) public unStakedDay;
    mapping(uint => mapping(address => bool)) private stakerClaimed;
    mapping(uint => mapping(address => mapping(uint => Lotto))) public userBets;
    mapping(uint => mapping(address => uint[])) public userTickets;
    mapping(uint => mapping(address => mapping(uint => bool))) public userClaimed;


    event LogStaked (address staker, uint amount);
    event LogUnStaked (address staker, uint amount);
    event LogRewardClaim (uint day, address staker, uint amount);
    event LogWinnerClaim (uint draw, address player, uint amount);

    constructor() VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    }

    function requestRandomWords() public onlyManager {
        //require(lottoState == LOTTO_STATE.CLOSED);
    // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
        lottoState == LOTTO_STATE.CLOSED;
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    function startLotto(
        uint _minBet,
        uint _maxBet,
        uint8 _winningTimes,
        uint _startTime
        ) public onlyManager{
        minumumBet = _minBet;
        maximumBet = _maxBet;
        winningTimes = _winningTimes;
        startTime = _startTime;
        lottoState = LOTTO_STATE.OPEN;
        stakeState = STAKE_STATE.OPEN;
    }

    function addFeeAddress(address _feeAddress)public onlyManager{
        feeAddress.push(payable(_feeAddress));
    }

    function removeFeeAddress() public onlyManager{
        delete feeAddress;
    }

    function updateWinningNumber() public onlyManager{
        winningNumber[Draw] = s_randomWords[0]%10;
        Draw++;
        lottoState = LOTTO_STATE.OPEN;
    }

    function withdrawFee(uint _drawNumber) public onlyManager{
        require(_drawNumber < Draw, "You can't withdraw current or upcoming draw");
        require(getPayed[_drawNumber] != true, "You already Withdrawn");
        uint finalAmount = feeAmount[_drawNumber] / feeAddress.length;
        for (uint i = 0; i < feeAddress.length; i++){
            require(feeAddress[i] != address(0));
            payable(feeAddress[i]).transfer(finalAmount);
        }
        getPayed[_drawNumber] = true;
    }

    function time() internal returns (uint){
        return block.timestamp;
    }

    function today() internal returns (uint){
        return dayFor(time());
    }

    function dayFor(uint timeStamp) internal returns (uint){
        return timeStamp < startTime ? 0 : (timeStamp - startTime) / 60 minutes + 1;
    }

    function buyTicket(uint8 _number) public payable{
        require(lottoState == LOTTO_STATE.OPEN, "The Draw is not Open");
        require(msg.value >= minumumBet && msg.value <= maximumBet, "Bet amount is wrong");
        require(_number < 10 , "Choose 0-9 number");
        Lotto storage L = userBets[Draw][msg.sender][TicketNumber];
        L.user = payable(msg.sender);
        L.betAmount = msg.value;
        L.number = _number;
        userTickets[Draw][msg.sender].push(TicketNumber);
        uint lot = (msg.value * 80) / 100;
        uint fee = (msg.value * 20) / 100;
        amountInLot[Draw] = lot;
        feeAmount[Draw] = fee;
        TicketNumber ++;
    }

    function claimWinningPrize(uint _drawNumber, uint _ticketNumber) public{
        require(userClaimed[_drawNumber][msg.sender][_ticketNumber] != true, "You already claimed the Prize value");
        require(_drawNumber < Draw, "The Draw is not closed yet");
        
        if (userBets[_drawNumber][msg.sender][_ticketNumber].number == winningNumber[_drawNumber]){
            uint wonAmount = userBets[_drawNumber][msg.sender][_ticketNumber].betAmount * winningTimes;
            address payable winner = userBets[_drawNumber][msg.sender][_ticketNumber].user;
            winner.transfer(wonAmount);
            amountInLot[_drawNumber] -= wonAmount;
            userClaimed[_drawNumber][msg.sender][_ticketNumber] = true;
            emit LogWinnerClaim(_drawNumber, msg.sender, wonAmount);
        }else {
            revert("You Did't Won this bet");
        }
    }

    function stake() public payable{
        require(msg.value >= 0.05 ether, "Minimum stake is 0.05 BNB");
        require(stakeState == STAKE_STATE.OPEN, "The game is not start yet");
        staked[msg.sender] += msg.value;
        totalStaked += msg.value;
        emit LogStaked(msg.sender, msg.value);
        stakedDay[msg.sender] = today() + 1;
    }
    
    function unStake() public{
        require(today() > (stakedDay[msg.sender] + 6), "The minimum staking period is 7 days");
        uint amount = staked[msg.sender];
        address payable user = payable(msg.sender);
        user.transfer(amount);
        staked[msg.sender] -= amount;
        totalStaked -= amount;
        unStakedDay[msg.sender] = today();
        emit LogUnStaked(msg.sender, amount);
    }

    function claimReward(uint _day) internal{
        require(_day >= unStakedDay[msg.sender], "You unstaked this day");
        uint stakerTotal = staked[msg.sender];
        uint price = amountInLot[_day] / totalStaked;
        uint reward = price * stakerTotal;
        address payable staker = payable(msg.sender);
        if (reward == 0 && stakerClaimed[_day][msg.sender] == true){
            return;
        } else if(reward > 0){
            staker.transfer(reward);
            emit LogRewardClaim(_day, msg.sender, reward);
            stakerClaimed[_day][msg.sender] = true;
        }
    }

    function claimAllRewards() public{
        for (uint i = stakedDay[msg.sender]; i < today(); i++){
            claimReward(i);
        }
    }
}