/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

interface BEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external  returns (bool) ;
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) ;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Wider is BEP20 {

    string private   constant name = "Wider"; 
    string private   constant symbol = "WD";
    uint8  private  constant decimals = 0;
   
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    address public _owner;
    uint private   totalSupply_=1000;
    using SafeMath for uint256;

     constructor() public 
      {
        balances[msg.sender] = totalSupply_;
        _owner=msg.sender;
    }
     event burn(address _owner , uint _value);
        
 

    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }


//function reduceSupp
    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool)
     {
    require(spender != address(0));

    allowed[msg.sender][spender] = 
        allowed[msg.sender][spender].add(addedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
   }

   function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
    require(spender != address(0));

    allowed[msg.sender][spender] =    allowed[msg.sender][spender].sub(subtractedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
}

    function _mintToken(uint _value) private returns(bool)
    {

        require(msg.sender==_owner,"only admin has this access");
        totalSupply_+=_value;
        balances[_owner]+=_value;
        return true;

    }

     function _burnToken(uint _value) private  returns(bool)
    {

       require(msg.sender==_owner,"only admin has this access");
        totalSupply_-=_value;
        balances[_owner]-=_value;
        emit burn(msg.sender, _value);
        return true;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}