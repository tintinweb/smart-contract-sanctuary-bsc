/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.9;
 
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
   function _msgSender() internal view virtual returns (address) {
       return msg.sender;
   }

   function _msgData() internal view virtual returns (bytes calldata) {
       this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
       return msg.data;
   }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
   address private _owner;

   event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
   /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
   constructor () {
       address msgSender = _msgSender();
       _owner = msgSender;
       emit OwnershipTransferred(address(0), msgSender);
   }

   /**
    * @dev Returns the address of the current owner.
    */
   function owner() public view returns (address) {
       return _owner;
   }

   /**
    * @dev Throws if called by any account other than the owner.
    */
   modifier onlyOwner() {
       require(_owner == _msgSender(), "Ownable: caller is not the owner");
       _;
   }

   /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
   function renounceOwnership() public virtual onlyOwner {
       emit OwnershipTransferred(_owner, address(0));
       _owner = address(0);
   }

   /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
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


contract Cryptonex is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances; 
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) public _isExcludedMaxTransactionAmount;

    bool _tradingActive = true;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    string private _name = "Cryptonex";
    string private _symbol = "CTX";
    uint8 private _decimals = 18;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10 ** 9 * 10 ** _decimals;

    uint256 public _liquidityTax;
    uint256 public _liquidityBuyTax = 1;
    uint256 public _liquiditySellTax = 1;

    uint256 public _marketingTax;
    uint256 public _marketingBuyTax = 11;
    uint256 public _marketingSellTax = 5;

    uint256 public _buybackTax;
    uint256 public _buybackBuyTax = 0;
    uint256 public _buybackSellTax = 6;

    uint256 public _totalTax;

    IUniswapV2Router02 public  uniswapV2Router;
    address public uniswapV2Pair;
    IERC20 public WETH;

    address public _ownerAddress = 0xDDE1C4DC37BACAbf7465470D452655c2975B466B;
    address public _marketingAddress = 0xFb5f78728775d3aa2d6618d4D72a1A041B3CB6a4;
    address public _buybackAddress = 0xB80a8Ea0Aa0f523D7f91E3e03f5F3b9a0b7d4B65;

    address public constant _deadAdderess = address(0xdead);

    uint256 private numTokensSellToAddToLiquidity = _tTotal / 500;
    uint256 public _maxwalletamount = _tTotal / 100;
    uint256 public _maxTxAmount = _tTotal / 200;
    uint256 public _tokenAmountForMarketingTax;
    uint256 public _tokenAmountForBuybackTax;
    uint256 public _tokenAmountForLiquidityTax;
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event ExcludeFromFee(address account);
    event IncludeInFee(address account);
    event SellTaxPercent(uint256 liquiditySellTax, uint256 marketingSellTax, uint256 buybackSellTax);
    event BuyTaxPercnetUpdate(uint256 liquidityBuyTax, uint256 marketingBuyTax, uint256 buybackBuyTax);
    event MarketingAddressUpdate(address marketingAddress);
    event BuybackAddressUpdate(address buybackAddress);
    event EnableTradingUpdate(bool tradingActive);
    event NumTokenSellToAddToLiquidityPercentageAndMaxwalletAmount(uint256 _numTokensSellToAddToLiquidityPercentage, uint256 _maxwalletamountPercentage, uint256 _maxTxAmountPercentage);
    event AutomatedMarketMakerPairsUpdate(address newPair);
    event UpdateAccountMaxWalletLimit(address account, bool enabled);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () public {
        _tOwned[_ownerAddress] = _tTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        WETH = IERC20(_uniswapV2Router.WETH());

        _isExcludedFromFee[_ownerAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        automatedMarketMakerPairs[uniswapV2Pair] = true;
        automatedMarketMakerPairs[address(uniswapV2Router)] = true;
        
        emit Transfer(address(0), _ownerAddress, _tTotal);
    }

    // ERC-20 standard functions

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
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

    function _approve(address owner, address spender, uint256 amount) private {
       require(owner != address(0), "ERC20: approve from the zero address");
       require(spender != address(0), "ERC20: approve to the zero address");

       _allowances[owner][spender] = amount;
       emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function burn(uint256 tBurn) external {

       address sender = _msgSender();
       require(sender != address(0), "ERC20: burn from the zero address");
       require(sender != address(_deadAdderess), "ERC20: burn from the burn address");

       uint256 balance = balanceOf(sender);
       require(balance >= tBurn, "ERC20: burn amount exceeds balance");
       _tOwned[sender] = _tOwned[sender].sub(tBurn);

       _burnTokens( sender, tBurn);
    }

    function _burnTokens(address sender, uint256 tBurn) internal {
       _tOwned[_deadAdderess] = _tOwned[_deadAdderess].add(tBurn);

       emit Transfer(sender, _deadAdderess, tBurn);
    }

    function _transfer(
       address from,
       address to,
       uint256 amount
    ) internal {
       require(from != address(0), "ERC20: transfer from the zero address");
       require(to != address(0), "ERC20: transfer to the zero address");
       require(amount > 0, "Transfer amount must be greater than zero");

       if(from != owner() && to != owner()) {
           if(!_tradingActive){
               require(_isExcludedFromFee[from] || _isExcludedFromFee[to], "Trading is not active.");
           }           

           if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) { 
               require(amount + balanceOf(to) <= _maxwalletamount, "Max wallet exceeded");

           } else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
               require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

           } else if(!_isExcludedMaxTransactionAmount[from] && !_isExcludedMaxTransactionAmount[to]) {
               require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
               require(amount + balanceOf(to) <= _maxwalletamount, "Max wallet exceeded");
           } else if (_isExcludedMaxTransactionAmount[from] && !_isExcludedMaxTransactionAmount[to]) {
               require(amount + balanceOf(to) <= _maxwalletamount, "Max wallet exceeded");
           }
           
       }

       uint256 contractTokenBalance = balanceOf(address(this));
       
       bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
       if (
           overMinTokenBalance &&
           !inSwapAndLiquify &&
           !automatedMarketMakerPairs[from] &&
           swapAndLiquifyEnabled
       ) {
           contractTokenBalance = numTokensSellToAddToLiquidity;
           swapAndLiquity(contractTokenBalance);
       }
       
       bool takeFee = true;
       
       if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
           takeFee = false;
       }
       _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquity(uint256 contractTokenBalance) internal lockTheSwap {
       uint256 totalTokenAmount = _tokenAmountForLiquidityTax + _tokenAmountForMarketingTax + _tokenAmountForBuybackTax;
       uint256 tokenForMarketing = contractTokenBalance * (_tokenAmountForMarketingTax) / totalTokenAmount;
       uint256 tokenForLiquidity = contractTokenBalance * (_tokenAmountForLiquidityTax) / totalTokenAmount;
       uint256 tokenForBuyback = contractTokenBalance * (_tokenAmountForBuybackTax) / totalTokenAmount;       
       uint256 half = tokenForLiquidity.div(2);
       uint256 otherHalf = tokenForLiquidity.sub(half);
       uint256 initialBalance = address(this).balance;
       uint256 tokenAmountForSwap = tokenForMarketing + tokenForBuyback + half; 
       swapTokensForEth(tokenAmountForSwap); 

       uint256 newBalance = address(this).balance.sub(initialBalance);
       uint256 ethForLiquidity = newBalance * half / tokenAmountForSwap;
       uint256 ethForMarketing = newBalance * tokenForMarketing / tokenAmountForSwap;
       uint256 ethForBuyback = newBalance * tokenForBuyback / tokenAmountForSwap;

       transferToAddressETH(payable(_marketingAddress), ethForMarketing);
       transferToAddressETH(payable(_buybackAddress), ethForBuyback);

       addLiquidity(otherHalf, ethForLiquidity);
       _tokenAmountForLiquidityTax = 0;
       _tokenAmountForMarketingTax = 0;
       _tokenAmountForBuybackTax = 0;

       
       emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) internal {

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

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {

       _approve(address(this), address(uniswapV2Router), tokenAmount);

       uniswapV2Router.addLiquidityETH{value: ethAmount}(
           address(this),
           tokenAmount,
           0, // slippage is unavoidable
           0, // slippage is unavoidable
           owner(),
           block.timestamp
       );
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) internal {
       if(!takeFee) {
          removeAllTax();
       } else if (automatedMarketMakerPairs[sender]) {
           setTaxBuyTax();
       } else  {
           setTaxSellTax();
       } 
       _transferStandard(sender, recipient, amount);
    
    }

    function removeAllTax() internal {                 
       _liquidityTax = 0;
       _marketingTax = 0;
       _buybackTax = 0;
       _totalTax = 0;
    }
   
    function setTaxBuyTax() internal {
      _liquidityTax = _liquidityBuyTax;
      _marketingTax = _marketingBuyTax;
      _buybackTax = _buybackBuyTax;
      _totalTax = _liquidityTax.add(_marketingTax).add(_buybackTax);

    }

    function setTaxSellTax() internal {
      _liquidityTax = _liquiditySellTax;
      _marketingTax = _marketingSellTax;
      _buybackTax = _buybackSellTax;
      _totalTax = _liquidityTax.add(_marketingTax).add(_buybackTax);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        uint256 tTotalTax = tAmount.mul(_totalTax).div(100);
        uint256 tTransferAmount = tAmount.sub(tTotalTax);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        
        if(_totalTax > 0) {
           _takeLiquidity(tTotalTax.mul(_liquidityTax).div(_totalTax));
           _takeMarketing(tTotalTax.mul(_marketingTax).div(_totalTax));
           _takeBuyback(tTotalTax.mul(_buybackTax).div(_totalTax));
        }        
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        _tokenAmountForLiquidityTax += tLiquidity;
        _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function _takeMarketing(uint256 tMarketing) private {
        _tokenAmountForMarketingTax += tMarketing;
        _tOwned[address(this)] = _tOwned[address(this)].add(tMarketing);
    }

    function _takeBuyback(uint256 tBuyback) private {
        _tokenAmountForBuybackTax += tBuyback;
        _tOwned[address(this)] = _tOwned[address(this)].add(tBuyback);
    }
        
   // External Read functions          

    function isExcludedFromFee(address account) public view returns(bool) {
       return _isExcludedFromFee[account];
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    // Write functions
    
    function excludeFromFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = true;

        emit ExcludeFromFee(account);
    }
    
    function includeInFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = false;

        emit IncludeInFee(account);
    }
    
    function setBuyTaxPercent(uint256 liquidityBuyTax, uint256 marketingBuyTax, uint256 buybackBuyTax) external onlyOwner() {
        _liquidityBuyTax = liquidityBuyTax;
        _marketingBuyTax = marketingBuyTax;
        _buybackBuyTax = buybackBuyTax;

        emit BuyTaxPercnetUpdate(liquidityBuyTax, marketingBuyTax, buybackBuyTax);
    }
    
    function setSellTaxPercent(uint256 liquiditySellTax, uint256 marketingSellTax, uint256 buybackSellTax) external onlyOwner() {
        _liquiditySellTax = liquiditySellTax;
        _marketingSellTax = marketingSellTax;
        _buybackSellTax = buybackSellTax;

        emit SellTaxPercent(liquiditySellTax, marketingSellTax, buybackSellTax);
    }

    function setMarketingAddress(address marketingAddress) external onlyOwner() {
       _marketingAddress = marketingAddress;

       emit MarketingAddressUpdate(marketingAddress);
    }
    
    function setBuybackAddress(address buybackAddress) external onlyOwner() {
       _buybackAddress = buybackAddress;

       emit BuybackAddressUpdate(buybackAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner() {
        swapAndLiquifyEnabled = _enabled;

        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setEnableTrading(bool tradingActive) external onlyOwner() {
       _tradingActive = tradingActive;

       emit EnableTradingUpdate(tradingActive);
    }

    function setNumTokensSellToAddToLiquidityPercentageAndmaxwalletamount(uint256 _numTokensSellToAddToLiquidityPercentage, uint256 _maxwalletamountPercentage, uint _maxTxAmountPercentage) external onlyOwner() {
       numTokensSellToAddToLiquidity = _tTotal.mul(_numTokensSellToAddToLiquidityPercentage).div(10000);
       _maxwalletamount = _tTotal.mul(_maxwalletamountPercentage).div(10000);
       _maxTxAmount = _tTotal.mul(_maxTxAmountPercentage).div(10000);

       emit NumTokenSellToAddToLiquidityPercentageAndMaxwalletAmount(_numTokensSellToAddToLiquidityPercentage, _maxwalletamountPercentage, _maxTxAmountPercentage);
    }

    function setAutomatedMarketMakerPairs(address newPair) external onlyOwner() {
       automatedMarketMakerPairs[newPair] = true;

       emit AutomatedMarketMakerPairsUpdate(newPair);
    }

    function SetAccountMaxWalletLimit(address account, bool enabled) external onlyOwner() {
        _isExcludedMaxTransactionAmount[account] = enabled;
        emit UpdateAccountMaxWalletLimit(account, enabled);
    }

    function airdrop(address recipient, uint256 amount) external onlyOwner() {
       _transfer(_msgSender(), recipient, amount * 10**18);
    }
   
    function airdropInternal(address recipient, uint256 amount) internal {
       _transfer(_msgSender(), recipient, amount);
    }
   
    function airdropArray(address[] calldata newholders, uint256[] calldata amounts) external onlyOwner(){
       uint256 iterator = 0;
       require(newholders.length == amounts.length, "must be the same length");
       while(iterator < newholders.length){
           airdropInternal(newholders[iterator], amounts[iterator] * 10**18);
           iterator += 1;
       }
    }

    receive() external payable {}

}