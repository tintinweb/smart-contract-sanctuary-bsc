/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

pragma solidity 0.8.10;


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
    function decimals() external pure returns (uint256);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     * `onlyOwner` - Bello Yaa!
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Token is Ownable, IERC20 { 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    mapping (address => bool) public isGrantedConfigAccess;
    mapping (address => bool) public isExcludedFromFee; 
    mapping (address => bool) public isBlacklisted;
    mapping (address => bool) public isLimitExempt;
    mapping (address => bool) public isExcluded; 
    mapping (address => bool) public isPair;

    bool public isTradingActive = false; 

    address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 
    address payable public Wallet_Marketing = payable(0x000000000000000000000000000000000000dEaD);      
    address payable public Wallet_LP = payable(0x000000000000000000000000000000000000dEaD);         

    uint256 public FeeBuy = 3;  
    uint256 public FeeSell = 5;  
    uint256 public FeeP2P = 0;  

    uint256 public ReflectBuy = 1;
    uint256 public ReflectSell = 1;  
    uint256 public ReflectP2P = 0;
    
    uint256 public maxWallet; 
    uint256 public maxTransaction;  

    uint256 public minSwapLiquidity; 
    uint256 public maxSwapLiquidity; 

    uint256 public immutable boughtEarlyIndicator; 
    uint256 public immutable boughtEarlySellCooldown; 
    uint256 public boughtEarlyThreshold;

    mapping(address => bool) public boughtEarly;
    mapping(address => uint256) public boughtEarlyAt;

    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true; 

    uint256 public swapTrigger = 10; 
    uint256 public txCount = 1;

    uint256 internal tReflect; 
    uint256 internal rReflect; 

    uint256 internal tFees; 
    uint256 internal rFees; 

    uint256 internal rAmount; 
    uint256 internal tTransferAmount; 
    uint256 internal rTransferAmount; 

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private constant _name = "TATE COBRA"; 
    string private constant _symbol = "COBRA";  

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _decimals = 18;
    uint256 private _tTotal = 2000000000000 ether;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 private percentLP = 70;
    address[] private _excluded; 
    
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event LimitExempted(
        address account, 
        bool isExempt
    );

    event AccessGranted(
        address account, 
        bool isGrantedAccess
    );

    event PairConfigured(
        address account, 
        bool isConfigured
    );

    event ExcludedFromFee(
        address account, 
        bool isExcludedFromFee
    );

    event Blacklisted(
        address account, 
        bool isBlacklisted);

    event ExcludedFromRewards(address account);
    event IncludedForRewards(address account);

    event FeesUpdated(
        uint256 FeeBuy, 
        uint256 FeeSell, 
        uint256 FeeP2P, 
        uint256 ReflectBuy, 
        uint256 ReflectSell, 
        uint256 ReflectP2P
    );

    event LimitsUpdated(
        uint256 newWalletLimit, 
        uint256 newTxLimit
    );

    event MarketingWalletUpdated(
        address indexed oldWallet, 
        address indexed newWallet
    );

    event LPWalletUpdated(
        address indexed oldWallet, 
        address indexed newWallet
    );

    event BoughtEarly(address indexed account);
    event SwapAndLiquifyEnabledUpdated(bool isEnabled);
    event TriggerLimitsUpdated(uint256 newTriggerMinimum, uint256 newTriggerMax);    
    event TradingActive(bool isOpen);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {

        _rOwned[owner()] = _rTotal;
        IUniswapV2Router02 _uniswapV2Router = 
        IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
      
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[Wallet_Burn] = true;

        isLimitExempt[owner()] = true;
        isLimitExempt[address(this)] = true;
        isLimitExempt[Wallet_Burn] = true;
        isLimitExempt[uniswapV2Pair] = true;

        isPair[uniswapV2Pair] = true;
        isGrantedConfigAccess[owner()] = true;

        isExcluded[Wallet_Burn] = true;
        isExcluded[uniswapV2Pair] = true;
        isExcluded[address(this)] = true;

        _excluded.push(Wallet_Burn);
        _excluded.push(uniswapV2Pair);
        _excluded.push(address(this));

        boughtEarlyIndicator = 10 minutes;
        boughtEarlySellCooldown = 1 minutes;

        minSwapLiquidity = _tTotal * 5 / 10000; 
        maxSwapLiquidity = _tTotal / 100; 

        maxWallet = _tTotal * 20 / 1000; 
        maxTransaction = _tTotal * 5 / 1000;  

        emit Transfer(address(0), owner(), _tTotal);
    }

    receive() external payable {}

    function setlimitExempt(
        address account, 
        bool isExempt) 
        external 
        onlyOwner 
        returns (bool) 
    {    

        isLimitExempt[account] = isExempt;
        emit LimitExempted(account, isExempt);
        return true;
    }

    function setPair(
        address account, 
        bool isPairs) 
        external 
        onlyOwner 
        returns (bool) 
    {

        isPair[account] = isPairs;
        emit PairConfigured(account, isPairs);
        return true;
    }

    function setExcludedFromFee(
        address account, 
        bool isExcludedFromFees) 
        external 
        onlyOwner 
        returns (bool) 
    {

        isExcludedFromFee[account] = isExcludedFromFees;
        emit ExcludedFromFee(account, isExcludedFromFees);
        return true;
    }

    function setBlacklist(
        address account, 
        bool isBlacklistedd) 
        external 
        onlyOwner 
        returns (bool) 
    {

        isBlacklisted[account] = isBlacklistedd;
        emit Blacklisted(account, isBlacklistedd);
        return true;
    }

    function setExcludedFromRewards(address account) 
        external 
        onlyOwner 
        returns (bool) 
    {

        require(
            !isExcluded[account], 
            "Account is already excluded"
        );

        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }

        isExcluded[account] = true;
        _excluded.push(account);
        emit ExcludedFromRewards(account);
        return true;
    }

    function setIncludedForRewards(address account) 
        external 
        onlyOwner 
        returns (bool) 
    {

        require(
            isExcluded[account], 
            "Account is already included"
        );
        
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
        emit IncludedForRewards(account);
        return true;
    }

    function setFees(
        uint256 newFeeBuy,
        uint256 newFeeSell,
        uint256 newFeeP2P,
        uint256 newReflectBuy,
        uint256 newReflectSell,
        uint256 newReflectP2P) 
        external 
        onlyOwner 
        returns (bool) 
    {

        require(
            newFeeBuy <= 20, 
            "Buy fee too high"
        );
        require(
            newFeeSell <= 20, 
            "Sell fee too high"
        );
        require(
            newFeeP2P <= 20, 
            "P2P fee too high"
        );

        require(
            newReflectBuy <= newFeeBuy, 
            "Fee_Buy must include Reflect_Buy"
        );
        require(
            newReflectSell <= newFeeSell, 
            "Fee_Sell must include Reflect_Sell"
        );
        require(
            newReflectP2P <= newFeeP2P, 
            "Fee_P2P must include Reflect_P2P"
        );

        FeeBuy      = newFeeBuy;
        FeeSell     = newFeeSell;
        FeeP2P      = newFeeP2P;
        ReflectBuy  = newReflectBuy;
        ReflectSell = newReflectSell;
        ReflectP2P  = newReflectP2P;

        emit FeesUpdated(
            FeeBuy, 
            FeeSell, 
            FeeP2P, 
            ReflectBuy, 
            ReflectSell, 
            ReflectP2P
        );

        return true;
    }

    function setTradingActive() 
        external 
        onlyOwner 
        returns (bool) 
    {

        isTradingActive = true;
        boughtEarlyThreshold = block.timestamp + boughtEarlyIndicator;
        emit TradingActive(isTradingActive);
        return true;
    }

    function setFeeDistribution(uint256 newPercentLP) 
        external 
        onlyOwner 
        returns (bool) 
    {

        percentLP = newPercentLP;
        return true;
    }

    function setMarketingWallet(address payable newWallet) 
        external 
        onlyOwner 
        returns (bool) 
    {

        require(
            newWallet != address(0), 
            "new wallet is the zero address"
        );

        emit MarketingWalletUpdated(Wallet_Marketing, newWallet);
        Wallet_Marketing = newWallet;
        return true;
    }

    function setLPWallet(address payable newWallet) 
        external 
        onlyOwner 
        returns (bool) 
    {

        require(
            newWallet != address(0), 
            "new wallet is the zero address"
        );
        
        emit LPWalletUpdated(Wallet_LP, newWallet);
        Wallet_LP = newWallet;
        return true;
    }

    function setSwapAndLiquifyEnabled(bool isEnabled) 
        external 
        onlyOwner 
        returns (bool) 
    {

        swapAndLiquifyEnabled = isEnabled;
        emit SwapAndLiquifyEnabledUpdated(isEnabled);
        return true;
    }

    function setLimitsForWallets(
        uint256 newMaxTransaction,
        uint256 newMaxWallet) 
        external 
        onlyOwner 
        returns (bool) 
    {

        require(
            newMaxWallet > 0, 
            "Must be greater than 0"
        );
        require(
            newMaxTransaction > 0, 
            "Must be greater than 0"
        );
        
        maxWallet = newMaxWallet * 1 ether;
        maxTransaction = newMaxTransaction * 1 ether;
      
        emit LimitsUpdated(maxWallet, maxTransaction);
        return true;
    }

    function setLimitsForSwapTrigger(
        uint256 newMinSwapLiquidity, 
        uint256 newMaxSwapLiquidity) 
        external 
        onlyOwner 
        returns (bool) 
    {
       
        minSwapLiquidity = newMinSwapLiquidity * 1 ether;
        maxSwapLiquidity = newMaxSwapLiquidity * 1 ether;
        emit TriggerLimitsUpdated(minSwapLiquidity, maxSwapLiquidity);
        return true;
    }    

    function recoverForeignTokens(
        address token, 
        uint256 percent) 
        external 
        onlyOwner 
        returns (bool recovered)
    {

        if (percent > 100) { 
            percent = 100; 
        }

        uint256 total = IERC20(token).balanceOf(address(this));
        uint256 recover = total * percent / 100;
        recovered = IERC20(token).transfer(msg.sender, recover);
    }

    function setManualLiquification(uint256 percent) 
        external 
        onlyOwner 
        returns (bool) 
    {

        require(
            !inSwapAndLiquify, 
            "Currently processing, try later."
        ); 

        if (percent > 100) { 
            percent == 100;
        }

        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * percent / 100;
        
        swapAndLiquify(sendTokens);
        return true;
    }

    function approve(
        address spender, 
        uint256 amount) 
        external 
        override 
        returns (bool) 
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender, 
        address recipient, 
        uint256 amount) 
        external 
        override 
        returns (bool) 
    {

        _transfer(sender, recipient, amount);
        
        _approve(
            sender, 
            _msgSender(), 
            _allowances[sender][_msgSender()] - amount
        );

        return true;
    }

    function increaseAllowance(
        address spender, 
        uint256 addedValue) 
        external 
        virtual 
        returns (bool) 
    {

        _approve(
            _msgSender(), 
            spender, 
            _allowances[_msgSender()][spender] + addedValue
        );

        return true;
    }

    function decreaseAllowance(
        address spender, 
        uint256 subtractedValue) 
        external 
        virtual 
        returns (bool) 
    {

        _approve(
            _msgSender(), 
            spender, 
            _allowances[_msgSender()][spender] - subtractedValue
        );

        return true;
    }

    function name() 
        external 
        pure 
        returns (string memory) 
    {

        return _name;
    }

    function symbol() 
        external 
        pure 
        returns (string memory) 
    {

        return _symbol;
    }

    function decimals() 
        external 
        pure 
        returns (uint256) 
    {

        return _decimals;
    }

    function totalSupply() 
        external 
        view 
        override 
        returns (uint256) 
    {

        return _tTotal;
    }

    function allowance(
        address theOwner, 
        address spender) 
        external 
        view 
        override 
        returns (uint256) 
    {

        return _allowances[theOwner][spender];
    }

    function isExcludedFromReward(address account) 
        external 
        view 
        returns (bool) 
    {

        return isExcluded[account];
    }

    function totalFees() 
        external 
        view 
        returns (uint256) 
    {

        return _tFeeTotal;
    }

    function transfer(
        address recipient, 
        uint256 amount) 
        public 
        override 
        returns (bool) 
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function balanceOf(address account) 
        public 
        view 
        override 
        returns (uint256) 
    {

        if (isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function tokenFromReflection(uint256 _rAmount) 
        public 
        view 
        returns (uint256) 
    {

        require(
            _rAmount <= _rTotal, 
            "Amount must be less than total reflections"
        );

        uint256 currentRate =  _getRate();
        return _rAmount / currentRate;
    }

    function _getRate() 
        private 
        view 
        returns (uint256) 
    {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() 
        private 
        view 
        returns (uint256, uint256) 
    {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;  

        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply || 
                _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);

            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }

        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount) 
        private 
    {

        if (!isTradingActive) {
            require(
                isGrantedConfigAccess[from] || 
                isGrantedConfigAccess[to], 
                "Trade not open"
            );
        }

        if (to != owner()){
            require(
                !isBlacklisted[from] && !isBlacklisted[to], 
                "This address is blacklisted. Transaction reverted."
            );
        }

        if (!isLimitExempt[to]) {
            uint256 heldTokens = balanceOf(to);
            require(
                (heldTokens + amount) <= maxWallet, 
                "Over max wallet"
            );
        }

        if (!isLimitExempt[to] || !isLimitExempt[from])
            require(
                amount <= maxTransaction, 
                "Over max TX"
            );

        require(
            from != address(0) && 
            to != address(0), 
            "Can not be 0 address"
        );

        require(
            amount > 0, 
            "Can not be 0 tokens!"
        );

        if (isPair[to] &&
            txCount > swapTrigger &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled) 
        
        {  
            uint256 contractBalance = balanceOf(address(this));

            if (contractBalance > minSwapLiquidity) {
                if (contractBalance < maxSwapLiquidity) {
                    swapAndLiquify(contractBalance);
                } 
                else {
                    swapAndLiquify(maxSwapLiquidity);
                }
            }
        }

        bool takeFee = true;

        if (isExcludedFromFee[from] || isExcludedFromFee[to]) {
            takeFee = false;
        } else {
            if (txCount <= swapTrigger) {
                txCount++;
            }
        }

        _tokenTransfer(from, to, amount, takeFee); 
    }
    
    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        
        uint256 Tokens_LP = contractTokenBalance * percentLP / 200;
        uint256 Tokens_Swap = contractTokenBalance - Tokens_LP;

        uint256 contract_BNB = address(this).balance;
        swapTokensForEth(Tokens_Swap);
        uint256 returned_BNB = address(this).balance - contract_BNB;

        uint256 fee_Split = 200 - percentLP;
        uint256 BNB_L = returned_BNB * percentLP / fee_Split;

        if (Tokens_LP != 0){
            addLiquidity(Tokens_LP, BNB_L);
            emit SwapAndLiquify(Tokens_LP, BNB_L, Tokens_LP);
        }

        contract_BNB = address(this).balance;

        if (contract_BNB > 0) {
            sendToWallet(Wallet_Marketing, contract_BNB);
        }

        txCount = 1;

    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            Wallet_LP,
            block.timestamp
        );
    } 

    function _takeRFI(uint256 _tReflect, uint256 _rReflect) private {
        
        _rTotal = _rTotal - _rReflect;
        _tFeeTotal = _tFeeTotal + _tReflect;
    }

    function _takeFees(uint256 _tFees, uint256 _rFees) private {
        
        _rOwned[address(this)] = _rOwned[address(this)] + _rFees;
        if(isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + _tFees;
    }

    function _approve(
        address theOwner, 
        address spender, 
        uint256 amount) 
        private 
    {
        require(
            theOwner != address(0) && spender != address(0), 
            "must not be the zero address"
        );

        _allowances[theOwner][spender] = amount;
        emit Approval(theOwner, spender, amount);
    }

    function _tokenTransfer(
        address sender, 
        address recipient, 
        uint256 amount, 
        bool takeFee) 
        private 
    {  

        if (!takeFee) {
                tReflect = 0;
                tFees = 0;
        } 

        else if (isPair[sender]) {
            tReflect = amount * ReflectBuy / 100;
            tFees = amount * (FeeBuy - ReflectBuy) / 100;

            if (block.timestamp < boughtEarlyThreshold) {
                    boughtEarly[recipient] = true;
                    boughtEarlyAt[recipient] = block.timestamp;
                    emit BoughtEarly(recipient);
                }
        } 
        
        else if (isPair[recipient]) {
            tReflect = amount * ReflectSell / 100;
            tFees = amount * (FeeSell - ReflectSell) / 100;

            if (boughtEarly[sender] && block.timestamp <= boughtEarlyThreshold) {
                    require(block.timestamp > boughtEarlyAt[sender] + boughtEarlySellCooldown, 
                    ": must wait till bought early sell cooldown is over");
            }
        } 
        
        else {
            tReflect = amount * ReflectP2P / 100;
            tFees = amount * (FeeP2P - ReflectP2P) / 100;

            if (boughtEarly[sender] && block.timestamp <= boughtEarlyThreshold) {
                    require(block.timestamp > boughtEarlyAt[sender] + boughtEarlySellCooldown, 
                    ": must wait till bought early sell cooldown is over");
            }
        } 
        
        uint256 rateRFI = _getRate();

        rAmount = amount * rateRFI;
        rReflect = tReflect * rateRFI;
        rFees = tFees * rateRFI;

        tTransferAmount = amount - (tReflect + tFees);
        rTransferAmount = rAmount - (rReflect + rFees);

        if (isExcluded[sender] && !isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount, takeFee);
        } 
        
        else if (!isExcluded[sender] && isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount, takeFee);
        } 
        
        else if (!isExcluded[sender] && !isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount, takeFee);
        } 
        
        else if (isExcluded[sender] && isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount, takeFee);
        } 
        
        else {
            _transferStandard(sender, recipient, amount, takeFee);
        }
    }

   function _transferStandard(
       address sender, 
       address recipient, 
       uint256 tAmount, 
       bool takeFee) 
       private 
    {

        _rOwned[sender] = _rOwned[sender] - rAmount;

        if (recipient != Wallet_Burn) {
            _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        }

        if(takeFee) {
            _takeRFI(tReflect, rReflect);
            _takeFees(tFees, rFees);
        }

        if (recipient == Wallet_Burn) {
            _tTotal = _tTotal - tAmount;
            _rTotal = _rTotal - rAmount;
        }
        
        emit Transfer(
            sender, 
            recipient, 
            tTransferAmount
        );
    }

    function _transferToExcluded(
        address sender, 
        address recipient, 
        uint256 tAmount, 
        bool takeFee) 
        private 
    {
        
        _rOwned[sender] = _rOwned[sender] - rAmount;

        if (recipient != Wallet_Burn) {
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
            _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        }

        if (takeFee) {
            _takeRFI(tReflect, rReflect);
            _takeFees(tFees, rFees);
        }


        if (recipient == Wallet_Burn) {
            _tTotal = _tTotal - tAmount;
            _rTotal = _rTotal - rAmount;
        }
        
        emit Transfer(
            sender, 
            recipient, 
            tTransferAmount
        );
    }

    function _transferFromExcluded(
        address sender, 
        address recipient, 
        uint256 tAmount, 
        bool takeFee) 
        private 
    {

        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        if (recipient != Wallet_Burn) {
            _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        }

        if (takeFee) {
            _takeRFI(tReflect, rReflect);
            _takeFees(tFees, rFees);
        }


        if (recipient == Wallet_Burn) {
            _tTotal = _tTotal - tAmount;
            _rTotal = _rTotal - rAmount;
        }
        
        emit Transfer(
            sender, 
            recipient, 
            tTransferAmount
        );
    }

    function _transferBothExcluded(
        address sender, 
        address recipient, 
        uint256 tAmount, 
        bool takeFee) 
        private 
    {

        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        if (recipient != Wallet_Burn) {
            _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
            _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        }

        if (takeFee) {
            _takeRFI(tReflect, rReflect);
            _takeFees(tFees, rFees);
        }


        if (recipient == Wallet_Burn) {
            _tTotal = _tTotal - tAmount;
            _rTotal = _rTotal - rAmount;
        }
        
        emit Transfer(
            sender, 
            recipient, 
            tTransferAmount
        );
    }
}