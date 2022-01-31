// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >= 0.6.0 < 0.9.0;

import "./Token.sol";
import "./SafeMath.sol";

contract CustomToken is Token  {

    event Emission(uint256 _value);
    
    string  _name1="Astrastack Technology";
    string  _symbol1="ASTRA";
    uint8   _decimals1=18;
    uint256 startSupply1=1000000000;


      constructor  ()
    Token(_name1, _symbol1, _decimals1, startSupply1)  public {}

    /**
     * @dev Token emission
     * @param _value amount of token values to emit
     * @notice receiver balance will be increased by `_value`
     */
    function emission(address receiver, uint256 _value) onlyOwner  public{
        // Overflow check
        if (_value + totalSupply < totalSupply) {
            require(false);
        }
        totalSupply        += _value;
        balances[receiver] += _value;
        emit Emission(_value);
    }

    /**
     * @dev Burn the token values from sender balance and from total
     * @param _value amount of token values for burn
     * @notice sender balance will be decreased by `_value`
     */
    function burn(uint _value)  public{
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            totalSupply          -= _value;
        }
    }



 
    /// @dev Fallback to calling deposit when ether is sent directly to contract.
 
    function buy()  public payable returns (bool)  {
        
        uint256 amount = safeMul(msg.value, rate);
        uint256 feeAmount = safeDiv( safeMul(amount , buytax ) , 100 );
        uint256 amountwithtax = safeSub (amount,feeAmount);
        if (balances[owner] >= amount) {
            balances[owner] -= amount;
            balances[msg.sender]   += amountwithtax;
            balances[taxaddress]   += feeAmount;

            emit Transfer(owner, taxaddress, feeAmount);
            emit Transfer(owner, msg.sender, amountwithtax);
            return true;
        }
        return false;
    }
    

 function sale(uint256 value,address to)  public payable returns (bool)  {
        
        uint256 amount = value;
        uint256 feeAmount = safeDiv( safeMul(amount , saletax ) , 100 );
        uint256 amountwithtax = safeSub (amount,feeAmount);
        if (balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            balances[to]   += amountwithtax;
            balances[taxaddress]   += feeAmount;

            emit Transfer(msg.sender, taxaddress, feeAmount);
            emit Transfer(msg.sender, to, amountwithtax);
            return true;
        }
        return false;
    }
    


    /// @dev Sells tokens in exchange for Ether, exchanging them 1:1.
    /// @param amount Number of tokens to sell.
    function withdraw(uint amount) public payable returns (bool){
 
        if (balances[address(this)] >= amount) {
            balances[address(this)] -= amount;
            balances[msg.sender]   += amount;
            emit Transfer(address(this), msg.sender, amount);
            return true;
        }
        return false;
    }
    /// @notice Fallback function of contract to receive founds
    fallback() external  payable {
            
             
    }

     receive() external payable {
        // custom function code
    }



}