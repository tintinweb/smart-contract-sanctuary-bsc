/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity 0.8.4;

contract Token {
    address payable public owner = payable(msg.sender);
    string public name = "GraduationToken";
    string public symbol = "GRT";
    uint256 public totalSupply = 0;
    uint8 public decimals = 4;
  
    /*
    Створюється, коли токени передаються з одної адреси до іншої.
    */
	
    event Transfer(
    address indexed _from, 
    address indexed _to, 
    uint256 _value
    );
   
    /*
    Генерується після виклику (approve), для підтвердження.

    Від _spender до _owner.
    */
	
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

  
    //Створює відображення з усіма залишками.
    
    mapping(address => uint256) public balanceOf;
   
    //Створює відображення з усіма надбавками.

    mapping(address => mapping(address => uint256)) public allowance;

   
    /*
    Передає кількість токенів від адреса виклику до адреси отримувача.
    
    Повертає булеве значення про успіх транзакції.
    
    Викликає подію (Transfer).
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
    Встановлює кількість токенів `spender` до токенів викликаючого.
    
    Повертає булеве значення про успіх транзакції.
    
    Викликає подію (Approval).
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
    Передає кількість токенів від відправника до отримувача, використовуючи механізм резерву.
    
	Повертає булеве значення про успіх транзакції.
    
    Викликає подію (Transfer).
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

    /*
    Мінтить кількість токенів на адресу.

    Виконується лише власником контракту.
    */

    function mint(uint256 _amount, address _to) public returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");

        totalSupply += _amount;
        balanceOf[_to] += _amount;

        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /*
    Спалює кількість токенів.

    Виконується з адреси відправника.
    */

    function burn(uint256 _amount) public returns (bool success) {
      require(msg.sender != address(0), "Invalid burn recipient");

      uint256 accountBalance = balanceOf[msg.sender];
      require(accountBalance > _amount, "Burn amount exceeds balance");

      balanceOf[msg.sender] -= _amount;
      totalSupply -= _amount;

      emit Transfer(msg.sender, address(0), _amount);
      return true;
    }
}