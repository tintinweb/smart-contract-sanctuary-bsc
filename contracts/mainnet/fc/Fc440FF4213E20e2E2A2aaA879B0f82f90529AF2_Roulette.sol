/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

contract Roulette {

    enum betName {zero, odd, even }    
    struct Game{
        uint balanceTotal;
        uint result;
        uint participant;
        mapping (address=>uint) balanceBet;
        mapping (address=>uint) betNumber;
        mapping (address=>uint) possibleWin;
        mapping (address=>betName) bet;
        mapping (address=>bool) isBet;
        mapping (uint=>address) addressIdBet;
        uint balanceOdd;
        uint balanceEven;
        uint balanceZero;
    }
    address payable owner;

    uint balanceTax;
    uint public idGame;
    mapping (uint => Game) games;

    mapping (address => uint[]) gamesWin;

    bool public gameEnable;

    event LastGameId(uint resultGame);
    event BalanceTotal(uint totalBalance);
    event BalanceBet(uint Odd, uint Even,uint Zero);

    constructor() {
        owner = payable(msg.sender);
        gameEnable = false;
    }

    function searchResult(uint _idGame) public view returns (uint) {
        Game storage g = games[_idGame];
        return g.result;
    }

    function setResult(uint _numberResult) private {
        Game storage g = games[idGame];
        g.result = _numberResult;
    }

    function launchNewGame() public {
        require(msg.sender == owner && gameEnable == true);
        Game storage g = games[idGame + 1];
        require(g.participant >= 1, 'No participant');
        idGame++;
        uint numberResult = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,idGame))) % 15 + 1;
        setResult(numberResult);
        emit LastGameId(numberResult);
        emit BalanceBet(0, 0, 0);
        correctBet(idGame);
    }

    function withdraw(address _address) public payable {
        require(msg.sender == owner);
        payable(_address).transfer(address(this).balance);
    }

    function betNextGame(uint _bet) public payable {
        require(_bet <= 15 && _bet != 0 && gameEnable == true);
        require(msg.value >= 1 ether / 1000, 'Your bet is under 0.001');
        Game storage g = games[idGame + 1];
        require(g.isBet[msg.sender] == false,'Caller already bet');
        uint tax = (msg.value / 100);
        balanceTax += tax;
        g.balanceBet[msg.sender] = msg.value - tax;
        if(_bet == 15) {
            g.bet[msg.sender] = betName.zero;
            g.possibleWin[msg.sender] += g.balanceBet[msg.sender] * 14;
            g.balanceZero += msg.value;
        } else if (_bet % 2 == 0) {
            g.bet[msg.sender] = betName.even;
            g.possibleWin[msg.sender] += g.balanceBet[msg.sender] * 2;
            g.balanceEven += msg.value;
        } else {
            g.bet[msg.sender] = betName.odd;
            g.possibleWin[msg.sender] += g.balanceBet[msg.sender] * 2;
            g.balanceOdd += msg.value;
        }
        g.betNumber[msg.sender] = _bet;
        g.isBet[msg.sender] = true;
        emit BalanceBet(g.balanceOdd, g.balanceEven, g.balanceZero);
        calculateGame(idGame + 1, msg.value);
    }

    function correctBet(uint _idGame) private {
        Game storage g = games[_idGame];
        for(uint i = 0; i <= g.participant; i++) {
            if(g.betNumber[g.addressIdBet[i]] == g.result) {
                gamesWin[g.addressIdBet[i]].push(_idGame);
            } else if (g.betNumber[g.addressIdBet[i]] % 2 == g.result % 2 && g.result == 15) {
                continue;
            } else if (g.betNumber[g.addressIdBet[i]] % 2 == g.result % 2 && g.betNumber[g.addressIdBet[i]] != 15 && g.result != 15) {
                gamesWin[g.addressIdBet[i]].push(_idGame);
            }
        }
    }

    function getGamesWin(address _address) public view returns(uint[] memory) {
        return gamesWin[_address];
    }

    function balanceTaxed() public view returns (uint){
        return balanceTax;
    }

    function calculateGame(uint _idGame,uint _reward) private {
        Game storage g = games[_idGame];
        g.balanceTotal += _reward;
        g.participant += 1;
        g.addressIdBet[g.participant] = msg.sender;
        emit BalanceTotal(g.balanceTotal);
    }

    function rewardGame(uint _idGame) public {
        Game storage g = games[_idGame];
        require(g.betNumber[msg.sender] <= 15 && g.betNumber[msg.sender] != 0);
        require(g.balanceBet[msg.sender] != 0);
        address payable winner = payable(msg.sender);
        if(g.result == 15 && g.result == g.betNumber[msg.sender]){
            winner.transfer(g.possibleWin[msg.sender]);
        } else if (g.result % 2 == 0 && g.result % 2 == g.betNumber[msg.sender] % 2 && g.result != 15) {
            winner.transfer(g.possibleWin[msg.sender]);
        } else if (g.result % 2 == 1 && g.result % 2 == g.betNumber[msg.sender] % 2 && g.result != 15) {
            winner.transfer(g.possibleWin[msg.sender]);
        }
        removeByValue(_idGame);
    }

    function rewardAllGames() public {
        for(uint i=0; i < gamesWin[msg.sender].length; i++){
            Game storage g = games[gamesWin[msg.sender][i]];
            require(g.betNumber[msg.sender] <= 15 && g.betNumber[msg.sender] != 0);
            require(g.balanceBet[msg.sender] != 0);
            address payable winner = payable(msg.sender);
            if(g.result == 15 && g.result == g.betNumber[msg.sender]){
                winner.transfer(g.possibleWin[msg.sender]);
            } else if (g.result % 2 == 0 && g.result % 2 == g.betNumber[msg.sender] % 2 && g.result != 15) {
                winner.transfer(g.possibleWin[msg.sender]);
            } else if (g.result % 2 == 1 && g.result % 2 == g.betNumber[msg.sender] % 2 && g.result != 15) {
                winner.transfer(g.possibleWin[msg.sender]);
            }
        }
        delete gamesWin[msg.sender];
    }

    function privatePayable(uint _amount) public {
        require(owner == msg.sender);
        balanceTax -= _amount;
        owner.transfer(_amount);
    }

    function infoGameid(uint _idGame) public view returns (uint, uint ,uint, uint ,uint ,uint) {
        Game storage g = games[_idGame];
        return(g.balanceTotal, g.result, g.participant, g.balanceOdd, g.balanceEven, g.balanceZero);
    }

    function find(uint value) private view returns(uint) {
        uint i = 0;
        while (gamesWin[msg.sender][i] != value) {
            i++;
        }
        return i;
    }

    function removeByValue(uint value) private {
        uint i = find(value);
        removeByIndex(i);
    }

    function removeByIndex(uint i) private {
        while (i<gamesWin[msg.sender].length-1) {
            gamesWin[msg.sender][i] = gamesWin[msg.sender][i+1];
            i++;
        }
        gamesWin[msg.sender].pop();
    }

    function pauseGame() public {
        require(owner == msg.sender);
        gameEnable = false;
    }

    function resumeGame() public {
        require(owner == msg.sender);
        gameEnable = true;
    }

    function whatIsBet(uint _idGame) public view returns (betName, uint, uint){
        Game storage g = games[_idGame];
        return (g.bet[msg.sender], g.betNumber[msg.sender], g.balanceBet[msg.sender]);
    }

    function partipantInGame(uint _idGame) public view returns(uint) {
        Game storage g = games[_idGame];
        return g.participant;
    }
}