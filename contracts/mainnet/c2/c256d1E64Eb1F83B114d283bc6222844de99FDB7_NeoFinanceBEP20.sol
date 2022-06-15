/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

/*
################################################
                                                             
  █▄░█ █▀▀ █▀█ ▄▄ █▀▀ █ █▄░█ ▄▀█ █▄░█ █▀▀ █▀▀                
  █░▀█ ██▄ █▄█ ░░ █▀░ █ █░▀█ █▀█ █░▀█ █▄▄ ██▄               
  
  visit : https://neofinance.digital/                
  𝑠𝑚𝑎𝑟𝑡 𝑐𝑜𝑛𝑡𝑟𝑎𝑐𝑡 𝑟𝑒𝑣𝑖𝑒𝑤 𝑎𝑛𝑑 𝑣𝑒𝑟𝑖𝑓𝑖𝑒𝑑.              
  
  Tokenomic : $NEOF token 
  - 4% buy/sell to manual burn wallet.
  - rebase and mining up to 1200% APR
  - stable liquidity function.
  - safe token <25% tax at maximum.
  - no pause trading function and no max tx.
  
################################################
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

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
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

}

contract NeoFinanceBEP20 is IBEP20, Auth {
  using SafeMath for uint256;

  string constant _name = "NEO FINANCE";
  string constant _symbol = "NEOF";
  uint8 constant _decimals = 18;

  uint256 _totalSupply = 0 * (10**_decimals);

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => bool) private _isExcludeFee;

  IDEXRouter public router;
  address WBNB;
  address public pair;
  address public currentRouter;
  address public burntwallet;

  uint256 public LPThreshold;
  uint256 public LPMintRate;
  uint256 public LPGas;

  uint256 public BuyFee;
  uint256 public feeDenominator;

  bool public reentrantcy;

  constructor() Auth(msg.sender) {

    _isExcludeFee[msg.sender] = true;
    _isExcludeFee[address(this)] = true;

    if (block.chainid == 56) {
    currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    } else if (block.chainid == 97) {
    currentRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    } else { revert(); }

    burntwallet = msg.sender;

    _isExcludeFee[currentRouter] = true;

    router = IDEXRouter(currentRouter);
    pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));

    _allowances[address(this)][address(router)] = type(uint256).max;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);

    LPThreshold = 2000;
    LPGas = 100;
    BuyFee = 40;
    feeDenominator = 1000;
    
  }

  modifier noReentrant() {
    require(!reentrantcy);
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  function setFee(uint256 _LPGas,uint256 _BuyFee,uint256 _denominator) external authorized() returns (bool) {
    require( _LPGas.add(_BuyFee) < _denominator.div(4) );
    LPGas = _LPGas;
    BuyFee = _BuyFee;
    feeDenominator = _denominator;
    return true;
  }

  function updateburntwallet(address account) external authorized() returns (bool) {
    burntwallet = account;
    return true;
  }

  function setExcludeFee(address account,bool flag) external authorized() returns (bool) {
    _isExcludeFee[account] = flag;
    return true;
  }

  function DynamicLiquidity() external noReentrant payable {
    uint256 pairBNB = IBEP20(WBNB).balanceOf(pair);
    uint256 pairToken = _balances[pair];
    uint256 currentLPTreshold;
    if ( pairBNB == 0) { currentLPTreshold = LPThreshold;}
    else { currentLPTreshold = pairToken.div(pairBNB); }
    uint256 mintTreshold = LPThreshold.mul(LPThreshold).div(currentLPTreshold);
    payable(owner).transfer(address(this).balance.mul(LPGas).div(feeDenominator));
    uint256 mintLP = address(this).balance.mul(mintTreshold);
    _mining(address(this), mintLP);
    router.addLiquidityETH{value: address(this).balance }(
    address(this),
    mintLP,
    0,
    0,
    address(this),
    block.timestamp
    );
  }

  function buytoken() external payable {
    address[] memory path = new address[](2);
    path[0] = WBNB;
    path[1] = address(this);
    router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
      0,
      path,
      msg.sender,
      block.timestamp
    );
  }

  function getOwner() external view override returns (address) { return owner; }
  function decimals() external pure override returns (uint8) { return _decimals; }
  function symbol() external pure override returns (string memory) { return _symbol; }
  function name() external pure override returns (string memory) { return _name; }
  function totalSupply() external view override returns (uint256) { return _totalSupply; }
  function balanceOf(address account) external view override returns (uint256) { return _balances[account]; }

  function isExcludeFee(address account) external view returns (bool) { return _isExcludeFee[account]; }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
      _transfer(msg.sender, recipient, amount); return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
    return true;
  }

  function mining(uint256 amount) external authorized() returns (bool) {
    _mining(msg.sender, amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0));
    require(recipient != address(0));

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);

    if (!_isExcludeFee[sender]) {
      _basictransfer(recipient,burntwallet,amount.mul(BuyFee).div(feeDenominator));
    }

    emit Transfer(sender, recipient, amount);
  }

  function _basictransfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0));
    require(recipient != address(0));

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);

    emit Transfer(sender, recipient, amount);
  }

  function _mining(address account, uint256 amount) internal {
    require(account != address(0));
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0));
    _balances[account] = _balances[account].sub(amount);
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0));
    require(spender != address(0));

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

}