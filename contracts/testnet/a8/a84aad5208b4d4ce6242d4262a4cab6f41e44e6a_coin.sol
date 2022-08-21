/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

pragma solidity >= 0.5.0; 
contract coin {
  string  constant symbol = "PAISAY";
  
  uint _totalSupply = 1000000;
  mapping(address => uint256) balances;
  mapping(address => mapping (address => uint256)) allowed;
  event Approval(address caller, address _spender, uint amount); 
  event Transfer(address caller, address _to, uint amount); 

  function totalSupply() public returns (uint256 theTotalSupply) {
    theTotalSupply = _totalSupply; 
    return theTotalSupply; 
  }

  function balanceOf(address wallet) public returns (uint) {
    return balances[wallet];
  }

  function approve(address _spender, uint256 _amount)public returns (bool success) {
    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

  function transfer(address _to, uint256 _amount) public returns (bool success) {

    if (balances[msg.sender] >= _amount 
      && _amount > 0) {
      balances[msg.sender] -= _amount;
      balances[_to] += _amount;
      emit Transfer(msg.sender, _to, _amount);
        return true;
      } else {
        return false;
      }
   }

   function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
    if (balances[_from] >= _amount
      && allowed[_from][msg.sender] >= _amount
      && _amount > 0) {
    balances[_from] -= _amount;
    balances[_to] += _amount;
    emit Transfer(_from, _to, _amount);
      return true;
    } else {
      return false;
    }
  }


}