/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

pragma solidity ^0.5.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}

contract ERC20Detailed is IERC20 {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns(string memory) {
    return _name;
  }

  function symbol() public view returns(string memory) {
    return _symbol;
  }

  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

contract GSI is ERC20Detailed {

  using SafeMath for uint256;
  mapping (address => BalanceOwner) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;
  address[] private _balanceOwners;
  struct BalanceOwner {
      uint256 amount;
      bool exists;
  }


  string constant tokenName = "Green Snake Inu";
  string constant tokenSymbol = "GSI";
  uint8  constant tokenDecimals = 7;
  uint256 _totalSupply;
  uint256 public basePercent = 100;
  address feeWallet =0x225cd1d2153a6A8691Bb5183f45A5C00364740d3 ;
 
  
  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    uint256 initSupply = 3012009000000000*10**18;
    _mint(msg.sender, initSupply);
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner].amount;
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  function findOnePercent(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value.ceil(basePercent);
    uint256 onePercent = roundValue.mul(basePercent).div(10000);
    return onePercent;
  }

  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _balances[msg.sender].amount);
    require(to != address(0));

    uint256 onePercent = findOnePercent(value);
    uint256 tokensToBurn = onePercent.mul(4);
    uint256 tokensToRedistribute = onePercent.mul(3);
    uint256 toFeeWallet = onePercent.mul(1);
    uint256 tokensToTransfer = value.sub(tokensToBurn + tokensToRedistribute + toFeeWallet);

    _balances[msg.sender].amount = _balances[msg.sender].amount.sub(value);
    _balances[to].amount = _balances[to].amount.add(tokensToTransfer);
    _balances[feeWallet].amount = _balances[feeWallet].amount.add(toFeeWallet);
    if (!_balances[to].exists){
        _balanceOwners.push(to);
        _balances[to].exists = true;
    }

    redistribute(tokensToRedistribute);
    _burn(msg.sender, tokensToBurn);
    emit Transfer(msg.sender, to, tokensToTransfer);
    return true;
  }

  function redistribute(uint256 amount) internal {
      uint256 remaining = amount;
      for (uint256 i = 0; i < _balanceOwners.length; i++) {
        if (_balances[_balanceOwners[i]].amount == 0 || _balanceOwners[i] == msg.sender) continue;
        
        uint256 ownedAmount = _balances[_balanceOwners[i]].amount;
        uint256 ownedPercentage = _totalSupply.div(ownedAmount);
        uint256 toReceive = amount.div(ownedPercentage);
        if (toReceive == 0) continue;
        if (remaining < toReceive) break;        
        remaining = remaining.sub(toReceive);
        _balances[_balanceOwners[i]].amount = _balances[_balanceOwners[i]].amount.add(toReceive);
      }
  }

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(value <= _balances[from].amount);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _balances[from].amount = _balances[from].amount.sub(value);

    uint256 onePercent = findOnePercent(value);
    uint256 tokensToBurn = onePercent.mul(4);
    uint256 tokensToRedistribute = onePercent.mul(3);
    uint256 toFeeWallet = onePercent.mul(1);
    uint256 tokensToTransfer = value.sub(tokensToBurn + tokensToRedistribute + toFeeWallet);

    _balances[to].amount = _balances[to].amount.add(tokensToTransfer);    
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _balances[feeWallet].amount = _balances[feeWallet].amount.add(toFeeWallet);
    if (!_balances[to].exists){
        _balanceOwners.push(to);
        _balances[to].exists = true;
    }

    redistribute(tokensToRedistribute);
    _burn(msg.sender, tokensToBurn);

    emit Transfer(from, to, tokensToTransfer);

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account].amount = _balances[account].amount.add(amount);
        emit Transfer(address(0), account, amount);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }
  function _burn(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _balances[account].amount);
    _totalSupply = _totalSupply.sub(amount);
    _balances[account].amount = _balances[account].amount.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function burnFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _burn(account, amount);
  }
}