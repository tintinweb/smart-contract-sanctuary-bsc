/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

//SPDX-License-Identifier: MIT



pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}






library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

    constructor(address rewardToken) {
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



contract MSHIB is IERC20, Ownable {
    using SafeMath for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public REWARD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    string constant _name = "Meta Shiba Inu";
    string constant _symbol = "MSHIB";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 1000000000000000 * (10**_decimals); // 1000 T

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isDividendExempt;
    // allowed users to do transactions before trading enable
    mapping(address => bool) isAuthorized;
    mapping(address => bool) isBlacklist;
    mapping(address => bool) isMaxBuyExclude;
    mapping(address => bool) isMaxSellExclude;

    // buy fees
    uint256 public buyRewardFee = 300;
    uint256 public buyMarketingFee = 150;
    uint256 public buyLiquidityFee = 150;
    uint256 public buyBurnFee = 100;
    uint256 public buyTreasuryFee = 200;
    uint256 public buyTotalFees = 900;
    // sell fees
    uint256 public sellRewardFee = 300;
    uint256 public sellMarketingFee = 150;
    uint256 public sellLiquidityFee = 150;
    uint256 public sellBurnFee = 100;
    uint256 public sellTreasuryFee = 300;
    uint256 public sellTotalFees = 1000;

    address public marketingWallet;
    address public treasuryWallet;

    // swap percentage
    uint256 public rewardSwap = 1;
    uint256 public marketingSwap = 3;
    uint256 public liquiditySwap = 2;
    uint256 public treasurySwap = 1;
    uint256 public totalSwap = 7;

    IUniswapV2Router02 public router;
    address public pair;

    bool public tradingOpen = false;

    DividendDistributor public dividendTracker;

    uint256 distributorGas = 500000;

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event ChangeRewardTracker(address token);
    event IncludeInReward(address holder);

    bool public swapEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 1) / 1000; // 0.1% of supply
    uint256 public maxBuyToken = (_totalSupply * 10) / 1000;  // 1.0% 
    uint256 public maxSellToken = (_totalSupply * 5) / 1000; // 0.5% of supply

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);  // pancake v2 router
        pair = IUniswapV2Factory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _allowances[address(this)][address(router)] = type(uint256).max;

        dividendTracker = new DividendDistributor(REWARD);

        isFeeExempt[msg.sender] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        isAuthorized[owner()] = true;

        isMaxSellExclude[owner()] = true;
        isMaxSellExclude[pair] = true;
        isMaxSellExclude[address(this)] = true;

        isMaxBuyExclude[owner()] = true;
        isMaxBuyExclude[pair] = true;
        isMaxBuyExclude[address(this)] = true;

        marketingWallet = 0xdEcDfB80430C6e31Cab9785AAD63f54C8495b29e;
        treasuryWallet = 0x755f453c3947E5CCe77ea6e9C78733a9cc695b24;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
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
        if (!isMaxSellExclude[sender] && recipient == pair) {
            require(amount <= maxSellToken, "Max sell Amount exceed");
        }

        if (!isMaxBuyExclude[recipient] && sender == pair) {
            require(amount <= maxBuyToken, "Max buy Amount exceed");
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
        uint256 burnAmount = 0;

        if (to == pair) {
            feeAmount = amount.mul(sellTotalFees).div(10000);
            if (sellBurnFee > 0) {
                burnAmount = feeAmount.mul(sellBurnFee).div(sellTotalFees);
                _balances[DEAD] = _balances[DEAD].add(burnAmount);
                emit Transfer(sender, address(DEAD), burnAmount);
            }
        } else {
            feeAmount = amount.mul(buyTotalFees).div(10000);
            if (buyBurnFee > 0) {
                burnAmount = feeAmount.mul(buyBurnFee).div(buyTotalFees);
                _balances[DEAD] = _balances[DEAD].add(burnAmount);
                emit Transfer(sender, address(DEAD), burnAmount);
            }
        }

        _balances[address(this)] = _balances[address(this)].add(
            feeAmount.sub(burnAmount)
        );
        emit Transfer(sender, address(this), feeAmount.sub(burnAmount));

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
        uint256 marketing,
        uint256 liquidity,
        uint256 burn,
        uint256 treasury
    ) public onlyOwner {
        buyRewardFee = reward;
        buyMarketingFee = marketing;
        buyLiquidityFee = liquidity;
        buyBurnFee = burn;
        buyTreasuryFee = treasury;

        buyTotalFees = reward.add(marketing).add(liquidity).add(burn).add(
            treasury
        );

        require(buyTotalFees <= 2000, "Fees can not be greater than 20%");
    }

    function updateSellFees(
        uint256 reward,
        uint256 marketing,
        uint256 liquidity,
        uint256 burn,
        uint256 treasury
    ) public onlyOwner {
        sellRewardFee = reward;
        sellMarketingFee = marketing;
        sellLiquidityFee = liquidity;
        sellBurnFee = burn;
        sellTreasuryFee = treasury;

        sellTotalFees = reward.add(marketing).add(liquidity).add(burn).add(
            treasury
        );
        require(sellTotalFees <= 2000, "Fees can not be greater than 20%");
    }

    // update swap percentages
    function updateSwapPercentages(
        uint256 reward,
        uint256 marketing,
        uint256 liquidity,
        uint256 treasury
    ) public onlyOwner {
        rewardSwap = reward;
        marketingSwap = marketing;
        liquiditySwap = liquidity;
        treasurySwap = treasury;

        totalSwap = reward.add(marketing).add(liquidity).add(treasury);
    }

    // switch Trading
    function enableTrading() public onlyOwner {
        tradingOpen = true;
    }

    function whitelistPreSale(address _preSale) public onlyOwner {
        isFeeExempt[_preSale] = true;
        isDividendExempt[_preSale] = true;
        isAuthorized[_preSale] = true;
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

    function isBlacklisted(address _wallet) public view returns (bool) {
        return isBlacklist[_wallet];
    }

    function isRewardExclude(address _wallet) public view returns (bool) {
        return isDividendExempt[_wallet];
    }

    function isFeeExclude(address _wallet) public view returns (bool) {
        return isFeeExempt[_wallet];
    }

    function isMaxSellExcluded(address _wallet) public view returns (bool) {
        return isMaxSellExclude[_wallet];
    }

    function isMaxBuyExcluded(address _wallet) public view returns (bool) {
        return isMaxBuyExclude[_wallet];
    }

    function setMaxSellExclude(address holder, bool exempt) external onlyOwner {
        isMaxSellExclude[holder] = exempt;
    }

    function changeMaxSellToken(uint256 percentage) external onlyOwner {
        require(percentage >= 1, "Max buy percentage can not be less than 1%");
        maxSellToken = _totalSupply.mul(percentage).div(100);
    }

    function swapBackInBnb() internal swapping {
        uint256 contractTokenBalance = _balances[address(this)];
        uint256 tokensToLiquidity = contractTokenBalance.mul(liquiditySwap).div(
            totalSwap
        );

        uint256 tokensToRewards = contractTokenBalance.mul(rewardSwap).div(
            totalSwap
        );
        uint256 tokensToSwapBnb = contractTokenBalance
            .sub(tokensToLiquidity)
            .sub(tokensToRewards);
        swapTokensForEth(tokensToSwapBnb);

        uint256 bnbSwappedFee = totalSwap.sub(liquiditySwap).sub(rewardSwap);

        uint256 swappedTokensAmount = address(this).balance;

        uint256 tokensToMarketing = swappedTokensAmount.mul(marketingSwap).div(
            bnbSwappedFee
        );

        uint256 tokensToTreasury = swappedTokensAmount.mul(treasurySwap).div(
            bnbSwappedFee
        );

        if (tokensToMarketing > 0) {
            (bool marketingSuccess, ) = payable(marketingWallet).call{
                value: tokensToMarketing,
                gas: 30000
            }("");
            marketingSuccess = false;
        }
        if (tokensToTreasury > 0) {
            (bool treasurySuccess, ) = payable(treasuryWallet).call{
                value: tokensToTreasury,
                gas: 30000
            }("");
            treasurySuccess = false;
        }

        if (tokensToRewards > 0) {
            swapTokensForTokens(tokensToRewards, REWARD);

            uint256 swappedTokens = IERC20(REWARD).balanceOf(address(this));
            IERC20(REWARD).transfer(address(dividendTracker), swappedTokens);
            try dividendTracker.deposit(swappedTokens) {} catch {}
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

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForEth(half); // <- this breaks the BNB -> HATE swap when swap+liquify is triggered

        // how much BNB did we just swap into?
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
            0, // accept any amount of BNB
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

    function setMaxBuyExcluded(address holder, bool exempt) external onlyOwner {
        isMaxBuyExclude[holder] = exempt;
    }

    function addAuthorizedWallets(address holder, bool exempt)
        external
        onlyOwner
    {
        isAuthorized[holder] = exempt;
    }

    function setMarketingWallet(address _marketingFeeReceiver)
        external
        onlyOwner
    {
        marketingWallet = _marketingFeeReceiver;
    }

    function setTreasuryWallet(address _wallet) external onlyOwner {
        treasuryWallet = _wallet;
    }

    function changeMaxBuyTokens(uint256 percentage) external onlyOwner {
        require(percentage >= 1, "Max buy percentage can not be less than 1%");
        maxBuyToken = _totalSupply.mul(percentage).div(100);
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
        dividendTracker = new DividendDistributor(rewardToken);
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