/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT

/*

 ██████╗██████╗ ██╗   ██╗██████╗ ████████╗ ██████╗ 
██╔════╝██╔══██╗╚██╗ ██╔╝██╔══██╗╚══██╔══╝██╔═══██╗
██║     ██████╔╝ ╚████╔╝ ██████╔╝   ██║   ██║   ██║
██║     ██╔══██╗  ╚██╔╝  ██╔═══╝    ██║   ██║   ██║
╚██████╗██║  ██║   ██║   ██║        ██║   ╚██████╔╝
 ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝        ╚═╝    ╚═════╝ 
                                                   
███████╗██╗  ██╗██████╗  ██████╗    ████████╗██████╗  █████╗ ██╗   ██╗███████╗██╗     ██╗     ███████╗██████╗ 
██╔════╝╚██╗██╔╝██╔══██╗██╔═══██╗   ╚══██╔══╝██╔══██╗██╔══██╗██║   ██║██╔════╝██║     ██║     ██╔════╝██╔══██╗
█████╗   ╚███╔╝ ██████╔╝██║   ██║█████╗██║   ██████╔╝███████║██║   ██║█████╗  ██║     ██║     █████╗  ██████╔╝
██╔══╝   ██╔██╗ ██╔═══╝ ██║   ██║╚════╝██║   ██╔══██╗██╔══██║╚██╗ ██╔╝██╔══╝  ██║     ██║     ██╔══╝  ██╔══██╗
███████╗██╔╝ ██╗██║     ╚██████╔╝      ██║   ██║  ██║██║  ██║ ╚████╔╝ ███████╗███████╗███████╗███████╗██║  ██║
╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝       ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝

Socials
Telegram:- https://t.me/CryptoExpoTraveller 
Primary Website:- https://cryptoexpotravel.com
Backup site for possible DNS issues: https://cryptoexpotravel.travel
Twitter:- https://twitter.com/cryptoexpotrav

Tokenomics
Max supply: 10,000,000,000 - 10 Million $EXPLORER TOKENS

Taxes:
Buy Tax: Initial and Cool off Buy Tax = 10% 
Sell Tax: Initial sell Tax = 25% for first 2 hours
Sell Tax: Cool off sell tax = 10%
Normal Tax split  for buy and Sell: 5% to Dev and Marketing wallet, 3% to Expotraveller, 2% to Liquidity

Initial Launch setup:
Max Buy initial setup: 1% of Max supply which is 100,000 $EXPLORER Tokens
Max Sell initial setup: 0.5% of Max supply which is 50,000 $EXPLORER Tokens
Max Wallet holding setup: 1% of Max supply which is 100,000 $EXPLORER Tokens

Snipe warning:
Deadblocks set to 5, bots get rekt for sniping with 99% tax and blocked.

LP locking:
1 year for 90% of Total circulation supply
10% tokens for platform development is locked for 90 days.

Trading will only start after dev enables the trading
1st lottery event will start as soon as $EXPLORER hits 1 Million Marketcap. See website for lottery winnder selection rules.

*/                                                                                                                                                                     


pragma solidity 0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
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

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

contract EXPLORER is ERC20, Ownable {

    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;
    uint256 public maxWalletAmount;

    IDexRouter public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool private swapping;
    uint256 public swapTokensAtAmount;

    address public DevMarketingAddress;
    address public ExpoTravellerAddress;

    uint256 public tradingActiveBlock = 0; // 0 means trading is not active
    uint256 public deadBlocks = 3;

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;

    uint256 public buyTotalFees;
    uint256 public buydevMarketingFee;
    uint256 public buyLiquidityFee;
    uint256 public buyTravelFee;

    uint256 public sellTotalFees;
    uint256 public selldevMarketingFee;
    uint256 public sellLiquidityFee;
    uint256 public sellTravelFee;

    uint256 public tokensFordevMarketing;
    uint256 public tokensForLiquidity;
    uint256 public tokensForTravel;

    /******************/

    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isExcludedMaxTransactionAmount;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) private _isSniper;
    
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event EnabledTrading(bool tradingActive, uint256 deadBlocks);
    event RemovedLimits();

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event UpdatedMaxBuyAmount(uint256 newAmount);

    event UpdatedMaxSellAmount(uint256 newAmount);

    event UpdatedMaxWalletAmount(uint256 newAmount);

    event UpdatedDevMarketingAddress(address indexed newWallet);

    event UpdatedExpoTravellerAddress(address indexed newWallet);

    event MaxTransactionExclusion(address _address, bool excluded);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    event TransferForeignToken(address token, uint256 amount);

    constructor() ERC20("EXPLORER", "EXPLORER") {

        address newOwner = msg.sender; // can leave alone if owner is deployer.

        IDexRouter _uniswapV2Router = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        _excludeFromMaxTransaction(address(_uniswapV2Router), true);
        uniswapV2Router = _uniswapV2Router;

        uniswapV2Pair = IDexFactory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        uint256 totalSupply = 1 * 1e9 * 1e18;

        maxBuyAmount = totalSupply *  10 / 1000;
        maxSellAmount = totalSupply *   5 / 1000;
        maxWalletAmount = totalSupply * 10 / 1000;
        swapTokensAtAmount = totalSupply * 25 / 100000; // 0.025% swap amount

        buydevMarketingFee = 5;
        buyTravelFee = 3;
        buyLiquidityFee = 2;
        buyTotalFees = buydevMarketingFee + buyLiquidityFee + buyTravelFee;

        selldevMarketingFee = 10;
        sellLiquidityFee = 3;
        sellTravelFee = 2;
        sellTotalFees = selldevMarketingFee + sellLiquidityFee + sellTravelFee;

        DevMarketingAddress = address(0x665df1d8A3e85191e5D0AA226219C943493A32C5);
        ExpoTravellerAddress = address(0x4E2Dd7aD7F8e0dd13421329e050cF8abcdeE62A5);

        _excludeFromMaxTransaction(newOwner, true);
        _excludeFromMaxTransaction(address(this), true);
        _excludeFromMaxTransaction(address(0xdead), true);

        excludeFromFees(newOwner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);


        _createInitialSupply(newOwner, totalSupply);
        transferOwnership(newOwner);
    }

    receive() external payable {}

    // once enabled, can never be turned off
    function enableTrading(bool _status, uint256 _deadBlocks) external onlyOwner {
        require(!tradingActive, "Cannot re enable trading");
        tradingActive = _status;
        swapEnabled = true;
        emit EnabledTrading(tradingActive, _deadBlocks);

        if (tradingActive && tradingActiveBlock == 0) {
            tradingActiveBlock = block.number;
            deadBlocks = _deadBlocks;
        } 
    }

    // remove limits after token is stable
    function removeLimits() external onlyOwner {
        limitsInEffect = false;
        emit RemovedLimits();
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

    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        require(newNum >= (totalSupply() * 3 / 1000)/1e18, "Cannot set max wallet amount lower than 0.3%");
        maxWalletAmount = newNum * (10**18);
        emit UpdatedMaxWalletAmount(maxWalletAmount);
    }

    // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        require(newAmount >= totalSupply() * 1 / 100000, "Swap amount cannot be lower than 0.001% total supply.");
        require(newAmount <= totalSupply() * 1 / 1000, "Swap amount cannot be higher than 0.1% total supply.");
        swapTokensAtAmount = newAmount;
    }

    function _excludeFromMaxTransaction(address updAds, bool isExcluded) private {
        _isExcludedMaxTransactionAmount[updAds] = isExcluded;
        emit MaxTransactionExclusion(updAds, isExcluded);
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) external onlyOwner {
        if(!isEx){
            require(updAds != uniswapV2Pair, "Cannot remove uniswap pair from max txn");
        }
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        _excludeFromMaxTransaction(pair, value);

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateBuyFees(uint256 _devMarketingFee, uint256 _liquidityFee, uint256 _TravelFee) external onlyOwner {
        buydevMarketingFee = _devMarketingFee;
        buyLiquidityFee = _liquidityFee;
        buyTravelFee = _TravelFee;
        buyTotalFees = buydevMarketingFee + buyLiquidityFee + buyTravelFee;
        require(buyTotalFees <= 15, "Must keep fees at 15% or less");
    }

    function updateSellFees(uint256 _devMarketingFee, uint256 _liquidityFee, uint256 _TravelFee) external onlyOwner {
        selldevMarketingFee = _devMarketingFee;
        sellLiquidityFee = _liquidityFee;
        sellTravelFee = _TravelFee;
        sellTotalFees = selldevMarketingFee + sellLiquidityFee + sellTravelFee;
        require(sellTotalFees <= 30, "Must keep fees at 20% or less");
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _transfer(address from, address to, uint256 amount) internal override {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "amount must be greater than 0");
        require(!_isSniper[from], "You are a sniper, get life!");
        require(!_isSniper[to], "You are a sniper, get life!");


        if(limitsInEffect){
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead)){
                if(!tradingActive){
                    require(_isExcludedMaxTransactionAmount[from] || _isExcludedMaxTransactionAmount[to], "Trading is not active.");
                    require(from == owner(), "Trading is enabled");
                }

                if (tradingActiveBlock > 0 && block.number < (tradingActiveBlock + deadBlocks) ) {
                   _isSniper[to] = true;
                }

                //when buy
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxBuyAmount, "Buy transfer amount exceeds the max buy.");
                    require(amount + balanceOf(to) <= maxWalletAmount, "Cannot Exceed max wallet");
                }
                //when sell
                else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    require(amount <= maxSellAmount, "Sell transfer amount exceeds the max sell.");
                }
                else if (!_isExcludedMaxTransactionAmount[to] && !_isExcludedMaxTransactionAmount[from]){
                    require(amount + balanceOf(to) <= maxWalletAmount, "Cannot Exceed max wallet");
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && swapEnabled && !swapping && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
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
        uint256 penaltyAmount = 0;
        // only take fees on Trades, not on wallet transfers

        if(takeFee){
            // bot/sniper penalty.  Tokens get transferred to devMarketing wallet and ETH to liquidity.
            if(tradingActiveBlock>0 && (tradingActiveBlock + 3) > block.number){
                penaltyAmount = amount * 99 / 100;
                super._transfer(from, DevMarketingAddress, penaltyAmount);
            }
            // on sell
            else if (automatedMarketMakerPairs[to] && sellTotalFees > 0){
                fees = amount * sellTotalFees /100;
                tokensForLiquidity += fees * sellLiquidityFee / sellTotalFees;
                tokensFordevMarketing += fees * selldevMarketingFee / sellTotalFees;
                tokensForTravel += fees * sellTravelFee / sellTotalFees;
            }
            // on buy
            else if(automatedMarketMakerPairs[from] && buyTotalFees > 0) {
                fees = amount * buyTotalFees / 100;
                tokensForLiquidity += fees * buyLiquidityFee / buyTotalFees;
                tokensFordevMarketing += fees * buydevMarketingFee / buyTotalFees;
                tokensForTravel += fees * buyTravelFee / buyTotalFees;
            }

            if(fees > 0){
                super._transfer(from, address(this), fees);
            }

            amount -= fees + penaltyAmount;
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(owner()),
            block.timestamp
        );
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForLiquidity + tokensFordevMarketing + tokensForTravel;

        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        if(contractBalance > swapTokensAtAmount * 10){
            contractBalance = swapTokensAtAmount * 10;
        }

        bool success;

        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = contractBalance * tokensForLiquidity / totalTokensToSwap / 2;

        swapTokensForEth(contractBalance - liquidityTokens);

        uint256 ethBalance = address(this).balance;
        uint256 ethForLiquidity = ethBalance;

        uint256 ethFordevMarketing = ethBalance * tokensFordevMarketing / (totalTokensToSwap - (tokensForLiquidity/2));
        uint256 ethForTravel = ethBalance * tokensForTravel / (totalTokensToSwap - (tokensForLiquidity/2));

        ethForLiquidity -= ethFordevMarketing + ethForTravel;

        tokensForLiquidity = 0;
        tokensFordevMarketing = 0;
        tokensForTravel = 0;

        if(liquidityTokens > 0 && ethForLiquidity > 0){
            addLiquidity(liquidityTokens, ethForLiquidity);
        }

        (success,) = address(ExpoTravellerAddress).call{value: ethForTravel}("");

        (success,) = address(DevMarketingAddress).call{value: address(this).balance}("");
    }

    function transferForeignToken(address _token, address _to) external onlyOwner returns (bool _sent) {
        require(_token != address(0), "_token address cannot be 0");
        require(_token != address(this), "Can't withdraw native tokens");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
        emit TransferForeignToken(_token, _contractBalance);
    }

    event sniperStatusChanged(address indexed sniper_address, bool status);

    function manageSniper(address sniper_address, bool status) external onlyOwner {
        require(_isSniper[sniper_address] != status, "Account is already in the said state");
        _isSniper[sniper_address] = status;
        emit sniperStatusChanged(sniper_address, status);
    }

    function isSniper(address account) public view returns (bool) {
        return _isSniper[account];
    }

    // withdraw ETH if stuck or someone sends to the address
    function withdrawStuckBNB() external onlyOwner {
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }

    function setDevMarketingAddress(address _DevMarketingAddress) external onlyOwner {
        require(_DevMarketingAddress != address(0), "_DevMarketingAddress address cannot be 0");
        DevMarketingAddress = payable(_DevMarketingAddress);
        emit UpdatedDevMarketingAddress(_DevMarketingAddress);
    }

    function setExpoTravellerAddress(address _TravellerAddress) external onlyOwner {
        require(_TravellerAddress != address(0), "_ExpoTravellerAddress address cannot be 0");
        ExpoTravellerAddress = payable(_TravellerAddress);
        emit UpdatedExpoTravellerAddress(_TravellerAddress);
    }
}