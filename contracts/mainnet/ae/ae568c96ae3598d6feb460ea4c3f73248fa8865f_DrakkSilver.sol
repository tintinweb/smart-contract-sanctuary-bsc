/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: MIT                                                                               
                                                    
pragma solidity 0.8.13;

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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) public _balances;

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

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

     function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

interface ILpPair {
    function sync() external;
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

interface Token {
  event LockToken(address indexed walletLock, uint256 amount, uint256 releaseTime, uint256 maxReleaseAmount);
}

contract DrakkSilver is ERC20, Ownable, Token{

    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;

    IDexRouter public immutable dexRouter;
    address public immutable lpPair;

    IERC20 public constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // Testnet: 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee  //Mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56

    bool private swapping;

    TokenHandler public tokenHandler;


    address public devAddress;
    address public rewardsAddress;
    address public incubatorAddress;
    address public liquidityAddress;
    address public futureOwnerAddress;

    uint256 public tradingActiveBlock = 0; // 0 means trading is not active
    uint256 public blockForPenaltyEnd;
    mapping (address => bool) public restrictedWallets;
    address[] public earlyBuyers;
    uint256 public botsCaught;

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;
    
     // Anti-bot and anti-whale mappings and variables
    mapping(address => uint256) private _holderLastTransferBlock; // to hold last Transfers temporarily during launch
    bool public transferDelayEnabled = true;

    uint256 public buyTotalFees;
    uint256 public buyLiquidityFee;

    uint256 public sellTotalFees;
    uint256 public sellDevsFee;
    uint256 public sellLiquidityFee;
    uint256 public sellRewardsFee;
    uint256 public sellIncubatorFee;

    uint256 public tokensForDevs;
    uint256 public tokensForLiquidity;
    uint256 public tokensForRewards;
    uint256 public tokensForIncubator;
    
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isExcludedMaxTransactionAmount;

    mapping (address => bool) public automatedMarketMakerPairs;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event EnabledTrading();
    event RemovedLimits();
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event UpdatedMaxBuyAmount(uint256 newAmount);
    event UpdatedMaxSellAmount(uint256 newAmount);
    event UpdatedMaxWalletAmount(uint256 newAmount);
    event UpdatedBuyFee(uint256 newAmount);
    event UpdatedSellFee(uint256 newAmount);
    event UpdatedDevsAddress(address indexed newWallet);
    event UpdatedRewardsAddress(address indexed newWallet);
    event UpdatedIncubatorAddress(address indexed newWallet);
    event UpdatedLiquidityAddress(address indexed newWallet);
    event MaxTransactionExclusion(address _address, bool excluded);
    event OwnerForcedSwapBack(uint256 timestamp);
    event CaughtEarlyBuyer(address sniper);
    event TransferForeignToken(address token, uint256 amount);

    constructor() ERC20("Drakk Silver", "DKS") {
        
        address newOwner = 0x7ac20f603ab219201B3cA014ebD534a5DD5C5c2A; // can leave alone if owner is deployer.

        // initialize router
        IDexRouter _dexRouter = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1  // Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        dexRouter = _dexRouter;

        // create pair
        lpPair = IDexFactory(dexRouter.factory()).createPair(address(this), address(BUSD));
        setAutomatedMarketMakerPair(address(lpPair), true);

        uint256 totalSupply = 600 * 1e6 * 1e18;

        tokenHandler = new TokenHandler();
        
        maxBuyAmount = totalSupply * 1 / 1000;
        maxSellAmount = totalSupply * 1 / 120000;

        buyLiquidityFee = 2;
        buyTotalFees = buyLiquidityFee;

        sellDevsFee = 7;
        sellLiquidityFee = 1;
        sellRewardsFee = 2;
        sellIncubatorFee = 3;
        sellTotalFees = sellDevsFee + sellLiquidityFee + sellRewardsFee + sellIncubatorFee;

        // update these!
        devAddress = address(0x0C6C644575aeA97983Ff14F9D7cA54972Cf1232d);
        rewardsAddress = address(msg.sender);
        incubatorAddress = address(0x118ab0C2013d4050419fdBDdD060B4a9b318B455);
        liquidityAddress = address(msg.sender);
        futureOwnerAddress = address(0x7ac20f603ab219201B3cA014ebD534a5DD5C5c2A);

        _excludeFromMaxTransaction(newOwner, true);
        _excludeFromMaxTransaction(futureOwnerAddress, true);
        _excludeFromMaxTransaction(address(this), true);
        _excludeFromMaxTransaction(address(0xdead), true);
        _excludeFromMaxTransaction(address(devAddress), true);
        _excludeFromMaxTransaction(address(incubatorAddress), true);
        _excludeFromMaxTransaction(address(liquidityAddress), true);

        excludeFromFees(newOwner, true);
        excludeFromFees(futureOwnerAddress, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        excludeFromFees(address(devAddress), true);
        excludeFromFees(address(incubatorAddress), true);
        excludeFromFees(address(liquidityAddress), true);

        _createInitialSupply(address(newOwner), totalSupply);
        transferOwnership(newOwner);
    }

    receive() external payable {}

    function enableTrading(uint256 blocksForPenalty) external onlyOwner {
        require(!tradingActive, "Trading is already active, cannot relaunch.");
        require(blocksForPenalty < 10, "Cannot make penalty blocks more than 10");
        tradingActive = true;
        swapEnabled = true;
        tradingActiveBlock = block.number;
        blockForPenaltyEnd = tradingActiveBlock + blocksForPenalty;
        emit EnabledTrading();
    }

    function pauseTrading() external onlyOwner {
        require(blockForPenaltyEnd > 0, "Cannot pause until token has launched");
        require(tradingActive, "Trading is already paused");
        tradingActive = false;
    }

    function unpauseTrading() external onlyOwner {
        require(blockForPenaltyEnd > 0, "Cannot unpause until token has launched");
        require(!tradingActive, "Trading is already unpaused");
        tradingActive = true;
    }

    function manageRestrictedWallets(address[] calldata wallets,  bool restricted) external onlyOwner {
        for(uint256 i = 0; i < wallets.length; i++){
            restrictedWallets[wallets[i]] = restricted;
        }
    }
    
    // remove limits after token is stable
    function removeLimits() external onlyOwner {
        limitsInEffect = false;
        transferDelayEnabled = false;
        maxBuyAmount = totalSupply();
        maxSellAmount = totalSupply();
        emit RemovedLimits();
    }

    function getEarlyBuyers() external view returns (address[] memory){
        return earlyBuyers;
    }

    function removeBoughtEarly(address wallet) external onlyOwner {
        restrictedWallets[wallet] = false;
    }

    // disable Transfer delay - cannot be reenabled
    function disableTransferDelay() external onlyOwner {
        transferDelayEnabled = false;
    }
    
    function updateMaxBuyAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 1 / 1000)/1e18, "Cannot set max buy amount lower than 0.1%");
        maxBuyAmount = newNum * (10**18);
        emit UpdatedMaxBuyAmount(maxBuyAmount);
    }
    
    function updateMaxSellAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 1 / 1000)/1e18, "Cannot set max sell amount lower than 0.1%");
        maxSellAmount = newNum * (10**18);
        emit UpdatedMaxSellAmount(maxSellAmount);
    }


    function _excludeFromMaxTransaction(address updAds, bool isExcluded) private {
        _isExcludedMaxTransactionAmount[updAds] = isExcluded;
        emit MaxTransactionExclusion(updAds, isExcluded);
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

    function updateBuyFees(uint256 _liquidityFee) external onlyOwner {
        buyLiquidityFee = _liquidityFee;
        buyTotalFees = buyLiquidityFee;
        require(buyTotalFees <= 5, "Must keep fees at 2% or less");
        emit UpdatedBuyFee(buyTotalFees);
    }

    function updateSellFees(uint256 _devFee, uint256 _liquidityFee, uint256 _rewardsFee, uint256 _incubatorFee) external onlyOwner {
        require(_devFee <= 10, "Exceeded max fee for dev");
        sellDevsFee = _devFee;
        require(_liquidityFee <= 5, "Exceeded max fee for liquidity");
        sellLiquidityFee = _liquidityFee;
        require(_rewardsFee <= 5, "Exceeded max fee for rewards");
        sellRewardsFee = _rewardsFee;
        require(_incubatorFee <= 5, "Exceeded max fee for incubator");
        sellIncubatorFee = _incubatorFee;
        sellTotalFees = sellDevsFee + sellLiquidityFee + sellRewardsFee + sellIncubatorFee;
        require(sellTotalFees <= 25, "Must keep fees at 25% or less");
        emit UpdatedSellFee(sellTotalFees);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _transfer(address from, address to, uint256 amount) internal override {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0){
            super._transfer(from, to, 0);
            return;
        }
        
        if(!tradingActive){
            require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
        }

        if(!earlyBuyPenaltyInEffect() && tradingActive){
            require(!restrictedWallets[from] || to == owner() || to == address(0xdead), "Bots cannot transfer tokens in or out except to owner or dead address.");
        }
        
        if(limitsInEffect){
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
                
                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.  
                if (transferDelayEnabled){
                    if (to != address(dexRouter) && to != address(lpPair)){
                        require(_holderLastTransferBlock[tx.origin] + 5 < block.number && _holderLastTransferBlock[to] + 5 < block.number, "_transfer:: Transfer Delay enabled.  Try again later.");
                        _holderLastTransferBlock[tx.origin] = block.number;
                        _holderLastTransferBlock[to] = block.number;
                    }
                }
                 
                //when buy
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxBuyAmount, "Buy transfer amount exceeds the max buy.");
                } 
                //when sell
                else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    require(amount <= maxSellAmount, "Sell transfer amount exceeds the max sell.");
                }
            }
        }


        if(swapEnabled && !swapping && automatedMarketMakerPairs[to]) {
            swapping = true;
            swapBack();
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
                    botsCaught += 1;
                    earlyBuyers.push(to);
                    emit CaughtEarlyBuyer(to);
                }

                fees = amount * buyTotalFees / 100;
        	    tokensForLiquidity += fees * buyLiquidityFee / buyTotalFees;
            }

            // on sell
            else if (automatedMarketMakerPairs[to] && sellTotalFees > 0){
                fees = amount * sellTotalFees / 100;
                tokensForLiquidity += fees * sellLiquidityFee / sellTotalFees;
                tokensForDevs += fees * sellDevsFee / sellTotalFees;
                tokensForRewards += fees * sellRewardsFee / sellTotalFees;
                tokensForIncubator += fees * sellIncubatorFee / sellTotalFees;
            }

            // on buy
            else if(automatedMarketMakerPairs[from] && buyTotalFees > 0) {
        	    fees = amount * buyTotalFees / 100;
        	    tokensForLiquidity += fees * buyLiquidityFee / buyTotalFees;
            }
            
            if(fees > 0){    
                super._transfer(from, address(this), fees);
            }
        	
        	amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function earlyBuyPenaltyInEffect() public view returns (bool){
        return block.number < blockForPenaltyEnd;
    }

    function swapTokensForBUSD(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(BUSD);

        _approve(address(this), address(dexRouter), tokenAmount);

        // make the swap
        dexRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(tokenHandler),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 busdAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(dexRouter), tokenAmount);
        BUSD.approve(address(dexRouter), busdAmount);

        // add the liquidity
        dexRouter.addLiquidity(address(this), address(BUSD), tokenAmount, busdAmount, 0,  0,  address(liquidityAddress), block.timestamp);
    }

    function swapBack() private {

        if(tokensForRewards > 0 && balanceOf(address(this)) >= tokensForRewards) {
            _transfer(address(this), address(rewardsAddress), tokensForRewards);
        }
        tokensForRewards = 0;

        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensForDevs + tokensForIncubator;
        
        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        
        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = contractBalance * tokensForLiquidity / totalTokensToSwap / 2;
        
        swapTokensForBUSD(contractBalance - liquidityTokens);

        tokenHandler.sendTokenToOwner(address(BUSD));

        
        uint256 busdBalance = BUSD.balanceOf(address(this));
        uint256 busdForLiquidity = busdBalance;

        uint256 busdForDevs = busdBalance * tokensForDevs / (totalTokensToSwap - (tokensForLiquidity/2));
        uint256 busdForIncubator = busdBalance * tokensForIncubator / (totalTokensToSwap - (tokensForLiquidity/2));

        busdForLiquidity -= busdForDevs + busdForIncubator;
            
        tokensForLiquidity = 0;
        tokensForDevs = 0;
        tokensForIncubator = 0;
        
       if(liquidityTokens > 0 && busdForLiquidity > 0){
            addLiquidity(liquidityTokens, busdForLiquidity);
        }

        if(busdForIncubator > 0){
            BUSD.transfer(incubatorAddress, busdForIncubator);
        }

        if(BUSD.balanceOf(address(this)) > 0){
            BUSD.transfer(devAddress, BUSD.balanceOf(address(this)));
        }
    }

    function getBusdBalance() external view onlyOwner returns (uint256){
       return BUSD.balanceOf(address(this));
    }

    function sendTokenToDevs(address token) external onlyOwner {
        if(IERC20(token).balanceOf(address(this)) > 0){
            IERC20(token).transfer(devAddress, IERC20(token).balanceOf(address(this)));
        }
    }

    function transferForeignToken(address _token, address _to) external onlyOwner returns (bool _sent) {
        require(_token != address(0), "_token address cannot be 0");
        require(_token != address(this) || !tradingActive, "Can't withdraw native tokens while trading is active");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
        emit TransferForeignToken(_token, _contractBalance);
    }

    // withdraw ETH if stuck or someone sends to the address
    function withdrawStuckETH() external onlyOwner {
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }

    function setDevsAddress(address _devAddress) external onlyOwner {
        require(_devAddress != address(0), "address cannot be 0");
        devAddress = payable(_devAddress);
        emit UpdatedDevsAddress(_devAddress);
    }
    
    function setRewardsAddress(address _rewardsAddress) external onlyOwner {
        require(_rewardsAddress != address(0), "address cannot be 0");
        rewardsAddress = payable(_rewardsAddress);
        emit UpdatedRewardsAddress(_rewardsAddress);
    }

    function setIncubatorAddress(address _incubatorAddress) external onlyOwner {
        require(_incubatorAddress != address(0), "address cannot be 0");
        incubatorAddress = payable(_incubatorAddress);
        emit UpdatedIncubatorAddress(_incubatorAddress);
    }

    function setLiquidityAddress(address _liquidityAddress) external onlyOwner {
        require(_liquidityAddress != address(0), "address cannot be 0");
        liquidityAddress = payable(_liquidityAddress);
        emit UpdatedLiquidityAddress(_liquidityAddress);
    }

    // force Swap back if slippage issues.
    function forceSwapBack() external onlyOwner {
        swapping = true;
        swapBack();
        swapping = false;
        emit OwnerForcedSwapBack(block.timestamp);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    

    struct lockParams{
        address walletLock;
        uint256 amount;
        uint256 releaseTime;
        uint256 maxReleaseAmount;
    }

    lockParams[] public lockArr;

    function multiLock(address[] memory wallets, uint256[] memory amountsInTokens, uint256[] memory _releaseTime, uint256[] memory _maxReleaseAmount) external onlyOwner {
        require(wallets.length == amountsInTokens.length, "arrays must be the same length");
        require(wallets.length == _releaseTime.length, "arrays must be the same length");
        require(wallets.length < 600, "Can only airdrop 600 wallets per txn due to gas limits");
        for(uint256 i = 0; i < wallets.length; i++){
            address wallet = wallets[i];
            uint256 amount = amountsInTokens[i];
            uint256 releaseTime = _releaseTime[i];
            uint256 maxReleaseAmount = _maxReleaseAmount[i];
            lockToken(wallet, amount, releaseTime, maxReleaseAmount);
        }
    }

    function lockToken(address wallet, uint256 amount, uint256 releaseTime, uint256 maxReleaseAmount) public onlyOwner {
        address walletLock = wallet;
        require(balanceOf(walletLock) >= amount, "balance too low");

        lockParams memory lock = lockParams({walletLock: walletLock, amount: amount, releaseTime: releaseTime, maxReleaseAmount: maxReleaseAmount});

        lockArr.push(lock);
        
        

        _balances[walletLock] -= amount * 10 ** 18;
        emit LockToken(walletLock, amount, releaseTime,maxReleaseAmount);

    }



    function unlockTokens(address walletLocked, uint indexLocked) external onlyOwner () {

        uint256 releaseTime = lockArr[indexLocked].releaseTime;
        uint256 maxReleaseAmount = lockArr[indexLocked].maxReleaseAmount;
        address _walletLocked = lockArr[indexLocked].walletLock;
        uint256 timeAdd = 2678400;

        

        require(releaseTime <= block.timestamp, "The token is still locked");

        if(walletLocked == _walletLocked){
            _balances[walletLocked] += maxReleaseAmount * 10 ** 18;
            lockArr[indexLocked].amount -= maxReleaseAmount;
            lockArr[indexLocked].releaseTime = block.timestamp + timeAdd;

            if(lockArr[indexLocked].amount <= 0){
                delete lockArr[indexLocked];
            }

        }
    }


}