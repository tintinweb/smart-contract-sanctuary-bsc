/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// File: contracts/MWGH.sol

pragma solidity 0.8.4;
 
/*
@title TestBEP20Token
@dev Приклад простого BEP-20 токена, в якому
всі токени спочатку призначені автору.
Зверніть увагу, що пізніше автор може
розподіляти токени на свій розсуд,
використовуючи “transfer” та інші функції BEP-20
НЕОБХІДНО МОДИФІКУВАТИ ПЕРЕД ВИПУСКОМ.
ВИКОРИСТОВУВАТИ ВИКЛЮЧНО В ОЗНАКОМНИХ ЦІЛЯХ.
*/
 
   contract TestBEP20Token {
   string public name = "MegaWIN Game Hub Token";
   string public symbol = "MWGH";
   uint256 public totalSupply = 10000000000000000000000000000;
   // 10 мілліардів
   uint8 public decimals = 18;
   
    /*
    @dev Генерується, коли `value` токенів
    передаються з одного акаунта (`from`) на інший (`to`).
    Значення `value` може дорівнювати нулю.
    */
     
   event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    /*
    @dev Генерується коли `spender` для `owner`
    встановлюється викликом {approve}. `value` - новий резерв.
    */
     
   event Approval(
       address indexed _owner,
       address indexed _spender,
       uint256 _value
   );
   mapping(address => uint256) public balanceOf;
   mapping(address => mapping(address => uint256)) public allowance;
    
    /*
@dev Конструктор, що дає msg.sender всі існуючі токени.
    */
     
   constructor() {
       balanceOf[msg.sender] = totalSupply;
   }
    
    /*
@dev Передає `amount` токенів
    від зухвалого акаунта до `recipient`.
      
    Повертає бульове значення про успіх транзакції.
      
    Видає подію {Transfer}.
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
   @dev Встановлює `amount` як допуск `spender` до токенів зухвалого.
      
    Повертає бульове значення про успіх транзакції.
      
    ВАЖЛИВО: Майте на увазі, що зміна дозволу
    за допомогою цього методу пов'язано з ризиком того, що
    хтось може використовувати як старе, так і нове
    дозвіл через невдалий порядок транзакцій.
    Одне з можливих рішень для пом'якшення цього
    стану гонки - спочатку зменшити допуск spender'a до 0,
    а потім встановити бажане значення.
      
    Видає подію {Approval}.
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
    @dev Передає `amount` токенів від `sender` до `recipient`
    використовуючи механізм резерву. `amount` віднімається з резерву зухвалого.
      
    Повертає бульове значення про успіх транзакції.
      
    Видає подію {Transfer}.
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