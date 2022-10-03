//SPDX-License-Identifier: LGPL-3.0-or-later

pragma solidity >=0.6.0 <0.9.0;

import "./Manageable.sol";
import "./VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2.sol";
import "./SafeMath.sol";

contract Lotto1Digit is Manageable, VRFConsumerBaseV2{
    using SafeMath for uint;
    VRFCoordinatorV2Interface COORDINATOR;
    address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
    uint256[] private s_randomWords;
    uint256 private s_requestId;
    
    uint256 public Draw = 1001;
    uint16 public TicketNumber = 11;
    uint public winningTimes;
    uint public minimumBet;
    uint public maximumBet;
    uint public startTime;
    uint public totalStaked;

    struct Lotto{
        address payable user;
        uint betAmount;
        uint number;
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
    mapping(uint => int) public amountInLot;
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

    function requestRandomWords(bytes32 _keyHash, uint64 _subscriptionId, uint16 _requestConfirmation, uint32 _callBackGasLimit, uint32 _numWords) public onlyManager {
        //require(lottoState == LOTTO_STATE.CLOSED);
    // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
        _keyHash,
        _subscriptionId,
        _requestConfirmation,
        _callBackGasLimit,
        _numWords
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
        uint _winningTimes,
        uint _startTime
        ) public onlyManager{
        minimumBet = _minBet;
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
        winningNumber[Draw] = s_randomWords[0].mod(10);
        Draw++; 
        TicketNumber = 11;
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

    function buyTicket(uint _number) public payable{
        require(lottoState == LOTTO_STATE.OPEN, "The Draw is not Open");
        require(msg.value >= minimumBet && msg.value <= maximumBet, "Bet amount is wrong");
        require(_number < 10 , "Choose 0-9 number");
        Lotto storage L = userBets[Draw][msg.sender][TicketNumber];
        L.user = payable(msg.sender);
        L.betAmount = msg.value;
        L.number = _number;
        userTickets[Draw][msg.sender].push(TicketNumber);
        uint lot = (msg.value * 80) / 100;
        uint fee = (msg.value * 20) / 100;
        amountInLot[Draw] = int(lot);
        feeAmount[Draw] = fee;
        TicketNumber ++;
    }

    function claimWinningPrize(uint _drawNumber, uint _ticketNumber) public{
        require(userClaimed[_drawNumber][msg.sender][_ticketNumber] == false, "You already claimed the Prize value");
        require(_drawNumber < Draw && _drawNumber > Draw - 168, "The Draw is not closed yet or claiming period of 7days is finished");
       
        if (userBets[_drawNumber][msg.sender][_ticketNumber].number != winningNumber[_drawNumber]){
            revert("You didn't won this lottery");
        }
        uint wonAmount = userBets[_drawNumber][msg.sender][_ticketNumber].betAmount.mul(winningTimes);
        address payable winner = payable(msg.sender);
        amountInLot[_drawNumber] -= int(wonAmount);
        (bool sent, bytes memory data) = winner.call{value: wonAmount}("Congrats Winner");
        require(sent, "Failed to send BNB");
        userClaimed[_drawNumber][msg.sender][_ticketNumber] = true;
        emit LogWinnerClaim(_drawNumber, msg.sender, wonAmount);
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
        //require(today() > (stakedDay[msg.sender] + 6), "The minimum staking period is 7 days");
        uint amount = staked[msg.sender];
        address payable user = payable(msg.sender);
        user.transfer(amount);
        staked[msg.sender] -= amount;
        totalStaked -= amount;
        unStakedDay[msg.sender] = today();
        emit LogUnStaked(msg.sender, amount);
    }

    function claimReward(uint _day) public{
        require(_day <= unStakedDay[msg.sender] && _day >= stakedDay[msg.sender], "choose between stake and unstake day");
        require(_day < today() - 6,"you can't claim your reward before 7 days of today");

        int stakerTotal = int(staked[msg.sender]);
        int price = amountInLot[_day] / int(totalStaked);
        int reward = price * stakerTotal;
        address payable staker = payable(msg.sender);
        if (reward <= 0 || stakerClaimed[_day][msg.sender] == true){
            return;
        } else if(reward > 0){
            staker.transfer(uint(reward));
            emit LogRewardClaim(_day, msg.sender, uint(reward));
            stakerClaimed[_day][msg.sender] = true;
        }
    }

    function claimAllRewards() public{
        for (uint i = stakedDay[msg.sender]; i < today()-1; i++){
            claimReward(i);
        }
    }
}