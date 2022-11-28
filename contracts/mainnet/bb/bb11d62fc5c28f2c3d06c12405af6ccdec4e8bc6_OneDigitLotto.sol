pragma solidity >=0.6.0 <0.9.0;

//SPDX-License-Identifier: LGPL-3.0-or-later

import "./Manageable.sol";
import "./Math.sol";

interface ILottoDefi{
    function sendGameBalance(uint _amount, address _contract) external;
}

contract OneDigitLotto is Manageable, LMath{
    
    address payable IFeeAddress;
    address payable ILottoDefiAddress;
    address public contractAddress = address(this);
    uint256 public Draw = 1001;
    uint16 public TicketNumber = 11;
    int public totalInLot;
    uint public feeAmount;
    uint public winningTimes;
    uint public minimumBet;
    uint public maximumBet;
    uint public claimLimit;
    uint public gameInterval;
    uint public drawEnds;

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

    constructor()  {
        lottoState = LOTTO_STATE.CLOSED;
    }

    mapping(uint => uint) public winningNumber;
    mapping(uint => int) public amountInLot;
    mapping(uint => mapping(address => mapping(uint => Lotto))) public userBets;
    mapping(uint => mapping(address => bool)) private hasUserBet;
    mapping(uint => bool) public hasSpin;
    mapping(uint => mapping(address => uint[])) public userTickets;
    mapping(uint => mapping(address => mapping(uint => bool))) public userClaimed;

    event LogWinnerClaim (uint draw, address player, uint amount);
    event LogUserBuy (uint draw, address player, uint ticket, uint betAmount);

    function setContractAddress(address payable _iFeeAddress, address payable _iLottoDefiAddress) public onlyManager{
        IFeeAddress = _iFeeAddress; // LottoCompany Fee Address.
        ILottoDefiAddress = _iLottoDefiAddress; // LottoDefi Contract Address.
    }

    receive() external payable{}

    function startLotto(
        uint _minBet,
        uint _maxBet,
        uint128 _winningTimes,
        uint _gameInterval,
        uint _claimLimit
        ) public onlyManager{
        minimumBet = _minBet;
        maximumBet = _maxBet;
        winningTimes = _winningTimes;
        gameInterval = _gameInterval;
        claimLimit = _claimLimit;
        lottoState = LOTTO_STATE.OPEN;
    }

    function sendGameFee() internal{ // The Game fee will transfer to the Company Each draw generated result.
        IFeeAddress.transfer(feeAmount);
        totalInLot -= int(feeAmount);
    }

    function getGameBalance(uint _amount, address _contract) internal{ // If the contract balance is less than winning amount who claimtheir prize reward the value of amount will transfer from LottoDefi balance and transfer to winner account.
        require(_contract == address(this));
        ILottoDefi(ILottoDefiAddress).sendGameBalance(_amount, _contract);

    }
    
    function sendGameProfit() internal{ // The Game profit sends to LottoDefi stakers reward.
        uint profitDraw = Draw - claimLimit; // The profit will send only after the winners claimperiod is finished.
        if (totalInLot < int(address(this).balance)){
            int remAmount = int(address(this).balance) - totalInLot;
            int profit = amountInLot[profitDraw];
            int result = remAmount + profit;
            if (amountInLot[profitDraw] > 0){
                ILottoDefiAddress.transfer(uint(result));
            } else{
                return;
            }
        } else {
            if (amountInLot[profitDraw] > 0){
                uint profit = uint(amountInLot[profitDraw]);
                ILottoDefiAddress.transfer(uint(profit));
            } else{
                return;
            }
        }
        
    }

    function generateResult(uint _ticketNumber) public{ // Any player who buys Lotto Ticket will generate the result after Draw time period and get cashback of 50% betamount of ticketNumber;
        require(drawState() == LOTTO_STATE.CLOSED, "Draw is not closed yet");
        require(hasUserBet[Draw][msg.sender] == true, "you didn't buy any ticket");
        require(hasSpin[Draw] != true, "The result was Generated");
        uint diff = block.difficulty;
        bytes32 hash = blockhash(block.number); // TODO - blockNumber - 4
        uint number = uint(keccak256(abi.encodePacked(block.timestamp, diff, hash))) % 10;
        winningNumber[Draw] = number;
        uint amount = div(mul(userBets[Draw][msg.sender][_ticketNumber].betAmount, 50), 100);
        address payable spinner = payable(msg.sender);
        spinner.transfer(amount);
        amountInLot[Draw] -= int(amount);
        totalInLot -= int(amount);
        hasSpin[Draw] = true;
        sendGameFee();
        sendGameProfit();
        Draw++;
        TicketNumber = 11;
        feeAmount = 0;
        lottoState == LOTTO_STATE.OPEN;
    }

    function managerGenResult() public onlyManager{ // If no Players generated the result after the drawEnds the manager will generate the result;
        require(time() > drawEnds + 3600, "The one hr time is not finished"); 
        require(drawState() == LOTTO_STATE.CLOSED, "Draw is not closed yet");
        require(hasSpin[Draw] != true, "The result was Generated");
        uint diff = block.difficulty;
        bytes32 hash = blockhash(block.number); // TODO - blockNumber - 4
        uint number = uint(keccak256(abi.encodePacked(block.timestamp, diff, hash, Draw))) % 10;
        winningNumber[Draw] = number;
        hasSpin[Draw] = true;
        sendGameFee();
        sendGameProfit();
        Draw++;
        TicketNumber = 11;
        feeAmount = 0;
        lottoState == LOTTO_STATE.OPEN;
    }

    function time() internal returns (uint){
        return block.timestamp;
    }

    function drawState() internal returns (LOTTO_STATE){
        return time() < drawEnds ? LOTTO_STATE.OPEN : LOTTO_STATE.CLOSED;
    }

    function buyTicket(uint _number, uint _amount) public payable{
        // When the player buys first ticket of draw the Draw Ending time will generate.
        // Once the Draw Time Ends the played couldn't buy any ticket.
        if(amountInLot[Draw] == 0){
            uint now = block.timestamp;
            drawEnds = add(now, gameInterval);
        }
        require(lottoState == LOTTO_STATE.OPEN && drawState() == LOTTO_STATE.OPEN, "The New Draw is not Open");
        require(_amount == msg.value, "Wrong BNB value");
        require(_amount >= minimumBet && _amount <= maximumBet, "Bet amount is wrong");
        require(_number < 10 , "Choose 0-9 number");
        Lotto storage L = userBets[Draw][msg.sender][TicketNumber];
        L.user = payable(msg.sender);
        L.betAmount = _amount;
        L.number = _number;
        userTickets[Draw][msg.sender].push(TicketNumber);
        hasUserBet[Draw][msg.sender] = true;
        emit LogUserBuy(Draw, msg.sender, TicketNumber, _amount);
        uint lot = (_amount * 80) / 100;
        uint fee = (_amount * 20) / 100;
        amountInLot[Draw] += int(lot);
        totalInLot += int(_amount);
        feeAmount += fee;
        TicketNumber ++;
    }

    function claimWinningPrize(uint _drawNumber, uint _ticketNumber) public{
        // If the player ticket's Number wins they can claim the winning prize with in the period of Claimed Limit.
        require(userClaimed[_drawNumber][msg.sender][_ticketNumber] == false, "You already claimed the Prize value");
        require(_drawNumber < Draw, "The Draw is not closed yet");
        require(_drawNumber >= Draw - claimLimit, "The claiming period is closed");
        uint wonAmount = mul(userBets[_drawNumber][msg.sender][_ticketNumber].betAmount, winningTimes);
        address payable winner = userBets[_drawNumber][msg.sender][_ticketNumber].user;
        require(userBets[_drawNumber][msg.sender][_ticketNumber].number == winningNumber[_drawNumber], "You didn't won this lottery");

        if (wonAmount > uint(amountInLot[_drawNumber]) && wonAmount > address(this).balance){
            getGameBalance(wonAmount, contractAddress);
            winner.transfer(wonAmount);
            emit LogWinnerClaim(_drawNumber, msg.sender, wonAmount);
        } else{
            winner.transfer(wonAmount);
            amountInLot[_drawNumber] -= int(wonAmount);
            totalInLot -= int(wonAmount);
            userClaimed[_drawNumber][msg.sender][_ticketNumber] = true;
            emit LogWinnerClaim(_drawNumber, msg.sender, wonAmount);
        }
    }
}