/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT

//*************************************************************************************************//

// Provided by EarthWalkers Dev Team
// TG : https://t.me/officialearthwalktoken

// Part of the MoonWalkers Eco-system
// Website : https://moonwalkerstoken.com/
// TG : https://t.me/officialmoonwalkerstoken
// Contact us if you need to build a contract
// Contact TG : @chrissou78, Mail : [email protected]
// Full Crypto services : smart-contracts, website, launch and deploy, KYC, Audit, Vault, BuyBot
// Marketing : AMA , Calls, TG Management (bots, security, links)

// and our on demand personnalised Gear shop
// TG : https://t.me/cryptojunkieteeofficial

//*************************************************************************************************//

pragma solidity ^0.8.15;
 
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
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
 
    function addLiquidity( address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB, uint liquidity); 
    function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity); 
    function removeLiquidity( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB); 
    function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountToken, uint amountETH); 
    function removeLiquidityWithPermit( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountA, uint amountB); 
    function removeLiquidityETHWithPermit( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountToken, uint amountETH); 
    function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts); 
    function swapTokensForExactTokens( uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts); 
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts); 
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts); 
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts); 
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts); 
 
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
 
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountETH); 
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountETH); 
    function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external; 
    function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline ) external payable; 
    function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external; 
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
 
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
 
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
 
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
 
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}
 
library SafeMathInt {
  function mul(int256 a, int256 b) internal pure returns (int256) {
    // Prevent overflow when multiplying INT256_MIN with -1
    // https://github.com/RequestNetwork/requestNetwork/issues/43
    require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));
 
    int256 c = a * b;
    require((b == 0) || (c / b == a));
    return c;
  }
 
  function div(int256 a, int256 b) internal pure returns (int256) {
    // Prevent overflow when dividing INT256_MIN by -1
    // https://github.com/RequestNetwork/requestNetwork/issues/43
    require(!(a == - 2**255 && b == -1) && (b > 0));
 
    return a / b;
  }
 
  function sub(int256 a, int256 b) internal pure returns (int256) {
    require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));
 
    return a - b;
  }
 
  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }
 
  function toUint256Safe(int256 a) internal pure returns (uint256) {
    require(a >= 0);
    return uint256(a);
  }
}
 
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {return payable(msg.sender);}
 
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
 
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
 
    function owner() public view virtual returns (address) {return _owner;}
 
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract BEP20 is Context, IBEP20 {
    using SafeMath for uint256;
 
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
 
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
 
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        //_decimals = 9;
    }
 
    function name() public view virtual returns (string memory) {return _name;}
    function symbol() public view virtual returns (string memory) {return _symbol;}
    function decimals() public view virtual returns (uint8) {return _decimals;}
    function totalSupply() public view virtual override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view virtual override returns (uint256) {return _balances[account];}

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
 
    function allowance(address owner, address spender) public view virtual override returns (uint256) {return _allowances[owner][spender];}
 
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
 
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "transfer amount exceeds allowance"));
        return true;
    }
 
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
 
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "decreased allowance below zero"));
        return true;
    }
 
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");
 
        _beforeTokenTransfer(sender, recipient, amount);
 
        _balances[sender] = _balances[sender].sub(amount, "transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
 
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "mint to the zero address");
 
        _beforeTokenTransfer(address(0), account, amount);
 
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
 
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "burn from the zero address");
 
        _beforeTokenTransfer(account, address(0), amount);
 
        _balances[account] = _balances[account].sub(amount, "burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
 
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");
 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }
 
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
 
contract SafeToken is Ownable {
    address payable safeManager;

    constructor() {
        safeManager = payable(msg.sender);
    }

    function setSafeManager(address payable _safeManager) public onlyOwner {
        safeManager = _safeManager;
    }

    function withdraw(address _token, uint256 _amount) external {
        require(msg.sender == safeManager);
        IBEP20(_token).transfer(safeManager, _amount);
    }

    function withdrawBNB(uint256 _amount) external {
        require(msg.sender == safeManager);
        safeManager.transfer(_amount);
    }
}

contract MegaMoon is BEP20, Ownable, SafeToken {
    using SafeMath for uint256;
 
    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;

    address payable public MarketingWallet; 
    address public DeadWallet;
    address private PancakeRouter;
         
    bool private swapping;
    bool private swapAndLiquifyEnabled = true;
    bool private tradingEnabled = false;
     
    uint256 private MaxSell = 1000000;
    uint256 private MaxWallet = 2000000;
    uint256 private SwapMin = 100000;
    uint256 private MaxTaxes = 15;
    uint256 private maxSellTransactionAmount; // max sell 1% of supply
    uint256 private maxWalletAmount; // max wallet amount 2%
    uint256 private swapTokensAtAmount;
    uint8 private constant decimal = 9;
    uint256 private constant InitialSupply = 100000000*10**decimal;
    uint256 private _liquidityUnlockTime = 0; 
    
    // Tax Fees
    uint256 private _LiquidityFee = 4;
    uint256 private _BurnFee = 0;
    uint256 private _MarketingFee = 3;

    uint256 private _Wallet2WalletFee = 0; // no wallet to wallet fee
    uint256 private _BuyFee = 5;
    uint256 private _SellFee = 0;
    uint256 private gasForProcessing = 500000;

    mapping (address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedFromMaxTx;
    mapping(address => bool) private _isBlacklisted; //blacklist function
    mapping (address => bool) private _isWhitelisted;
    mapping (address => bool) public automatedMarketMakerPairs;
 
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event MarketingWalletUpdated(address indexed newMarketingWallet, address indexed oldMarketingWallet);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event ExtendLiquidityLock(uint256 extendedLockTime);
     
    constructor() BEP20("Mega Moon", "MegamOOn") {
 
    MarketingWallet = payable(0x4aAB4ED440A8406eC15C140e3627dfc7701B9D0F); 
    DeadWallet = 0x000000000000000000000000000000000000dEaD;

    maxSellTransactionAmount = MaxSell * 10**decimal; // max sell 1% of supply
    maxWalletAmount = MaxWallet * 10**decimal; // max wallet amount 2%
    swapTokensAtAmount = SwapMin * 10**decimal;
    

 	if (block.chainid == 56) {
     	    PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
      } else if (block.chainid == 97) {
          PancakeRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
      } else revert();
        
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(PancakeRouter);
        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
 
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
 
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _SellFee = _LiquidityFee.add(_MarketingFee).add(_BurnFee);//YY%
       
        // exclude from paying fees or having max transaction amount
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DeadWallet] = true;
        _isExcludedFromFees[MarketingWallet] = true;
        _isExcludedFromFees[owner()] = true;
        
        // exclude from max tx
        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[DeadWallet] = true;
        _isExcludedFromMaxTx[MarketingWallet] = true;
        _isExcludedFromMaxTx[owner()] = true;

        // WHitelist
        _isWhitelisted[address(this)] = true;
        _isWhitelisted[DeadWallet] = true;
        _isWhitelisted[MarketingWallet] = true;
        _isWhitelisted[owner()] = true;
        
        //  _mint is an internal function in BEP20.sol that is only called here, and CANNOT be called ever again
        _mint(address(this), InitialSupply);
    }
 
    receive() external payable {}
 
    function decimals() public pure override returns (uint8) { return decimal; }
    
    function GetExclusions() public view returns(bool MaxTx, bool Fees, bool Blacklist, bool Whitelist){
        return (_isExcludedFromMaxTx[msg.sender], _isExcludedFromFees[msg.sender], _isBlacklisted[msg.sender], _isWhitelisted[msg.sender]);
    }

    function GetFees() public view returns(uint Buy, uint Sell, uint Wallet2Wallet, uint Liquidity, uint Marketing, uint Burn){
        return (_BuyFee, _SellFee, _Wallet2WalletFee, _LiquidityFee, _MarketingFee, _BurnFee);
    }

    function GetLimits() public view returns(uint256 SellMax, uint256 WalletMax, uint256 TaxMax, uint256 Gas, uint256 MinSwap, bool SwapLiq, bool ENtrading){
        return (MaxSell, MaxWallet, MaxTaxes, gasForProcessing, SwapMin, swapAndLiquifyEnabled, tradingEnabled);
    }

    function GetSupplyInfo() public view returns (uint256 initialSupply, uint256 circulatingSupply, uint256 burntTokens) {
        uint256 supply = totalSupply ();
        uint256 tokensBurnt = InitialSupply - supply;
        return (InitialSupply, supply, tokensBurnt);
    }
    
    function setMarketingWallet(address payable _newWallet) external onlyOwner {
  	    require(_newWallet != MarketingWallet, "The marketing wallet is already this address");
        _isExcludedFromFees[MarketingWallet] = false;
        _isExcludedFromMaxTx[MarketingWallet] = false;
        _isWhitelisted[MarketingWallet] = false;
               
        _isExcludedFromFees[_newWallet] = true;
        _isExcludedFromMaxTx[_newWallet] = true;
        _isWhitelisted[_newWallet] = true;
  	    MarketingWallet = _newWallet;
  	}

    function SetLimits(uint256 _maxWallet, uint256 _maxSell, uint256 _minswap, uint NewGas, uint256 MaxTax, bool _swapAndLiquifyEnabled) public onlyOwner {
        uint256 supply = totalSupply ();
        require(_maxWallet * 10**decimal >= supply / 100 && _maxWallet * 10**decimal <= supply, "MawWallet must be between totalsupply and 1% of totalsupply");
        require(_maxSell * 10**decimal >= supply / 1000 && _maxSell * 10**decimal <= supply, "MawSell must be between totalsupply and 0.1% of totalsupply" );
        require(_minswap * 10**decimal >= supply / 10000 && _minswap * 10**decimal <= supply, "MinSwap must be between totalsupply and 0.01% of totalsupply" );
        require(NewGas >= 300000, "Gas can't be lower than 300000");
        require(MaxTax >= 1 && MaxTax <= 25, "Max Tax must be updated to between 1 and 25 percent");
        
        MaxWallet = _maxWallet;
        maxWalletAmount = MaxWallet * 10**decimal;
        MaxSell = _maxSell;
        maxSellTransactionAmount = MaxSell * 10**decimal;
        SwapMin = _minswap;
        swapTokensAtAmount = SwapMin * 10**decimal;
        MaxTaxes = MaxTax;

        gasForProcessing = NewGas;
        emit GasForProcessingUpdated(NewGas, gasForProcessing);
       
        swapAndLiquifyEnabled = _swapAndLiquifyEnabled;
        emit SwapAndLiquifyEnabledUpdated(_swapAndLiquifyEnabled);
    }
    // Update all buy and sell taxes
    function SetTaxes(uint256 newBuyTax, uint256 wallet2walletfee, uint256 newLiquidityTax, uint256 newBurnTax, uint256 newMarketingTax) external onlyOwner() {
        require(newBuyTax <= MaxTaxes && newBuyTax >= newBurnTax, "Total Tax can't exceed MaxTaxes. or be lower than burn tax");
        require(newMarketingTax.add(newLiquidityTax).add(newBurnTax) <= MaxTaxes, "Total Tax can't exceed MaxTaxes.");
        require(newMarketingTax >= 0 && newBuyTax >= 0 && newLiquidityTax >= 0 && newBurnTax >= 0,"No tax can be negative");
        if(wallet2walletfee != 0){require(wallet2walletfee >= _BurnFee && wallet2walletfee <= MaxTaxes, "Wallet 2 Wallet Tax must be updated to between burn tax and 25 percent");}
        
        _BuyFee = newBuyTax;
        _Wallet2WalletFee = wallet2walletfee;
        _LiquidityFee = newLiquidityTax;
        _BurnFee = newBurnTax;
        _MarketingFee = newMarketingTax;
        _SellFee = _LiquidityFee.add(_MarketingFee).add(_BurnFee);
    } 
    
    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }
 
    function SetExclusions (address account, bool Fee, bool MaxTx, bool BlackList, bool WhiteList) public {
        require(msg.sender == safeManager);
        _isExcludedFromFees[account] = Fee;
        _isExcludedFromMaxTx[account] = MaxTx;
        _isBlacklisted[account] = BlackList;
        _isWhitelisted[account] = WhiteList;
    }
    
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The Market pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
 
    function _setAutomatedMarketMakerPair(address pair, bool value) private onlyOwner {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
 
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
    }

    function takeFee(address from, address to, uint256 amount) internal returns (uint256) {
        uint256 fees = 0; // no wallet to wallet tax
        uint256 burntaxamount = 0; // no wallet to wallet tax
        
        if(automatedMarketMakerPairs[from]) {                   // buy tax applied if buy
            if(_BuyFee != 0) {
                fees = amount.mul(_BuyFee).div(100);  // total fee amount
                burntaxamount=amount.mul(_BurnFee).div(100);    // burn amount aside
            }                   
        } else if(automatedMarketMakerPairs[to]) {          // sell tax applied if sell
            if(_SellFee != 0) {
                fees = amount.mul(_SellFee).div(100); // total fee amount
                burntaxamount=amount.mul(_BurnFee).div(100);    // burn amount aside
            }
        } else if(!automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to] && _Wallet2WalletFee != 0) {
            fees = amount.mul(_Wallet2WalletFee).div(100);
            burntaxamount=amount.mul(_BurnFee).div(100);    // burn amount aside      
        } 
        fees = fees.sub(burntaxamount);    // fee is total amount minus burn
        
        if (burntaxamount != 0) {super._burn(from, burntaxamount);}    // burn amount 
        if(fees > 0) {super._transfer(from, address(this), fees);}
        return amount.sub(fees).sub(burntaxamount);
    }
 
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "Blacklisted address"); //blacklist function
        
        // preparation of launch LP and token dispatch allowed even if trading not allowed
        if(!tradingEnabled) {require(_isWhitelisted[from], "Trading not allowed yet");}

        uint256 amountToSend = amount;
        // Max Wallet limitation
        if(to != owner() && to != address(this) && to != DeadWallet && to != uniswapV2Pair && to != MarketingWallet){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= maxWalletAmount, "wallet amount exceed maxWalletAmount");
        }
        
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        
        // Max sell limitation
        if(to == uniswapV2Pair && (!_isExcludedFromMaxTx[from]) && (!_isExcludedFromMaxTx[to])){  // sell limitation
            require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }
        
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
         // Can Swap on sell only
        if (canSwap && !swapping && !automatedMarketMakerPairs[from] && !_isWhitelisted[from] && !_isWhitelisted[to]) {
            swapping = true;
         
            uint256 initialBalance = address(this).balance;
            uint256 TotalFees = _SellFee.sub(_BurnFee);

            if(TotalFees != 0) {
                if(_MarketingFee != 0) {
                    uint256 swapTokens = contractTokenBalance.div(TotalFees).mul(_MarketingFee);
                    swapTokensForBNB(swapTokens);
                    uint256 marketingPortion = address(this).balance.sub(initialBalance);
                    MarketingWallet.transfer(marketingPortion);
                    //address(marketingWallet).call{value: marketingPortion}("");
                }

                if(_LiquidityFee != 0) {
                    uint256 liqTokens = contractTokenBalance.div(TotalFees).mul(_LiquidityFee);
                    swapAndLiquify(liqTokens);
                }
            }
            swapping = false;
        }

        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {amountToSend = takeFee(from, to, amount);}
        if(to == DeadWallet) {super._burn(from,amountToSend);}    // if destination address is Deadwallet, burn amount 
        else if(to != DeadWallet) {super._transfer(from, to, amountToSend);}
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
 
        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(half);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
 
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
 
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
 
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: bnbAmount}(address(this), tokenAmount, 0, 0, address(this), block.timestamp);
    }
 
    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
 
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function getLiquidityUnlockTime() public view returns (uint256 Days, uint256 Hours, uint256 Minutes, uint256 Seconds) {
        if (block.timestamp < _liquidityUnlockTime){
            Days = (_liquidityUnlockTime - block.timestamp) / 86400;
            Hours = (_liquidityUnlockTime - block.timestamp - Days*86400) / 3600;
            Minutes = (_liquidityUnlockTime - block.timestamp - Days*86400 - Hours*3600 ) / 60;
            Seconds = _liquidityUnlockTime - block.timestamp - Days*86400 - Hours*3600 - Minutes*60;

            return (Days, Hours, Minutes, Seconds);}
        return (0, 0, 0, 0);
    }

    function setUnlockTime(uint256 newUnlockTime) private {
        // require new unlock time to be longer than old one
        require(newUnlockTime > _liquidityUnlockTime);
        _liquidityUnlockTime = newUnlockTime;
    }

    function ExtendLockTime(uint256 newdays, uint256 newhours) public onlyOwner {
        uint256 lockTimeInSeconds = newdays*86400 + newhours*3600;
        setUnlockTime(lockTimeInSeconds + block.timestamp);
        emit ExtendLiquidityLock(lockTimeInSeconds);
    }

    function CreateLP (uint256 tokenAmount, uint256 bnbAmount, uint256 lockTimeInDays, uint256 lockTimeInHours) public onlyOwner {
        uint256 lockTimeInSeconds = lockTimeInDays*86400 + lockTimeInHours*3600;
        _liquidityUnlockTime = block.timestamp + lockTimeInSeconds;
        uint256 token = tokenAmount*10**decimal;
        uint256 bnb = bnbAmount*10**18;
        addLiquidity (token, bnb);
    }

    function ReleaseLP() public onlyOwner {
        require(block.timestamp >= _liquidityUnlockTime, "Not yet unlocked");
        IBEP20 liquidityToken = IBEP20(uniswapV2Pair);
        uint256 amount = liquidityToken.balanceOf(address(this));
            liquidityToken.transfer(msg.sender, amount);
    }
}