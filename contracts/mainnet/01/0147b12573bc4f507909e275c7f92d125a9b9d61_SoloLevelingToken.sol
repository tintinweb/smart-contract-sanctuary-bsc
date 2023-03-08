//This is first ever Deflationary Meme coin dedicated for South Korean manhwa/webnovel Solo Leveling in Binance Smart Chain.
//Our social Medias: Telegram:- https://t.me/SOLOLevelingToken and Twitter:- https://twitter.com/SoloLevelingBSC
//Note is contract is deployed by a Rookie Developer. Invest on your own risk.


//SPDX-License-Identifier: NONE

pragma solidity ^0.8.7;

import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./DividendDistributor.sol";

contract SoloLevelingToken is IERC20, Ownable {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public REWARD;

    string constant _name = "Solo Leveling";
    string constant _symbol = "SOLO";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 745000000000 * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isDividendExempt;
    mapping(address => bool) isMaxWalletExempt;
    mapping(address => bool) isMaxTxExempt;

    // allowed users to do transactions before trading enable
    mapping(address => bool) isAuthorized;

    mapping(address => bool) whitelistedCustomTokens;

    // buy fees
    uint256 public buyRewardFee = 5;
    uint256 public buyLiquidityFee = 1;
    uint256 public buyDevFee = 3;
    uint256 public buyStrategicFee = 1;
    uint256 public buyP2EFee = 0;
    uint256 public buyStakeFee = 0;
    uint256 public buyBurnFee = 0;
    uint256 public buyTotalFees = 10;
    // sell fees
    uint256 public sellRewardFee = 5;
    uint256 public sellLiquidityFee = 1;
    uint256 public sellDevFee = 3;
    uint256 public sellStrategicFee = 1;
    uint256 public sellP2EFee = 0;
    uint256 public sellStakeFee = 0;
    uint256 public sellBurnFee = 0;
    uint256 public sellTotalFees = 10;

    address public devFeeReceiver;
    address public strategicFeeReceiver;
    address public p2eFeeReceiver;
    address public stakeFeeReceiver;

    // swap percentage
    uint256 public rewardSwap = 3;
    uint256 public devSwap = 3;
    uint256 public strategicSwap = 2;
    uint256 public liquiditySwap = 2;
    uint256 public totalSwap = 10;

    IUniswapV2Router02 public router;
    address public pair;

    bool public tradingOpen = false;

    DividendDistributor public dividendTracker;

    uint256 distributorGas = 500000;

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event ChangeRewardTracker(address token);
    event IncludeInReward(address holder);
    event LPAddressChanged(address newLpAddress);
    event WhiteListCustomToken(address token, bool status);

    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 10) / 10000; // 0.01% of supply
    uint256 public maxWalletTokens = _totalSupply / 100; // 1% of supply
    uint256 public maxTxAmount = _totalSupply / 1000; // 0.1% of supply

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        uint256 chainId = block.chainid;
        address routerAddress;

        if (chainId == 56) {
            routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        } else if (chainId == 97) {
            routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        }
        router = IUniswapV2Router02(routerAddress);
        pair = IUniswapV2Factory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _allowances[address(this)][address(router)] = type(uint256).max;

        address deployer;

        REWARD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        deployer = 0xA7fd7AD78C5a66FdB373D7F5B4609b246e7b993C;

        dividendTracker = new DividendDistributor(address(router), REWARD);

        isFeeExempt[deployer] = true;
        isMaxTxExempt[deployer] = true;
        isMaxWalletExempt[deployer] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        isAuthorized[deployer] = true;

        devFeeReceiver = 0xA7fd7AD78C5a66FdB373D7F5B4609b246e7b993C;
        strategicFeeReceiver = 0x519ff0b937715f0b29d7C4B70D347e0dF1796227;
        p2eFeeReceiver = 0x519ff0b937715f0b29d7C4B70D347e0dF1796227;
        stakeFeeReceiver = 0x519ff0b937715f0b29d7C4B70D347e0dF1796227;

        transferOwnership(deployer);

        _balances[deployer] = _totalSupply;
        emit Transfer(address(0), deployer, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
        return dividendTracker.getHolderDetails(holder);
    }

    function getLastProcessedIndex() public view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfTokenHolders() public view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function totalDistributedRewards() public view returns (uint256) {
        return dividendTracker.totalDistributedRewards();
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
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

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (!isAuthorized[sender]) {
            require(tradingOpen, "Trading not open yet");
        }

        if (shouldSwapBack()) {
            swapBackInBnb();
        }

        if (!isMaxTxExempt[sender] && sender != pair) {
            require(amount <= maxTxAmount, "Max Transaction amount exceeded");
        }
        if (!isMaxWalletExempt[recipient] && recipient != pair) {
            uint256 currentBalance = _balances[recipient].add(amount);
            require(
                currentBalance <= maxTxAmount,
                "Max wallet amount exceeded"
            );
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, amount, recipient)
            : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        // Dividend tracker
        if (!isDividendExempt[sender]) {
            try dividendTracker.setShare(sender, _balances[sender]) {} catch {}
        }

        if (!isDividendExempt[recipient]) {
            try
                dividendTracker.setShare(recipient, _balances[recipient])
            {} catch {}
        }

        try dividendTracker.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender, address to)
        internal
        view
        returns (bool)
    {
        if (isFeeExempt[sender] || isFeeExempt[to]) {
            return false;
        } else {
            return true;
        }
    }

    function takeFee(
        address sender,
        uint256 amount,
        address to
    ) internal returns (uint256) {
        uint256 feeAmount = 0;
        uint256 p2eAmount = 0;
        uint256 stakeAmount = 0;
        uint256 burnAmount = 0;

        if (to == pair) {
            feeAmount = amount.mul(sellTotalFees).div(100);

            if (sellP2EFee > 0) {
                p2eAmount = feeAmount.mul(sellP2EFee).div(sellTotalFees);
                _balances[p2eFeeReceiver] = _balances[p2eFeeReceiver].add(
                    p2eAmount
                );
                emit Transfer(sender, address(p2eFeeReceiver), p2eAmount);
            }
            if (sellStakeFee > 0) {
                stakeAmount = feeAmount.mul(sellStakeFee).div(sellTotalFees);
                _balances[stakeFeeReceiver] = _balances[stakeFeeReceiver].add(
                    stakeAmount
                );
                emit Transfer(sender, address(stakeFeeReceiver), stakeAmount);
            }
            if (sellBurnFee > 0) {
                burnAmount = feeAmount.mul(sellBurnFee).div(sellTotalFees);
                _balances[ZERO] = _balances[ZERO].add(burnAmount);
                emit Transfer(sender, address(ZERO), burnAmount);
            }
        } else {
            feeAmount = amount.mul(buyTotalFees).div(100);
            if (buyP2EFee > 0) {
                p2eAmount = feeAmount.mul(buyP2EFee).div(buyTotalFees);
                _balances[p2eFeeReceiver] = _balances[p2eFeeReceiver].add(
                    p2eAmount
                );
                emit Transfer(sender, address(p2eFeeReceiver), p2eAmount);
            }
            if (buyStakeFee > 0) {
                stakeAmount = feeAmount.mul(buyStakeFee).div(buyTotalFees);
                _balances[stakeFeeReceiver] = _balances[stakeFeeReceiver].add(
                    stakeAmount
                );
                emit Transfer(sender, address(stakeFeeReceiver), stakeAmount);
            }
            if (buyBurnFee > 0) {
                burnAmount = feeAmount.mul(buyBurnFee).div(buyTotalFees);
                _balances[ZERO] = _balances[ZERO].add(burnAmount);
                emit Transfer(sender, address(ZERO), burnAmount);
            }
        }

        uint256 tokensToContract = feeAmount
            .sub(p2eAmount)
            .sub(stakeAmount)
            .sub(burnAmount);
        _balances[address(this)] = _balances[address(this)].add(
            tokensToContract
        );
        emit Transfer(sender, address(this), tokensToContract);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled &&
            tradingOpen &&
            _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer((amountBNB * amountPercentage) / 100);
    }

    function updateLpAddress(address _newLpAddress) external onlyOwner {
        isDividendExempt[_newLpAddress] = true;

        pair = _newLpAddress;

        emit LPAddressChanged(_newLpAddress);
    }

    function getBep20Tokens(address _tokenAddress, uint256 amount)
        external
        onlyOwner
    {
        require(
            _tokenAddress != address(this),
            "You can not withdraw native tokens"
        );
        require(
            IERC20(_tokenAddress).balanceOf(address(this)) >= amount,
            "No Enough Tokens"
        );
        IERC20(_tokenAddress).transfer(msg.sender, amount);
    }

    function updateBuyFees(
        uint256 reward,
        uint256 liquidity,
        uint256 dev,
        uint256 strategic,
        uint256 p2e,
        uint256 stake,
        uint256 burn
    ) public onlyOwner {
        buyRewardFee = reward;
        buyLiquidityFee = liquidity;
        buyDevFee = dev;
        buyStrategicFee = strategic;
        buyP2EFee = p2e;
        buyStakeFee = stake;
        buyBurnFee = burn;

        buyTotalFees = reward.add(liquidity).add(dev).add(strategic);
        buyTotalFees = buyTotalFees.add(p2e).add(stake).add(burn);
        require(buyTotalFees <= 15, "Fees can not be greater than 15%");
    }

    function updateSellFees(
        uint256 reward,
        uint256 liquidity,
        uint256 dev,
        uint256 strategic,
        uint256 p2e,
        uint256 stake,
        uint256 burn
    ) public onlyOwner {
        sellRewardFee = reward;
        sellLiquidityFee = liquidity;
        sellDevFee = dev;
        sellStrategicFee = strategic;
        sellP2EFee = p2e;
        sellStakeFee = stake;
        sellBurnFee = burn;

        sellTotalFees = reward.add(liquidity).add(dev).add(strategic);
        sellTotalFees = sellTotalFees.add(p2e).add(stake).add(burn);
        require(sellTotalFees <= 15, "Fees can not be greater than 15%");
    }

    // update swap percentages
    function updateSwapPercentages(
        uint256 reward,
        uint256 strategic,
        uint256 liquidity,
        uint256 dev
    ) public onlyOwner {
        rewardSwap = reward;
        devSwap = dev;
        liquiditySwap = liquidity;
        strategicSwap = strategic;

        totalSwap = reward.add(dev).add(liquidity).add(strategic);
    }

    // switch Trading
    function enableTrading() public onlyOwner {
        tradingOpen = true;
    }

    function whitelistPreSale(address _preSale) public onlyOwner {
        isFeeExempt[_preSale] = true;
        isDividendExempt[_preSale] = true;
        isAuthorized[_preSale] = true;
        isMaxTxExempt[_preSale] = true;
        isMaxWalletExempt[_preSale] = true;
    }

    // manual claim for the greedy humans
    function ___claimRewards(bool tryAll) public {
        dividendTracker.claimDividend();
        if (tryAll) {
            try dividendTracker.process(distributorGas) {} catch {}
        }
    }

    // manually clear the queue
    function claimProcess() public {
        try dividendTracker.process(distributorGas) {} catch {}
    }

    function isRewardExclude(address _wallet) public view returns (bool) {
        return isDividendExempt[_wallet];
    }

    function isFeeExclude(address _wallet) public view returns (bool) {
        return isFeeExempt[_wallet];
    }

    function isMaxTxExcluded(address _wallet) public view returns (bool) {
        return isMaxTxExempt[_wallet];
    }

    function isMaxWalletExcluded(address _wallet) public view returns (bool) {
        return isMaxWalletExempt[_wallet];
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        require(
            amount >= 1000000,
            "Minimum wallet token amount should grater than 0.1%"
        );

        maxTxAmount = amount * (10**9);
    }

    function swapBackInBnb() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 tokensToLiquidity = contractTokenBalance.mul(liquiditySwap).div(
            totalSwap
        );

        uint256 tokensToSwap = contractTokenBalance.sub(tokensToLiquidity);

        swapTokensForTokens(tokensToSwap, REWARD);

        uint256 swappedTokensAmount = IERC20(REWARD).balanceOf(address(this));

        uint256 swappedFee = totalSwap.sub(liquiditySwap);

        uint256 tokensForReward = swappedTokensAmount.mul(rewardSwap).div(
            swappedFee
        );
        uint256 tokensForDev = swappedTokensAmount.mul(devSwap).div(swappedFee);
        uint256 tokensForStrategic = swappedTokensAmount.mul(strategicSwap).div(
            swappedFee
        );

        if (tokensForReward > 0) {
            // send token to reward
            IERC20(REWARD).transfer(address(dividendTracker), tokensForReward);
            try dividendTracker.deposit(tokensForReward) {} catch {}
        }

        if (tokensForDev > 0) {
            IERC20(REWARD).transfer(address(devFeeReceiver), tokensForDev);
        }
        if (tokensForStrategic > 0) {
            IERC20(REWARD).transfer(
                address(strategicFeeReceiver),
                tokensForStrategic
            );
        }

        if (tokensToLiquidity > 0) {
            // add liquidity
            swapAndLiquify(tokensToLiquidity);
        }
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
        _approve(address(this), address(router), tokenAmount);
        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForTokens(uint256 tokenAmount, address tokenToSwap)
        private
    {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = tokenToSwap;
        _approve(address(this), address(router), tokenAmount);
        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of tokens
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(router), tokenAmount);

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
            dividendTracker.setShare(holder, 0);
        } else {
            dividendTracker.setShare(holder, _balances[holder]);
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function addAuthorizedWallets(address holder, bool exempt)
        external
        onlyOwner
    {
        isAuthorized[holder] = exempt;
    }

    function setMaxWalletToken(uint256 amount) external onlyOwner {
        require(
            amount >= 10000000,
            "Minimum wallet token amount should grater than 1%"
        );
        maxWalletTokens = amount * (10**9);
    }

    function changeFeeWallets(
        address _dev,
        address _strategic,
        address _p2e,
        address _stake
    ) external onlyOwner {
        devFeeReceiver = _dev;
        strategicFeeReceiver = _strategic;
        p2eFeeReceiver = _p2e;
        stakeFeeReceiver = _stake;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        dividendTracker.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }

    function purgeBeforeSwitch() public onlyOwner {
        dividendTracker.purge(msg.sender);
    }

    function includeMeinRewards() public {
        require(
            !isDividendExempt[msg.sender],
            "You are not allowed to get rewards"
        );
        try
            dividendTracker.setShare(msg.sender, _balances[msg.sender])
        {} catch {}

        emit IncludeInReward(msg.sender);
    }

    function switchToken(address rewardToken) public onlyOwner {
        require(
            rewardToken != router.WETH(),
            "Can not reward BNB in this tracker"
        );
        REWARD = rewardToken;

        dividendTracker = new DividendDistributor(address(router), rewardToken);

        emit ChangeRewardTracker(rewardToken);
    }

    function whitelistCustomToken(address token, bool status) public onlyOwner {
        require(
            token != address(0),
            "Cannot use the zero address as reward address"
        );
        address pairAddress = IUniswapV2Factory(router.factory()).getPair(
            router.WETH(),
            address(this)
        );
        require(
            pairAddress != address(0),
            "Cannot use this address as reward address because this address is not added on pancakeswap"
        );

        whitelistedCustomTokens[token] = true;

        emit WhiteListCustomToken(token, status);
    }

    function setCustomToken(address token, uint256 percentage) public {
        require(
            whitelistedCustomTokens[token],
            "Token not whitelisted please contact admin to whitelist the token"
        );

        require(percentage <= 100, "Percentage can not be grater than 100%");

        dividendTracker.setCustomTokens(token, percentage, msg.sender);
    }

    function setMaxTxExempt(address _wallet, bool _status) public onlyOwner {
        isMaxTxExempt[_wallet] = _status;
    }

    function setMaxWalletExempt(address _wallet, bool _status)
        public
        onlyOwner
    {
        isMaxWalletExempt[_wallet] = _status;
    }
}