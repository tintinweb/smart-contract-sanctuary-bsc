/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract Shuffle {
    /*
        variables globals
    */
    address owner;
    bool gameOn;
    bool gamePause;
    uint256 round;

    uint256 prize;

    uint256 ticketPrice;
    uint256 ticketsCurrentNumber;

    uint256 percentageOwner;
    uint256 percentageWinner;

    uint256 playersMax;
    uint256 playersCurrentNumber;
    uint256 [] playersTimeTracker;
    mapping (address => bool) playersAddressTracker;
    mapping (uint => Player) playersCurrent;
    struct Player {
        uint _timestamp;
        address _address;
        uint256 _value;
        uint256 _tickerNumbers;
        uint256 _tickerStart;
        uint256 _tickerEnd;
    }

    /*
        events -
    */
    event __roundStart(uint256 round, uint256 playersMax);
    event __roundEnd(uint256 round, address winnerAddress, uint256 winnerAmount);
    event __roundPlayersComplete(uint256 round, uint256 playersMax, uint256 playersCurrentNumber, uint256 ticketsCurrentNumber);
    event __tickerBuy(uint256 round, address addressBuy, uint256 amount, uint256 tickerNumbers, uint256 tickerStart, uint256 tickerEnd);
    event __setPlayersMax(uint256 playersMax);
    event __setPercentageChange(uint256 percentageWinner, uint256 percentageOwner);

    /*
        modifier
    */

    modifier ownerRequired() {
        require(owner == msg.sender, "No eres el dueno del contrato");
        _;
    }

    modifier gameOnRequired() {
        require(gameOn, "No hay juego en curso");
        _;
    }

    modifier gameStopRequired() {
        require(!gameOn, "Hay un juego en curso");
        _;
    }

    modifier playersMinRequired() {
        require(playersCurrentNumber <= (playersMax - 1), "Ya esta el maximo de jugadores");
        _;
    }

    modifier playersMaxRequired() {
        require(playersCurrentNumber >= playersMax, "No esta el maximo de jugadores");
        _;
    }


    modifier tickerPriceMinRequired() {
        require(msg.value >= ticketPrice, "No estas enviando el valor minimo de entrada");
        _;
    }

    /*
        constructor - 
    */

    constructor() payable {
        owner = msg.sender;
        gameOn = true;
        round = 1;
        prize = msg.value;
        ticketPrice = 100000000000000000;
        ticketsCurrentNumber = 0;
        percentageOwner = 7;
        percentageWinner = 95;
        playersMax = 3;
        playersCurrentNumber = 0;
    }

    /* Setters */
    function setRoundStart() public ownerRequired gameStopRequired {
        gameOn = true;
        emit __roundStart(round, playersMax);
    }

    function setRoundEnd(address winnerAddress) public payable ownerRequired playersMaxRequired  {
        round += 1;
        ticketsCurrentNumber = 0;
        playersReset();
        gameOn = false;

        // round payment
        uint256 winnerAmount;
        uint256 payOwner;
        winnerAmount = (prize / 100) * percentageWinner;
        payOwner = (prize / 100) * percentageOwner;
        payable(winnerAddress).transfer(winnerAmount);
        payable(owner).transfer(payOwner);
        prize = 0;
        emit __roundEnd(round, winnerAddress, winnerAmount);
    }

    function setPlayersMax(uint256 _playersMax) public ownerRequired gameStopRequired {
        playersMax = _playersMax;
        emit __setPlayersMax(playersMax);
    }

    function setPercentage(uint256 _percentage) public ownerRequired gameStopRequired {
        require(_percentage <= 100, "El porcentage debe ser >= 100");
        percentageWinner = _percentage;
        percentageOwner = 100 - _percentage;
        emit __setPercentageChange(percentageWinner, percentageOwner);
    }

    /*
        game -
    */

    function gameInfo() public view returns (bool, uint256, uint256, uint256, uint256, uint256, uint256) {
        return (gameOn, round, prize, ticketPrice, playersMax, playersCurrentNumber, ticketsCurrentNumber);
    }

    /*
        ticker -
    */
    function tickerSetPrice(uint256 _price) public ownerRequired gameStopRequired {
        ticketPrice = _price;
    }

    function tickerBuy() public payable gameOnRequired playersMinRequired tickerPriceMinRequired {
        uint256 tickerN = msg.value / ticketPrice;
        uint256 tickerS = ticketsCurrentNumber + 1;
        uint256 tickerE = ticketsCurrentNumber + tickerN;
        
        ticketsCurrentNumber += tickerN;
        prize += msg.value;
        emit __tickerBuy(round, msg.sender, msg.value, tickerN, tickerS, tickerE);

        playerSet(msg.sender, msg.value, tickerN, tickerS, tickerE);
    }

    /*
        players -
    */

    function playersGet() public view returns(Player[] memory) {
        Player[] memory playersAll = new Player[](playersTimeTracker.length);

        for (uint i = 0; i < playersTimeTracker.length; i++) {
            Player memory _gplayer = playersCurrent[playersTimeTracker[i]];

            playersAll[i] = _gplayer;
        }

        return playersAll;
    }
    
    function playerSet(address _address, uint256 _value, uint256 _tickerN, uint256 _tickerS, uint256 _tickerE) internal {
        uint256 time = block.timestamp;
        playersCurrent[time] = Player(time, _address, _value, _tickerN, _tickerS, _tickerE);
        playersTimeTracker.push(time);

        if(!playersAddressTracker[_address]) {
            playersCurrentNumber++;
        }

        playersAddressTracker[_address] = true;

        if (playersCurrentNumber >= playersMax) {
            emit __roundPlayersComplete(round, playersMax, playersCurrentNumber, ticketsCurrentNumber);
        }
    }


    function playersReset() internal {
        for (uint i = 0; i < playersTimeTracker.length; i++) {
            delete playersAddressTracker[playersCurrent[playersTimeTracker[i]]._address];
        }

        for (uint i = 0; i < playersTimeTracker.length; i++) {
            delete playersCurrent[playersTimeTracker[i]];
        }

        playersCurrentNumber = 0;
        delete playersTimeTracker;  
    }
}