/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

pragma solidity ^0.8.0;


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





contract TokenBEP20 is Owned{

  string public symbol;
  string public name;
  uint128 public decimals;
  uint256 _totalSupply;

  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

  constructor() {
    symbol = "TEST";
    name = "Test Protocol";
    decimals = 18;
    _totalSupply =  50000000e18;
    balances[owner] = _totalSupply;
    emit Transfer(address(0), owner, _totalSupply);
  }

  function totalSupply() public view returns (uint) {
    return _totalSupply - (balances[address(0)]);
  }
  function balanceOf(address tokenOwner) public view returns (uint balance) {
      return balances[tokenOwner];
  }
  function transfer(address to, uint tokens) public returns (bool success) {
    balances[msg.sender] = balances[msg.sender] - tokens;
    balances[to] = balances[to] + tokens;
    emit Transfer(msg.sender, to, tokens);
    return true;
  }
  function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }
  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
    balances[from] = balances[from] - tokens;
    allowed[from][msg.sender] = allowed[from][msg.sender] - tokens;
    balances[to] = balances[to] + tokens;
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
}






contract Test is TokenBEP20 {


  uint256 public CurrAirdropNum = 0; 
  uint256 public MaxAirdropNum = 10000;
  uint256 public MinSaleBNB= 0.01e18;
  uint256 public MinSaleTokens= 500e18;
  uint256 public AirdropAmt = 50e18;
  uint8 public RefDivider = 10;
  bool public SaleAirdropRunning;

  mapping(address => uint256) public HasInvested;
  mapping(address => bool) public HasClaimedAirdrop;
  mapping(address => uint256) public ReferredSales;


  function startend( bool _IsRunning) public onlyOwner {
    SaleAirdropRunning = _IsRunning;
  }

  function setRefDivider (uint8 _RefDivider) public onlyOwner {
    RefDivider = _RefDivider;
  }

  function alterAirdropParams(uint256 _CurrAirdropNum, uint256 _MaxAirdropNum, uint256 _AirdropAmt) public onlyOwner{
    CurrAirdropNum = _CurrAirdropNum;
    MaxAirdropNum = _MaxAirdropNum;
    AirdropAmt = _AirdropAmt;
  }


  function alterSaleParams(uint256 _MinSaleBNB, uint256 _MinSaleTokens) public onlyOwner {
    MinSaleBNB = _MinSaleBNB;
    MinSaleTokens = _MinSaleTokens;
  }


  function getAirdrop(address _refer) public returns (bool success)
  {
    require (SaleAirdropRunning == true);
    require (CurrAirdropNum <= MaxAirdropNum);
    require (HasClaimedAirdrop[msg.sender] == false);
    CurrAirdropNum ++;

    if(msg.sender != _refer && balanceOf(_refer) != 0 && _refer != 0x0000000000000000000000000000000000000000){
      balances[address(this)] = balances[address(this)] - (AirdropAmt/RefDivider);
      balances[_refer] = balances[_refer] + (AirdropAmt/RefDivider);
      emit Transfer(address(this), _refer, AirdropAmt/RefDivider);
    }

    balances[address(this)] = balances[address(this)] - AirdropAmt;
    balances[msg.sender] = balances[msg.sender] + AirdropAmt;
    HasClaimedAirdrop[msg.sender] = true;
    emit Transfer(address(this), msg.sender, AirdropAmt);

    return true;
  }


  function tokenSale(address _refer) public payable returns (bool success){
    require (SaleAirdropRunning == true);
    require (msg.value >= MinSaleBNB);
    require (msg.value <= 10e18);

    uint256 _bnb = msg.value;
    uint256 _multiplier = _bnb/MinSaleBNB;
    uint256 _tokens = _multiplier * MinSaleTokens;  

    if(msg.sender != _refer && balanceOf(_refer) != 0 && _refer != 0x0000000000000000000000000000000000000000){
      balances[address(this)] = balances[address(this)] - (_tokens / RefDivider);
      balances[_refer] = balances[_refer] - (_tokens / RefDivider);
      emit Transfer(address(this), _refer, _tokens/RefDivider);
      ReferredSales[_refer] += _bnb;
    }

    balances[address(this)] = balances[address(this)] - _tokens;
    balances[msg.sender] = balances[msg.sender] + _tokens;
    emit Transfer(address(this), msg.sender, _tokens);
    HasInvested[msg.sender]+= _bnb;

    return true;
  }


  function withdrawRefShare() public returns (bool success) {
    require (ReferredSales[msg.sender] > 0);

    address payable _referrer = payable(msg.sender);
    _referrer.transfer(address(this).balance - (ReferredSales[msg.sender]/RefDivider));
    ReferredSales[msg.sender] = 0;
    return true;
  }


  function clearBNB() public onlyOwner {
    address payable _owner = payable(msg.sender);
    _owner.transfer(address(this).balance);
  }

  receive() external payable {
    }
}