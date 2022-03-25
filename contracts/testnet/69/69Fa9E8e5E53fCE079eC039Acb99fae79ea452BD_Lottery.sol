/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

contract Lottery{

    // адрес игрока сделавшего последнюю ставку
    address lastPlayer;
    // время когда была сделана последняя ставка
    uint timeOfLastBid;
    // эта перменная нужна, чтобы один и тот же человек не смог вытащить весь банк
    // за несколько вызовов функции withdraw()
    // true - победитель забрал выигрыш
    // false - победитель не забрал выигрыш
    bool winnerGetEth;

    constructor(){
        winnerGetEth = false;
    }

    // функция для внесения ставки
    function bet()external payable{
        // проверяем, что размер ставки не менее 1% от общей ставки
        require(msg.value >= address(this).balance / 100, "The bet is too low");

        lastPlayer = msg.sender;
        timeOfLastBid = block.timestamp;

        // новая ставка - новая игра
        // полученный ранее выигрыш был за предыдущую игру
        if(winnerGetEth == true){
            winnerGetEth = false;
        }
    }

    // функция для вывода выигрыша
    function withdraw()external{
        // проверка,
        // что с последней ставки прошло больше часа
        require(timeOfLastBid + 1 hours < block.timestamp, "The hour hasn't passed yet");
        // что деньги хочет вывести победитель
        require(msg.sender == lastPlayer, "You are not a winner");
        // и победитель ещё не забрал свой выигрыш
        require(winnerGetEth == false, "You've already taken your winnings");
        // отправка на адрес победителя его выигрыша - 90% баланса контракта
        payable(lastPlayer).transfer(address(this).balance - address(this).balance / 10);
        // запоминаем, что выигрыш выдан победителю
        winnerGetEth = true;
    }
}