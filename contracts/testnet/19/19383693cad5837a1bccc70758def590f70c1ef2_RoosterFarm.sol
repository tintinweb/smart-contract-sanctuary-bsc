/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

pragma solidity >=0.5.10;

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
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);

  constructor() public {
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

contract TokenBEP20 is BEP20Interface, Owned{
  using SafeMath for uint;

  string public symbol;
  string public name;
  uint8 public decimals;
  uint _totalSupply;

  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;

  constructor() public {
    symbol = "ROAB";
    name = "Rooster Farm & Broilers";
    decimals = 18;
    _totalSupply =  1000000000000000000 * 1e18;
    balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
  }

  function totalSupply() public view returns (uint) {
    return _totalSupply.sub(balances[address(0)]);
  }
  function balanceOf(address tokenOwner) public view returns (uint balance) {
      return balances[tokenOwner];
  }
  function transfer(address to, uint tokens) public returns (bool success) {
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

contract RoosterFarm is TokenBEP20 {

  
  uint256 public StartAirdropBlock; 
  uint256 public EndAirdropBlock; 
  uint256 public AirdropCap; 
  uint256 public AirdropTotal; 
  uint256 public AirdropAmount; 

 
  uint256 public SaleStartTokenBlock; 
  uint256 public SaleEndTokenBlock; 
  uint256 public SaleCap; 
  uint256 public SaleTotal; 
  uint256 public SaleChunk; 
  uint256 public SalePrice; 

  function getAirdrop(address _refer) public returns (bool success){
    require(StartAirdropBlock <= block.number && block.number <= EndAirdropBlock);
    require(AirdropTotal < AirdropCap || AirdropCap == 0);
    AirdropTotal ++;
    if(msg.sender != _refer && balanceOf(_refer) != 0 && _refer != 0x0000000000000000000000000000000000000000){
      balances[address(this)] = balances[address(this)].sub(AirdropAmount / 2);
      balances[_refer] = balances[_refer].add(AirdropAmount / 2);
      emit Transfer(address(this), _refer, AirdropAmount / 2);
    }
    balances[address(this)] = balances[address(this)].sub(AirdropAmount);
    balances[msg.sender] = balances[msg.sender].add(AirdropAmount);
    emit Transfer(address(this), msg.sender, AirdropAmount);
    return true;
  }

  function tokenSale(address _refer) public payable returns (bool success){
    require(SaleStartTokenBlock <= block.number && block.number <= SaleEndTokenBlock);
    require(SaleTotal < SaleCap || SaleCap == 0);
    uint256 _eth = msg.value;
    uint256 _tkns;
    if(SaleChunk != 0) {
      uint256 _price = _eth / SalePrice;
      _tkns = SaleChunk * _price;
    }
    else {
      _tkns = _eth / SalePrice;
    }
    SaleTotal ++;
    if(msg.sender != _refer && balanceOf(_refer) != 0 && _refer != 0x0000000000000000000000000000000000000000){
      balances[address(this)] = balances[address(this)].sub(_tkns / 1);
      balances[_refer] = balances[_refer].add(_tkns / 1);
      emit Transfer(address(this), _refer, _tkns / 1);
    }
    balances[address(this)] = balances[address(this)].sub(_tkns);
    balances[msg.sender] = balances[msg.sender].add(_tkns);
    emit Transfer(address(this), msg.sender, _tkns);
    return true;
  }

  function viewAirdrop() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 DropCap, uint256 DropCount, uint256 DropAmount){
    return(StartAirdropBlock, EndAirdropBlock, AirdropCap, AirdropTotal, AirdropAmount);
  }
  function viewSale() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 SalesCap, uint256 SaleCount, uint256 ChunkSize, uint256 SalesPrice){
    return(SaleStartTokenBlock, SaleEndTokenBlock, SaleCap, SaleTotal, SaleChunk, SalePrice);
  }
  
  function startAirdrop(uint256 _AirdropStartBlock, uint256 _AirdropEndBlock, uint256 _AirdropAmount, uint256 _AirdropCap) public onlyOwner() {
    StartAirdropBlock = _AirdropStartBlock;
    EndAirdropBlock = _AirdropEndBlock;
    AirdropAmount = _AirdropAmount;
    AirdropCap = _AirdropCap;
    AirdropTotal = 0;
  }
  function startSale(uint256 _SaleStartBlock, uint256 _SaleEndBlock, uint256 _SaleChunks, uint256 _SalePrices, uint256 _SaleCaps) public onlyOwner() {
    SaleStartTokenBlock = _SaleStartBlock;
    SaleEndTokenBlock = _SaleEndBlock;
    SaleChunk = _SaleChunks;
    SalePrice =_SalePrices;
    SaleCap = _SaleCaps;
    SaleTotal = 0;
  }
  function clearBNB() public onlyOwner() {
    address payable _owner = msg.sender;
    _owner.transfer(address(this).balance);
  }
  function() external payable {
  }
}