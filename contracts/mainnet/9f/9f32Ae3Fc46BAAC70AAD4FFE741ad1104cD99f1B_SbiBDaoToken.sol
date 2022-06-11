/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;

    function claimDividend(address holder) external;
}

contract DividendDistributor is IDividendDistributor {
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    //Dex路由地址
    IDEXRouter router;
    //分红币
    IBEP20 RewardToken;

    //参与分红的地址列表
    address[] shareholders;
    //在分红地址列表里的位置
    mapping(address => uint256) shareholderIndexes;
    //已经领取的分红
    mapping(address => uint256) shareholderClaims;
    //地址分红份额
    mapping(address => Share) public shares;

    //总份额
    uint256 public totalShares;
    //总分红
    uint256 public totalDividends;
    //已经分配的分红
    uint256 public totalDistributed;
    //每个份额能领取的分红
    uint256 public dividendsPerShare;

    //合约里分红币总数量达到该值时开始分红
    uint256 public openDividends = 10 ** 18 * 1;

    //分红份额的因子，避免数值过小
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    //每个地址分红周期，地址在周期内只分红一次
    uint256 public minPeriod = 60 minutes;
    //地址的分红数量超过该值时，才发放分红
    uint256 public minDistribution = 10000 * (10 ** 18);

    //已经执行过的分红下标
    uint256 currentIndex;

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor (address RouterAddress, address RewardTokenAddress) {
        router = IDEXRouter(RouterAddress);
        RewardToken = IBEP20(RewardTokenAddress);
        _token = msg.sender;
    }

    //设置分红周期和最小分红数量要求
    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }

    //开放分红时，分红币的总数量要求
    function setOpenDividends(uint256 _openDividends) external onlyToken {
        openDividends = _openDividends * 10 ** 18;
    }

    //设置地址的份额
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        //本来有份额，先发放分红
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares - shares[shareholder].amount + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    //往分红合约里充值主链币，将主链币换成分红币
    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardToken);

        //将主链币换成分红币
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RewardToken.balanceOf(address(this)) - balanceBefore;
        totalDividends = totalDividends + amount;
        //累加每份额的分红
        dividendsPerShare = dividendsPerShare + (dividendsPerShareAccuracyFactor * amount / totalShares);
    }

    //根据gas按照顺序给地址列表发放分红
    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {return;}

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {currentIndex = 0;}
            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    //是否应该发放分红
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    //发放地址的分红
    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {return;}

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0 && totalDividends >= openDividends) {
            totalDistributed = totalDistributed + amount;
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised + amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

    }

    //获取未领取的分红
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {return 0;}

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {return 0;}

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    //份额数量累计的分红
    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share * dividendsPerShare / dividendsPerShareAccuracyFactor;
    }

    //添加分红地址
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    //移除分红地址
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    //领取某个地址的分红
    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }
}

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public authorized {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unAuthorize(address adr) public authorized {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
* @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual authorized {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public authorized {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

abstract contract AbsToken is IBEP20, Auth {
    string _name;
    string _symbol;
    uint8 _decimals;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    //分红代币
    address rewardTokenAddress;

    uint256 _totalSupply;

    //单笔最大交易量
    uint256 public  _maxTxAmount;
    //单钱包最大持有量
    uint256 public  _walletMax;
    //是否防巨鲸
    bool public restrictWhales = true;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    //是否手续费例外账户
    mapping(address => bool) public isFeeExempt;
    //是否单笔交易量限制例外账户
    mapping(address => bool) public isTxLimitExempt;
    //是否分红例外账户
    mapping(address => bool) public isDividendExempt;

    //回流
    uint256 public liquidityFee = 300;
    //营销
    uint256 public marketingFee = 0;
    //分红
    uint256 public rewardsFee = 700;
    //销毁
    uint256 public burnFee = 0;
    //空投
    uint256 public airdropFee = 0;
    //手续费的被除数，即分母
    uint256 private constant FeeFactor = 10000;

    //总手续费，不包括销毁和空投部分
    uint256 public totalFee = 1000;

    address public autoLiquidityReceiver;
    address public marketingWallet;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;

    //是否机器人
    mapping(address => bool) public isXXKING;

    DividendDistributor public dividendDistributor;
    //用于分红的gasLimit
    uint256 distributorGas = 300000;

    bool inSwapAndLiquidity;
    bool public swapAndLiquidityEnabled = true;

    //合约卖币换主链币的阀值
    uint256 public swapThreshold;

    uint256 private constant MAX = ~uint256(0);

    modifier lockTheSwap {
        inSwapAndLiquidity = true;
        _;
        inSwapAndLiquidity = false;
    }

    constructor(string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address MarketingWallet, address RouterAddress, address RewardTokenAddress) payable  Auth(msg.sender) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _totalSupply = Supply * 10 ** Decimals;
        _maxTxAmount = _totalSupply / 42;
        _walletMax = _totalSupply / 10;
        swapThreshold = _totalSupply / 50000000;
        marketingWallet = MarketingWallet;
        autoLiquidityReceiver = MarketingWallet;
        rewardTokenAddress = RewardTokenAddress;

        router = IDEXRouter(RouterAddress);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][RouterAddress] = MAX;
        dividendDistributor = new DividendDistributor(RouterAddress, RewardTokenAddress);

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[RouterAddress] = true;
        isFeeExempt[MarketingWallet] = true;
        isFeeExempt[DEAD] = true;

        isTxLimitExempt[MarketingWallet] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[RouterAddress] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[address(this)] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[RouterAddress] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        _balances[MarketingWallet] = _totalSupply;
        emit Transfer(address(0), MarketingWallet, _totalSupply);
    }

    receive() external payable {}

    function name() external view override returns (string memory) {return _name;}

    function symbol() external view override returns (string memory) {return _symbol;}

    function decimals() external view override returns (uint256) {return _decimals;}

    function totalSupply() external view override returns (uint256) {return _totalSupply;}

    function getOwner() external view override returns (address) {return owner;}

    function getCirculatingSupply() external view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}

    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, MAX);
    }

    //领取分红
    function claim() external {
        dividendDistributor.claimDividend(msg.sender);
    }

    function changeTxLimit(uint256 newLimit) external authorized {
        _maxTxAmount = newLimit;
    }

    function changeWalletLimit(uint256 newLimit) external authorized {
        _walletMax = newLimit;
    }

    function changeRestrictWhales(bool newValue) external authorized {
        restrictWhales = newValue;
    }

    function changeIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function changeIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;

        if (exempt) {
            dividendDistributor.setShare(holder, 0);
        } else {
            dividendDistributor.setShare(holder, _balances[holder]);
        }
    }

    function changeFs(uint256 newLiqFee, uint256 newRewardFee, uint256 newMarketingFee, uint256 newBurnFee, uint256 newAirdropFee) external authorized {
        liquidityFee = newLiqFee;
        rewardsFee = newRewardFee;
        marketingFee = newMarketingFee;
        burnFee = newBurnFee;
        airdropFee = newAirdropFee;

        totalFee = newLiqFee + newRewardFee + newMarketingFee;
        require(totalFee < 1201);
    }

    function changeFeeReceivers(address newLiquidityReceiver, address newMarketingWallet) external authorized {
        autoLiquidityReceiver = newLiquidityReceiver;
        marketingWallet = newMarketingWallet;
    }

    function changeSwapBackSettings(bool enableSwapBack, uint256 newSwapBackLimit) external authorized {
        swapAndLiquidityEnabled = enableSwapBack;
        swapThreshold = newSwapBackLimit;
    }

    function changeDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution) external authorized {
        dividendDistributor.setDistributionCriteria(newinPeriod, newMinDistribution);
    }

    function changeOpenDividends(uint256 openDividends) external authorized {
        dividendDistributor.setOpenDividends(openDividends);
    }

    function changeDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    } 
                 

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (inSwapAndLiquidity) {return _basicTransfer(sender, recipient, amount);}

        //机器人黑名单不让转出
        if (block.number > launchedAt) {
            require(!isXXKING[sender], "bot killed");
        }

        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");

        if (msg.sender != pair && !inSwapAndLiquidity && swapAndLiquidityEnabled && _balances[address(this)] >= swapThreshold) {swapBack();}

        //没有开盘，加完池子就开盘
        if (0 == launchedAt && recipient == pair) {
            require(_balances[sender] > 0 && isFeeExempt[sender]);
            launchedAt = block.number;
        }

        //杀机器人
        if (block.number < launchedAt + 4 && sender != owner && recipient != pair && !isFeeExempt[recipient]) {
            isXXKING[recipient] = true;
        }

        //Exchange tokens
        _balances[sender] = _balances[sender] - amount;

        //单钱包限制
        if (!isTxLimitExempt[recipient] && restrictWhales) {
            require(_balances[recipient] + amount <= _walletMax);
        }

        //计算最终接收数量
        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient] ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient] + finalAmount;

        //设置转出地址分红份额
        if (!isDividendExempt[sender]) {
            try dividendDistributor.setShare(sender, _balances[sender]) {} catch {}
        }

        //设置转入地址分红份额
        if (!isDividendExempt[recipient]) {
            try dividendDistributor.setShare(recipient, _balances[recipient]) {} catch {}
        }

        //根据顺序分红
        try dividendDistributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    //扣除手续费，返回扣税后数量
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        //总手续费，不包含销毁和空投部分
        uint256 feeAmount = amount * totalFee / FeeFactor;
        //销毁数量
        uint256 burnAmount = amount * burnFee / FeeFactor;
        //空投数量
        uint256 airdropAmount;

        //总手续费，不包含销毁和空投部分，留在代币合约里
        _balances[address(this)] = _balances[address(this)] + feeAmount;
        emit Transfer(sender, address(this), feeAmount);

        //销毁
        if (burnFee > 0) {
            _balances[address(DEAD)] = _balances[address(DEAD)] + burnAmount;
            emit Transfer(sender, address(DEAD), burnAmount);
        }

        //空投到地址
        if (airdropFee > 0 && airDropList.length > 0 && airDropNum > 0) {
            airdropAmount = amount * airdropFee / FeeFactor;
            if (airDropIndex >= airDropList.length) {
                airDropIndex = 0;
            }
            uint256 start = airDropIndex;
            uint256 end = airDropIndex + airDropNum;
            if (end > airDropList.length) {
                end = airDropList.length;
            }
            airDropIndex = end;
            uint256 perDropAmount = airdropAmount / (end - start);
            address airdropAddress;
            for (; start < end; ++start) {
                airdropAddress = airDropList[start];
                _balances[airdropAddress] = _balances[airdropAddress] + perDropAmount;
                emit Transfer(sender, airdropAddress, perDropAmount);
            }
        }

        return amount - feeAmount - burnAmount - airdropAmount;
    }

    //设置为机器人
    function AntiBot(address _user) external authorized {
        require(!isXXKING[_user], "killing bot");
        isXXKING[_user] = true;
    }

    //修改代币名称和符号
    function setName(string calldata name1, string calldata symbol1) external authorized {
        _name = name1;
        _symbol = symbol1;
    }

    //移除机器人
    function removeFromBot(address _user) external authorized {
        require(isXXKING[_user], "release bot");
        isXXKING[_user] = false;
    }

    //提取合约里的代币
    function recoverBEP20(address tokenAddress, uint256 tokenAmount) public authorized {
        IBEP20(tokenAddress).transfer(msg.sender, tokenAmount);
    }

    //提取合约里的主链币
    function recoverBNB(uint256 tokenAmount) public authorized {
        payable(address(msg.sender)).transfer(tokenAmount);
    }

    //用合约里的币换BNB，进行分红，营销，回流
    function swapBack() internal lockTheSwap {
        uint256 tokensToLiquidity = swapThreshold;

        //用于回流添加流动性的代币数量
        uint256 amountToLiquidity = tokensToLiquidity * liquidityFee / totalFee / 2;
        //兑换为主链币的代币数量
        uint256 amountToSwap = tokensToLiquidity - amountToLiquidity;

        //将合约里的本币兑换为主链币
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;

        uint256 totalBNBFee = totalFee - liquidityFee / 2;

        //用于回流添加流动性的主链币
        uint256 amountBNBLiquidity = amountBNB * liquidityFee / totalBNBFee / 2;
        //分红
        uint256 amountBNBReflection = amountBNB * rewardsFee / totalBNBFee;
        //营销钱包
        uint256 amountBNBMarketing = amountBNB - amountBNBLiquidity - amountBNBReflection;
        //给分红合约充值
        try dividendDistributor.deposit{value : amountBNBReflection}() {} catch {}
        //换成分红币转到营销钱包
        path[0] = router.WETH();
        path[1] = rewardTokenAddress;
        //将主链币换成分红币
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : amountBNBMarketing}(
            0,
            path,
            marketingWallet,
            block.timestamp
        );

        //回流添加流动性
        if (amountToLiquidity > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquidity,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquidity(amountBNBLiquidity, amountToLiquidity);
        }
    }

    event AutoLiquidity(uint256 amountBNB, uint256 amountBOG);

    //空投地址列表
    address[] private airDropList;
    //已空投下标
    uint256 airDropIndex = 0;
    //一次空投地址数量
    uint256 airDropNum = 3;

    //设置空投地址
    function setAirDropList(address[] calldata adl) public authorized {
        airDropList = adl;
        airDropIndex = 0;
    }

    //添加空投地址
    function addAirDropList(address[] calldata adl) public authorized {
        uint256 len = adl.length;
        for (uint256 i; i < len; ++i) {
            airDropList.push(adl[i]);
        }
    }
}

contract SbiBDaoToken is AbsToken {
    constructor() AbsToken(
    //名称
        "BTCs",
    //符号
        "BTCs",
    //精度
        9,
    //总量
        21000000,
    //营销钱包
        address(0x0000000000000000000000000000000000000000),
    //路由合约地址
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //分红币合约地址
        address(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c)
    ){}
}