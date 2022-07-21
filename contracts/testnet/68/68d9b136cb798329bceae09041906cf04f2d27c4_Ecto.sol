//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.9;

import "./interfaces/IDEXFactory.sol";
import "./interfaces/IDEXRouter.sol";
import "./DividendDistributor.sol";
import "./abstracts/Auth.sol";
import "./abstracts/NewBEP20Token.sol";
import "./structs/Share.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Ecto is NewBEP20Token, Auth, ReentrancyGuard {
    string constant _name = "LittleGhosts Ectoplasm";
    string constant _symbol = "ECTO";

    address ZERO = 0x0000000000000000000000000000000000000000;
    address[] public circulatingSupplyExclusions = [DEAD, ZERO];
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address RewardToken = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47; //BUSD
    bool rewardTokenHasTxFee = false;

    uint256 public _maxTxAmount = (_totalSupply * 2) / 200;
    uint256 public _walletMax = (_totalSupply * 3) / 100;

    bool public restrictWhales = true;

    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isDividendExempt;

    uint256 public liquidityFee = 7;
    uint256 public rewardsFee = 8;
    uint256 public extraFeeOnSell = 0;

    uint256 public totalFee = 0;
    uint256 public totalFeeIfSelling = 0;

    address public autoLiquidityReceiver;

    address public teamWallet;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    bool public tradingOpen = false;

    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 500000;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;

    uint256 public swapThreshold = (_totalSupply * 5) / 4000;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    event TradingStatusChanged(bool status);
    event RouterChanged(address newRouterAddress);
    event TeamWalletChanged(address newTeamWallet);
    event AddedToCirculatingSupplyExclusion(address _address);
    event RemovedFromCirculatingSupplyExclusion(address _address);

    constructor(address _oldContractAddress)
        Auth(msg.sender)
        ReentrancyGuard()
        NewBEP20Token(_oldContractAddress)
    {
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _allowances[address(this)][address(router)] = type(uint256).max;

        teamWallet = 0x896986Db81727B2C7253cE533DF44fC6A42d7A78;

        dividendDistributor = new DividendDistributor(address(router));

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        totalFee = liquidityFee + rewardsFee;
        totalFeeIfSelling = totalFee + extraFeeOnSell;
    }

    receive() external payable {}

    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getCirculatingSupply() public view returns (uint256) {
        uint256 result = _totalSupply;
        for (uint256 i = 0; i < circulatingSupplyExclusions.length; i++) {
            result = result - balanceOf(circulatingSupplyExclusions[i]);
        }
        return result;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function changeTxLimit(uint256 newLimit) external authorized {
        _maxTxAmount = newLimit;
    }

    function changeWalletLimit(uint256 newLimit) external authorized {
        _walletMax = newLimit;
    }

    function changeRewardToken(address token, bool chargeTxFee)
        external
        authorized
    {
        RewardToken = token;
        rewardTokenHasTxFee = chargeTxFee;
        dividendDistributor.setRewardToken(token, chargeTxFee);
    }

    function changeRestrictWhales(bool newValue) external authorized {
        restrictWhales = newValue;
    }

    function changeIsFeeExempt(address holder, bool exempt)
        external
        authorized
    {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt)
        external
        authorized
    {
        isTxLimitExempt[holder] = exempt;
    }

    function changeIsDividendExempt(address holder, bool exempt)
        external
        authorized
    {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;

        if (exempt) {
            dividendDistributor.setShare(holder, 0);
        } else {
            dividendDistributor.setShare(holder, _balances[holder]);
        }
    }

    function changeFees(
        uint256 newLiqFee,
        uint256 newRewardFee,
        uint256 newExtraSellFee
    ) external authorized {
        liquidityFee = newLiqFee;
        rewardsFee = newRewardFee;
        extraFeeOnSell = newExtraSellFee;

        totalFee = liquidityFee + rewardsFee;
        totalFeeIfSelling = totalFee + extraFeeOnSell;
    }

    function changeFeeReceivers(address newLiquidityReceiver)
        external
        authorized
    {
        autoLiquidityReceiver = newLiquidityReceiver;
    }

    function changeSwapBackSettings(
        bool enableSwapBack,
        uint256 newSwapBackLimit,
        bool swapByLimitOnly
    ) external authorized {
        swapAndLiquifyEnabled = enableSwapBack;
        swapThreshold = newSwapBackLimit;
        swapAndLiquifyByLimitOnly = swapByLimitOnly;
    }

    function changeDistributionCriteria(
        uint256 newinPeriod,
        uint256 newMinDistribution
    ) external authorized {
        dividendDistributor.setDistributionCriteria(
            newinPeriod,
            newMinDistribution
        );
    }

    function changeDistributorSettings(uint256 gas) external authorized {
        require(gas < 1500000);
        distributorGas = gas;
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        nonReentrant
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override nonReentrant returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(
                amount <= _allowances[sender][msg.sender],
                "Insufficient Allowance"
            );
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (!authorizations[sender] && !authorizations[recipient]) {
            require(tradingOpen, "Trading not open yet");
        }

        require(
            amount <= _maxTxAmount || isTxLimitExempt[sender],
            "TX Limit Exceeded"
        );

        if (
            msg.sender != pair &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            _balances[address(this)] >= swapThreshold
        ) {
            swapBack();
        }

        if (!launched() && recipient == pair) {
            require(_balances[sender] > 0);
            launch();
        }

        //Exchange tokens
        require(amount <= _balances[sender], "Insufficient Balance");
        _balances[sender] = _balances[sender] - amount;

        if (!isTxLimitExempt[recipient] && restrictWhales) {
            require(_balances[recipient] + amount <= _walletMax);
        }

        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient]
            ? takeFee(sender, recipient, amount)
            : amount;
        _balances[recipient] = _balances[recipient] + finalAmount;

        // Dividend tracker
        if (!isDividendExempt[sender]) {
            try
                dividendDistributor.setShare(sender, _balances[sender])
            {} catch {}
        }

        if (!isDividendExempt[recipient]) {
            try
                dividendDistributor.setShare(recipient, _balances[recipient])
            {} catch {}
        }

        try dividendDistributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(amount <= _balances[sender], "Insufficient Balance");
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeApplicable = pair == recipient
            ? totalFeeIfSelling
            : totalFee;
        uint256 feeAmount = (amount * feeApplicable) / 100;

        _balances[address(this)] = _balances[address(this)] + (feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount - feeAmount;
    }

    function tradingStatus(bool newStatus) public onlyOwner {
        tradingOpen = newStatus;

        emit TradingStatusChanged(newStatus);
    }

    function transferToWallet(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    function swapBack() internal lockTheSwap {
        uint256 tokensToLiquify = _balances[address(this)];
        uint256 amountToSwap = tokensToLiquify;

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

        uint256 totalBNBFee = totalFee;

        uint256 amountBNBLiquidity = (amountBNB * liquidityFee) / totalBNBFee;
        uint256 amountBNBReflection = (amountBNB * rewardsFee) / totalBNBFee;

        try
            dividendDistributor.deposit{value: amountBNBReflection}()
        {} catch {}

        transferToWallet(payable(teamWallet), amountBNBLiquidity);
    }

    function switchRouter(address _newRouterAddress) public onlyOwner {
        router = IDEXRouter(_newRouterAddress);
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _allowances[address(this)][address(router)] = type(uint256).max;

        dividendDistributor.setRouter(_newRouterAddress);

        isTxLimitExempt[pair] = true;

        isDividendExempt[pair] = true;

        emit RouterChanged(_newRouterAddress);
    }

    function switchDistributor() public onlyOwner {
        DividendDistributor _dividendDistributor;
        _dividendDistributor = new DividendDistributor(address(router));

        _dividendDistributor.migrateDistributorStates(
            dividendDistributor.getShareHolders(),
            dividendDistributor.getShareholderIndexes(),
            dividendDistributor.currentIndex(),
            dividendDistributor.getShares(),
            dividendDistributor.totalShares(),
            dividendDistributor.totalDividends(),
            dividendDistributor.totalDistributed(),
            dividendDistributor.dividendsPerShare()
        );
    }

    function switchTeamWallet(address _newTeamWallet) public onlyOwner {
        teamWallet = _newTeamWallet;

        emit TeamWalletChanged(_newTeamWallet);
    }

    function addToCirculatingSupplyExclusion(address _address)
        external
        authorized
    {
        bool exists = false;
        uint256 i = 0;
        for (i; i < circulatingSupplyExclusions.length; i++) {
            address exclusion = circulatingSupplyExclusions[i];
            if (exclusion == _address) {
                exists = true;
                break;
            }
        }
        if (!exists) {
            circulatingSupplyExclusions.push(_address);
            emit AddedToCirculatingSupplyExclusion(_address);
        }
    }

    function removeFromCirculatingSupplyExclusion(address _address)
        external
        authorized
    {
        bool found = false;
        uint256 i = 0;
        for (i; i < circulatingSupplyExclusions.length; i++) {
            address exclusion = circulatingSupplyExclusions[i];
            if (exclusion == _address) {
                found = true;
                break;
            }
        }
        if (found) {
            circulatingSupplyExclusions[i] = circulatingSupplyExclusions[
                circulatingSupplyExclusions.length - 1
            ];
            circulatingSupplyExclusions.pop();
            emit RemovedFromCirculatingSupplyExclusion(_address);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDEXRouter {
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
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

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

    function swapExactETHForTokens(
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IDividendDistributor.sol";
import "./interfaces/IDEXRouter.sol";
import "./interfaces/IBEP20.sol";

contract DividendDistributor is IDividendDistributor, ReentrancyGuard {
    address _token;

    IDEXRouter router;
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IBEP20 RewardToken = IBEP20(0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47); //BUSD
    bool rewardTokenHasTxFee = false;

    address[] shareholders;
    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;
    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 30 minutes;
    uint256 public minDistribution = 1 * (10**18);

    uint256 public currentIndex;

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

    event DistributionCriteriaChanged(
        uint256 newMinPeriod,
        uint256 newMinDistribution
    );

    event HolderShareChanged(
        address indexed shareholder,
        uint256 amount,
        uint256 totalExcluded
    );

    event RewardTokenChanged(address indexed token, bool chargeTxFee);

    event Deposited(
        address rewardToken,
        uint256 amount,
        uint256 totalDividends,
        uint256 dividendsPerShare
    );

    event Processed(
        uint256 gasUsed,
        uint256 gasLeft,
        uint256 currentIndex,
        uint256 iterations
    );

    event RouterChanged(address _router);

    constructor(address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(routerAddress);
        _token = msg.sender;
    }

    function setDistributionCriteria(
        uint256 newMinPeriod,
        uint256 newMinDistribution
    ) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;

        emit DistributionCriteriaChanged(newMinPeriod, newMinDistribution);
    }

    function setRewardToken(address token, bool chargeTxFee)
        external
        onlyToken
    {
        RewardToken = IBEP20(token); //BUSD
        rewardTokenHasTxFee = chargeTxFee;

        emit RewardTokenChanged(token, chargeTxFee);
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        nonReentrant
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

        totalShares = totalShares - shares[shareholder].amount + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );

        emit HolderShareChanged(
            shareholder,
            amount,
            shares[shareholder].totalExcluded
        );
    }

    function setRouter(address _router) external override onlyToken {
        router = IDEXRouter(_router);
        emit RouterChanged(_router);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardToken);

        if (rewardTokenHasTxFee) {
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: msg.value
            }(0, path, address(this), block.timestamp);
        } else {
            router.swapExactETHForTokens{value: msg.value}(
                0,
                path,
                address(this),
                block.timestamp
            );
        }

        uint256 amount = RewardToken.balanceOf(address(this)) - balanceBefore;
        totalDividends = totalDividends + amount;
        dividendsPerShare =
            dividendsPerShare +
            ((dividendsPerShareAccuracyFactor * amount) / totalShares);

        emit Deposited(
            address(RewardToken),
            amount,
            totalDividends,
            dividendsPerShare
        );
    }

    function process(uint256 gas) external override onlyToken nonReentrant {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        emit Processed(gasUsed, gasLeft, currentIndex, iterations);
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
            totalDistributed = totalDistributed + amount;
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised =
                shares[shareholder].totalRealised +
                amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend() external nonReentrant {
        require(shouldDistribute(msg.sender), "Too soon. Need to wait!");
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

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return (share * dividendsPerShare) / dividendsPerShareAccuracyFactor;
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

    function getShareHolders() external view returns (address[] memory) {
        return shareholders;
    }

    function getShareholderIndexes() public view returns (uint256[] memory) {
        uint256[] memory indexes = new uint256[](shareholders.length);

        for (uint256 i = 0; i < shareholders.length; i++) {
            indexes[i] = shareholderIndexes[shareholders[i]];
        }
        return indexes;
    }

    function getShares() public view returns (Share[] memory) {
        Share[] memory _shares = new Share[](shareholders.length);

        for (uint256 i = 0; i < shareholders.length; i++) {
            _shares[i] = shares[shareholders[i]];
        }
        return _shares;
    }

    function migrateDistributorStates(
        address[] calldata _shareHolders,
        uint256[] calldata _shareHolderIndexes,
        uint256 _currentIndex,
        Share[] calldata _shares,
        uint256 _totalShare,
        uint256 _totalDividends,
        uint256 _totalDistributed,
        uint256 _dividendsPerShare
    ) external override onlyToken {
        require(
            _shareHolders.length == _shareHolderIndexes.length &&
                _shareHolderIndexes.length == _shares.length,
            "Unequal length"
        );

        shareholders = _shareHolders;
        currentIndex = _currentIndex;

        for (uint256 i = 0; i < _shareHolders.length; i++) {
            shareholderIndexes[_shareHolders[i]] = _shareHolderIndexes[i];
            shares[_shareHolders[i]] = _shares[i];
        }

        totalShares = _totalShare;
        totalDividends = _totalDividends;
        totalDistributed = _totalDistributed;
        dividendsPerShare = _dividendsPerShare;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;

        emit Authorized(adr);
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;

        emit Unauthorized(adr);
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
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
    event Authorized(address adr);
    event Unauthorized(address adr);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IBEP20.sol";
import "../abstracts/Auth.sol";

abstract contract NewBEP20Token is IBEP20 {
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 1 * 10**12 * (10**_decimals);
    mapping(address => uint256) _balances;

    address internal oldTokenAddress;
    IBEP20 internal OldToken;
    uint256 public burned; // To keep track of migrated tokens for burned address

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    constructor(address _oldContractAddress) {
        oldTokenAddress = _oldContractAddress;
        OldToken = IBEP20(_oldContractAddress);

        burned = OldToken.balanceOf(DEAD);

        _balances[address(this)] = _totalSupply - burned;
        emit Transfer(address(0), address(this), _balances[address(this)]);

        /* Transfer new tokens to burned address based on the amount of old tokens that were burned */
        _balances[DEAD] = burned;
        emit Transfer(address(0), DEAD, burned);
    }

    function migrate() external {
        uint256 _balance = OldToken.balanceOf(msg.sender);
        require(_balance <= 0, "You have nothing to migrate");

        OldToken.transferFrom(msg.sender, address(this), _balance);
        this.transfer(msg.sender, _balance);

        emit Migrated(msg.sender, _balance);
    }

    function migrate(uint256 _amount) external {
        uint256 _balance = OldToken.balanceOf(msg.sender);
        require(_balance > 0, "You have nothing to migrate");
        require(_balance >= _amount, "Insufficient balance for migration");

        uint256 _toMigrate = _balance - _amount;

        OldToken.transferFrom(msg.sender, address(this), _toMigrate);
        this.transfer(msg.sender, _toMigrate);

        emit Migrated(msg.sender, _toMigrate);
    }

    function burn() external {
        uint256 _balance = OldToken.balanceOf(DEAD);
        require(_balance > burned, "Nothing to burn");

        uint256 _toBurn = _balance - burned;
        burned = _balance;
        this.transfer(DEAD, _toBurn);

        emit Burned(msg.sender, _toBurn);
    }

    event Migrated(address _user, uint256 _amount);
    event Burned(address _caller, uint256 _burned);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

struct Share {
    uint256 amount;
    uint256 totalExcluded;
    uint256 totalRealised;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../structs/Share.sol";

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function setRouter(address _router) external;

    function deposit() external payable;

    function process(uint256 gas) external;

    function migrateDistributorStates(
        address[] calldata _shareHolders,
        uint256[] calldata _shareHolderIndexes,
        uint256 _currentIndex,
        Share[] calldata _shares,
        uint256 _totalShare,
        uint256 _totalDividends,
        uint256 _totalDistributed,
        uint256 _dividendsPerShare
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
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