//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./DividendDistributor.sol";

contract EFBP is IERC20, Ownable {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public REWARD;
    address public BURN;

    string constant _name = "ETH Fan Burn Test 01";
    string constant _symbol = "$EFBP 01";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 1000000000000 * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isDividendExempt;
    // allowed users to do transactions before trading enable
    mapping(address => bool) isAuthorized;
    mapping(address => bool) isBlacklist;
    mapping(address => bool) isMaxWalletExempt;
    mapping(address => bool) isBlacklistedFromSell;
    mapping(address => bool) isMaxTxExempt;
    mapping(address => bool) isTimelockExempt;

    // buy fees
    uint256 public buyRewardFee = 0;
    uint256 public buyLiquidityFee = 0;
    uint256 public buyBurnFee = 0;
    uint256 public buyCharityFee = 0;
    uint256 public buyTotalFees = 0;
    // sell fees
    uint256 public sellRewardFee = 0;
    uint256 public sellLiquidityFee = 0;
    uint256 public sellBurnFee = 0;
    uint256 public sellCharityFee = 0;
    uint256 public sellTotalFees = 0;

    address public charityFeeReceiver;

    // swap percentage
    uint256 public rewardSwap = 0;
    uint256 public charitySwap = 0;
    uint256 public buyBackSwap = 0;
    uint256 public liquiditySwap = 0;
    uint256 public totalSwap = 0;

    IUniswapV2Router02 public router;
    address public pair;

    bool public tradingOpen = true;

    uint256 public sellTaxMultiplier = 1;

    DividendDistributor public dividendTracker;

    uint256 distributorGas = 500000;

    bool public coolDownEnabled = false;
    uint256 public cooldownTimerInterval = 86400;

    mapping(address => uint256) private cooldownTimer;

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event ChangeRewardTracker(address token);
    event IncludeInReward(address holder);
    event LPAddressChanged(address newLpAddress);

    bool public swapEnabled = false;
    uint256 public swapThreshold = _totalSupply;
    uint256 public maxWalletTokens = _totalSupply;
    uint256 public maxTxAmount = _totalSupply;

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
            routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        }
        router = IUniswapV2Router02(routerAddress);
        pair = IUniswapV2Factory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _allowances[address(this)][address(router)] = type(uint256).max;

        address deployer;

        REWARD = 0x002d3C280f719c4B0444680A8C4B1785b6cC2A59;
        BURN = 0x002d3C280f719c4B0444680A8C4B1785b6cC2A59;
        deployer = 0xb6658AE3BD78a03403c0b6989E9c1083c1cf5907;

        dividendTracker = new DividendDistributor(address(router), REWARD);

        isFeeExempt[deployer] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        isAuthorized[deployer] = true;

        isMaxTxExempt[deployer] = true;
        isMaxTxExempt[pair] = true;
        isMaxTxExempt[address(this)] = true;

        isMaxWalletExempt[deployer] = true;
        isMaxWalletExempt[pair] = true;
        isMaxWalletExempt[address(this)] = true;

        charityFeeReceiver = 0xC772558c3Ab669362273BEA212CE08FAc5aa4976;

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
        require(
            !isBlacklist[sender] && !isBlacklist[recipient],
            "Blacklisted users"
        );
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (!isAuthorized[sender]) {
            require(tradingOpen, "Trading not open yet");
        }
        if (recipient == pair) {
            require(
                !isBlacklistedFromSell[sender],
                "Wallet Blacklisted from sell"
            );
        }
        if (!isMaxTxExempt[sender]) {
            require(amount <= maxTxAmount, "Max Transaction Amount exceed");
        }
        if (coolDownEnabled && sender == pair) {
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }
        if (!isMaxWalletExempt[recipient]) {
            uint256 balanceAfterTransfer = amount.add(_balances[recipient]);
            require(
                balanceAfterTransfer <= maxWalletTokens,
                "Max Wallet Amount exceed"
            );
        }
        if (shouldSwapBack()) {
            swapBackInBnb();
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

        if (to == pair) {
            feeAmount = amount.mul(sellTotalFees).div(100);
            if (
                coolDownEnabled &&
                !isTimelockExempt[sender] &&
                cooldownTimer[sender] > block.timestamp
            ) {
                feeAmount = feeAmount.mul(sellTaxMultiplier);
            }
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
            tradingOpen &&
            _balances[address(this)] >= swapThreshold;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer((amountBNB * amountPercentage) / 100);
    }

    function updateLpAddress(address _newLpAddress) external onlyOwner {
        isDividendExempt[_newLpAddress] = true;
        isMaxTxExempt[_newLpAddress] = true;
        isMaxWalletExempt[_newLpAddress] = true;

        pair = _newLpAddress;

        emit LPAddressChanged(_newLpAddress);
    }

    function getBep20Tokens(address _tokenAddress, uint256 amount)
        external
        onlyOwner
    {
        require(
            IERC20(_tokenAddress).balanceOf(address(this)) >= amount,
            "No Enough Tokens"
        );
        IERC20(_tokenAddress).transfer(msg.sender, amount);
    }

    function updateBuyFees(
        uint256 reward,
        uint256 charity,
        uint256 liquidity,
        uint256 burn
    ) public onlyOwner {
        buyRewardFee = reward;
        buyCharityFee = charity;
        buyLiquidityFee = liquidity;
        buyBurnFee = burn;

        buyTotalFees = reward.add(charity).add(liquidity).add(burn);
        require(buyTotalFees <= 40, "Fees can not be greater than 40%");
    }

    function updateSellFees(
        uint256 reward,
        uint256 charity,
        uint256 liquidity,
        uint256 burn
    ) public onlyOwner {
        sellRewardFee = reward;
        sellCharityFee = charity;
        sellLiquidityFee = liquidity;
        sellBurnFee = burn;

        sellTotalFees = reward.add(charity).add(liquidity).add(burn);
        require(sellTotalFees <= 40, "Fees can not be greater than 40%");
    }

    // update swap percentages
    function updateSwapPercentages(
        uint256 reward,
        uint256 charity,
        uint256 liquidity,
        uint256 burn
    ) public onlyOwner {
        rewardSwap = reward;
        charitySwap = charity;
        liquiditySwap = liquidity;
        buyBackSwap = burn;

        totalSwap = reward.add(charity).add(liquidity).add(burn);
    }

    // switch Trading
    function enableTrading(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    function whitelistPreSale(address _preSale) public onlyOwner {
        isFeeExempt[_preSale] = true;
        isDividendExempt[_preSale] = true;
        isAuthorized[_preSale] = true;
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

    function blackListWallets(address wallet, bool _status) public onlyOwner {
        isBlacklist[wallet] = _status;
    }

    function blacklistFromSell(address wallet, bool _status) public onlyOwner {
        isBlacklistedFromSell[wallet] = _status;
    }

    function isBlacklisted(address _wallet) public view returns (bool) {
        return isBlacklist[_wallet];
    }

    function isSellBlacklisted(address _wallet) public view returns (bool) {
        return isBlacklistedFromSell[_wallet];
    }

    function isRewardExclude(address _wallet) public view returns (bool) {
        return isDividendExempt[_wallet];
    }

    function isFeeExclude(address _wallet) public view returns (bool) {
        return isFeeExempt[_wallet];
    }

    function isMaxWalletExclude(address _wallet) public view returns (bool) {
        return isMaxWalletExempt[_wallet];
    }

    function isMaxTxExcluded(address _wallet) public view returns (bool) {
        return isMaxTxExempt[_wallet];
    }

    function setIsMaxTxExempt(address holder, bool exempt) external onlyOwner {
        isMaxTxExempt[holder] = exempt;
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        maxTxAmount = amount * (10**9);
    }

    function isExemptTimeLock(address _wallet) public view returns (bool) {
        return isTimelockExempt[_wallet];
    }

    function changeSellCoolDownTime(uint256 _time) public onlyOwner {
        cooldownTimerInterval = _time;
    }

    function enableSellCollDown(bool _status) public onlyOwner {
        coolDownEnabled = _status;
    }

    function exemptTimeLock(address wallet, bool _status) public onlyOwner {
        isTimelockExempt[wallet] = _status;
    }

    function swapBackInBnb() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 tokensToLiquidity = contractTokenBalance.mul(liquiditySwap).div(
            totalSwap
        );

        uint256 tokensToCharity = contractTokenBalance.mul(charitySwap).div(
            totalSwap
        );
        uint256 tokensForRewardAndBurn = contractTokenBalance
            .sub(tokensToLiquidity)
            .sub(tokensToCharity);

        if (tokensForRewardAndBurn > 0) {
            if (REWARD == BURN) {
                swapTokensForTokens(tokensForRewardAndBurn, REWARD);
                uint256 swappedTokensAmount = IERC20(REWARD).balanceOf(
                    address(this)
                );
                uint256 rewardAndBurnFee = rewardSwap.add(buyBackSwap);
                uint256 tokensToBurn = swappedTokensAmount.mul(buyBackSwap).div(
                    rewardAndBurnFee
                );
                if (tokensToBurn > 0) {
                    // send burn token
                    try
                        IERC20(REWARD).transfer(address(DEAD), tokensToBurn)
                    {} catch {}
                }

                uint256 tokensToReward = swappedTokensAmount.sub(tokensToBurn);
                if (tokensToReward > 0) {
                    // send token to reward
                    IERC20(REWARD).transfer(
                        address(dividendTracker),
                        tokensToReward
                    );
                    try dividendTracker.deposit(tokensToReward) {} catch {}
                }
            } else {
                uint256 rewardAndBurnFee = rewardSwap.add(buyBackSwap);
                uint256 tokensToBurn = tokensForRewardAndBurn
                    .mul(buyBackSwap)
                    .div(rewardAndBurnFee);
                uint256 tokensToReward = tokensForRewardAndBurn.sub(
                    tokensToBurn
                );

                if (tokensToBurn > 0) {
                    swapTokensForTokens(tokensToBurn, BURN);
                    uint256 swappedTokensAmountBurn = IERC20(BURN).balanceOf(
                        address(this)
                    );
                    // send burn token
                    try
                        IERC20(BURN).transfer(
                            address(DEAD),
                            swappedTokensAmountBurn
                        )
                    {} catch {}
                }

                if (tokensToReward > 0) {
                    swapTokensForTokens(tokensToBurn, REWARD);
                    uint256 swappedTokensAmount = IERC20(REWARD).balanceOf(
                        address(this)
                    );
                    // send token to reward
                    IERC20(REWARD).transfer(
                        address(dividendTracker),
                        swappedTokensAmount
                    );
                    try dividendTracker.deposit(tokensToReward) {} catch {}
                }
            }
        }

        if (tokensToCharity > 0) {
            swapTokensForEth(tokensToCharity);
            uint256 swappedTokensAmount = address(this).balance;

            if (swappedTokensAmount > 0) {
                (bool charitySuccess, ) = payable(charityFeeReceiver).call{
                    value: swappedTokensAmount,
                    gas: 30000
                }("");
                charitySuccess = false;
            }
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

    function setIsMaxWalletExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isMaxWalletExempt[holder] = exempt;
    }

    function addAuthorizedWallets(address holder, bool exempt)
        external
        onlyOwner
    {
        isAuthorized[holder] = exempt;
    }

    function setCharityWallet(address _wallet) external onlyOwner {
        charityFeeReceiver = _wallet;
    }

    function changeBuyBackAndBurnToken(address _tokenAddress)
        external
        onlyOwner
    {
        BURN = _tokenAddress;
    }

    function setMaxWalletToken(uint256 amount) external onlyOwner {
        maxWalletTokens = amount * (10**9);
    }

    function changeSellFeeMultiplier(uint256 amount) external onlyOwner {
        sellTaxMultiplier = amount;
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

    function switchToken(address rewardToken, bool isIncludeHolders)
        public
        onlyOwner
    {
        require(
            rewardToken != router.WETH(),
            "Can not reward BNB in this tracker"
        );
        REWARD = rewardToken;
        // get current shareholders list
        address[] memory currentHolders = dividendTracker.getShareHoldersList();
        dividendTracker = new DividendDistributor(address(router), rewardToken);
        if (isIncludeHolders) {
            // add old share holders to new tracker
            for (uint256 i = 0; i < currentHolders.length; i++) {
                try
                    dividendTracker.setShare(
                        currentHolders[i],
                        _balances[currentHolders[i]]
                    )
                {} catch {}
            }
        }

        emit ChangeRewardTracker(rewardToken);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

pragma solidity >=0.5.0;

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

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

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
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
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

    uint256 public minPeriod = 30 * 60;
    uint256 public minDistribution = 1 * (10**9);

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
        router = _router != address(0)
            ? IUniswapV2Router02(_router)
            : IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        _token = msg.sender;
        REWARD = IERC20(rewardToken);
    }

    receive() external payable {}

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function purge(address receiver) external override onlyToken {
        uint256 balance = REWARD.balanceOf(address(this));
        REWARD.transfer(receiver, balance);
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
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
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit(uint256 amount) external override onlyToken {
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
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

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
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
            shares[shareholder].totalRealised = shares[shareholder]
                .totalRealised
                .add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
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

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
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
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity >=0.6.2;

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