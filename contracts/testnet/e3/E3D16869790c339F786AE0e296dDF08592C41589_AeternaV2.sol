/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.13;

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

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IDexFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

contract AeternaV2 is Context, IERC20, Ownable {
    
    string constant private _name = "AeternaV2";
    string constant private _symbol = "AeternaV2";
    uint8 constant private _decimals = 9;

    address public constant  deadAddress = 0x000000000000000000000000000000000000dEaD;
    address payable public autoLiquidityReceiver = payable(0xDe7796cc7F65F98a053Dba0215a75a7449b34e08); // LP Address
    address payable public marketingFeeReceiver = payable(0xd9Cb687EccC712A045eE3Af1542A4b057d8611C1); // Marketing Address
    address payable public devFeeReceiver = payable(0xF2e913F5BFa727a745d88903FFA9949990A5Af8c); // Development Address
    address payable public lottetyFeeReceiver = payable(0xff8cC92700744ebF425fac18d546d020bd9C8459); // Lottery Address
    
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;
    
    mapping (address => bool) public isBot;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isWalletLimitExempt;

    bool public txLimitsEnabled = true;
    bool public cooldownEnabled = true;
    bool public launchRestrictionsExpired = false;

    uint8 public cooldownTimerInterval = 1 minutes;
    mapping (address => uint) public cooldownTimer;

    uint256 public buyTax = 200;
    uint256 public sellTax = 300;
    uint256 public transferTax = 100;

    uint256 public lpShare = 20;
    uint256 public marketingShare = 40;
    uint256 public devShare = 20;
    uint256 public lotteryShare = 10;

    uint256 constant private _totalSupply = 20 * 10**6 * 10**_decimals;
    uint256 public swapThreshold = 100 * 10**3 * 10**_decimals; 

    uint256 public maxBuy = 1 * 10**6 * 10**_decimals;
    uint256 public maxSell = 1 * 10**6 * 10**_decimals;
    uint256 public walletMax = 1 * 10**6 * 10**_decimals;

    //Launch Settings
    uint256 public maxBuyStage2 = 10 * 10**6 * 10**_decimals;
    uint256 public maxSellStage2 = 3 * 10**6 * 10**_decimals;
    uint256 public walletMaxStage2 = 10 * 10**6 * 10**_decimals;
    
    uint256 public maxBuyStage3 = 20 * 10**6 * 10**_decimals;
    uint256 public maxSellStage3 = 5 * 10**6 * 10**_decimals;
    uint256 public walletMaxStage3 = 20 * 10**6 * 10**_decimals;

    IDexRouter public dexRouter;
    address public lpPair;
    
    bool private isInSwap;
    bool public swapEnabled = true;
    bool public swapByLimitOnly = false;
    bool public launched = false;
    bool public checkWalletLimit = true;

    uint256 public launchBlock = 0;

    event RouterVersionChanged(address newRouterAddress);
    event BotStatusUpdated(address account, bool isBot_);
    event SwapTokensForBNB(uint256 amountIn, address[] path);
    event MaxTxAmountChanged(uint256 maxBuy_, uint256 maxSell_);
    event MarketPairUpdated(address account, bool isMarketPair_);
    event TaxesChanged(uint256 buyTax_, uint256 sellTax_, uint256 transferTax_);
    event SwapSettingsUpdated(bool swapEnabled_, uint256 swapThreshold_, bool swapByLimitOnly_);
    event AccountWhitelisted(address account, bool feeExempt, bool walletLimitExempt, bool txLimitExempt);
    event TaxDistributionChanged(uint256 lpShare_, uint256 devShare_, uint256 lotteryShare_, uint256 marketingShare_);

    modifier lockTheSwap {
        isInSwap = true;
        _;
        isInSwap = false;
    }
    
    constructor () {
        
        dexRouter = IDexRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
        lpPair = IDexFactory(dexRouter.factory()).createPair(address(this), dexRouter.WETH());

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;

        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(lpPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        
        isMarketPair[address(lpPair)] = true;

        allowances[address(this)][address(dexRouter)] = _totalSupply;
        balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

     //to receive BNB from dexRouter when swapping
    receive() external payable {}

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    
    function circulatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(deadAddress);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return allowances[owner_][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner_, address spender, uint256 amount) private {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowances[sender][_msgSender()] - amount);
        return true;
    }
    
    function updateRouter(address newRouterAddress) public onlyOwner returns(address newPairAddress) {
        IDexRouter dexRouter_ = IDexRouter(newRouterAddress); 
        newPairAddress = IDexFactory(dexRouter_.factory()).getPair(address(this), dexRouter_.WETH());

        if(newPairAddress == address(0)) { //Create If Doesnt exist
            newPairAddress = IDexFactory(dexRouter_.factory()).
                                createPair(address(this), dexRouter_.WETH());
        }

        lpPair = newPairAddress; //Set new pair address
        dexRouter = dexRouter_; //Set new router address

        isWalletLimitExempt[address(lpPair)] = true;
        isMarketPair[address(lpPair)] = true;
        emit RouterVersionChanged(newRouterAddress);
    }

    function launch(uint256 maxBuy_, uint256 maxSell_, uint256 walletMax_, 
        uint256 maxBuyStage2_, uint256 maxSellStage2_, uint256 walletMaxStage2_, 
        uint256 maxBuyStage3_, uint256 maxSellStage3_, uint256 walletMaxStage3_) 
    public onlyOwner {
        launched = true;
        launchBlock = block.number;

        maxBuy = maxBuy_;
        maxSell = maxSell_;
        walletMax = walletMax_;

        maxBuyStage2 = maxBuyStage2_;
        maxSellStage2 = maxSellStage2_;
        walletMaxStage2 = walletMaxStage2_;

        maxBuyStage3 = maxBuyStage3_;
        maxSellStage3 = maxSellStage3_;
        walletMaxStage3 = walletMaxStage3_;
    }

    function changeLaunchStatus(bool launched_) public onlyOwner {
        launched = launched_;
    }

    function changeBotStatus(address account, bool isBot_) public onlyOwner {
        isBot[account] = isBot_;
        emit BotStatusUpdated(account, isBot_);
    }

    function changeMarketPairStatus(address account, bool isMarketPair_) public onlyOwner {
        isMarketPair[account] = isMarketPair_;
        emit MarketPairUpdated(account, isMarketPair_);
    }
    
    function setTaxes(uint256 buyTax_, uint256 sellTax_, uint256 transferTax_) external onlyOwner {
        require(buyTax_ <= 300, "Cannot exceed 30%");
        require(sellTax_ <= 300, "Cannot exceed 30%");
        require(transferTax_ <= 300, "Cannot exceed 30%");
        buyTax = buyTax_;
        sellTax = sellTax_;
        transferTax = transferTax_;
        emit TaxesChanged(buyTax_, sellTax_, transferTax_);
    }

    function changeTaxDistribution(uint256 lpShare_, uint256 devShare_, uint256 lotteryShare_, uint256 marketingShare_) external onlyOwner {
        lpShare = lpShare_;
        devShare = devShare_;
        lotteryShare = lotteryShare_;
        marketingShare = marketingShare_;
        emit TaxDistributionChanged(lpShare_, devShare_, lotteryShare_, marketingShare_);
    }

    function changeTxLimits(uint256 maxBuy_, uint256 maxSell_, bool txLimitsEnabled_) external onlyOwner {
        maxBuy = maxBuy_;
        maxSell = maxSell_;
        txLimitsEnabled = txLimitsEnabled_;
        emit MaxTxAmountChanged(maxBuy_, maxSell_);
    }

    function changeCooldownSettings(bool cooldownEnabled_, uint8 cooldownTimerInterval_) external onlyOwner {
        require(cooldownTimerInterval_ <= 10 minutes, "Exceeds the limit");
        cooldownEnabled = cooldownEnabled_;
        cooldownTimerInterval = cooldownTimerInterval_;
    }

    function changeWalletLimits(bool checkWalletLimit_, uint256 walletMax_) external onlyOwner {
        checkWalletLimit = checkWalletLimit_;
        walletMax  = walletMax_;
    }

    function whitelistAccounts(address[] memory wallets, bool feeExempt, bool walletLimitExempt, bool txLimitExempt) public onlyOwner {
        for(uint256 i = 0; i < wallets.length; i++){
            isExcludedFromFee[wallets[i]] = feeExempt;
            isWalletLimitExempt[wallets[i]] = walletLimitExempt;
            isTxLimitExempt[wallets[i]] = txLimitExempt;
            emit AccountWhitelisted(wallets[i], feeExempt, walletLimitExempt, txLimitExempt);
        }
    }

    function changeSwapSettings(bool swapEnabled_, uint256 swapThreshold_, bool swapByLimitOnly_) public onlyOwner {
        swapEnabled = swapEnabled_;
        swapThreshold = swapThreshold_;
        swapByLimitOnly = swapByLimitOnly_;
        emit SwapSettingsUpdated(swapEnabled_, swapThreshold_, swapByLimitOnly_);
    }

    function changeMarketingFeeReceiver(address marketingFeeReceiver_) external onlyOwner {
        require(marketingFeeReceiver_ != address(0), "New address cannot be zero address");
        marketingFeeReceiver = payable(marketingFeeReceiver_);
    }

    function changeDevFeeReceiver(address devFeeReceiver_) external onlyOwner {
        require(devFeeReceiver_ != address(0), "New address cannot be zero address");
        devFeeReceiver = payable(devFeeReceiver_);
    }

    function changeLotteryFeeReceiver(address lottetyFeeReceiver_) external onlyOwner {
        require(lottetyFeeReceiver_ != address(0), "New address cannot be zero address");
        lottetyFeeReceiver = payable(lottetyFeeReceiver_);
    }

    function changeAutoLiquidityReceiver(address autoLiquidityReceiver_) external onlyOwner {
        require(autoLiquidityReceiver_ != address(0), "New address cannot be zero address");
        autoLiquidityReceiver = payable(autoLiquidityReceiver_);
    }

    function transferBNB(address payable recipient, uint256 amount) private {
        bool success;
        (success,) = address(recipient).call{value: amount}("");
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        if(isInSwap) { 
            return _basicTransfer(sender, recipient, amount); 
        } else {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");
            require(!isBot[sender] && !isBot[recipient], "To/from address is blacklisted!");

            if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
                require(launched, "Not Launched.");

                if(txLimitsEnabled) {
                    if(!launchRestrictionsExpired) {
                        updateLaunchRestrictions();
                    }
                    if(isMarketPair[recipient]) {
                        require(amount <= maxSell, "Transfer amount exceeds the max sell.");
                    } else {
                        require(amount <= maxBuy, "Transfer amount exceeds the max buy.");
                    }
                }
                
                if(cooldownEnabled) {
                    if(isMarketPair[recipient]) {
                        require(cooldownTimer[sender] < block.timestamp, "Please wait for cooldown between trades");
                    }
                    cooldownTimer[sender] = block.timestamp + cooldownTimerInterval;
                }
            }

            bool isTaxFree = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]);

            if (!isTaxFree && !isMarketPair[sender] && swapEnabled && !isInSwap) 
            {
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinimumTokenBalance = contractTokenBalance >= swapThreshold;
                if(overMinimumTokenBalance) {
                    if(swapByLimitOnly)
                        contractTokenBalance = swapThreshold;
                    swapAndLiquify(contractTokenBalance);    
                }
            }

            balances[sender] = balances[sender] - amount;

            uint256 finalAmount = isTaxFree ? amount : takeFee(sender, recipient, amount);

            if(checkWalletLimit && !isWalletLimitExempt[recipient])
                require((balanceOf(recipient) + finalAmount) <= walletMax);

            balances[recipient] = balances[recipient] + finalAmount;

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function updateLaunchRestrictions() private {
        if((block.number - launchBlock) > 1 minutes && (block.number - launchBlock) < 2 minutes) {
            maxBuy = maxBuyStage2;
            maxSell = maxSellStage2;
            walletMax = walletMaxStage2;
        } else if((block.number - launchBlock) > 2 minutes) {
            maxBuy = maxBuyStage3;
            maxSell = maxSellStage3;
            walletMax = walletMaxStage3;
            launchRestrictionsExpired = true;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        balances[sender] = balances[sender] - amount;
        balances[recipient] = balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        uint256 totalShares = lpShare + marketingShare + devShare + lotteryShare;
        uint256 tokensForLP = ((tAmount * lpShare) / totalShares) / 2;
        uint256 tokensForSwap = tAmount - tokensForLP;

        swapTokensForEth(tokensForSwap);
        
        uint256 amountReceived = address(this).balance;

        uint256 bnbShares = totalShares - (lpShare / 2);
        
        uint256 bnbForLiquidity = ((amountReceived * lpShare) / bnbShares) / 2;
        uint256 bnbForDev = (amountReceived * devShare) / bnbShares;
        uint256 bnbForLottery = (amountReceived * lotteryShare) / bnbShares;
        uint256 bnbForMarketing = amountReceived - bnbForLiquidity - bnbForDev - bnbForLottery;

        if(bnbForMarketing > 0) {
            transferBNB(marketingFeeReceiver, bnbForMarketing);
        }

        if(bnbForDev > 0) {
            transferBNB(devFeeReceiver, bnbForDev);
        }

        if(bnbForLottery > 0) {
            transferBNB(lottetyFeeReceiver, bnbForLottery);
        }

        if(bnbForLiquidity > 0 && tokensForLP > 0) {
            addLiquidity(tokensForLP, bnbForLiquidity);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForBNB(tokenAmount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(dexRouter), tokenAmount);

        // add the liquidity
        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            autoLiquidityReceiver,
            block.timestamp
        );
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = (amount * transferTax) / 1000;   

        if(isMarketPair[recipient]) {
            feeAmount = (amount * sellTax) / 1000; 
        } else if(isMarketPair[sender]) {
            feeAmount = (amount * buyTax) / 1000; 
        }
        
        if(feeAmount > 0) {
            balances[address(this)] = balances[address(this)] + feeAmount;
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount - feeAmount;
    }
    
}