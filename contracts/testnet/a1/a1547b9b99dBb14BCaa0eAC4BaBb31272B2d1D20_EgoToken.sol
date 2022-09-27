/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: GPL-3.0

// Указываем ^, чтобы зафиксировать верстю компилятора

/* 
    Общий code-style:
        
    Pragma statements
    Import statements
    Interfaces
    Libraries
    Contracts
*/


pragma solidity ^0.8.13;

/*
    Интерфейс стандарта ERC-20:
    totalSupply()
    balanceOf(account)
    transfer(recipient, amount)
    allowance(owner, spender)
    approve(spender, amount)
    transferFrom(sender, recipient, amount)

    Добавляем расширение:
    name()
    symbol()
    decimals()
*/

interface IERC20 {
 
    // Возвращаем символ токена. Возвращает строку.
    function symbol() external view returns (string memory);

    // Возвращаем название токена. Возвращает строку.
    function name() external view returns (string memory);

    // Возвращаем количество знаков после запятой. Возвращает число.
    function decimals() external view returns (uint8);

    // Возвращаем общее количество токенов. Возвращает число.
    function totalSupply() external view returns (uint256);

    // Возвращаем баланс токенов на адресе. Возвращает число. 
    function balanceOf(address account) external view returns (uint256);

    /* 
        Отправка токенов на адрес получателя. 
        Возвращает true, если transfer успешен.
        Вызывает событие трансфер, это то, что можно видеть в логах блокчейна через web3.getPastLogs()
    */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /*
        Возвращает остаток токенов (число), которые доступны для траты сторонним адресом.
        По дефолту всегда будет ноль, пока не будут вызван approve
        Например, когда человек хочет продать 1 EGO на панкейке, 
        роутер панкейка запросит разрешение. Когда дается доступ, то роутер 
        панкейка будет вызывать метод trasnferFrom ниже и обменивать EGO на BNB\BUSD и т.д.
    */
    function allowance(address owner, address spender) external view returns (uint256);

    /*
        Устанавливает предел количества токенов, возможных для траты через сторонний адрес.
        Возвращаем true, если вызов был успешный.
        Вызывает событие Approval.  
    */
    function approve(address spender, uint256 amount) external returns (bool);

    /*
        Пересылает токены с адреса отправителя на адрес получателя. 
        Количество пересланных токенов вычитается из количества доступных 
        через allowance токенов для инициатора транзакции.
        Если операция прошла успешна, то возвращается true.
        Вызывается события transfer
    */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /*
        Стандарт ERC20. Количество токенов для трансфер может быть 0.
        Если отсутствуют эти события, то код скомпилируется, 
        но блокчейн эксплореры и price screeners не увидят в логах блокчайна эти события,
        поэтому они необходимы.
    */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /*
        см. выше. 
        Значение при вызове события - количество доступных токенов в allowance.
    */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/*
    За счет этого абстрактного контракта получаем актуальную информацию о sender и сама data.
    В целом можно получать напрямую, но как описано в openzeppelin, в случае с метатранзакциями 
    msg.sender/msg.data могут быть не настоящими:
    подробнее - https://forum.openzeppelin.com/t/help-understanding-contract-context/10579/2
*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/*
    Базовый модуль для ролевой модели.
    Нужен для модификатора onlyOwner. Например, когда происходит минт, 
    чтоб только владелец мог это делать и т.д.
    Для текущего контракта не очень нужен (нет функций который бы только владелец вызывал), 
    но этот модуль вставляют все.
*/
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Во время деплоя инициализируем деплоера как владельца контракта.
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    // Возвращаем текущего владельца токена. Возвращает адрес eth.
    function owner() public view virtual returns (address) {
        return _owner;
    }

    //см. выше. про модицикаторы
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // Убираем владельца токена: делаем владельцем токена нулевой адрес
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // Передаем владельца токена: делаем владельцем токена другой адрес, который укажем, отличный от нулевого
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/*
    Основной контракт EGO токена,
    конструктор выносим
*/
contract EgoToken is Context, Ownable, IERC20 {
    // создаем словари key : value. Аналогично dict в js
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;


    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /*
      При деплое задаем название и символ токена. Предложение и decimals фиксированы:
      1 млрд и 18 decimals
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

        /*
            Вызываем минт 1 млрд токенов на адрес деплоера.
            Внутри минт также будет вызвано событие transfer.
            В итоге общее предложение увеличится на миллиард и токены будут на адресе деплоера.
        */
        _mint(msg.sender, 1_000_000_000 * 10 ** decimals());
    }

    // Возвращаем имя токена
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    // Возвращаем символ токена
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    // Возвращаем decimals токена
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    // Возвращаем total supply токена
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    // Возвращаем баланс токена для адреса
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /* 
        Функция трансфер, см. интерфейсы выше.
        Получатель не может быть нулевым адресом.
        У того кто вызывает функцию должен быть баланс не меньше того, что хочет отправить
    */

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /*
        см. описание интерфейсов
    */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /*
        см. описание интерфейсов
        отправитель не может быть нулевым адресом
    */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /*
        получатель и отправитель не могут быть нулевыми адресами.
        у отправителя должен быт не меньший баланс.
        тот кто инициировал вызывал функцию (например, роутер панкейка) 
        должен иметь allowance не меньше токенов для пересылки
    */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /*
        Аналог approve, позволяет избежать проблем как описано здесь: 
        https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        Дает доступ. см. описание интерфейсов.

        Spender не может быть нулевым адресом
    */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /*
        Аналог approve, позволяет избежать проблем как описано здесь: 
        https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        Сокращает доступ. см. описание интерфейсов.

        Spender не может быть нулевым адресом
    */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /** @notice Отправка токенов с адреса контракта
     * @param _token Адрес токена, которые необходимо отправить
     * @param _receiver Адрес получателя.
     * @param _amount Количество токенов.
     */
    function withdrawToken(
        address _token,
        address _receiver,
        uint256 _amount
    ) external onlyOwner {
        require(_receiver != address(0), "Invalid receiver address");

        IERC20(_token).transfer(_receiver, _amount);
    }


    /*
        Внутренняя функция траснферов, через нее можно будет добавить отправку на многих.
    */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /*
        Функция минт, доступна только внутри смартконтратка, не вызывается извне.
        Минтить на нулевой адрес нельзя.
    */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /*
        Функция burn.
        Адрес не может быть нулевым, и на балансе должно быть не меньше токенов.
    */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /*
        Внутренняя функция approve, через нее можно реализовывать механику автоматического изменения allowance.
    */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}