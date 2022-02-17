// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./SafeMath.sol";
import "./IBEP20.sol";
import "./IPancake.sol";
import "./Auth.sol";
import "./DividentTracker.sol";


contract MoonDynamics is IBEP20, Auth {
    using SafeMath for uint256;

    //TODO:Change this to real one 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Moon";
    string constant _symbol = "Moon";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 1000000000000000 * (10**_decimals);

    IBEP20 public VipToken;
    uint256 internal vipCoinThresholdAmount = 1000 * (10**_decimals);
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTimelockExempt;
    mapping(address => bool) isDividendExempt;

    // buy fees
    uint256 public buyDividendRewardsFee = 5;
    uint256 public buyMarketingFee = 6;
    uint256 public buyLiquidityFee = 1;
    uint256 public buyTotalFees = 12;
    // sell fees
    uint256 public sellDividendRewardsFee = 7;
    uint256 public sellMarketingFee = 6;
    uint256 public sellLiquidityFee = 3;
    uint256 public sellTotalFees = 16;

    // swap precentage
    uint256 public devidendSwap = 6;
    uint256 public marketingSwap = 6;
    uint256 public liquiditySwap = 2;
    uint256 public totalSwap = 14;

    address marketingFeeReceiver;

    IPancakeRouter02 public router;
    address public pair;

    bool public tradingOpen = true;

    DividendDistributor public distributor;
    uint256 distributorGas = 500000;

    // Cooldown & timer functionality
    bool public buyCooldownEnabled = false;
    uint8 public cooldownTimerInterval = 45;
    mapping(address => uint256) private cooldownTimer;
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 10) / 10000; // 0.01% of supply
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        //TODO Change this to real one 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // Make a function to change router address
        router = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pair = IPancakeFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        distributor = new DividendDistributor(
            address(router),
            0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 //USDT
        );

       //Before deploy set the real VipToken
        VipToken = IBEP20(0xbB69afA00f49F8735AE19F5066415bfB49ef3428);

        isFeeExempt[msg.sender] = true;

        // No timelock for these people
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        marketingFeeReceiver = 0x2D59a30A28887Ca4B55D891F333cB0Fb4EfeeEdF;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)external view override returns (uint256){
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)public override returns (bool){
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount)external override returns (bool){
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (!authorizations[sender] && !authorizations[recipient]) {
            require(tradingOpen, "Trading not open yet");
        }

        // cooldown timer, so a bot doesnt do quick trades! 1min gap between 2 trades.
        if (
            sender == pair && buyCooldownEnabled && !isTimelockExempt[recipient]
        ) {
            require(
                cooldownTimer[recipient] < block.timestamp,
                "Please wait for cooldown between buys"
            );
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }

        // Liquidity, Maintained at 25%
        if (shouldSwapBack()) {
            swapBack();
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived = shouldTakeFee(sender)
            ? takeFee(sender, amount, recipient)
            : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if (!isDividendExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }

        if (!isDividendExempt[recipient]) {
            try
                distributor.setShare(recipient, _balances[recipient])
            {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        sendVipCoints(amount, recipient, sender);
        return true;
    }

    function _basicTransfer(address sender,address recipient,uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function sendVipCoints(uint256 amount, address recipient, address sender) internal{
        if (sender == pair && amount >= vipCoinThresholdAmount)
        {
            VipToken.transfer(recipient, 1);
        }
    }

    function setVipCointThresholdAmount(uint256 amount) public onlyOwner {
        vipCoinThresholdAmount = amount * (10**_decimals);
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount, address to) internal returns (uint256) {
        uint256 feeAmount = 0;
        if (to == pair) {
            feeAmount = amount.mul(sellTotalFees).div(100);
        } else {
            feeAmount = amount.mul(buyTotalFees).div(100);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(marketingFeeReceiver).transfer(
            (amountBNB * amountPercentage) / 100
        );
    }

    function updateBuylFees(uint256 reward,uint256 marketing,uint256 liquidity) public onlyOwner {
        buyDividendRewardsFee = reward;
        buyMarketingFee = marketing;
        buyLiquidityFee = liquidity;
        buyTotalFees = reward.add(marketing).add(liquidity);
    }

    function updateSellFees(uint256 reward,uint256 marketing,uint256 liquidity) public onlyOwner {
        sellDividendRewardsFee = reward;
        sellMarketingFee = marketing;
        sellLiquidityFee = liquidity;
        sellTotalFees = reward.add(marketing).add(liquidity);
    }

    function updateSwapPercentage(uint256 reward,uint256 marketing,uint256 liquidity) public onlyOwner {
        devidendSwap = reward;
        marketingSwap = marketing;
        liquiditySwap = liquidity;
        totalSwap = reward.add(marketing).add(liquidity);
    }

    // switch Trading
    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    function whitelistPreSale(address _preSale) public onlyOwner {
        isFeeExempt[_preSale] = true;
        isTimelockExempt[_preSale] = true;
        isDividendExempt[_preSale] = true;
    }

    // enable cooldown between trades
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    // new dividend tracker, clear balance
    function purgeBeforeSwitch() public onlyOwner {
        distributor.purge(msg.sender);
    }

    // new dividend token
    function switchDividendToken(address rewardToken) public onlyOwner {
        distributor.purge(msg.sender);
        distributor.switchRewardToken(rewardToken);
    }

    // new router
    function switchRouter(address _router) public onlyOwner {
        router = IPancakeRouter02(_router);
        pair = IPancakeFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        distributor.switchRouter(address(router));
    }

    function setVipToken(address vipToken) public onlyOwner {
        VipToken = IBEP20(vipToken);
    }

    // manual claim
    function ___claimRewards() public {
        distributor.claimDividend();
        try distributor.process(distributorGas) {} catch {}
    }

    // get dividend Balance for a wallet
    function getClaimableDividentBalance(address shareHolder) public view  returns (uint256){
        return distributor.getUnpaidEarnings(shareHolder);
    }

    // get Total Claimable Dividends
    function getTotalClaimableDividentBalance() public view  returns (uint256){
        return distributor.getTotalClaimableDividends();
    }

      //get Pending Dividends for a wallet
    function getPendingDividentBalanceForWallet(address shareHolder) public view  returns (uint256){      
        uint256 dividends = getTotalPendingDividentBalance();
        uint256 shares =  distributor.getRewarsPercentage(shareHolder);
        return dividends.mul(shares);
    }

    //get Total Pending Dividends
    function getTotalPendingDividentBalance() public view  returns (uint256){
        uint256 contractBnbBalance = _balances[address(this)];      
        // calculate reward amount
        uint256 dividends = contractBnbBalance.mul(devidendSwap).div(totalSwap);
        return dividends;
    }

    //get Total Paid Rewards for wallet
    function getPaidRewardsForWallet(address shareholder) external view returns (uint256){
           return distributor.getPaidRewardsForWallet(shareholder);
    }

    //Get Total paid rewards
    function getTotalPaidRewards() external view returns (uint256){
        return distributor.getTotalPaidRewards();
    }

    // manually clear the queue
    function claimProcess() public {
        try distributor.process(distributorGas) {} catch {}
    }

    function swapBack() internal swapping {
        uint256 contractBnbBalance = _balances[address(this)];
        // calculate token amount to add liquidity
        uint256 tokensToLiquidity = contractBnbBalance.mul(liquiditySwap).div(
            totalSwap
        );
        // calculate total swap fee
        uint256 totalSwapFee = totalSwap.sub(liquiditySwap);
        // calculate tokens amount to swap
        uint256 tokensToSwap = contractBnbBalance.sub(tokensToLiquidity);

        // swap the tokens
        swapTokensForEth(tokensToSwap);
        // get swapped bnb amount
        uint256 swappedBnbAmount = address(this).balance;

        // calculate reward bnb amount
        uint256 amountBNBReflection = swappedBnbAmount.mul(devidendSwap).div(
            totalSwapFee
        );
        // calculate marketing total
        uint256 totalBnbMarketing = swappedBnbAmount.mul(marketingSwap).div(
            totalSwapFee
        );
        // allocate some bnb amount to cover contract gas fee (30%)
        uint256 amountBNBForGas = totalBnbMarketing.mul(30).div(100);
        // actual bnb amount to send marketing address
        uint256 amountBNBMarketing = totalBnbMarketing.sub(amountBNBForGas);

        // send bnb to reward
        try distributor.deposit{value: amountBNBReflection}() {} catch {}

        // send bnb to gas fee
        (bool gasSuccess, ) = address(this).call{
            value: amountBNBForGas,
            gas: 30000
        }("");
        // send bnb to marketing
        (bool marketingSuccess, ) = payable(marketingFeeReceiver).call{
            value: amountBNBMarketing,
            gas: 30000
        }("");

        // only to supress warning msg
        gasSuccess = false;
        marketingSuccess = false;
        // add liquidity
        swapAndLiquify(tokensToLiquidity);
    }

    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit AutoLiquify(newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function setIsDividendExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTimelockExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isTimelockExempt[holder] = exempt;
    }

    function setFeeReceivers(address _marketingFeeReceiver) external onlyOwner{
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner{
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256){
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy)public view returns (bool){
        return getLiquidityBacking(accuracy) > target;
    }

    // Do air drops
    function makeAirDrop(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
        uint256 SCCC = 0;
        require(addresses.length == tokens.length, "Mismatch between Address and token count");

        for (uint256 i = 0; i < addresses.length; i++) {
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf(from) >= SCCC, "Not enough tokens to airdrop");

        for (uint256 i = 0; i < addresses.length; i++) {
            _basicTransfer(from, addresses[i], tokens[i]);
            if (!isDividendExempt[addresses[i]]) {
                try
                    distributor.setShare(addresses[i], _balances[addresses[i]])
                {} catch {}
            }
        }

        // Dividend tracker
        if (!isDividendExempt[from]) {
            try distributor.setShare(from, _balances[from]) {} catch {}
        }
    }
}