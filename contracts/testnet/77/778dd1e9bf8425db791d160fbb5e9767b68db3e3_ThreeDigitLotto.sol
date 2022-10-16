pragma solidity >=0.6.0 <0.9.0;

//SPDX-License-Identifier: LGPL-3.0-or-later

import "./Manageable.sol";
import "./Math.sol";

interface ILottoDefi{
    function sendGameBalance(uint _amount, address _contract) external;
}

contract ThreeDigitLotto is Manageable, LMath{
    
    address payable IFeeAddress;
    address payable ILottoDefiAddress;
    address public contractAddress = address(this);
    uint256 public Draw = 1001;
    uint16 public TicketNumber = 11;
    uint public feeAmount;
    uint public ThreeDigitWinningTimes;
    uint public TwoDigitWinningTimes;
    uint public OneDigitWinningTimes;
    uint public minimumBet;
    uint public maximumBet;
    uint public claimLimit;
    uint public gameInterval;
    uint public drawEnds;
    

    struct Lotto{
        address payable user;
        uint betAmount;
        uint blockA;
        uint blockB;
        uint blockC;
    }

    enum LOTTO_STATE{
        OPEN,
        CLOSED
    }

    LOTTO_STATE public lottoState;

    constructor()  {
        lottoState = LOTTO_STATE.CLOSED;
    }

    mapping(uint => uint[3]) winningNumber;
    mapping(uint => int) public amountInLot;
    mapping(uint => mapping(address => mapping(uint => Lotto))) public userBets;
    mapping(uint => mapping(address => bool)) private hasUserBet;
    mapping(uint => bool) private hasSpin;
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
        uint128 _ThreeDigitWinningTime,
        uint128 _TwoDigitWinningTime,
        uint128 _OneDigitWinningTime,
        uint _gameInterval,
        uint _claimLimit
        ) public onlyManager{
        minimumBet = _minBet;
        maximumBet = _maxBet;
        ThreeDigitWinningTimes = _ThreeDigitWinningTime;
        TwoDigitWinningTimes = _TwoDigitWinningTime;
        OneDigitWinningTimes = _OneDigitWinningTime;
        gameInterval = _gameInterval;
        claimLimit = _claimLimit;
        lottoState = LOTTO_STATE.OPEN;
    }

    function sendGameFee() internal{ // The Game fee will transfer to the Company Each draw generated result.
        IFeeAddress.transfer(feeAmount);
    }

    function getGameBalance(uint _amount, address _contract) internal{ // If the contract balance is less than winning amount who claimtheir prize reward the value of amount will transfer from LottoDefi balance and transfer to winner account.
        require(_contract == address(this));
        ILottoDefi(ILottoDefiAddress).sendGameBalance(_amount, _contract);
    }
    
    function sendGameProfit() internal{ // The Game profit sends to LottoDefi stakers reward.
        uint profitDraw = Draw - claimLimit; // The profit will send only after the winners claimperiod is finished.
        if (amountInLot[profitDraw] > 0){
            uint profit = uint(amountInLot[profitDraw]);
            (bool success, ) = address(ILottoDefiAddress).call{gas: 200000, value: profit}('');
            require(success);
        } else{
            return;
        }
    }

    function generateResult(uint _ticketNumber) public{ // Any player who buys Lotto Ticket will generate the result after Draw time period and get cashback of 50% betamount of ticketNumber;
        require(drawState() == LOTTO_STATE.CLOSED, "Draw is not closed yet");
        require(hasUserBet[Draw][msg.sender] == true, "you didn't buy any ticket");
        require(hasSpin[Draw] != true, "The result was Generated");
        uint diff = block.difficulty;
        bytes32 hash = blockhash(block.number); // TODO - blockNumber - 4
        uint number = uint(keccak256(abi.encodePacked(block.timestamp, diff, hash)));
        uint _blockA = (number % 1000) / 100;
        uint _blockB = (number % 100) / 10;
        uint _blockC = number % 10;
        winningNumber[Draw] = [_blockA, _blockB, _blockC];
        uint amount = div(mul(userBets[Draw][msg.sender][_ticketNumber].betAmount, 50), 100);
        address payable spinner = payable(msg.sender);
        spinner.transfer(amount);
        amountInLot[Draw] -= int256(amount);
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
        uint number = uint(keccak256(abi.encodePacked(block.timestamp, diff, hash, Draw)));
        uint _blockA = (number % 1000) / 100;
        uint _blockB = (number % 100) / 10;
        uint _blockC = number % 10;
        winningNumber[Draw] = [_blockA, _blockB, _blockC];
        sendGameFee();
        sendGameProfit();
        hasSpin[Draw] = true;
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

    function buyTicket(uint _blockA, uint _blockB, uint _blockC, uint _amount) public payable{
        // When the player buys first ticket of draw the Draw Ending time will generate.
        // Once the Draw Time Ends the played couldn't buy any ticket.
        if(amountInLot[Draw] == 0){
            uint now = block.timestamp;
            drawEnds = add(now, gameInterval);
        }
        require(lottoState == LOTTO_STATE.OPEN && drawState() == LOTTO_STATE.OPEN, "The New Draw is not Open");
        require(_amount == msg.value, "Wrong BNB value");
        require(_amount >= minimumBet && _amount <= maximumBet, "Bet amount is wrong");
        require(_blockA < 10 && _blockB < 10 && _blockC < 10, "Choose 0-9 number of each block");
        Lotto storage L = userBets[Draw][msg.sender][TicketNumber];
        L.user = payable(msg.sender);
        L.betAmount = _amount;
        L.blockA = _blockA;
        L.blockB = _blockB;
        L.blockC = _blockC;
        userTickets[Draw][msg.sender].push(TicketNumber);
        hasUserBet[Draw][msg.sender] = true;
        emit LogUserBuy(Draw, msg.sender, TicketNumber, _amount);
        uint lot = (_amount * 80) / 100;
        uint fee = (_amount * 20) / 100;
        amountInLot[Draw] += int(uint(lot));
        feeAmount += fee;
        TicketNumber ++;
    }

    function viewWonNumber(uint _drawNumber) public view returns(uint[3] memory result){
        for (uint i = 0; i < 3 ; i++) {
            result[i] = winningNumber[_drawNumber][i];
        }
    }

    function claimWinningPrize(uint _drawNumber, uint _ticketNumber) public{
        // If the player ticket's Number wins they can claim the winning prize with in the period of Claimed Limit.
        require(userClaimed[_drawNumber][msg.sender][_ticketNumber] == false, "You already claimed the Prize value");
        require(_drawNumber < Draw && _drawNumber >= Draw - claimLimit, "The Draw is not closed yet or claiming period is finished");
        uint blockA = userBets[_drawNumber][msg.sender][_ticketNumber].blockA;
        uint blockB = userBets[_drawNumber][msg.sender][_ticketNumber].blockB;
        uint blockC = userBets[_drawNumber][msg.sender][_ticketNumber].blockC;
        uint winNumA = winningNumber[_drawNumber][0];
        uint winNumB = winningNumber[_drawNumber][1];
        uint winNumC = winningNumber[_drawNumber][2];
        address payable winner = userBets[_drawNumber][msg.sender][_ticketNumber].user;
        if (blockA == winNumA && blockB == winNumB && blockC == winNumC){
            uint wonAmount3 = userBets[_drawNumber][msg.sender][_ticketNumber].betAmount * ThreeDigitWinningTimes;
            if (wonAmount3 > uint(amountInLot[_drawNumber])){
            getGameBalance(wonAmount3, contractAddress);
            winner.transfer(wonAmount3);
            emit LogWinnerClaim(_drawNumber, msg.sender, wonAmount3);
            } else{
                winner.transfer(wonAmount3);
                amountInLot[_drawNumber] -= int(wonAmount3);
                userClaimed[_drawNumber][msg.sender][_ticketNumber] = true;
                emit LogWinnerClaim(_drawNumber, msg.sender, wonAmount3);
            }
        } else if (blockB == winNumB && blockC == winNumC){
            uint wonAmount2 = userBets[_drawNumber][msg.sender][_ticketNumber].betAmount * TwoDigitWinningTimes;
            if (wonAmount2 > uint(amountInLot[_drawNumber])){
            getGameBalance(wonAmount2, contractAddress);
            winner.transfer(wonAmount2);
            emit LogWinnerClaim(_drawNumber, msg.sender, wonAmount2);
            } else{
                winner.transfer(wonAmount2);
                amountInLot[_drawNumber] -= int(wonAmount2);
                userClaimed[_drawNumber][msg.sender][_ticketNumber] = true;
                emit LogWinnerClaim(_drawNumber, msg.sender, wonAmount2);
            }
        } else if (blockC == winNumC){
            uint wonAmount1 = userBets[_drawNumber][msg.sender][_ticketNumber].betAmount * OneDigitWinningTimes;
            if (wonAmount1 > uint(amountInLot[_drawNumber])){
            getGameBalance(wonAmount1, contractAddress);
            winner.transfer(wonAmount1);
            emit LogWinnerClaim(_drawNumber, msg.sender, wonAmount1);
            } else{
                winner.transfer(wonAmount1);
                amountInLot[_drawNumber] -= int(wonAmount1);
                userClaimed[_drawNumber][msg.sender][_ticketNumber] = true;
                emit LogWinnerClaim(_drawNumber, msg.sender, wonAmount1);
            }
        } else {
            revert("You didn't won this lottery");
        }
    }
}