//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.15;

import "./interfaces/IBEP20.sol";
import "./interfaces/IDEXFactory.sol";
import "./interfaces/IDEXRouter.sol";
import "./DividendDistributor.sol";
import "./Airdropper.sol";
import "./abstracts/Auth.sol";

contract Ecto is IBEP20, Auth {
    /* BEP20 attributes */
    string constant _name = "LittleGhosts Ectoplasm";
    string constant _symbol = "ECTO";
    uint8 constant _decimals = 9;
    uint256 constant _totalSupply = 1 * (10**12) * (10**_decimals);
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    /* ECTO token attributes */
    uint256 public launchedAt;
    bool public tradingOpen = false;

    /* ECTO token restrictions */
    uint256 public _maxTxAmount = (_totalSupply * 2) / 200;
    uint256 public _walletMax = (_totalSupply * 3) / 100;
    bool public restrictWhales = true;

    /* ECTO token bypass restrictions */
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;
    mapping(address => bool) public isDividendExempt;

    /* Reward token attributes */
    uint256 public liquidityFee = 7;
    uint256 public rewardsFee = 8;
    uint256 public extraFeeOnSell = 0;
    uint256 public totalFee = 0;
    uint256 public totalFeeIfSelling = 0;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    uint256 public swapThreshold = (_totalSupply * 5) / 4000;

    /* Constant variables */
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    /* Circulating Supply */
    address[] public circulatingSupplyExclusions = [DEAD, ZERO];

    /* Router */
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IDEXRouter public router;
    address public pair;

    /* Reward tokens */
    address rewardToken = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47; //BUSD
    bool rewardTokenHasTxFee = false; //Flag for whether the reward token charges transaction fees (transfer, trading, etc)

    /* Dividend distributor */
    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 500000;

    /* Airdropper */
    Airdropper public airdropper;
    address public oldEctoContractAddress;

    /* Team wallet */
    address public teamWallet = 0x896986Db81727B2C7253cE533DF44fC6A42d7A78;

    event TradingStatusChanged(bool status);
    event RouterChanged(address newRouterAddress);
    event DistributorChanged(address distributor);
    event TeamWalletChanged(address newTeamWallet);
    event AddedToCirculatingSupplyExclusion(address _address);
    event RemovedFromCirculatingSupplyExclusion(address _address);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(address _oldContractAddress) Auth(msg.sender) {
        oldEctoContractAddress = _oldContractAddress;
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        dividendDistributor = new DividendDistributor();
        airdropper = new Airdropper(_oldContractAddress);

        _allowances[address(this)][address(router)] = type(uint256).max;
        _allowances[address(airdropper)][address(airdropper)] = type(uint256)
            .max;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[address(airdropper)] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[address(airdropper)] = true;

        isDividendExempt[pair] = true;
        isDividendExempt[address(airdropper)] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[ZERO] = true;

        authorizations[address(airdropper)] = true;

        totalFee = liquidityFee + rewardsFee;
        totalFeeIfSelling = totalFee + extraFeeOnSell;

        _balances[address(airdropper)] = _totalSupply;
        emit Transfer(address(0), address(airdropper), _totalSupply);
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

    function totalSupply() external pure override returns (uint256) {
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
        rewardToken = token;
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

    function changeSwapBackSettings(
        bool enableSwapBack,
        uint256 newSwapBackLimit
    ) external authorized {
        swapAndLiquifyEnabled = enableSwapBack;
        swapThreshold = newSwapBackLimit;
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
            require(
                _allowances[sender][msg.sender] >= amount,
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
        require(_balances[sender] >= amount, "Insufficient Balance");
        _balances[sender] = _balances[sender] - amount;

        if (!isTxLimitExempt[recipient] && restrictWhales) {
            require(
                _balances[recipient] + amount <= _walletMax,
                "Exceeding wallet max"
            );
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
        require(_balances[sender] >= amount, "Insufficient Balance");

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

        _balances[address(this)] = _balances[address(this)] + feeAmount;
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

    function switchDistributor(address _newDistributor) public onlyOwner {
        DividendDistributor _dividendDistributor = DividendDistributor(
            _newDistributor
        );

        DistributorState memory distributorState = dividendDistributor
            .getDistributorState();

        _dividendDistributor.migrateDistributorStates(distributorState);

        dividendDistributor = _dividendDistributor;

        emit DistributorChanged(_newDistributor);
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
pragma solidity ^0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.15;

import "./interfaces/IDividendDistributor.sol";
import "./interfaces/IDEXRouter.sol";
import "./interfaces/IBEP20.sol";
import "./abstracts/TokenGuard.sol";
import "./structs/DistributorState.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DividendDistributor is
    IDividendDistributor,
    ReentrancyGuard,
    TokenGuard
{
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

    constructor() ReentrancyGuard() TokenGuard() {}

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

    function getShareHolders() public view returns (address[] memory) {
        address[] memory _shareHolders = new address[](shareholders.length);
        for (uint256 i = 0; i < shareholders.length; i++) {
            _shareHolders[i] = shareholders[i];
        }
        return _shareHolders;
    }

    function getShareholderIndexes() public view returns (uint256[] memory) {
        uint256[] memory indexes = new uint256[](shareholders.length);

        for (uint256 i = 0; i < shareholders.length; i++) {
            indexes[i] = shareholderIndexes[shareholders[i]];
        }
        return indexes;
    }

    function getShareholderClaims() public view returns (uint256[] memory) {
        uint256[] memory claims = new uint256[](shareholders.length);

        for (uint256 i = 0; i < shareholders.length; i++) {
            claims[i] = shareholderClaims[shareholders[i]];
        }
        return claims;
    }

    function getShares() public view returns (Share[] memory) {
        Share[] memory _shares = new Share[](shareholders.length);

        for (uint256 i = 0; i < shareholders.length; i++) {
            _shares[i] = shares[shareholders[i]];
        }
        return _shares;
    }

    function getDistributorState()
        external
        view
        returns (DistributorState memory)
    {
        DistributorState memory distributorState;

        for (uint256 i = 0; i < shareholders.length; i++) {
            distributorState.holders[i] = shareholders[i];
            distributorState.indexes[i] = shareholderIndexes[shareholders[i]];
            distributorState.claims[i] = shareholderClaims[shareholders[i]];
            distributorState.amounts[i] = shares[shareholders[i]].amount;
            distributorState.totalExcluded[i] = shares[shareholders[i]]
                .totalExcluded;
            distributorState.totalRealised[i] = shares[shareholders[i]]
                .totalRealised;
        }
        distributorState.currentIndex = currentIndex;
        distributorState.totalShares = totalShares;
        distributorState.totalDividends = totalDividends;
        distributorState.totalDistributed = totalDistributed;
        distributorState.dividendsPerShare = dividendsPerShare;

        return distributorState;
    }

    function migrateDistributorStates(
        DistributorState calldata distributorState
    ) external override {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interfaces/IBEP20.sol";

/**
 * @notice This contract aids migration for a BEP20 token.
 * @dev This contract assumes the total supply of the new token is the same as the total supply of
 * old token, and will migrate tokens with 1:1 ratio.
 */
contract Airdropper {
    /* Constant variables */
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    /* Address of the old token */
    address public oldTokenAddress;

    /* Address of the new token */
    address public newTokenAddress;

    /* To keep track of migrated tokens for burned address */
    uint256 public burned;

    /* Token that will be received in exchange of new token */
    IBEP20 internal OldToken;

    /* Token that will be airdropped */
    IBEP20 internal NewToken;

    constructor(address _oldTokenAddress) {
        /* Set old BEP20 token */
        oldTokenAddress = _oldTokenAddress;
        OldToken = IBEP20(_oldTokenAddress);

        /* Set new BEP20 token */
        newTokenAddress = msg.sender;
        NewToken = IBEP20(msg.sender);
    }

    /**
     * Allows users to migrate all of their old tokens at once
     */
    function migrate() external {
        uint256 _balance = OldToken.balanceOf(msg.sender);
        require(_balance > 0, "You have nothing to migrate");

        OldToken.transferFrom(msg.sender, address(this), _balance);
        NewToken.transferFrom(address(this), msg.sender, _balance);

        emit Migrated(msg.sender, _balance);
    }

    /**
     * Allows users to migrate part of their old tokens
     * @param _amount the amount of tokens to migrate
     */
    function migrate(uint256 _amount) external {
        uint256 _balance = OldToken.balanceOf(msg.sender);
        require(_amount > 0, "Amount cannot be zero");
        require(_balance > 0, "You have nothing to migrate");
        require(_balance >= _amount, "Insufficient balance for migration");

        OldToken.transferFrom(msg.sender, address(this), _amount);
        NewToken.transferFrom(address(this), msg.sender, _amount);

        emit Migrated(msg.sender, _amount);
    }

    /**
     * Match the amount of new tokens in the burned address with the old tokens
     * that were sent to the burned address
     */
    function burn() external {
        uint256 _balance = OldToken.balanceOf(DEAD);
        require(_balance > burned, "Nothing to burn");

        uint256 _toBurn = _balance - burned;
        burned = _balance;
        NewToken.transferFrom(address(this), DEAD, _toBurn);

        emit Burned(msg.sender, _toBurn);
    }

    event Migrated(address _user, uint256 _amount);
    event Burned(address _caller, uint256 _burned);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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
pragma solidity ^0.8.15;

import "../structs/Share.sol";
import "../structs/DistributorState.sol";

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
        DistributorState calldata distributorState
    ) external;

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

abstract contract TokenGuard {
    address _token;

    constructor() {
        _token = msg.sender;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

struct DistributorState {
    address[] holders;
    uint256[] indexes;
    uint256[] claims;
    uint256[] amounts;
    uint256[] totalExcluded;
    uint256[] totalRealised;
    uint256 currentIndex;
    uint256 totalShares;
    uint256 totalDividends;
    uint256 totalDistributed;
    uint256 dividendsPerShare;
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
pragma solidity ^0.8.15;

struct Share {
    uint256 amount;
    uint256 totalExcluded;
    uint256 totalRealised;
}