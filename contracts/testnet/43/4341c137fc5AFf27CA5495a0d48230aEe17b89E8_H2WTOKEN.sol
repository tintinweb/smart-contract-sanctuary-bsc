// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.0;

import "./Interface.sol";

contract H2WTOKEN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    address payable public marketingAddress = payable(0xDce443131b43F65B6e716206BB4316380e006d80); // Marketing Address
    address payable public burnAddress = payable(0x000000000000000000000000000000000000dEaD); // Reward Address. zero address so will burn.
    address payable public liquidityAddress = payable(0xDce443131b43F65B6e716206BB4316380e006d80); // Liquidity Address
    address payable public devAddress = payable(0xDce443131b43F65B6e716206BB4316380e006d80); // dev address
    address payable public potAddress = payable(0xDce443131b43F65B6e716206BB4316380e006d80); // dev address
    address payable public partnerAddress = payable(0xDce443131b43F65B6e716206BB4316380e006d80); // dev address

    IERC20 public REWARD;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    mapping(address => bool) isDividendExempt;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1 * 1e12 * 1e18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "Hold2Win";
    string private constant _symbol = "H2W";
    uint8 private constant _decimals = 18;

    uint256 private constant BUY = 1;
    uint256 private constant SELL = 2;
    uint256 private constant TRANSFER = 3;
    uint256 private buyOrSellSwitch;

    uint256 private _taxFee;
    uint256 private _previousTaxFee = _taxFee;

    uint256 private _liquidityFee;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _buyTaxFee = 1;
    uint256 public _buyLiquidityFee = 2;
    uint256 public _buyMarketingFee = 4;
    uint256 public _buyDevFee = 3;
    uint256 public _buyPotFee = 5;
    uint256 public _buyPartnerFee = 2;

    uint256 public _sellTaxFee = 1;
    uint256 public _sellLiquidityFee = 2;
    uint256 public _sellMarketingFee = 4;
    uint256 public _sellDevFee = 3;
    uint256 public _sellPotFee = 7;
    uint256 public _sellBurnFee = 2;
    uint256 public _sellPartnerFee = 2;

    bool public tradingActive = false;

    mapping(address => bool) public _isExcludedMaxTransactionAmount;

    uint256 public _liquidityTokensToSwap;
    uint256 public _burnTokens;
    uint256 public _marketingTokensToSwap;
    uint256 public _devTokensToSwap;
    uint256 public _potTokensToSwap;
    uint256 public _partnerTokensToSwap;

    IPinkAntiBot public pinkAntiBot;
    bool public antibotEnabled = false;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private _isSniper;

    uint256 public minimumTokensBeforeSwap;
    uint256 public maxTransactionAmount;
    uint256 public maxWallet;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 500000;

    IReferral public referralContract;
    uint256 public referralCommissionPercentage = 5;
    mapping(address => address) public referrers;

    mapping(address => uint256) public referralsCount;

    mapping(address => uint256) public totalReferralCommissions;

    mapping(address => uint256) public referralCommissionAmount;

    event RewardLiquidityProviders(uint256 tokenAmount);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

    event SwapETHForTokens(uint256 amountIn, address[] path);

    event SwapTokensForETH(uint256 amountIn, address[] path);

    event ExcludedMaxTransactionAmount(address indexed account, bool isExcluded);

    event ReferralCommissionRecorded(address indexed _referrer, uint256 _commission);
    event ReferralRecorded(address indexed _user, address indexed _referrer);
    event ClaimReferralCommission(address indexed referrer, uint256 amount);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(address pinkAntiBot_, address _rewardToken) {
        address newOwner = msg.sender; // update if auto-deploying to a different wallet

        maxTransactionAmount = (_tTotal * 100) / 10000; // 1% max txn
        minimumTokensBeforeSwap = (_tTotal * 5) / 10000; // 0.05%
        maxWallet = (_tTotal * 100) / 10000; // 1%

        REWARD = IERC20(_rewardToken);

        _rOwned[newOwner] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            // ROPSTEN or HARDHAT
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        dividendDistributor = new DividendDistributor(address(uniswapV2Router), address(REWARD));

        pinkAntiBot = IPinkAntiBot(pinkAntiBot_);
        pinkAntiBot.setTokenOwner(_msgSender());

        isDividendExempt[uniswapV2Pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        excludeFromReward(DEAD);

        _isExcludedFromFee[newOwner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[liquidityAddress] = true;

        excludeFromMaxTransaction(newOwner, true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        excludeFromMaxTransaction(DEAD, true);

        emit Transfer(address(0), newOwner, _tTotal);
    }

    // tracker dashboard functions
    function getHolderDetails(address holder)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendDistributor.getHolderDetails(holder);
    }

    function getLastProcessedIndex() public view returns (uint256) {
        return dividendDistributor.getLastProcessedIndex();
    }

    function getNumberOfTokenHolders() public view returns (uint256) {
        return dividendDistributor.getNumberOfTokenHolders();
    }

    function totalDistributedRewards() public view returns (uint256) {
        return dividendDistributor.totalDistributedRewards();
    }

    function getMinBalanceToGetReward() public view returns (uint256) {
        return dividendDistributor.minBalanceToGetReward();
    }

    function setMinBalanceToGetReward(uint256 _minBalanceToGetReward) external onlyOwner {
        dividendDistributor.setMinBalanceToGetReward(_minBalanceToGetReward);
    }

    // manual claim for the greedy humans
    function ___claimRewards(bool tryAll) public {
        dividendDistributor.claimDividend();
        if (tryAll) {
            try dividendDistributor.process(distributorGas) {} catch {}
        }
    }

    // manually clear the queue
    function claimProcess() public {
        try dividendDistributor.process(distributorGas) {} catch {}
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != address(uniswapV2Router));
        isDividendExempt[holder] = exempt;
        if (exempt) {
            dividendDistributor.setShare(holder, 0);
        } else {
            dividendDistributor.setShare(holder, balanceOf(holder));
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        dividendDistributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    // referral contract functions

    function setReferralContract(address _referralContract) external onlyOwner {
        require(_referralContract != address(0), "Zero address");
        referralContract = IReferral(_referralContract);
        isDividendExempt[_referralContract] = true;
        excludeFromReward(_referralContract);
        _isExcludedFromFee[_referralContract] = true;
    }

    function recordReferral(address _user, address _referrer) external onlyOwner {
        if (_user != address(0) && _referrer != address(0) && _user != _referrer && referrers[_user] == address(0)) {
            /** update referrers and refferalsCount mappings */
            referrers[_user] = _referrer;
            referralsCount[_referrer] += 1;

            /** emit the new referral update event */
            emit ReferralRecorded(_user, _referrer);
        }
    }

    function recordReferralCommission(address _referrer, uint256 _commission) external onlyOwner {
        if (_referrer != address(0) && _commission > 0) {
            /** update total gained commissions of referrer when condition is meet */
            totalReferralCommissions[_referrer] += _commission;

            /** emit the event of new commisions recorded */
            emit ReferralCommissionRecorded(_referrer, _commission);
        }
    }

    function getReferrer(address _user) external view returns (address) {
        return referrers[_user];
    }

    function claimReferralCommission() external {
        require(msg.sender != address(0), "Zero address");
        require(referralCommissionAmount[msg.sender] > 0, "No referral commission for this user");
        referralContract.claim(msg.sender, referralCommissionAmount[msg.sender]);
        emit ClaimReferralCommission(msg.sender, referralCommissionAmount[msg.sender]);
    }

    function setReferralCommissionPercentage(uint256 _referralCommissionPercentage) external onlyOwner {
        require(_referralCommissionPercentage < 100, "Commission fee is too high!");
        referralCommissionPercentage = _referralCommissionPercentage;
    }

    // antibot enable
    function enableAntibot(bool enable_) external onlyOwner {
        antibotEnabled = enable_;
    }

    // main functions

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    // once enabled, can never be turned off
    function enableTrading() external onlyOwner {
        tradingActive = true;
        swapAndLiquifyEnabled = true;
    }

    function isSniper(address account) public view returns (bool) {
        return _isSniper[account];
    }

    function manageSnipers(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            _isSniper[addresses[i]] = status;
        }
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        excludeFromMaxTransaction(pair, value);
        if (value) {
            excludeFromReward(pair);
        }
        if (!value) {
            includeInReward(pair);
        }
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns (uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    // for one-time airdrop feature after contract launch
    function airdropToWallets(address[] memory airdropWallets, uint256[] memory amount) external onlyOwner {
        require(airdropWallets.length == amount.length, "airdropToWallets:: Arrays must be the same length");
        removeAllFee();
        buyOrSellSwitch = TRANSFER;
        for (uint256 i = 0; i < airdropWallets.length; i++) {
            address wallet = airdropWallets[i];
            uint256 airdropAmount = amount[i];
            _tokenTransfer(msg.sender, wallet, airdropAmount);
        }
        restoreAllFee();
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        require(_excluded.length + 1 <= 50, "Cannot exclude more than 50 accounts.  Include a previously excluded address.");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
        emit ExcludedMaxTransactionAmount(updAds, isEx);
    }

    function includeInReward(address account) public onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (antibotEnabled) {
            pinkAntiBot.onPreTransferCheck(from, to, amount);
        }

        if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !inSwapAndLiquify) {
            require(tradingActive, "trading is not active yet");

            if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
            }
        }

        if (automatedMarketMakerPairs[from]) {
            // when buy, handle referral commission
            // referral commission
            if (referrers[to] != address(0)) {
                referralCommissionAmount[referrers[to]] = referralCommissionAmount[referrers[to]].add(amount.mul(referralCommissionPercentage).div(1000));
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;

        // Sell tokens for ETH
        if (!inSwapAndLiquify && swapAndLiquifyEnabled && balanceOf(uniswapV2Pair) > 0 && overMinimumTokenBalance && automatedMarketMakerPairs[to]) {
            swapBack();
        }

        removeAllFee();

        buyOrSellSwitch = TRANSFER;

        // If any account belongs to _isExcludedFromFee account then remove the fee
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            // Buy
            if (automatedMarketMakerPairs[from]) {
                _taxFee = _buyTaxFee;
                _liquidityFee = _buyLiquidityFee + _buyMarketingFee + _buyPotFee + _buyPartnerFee + _buyDevFee;
                if (_liquidityFee != 0) {
                    buyOrSellSwitch = BUY;
                }
            }
            // Sell
            else if (automatedMarketMakerPairs[to]) {
                _taxFee = _sellTaxFee;
                _liquidityFee = _sellLiquidityFee + _sellMarketingFee + _sellPotFee + _sellBurnFee + _sellPartnerFee + _sellDevFee;
                if (_liquidityFee != 0) {
                    buyOrSellSwitch = SELL;
                }
            }
        }

        _tokenTransfer(from, to, amount);

        // Dividend tracker
        if (!isDividendExempt[from]) {
            try dividendDistributor.setShare(from, balanceOf(from)) {} catch {}
        }

        if (!isDividendExempt[to]) {
            try dividendDistributor.setShare(to, balanceOf(to)) {} catch {}
        }

        try dividendDistributor.process(distributorGas) {} catch {}
    }

    // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtPercent(uint256 percent) external onlyOwner returns (bool) {
        require(percent >= 1, "Swap amount cannot be lower than 0.001% total supply.");
        require(percent <= 50, "Swap amount cannot be higher than 0.5% total supply.");
        minimumTokensBeforeSwap = (_tTotal * percent) / 10000;
        return true;
    }

    function swapBack() private lockTheSwap {
        uint256 contractBalance = balanceOf(address(this));
        bool success;
        uint256 totalTokensToSwap = _liquidityTokensToSwap + _burnTokens + _marketingTokensToSwap + _devTokensToSwap + _potTokensToSwap + _partnerTokensToSwap;
        uint256 tokensForRewardDistribution = contractBalance.sub(totalTokensToSwap);
        if (totalTokensToSwap == 0 || contractBalance == 0) {
            return;
        }

        uint256 tokensForLiquidity = _liquidityTokensToSwap.div(2);
        uint256 amountToSwapForETH = _liquidityTokensToSwap.sub(tokensForLiquidity).add(_marketingTokensToSwap).add(_devTokensToSwap).add(_potTokensToSwap).add(_partnerTokensToSwap);

        uint256 initialETHBalance = address(this).balance;

        swapTokensForETH(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForMarketing = ethBalance.mul(_marketingTokensToSwap + _devTokensToSwap + _potTokensToSwap + _partnerTokensToSwap).div(amountToSwapForETH);

        uint256 ethForLiquidity = ethBalance - ethForMarketing;

        // Transfer burn token to burn wallet
        uint256 currentRate = _getRate();
        uint256 rBurn = _burnTokens.mul(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurn);
        _tOwned[burnAddress] = _tOwned[burnAddress].add(_burnTokens);
        emit Transfer(address(this), burnAddress, _burnTokens);

        if (tokensForRewardDistribution > 0) {
            swapTokensForTokens(tokensForRewardDistribution, address(REWARD));

            uint256 swappedTokensAmount = IERC20(REWARD).balanceOf(address(this));
            // send bnb to reward
            IERC20(REWARD).transfer(address(dividendDistributor), swappedTokensAmount);
            try dividendDistributor.deposit(swappedTokensAmount) {} catch {}
        }

        if (tokensForLiquidity > 0 && ethForLiquidity > 0) {
            addLiquidity(tokensForLiquidity, ethForLiquidity);
            emit SwapAndLiquify(amountToSwapForETH, ethForLiquidity, tokensForLiquidity);
        }

        // uint256 devFee = address(this).balance.mul(_devFee).div(_sellMarketingFee);
        // (success, ) = address(devAddress).call{ value: devFee }("");

        (success, ) = address(marketingAddress).call{
            value: address(this).balance.mul(_marketingTokensToSwap).div(_marketingTokensToSwap + _devTokensToSwap + _potTokensToSwap + _partnerTokensToSwap)
        }("");
        (success, ) = address(devAddress).call{ value: address(this).balance.mul(_devTokensToSwap).div(_devTokensToSwap + _potTokensToSwap + _partnerTokensToSwap) }("");
        (success, ) = address(potAddress).call{ value: address(this).balance.mul(_potTokensToSwap).div(_potTokensToSwap + _partnerTokensToSwap) }("");
        (success, ) = address(partnerAddress).call{ value: address(this).balance }("");

        _liquidityTokensToSwap = 0;
        _burnTokens = 0;
        _marketingTokensToSwap = 0;
        _devTokensToSwap = 0;
        _potTokensToSwap = 0;
        _partnerTokensToSwap = 0;
    }

    function swapTokensForETH(uint256 tokenAmount) private {
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

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{ value: ethAmount }(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityAddress,
            block.timestamp
        );
    }

    function swapTokensForTokens(uint256 tokenAmount, address tokenToSwap) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = tokenToSwap;
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        if (buyOrSellSwitch == BUY) {
            _liquidityTokensToSwap += (tLiquidity * _buyLiquidityFee) / _liquidityFee;
            // _burnTokens += (tLiquidity * _buyBurnFee) / _liquidityFee;
            _marketingTokensToSwap += (tLiquidity * _buyMarketingFee) / _liquidityFee;
            _devTokensToSwap += (tLiquidity * _buyDevFee) / _liquidityFee;
            _potTokensToSwap += (tLiquidity * _buyPotFee) / _liquidityFee;
            _partnerTokensToSwap += (tLiquidity * _buyPartnerFee) / _liquidityFee;
        } else if (buyOrSellSwitch == SELL) {
            _liquidityTokensToSwap += (tLiquidity * _sellLiquidityFee) / _liquidityFee;
            _burnTokens += (tLiquidity * _sellBurnFee) / _liquidityFee;
            _marketingTokensToSwap += (tLiquidity * _sellMarketingFee) / _liquidityFee;
            _devTokensToSwap += (tLiquidity * _sellDevFee) / _liquidityFee;
            _potTokensToSwap += (tLiquidity * _sellPotFee) / _liquidityFee;
            _partnerTokensToSwap += (tLiquidity * _sellPartnerFee) / _liquidityFee;
        }

        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        if (buyOrSellSwitch == BUY) {
            _rOwned[address(this)] = _rOwned[address(this)].add(rFee);

            if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)].add(tFee);
        } else if (buyOrSellSwitch == SELL) {
            _rTotal = _rTotal.sub(rFee);
            _tFeeTotal = _tFeeTotal.add(tFee);
        }
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(10**2);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;

        _taxFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setBuyFee(
        uint256 buyTaxFee,
        uint256 buyLiquidityFee,
        uint256 buyMarketingFee,
        uint256 buyPotFee,
        uint256 buyPartnerFee
    ) external onlyOwner {
        _buyTaxFee = buyTaxFee;
        _buyLiquidityFee = buyLiquidityFee;
        _buyMarketingFee = buyMarketingFee;
        _buyPotFee = buyPotFee;
        _buyPartnerFee = buyPartnerFee;
        require(_buyTaxFee + _buyLiquidityFee + _buyMarketingFee + _buyPotFee + _buyPartnerFee <= 25, "Must keep taxes below 25%");
    }

    function setSellFee(
        uint256 sellTaxFee,
        uint256 sellLiquidityFee,
        uint256 sellMarketingFee,
        uint256 sellPotFee,
        uint256 sellBurnFee,
        uint256 sellPartnerFee
    ) external onlyOwner {
        _sellTaxFee = sellTaxFee;
        _sellLiquidityFee = sellLiquidityFee;
        _sellMarketingFee = sellMarketingFee;
        _sellPotFee = sellPotFee;
        _sellBurnFee = sellBurnFee;
        _sellPartnerFee = sellPartnerFee;
        require(_sellTaxFee + _sellLiquidityFee + _sellMarketingFee + _sellPotFee + _sellBurnFee + _sellPartnerFee <= 25, "Must keep taxes below 25%");
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        marketingAddress = payable(_marketingAddress);
        _isExcludedFromFee[marketingAddress] = true;
    }

    function setLiquidityAddress(address _liquidityAddress) external onlyOwner {
        liquidityAddress = payable(_liquidityAddress);
        _isExcludedFromFee[liquidityAddress] = true;
    }

    function setDevAddress(address _devAddress) external onlyOwner {
        devAddress = payable(_devAddress);
        _isExcludedFromFee[devAddress] = true;
    }

    function setPotAddress(address _potAddress) external onlyOwner {
        potAddress = payable(_potAddress);
        _isExcludedFromFee[devAddress] = true;
    }

    function setPartnerAddress(address _partnerAddress) external onlyOwner {
        partnerAddress = payable(_partnerAddress);
        _isExcludedFromFee[partnerAddress] = true;
    }

    function setBurnAddress(address _burnAddress) external onlyOwner {
        burnAddress = payable(_burnAddress);
        _isExcludedFromFee[burnAddress] = true;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    // useful for buybacks or to reclaim any ETH on the contract in a way that helps holders.
    function buyBackTokens(uint256 ethAmountInWei) external onlyOwner {
        // generate the uniswap pair path of weth -> eth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: ethAmountInWei }(
            0, // accept any amount of Token
            path,
            address(0xdead),
            block.timestamp
        );
    }

    // To receive ETH from uniswapV2Router when swapping
    receive() external payable {}

    function transferForeignToken(address _token, address _to) external onlyOwner returns (bool _sent) {
        require(_token != address(this), "Can't withdraw native tokens");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    function manualSend(address _recipient) external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        (bool success, ) = _recipient.call{ value: contractETHBalance }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IPinkAntiBot {
    function setTokenOwner(address owner) external;

    function onPreTransferCheck(
        address from,
        address to,
        uint256 amount
    ) external;
}

interface IReferral {
    function claim(address _withdrawalAddress, uint256 _amount) external;
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit(uint256 amount) external;

    function process(uint256 gas) external;

    function purge(address receiver) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address public _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 public REWARD;
    IERC20 public mbabyToken;
    // address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    // address public WBNB = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    IUniswapV2Router02 public router;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1440 * 60; // 24 hours
    uint256 public minDistribution = 1 * (10**9);
    uint256 public minBalanceToGetReward = 3000000 * (10**18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor(address _router, address rewardToken) {
        router = _router != address(0) ? IUniswapV2Router02(_router) : IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // : IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
        REWARD = IERC20(rewardToken);
        mbabyToken = IERC20(_token);
    }

    receive() external payable {}

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function purge(address receiver) external override onlyToken {
        uint256 balance = REWARD.balanceOf(address(this));
        REWARD.transfer(receiver, balance);
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit(uint256 amount) external override onlyToken {
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution && mbabyToken.balanceOf(shareholder) > minBalanceToGetReward;
    }

    function setMinBalanceToGetReward(uint256 _minBalanceToGetReward) external onlyToken {
        minBalanceToGetReward = _minBalanceToGetReward;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            REWARD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getHolderDetails(address holder)
        public
        view
        returns (
            uint256 lastClaim,
            uint256 unpaidEarning,
            uint256 totalReward,
            uint256 holderIndex
        )
    {
        lastClaim = shareholderClaims[holder];
        unpaidEarning = getUnpaidEarnings(holder);
        totalReward = shares[holder].totalRealised;
        holderIndex = shareholderIndexes[holder];
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return currentIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return shareholders.length;
    }

    function getShareHoldersList() external view returns (address[] memory) {
        return shareholders;
    }

    function totalDistributedRewards() external view returns (uint256) {
        return totalDistributed;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}