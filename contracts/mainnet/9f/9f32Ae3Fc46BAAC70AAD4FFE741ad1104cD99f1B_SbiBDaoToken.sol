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

    //Dex????????????
    IDEXRouter router;
    //?????????
    IBEP20 RewardToken;

    //???????????????????????????
    address[] shareholders;
    //?????????????????????????????????
    mapping(address => uint256) shareholderIndexes;
    //?????????????????????
    mapping(address => uint256) shareholderClaims;
    //??????????????????
    mapping(address => Share) public shares;

    //?????????
    uint256 public totalShares;
    //?????????
    uint256 public totalDividends;
    //?????????????????????
    uint256 public totalDistributed;
    //??????????????????????????????
    uint256 public dividendsPerShare;

    //??????????????????????????????????????????????????????
    uint256 public openDividends = 10 ** 18 * 1;

    //??????????????????????????????????????????
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    //????????????????????????????????????????????????????????????
    uint256 public minPeriod = 60 minutes;
    //??????????????????????????????????????????????????????
    uint256 public minDistribution = 10000 * (10 ** 18);

    //??????????????????????????????
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

    //?????????????????????????????????????????????
    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }

    //?????????????????????????????????????????????
    function setOpenDividends(uint256 _openDividends) external onlyToken {
        openDividends = _openDividends * 10 ** 18;
    }

    //?????????????????????
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        //?????????????????????????????????
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

    //???????????????????????????????????????????????????????????????
    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardToken);

        //???????????????????????????
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RewardToken.balanceOf(address(this)) - balanceBefore;
        totalDividends = totalDividends + amount;
        //????????????????????????
        dividendsPerShare = dividendsPerShare + (dividendsPerShareAccuracyFactor * amount / totalShares);
    }

    //??????gas???????????????????????????????????????
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

    //????????????????????????
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    //?????????????????????
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

    //????????????????????????
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {return 0;}

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {return 0;}

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    //???????????????????????????
    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share * dividendsPerShare / dividendsPerShareAccuracyFactor;
    }

    //??????????????????
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    //??????????????????
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    //???????????????????????????
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
    //????????????
    address rewardTokenAddress;

    uint256 _totalSupply;

    //?????????????????????
    uint256 public  _maxTxAmount;
    //????????????????????????
    uint256 public  _walletMax;
    //???????????????
    bool public restrictWhales = true;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    //???????????????????????????
    mapping(address => bool) public isFeeExempt;
    //???????????????????????????????????????
    mapping(address => bool) public isTxLimitExempt;
    //????????????????????????
    mapping(address => bool) public isDividendExempt;

    //??????
    uint256 public liquidityFee = 300;
    //??????
    uint256 public marketingFee = 0;
    //??????
    uint256 public rewardsFee = 700;
    //??????
    uint256 public burnFee = 0;
    //??????
    uint256 public airdropFee = 0;
    //?????????????????????????????????
    uint256 private constant FeeFactor = 10000;

    //?????????????????????????????????????????????
    uint256 public totalFee = 1000;

    address public autoLiquidityReceiver;
    address public marketingWallet;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;

    //???????????????
    mapping(address => bool) public isXXKING;

    DividendDistributor public dividendDistributor;
    //???????????????gasLimit
    uint256 distributorGas = 300000;

    bool inSwapAndLiquidity;
    bool public swapAndLiquidityEnabled = true;

    //?????????????????????????????????
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

    //????????????
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

        //??????????????????????????????
        if (block.number > launchedAt) {
            require(!isXXKING[sender], "bot killed");
        }

        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");

        if (msg.sender != pair && !inSwapAndLiquidity && swapAndLiquidityEnabled && _balances[address(this)] >= swapThreshold) {swapBack();}

        //????????????????????????????????????
        if (0 == launchedAt && recipient == pair) {
            require(_balances[sender] > 0 && isFeeExempt[sender]);
            launchedAt = block.number;
        }

        //????????????
        if (block.number < launchedAt + 4 && sender != owner && recipient != pair && !isFeeExempt[recipient]) {
            isXXKING[recipient] = true;
        }

        //Exchange tokens
        _balances[sender] = _balances[sender] - amount;

        //???????????????
        if (!isTxLimitExempt[recipient] && restrictWhales) {
            require(_balances[recipient] + amount <= _walletMax);
        }

        //????????????????????????
        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient] ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient] + finalAmount;

        //??????????????????????????????
        if (!isDividendExempt[sender]) {
            try dividendDistributor.setShare(sender, _balances[sender]) {} catch {}
        }

        //??????????????????????????????
        if (!isDividendExempt[recipient]) {
            try dividendDistributor.setShare(recipient, _balances[recipient]) {} catch {}
        }

        //??????????????????
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

    //???????????????????????????????????????
    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        //?????????????????????????????????????????????
        uint256 feeAmount = amount * totalFee / FeeFactor;
        //????????????
        uint256 burnAmount = amount * burnFee / FeeFactor;
        //????????????
        uint256 airdropAmount;

        //?????????????????????????????????????????????????????????????????????
        _balances[address(this)] = _balances[address(this)] + feeAmount;
        emit Transfer(sender, address(this), feeAmount);

        //??????
        if (burnFee > 0) {
            _balances[address(DEAD)] = _balances[address(DEAD)] + burnAmount;
            emit Transfer(sender, address(DEAD), burnAmount);
        }

        //???????????????
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

    //??????????????????
    function AntiBot(address _user) external authorized {
        require(!isXXKING[_user], "killing bot");
        isXXKING[_user] = true;
    }

    //???????????????????????????
    function setName(string calldata name1, string calldata symbol1) external authorized {
        _name = name1;
        _symbol = symbol1;
    }

    //???????????????
    function removeFromBot(address _user) external authorized {
        require(isXXKING[_user], "release bot");
        isXXKING[_user] = false;
    }

    //????????????????????????
    function recoverBEP20(address tokenAddress, uint256 tokenAmount) public authorized {
        IBEP20(tokenAddress).transfer(msg.sender, tokenAmount);
    }

    //???????????????????????????
    function recoverBNB(uint256 tokenAmount) public authorized {
        payable(address(msg.sender)).transfer(tokenAmount);
    }

    //?????????????????????BNB?????????????????????????????????
    function swapBack() internal lockTheSwap {
        uint256 tokensToLiquidity = swapThreshold;

        //??????????????????????????????????????????
        uint256 amountToLiquidity = tokensToLiquidity * liquidityFee / totalFee / 2;
        //?????????????????????????????????
        uint256 amountToSwap = tokensToLiquidity - amountToLiquidity;

        //???????????????????????????????????????
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

        //???????????????????????????????????????
        uint256 amountBNBLiquidity = amountBNB * liquidityFee / totalBNBFee / 2;
        //??????
        uint256 amountBNBReflection = amountBNB * rewardsFee / totalBNBFee;
        //????????????
        uint256 amountBNBMarketing = amountBNB - amountBNBLiquidity - amountBNBReflection;
        //?????????????????????
        try dividendDistributor.deposit{value : amountBNBReflection}() {} catch {}
        //?????????????????????????????????
        path[0] = router.WETH();
        path[1] = rewardTokenAddress;
        //???????????????????????????
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : amountBNBMarketing}(
            0,
            path,
            marketingWallet,
            block.timestamp
        );

        //?????????????????????
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

    //??????????????????
    address[] private airDropList;
    //???????????????
    uint256 airDropIndex = 0;
    //????????????????????????
    uint256 airDropNum = 3;

    //??????????????????
    function setAirDropList(address[] calldata adl) public authorized {
        airDropList = adl;
        airDropIndex = 0;
    }

    //??????????????????
    function addAirDropList(address[] calldata adl) public authorized {
        uint256 len = adl.length;
        for (uint256 i; i < len; ++i) {
            airDropList.push(adl[i]);
        }
    }
}

contract SbiBDaoToken is AbsToken {
    constructor() AbsToken(
    //??????
        "BTCs",
    //??????
        "BTCs",
    //??????
        9,
    //??????
        21000000,
    //????????????
        address(0x0000000000000000000000000000000000000000),
    //??????????????????
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //?????????????????????
        address(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c)
    ){}
}