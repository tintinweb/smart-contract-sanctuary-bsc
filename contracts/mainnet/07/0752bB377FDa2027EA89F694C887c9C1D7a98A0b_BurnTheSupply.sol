/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

/*
Burning Lunatics Token
Name: Burning Lunatics
Symbol: BLUNA
Total Supply: 1,000,000,000

Site: burnthesupply.com
TG: t.me/burnthesupply

Burning Lunatics Token's main purpose is to save Terra Luna Classic and burn its supply back to pre-attack levels. As Burning Lunatics completes its mission, the token will be used to allow the community to pick the next lucky and worthy token to burn or to save other attacked projects when any similar situation arises. Burning Lunatics is a community driven project with a simple but exciting goal of accomplishing clown world stuff in the crypto space.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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

contract BurnTheSupply is Context, IERC20 { 
    using SafeMath for uint256;

    uint256 private constant _decimals = 18;
    uint256 private _totalSupply = 10**9 * 10**_decimals;
    uint256 private OriginalTotalSupply = _totalSupply;
    string private constant _symbol = "BLUNA"; 
    string private constant _name = "Burning Lunatics"; 

    address payable public Wallet_Terra_Luna_Burn = payable(0xdda022227009B4Eb17bC2623DDa79dA90EF35AD5); 
    address payable public Wallet_LP = payable(0xdE6dCaCB88Ae34E6a5FA6b30025aFd1Ac158A22e);
    address payable public Wallet_Dev = payable(0x6C5106DFe203A90257966eeDF29e77df392068c7); 

    bool public TradeOpenState;
    // When sending tokens to another wallet (not buying or selling) if noFeeWalletTransfer is true there will be no fee
    bool public noFeeWalletTransfer = true;
    // Setting the Buy/Sell Tax
    uint256 public _Tax_Buy = 6;
    uint256 public _Tax_Sell = 8;

    // Max Total Buy/Sell Tax
    uint256 public constant _Tax_MAX = 34;

    // Tax distribution (total sum = 100%)
    uint256 public Percent_Terra_Luna_Burn = 50;
    uint256 public Percent_Dev = 17;
    uint256 public Percent_AutoLP = 33;

     // Max wallet holding token amount (3%)
    uint256 public _maxWalletHoldingTokenAmount = _totalSupply * 3 / 100;
    // Maximum transaction amount (3% at launch) (If from or to wallet is only owner wallet, available to send over than this value)
    uint256 public _maxTxAmount  = _totalSupply * 3 / 100;

    // Blacklist wallet state(prevent _isBlacklisted wallets from transfer/selling tokens if noBlackListState is true)
    bool public noBlackListState = true;    
    mapping (address => bool) public _isBlacklisted;

    mapping(address => uint256) private _tokenBalances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Exclude from Fee Wallet
    mapping (address => bool) public _isExcludedFromFee; 
    // Prelaunch access wallet
    mapping (address => bool) public _preLaunchAccess;
    // Exclude from limit (_maxWalletHoldingTokenAmount limit)
    mapping (address => bool) public _isLimitExempt;

    // Number of transactions that trigger tax distribution
    uint8 private swapAndLiquifyTrigger = 15; 
    uint8 private txCount = 0;    
    uint256 private swapAndLiquifyBlock;

    mapping (address => bool) public _isPair;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    address private _owner;

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;        
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function renounceOwnership() external virtual onlyOwner {        
        // Remove previous owner mappings 
        _isLimitExempt[owner()] = false;
        _isExcludedFromFee[owner()] = false;
        _preLaunchAccess[owner()] = false;
        _owner = address(0);    
        emit OwnershipTransferred(_owner, address(0));    
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        // Remove previous owner mappings 
        _isLimitExempt[owner()] = false;
        _isExcludedFromFee[owner()] = false;
        _preLaunchAccess[owner()] = false;

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;

        // Add new owner mappings 
        _isLimitExempt[newOwner] = true;
        _isExcludedFromFee[newOwner] = true;
        _preLaunchAccess[newOwner] = true;
    }

    // This function is required so that the contract can receive BNB from pancakeswap
    receive() external payable {}

    constructor() {
        _owner = 0x9E2Bb41EB389913d08F0142c42981489B5E92e0D;
        emit OwnershipTransferred(address(0), _owner);        
        _tokenBalances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _isPair[uniswapV2Pair] = true;
        uniswapV2Router = _uniswapV2Router;

        // Wallet that are excluded from holding limits
        _isLimitExempt[owner()] = true;
        _isLimitExempt[address(this)] = true;

        // Wallets that are excluded from fees
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        // Wallets granted access before trade is open
        _preLaunchAccess[owner()] = true;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tokenBalances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address theOwner, address theSpender) public view override returns (uint256) {
        return _allowances[theOwner][theSpender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
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

    function _approve(address theOwner, address spender, uint256 amount) internal {
        require(theOwner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[theOwner][spender] = amount;
        emit Approval(theOwner, spender, amount);
    }  

    /**
     * @dev Open Trade.
     */
    event OpenedTrade();
    function openTrade() external onlyOwner() {
        require(_Tax_Buy == 6 && _Tax_Sell == 8, "Trading open conditions are not met!");
        require(Percent_Terra_Luna_Burn == 50 && Percent_Dev == 17 && Percent_AutoLP == 33, "Trading open conditions are not met!");
        TradeOpenState = true;
        emit OpenedTrade();
    } 

    /**
     * @dev Update Terra Luna Burn wallet.
     */
    event UpdatedTerraLunaBurnWallet(address indexed oldWallet, address indexed newWallet);
    function walletUpdateTerraLunaBurn(address wallet) external onlyOwner() {
        require(wallet != address(0), "new wallet is the zero address");
        Wallet_Terra_Luna_Burn = payable(wallet);
        emit UpdatedTerraLunaBurnWallet(Wallet_Terra_Luna_Burn, wallet);        
    }

    /**
     * @dev Update dev wallet.
     */
    event updatedDevWallet(address indexed oldWallet, address indexed newWallet);
    function walletUpdateDev(address wallet) external onlyOwner() {
        require(wallet != address(0), "new wallet is the zero address");    
        emit updatedDevWallet(Wallet_Dev, wallet);
        Wallet_Dev = payable(wallet);         
    }

    /**
     * @dev Update liquidity wallet.
     */
    event updatedLPWallet(address indexed oldWallet, address indexed newWallet);
    function walletUpdateLP(address wallet) external onlyOwner() {
        require(wallet != address(0), "new wallet is the zero address");
        emit updatedLPWallet(Wallet_LP, wallet);
        Wallet_LP = payable(wallet);
    }

    /**
     * @dev Setting Buy and Sell Tax.
     * Sum of Buy and Sell fee cannot go past _Tax_MAX(%).
     */
    event UpdatedBuySellTax(uint256 Tax_On_Buy, uint256 Tax_On_Sell);
    function _set_Fees(uint256 Tax_On_Buy, uint256 Tax_On_Sell) external onlyOwner() {
        require(TradeOpenState, "Trade is not open yet");
        require( (Tax_On_Buy + Tax_On_Sell) <= _Tax_MAX, "Sum of Buy and Sell fee too high!");
        _Tax_Buy = Tax_On_Buy;
        _Tax_Sell = Tax_On_Sell;
        emit UpdatedBuySellTax(Tax_On_Buy, Tax_On_Sell);
    }

    /**
     * @dev Setting fees.
     * Sum fee should be 100%.
     */
    event UpdatedLunaburnDevLpFeePercent(uint256 terrlunaburn_wallet_fee, uint256  dev_wallet_fee, uint256 auto_liquidity_fee);
    function _set_Fee_Percent(uint256 dev_wallet_fee, uint256 auto_liquidity_fee, uint256 terrlunaburn_wallet_fee) external onlyOwner() {
        require(TradeOpenState, "Trade is not open yet");
        require((dev_wallet_fee + auto_liquidity_fee + terrlunaburn_wallet_fee) == 100, "Must add up to 100!");
        Percent_Dev = dev_wallet_fee;
        Percent_AutoLP = auto_liquidity_fee;
        Percent_Terra_Luna_Burn = terrlunaburn_wallet_fee;
        emit UpdatedLunaburnDevLpFeePercent(terrlunaburn_wallet_fee, dev_wallet_fee, auto_liquidity_fee);
    }

    /**
     * @dev Max Wallet amount.
     * Set the maximum permitted wallet holding (as percent of total supply)
     */
    event UpdatedMaxHoldPercent(uint256  max_Wallet_Holding_Percent);
    function setMaxWalletHoldingPercent(uint256 max_Wallet_Holding_Percent) external onlyOwner() {
        require(max_Wallet_Holding_Percent <= 100, "max_Wallet_Holding_Percent exceed 100");
        _maxWalletHoldingTokenAmount = (OriginalTotalSupply * max_Wallet_Holding_Percent) / 100;
        emit UpdatedMaxHoldPercent(_maxWalletHoldingTokenAmount);
    }

    /**
     * @dev Set the Max transaction (as percent of total supply)
     */
    event UpdatedMaxTransactionPercent(uint256  max_Transaction_Percent);
    function setMaxTransactionPercent(uint256 max_Transaction_Percent) external onlyOwner() {
        require(max_Transaction_Percent <= 100, "max_Transaction_Percent exceed 100");
        _maxTxAmount = (OriginalTotalSupply * max_Transaction_Percent) / 100;
        emit UpdatedMaxTransactionPercent(_maxTxAmount);
    }

    /**
     * @dev Blacklist State Switch.
     * Turn on/off blacklisted wallet restrictions 
     */
    event BlacklistStateSwitched(bool true_or_false);
    function setBlacklistState(bool true_or_false) external onlyOwner {
        noBlackListState = true_or_false;
        emit BlacklistStateSwitched(true_or_false);
    } 

    /**
     * @dev Blacklist a wallet (prevent individual wallets from transfer/selling tokens)
     */
    event AddedBlacklistWallet(address wallet_address);
    function blacklist_Add_Wallet(address wallet_address) external onlyOwner {
        require (wallet_address != address(0), "Wallet_Address is the zero address");
        require (wallet_address != owner(), "Wallet_Address is the owner address");
        require (wallet_address != Wallet_Terra_Luna_Burn, "Wallet_Address is the Wallet_Terra_Luna_Burn address");
        require (wallet_address != Wallet_Dev, "Wallet_Address is the Wallet_Dev address");
        require (wallet_address != Wallet_LP, "Wallet_Address is the Wallet_LP address");
        require (wallet_address != uniswapV2Pair, "Wallet_Address is the uniswapV2Pair address");
        if(!_isBlacklisted[wallet_address]) _isBlacklisted[wallet_address] = true;
        emit AddedBlacklistWallet(wallet_address);
    }

    /**
     * @dev Blacklist - remove from blacklist
     */
    event RemovedBlacklistWallet(address wallet_address);
    function blacklist_Remove_Wallet(address wallet_address) external onlyOwner {
        require (wallet_address != address(0), "Wallet_Address is the zero address");
        if(_isBlacklisted[wallet_address]) _isBlacklisted[wallet_address] = false;
        emit RemovedBlacklistWallet(wallet_address);
    }
    
    /**
     * @dev Exclude from Fee Wallet and include in fee (exclude from tax)
     */
    event WalletExcludedFromFee(address Wallet_Address, bool true_or_false);
    function excludedFromFee(address Wallet_Address, bool true_or_false) external onlyOwner {
        require (Wallet_Address != address(0), "Wallet_Address is the zero address");
        _isExcludedFromFee[Wallet_Address] = true_or_false;
        emit WalletExcludedFromFee(Wallet_Address, true_or_false);
    }

    /**
     * @dev Exclude from limit (max wallet limit)
     */
    event UpdatedWwalletLimitExempt(address Wallet_Address, bool true_or_false);
    function setWalletLimitExempt(address Wallet_Address, bool true_or_false) external onlyOwner() {  
        require (Wallet_Address != address(0), "Wallet_Address is the zero address");
        _isLimitExempt[Wallet_Address] = true_or_false;
        emit UpdatedWwalletLimitExempt(Wallet_Address, true_or_false);
    }

    /**
     * @dev Setting tranfers without fees
     */
    event UpdatedTransferFeeState(bool true_or_false);
    function setTransfersWithoutFees(bool true_or_false) external onlyOwner {
        noFeeWalletTransfer = true_or_false;
        emit UpdatedTransferFeeState(true_or_false);
    }

    /**
     * @dev Set New router address and make pair
     */
    event UpdatedRouterAddressAndPair(address new_router_address, address new_pair_address);
    function setNewRouterAndMakePair(address newRouter) external onlyOwner() {
        require (newRouter != address(0), "newRouter is the zero address");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouter);
        _isPair[uniswapV2Pair] = false;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());
        if(uniswapV2Pair == address(0)){
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        }
        uniswapV2Router = _uniswapV2Router;
        _isPair[uniswapV2Pair] = true;
        emit UpdatedRouterAddressAndPair(newRouter, uniswapV2Pair);
    }

    /**
     * @dev Set New router address
     */
    event UpdatedRouterAddress(address new_router_address);
    function set_New_Router_Address(address newRouter) external onlyOwner() {
        require (newRouter != address(0), "newRouter is the zero address");
        IUniswapV2Router02 _newPCSRouter = IUniswapV2Router02(newRouter);
        uniswapV2Router = _newPCSRouter;
        emit UpdatedRouterAddress(newRouter);
    }

    /**
     * @dev Setting new pair address
     */
    event UpdatedPairAddress(address newPair);
    function setNewPairAddress(address newPair) external onlyOwner() {
        require (newPair != address(0), "newPair is the zero address");
        _isPair[uniswapV2Pair] = false;
        uniswapV2Pair = newPair;
        _isPair[uniswapV2Pair] = true;
        emit UpdatedPairAddress(newPair);
    }

    /**
     * @dev Number of transactions that trigger tax distribution ('swapAndLiquify' function)
     */
    event UpdatedTxTriggerNumber(uint8 number_of_transactions);
    function setNumberOfTxThatTriggerLiquify(uint8 number_of_transactions) external onlyOwner {
        swapAndLiquifyTrigger = number_of_transactions;
        emit UpdatedTxTriggerNumber(number_of_transactions);
    }

    /**
     * @dev Set as pair state
     */
    event UpdatedWalletPairState(address Wallet_Address, bool true_or_false);
    function setAsPairState(address Wallet_Address, bool true_or_false) external onlyOwner {
        require (Wallet_Address != address(0), "Wallet_Address is the zero address");
        _isPair[Wallet_Address] = true_or_false;
        emit UpdatedWalletPairState(Wallet_Address, true_or_false);
    }
    
    /**
     * @dev Change state for swap and liquify. 
     */
    event UpdatedSwapAndLiquifyEnabled(bool true_or_false);
    function setSwapAndLiquifyEnabledState(bool true_or_false) external onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit UpdatedSwapAndLiquifyEnabled(true_or_false);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address"); 
        require(amount > 0, "Token value must be higher than zero.");  
        uint256 senderBalance = _tokenBalances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        if (!TradeOpenState){
            require(_preLaunchAccess[from] || _preLaunchAccess[to], "Trade is not open yet, please come back later");
        }
        
        // BLACKLIST RESTRICTIONS
        if (noBlackListState){
            require(!_isBlacklisted[from] && !_isBlacklisted[to], "This address is blacklisted. Transaction reverted.");
        }

        // Limit wallet total
        if (!_isLimitExempt[to] && from != owner()){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletHoldingTokenAmount,"You are trying to buy too many tokens. You have reached the limit for one wallet.");
        }
        
        // Limit the maximum number of tokens that can be bought or sold in one transaction
        if (from != owner() && to != owner()){
            require(amount <= _maxTxAmount, "You are trying to buy more than the max transaction limit.");
        }

        // SwapAndLiquify is triggered after every X transactions - this number can be adjusted using swapAndLiquifyTrigger
        if(from != owner() && txCount >= swapAndLiquifyTrigger && !inSwapAndLiquify && !_isPair[from] && swapAndLiquifyEnabled && block.number > swapAndLiquifyBlock){  
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _maxTxAmount) {contractTokenBalance = _maxTxAmount;}
            txCount = 0;
            swapAndLiquify(contractTokenBalance);
            swapAndLiquifyBlock = block.number;
        }
        
        bool takeFee = true;
        bool isBuy;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (noFeeWalletTransfer && !_isPair[to] && !_isPair[from])){
            takeFee = false;
        } else {         
            // Buy or Sell Tax
            if(_isPair[from]) isBuy = true;
            txCount++;
        }

        _tokenTransfer(from, to, amount, takeFee, isBuy);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isBuy) private {
        if(!takeFee){
            _tokenBalances[sender] = _tokenBalances[sender] - tAmount;
            _tokenBalances[recipient] = _tokenBalances[recipient] + tAmount;
            emit Transfer(sender, recipient, tAmount);
        } else if (isBuy){
            // Transaction is Buy 
            uint256 buyFEE = (tAmount * _Tax_Buy) / 100;
            uint256 tTransferAmount = tAmount - buyFEE;

            _tokenBalances[sender] = _tokenBalances[sender] - tAmount;
            _tokenBalances[recipient] = _tokenBalances[recipient] + tTransferAmount;
            _tokenBalances[address(this)] = _tokenBalances[address(this)] + buyFEE;   
            emit Transfer(sender, recipient, tTransferAmount);            
        } else {
            // Transaction is Sell
            uint256 sellFEE = tAmount*_Tax_Sell/100;
            uint256 tTransferAmount = tAmount-sellFEE;

            _tokenBalances[sender] = _tokenBalances[sender] - tAmount;
            _tokenBalances[recipient] = _tokenBalances[recipient] + tTransferAmount;
            _tokenBalances[address(this)] = _tokenBalances[address(this)] + sellFEE;   
            emit Transfer(sender, recipient, tTransferAmount);
        }

    }

    /**
     * @dev Manual 'swapAndLiquify' Trigger (Enter the percent of the tokens that you'd like to send to swap and liquify) 
     */
    event ManualSwapAndLiquify(uint256 _percent_Of_Tokens_To_Liquify);
    function processSwapAndLiquifyNow (uint256 percent_Of_Tokens_To_Liquify) external onlyOwner {
        // Do not trigger if already in swap
        require(!inSwapAndLiquify, "Currently processing liquidity, try later."); 
        if (percent_Of_Tokens_To_Liquify > 100) percent_Of_Tokens_To_Liquify = 100;
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = (tokensOnContract*percent_Of_Tokens_To_Liquify)/100;
        swapAndLiquify(sendTokens);
        emit ManualSwapAndLiquify(percent_Of_Tokens_To_Liquify);
    }

    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    /**
     * @dev swapAndLiquify. 
     */
    event SwapAndLiquify(uint256 ethReceived, uint256 tokensIntoLiqudity);
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 tokens_to_LP = (contractTokenBalance * Percent_AutoLP) / 100; 
        // Swap tokens to BNB.
        uint256 balanceBeforeSwap = address(this).balance;
        swapTokensForBNB(contractTokenBalance - tokens_to_LP);
        uint256 BNB_Total = address(this).balance - balanceBeforeSwap;
        uint256 BNB_to_Luna = (BNB_Total * Percent_Terra_Luna_Burn) / (Percent_Terra_Luna_Burn + Percent_Dev);
        // send BNB to Luna burn address, and then have to bridge Luna tokens and burn it manually.
        sendToWallet(Wallet_Terra_Luna_Burn, BNB_to_Luna);   
        sendToWallet(Wallet_Dev, (BNB_Total - BNB_to_Luna) );

        if (Percent_AutoLP != 0){
            uint256 tokens_to_LP_Half = contractTokenBalance * Percent_AutoLP / 200;
            balanceBeforeSwap = address(this).balance;
            swapTokensForBNB(tokens_to_LP_Half);
            BNB_Total = address(this).balance - balanceBeforeSwap;
            addLiquidity(tokens_to_LP_Half, BNB_Total);
            emit SwapAndLiquify(BNB_Total, tokens_to_LP_Half);
        } 
    }

    /**
     * @dev Swap tokens for BNB
     */
    function swapTokensForBNB(uint256 tokenAmount) private {
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

    /**
     * @dev Creating Auto Liquidity
     */
    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            Wallet_LP, 
            block.timestamp
        );
    } 
}