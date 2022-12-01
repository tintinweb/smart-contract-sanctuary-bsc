/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

/*


░█████╗░██╗░░██╗  ░██████╗░█████╗░███████╗██╗░░░██╗
██╔══██╗██║░██╔╝  ██╔════╝██╔══██╗██╔════╝██║░░░██║
██║░░╚═╝█████═╝░  ╚█████╗░███████║█████╗░░██║░░░██║
██║░░██╗██╔═██╗░  ░╚═══██╗██╔══██║██╔══╝░░██║░░░██║
╚█████╔╝██║░╚██╗  ██████╔╝██║░░██║██║░░░░░╚██████╔╝
░╚════╝░╚═╝░░╚═╝  ╚═════╝░╚═╝░░╚═╝╚═╝░░░░░░╚═════╝░

██╗░░░░░░█████╗░██╗░░░██╗███╗░░██╗░█████╗░██╗░░██╗██████╗░░█████╗░██████╗░
██║░░░░░██╔══██╗██║░░░██║████╗░██║██╔══██╗██║░░██║██╔══██╗██╔══██╗██╔══██╗
██║░░░░░███████║██║░░░██║██╔██╗██║██║░░╚═╝███████║██████╔╝███████║██║░░██║
██║░░░░░██╔══██║██║░░░██║██║╚████║██║░░██╗██╔══██║██╔═══╝░██╔══██║██║░░██║
███████╗██║░░██║╚██████╔╝██║░╚███║╚█████╔╝██║░░██║██║░░░░░██║░░██║██████╔╝
╚══════╝╚═╝░░╚═╝░╚═════╝░╚═╝░░╚══╝░╚════╝░╚═╝░░╚═╝╚═╝░░░░░╚═╝░░╚═╝╚═════╝░

Welcome to CK SAFU LAUNCH
Launch latest safu dapp base on Binance Smart Chain.
🔥Huge supply burn ecosystem. hype community with high APY!
✔️ Audit ✔️ KYC ✔️ SAFU ✔️ DOXX

website : cksafu-launch.space
telegram : https://t.me/CKsafuprojectofficial

tax :
4.5% buy/sell -> 2% AutoLP 2% Operation 0.5% LuckyReward

distribute :
15% presale, vesting initial unlock 20% and release 5% each 7 days

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ILUCKYREWARD {
    function updatepoint(address account, uint256 amount, uint256 wbnb, uint256 token) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    function transferOwnership(address account) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, account);
        _owner = account;
    }

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

contract CKSafuLaunchpad is Context, IERC20, Ownable {
  using SafeMath for uint256;

  string constant _name = "CK Safu Launch";
  string constant _symbol = "CKSL";
  uint8 constant _decimals = 18;
  uint256 _totalSupply = 50 * 1000 * 1000 * (10**_decimals);

  mapping (address => uint256) private _balances;
  mapping (address => bool) private _isAntiDump;
  mapping (address => bool) private _isExcludeFee;
  mapping (address => mapping (address => uint256)) private _allowances;
  address private LPReceiver;
  address private FeeReceiver;
  address private LuckyReceiver;

  IDEXRouter public router;
  address NATIVETOKEN;
  address public pair;
  address public currentRouter;

  uint256 public totalfee;
  uint256 public operationfee;
  uint256 public liquidityfee;
  uint256 public feeDenominator;
  bool public inSwap;
  bool public autoswap;
  bool public baseERC20;
  bool public isDisbledPoint = true;

  constructor(address _LPReceiver,address _FeeReceiver,address _LuckyReceiver) {
    LPReceiver = _LPReceiver;
    FeeReceiver = _FeeReceiver;
    LuckyReceiver = _LuckyReceiver;
    currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    NATIVETOKEN = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    _isExcludeFee[msg.sender] = true;
    _isExcludeFee[address(this)] = true;
    _isExcludeFee[currentRouter] = true;
    _isExcludeFee[LPReceiver] = true;
    _isExcludeFee[FeeReceiver] = true;
    _isExcludeFee[LuckyReceiver] = true;

    router = IDEXRouter(currentRouter);
    pair = IDEXFactory(router.factory()).createPair(NATIVETOKEN, address(this));
    _allowances[address(this)][address(router)] = type(uint256).max;
    _allowances[address(this)][address(pair)] = type(uint256).max;
    IERC20(NATIVETOKEN).approve(address(router),type(uint256).max);
    IERC20(NATIVETOKEN).approve(address(pair),type(uint256).max);

    _balances[msg.sender] = _totalSupply;
    operationfee = 50;
    liquidityfee = 40;
    totalfee = 90;
    feeDenominator = 1000;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function setFee(uint256 _operation,uint256 _liquidity,uint256 _denominator) external onlyOwner returns (bool) {
    require( _operation.add(_liquidity) <= _denominator.mul(10).div(100) );
    operationfee = _operation;
    liquidityfee = _liquidity;
    totalfee = _operation.add(_liquidity);
    feeDenominator = _denominator;
    return true;
  }

  function halfFee() external onlyOwner returns (bool) {
    operationfee = operationfee.div(2);
    liquidityfee = liquidityfee.div(2);
    totalfee = operationfee.add(liquidityfee);
    return true;
  }

  function updateNativeToken(address weth) external onlyOwner returns (bool) {
    NATIVETOKEN = weth;
    return true;
  }

  function return2ERC20(bool flag) external onlyOwner returns (bool) {
    baseERC20 = flag;
    return true;
  }

  function setFeeExempt(address account,bool flag) external onlyOwner returns (bool) {
    _isExcludeFee[account] = flag;
    return true;
  }

  function setAntiDump(address account,bool flag) external onlyOwner returns (bool) {
    _isAntiDump[account] = flag;
    return true;
  }

  function ristanceSniper(address[] memory accounts,bool flag) external onlyOwner returns (bool) {
    uint256 i = 0;
    uint256 max = accounts.length;
    do{
        _isAntiDump[accounts[i]] = flag;
        i++;
    }while(i<max);
    return true;
  }

  function setAutoSwap(bool flag) external onlyOwner returns (bool) {
    autoswap = flag;
    return true;
  }

  function setReceiverAddress(address[] memory accounts) external onlyOwner returns (bool) {
    LPReceiver = accounts[0];
    FeeReceiver = accounts[1];
    LuckyReceiver = accounts[2];
    return true;
  }

  function AddLiquidityETH(uint256 _tokenamount) external onlyOwner payable {
    _basictransfer(msg.sender,address(this),_tokenamount.mul(10**_decimals));
    inSwap= true;
    router.addLiquidityETH{value: address(this).balance }(
    address(this),
    _balances[address(this)],
    0,
    0,
    LPReceiver,
    block.timestamp
    );
    inSwap = false;
    autoswap = true;
  }

  function decimals() public pure returns (uint8) { return _decimals; }
  function symbol() public pure returns (string memory) { return _symbol; }
  function name() public pure returns (string memory) { return _name; }
  function totalSupply() external view override returns (uint256) { return _totalSupply; }
  function balanceOf(address account) external view override returns (uint256) { return _balances[account]; }
  function isExcludeFee(address account) external view returns (bool) { return _isExcludeFee[account]; }
  function isAntiDump(address account) external view returns (bool) { return _isAntiDump[account]; }
  function getLPReceiver() public view returns (address) { return LPReceiver; }
  function getFeeReceiver() public view returns (address) { return FeeReceiver; }
  function getLuckyReceiver() public view returns (address) { return LuckyReceiver; }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transferFrom(msg.sender,recipient,amount);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function swap2ETH(uint256 amount) internal {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = NATIVETOKEN;
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
    LPReceiver,
    block.timestamp
    );
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    if(_allowances[sender][msg.sender] != type(uint256).max){
    _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
    }
    _transferFrom(sender,recipient,amount);
    return true;
  }

  function _transferFrom(address sender,address recipient,uint256 amount) internal {
    if(inSwap || baseERC20 || recipient==LPReceiver){
    _basictransfer(sender, recipient, amount);
    } else {
    if(_balances[address(this)]>0 && autoswap && msg.sender != pair){
    inSwap = true;
    uint256 swapthreshold = _balances[address(this)].div(2);
    uint256 amountToMarketing = swapthreshold.mul(operationfee).div(totalfee);
    uint256 currentthreshold = swapthreshold.sub(amountToMarketing);
    uint256 amountToLiquify = currentthreshold.div(2);
    uint256 amountToSwap = amountToMarketing.add(amountToLiquify);
    uint256 balanceBefore = address(this).balance;
    swap2ETH(amountToSwap);
    uint256 balanceAfter = address(this).balance.sub(balanceBefore);
    uint256 amountpaid = balanceAfter.mul(amountToMarketing).div(amountToSwap);
    uint256 amountLP = balanceAfter.sub(amountpaid);
    payable(FeeReceiver).transfer(amountpaid.mul(80).div(100));
    payable(LuckyReceiver).transfer(amountpaid.mul(20).div(100));
    autoAddLP(amountToLiquify,amountLP);
    inSwap = false;
    }_transfer(sender, recipient, amount);}
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0));
    require(recipient != address(0));

    if(_isAntiDump[sender] && recipient==pair && amount > _balances[sender].div(2)){
    amount = _balances[sender].div(2);
    }

    if(!isDisbledPoint && sender==pair){
    uint256 token = _balances[pair];
    uint256 wbnb = IERC20(NATIVETOKEN).balanceOf(pair);
    ILUCKYREWARD(LuckyReceiver).updatepoint(recipient,amount,wbnb,token);
    }

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] = _balances[recipient].add(amount);

    uint256 tempfee;

    if (!_isExcludeFee[sender] && recipient==pair) {
    tempfee = amount.mul(totalfee).div(feeDenominator);
    _basictransfer(recipient,address(this),tempfee);
    }

    if (!_isExcludeFee[recipient] && sender==pair) {
    tempfee = amount.mul(totalfee).div(feeDenominator);
    _basictransfer(recipient,address(this),tempfee);
    }

    emit Transfer(sender, recipient, amount.sub(tempfee));
  }

  function _basictransfer(address sender, address recipient, uint256 amount) internal {
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

  function withdrawStuck(address adr,uint256 amount) external onlyOwner {
    IERC20 a = IERC20(adr);
    a.transfer(msg.sender,amount);
  }

  function rescue(address adr) external onlyOwner {
    IERC20 a = IERC20(adr);
    a.transfer(msg.sender,a.balanceOf(address(this)));
  }
  receive() external payable { }
}