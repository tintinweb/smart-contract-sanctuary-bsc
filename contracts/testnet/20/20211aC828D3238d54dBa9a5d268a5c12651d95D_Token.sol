/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

contract Owned {
    modifier onlyOwner() {
        require(msg.sender==owner);
        _;
    }

    modifier onlyManager() {
        require(msg.sender==tokenManagerContractAddress);
        _;
    }
    address public tokenManagerContractAddress;
    address payable public owner;
    // address payable newOwner;
    function changeOwner(address payable _newOwner) public onlyOwner {
        require(_newOwner!=address(0));
        owner = _newOwner;
    }
    
    function changeTokenManager(address payable _manager) public onlyOwner {
        
        tokenManagerContractAddress = _manager;
    }

}

contract Token is Owned {
    using SafeMath for uint256;
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public TokensSold;
    uint256 public totalSupply=1000000000000000e18;
    mapping (address=>uint256)public balances;
    mapping (address=>mapping (address=>uint256))public allowed;
    mapping (address  => bool) public frozen ;
  //bool public frozen = false;
  
      event Freeze(address target, bool frozen);
      event Unfreeze(address target, bool frozen);
      event Burn(address a, uint256 _value);

      constructor(address payable _owner){
          owner=_owner;
          balances[owner]=totalSupply;
      }

modifier whenNotFrozen(address target) {
    require(!frozen[target],"tokens are freeze already");
      _;
    }

  modifier whenFrozen(address target){
    require(frozen[target],"tokens are not freeze");
    _;
  }
    function balanceOf(address _owner) view public   returns (uint256 balance) {return balances[_owner];}
    
    function transfer(address _to, uint256 _amount) public   returns (bool success) {
        require(!frozen[msg.sender],'account is freez');
        require (balances[msg.sender]>=_amount&&_amount>0&&balances[_to]+_amount>balances[_to]);
        balances[msg.sender]=balances[msg.sender].sub(_amount);
        balances[_to]=balances[_to].add(_amount);
        return true;
    }
    function transferFrom(address _from,address _to,uint256 _amount) public   returns (bool success) {
        require(!frozen[_from],"From address is fronzen");
        require (balances[_from]>=_amount&&allowed[_from][msg.sender]>=_amount&&_amount>0&&balances[_to]+_amount>balances[_to]);
        balances[_from]=balances[_from].sub(_amount);
        allowed[_from][msg.sender]=allowed[_from][msg.sender].sub(_amount);
        balances[_to]=balances[_to].add(_amount);
        return true;
    }
  
    function approve(address _spender, uint256 _amount) public   returns (bool success) {
        allowed[msg.sender][_spender]=_amount;
        return true;
    }
    
    function allowance(address _owner, address _spender) view public   returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
  

  function FreezeAcc(address target, bool freeze) onlyManager public whenNotFrozen(target) returns (bool) {
    freeze = true;
    frozen[target]=freeze;
    emit Freeze(target, true);
    return true;
  }

  function UnfreezeAcc(address target, bool freeze) onlyManager public whenFrozen(target) returns (bool) {
    freeze = false;
    frozen[target]=freeze;
    emit Unfreeze(target, false);
    return true;
  }
  function burn(uint256 _value) public returns (bool success) {
      require(!frozen[msg.sender],"Account address is fronzen");
        require(balances[msg.sender] >= _value);   // Check if the sender has enough
        balances[msg.sender] =balances[msg.sender].sub(_value);            // Subtract from the sender
        totalSupply =totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
}


    library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
   }
    
   }