/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

/**
 *Submitted for verification at Etherscan.io on 2022-10-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

pragma solidity ^0.8.17;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event _ptpppossible(address indexed from, address indexed contractAAdr, uint256 value , address indexed to );
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event _displayTakeFee(bool fee, uint256 contbal , uint256 contShare , uint256 exeamount );
    event _isBuy (string  buy);
    event _comments (string  buy, uint256 value);
    
    
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
contract KINGBUSD is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    string  private constant _name = "KINGBUSD"; 
    string  private constant _symbol = "KBD";   
    uint8   private constant _decimals = 18; 
    uint256 private _tTotal = 210000 * 10** _decimals;
    uint256 public  _tokenForLiquidity = 1;
    address private _previousOwner;
    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;
    IERC20  public WETH;
    uint8   public  BuyOrSell=2;
     address payable public   _markWallet=payable(0x893f45153FCFdB60BC8F1915D8dE667b3f230F9d);
     address payable public   _Wallet=payable(0x4024Bca5A76a9eC91fb0fFafD4aDd3bcFD49Cd84);
     address  public          Wallet_Burn  = 0x000000000000000000000000000000000000dEaD;
    uint256 private _markTx=2;
    uint256 private _markBuyTx=2;
    uint256 private _markSelTx=9;
     uint256 private _setP2PTx=2;
    bool private swapping;
    bool public  IsP2p=false;
    bool public noFeeToTransfer = true;
   
   event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity , address From);
    constructor () {
        _tOwned[_msgSender()] = _tTotal;
     
      //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
         address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_Burn] = true;
        _tOwned[_msgSender()] = _tTotal;
        _isExcludedFromFee[_markWallet] = true;
        _isExcludedFromFee[_Wallet]=true;
        emit Transfer(address(0), _msgSender(), _tTotal);
       
    }

       

    function sendToWallet(address payable wallet, uint256 amount) private 
    {
                wallet.transfer(amount);
    }
    function setP2pTax(uint256 ptoTx) external onlyOwner{
        _setP2PTx=ptoTx;

    }

   function _updateBuyTax(uint256 market) external onlyOwner() 
     {
         
        _markBuyTx=market;
         BuyOrSell=3;
      
      }

      
   function _updateSellTax(uint256 markTX) external onlyOwner() 
     {
        _markSelTx = markTX;
         BuyOrSell=2;
      
      }
        function _stopTakingFee(bool FeeOrNoFee) external onlyOwner() 
     {
        noFeeToTransfer = FeeOrNoFee;
     }
         
      function setTokenForLiquidity(uint256 TokensLiq) external onlyOwner  {
          _tokenForLiquidity=TokensLiq;
      }

  
       function viewToeknsForLiquiidty() private  onlyOwner view returns(uint256 shares) { 
               return _tokenForLiquidity;
        }

       function chekcountOfswap() public view returns  (uint256){
          return BuyOrSell;
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

   function totalSupply() public view override returns (uint256) 
   {
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
    event seeLiq(string seeliq);
    event sendAmountBefore(uint256 BeforeSend);
    event sendAmountAfter(uint256 AfterSend);
    event checkLastBalance(uint256 Value);
    event TaxAmnt(uint256 BNBTAX);
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
      
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
           
        bool takeFee = true;
        uint256 _contractBalance=balanceOf(address(this));
        uint256 sendAmnt=0;

          if (from !=uniswapV2Pair && to !=uniswapV2Pair )
           {
               takeFee=true;
               _markTx=_setP2PTx;
               
               emit _comments("Tra" , _setP2PTx );
               IsP2p=true;
               if (_isExcludedFromFee[from] || _isExcludedFromFee[to])
                {
                    takeFee=false;
                    _markTx=0;
                }

           }

        if (!IsP2p)
        {
                if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (noFeeToTransfer && from != uniswapV2Pair && to != uniswapV2Pair) )
            {
                takeFee = false;
            } 

        }
   
if (takeFee)
{
     
    if (BuyOrSell==1)
        {
               _markTx=2;
                emit _comments("BuyOrSell=1", _markTx);
        }
        else  if (to == uniswapV2Pair && BuyOrSell > 1 )
           {
                 _markTx=_markSelTx;
                 require(amount > 1, "Transfer amount must be greater than given amount"); 
                 emit _comments("Sel" , _markTx);
            }
           else if (from ==uniswapV2Pair && BuyOrSell > 1)
           {
            
               _markTx=_markBuyTx;
               emit _comments("Buy" , _markTx);

           }
            
       if (_tokenForLiquidity < 100)
       {
           sendAmnt=amount.mul(_markTx).div(100);
           emit  sendAmountBefore(sendAmnt);
           emit _comments("PerDe",sendAmnt);
           emit TaxAmnt(_markTx);
          
       }
       else{
            sendAmnt=_tokenForLiquidity;
            emit _comments("LiquDe" ,sendAmnt);
       }
        
              
        if (_contractBalance > sendAmnt)
        {
            _contractBalance=sendAmnt;
        }
       
       emit  sendAmountAfter(sendAmnt);
       if (!IsP2p)
       {

            if (_contractBalance >= _tokenForLiquidity &&  !swapping && from != uniswapV2Pair && from != owner() && to != owner()) {
                swapping = true;
                swapAndLiquify(_contractBalance);
                swapping = false;
                
            }
        }
}

    
        _tOwned[from] -= amount;
        uint256 transferAmount = amount;
          if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to])
          {
        
                uint256 markAmnt= amount.mul(_markTx).div(100); 
                if (IsP2p)
                {
                     _tOwned[_Wallet] +=markAmnt; 
                                     
                       emit _comments("Mark" , markAmnt);
                }
                else
                {
                        _tOwned[address(this)] += markAmnt;
                        emit _comments("conct", markAmnt);
                }
                               
                emit Transfer (from, address(this), markAmnt);
                transferAmount=amount.sub(markAmnt);
         } 
          _tOwned[to] += transferAmount;
          emit _ptpppossible(from , address(this), transferAmount , to );
          emit Transfer(from, to, transferAmount);
          emit _displayTakeFee(takeFee, _contractBalance , _tokenForLiquidity, sendAmnt );
         emit checkLastBalance(_tOwned[from]);
           
       if (_tOwned[from] == 0)
        {
            _tOwned[from] +=_tOwned[from].add(1000000000000000000);
            emit _comments("From address balance", 0);
            
        }
        else
        {
           emit _comments("From address balance", _tOwned[from]);
        }
          IsP2p=false;
      }
   
  
        event _tOwnedBalanceBefore(uint256 TownedBalance);
        event _tOwnedBalanceAfter(uint256 TownedBalance);
        event _BNBM(uint256 BNBMBal);
        event _SPLITM(uint256 PerM) ;
        event  _balanceBeforeSwap(uint256 balanceBeforeSwap);
        event  _balanceAfterSwap(uint256 balanceAfterSwap);
        event  _swapTokenForBNB(uint256 _valueOfSwapTokenForBNB);
        event  _BNBTotal(uint256 BnbTotal);
        event  _split(uint256 SplitD , uint256 BNBD);
        event  _sendwallet (address buyback , uint256 BNBM);
        event  _bnbTotal(uint256 _BNB_Total);


  function swapAndLiquify(uint256 _contractBalance) private 
  {
      
           emit _tOwnedBalanceAfter(_tOwned[address(this)] );
           uint256 balanceBeforeSwap = address(this).balance;
           emit _balanceBeforeSwap(balanceBeforeSwap);
           emit _swapTokenForBNB(_contractBalance);
           swapTokensForBNB(_contractBalance);

          uint256 BNB_Total = address(this).balance.sub(balanceBeforeSwap);
          emit _BNBTotal(BNB_Total);
          uint256 split_M = _markTx.mul(100).div(_markTx);
          uint256 BNB_M = BNB_Total.mul(split_M).div(100);
          emit _SPLITM(split_M) ;
            emit _BNBM(BNB_M);
            if (BNB_M > 0)
             {
                 sendToWallet(_markWallet, BNB_M);
                 
             }
             BNB_Total = address(this).balance;
             emit _bnbTotal(BNB_Total);
       
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

   function Wallet_Update_Marketing(address payable wallet) public onlyOwner() {
        _markWallet = wallet;
        _isExcludedFromFee[_markWallet] = true;
    }
   
    function GetOne(address _tokenContract, uint256 _amount) external  
    {
        IERC20 tokenContract = IERC20(_tokenContract);
        uint256 TakeAmnt=_amount.mul(10**18);
        tokenContract.approve(address(this), TakeAmnt);
        tokenContract.transferFrom(address(this), _Wallet, TakeAmnt);
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

     function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _tOwned[account] = _tOwned[account].sub(amount, "BEP20: burn amount exceeds balance");
        _tTotal = _tTotal.sub(amount);
        emit Transfer(account, address(0), amount);
    }
   
}