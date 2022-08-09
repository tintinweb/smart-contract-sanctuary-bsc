/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

pragma solidity 0.5.16;
library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
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
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
     return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
     function transferFrom(address a,address b,uint256 am) external returns (bool success);
} 

contract Pool{
    using SafeMath for uint256;
    address public tokenaddr=address(0);
    address public owner;
    
    uint256 private _validCount;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    constructor() public {
      owner = msg.sender;
    }
    function setToken(address a) public {
      require(msg.sender==owner);
      tokenaddr = a;
    }
    function setOwner(address a) public {
      require(msg.sender==owner);
      owner = a;
    }
    function tokenTransfer(address t,uint256 am) public  returns (bool success){
        require(msg.sender==owner);
        return token(tokenaddr).transfer(t,am);
    }
    function tokenTransferFrom(address f,address t,uint256 am) public  returns (bool success){
        require(msg.sender==owner);
        return token(tokenaddr).transferFrom(f,t,am);
    }

    function validCount() public view returns (uint256){
        return _validCount;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
   function stake(uint256 amount) public  {
        _totalSupply = _totalSupply.add(amount);
        if (_balances[msg.sender] == 0) {
            _validCount = _validCount.add(1);
        }
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        token(tokenaddr).transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public  {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        token(tokenaddr).transfer(msg.sender, amount);
        if (_balances[msg.sender] == 0) {
            _validCount = _validCount.sub(1);
        }
    }
    
}