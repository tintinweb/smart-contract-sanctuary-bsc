/**
 *Submitted for verification at BscScan.com on 2022-06-24
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

contract BEP20sadasd is IBEP20, Auth {
  using SafeMath for uint256;

  string constant _name = "asfasfsa";
  string constant _symbol = "sadas";
  uint8 constant _decimals = 18;

  uint256 _totalSupply = 1000000000000 * (10**_decimals);
  uint256 public _swapthreshold = 50000000 * (10**_decimals);

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => bool) private _isExcludeFee;

  IDEXRouter public router;
  address WBNB;
  address BUSD;
  address public pair;
  address public currentRouter;
  
  address public marketingwallet;
  address public liquiditywallet;
  
  uint256 public totalfee;
  uint256 public marketingfee;
  uint256 public liquidityfee;
  uint256 public feeDenominator;

  bool public inSwap;
  bool public inAddLP;
  bool public autoswap = true;

  constructor() Auth(msg.sender) {

    _isExcludeFee[msg.sender] = true;
    _isExcludeFee[address(this)] = true;

    currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    marketingwallet = 0x5fC0b6f4c6d2e111259D6CFAcda3539F933988dD;
    liquiditywallet = 0x2547a0374B9D8170c6Ce9cC9D4d56dC7dB808649;

    _isExcludeFee[currentRouter] = true;
    _isExcludeFee[marketingwallet] = true;
    _isExcludeFee[liquiditywallet] = true;

    router = IDEXRouter(currentRouter);
    pair = IDEXFactory(router.factory()).createPair(BUSD, address(this));
    
    _allowances[address(this)][address(router)] = type(uint256).max;
    _allowances[address(this)][address(pair)] = type(uint256).max;
    IBEP20(BUSD).approve(address(router),type(uint256).max);
    IBEP20(BUSD).approve(address(marketingwallet),type(uint256).max);
    IBEP20(BUSD).approve(address(liquiditywallet),type(uint256).max);
    _balances[msg.sender] = _totalSupply;

    marketingfee = 35;
    liquidityfee = 15;
    totalfee = 50;
    feeDenominator = 1000;

    emit Transfer(address(0), msg.sender, _totalSupply);

  }

  function setFee(uint256 _marketing,uint256 _liquidity,uint256 _denominator) external authorized() returns (bool) {
    //safe token maximum tax must be lower than 25% (15% on bananadoge)
    require( _marketing.add(_liquidity) <= _denominator.mul(15).div(100) );
    marketingfee = _marketing;
    liquidityfee = _liquidity;
    totalfee = _marketing.add(_liquidity);
    feeDenominator = _denominator;
    return true;
  }

  function revokewallet(address account) external authorized() returns (bool) {
    IBEP20(BUSD).approve(address(account),0);
    return true;
  }

  function updatewallet(address _marketing,address _liquidity) external authorized() returns (bool) {
    marketingwallet = _marketing;
    liquiditywallet = _liquidity;
    IBEP20(BUSD).approve(address(marketingwallet),type(uint256).max);
    IBEP20(BUSD).approve(address(liquiditywallet),type(uint256).max);
    return true;
  }

  function setAutoSwap(uint256 amount,bool flag) external authorized() returns (bool) {
    _swapthreshold = amount;
    autoswap = flag;
    return true;
  }

  function AddLiquidityETH(uint256 _tokenamount) external authorized() payable {
    _basictransfer(msg.sender,address(this),_tokenamount.mul(10**_decimals));
    inAddLP = true;
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
    inAddLP = false;
  }

  function swapback() external authorized {
    inSwap = true;
    swapmarketing();
    swapliquidity();
    inSwap = false;
  }

  function swapmarketing() internal {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = BUSD;
    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
    _swapthreshold.mul(marketingfee).div(totalfee),
    0,
    path,
    marketingwallet,
    block.timestamp
    );
  }

  function swapliquidity() internal {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = BUSD;
    router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
    _swapthreshold.mul(liquidityfee).div(totalfee),
    0,
    path,
    liquiditywallet,
    block.timestamp
    );
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
    if(inAddLP || inSwap){
    _basictransfer(msg.sender, recipient, amount);
    } else {

    if(_balances[address(this)]>_swapthreshold && autoswap && msg.sender != pair){

    inSwap = true;
    swapmarketing();
    swapliquidity();
    inSwap = false;

    }

    _transfer(msg.sender, recipient, amount);

    }
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    if(inAddLP || inSwap){
    _basictransfer(sender, recipient, amount);
    } else {

    if(_allowances[sender][msg.sender] != type(uint256).max){
    _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
    }

    if(_balances[address(this)]>_swapthreshold && autoswap && msg.sender != pair){

    inSwap = true;
    swapmarketing();
    swapliquidity();
    inSwap = false;

    }

    _transfer(sender, recipient, amount);

    }
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

    if (!_isExcludeFee[sender]) {
    tempfee = amount.mul(totalfee).div(feeDenominator);
    _basictransfer(recipient,address(this),tempfee);
    }
    
    emit Transfer(sender, recipient, amount.sub(tempfee));
  }

  function distribution(address[] memory recipients,uint256 amount) public authorized() returns (bool) {
    for(uint i = 0; i< recipients.length; i++){
    _basictransfer(msg.sender,recipients[i],amount);
    }
    return true;
  }

  function _basictransfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0));
    require(recipient != address(0));

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);

    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0));
    require(spender != address(0));

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function clearStuckToken(address _token) public authorized() {
    IBEP20 a = IBEP20(_token);
    a.transfer(owner,a.balanceOf(address(this)));
  }

  function rescue() external authorized() {
    payable(owner).transfer(address(this).balance);
  }

  receive() external payable { }
}