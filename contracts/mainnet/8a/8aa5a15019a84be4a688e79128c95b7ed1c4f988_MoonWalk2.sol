/**
 *Submitted for verification at BscScan.com on 2022-09-18
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

pragma solidity ^0.8.16;
 
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

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }
 
    function get(Map storage map, address key) public view returns (uint) {return map.values[key];}
 
    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {return -1;} return int(map.indexOf[key]);
    }
 
    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {return map.keys[index];}
    function size(Map storage map) public view returns (uint) {return map.keys.length;}
 
    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }
 
    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {return;}
 
        delete map.inserted[key];
        delete map.values[key];
 
        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];
 
        map.indexOf[lastKey] = index;
        delete map.indexOf[key];
        map.keys[index] = lastKey;
        map.keys.pop();
    }
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
    //uint8 private _decimals;
 
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
      //  _decimals = 9;
    }
 
    function name() public view virtual returns (string memory) {return _name;}
    function symbol() public view virtual returns (string memory) {return _symbol;}
    //function decimals() public view virtual returns (uint8) {return _decimals;}
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
 
    //function _setupDecimals(uint8 decimals_) internal virtual {
    //    _decimals = decimals_;
    //}
 
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

abstract contract SharedOwnable is Ownable {
    address private _creator;
    mapping(address => bool) private _sharedOwners;
    event SharedOwnershipAdded(address indexed sharedOwner);

    constructor() Ownable() {
        _creator = msg.sender;
        _setSharedOwner(msg.sender);
        renounceOwnership();
    }
    modifier onlySharedOwners() {require(_sharedOwners[msg.sender], "SharedOwnable: caller is not a shared owner"); _;}
    function getCreator() external view returns (address) {return _creator;}
    function isSharedOwner(address account) external view returns (bool) {return _sharedOwners[account];}
    function setSharedOwner(address account) internal onlySharedOwners {_setSharedOwner(account);}
    function _setSharedOwner(address account) private {_sharedOwners[account] = true; emit SharedOwnershipAdded(account);}
    function EraseSharedOwner(address account) internal onlySharedOwners {_eraseSharedOwner(account);}
    function _eraseSharedOwner(address account) private {_sharedOwners[account] = false;}
}

contract SafeToken is SharedOwnable {
    address payable safeManager;
    constructor() {safeManager = payable(msg.sender);}
    function setSafeManager(address payable _safeManager) public onlySharedOwners {safeManager = _safeManager;}
    function withdraw(address _token, uint256 _amount) external { require(msg.sender == safeManager); IBEP20(_token).transfer(safeManager, _amount);}
    function withdrawBNB(uint256 _amount) external {require(msg.sender == safeManager); safeManager.transfer(_amount);}
}
 
contract Main is BEP20, SharedOwnable, SafeToken {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address private immutable uniswapV2Pair;
    address [] List; 
    address payable private MarketingWallet;
    address payable private TeamWallet; 
    address payable private MultiUseWallet; 
    address payable private StakingWallet;
    address private DeadWallet;
    address private PancakeRouter;
    uint256 private nextTxSendDividends = 0;

    bool private inSwapAndLiquify;
    bool private swapAndLiquifyEnabled = true;
    bool public tradingEnabled = false;
    bool private AutoReward = true;
    bool private JeetsFee = true;
    bool private JeetsBurn = false;
    bool private JeetsStaking = true;
    bool private AutoDistribution = true;
    bool private DelayOption = false;

    MoonWalkersDividendTracker private dividendTracker;

    uint256 private SwapMin;
    uint256 private MaxWallet;
    uint256 private MaxSell;
    uint256 private MaxSwap;
    uint256 private MaxTokenToSwap;
    uint256 private maxSellTransactionAmount; // max sell 1% of supply
    uint256 private maxWalletAmount; // max wallet amount 2%
    uint256 private swapTokensAtAmount;
    uint256 private counter;
    uint8 private decimal;
    uint256 private InitialSupply;
    uint256 private DispatchSupply;
    uint256 private _liquidityUnlockTime = 0; 
    uint256 private MinTime = 0;
    
    uint256 private rewardBNBPortion = 0;
    uint256 private marketingBNBPortion = 0;
    uint256 private teamBNBPortion = 0;
    uint256 private multiuseBNBPortion = 0;
    uint256 private stakingPortion = 0;

    uint256 private _LiquidityFee = 3;
    uint256 private _MarketingFee = 3;
    uint256 private _TeamFee = 0;
    uint256 private _MultiUseFee = 0;
    uint256 private _StakingFee = 0;
    uint256 private _token1DividendRewardsFee = 8;
    uint256 private _BurnFee = 1;
    uint256 private _BuyFee = 5;
    uint256 private _SellFee = 0;
    uint256 private _Wallet2WalletFee = 0; // no wallet to wallet fee
    uint256 private MaxTaxes = 25;
    uint8 private VminDiv = 1;
    uint8 private VmaxDiv = 10;
    uint8 private MaxJeetsFee = 10;
    // use by default 300,000 gas to process auto-claiming dividends
    uint256 private gasForProcessing = 600000;
    uint256 private minTokenBalanceForDividends = 1000000;

    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedFromMaxTx;
    mapping (address => bool) private _isExcludedFromDividend;
    mapping(address => bool) private _isBlacklisted; //blacklist function
    mapping (address => bool) private _isWhitelisted;
    mapping (address => uint256) private LastTimeSell; 
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensIntoLiqudity, uint256 ethReceived);
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker(uint256 iterations,	uint256 claims, uint256 lastProcessedIndex,	bool indexed automatic, uint256 gas, address indexed processor);
    event rewardsGetBnb(uint256 amount);
    event marketingGetBnb(uint256 amount);
    event liquidityGetBnb(uint256 amount);
    event ExtendLiquidityLock(uint256 extendedLockTime);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(string memory name_, string memory symbol_, uint8 decimal_, address marketing_, address team_, address multiuse_, uint256 supply_, uint256 dispatch_, uint8 maxtaxes_) BEP20(name_, symbol_) {
        MarketingWallet = payable(marketing_);
        TeamWallet = payable(team_); 
        MultiUseWallet = payable(multiuse_); 
        StakingWallet = payable(marketing_);
        DeadWallet = 0x000000000000000000000000000000000000dEaD;
        decimal = decimal_;
        InitialSupply = supply_*10**decimal;
        DispatchSupply = dispatch_*10**decimal;
        MaxSwap = supply_ * 1 / 100;
        MaxSell = supply_ * 1 / 100;
        MaxWallet = supply_ * 3 / 100;
        SwapMin = supply_ * 1 / 1000;
        MaxTokenToSwap = MaxSwap*10**decimal;
        minTokenBalanceForDividends = supply_ * 1 / 10000;
        maxSellTransactionAmount = MaxSell * 10**decimal; // max sell 1% of supply
        maxWalletAmount = MaxWallet * 10**decimal; // max wallet amount 2%
        swapTokensAtAmount = SwapMin * 10**decimal;
        MaxTaxes = maxtaxes_;
 		_SellFee = _LiquidityFee.add(_MarketingFee).add(_TeamFee).add(_MultiUseFee).add(_StakingFee).add(_token1DividendRewardsFee).add(_BurnFee);//17%
     	
 	    if (block.chainid == 56) {
            PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        } else if (block.chainid == 97) {
            PancakeRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        } else revert();
        
        dividendTracker = new MoonWalkersDividendTracker("MoonWalk_Track", "MoonWalkT", minTokenBalanceForDividends, decimal);
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(PancakeRouter);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from receiving dividends
        _isExcludedFromDividend[address(_uniswapV2Router)] = true;
        dividendTracker.excludeFromDividends(address(_uniswapV2Router), true);
        _isExcludedFromDividend[address(this)] = true;
        dividendTracker.excludeFromDividends(address(address(this)), true);
        _isExcludedFromDividend[DeadWallet] = true;
        dividendTracker.excludeFromDividends(address(DeadWallet), true);
        _isExcludedFromDividend[MarketingWallet] = true;
        dividendTracker.excludeFromDividends(address(MarketingWallet), true);
        _isExcludedFromDividend[msg.sender] = true;
        dividendTracker.excludeFromDividends(msg.sender, true);
 
        // exclude from paying fees or having max transaction amount
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DeadWallet] = true;
        _isExcludedFromFees[MarketingWallet] = true;
        _isExcludedFromFees[TeamWallet] = true;
        _isExcludedFromFees[MultiUseWallet] = true;
        _isExcludedFromFees[StakingWallet] = true;
        _isExcludedFromFees[msg.sender] = true;
        
        // exclude from max tx
        _isExcludedFromMaxTx[msg.sender] = true;
        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxTx[MarketingWallet] = true;
        _isExcludedFromMaxTx[TeamWallet] = true;
        _isExcludedFromMaxTx[MultiUseWallet] = true;
        _isExcludedFromMaxTx[StakingWallet] = true;
        _isExcludedFromMaxTx[DeadWallet] = true;

        // WHitelist
        _isWhitelisted[address(this)] = true;
        _isWhitelisted[DeadWallet] = true;
        _isWhitelisted[MarketingWallet] = true;
        _isWhitelisted[TeamWallet] = true;
        _isWhitelisted[MultiUseWallet] = true;
        _isWhitelisted[StakingWallet] = true;
        _isWhitelisted[msg.sender] = true;
        
        if(DispatchSupply <= 0) {_mint(address(this), InitialSupply);} 
        else {
            _mint(msg.sender, DispatchSupply);
            _mint(address(this), InitialSupply - DispatchSupply);
        } 
    }
    receive() external payable {}
    //******************************************************************************************************
    // Public functions
    //******************************************************************************************************
    function decimals() public view returns (uint8) { return decimal;}
    function GetExclusions() public view returns(bool MaxTx, bool Fees, bool Dividend, bool Blacklist, bool Whitelist){return (_isExcludedFromMaxTx[msg.sender], _isExcludedFromFees[msg.sender], _isExcludedFromDividend[msg.sender], _isBlacklisted[msg.sender], _isWhitelisted[msg.sender]);}
    function GetFees() public view returns(uint Buy, uint Sell, uint Wallet2Wallet, uint Liquidity, uint Marketing, uint Team, uint MultiUse, uint staking, uint Dividend, uint Burn){return (_BuyFee, _SellFee, _Wallet2WalletFee, _LiquidityFee, _MarketingFee, _TeamFee, _MultiUseFee, _StakingFee, _token1DividendRewardsFee, _BurnFee);}
    function GetLimits() public view returns(uint256 SellMax, uint256 WalletMax, uint256 TaxMax, uint256 Gas, uint256 MinSwap, uint256 SwapMax, uint256 mintokenfordividend, bool SwapLiq, bool ENtrading, bool RewardAuto, bool autodistribution){return (MaxSell, MaxWallet, MaxTaxes, gasForProcessing, SwapMin, MaxSwap, minTokenBalanceForDividends, swapAndLiquifyEnabled, tradingEnabled, AutoReward, AutoDistribution);}
    function GetDelay() public view returns (bool delayoption, uint256 mintime) {return (DelayOption, MinTime);}
    function GetContractAddresses() public view returns(address marketing, address team, address multiuse, address staking, address reward, address Dead, address LP){return (address(MarketingWallet), address(TeamWallet), address(MultiUseWallet), address(StakingWallet), address(dividendTracker), address(DeadWallet), address(uniswapV2Pair));}
    function getAccountDividendsInfo(address account) external view returns (address wallet, int256 indexA, int256 iteration, uint256 pendingdiv, uint256 totaldiv, uint256 lastclaimtime, uint256 nextclaimtime, uint256 secondsuntilautoclaim) {return dividendTracker.getAccount(account);}
    function GetDividendInfo() external view returns(uint256 RewardTokenHolders, uint256 RewardTotalDivDistributed, uint256 claimwait) {return(dividendTracker.getNumberOfTokenHolders(), dividendTracker.totalDividendsDistributed(), dividendTracker.claimWait());}
    function withdrawableDividendOf(address account) public view returns(uint256) {return dividendTracker.withdrawableDividendOf(account);}
    function GetJeetsTaxInfo() external view returns (bool jeetsfee, bool jeetsburn, bool jeetsstaking, uint vmaxdiv, uint vmindiv, uint maxjeetsfee) {return(JeetsFee, JeetsBurn, JeetsStaking, VmaxDiv, VminDiv, MaxJeetsFee);}
    function GetContractBalance() external view returns (uint256 stakingportion, uint256 marketingbnb, uint256 teambnb , uint256 multiusebnb) {return(stakingPortion, marketingBNBPortion, teamBNBPortion , multiuseBNBPortion);}


    function GetSupplyInfo() public view returns (uint256 initialSupply, uint256 circulatingSupply, uint256 burntTokens) {
        uint256 supply = totalSupply ();
        uint256 tokensBurnt = InitialSupply - supply;
        return (InitialSupply, supply, tokensBurnt);
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

    function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {dividendTracker.processAccount(payable(msg.sender), false);}
    //******************************************************************************************************
    // Write OnlyOwners functions
    //******************************************************************************************************
    function updateUniswapV2Router(address newAddress) public onlySharedOwners {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function SetExclusions (address account, bool Fee, bool MaxTx, bool Dividend, bool BlackList, bool WhiteList) public onlySharedOwners {
        _isExcludedFromFees[account] = Fee;
        _isExcludedFromMaxTx[account] = MaxTx;
        _isExcludedFromDividend[account] = Dividend;
        dividendTracker.excludeFromDividends(address(account), Dividend);
        _isBlacklisted[account] = BlackList;
        _isWhitelisted[account] = WhiteList;
    }

    function SetTaxes(uint256 newBuyTax, uint256 wallet2walletfee, uint256 newLiquidityTax, uint256 newBurnTax, uint256 newMarketingTax, uint256 newTeamTax, uint256 newMultiUseTax, uint256 newStakingTax, uint256 newReward1Tax) external onlySharedOwners {
        require(newBuyTax <= MaxTaxes && newBuyTax >= newBurnTax, "Total Tax can't exceed MaxTaxes. or be lower than burn tax");
        uint256 TransferTax = newMarketingTax.add(newTeamTax).add(newMultiUseTax).add(newStakingTax);
        require(TransferTax.add(newReward1Tax).add(newLiquidityTax).add(newBurnTax) <= MaxTaxes, "Total Tax can't exceed MaxTaxes.");
        require(newMarketingTax >= 0 && newTeamTax >= 0 && newMultiUseTax >= 0 && newBuyTax >= 0 && newReward1Tax >= 0 && newLiquidityTax >= 0 && newBurnTax >= 0,"No tax can be negative");
        if(wallet2walletfee != 0){require(wallet2walletfee >= _BurnFee && wallet2walletfee <= MaxTaxes, "Wallet 2 Wallet Tax must be updated to between burn tax and 25 percent");}
                
        _BuyFee = newBuyTax;
        _Wallet2WalletFee = wallet2walletfee;
        _BurnFee = newBurnTax;
        _LiquidityFee = newLiquidityTax;
        _MarketingFee = newMarketingTax;
        _TeamFee = newTeamTax;
        _MultiUseFee = newMultiUseTax;
        _StakingFee = newStakingTax;
        _token1DividendRewardsFee = newReward1Tax;
        _SellFee = _LiquidityFee.add(_MarketingFee).add(_TeamFee).add(_MultiUseFee).add(_StakingFee).add(_token1DividendRewardsFee).add(_BurnFee);
    } 

    function SetDelay (bool delayoption, uint256 mintime) external onlySharedOwners {
        require(mintime <= 28800, "MinTime Can't be more than a Day" );
        MinTime = mintime;
        DelayOption = delayoption;
    }

    function SetLimits(uint256 _maxWallet, uint256 _maxSell, uint256 _minswap, uint256 _swapmax, uint256 newMinimumBalance, uint256 NewGas, uint256 claimWait, uint256 MaxTax, bool _swapAndLiquifyEnabled, bool autoreward, bool autodistribution) public onlySharedOwners {
        uint256 supply = totalSupply ();
        require(_maxWallet * 10**decimal >= supply / 100 && _maxWallet * 10**decimal <= supply, "MawWallet must be between totalsupply and 1% of totalsupply");
        require(_maxSell * 10**decimal >= supply / 1000 && _maxSell * 10**decimal <= supply, "MawSell must be between totalsupply and 0.1% of totalsupply" );
        require(_minswap * 10**decimal >= supply / 10000 && _minswap <= _swapmax / 2, "MinSwap must be between maxswap/2 and 0.01% of totalsupply" );
        require(newMinimumBalance * 10**decimal <= supply / 100, "newMinimumBalance must be lower than 1% of totalsupply" );
        require(NewGas >= 300000, "Gas can't be lower than 300000");
        require(claimWait >= 3600 && claimWait <= 86400, "claimWait must be updated to between 1 and 24 hours");
        require(MaxTax >= 1 && MaxTax <= 25, "Max Tax must be updated to between 1 and 25 percent");
        require(_swapmax >= _minswap.mul(2) && _swapmax * 10**decimal <= supply, "MaxSwap must be between totalsupply and SwapMin x 2" );

        MaxSwap = _swapmax;
        MaxTokenToSwap = MaxSwap * 10**decimal;
        MaxSell = _maxSell;
        maxSellTransactionAmount = MaxSell * 10**decimal;
        MaxWallet = _maxWallet;
        maxWalletAmount = MaxWallet * 10**decimal;  
        SwapMin = _minswap;
        swapTokensAtAmount = SwapMin * 10**decimal;
        minTokenBalanceForDividends = newMinimumBalance;
        dividendTracker.updateMinimumTokenBalanceForDividends(newMinimumBalance);
        MaxTaxes = MaxTax;
        AutoReward = autoreward;
        AutoDistribution = autodistribution;
        dividendTracker.updateClaimWait(claimWait);

        gasForProcessing = NewGas;
        emit GasForProcessingUpdated(NewGas, gasForProcessing);

        swapAndLiquifyEnabled = _swapAndLiquifyEnabled;
        emit SwapAndLiquifyEnabledUpdated(_swapAndLiquifyEnabled);
    }

    function setProjectWallet (address payable _newMarketingWallet, address payable _newTeamWallet, address payable _newMultiUseWallet, address payable _newStakingWallet) external onlySharedOwners {
        if (_newMarketingWallet != MarketingWallet) {
            _isExcludedFromFees[MarketingWallet] = false;
            _isExcludedFromMaxTx[MarketingWallet] = false;
            _isWhitelisted[MarketingWallet] = false;
            dividendTracker.excludeFromDividends(MarketingWallet, false);
            
            _isExcludedFromFees[_newMarketingWallet] = true;
            _isExcludedFromMaxTx[_newMarketingWallet] = true;
            _isWhitelisted[_newMarketingWallet] = true;
            dividendTracker.excludeFromDividends(_newMarketingWallet, true);
  	        MarketingWallet = _newMarketingWallet;
        }
        if (_newTeamWallet != TeamWallet) {
            _isExcludedFromFees[TeamWallet] = false;
            _isExcludedFromMaxTx[TeamWallet] = false;
            _isWhitelisted[TeamWallet] = false;
                       
            _isExcludedFromFees[_newTeamWallet] = true;
            _isExcludedFromMaxTx[_newTeamWallet] = true;
            _isWhitelisted[_newTeamWallet] = true;
            TeamWallet = _newTeamWallet;
        }
        if (_newMultiUseWallet != MultiUseWallet) {
            _isExcludedFromFees[MultiUseWallet] = false;
            _isExcludedFromMaxTx[MultiUseWallet] = false;
            _isWhitelisted[MultiUseWallet] = false;
                       
            _isExcludedFromFees[_newMultiUseWallet] = true;
            _isExcludedFromMaxTx[_newMultiUseWallet] = true;
            _isWhitelisted[_newMultiUseWallet] = true;
            MultiUseWallet = _newMultiUseWallet;
        }
        if (_newStakingWallet != StakingWallet) {
            _isExcludedFromFees[StakingWallet] = false;
            _isExcludedFromMaxTx[StakingWallet] = false;
            _isWhitelisted[StakingWallet] = false;
                       
            _isExcludedFromFees[_newStakingWallet] = true;
            _isExcludedFromMaxTx[_newStakingWallet] = true;
            _isWhitelisted[_newStakingWallet] = true;
            StakingWallet = _newStakingWallet;
        }
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlySharedOwners {
        require(pair != uniswapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function AddSharedOwner(address account, bool DividendExcluded) public onlySharedOwners {
        setSharedOwner(account);
        if(DividendExcluded) {
            _isExcludedFromDividend[address(account)] = true;
            dividendTracker.excludeFromDividends(address(account), true);
        }
        _isExcludedFromFees[address(account)] = true;
        _isExcludedFromMaxTx[address(account)] = true;
        _isWhitelisted[address(account)] = true;
    }

    function RemoveharedOwner(address account) public onlySharedOwners {
        EraseSharedOwner(account);
        _isExcludedFromDividend[address(account)] = false;
        dividendTracker.excludeFromDividends(address(account), false);
        _isExcludedFromFees[address(account)] = false;
        _isExcludedFromMaxTx[address(account)] = false;
        _isWhitelisted[address(account)] = false;
    }
      
    function ExtendLockTime(uint256 newdays, uint256 newhours) public onlySharedOwners {
        uint256 lockTimeInSeconds = newdays*86400 + newhours*3600;
        if (_liquidityUnlockTime < block.timestamp) _liquidityUnlockTime = block.timestamp;
	setUnlockTime(lockTimeInSeconds + _liquidityUnlockTime);
        emit ExtendLiquidityLock(lockTimeInSeconds);
    }

    function CreateLP (uint256 tokenAmount, uint256 bnbAmountnum, uint256 bnbAmountdiv, uint256 Blocks, uint256 lockTimeInDays, uint256 lockTimeInHours) public onlySharedOwners {
        require(Blocks <= 40, "Not more than 2mn");
        uint256 lockTimeInSeconds = lockTimeInDays*86400 + lockTimeInHours*3600;
        _liquidityUnlockTime = block.timestamp + lockTimeInSeconds;
        uint256 token = tokenAmount*10**decimal;
        uint256 bnb = (bnbAmountnum*10**18)/bnbAmountdiv;
        addLiquidity (token, bnb);
        tradingEnabled = true;
        counter = block.number + Blocks;
    }

    function ReleaseLP() public onlySharedOwners {
        require(block.timestamp >= _liquidityUnlockTime, "Not yet unlocked");
        IBEP20 liquidityToken = IBEP20(uniswapV2Pair);
        uint256 amount = liquidityToken.balanceOf(address(this));
            liquidityToken.transfer(msg.sender, amount);
    }

    function GetList() external view onlySharedOwners returns (uint number, address [] memory) {
        number = List.length;
        return (number, List);
    }

    function SetJeetsTax(bool jeetsfee, bool jeetsburn, bool jeetsstaking, uint8 vmaxdiv, uint8 vmindiv, uint8 maxjeetsfee)  external onlySharedOwners {
        require (vmaxdiv >= 10 && vmaxdiv <= 40, "cannot set Vmax outside 10%/40% ratio");
        require (vmindiv >= 1 && vmindiv <= 10, "cannot set Vmin outside 1%/10% ratio");
        require (maxjeetsfee >= 1 && maxjeetsfee <= 20, "max jeets fee must be betwwen 1% and 20%");
        JeetsFee = jeetsfee;
        JeetsBurn = jeetsburn;
        JeetsStaking = jeetsstaking;
        VmaxDiv = vmaxdiv;
        VminDiv = vmindiv;
        MaxJeetsFee = maxjeetsfee;
    }

    function ManualDistribution() external onlySharedOwners {
        if(stakingPortion != 0) {
            super._transfer(address(this), StakingWallet, stakingPortion);
            stakingPortion = 0;
        }
        if(marketingBNBPortion != 0) {
            MarketingWallet.transfer(marketingBNBPortion);
            marketingBNBPortion = 0;
        }
        if(teamBNBPortion != 0) {
            TeamWallet.transfer(teamBNBPortion);
            teamBNBPortion = 0;
        }
        if(multiuseBNBPortion != 0) {
            MultiUseWallet.transfer(multiuseBNBPortion);
            multiuseBNBPortion = 0;
        }
    }

    function RAZStakingportion() public onlySharedOwners {stakingPortion = 0;}
    //******************************************************************************************************
    // Internal functions
    //******************************************************************************************************
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        if(value) {dividendTracker.excludeFromDividends(pair, true);}
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function takeFee(address from, address to, uint256 amount) internal returns (uint256) {
        uint256 fees = 0; // no wallet to wallet tax
        uint256 burntaxamount = 0; // no wallet to wallet tax
        uint256 extraTax = 0;
        
        if(automatedMarketMakerPairs[from]) {                   // buy tax applied if buy
            if(_BuyFee != 0) {
                fees = amount.mul(_BuyFee).div(100);  // total fee amount
                burntaxamount=amount.mul(_BurnFee).div(100);    // burn amount aside
            }                   
        } else if(automatedMarketMakerPairs[to]) {          // sell tax applied if sell
            if (JeetsFee && !_isWhitelisted[from]){ // Jeets extra Fee against massive dumpers
                extraTax = JeetsSellTax(amount);
                if (extraTax > 0) {
                    if (JeetsBurn) {burntaxamount += extraTax;} 
		            else if (JeetsStaking) {stakingPortion += extraTax;}
                    fees += extraTax;
                }
            }
            if(_SellFee != 0) {
                fees += amount.mul(_SellFee).div(100); // total fee amount
                burntaxamount+=amount.mul(_BurnFee).div(100);    // burn amount aside
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

    function _transfer(address from, address to, uint256 amount)  internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {return;}
        if(to != address(this) && to != DeadWallet) require(!_isBlacklisted[from] && !_isBlacklisted[to] , "Blacklisted address"); //blacklist function
 
       // preparation of launch LP and token dispatch allowed even if trading not allowed
        if(!tradingEnabled) {require(_isWhitelisted[from], "Trading not allowed yet");}

        if(tradingEnabled && block.number < counter && !_isWhitelisted[to] && automatedMarketMakerPairs[from]) {
            _isBlacklisted[to] = true;
            List.push(to);
            _isExcludedFromDividend[address(to)] = true;
            dividendTracker.excludeFromDividends(address(to), true);
        }

        if(!_isWhitelisted[to] && automatedMarketMakerPairs[from]){
            if(to != address(this) && to != DeadWallet){
                uint256 heldTokens = balanceOf(to);
                require((heldTokens + amount) <= maxWalletAmount, "wallet amount exceed maxWalletAmount");
            }
        }

        if(automatedMarketMakerPairs[to] && (!_isExcludedFromMaxTx[from]) && (!_isExcludedFromMaxTx[to])){require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");}

        if (DelayOption && !_isWhitelisted[from] && automatedMarketMakerPairs[to]) {
            require( LastTimeSell[from] + MinTime <= block.number, "Trying to sell too often!");
            LastTimeSell[from] = block.number;
        }

    	uint256 contractTokenBalance = balanceOf(address(this));
        if (stakingPortion != 0 && stakingPortion < contractTokenBalance) {contractTokenBalance = balanceOf(address(this)) - stakingPortion;}
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        uint256 TotalFees = _SellFee.sub(_BurnFee);
        if(contractTokenBalance >= MaxTokenToSwap){contractTokenBalance = MaxTokenToSwap;}       
        if(swapAndLiquifyEnabled && canSwap && !inSwapAndLiquify && !automatedMarketMakerPairs[from] && !_isWhitelisted[from] && !_isWhitelisted[to] && TotalFees != 0) {swapAndLiquify(contractTokenBalance);}
        
        uint256 amountToSend = amount;        
        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {amountToSend = takeFee(from, to, amount);}
        if(to == DeadWallet) {super._burn(from,amountToSend);}    // if destination address is Deadwallet, burn amount 
        else if(to != DeadWallet) {super._transfer(from, to, amountToSend);}

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!inSwapAndLiquify && AutoReward) {
	    	uint256 gas = gasForProcessing;
	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);} catch {}
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 TotalFees = _SellFee.sub(_BurnFee);
        uint256 initialBalance = address(this).balance;
        
        uint256 tokensForLP = contractTokenBalance * _LiquidityFee / 2 / TotalFees;
        stakingPortion += contractTokenBalance * _StakingFee / TotalFees;

        uint256 tokensForSwap = contractTokenBalance.sub(tokensForLP).sub(stakingPortion);
        swapTokensForBnb(tokensForSwap, address(this));
        uint256 BNBBalance = address(this).balance - initialBalance;
        uint256 totalBNBFee = TotalFees - (_LiquidityFee / 2) - _StakingFee;
      
        uint256 liquidityBNBPortion = BNBBalance * _LiquidityFee / 2 / totalBNBFee;  
        marketingBNBPortion += BNBBalance * _MarketingFee / totalBNBFee;
        teamBNBPortion += BNBBalance * _TeamFee / totalBNBFee;
        multiuseBNBPortion += BNBBalance * _MultiUseFee / totalBNBFee;
        rewardBNBPortion = BNBBalance * _token1DividendRewardsFee / totalBNBFee;
       
        if(liquidityBNBPortion != 0) {addLiquidity(tokensForLP, liquidityBNBPortion);}
        if(rewardBNBPortion != 0) {swapAndLiquifyDividends (rewardBNBPortion);}
        if (AutoDistribution){    
            if(stakingPortion != 0) {
                super._transfer(address(this), StakingWallet, stakingPortion);
                stakingPortion = 0;
            }
            if(marketingBNBPortion != 0) {
                MarketingWallet.transfer(marketingBNBPortion);
                marketingBNBPortion = 0;
            }
            if(teamBNBPortion != 0) {
                TeamWallet.transfer(teamBNBPortion);
                teamBNBPortion = 0;
            }
            if(multiuseBNBPortion != 0) {
                MultiUseWallet.transfer(multiuseBNBPortion);
                multiuseBNBPortion = 0;
            }
        }
        uint256 totMarkRewardsLiquidity = liquidityBNBPortion.add(rewardBNBPortion).add(marketingBNBPortion).add(teamBNBPortion).add(multiuseBNBPortion);
        emit SwapAndLiquify(tokensForLP, totMarkRewardsLiquidity);
    }
    
    function swapAndLiquifyDividends(uint256 amount) private lockTheSwap {
        uint256 dividends = amount;
        (bool success,) = address(dividendTracker).call{value: dividends}("");
        if(success) {emit SendDividends(nextTxSendDividends, dividends);}
    }

    function swapTokensForBnb(uint256 tokenAmount, address _to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        if(allowance(address(this), address(uniswapV2Router)) < tokenAmount) {_approve(address(this), address(uniswapV2Router), ~uint256(0));}
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, _to, block.timestamp);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, address(this), block.timestamp);
    }

    function setUnlockTime(uint256 newUnlockTime) private {
        // require new unlock time to be longer than old one
        require(newUnlockTime > _liquidityUnlockTime);
        _liquidityUnlockTime = newUnlockTime;
    }

    function JeetsSellTax (uint256 amount) internal view returns (uint256) {
        uint256 value = balanceOf(uniswapV2Pair);
        uint256 vMin = value * VminDiv / 100;
        uint256 vMax = value * VmaxDiv / 100;
        if (amount <= vMin) 
            return amount = 0;
        
        if (amount > vMax) 
            return amount * MaxJeetsFee / 100;

        return (((amount-vMin) * MaxJeetsFee * amount) / (vMax-vMin)) / 100;
    }
}

contract MoonWalk2 is Main {

    constructor() Main (
        "Moon Walkers 2",       // Name
        "MoonWalk",        // Symbol
        9,                  // Decimal
        0x4aAB4ED440A8406eC15C140e3627dfc7701B9D0F,     // Marketing address
        0x4aAB4ED440A8406eC15C140e3627dfc7701B9D0F,     // Team address
        0x4aAB4ED440A8406eC15C140e3627dfc7701B9D0F,     // Multi Use address
        8_000_000_000,      // Initial Supply
        7_500_000_000,       // Dispa&tch Supply
        25     // Max Tax
        ) {} 
}

interface DividendPayingTokenInterface {
    function dividendOf(address _owner) external view returns(uint256);
    function distributeDividends() external payable;
    function withdrawDividend() external;
    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}
 
interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner) external view returns(uint256);
    function withdrawnDividendOf(address _owner) external view returns(uint256);
    function accumulativeDividendOf(address _owner) external view returns(uint256);
}

contract DividendPayingToken is BEP20, SharedOwnable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;
    uint256 constant internal magnitude = 2**128;
    uint256 internal magnifiedDividendPerShare;
 
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 public totalDividendsDistributed;
 
    constructor(string memory _name, string memory _symbol) BEP20(_name, _symbol) {}
    receive() external payable {distributeDividends();}
 
    function distributeDividends() public override payable {
    require(totalSupply() > 0);

    if (msg.value > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare.add(
        (msg.value).mul(magnitude) / totalSupply()
      );
      emit DividendsDistributed(msg.sender, msg.value);
      totalDividendsDistributed = totalDividendsDistributed.add(msg.value);
    }
  }
 
    function withdrawDividend() public virtual override {_withdrawDividendOfUser(payable(msg.sender));}
  
    function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend);
            (bool success,) = user.call{value: _withdrawableDividend, gas: 3000}("");
            if(!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                return 0;
            }
            return _withdrawableDividend;
        }
        return 0;
    }
 
    function dividendOf(address _owner) public view override returns(uint256) {return withdrawableDividendOf(_owner);}
    function withdrawableDividendOf(address _owner) public view override returns(uint256) {return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);}
    function withdrawnDividendOf(address _owner) public view override returns(uint256) {return withdrawnDividends[_owner];}
    function accumulativeDividendOf(address _owner) public view override returns(uint256) {return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe().add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;}
 
    function _transfer(address from, address to, uint256 value) internal virtual override {
        require(false);
        int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
    }
 
    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);
        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account].sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    }
 
    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);
        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account].add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    }
 
    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);
        if(newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if(newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}

contract MoonWalkersDividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;
    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint8 private decimal;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account, bool indexed exclude);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor(string memory divname_, string memory divsymbol_, uint256 minfordiv_, uint8 decimal_) DividendPayingToken(divname_, divsymbol_) {
        decimal = decimal_;
        claimWait = 3600;
        minimumTokenBalanceForDividends = minfordiv_ * 10**decimal; //must hold 10000+ tokens
    }

    function decimals() public view returns (uint8) { return decimal; }
    function _transfer(address, address, uint256) internal pure override {require(false, "Dividend_Tracker: No transfers allowed");}
    function updateMinimumTokenBalanceForDividends(uint256 _newMinimumBalance) public onlySharedOwners {minimumTokenBalanceForDividends = _newMinimumBalance * 10**decimal;}
    function withdrawDividend() public pure override {require(false, "Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main contract.");}

     function excludeFromDividends(address account, bool excluded) public onlySharedOwners {
    	excludedFromDividends[account] = excluded;
    	if (excluded){
            _setBalance(account, 0);
    	    tokenHoldersMap.remove(account);}
        else if (!excluded){
            _setBalance(account, balanceOf(account));
    	    tokenHoldersMap.set(account, balanceOf(account));
        }
    	emit ExcludeFromDividends(account, excluded); 
    }

    function updateClaimWait(uint256 newClaimWait) external onlySharedOwners {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");	
        //require(newClaimWait != claimWait, "Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {return tokenHoldersMap.keys.length;}

    function getAccount(address _account) public view returns ( address account, int256 index, int256 iterationsUntilProcessed, uint256 withdrawableDividends, uint256 totalDividends, uint256 lastClaimTime, uint256 nextClaimTime, uint256 secondsUntilAutoClaimAvailable) {
        account = _account;
        index = tokenHoldersMap.getIndexOfKey(account);
        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ? tokenHoldersMap.keys.length.sub(lastProcessedIndex) : 0;
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }
        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
    }

    function getAccountAtIndex(uint256 index) public view returns ( address, int256, int256, uint256, uint256, uint256, uint256, uint256) {
    	if(index >= tokenHoldersMap.size()) {return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);}
        address account = tokenHoldersMap.getKeyAtIndex(index);
        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {return false;}
    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlySharedOwners {
    	if(excludedFromDividends[account]) {return;}

    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	} else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}
    	processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
    	if(numberOfTokenHolders == 0) {return (0, 0, lastProcessedIndex);}

    	uint256 _lastProcessedIndex = lastProcessedIndex;
    	uint256 gasUsed = 0;
    	uint256 gasLeft = gasleft();
    	uint256 iterations = 0;
    	uint256 claims = 0;

    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;
    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {_lastProcessedIndex = 0;}
    		address account = tokenHoldersMap.keys[_lastProcessedIndex];
    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(processAccount(payable(account), true)) {claims++;}
    		}
    		iterations++;
    		uint256 newGasLeft = gasleft();
    		if(gasLeft > newGasLeft) {gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));}
    		gasLeft = newGasLeft;
    	}
    	lastProcessedIndex = _lastProcessedIndex;
    	return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlySharedOwners returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
    		return true;
    	}
    	return false;
    }
}