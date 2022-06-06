/**
 *Submitted for verification at BscScan.com on 2022-06-06
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

contract NeoFinance is IBEP20, Auth {
  using SafeMath for uint256;

  address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

  string constant _name = "Neo-Finance";
  string constant _symbol = "NEOF";
  uint8 constant _decimals = 18;

  uint256 _totalSupply = 0 * (10**_decimals);

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => bool) private _isExcludeFee;

  IDEXRouter public router;
  address public pair;
  address public currentRouter;

  uint256 public LPThreshold;
  uint256 public LPMintRate;

  uint256 public LPFee;
  uint256 public BuyFee;
  uint256 public feeDenominator;

  bool public reentrantcy;

  constructor() Auth(msg.sender) {

    _isExcludeFee[msg.sender] = true;
    _isExcludeFee[address(this)] = true;

    currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    _isExcludeFee[currentRouter] = true;

    router = IDEXRouter(currentRouter);
    pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
    _isExcludeFee[pair] = true;

    _allowances[address(this)][address(router)] = type(uint256).max;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);

    LPThreshold = 2000;
    LPFee = 100;
    BuyFee = 30;
    feeDenominator = 1000;
    
  }

  modifier noReentrant() {
    require(!reentrantcy);
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  function setFee(uint256 _LPFee,uint256 _BuyFee,uint256 _denominator) external authorized() returns (bool) {
    LPFee = _LPFee;
    BuyFee = _BuyFee;
    feeDenominator = _denominator;
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
    if ( pairBNB <= 0) { currentLPTreshold = LPThreshold;}
    else { currentLPTreshold = pairToken.div(pairBNB); }
    uint256 denominator = currentLPTreshold.div(LPThreshold).mul(10000);
    uint256 mintTreshold = currentLPTreshold.mul(10000).div(denominator);
    payable(owner).transfer(address(this).balance.mul(LPFee).div(feeDenominator));
    uint256 mintLP = address(this).balance.mul(mintTreshold);
    _mint(address(this), mintLP);
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

  function mint(uint256 amount) external authorized() returns (bool) {
    _mint(msg.sender, amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0));
    require(recipient != address(0));

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);

    if (sender==pair && !_isExcludeFee[recipient]) {
      _burn(recipient,amount.mul(BuyFee).div(feeDenominator));
    }

    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal {
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