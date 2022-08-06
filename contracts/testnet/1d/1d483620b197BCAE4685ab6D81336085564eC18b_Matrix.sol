/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.15;

struct User {
    uint id;
    uint regTime;
    address referrer;
    uint referrals;
    uint rewards;
}

struct ContractInfo {
    address ownerAddr;
    address marketingAddr;
    address insuranceAddr;
}

struct ContractStat {
    uint users;
    uint turnover;
}

struct Fees {
    uint16 insurance;
    uint16 marketing;
}

struct Rewards {
    uint round;
    uint referrer;
}

struct Table {
    uint8 id;
    uint turnover;
    uint price;
    uint queueHead;
    uint queueSize;
    mapping(uint => address) queue;
    mapping(address => uint) rounds;
}

contract Matrix {
    // Объявляем константы
    uint16 constant PERCENT_DIVIDER = 1000;

    // Объявляем структуры
    ContractInfo contractInfo;
    ContractStat contractStat;
    Fees fees;
    Rewards rewards;

    // Объявляем массивы
    mapping(address => User) users;
    mapping(uint8 => Table) tables;

    // Объявляем эвенты
    event UserRegistration(uint regTime, address indexed addr, uint userid, uint referrerid);
    event BuyTable(uint buyTime, uint8 indexed tableid, address indexed addr);
    event SendTableReward(uint8 indexed tableid, address indexed to, uint reward);
    event SendReferrerReward(uint8 indexed tableid, address indexed to, uint reward);
    event SendInsuranceFee(uint8 indexed tableid, uint reward);
    event SendMarketingFee(uint8 indexed tableid, uint reward);
    event SendReversePayment(uint8 indexed tableid, address indexed to, uint diff);

    constructor() {
        // Инициализируем стату
        contractStat.users = 0;
        contractStat.turnover = 0;

        // Устанавливаем адрес админа, куда перечислять комсу и куда переводить страховку
        contractInfo.ownerAddr = payable(msg.sender);
        contractInfo.marketingAddr = payable(msg.sender);
        contractInfo.insuranceAddr = payable(msg.sender);

        // Регистрируем юзера для админа
        registerUser(address(0));

        // Устанавливаем комиссии
        fees.insurance = 200;
        fees.marketing = 50;

        // Устанавливаем награды
        rewards.round = 650;
        rewards.referrer = 100;

        // Добавляем столы
        _addTable(1, 0.1 ether);
        _addTable(2, 0.13 ether);
        _addTable(3, 0.17 ether);
        _addTable(4, 0.22 ether);
        _addTable(5, 0.25 ether);
        _addTable(6, 0.325 ether);
        _addTable(7, 0.45 ether);
        _addTable(8, 0.58 ether);
        _addTable(9, 0.75 ether);
        _addTable(10, 1 ether);
        _addTable(11, 1.6 ether);
        _addTable(12, 2.5 ether);
        _addTable(13, 4 ether);
        _addTable(14, 6.4 ether);
        _addTable(15, 10 ether);
    }

    // Добавляем стол
    function _addTable(uint8 id, uint price) private {
        // Объявляем в хранилище структуру стола
        Table storage table = tables[id];

        // Заполняем эту структуру
        table.id = id;
        table.price = price;
        table.turnover = 0;
        table.queueHead = 0;
        table.queueSize = 0;
    }

    // Регистрируем нового юзера
    function registerUser(address referrer) public {
        // Юзер не должен быть уже зарегестрирован
        require(!isUserRegistered(msg.sender), "User is already registered");

        // Если новый юзер - админ, то выставляем нулевой адрес для рефера
        // Если адрес рефера не указан, то ставим рефера админом
        // Если такого рефера нет среди юзеров, то возвращаем ошибку
        if(msg.sender == contractInfo.ownerAddr){
            referrer = address(0);
        } else if(referrer == address(0)){
            referrer = contractInfo.ownerAddr;
        } else {
            require(isUserRegistered(referrer), "Referrer is not registered");
        }

        // Добавляем юзера в базу
        uint regTime = block.timestamp;
        users[msg.sender] = User({
            id: contractStat.users + 1,
            regTime: regTime,
            referrer: referrer,
            referrals: 0,
            rewards: 0
        });

        // Увеличиваем счетчик кол-ва рефералов у рефера и счетчик кол-ва юзеров
        users[referrer].referrals = users[referrer].referrals + 1;
        contractStat.users = contractStat.users + 1;

        // Создаем эвент о регистрации
        emit UserRegistration(regTime, msg.sender, users[msg.sender].id, users[referrer].id);
    }

    // Покупаем стол
    function buyTable(uint8 id) public payable {
        // Получаем стол
        Table storage table = tables[id];

        // Проверяем
        // Что достаточно денег для покупки
        require(msg.value >= table.price, "Not enough money to buy a table");
        // Что пользователь зарегестрирован
        require(isUserRegistered(msg.sender), "User not registered");
        
        // Добавляем адрес в очередь
        uint buyTime = block.timestamp;

        // Если у юзера остались круги то увеличиваем их количество на 2, если кругов больше нет добавляем в конец очереди
        if (table.rounds[msg.sender] == 0){
            // Записываем юзера в конец очереди
            table.queue[table.queueSize] = msg.sender;
            // Увеличиваем размер очереди на 1
            table.queueSize = table.queueSize + 1;
            // Записываем, что у юзера есть еще 1 круг
            table.rounds[msg.sender] = 1;
        } else {
            // Если у юзера уже есть круги, то добавляем к ним еще 2
            table.rounds[msg.sender] = table.rounds[msg.sender] + 2;
        }
        
        // Выпускаем событие, что кто то купил адрес
        emit BuyTable(buyTime, id, msg.sender);

        // Записываем текущий верх очереди и смещаем его на 1
        uint queueHead = table.queueHead;
        table.queueHead = table.queueHead + 1;

        // Если у юзера из верха очереди остались круги, то записывем его в конец очереди
        if (table.rounds[table.queue[queueHead]] > 0) {
            table.rounds[table.queue[queueHead]] = table.rounds[table.queue[queueHead]] - 1;
            table.queue[table.queueSize] = table.queue[queueHead];
            // Увеличиваем размер очереди на 1
            table.queueSize = table.queueSize + 1;
        }

        // Отправляем награду за круг
        _sendTableReward(id, table.queue[queueHead], table.price*rewards.round/PERCENT_DIVIDER);

        // Отправляем награду реферу
        address referrer = users[table.queue[queueHead]].referrer;
        if (referrer != address(0)){
            _sendReferrerReward(id, referrer, table.price*rewards.referrer/PERCENT_DIVIDER);
        }

        // Отправляем в страховку
        _sendInsuranceFee(id, table.price*fees.insurance/PERCENT_DIVIDER);

        // Отправляем комсу на маркетинг
        _sendMarketingFee(id, table.price*fees.marketing/PERCENT_DIVIDER);

        // Если прислали больше чем стоит уровень, отправляем разницу обратно отправителю
        if (msg.value > table.price) {
             _sendReversePayment(id, msg.sender, (msg.value - table.price));
        }

        // Увеличиваем оборот контракта и стола
        contractStat.turnover = contractStat.turnover + msg.value;
        table.turnover = table.turnover + msg.value;
    }

    // Отправка награды за раунд
    function _sendTableReward(uint8 tableid, address to, uint reward) private {
        bool sendReward = payable(to).send(reward);
        if(sendReward){
            emit SendTableReward(tableid, to, reward);
        }
    }

    // Отправка реферального вознаграждения
    function _sendReferrerReward(uint8 tableid, address to, uint reward) private {
        bool sendReward = payable(to).send(reward);
        if(sendReward){
            emit SendReferrerReward(tableid, to, reward);
        }
    }

    // Отправка в страховой фонд
    function _sendInsuranceFee(uint8 tableid, uint reward) private {
        bool sendFee = payable(contractInfo.insuranceAddr).send(reward);
        if(sendFee){
            emit SendInsuranceFee(tableid, reward);
        }
    }

    // Отправка комсы на маркетинг
    function _sendMarketingFee(uint8 tableid, uint reward) private {
        bool sendFee = payable(contractInfo.marketingAddr).send(reward);
        if(sendFee){
            emit SendMarketingFee(tableid, reward);
        }
    }

    function _sendReversePayment(uint8 tableid, address to, uint diff) private {
        bool sendPayment = payable(to).send(diff);
        if(sendPayment){
            emit SendReversePayment(tableid, to, diff);
        }
    }

    // Выводим данные по юзеру
    function getUser(address addr) public view returns (uint, uint, address, uint, uint) {
        User memory user = users[addr];
        return (
            user.id,
            user.regTime,
            user.referrer,
            user.referrals,
            user.rewards
        );
    }

    // Выводим информацию о контракте
    function getContractInfo() public view returns (address, address, address) {
        return (
            contractInfo.ownerAddr,
            contractInfo.marketingAddr,
            contractInfo.insuranceAddr
        );
    }

    // Выводим статистику по контракту + баланс
    function getContractStat() public view returns (uint, uint, uint) {
        return (
            contractStat.users,
            contractStat.turnover,
            address(this).balance
        );
    }

    // Выводим данные по комиссиям
    function getFees() public view returns (uint, uint) {
        return (
            fees.insurance,
            fees.marketing
        );
    }

    // Воводим данные по столу 
    function getTable(uint8 id) public view returns (uint8, uint, uint, uint, uint) {
        Table storage table = tables[id];
        return (
            table.id,
            table.price,
            table.turnover,
            table.queueHead,
            table.queueSize
        );
    }

    // Проверяем на наличие юзера в базе
    function isUserRegistered(address addr) public view returns (bool) {
        return users[addr].id != 0;
    }
}