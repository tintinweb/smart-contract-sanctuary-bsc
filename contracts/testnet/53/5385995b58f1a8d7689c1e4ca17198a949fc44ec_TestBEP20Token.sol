/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

//SPDX-License-Identifier: UNLISCENSED
 
pragma solidity ^0.8.0;
 
/*
@title TestBEP20Token
@dev Пример простого BEP-20 токена, в котором
все токены изначально назначены создателю.
Обратите внимание, что позже создатель может
распределять токены по своему усмотрению,
используя “transfer” и другие функции BEP-20
НЕОБХОДИМО МОДИФИЦИРОВАТЬ ПЕРЕД ВЫПУСКОМ.
ИСПОЛЬЗОВАТЬ ИСКЛЮЧИТЕЛЬНО В ОЗНАКОМИТЕЛЬНЫХ ЦЕЛЯХ.
*/
 
   contract TestBEP20Token {
   string public name = "TestBEP20Token";
   string public symbol = "STST";
   uint256 public totalSupply = 1000000000000000000000000;
   // 1 миллион
   uint8 public decimals = 18;
   
    /*
    @dev Генерируется, когда `value` токенов 
    передаются с одного аккаунта (`from`) на другой (`to`).
    Значение `value` может быть равно нулю.
    */
     
   event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    /*
    @dev Генерируется когда `spender` для `owner`
    устанавливается вызовом {approve}. `value` — новый резерв.
    */
     
   event Approval(
       address indexed _owner,
       address indexed _spender,
       uint256 _value
   );
   mapping(address => uint256) public balanceOf;
   mapping(address => mapping(address => uint256)) public allowance;
    
    /*
    @dev Конструктор дающий msg.sender все существующие токены.
    */
     
   constructor() {
       balanceOf[msg.sender] = totalSupply;
   }
    
    /*
    @dev Передаёт `amount` токенов
    от вызывающего аккаунта к `recipient`.
    Возвращает булевое значение об успехе транзакции.
    Выдает событие {Transfer}.
    */
     
   function transfer(address _to, uint256 _value)
       public
       returns (bool success)
   {
       require(balanceOf[msg.sender] >= _value);
       balanceOf[msg.sender] -= _value;
       balanceOf[_to] += _value;
       emit Transfer(msg.sender, _to, _value);
       return true;
   }
   
    /*
    @dev Устанавливает `amount` как допуск `spender` к токенам вызывающего.
     
    Возвращает булевое значение об успехе транзакции.
     
    ВАЖНО: Имейте в виду, что изменение разрешения
    с помощью этого метода сопряжено с риском того, что
    кто-то может использовать как старое, так и новое
    разрешение из-за неудачного порядка транзакций.
    Одно из возможных решений для смягчения этого
    состояния гонки — сначала уменьшить допуск spender’a до 0,
    а затем установить желаемое значение.
     
    Выдает событие {Approval}.
    */
     
   function approve(address _spender, uint256 _value)
       public
       returns (bool success)
   {
       allowance[msg.sender][_spender] = _value;
       emit Approval(msg.sender, _spender, _value);
       return true;
   }
    
    /*
    @dev Передает `amount` токенов от `sender` к `recipient`
    используя механизм резерва. `amount` вычитается из резерва вызывающего.
     
    Возвращает булевое значение об успехе транзакции.
     
    Выдает событие {Transfer}.
    */
     
   function transferFrom(
       address _from,
       address _to,
       uint256 _value
   ) public returns (bool success) {
       require(_value <= balanceOf[_from]);
       require(_value <= allowance[_from][msg.sender]);
       balanceOf[_from] -= _value;
       balanceOf[_to] += _value;
       allowance[_from][msg.sender] -= _value;
       emit Transfer(_from, _to, _value);
       return true;
   }
}