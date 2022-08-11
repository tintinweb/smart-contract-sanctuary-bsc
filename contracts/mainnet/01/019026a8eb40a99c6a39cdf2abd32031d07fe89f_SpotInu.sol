/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.15;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
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
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }
    function name() public view virtual override returns (string memory) {return _name;}
    function symbol() public view virtual override returns (string memory) {return _symbol;}
    function decimals() public view virtual override returns (uint8) {return _decimals;}
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()]-amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]+addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]-subtractedValue);
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender]-amount;
        _balances[recipient] = _balances[recipient]+amount;
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply+amount;
        _balances[account] = _balances[account]+amount;
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account]-amount;
        _totalSupply = _totalSupply-amount;
        emit Transfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
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


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IUniswapV2Pair {
    function factory() external view returns (address);
}

interface IspotDividendTracker { 
    function excludeFromDividends (address) external;
    function setWhiteListAMM (address, bool) external;
    function owner() external view returns (address);
    function updateDividendMinimum (uint256) external;
    function updateDividendUniswapV2Router (address) external;
    function includeInDividends (address) external;
    function updateClaimWait (uint256) external;
    function setIgnoreToken (address, bool) external;
    function ammIsWhiteListed (address) external view returns (bool);
    function userCurrentRewardToken (address) external view returns (address);
    function userHasCustomRewardToken (address) external view returns (bool);
    function rewardTokenSelectionCount (address) external view returns (uint256);
    function getLastProcessedIndex() external view returns(uint256);
    function getNumberOfTokenHolders() external view returns(uint256);
    function minimumTokenBalanceForDividends() external view returns (uint256);
    function claimWait() external view returns(uint256);
    function totalDividendsDistributed() external view returns (uint256);
    function withdrawableDividendOf(address) external view returns(uint256);
    function balanceOf(address) external view returns (uint256);
    function getAccount(address) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256);
    function getAccountAtIndex(uint256) external view returns (address, int256, int256, uint256, uint256, uint256, uint256, uint256);
    function getRawETHDividends(address) external view returns (uint256);
    function isIgnoredToken(address) external view returns (bool);
    function setRewardToken(address, address, address) external;
    function unsetRewardToken(address) external;
    function processAccount(address payable, bool) external returns (bool);
    function process(uint256) external returns (uint256, uint256, uint256);
    function setBalance(address payable, uint256) external;
    function transferOwnership(address) external;
}

contract SpotInu is ERC20, Ownable {
    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool private swapping;

    IspotDividendTracker public dividendTracker;
    
    mapping(address => bool) public _isAllowedDuringDisabled;
    mapping(address => bool) public _isIgnoredAddress;
    mapping(address => bool) private excludedFromLimits;

    address public liquidityWallet;
    uint256 public swapTokensAtAmount = 100000 * (10**9);
    
    // fees
    uint256 public RewardsFee = 4;
    uint256 public liqFee = 2; // This fee must be a TOTAL of LP
    uint256 public totalFees = RewardsFee+liqFee;
    uint256 public maxWalletBalance;
    
    // Disable trading initially
    bool isTradingEnabled = false;
    bool isSwapAndLiquifyEnabled = false;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event FeesUpdated(uint256 indexed newRewardsFee, uint256 indexed newLiquidityFee);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor(address payable dividendaddress) ERC20("Spot Inu", "SPOT", 9) {

        IspotDividendTracker _dividendTracker = IspotDividendTracker(payable(dividendaddress));
        dividendTracker = _dividendTracker;
        liquidityWallet = owner();
        
       IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        excludeFromFees(liquidityWallet, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(dividendTracker), true);

        excludedFromLimits[msg.sender] = true;
        excludedFromLimits[address(0xdead)] = true;
        excludedFromLimits[address(this)] = true;
        excludedFromLimits[liquidityWallet] = true;
        
        _isAllowedDuringDisabled[address(this)] = true;
        _isAllowedDuringDisabled[owner()] = true;
        _isAllowedDuringDisabled[liquidityWallet] = true;
        _mint(owner(), 101010101010 * (10**9));
    }

    receive() external payable {}

    function setWhiteListAMM(address ammAddress, bool isWhiteListed) external onlyOwner {
      require(isContract(ammAddress), "SPOT: setWhiteListAMM:: AMM is a wallet, not a contract");
      dividendTracker.setWhiteListAMM(ammAddress, isWhiteListed);
    }
    
    // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner returns (bool){
        require(newAmount < totalSupply(), "Swap amount cannot be higher than total supply.");
        swapTokensAtAmount = newAmount;
        return true;
    }
    
    
    // migration feature (DO NOT CHANGE WITHOUT CONSULTATION)
    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "SPOT: The dividend tracker already has that address");
        IspotDividendTracker newDividendTracker = IspotDividendTracker(payable(newAddress));
        require(newDividendTracker.owner() == address(this), "SPOT: The new dividend tracker must be owned by the SPOT token contract");
        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(owner());
        newDividendTracker.excludeFromDividends(address(uniswapV2Router));
        emit UpdateDividendTracker(newAddress, address(dividendTracker));
        dividendTracker = newDividendTracker;
    }
    
    // updates the minimum amount of tokens people must hold in order to get dividends
    function updateDividendTokensMinimum(uint256 minimumToEarnDivs) external onlyOwner {
        dividendTracker.updateDividendMinimum(minimumToEarnDivs);
    }

    // updates the default router for selling tokens
    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "SPOT: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }
    
    // updates the default router for buying tokens from dividend tracker
    function updateDividendUniswapV2Router(address newAddress) external onlyOwner {
        dividendTracker.updateDividendUniswapV2Router(newAddress);
    }

    // excludes wallets from max txn and fees.
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    // allows multiple exclusions at once
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }
    
    function addToWhitelist(address wallet, bool status) external onlyOwner {
        _isAllowedDuringDisabled[wallet] = status;
    }
    
    function setIsBot(address wallet, bool status) external onlyOwner {
        _isIgnoredAddress[wallet] = status;
    }

    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    function includeInDividends(address account) external onlyOwner {
        dividendTracker.includeInDividends(account);
    }
    
    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != address(0xdead), "SPOT: The pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
    
    // sets the wallet that receives LP tokens to lock
    function updateLiquidityWallet(address newLiquidityWallet) external onlyOwner {
        require(newLiquidityWallet != liquidityWallet, "SPOT: The liquidity wallet is already this address");
        excludeFromFees(newLiquidityWallet, true);
        emit LiquidityWalletUpdated(newLiquidityWallet, liquidityWallet);
        liquidityWallet = newLiquidityWallet;
    }
    
    
    // rebalance fees as needed
    function updateFees(uint256 RewardPerc, uint256 liquidityPerc) external onlyOwner {
        require (liquidityPerc <= 10, "Liquidity Perc must be less than 10.");
        require (RewardPerc <= 10, "Rewards Perc must be less than 10.");
        emit FeesUpdated(RewardPerc, liquidityPerc);
        RewardsFee = RewardPerc;
        liqFee = liquidityPerc;
        
        totalFees = RewardsFee+liqFee;
        
    }

    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "SPOT: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "SPOT: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner returns (bool){
        dividendTracker.updateClaimWait(claimWait);
        return true;
    }
    
    function setIgnoreToken(address tokenAddress, bool isIgnored) external onlyOwner returns (bool){
        dividendTracker.setIgnoreToken(tokenAddress, isIgnored);
        return true;
    }
    
    // determines if an AMM can be used for rewards
    function isAMMWhitelisted(address ammAddress) public view returns (bool){
        return dividendTracker.ammIsWhiteListed(ammAddress);
    }
    
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function getUserCurrentRewardToken(address holder) public view returns (address){
        return dividendTracker.userCurrentRewardToken(holder);
    }
    
    function getUserHasCustomRewardToken(address holder) public view returns (bool){
        return dividendTracker.userHasCustomRewardToken(holder);
    }
    
    function getRewardTokenSelectionCount(address token) public view returns (uint256){
        return dividendTracker.rewardTokenSelectionCount(token);
    }
    
    function getLastProcessedIndex() external view returns(uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
    
     function getDividendTokensMinimum() external view returns (uint256) {
        return dividendTracker.minimumTokenBalanceForDividends();
    }
    
    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }
    
    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccountAtIndex(index);
    }
    
    function getRawETHDividends(address holder) public view returns (uint256){
        return dividendTracker.getRawETHDividends(holder);
    }
    
    function isIgnoredToken(address tokenAddress) public view returns (bool){
        return dividendTracker.isIgnoredToken(tokenAddress);
    }
    
    function setRewardToken(address rewardTokenAddress) public returns (bool) {
        require(isContract(rewardTokenAddress), "SPOT: setRewardToken:: Address is a wallet, not a contract.");
        require(rewardTokenAddress != address(this), "SPOT: setRewardToken:: Cannot set reward token as this token due to Router limitations.");
        require(!isIgnoredToken(rewardTokenAddress), "SPOT: setRewardToken:: Reward Token is ignored from being used as rewards.");
        dividendTracker.setRewardToken(msg.sender, rewardTokenAddress, address(uniswapV2Router));
        return true;
    }
    
    function setRewardTokenWithCustomAMM(address rewardTokenAddress, address ammContractAddress) public returns (bool) {
        require(isContract(rewardTokenAddress), "SPOT: setRewardToken:: Address is a wallet, not a contract.");
        require(ammContractAddress != address(uniswapV2Router), "SPOT: setRewardToken:: Use setRewardToken to use default Router");
        require(rewardTokenAddress != address(this), "SPOT: setRewardToken:: Cannot set reward token as this token due to Router limitations.");
        require(!isIgnoredToken(rewardTokenAddress), "SPOT: setRewardToken:: Reward Token is ignored from being used as rewards.");
        require(isAMMWhitelisted(ammContractAddress) == true, "SPOT: setRewardToken:: AMM is not whitelisted!");
        dividendTracker.setRewardToken(msg.sender, rewardTokenAddress, ammContractAddress);
        return true;
    }
    
    function unsetRewardToken() public returns (bool){
        dividendTracker.unsetRewardToken(msg.sender);
        return true;
    }
    
    function activateContract() external onlyOwner {
        _setAutomatedMarketMakerPair(uniswapV2Pair, true);
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(liquidityWallet);
        dividendTracker.excludeFromDividends(address(0xdead)); 
        dividendTracker.excludeFromDividends(address(uniswapV2Router));
        maxWalletBalance = totalSupply() * 30 / 1000;
        isTradingEnabled = true;
        isSwapAndLiquifyEnabled = true;
    }

    function SetExcludedAccountFromLimits(address account, bool exclude) external onlyOwner{
        excludedFromLimits[account]=exclude;
    }

    function setMaxWalletPercent(uint256 percent) external onlyOwner {
        require(percent >= 10, "min 1%");
        require(percent <= 1000, "max 100%");
        maxWalletBalance = totalSupply() * percent / 1000;
    }

    function setSwapAndLiquifyEnabled(bool onOff) external onlyOwner {
        isSwapAndLiquifyEnabled = onOff;
    }
    
    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }
    
    function processDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }
    
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "SPOT: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }
        emit SetAutomatedMarketMakerPair(pair, value);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isIgnoredAddress[to] || !_isIgnoredAddress[from], "SPOT: To/from address is ignored");
        bool excludedAccount = excludedFromLimits[from] || excludedFromLimits[to];
        if(!isTradingEnabled) {
            require(_isAllowedDuringDisabled[to] || _isAllowedDuringDisabled[from], "Trading is currently disabled");
        }
        if(automatedMarketMakerPairs[to] && !isTradingEnabled && _isAllowedDuringDisabled[from]) {
            require((from == owner() || to == owner()) || _isAllowedDuringDisabled[from], "Only dev can trade against UNISWAP");
        }
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if (automatedMarketMakerPairs[from] && !excludedAccount) {
            uint256 contractBalanceRecepient = balanceOf(to);
            require(contractBalanceRecepient + amount <= maxWalletBalance, "Exceeds maximum wallet token amount.");
        } 

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(
            canSwap &&
            !swapping &&
            isSwapAndLiquifyEnabled &&
            !automatedMarketMakerPairs[from] &&
            from != liquidityWallet &&
            to != liquidityWallet &&
            !_isExcludedFromFees[to] &&
            !_isExcludedFromFees[from] &&
            from != address(this) &&
            from != address(dividendTracker)
        ) {
            swapping = true;
            uint256 swapTokens = balanceOf(address(this));
            swapAndLiquify(swapTokens);
            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to] || from == address(this)) {
            takeFee = false;
        }
        if(takeFee) {
            uint256 fees = amount*totalFees/100;
            amount = amount-fees;
            super._transfer(from, address(this), fees);
        }
        super._transfer(from, to, amount);
        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}
        if(!swapping) {
            uint256 gas = gasForProcessing;
            try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            } 
            catch {
            }
        }
    }

    function swapAndLiquify(uint256 tokens) private {
            if(liqFee > 0){ 
                uint256 tokenForLiquidity;
                if(liqFee > 0){
                    tokenForLiquidity = (tokens*liqFee)/totalFees;
                } else {
                    tokenForLiquidity = 0;
                }
                uint256 tokensForDividends = tokens-tokenForLiquidity;
                uint256 LiqHalf = tokenForLiquidity/2;
                uint256 swapToken = tokensForDividends+LiqHalf;
                uint256 otherHalf = tokenForLiquidity-LiqHalf;
                uint256 initialBalance = address(this).balance;
                swapTokensForEth(swapToken); 
                uint256 newETH = (address(this).balance-initialBalance);
                if(tokenForLiquidity>0){
                    uint liqETH = (newETH*LiqHalf)/swapToken;
                    addLiquidity(LiqHalf, liqETH);
                }
                uint256 balanceForDividends = address(this).balance-initialBalance;
                (bool success,) = address(dividendTracker).call{value: balanceForDividends}("");
            if(success) {
                    emit SendDividends(tokensForDividends, balanceForDividends);
                }
            emit SwapAndLiquify(LiqHalf, newETH, otherHalf);
        }
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
            liquidityWallet,
            block.timestamp
        );
    }

	function recoverContractETH() public onlyOwner{
        		uint256 ethAmount = address(this).balance;
        		if(ethAmount > 0){
                payable(msg.sender).transfer(ethAmount);
        		}
    	}
}