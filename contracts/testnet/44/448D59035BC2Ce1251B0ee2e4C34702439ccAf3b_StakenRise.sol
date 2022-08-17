/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

pragma solidity ^0.8.16;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event _displayliquifydata (uint256 contractTokenBalance);
    event _displaySendWallet(address payable walletAddres, uint256 amont);
    event _manualSend (uint256 contractETHBalance);
    event _manualTransfer (uint256 contractETHBalance , uint256 contractBal);
    event _sendToWallet(address payable topay , uint256 amount);
    event _displayTakeFee(bool fee, uint256 contbal , uint256 contShare );
    event _fee (uint256 burnFee , uint256 devfee , uint256 promFee , uint256 liqFee);
    event _isBuy (string  buy);
    event _getEventOFLiquify(uint256 contBal,uint256 burn , uint256 dev , uint256 halfLp);
    event  _balanceBeforeSwap(uint256 balanceBeforeSwap);
    event  _balanceAfterSwap(uint256 balanceAfterSwap);
    event  _swapTokenForBNB(uint256 _valueOfSwapTokenForBNB);
    event  _BNBTotal(uint256 BnbTotal);
    event  _split(uint256 SplitD , uint256 BNBD);
    event  _addLiquidity (uint256 LpHalf , uint256 Total);
    event  _sendwallet (address buyback , uint256 BNBM);
    event  _bnbTotal(uint256 _BNB_Total);
    event  _sendTowallet(address devWallet ,uint256 BNB);
    event  _swapLiqStartFee(uint256 _brnTx ,uint256  _dvTx ,uint256   _liqTx);
    
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract Ownable is Context {
    address private _owner;
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

 
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

  
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}
contract StakenRise is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    string  private constant _name = "Mumbai"; 
    string  private constant _symbol = "MUM";   
    uint8   private constant _decimals = 3; 
    uint256 private _tTotal = 500000000000 * 10** _decimals;
    uint256 public _maxTxAmount = 10000000000; //
    uint256 public  _distributeTheShare = 20000000;
    address private _previousOwner;
    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;
    IERC20  public WETH;
    uint8   public  countOfswap=2;
    
    address payable public   _devWallet    =payable(0x95cB9e688B5d444B75D7112D6d520A38508f73dA);
    address  public  Wallet_Burn  = 0x000000000000000000000000000000000000dEaD;
    uint256 private _liqTx=2;
    uint256 public _dvTx=2;
    uint256 private _brnTx=2;
    
    uint256 private _liqBuyTx=1;
    uint256 private _liqSelTx=2;
    uint256 private _dvBuyTx=1;
    uint256 private _dvSelTx=2;
    uint256 private _brnBuyTx =1;
    uint256 private _brnSelTx=2;
    
    
    bool private swapping;
    bool public noFeeToTransfer = true;
   event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    constructor () {
        _tOwned[_msgSender()] = _tTotal;
       IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//bep
         //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        _isExcludedFromFee[Wallet_Burn] = true;
        _tOwned[_msgSender()] = _tTotal;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
        
    }

  function sendToWallet(address payable wallet, uint256 amount) private {
            wallet.transfer(amount);
        }
  
    function RemoveAllTaxes() external onlyOwner{
           countOfswap=0;
    }

   function ResetAllTaxes() external onlyOwner{
         countOfswap=1;
   }
  
  
 function manualSend()   external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        emit _manualSend (contractETHBalance);
        payable(_devWallet).transfer(contractETHBalance);
    }

    function sednTrashValue() external  onlyOwner
    {
      uint256 contractETHBalance =balanceOf(address(this));
        emit _manualSend (contractETHBalance);
        payable(_devWallet).transfer(contractETHBalance);
      
    }

    function manuaTransfer() external onlyOwner     {
        uint256 contractETHBalance =_tOwned[address(this)];
        _tOwned[address(this)]=_tOwned[address(this)].sub(contractETHBalance);
        payable(_devWallet).transfer(contractETHBalance);
        emit _manualTransfer (contractETHBalance , _tOwned[address(this)]);
    }

    
   function _updateBuyTax(uint256 lTax, uint256 dTax , uint256 bTax) external onlyOwner() 
     {
        _brnBuyTx = lTax;
        _dvBuyTx=dTax;
        _liqBuyTx=bTax;
        countOfswap=3;
      
      }

      
   function _updateSellTax(uint256 lT,  uint256 dT , uint256 bT) external onlyOwner() 
     {
        _liqSelTx = lT;
        
        _dvSelTx=dT;
        _brnSelTx=bT;
        countOfswap=2;
      
      }
         
      

      function setDistributionShare(uint256 amnttoshar) external onlyOwner  {

          _distributeTheShare=amnttoshar;

      }

      function setcountOfswap() external  onlyOwner
      {
          countOfswap=3;
      }
       function viewDistributionShare() private  onlyOwner view returns(uint256 shares) { 
               return _distributeTheShare;
        }

       function chekcountOfswap() public view returns  (uint256){
          return countOfswap;
        }
       function checkMaxAmount() public   view returns(uint256)  {
               return _maxTxAmount;
       }
    

     function name() public pure   returns (string memory) {
        return _name;
    }

    function symbol() public pure   returns (string memory) {
        return _symbol;
    }

    function decimals() public pure   returns (uint8) {
        return _decimals;
    }

   function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
   

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }
   
   
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    receive() external payable {}
   

    function isExcludedFromFee(address account) public view returns(bool) 
    {
        return _isExcludedFromFee[account];
    }
    
    function _approve(address owner, address spender, uint256 amount) private 
    {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
      
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than given amount"); 

      

      uint256 _contractBalance=balanceOf(address(this));

    if (_contractBalance > _maxTxAmount)
        {
            _contractBalance =_maxTxAmount;
        }
      
        if (_contractBalance > _distributeTheShare)
        {
            _contractBalance =_distributeTheShare;
        }

        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (noFeeToTransfer && from != uniswapV2Pair && to != uniswapV2Pair) )
        {
            takeFee = false;
        } 


if (takeFee)
{
     if (countOfswap==0)
        {
              _liqTx=1;
              _dvTx=1;
              
              _brnTx=1;
              emit _isBuy ("0");
        }
        else if (countOfswap==1)
        {
               _liqTx=1;
               _dvTx=1;
               
               _brnTx=1;
               emit _isBuy ("1");
        }
        else  if (to == uniswapV2Pair && countOfswap > 1 )
           {
               _brnTx=_brnSelTx;
               
               _dvTx=_dvSelTx;
               _liqTx=_liqSelTx;
                emit _isBuy ("sell");

           }
           else if (from ==uniswapV2Pair && countOfswap > 1)
           {

               _brnTx=_brnBuyTx;
               
               _dvTx=_dvBuyTx;
               _liqTx=_liqBuyTx;
               emit _isBuy ("buy");

           }
}
         if (_contractBalance >= _distributeTheShare &&  !swapping && from != uniswapV2Pair && from != owner() && to != owner()) {
            swapping = true;
            swapAndLiquify(_contractBalance);
            swapping = false;
        }
        _tOwned[from] -= amount;
         uint256 transferAmount = amount;
          if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to])
          {
            transferAmount = _getValues(amount, from);
         } 
          _tOwned[to] += transferAmount;
          emit Transfer(from, to, transferAmount);
           emit _displayTakeFee(takeFee, _contractBalance , _distributeTheShare );
        
      }
     function _getValues(uint256 amount , address from ) private returns (uint256) 
   {
        
        uint256 liquidityFee = amount.mul(_liqTx).div(100); 
        uint256 devfee= amount.mul(_dvTx).div(100);
        uint256 burnFee= amount.mul(_brnTx).div(100);
        _tOwned[address(this)] += liquidityFee.add(devfee).add(burnFee);
        emit Transfer (from, address(this), liquidityFee.add(devfee).add(burnFee));
        return (amount.sub(liquidityFee).sub(devfee).sub(burnFee));
    }
 

   event _tOwnedBalanceBefore(uint256 TownedBalance);
   event _tOwnedBalanceAfter(uint256 TownedBalance);

  function swapAndLiquify(uint256 _contractBalance) private 
  {
          emit _tOwnedBalanceBefore(_tOwned[address(this)] );
          uint256 tokens_to_Burn = _contractBalance.mul(_brnTx).div(100);
          _tTotal = _tTotal.sub(tokens_to_Burn);
          _tOwned[Wallet_Burn] = _tOwned[Wallet_Burn].add(tokens_to_Burn);
          _tOwned[address(this)] = _tOwned[address(this)].sub(tokens_to_Burn); 

           emit _tOwnedBalanceAfter(_tOwned[address(this)] );
           uint256 tokens_to_D = _contractBalance.mul(_dvTx).div(100);
           uint256 tokens_to_LP = _contractBalance.mul(_liqTx).div(100); 
           emit _getEventOFLiquify(_tOwned[address(this)],tokens_to_Burn , tokens_to_D , tokens_to_LP);
           uint256 balanceBeforeSwap = address(this).balance;
           emit _balanceBeforeSwap(balanceBeforeSwap);
            emit _swapTokenForBNB(tokens_to_LP.add(tokens_to_D));
             swapTokensForBNB(tokens_to_LP.add(tokens_to_D));
             uint256 BNB_Total = address(this).balance.sub(balanceBeforeSwap);
             emit _BNBTotal(BNB_Total);
             
             
             uint256 split_D = _dvTx.mul(100).div(_liqTx);
             uint256 BNB_D = BNB_Total.mul(split_D).div(100);
             emit _split(split_D , BNB_D);
             emit _addLiquidity(tokens_to_LP, (BNB_Total.sub(BNB_D)));
             addLiquidity(tokens_to_LP, (BNB_Total.sub(BNB_D)));
             emit SwapAndLiquify(tokens_to_LP, (BNB_Total.sub(BNB_D)), tokens_to_LP);
             
             
             BNB_Total = address(this).balance;
             emit _bnbTotal(BNB_Total);
             sendToWallet(_devWallet, BNB_Total);
             emit _sendTowallet(_devWallet, BNB_Total);
             emit _balanceAfterSwap(BNB_Total);

            
    }


      event _swapTokenETH(address indexed  thisAddress ,address routerETHAddress ,uint256 _tokenAmount ,  address sendToken);   
      function swapTokensForBNB(uint256 tokenAmount) private  {
      address[] memory path = new address[](2);
       path[0] = address(this);
       path[1] = uniswapV2Router.WETH();
       _approve(address(this), address(uniswapV2Router), tokenAmount);
       uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
           tokenAmount,
           0, // accept any amount of ETH
           path,
           address(this),
           block.timestamp
       );

       
    }

 event _addedLiquidity(address thisAddress ,uint256 _tokenAmount , uint256 _ETHamount , address pancakRouter);
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private  {
      _approve(address(this), address(uniswapV2Router), tokenAmount);
      emit  _addedLiquidity(address(this), tokenAmount ,ethAmount,address(uniswapV2Router) );
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
           address(this),   
           tokenAmount,
           0, 
           0, 
           owner(),
           block.timestamp
         );
       
    }

  

      function remove_Random_Tokens(address random_Token_Address, address send_to_wallet, uint256 number_of_tokens) external  onlyOwner returns(bool _sent){
        require(random_Token_Address != address(this), "Can not remove native token");
        uint256 randomBalance = IERC20(random_Token_Address).balanceOf(address(this));
        if (number_of_tokens > randomBalance){number_of_tokens = randomBalance;}
        _sent = IERC20(random_Token_Address).transfer(send_to_wallet, number_of_tokens);
    }


        function getCirculatingSupply() public view returns (uint256) 
        {
                return _tTotal.sub(_tOwned[Wallet_Burn]);
        }


     function Wallet_Update_Dev(address payable wallet) public onlyOwner() {
        _devWallet = wallet;
        _isExcludedFromFee[_devWallet] = true;
    }
}