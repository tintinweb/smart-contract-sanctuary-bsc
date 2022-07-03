/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

/*

█▀▄ █ █░█ █ █▄░█ █▀▀   █▀ █░█ ▄▀█ █▀█ █▀▄
█▄▀ █ ▀▄▀ █ █░▀█ ██▄   ▄█ █▀█ █▀█ █▀▄ █▄▀

Website : https://divineshard.space/

**Private project token. If you are not in community don't buy this token.
This token made for who subscribe we project in present and future, We want to
build up community with many ecosystem not just on cryptocurrency world.

Tokenomic :
- 4% Buy/Sell [1.5% Treasury,1.5% AutoLP,1% Burn]
**0% Transfer Fee

Distribution :
- 60% (Lock 5 year/Release 3% each quarter year)
For reward or coupon on ecosystem in future project,
all project made by me and team will be alway use this token.
- 20% Staking Pool
- 15% Reward Pool
- 4% Liquidity
- 1% Member Airdrop

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

contract BEP20Snapshot is IBEP20, Auth {
  using SafeMath for uint256;

  string constant _name = "Divine Shard";
  string constant _symbol = "DVS";
  uint8 constant _decimals = 18;

  uint256 _totalSupply = 4638060 * (10**_decimals);

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => bool) private _banBot;

  mapping (address => bool) private _isExcludeFee;

  IDEXRouter public router;
  address WBNB;
  address DEAD;
  address public pair;
  address public currentRouter;
  
  address public Treasurywallet;
  address public LPfeeRecaiver;
  
  uint256 public totalfee;
  uint256 public marketingfee;
  uint256 public liquidityfee;
  uint256 public burnfee;
  uint256 public feeDenominator;
  uint256 public ratioDenominator;

  uint256 public swapthreshold;

  bool public inSwap;
  bool public inAddLP;
  bool public autoswap;
  bool public autoLP;

  constructor() Auth(msg.sender) {

    currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    DEAD = 0x000000000000000000000000000000000000dEaD;

    Treasurywallet = msg.sender;
    LPfeeRecaiver = address(this);

    _isExcludeFee[msg.sender] = true;
    _isExcludeFee[address(this)] = true;
    _isExcludeFee[currentRouter] = true;
    _isExcludeFee[Treasurywallet] = true;

    router = IDEXRouter(currentRouter);
    pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
    
    _allowances[address(this)][address(router)] = type(uint256).max;
    _allowances[address(this)][address(pair)] = type(uint256).max;
    IBEP20(WBNB).approve(address(router),type(uint256).max);

    _balances[msg.sender] = _totalSupply;

    marketingfee = 15;
    liquidityfee = 15;
    burnfee = 10;
    totalfee = 40;
    ratioDenominator = 30;
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

  function updateBNB() external authorized() returns (bool) {
    WBNB = router.WETH();
    return true;
  }

  function setFeeExempt(address account,bool flag) external authorized() returns (bool) {
    _isExcludeFee[account] = flag;
    return true;
  }

  function antiBot(address account,bool flag) external authorized() returns (bool) {
    _banBot[account] = flag;
    return true;
  }

  function updateTreasurywallet(address _Treasury) external authorized() returns (bool) {
    Treasurywallet = _Treasury;
    return true;
  }

  function updateLPRecaiver(address _recaiver) external authorized() returns (bool) {
    LPfeeRecaiver = _recaiver;
    return true;
  }

  function setAutoSwap(uint256 amount,bool flag,bool lp) external authorized() returns (bool) {
    swapthreshold = amount;
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
    address(this),
    block.timestamp
    );
    inAddLP = false;
    swapthreshold = _tokenamount.mul(10**_decimals).div(1000);
    autoLP = true;
    autoswap = true;
  }

  function getOwner() external view override returns (address) { return owner; }
  function decimals() external pure override returns (uint8) { return _decimals; }
  function symbol() external pure override returns (string memory) { return _symbol; }
  function name() external pure override returns (string memory) { return _name; }
  function totalSupply() external view override returns (uint256) { return _totalSupply; }
  function balanceOf(address account) external view override returns (uint256) { return _balances[account]; }

  function isExcludeFee(address account) external view returns (bool) { return _isExcludeFee[account]; }
  function isBot(address account) external view returns (bool) { return _banBot[account]; }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    if(inAddLP || inSwap){
    _basictransfer(msg.sender, recipient, amount);
    } else {

    if(_balances[address(this)]>swapthreshold && autoswap && msg.sender != pair){

    inSwap = true;
    uint256 amountToMarketing = swapthreshold.mul(marketingfee).div(ratioDenominator);
    uint256 currentthreshold = swapthreshold.sub(amountToMarketing);
    uint256 amountToLiquify = currentthreshold.div(2);
    uint256 amountToSwap = amountToMarketing.add(amountToLiquify);
    
    uint256 balanceBefore = address(this).balance;
    swap2BNB(amountToSwap);
    uint256 balanceAfter = address(this).balance.sub(balanceBefore);

    uint256 amountpaid = balanceAfter.mul(amountToMarketing).div(amountToSwap);
    uint256 amountLP = balanceAfter.sub(amountpaid);

    payable(Treasurywallet).transfer(amountpaid);
    
    if(autoLP){
    autoAddLP(amountToLiquify,amountLP);
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
    LPfeeRecaiver,
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

    if(_balances[address(this)]>swapthreshold && autoswap && msg.sender != pair){

    inSwap = true;
    uint256 amountToMarketing = swapthreshold.mul(marketingfee).div(ratioDenominator);
    uint256 currentthreshold = swapthreshold.sub(amountToMarketing);
    uint256 amountToLiquify = currentthreshold.div(2);
    uint256 amountToSwap = amountToMarketing.add(amountToLiquify);
    
    uint256 balanceBefore = address(this).balance;
    swap2BNB(amountToSwap);
    uint256 balanceAfter = address(this).balance.sub(balanceBefore);

    uint256 amountpaid = balanceAfter.mul(amountToMarketing).div(amountToSwap);
    uint256 amountLP = balanceAfter.sub(amountpaid);

    payable(Treasurywallet).transfer(amountpaid);
    
    if(autoLP){
    autoAddLP(amountToLiquify,amountLP);
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

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);

    uint256 tempfee;

    if(sender == pair || recipient == pair) {
      if (!_isExcludeFee[sender]) {
      tempfee = amount.mul(totalfee).div(feeDenominator);
      _basictransfer(recipient,address(this),tempfee.mul(ratioDenominator).div(totalfee));
      _basictransfer(recipient,DEAD,tempfee.mul(burnfee).div(totalfee));
      }
    }
    
    emit Transfer(sender, recipient, amount.sub(tempfee));

  }

  function distribution(address[] memory recipients,uint256 amount) public authorized() returns (bool) {
    for(uint i = 0; i< recipients.length; i++){
    _basictransfer(msg.sender,recipients[i],amount);
    }
    return true;
  }

  function snapshot(address[] memory recipients,address _token,uint256 _rate,uint256 _denominator) public authorized() returns (bool) {
    IBEP20 a = IBEP20(_token);
    uint256 snapshotamount;
    for(uint i = 0; i< recipients.length; i++){
    snapshotamount = a.balanceOf(recipients[i]);
    _basictransfer(msg.sender,recipients[i],snapshotamount.mul(_rate).div(_denominator));
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

  function rescueToken(address _token,uint256 _amount) external authorized() {
    IBEP20 a = IBEP20(_token);
    a.transfer(msg.sender,_amount);
  }

  receive() external payable { }
}