// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Token {
    function transfer(address, uint)public returns(bool){}
    function transferFrom(address,address,uint)public returns(bool){}
    function balanceOf(address)public view returns(uint){}
}

contract Lending {
    uint public loanTime; //время, на которое выдается ссуда
    uint ratio = 2; //во сколько раз залог должен быть больше ссуды
    Token busd; //токены залога
    Token wbnb; //токены ссуды
    uint rate = 12; //заемщик должен вернуть долг 12%
    uint awardForLiquidation = 1; //ликвидатор получает 1% залога
    mapping (address => uint) deposit;
    mapping (address => uint) loan;
    mapping (address => uint) time;

    constructor(address BUSD_addr, address WBNB_addr, uint _loanTime) {
        busd=Token(BUSD_addr);
        wbnb=Token(WBNB_addr);
        loanTime = _loanTime;
    }

    function borrow(uint _deposit, uint _loan) public {
        //либо ссуда еще не бралась, либо был вызван repay
        require(time[msg.sender] == 0, "This address already has a loan");
        //нельзя запросить нулевую ссуду и ссуду, превашающую баланс контракта
        require(_loan > 0, "Zero loan");
        require(wbnb.balanceOf(address(this)) >= _loan, "Not enough tokens for loan");
        //ограничение залога размером ссуды и балансом отправителя
        require(_deposit >= ratio*_loan, "Deposit must be at least twice the amount of the loan");
        require(busd.balanceOf(msg.sender) >= _deposit, "Not enough tokens for deposit");
        //забираем залог
        busd.transferFrom(msg.sender, address(this), _deposit);
        deposit[msg.sender] = _deposit;
        //выдаем ссуду
        wbnb.transfer(msg.sender, _loan);
        loan[msg.sender] = _loan;
        //запоминаем время займа
        time[msg.sender] = block.timestamp;
    }

    function repay() public {
        //нельзя вернуть ссуду, если не вызывался borrow
        require(time[msg.sender] != 0, "This address doesn't have a loan");
        uint lendingTime = block.timestamp - time[msg.sender]; //время пользования ссудой
        require(lendingTime <= loanTime, "Loan time's up");
        uint amountOfRepay = loan[msg.sender] + loan[msg.sender]*rate/100; //размер долга
        require(wbnb.balanceOf(msg.sender) >= amountOfRepay, "Not enough tokens for repay");
        //возврат долга
        wbnb.transferFrom(msg.sender, address(this), amountOfRepay);
        loan[msg.sender] = 0;
        //возврат залога
        busd.transfer( msg.sender, deposit[msg.sender]);
        deposit[msg.sender] = 0;

        time[msg.sender] = 0;
    }

    function liquidate(address borrower) public {
        require(msg.sender != borrower, "You can't liquidate your own loan");
        require(time[borrower] != 0, "This address doesn't have a loan");
        require(block.timestamp - time[borrower] > loanTime, "Time for using the loan hasn't expired yet");
        //обнуление ссуды
        loan[borrower] = 0;
        //отправка награды
        uint award = deposit[borrower]*awardForLiquidation/100;
        busd.transfer(msg.sender, award);
        deposit[borrower] = 0;

        time[borrower] = 0;
    }
}