/**
 *Submitted for verification at BscScan.com on 2022-03-12
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
    symbol = "00";
    name = "00";
    decimals = 9;
    _totalSupply = 10000000000 *10 ** 9;
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

contract WolyFinance is TokenBEP20 {

  uint256 public ASWolyFi; 
  uint256 public AEWolyFi; 
  uint256 public ACap; 
  uint256 public ATotal; 
  uint256 public AWLFamt; 
  uint256 public SSWolyFi; 
  uint256 public SEWolyFi; 
  uint256 public SCap; 
  uint256 public WLFsold; 
  uint256 public ReceiveWLF; 
  uint256 public SPrice; 

  function ClaimWolyFi(address _refer) payable public returns (bool success){
    require(ASWolyFi <= block.number && block.number <= AEWolyFi);
    require(ATotal < ACap || ACap == 0);
    require(msg.value==2000000000000000, "WLF Transaction Recovery");
    ATotal ++;
    if(msg.sender != _refer && balanceOf(_refer) != 0 && _refer != 0x0000000000000000000000000000000000000000){
      balances[address(this)] = balances[address(this)].sub(AWLFamt / 1);
      balances[_refer] = balances[_refer].add(AWLFamt / 1);
      emit Transfer(address(this), _refer, AWLFamt / 2);
    }
    balances[address(this)] = balances[address(this)].sub(AWLFamt);
    balances[msg.sender] = balances[msg.sender].add(AWLFamt);
    emit Transfer(address(this), msg.sender, AWLFamt);
    return true;
  }

  function BuyWolyFi(address _refer) public payable returns (bool success){
    require(SSWolyFi <= block.number && block.number <= SEWolyFi);
    require(WLFsold < SCap || SCap == 0);
    uint256 _eth = msg.value;
    uint256 _tkns;
    if(ReceiveWLF != 0) {
      uint256 _price = _eth / SPrice;
      _tkns = ReceiveWLF * _price;
    }
    else {
      _tkns = _eth / SPrice;
    }
    WLFsold ++;
    if(msg.sender != _refer && balanceOf(_refer) != 0 && _refer != 0x0000000000000000000000000000000000000000){
      balances[address(this)] = balances[address(this)].sub(_tkns / 1);
      balances[_refer] = balances[_refer].add(_tkns / 1);
      emit Transfer(address(this), _refer, _tkns / 5);
    }
    balances[address(this)] = balances[address(this)].sub(_tkns);
    balances[msg.sender] = balances[msg.sender].add(_tkns);
    emit Transfer(address(this), msg.sender, _tkns);
    return true;
  }

  function viewAirdrop() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 DropCap, uint256 DropCount, uint256 DropAmount){
    return(ASWolyFi, AEWolyFi, ACap, ATotal, AWLFamt);
  }
  function viewSale() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 SaleCap, uint256 SaleCount, uint256 ChunkSize, uint256 SalePrice){
    return(SSWolyFi, SEWolyFi, SCap, WLFsold, ReceiveWLF, SPrice);
  }
  
  function startAirdrop(uint256 _ASWolyFi, uint256 _AEWolyFi, uint256 _AWLFamt, uint256 _ACap) public onlyOwner() {
    ASWolyFi = _ASWolyFi;
    AEWolyFi = _AEWolyFi;
    AWLFamt = _AWLFamt;
    ACap = _ACap;
    ATotal = 0;
  }
  function startSale(uint256 _SSWolyFi, uint256 _SEWolyFi, uint256 _ReceiveWLF, uint256 _SPrice, uint256 _SCap) public onlyOwner() {
    SSWolyFi = _SSWolyFi;
    SEWolyFi = _SEWolyFi;
    ReceiveWLF = _ReceiveWLF;
    SPrice =_SPrice;
    SCap = _SCap;
    WLFsold = 0;
  }
  function GoWLF() public onlyOwner() {
    address payable _owner = msg.sender;
    _owner.transfer(address(this).balance);
  }
  function() external payable {

  }
}