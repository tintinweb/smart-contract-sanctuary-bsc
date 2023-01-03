/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

pragma solidity ^0.6.0;

contract Brifetoken {
    // определяем переменные и типы данных
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public commissionRate;

    // определяем мапу для хранения балансов токенов по адресам
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowed;
    // определяем структуру для хранения информации о транзакциях
    struct Transaction {
        address from;
        address to;
        uint256 value;
    }

    // определяем массив для хранения информации о транзакциях
    Transaction[] public transactions;

    // определяем событие для отправки токенов
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // конструктор смарт-контракта
    constructor() public {
        name = "TESTTOKEN3";
        symbol = "TST3";
        decimals = 18;
        totalSupply = 100000000000000000000000000;

        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function distribute(address _to, uint _value) public {
        require(balanceOf[msg.sender] >= _value && _value > 0, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }
    
    function transfer(address _to, uint _value) public {
        require(balanceOf[msg.sender] >= _value && _value > 0, "Insufficient balance");
        require(_to != address(0), "Invalid address");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }
   /*function approve(address _to, uint256 _value) public returns (bool) {
        require(_value <= balanceOf[msg.sender], "Insufficient balance");
        approve[_to][msg.sender] -= _value;
        _to.transfer(_value / 10);
    }   */
    function approve(address spender, uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        // Взимаем дополнительную комиссию у отправителя
        uint256 commission = amount * commissionRate / 100;
        balanceOf[msg.sender] -= commission;
        // Обновляем лимит разрешенного количества токенов для спендера
        allowed[msg.sender][spender] = amount;
        // Уведомляем о транзакции
        emit Approval(msg.sender, spender, amount);
    }
}