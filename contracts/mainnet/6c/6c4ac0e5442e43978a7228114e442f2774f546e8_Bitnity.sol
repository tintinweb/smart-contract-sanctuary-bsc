/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT                                                                               
                                                    
pragma solidity 0.8.15;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _createInitialSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract TokenHandler is Ownable {
    function sendTokenToOwner(address token) external onlyOwner {
        if(IERC20(token).balanceOf(address(this)) > 0){
            IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
        }
    }
}

contract Bitnity is ERC20, Ownable {

    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;

    IDexRouter public immutable dexRouter;
    address public immutable lpPair;
    address public immutable lpPairEth;

    bool public lpToEth;

    IERC20 public immutable STABLECOIN; 

    bool private swapping;
    uint256 public swapTokensAtAmount;

    // must be used with Stablecoin
    TokenHandler public tokenHandler;

    address public operationsAddress;
    address public futureOwnerAddress;

    uint256 public tradingActiveBlock = 0; // 0 means trading is not active
    mapping (address => bool) public restrictedWallets;
    uint256 public blockForPenaltyEnd;

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;
    
    uint256 public buyTotalFees;
    uint256 public buyOperationsFee;

    uint256 public sellTotalFees;
    uint256 public sellOperationsFee;

    uint256 constant FEE_DIVISOR = 10000;

    uint256 public tokensForLiquidity;
    uint256 public tokensForOperations;
    
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isExcludedMaxTransactionAmount;

    mapping (address => bool) public automatedMarketMakerPairs;

    // Events

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event EnabledTrading();
    event RemovedLimits();
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event UpdatedMaxBuyAmount(uint256 newAmount);
    event UpdatedMaxSellAmount(uint256 newAmount);
    event UpdatedMaxWalletAmount(uint256 newAmount);
    event UpdatedBuyFee(uint256 newAmount);
    event UpdatedSellFee(uint256 newAmount);
    event UpdatedProjectAddress(address indexed newWallet);
    event UpdatedLiquidityAddress(address indexed newWallet);
    event UpdatedDevAddress(address indexed newWallet);
    event UpdatedOperationsAddress(address indexed newWallet);
    event MaxTransactionExclusion(address _address, bool excluded);
    event OwnerForcedSwapBack(uint256 timestamp);
    event CaughtEarlyBuyer(address sniper);
    event TransferForeignToken(address token, uint256 amount);

    constructor(bool _lpIsEth, address newOwner) ERC20("Bitnity Token", "BTNTY") {

        lpToEth = _lpIsEth;

        address stablecoinAddress;
        address _dexRouter;

        // automatically detect router/desired stablecoin
        if(block.chainid == 1){
            stablecoinAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // USDC
            _dexRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ETH: Uniswap V2
        } else if(block.chainid == 4){
            stablecoinAddress  = 0xE7d541c18D6aDb863F4C570065c57b75a53a64d3; // Rinkeby Testnet USDC
            _dexRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ETH: Uniswap V2
        } else if(block.chainid == 56){
            stablecoinAddress  = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BUSD
            _dexRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // BNB Chain: PCS V2
        } else if(block.chainid == 97){
            stablecoinAddress  = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // BSC Testnet BUSD
            _dexRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // BNB Chain: PCS V2
        } else {
            revert("Chain not configured");
        }

        STABLECOIN = IERC20(stablecoinAddress);
        require(STABLECOIN.decimals() > 0 , "Incorrect liquidity token");

        dexRouter = IDexRouter(_dexRouter);

        // create pair
        lpPair = IDexFactory(dexRouter.factory()).createPair(address(this), address(STABLECOIN));
        setAutomatedMarketMakerPair(address(lpPair), true);

        lpPairEth = IDexFactory(dexRouter.factory()).createPair(address(this), dexRouter.WETH());
        setAutomatedMarketMakerPair(address(lpPairEth), true);

        uint256 totalSupply = 1 * 1e9 * 1e18;
        
        maxBuyAmount = totalSupply * 25 / 10000;
        maxSellAmount = totalSupply * 25 / 10000;
        swapTokensAtAmount = totalSupply * 25 / 100000;

        tokenHandler = new TokenHandler();

        buyOperationsFee = 450;
        buyTotalFees = buyOperationsFee;

        sellOperationsFee = 450;
        sellTotalFees = sellOperationsFee;

        operationsAddress = address(0xCF32e7019048Ac0C51AeC2678f98a73905D8d64d);

        _excludeFromMaxTransaction(newOwner, true);
        _excludeFromMaxTransaction(address(this), true);
        _excludeFromMaxTransaction(address(0xdead), true);
        _excludeFromMaxTransaction(address(operationsAddress), true);
        _excludeFromMaxTransaction(address(dexRouter), true);

        excludeFromFees(newOwner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        excludeFromFees(address(operationsAddress), true);
        excludeFromFees(address(dexRouter), true);

        _createInitialSupply(address(newOwner), totalSupply);
        transferOwnership(newOwner);
    }

    receive() external payable {}

    // Owner Functions

    function updateLpToEth(bool _lpToEth) external onlyOwner {
        if(_lpToEth){
            require(balanceOf(address(lpPairEth))>0, "Must have tokens in ETH pair to set as default LP pair");
        } else {
            require(balanceOf(address(lpPair))>0, "Must have tokens in STABLECOIN pair to set as default LP pair");
        }
        lpToEth = _lpToEth;
    }

    function enableTrading(uint256 blocksForPenalty) external onlyOwner {
        require(!tradingActive, "Trading is already active, cannot relaunch.");
        require(blocksForPenalty <= 10, "Cannot make penalty blocks more than 10");
        tradingActive = true;
        swapEnabled = true;
        tradingActiveBlock = block.number;
        blockForPenaltyEnd = tradingActiveBlock + blocksForPenalty;
        emit EnabledTrading();
    }

    function pauseTrading() external onlyOwner {
        require(tradingActiveBlock > 0, "Cannot pause until token has launched");
        require(tradingActive, "Trading is already paused");
        tradingActive = false;
    }

    function unpauseTrading() external onlyOwner {
        require(tradingActiveBlock > 0, "Cannot unpause until token has launched");
        require(!tradingActive, "Trading is already unpaused");
        tradingActive = true;
    }

    function manageRestrictedWallets(address[] calldata wallets,  bool restricted) external onlyOwner {
        for(uint256 i = 0; i < wallets.length; i++){
            restrictedWallets[wallets[i]] = restricted;
        }
    }
    
    function removeLimits() external onlyOwner {
        limitsInEffect = false;
        maxBuyAmount = totalSupply();
        maxSellAmount = totalSupply();
        emit RemovedLimits();
    }

    function updateMaxBuyAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 1 / 1000) / (10 ** decimals()), "Cannot set max buy amount lower than 0.1%");
        maxBuyAmount = newNum * (10 ** decimals());
        emit UpdatedMaxBuyAmount(maxBuyAmount);
    }
    
    function updateMaxSellAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 1 / 1000) / (10 ** decimals()), "Cannot set max sell amount lower than 0.1%");
        maxSellAmount = newNum * (10 ** decimals());
        emit UpdatedMaxSellAmount(maxSellAmount);
    }

    // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
  	    require(newAmount >= totalSupply() * 1 / 1000000, "Swap amount cannot be lower than 0.0001% total supply.");
  	    require(newAmount <= totalSupply() * 1 / 1000, "Swap amount cannot be higher than 0.1% total supply.");
  	    swapTokensAtAmount = newAmount;
  	}
    
    function transferForeignToken(address _token, address _to) external onlyOwner returns (bool _sent) {
        require(_token != address(0), "_token address cannot be 0");
        require(_token != address(this) || !tradingActive, "Can't withdraw native tokens while trading is active");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
        emit TransferForeignToken(_token, _contractBalance);
    }

    function withdrawStuckEth() public onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    function setOperationsAddress(address _operationsAddress) external onlyOwner {
        require(_operationsAddress != address(0), "address cannot be 0");
        operationsAddress = payable(_operationsAddress);
        emit UpdatedOperationsAddress(_operationsAddress);
    }

    function forceSwapBack(bool inEth) external onlyOwner {
        require(balanceOf(address(this)) >= swapTokensAtAmount, "Can only swap when token amount is at or higher than restriction");
        swapping = true;
        if(inEth){
            swapBackEth();
        } else {
            swapBack();
        }
        swapping = false;
        emit OwnerForcedSwapBack(block.timestamp);
    }
    
    function airdropToWallets(address[] memory wallets, uint256[] memory amountsInTokens) external onlyOwner {
        require(wallets.length == amountsInTokens.length, "arrays must be the same length");
        require(wallets.length < 600, "Can only airdrop 600 wallets per txn due to gas limits");
        for(uint256 i = 0; i < wallets.length; i++){
            address wallet = wallets[i];
            uint256 amount = amountsInTokens[i];
            super._transfer(msg.sender, wallet, amount);
        }
    }
    
    function excludeFromMaxTransaction(address updAds, bool isEx) external onlyOwner {
        if(!isEx){
            require(updAds != lpPair, "Cannot remove uniswap pair from max txn");
        }
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != lpPair || value, "The pair cannot be removed from automatedMarketMakerPairs");
        automatedMarketMakerPairs[pair] = value;
        _excludeFromMaxTransaction(pair, value);
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateBuyFees(uint256 _operationsFee) external onlyOwner {
        buyOperationsFee = _operationsFee;
        buyTotalFees = buyOperationsFee;
        require(buyTotalFees <= 1500, "Must keep fees at 15% or less");
        emit UpdatedBuyFee(buyTotalFees);
    }

    function updateSellFees(uint256 _operationsFee) external onlyOwner {
        sellOperationsFee = _operationsFee;
        sellTotalFees = sellOperationsFee;
        require(sellTotalFees <= 1500, "Must keep fees at 15% or less");
        emit UpdatedSellFee(sellTotalFees);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    // private / internal functions

    function _transfer(address from, address to, uint256 amount) internal override {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        // transfer of 0 is allowed, but triggers no logic.  In case of staking where a staking pool is paying out 0 rewards.
        if(amount == 0){
            super._transfer(from, to, 0);
            return;
        }
        
        if(!tradingActive){
            require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
        }

        if(!earlyBuyPenaltyInEffect() && blockForPenaltyEnd > 0){
            require(!restrictedWallets[from] || to == owner() || to == address(0xdead), "Bots cannot transfer tokens in or out except to owner or dead address.");
        }

        if(limitsInEffect){
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
                
                //on buy
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxBuyAmount, "Buy transfer amount exceeds the max buy.");
                } 
                //on sell
                else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    require(amount <= maxSellAmount, "Sell transfer amount exceeds the max sell.");
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && swapEnabled && !swapping && automatedMarketMakerPairs[to]) {
            swapping = true;
            if(lpToEth){
                swapBackEth();
            } else {
                swapBack();
            }
            swapping = false;
        }

        bool takeFee = true;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        
        uint256 fees = 0;

        // only take fees on buys/sells, do not take on wallet transfers
        if(takeFee){
            // bot/sniper penalty.
            if(earlyBuyPenaltyInEffect() && automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to] && buyTotalFees > 0){
                
                if(!restrictedWallets[to]){
                    restrictedWallets[to] = true;
                }
                
                fees = amount * buyTotalFees / FEE_DIVISOR;
                tokensForOperations += fees * buyOperationsFee / buyTotalFees;
            }

            // on sell
            else if (automatedMarketMakerPairs[to] && sellTotalFees > 0){
                fees = amount * sellTotalFees / FEE_DIVISOR;
                tokensForOperations += fees * sellOperationsFee / sellTotalFees;
            }

            // on buy
            else if(automatedMarketMakerPairs[from] && buyTotalFees > 0) {
        	    fees = amount * buyTotalFees / FEE_DIVISOR;
                tokensForOperations += fees * buyOperationsFee / buyTotalFees;
            }
            
            if(fees > 0){    
                super._transfer(from, address(this), fees);
            }
        	
        	amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForSTABLECOIN(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(STABLECOIN);

        _approve(address(this), address(dexRouter), tokenAmount);

        dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(tokenHandler), block.timestamp);
    }

    // if LP pair in use is STABLECOIN, this function will be used to handle fee distribution.

    function swapBack() private {

        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForOperations;
        
        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        if(contractBalance > swapTokensAtAmount * 10){
            contractBalance = swapTokensAtAmount * 10;
        }
        
        swapTokensForSTABLECOIN(contractBalance);

        tokenHandler.sendTokenToOwner(address(STABLECOIN));

        tokensForOperations = 0;

        if(STABLECOIN.balanceOf(address(this)) > 0){
            STABLECOIN.transfer(operationsAddress, STABLECOIN.balanceOf(address(this)));
        }
    }

    // if LP pair in use is ETH, this function will be used to handle fee distribution.

    function swapBackEth() private {
        bool success;

        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForOperations;
        
        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        if(contractBalance > swapTokensAtAmount * 10){
            contractBalance = swapTokensAtAmount * 10;
        }

        swapTokensForEth(contractBalance);
        
        tokensForOperations = 0;

        if(address(this).balance > 0){
            (success, ) = operationsAddress.call{value: address(this).balance}("");
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function _excludeFromMaxTransaction(address updAds, bool isExcluded) private {
        _isExcludedMaxTransactionAmount[updAds] = isExcluded;
        emit MaxTransactionExclusion(updAds, isExcluded);
    }

    //views

    function earlyBuyPenaltyInEffect() private view returns (bool){
        return block.number < blockForPenaltyEnd;
    }

    function getBlockNumber() external view returns (uint256){
        return block.number;
    }
}